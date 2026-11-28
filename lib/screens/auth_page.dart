import 'package:material_ui/material_ui.dart';

import '../forum_api.dart';
import '../theme/app_theme.dart';
import '../widgets/error_notice.dart';

// Un seul écran pour deux modes : register = true pour créer un compte,
// false pour se connecter. Cela évite de dupliquer les champs communs.
class AuthPage extends StatefulWidget {
  const AuthPage({super.key, required this.api, this.register = false});
  final ForumApi api;
  final bool register;
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  // La clé permet de retrouver le Form et de valider tous ses champs.
  final form = GlobalKey<FormState>();
  // Les contrôleurs permettent de lire les saisies, par exemple email.text.
  final email = TextEditingController(),
      password = TextEditingController(),
      firstName = TextEditingController(),
      lastName = TextEditingController(),
      confirmation = TextEditingController();
  late bool register;
  // obscure masque le mot de passe ; busy indique qu’une requête est en cours.
  bool obscure = true, busy = false;
  String? error, success;
  @override
  void initState() {
    super.initState();
    register = widget.register;
  }

  @override
  // Libère les contrôleurs lorsque le formulaire est retiré.
  void dispose() {
    for (final c in [email, password, firstName, lastName, confirmation]) {
      c.dispose();
    }
    super.dispose();
  }

  // Action du bouton principal : valide les champs puis appelle le serveur.
  Future<void> submit() async {
    // Arrête si un envoi est déjà en cours OU si au moins un champ est invalide.
    if (busy || !form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      busy = true;
      error = null;
      success = null;
    });
    try {
      if (register) {
        await widget.api.register(
          email: email.text,
          password: password.text,
          lastName: lastName.text,
          firstName: firstName.text,
        );
        if (!mounted) return;
        setState(() {
          // Compte créé : on passe en mode connexion. L’inscription ne connecte pas.
          register = false;
          success =
              'Votre compte a été créé. Connectez-vous avec vos identifiants.';
          password.clear();
          confirmation.clear();
        });
      } else {
        await widget.api.login(email.text, password.text);
        // Ferme le formulaire et renvoie true à l’écran qui l’a ouvert.
        if (mounted) Navigator.pop(context, true);
      }
      // Une erreur du serveur reste affichée ici pour permettre une nouvelle tentative.
    } on ApiException catch (e) {
      if (mounted) setState(() => error = e.message);
      // Cette partie s’exécute après un succès comme après une erreur.
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  // Construit l’écran du formulaire à partir des valeurs actuelles de l’état.
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(register ? 'Inscription' : 'Connexion')),
    body: Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        // Permet de défiler lorsque le clavier ou un petit écran réduit la place.
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          // Form regroupe les champs : validate() lance leurs vérifications.
          child: Form(
            key: form,
            child: AutofillGroup(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  const Icon(Icons.nights_stay_outlined, size: 42),
                  const SizedBox(height: 24),
                  Text(
                    register
                        ? 'La conversation commence ici.'
                        : 'Heureux de vous revoir.',
                    style: const TextStyle(
                      fontSize: 29,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -.8,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    register
                        ? 'Inscrivez-vous pour rejoindre Nocturne.'
                        : 'Connectez-vous à votre compte.',
                    style: const TextStyle(color: muted),
                  ),
                  const SizedBox(height: 28),
                  if (error != null) ...[
                    ErrorNotice(error!),
                    const SizedBox(height: 18),
                  ],
                  if (success != null) ...[
                    Text(
                      success!,
                      style: const TextStyle(
                        color: Color(0xFFC8D8BC),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],
                  // Ces champs sont ajoutés à la liste seulement en mode inscription.
                  if (register) ...[
                    TextFormField(
                      key: const Key('firstName'),
                      controller: firstName,
                      enabled: !busy,
                      textCapitalization: TextCapitalization.words,
                      autofillHints: const [AutofillHints.givenName],
                      decoration: const InputDecoration(labelText: 'Prénom'),
                      // null signifie valide ; un texte devient le message d’erreur.
                      validator: (v) => (v?.trim().isEmpty ?? true)
                          ? 'Saisissez votre prénom.'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      key: const Key('lastName'),
                      controller: lastName,
                      enabled: !busy,
                      textCapitalization: TextCapitalization.words,
                      autofillHints: const [AutofillHints.familyName],
                      decoration: const InputDecoration(labelText: 'Nom'),
                      validator: (v) => (v?.trim().isEmpty ?? true)
                          ? 'Saisissez votre nom.'
                          : null,
                    ),
                    const SizedBox(height: 16),
                  ],
                  TextFormField(
                    // Champ e-mail : le contrôleur email permet de lire email.text.
                    key: const Key('email'),
                    controller: email,
                    enabled: !busy,
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    autofillHints: const [AutofillHints.email],
                    decoration: const InputDecoration(
                      labelText: 'Adresse e-mail',
                      prefixIcon: Icon(Icons.alternate_email),
                    ),
                    validator: (v) =>
                        RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                            .hasMatch(v?.trim() ?? '')
                        ? null
                        : 'Saisissez une adresse e-mail valide.',
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    // Champ mot de passe : obscureText commande son masquage.
                    key: const Key('password'),
                    controller: password,
                    enabled: !busy,
                    obscureText: obscure,
                    autocorrect: false,
                    enableSuggestions: false,
                    autofillHints: [
                      register
                          ? AutofillHints.newPassword
                          : AutofillHints.password,
                    ],
                    decoration: InputDecoration(
                      labelText: 'Mot de passe',
                      helperText: register
                          ? '12 caractères minimum : majuscule, minuscule, chiffre et caractère spécial.'
                          : null,
                      helperMaxLines: 3,
                      errorMaxLines: 3,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        tooltip: 'Afficher ou masquer le mot de passe',
                        onPressed: () => setState(() => obscure = !obscure),
                        icon: Icon(
                          obscure
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                    validator: (v) => (v?.isEmpty ?? true)
                        ? 'Saisissez votre mot de passe.'
                        : register &&
                              !RegExp(
                                r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[^A-Za-z0-9]).{12,}$',
                              ).hasMatch(v!)
                        ? '12 caractères minimum, avec majuscule, minuscule, chiffre et caractère spécial.'
                        : null,
                  ),
                  if (register) ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      key: const Key('confirmation'),
                      controller: confirmation,
                      enabled: !busy,
                      obscureText: obscure,
                      autocorrect: false,
                      enableSuggestions: false,
                      decoration: const InputDecoration(
                        labelText: 'Confirmer le mot de passe',
                      ),
                      validator: (v) => v != password.text
                          ? 'Les mots de passe ne correspondent pas.'
                          : null,
                    ),
                  ],
                  const SizedBox(height: 24),
                  FilledButton(
                    // Un onPressed à null désactive le bouton pendant l’envoi.
                    onPressed: busy ? null : submit,
                    child: busy
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(register ? 'Créer mon compte' : 'Se connecter'),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: busy
                        ? null
                        : () => setState(() {
                            register = !register;
                            error = null;
                            success = null;
                            password.clear();
                            confirmation.clear();
                          }),
                    child: Text(
                      register
                          ? 'Déjà membre ? Se connecter'
                          : 'Pas encore membre ? S’inscrire',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
