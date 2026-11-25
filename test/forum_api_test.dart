import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:flutter_application_1/forum_api.dart';

Map<String, dynamic> messageJson(int id) => {
  'id': id,
  'titre': 'Sujet $id',
  'contenu': 'Contenu du message',
  'datePoste': '2026-11-24T10:00:00+00:00',
  'user': {'prenom': 'Camille', 'nom': 'Test'},
  'message': null,
};

void main() {
  test('Lecture JSON-LD, auteur et pagination de l’API', () async {
    final api = ForumApi(
      client: MockClient((request) async {
        expect(request.url.path, '/ApiPlatform/api/messages');
        expect(request.headers['Accept'], contains('application/ld+json'));
        return http.Response(
          jsonEncode({
            'member': [messageJson(2)],
            'totalItems': 2,
            'view': {'next': '/ApiPlatform/api/messages?page=2'},
          }),
          200,
        );
      }),
    );
    final page = await api.messages();
    expect(page.messages.single.author, 'Camille Test');
    expect(page.total, 2);
    expect(page.next, contains('page=2'));
  });

  test(
    'Connexion réelle : jeton envoyé en Bearer et retiré à la déconnexion',
    () async {
      var authenticated = false;
      final api = ForumApi(
        client: MockClient((request) async {
          if (request.method == 'POST') {
            expect(request.url.path, '/ApiPlatform/api/authentication_token');
            expect(jsonDecode(request.body), {
              'email': 'test@example.com',
              'password': 'secret-test',
            });
            authenticated = true;
            return http.Response('{"token":"test-token"}', 200);
          }
          expect(
            request.headers['Authorization'],
            authenticated ? 'Bearer test-token' : isNull,
          );
          return http.Response('{"member":[],"totalItems":0}', 200);
        }),
      );
      await api.login('test@example.com', 'secret-test');
      expect(api.isLoggedIn, isTrue);
      await api.messages();
      api.logout();
      authenticated = false;
      await api.messages();
      expect(api.email, isNull);
    },
  );

  test('Identifiants refusés : aucune session simulée', () async {
    final api = ForumApi(
      client: MockClient(
        (_) async => http.Response('{"message":"Invalid credentials."}', 401),
      ),
    );
    await expectLater(
      api.login('test@example.com', 'incorrect'),
      throwsA(
        isA<ApiException>().having(
          (e) => e.message,
          'message',
          contains('incorrect'),
        ),
      ),
    );
    expect(api.isLoggedIn, isFalse);
  });

  test('Inscription : champs nom, prénom, email et mot de passe, sans rôle administrateur', () async {
    final api = ForumApi(
      client: MockClient((request) async {
        expect(request.url.path, '/ApiPlatform/api/users');
        expect(request.headers['Content-Type'], 'application/ld+json');
        final body = jsonDecode(request.body) as Map;
        expect(body['email'], 'test@example.com');
        expect(body['nom'], 'Test');
        expect(body['prenom'], 'Camille');
        expect(body['password'], 'secret-test');
        expect(body.containsKey('roles'), isFalse);
        return http.Response('{"id":1}', 201);
      }),
    );
    await api.register(
      email: 'test@example.com',
      password: 'secret-test',
      lastName: 'Test',
      firstName: 'Camille',
    );
    expect(api.isLoggedIn, isFalse);
  });

  test('Erreur serveur inscription : message utile sans trace SQL', () async {
    final api = ForumApi(
      client: MockClient(
        (_) async => http.Response(
          jsonEncode({
            'detail': "SQLSTATE: Column 'email' cannot be null",
            'trace': ['private server trace'],
          }),
          500,
        ),
      ),
    );
    await expectLater(
      api.register(
        email: 'test@example.com',
        password: 'secret-test',
        lastName: 'Test',
        firstName: 'Camille',
      ),
      throwsA(
        isA<ApiException>().having(
          (e) => e.message,
          'message',
          allOf(contains('côté serveur'), isNot(contains('SQLSTATE'))),
        ),
      ),
    );
  });

  test('Session expirée effacée sur une lecture protégée', () async {
    final api = ForumApi(
      client: MockClient(
        (r) async => r.method == 'POST'
            ? http.Response('{"token":"expired"}', 200)
            : http.Response('{}', 401),
      ),
    );
    await api.login('test@example.com', 'secret-test');
    await expectLater(api.messages(), throwsA(isA<ApiException>()));
    expect(api.isLoggedIn, isFalse);
  });

  test('Un lien de pagination externe ne reçoit pas le jeton', () async {
    var calls = 0;
    final api = ForumApi(
      client: MockClient((r) async {
        calls++;
        return http.Response('{}', 200);
      }),
    );
    await expectLater(
      api.messages(next: 'https://example.org/api/messages'),
      throwsA(isA<ApiException>()),
    );
    expect(calls, 0);
  });

  test('Erreur réseau et réponse invalide explicites', () async {
    final offline = ForumApi(
      client: MockClient((_) async => throw http.ClientException('offline')),
    );
    await expectLater(
      offline.messages(),
      throwsA(
        isA<ApiException>().having(
          (e) => e.message,
          'message',
          contains('Internet'),
        ),
      ),
    );
    final invalid = ForumApi(
      client: MockClient((_) async => http.Response('<html>error</html>', 200)),
    );
    await expectLater(invalid.messages(), throwsA(isA<ApiException>()));
  });

  test('Détail récupéré par son id, avec référence au parent', () async {
    final api = ForumApi(
      client: MockClient((request) async {
        expect(request.url.path, '/ApiPlatform/api/messages/2');
        return http.Response(
          jsonEncode({
            ...messageJson(2),
            'message': {'id': 1},
          }),
          200,
        );
      }),
    );
    expect((await api.message(2)).parentId, 1);
  });
}
