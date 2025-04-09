#!/bin/bash

# Script pour corriger l'erreur d'importation de submitFormData
# en remplaçant par createFormSubmission

echo "Début de la correction de l'erreur d'importation de submitFormData..."

# Vérification de l'existence du répertoire client
if [ ! -d "./client" ]; then
  echo "Erreur: Le répertoire client n'existe pas. Assurez-vous d'exécuter ce script à la racine du projet."
  exit 1
fi

# Sauvegarde des fichiers qui seront potentiellement modifiés
echo "Création d'un répertoire de sauvegarde..."
BACKUP_DIR="./backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Recherche de tous les fichiers contenant submitFormData
echo "Recherche des fichiers contenant submitFormData..."
FILES_TO_CHECK=$(find ./client/src -type f -name "*.js*" -o -name "*.ts*" 2>/dev/null)

# Compteur pour suivre les modifications
MODIFIED_FILES=0

# Parcourir tous les fichiers et effectuer les remplacements si nécessaire
for FILE in $FILES_TO_CHECK; do
  # Vérifier si le fichier contient submitFormData
  if grep -q "submitFormData" "$FILE"; then
    echo "Fichier trouvé contenant submitFormData: $FILE"
    
    # Créer une sauvegarde du fichier
    cp "$FILE" "$BACKUP_DIR/$(basename "$FILE")"
    
    # Remplacer les imports
    sed -i 's/import[[:space:]]*{[[:space:]]*\([^}]*\)submitFormData[[:space:]]*\([^}]*\)}[[:space:]]*from[[:space:]]*'\''\.\.\/\.\.\/services\/formSubmissionsService'\''/import { \1createFormSubmission\2} from '\''..\/..\/services\/formSubmissionsService'\''/g' "$FILE"
    sed -i 's/import[[:space:]]*{[[:space:]]*\([^}]*\),[[:space:]]*submitFormData[[:space:]]*\([^}]*\)}[[:space:]]*from[[:space:]]*'\''\.\.\/\.\.\/services\/formSubmissionsService'\''/import { \1, createFormSubmission\2} from '\''..\/..\/services\/formSubmissionsService'\''/g' "$FILE"
    
    # Remplacer les appels de fonction
    sed -i 's/submitFormData(/createFormSubmission(/g' "$FILE"
    
    # Remplacer les références à la fonction
    sed -i 's/submitFormData/createFormSubmission/g' "$FILE"
    
    echo "Remplacements effectués dans: $FILE"
    MODIFIED_FILES=$((MODIFIED_FILES + 1))
  fi
done

# Vérifier spécifiquement le composant PublicFormPage.jsx qui est mentionné dans l'erreur
PUBLIC_FORM_PAGE="./client/src/components/public/PublicFormPage.jsx"
if [ -f "$PUBLIC_FORM_PAGE" ]; then
  echo "Vérification spécifique de $PUBLIC_FORM_PAGE..."
  
  # Créer une sauvegarde si elle n'existe pas déjà
  if [ ! -f "$BACKUP_DIR/$(basename "$PUBLIC_FORM_PAGE")" ]; then
    cp "$PUBLIC_FORM_PAGE" "$BACKUP_DIR/$(basename "$PUBLIC_FORM_PAGE")"
  fi
  
  # Vérifier et corriger les imports
  if grep -q "submitFormData" "$PUBLIC_FORM_PAGE"; then
    echo "Correction des imports dans $PUBLIC_FORM_PAGE..."
    sed -i 's/import[[:space:]]*{[[:space:]]*getFormLinkByToken,[[:space:]]*submitFormData[[:space:]]*}[[:space:]]*from/import { getFormLinkByToken, createFormSubmission } from/g' "$PUBLIC_FORM_PAGE"
    sed -i 's/import[[:space:]]*{[[:space:]]*submitFormData[[:space:]]*}[[:space:]]*from/import { createFormSubmission } from/g' "$PUBLIC_FORM_PAGE"
    sed -i 's/submitFormData(/createFormSubmission(/g' "$PUBLIC_FORM_PAGE"
    MODIFIED_FILES=$((MODIFIED_FILES + 1))
    echo "Remplacements effectués dans: $PUBLIC_FORM_PAGE"
  else
    echo "Aucune occurrence de submitFormData trouvée dans $PUBLIC_FORM_PAGE"
  fi
fi

