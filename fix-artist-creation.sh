#!/bin/bash

# Script pour corriger le problème d'ajout d'artistes dans l'application App Booking
# Créé le $(date +"%d/%m/%Y")

# Couleurs pour les messages
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Script de correction pour l'ajout d'artistes dans App Booking ===${NC}"
echo "Ce script va appliquer des correctifs pour résoudre le problème d'ajout d'artistes."
echo "Les fichiers originaux seront sauvegardés avec l'extension .bak"

# Vérifier si nous sommes dans le répertoire racine du projet
if [ ! -d "./client" ]; then
  echo -e "${RED}Erreur: Ce script doit être exécuté depuis le répertoire racine du projet.${NC}"
  echo "Veuillez vous placer dans le répertoire racine du projet et réessayer."
  exit 1
fi

# Créer le répertoire de sauvegarde s'il n'existe pas
BACKUP_DIR="./backups/$(date +"%Y%m%d_%H%M%S")"
mkdir -p "$BACKUP_DIR"
echo -e "${GREEN}Répertoire de sauvegarde créé: $BACKUP_DIR${NC}"

# Fonction pour sauvegarder et remplacer un fichier
replace_file() {
  local SOURCE_FILE=$1
  local TARGET_FILE=$2
  
  # Vérifier si le fichier source existe
  if [ ! -f "$SOURCE_FILE" ]; then
    echo -e "${RED}Erreur: Le fichier source $SOURCE_FILE n'existe pas.${NC}"
    return 1
  fi
  
  # Vérifier si le fichier cible existe
  if [ ! -f "$TARGET_FILE" ]; then
    echo -e "${YELLOW}Attention: Le fichier cible $TARGET_FILE n'existe pas. Création du fichier...${NC}"
    # Créer les répertoires parents si nécessaires
    mkdir -p "$(dirname "$TARGET_FILE")"
  else
    # Sauvegarder le fichier original
    cp "$TARGET_FILE" "$BACKUP_DIR/$(basename "$TARGET_FILE").bak"
    echo -e "${GREEN}Fichier original sauvegardé: $BACKUP_DIR/$(basename "$TARGET_FILE").bak${NC}"
  fi
  
  # Remplacer le fichier
  cp "$SOURCE_FILE" "$TARGET_FILE"
  echo -e "${GREEN}Fichier remplacé: $TARGET_FILE${NC}"
  
  return 0
}

# Appliquer les correctifs
echo -e "\n${GREEN}=== Application des correctifs ===${NC}"

# 1. Corriger firebase.js
echo -e "\n${YELLOW}1. Correction de firebase.js${NC}"
replace_file "./client/src/firebase.js.fix" "./client/src/firebase.js"

# 2. Corriger artistsService.js
echo -e "\n${YELLOW}2. Correction de artistsService.js${NC}"
replace_file "./client/src/services/artistsService.js.fix" "./client/src/services/artistsService.js"

# 3. Créer les règles Firestore
echo -e "\n${YELLOW}3. Création des règles Firestore${NC}"
cat > ./firestore.rules << 'EOL'
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Permettre l'accès en lecture à tous les utilisateurs
    match /{document=**} {
      allow read: if true;
    }
    
    // Permettre l'accès en écriture aux utilisateurs authentifiés (même anonymement)
    match /artists/{artistId} {
      allow write: if request.auth != null;
    }
    
    match /concerts/{concertId} {
      allow write: if request.auth != null;
    }
    
    match /programmers/{programmerId} {
      allow write: if request.auth != null;
    }
  }
}
EOL
echo -e "${GREEN}Fichier de règles Firestore créé: ./firestore.rules${NC}"

echo -e "\n${GREEN}=== Correctifs appliqués avec succès ===${NC}"
echo -e "Les fichiers originaux ont été sauvegardés dans: ${YELLOW}$BACKUP_DIR${NC}"

echo -e "\n${GREEN}=== Instructions pour déployer les règles Firestore ===${NC}"
echo -e "Pour déployer les règles Firestore, exécutez la commande suivante:"
echo -e "${YELLOW}firebase deploy --only firestore:rules${NC}"

echo -e "\n${GREEN}=== Instructions pour tester les correctifs ===${NC}"
echo -e "1. Redémarrez l'application avec: ${YELLOW}npm start${NC}"
echo -e "2. Testez l'ajout d'un nouvel artiste"
echo -e "3. Vérifiez que l'artiste apparaît dans la liste"
echo -e "4. Si l'artiste n'apparaît pas immédiatement, rafraîchissez la page"

echo -e "\n${GREEN}=== Terminé ===${NC}"
