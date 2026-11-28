import 'package:material_ui/material_ui.dart';

import '../forum_api.dart';
import '../theme/app_theme.dart';
import '../widgets/error_notice.dart';
import '../widgets/forum_panel.dart';
import '../widgets/message_author.dart';
import 'auth_page.dart';
import 'message_detail_page.dart';

// Écran principal : liste des messages et onglet compte.
// Les valeurs qui changent sont conservées dans _ForumHomeState.
class ForumHome extends StatefulWidget {
  const ForumHome({super.key, this.api});
  final ForumApi? api;
  @override
  State<ForumHome> createState() => _ForumHomeState();
}

class _ForumHomeState extends State<ForumHome> {
  late final ForumApi api;
  final search = TextEditingController();
  // Messages déjà reçus ; la recherche filtre uniquement cette liste.
  final List<ForumMessage> messages = [];
  bool loading = true;
  String? error, next;
  int total = 0, tab = 0;

  @override
  void initState() {
    super.initState();
    // ?? signifie : utiliser la valeur de droite si celle de gauche est null.
    // Le même service est transmis aux autres écrans pour partager la connexion.
    api = widget.api ?? ForumApi();
    load();
  }

  @override
  void dispose() {
    // Libère le contrôleur quand cet écran est retiré.
    // On ferme le service seulement si cet écran l’a créé.
    search.dispose();
    if (widget.api == null) api.close();
    super.dispose();
  }

  // Charge les messages. more = true ajoute la page suivante.
  // async / await permettent d’attendre le serveur sans bloquer l’interface.
  Future<void> load({bool more = false}) async {
    // setState signale à Flutter de reconstruire l’affichage après le changement.
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final page = await api.messages(next: more ? next : null);
      // Après l’attente, vérifie que l’écran existe encore avant de le modifier.
      if (!mounted) return;
      setState(() {
        if (!more) messages.clear();
        // Évite d’afficher deux fois le même message entre deux pages de résultats.
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

  // Ouvre le formulaire avec Navigator.push et attend son résultat.
  // La valeur true renvoyée par le formulaire signifie que la connexion a réussi.
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

  // Ouvre le détail avec l’identifiant du message sélectionné.
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
    // Sur grand écran, menu à gauche ; sur petit écran, navigation en bas.
    final wide = MediaQuery.sizeOf(context).width >= 900;
    // Structure de la page : barre du haut, contenu et navigation.
    return Scaffold(
      // Barre du haut : logo, nom du forum et accès au compte.
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
            // Menu vertical réservé aux fenêtres larges.
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
                // Condition ? A : B : affiche A si vrai, sinon B. tab choisit l’onglet.
                child: tab == 0 ? feed() : account(),
              ),
            ),
          ),
        ],
      ),
      // Menu du bas sur téléphone ; null le masque sur grand écran.
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

  // Construit la liste défilante : recherche, chargement, erreurs et cartes.
  Widget feed() {
    final query = search.text.trim().toLowerCase();
    final visible = messages
        .where(
          (m) => '${m.title} ${m.content} ${m.author}'.toLowerCase().contains(
            query,
          ),
        )
        .toList();
    // Permet de tirer la liste vers le bas pour actualiser les messages.
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
          // Champ de recherche : son contrôleur fournit le texte saisi.
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
            ForumPanel(
              child: Column(
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
          // map transforme chaque message en widget ; ... insère ces widgets dans la liste.
          ...visible.map(
            (m) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              // Une carte par message : auteur, titre et aperçu du contenu.
              child: Card(
                margin: EdgeInsets.zero,
                color: panel,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: outline),
                ),
                clipBehavior: Clip.antiAlias,
                // InkWell rend la carte cliquable. Padding espace le contenu, Column l’empile.
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

  // Affiche les boutons de connexion ou les informations de la session.
  // => est une écriture courte pour retourner le widget construit.
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
      ForumPanel(
        child: Column(
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
