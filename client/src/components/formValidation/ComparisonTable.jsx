import React, { useState } from 'react';
import { updateProgrammer } from '../../services/programmersService';
import { updateFormSubmission } from '../../services/formSubmissionsService';
import './ComparisonTable.css';

/**
 * Composant d'interface de comparaison entre les données du formulaire et la fiche programmateur
 * Permet de visualiser côte à côte les données et de copier les valeurs avec des flèches
 */
const ComparisonTable = ({ formData, programmer, onClose, onSuccess }) => {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  
  // État pour stocker les données modifiées du programmateur
  const [updatedProgrammerData, setUpdatedProgrammerData] = useState({...programmer});
  
  // Liste des champs à comparer
  const fieldsToCompare = [
    { key: 'businessName', label: 'Raison sociale' },
    { key: 'firstName', label: 'Prénom', programmerKey: 'firstName' },
    { key: 'lastName', label: 'Nom', programmerKey: 'lastName' },
    { key: 'role', label: 'Qualité' },
    { key: 'address', label: 'Adresse de la raison sociale' },
    { key: 'venue', label: 'Lieu ou festival' },
    { key: 'venueAddress', label: 'Adresse du lieu ou festival', programmerKey: 'venueAddress' },
    { key: 'vatNumber', label: 'Numéro intracommunautaire' },
    { key: 'siret', label: 'Siret' },
    { key: 'email', label: 'Mail' },
    { key: 'phone', label: 'Téléphone' },
    { key: 'website', label: 'Site web' }
  ];
  
  // Fonction pour copier une valeur du formulaire vers la fiche programmateur
  const copyValueToProgrammer = (field) => {
    const sourceKey = field.key;
    const targetKey = field.programmerKey || field.key;
    
    if (formData[sourceKey]) {
      setUpdatedProgrammerData(prev => ({
        ...prev,
        [targetKey]: formData[sourceKey]
      }));
    }
  };
  
  // Fonction pour valider les modifications
  const handleValidate = async () => {
    try {
      setLoading(true);
      setError(null);
      
      // Mettre à jour la fiche programmateur avec les données modifiées
      await updateProgrammer(programmer.id, {
        ...updatedProgrammerData,
        // Ajouter le token commun pour lier les entités
        commonToken: formData.commonToken
      });
      
      // Marquer le formulaire comme traité
      await updateFormSubmission(formData.id, {
        status: 'processed',
        processedAt: new Date()
      });
      
      setLoading(false);
      
      // Appeler le callback de succès
      if (onSuccess) {
        onSuccess();
      }
      
    } catch (err) {
      console.error("Erreur lors de la validation des modifications:", err);
      setError(err.message);
      setLoading(false);
    }
  };
  
  return (
    <div className="comparison-table-container">
      <div className="comparison-table-header">
        <h3>Comparaison des données</h3>
        <button className="close-btn" onClick={onClose}>
          <i className="fas fa-times"></i>
        </button>
      </div>
      
      {error && (
        <div className="comparison-error">
          <i className="fas fa-exclamation-circle"></i> {error}
        </div>
      )}
      
      <div className="comparison-table">
        <div className="comparison-table-row header">
          <div className="comparison-field">Champ</div>
          <div className="comparison-form-value">Valeur du formulaire</div>
          <div className="comparison-action"></div>
          <div className="comparison-programmer-value">Fiche programmateur</div>
        </div>
        
        {fieldsToCompare.map((field) => {
          const formValue = formData[field.key];
          const programmerKey = field.programmerKey || field.key;
          const programmerValue = updatedProgrammerData[programmerKey];
          
          return (
            <div className="comparison-table-row" key={field.key}>
              <div className="comparison-field">{field.label}</div>
              <div className="comparison-form-value">
                {formValue || <span className="empty-value">Non renseigné</span>}
              </div>
              <div className="comparison-action">
                {formValue && (
                  <button 
                    className="copy-arrow-btn"
                    onClick={() => copyValueToProgrammer(field)}
                    disabled={loading}
                  >
                    <i className="fas fa-arrow-right"></i>
                  </button>
                )}
              </div>
              <div className="comparison-programmer-value">
                {programmerValue || <span className="empty-value">Non renseigné</span>}
              </div>
            </div>
          );
        })}
      </div>
      
      <div className="comparison-actions">
        <button 
          className="cancel-btn"
          onClick={onClose}
          disabled={loading}
        >
          Annuler
        </button>
        <button 
          className="validate-btn"
          onClick={handleValidate}
          disabled={loading}
        >
          {loading ? 'Validation en cours...' : 'Valider les modifications'}
        </button>
      </div>
    </div>
  );
};

export default ComparisonTable;
