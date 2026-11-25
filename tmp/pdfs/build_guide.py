from pathlib import Path
from xml.sax.saxutils import escape
import re
from reportlab.pdfgen import canvas
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, PageBreak, Table, TableStyle, Preformatted, KeepTogether, Flowable
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib import colors
from reportlab.lib.enums import TA_LEFT
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.lib.pagesizes import A4

ROOT=Path.cwd()
OUT=ROOT/'output/pdf/Comprendre_Flutter_Nocturne.pdf'
for name,file in [('Body','segoeui.ttf'),('Bold','segoeuib.ttf'),('Code','consola.ttf')]:
    pdfmetrics.registerFont(TTFont(name, 'C:/Windows/Fonts/'+file))
pdfmetrics.registerFontFamily('Body',normal='Body',bold='Bold',italic='Body',boldItalic='Bold')
INK=colors.HexColor('#172336'); MUTED=colors.HexColor('#566477'); TEAL=colors.HexColor('#087E86'); LIGHT=colors.HexColor('#EDF5F5'); BORDER=colors.HexColor('#D8E2E8')
styles={
 'h1':ParagraphStyle('h1',fontName='Bold',fontSize=25,leading=30,textColor=INK,spaceAfter=14),
 'h2':ParagraphStyle('h2',fontName='Bold',fontSize=13,leading=18,textColor=INK,spaceBefore=13,spaceAfter=7),
 'p':ParagraphStyle('p',fontName='Body',fontSize=10.3,leading=15.3,textColor=INK,spaceAfter=8),
 'small':ParagraphStyle('small',fontName='Body',fontSize=8.5,leading=12,textColor=MUTED,spaceAfter=6),
 'label':ParagraphStyle('label',fontName='Bold',fontSize=9,leading=12,textColor=TEAL,spaceAfter=9),
 'cell':ParagraphStyle('cell',fontName='Body',fontSize=9.3,leading=13,textColor=INK),
 'code':ParagraphStyle('code',fontName='Code',fontSize=8.1,leading=11.2,textColor=INK),
}
story=[]
def p(s,style='p'): story.append(Paragraph(s,styles[style]))
def h(s): p(s,'h2')
def code(s):
    lines=s.strip('\n').splitlines()
    # Each snippet is deliberately short enough to read at full page scale.
    for line in lines:
        if pdfmetrics.stringWidth(line,'Code',8.1)>465: raise ValueError('Code too wide: '+line)
    box=Table([[Preformatted(s.strip('\n'),styles['code'])]],colWidths=[487])
    box.setStyle(TableStyle([('BACKGROUND',(0,0),(-1,-1),colors.HexColor('#F3F5F8')),('BOX',(0,0),(-1,-1),.5,BORDER),('LEFTPADDING',(0,0),(-1,-1),11),('RIGHTPADDING',(0,0),(-1,-1),11),('TOPPADDING',(0,0),(-1,-1),10),('BOTTOMPADDING',(0,0),(-1,-1),10)]))
    story.extend([box,Spacer(1,9)])
def note(s):
    t=Table([[Paragraph(s,styles['p'])]],colWidths=[487]);t.setStyle(TableStyle([('BACKGROUND',(0,0),(-1,-1),LIGHT),('LINEBEFORE',(0,0),(0,-1),3,TEAL),('LEFTPADDING',(0,0),(-1,-1),12),('RIGHTPADDING',(0,0),(-1,-1),12),('TOPPADDING',(0,0),(-1,-1),9),('BOTTOMPADDING',(0,0),(-1,-1),4)]));story.extend([t,Spacer(1,9)])
def table(rows,widths):
    data=[[Paragraph(escape(str(c)),styles['cell']) for c in row] for row in rows]
    t=Table(data,colWidths=widths,hAlign='LEFT');t.setStyle(TableStyle([('BACKGROUND',(0,0),(-1,0),LIGHT),('VALIGN',(0,0),(-1,-1),'TOP'),('LINEBELOW',(0,0),(-1,-1),.4,BORDER),('LEFTPADDING',(0,0),(-1,-1),8),('RIGHTPADDING',(0,0),(-1,-1),8),('TOPPADDING',(0,0),(-1,-1),8),('BOTTOMPADDING',(0,0),(-1,-1),8)]));story.extend([t,Spacer(1,9)])
