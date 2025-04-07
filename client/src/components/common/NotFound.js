// client/src/components/common/NotFound.js
import React from 'react';
import { Link } from 'react-router-dom';

const NotFound = () => {
  return (
    <div className="not-found-container">
      <h2>404 - Page Non Trouvée</h2>
      <p>La page que vous recherchez n'existe pas ou a été déplacée.</p>
      <div className="not-found-actions">
        <Link to="/" className="home-btn">
          Retour à l'accueil
        </Link>
      </div>
    </div>
  );
};

export default NotFound;
