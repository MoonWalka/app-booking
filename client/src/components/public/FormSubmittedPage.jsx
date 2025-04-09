import React from 'react';
import './FormSubmittedPage.css';

const FormSubmittedPage = () => {
  return (
    <div className="form-submitted-container">
      <div className="form-submitted-content">
        <div className="success-icon">
          <i className="fas fa-check-circle"></i>
        </div>
        <h1>Formulaire envoyé avec succès !</h1>
        <p className="thank-you-message">
          Merci d'avoir complété ce formulaire. Vos informations ont été enregistrées et seront traitées prochainement.
        </p>
        <div className="additional-info">
          <p>
            <i className="fas fa-info-circle"></i>
            Les informations que vous avez fournies seront utilisées pour la préparation des contrats et la facturation.
          </p>
          <p>
            <i className="fas fa-envelope"></i>
            Vous pourriez être contacté par email ou téléphone si des informations supplémentaires sont nécessaires.
          </p>
        </div>
        <div className="form-submitted-footer">
          <p>Vous pouvez maintenant fermer cette page.</p>
        </div>
      </div>
    </div>
  );
};

export default FormSubmittedPage;