def start(n,title,ref):
    if story: story.append(PageBreak())
    p(f'NOCTURNE  /  GUIDE D’APPRENTISSAGE  /  {n:02d}','label');p(title,'h1');p(ref,'small')
class Diagram(Flowable):
    def __init__(self): Flowable.__init__(self);self.width=487;self.height=103
    def draw(self):
        c=self.canv
        for x,title,sub in [(0,'FLUTTER','Écrans + service API'),(174,'API SYMFONY','Validation + traitement'),(348,'BASE DE DONNÉES','Comptes + messages')]:
            c.setFillColor(LIGHT);c.roundRect(x,34,139,62,7,fill=1,stroke=0)
            c.setFillColor(INK);c.setFont('Bold',9);c.drawCentredString(x+69.5,72,title)
            c.setFont('Body',8);c.drawCentredString(x+69.5,52,sub)
        c.setStrokeColor(TEAL)
        for x in [143,317]:
            c.line(x,70,x+26,70);c.line(x+26,70,x+21,73);c.line(x+26,70,x+21,67)
            c.line(x+26,50,x,50);c.line(x,50,x+5,53);c.line(x,50,x+5,47)
        c.setFont('Body',8.5);c.setFillColor(MUTED);c.drawString(0,13,'Flutter envoie une requête HTTPS ; le serveur renvoie une réponse JSON.')

start(1,'Comprendre ton forum Flutter','Inscription • Connexion • Lecture des messages | Version étudiée : 24 novembre 2026')
p('Ce guide explique <b>comment ton application Nocturne a été construite</b>. L’objectif est de comprendre le rôle de chaque morceau de code, puis de savoir le retrouver et le modifier toi-même.')
h('Le cahier des charges de cette étape')
table([['Besoin','Ce que fait l’application'],['S’inscrire','Recueille les informations, les vérifie et demande à l’API de créer un compte.'],['Se connecter','Envoie les identifiants et conserve le jeton renvoyé par le serveur.'],['Lire les messages','Charge la liste, permet une recherche locale et ouvre le contenu complet.']],[110,377])
h('Qui fait quoi ?')
story.append(Diagram())
p('<b>Flutter</b> construit l’interface. <b>Dart</b> est le langage utilisé pour écrire le code Flutter. <b>L’API</b> est le service web auquel l’application demande les données. <b>La base de données</b> conserve les comptes et les messages sur le serveur.')
note('<b>À retenir :</b> Flutter ne crée pas directement un compte dans la base. Il envoie une demande à l’API, qui la valide et l’enregistre.')
h('Parcours conseillé')
p('Pages 2-4 : comprendre les fichiers, les widgets et les formulaires.<br/>Pages 5-8 : suivre l’inscription, la connexion et les messages.<br/>Pages 9-11 : comprendre la correction serveur, tester et s’entraîner.')
p('Les extraits « simplifiés » sont pédagogiques et ne remplacent pas des fichiers complets. Les autres extraits proviennent du projet. Aucun identifiant personnel n’est utilisé dans ce guide.','small')

start(2,'Les fichiers et les widgets','Repères : lib/main.dart • lib/forum_api.dart • pubspec.yaml')
table([['Fichier','Rôle'],['lib/main.dart','Les écrans, les champs, les boutons, la navigation et le thème sombre.'],['lib/forum_api.dart','Les requêtes HTTP, les données des messages et les erreurs de l’API.'],['pubspec.yaml','La configuration du projet et les dépendances, dont le package http.'],['android/app/src/main/AndroidManifest.xml','La permission INTERNET pour que l’application Android accède à l’API.'],['test/','Les tests du service API et des écrans.']],[225,262])
h('Le point de départ')
code('void main() => runApp(const MyApp());')
p('<b>main()</b> est exécutée au démarrage. <b>runApp</b> affiche le widget racine <b>MyApp</b>. Le mot <b>const</b> indique ici une construction constante.')
h('Un widget est une brique d’interface')
p('Un texte est un <b>Text</b>, un bouton est un <b>FilledButton</b>, une liste est une <b>ListView</b>. Les briques sont assemblées dans un arbre. Dans ton application :')
code('MyApp\n  MaterialApp       // thème et navigation\n    ForumHome\n      Scaffold      // structure de la page\n        AppBar      // barre en haut\n        ListView    // messages ou espace compte\n        NavigationBar  // Messages / Mon compte')
p('<b>build(context)</b> décrit l’interface à afficher. Le <b>context</b> permet notamment d’accéder au thème et à la navigation. Le thème centralise les couleurs ; la fonction <b>surface()</b> réutilise le même style de carte.')
note('Sur un écran large, <b>NavigationRail</b> remplace la barre du bas. Le contenu reste limité en largeur avec <b>ConstrainedBox</b> pour faciliter la lecture.')

