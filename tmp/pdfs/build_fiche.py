from pathlib import Path
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib import colors
from reportlab.lib.pagesizes import A4
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
for n,f in [('Body','segoeui.ttf'),('Bold','segoeuib.ttf')]: pdfmetrics.registerFont(TTFont(n,'C:/Windows/Fonts/'+f))
pdfmetrics.registerFontFamily('Body',normal='Body',bold='Bold')
ink=colors.HexColor('#172336'); teal=colors.HexColor('#087E86')
pstyle=ParagraphStyle('p',fontName='Body',fontSize=11,leading=16,textColor=ink,spaceAfter=8)
hstyle=ParagraphStyle('h',fontName='Bold',fontSize=13,leading=18,textColor=teal,spaceBefore=10,spaceAfter=5)
s=[]
def p(t): s.append(Paragraph(t,pstyle))
def h(t): s.append(Paragraph(t,hstyle))
s.append(Paragraph('Mon forum Flutter : l’essentiel',ParagraphStyle('title',fontName='Bold',fontSize=23,leading=29,textColor=ink,spaceAfter=8)))
p('Objectif : <b>s’inscrire, se connecter et lire les messages.</b>')
h('1. Où se trouve le code ?')
p('<b>lib/main.dart</b> : les écrans, les boutons et les formulaires.<br/><b>lib/forum_api.dart</b> : les échanges avec l’API et les données reçues.')
p('<b>Flutter affiche</b> l’application. <b>Dart</b> est le langage du code.<br/><b>L’API</b> reçoit les demandes et accède à la base de données.')
h('2. Comment fonctionne l’inscription ?')
p('L’utilisateur remplit son prénom, son nom, son e-mail et son mot de passe. Le formulaire vérifie les champs, puis <b>register()</b> envoie une demande <b>POST /users</b> à l’API.')
p('Le serveur valide les informations, hache le mot de passe et crée le compte. Flutter affiche le succès <b>seulement après confirmation du serveur</b>, puis propose de se connecter.')
h('3. Comment fonctionne la connexion ?')
p('<b>login()</b> envoie l’e-mail et le mot de passe à <b>POST /authentication_token</b>. Si les identifiants sont corrects, l’API renvoie un <b>jeton</b> : une preuve de connexion.')
p('Flutter garde ce jeton en mémoire pour les appels suivants. <b>logout()</b> l’efface. La session n’est pas conservée après fermeture complète de l’application.')
h('4. Comment affiche-t-on les messages ?')
p('<b>messages()</b> demande la liste avec <b>GET /messages</b>. L’API répond en <b>JSON</b>, un format de données. <b>ForumMessage.fromJson()</b> transforme ces données en objets Dart, affichés dans une <b>ListView</b>.')
p('Un clic charge le détail avec <b>GET /messages/{id}</b>. La recherche filtre seulement les messages déjà chargés. Leur lecture est possible sans connexion.')
h('5. Les mots à retenir dans le code')
rows=[['Widget','Une brique visuelle : texte, bouton, champ…'],['setState()','Met à jour l’écran après un changement.'],['async / await','Permet d’attendre la réponse de l’API.'],['validator','Vérifie une saisie avant son envoi.'],['try / catch','Gère une erreur et affiche un message clair.']]
t=Table([[Paragraph(a,pstyle),Paragraph(b,pstyle)] for a,b in rows],colWidths=[115,372]);t.setStyle(TableStyle([('BACKGROUND',(0,0),(-1,-1),colors.HexColor('#EDF5F5')),('VALIGN',(0,0),(-1,-1),'TOP'),('LEFTPADDING',(0,0),(-1,-1),9),('TOPPADDING',(0,0),(-1,-1),4),('BOTTOMPADDING',(0,0),(-1,-1),1)]));s.append(t)
s.append(Spacer(1,12))
p('<b>À retenir :</b> bouton → fonction Dart → requête API → réponse → mise à jour de l’écran.')
def footer(c,d):
 c.setFont('Body',8);c.setFillColor(colors.HexColor('#566477'));c.drawString(54,27,'NOCTURNE • Fiche de révision • 25 novembre 2026');c.drawRightString(A4[0]-54,27,'1 / 1')
path=Path('output/pdf/Fiche_Flutter_Nocturne.pdf')
SimpleDocTemplate(str(path),pagesize=A4,leftMargin=54,rightMargin=54,topMargin=38,bottomMargin=43,title='Fiche simple - Forum Flutter Nocturne').build(s,onFirstPage=footer,onLaterPages=footer)
from pypdf import PdfReader
assert len(PdfReader(path).pages)==1, 'La fiche doit tenir sur une page'
print(path.resolve())
