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
