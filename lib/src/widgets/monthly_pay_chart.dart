import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// One month's expected-vs-actual pay, for [MonthlyPayChart].
class MonthlyPayPoint {
  const MonthlyPayPoint({
    required this.label,
    required this.expectedYen,
    required this.actualYen,
  });

  /// Short axis label, e.g. "7月".
  final String label;
  final double expectedYen;
  /// Null when the user hasn't recorded what they actually received yet.
  final double? actualYen;
}

const _expectedColor = Color(0xFF0EA894);
const _actualColor = Color(0xFFF59E0B);
final _yenFormat = NumberFormat.currency(locale: 'ja_JP', symbol: '¥', decimalDigits: 0);

/// Grouped bar chart comparing expected vs. actually-received pay across
/// recent months. Bars carry no permanent numeric labels (would clutter a
/// 6-month x 2-series grid) — tapping a month reveals the exact figures
/// above the chart instead, acting as this chart's hover/tooltip layer.
class MonthlyPayChart extends StatefulWidget {
  const MonthlyPayChart({super.key, required this.points});

  final List<MonthlyPayPoint> points;

  @override
  State<MonthlyPayChart> createState() => _MonthlyPayChartState();
}

class _MonthlyPayChartState extends State<MonthlyPayChart> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.points.length - 1;
  }

  @override
  void didUpdateWidget(MonthlyPayChart old) {
    super.didUpdateWidget(old);
    if (_selectedIndex >= widget.points.length) {
      _selectedIndex = widget.points.length - 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.points.isEmpty) return const SizedBox.shrink();
    final maxYen = widget.points
        .map((p) => [p.expectedYen, p.actualYen ?? 0].reduce((a, b) => a > b ? a : b))
        .reduce((a, b) => a > b ? a : b);
    final selected = widget.points[_selectedIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const _LegendChip(color: _expectedColor, label: '想定給与'),
            const SizedBox(width: 16),
            const _LegendChip(color: _actualColor, label: '実際の受取額'),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < widget.points.length; i++)
                Expanded(
                  child: _MonthColumn(
                    point: widget.points[i],
                    maxYen: maxYen == 0 ? 1 : maxYen,
                    selected: i == _selectedIndex,
                    onTap: () => setState(() => _selectedIndex = i),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  selected.label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Text('想定 ${_yenFormat.format(selected.expectedYen)}', style: const TextStyle(fontSize: 12)),
              const SizedBox(width: 10),
              Text(
                selected.actualYen == null ? '実際 未入力' : '実際 ${_yenFormat.format(selected.actualYen)}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MonthColumn extends StatelessWidget {
  const _MonthColumn({
    required this.point,
    required this.maxYen,
    required this.selected,
    required this.onTap,
  });

  final MonthlyPayPoint point;
  final double maxYen;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        decoration: selected
            ? BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(8),
              )
            : null,
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _Bar(heightFactor: point.expectedYen / maxYen, color: _expectedColor),
                  const SizedBox(width: 2),
                  _Bar(
                    heightFactor: (point.actualYen ?? 0) / maxYen,
                    color: _actualColor,
                    isPlaceholder: point.actualYen == null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              point.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                color: selected ? scheme.primary : scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.heightFactor, required this.color, this.isPlaceholder = false});

  final double heightFactor;
  final Color color;
  final bool isPlaceholder;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FractionallySizedBox(
        heightFactor: heightFactor.clamp(0.02, 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: isPlaceholder ? color.withValues(alpha: 0.15) : color,
            border: isPlaceholder ? Border.all(color: color.withValues(alpha: 0.5)) : null,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ),
      ),
    );
  }
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
