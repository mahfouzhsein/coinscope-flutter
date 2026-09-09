import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';

class CoinChange extends StatelessWidget {
  const CoinChange({required this.value, this.fontSize = 13, super.key});

  final double value;
  final double fontSize;

  @override
  Widget build(BuildContext context) => Text(
    formatPercent(value),
    style: TextStyle(
      color: value >= 0 ? AppColors.positive : AppColors.negative,
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
    ),
  );
}