start(3,'Faire évoluer l’écran','Repères : ForumHome • _ForumHomeState • initState() • load()')
p('<b>MyApp</b> est un <b>StatelessWidget</b> : il ne gère pas d’état mutable propre. <b>ForumHome</b> est un <b>StatefulWidget</b> : sa liste de messages, son chargement et son onglet peuvent changer.')
code('final List<ForumMessage> messages = [];\nbool loading = true;\nString? error, next;\nint total = 0, tab = 0;')
p('<b>messages</b> contient les messages chargés. <b>loading</b> commande l’indicateur d’attente. <b>error</b> contient une erreur éventuelle. <b>next</b> contient le lien de la page suivante. <b>tab</b> indique l’onglet sélectionné.')
h('Le chargement est asynchrone')
p('Une requête réseau ne répond pas immédiatement. <b>Future</b> représente un résultat à venir ; <b>async</b> permet d’utiliser <b>await</b>. Pendant cette attente, l’application peut continuer à afficher l’interface.')
code('// Extrait simplifié de load()\nsetState(() {\n  loading = true;\n  error = null;\n});\ntry {\n  final page = await api.messages();\n  if (!mounted) return;\n  setState(() {\n    messages.clear();\n    messages.addAll(page.messages);\n  });\n} on ApiException catch (e) {\n  if (mounted) setState(() => error = e.message);\n} finally {\n  if (mounted) setState(() => loading = false);\n}')
p('<b>setState</b> signale une modification et demande à Flutter de reconstruire l’interface. Le travail réseau est effectué <b>en dehors</b> de son bloc. <b>mounted</b> vérifie que l’écran existe encore après l’attente.')
note('<b>initState()</b> démarre le premier chargement une seule fois pour cet état. <b>dispose()</b> libère les contrôleurs et, si l’écran l’a créé, le client HTTP. On ne lance pas la requête dans <b>build()</b>, qui peut être rappelée souvent.')

start(4,'Comprendre le formulaire','Repères : AuthPage • _AuthPageState • TextFormField • submit()')
p('Un seul écran <b>AuthPage</b> gère les deux cas. Quand <b>register = true</b>, il montre l’inscription. Quand <b>register = false</b>, il montre la connexion. Cela évite de recopier les champs e-mail et mot de passe.')
h('Lire et vérifier une saisie')
code('// Extrait simplifié\nfinal form = GlobalKey<FormState>();\nfinal email = TextEditingController();\n\nForm(\n  key: form,\n  child: TextFormField(\n    controller: email,\n    validator: (value) {\n      if (value == null || value.trim().isEmpty) {\n        return "Saisissez votre e-mail.";\n      }\n      return null;\n    },\n  ),\n)')
p('Le <b>controller</b> donne accès à la saisie via <b>email.text</b>. Le <b>validator</b> renvoie un texte quand le champ est incorrect, ou <b>null</b> quand il est valide. Dans le vrai code, le format de l’e-mail est également vérifié.')
code('if (busy || !form.currentState!.validate()) return;')
p('Cette ligne de <b>submit()</b> arrête l’action si un envoi est déjà en cours ou si un champ est invalide. <b>busy</b> désactive aussi le bouton et affiche une roue de chargement.')
h('Les règles appliquées à l’inscription')
p('Prénom et nom non vides ; e-mail au format valide ; mot de passe de <b>12 caractères minimum</b> avec majuscule, minuscule, chiffre et caractère spécial ; confirmation identique. Une <b>RegExp</b> est un motif qui vérifie ces caractéristiques.')
note('La validation Flutter donne un retour immédiat. <b>Le serveur doit aussi valider</b> : une autre application peut envoyer une requête sans utiliser ton formulaire. Les contraintes de nom et prénom du serveur sont plus strictes que le simple contrôle « non vide » de Flutter.')

