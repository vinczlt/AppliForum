import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

// Erreur compréhensible par les écrans : message à afficher et code HTTP éventuel.
class ApiException implements Exception {
  const ApiException(this.message, {this.status});
  final String message;
  final int? status;
  @override
  String toString() => message;
}

// Représente les données d’un message. Ce n’est pas un widget : aucun affichage ici.
class ForumMessage {
  const ForumMessage({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    this.date,
    this.parentId,
  });
  final int id;
  final String title, content, author;
  final DateTime? date;
  final int? parentId;
  // Transforme les données JSON du serveur en objet Dart utilisable par les écrans.
  factory ForumMessage.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    final name = user is Map
        ? [
            user['prenom'],
            user['nom'],
          ].whereType<String>().where((s) => s.trim().isNotEmpty).join(' ')
        : '';
    final parent = json['message'];
    final parentValue = parent is Map ? parent['id'] ?? parent['@id'] : parent;
    return ForumMessage(
      id: (json['id'] as num).toInt(),
      title: json['titre'] as String? ?? '',
      content: json['contenu'] as String? ?? '',
      author: name.isEmpty ? 'Auteur non renseigné' : name,
      date: DateTime.tryParse(json['datePoste'] as String? ?? ''),
      parentId: parentValue == null
          ? null
          : int.tryParse(parentValue.toString().split('/').last),
    );
  }
}

// Une page de résultats : messages, total disponible et lien vers la page suivante.
class MessagePage {
  const MessagePage(this.messages, this.total, this.next);
  final List<ForumMessage> messages;
  final int total;
  final String? next;
}

// Service partagé par les écrans : toutes les communications réseau passent ici.
class ForumApi {
  ForumApi({http.Client? client}) : _client = client ?? http.Client();
  static final base = Uri.parse(
    'https://4743.s3.nuage-peda.fr/ApiPlatform/api/',
  );
  final http.Client _client;
  // Preuve de connexion conservée en mémoire uniquement ; elle disparaît à la fermeture.
  String? _token;
  String? email;
  bool get isLoggedIn => _token != null;

  // Déconnecte localement en oubliant le token et l’adresse e-mail.
  void logout() {
    _token = null;
    email = null;
  }

  void close() => _client.close();

  Uri _uri(String path) {
    final uri = base.resolve(path);
    // Refuse un lien de pagination externe pour ne pas y envoyer le token.
    if (uri.origin != base.origin || !uri.path.startsWith(base.path)) {
      throw const ApiException('Le serveur a renvoyé un lien invalide.');
    }
    return uri;
  }

