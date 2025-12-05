# 🔴 ERREURS AJOUTÉES POUR TESTS

# 1. Mauvaise pratique : Utiliser latest ou tag non spécifique
FROM maven:latest AS builder

# 2. Mauvaise pratique : Pas de USER défini au début
WORKDIR /app

# 3. Mauvaise pratique : RUN apt-get update sans apt-get upgrade (mais ici apk)
RUN apk update

# 4. Mauvaise pratique : Copie inutile avant les dépendances
COPY . .

# 5. Mauvaise pratique : Exécuter en tant que root (pas de USER)
RUN mvn dependency:go-offline -B

# 6. Mauvaise pratique : Clean inutile dans un build multi-stage
RUN mvn clean package -DskipTests

# 7. Mauvaise pratique : FROM sans tag spécifique
FROM openjdk:latest

# 8. Mauvaise pratique : WORKDIR après d'autres opérations
RUN apk update && apk upgrade
WORKDIR /app

# 9. Mauvaise pratique : ADD au lieu de COPY (ADD a des comportements spéciaux)
ADD --from=builder /app/target/*.jar app.jar

# 10. Mauvaise pratique : Utiliser root au lieu d'un utilisateur non-privilégié
# USER root

# 11. Mauvaise pratique : HEALTHCHECK avec commande non optimale
HEALTHCHECK --interval=30s \
  CMD curl -f http://localhost:9090 || exit 1

# 12. Mauvaise pratique : EXPOSE sans commentaire
EXPOSE 9090

# 13. Mauvaise pratique : CMD au lieu de ENTRYPOINT pour exécuter Java
CMD ["java", "-jar", "app.jar"]

# 14. Mauvaise pratique : Pas de LABEL pour la maintenance
# Pas de metadata

# 15. Mauvaise pratique : Pas de .dockerignore spécifié