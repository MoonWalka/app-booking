import React from 'react';
import ReactDOM from 'react-dom/client';

import App from './App';
import { HashRouter } from 'react-router-dom';
import { AuthProvider } from './context/AuthContext';
import PublicFormPage from './components/public/PublicFormPage';
import FormSubmittedPage from './components/public/FormSubmittedPage';

// Fonction pour vérifier si l'URL actuelle est une route publique
const isPublicRoute = () => {
  // Obtenir le hash de l'URL (pour HashRouter)
  const hash = window.location.hash || '';
  // Nettoyer le hash pour obtenir le chemin réel (enlever le # au début)
  const cleanPath = hash.replace(/^#/, '');
  
  console.log('index.js - Hash brut:', hash);
  console.log('index.js - Chemin nettoyé:', cleanPath);
  
  // Vérifier si le chemin correspond à une route publique
  const isPublic = cleanPath.startsWith('/form/') || cleanPath === '/form-submitted';
  console.log('index.js - Est une route publique:', isPublic);
  
  return isPublic;
};

// Extraire l'ID du concert de l'URL si c'est une route de formulaire
const extractConcertId = () => {
  const hash = window.location.hash || '';
  const match = hash.match(/^#\/form\/([^\/]+)$/);
  return match ? match[1] : null;
};

const root = ReactDOM.createRoot(document.getElementById('root'));

// Si c'est une route publique, rendre directement le composant correspondant sans AuthProvider
if (isPublicRoute()) {
  const concertId = extractConcertId();
  console.log('index.js - Rendu direct du composant public avec concertId:', concertId);
  
  // Déterminer quel composant public rendre
  const hash = window.location.hash || '';
  const cleanPath = hash.replace(/^#/, '');
  
  if (cleanPath === '/form-submitted') {
    root.render(
      <React.StrictMode>
        <HashRouter>
          <FormSubmittedPage />
        </HashRouter>
      </React.StrictMode>
    );
  } else {
    root.render(
      <React.StrictMode>
        <HashRouter>
          <PublicFormPage concertId={concertId} />
        </HashRouter>
      </React.StrictMode>
    );
  }
} else {
  // Pour les routes protégées, rendre l'application normale avec AuthProvider
  console.log('index.js - Rendu de l\'application normale avec AuthProvider');
  root.render(
    <React.StrictMode>
      <HashRouter>
        <AuthProvider>
          <App />
        </AuthProvider>
      </HashRouter>
    </React.StrictMode>
  );
}
