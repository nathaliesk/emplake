import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

/// Indicador de carregamento do app (não usa o CircularProgressIndicator padrão).
class AppLoader extends StatelessWidget {
  const AppLoader({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LoadingAnimationWidget.twistingDots(
              leftDotColor: scheme.primary,
              rightDotColor: scheme.tertiary,
              size: 56,
            ),
            if (message != null) ...[
              const SizedBox(height: 20),
              Text(message!, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
            ],
          ],
        ),
      ),
    );
  }
}

/// Mensagem de erro com botão de tentar novamente.
class ErrorRetry extends StatelessWidget {
  const ErrorRetry({super.key, required this.message, required this.retryLabel, required this.onRetry});

  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, size: 48, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton.tonalIcon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: Text(retryLabel)),
          ],
        ),
      ),
    );
  }
}

/// Limita a largura do conteúdo em telas grandes e centraliza.
class MaxWidth extends StatelessWidget {
  const MaxWidth({super.key, this.maxWidth = 1100, required this.child});
  final double maxWidth;
  final Widget child;

  @override
  Widget build(BuildContext context) => Center(
        child: ConstrainedBox(constraints: BoxConstraints(maxWidth: maxWidth), child: child),
      );
}
