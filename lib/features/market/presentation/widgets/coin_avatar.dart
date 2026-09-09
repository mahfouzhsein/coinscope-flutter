import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class CoinAvatar extends StatelessWidget {
  const CoinAvatar({
    required this.url,
    required this.name,
    this.size = 40,
    super.key,
  });

  final String url;
  final String name;
  final double size;

  @override
  Widget build(BuildContext context) => ClipOval(
    child: CachedNetworkImage(
      imageUrl: url,
      width: size,
      height: size,
      fit: BoxFit.cover,
      fadeInDuration: const Duration(milliseconds: 180),
      placeholder: (_, _) => ColoredBox(
        color: AppColors.surfaceRaised,
        child: SizedBox.square(dimension: size),
      ),
      errorWidget: (_, _, _) => ColoredBox(
        color: AppColors.surfaceRaised,
        child: SizedBox.square(
          dimension: size,
          child: const Icon(Icons.currency_bitcoin, color: AppColors.subtle),
        ),
      ),
      memCacheWidth: (size * MediaQuery.devicePixelRatioOf(context)).round(),
    ),
  );
}