start(5,'Suivre une inscription','Repères : AuthPage.submit() → ForumApi.register() → POST /api/users')
p('<b>1.</b> L’utilisateur remplit les champs.<br/><b>2.</b> Le formulaire valide les saisies.<br/><b>3.</b> <b>submit()</b> appelle le service API avec les valeurs des contrôleurs.')
code('await widget.api.register(\n  email: email.text,\n  password: password.text,\n  lastName: lastName.text,\n  firstName: firstName.text,\n);')
p('Les noms de paramètres permettent de comprendre quelle valeur est transmise. Le service transforme ensuite ces valeurs en champs attendus par le serveur :')
code('// Corps envoyé par ForumApi.register()\n{\n  \'email\': email.trim(),\n  \'password\': password,\n  \'nom\': lastName.trim(),\n  \'prenom\': firstName.trim(),\n  \'dateInscription\': DateTime.now().toUtc().toIso8601String(),\n}')
p('<b>trim()</b> retire les espaces au début et à la fin des textes. Il n’est pas appliqué au mot de passe pour ne pas modifier le secret choisi. <b>jsonEncode</b>, dans le service, transforme cette structure Dart en texte JSON.')
h('Ce que fait le serveur')
p('L’API reçoit la requête <b>POST</b>, contrôle les champs, hache le mot de passe et enregistre le compte. La date est envoyée par Flutter, mais dans cette API elle n’appartient pas au groupe d’écriture : <b>le constructeur User initialise la date côté serveur</b>.')
h('Ce qui apparaît après la réponse')
p('Si le serveur confirme la création, Flutter affiche « Votre compte a été créé », bascule vers la connexion et vide les champs de mot de passe. Si le serveur refuse, l’écran conserve le formulaire et montre l’erreur.')
note('<b>Créer un compte et se connecter sont deux actions distinctes.</b> L’inscription ne crée pas de session dans le code actuel. Il faut ensuite utiliser le formulaire de connexion.')

start(6,'Comprendre la connexion','Repères : ForumApi.login() • _token • logout()')
p('Le formulaire transmet l’e-mail et le mot de passe à <b>POST /api/authentication_token</b>. L’API vérifie les identifiants et renvoie un <b>jeton JWT</b> si la connexion réussit.')
code('// Extrait du service : contrôle et stockage du jeton\nfinal data = await _request(\n  \'authentication_token\',\n  body: {\n    \'email\': email.trim(),\n    \'password\': password,\n  },\n  login: true,\n);\nfinal token = data[\'token\'];\nif (token is! String || token.isEmpty) {\n  throw const ApiException(\n    \'Le serveur n’a pas renvoyé de jeton de connexion.\',\n  );\n}\n_token = token;\nthis.email = email.trim();')
p('On ne considère pas la connexion comme réussie simplement parce que le bouton a été pressé. <b>Il faut recevoir un jeton non vide.</b> Les erreurs d’identifiants sont affichées sans créer de fausse session.')
h('À quoi sert le jeton ?')
code("'Authorization': 'Bearer $_token'")
p('Cet en-tête accompagne les requêtes de lecture lorsque la session existe. <b>Bearer</b> signifie que l’accès repose sur le jeton fourni. Le serveur vérifie sa validité ; Flutter ne décide pas lui-même des permissions.')
h('Retour à l’écran principal')
p('Après une connexion réussie, <b>Navigator.pop(context, true)</b> ferme le formulaire. La méthode <b>authenticate()</b> récupère ce <b>true</b>, rafraîchit l’écran et recharge les messages.')
note('Le jeton est conservé <b>uniquement en mémoire</b>. Il disparaît à la fermeture complète de l’application ou à la déconnexion. Un HTTP 401 sur une lecture efface aussi la session. <b>isLoggedIn</b> vérifie la présence du jeton, pas sa date d’expiration ; le serveur reste l’autorité.')

