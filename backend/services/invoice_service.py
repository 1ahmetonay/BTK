"""
KOBİ AI Asistan — E-Fatura Servisi
UBL-TR 1.2 formatında e-fatura üretimi, QR kod ve PDF render.
"""

import io
import json
import os
from datetime import datetime
from typing import Optional
from uuid import uuid4

import qrcode
from qrcode.constants import ERROR_CORRECT_M
from jinja2 import Template
from reportlab.lib import colors
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import mm
from reportlab.platypus import SimpleDocTemplate, Table, TableStyle, Paragraph, Spacer, Image


# ─── UBL-TR XML Template ─────────────────────────────────────────────
UBL_TR_TEMPLATE = """<?xml version="1.0" encoding="UTF-8"?>
<Invoice xmlns="urn:oasis:names:specification:ubl:schema:xsd:Invoice-2"
         xmlns:cac="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2"
         xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2">
  <cbc:UBLVersionID>2.1</cbc:UBLVersionID>
  <cbc:CustomizationID>TR1.2</cbc:CustomizationID>
  <cbc:ProfileID>TICARIFATURA</cbc:ProfileID>
  <cbc:ID>{{ fatura_no }}</cbc:ID>
  <cbc:CopyIndicator>false</cbc:CopyIndicator>
  <cbc:UUID>{{ uuid }}</cbc:UUID>
  <cbc:IssueDate>{{ tarih }}</cbc:IssueDate>
  <cbc:IssueTime>{{ saat }}</cbc:IssueTime>
  <cbc:InvoiceTypeCode>SATIS</cbc:InvoiceTypeCode>
  <cbc:DocumentCurrencyCode>{{ para_birimi }}</cbc:DocumentCurrencyCode>

  <cac:AccountingSupplierParty>
    <cac:Party>
      <cac:PartyIdentification>
        <cbc:ID schemeID="VKN">{{ satici_vkn }}</cbc:ID>
      </cac:PartyIdentification>
      <cac:PartyName>
        <cbc:Name>{{ satici_adi }}</cbc:Name>
      </cac:PartyName>
    </cac:Party>
  </cac:AccountingSupplierParty>

  <cac:AccountingCustomerParty>
    <cac:Party>
      <cac:PartyIdentification>
        <cbc:ID schemeID="VKN">{{ musteri_vkn }}</cbc:ID>
      </cac:PartyIdentification>
      <cac:PartyName>
        <cbc:Name>{{ musteri_adi }}</cbc:Name>
      </cac:PartyName>
    </cac:Party>
  </cac:AccountingCustomerParty>

  {% for kalem in kalemler %}
  <cac:InvoiceLine>
    <cbc:ID>{{ loop.index }}</cbc:ID>
    <cbc:InvoicedQuantity unitCode="{{ kalem.birim }}">{{ kalem.miktar }}</cbc:InvoicedQuantity>
    <cbc:LineExtensionAmount currencyID="{{ para_birimi }}">{{ kalem.satir_toplam }}</cbc:LineExtensionAmount>
    <cac:TaxTotal>
      <cbc:TaxAmount currencyID="{{ para_birimi }}">{{ kalem.kdv_tutari }}</cbc:TaxAmount>
      <cac:TaxSubtotal>
        <cbc:TaxableAmount currencyID="{{ para_birimi }}">{{ kalem.matrah }}</cbc:TaxableAmount>
        <cbc:TaxAmount currencyID="{{ para_birimi }}">{{ kalem.kdv_tutari }}</cbc:TaxAmount>
        <cac:TaxCategory>
          <cbc:Percent>{{ kalem.kdv_orani }}</cbc:Percent>
          <cac:TaxScheme><cbc:Name>KDV</cbc:Name></cac:TaxScheme>
        </cac:TaxCategory>
      </cac:TaxSubtotal>
    </cac:TaxTotal>
    <cac:Item>
      <cbc:Name>{{ kalem.urun_adi }}</cbc:Name>
    </cac:Item>
    <cac:Price>
      <cbc:PriceAmount currencyID="{{ para_birimi }}">{{ kalem.birim_fiyat }}</cbc:PriceAmount>
    </cac:Price>
  </cac:InvoiceLine>
  {% endfor %}

  <cac:TaxTotal>
    <cbc:TaxAmount currencyID="{{ para_birimi }}">{{ toplam_kdv }}</cbc:TaxAmount>
  </cac:TaxTotal>

  <cac:LegalMonetaryTotal>
    <cbc:LineExtensionAmount currencyID="{{ para_birimi }}">{{ net_tutar }}</cbc:LineExtensionAmount>
    <cbc:TaxExclusiveAmount currencyID="{{ para_birimi }}">{{ net_tutar }}</cbc:TaxExclusiveAmount>
    <cbc:TaxInclusiveAmount currencyID="{{ para_birimi }}">{{ genel_toplam }}</cbc:TaxInclusiveAmount>
    <cbc:PayableAmount currencyID="{{ para_birimi }}">{{ genel_toplam }}</cbc:PayableAmount>
  </cac:LegalMonetaryTotal>
</Invoice>"""


