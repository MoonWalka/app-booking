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
