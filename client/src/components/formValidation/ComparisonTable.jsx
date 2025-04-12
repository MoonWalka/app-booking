import React, { useState, useEffect } from 'react';
import { updateFormSubmissionWithValidatedData, updateLinkedEntities } from '../../services/formSubmissionsService';
import from './services/programmersService';


const ComparisonTable = ({ submission, onValidationComplete }) => {
  const [programmerData, setProgrammerData] = useState(null);
  const [finalData, setFinalData] = useState({});
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchProgrammerData = async () => {
      try {
        setLoading(true);
        
        // Rechercher le programmateur par email
        if (submission.email) {
          const programmer = await getProgrammerByEmail(submission.email);
          if (programmer) {
            setProgrammerData(programmer);
            
            // Initialiser les données finales avec les valeurs existantes du programmateur
            const initialFinalData = {};
            Object.keys(submission).forEach(key => {
              if (key !== 'id' && key !== 'status' && key !== 'createdAt' && key !== 'commonToken') {
                initialFinalData[key] = programmer[key] || '';
              }
            });
            setFinalData(initialFinalData);
          } else {
            // Si aucun programmateur n'est trouvé, utiliser les données de la soumission
            const initialFinalData = {};
            Object.keys(submission).forEach(key => {
              if (key !== 'id' && key !== 'status' && key !== 'createdAt' && key !== 'commonToken') {
                initialFinalData[key] = submission[key] || '';
              }
            });
            setFinalData(initialFinalData);
          }
        } else {
          // Si pas d'email, utiliser les données de la soumission
          const initialFinalData = {};
          Object.keys(submission).forEach(key => {
            if (key !== 'id' && key !== 'status' && key !== 'createdAt' && key !== 'commonToken') {
              initialFinalData[key] = submission[key] || '';
            }
          });
          setFinalData(initialFinalData);
        }
        
        setLoading(false);
      } catch (error) {
        console.error("Erreur lors de la récupération des données du programmateur:", error);
        setLoading(false);
      }
    };

    fetchProgrammerData();
  }, [submission]);

  const handleCopyFromSubmission = (field) => {
    setFinalData(prevData => ({
      ...prevData,
      [field]: submission[field] || ''
    }));
  };

  const handleCopyFromProgrammer = (field) => {
    if (programmerData && programmerData[field]) {
      setFinalData(prevData => ({
        ...prevData,
        [field]: programmerData[field]
      }));
    }
  };

  const handleInputChange = (field, value) => {
    setFinalData(prevData => ({
      ...prevData,
      [field]: value
    }));
  };

  const handleValidateData = async () => {
    try {
      // Mettre à jour la soumission avec les données validées
      await updateFormSubmissionWithValidatedData(submission.id, finalData);
      
      // Si un token commun existe, mettre à jour toutes les entités liées
      if (submission.commonToken) {
        await updateLinkedEntities(submission.commonToken, finalData);
      }
      
      // Si un programmateur existe, le mettre à jour
      if (programmerData) {
        await updateProgrammer(programmerData.id, finalData);
      }
      
      // Notifier le composant parent que la validation est terminée
      if (onValidationComplete) {
        onValidationComplete();
      }
    } catch (error) {
      console.error("Erreur lors de la validation des données:", error);
    }
  };

  if (loading) {
    return <div className="loading">Chargement des données...</div>;
  }

  // Définir les champs à afficher et leur libellé
  const fields = [
    { key: 'firstName', label: 'Prénom' },
    { key: 'lastName', label: 'Nom' },
    { key: 'organization', label: 'Structure' },
    { key: 'position', label: 'Fonction' },
    { key: 'email', label: 'Email' },
    { key: 'phone', label: 'Téléphone' },
    { key: 'address', label: 'Adresse' },
    { key: 'postalCode', label: 'Code postal' },
    { key: 'city', label: 'Ville' },
    { key: 'country', label: 'Pays' },
    { key: 'website', label: 'Site web' },
    { key: 'vatNumber', label: 'Numéro TVA' },
    { key: 'siret', label: 'SIRET' },
    { key: 'notes', label: 'Notes' }
  ];

  return (
    <div className="comparison-table-container">
      <table className="comparison-table">
        <thead>
          <tr>
            <th>Champ</th>
            <th>Valeur du formulaire</th>
            <th></th>
            <th>Valeur existante</th>
            <th></th>
            <th>Valeur finale</th>
          </tr>
        </thead>
        <tbody>
          {fields.map((field) => (
            <tr key={field.key}>
              <td className="field-label">{field.label}</td>
              <td className="submission-value">{submission[field.key] || ''}</td>
              <td className="action-cell">
                {submission[field.key] && (
                  <button 
                    className="copy-btn"
                    onClick={() => handleCopyFromSubmission(field.key)}
                    title="Utiliser cette valeur"
                  >
                    →
                  </button>
                )}
              </td>
              <td className="programmer-value">
                {programmerData ? (programmerData[field.key] || '') : ''}
              </td>
              <td className="action-cell">
                {programmerData && programmerData[field.key] && (
                  <button 
                    className="copy-btn"
                    onClick={() => handleCopyFromProgrammer(field.key)}
                    title="Utiliser cette valeur"
                  >
                    →
                  </button>
                )}
              </td>
              <td className="final-value">
                <input 
                  type="text" 
                  value={finalData[field.key] || ''} 
                  onChange={(e) => handleInputChange(field.key, e.target.value)}
                />
              </td>
            </tr>
          ))}
        </tbody>
      </table>
      
      <div className="validation-actions">
        <button 
          className="validate-final-btn"
          onClick={handleValidateData}
        >
          Valider les données
        </button>
      </div>
    </div>
  );
};

export default ComparisonTable;
