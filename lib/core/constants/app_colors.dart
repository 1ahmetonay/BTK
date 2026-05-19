import 'package:flutter/material.dart';

/// Merkezi renk paleti — tum uygulama genelinde bu sabitler kullanilir.
class AppColors {
  const AppColors._();

  // ── Primary (Koyu lacivert) ───────────────────────────────────────
  static const Color primary = Color(0xFF002045);
  static const Color primaryDark = Color(0xFF1A365D);
  static const Color primaryLight = Color(0xFFADC7F7);

  // ── Secondary (Yesil) ─────────────────────────────────────────────
  static const Color secondary = Color(0xFF2C694E);
  static const Color secondaryContainer = Color(0xFFB1F0CE);
  static const Color onSecondaryContainer = Color(0xFF0E5138);
  static const Color secondaryLight = Color(0xFF95D4B3);
  static const Color secondaryBg = Color(0xFFF4F8F6);
  static const Color secondaryBorder = Color(0xFFD0E8DB);
  static const Color emeraldDark = Color(0xFF1a4d2e);

  // ── Error / Danger ────────────────────────────────────────────────
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorDark = Color(0xFF93000A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color errorSurface = Color(0xFFFFE4E6);
  static const Color errorSurfaceLight = Color(0xFFFFF8F8);
  static const Color errorLight = Color(0xFFF2B8B5);

  // ── Warning ───────────────────────────────────────────────────────
  static const Color warning = Color(0xFFC6955E);
  static const Color warningDark = Color(0xFF4F2E00);
  static const Color warningAmber = Color(0xFFF59E0B);
  static const Color warningContainer = Color(0xFFFEF3C7);
  static const Color warningSurface = Color(0xFFFFF7ED);
  static const Color warningBorder = Color(0xFFFCD9BD);
  static const Color warningLight = Color(0xFFFFDDBA);
  static const Color warningSurfaceWarm = Color(0xFFF1EEE8);
  static const Color warningMuted = Color(0xFFD8C7B3);

  // ── Success ───────────────────────────────────────────────────────
  static const Color successContainer = Color(0xFFDCFCE7);
  static const Color successBg = Color(0xFFF0FFF4);
  static const Color successLight = Color(0xFFAEEECB);
  static const Color successSurface = Color(0xFFEFF8F3);

  // ── Info ───────────────────────────────────────────────────────────
  static const Color infoContainer = Color(0xFFDBEAFE);
  static const Color infoSurface = Color(0xFFEFF6FF);
  static const Color infoLight = Color(0xFFD6E3FF);
  static const Color infoBorder = Color(0xFFBFDBFE);
  static const Color infoLighter = Color(0xFFE0F2FE);
  static const Color infoDark = Color(0xFF075985);

  // ── Text / On-Surface ─────────────────────────────────────────────
  static const Color ink = Color(0xFF172033);
  static const Color onSurface = Color(0xFF191C1D);
  static const Color nearBlack = Color(0xFF1D1D1F);
  static const Color mutedText = Color(0xFF43474E);
  static const Color muted = Color(0xFF667085);
  static const Color neutral = Color(0xFF74777F);

  // ── Surface / Background ──────────────────────────────────────────
  static const Color surface = Color(0xFFF6F8FB);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color surfaceUltraLight = Color(0xFFF8FAFC);
  static const Color surfaceContainerLow = Color(0xFFF8F9FA);
  static const Color surfaceLow = Color(0xFFF3F4F5);
  static const Color surfaceCool = Color(0xFFF1F5F9);
  static const Color surfaceHigh = Color(0xFFE7E8E9);
  static const Color surfaceDim = Color(0xFFEDEEEF);
  static const Color highlightedSurface = Color(0xFFFFF7F5);

  // ── Outline / Border ──────────────────────────────────────────────
  static const Color outline = Color(0xFFC4C6CF);
  static const Color outlineSoft = Color(0xFFE1E3E4);
  static const Color line = Color(0xFFE4E7EC);
  static const Color gray200 = Color(0xFFE5E7EB);

  // ── Neutral Container ─────────────────────────────────────────────
  static const Color neutralContainer = Color(0xFFF2F4F7);

  // ── Sidebar ───────────────────────────────────────────────────────
  static const Color sidebar = Color(0xFF101828);
  static const Color sidebarActive = Color(0xFF1D2939);
  static const Color sidebarHover = Color(0xFF182230);
  static const Color sidebarMuted = Color(0xFF98A2B3);
  static const Color sidebarText = Color(0xFFD0D5DD);
  static const Color sidebarSubtle = Color(0xFF344054);

  // ── Legacy aliases (eski AppColors uyumlulugu) ────────────────────
  static const Color teal = Color(0xFF0F766E);
  static const Color emerald = Color(0xFF059669);
  static const Color amber = Color(0xFFD97706);
  static const Color rose = Color(0xFFE11D48);

  // ── Alpha variants ────────────────────────────────────────────────
  static const Color primaryOverlay = Color(0x1A002045);

  // ── EAB308 (sarı uyarı) ───────────────────────────────────────────
  static const Color yellowWarning = Color(0xFFEAB308);
}
