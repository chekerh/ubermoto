import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Empty state widget shown when no drivers are available
class NoDriversWidget extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? customMessage;

  const NoDriversWidget({
    super.key,
    this.onRetry,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Icon(
              Icons.directions_bike_outlined,
              size: 64,
              color: Colors.grey.shade400,
            )
                .animate()
                .fadeIn(duration: 300.ms)
                .scale(delay: 100.ms, duration: 400.ms, curve: Curves.elasticOut),

            const SizedBox(height: 24),

            // Title
            Text(
              'No drivers available',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(delay: 200.ms, duration: 300.ms)
                .slideY(begin: 0.2, end: 0, delay: 200.ms, duration: 300.ms),

            const SizedBox(height: 12),

            // Message
            Text(
              customMessage ??
                  'We couldn\'t find any drivers nearby.\nTry again in a few moments.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(delay: 300.ms, duration: 300.ms)
                .slideY(begin: 0.2, end: 0, delay: 300.ms, duration: 300.ms),

            if (onRetry != null) ...[
              const SizedBox(height: 32),

              // Retry button
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              )
                  .animate()
                  .fadeIn(delay: 400.ms, duration: 300.ms)
                  .scale(delay: 400.ms, duration: 300.ms, curve: Curves.elasticOut),
            ],
          ],
        ),
      ),
    );
  }
}
