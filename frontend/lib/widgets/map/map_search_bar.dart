import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MapSearchBar extends StatelessWidget {
  final String placeholder;
  final VoidCallback onTap;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const MapSearchBar({
    super.key,
    this.placeholder = 'Where to?',
    required this.onTap,
    this.showBackButton = false,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (showBackButton) ...[
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search,
                        color: Colors.grey.shade600,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        placeholder,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: -0.1, end: 0, duration: 300.ms);
  }
}