start(7,'Transformer et afficher les messages','Repères : ForumMessage.fromJson() • MessagePage • feed() • MessageDetailPage')
p('L’API renvoie du JSON-LD : une liste <b>member</b>, un total <b>totalItems</b> et parfois un lien de page suivante <b>view.next</b>. Le code accepte aussi les anciennes clés préfixées par <b>hydra:</b>.')
h('Passer des données réseau à un objet Dart')
code('// Extrait simplifié du modèle\nForumMessage(\n  id: (json[\'id\'] as num).toInt(),\n  title: json[\'titre\'] as String? ?? \'\',\n  content: json[\'contenu\'] as String? ?? \'\',\n  author: name,\n  date: DateTime.tryParse(json[\'datePoste\'] as String? ?? \'\'),\n)')
p('<b>ForumMessage</b> est un modèle : un objet qui représente un message. La fabrique <b>fromJson()</b> fait la conversion. Le prénom et le nom de l’auteur sont assemblés depuis <b>user</b>. Le champ <b>message</b> éventuel fournit la référence au message parent.')
table([['Champ API','Champ utilisé dans Flutter'],['titre / contenu','title / content'],['user.prenom + user.nom','author'],['datePoste','date, convertie en heure locale pour l’affichage'],['member / totalItems / view.next','MessagePage.messages / total / next']],[235,252])
h('Liste, recherche et pagination')
p('<b>feed()</b> produit des cartes dans une <b>ListView</b>. La recherche utilise <b>where</b> et <b>contains</b> sur le titre, le contenu et l’auteur, après passage en minuscules. Elle filtre <b>uniquement les messages déjà chargés</b>, sans recherche distante.')
p('Le bouton « Charger les messages suivants » utilise le lien <b>next</b>. <b>load(more: true)</b> ajoute les nouveaux messages et évite les doublons par identifiant. Tirer la liste vers le bas déclenche <b>RefreshIndicator</b> et recharge la première page.')
note('Un clic ouvre <b>MessageDetailPage</b> avec l’identifiant. Cet écran effectue un nouveau <b>GET /messages/{id}</b> et affiche le contenu complet avec <b>SelectableText</b>. Le tri de la liste est par identifiant décroissant, pas par date.')

start(8,'Le service HTTP et les erreurs','Repères : ForumApi._request() • _uri() • ApiException • ErrorNotice')
p('La méthode privée <b>_request()</b> centralise les échanges. Cela évite de réécrire les mêmes en-têtes, décodages et contrôles dans chaque écran. Le préfixe <b>_</b> rend un nom privé à la bibliothèque Dart.')
code('// Principe simplifié de la requête\nfinal response = await (body == null\n    ? _client.get(uri, headers: headers)\n    : _client.post(\n        uri, headers: headers, body: jsonEncode(body),\n      ))\n    .timeout(const Duration(seconds: 20));\n\nfinal decoded = jsonDecode(utf8.decode(response.bodyBytes));')
p('Dans ce service, absence de corps = <b>GET</b> ; présence d’un corps = <b>POST</b>. L’inscription utilise <b>application/ld+json</b> et la connexion <b>application/json</b>. UTF-8 permet de décoder correctement les accents.')
table([['Résultat','Comportement prévu'],['200-299','Réponse considérée comme réussie ; lecture des données.'],['401','Identifiants incorrects ou session expirée selon l’appel.'],['403 / 404','Accès refusé / ressource introuvable.'],['422 avec violations','Affichage des erreurs de validation renvoyées par champ.'],['429 / 500 et plus','Trop de tentatives / problème côté serveur.'],['Réseau indisponible / délai > 20 s','Message compréhensible invitant à réessayer.']],[155,332])
p('Le service lève une <b>ApiException</b>. L’écran la capture avec <b>catch</b>, met à jour son état, puis <b>ErrorNotice</b> affiche le message. L’indicateur de chargement s’arrête dans <b>finally</b>, même en cas d’échec.')
note('<b>Protection du jeton :</b> <b>_uri()</b> vérifie que les liens de pagination restent sur la même origine et dans le chemin de l’API. Un lien vers un autre serveur est refusé avant tout envoi.')

