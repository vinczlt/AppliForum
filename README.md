# Nocturne — Forum Flutter

Application Flutter utilisant https://4743.s3.nuage-peda.fr/ApiPlatform/api.

## Fonctionnalités de cette étape

- Lecture publique des messages, détail et lien vers le message parent.
- Recherche dans les messages chargés, actualisation et pagination.
- Formulaire d’inscription : prénom, nom, e-mail, mot de passe et confirmation.
- Connexion par e-mail et mot de passe ; déconnexion.
- États de chargement, liste vide et erreurs réseau/serveur.

Aucun compte ou message de démonstration n’est créé par l’application. Les textes renvoyés par le serveur peuvent eux-mêmes être des données pédagogiques. Votes, favoris, catégories et publication locale ont été retirés de cette étape.

## API

- `POST /ApiPlatform/api/users` : JSON-LD, champs `email`, `password`, `nom`, `prenom`, `dateInscription`.
- `POST /ApiPlatform/api/authentication_token` : JSON, champs `email` et `password` ; réponse `token`.
- `GET /ApiPlatform/api/messages?order[id]=desc` : collection JSON-LD (`member`, `totalItems`, `view.next`).
- `GET /ApiPlatform/api/messages/{id}` : détail.

Le jeton est uniquement conservé en mémoire et transmis en `Authorization: Bearer` pour les lectures. Il est effacé à la déconnexion, à la fermeture de l’application ou après un refus HTTP 401 sur une lecture. Aucun mot de passe n’est enregistré sur disque. Une conservation de session entre redémarrages n’est pas implémentée.

## Correction de l’inscription (24 novembre 2026)

Dans `src/Entity/User.php` sur le serveur, le champ `email` a été ajouté au groupe `user:write` et l’import `Symfony\Component\Validator\Constraints as Assert` a été ajouté. Le cache Symfony a été mis de côté dans `var/cache/dev.before-signup-fix-20261124`, puis reconstruit automatiquement.

Vérifications sur le serveur : le schéma expose désormais `email` à l’inscription ; une inscription vide et une adresse mal formée renvoient HTTP 422 avec les erreurs de champs. La date d’inscription est initialisée par le constructeur et le mot de passe est haché par `UserStateProcessor`. Le formulaire Flutter exige maintenant les mêmes 12 caractères minimum, majuscule, minuscule, chiffre et caractère spécial que l’API.

La réussite complète inscription puis connexion reste à vérifier avec le compte de l’utilisateur. Aucun compte fictif n’a été créé pour les tests. Les tests automatiques utilisent un client HTTP simulé, distinct du service réel.

## Lancer et vérifier

```sh
flutter pub get
flutter analyze
flutter test
flutter run -d emulator-5554
```

Vérification réelle en lecture seule :

```sh
dart run tool/check_api.dart
```

Après une modification des dépendances ou de la permission Internet Android, arrêter puis relancer l’application complètement.
