import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-1, -1.15),
            radius: 1.05,
            colors: [Color(0x2622D3EE), Color(0x00070B14)],
            stops: [0, 0.72],
          ),
        ),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(1.1, -1),
              radius: 1.15,
              colors: [Color(0x226366F1), Color(0x00070B14)],
              stops: [0, 0.72],
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
