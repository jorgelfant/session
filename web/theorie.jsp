<%--
  Created by IntelliJ IDEA.
  User: jorge.carrillo
  Date: 1/30/2020
  Time: 9:43 AM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>$Title$</title>
</head>
<body>

<%--
//----------------------------------------------------------------------------------------------------------------------
//                                       La SESSION : connectez vos clients
//----------------------------------------------------------------------------------------------------------------------
Nous allons ici découvrir par l'exemple comment utiliser la session.

La situation que nous allons mettre en place est un système de connexion des utilisateurs. Nous allons grandement
nous inspirer de ce que nous venons de faire dans le précédent chapitre avec notre système d'inscription, et allons
directement appliquer les bonnes pratiques découvertes. Là encore, nous n'allons pas pouvoir mettre en place un système
complet de A à Z, puisqu'il nous manque toujours la gestion des données. Mais ce n'est pas important : ce qui compte,
c'est que vous tenez là une occasion de plus pour pratiquer la gestion des formulaires en suivant MVC !

//----------------------------------------------------------------------------------------------------------------------
//                                               Le formulaire
//----------------------------------------------------------------------------------------------------------------------

La première chose que nous allons mettre en place est le formulaire de connexion, autrement dit la vue. Cela ne va pas
nous demander trop d'efforts : nous allons reprendre l'architecture de la page JSP que nous avons créée dans le chapitre
précédent, et l'adapter à nos nouveaux besoins !

Voici le code de notre page connexion.jsp, à placer sous le répertoire /WEB-INF :  connexion.jsp

Nous reprenons la même architecture que pour le système d'inscription : notre JSP exploite un objet form contenant
les éventuels messages d'erreur, et un objet utilisateur contenant les données saisies et validées.

Par ailleurs, nous réutilisons la même feuille de style.

//----------------------------------------------------------------------------------------------------------------------
//                                       LE PRINCIPE DE LA SESSION
//----------------------------------------------------------------------------------------------------------------------

Avant d'aller plus loin, nous devons nous attarder un instant sur ce qu'est une session.

**************************************
POURQUOI LES SESSIONS EXISTENT -ELLES ?
**************************************

Notre application web est basée sur le protocole HTTP, qui est un protocole dit "sans état" : cela signifie que le
serveur, une fois qu'il a envoyé une réponse à la requête d'un client, ne conserve pas les données le concernant.
Autrement dit, le serveur traite les clients requête par requête et est absolument incapable de faire un rapprochement
entre leur origine : pour lui, chaque nouvelle requête émane d'un nouveau client, puisqu'il oublie le client après
l'envoi de chaque réponse... Oui, le serveur HTTP est un peu gâteux ! :-°

C'est pour pallier cette lacune que le concept de session a été créé : il permet au serveur de mémoriser des informations
relatives au client, d'une requête à l'autre.

*************************************
QU'EST-CE QU'UNE SESSION EN Java EE ?
*************************************

Souvenez-vous : nous en avions déjà parlé dans ce paragraphe dédié à la portée des objets ainsi que dans ce chapitre
sur la JSTL Core :

   * la session représente un espace mémoire alloué pour chaque utilisateur, permettant de sauvegarder des informations tout
     le long de leur visite ;

   * le contenu d'une session est conservé jusqu'à ce que l'utilisateur ferme son navigateur, reste inactif trop
     longtemps, ou encore lorsqu'il se déconnecte du site ;

   * l'objet Java sur lequel se base une session est l'objet HttpSession ;

   * il existe un objet implicite sessionScope permettant d'accéder directement au contenu de la session depuis une
     expression EL dans une page JSP.

************************************************
Comment manipuler cet objet depuis une servlet ?
************************************************

Pour commencer, il faut le récupérer depuis l'objet HttpServletRequest. Cet objet propose en effet une méthode
getSession(), qui permet de récupérer la session associée à la requête HTTP en cours si elle existe, ou d'en créer
une si elle n'existe pas encore :

                                  HttpSession session = request.getSession();

