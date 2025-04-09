import React from 'react';
import './FormSubmittedPage.css';

const FormSubmittedPage = () => {
  console.log('FormSubmittedPage rendered');
  
  return (
    <div className="form-submitted-container">
      <div className="form-submitted-card">
        <div className="success-icon">
          <svg xmlns="http://www.w3.org/2000/svg" width="64" height="64" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
            <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path>
            <polyline points="22 4 12 14.01 9 11.01"></polyline>
          </svg>
        </div>
        <h2>Formulaire envoyé avec succès !</h2>
        <p>
          Merci d'avoir complété ce formulaire. Vos informations ont été enregistrées
          et seront traitées prochainement.
        </p>
        <p>
          Vous pouvez maintenant fermer cette page.
        </p>
        <button 
          className="back-button"
          onClick={() => window.location.href = window.location.origin}
        >
          Retour à l'accueil
        </button>
      </div>
    </div>
  );
};

export default FormSubmittedPage;
