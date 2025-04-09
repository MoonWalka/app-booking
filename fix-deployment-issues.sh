#!/bin/bash

# Script pour corriger les problèmes de déploiement après l'ajout de la fonctionnalité
# de génération de liens de formulaires

echo "Début de la correction des problèmes de déploiement..."

# Vérification de l'existence du répertoire client
if [ ! -d "./client" ]; then
  echo "Erreur: Le répertoire client n'existe pas. Assurez-vous d'exécuter ce script à la racine du projet."
  exit 1
fi

# Sauvegarde du package.json actuel
echo "Sauvegarde du package.json actuel..."
cp ./client/package.json ./client/package.json.backup
echo "Sauvegarde effectuée: ./client/package.json.backup"

# Modification du package.json pour ajouter "homepage": "."
echo "Modification du package.json pour ajouter \"homepage\": \".\"..."
sed -i 's/"private": true,/"private": true,\n  "homepage": ".",/g' ./client/package.json
echo "package.json modifié avec succès."

# Vérification de la modification
if grep -q '"homepage": "."' ./client/package.json; then
  echo "Vérification réussie: \"homepage\": \".\" a été ajouté au package.json."
else
  echo "Erreur: La modification du package.json a échoué. Tentative alternative..."
  # Tentative alternative avec un fichier temporaire
  cat ./client/package.json | sed '/"private": true,/a\  "homepage": ".",' > ./client/package.json.tmp
  mv ./client/package.json.tmp ./client/package.json
  
  # Nouvelle vérification
  if grep -q '"homepage": "."' ./client/package.json; then
    echo "Vérification réussie après tentative alternative: \"homepage\": \".\" a été ajouté au package.json."
  else
    echo "Erreur: Impossible de modifier automatiquement le package.json. Veuillez l'éditer manuellement."
    echo "Ajoutez \"homepage\": \".\" après la ligne \"private\": true,"
    exit 1
  fi
fi

# Création d'un fichier .env pour configurer le comportement de React Router
echo "Création du fichier .env pour configurer React Router..."
cat > ./client/.env << 'EOL'
# Configuration pour le déploiement sur Render
# Désactive le strict mode pour les URLs
REACT_APP_ROUTER_BASE_URL=.
# Force l'utilisation des chemins relatifs pour les assets
PUBLIC_URL=.
EOL
echo "Fichier .env créé avec succès."

# Création d'un fichier _redirects pour Render
echo "Création du fichier _redirects pour Render..."
mkdir -p ./client/public
cat > ./client/public/_redirects << 'EOL'
/* /index.html 200
EOL
echo "Fichier _redirects créé avec succès."

# Vérification et mise à jour du fichier render.yaml si nécessaire
if [ -f "./render.yaml" ]; then
  echo "Mise à jour du fichier render.yaml..."
  # Sauvegarde du render.yaml actuel
  cp ./render.yaml ./render.yaml.backup
  
  # Vérifier si la règle de redirection existe déjà
  if grep -q "source: /\*" ./render.yaml; then
    echo "La règle de redirection existe déjà dans render.yaml."
  else
    # Ajouter la règle de redirection
    cat > ./render.yaml << 'EOL'
services:
  - type: web
    name: app-booking
    env: static
    buildCommand: cd client && npm install --legacy-peer-deps && npm run build
    staticPublishPath: ./client/build
    routes:
      - type: rewrite
        source: /*
        destination: /index.html
EOL
    echo "Fichier render.yaml mis à jour avec la règle de redirection."
  fi
else
  echo "Création du fichier render.yaml..."
  cat > ./render.yaml << 'EOL'
services:
  - type: web
    name: app-booking
    env: static
    buildCommand: cd client && npm install --legacy-peer-deps && npm run build
    staticPublishPath: ./client/build
    routes:
      - type: rewrite
        source: /*
        destination: /index.html
EOL
  echo "Fichier render.yaml créé avec succès."
fi

# Modification du fichier index.html pour ajouter une balise base
echo "Modification du fichier index.html pour ajouter une balise base..."
if [ -f "./client/public/index.html" ]; then
  # Sauvegarde du index.html actuel
  cp ./client/public/index.html ./client/public/index.html.backup
  
  # Vérifier si la balise base existe déjà
  if grep -q "<base href=\"/\"" ./client/public/index.html; then
    echo "La balise base existe déjà dans index.html."
  else
    # Ajouter la balise base après la balise head
    sed -i 's/<head>/<head>\n    <base href="\/">/' ./client/public/index.html
    echo "Balise base ajoutée à index.html."
  fi
else
  echo "Avertissement: Le fichier index.html n'a pas été trouvé dans ./client/public/"
fi

# Vérification de l'utilisation de BrowserRouter dans App.js
echo "Vérification de l'utilisation de BrowserRouter dans App.js..."
if [ -f "./client/src/App.js" ]; then
  # Sauvegarde du App.js actuel
  cp ./client/src/App.js ./client/src/App.js.backup
  
  # Vérifier si BrowserRouter est utilisé
  if grep -q "BrowserRouter as Router" ./client/src/App.js; then
    echo "BrowserRouter est utilisé dans App.js. Aucune modification nécessaire."
    echo "Note: Si les problèmes persistent, envisagez de remplacer BrowserRouter par HashRouter."
  fi
else
  echo "Avertissement: Le fichier App.js n'a pas été trouvé dans ./client/src/"
fi

echo "Toutes les corrections ont été appliquées avec succès."
echo ""
echo "Pour déployer ces modifications:"
echo "1. Exécutez: npm run build dans le répertoire client"
echo "2. Vérifiez que le build se termine sans erreur"
echo "3. Déployez sur Render en suivant votre processus habituel"
echo ""
echo "Si les problèmes persistent après le déploiement, envisagez de:"
echo "1. Remplacer BrowserRouter par HashRouter dans App.js"
echo "2. Vérifier les logs de build sur Render pour identifier d'éventuelles erreurs"
echo "3. Tester localement avec serve -s build pour simuler un environnement de production"
echo ""
echo "Fin du script de correction."
