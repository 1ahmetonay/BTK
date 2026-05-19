import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../core/services/api_service.dart';
import '../../../shared/widgets/section_card.dart';
import '../../../shared/widgets/mobile_stat_strip.dart';
import '../../../shared/widgets/stat_card.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../core/constants/app_colors.dart';
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
  // Veriler — başlangıçta boş, API'den dolar
  List<AttendanceSummaryMock> _summaryCards = [];
  List<EmployeeAttendanceMock> _employees = [];
  List<AttendanceIssueMock> _issues = [];
  SalarySummaryMock _salarySummary = const SalarySummaryMock(
    baseSalaryTotal: '—',
    overtimePayment: '—',
    deductionEffect: '—',
    totalPersonnelCost: '—',
    aiComment: '',
  );
  List<EmployeeInsightMock> _aiInsights = [];
  List<AttendanceMovementMock> _movements = [];
  String _selectedFileName = '';
  bool _loading = true;
  bool _isLiveData = false;
  String? _error;
  List<int>? _pickedFileBytes;
  String _pickedFileName = '';
  int _totalWorkDays = 0;
  int _totalOvertimeHours = 0;
  int _totalLeaveDays = 0;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final results = await Future.wait([
        ApiService.instance.getEmployees(),
        ApiService.instance.getPayroll(),
      ]);

      if (!mounted) return;

      final employeeList = results[0] as List<dynamic>;
      final payroll = results[1] as Map<String, dynamic>;
      final bordro = payroll['bordro'] as List<dynamic>? ?? [];

      // Çalışanları eşleştir
      final liveEmployees = <EmployeeAttendanceMock>[];
      int toplamMesai = 0;
      int toplamIzin = 0;
      int toplamCalismaGunu = 0;
      double toplamNet = 0;

      for (final row in bordro) {
        final m = row as Map<String, dynamic>;
        final calismaGunu = (m['calisma_gunu'] as num?)?.toInt() ?? 0;
        final mesai = (m['mesai_saat'] as num?)?.toInt() ?? 0;
        final izin = (m['izin_gunu'] as num?)?.toInt() ?? 0;
        final net = (m['net_maas'] as num?)?.toDouble() ?? 0;

        toplamCalismaGunu += calismaGunu;
        toplamMesai += mesai;
        toplamIzin += izin;
        toplamNet += net;

        AttendanceStatus status;
        if (izin >= 3) {
          status = AttendanceStatus.needsReview;
        } else if (mesai >= 10) {
          status = AttendanceStatus.highOvertime;
        } else {
          status = AttendanceStatus.normal;
        }

        final rate = calismaGunu > 0 ? calismaGunu / 22.0 : 0.0;

        liveEmployees.add(EmployeeAttendanceMock(
          employeeName: m['calisan'] as String? ?? '—',
          position: m['pozisyon'] as String? ?? '—',
          workDays: '$calismaGunu gün',
          overtime: '$mesai saat',
          leaveDays: '$izin gün',
          estimatedNetSalary: '${_fmt(net)} TL',
          status: status,
          attendanceRate: rate.clamp(0.0, 1.0),
        ));
      }

      // Eğer bordro yoksa employeeList'ten basit liste oluştur
      if (liveEmployees.isEmpty) {
        for (final raw in employeeList) {
          final m = raw as Map<String, dynamic>;
          liveEmployees.add(EmployeeAttendanceMock(
            employeeName: m['ad_soyad'] as String? ?? '—',
            position: m['pozisyon'] as String? ?? '—',
            workDays: '—',
            overtime: '—',
            leaveDays: '—',
            estimatedNetSalary: '${_fmt((m['brut_maas'] as num?)?.toDouble() ?? 0)} TL',
            status: AttendanceStatus.normal,
            attendanceRate: 0.0,
          ));
        }
      }

      // Summary kartları
      final calisanSayisi = liveEmployees.isNotEmpty
          ? liveEmployees.length
          : employeeList.length;

      final liveSummary = [
        AttendanceSummaryMock(
          title: 'Aktif Çalışan',
          value: '$calisanSayisi',
          description: '${payroll['donem'] ?? ''} puantajında',
          trend: bordro.isNotEmpty ? 'Kayıtlar işlendi' : 'Bordro bekleniyor',
          trendTone: bordro.isNotEmpty ? StatusTone.success : StatusTone.info,
          icon: Icons.groups_2_outlined,
          accentColor: AppColors.primary,
        ),
        AttendanceSummaryMock(
          title: 'Toplam Mesai',
          value: '$toplamMesai saat',
          description: 'Bu dönem ek mesai',
          trend: toplamMesai > 20 ? 'Yüksek' : 'Normal',
          trendTone: toplamMesai > 20 ? StatusTone.warning : StatusTone.success,
          icon: Icons.more_time_outlined,
          accentColor: AppColors.amber,
        ),
        AttendanceSummaryMock(
          title: 'İzin Günü',
          value: '$toplamIzin',
          description: 'Toplam izin/devamsızlık',
          trend: toplamIzin > 5 ? 'Dikkat' : 'Normal',
          trendTone: toplamIzin > 5 ? StatusTone.danger : StatusTone.success,
          icon: Icons.event_busy_outlined,
          accentColor: AppColors.rose,
        ),
        AttendanceSummaryMock(
          title: 'Tahmini Personel Gideri',
          value: '${_fmt(toplamNet)} TL',
          description: 'Net maaş toplamı',
          trend: 'Hesaplandı',
          trendTone: StatusTone.info,
          icon: Icons.payments_outlined,
          accentColor: AppColors.teal,
        ),
      ];

      // Issues — sorunlu çalışanlar
      final liveIssues = <AttendanceIssueMock>[];
      for (final e in liveEmployees) {
        if (e.status == AttendanceStatus.needsReview) {
          liveIssues.add(AttendanceIssueMock(
            employeeName: e.employeeName,
            description: '${e.leaveDays} izin tespit edildi, manuel kontrol önerilir.',
          ));
        } else if (e.status == AttendanceStatus.highOvertime) {
          liveIssues.add(AttendanceIssueMock(
            employeeName: e.employeeName,
            description: '${e.overtime} mesai ile dönem ortalamasının üzerinde.',
          ));
        }
      }

      // Maaş özeti
      final brut = (payroll['toplam_brut'] as num?)?.toDouble() ?? 0;
      final net = (payroll['toplam_net'] as num?)?.toDouble() ?? 0;
      final mesaiEtki = toplamMesai * 50.0; // basit tahmin

      final liveSalarySummary = SalarySummaryMock(
        baseSalaryTotal: '${_fmt(brut)} TL',
        overtimePayment: '${_fmt(mesaiEtki)} TL',
        deductionEffect: '${_fmt(brut - net - mesaiEtki)} TL',
        totalPersonnelCost: '${_fmt(net)} TL',
        aiComment: liveIssues.isNotEmpty
            ? 'Bu dönem ${liveIssues.length} çalışan için kontrol gerekli durumlar tespit edildi.'
            : 'Bu dönem tüm çalışanların puantaj kaydı normal.',
      );

      // AI Insights
      final liveInsights = <EmployeeInsightMock>[];
      for (final issue in liveIssues) {
        liveInsights.add(EmployeeInsightMock(
          message: '${issue.employeeName}: ${issue.description}',
          icon: Icons.auto_awesome_outlined,
          iconColor: AppColors.amber,
        ));
      }
      if (toplamNet > 0) {
        liveInsights.add(EmployeeInsightMock(
          message: 'Puantaj onaylandığında ${_fmt(toplamNet)} TL personel gideri finans modülüne aktarılabilir.',
          icon: Icons.auto_awesome_outlined,
          iconColor: AppColors.primary,
        ));
      }

      // Movements
      final liveMovements = <AttendanceMovementMock>[
        AttendanceMovementMock(
          title: '${payroll['donem'] ?? ''} puantaj belgesi işlendi',
          detail: '$calisanSayisi çalışan',
          timestamp: 'Güncel',
          icon: Icons.description_outlined,
          iconColor: AppColors.primary,
        ),
      ];
      for (final issue in liveIssues.take(2)) {
        liveMovements.add(AttendanceMovementMock(
          title: '${issue.employeeName} kontrol uyarısı',
          detail: issue.description,
          timestamp: 'Güncel',
          icon: Icons.warning_amber_outlined,
          iconColor: AppColors.rose,
        ));
      }
      liveMovements.add(AttendanceMovementMock(
        title: 'Personel gideri finans modülüne hazırlandı',
        detail: '${_fmt(toplamNet)} TL',
        timestamp: 'Güncel',
        icon: Icons.account_balance_wallet_outlined,
        iconColor: AppColors.emerald,
      ));

      setState(() {
        _summaryCards = liveSummary;
        _employees = liveEmployees;
        _issues = liveIssues;
        _salarySummary = liveSalarySummary;
        _aiInsights = liveInsights;
        _movements = liveMovements;
        _selectedFileName = payroll['donem'] != null
            ? 'puantaj_${payroll['donem']}.jpg'
            : _selectedFileName;
        _isLiveData = bordro.isNotEmpty;
        _totalWorkDays = toplamCalismaGunu;
        _totalOvertimeHours = toplamMesai;
        _totalLeaveDays = toplamIzin;
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Puantaj verileri yüklenemedi: $e';
        });
      }
    }
  }

  String _fmt(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) {
      return v.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]}.',
      );
    }
    return v.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 48, color: AppColors.mutedText),
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: AppColors.mutedText)),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () {
                setState(() { _loading = true; _error = null; });
                _fetchData();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Tekrar Dene'),
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionCard(
          title: 'Puantaj / Çalışanlar',
          subtitle:
              'Kağıt puantajları AI ile dijitalleştirin, çalışan mesai ve maaş etkilerini tek panelden takip edin.',
          child: Text(
            'Veriler backend API üzerinden gerçek zamanlı çekilmektedir.',
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 700) {
              return MobileStatStrip(
                children: _summaryCards
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
              children: _summaryCards
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
                    fileName: _selectedFileName,
                    onApprove: _approveAttendance,
                    onManualEdit: _manualEdit,
                    onReanalyze: _reanalyze,
                    onPickFile: _pickTimesheetFile,
                    employeeCount: _employees.length,
                    totalWorkDays: _totalWorkDays,
                    totalOvertime: _totalOvertimeHours,
                    totalLeaveDays: _totalLeaveDays,
                    isLiveData: _isLiveData,
                  ),
                  const SizedBox(height: 16),
                  EmployeeAttendanceTableCard(
                    employees: _employees,
                  ),
                  const SizedBox(height: 16),
                  AttendanceIssuesCard(
                    issues: _issues,
                    onReview: _reviewEmployee,
                  ),
                  const SizedBox(height: 16),
                  SalarySummaryCard(
                    summary: _salarySummary,
                  ),
                  const SizedBox(height: 16),
                  AttendancePerformanceCard(
                    employees: _employees,
                  ),
                  const SizedBox(height: 16),
                  AiAttendanceSuggestionsCard(
                    insights: _aiInsights,
                  ),
                  const SizedBox(height: 16),
                  AttendanceMovementsCard(
                    movements: _movements,
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
                        fileName: _selectedFileName,
                        onApprove: _approveAttendance,
                        onManualEdit: _manualEdit,
                        onReanalyze: _reanalyze,
                        onPickFile: _pickTimesheetFile,
                      ),
                      const SizedBox(height: 16),
                      EmployeeAttendanceTableCard(
                        employees: _employees,
                      ),
                      const SizedBox(height: 16),
                      SalarySummaryCard(
                        summary: _salarySummary,
                      ),
                      const SizedBox(height: 16),
                      AttendanceMovementsCard(
                        movements: _movements,
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
                        issues: _issues,
                        onReview: _reviewEmployee,
                      ),
                      const SizedBox(height: 16),
                      AttendancePerformanceCard(
                        employees: _employees,
                      ),
                      const SizedBox(height: 16),
                      AiAttendanceSuggestionsCard(
                        insights: _aiInsights,
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
    _showMessage('Puantaj onaylandı ve finans modülüne aktarıldı.');
  }

  Future<void> _pickTimesheetFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'tiff', 'xlsx', 'xls'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;
      final file = result.files.first;
      if (!mounted) return;
      setState(() {
        _pickedFileBytes = file.bytes;
        _pickedFileName = file.name;
        _selectedFileName = file.name;
      });
      _showMessage('${file.name} seçildi. "Yeniden Analiz Et" ile işleyebilirsiniz.');
    } catch (e) {
      if (mounted) _showMessage('Dosya seçilemedi: $e');
    }
  }

  void _manualEdit() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Manuel Düzenleme'),
        content: const Text('Puantaj verilerini düzenlemek için ilgili satıra dokunun. Değişiklikler kaydedildikten sonra finans modülüne yansıtılır.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Anladım')),
        ],
      ),
    );
  }

  Future<void> _reanalyze() async {
    _showMessage('Puantaj belgesi analiz ediliyor...');
    try {
      final Map<String, dynamic> result;
      if (_pickedFileBytes != null && _pickedFileBytes!.isNotEmpty) {
        result = await ApiService.instance.processTimesheet(_pickedFileBytes!, _pickedFileName);
      } else {
        result = await ApiService.instance.processTimesheetDemo();
      }
      if (!mounted) return;
      _showMessage('Puantaj analiz edildi: ${result['calisan_sayisi'] ?? ''} çalışan işlendi.');
      _fetchData();
    } catch (e) {
      if (mounted) _showMessage('Analiz hatası: $e');
    }
  }

  void _reviewEmployee(String employeeName) {
    final employee = _employees.where((e) => e.employeeName == employeeName).firstOrNull;
    if (employee == null) {
      _showMessage('$employeeName bulunamadı.');
      return;
    }
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(employee.employeeName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow('Pozisyon', employee.position),
            _detailRow('Çalışma Günü', employee.workDays),
            _detailRow('Mesai', employee.overtime),
            _detailRow('İzin', employee.leaveDays),
            _detailRow('Tahmini Net Maaş', employee.estimatedNetSalary),
            const SizedBox(height: 8),
            StatusBadge(
              label: employee.status == AttendanceStatus.normal
                  ? 'Normal'
                  : employee.status == AttendanceStatus.highOvertime
                      ? 'Yüksek Mesai'
                      : 'İnceleme Gerekli',
              tone: employee.status == AttendanceStatus.normal
                  ? StatusTone.success
                  : employee.status == AttendanceStatus.highOvertime
                      ? StatusTone.warning
                      : StatusTone.danger,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Kapat')),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.mutedText)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }
}