Ainsi, tant que cette ligne de code n'a pas été appelée, la session n'existe pas !

Ensuite, lorsque nous étudions attentivement la documentation de cet objet, nous remarquons entre autres :

       * qu'il propose un couple de méthodes setAttribute() / getAttribute(), permettant la mise en place d'objets
         au sein de la session et leur récupération, tout comme dans l'objet HttpServletRequest ;

       * qu'il propose une méthode getId(), retournant un identifiant unique permettant de déterminer à qui
         appartient telle session.

Nous savons donc maintenant qu'il nous suffit d'appeler le code suivant pour enregistrer un objet en session depuis
notre servlet, puis le récupérer :


                            /* Création ou récupération de la session */
                            HttpSession session = request.getSession();

                            /* Mise en session d'une chaîne de caractères */
                            String exemple = "abc";
                            session.setAttribute( "chaine", exemple );

                            /* Récupération de l'objet depuis la session */
                            String chaine = (String) session.getAttribute( "chaine" );

C'est tout ce que nous avons besoin de savoir pour le moment.

Observez sur la figure suivante l'enchaînement lors de la première visite d'un utilisateur sur une page ou servlet
contenant un appel à request.getSession().

En fait dans le servlet se crée un objet HTTPSESSION  avec un IDENTIFIANT UNIQUE  du type id = 65AE8...5D32F7
celui ci est transmis à la page JSP qui renvoie au client une REPONSE HTTP contenant l'identifiant de
l'objet HTTPSession crée, et le client enregistre l'identifiant reçu

------------------------------------------------------------------------------------------------------------------------
    1) le navigateur de l'utilisateur envoie une requête au serveur ;

    2) la servlet ne trouve aucune session existante lors de l'appel à getSession(), et crée donc un nouvel
       objet HttpSession qui contient un identifiant unique ;

    3) le serveur place automatiquement l'identifiant de l'objet session dans la réponse renvoyée au navigateur
       de l'utilisateur ;

    4) le navigateur enregistre l'identifiant que le serveur lui a envoyé.


//----------------------------------------------------------------------------------------------------------------------
//                  Observez alors à la figure suivante ce qui se passe lors des prochaines visites.
//----------------------------------------------------------------------------------------------------------------------

   le client envoie une requette HTTP contenant l'identidiant recu dans la première réponse du serveur
   a la servlet qui contient un appel à getSession() , Récupération de l'objet HttpSession existant, grâce à l'identifiant
   transmis par le client, la jsp envoi la réponse HTTP

    1) le navigateur place automatiquement l'identifiant enregistré dans la requête qu'il envoie au serveur ;

    2) la servlet retrouve la session associée à l'utilisateur lors de l'appel à getSession(), grâce à l'identifiant
       unique que le navigateur a placé dans la requête ;

    3) le serveur sait que le navigateur du client a déjà enregistré l'identifiant de la session courante, et renvoie
       donc une réponse classique à l'utilisateur : il sait qu'il n'est pas nécessaire de lui transmettre à nouveau
       l'identifiant !

Vous avez maintenant tout en main pour comprendre comment l'établissement d'une session fonctionne. En ce qui concerne
les rouages du système, chaque chose en son temps : dans la dernière partie de ce chapitre, nous analyserons comment
tout cela s'organise dans les coulisses !

Très bien, nous avons compris comment ça marche. Maintenant dans notre cas, qu'avons-nous besoin d'enregistrer
en session ?

En effet, c'est une très bonne question : qu'est-il intéressant et utile de stocker en session ? Rappelons-le,
notre objectif est de connecter un utilisateur : nous souhaitons donc être capables de le reconnaître d'une requête
à l'autre.

La première intuition qui nous vient à l'esprit, c'est naturellement de sauvegarder l'adresse mail et le mot de passe
de l'utilisateur dans un objet, et de placer cet objet dans la session !

