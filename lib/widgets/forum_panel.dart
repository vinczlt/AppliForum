import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';

// Encadré commun : évite de répéter la couleur, les marges et les bordures.
// child est le contenu choisi par l’écran qui utilise ce widget.
class ForumPanel extends StatelessWidget {
  const ForumPanel({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: panel,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: outline),
    ),
    child: child,
  );
}
