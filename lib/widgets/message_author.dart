import 'package:material_ui/material_ui.dart';

import '../forum_api.dart';
import '../theme/app_theme.dart';

// Affiche l’avatar, le nom et la date, dans la liste comme dans le détail.
// Le message est reçu en paramètre : ce widget ne contacte pas le serveur.
class MessageAuthor extends StatelessWidget {
  const MessageAuthor({super.key, required this.message});
  final ForumMessage message;
  @override
  Widget build(BuildContext context) {
    final date = message.date?.toLocal();
    final label = date == null
        ? 'Date non renseignée'
        : '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    // Row place l’avatar à gauche et les informations de l’auteur à droite.
    return Row(
      children: [
        // Rond contenant la première lettre du nom de l’auteur.
        CircleAvatar(
          backgroundColor: outline,
          foregroundColor: Colors.white,
          child: Text(message.author.characters.first.toUpperCase()),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.author,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(color: muted, fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }
}