//----------------------------------------------------------------------------------------------------------------------
//                                               LE MODELE
//----------------------------------------------------------------------------------------------------------------------

D'après ce que nous venons de déduire, nous pouvons nous inspirer de ce que nous avons créé dans le chapitre précédent.
Il va nous falloir :

    * un bean représentant un utilisateur, que nous placerons en session lors de la connexion ;

    * un objet métier représentant le formulaire de connexion, pour traiter et valider les données et connecter
      l'utilisateur.

En ce qui concerne l'utilisateur, nous n'avons besoin de rien de nouveau : nous disposons déjà du bean créé pour
le système d'inscription ! Vous devez maintenant bien mieux saisir le caractère réutilisable du JavaBean, que je
vous vantais dans ce chapitre.

En ce qui concerne le formulaire, là par contre nous allons devoir créer un nouvel objet métier. Eh oui, nous n'y
coupons pas : pour chaque nouveau formulaire, nous allons devoir mettre en place un nouvel objet. Vous découvrez
ici un des inconvénients majeurs de l'application de MVC dans une application Java EE uniquement basée sur le trio
objets métier - servlets - pages JSP : il faut réécrire les méthodes de récupération, conversion et validation des
paramètres de la requête HTTP à chaque nouvelle requête traitée !

************************************************************************************************************************
Plus loin dans ce cours, lorsque nous aurons acquis un bagage assez important pour nous lancer au-delà du Java EE "nu",
nous découvrirons comment les développeurs ont réussi à rendre ces étapes entièrement automatisées en utilisant un
framework MVC pour construire leurs applications. En attendant, vous allez devoir faire preuve de patience et être
assidus, nous avons encore du pain sur la planche !
************************************************************************************************************************

Nous devons donc créer un objet métier, que nous allons nommer ConnexionForm et qui va grandement s'inspirer de l'objet
InscriptionForm :

Nous retrouvons ici la même architecture que dans l'objet InscriptionForm :

      * des constantes d'identification des champs du formulaire ;

      * des méthodes de validation des champs ;

      * une méthode de gestion des erreurs ;

      * une méthode centrale, connecterUtilisateur(), qui fait intervenir les méthodes précédemment citées et renvoie
        un bean Utilisateur.

//----------------------------------------------------------------------------------------------------------------------
//                                               LA SERVLET
//----------------------------------------------------------------------------------------------------------------------

Afin de rendre tout ce petit monde opérationnel, nous devons mettre en place une servlet dédiée à la connexion.
Une fois n'est pas coutume, nous allons grandement nous inspirer de ce que nous avons créé dans les chapitres précédents.
Voici donc le code de la servlet nommée Connexion, placée tout comme sa grande sœur dans le package com.sdzee.servlets :

Au niveau de la structure, rien de nouveau : la servlet joue bien un rôle d'aiguilleur, en appelant les traitements
présents dans l'objet ConnexionForm, et en récupérant le bean utilisateur. Ce qui change cette fois, c'est bien entendu
la gestion de la session :

       * à la ligne 33, nous appelons la méthode request.getSession() pour créer une session ou récupérer la session
         existante ;

       * dans le bloc if lignes 39 à 43, nous enregistrons le bean utilisateur en tant qu'attribut de session uniquement
         si aucune erreur de validation n'a été envoyée lors de l'exécution de la méthode connecterUtilisateur().
         À partir du moment où une seule erreur est détectée, c'est-à-dire si form.getErreurs().isEmpty() renvoie false,
         alors le bean utilisateur est supprimé de la session, via un passage de l'attribut à null.

Une fois tout ce code bien en place et votre serveur redémarré, vous pouvez accéder à la page de connexion via votre
navigateur en vous rendant sur l'URL http://localhost:8080/pro/connexion. À la figure suivante, le résultat attendu.

