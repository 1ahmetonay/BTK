import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/section_card.dart';
import '../employees_mock_data.dart';

class AttendancePerformanceCard extends StatelessWidget {
  const AttendancePerformanceCard({
    required this.employees,
    super.key,
  });

  final List<EmployeeAttendanceMock> employees;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Çalışan Devamlılığı',
      subtitle: 'Dönem bazlı devamlılık oranı',
      child: Column(
        children: employees
            .map(
              (employee) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            employee.employeeName,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                        Text(
                          '%${(employee.attendanceRate * 100).round()}',
                          style: TextStyle(
                            color: _colorFor(employee.attendanceRate),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: employee.attendanceRate,
                      minHeight: 9,
                      borderRadius: BorderRadius.circular(999),
                      color: _colorFor(employee.attendanceRate),
                      backgroundColor: AppColors.gray200,
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Color _colorFor(double rate) {
    if (rate < 0.90) {
      return AppColors.rose;
    }
    if (rate < 0.95) {
      return AppColors.amber;
    }
    return AppColors.emerald;
  }
}
