import 'package:flutter/material.dart';

import 'forum_api.dart';

void main() => runApp(const MyApp());

const background = Color(0xFF0C0C0C);
const panel = Color(0xFF141416);
const outline = Color(0xFF29292E);
const muted = Color(0xFF9999A3);

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.api});
  final ForumApi? api;
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Nocturne — Forum',
    theme: ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: Colors.white,
        onPrimary: background,
        surface: panel,
        outline: outline,
      ),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
      ),
      dividerColor: outline,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: panel,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: outline),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 17),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    ),
    home: ForumHome(api: api),
  );
}

class ForumHome extends StatefulWidget {
  const ForumHome({super.key, this.api});
  final ForumApi? api;
  @override
  State<ForumHome> createState() => _ForumHomeState();
}

class _ForumHomeState extends State<ForumHome> {
  late final ForumApi api;
  final search = TextEditingController();
  final List<ForumMessage> messages = [];
  bool loading = true;
  String? error, next;
  int total = 0, tab = 0;

  @override
  void initState() {
    super.initState();
    api = widget.api ?? ForumApi();
    load();
  }

  @override
  void dispose() {
    search.dispose();
    if (widget.api == null) api.close();
    super.dispose();
  }

  Future<void> load({bool more = false}) async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final page = await api.messages(next: more ? next : null);
      if (!mounted) return;
      setState(() {
        if (!more) messages.clear();
        final ids = messages.map((m) => m.id).toSet();
        messages.addAll(page.messages.where((m) => ids.add(m.id)));
        total = page.total;
        next = page.next;
      });
    } on ApiException catch (e) {
      if (mounted) setState(() => error = e.message);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> authenticate({bool register = false}) async {
    final connected = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AuthPage(api: api, register: register),
      ),
    );
    if (!mounted) return;
    setState(() {});
    if (connected == true) await load();
  }

  Future<void> openMessage(int id) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MessageDetailPage(api: api, id: id),
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 76,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: const Color(0xFFE9E7D9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.nights_stay_outlined,
                color: background,
                size: 25,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nocturne',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 21,
                      letterSpacing: -.7,
                    ),
                  ),
                  Text(
                    'LE FORUM DES CURIEUX',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 9,
                      color: muted,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Mon compte',
            onPressed: () => setState(() => tab = 1),
            icon: Icon(
              api.isLoggedIn ? Icons.account_circle : Icons.person_outline,
            ),
          ),
          const SizedBox(width: 10),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1),
        ),
      ),
      body: Row(
        children: [
          if (wide)
            NavigationRail(
              selectedIndex: tab,
              onDestinationSelected: (v) => setState(() => tab = v),
              extended: true,
              backgroundColor: background,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.forum_outlined),
                  label: Text('Messages'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person_outline),
                  label: Text('Mon compte'),
                ),
              ],
            ),
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: tab == 0 ? feed() : account(),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              backgroundColor: background,
              indicatorColor: outline,
              selectedIndex: tab,
              onDestinationSelected: (v) => setState(() => tab = v),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.forum_outlined),
                  label: 'Messages',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  label: 'Mon compte',
                ),
              ],
            ),
    );
  }

  Widget feed() {
    final query = search.text.trim().toLowerCase();
    final visible = messages
        .where(
          (m) => '${m.title} ${m.content} ${m.author}'.toLowerCase().contains(
            query,
          ),
        )
        .toList();
    return RefreshIndicator(
      onRefresh: () async {
        if (!loading) await load();
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 6),
          const Text(
            'La nuit porte conseil.',
            style: TextStyle(
              fontSize: 29,
              fontWeight: FontWeight.w700,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Retrouvez les messages de la communauté.',
            style: TextStyle(color: muted, height: 1.5),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: search,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Rechercher dans les messages chargés…',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: search.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Effacer la recherche',
                      onPressed: () => setState(search.clear),
                      icon: const Icon(Icons.close),
                    ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${messages.length} / $total messages chargés',
                  style: const TextStyle(color: muted, fontSize: 12),
                ),
              ),
              IconButton(
                tooltip: 'Actualiser',
                onPressed: loading ? null : () => load(),
                icon: const Icon(Icons.refresh, size: 20),
              ),
            ],
          ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ErrorNotice(
                error!,
                onRetry: () => load(more: messages.isNotEmpty && next != null),
              ),
            ),
          if (loading && messages.isEmpty)
            const Padding(
              padding: EdgeInsets.all(48),
              child: Center(child: CircularProgressIndicator()),
            ),
          if (!loading && error == null && visible.isEmpty)
            surface(
              Column(
                children: [
                  const Icon(Icons.chat_bubble_outline, size: 34, color: muted),
                  const SizedBox(height: 16),
                  Text(
                    query.isEmpty
                        ? 'Aucun message pour le moment.'
                        : 'Aucun résultat dans les messages chargés.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: muted),
                  ),
                ],
              ),
            ),
          ...visible.map(
            (m) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Card(
                margin: EdgeInsets.zero,
                color: panel,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: outline),
                ),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => openMessage(m.id),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MessageAuthor(message: m),
                        const SizedBox(height: 16),
                        Text(
                          m.title.isEmpty ? 'Sans titre' : m.title,
                          style: const TextStyle(
                            fontSize: 18,
                            height: 1.4,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 9),
                        Text(
                          m.content,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: muted,
                            height: 1.7,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Row(
                          children: [
                            Text(
                              'Lire le message',
                              style: TextStyle(fontSize: 12),
                            ),
                            Spacer(),
                            Icon(Icons.arrow_forward, size: 17),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (loading && messages.isNotEmpty)
            const Center(child: CircularProgressIndicator()),
          if (next != null && !loading)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: OutlinedButton(
                onPressed: () => load(more: true),
                child: const Text('Charger les messages suivants'),
              ),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget account() => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      const SizedBox(height: 20),
      const Text(
        'Votre coin de nuit.',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          letterSpacing: -1,
        ),
      ),
      const SizedBox(height: 24),
      surface(
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              api.isLoggedIn
                  ? Icons.verified_user_outlined
                  : Icons.person_outline,
              size: 48,
            ),
            const SizedBox(height: 20),
            Text(
              api.isLoggedIn
                  ? 'Vous êtes connecté.'
                  : 'Rejoignez la communauté.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            if (api.isLoggedIn) ...[
              Text(
                api.email ?? '',
                textAlign: TextAlign.center,
                style: const TextStyle(color: muted),
              ),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () {
                  setState(api.logout);
                  load();
                },
                child: const Text('Se déconnecter'),
              ),
              const SizedBox(height: 12),
              const Text(
                'La session reste active jusqu’à la fermeture de l’application ou l’expiration de votre connexion.',
                textAlign: TextAlign.center,
                style: TextStyle(color: muted, fontSize: 12, height: 1.6),
              ),
            ] else ...[
              const Text(
                'Créez votre compte ou retrouvez votre espace. Les messages restent accessibles sans connexion.',
                textAlign: TextAlign.center,
                style: TextStyle(color: muted, height: 1.6),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => authenticate(),
                child: const Text('Se connecter'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => authenticate(register: true),
                child: const Text('S’inscrire'),
              ),
            ],
          ],
        ),
      ),
    ],
  );
}

