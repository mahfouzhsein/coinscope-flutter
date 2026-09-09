import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({this.showName = true, super.key});

  final bool showName;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.cyan, AppColors.indigo],
            ),
          ),
          child: const Text(
            'CS',
            style: TextStyle(
              color: AppColors.backgroundDeep,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        if (showName) ...[
          const SizedBox(width: 11),
          const Text(
            'CoinScope',
            style: TextStyle(
              color: AppColors.text,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ],
    );
  }
}
