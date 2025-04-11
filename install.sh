#!/bin/bash

# Script d'installation pour les améliorations visuelles de l'onglet "Concerts"
# Ce script copie les fichiers nécessaires et met à jour les imports dans l'application existante

echo "Installation des améliorations visuelles de l'onglet Concerts..."

# Créer les répertoires nécessaires s'ils n'existent pas
mkdir -p client/src/components/concerts

# Copier les fichiers du tableau de bord
echo "Copie des fichiers du tableau de bord..."
cp ConcertsDashboard.jsx client/src/components/concerts/
cp ConcertsDashboard.css client/src/components/concerts/

# Créer un fichier d'index pour faciliter l'import
echo "Création du fichier d'index..."
cat > client/src/components/concerts/index.js << 'EOL'
export { default as ConcertsDashboard } from './ConcertsDashboard';
EOL

# Mettre à jour le fichier de route principal pour utiliser le nouveau composant
echo "Mise à jour du fichier de route principal..."
cat > client/src/routes/ConcertsPage.jsx << 'EOL'
import React from 'react';
import { ConcertsDashboard } from '../components/concerts';

const ConcertsPage = () => {
  return <ConcertsDashboard />;
};

export default ConcertsPage;
EOL

# Installer les dépendances nécessaires
echo "Installation des dépendances..."
npm install --save react-icons

echo "✅ Installation terminée avec succès!"
echo ""
echo "Pour visualiser les changements, démarrez l'application avec:"
echo "npm start"
echo ""
echo "Note: Ce script suppose que vous êtes à la racine du projet et que la structure de dossiers est standard."
echo "Si votre structure est différente, vous devrez ajuster les chemins manuellement."
