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


--%>


</body>
</html>
