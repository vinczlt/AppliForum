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

L’utilisateur a confirmé que le parcours fonctionne après la correction. Aucun compte fictif n’a été créé pour les tests. Les tests automatiques utilisent un client HTTP simulé, distinct du service réel.

## Installer le projet sur une autre machine

### 1. Préparer le PC

Installer Git, Flutter et Android Studio avec le SDK Android et un émulateur (ou utiliser un téléphone Android en débogage USB). Ajouter le dossier `bin` de Flutter au PATH.

Le projet demande Dart `>=3.13.7 <4.0.0` via Flutter (voir `pubspec.yaml`). Vérifier la version fournie par l’installation avec `flutter --version`.

Choisir de préférence un dossier local non synchronisé, par exemple `C:\dev`, pour éviter les problèmes de fichiers de compilation en lecture seule rencontrés dans OneDrive.

### 2. Récupérer les sources

Remplacer `URL_DU_DEPOT` par l’adresse du dépôt GitHub créé pour ce projet :

```sh
git clone URL_DU_DEPOT nocturne
cd nocturne
flutter pub get
flutter doctor
flutter doctor --android-licenses
```

Lire les licences proposées et accepter celles nécessaires au développement Android. Corriger les éventuels problèmes de la rubrique Android de `flutter doctor`.

Ne pas copier `android/local.properties` depuis l’ancien PC : Flutter le régénère avec les chemins du SDK de la nouvelle machine. Ne pas copier non plus `build` ou `.dart_tool`. Conserver `pubspec.lock` dans Git pour retrouver les versions des dépendances.

### 3. Démarrer l’application

Ouvrir le dossier cloné dans VS Code. Démarrer un appareil dans le Device Manager d’Android Studio, puis :

```sh
flutter devices
flutter run -d ID_ANDROID
```

Remplacer `ID_ANDROID` par l’identifiant Android affiché, par exemple `emulator-5554`. Dans VS Code, sélectionner ce même appareil avant d’utiliser F5. La cible Windows exige d’autres outils et n’est pas nécessaire pour lancer Android.

Au premier lancement, Gradle peut télécharger des composants Android. Si un composant manque, installer la version indiquée par l’erreur dans Android Studio, SDK Manager (Show Package Details pour le NDK).

### 4. Comprendre ce qui est partagé

- Le dépôt contient le code Flutter, les tests, les projets de plateforme, les maquettes de référence et les PDF pédagogiques.
- Le code Symfony et la base de données restent sur le serveur : ils ne font pas partie de ce dépôt Flutter.
- L’application utilise la même API distante depuis les deux machines. Les comptes et messages restent donc les mêmes ; une connexion Internet est nécessaire.
- Le jeton de connexion n’est pas partagé par Git : se reconnecter dans l’application sur la nouvelle machine.
- Les fichiers temporaires de génération des PDF dans `tmp/` sont exclus du suivi.

Pour récupérer les prochaines modifications : enregistrer ou committer d’abord son travail local, puis lancer `git pull` et `flutter pub get`.

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