Oui mais voilà, nous n'avons pas encore de moyen de tester le bon fonctionnement de ce semblant de système de connexion !
Et pour cause, les seuls messages que nous affichons dans notre vue, ce sont les résultats des vérifications du contenu
des champs du formulaire... Aux figures suivantes, le résultat actuel respectivement lors d'un échec et d'un succès de
la validation.

Ce qu'il serait maintenant intéressant de vérifier dans notre vue, c'est le contenu de la session. Et comme le hasard
fait très bien les choses, je vous ai justement rappelé en début de chapitre qu'il existe un objet implicite nommé
sessionScope dédié à l'accès au contenu de la session !

//----------------------------------------------------------------------------------------------------------------------
//                                         LES VERIFICATIONS
//----------------------------------------------------------------------------------------------------------------------

Test du formulaire de connexion
*******************************

Pour commencer, nous allons donc modifier notre page JSP afin d'afficher le contenu de la session (connexion.jsp):

Dans cette courte modification (un if fait dans le jsp connexion.jsp) , aux lignes 31 à 35, vous pouvez remarquer :

        * l'utilisation de l'objet implicite sessionScope pour cibler la portée session ;

        * la mise en place d'un test conditionnel via la balise <c:if>. Son contenu (les lignes 33 et 34) s'affichera
          uniquement si le test est validé ;

        * le test de l'existence d'un objet via l'expression ${!empty ...}. Si aucun objet n'est trouvé,
          ce test renvoie false ;

        * l'accès au bean sessionUtilisateur de la session via l'expression ${sessionScope.sessionUtilisateur} ;

        * l'accès à la propriété email du bean sessionUtilisateur via l'expression
          ${sessionScope.sessionUtilisateur.email}.

        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////

        Rappelez-vous : nous pourrions très bien accéder à l'objet en écrivant simplement ${sessionUtilisateur}, et
        l'expression EL chercherait alors d'elle-même un objet nommé sessionUtilisateur dans chaque portée. Mais je
        vous ai déjà dit que la bonne pratique était de réserver cette écriture à l'accès des objets de la portée page,
        et de toujours accéder aux objets des autres portées en précisant l'objet implicite correspondant
        (requestScope, sessionScope ou applicationScope).

        Accédez maintenant à la page http://localhost:8080/pro/connexion, et entrez des données valides.
        Voici à la figure suivante le résultat attendu après succès de la connexion.

        Succes de la connexion

        Vous etes connecté avec l'adresse : lsdfhsdhjs@yahoo.com

        ****************************************************************************************************************

        Ensuite, réaffichez la page http://localhost:8080/pro/connexion, mais attention pas en appuyant sur F5 ni en
        actualisant la page : cela renverrait les données de votre formulaire ! Non, simplement entrez à nouveau l'URL
        dans le même onglet de votre navigateur, ou bien ouvrez un nouvel onglet. Voici à la figure suivante le résultat
        attendu.

        Vous etes connecté avec l'adresse : shfsjksdhjkf@yahoo.com
        ****************************************************************************************************************

        Vous pouvez alors constater que la mémorisation de l'utilisateur a fonctionné ! Lorsqu'il a reçu la deuxième
        requête d'affichage du formulaire, le serveur vous a reconnus : il sait que vous êtes le client qui a effectué
        la requête de connexion auparavant, et a conservé vos informations dans la session. En outre, vous voyez également
        que les informations qui avaient été saisies dans les champs du formulaire lors de la première requête sont bien
        évidemment perdues : elles n'avaient été gérées que via l'objet request, et ont donc été détruites après envoi
        de la première réponse au client.

        ****************************************************************************************************************

        Vous devez maintenant mieux comprendre cette histoire de portée des objets : l'objet qui a été enregistré en
        session reste accessible sur le serveur au fil des requêtes d'un même client, alors que l'objet qui a été
        enregistré dans la requête n'est accessible que lors d'une requête donnée, et disparaît du serveur dès que la
        réponse est envoyée au client.

        Pour finir, testons l'effacement de l'objet de la session lorsqu'une erreur de validation survient. Remplissez
        le formulaire avec des données invalides, et regardez à la figure suivante le résultat renvoyé.

        Le contenu du corps de la balise <c:if> n'est ici pas affiché. Cela signifie que le test de présence de
        l'objet en session a retourné false, et donc que notre servlet a bien passé l'objet utilisateur à null dans
        la session. En conclusion, jusqu'à présent, tout roule ! ;)


