import 'dart:io';
import 'package:flutter_application_1/forum_api.dart';

// Read-only verification: never creates users or messages on the shared API.
Future<void> main() async {
  final api = ForumApi();
  try {
    final page = await api.messages();
    stdout.writeln('Messages reçus : ${page.messages.length} / ${page.total}');
    if (page.messages.isNotEmpty) {
      final message = await api.message(page.messages.first.id);
      if (message.id != page.messages.first.id) {
        throw StateError('Identifiant inattendu');
      }
      stdout.writeln('Lecture du détail : OK');
    }
  } finally {
    api.close();
  }
}
