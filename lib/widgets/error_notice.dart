import 'package:material_ui/material_ui.dart';

import 'forum_panel.dart';

// Affiche une erreur et, si onRetry est fourni, un bouton pour réessayer.
// Le widget affiche le message ; l’écran décide de l’action à relancer.
class ErrorNotice extends StatelessWidget {
  const ErrorNotice(this.message, {super.key, this.onRetry});
  final String message;
  final VoidCallback? onRetry;
  @override
  Widget build(BuildContext context) => ForumPanel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          message,
          style: const TextStyle(color: Color(0xFFFFB4AB), height: 1.5),
        ),
        if (onRetry != null)
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
          ),
      ],
    ),
  );
}