//----------------------------------------------------------------------------------------------------------------------
//                                      Test de la destruction de session
//----------------------------------------------------------------------------------------------------------------------

Je vous l'ai rappelé en début de chapitre, la session peut être détruite dans plusieurs circonstances :

       * l'utilisateur ferme son navigateur ;

       * la session expire après une période d'inactivité de l'utilisateur ;

       * l'utilisateur se déconnecte.

**********************************
L'utilisateur ferme son navigateur
**********************************

Ce paragraphe va être très court. Faites le test vous-mêmes :

    1) ouvrez un navigateur et affichez le formulaire de connexion ;

    2) entrez des données valides et connectez-vous ;

    3) fermez votre navigateur ;

    4) rouvrez-le, et rendez-vous à nouveau sur le formulaire de connexion.

Vous constaterez alors que le serveur ne vous a pas reconnus : les informations vous concernant n'existent plus, et
le serveur considère que vous êtes un nouveau client.

Quand on parle de fermer le navigateur on parle de fermer tout le navigateur et pas seulement une de tabs du navigateur

*****************************************************************
La session expire après une période d'inactivité de l'utilisateur
*****************************************************************

Par défaut avec Tomcat, la durée maximum de validité imposée au-delà de laquelle la session est automatiquement
détruite par le serveur est de 30 minutes. Vous vous doutez bien que nous n'allons pas poireauter une demi-heure
devant notre écran pour vérifier si cela fonctionne bien : vous avez la possibilité via le fichier web.xml de votre
application de personnaliser cette durée. Ouvrez-le dans Eclipse et modifiez-le comme suit :

                                <?xml version="1.0" encoding="UTF-8"?>
                                <web-app>
                                   	<session-config>
                                   		<session-timeout>1</session-timeout>
                                   	</session-config>

                                   	<servlet>
                                   		<servlet-name>Inscription</servlet-name>
                                   		<servlet-class>com.sdzee.servlets.Inscription</servlet-class>
                                   	</servlet>
                                   	<servlet>
                                   		<servlet-name>Connexion</servlet-name>
                                   		<servlet-class>com.sdzee.servlets.Connexion</servlet-class>
                                   	</servlet>

                                   	<servlet-mapping>
                                   		<servlet-name>Inscription</servlet-name>
                                   		<url-pattern>/inscription</url-pattern>
                                   	</servlet-mapping>
                                   	<servlet-mapping>
                                   		<servlet-name>Connexion</servlet-name>
                                   		<url-pattern>/connexion</url-pattern>
                                   	</servlet-mapping>
                                </web-app>

Le champ <session-timeout> permet de définir en minutes le temps d'inactivité de l'utilisateur après lequel sa session
est détruite. Je l'ai ici abaissé à une minute, uniquement pour effectuer notre vérification. Redémarrez Tomcat afin que
la modification apportée au fichier soit prise en compte, puis :

    1) ouvrez un navigateur et affichez le formulaire de connexion ;

    2) entrez des données valides et connectez-vous ;

    3) attendez quelques minutes, puis affichez à nouveau le formulaire, dans la même page ou dans un nouvel onglet.

Vous constaterez alors que le serveur vous a oubliés : les informations vous concernant n'existent plus, et le serveur
considère que vous êtes un nouveau client.