Widget surface(Widget child) => Container(
  width: double.infinity,
  padding: const EdgeInsets.all(20),
  decoration: BoxDecoration(
    color: panel,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: outline),
  ),
  child: child,
);

class ErrorNotice extends StatelessWidget {
  const ErrorNotice(this.message, {super.key, this.onRetry});
  final String message;
  final VoidCallback? onRetry;
  @override
  Widget build(BuildContext context) => surface(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          message,
          style: const TextStyle(color: Color(0xFFFFB4AB), height: 1.5),
        ),
        if (onRetry != null)
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
          ),
      ],
    ),
  );
}

class MessageAuthor extends StatelessWidget {
  const MessageAuthor({super.key, required this.message});
  final ForumMessage message;
  @override
  Widget build(BuildContext context) {
    final date = message.date?.toLocal();
    final label = date == null
        ? 'Date non renseignée'
        : '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    return Row(
      children: [
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

class AuthPage extends StatefulWidget {
  const AuthPage({super.key, required this.api, this.register = false});
  final ForumApi api;
  final bool register;
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final form = GlobalKey<FormState>();
  final email = TextEditingController(),
      password = TextEditingController(),
      firstName = TextEditingController(),
      lastName = TextEditingController(),
      confirmation = TextEditingController();
  late bool register;
  bool obscure = true, busy = false;
  String? error, success;
  @override
  void initState() {
    super.initState();
    register = widget.register;
  }

  @override
  void dispose() {
    for (final c in [email, password, firstName, lastName, confirmation]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> submit() async {
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
          register = false;
          success =
              'Votre compte a été créé. Connectez-vous avec vos identifiants.';
          password.clear();
          confirmation.clear();
        });
      } else {
        await widget.api.login(email.text, password.text);
        if (mounted) Navigator.pop(context, true);
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => error = e.message);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(register ? 'Inscription' : 'Connexion')),
    body: Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
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
                  if (register) ...[
                    TextFormField(
                      key: const Key('firstName'),
                      controller: firstName,
                      enabled: !busy,
                      textCapitalization: TextCapitalization.words,
                      autofillHints: const [AutofillHints.givenName],
                      decoration: const InputDecoration(labelText: 'Prénom'),
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
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Message')),
    body: Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 740),
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
                    MessageAuthor(message: message!),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 24),
                    SelectableText(
                      message!.content,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.9,
                        color: Color(0xFFCCCCD1),
                      ),
                    ),
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
