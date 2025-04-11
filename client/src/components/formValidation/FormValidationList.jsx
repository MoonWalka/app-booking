import React, { useState, useEffect } from 'react';
import { getFormSubmissions, updateFormSubmission, updateSubmissionsWithoutStatus } from '../../services/formSubmissionsService';
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
  const [refreshCount, setRefreshCount] = useState(0);
  const [debugInfo, setDebugInfo] = useState(null);

  // Charger les soumissions de formulaire
  useEffect(() => {
    const fetchFormSubmissions = async () => {
      try {
        setLoading(true);
        console.log('FormValidationList - Chargement des soumissions en attente...');
        
        // Mettre à jour les soumissions sans statut
        const updatedCount = await updateSubmissionsWithoutStatus();
        if (updatedCount > 0) {
          console.log(`FormValidationList - ${updatedCount} soumissions mises à jour avec statut 'pending'`);
        }
        
        // Récupérer toutes les soumissions pour le débogage
        const allSubmissions = await getFormSubmissions({});
        console.log(`FormValidationList - ${allSubmissions.length} soumissions totales récupérées`);
        
        // Filtrer pour n'obtenir que les soumissions en attente
        const pendingSubmissions = await getFormSubmissions({ status: 'pending' });
        console.log(`FormValidationList - ${pendingSubmissions.length} soumissions en attente récupérées`);
        
        // Collecter des informations de débogage
        const debug = {
          totalCount: allSubmissions.length,
          pendingCount: pendingSubmissions.length,
          statusDistribution: {},
          hasCommonToken: 0,
          missingCommonToken: 0
        };
        
        // Analyser la distribution des statuts
        allSubmissions.forEach(submission => {
          const status = submission.status || 'non défini';
          debug.statusDistribution[status] = (debug.statusDistribution[status] || 0) + 1;
          
          if (submission.commonToken) {
            debug.hasCommonToken++;
          } else {
            debug.missingCommonToken++;
          }
        });
        
        setDebugInfo(debug);
        setFormSubmissions(pendingSubmissions);
        setLoading(false);
      } catch (err) {
        console.error('FormValidationList - Erreur lors du chargement des soumissions:', err);
        setError('Erreur lors du chargement des soumissions. Veuillez réessayer.');
        setLoading(false);
      }
    };

    fetchFormSubmissions();
    
    // Mettre en place un intervalle pour rafraîchir les soumissions toutes les 30 secondes
    const refreshInterval = setInterval(() => {
      console.log('FormValidationList - Rafraîchissement automatique des soumissions');
      setRefreshCount(prev => prev + 1);
    }, 30000);
    
    // Nettoyer l'intervalle lors du démontage du composant
    return () => clearInterval(refreshInterval);
  }, [refreshCount]);

  // Gérer la sélection d'une soumission
  const handleSelectSubmission = async (submission) => {
    console.log('FormValidationList - Sélection de la soumission:', submission);
    setSelectedSubmission(submission);
    setUpdateStatus({ status: '', message: '' });
    
    try {
      // Rechercher le programmateur associé par token commun
      let programmer = null;
      
      if (submission.commonToken) {
        console.log(`FormValidationList - Recherche du programmateur avec token: ${submission.commonToken}`);
        // Rechercher par token commun
        const programmers = await getProgrammerById(submission.commonToken);
        if (programmers) {
          programmer = programmers;
          console.log('FormValidationList - Programmateur trouvé:', programmer);
        } else {
          console.log('FormValidationList - Aucun programmateur trouvé avec ce token');
        }
      } else {
        console.log('FormValidationList - Pas de token commun dans la soumission');
      }
      
      // Si aucun programmateur n'est trouvé, créer un objet vide
      if (!programmer) {
        console.log('FormValidationList - Création d\'un objet programmateur vide');
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
      console.error('FormValidationList - Erreur lors de la récupération des données du programmateur:', err);
      setError('Erreur lors de la récupération des données du programmateur. Veuillez réessayer.');
    }
  };

  // Gérer l'intégration des données
  const handleIntegrateData = async (updatedData) => {
    try {
      setLoading(true);
      console.log('FormValidationList - Début de l\'intégration des données');
      
      // Mettre à jour ou créer le programmateur
      let programmerId = programmerData.id;
      
      // Préparer les données du programmateur
      const programmerDataToUpdate = {
        ...updatedData,
        commonToken: selectedSubmission.commonToken,
        // Ajouter d'autres champs nécessaires
        contact: updatedData.firstName && updatedData.lastName 
          ? `${updatedData.firstName} ${updatedData.lastName}` 
          : updatedData.firstName || updatedData.lastName || 'Contact non spécifié'
      };
      
      console.log('FormValidationList - Données du programmateur à mettre à jour:', programmerDataToUpdate);
      
      if (programmerId) {
        // Mettre à jour le programmateur existant
        console.log(`FormValidationList - Mise à jour du programmateur existant: ${programmerId}`);
        await updateProgrammer(programmerId, programmerDataToUpdate);
      } else {
        // Créer un nouveau programmateur avec le token commun comme ID
        programmerId = selectedSubmission.commonToken;
        console.log(`FormValidationList - Création d'un nouveau programmateur avec ID: ${programmerId}`);
        await updateProgrammer(programmerId, programmerDataToUpdate);
      }
      
      // Mettre à jour le concert si nécessaire
      if (selectedSubmission.concertId) {
        try {
          console.log(`FormValidationList - Récupération du concert: ${selectedSubmission.concertId}`);
          const concert = await getConcertById(selectedSubmission.concertId);
          if (concert) {
            // Mettre à jour le concert avec le token commun
            console.log(`FormValidationList - Mise à jour du concert: ${selectedSubmission.concertId}`);
            await updateConcert(selectedSubmission.concertId, {
              ...concert,
              commonToken: selectedSubmission.commonToken,
              programmerId: programmerId
            });
          } else {
            console.log(`FormValidationList - Concert non trouvé: ${selectedSubmission.concertId}`);
          }
        } catch (concertErr) {
          console.error('FormValidationList - Erreur lors de la mise à jour du concert:', concertErr);
        }
      }
      
      // Mettre à jour le statut de la soumission
      console.log(`FormValidationList - Mise à jour du statut de la soumission: ${selectedSubmission.id}`);
      await updateFormSubmission(selectedSubmission.id, {
        ...selectedSubmission,
        status: 'processed',
        processedAt: new Date()
      });
      
      // Mettre à jour la liste des soumissions
      const updatedSubmissions = formSubmissions.filter(
        submission => submission.id !== selectedSubmission.id
      );
      console.log(`FormValidationList - Mise à jour de la liste des soumissions: ${updatedSubmissions.length} restantes`);
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
      
      // Forcer un rafraîchissement de la liste
      setRefreshCount(prev => prev + 1);
    } catch (err) {
      console.error('FormValidationList - Erreur lors de l\'intégration des données:', err);
      setUpdateStatus({
        status: 'error',
        message: `Erreur lors de l'intégration des données: ${err.message}`
      });
      setLoading(false);
    }
  };

  // Annuler l'intégration
  const handleCancelIntegration = () => {
    console.log('FormValidationList - Annulation de l\'intégration');
    setSelectedSubmission(null);
    setProgrammerData(null);
    setShowComparisonTable(false);
  };

  // Rafraîchir manuellement la liste
  const handleRefresh = () => {
    console.log('FormValidationList - Rafraîchissement manuel de la liste');
    setRefreshCount(prev => prev + 1);
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
      
      <div className="refresh-button-container">
        <button className="refresh-button" onClick={handleRefresh}>
          Rafraîchir la liste
        </button>
      </div>
      
      {debugInfo && (
        <div className="debug-info">
          <h3>Informations de débogage</h3>
          <p>Total des soumissions: {debugInfo.totalCount}</p>
          <p>Soumissions en attente: {debugInfo.pendingCount}</p>
          <p>Distribution des statuts:</p>
          <ul>
            {Object.entries(debugInfo.statusDistribution).map(([status, count]) => (
              <li key={status}>{status}: {count}</li>
            ))}
          </ul>
          <p>Avec token commun: {debugInfo.hasCommonToken}</p>
          <p>Sans token commun: {debugInfo.missingCommonToken}</p>
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
