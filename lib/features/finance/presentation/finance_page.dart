import 'package:flutter/material.dart';

import '../../../shared/widgets/status_badge.dart';
import 'finance_mock_data.dart';
import 'widgets/ai_finance_suggestions_card.dart';
import 'widgets/cashflow_forecast_card.dart';
import 'widgets/distribution_card.dart';
import 'widgets/finance_movements_card.dart';
import 'widgets/kdv_summary_card.dart';
import 'widgets/overdue_payments_card.dart';
import 'widgets/profit_loss_card.dart';

class FinancePage extends StatefulWidget {
  const FinancePage({super.key});

  @override
  State<FinancePage> createState() => _FinancePageState();
}

class _FinancePageState extends State<FinancePage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FinanceIntroCard(),
        const SizedBox(height: 16),
        const _FinanceRiskStrip(),
        const SizedBox(height: 16),
        const _FinanceSummaryStrip(summaries: FinanceMockData.summaries),
        const SizedBox(height: 16),
        const ProfitLossCard(
          items: FinanceMockData.profitLossItems,
          margin: FinanceMockData.profitMargin,
          aiInsight: FinanceMockData.profitLossInsight,
        ),
        const SizedBox(height: 16),
        const KdvSummaryCard(summary: FinanceMockData.kdvSummary),
        const SizedBox(height: 16),
        const CashflowForecastCard(
          metrics: FinanceMockData.cashflowMetrics,
          points: FinanceMockData.cashflowPoints,
          riskText: FinanceMockData.cashflowRisk,
        ),
        const SizedBox(height: 16),
        OverduePaymentsCard(
          payments: FinanceMockData.overduePayments,
          onDraftReminder: _showReminderMessage,
        ),
        const SizedBox(height: 16),
        const DistributionCard(
          incomeItems: FinanceMockData.incomeDistribution,
          expenseItems: FinanceMockData.expenseDistribution,
        ),
        const SizedBox(height: 16),
        const AiFinanceSuggestionsCard(insights: FinanceMockData.aiInsights),
        const SizedBox(height: 16),
        const FinanceMovementsCard(movements: FinanceMockData.movements),
      ],
    );
  }

  void _showReminderMessage(String customerName) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            '$customerName için ödeme hatırlatma taslağı hazırlandı.',
          ),
        ),
      );
  }
}

class _FinanceIntroCard extends StatelessWidget {
  const _FinanceIntroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF002045),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Finans ve KDV',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Gelir, gider, KDV ve nakit akışınızı takip edin.',
            style: TextStyle(
              color: Color(0xFFADC7F7),
              fontSize: 14,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.auto_awesome, color: Color(0xFFB1F0CE), size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'AI destekli özetlerle finansal riskleri önceden görün.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      height: 1.35,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FinanceRiskStrip extends StatelessWidget {
  const _FinanceRiskStrip();

  @override
  Widget build(BuildContext context) {
    const items = [
      ('Nakit Riski', 'Orta', StatusTone.warning),
      ('KDV Durumu', 'Takip', StatusTone.danger),
      ('Tahsilat', '7 Geciken', StatusTone.success),
    ];

    return Row(
      children: [
        for (var index = 0; index < items.length; index++) ...[
          Expanded(
            child: Container(
              height: 82,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFC4C6CF)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    items[index].$1,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF43474E),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.center,
                    child: StatusBadge(
                      label: items[index].$2,
                      tone: items[index].$3,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (index != items.length - 1) const SizedBox(width: 8),
        ],
      ],
    );
  }
}

class _FinanceSummaryStrip extends StatelessWidget {
  const _FinanceSummaryStrip({required this.summaries});

  final List<FinanceSummaryMock> summaries;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 104,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: summaries.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) =>
            _FinanceSummaryTile(summary: summaries[index]),
      ),
    );
  }
}

class _FinanceSummaryTile extends StatelessWidget {
  const _FinanceSummaryTile({required this.summary});

  final FinanceSummaryMock summary;

  @override
  Widget build(BuildContext context) {
    final trendColor = switch (summary.trendTone) {
      StatusTone.success => const Color(0xFF2C694E),
      StatusTone.warning => const Color(0xFFBA1A1A),
      StatusTone.danger => const Color(0xFFBA1A1A),
      StatusTone.info => const Color(0xFF002045),
      StatusTone.neutral => const Color(0xFF43474E),
    };

    return Container(
      width: 160,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC4C6CF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            summary.title,
            style: const TextStyle(
              color: Color(0xFF43474E),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            summary.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF002045),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Icon(
                summary.title == 'Ödenecek KDV'
                    ? Icons.schedule
                    : Icons.trending_up,
                color: trendColor,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                _shortTrend(summary),
                style: TextStyle(
                  color: trendColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _shortTrend(FinanceSummaryMock summary) {
    if (summary.title == 'Ödenecek KDV') {
      return '26 Gün';
    }

    return summary.trend
        .replaceAll('+18,4%', '%12')
        .replaceAll('+9,7%', '%8')
        .replaceAll('+12,1%', '%4');
  }
}
