#!/bin/bash

# Script pour restaurer l'application App Booking à une version fonctionnelle
# Ce script revient à la version où l'authentification était désactivée et où
# toutes les fonctionnalités (artistes, concerts, programmateurs) fonctionnaient correctement

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Fonction pour afficher les messages
print_message() {
  echo -e "${BLUE}$1${NC}"
}

print_success() {
  echo -e "${GREEN}$1${NC}"
}

print_error() {
  echo -e "${RED}$1${NC}"
}

print_warning() {
  echo -e "${YELLOW}$1${NC}"
}

# Vérifier si nous sommes dans un dépôt Git
if [ ! -d ".git" ]; then
  print_error "Erreur: Ce script doit être exécuté depuis la racine du dépôt Git app-booking"
  exit 1
fi

# Vérifier s'il y a des modifications non commitées
if [ -n "$(git status --porcelain)" ]; then
  print_warning "⚠️ Attention: Vous avez des modifications non commitées qui seront perdues."
  read -p "Voulez-vous continuer? (o/n) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Oo]$ ]]; then
    print_message "Opération annulée. Veuillez commiter ou stasher vos modifications avant de continuer."
    exit 0
  fi
fi

print_message "🔄 Restauration de l'application à la version fonctionnelle précédente..."

# Créer une nouvelle branche pour la restauration
BRANCH_NAME="restore-working-version-$(date +%Y%m%d%H%M%S)"
git checkout -b $BRANCH_NAME 6fec9b41a

if [ $? -ne 0 ]; then
  print_error "❌ Erreur lors de la création de la branche de restauration."
  exit 1
fi

print_success "✅ Branche de restauration créée: $BRANCH_NAME"

# Vérifier que le fichier AuthContext.js a bien BYPASS_AUTH = true
AUTH_CONTEXT_FILE="client/src/context/AuthContext.js"
if grep -q "BYPASS_AUTH = true" "$AUTH_CONTEXT_FILE"; then
  print_success "✅ Mode bypass d'authentification correctement configuré (BYPASS_AUTH = true)"
else
  print_error "❌ Le mode bypass d'authentification n'est pas correctement configuré."
  print_message "🔄 Correction du fichier AuthContext.js..."
  
  # Remplacer BYPASS_AUTH = false par BYPASS_AUTH = true si nécessaire
  sed -i 's/BYPASS_AUTH = false/BYPASS_AUTH = true/g' "$AUTH_CONTEXT_FILE"
  
  if grep -q "BYPASS_AUTH = true" "$AUTH_CONTEXT_FILE"; then
    print_success "✅ Mode bypass d'authentification corrigé (BYPASS_AUTH = true)"
  else
    print_error "❌ Impossible de corriger le mode bypass d'authentification."
    exit 1
  fi
fi

# Vérifier si des règles Firestore ont été ajoutées et les supprimer si nécessaire
if [ -f "firestore.rules" ]; then
  print_message "🔄 Suppression des règles Firestore restrictives..."
  rm firestore.rules
  print_success "✅ Règles Firestore supprimées"
fi

# Commiter les changements
git add .
git commit -m "Restauration à la version fonctionnelle avec authentification désactivée"

print_success "✅ Restauration terminée avec succès!"
print_message "📋 Résumé des actions effectuées:"
echo "  - Création d'une nouvelle branche: $BRANCH_NAME"
echo "  - Restauration au commit 'artiste features' (6fec9b41a)"
echo "  - Vérification/correction du mode bypass d'authentification"
echo "  - Suppression des règles Firestore restrictives (si présentes)"
echo "  - Commit des changements"

print_message "📌 Prochaines étapes:"
echo "  1. Vérifiez que l'application fonctionne correctement en local"
echo "  2. Poussez la branche vers GitHub avec: git push origin $BRANCH_NAME"
echo "  3. Si tout fonctionne, fusionnez cette branche avec main:"
echo "     git checkout main"
echo "     git merge $BRANCH_NAME"
echo "     git push origin main"

print_warning "⚠️ Important: Cette restauration désactive l'authentification Firebase."
echo "   Lorsque vous serez prêt à réactiver l'authentification, utilisez une approche"
echo "   plus progressive qui maintient la fonctionnalité de l'application."

exit 0
