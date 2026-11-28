import 'package:material_ui/material_ui.dart';

import '../forum_api.dart';
import '../widgets/error_notice.dart';
import '../widgets/message_author.dart';

// Écran de lecture : reçoit un identifiant et charge le message complet.
class MessageDetailPage extends StatefulWidget {
  const MessageDetailPage({super.key, required this.api, required this.id});
  final ForumApi api;
  final int id;
  @override
  State<MessageDetailPage> createState() => _MessageDetailPageState();
}

class _MessageDetailPageState extends State<MessageDetailPage> {
  ForumMessage? message;
  String? error;
  bool loading = true;
  @override
  void initState() {
    super.initState();
    load();
  }

  // Cette fonction appartient au détail : elle charge un seul message,
  // contrairement au load de ForumHome qui charge une liste.
  Future<void> load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final result = await widget.api.message(widget.id);
      if (mounted) setState(() => message = result);
    } on ApiException catch (e) {
      if (mounted) setState(() => error = e.message);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  // Construit la page de lecture : titre en haut et message dans le corps.
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Message')),
    body: Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 740),
        // Pendant l’attente : cercle de chargement ; ensuite : contenu défilant.
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  if (error != null) ErrorNotice(error!, onRetry: load),
                  if (error == null && message != null) ...[
                    Text(
                      message!.title.isEmpty ? 'Sans titre' : message!.title,
                      style: const TextStyle(
                        fontSize: 28,
                        height: 1.4,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -.6,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Widget partagé : avatar, nom de l’auteur et date.
                    MessageAuthor(message: message!),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 24),
                    // Contrairement à Text, permet de sélectionner et copier le contenu.
                    SelectableText(
                      message!.content,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.9,
                        color: Color(0xFFCCCCD1),
                      ),
                    ),
                    // Si ce message est une réponse, propose d’ouvrir le message d’origine.
                    if (message!.parentId != null &&
                        message!.parentId != message!.id) ...[
                      const SizedBox(height: 30),
                      OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => MessageDetailPage(
                              api: widget.api,
                              id: message!.parentId!,
                            ),
                          ),
                        ),
                        icon: const Icon(Icons.reply),
                        label: const Text('Lire le message auquel il répond'),
                      ),
                    ],
                  ],
                ],
              ),
      ),
    ),
  );
}