Une fois ce test effectué, éditez à nouveau votre fichier web.xml et supprimez la section fraîchement ajoutée :
dans la suite de nos exemples, nous n'allons pas avoir besoin de cette limitation.

*********************************
L'utilisateur se déconnecte
*********************************

Cette dernière vérification va nécessiter un peu de développement. En effet, nous avons créé une servlet de connexion,
mais nous n'avons pas encore mis en place de <<servlet de déconnexion>>. Par conséquent, il est pour le moment impossible
pour le client de se déconnecter volontairement du site, il est obligé de fermer son navigateur ou d'attendre que la
durée d'inactivité soit dépassée.

Comment détruire manuellement une session ?
******************************************

Il faut regarder dans la documentation de l'objet HttpSession pour répondre à cette question : nous y trouvons une
méthode invalidate(), qui supprime une session et les objets qu'elle contient, et envoie une exception si jamais elle
est appliquée sur une session déjà détruite.

Créons sans plus attendre notre nouvelle servlet nommée Deconnexion :

       public class Deconnexion extends HttpServlet {
           public static final String URL_REDIRECTION = "http://www.siteduzero.com";

           public void doGet( HttpServletRequest request, HttpServletResponse response ) throws ServletException, IOException {
               /* Récupération et destruction de la session en cours */
               HttpSession session = request.getSession();
               session.invalidate();

               /* Redirection vers le Site du Zéro ! */
               response.sendRedirect( URL_REDIRECTION );
           }
       }

Vous remarquez ici deux nouveautés :

l'appel à la méthode invalidate() de l'objet HttpSession ;

la redirection vers la page de connexion via la méthode sendRedirect() de l'objet HttpServletResponse, en lieu et place
du forwarding que nous utilisions auparavant.

************************************************************************************************************************
                        Quelle est la différence entre la redirection et le forwarding ?
************************************************************************************************************************

En réalité, vous le savez déjà ! Eh oui, vous ne l'avez pas encore appliqué depuis une servlet, mais je vous
ai déjà expliqué le principe lorsque nous avons découvert la balise <c:redirect>, dans cette partie du chapitre
portant sur la JSTL Core.

Pour rappel donc, une redirection HTTP implique l'envoi d'une réponse au client, alors que le forwarding
s'effectue sur le serveur et le client n'en est pas tenu informé. Cela implique notamment que, via un
forwarding, il est uniquement possible de cibler des pages internes à l'application, alors que via la
redirection il est possible d'atteindre n'importe quelle URL publique ! En l'occurrence, dans notre servlet
j'ai fait en sorte que lorsque vous vous déconnectez, vous êtes redirigés vers votre site web préféré.

Fin du rappel, nous allons de toute manière y revenir dans le prochain paragraphe. Pour le moment,
concentrons-nous sur la destruction de notre session !

Déclarons notre servlet dans le fichier web.xml de l'application :

                        <servlet>
                        	<servlet-name>Deconnexion</servlet-name>
                        	<servlet-class>com.sdzee.servlets.Deconnexion</servlet-class>
                        </servlet>

                         <servlet-mapping>
                         	<servlet-name>Deconnexion</servlet-name>
                         	<url-pattern>/deconnexion</url-pattern>
                         </servlet-mapping>

------------------------------------------------------------------------------------------------------------------------

Redémarrez Tomcat pour que la modification du fichier web.xml soit prise en compte, et testez alors comme suit :

       1) ouvrez un navigateur et affichez le formulaire de connexion ;

       2) entrez des données valides et connectez-vous ;

       3) entrez l'URL http://localhost:8080/pro/deconnexion ;

       4) affichez à nouveau le formulaire de connexion.

Vous constaterez alors que lors de votre retour le serveur ne vous reconnaît pas : la session a bien été détruite.

************************************************************************************************************************
                                Différence entre forwarding et redirection
************************************************************************************************************************

