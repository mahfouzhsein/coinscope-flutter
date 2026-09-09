import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/async_widgets.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../application/market_providers.dart';
import '../../domain/market_models.dart';

class PriceChartCard extends ConsumerWidget {
  const PriceChartCard({
    required this.coinId,
    required this.currency,
    required this.days,
    required this.onDaysChanged,
    super.key,
  });

  final String coinId;
  final String currency;
  final int days;
  final ValueChanged<int> onDaysChanged;

  static const _ranges = <(int, String)>[
    (1, '24H'),
    (7, '7D'),
    (30, '30D'),
    (90, '90D'),
    (365, '1Y'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final request = PriceHistoryRequest(
      id: coinId,
      currency: currency,
      days: days,
    );
    final history = ref.watch(priceHistoryProvider(request));

    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Price history',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const Icon(Icons.show_chart_rounded, color: AppColors.cyan),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _ranges
                  .map(
                    (range) => Padding(
                      padding: const EdgeInsets.only(right: 7),
                      child: _RangeButton(
                        label: range.$2,
                        selected: days == range.$1,
                        onPressed: () => onDaysChanged(range.$1),
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 260,
            child: history.when(
              loading: () => const LoadingCard(lines: 7),
              error: (error, _) => Center(
                child: ErrorCard(
                  title: 'Chart unavailable',
                  message: error.toString(),
                  onRetry: () => ref.invalidate(priceHistoryProvider(request)),
                ),
              ),
              data: (points) => points.isEmpty
                  ? const Center(
                      child: Text(
                        'No price history is available for this range.',
                        style: TextStyle(color: AppColors.muted),
                      ),
                    )
                  : _PriceChart(points: points, currency: currency, days: days),
            ),
          ),
        ],
      ),
    );
  }
}

class _RangeButton extends StatelessWidget {
  const _RangeButton({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Material(
    color: selected
        ? AppColors.cyan.withValues(alpha: 0.12)
        : Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(9),
      side: BorderSide(color: selected ? AppColors.cyan : AppColors.border),
    ),
    child: InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(9),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.cyanSoft : AppColors.muted,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ),
  );
}

class _PriceChart extends StatelessWidget {
  const _PriceChart({
    required this.points,
    required this.currency,
    required this.days,
  });

  final List<PricePoint> points;
  final String currency;
  final int days;

  @override
  Widget build(BuildContext context) {
    final prices = points.map((point) => point.price).toList(growable: false);
    final lowest = prices.reduce(math.min);
    final highest = prices.reduce(math.max);
    final spread = highest - lowest;
    final padding = spread == 0
        ? math.max(highest.abs() * 0.03, 1.0)
        : spread * 0.08;
    final labelInterval = math.max(1, (points.length - 1) ~/ 4).toDouble();

    return Semantics(
      label:
          '$days day price chart. Latest price ${formatCurrency(prices.last, currency)}.',
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: (points.length - 1).toDouble(),
          minY: lowest - padding,
          maxY: highest + padding,
          clipData: const FlClipData.all(),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            drawVerticalLine: false,
            horizontalInterval: spread == 0 ? padding : spread / 4,
            getDrawingHorizontalLine: (_) => FlLine(
              color: AppColors.border.withValues(alpha: 0.72),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 52,
                getTitlesWidget: (value, meta) => SideTitleWidget(
                  meta: meta,
                  space: 7,
                  child: Text(
                    _compactPrice(value, currency),
                    style: const TextStyle(
                      color: AppColors.subtle,
                      fontSize: 9,
                    ),
                  ),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: labelInterval,
                getTitlesWidget: (value, meta) {
                  final index = value.round().clamp(0, points.length - 1);
                  final date = points[index].time;
                  final label = days <= 1
                      ? DateFormat.Hm().format(date.toLocal())
                      : DateFormat.MMMd().format(date.toLocal());
                  return SideTitleWidget(
                    meta: meta,
                    space: 8,
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: AppColors.subtle,
                        fontSize: 9,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => AppColors.surfaceRaised,
              getTooltipItems: (spots) => spots
                  .map(
                    (spot) => LineTooltipItem(
                      formatCurrency(spot.y, currency),
                      const TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: points.indexed
                  .map((entry) => FlSpot(entry.$1.toDouble(), entry.$2.price))
                  .toList(growable: false),
              isCurved: true,
              preventCurveOverShooting: true,
              color: AppColors.cyan,
              barWidth: 2.4,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.cyan.withValues(alpha: 0.2),
                    AppColors.cyan.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(milliseconds: 320),
      ),
    );
  }
}

String _compactPrice(double value, String currency) {
  final symbol = currencySymbol(currency);
  if (value.abs() >= 1000) {
    return '$symbol${NumberFormat.compact().format(value)}';
  }
  if (value.abs() < 1) return '$symbol${value.toStringAsFixed(3)}';
  return '$symbol${value.toStringAsFixed(0)}';
}
