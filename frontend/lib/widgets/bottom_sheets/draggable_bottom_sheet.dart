import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// A reusable draggable bottom sheet with smooth animations
class DraggableBottomSheet extends StatefulWidget {
  final Widget child;
  final double initialChildSize;
  final double minChildSize;
  final double maxChildSize;
  final bool isDismissible;
  final bool enableDrag;
  final VoidCallback? onDismissed;
  final Color? backgroundColor;

  const DraggableBottomSheet({
    super.key,
    required this.child,
    this.initialChildSize = 0.5,
    this.minChildSize = 0.25,
    this.maxChildSize = 0.95,
    this.isDismissible = true,
    this.enableDrag = true,
    this.onDismissed,
    this.backgroundColor,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    double initialChildSize = 0.5,
    double minChildSize = 0.25,
    double maxChildSize = 0.95,
    bool isDismissible = true,
    bool enableDrag = true,
    Color? backgroundColor,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      enableDrag: enableDrag,
      builder: (context) => DraggableBottomSheet(
        initialChildSize: initialChildSize,
        minChildSize: minChildSize,
        maxChildSize: maxChildSize,
        isDismissible: isDismissible,
        enableDrag: enableDrag,
        backgroundColor: backgroundColor,
        child: child,
      ),
    );
  }

  @override
  State<DraggableBottomSheet> createState() => _DraggableBottomSheetState();
}

class _DraggableBottomSheetState extends State<DraggableBottomSheet> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = widget.backgroundColor ?? theme.scaffoldBackgroundColor;

    return DraggableScrollableSheet(
      initialChildSize: widget.initialChildSize,
      minChildSize: widget.minChildSize,
      maxChildSize: widget.maxChildSize,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Content
              Expanded(
                child: widget.child,
              ),
            ],
          ),
        ).animate().fadeIn(duration: 200.ms).slideY(
              begin: 0.3,
              end: 0,
              duration: 300.ms,
              curve: Curves.easeOutCubic,
            );
      },
    );
  }
}
