import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/status_badge.dart';

enum AttendanceStatus { normal, highOvertime, needsReview }

extension AttendanceStatusView on AttendanceStatus {
  String get label {
    return switch (this) {
      AttendanceStatus.normal => 'Normal',
      AttendanceStatus.highOvertime => 'Yüksek Mesai',
      AttendanceStatus.needsReview => 'Kontrol Gerekli',
    };
  }

  StatusTone get tone {
    return switch (this) {
      AttendanceStatus.normal => StatusTone.success,
      AttendanceStatus.highOvertime => StatusTone.warning,
      AttendanceStatus.needsReview => StatusTone.danger,
    };
  }

  Color get color {
    return switch (this) {
      AttendanceStatus.normal => AppColors.emerald,
      AttendanceStatus.highOvertime => AppColors.amber,
      AttendanceStatus.needsReview => AppColors.rose,
    };
  }
}

class AttendanceSummaryMock {
  const AttendanceSummaryMock({
    required this.title,
    required this.value,
    required this.description,
    required this.trend,
    required this.trendTone,
    required this.icon,
    required this.accentColor,
  });

  final String title;
  final String value;
  final String description;
  final String trend;
  final StatusTone trendTone;
  final IconData icon;
  final Color accentColor;
}

class EmployeeAttendanceMock {
  const EmployeeAttendanceMock({
    required this.employeeName,
    required this.position,
    required this.workDays,
    required this.overtime,
    required this.leaveDays,
    required this.estimatedNetSalary,
    required this.status,
    required this.attendanceRate,
  });

  final String employeeName;
  final String position;
  final String workDays;
  final String overtime;
  final String leaveDays;
  final String estimatedNetSalary;
  final AttendanceStatus status;
  final double attendanceRate;
}

class AttendanceIssueMock {
  const AttendanceIssueMock({
    required this.employeeName,
    required this.description,
  });

  final String employeeName;
  final String description;
}

class SalarySummaryMock {
  const SalarySummaryMock({
    required this.baseSalaryTotal,
    required this.overtimePayment,
    required this.deductionEffect,
    required this.totalPersonnelCost,
    required this.aiComment,
  });

  final String baseSalaryTotal;
  final String overtimePayment;
  final String deductionEffect;
  final String totalPersonnelCost;
  final String aiComment;
}

class AttendanceMovementMock {
  const AttendanceMovementMock({
    required this.title,
    required this.detail,
    required this.timestamp,
    required this.icon,
    this.iconColor = AppColors.primary,
  });

  final String title;
  final String detail;
  final String timestamp;
  final IconData icon;
  final Color iconColor;
}

class EmployeeInsightMock {
  const EmployeeInsightMock({
    required this.message,
    required this.icon,
    this.iconColor = AppColors.primary,
  });

  final String message;
  final IconData icon;
  final Color iconColor;
}

class EmployeesMockData {
  const EmployeesMockData._();

  static const selectedFileName = 'mayis_2026_puantaj.jpg';

  static const summaryCards = [
    AttendanceSummaryMock(
      title: 'Aktif Çalışan',
      value: '5',
      description: 'Mayıs 2026 puantajında',
      trend: 'Tüm kayıtlar işlendi',
      trendTone: StatusTone.success,
      icon: Icons.groups_2_outlined,
      accentColor: AppColors.primary,
    ),
    AttendanceSummaryMock(
      title: 'Toplam Mesai',
      value: '30 saat',
      description: 'Bu dönem ek mesai',
      trend: '+8 saat',
      trendTone: StatusTone.warning,
      icon: Icons.more_time_outlined,
      accentColor: AppColors.amber,
    ),
    AttendanceSummaryMock(
      title: 'İzin Günü',
      value: '6',
      description: 'Toplam izin/devamsızlık',
      trend: '1 kayıt kontrol gerekli',
      trendTone: StatusTone.danger,
      icon: Icons.event_busy_outlined,
      accentColor: AppColors.rose,
    ),
    AttendanceSummaryMock(
      title: 'Tahmini Personel Gideri',
      value: '22.900 TL',
      description: 'Maaş + mesai etkisi',
      trend: 'Finansa aktarılacak',
      trendTone: StatusTone.info,
      icon: Icons.payments_outlined,
      accentColor: AppColors.teal,
    ),
  ];

