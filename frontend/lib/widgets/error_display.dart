import 'package:flutter/material.dart';
import '../core/errors/app_exception.dart';

class ErrorDisplay extends StatelessWidget {
  final AppException? error;
  final VoidCallback? onRetry;
  final String? retryText;
  final bool showRetryButton;

  const ErrorDisplay({
    super.key,
    this.error,
    this.onRetry,
    this.retryText = 'Retry',
    this.showRetryButton = true,
  });

  @override
  Widget build(BuildContext context) {
    if (error == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: _getErrorColor(error!).withOpacity(0.1),
        border: Border.all(color: _getErrorColor(error!)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getErrorIcon(error!),
                color: _getErrorColor(error!),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _getErrorTitle(error!),
                  style: TextStyle(
                    color: _getErrorColor(error!),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            error!.message,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
            ),
          ),
          if (showRetryButton && onRetry != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 16),
                label: Text(retryText!),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _getErrorColor(error!),
                  side: BorderSide(color: _getErrorColor(error!)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getErrorColor(AppException error) {
    if (error is AuthenticationException) {
      return Colors.red;
    } else if (error is NetworkException) {
      return Colors.orange;
    } else if (error is ValidationException) {
      return Colors.amber;
    } else {
      return Colors.red;
    }
  }

  IconData _getErrorIcon(AppException error) {
    if (error is AuthenticationException) {
      return Icons.lock;
    } else if (error is NetworkException) {
      return Icons.wifi_off;
    } else if (error is ValidationException) {
      return Icons.warning;
    } else {
      return Icons.error;
    }
  }

  String _getErrorTitle(AppException error) {
    if (error is AuthenticationException) {
      return 'Authentication Error';
    } else if (error is NetworkException) {
      return 'Connection Error';
    } else if (error is ValidationException) {
      return 'Validation Error';
    } else {
      return 'Error';
    }
  }
}