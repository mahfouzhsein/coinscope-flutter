import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'surface_card.dart';

class ErrorCard extends StatelessWidget {
  const ErrorCard({
    required this.onRetry,
    this.title = 'Market data unavailable',
    this.message,
    super.key,
  });

  final String title;
  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => SurfaceCard(
    child: Column(
      children: [
        const Icon(
          Icons.cloud_off_rounded,
          color: AppColors.negative,
          size: 30,
        ),
        const SizedBox(height: 12),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        if (message != null) ...[
          const SizedBox(height: 6),
          Text(
            message!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        const SizedBox(height: 14),
        FilledButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded, size: 18),
          label: const Text('Retry'),
        ),
      ],
    ),
  );
}

class SkeletonList extends StatefulWidget {
  const SkeletonList({this.lines = 5, super.key});

  final int lines;

  @override
  State<SkeletonList> createState() => _SkeletonListState();
}

class _SkeletonListState extends State<SkeletonList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
      lowerBound: 0.35,
      upperBound: 0.8,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    builder: (context, child) => Opacity(
      opacity: _controller.value,
      child: Column(
        children: List.generate(
          widget.lines,
          (index) => Container(
            height: index == 0 ? 18 : 13,
            margin: const EdgeInsets.symmetric(vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.surfaceRaised,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    ),
  );
}

class LoadingCard extends StatelessWidget {
  const LoadingCard({this.lines = 5, super.key});

  final int lines;

  @override
  Widget build(BuildContext context) =>
      SurfaceCard(child: SkeletonList(lines: lines));
}