Avant de continuer, puisque nous y sommes, testons cette histoire de forwarding et de redirection. Modifiez le code
de la servlet comme suit :

       public class Deconnexion extends HttpServlet {

           public static final String VUE = "/connexion";

           public void doGet( HttpServletRequest request, HttpServletResponse response ) throws ServletException, IOException {
               /* Récupération et destruction de la session en cours */
               HttpSession session = request.getSession();
               session.invalidate();

               /* Affichage de la page de connexion */
               this.getServletContext().getRequestDispatcher( VUE ).forward( request, response );
           }
       }

             2) CAS DE FORWARDING  REDIRECTION VER PAGES INTERNES A L'APPLICATION Affichage de la page de connexion
             côté serveur, le client ne sait pas qu'il est redirigé
             l'url ne change pas et meme si on est envoyé à la page jsp connexion, l'url continue d'afficher deconnexion
             http://localhost:8080/session_war_exploded/deconnexion */

             Nous avons ici simplement mis en place un forwarding vers la servlet de connexion : une fois déconnectés,
             vous allez visualiser le formulaire de connexion dans votre navigateur. Oui, mais voyez plutôt ce qu'indique
             la figure suivante !

             http://localhost:8080/session_war_exploded/deconnexion

------------------------------------------------------------------------------------------------------------------------

Vous comprenez ce qu'il s'est passé ? Comme je vous l'ai expliqué dans plusieurs chapitres, le client n'est pas au
courant qu'un forwarding a été réalisé côté serveur. Pour lui, la page jointe est /pro/deconnexion, et c'est bien elle
qui lui a renvoyé une réponse HTTP. Par conséquent, l'URL dans la barre d'adresses de votre navigateur n'a pas changé !
Pourtant, côté serveur, a été effectué un petit enchaînement de forwardings, comme on peut le voir à la figure suivante.

mon servlet de connexion m'envoie au servlet connexion qui lui a son tour m'envoie dans la page connexion.jsp

      1) l'utilisateur accède à la page de déconnexion depuis son navigateur ;

      2) la servlet de déconnexion transfère la requête vers la servlet de connexion via un forwarding ;

      3) la servlet de connexion transfère la requête vers la JSP du formulaire de connexion via un forwarding ;

      4) la JSP renvoie le formulaire à l'utilisateur.

------------------------------------------------------------------------------------------------------------------------

Ce que vous devez comprendre avec ce schéma, c'est que du point de vue du client, pour qui le serveur est comme une
grosse boîte noire, la réponse envoyée par la JSP finale correspond à la requête vers la servlet de déconnexion qu'il
a effectuée. C'est donc pour cette raison que l'utilisateur croit que la réponse est issue de la servlet de déconnexion,
et que son navigateur lui affiche toujours l'URL de la page de déconnexion dans la barre d'adresses : il ne voit pas ce
qui se passe côté serveur, et ne sait pas qu'en réalité sa requête a été baladée de servlet en servlet.

Voyons maintenant ce qui se passerait si nous utilisions une redirection vers la page de connexion à la place du
forwarding dans la servlet de déconnexion (voir la figure suivante).

    1) l'utilisateur accède à la page de déconnexion depuis son navigateur ;

    2) la servlet de déconnexion envoie une demande de redirection au navigateur vers la servlet de connexion,
       via un sendRedirect( "/pro/connexion" ) ;

    3) le navigateur de l'utilisateur exécute alors la redirection et effectue alors une nouvelle requête vers la servlet
       de connexion ;

    4) la servlet de connexion transfère la requête vers la JSP du formulaire de connexion via un forwarding ;

    5) la JSP renvoie le formulaire à l'utilisateur.

Cette fois, vous voyez bien que la réponse envoyée par la JSP finale correspond à la seconde requête effectuée par le
navigateur, à savoir celle vers la servlet de connexion. Ainsi, l'URL affichée dans la barre d'adresses du navigateur
est bien celle de la page de connexion, et l'utilisateur n'est pas dérouté.

