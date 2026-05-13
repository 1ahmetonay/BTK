import 'package:flutter/material.dart';

import '../../../shared/widgets/section_card.dart';
import '../../../shared/widgets/mobile_stat_strip.dart';
import '../../../shared/widgets/stat_card.dart';
import 'employees_mock_data.dart';
import 'widgets/ai_attendance_suggestions_card.dart';
import 'widgets/attendance_issues_card.dart';
import 'widgets/attendance_movements_card.dart';
import 'widgets/attendance_performance_card.dart';
import 'widgets/attendance_processing_card.dart';
import 'widgets/employee_attendance_table_card.dart';
import 'widgets/salary_summary_card.dart';

class EmployeesPage extends StatefulWidget {
  const EmployeesPage({super.key});

  @override
  State<EmployeesPage> createState() => _EmployeesPageState();
}

class _EmployeesPageState extends State<EmployeesPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionCard(
          title: 'Puantaj / Çalışanlar',
          subtitle:
              'Kağıt puantajları AI ile dijitalleştirin, çalışan mesai ve maaş etkilerini tek panelden takip edin.',
          child: Text(
            'Demo modunda puantaj verileri mock olarak okunur; onay, düzenleme ve yeniden analiz aksiyonları yalnızca snackbar ile simüle edilir.',
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 700) {
              return MobileStatStrip(
                children: EmployeesMockData.summaryCards
                    .map(
                      (summary) => MobileStatTile(
                        title: summary.title,
                        value: summary.value,
                        trend: summary.trend,
                        trendTone: summary.trendTone,
                        icon: summary.icon,
                        accentColor: summary.accentColor,
                      ),
                    )
                    .toList(),
              );
            }

            final columns = constraints.maxWidth >= 1200
                ? 4
                : constraints.maxWidth >= 720
                    ? 2
                    : 1;

            return GridView.count(
              crossAxisCount: columns,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: columns == 1 ? 2.25 : 1.25,
              children: EmployeesMockData.summaryCards
                  .map(
                    (summary) => StatCard(
                      title: summary.title,
                      value: summary.value,
                      description: summary.description,
                      trend: summary.trend,
                      trendTone: summary.trendTone,
                      icon: summary.icon,
                      accentColor: summary.accentColor,
                    ),
                  )
                  .toList(),
            );
          },
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 1120;

            if (!isWide) {
              return Column(
                children: [
                  AttendanceProcessingCard(
                    fileName: EmployeesMockData.selectedFileName,
                    onApprove: _approveAttendance,
                    onManualEdit: _manualEdit,
                    onReanalyze: _reanalyze,
                  ),
                  const SizedBox(height: 16),
                  const EmployeeAttendanceTableCard(
                    employees: EmployeesMockData.employees,
                  ),
                  const SizedBox(height: 16),
                  AttendanceIssuesCard(
                    issues: EmployeesMockData.issues,
                    onReview: _reviewEmployee,
                  ),
                  const SizedBox(height: 16),
                  const SalarySummaryCard(
                    summary: EmployeesMockData.salarySummary,
                  ),
                  const SizedBox(height: 16),
                  const AttendancePerformanceCard(
                    employees: EmployeesMockData.employees,
                  ),
                  const SizedBox(height: 16),
                  const AiAttendanceSuggestionsCard(
                    insights: EmployeesMockData.aiInsights,
                  ),
                  const SizedBox(height: 16),
                  const AttendanceMovementsCard(
                    movements: EmployeesMockData.movements,
                  ),
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 7,
                  child: Column(
                    children: [
                      AttendanceProcessingCard(
                        fileName: EmployeesMockData.selectedFileName,
                        onApprove: _approveAttendance,
                        onManualEdit: _manualEdit,
                        onReanalyze: _reanalyze,
                      ),
                      const SizedBox(height: 16),
                      const EmployeeAttendanceTableCard(
                        employees: EmployeesMockData.employees,
                      ),
                      const SizedBox(height: 16),
                      const SalarySummaryCard(
                        summary: EmployeesMockData.salarySummary,
                      ),
                      const SizedBox(height: 16),
                      const AttendanceMovementsCard(
                        movements: EmployeesMockData.movements,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 4,
                  child: Column(
                    children: [
                      AttendanceIssuesCard(
                        issues: EmployeesMockData.issues,
                        onReview: _reviewEmployee,
                      ),
                      const SizedBox(height: 16),
                      const AttendancePerformanceCard(
                        employees: EmployeesMockData.employees,
                      ),
                      const SizedBox(height: 16),
                      const AiAttendanceSuggestionsCard(
                        insights: EmployeesMockData.aiInsights,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  void _approveAttendance() {
    _showMessage('Mayıs 2026 puantajı onaylandı ve finans modülüne aktarıldı.');
  }

  void _manualEdit() {
    _showMessage('Manuel düzenleme modu yakında eklenecek.');
  }

  void _reanalyze() {
    _showMessage('Puantaj belgesi yeniden analiz kuyruğuna alındı.');
  }

  void _reviewEmployee(String employeeName) {
    _showMessage('$employeeName puantaj kaydı kontrol için açıldı.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }
}
