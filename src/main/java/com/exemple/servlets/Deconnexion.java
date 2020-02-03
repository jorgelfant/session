package com.exemple.servlets;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

public class Deconnexion extends HttpServlet {
    public static final String URL_REDIRECTION = "http://www.siteduzero.com";

    public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        /* Récupération et destruction de la session en cours */
        HttpSession session = request.getSession();
        session.invalidate();//la méthode invalidate() sert à détruire une session manuellement

        /* Redirection vers le Site du Zéro !
           la redirection vers la page de connexion via la méthode sendRedirect() de l'objet HttpServletResponse,
           en lieu et place du forwarding que nous utilisions auparavant.                                         */

        response.sendRedirect(URL_REDIRECTION);

        /* Quelle est la différence entre la redirection et le forwarding ?
         *****************************************************************

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

        */

    }
}