Certes, dans le cas de notre page de déconnexion et de notre forwarding, le fait que le client ne soit pas au courant
du cheminement de sa requête au sein du serveur n'a rien de troublant, seule l'URL n'est pas en accord avec l'affichage
final. En effet, si le client appuie sur F5 et actualise la page, cela va appeler à nouveau la servlet de déconnexion,
qui va supprimer sa session si elle existe, puis à nouveau faire un forwarding, puis finir par afficher le formulaire
de connexion à nouveau.

Seulement imaginez maintenant que nous n'avons plus affaire à un système de déconnexion, mais à un système de gestion
de compte en banque, dans lequel la servlet de déconnexion deviendrait une servlet de transfert d'argent, et la servlet
de connexion deviendrait une servlet d'affichage du solde du compte. Si nous gardons ce système de forwarding, après que
le client effectue un transfert d'argent, il est redirigé de manière transparente vers l'affichage du solde de son compte.
Et là, ça devient problématique : si le client ne fait pas attention, et qu'il actualise la page en pensant simplement
actualiser l'affichage de son solde, il va en réalité à nouveau effectuer un transfert d'argent, puisque l'URL de son
navigateur est restée figée sur la première servlet contactée...

Vous comprenez mieux maintenant pourquoi je vous avais conseillé d'utiliser <c:redirect> plutôt que <jsp:forward> dans
le chapitre sur la JSTL Core, et pourquoi dans notre exemple j'ai mis en place une redirection HTTP via sendRedirect()
plutôt qu'un forwarding ? :D

Avant de poursuivre, éditez le code de votre servlet de déconnexion et remettez en place la redirection HTTP vers votre
site préféré, comme je vous l'ai montré avant de faire cet aparté sur le forwarding.

************************************************************************************************************************
                                            Derrière les rideaux
************************************************************************************************************************

***************************************
La théorie : principe de fonctionnement
***************************************

C'est bien joli tout ça, mais nous n'avons toujours pas abordé la question fatidique :

************************************************************************************************************************
                                      Comment fonctionnent les sessions ?
************************************************************************************************************************

Jusqu'à présent, nous ne sommes pas inquiétés de ce qui se passe derrière les rideaux. Et pourtant croyez-moi,
il y a de quoi faire !

La chose la plus importante à retenir, c'est que c'est vous qui contrôlez l'existence d'une session dans votre
application. Un objet HttpSession dédié à un utilisateur sera créé ou récupéré uniquement lorsque la page qu'il
visite implique un appel à <<request.getSession()>>, en d'autres termes uniquement lorsque vous aurez placé un tel appel
dans votre code. En ce qui concerne la gestion de l'objet, c'est le conteneur de servlets qui va s'en charger, en
le créant et le stockant en mémoire. Au passage, le serveur dispose d'un moyen pour identifier chaque session qu'il
crée : il leur attribue un identifiant unique, que nous pouvons d'ailleurs retrouver via la méthode session.getId().

Ensuite, le conteneur va mettre en place un élément particulier dans la réponse HTTP qu'il va renvoyer au client :
un Cookie. Nous reviendrons plus tard sur ce que sont exactement ces cookies, et comment les manipuler. Pour le moment,
voyez simplement un cookie comme un simple marqueur, un petit fichier texte qui :

      * contient des informations envoyées par le serveur ;

      * est stocké par votre navigateur, directement sur votre poste ;

      * a obligatoirement un nom et une valeur.

En l'occurrence, le cookie mis en place lors de la gestion d'une session utilisateur par le serveur se nomme JSESSIONID,
et contient l'identifiant de session unique en tant que valeur.

Pour résumer, le serveur va placer directement chez le client son identifiant de session. Donc, chaque fois qu'il crée
une session pour un nouveau client, le serveur va envoyer son identifiant au navigateur de celui-ci.






--%>


</body>
</html>
