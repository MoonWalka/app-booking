import React, { useState, useEffect } from 'react';
import { getFormSubmissions, updateFormSubmission } from '../../services/formSubmissionsService';
import { getProgrammerById, updateProgrammer } from '../../services/programmersService';
import { getConcertById, updateConcert } from '../../services/concertsService';
import ComparisonTable from './ComparisonTable';
import './FormValidationList.css';

const FormValidationList = () => {
  const [formSubmissions, setFormSubmissions] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [selectedSubmission, setSelectedSubmission] = useState(null);
  const [programmerData, setProgrammerData] = useState(null);
  const [showComparisonTable, setShowComparisonTable] = useState(false);
  const [updateStatus, setUpdateStatus] = useState({ status: '', message: '' });

  // Charger les soumissions de formulaire
  useEffect(() => {
    const fetchFormSubmissions = async () => {
      try {
        setLoading(true);
        const submissions = await getFormSubmissions({ status: 'pending' });
        setFormSubmissions(submissions);
        setLoading(false);
      } catch (err) {
        console.error('Erreur lors du chargement des soumissions:', err);
        setError('Erreur lors du chargement des soumissions. Veuillez réessayer.');
        setLoading(false);
      }
    };

    fetchFormSubmissions();
  }, []);

  // Gérer la sélection d'une soumission
  const handleSelectSubmission = async (submission) => {
    setSelectedSubmission(submission);
    setUpdateStatus({ status: '', message: '' });
    
    try {
      // Rechercher le programmateur associé par token commun
      let programmer = null;
      
      if (submission.commonToken) {
        // Rechercher par token commun
        const programmers = await getProgrammerById(submission.commonToken);
        if (programmers) {
          programmer = programmers;
        }
      }
      
      // Si aucun programmateur n'est trouvé, créer un objet vide
      if (!programmer) {
        programmer = {
          id: null,
          businessName: '',
          firstName: '',
          lastName: '',
          role: '',
          address: '',
          venue: '',
          venueAddress: '',
          vatNumber: '',
          siret: '',
          email: '',
          phone: '',
          website: ''
        };
      }
      
      setProgrammerData(programmer);
      setShowComparisonTable(true);
    } catch (err) {
      console.error('Erreur lors de la récupération des données du programmateur:', err);
      setError('Erreur lors de la récupération des données du programmateur. Veuillez réessayer.');
    }
  };

  // Gérer l'intégration des données
  const handleIntegrateData = async (updatedData) => {
    try {
      setLoading(true);
      
      // Mettre à jour ou créer le programmateur
      let programmerId = programmerData.id;
      
      // Préparer les données du programmateur
      const programmerData = {
        ...updatedData,
        commonToken: selectedSubmission.commonToken,
        // Ajouter d'autres champs nécessaires
        contact: updatedData.firstName && updatedData.lastName 
          ? `${updatedData.firstName} ${updatedData.lastName}` 
          : updatedData.firstName || updatedData.lastName || 'Contact non spécifié'
      };
      
      if (programmerId) {
        // Mettre à jour le programmateur existant
        await updateProgrammer(programmerId, programmerData);
      } else {
        // Créer un nouveau programmateur avec le token commun comme ID
        programmerId = selectedSubmission.commonToken;
        await updateProgrammer(programmerId, programmerData);
      }
      
      // Mettre à jour le concert si nécessaire
      if (selectedSubmission.concertId) {
        try {
          const concert = await getConcertById(selectedSubmission.concertId);
          if (concert) {
            // Mettre à jour le concert avec le token commun
            await updateConcert(selectedSubmission.concertId, {
              ...concert,
              commonToken: selectedSubmission.commonToken,
              programmerId: programmerId
            });
          }
        } catch (concertErr) {
          console.error('Erreur lors de la mise à jour du concert:', concertErr);
        }
      }
      
      // Mettre à jour le statut de la soumission
      await updateFormSubmission(selectedSubmission.id, {
        ...selectedSubmission,
        status: 'processed',
        processedAt: new Date()
      });
      
      // Mettre à jour la liste des soumissions
      const updatedSubmissions = formSubmissions.filter(
        submission => submission.id !== selectedSubmission.id
      );
      setFormSubmissions(updatedSubmissions);
      
      // Réinitialiser l'état
      setSelectedSubmission(null);
      setProgrammerData(null);
      setShowComparisonTable(false);
      setUpdateStatus({
        status: 'success',
        message: 'Données intégrées avec succès!'
      });
      setLoading(false);
    } catch (err) {
      console.error('Erreur lors de l\'intégration des données:', err);
      setUpdateStatus({
        status: 'error',
        message: `Erreur lors de l'intégration des données: ${err.message}`
      });
      setLoading(false);
    }
  };

  // Annuler l'intégration
  const handleCancelIntegration = () => {
    setSelectedSubmission(null);
    setProgrammerData(null);
    setShowComparisonTable(false);
  };

  if (loading && !showComparisonTable) {
    return <div className="loading">Chargement des soumissions...</div>;
  }

  if (error) {
    return <div className="error">{error}</div>;
  }

  if (showComparisonTable && selectedSubmission && programmerData) {
    return (
      <div className="form-validation-container">
        <h2>Intégration des données</h2>
        <div className="submission-details">
          <h3>Détails de la soumission</h3>
          <p><strong>ID:</strong> {selectedSubmission.id}</p>
          <p><strong>Date de soumission:</strong> {selectedSubmission.submittedAt instanceof Date 
            ? selectedSubmission.submittedAt.toLocaleString() 
            : new Date(selectedSubmission.submittedAt.seconds * 1000).toLocaleString()}</p>
          <p><strong>Token commun:</strong> {selectedSubmission.commonToken}</p>
          <p><strong>Concert ID:</strong> {selectedSubmission.concertId}</p>
        </div>
        
        <ComparisonTable 
          formData={selectedSubmission} 
          programmerData={programmerData}
          onSave={handleIntegrateData}
          onCancel={handleCancelIntegration}
        />
      </div>
    );
  }

  return (
    <div className="form-validation-container">
      <h2>Validation des formulaires</h2>
      
      {updateStatus.message && (
        <div className={`status-message ${updateStatus.status}`}>
          {updateStatus.message}
        </div>
      )}
      
      {formSubmissions.length === 0 ? (
        <p>Aucune soumission en attente de validation.</p>
      ) : (
        <div className="submissions-list">
          <h3>Soumissions en attente ({formSubmissions.length})</h3>
          <table className="submissions-table">
            <thead>
              <tr>
                <th>Date</th>
                <th>Raison sociale</th>
                <th>Contact</th>
                <th>Token</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {formSubmissions.map(submission => (
                <tr key={submission.id}>
                  <td>
                    {submission.submittedAt instanceof Date 
                      ? submission.submittedAt.toLocaleString() 
                      : new Date(submission.submittedAt.seconds * 1000).toLocaleString()}
                  </td>
                  <td>{submission.businessName || 'Non spécifié'}</td>
                  <td>{submission.contact || 'Non spécifié'}</td>
                  <td>{submission.commonToken ? submission.commonToken.substring(0, 10) + '...' : 'Non spécifié'}</td>
                  <td>
                    <button 
                      className="action-button"
                      onClick={() => handleSelectSubmission(submission)}
                    >
                      Comparer et intégrer
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
};

export default FormValidationList;
