import React, { useState, useEffect } from 'react';
import './ComparisonTable.css';

/**
 * Composant de tableau comparatif pour comparer et intégrer les données du formulaire
 * avec les données existantes du programmateur
 */
const ComparisonTable = ({ formData, programmerData, onSave, onCancel }) => {
  // État pour stocker les valeurs sélectionnées
  const [selectedValues, setSelectedValues] = useState({});
  
  // Initialiser les valeurs sélectionnées avec les valeurs du programmateur
  useEffect(() => {
    if (programmerData) {
      const initialValues = {};
      // Pour chaque champ du programmateur, utiliser sa valeur comme valeur initiale
      Object.keys(programmerData).forEach(key => {
        if (key !== 'id' && key !== 'submittedAt' && key !== 'status' && 
            key !== 'processedAt' && key !== 'commonToken' && key !== 'formLinkId') {
          initialValues[key] = programmerData[key] || '';
        }
      });
      setSelectedValues(initialValues);
      console.log('ComparisonTable - Valeurs initiales chargées:', initialValues);
    }
  }, [programmerData]);
  
  // Gérer le clic sur une flèche pour copier une valeur
  const handleCopyValue = (field, value) => {
    setSelectedValues(prev => ({
      ...prev,
      [field]: value
    }));
    console.log(`ComparisonTable - Valeur copiée pour le champ ${field}:`, value);
  };
  
  // Gérer la modification manuelle d'une valeur
  const handleChange = (field, value) => {
    setSelectedValues(prev => ({
      ...prev,
      [field]: value
    }));
  };
  
  // Gérer la sauvegarde des valeurs sélectionnées
  const handleSave = () => {
    // Conserver le token commun et l'ID du formulaire
    const updatedData = {
      ...selectedValues,
      commonToken: formData.commonToken,
      formLinkId: formData.formLinkId
    };
    console.log('ComparisonTable - Données finales à sauvegarder:', updatedData);
    onSave(updatedData);
  };
  
  // Définir les champs à comparer et leur libellé
  const fieldDefinitions = [
    { key: 'businessName', label: 'Raison sociale' },
    { key: 'firstName', label: 'Prénom' },
    { key: 'lastName', label: 'Nom' },
    { key: 'role', label: 'Qualité' },
    { key: 'address', label: 'Adresse' },
    { key: 'venue', label: 'Lieu ou festival' },
    { key: 'venueAddress', label: 'Adresse du lieu' },
    { key: 'vatNumber', label: 'Numéro intracommunautaire' },
    { key: 'siret', label: 'Siret' },
    { key: 'email', label: 'Email' },
    { key: 'phone', label: 'Téléphone' },
    { key: 'website', label: 'Site web' }
  ];
  
  return (
    <div className="comparison-table-container">
      <h3>Comparaison et intégration des données</h3>
      <p>Comparez les données du formulaire avec les données existantes et choisissez les valeurs à conserver.</p>
      
      <table className="comparison-table">
        <thead>
          <tr>
            <th>Champ</th>
            <th>Valeur existante</th>
            <th>Valeur du formulaire</th>
            <th></th>
            <th>Valeur finale</th>
          </tr>
        </thead>
        <tbody>
          {fieldDefinitions.map(field => (
            <tr key={field.key}>
              <td className="field-label">{field.label}</td>
              <td className="existing-value">
                {programmerData && programmerData[field.key] ? programmerData[field.key] : '-'}
              </td>
              <td className="form-value">
                {formData && formData[field.key] ? formData[field.key] : '-'}
              </td>
              <td className="arrow-cell">
                {formData && formData[field.key] && (
                  <button 
                    className="arrow-button right-arrow"
                    onClick={() => handleCopyValue(field.key, formData[field.key])}
                    title="Utiliser la valeur du formulaire"
                  >
                    →
                  </button>
                )}
              </td>
              <td className="final-value">
                <input 
                  type="text" 
                  value={selectedValues[field.key] || ''} 
                  onChange={(e) => handleChange(field.key, e.target.value)}
                  className="final-value-input"
                />
              </td>
            </tr>
          ))}
        </tbody>
      </table>
      
      <div className="comparison-actions">
        <button className="cancel-button" onClick={onCancel}>Annuler</button>
        <button className="save-button" onClick={handleSave}>Valider et intégrer</button>
      </div>
    </div>
  );
};

export default ComparisonTable;
