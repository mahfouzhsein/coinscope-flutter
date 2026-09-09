import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'features/navigation/presentation/app_shell.dart';

class CoinScopeApp extends StatelessWidget {
  const CoinScopeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CoinScope',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const AppShell(),
      builder: (context, child) {
        final content = child ?? const SizedBox.shrink();
        if (!kIsWeb) return content;

        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth > 430
                ? 430.0
                : constraints.maxWidth;
            return ColoredBox(
              color: AppColors.backgroundDeep,
              child: Center(
                child: SizedBox(
                  width: width,
                  height: constraints.maxHeight,
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      border: Border(
                        left: BorderSide(color: AppColors.border),
                        right: BorderSide(color: AppColors.border),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x66000000),
                          blurRadius: 42,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                    child: ClipRect(child: content),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