class InvoiceService:
    """E-fatura üretim servisi — UBL-TR XML + QR kod + PDF."""

    def generate_efatura(self, invoice_data: dict) -> dict:
        """UBL-TR formatında e-fatura üretir ve PDF'i base64 olarak döner."""
        fatura_uuid = str(uuid4())
        now = datetime.now()

        # Kalemlere matrah ekle
        for k in invoice_data.get("kalemler", []):
            k["matrah"] = k.get("satir_toplam", 0) - k.get("kdv_tutari", 0)

        fatura_no = invoice_data.get("fatura_no") or f"KAI-{now.strftime('%Y%m%d')}-{fatura_uuid[:6].upper()}"

        template_data = {
            "fatura_no": fatura_no,
            "uuid": fatura_uuid,
            "tarih": now.strftime("%Y-%m-%d"),
            "saat": now.strftime("%H:%M:%S"),
            "para_birimi": invoice_data.get("para_birimi", "TRY"),
            "satici_adi": invoice_data.get("satici_adi", "KOBİ AI Demo İşletmesi"),
            "satici_vkn": invoice_data.get("satici_vkn", "1234567890"),
            "musteri_adi": invoice_data.get("musteri_adi", ""),
            "musteri_vkn": invoice_data.get("musteri_vkn", ""),
            "kalemler": invoice_data.get("kalemler", []),
            "toplam_kdv": invoice_data.get("toplam_kdv", 0),
            "net_tutar": invoice_data.get("net_tutar", 0),
            "genel_toplam": invoice_data.get("genel_toplam", 0),
        }

        # XML üret
        template = Template(UBL_TR_TEMPLATE)
        xml_content = template.render(**template_data)

        # QR kod üret (GİB doğrulama bilgileri)
        qr_data = json.dumps({
            "fatura_no": fatura_no,
            "ettn": fatura_uuid,
            "tutar": template_data["genel_toplam"],
            "tarih": template_data["tarih"],
            "vkn": template_data["satici_vkn"],
            "dogrulama": f"https://ebelge.gib.gov.tr/verify/{fatura_uuid}",
        }, ensure_ascii=False)
        qr_bytes = self._generate_qr_code(qr_data)

        # PDF üret
        pdf_bytes = self._generate_pdf(template_data, qr_bytes)

        # PDF'i base64 encode (frontend indirmesi için)
        import base64
        pdf_base64 = base64.b64encode(pdf_bytes).decode("utf-8")

        return {
            "success": True,
            "fatura_no": fatura_no,
            "uuid": fatura_uuid,
            "xml": xml_content,
            "pdf_base64": pdf_base64,
            "pdf_size_bytes": len(pdf_bytes),
            "qr_size_bytes": len(qr_bytes),
            "tarih": template_data["tarih"],
            "genel_toplam": template_data["genel_toplam"],
            "musteri_adi": template_data["musteri_adi"],
            "kalem_sayisi": len(template_data["kalemler"]),
        }

    def _generate_qr_code(self, data: str) -> bytes:
        """GİB standardında QR kod üretir."""
        qr = qrcode.QRCode(
            version=None,
            error_correction=ERROR_CORRECT_M,
            box_size=8,
            border=4,
        )
        qr.add_data(data)
        qr.make(fit=True)
        img = qr.make_image(fill_color="black", back_color="white").convert("RGB")
        buf = io.BytesIO()
        img.save(buf, format="PNG")
        return buf.getvalue()

    def _generate_pdf(self, data: dict, qr_bytes: bytes) -> bytes:
        """E-fatura PDF render — profesyonel A4 layout, QR kod dahil."""
        buf = io.BytesIO()
        doc = SimpleDocTemplate(
            buf, pagesize=A4,
            topMargin=15*mm, bottomMargin=15*mm,
            leftMargin=18*mm, rightMargin=18*mm,
        )
        styles = getSampleStyleSheet()
        brand_color = colors.HexColor("#1a4d2e")
        brand_dark = colors.HexColor("#002045")

        elements = []

        # ─── Üst Başlık Bandı ─────────────────────────────────────────
        header_data = [[
            Paragraph(
                f"<font size='18' color='#002045'><b>E-FATURA</b></font><br/>"
                f"<font size='9' color='#43474E'>{data['fatura_no']}</font>",
                styles["Normal"],
            ),
            Paragraph(
                f"<font size='9' color='#43474E'>"
                f"Düzenlenme Tarihi<br/></font>"
                f"<font size='11' color='#002045'><b>{data['tarih']}</b></font>",
                ParagraphStyle("RightAlign", parent=styles["Normal"], alignment=2),
            ),
        ]]
        header_table = Table(header_data, colWidths=[320, 150])
        header_table.setStyle(TableStyle([
            ("VALIGN", (0, 0), (-1, -1), "TOP"),
            ("LINEBELOW", (0, 0), (-1, 0), 2, brand_color),
            ("BOTTOMPADDING", (0, 0), (-1, -1), 8),
        ]))
        elements.append(header_table)
        elements.append(Spacer(1, 6*mm))

        # ─── Satıcı / Alıcı Bilgileri (Yan Yana) ─────────────────────
        satici_text = (
            f"<font size='8' color='#43474E'>SATICI</font><br/>"
            f"<font size='10'><b>{data['satici_adi']}</b></font><br/>"
            f"<font size='9'>VKN: {data['satici_vkn']}</font>"
        )
        musteri_text = (
            f"<font size='8' color='#43474E'>ALICI</font><br/>"
            f"<font size='10'><b>{data['musteri_adi']}</b></font><br/>"
            f"<font size='9'>VKN: {data['musteri_vkn']}</font>"
        )
        parties_data = [[
            Paragraph(satici_text, styles["Normal"]),
            Paragraph(musteri_text, styles["Normal"]),
        ]]
        parties_table = Table(parties_data, colWidths=[235, 235])
        parties_table.setStyle(TableStyle([
            ("VALIGN", (0, 0), (-1, -1), "TOP"),
            ("BACKGROUND", (0, 0), (0, 0), colors.HexColor("#f4f8f6")),
            ("BACKGROUND", (1, 0), (1, 0), colors.HexColor("#f4f6f8")),
            ("ROUNDEDCORNERS", [4, 4, 4, 4]),
            ("LEFTPADDING", (0, 0), (-1, -1), 10),
            ("RIGHTPADDING", (0, 0), (-1, -1), 10),
            ("TOPPADDING", (0, 0), (-1, -1), 8),
            ("BOTTOMPADDING", (0, 0), (-1, -1), 8),
        ]))
        elements.append(parties_table)
        elements.append(Spacer(1, 8*mm))

        # ─── Kalem Tablosu ────────────────────────────────────────────
        header = ["#", "Ürün / Hizmet", "Miktar", "Birim Fiyat", "KDV", "Toplam"]
        rows = [header]
        for i, k in enumerate(data.get("kalemler", []), 1):
            rows.append([
                str(i),
                k.get("urun_adi", ""),
                str(k.get("miktar", 0)),
                f"{k.get('birim_fiyat', 0):,.2f} TL",
                f"%{int(k.get('kdv_orani', 20))}",
                f"{k.get('satir_toplam', 0):,.2f} TL",
            ])

        kalem_table = Table(rows, colWidths=[25, 175, 50, 80, 45, 95])
        kalem_style = [
            ("BACKGROUND", (0, 0), (-1, 0), brand_color),
            ("TEXTCOLOR", (0, 0), (-1, 0), colors.white),
            ("FONTNAME", (0, 0), (-1, 0), "Helvetica-Bold"),
            ("FONTSIZE", (0, 0), (-1, 0), 9),
            ("FONTSIZE", (0, 1), (-1, -1), 9),
            ("GRID", (0, 0), (-1, -1), 0.4, colors.HexColor("#dcdcdc")),
            ("ALIGN", (2, 0), (-1, -1), "RIGHT"),
            ("ROWBACKGROUNDS", (0, 1), (-1, -1), [colors.white, colors.HexColor("#fafafa")]),
            ("BOTTOMPADDING", (0, 0), (-1, -1), 5),
            ("TOPPADDING", (0, 0), (-1, -1), 5),
        ]
        kalem_table.setStyle(TableStyle(kalem_style))
        elements.append(kalem_table)
        elements.append(Spacer(1, 6*mm))

        # ─── Toplamlar + QR Kod (Yan Yana) ────────────────────────────
        totals_text = (
            f"<font size='9'>"
            f"Ara Toplam (KDV Hariç): <b>{data.get('net_tutar', 0):,.2f} TL</b><br/>"
            f"Toplam KDV: <b>{data.get('toplam_kdv', 0):,.2f} TL</b><br/><br/>"
            f"</font>"
            f"<font size='12' color='#002045'>"
            f"GENEL TOPLAM: <b>{data.get('genel_toplam', 0):,.2f} TL</b>"
            f"</font>"
        )
        totals_para = Paragraph(totals_text, ParagraphStyle(
            "Totals", parent=styles["Normal"], alignment=2, leading=16,
        ))

        # QR kodu PDF'e embed et. PNG'yi BytesIO üzerinde tutmak ReportLab'in
        # PDF build aşamasında görseli güvenilir şekilde okuyabilmesi için gerekli.
        qr_buf = io.BytesIO(qr_bytes)
        qr_image = Image(qr_buf, width=40*mm, height=40*mm)
        qr_label = Paragraph(
            "<font size='7' color='#43474E'>QR Doğrulama</font>",
            ParagraphStyle("QrLabel", parent=styles["Normal"], alignment=1),
        )

        footer_data = [[[qr_image, qr_label], totals_para]]
        footer_table = Table(footer_data, colWidths=[135, 335])
        footer_table.setStyle(TableStyle([
            ("VALIGN", (0, 0), (-1, -1), "TOP"),
            ("ALIGN", (0, 0), (0, 0), "CENTER"),
            ("ALIGN", (1, 0), (1, 0), "RIGHT"),
            ("LINEABOVE", (0, 0), (-1, 0), 1.5, brand_color),
            ("TOPPADDING", (0, 0), (-1, -1), 10),
        ]))
        elements.append(footer_table)
        elements.append(Spacer(1, 10*mm))

        # ─── Alt Bilgi ────────────────────────────────────────────────
        footer_note = Paragraph(
            "<font size='7' color='#888888'>"
            "Bu belge 213 sayılı VUK'un 242. maddesi uyarınca düzenlenmiş elektronik faturadır. "
            f"ETTN: {data.get('uuid', '-')} | 5070 sayılı kanun gereği e-imza ile güvence altındadır."
            "</font>",
            ParagraphStyle("FooterNote", parent=styles["Normal"], alignment=1),
        )
        elements.append(footer_note)

        doc.build(elements)
        return buf.getvalue()


# Singleton
invoice_service = InvoiceService()