  // Fonction commune aux appels API : prépare la requête et vérifie la réponse.
  // Sans body : GET pour lire. Avec body : POST pour envoyer des données.
  Future<Map<String, dynamic>> _request(
    String path, {
    Map<String, dynamic>? body,
    bool login = false,
  }) async {
    try {
      final headers = <String, String>{
        'Accept': 'application/ld+json, application/json',
        if (body != null)
          'Content-Type': login ? 'application/json' : 'application/ld+json',
        if (_token != null && body == null) 'Authorization': 'Bearer $_token',
      };
      final uri = _uri(path);
      final response =
          await (body == null
                  ? _client.get(uri, headers: headers)
                  : _client.post(uri, headers: headers, body: jsonEncode(body)))
              .timeout(const Duration(seconds: 20));
      // Le JSON est un format de transport ; on le décode en dictionnaire Dart.
      Map<String, dynamic> data = {};
      try {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        if (decoded is Map<String, dynamic>) data = decoded;
      } on FormatException {
        if (response.statusCode >= 200 && response.statusCode < 300) {
          throw const ApiException('La réponse du serveur est illisible.');
        }
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        final status = response.statusCode;
        if (status == 401) {
          if (!login && body == null) logout();
          throw ApiException(
            login
                ? 'Adresse e-mail ou mot de passe incorrect.'
                : 'Votre session a expiré. Connectez-vous à nouveau.',
            status: status,
          );
        }
        if (status == 403) {
          throw ApiException(
            'Vous n’avez pas accès à cette ressource.',
            status: status,
          );
        }
        if (status == 404) {
          throw ApiException(
            'Ce message ou cette ressource est introuvable.',
            status: status,
          );
        }
        if (status == 429) {
          throw ApiException(
            'Trop de tentatives. Réessayez dans quelques instants.',
            status: status,
          );
        }
        if (status >= 500) {
          final detail = data['detail']?.toString() ?? '';
          throw ApiException(
            path == 'users' &&
                    detail.contains('email') &&
                    detail.contains('cannot be null')
                ? 'L’inscription est bloquée côté serveur : l’API ne prend pas en compte l’adresse e-mail. Contactez le responsable de l’API.'
                : 'Le serveur rencontre un problème. Réessayez plus tard.',
            status: status,
          );
        }
        final violations = data['violations'];
        final details = violations is List
            ? violations
                  .whereType<Map>()
                  .map(
                    (v) =>
                        '${v['propertyPath'] ?? ''} : ${v['message'] ?? 'Valeur invalide'}',
                  )
                  .join('\n')
            : '';
        throw ApiException(
          details.isNotEmpty
              ? details
              : status == 409
              ? 'Un compte existe déjà avec ces informations.'
              : 'Les informations ont été refusées par le serveur. Vérifiez les champs.',
          status: status,
        );
      }
      return data;
    } on TimeoutException {
      throw const ApiException(
        'Le serveur met trop de temps à répondre. Réessayez.',
      );
    } on http.ClientException {
      throw const ApiException(
        'Impossible de joindre le serveur. Vérifiez votre connexion Internet.',
      );
    }
  }

  // Envoie les identifiants ; le token renvoyé prouve que le serveur les a acceptés.
  Future<void> login(String email, String password) async {
    final data = await _request(
      'authentication_token',
      body: {'email': email.trim(), 'password': password},
      login: true,
    );
    final token = data['token'];
    if (token is! String || token.isEmpty) {
      throw const ApiException(
        'Le serveur n’a pas renvoyé de jeton de connexion.',
      );
    }
    _token = token;
    this.email = email.trim();
  }

  // Demande la création du compte. Le serveur valide et enregistre les informations.
  Future<void> register({
    required String email,
    required String password,
    required String lastName,
    required String firstName,
  }) async {
    await _request(
      'users',
      body: {
        'email': email.trim(),
        'password': password,
        'nom': lastName.trim(),
        'prenom': firstName.trim(),
        'dateInscription': DateTime.now().toUtc().toIso8601String(),
      },
    );
  }

  // Charge une liste de messages, ou la page suivante si next est fourni.
  Future<MessagePage> messages({String? next}) async {
    final data = await _request(next ?? 'messages?order%5Bid%5D=desc');
    final members = data['member'] ?? data['hydra:member'];
    if (members is! List) {
      throw const ApiException(
        'Le format de la liste des messages est inattendu.',
      );
    }
    try {
      final items = members
          .map((m) => ForumMessage.fromJson(m as Map<String, dynamic>))
          .toList();
      final view = data['view'] ?? data['hydra:view'];
      final nextPage = view is Map ? view['next'] ?? view['hydra:next'] : null;
      return MessagePage(
        items,
        ((data['totalItems'] ?? data['hydra:totalItems']) as num?)?.toInt() ??
            items.length,
        nextPage as String?,
      );
    } on TypeError {
      throw const ApiException('Le format des messages est inattendu.');
    }
  }

  // Charge un seul message à partir de son identifiant.
  Future<ForumMessage> message(int id) async {
    final data = await _request('messages/$id');
    try {
      return ForumMessage.fromJson(data);
    } on TypeError {
      throw const ApiException('Le format du message est inattendu.');
    }
  }
}
