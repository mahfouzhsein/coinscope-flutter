import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Keeps the mobile-first dashboard comfortable on wide desktop windows.
class ResponsivePage extends StatelessWidget {
  const ResponsivePage({required this.child, this.maxWidth = 760, super.key});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final inset = math.max(0.0, (constraints.maxWidth - maxWidth) / 2);
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: inset),
        child: child,
      );
    },
  );
}