start(9,'Pourquoi l’inscription bloquait','Repères serveur : src/Entity/User.php • src/State/UserStateProcessor.php')
p('Flutter envoyait correctement l’e-mail. Mais l’API ne l’acceptait pas comme champ d’entrée. Le compte arrivait donc à la base de données avec un e-mail vide, ce qui provoquait une erreur serveur.')
h('Le rôle des groupes Symfony')
code('// Dans l’opération POST : seuls ces champs sont acceptés\ndenormalizationContext: [\n  \'groups\' => [\'user:write\']\n]\n\n// Sur la propriété email, après correction :\n#[Groups([\'user:item\', \'user:write\'])]\nprivate ?string $email = null;')
p('<b>user:item</b> sert ici à exposer l’e-mail dans le détail d’un utilisateur. <b>user:write</b> autorise son alimentation à l’inscription. Ce sont des groupes de sérialisation, pas des rôles comme <b>ROLE_ADMIN</b>.')
h('La validation devait aussi être activée correctement')
code(r'use Symfony\Component\Validator\Constraints as Assert;')
p(r'Cet import manquait alors que les attributs utilisaient <b>Assert\NotBlank</b>, <b>Assert\Email</b> et <b>Assert\Regex</b>. L’ajout relie ces noms aux contraintes Symfony. Après correction, les valeurs invalides produisent des erreurs <b>HTTP 422</b>.')
h('Le mot de passe est traité côté serveur')
p('<b>UserStateProcessor</b> appelle <b>hashPassword()</b> avant l’enregistrement. Le hachage produit une empreinte qui sert ensuite à vérifier le mot de passe. Flutter transmet le mot de passe via HTTPS ; il ne remplace pas ce hachage serveur.')
p('Le serveur conservait aussi l’ancien groupe de champs en cache. Le cache de développement a été mis de côté, puis reconstruit. Le schéma d’inscription expose maintenant <b>email</b>.')
note('<b>Leçon de débogage :</b> un formulaire peut être correct alors que le serveur refuse ses données. Il faut vérifier la requête envoyée, le statut HTTP, la réponse et les champs autorisés côté API. Tu as ensuite confirmé que l’inscription fonctionne.')

start(10,'Tester et lancer sur Android','Repères : test/forum_api_test.dart • test/widget_test.dart • tool/check_api.dart')
p('Les tests vérifient un comportement automatiquement. Le projet contient <b>13 tests</b> : 9 tests du service API et 4 tests des écrans. Ils sont passés lors de la vérification de cette version.')
table([['Type','Exemples vérifiés'],['Service API','Conversion des messages, envoi du jeton, refus des identifiants, inscription, erreurs réseau et session expirée.'],['Widgets','Affichage sur petit écran, recherche et détail, bouton Réessayer, formulaire de connexion et validation d’inscription.']],[115,372])
p('<b>MockClient</b> remplace le serveur par des réponses contrôlées pendant les tests. Les noms et mots de passe présents dans ces tests sont des fixtures : ils ne sont ni affichés dans l’application normale, ni envoyés au serveur réel.')
h('Les commandes à connaître')
code('flutter pub get                 # récupérer les dépendances\nflutter analyze                 # analyser le code\nflutter test                    # lancer les tests\nflutter devices                 # voir les appareils disponibles\nflutter run -d emulator-5554     # lancer sur cet émulateur\ndart run tool/check_api.dart     # vérifier la lecture réelle')
p('Exécute-les dans le dossier du projet. <b>emulator-5554</b> doit apparaître dans <b>flutter devices</b> ; l’identifiant peut changer. La vérification avec <b>check_api.dart</b> lit seulement les messages et un détail : elle ne crée pas de compte.')
h('Reconnaître les problèmes déjà rencontrés')
p('<b>« Visual Studio toolchain » :</b> la cible choisie est Windows ; sélectionne Android.<br/><b>Ancienne interface :</b> redémarrer le téléphone ne réinstalle pas l’application ; relance le projet Flutter.<br/><b>« Unable to delete directory » :</b> des fichiers temporaires de <b>build</b> étaient en lecture seule. Ce problème de compilation est distinct d’un bug dans le formulaire.')
note('<b>Hot reload</b> recharge le code tout en conservant l’état. Un redémarrage complet repart de zéro et perd le jeton en mémoire. Après une modification Android native ou de dépendances, arrête puis relance l’application.')