# Vérifier si le service formSubmissionsService.js exporte bien createFormSubmission
FORM_SUBMISSIONS_SERVICE="./client/src/services/formSubmissionsService.js"
if [ -f "$FORM_SUBMISSIONS_SERVICE" ]; then
  echo "Vérification de l'export de createFormSubmission dans $FORM_SUBMISSIONS_SERVICE..."
  
  # Créer une sauvegarde
  cp "$FORM_SUBMISSIONS_SERVICE" "$BACKUP_DIR/$(basename "$FORM_SUBMISSIONS_SERVICE")"
  
  # Vérifier si createFormSubmission est exportée
  if ! grep -q "export.*createFormSubmission" "$FORM_SUBMISSIONS_SERVICE"; then
    echo "Ajout de l'export pour createFormSubmission dans $FORM_SUBMISSIONS_SERVICE..."
    
    # Chercher la fonction createFormSubmission
    if grep -q "const createFormSubmission" "$FORM_SUBMISSIONS_SERVICE"; then
      # Remplacer la déclaration pour exporter la fonction
      sed -i 's/const createFormSubmission/export const createFormSubmission/g' "$FORM_SUBMISSIONS_SERVICE"
      MODIFIED_FILES=$((MODIFIED_FILES + 1))
      echo "Export ajouté pour createFormSubmission dans $FORM_SUBMISSIONS_SERVICE"
    else
      echo "Avertissement: La fonction createFormSubmission n'a pas été trouvée dans $FORM_SUBMISSIONS_SERVICE"
    fi
  else
    echo "La fonction createFormSubmission est déjà exportée dans $FORM_SUBMISSIONS_SERVICE"
  fi
fi

# Recherche manuelle dans les fichiers de composants publics
echo "Recherche manuelle dans les fichiers de composants publics..."
PUBLIC_COMPONENTS_DIR="./client/src/components/public"
if [ -d "$PUBLIC_COMPONENTS_DIR" ]; then
  PUBLIC_FILES=$(find "$PUBLIC_COMPONENTS_DIR" -type f -name "*.js*" -o -name "*.ts*" 2>/dev/null)
  
  for FILE in $PUBLIC_FILES; do
    # Vérifier si le fichier contient submitFormData
    if grep -q "submitFormData" "$FILE"; then
      echo "Fichier trouvé contenant submitFormData: $FILE"
      
      # Créer une sauvegarde du fichier
      cp "$FILE" "$BACKUP_DIR/$(basename "$FILE")"
      
      # Remplacer les imports
      sed -i 's/import[[:space:]]*{[[:space:]]*\([^}]*\)submitFormData[[:space:]]*\([^}]*\)}[[:space:]]*from[[:space:]]*'\''\.\.\/\.\.\/services\/formSubmissionsService'\''/import { \1createFormSubmission\2} from '\''..\/..\/services\/formSubmissionsService'\''/g' "$FILE"
      sed -i 's/import[[:space:]]*{[[:space:]]*\([^}]*\),[[:space:]]*submitFormData[[:space:]]*\([^}]*\)}[[:space:]]*from[[:space:]]*'\''\.\.\/\.\.\/services\/formSubmissionsService'\''/import { \1, createFormSubmission\2} from '\''..\/..\/services\/formSubmissionsService'\''/g' "$FILE"
      
      # Remplacer les appels de fonction
      sed -i 's/submitFormData(/createFormSubmission(/g' "$FILE"
      
      # Remplacer les références à la fonction
      sed -i 's/submitFormData/createFormSubmission/g' "$FILE"
      
      echo "Remplacements effectués dans: $FILE"
      MODIFIED_FILES=$((MODIFIED_FILES + 1))
    fi
  done
else
  echo "Le répertoire des composants publics n'existe pas: $PUBLIC_COMPONENTS_DIR"
fi

# Résumé des modifications
if [ $MODIFIED_FILES -eq 0 ]; then
  echo "Aucun fichier n'a été modifié. Il est possible que les corrections aient déjà été appliquées."
  echo "Vérifiez manuellement les fichiers suivants pour vous assurer que createFormSubmission est utilisé correctement:"
  echo "- ./client/src/components/public/PublicFormPage.jsx"
  echo "- ./client/src/services/formSubmissionsService.js"
else
  echo "$MODIFIED_FILES fichier(s) ont été modifiés."
  echo "Les fichiers originaux ont été sauvegardés dans le répertoire: $BACKUP_DIR"
fi

echo ""
echo "Pour vérifier que les corrections ont résolu le problème:"
echo "1. Exécutez: cd client && npm run build"
echo "2. Vérifiez que le build se termine sans erreur"
echo "3. Testez le formulaire public en accédant à /form/:token"
echo ""
echo "Fin du script de correction."
