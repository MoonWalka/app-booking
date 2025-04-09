#!/bin/bash

# Script pour corriger l'erreur d'importation de generateFormLink
# Créé le $(date +"%d/%m/%Y")

# Définition des couleurs pour les messages
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Fonction pour afficher les messages
print_message() {
  echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
  echo -e "${YELLOW}[ATTENTION]${NC} $1"
}

print_error() {
  echo -e "${RED}[ERREUR]${NC} $1"
}

# Vérification de l'existence du répertoire du projet
if [ ! -d "./client" ]; then
  print_error "Ce script doit être exécuté depuis la racine du projet app-booking."
  exit 1
fi

print_message "Début de la correction de l'erreur d'importation de generateFormLink..."

# Création du répertoire de sauvegarde
BACKUP_DIR="./backups/$(date +"%Y%m%d_%H%M%S")_import_fix"
mkdir -p "$BACKUP_DIR"
print_message "Répertoire de sauvegarde créé: $BACKUP_DIR"

# Vérification et mise à jour du fichier formLinkService.js
FORM_LINK_SERVICE="./client/src/services/formLinkService.js"
if [ -f "$FORM_LINK_SERVICE" ]; then
  # Sauvegarde du fichier original
  cp "$FORM_LINK_SERVICE" "$BACKUP_DIR/formLinkService.js.bak"
  print_message "Sauvegarde de $FORM_LINK_SERVICE effectuée."
  
  # Vérification si l'alias existe déjà
  if grep -q "export { createFormLink as generateFormLink }" "$FORM_LINK_SERVICE"; then
    print_warning "L'alias generateFormLink existe déjà dans $FORM_LINK_SERVICE."
  else
    # Ajout de l'alias à la fin du fichier
    echo -e "\n// Alias pour maintenir la compatibilité avec les imports existants\nexport { createFormLink as generateFormLink };" >> "$FORM_LINK_SERVICE"
    print_message "Alias generateFormLink ajouté à $FORM_LINK_SERVICE."
  fi
else
  print_error "Le fichier $FORM_LINK_SERVICE n'existe pas."
  exit 1
fi

# Recherche de tous les fichiers qui pourraient utiliser generateFormLink
print_message "Recherche des fichiers qui importent generateFormLink..."
FILES_WITH_IMPORT=$(find ./client/src -type f -name "*.js*" -exec grep -l "import.*generateFormLink" {} \; 2>/dev/null)

if [ -z "$FILES_WITH_IMPORT" ]; then
  print_warning "Aucun fichier avec import de generateFormLink trouvé dans le code source."
  print_message "L'erreur pourrait provenir d'un fichier créé récemment qui n'est pas encore dans le dépôt."
else
  print_message "Fichiers trouvés avec import de generateFormLink:"
  for FILE in $FILES_WITH_IMPORT; do
    echo "  - $FILE"
    # Sauvegarde du fichier original
    cp "$FILE" "$BACKUP_DIR/$(basename "$FILE").bak"
    print_message "Sauvegarde de $FILE effectuée."
  done
fi

# Vérification spécifique des fichiers qui pourraient utiliser generateFormLink
CONCERT_DETAIL="./client/src/components/concerts/ConcertDetail.js"
if [ -f "$CONCERT_DETAIL" ]; then
  # Sauvegarde du fichier original
  cp "$CONCERT_DETAIL" "$BACKUP_DIR/ConcertDetail.js.bak"
  print_message "Sauvegarde de $CONCERT_DETAIL effectuée."
  
  # Vérification et correction de l'import
  if grep -q "import.*generateFormLink" "$CONCERT_DETAIL"; then
    sed -i 's/import.*generateFormLink.*/import { createFormLink } from "..\/..\/services\/formLinkService";/' "$CONCERT_DETAIL"
    sed -i 's/generateFormLink(/createFormLink(/g' "$CONCERT_DETAIL"
    print_message "Import et utilisation corrigés dans $CONCERT_DETAIL."
  fi
fi

# Vérification des composants publics
PUBLIC_FORM_PAGE="./client/src/components/public/PublicFormPage.jsx"
if [ -f "$PUBLIC_FORM_PAGE" ]; then
  # Sauvegarde du fichier original
  cp "$PUBLIC_FORM_PAGE" "$BACKUP_DIR/PublicFormPage.jsx.bak"
  print_message "Sauvegarde de $PUBLIC_FORM_PAGE effectuée."
  
  # Vérification et correction de l'import
  if grep -q "import.*generateFormLink" "$PUBLIC_FORM_PAGE"; then
    sed -i 's/import.*generateFormLink.*/import { createFormLink } from "..\/..\/services\/formLinkService";/' "$PUBLIC_FORM_PAGE"
    sed -i 's/generateFormLink(/createFormLink(/g' "$PUBLIC_FORM_PAGE"
    print_message "Import et utilisation corrigés dans $PUBLIC_FORM_PAGE."
  fi
fi

print_message "Correction terminée avec succès."
print_message "Pour appliquer ces modifications, exécutez les commandes suivantes:"
echo -e "${GREEN}git add .${NC}"
echo -e "${GREEN}git commit -m \"Correction de l'erreur d'importation de generateFormLink\"${NC}"
echo -e "${GREEN}git push origin main${NC}"

print_message "Si vous rencontrez toujours des erreurs après le déploiement, vérifiez les logs de build pour identifier les fichiers problématiques."