start(11,'T’entraîner et retrouver le code','Petit parcours pratique • Vocabulaire • Limites de la version')
h('Trois exercices progressifs')
p('<b>1. Modifier un texte.</b> Dans <b>ForumHome.feed()</b>, change « La nuit porte conseil. ». Relance : le titre doit changer sans toucher aux données du serveur.')
p('<b>2. Comprendre la validation.</b> Essaie un mot de passe trop court puis deux confirmations différentes. Repère <b>validator</b>, <b>validate()</b> et <b>busy</b>. Résultat attendu : aucun appel d’inscription tant que le formulaire est invalide.')
p('<b>3. Tester une panne sans casser l’API.</b> Dans un test utilisant <b>MockClient</b>, renvoie HTTP 500. Vérifie l’apparition du message d’erreur et la disparition du chargement. Fais cet exercice dans les tests, pas sur le serveur partagé.')
h('Mini-dictionnaire Dart')
table([['Mot / symbole','Signification dans ce projet'],['String? / null','Une chaîne peut être absente ; null représente cette absence.'],['??','Utilise la valeur de droite si celle de gauche est null.'],['!','Affirme qu’une valeur n’est pas null ; provoque une erreur si cette affirmation est fausse.'],['final / late final','Variable affectée une fois ; late permet de l’initialiser plus tard. Une liste final peut quand même changer de contenu.'],['Future / await','Résultat à venir / attendre ce résultat sans bloquer toute l’interface.'],['Map / List','Données par clés et valeurs / collection ordonnée.']],[120,367])
h('Ce que cette étape ne fait pas encore')
p('Pas de publication de messages, de votes, de favoris ou de catégories. Pas de session conservée après fermeture complète. La recherche porte seulement sur les messages chargés. Les éventuels textes d’exemple encore visibles proviennent de l’API.')
h('Où poursuivre ta lecture')
p('<b>Interface :</b> MyApp → ForumHome → AuthPage → MessageDetailPage dans <b>lib/main.dart</b>.<br/><b>Données :</b> ForumMessage → ForumApi → _request() dans <b>lib/forum_api.dart</b>.<br/><b>Vérifications :</b> les deux fichiers de <b>test/</b> et <b>tool/check_api.dart</b>.','small')
p('Sources du guide : code du projet et fichiers serveur examinés pendant la correction. API du projet : <link href="https://4743.s3.nuage-peda.fr/ApiPlatform/api" color="#087E86">4743.s3.nuage-peda.fr/ApiPlatform/api</link>.','small')

class NumberedCanvas(canvas.Canvas):
    def __init__(self,*a,**kw):super().__init__(*a,**kw);self.saved=[]
    def showPage(self):self.saved.append(dict(self.__dict__));self._startPage()
    def save(self):
        n=len(self.saved)
        for state in self.saved:
            self.__dict__.update(state)
            self.setStrokeColor(BORDER);self.line(54,43,A4[0]-54,43)
            self.setFont('Body',8);self.setFillColor(MUTED)
            self.drawString(54,28,'NOCTURNE  /  Comprendre le code Flutter')
            self.drawRightString(A4[0]-54,28,f'{self._pageNumber:02d} / {n:02d}')
            super().showPage()
        super().save()

doc=SimpleDocTemplate(str(OUT),pagesize=A4,rightMargin=54,leftMargin=54,topMargin=43,bottomMargin=58,title='Comprendre Flutter - Le forum Nocturne',author='Guide pédagogique du projet Nocturne')
doc.build(story,canvasmaker=NumberedCanvas)
print(OUT)

