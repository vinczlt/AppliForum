import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/forum_api.dart';

final message = {
  'id': 1,
  'titre': 'Message reçu du serveur',
  'contenu': 'Le contenu complet reçu depuis notre API.',
  'user': {'prenom': 'Camille', 'nom': 'Test'},
  'datePoste': '2026-11-24T10:00:00Z',
};

void main() {
  testWidgets('Messages API, recherche et détail sur petit écran', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final api = ForumApi(
      client: MockClient(
        (r) async => http.Response(
          jsonEncode(
            r.url.path.endsWith('/1')
                ? message
                : {
                    'member': [message],
                    'totalItems': 1,
                  },
          ),
          200,
          headers: {'content-type': 'application/ld+json; charset=utf-8'},
        ),
      ),
    );
    await tester.pumpWidget(MyApp(api: api));
    await tester.pumpAndSettle();
    expect(find.text('Message reçu du serveur'), findsOneWidget);
    expect(find.textContaining('alex_dev'), findsNothing);
    await tester.enterText(find.byType(TextField), 'introuvable');
    await tester.pumpAndSettle();
    expect(
      find.text('Aucun résultat dans les messages chargés.'),
      findsOneWidget,
    );
    await tester.tap(find.byTooltip('Effacer la recherche'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Message reçu du serveur'));
    await tester.pumpAndSettle();
    expect(find.byType(SelectableText), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Erreur réseau affichée puis reprise sans messages fictifs', (
    tester,
  ) async {
    var calls = 0;
    final api = ForumApi(
      client: MockClient((_) async {
        if (calls++ == 0) throw http.ClientException('offline');
        return http.Response('{"member":[],"totalItems":0}', 200);
      }),
    );
    await tester.pumpWidget(MyApp(api: api));
    await tester.pumpAndSettle();
    expect(find.textContaining('Vérifiez votre connexion'), findsOneWidget);
    await tester.tap(find.text('Réessayer'));
    await tester.pumpAndSettle();
    expect(find.text('Aucun message pour le moment.'), findsOneWidget);
  });

  testWidgets('La connexion échouée reste sur le formulaire', (tester) async {
    final api = ForumApi(
      client: MockClient((_) async => http.Response('{}', 401)),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: AuthPage(api: api),
      ),
    );
    await tester.enterText(find.byKey(const Key('email')), 'test@example.com');
    await tester.enterText(find.byKey(const Key('password')), 'incorrect');
    await tester.ensureVisible(find.text('Se connecter'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Se connecter'));
    await tester.pumpAndSettle();
    expect(
      find.text('Adresse e-mail ou mot de passe incorrect.'),
      findsOneWidget,
    );
    expect(api.isLoggedIn, isFalse);
  });

  testWidgets('Inscription confirmée uniquement après succès du serveur', (
    tester,
  ) async {
    var calls = 0;
    final api = ForumApi(
      client: MockClient((_) async {
        calls++;
        return http.Response('{"id":1}', 201);
      }),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: AuthPage(api: api, register: true),
      ),
    );
    await tester.enterText(find.byKey(const Key('firstName')), 'Camille');
    await tester.enterText(find.byKey(const Key('lastName')), 'Test');
    await tester.enterText(find.byKey(const Key('email')), 'test@example.com');
    await tester.enterText(find.byKey(const Key('password')), 'secret-test');
    await tester.enterText(
      find.byKey(const Key('confirmation')),
      'secret-test',
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Créer mon compte'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Créer mon compte'));
    await tester.pumpAndSettle();
    expect(calls, 0);
    expect(find.textContaining('12 caractères minimum'), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('password')),
      'Test-Compte2026!',
    );
    await tester.enterText(find.byKey(const Key('confirmation')), 'autre');
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Créer mon compte'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Créer mon compte'));
    await tester.pumpAndSettle();
    expect(calls, 0);
    expect(
      find.text('Les mots de passe ne correspondent pas.'),
      findsOneWidget,
    );
    await tester.enterText(
      find.byKey(const Key('confirmation')),
      'Test-Compte2026!',
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Créer mon compte'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Créer mon compte'));
    await tester.pumpAndSettle();
    expect(calls, 1);
    expect(find.textContaining('Votre compte a été créé.'), findsOneWidget);
    expect(api.isLoggedIn, isFalse);
    expect(tester.takeException(), isNull);
  });
}
