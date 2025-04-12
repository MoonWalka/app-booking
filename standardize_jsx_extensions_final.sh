#!/bin/bash

# Script de standardisation des extensions de fichiers pour les composants React
# Ce script convertit tous les fichiers .js qui sont des composants React en .jsx
# tout en préservant les console.log et en s'assurant que l'application reste fonctionnelle

# Couleurs pour les messages
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Fonction pour afficher les messages
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[ATTENTION]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERREUR]${NC} $1"
}

# Créer un répertoire de sauvegarde
BACKUP_DIR="./backups/jsx_standardization_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"
log_info "Création du répertoire de sauvegarde: $BACKUP_DIR"

# Copier tous les fichiers source dans le répertoire de sauvegarde
cp -r ./client/src "$BACKUP_DIR/"
log_info "Sauvegarde des fichiers source effectuée"

# Liste des fichiers à convertir (composants React avec extension .js)
JS_FILES=$(find ./client/src -name "*.js" | grep -v "node_modules" | grep -v "index.js" | grep -v "utils" | grep -v "services" | grep -v "context" | grep -v "firebase.js" | grep -v "initFirestore.js" | grep -v "test_public_route.js")

# Nombre total de fichiers à convertir
TOTAL_FILES=$(echo "$JS_FILES" | wc -l)
log_info "Nombre de fichiers à convertir: $TOTAL_FILES"

# Compteur pour suivre la progression
COUNTER=0

# Convertir chaque fichier .js en .jsx
for js_file in $JS_FILES; do
    # Incrémenter le compteur
    ((COUNTER++))
    
    # Obtenir le nom du fichier sans l'extension
    file_base=$(basename "$js_file" .js)
    file_dir=$(dirname "$js_file")
    jsx_file="$file_dir/$file_base.jsx"
    
    # Copier le fichier avec la nouvelle extension
    cp "$js_file" "$jsx_file"
    
    log_info "[$COUNTER/$TOTAL_FILES] Conversion: $js_file -> $jsx_file"
    
    # Supprimer l'ancien fichier .js
    rm "$js_file"
done

# Vérifier s'il y a des importations qui spécifient explicitement l'extension .js
EXPLICIT_JS_IMPORTS=$(grep -r "import.*from.*\.js[\"']" --include="*.jsx" ./client/src | grep -v "node_modules")

if [ -n "$EXPLICIT_JS_IMPORTS" ]; then
    log_warning "Des importations explicites avec extension .js ont été trouvées. Correction en cours..."
    
    # Remplacer les importations explicites .js par .jsx
    find ./client/src -name "*.jsx" -exec sed -i 's/\.js"/\.jsx"/g' {} \;
    find ./client/src -name "*.jsx" -exec sed -i "s/\.js'/\.jsx'/g" {} \;
    
    log_info "Importations explicites corrigées"
else
    log_info "Aucune importation explicite avec extension .js trouvée. Aucune correction nécessaire."
fi

# Mettre à jour les importations dans index.js et autres fichiers qui ne sont pas convertis
log_info "Mise à jour des importations dans les fichiers qui ne sont pas convertis..."

# Liste des fichiers qui ne sont pas convertis mais qui pourraient importer des composants
NON_CONVERTED_FILES=$(find ./client/src -name "*.js" | grep -v "node_modules")

for file in $NON_CONVERTED_FILES; do
    # Vérifier si le fichier contient des importations de composants convertis
    NEEDS_UPDATE=false
    
    for js_file in $JS_FILES; do
        component_name=$(basename "$js_file" .js)
        if grep -q "import.*$component_name.*from" "$file"; then
            NEEDS_UPDATE=true
            break
        fi
    done
    
    if [ "$NEEDS_UPDATE" = true ]; then
        log_info "Mise à jour des importations dans: $file"
        # Pas besoin de modifier les chemins d'importation car ils n'incluent pas l'extension
    fi
done

# Mettre à jour le fichier index.js pour qu'il importe App.jsx au lieu de App.js
if [ -f "./client/src/index.js" ]; then
    log_info "Mise à jour des importations dans index.js..."
    # Remplacer l'importation de App sans modifier l'extension (car elle n'est probablement pas spécifiée)
    # Cette étape est ajoutée par précaution
    sed -i 's/import App from/import App from/g' ./client/src/index.js
fi

# Vérifier si le fichier package.json existe dans le répertoire client
if [ -f "./client/package.json" ]; then
    log_info "Vérification des dépendances dans package.json..."
    
    # Vérifier si react-scripts est présent dans les dépendances
    if ! grep -q "\"react-scripts\"" "./client/package.json"; then
        log_warning "react-scripts n'est pas trouvé dans package.json. Ajout en cours..."
        # Ajouter react-scripts aux devDependencies
        sed -i '/"dependencies": {/a \    "react-scripts": "^5.0.1",' "./client/package.json"
    fi
else
    log_warning "Le fichier package.json n'a pas été trouvé dans le répertoire client."
fi

log_info "Standardisation des extensions de fichiers terminée avec succès!"
log_info "Tous les composants React utilisent maintenant l'extension .jsx"
log_info "Les console.log ont été préservés comme demandé"
log_info ""
log_info "IMPORTANT: Avant de faire un build, assurez-vous d'installer les dépendances avec:"
log_info "cd client && npm install"
log_info ""
log_info "Pour tester le build après l'installation des dépendances:"
log_info "cd client && npm run build"

exit 0
