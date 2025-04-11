#!/bin/bash

# Script d'installation pour le tableau de bord des concerts
# Ce script intègre les fichiers ConcertsDashboard.jsx et ConcertsDashboard.css
# dans votre application React existante

echo "Installation du tableau de bord des concerts..."

# Vérifier que les fichiers nécessaires existent
if [ ! -f "ConcertsDashboard.jsx" ] || [ ! -f "ConcertsDashboard.css" ]; then
  echo "❌ Erreur: Les fichiers ConcertsDashboard.jsx et/ou ConcertsDashboard.css sont manquants."
  echo "Assurez-vous que ces fichiers sont présents à la racine du projet."
  exit 1
fi

# Créer le dossier pour les composants de concerts s'il n'existe pas
mkdir -p client/src/components/concerts
echo "✅ Dossier components/concerts créé"

# Copier les fichiers dans le dossier approprié
cp ConcertsDashboard.jsx client/src/components/concerts/
cp ConcertsDashboard.css client/src/components/concerts/
echo "✅ Fichiers copiés dans le dossier components/concerts"

# Créer le fichier index.js pour faciliter l'importation
echo "export { default } from './ConcertsDashboard';" > client/src/components/concerts/index.js
echo "✅ Fichier index.js créé"

# Trouver le fichier principal qui affiche les concerts
CONCERTS_FILE=$(find client/src -type f -name "*.jsx" -o -name "*.js" | xargs grep -l "concerts" | head -n 1)

if [ -z "$CONCERTS_FILE" ]; then
  echo "⚠️ Aucun fichier contenant 'concerts' n'a été trouvé."
  echo "Vous devrez intégrer manuellement le composant ConcertsDashboard dans votre application."
else
  echo "📝 Fichier principal des concerts détecté: $CONCERTS_FILE"
  echo "⚠️ Ce script ne modifiera pas automatiquement ce fichier pour éviter des erreurs."
  echo "Veuillez ajouter manuellement l'importation et l'utilisation du composant:"
  echo ""
  echo "1. Ajoutez cette ligne d'importation au début du fichier:"
  echo "   import ConcertsDashboard from '../components/concerts';"
  echo ""
  echo "2. Utilisez le composant dans votre rendu:"
  echo "   <ConcertsDashboard concerts={vosConerts} onViewConcert={handleViewConcert} onEditConcert={handleEditConcert} />"
fi

# Installer la dépendance react-icons si elle n'est pas déjà installée
if ! grep -q "react-icons" package.json; then
  echo "📦 Installation de la dépendance react-icons..."
  npm install --save react-icons
  echo "✅ react-icons installé"
else
  echo "✅ react-icons est déjà installé"
fi

echo ""
echo "✅ Installation terminée!"
echo ""
echo "Pour finaliser l'intégration:"
echo "1. Importez le composant ConcertsDashboard dans votre fichier principal des concerts"
echo "2. Passez vos données de concerts au composant"
echo "3. Définissez les fonctions de gestion pour les actions 'voir' et 'modifier'"
echo ""
echo "Exemple d'utilisation:"
echo "import ConcertsDashboard from './components/concerts';"
echo ""
echo "// Dans votre composant"
echo "const handleViewConcert = (concert) => {"
echo "  // Naviguer vers la page de détail"
echo "};"
echo ""
echo "const handleEditConcert = (concert) => {"
echo "  // Naviguer vers la page d'édition"
echo "};"
echo ""
echo "// Dans votre rendu"
echo "<ConcertsDashboard"
echo "  concerts={vosConerts}"
echo "  onViewConcert={handleViewConcert}"
echo "  onEditConcert={handleEditConcert}"
echo "/>"
