import 'package:flutter/material.dart';

import '../platform/external_link.dart';
import '../theme/app_colors.dart';
import 'surface_card.dart';

class WebDownloadBanner extends StatelessWidget {
  const WebDownloadBanner({super.key});

  static const _androidUrl =
      'https://github.com/mahfouzhsein/coinscope-flutter/releases/latest/download/CoinScope-Android.apk';
  static const _windowsUrl =
      'https://github.com/mahfouzhsein/coinscope-flutter/releases/latest/download/CoinScope-Windows.zip';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: SurfaceCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.install_mobile_rounded, color: AppColors.cyanSoft),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Get the native app',
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Download CoinScope for Android or Windows.',
              style: TextStyle(color: AppColors.muted, fontSize: 12),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton.tonalIcon(
                  onPressed: () => openExternalLink(_androidUrl),
                  icon: const Icon(Icons.android_rounded, size: 18),
                  label: const Text('Android APK'),
                ),
                OutlinedButton.icon(
                  onPressed: () => openExternalLink(_windowsUrl),
                  icon: const Icon(Icons.desktop_windows_rounded, size: 18),
                  label: const Text('Windows ZIP'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