  static const employees = [
    EmployeeAttendanceMock(
      employeeName: 'Ahmet Yılmaz',
      position: 'Depo Sorumlusu',
      workDays: '22 gün',
      overtime: '8 saat',
      leaveDays: '1 gün',
      estimatedNetSalary: '28.400 TL',
      status: AttendanceStatus.normal,
      attendanceRate: 0.96,
    ),
    EmployeeAttendanceMock(
      employeeName: 'Elif Demir',
      position: 'Muhasebe Asistanı',
      workDays: '21 gün',
      overtime: '4 saat',
      leaveDays: '2 gün',
      estimatedNetSalary: '25.800 TL',
      status: AttendanceStatus.normal,
      attendanceRate: 0.92,
    ),
    EmployeeAttendanceMock(
      employeeName: 'Mehmet Kaya',
      position: 'Operasyon',
      workDays: '24 gün',
      overtime: '12 saat',
      leaveDays: '0 gün',
      estimatedNetSalary: '31.200 TL',
      status: AttendanceStatus.highOvertime,
      attendanceRate: 1.00,
    ),
    EmployeeAttendanceMock(
      employeeName: 'Zeynep Arslan',
      position: 'Paketleme',
      workDays: '20 gün',
      overtime: '0 saat',
      leaveDays: '3 gün',
      estimatedNetSalary: '22.100 TL',
      status: AttendanceStatus.needsReview,
      attendanceRate: 0.85,
    ),
    EmployeeAttendanceMock(
      employeeName: 'Burak Çelik',
      position: 'Kargo Hazırlık',
      workDays: '23 gün',
      overtime: '6 saat',
      leaveDays: '0 gün',
      estimatedNetSalary: '27.600 TL',
      status: AttendanceStatus.normal,
      attendanceRate: 0.98,
    ),
  ];

  static const issues = [
    AttendanceIssueMock(
      employeeName: 'Zeynep Arslan',
      description: '3 izin günü tespit edildi, manuel kontrol önerilir.',
    ),
    AttendanceIssueMock(
      employeeName: 'Mehmet Kaya',
      description: '12 saat mesai ile dönem ortalamasının üzerinde.',
    ),
    AttendanceIssueMock(
      employeeName: 'Elif Demir',
      description: '2 izin günü bordro hesaplamasında doğrulanmalı.',
    ),
  ];

  static const salarySummary = SalarySummaryMock(
    baseSalaryTotal: '21.400 TL',
    overtimePayment: '1.500 TL',
    deductionEffect: '-0 TL',
    totalPersonnelCost: '22.900 TL',
    aiComment:
        'Bu dönem personel giderinin en büyük artış nedeni Mehmet Kaya ve Ahmet Yılmaz için oluşan ek mesai saatleridir.',
  );

  static const aiInsights = [
    EmployeeInsightMock(
      message:
          'Zeynep Arslan için izin günleri bordro hesaplaması öncesi kontrol edilmeli.',
      icon: Icons.auto_awesome_outlined,
      iconColor: AppColors.rose,
    ),
    EmployeeInsightMock(
      message:
          'Mehmet Kaya’nın 12 saat mesaisi operasyon yoğunluğuna işaret ediyor.',
      icon: Icons.lightbulb_outline,
      iconColor: AppColors.amber,
    ),
    EmployeeInsightMock(
      message:
          'Puantaj onaylandığında 22.900 TL personel gideri finans modülüne aktarılabilir.',
      icon: Icons.auto_awesome_outlined,
      iconColor: AppColors.primary,
    ),
  ];

  static const movements = [
    AttendanceMovementMock(
      title: 'Mayıs 2026 puantaj belgesi işlendi',
      detail: '5 çalışan',
      timestamp: 'Bugün 11:15',
      icon: Icons.description_outlined,
      iconColor: AppColors.primary,
    ),
    AttendanceMovementMock(
      title: 'Zeynep Arslan kontrol uyarısı oluşturuldu',
      detail: '3 izin günü',
      timestamp: 'Bugün 11:16',
      icon: Icons.warning_amber_outlined,
      iconColor: AppColors.rose,
    ),
    AttendanceMovementMock(
      title: 'Mehmet Kaya mesai uyarısı oluşturuldu',
      detail: '12 saat',
      timestamp: 'Bugün 11:17',
      icon: Icons.more_time_outlined,
      iconColor: AppColors.amber,
    ),
    AttendanceMovementMock(
      title: 'Personel gideri finans modülüne hazırlandı',
      detail: '22.900 TL',
      timestamp: 'Bugün 11:20',
      icon: Icons.account_balance_wallet_outlined,
      iconColor: AppColors.emerald,
    ),
  ];
}
