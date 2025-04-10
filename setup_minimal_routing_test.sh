#!/bin/bash
# Ce script sauvegarde l'actuel client/src/App.js et le remplace par une version minimale
# pour tester le routage public (/form/:concertId) dans notre application React.
# Placez ce fichier à la racine du projet.

TARGET="client/src/App.js"
BACKUP_DIR="./backups/$(date +"%Y%m%d_%H%M%S")_minimal_routing_test"
mkdir -p "$BACKUP_DIR"

echo "[INFO] Sauvegarde de $TARGET dans $BACKUP_DIR"
cp "$TARGET" "$BACKUP_DIR/App.js.bak"

echo "[INFO] Remplacement de $TARGET par une version minimaliste pour tester le routage public..."

cat << 'EOF' > "$TARGET"
import React from 'react';
import { Routes, Route, HashRouter } from 'react-router-dom';

// Composant minimal pour la page publique du formulaire
function PublicFormPage() {
  console.log("PublicFormPage loaded, current hash:", window.location.hash);
  return (
    <div style={{ padding: "20px", textAlign: "center" }}>
      <h2>Public Form Page Loaded</h2>
      <p>URL: {window.location.hash}</p>
    </div>
  );
}

// Composant minimal pour le Dashboard (routes protégées)
function Dashboard() {
  return (
    <div style={{ padding: "20px", textAlign: "center" }}>
      <h2>Dashboard - Protected Area</h2>
    </div>
  );
}

function App() {
  return (
    <Routes>
      {/* Route publique pour le formulaire */}
      <Route path="/form/:concertId" element={<PublicFormPage />} />
      
      {/* Route protégée minimale (pour tester la différence) */}
      <Route path="/" element={<Dashboard />} />
    </Routes>
  );
}

// On exporte une application racine utilisant HashRouter
export default function RootApp() {
  return (
    <HashRouter>
      <App />
    </HashRouter>
  );
}
EOF

echo "[SUCCESS] Version minimale de App.js créée."
echo "[INFO] Pour tester, lancez l'app et accédez à une URL du type:"
echo "      https://[your-app-domain]/#/form/123"
echo ""
echo "Pour rendre ce script exécutable et l'exécuter, copiez-collez la commande suivante :"
echo "chmod +x setup_minimal_routing_test.sh && ./setup_minimal_routing_test.sh"
EOF