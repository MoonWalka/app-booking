#!/bin/bash
set -e

# Ajouter Firebase au package.json
sed -i 's/"axios": "^1.3.4",/"axios": "^1.3.4",\n    "firebase": "^9.17.2",/' client/package.json

# Modifier firebase.js
sed -i '/import { getAnalytics } from "firebase\/analytics";/a import { getFirestore } from "firebase\/firestore";' client/src/firebase.js
sed -i '/const analytics = getAnalytics(app) ;/a const db = getFirestore(app);\n\nexport { db };' client/src/firebase.js

# Créer les dossiers nécessaires
mkdir -p client/src/components/dashboard

# Télécharger les fichiers nécessaires
curl -s -o client/src/components/dashboard/Dashboard.js https://raw.githubusercontent.com/MoonWalka/app-booking-fixes/main/client/src/components/dashboard/Dashboard.js
curl -s -o client/src/components/dashboard/Dashboard.css https://raw.githubusercontent.com/MoonWalka/app-booking-fixes/main/client/src/components/dashboard/Dashboard.css
curl -s -o client/src/components/common/Layout.css https://raw.githubusercontent.com/MoonWalka/app-booking-fixes/main/client/src/components/common/Layout.css

# Mettre à jour le Layout.js
curl -s -o client/src/components/common/Layout.js https://raw.githubusercontent.com/MoonWalka/app-booking-fixes/main/client/src/components/common/Layout.js

# Mettre à jour App.js
sed -i '/import NotFound from/a import Dashboard from '\''./components/dashboard/Dashboard'\'';' client/src/App.js
sed -i 's/<Route index element={<div>Dashboard<\/div>} \/>/<Route index element={<Dashboard \/>} \/>/' client/src/App.js

# Mettre à jour index.html pour Font Awesome
sed -i '/<link rel="manifest" href="%PUBLIC_URL%\/manifest.json" \/>/a \    <!-- Ajout de Font Awesome pour les icônes -->\n    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" integrity="sha512-9usAa10IRO0HhonpyAIVpjrylPvoDwiPUiKdWk5t3PyolY1cOd4DSE0Ga+ri4AuTroPR5aQvXU9xC6qOPnzFeg==" crossorigin="anonymous" referrerpolicy="no-referrer" />' client/public/index.html

# Corriger AuthContext.js si nécessaire
if grep -q "cat >" client/src/context/AuthContext.js; then
  curl -s -o client/src/context/AuthContext.js https://raw.githubusercontent.com/MoonWalka/app-booking-fixes/main/client/src/context/AuthContext.js
fi

# Installer les dépendances
cd client && npm install

echo "Toutes les modifications ont été appliquées avec succès!"
