import 'package:material_ui/material_ui.dart';

import 'forum_api.dart';
import 'screens/forum_home.dart';
import 'theme/app_theme.dart';

// Racine de l’application : choisit le thème et le premier écran.
// StatelessWidget ne conserve pas d’état mutable propre.
class MyApp extends StatelessWidget {
  const MyApp({super.key, this.api});
  // En utilisation normale, l’accueil crée le service API.
  // Les tests peuvent fournir leur propre service avec des réponses simulées.
  final ForumApi? api;
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Nocturne — Forum',
    theme: buildAppTheme(),
    home: ForumHome(api: api),
  );
}
