import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/services/api_service.dart';

/// E-Fatura kesme dialog'u — form doldurup fatura üretir.
/// Herhangi bir sayfadan `showEFaturaDialog(context)` ile açılır.
Future<Map<String, dynamic>?> showEFaturaDialog(BuildContext context) {
  return showDialog<Map<String, dynamic>>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const _EFaturaDialog(),
  );
}

class _EFaturaDialog extends StatefulWidget {
  const _EFaturaDialog();

  @override
  State<_EFaturaDialog> createState() => _EFaturaDialogState();
}

class _EFaturaDialogState extends State<_EFaturaDialog> {
  final _formKey = GlobalKey<FormState>();
  final _musteriAdiController = TextEditingController();
  final _musteriVknController = TextEditingController();

  final List<_FaturaKalem> _kalemler = [_FaturaKalem()];
  bool _loading = false;
  Map<String, dynamic>? _result;
  String? _error;

  @override
  void dispose() {
    _musteriAdiController.dispose();
    _musteriVknController.dispose();
    for (final k in _kalemler) {
      k.dispose();
    }
    super.dispose();
  }

  double get _araToplam =>
      _kalemler.fold(0, (sum, k) => sum + k.miktar * k.birimFiyat);

  double get _toplamKdv =>
      _kalemler.fold(0, (sum, k) => sum + k.miktar * k.birimFiyat * k.kdvOrani / 100);

