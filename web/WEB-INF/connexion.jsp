<%--
  Created by IntelliJ IDEA.
  User: jorge.carrillo
  Date: 1/30/2020
  Time: 10:19 AM
  To change this template use File | Settings | File Templates.
--%>
<%@ page pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8"/>
    <title>Connexion</title>
    <link type="text/css" rel="stylesheet" href="form.css"/>

</head>
<body>
<form method="post" action="connexion">
    <fieldset>
        <legend>Connexion</legend>
        <p>Vous pouvez vous connecter via ce formulaire.</p>

        <label for="email">Adresse email <span class="requis">*</span></label>
        <input type="email" id="email" name="email" value="<c:out value="${requestScope.utilisateur.email}"/>" size="20"
               maxlength="60"/>
        <span class="erreur">${requestScope.form.erreurs['email']}</span>
        <br/>

        <label for="motdepasse">Mot de passe <span class="requis">*</span></label>
        <input type="password" id="motdepasse" name="motdepasse" value="" size="20" maxlength="20"/>
        <span class="erreur">${requestScope.form.erreurs['motdepasse']}</span>
        <br/>

        <input type="submit" value="Connexion" class="sansLabel"/>
        <br/>

        <p class="${empty requestScope.form.erreurs ? 'succes' : 'erreur'}">${requestScope.form.resultat}</p>

        <%-- Ajout de la partie correspondant à la session créée (ou récupérée) dans la servlet et transmise à la JSP --%>

        <%-- Vérification de la présence d'un objet utilisateur en session --%>
        <c:if test="${!empty sessionScope.sessionUtilisateur}"><%--Si aucun objet n'est trouvé (!empty) ce test renvoie false--%>
            <%-- Si l'utilisateur existe en session (s'il est paas null) , alors on affiche son adresse email. --%>
            <p class="succes">Vous êtes connecté(e) avec l'adresse : ${sessionScope.sessionUtilisateur.email}</p>
        </c:if>



    </fieldset>
</form>
</body>
</html>