  double get _genelToplam => _araToplam + _toplamKdv;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: isWide ? 80 : 16,
        vertical: 24,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 700),
        child: _result != null ? _buildResult() : _buildForm(),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Başlık
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
          decoration: const BoxDecoration(
            color: Color(0xFF002045),
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Row(
            children: [
              const Icon(Icons.receipt_long, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'E-Fatura Kes',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'UBL-TR 1.2 • QR Kod • PDF',
                      style: TextStyle(color: Color(0xFFAEEECB), fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white70),
              ),
            ],
          ),
        ),

        // Form
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Müşteri bilgileri
                  const Text(
                    'Müşteri Bilgileri',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: _musteriAdiController,
                          decoration: _inputDecor('Müşteri / Firma Adı'),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Zorunlu' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _musteriVknController,
                          decoration: _inputDecor('VKN / TCKN'),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(11),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Kalemler
                  Row(
                    children: [
                      const Text(
                        'Fatura Kalemleri',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () => setState(() => _kalemler.add(_FaturaKalem())),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Kalem Ekle'),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF1a4d2e),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  ...List.generate(_kalemler.length, (i) => _buildKalemRow(i)),

                  const SizedBox(height: 16),

                  // Toplam
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F8F6),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFD0E8DB)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _totalRow('Ara Toplam', _araToplam),
                        _totalRow('KDV', _toplamKdv),
                        const Divider(height: 16),
                        _totalRow('Genel Toplam', _genelToplam, bold: true, large: true),
                      ],
                    ),
                  ),

                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                  ],
                ],
              ),
            ),
          ),
        ),

        // Butonlar
        Container(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
          child: Row(
            children: [
              OutlinedButton(
                onPressed: _loading ? null : () => Navigator.pop(context),
                child: const Text('İptal'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _loading ? null : _submitInvoice,
                  icon: _loading
                      ? const SizedBox(
                          width: 18, height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send),
                  label: Text(_loading ? 'Oluşturuluyor...' : 'Fatura Kes'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1a4d2e),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKalemRow(int index) {
    final kalem = _kalemler[index];
    return Padding(
      key: ValueKey('kalem_$index'),
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ürün adı
          Expanded(
            flex: 4,
            child: TextFormField(
              controller: kalem.urunAdiCtrl,
              decoration: _inputDecor('Ürün/Hizmet'),
              style: const TextStyle(fontSize: 13),
              validator: (v) => (v == null || v.trim().isEmpty) ? '' : null,
            ),
          ),
          const SizedBox(width: 8),
          // Miktar
          Expanded(
            flex: 1,
            child: TextFormField(
              controller: kalem.miktarCtrl,
              decoration: _inputDecor('Adet'),
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 13),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(width: 8),
          // Birim fiyat
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: kalem.fiyatCtrl,
              decoration: _inputDecor('Birim Fiyat (TL)'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(fontSize: 13),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(width: 8),
          // KDV
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<int>(
              initialValue: kalem.kdvOraniInt,
              items: const [
                DropdownMenuItem(value: 1, child: Text('%1')),
                DropdownMenuItem(value: 10, child: Text('%10')),
                DropdownMenuItem(value: 20, child: Text('%20')),
              ],
              onChanged: (v) => setState(() => kalem.kdvOraniInt = v ?? 20),
              decoration: _inputDecor('KDV'),
              isExpanded: true,
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ),
          // Sil butonu
          if (_kalemler.length > 1)
            IconButton(
              onPressed: () => setState(() {
                _kalemler[index].dispose();
                _kalemler.removeAt(index);
              }),
              icon: const Icon(Icons.close, size: 18, color: Colors.red),
              padding: const EdgeInsets.only(top: 8),
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }

  Widget _totalRow(String label, double value, {bool bold = false, bool large = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: large ? 15 : 13,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
              color: const Color(0xFF43474E),
            ),
          ),
          const SizedBox(width: 24),
          Text(
            '${value.toStringAsFixed(2)} TL',
            style: TextStyle(
              fontSize: large ? 16 : 13,
              fontWeight: bold ? FontWeight.w900 : FontWeight.w600,
              color: bold ? const Color(0xFF002045) : const Color(0xFF1a4d2e),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResult() {
    final fNo = _result!['fatura_no'] ?? '';
    final toplam = _result!['genel_toplam'] ?? 0;
    final musteri = _result!['musteri_adi'] ?? '';
    final pdfBase64 = _result!['pdf_base64'] as String?;

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF1a4d2e), size: 56),
          const SizedBox(height: 16),
          const Text(
            'E-Fatura Oluşturuldu',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 20),
          _resultRow('Fatura No', fNo.toString()),
          _resultRow('Müşteri', musteri.toString()),
          _resultRow('Genel Toplam', '${(toplam as num).toStringAsFixed(2)} TL'),
          _resultRow('Tarih', _result!['tarih']?.toString() ?? '-'),
          const SizedBox(height: 20),
          const Text(
            'PDF, UBL-TR XML ve QR kod başarıyla üretildi.\nStok ve nakit akışı otomatik güncellendi.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Color(0xFF43474E), height: 1.5),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: () => Navigator.pop(context, _result),
                icon: const Icon(Icons.close),
                label: const Text('Kapat'),
              ),
              if (pdfBase64 != null && pdfBase64.isNotEmpty) ...[
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: () => _downloadPdf(pdfBase64),
                  icon: const Icon(Icons.download),
                  label: const Text('PDF İndir'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1a4d2e),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _resultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: Color(0xFF43474E)),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  void _downloadPdf(String base64Data) {
    // Web'de base64 PDF indirme
    // ignore: avoid_web_libraries_in_flutter
    // Bu kısım web için çalışır; mobilde farkl�� yöntem gerekir
    try {
      final bytes = base64Decode(base64Data);
      // Basit bildirim — gerçek indirme için platform-specific kod gerekir
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF hazır (${(bytes.length / 1024).toStringAsFixed(1)} KB)'),
          backgroundColor: const Color(0xFF1a4d2e),
        ),
      );
    } catch (_) {
      // Fallback
    }
  }

  Future<void> _submitInvoice() async {
    if (!_formKey.currentState!.validate()) return;
    if (_kalemler.any((k) => k.urunAdiCtrl.text.trim().isEmpty)) {
      setState(() => _error = 'Tüm kalem alanlarını doldurun.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final kalemler = _kalemler.map((k) {
        final miktar = k.miktar;
        final fiyat = k.birimFiyat;
        final kdv = k.kdvOrani;
        final matrah = miktar * fiyat;
        final kdvTutari = matrah * kdv / 100;
        return {
          'urun_adi': k.urunAdiCtrl.text.trim(),
          'miktar': miktar,
          'birim': 'adet',
          'birim_fiyat': fiyat,
          'kdv_orani': kdv,
          'kdv_tutari': kdvTutari,
          'satir_toplam': matrah + kdvTutari,
        };
      }).toList();

      final result = await ApiService.instance.generateEfatura({
        'musteri_adi': _musteriAdiController.text.trim(),
        'musteri_vkn': _musteriVknController.text.trim(),
        'kalemler': kalemler,
      });

      if (!mounted) return;
      setState(() {
        _result = result;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Fatura oluşturulamadı: $e';
        _loading = false;
      });
    }
  }

  InputDecoration _inputDecor(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 12),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFC4C6CF)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF1a4d2e), width: 1.5),
      ),
    );
  }
}

/// Tek bir fatura kalemi verisi
class _FaturaKalem {
  final urunAdiCtrl = TextEditingController();
  final miktarCtrl = TextEditingController(text: '1');
  final fiyatCtrl = TextEditingController();
  int kdvOraniInt = 20;

  double get miktar => double.tryParse(miktarCtrl.text) ?? 0;
  double get birimFiyat => double.tryParse(fiyatCtrl.text) ?? 0;
  double get kdvOrani => kdvOraniInt.toDouble();

  void dispose() {
    urunAdiCtrl.dispose();
    miktarCtrl.dispose();
    fiyatCtrl.dispose();
  }
}
