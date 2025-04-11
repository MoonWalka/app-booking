import React, { useState, useEffect } from 'react';
import { 
  getFormSubmissions, 
  getPendingFormSubmissions, 
  updateFormSubmissionStatus,
  updateFormSubmissionWithProgrammerData,
  getFormSubmissionsStats
} from '../../services/formSubmissionsService';
import ComparisonTable from './ComparisonTable';
import './FormValidationList.css';

const FormValidationList = () => {
  const [submissions, setSubmissions] = useState([]);
  const [pendingSubmissions, setPendingSubmissions] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [selectedSubmission, setSelectedSubmission] = useState(null);
  const [showComparisonTable, setShowComparisonTable] = useState(false);
  const [stats, setStats] = useState({
    total: 0,
    pendingCount: 0,
    statusCounts: {},
    withCommonToken: 0,
    withoutCommonToken: 0
  });

  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true);
        setError(null);
        
        console.log('FormValidationList - Chargement des soumissions...');
        
        // Récupérer toutes les soumissions
        const allSubmissions = await getFormSubmissions();
        setSubmissions(allSubmissions);
        
        // Récupérer les soumissions en attente
        const pendingSubmissionsData = await getPendingFormSubmissions();
        setPendingSubmissions(pendingSubmissionsData);
        
        // Calculer les statistiques
        const statsData = await getFormSubmissionsStats();
        setStats(statsData);
        
        console.log('FormValidationList - Données chargées avec succès');
        setLoading(false);
      } catch (error) {
        console.error('FormValidationList - Erreur lors du chargement des données:', error);
        setError('Erreur lors du chargement des soumissions. Veuillez réessayer.');
        setLoading(false);
      }
    };

    fetchData();
  }, []);

  const handleApprove = async (id) => {
    try {
      setLoading(true);
      console.log(`FormValidationList - Approbation de la soumission ${id}...`);
      
      // Trouver la soumission sélectionnée
      const submission = pendingSubmissions.find(sub => sub.id === id);
      if (submission) {
        setSelectedSubmission(submission);
        setShowComparisonTable(true);
        setLoading(false);
        return;
      }
      
      await updateFormSubmissionStatus(id, 'approved');
      
      // Mettre à jour la liste des soumissions
      const updatedSubmissions = submissions.map(submission => 
        submission.id === id 
          ? { ...submission, status: 'approved' } 
          : submission
      );
      setSubmissions(updatedSubmissions);
      
      // Mettre à jour la liste des soumissions en attente
      const updatedPendingSubmissions = pendingSubmissions.filter(
        submission => submission.id !== id
      );
      setPendingSubmissions(updatedPendingSubmissions);
      
      // Mettre à jour les statistiques
      const newStats = { ...stats };
      newStats.statusCounts.pending = (newStats.statusCounts.pending || 0) - 1;
      newStats.statusCounts.approved = (newStats.statusCounts.approved || 0) + 1;
      newStats.pendingCount = newStats.pendingCount - 1;
      setStats(newStats);
      
      console.log(`FormValidationList - Soumission ${id} approuvée`);
      setLoading(false);
    } catch (error) {
      console.error(`FormValidationList - Erreur lors de l'approbation de la soumission ${id}:`, error);
      setError(`Erreur lors de l'approbation de la soumission. Veuillez réessayer.`);
      setLoading(false);
    }
  };

  const handleReject = async (id) => {
    try {
      setLoading(true);
      console.log(`FormValidationList - Rejet de la soumission ${id}...`);
      
      await updateFormSubmissionStatus(id, 'rejected');
      
      // Mettre à jour la liste des soumissions
      const updatedSubmissions = submissions.map(submission => 
        submission.id === id 
          ? { ...submission, status: 'rejected' } 
          : submission
      );
      setSubmissions(updatedSubmissions);
      
      // Mettre à jour la liste des soumissions en attente
      const updatedPendingSubmissions = pendingSubmissions.filter(
        submission => submission.id !== id
      );
      setPendingSubmissions(updatedPendingSubmissions);
      
      // Mettre à jour les statistiques
      const newStats = { ...stats };
      newStats.statusCounts.pending = (newStats.statusCounts.pending || 0) - 1;
      newStats.statusCounts.rejected = (newStats.statusCounts.rejected || 0) + 1;
      newStats.pendingCount = newStats.pendingCount - 1;
      setStats(newStats);
      
      console.log(`FormValidationList - Soumission ${id} rejetée`);
      setLoading(false);
    } catch (error) {
      console.error(`FormValidationList - Erreur lors du rejet de la soumission ${id}:`, error);
      setError(`Erreur lors du rejet de la soumission. Veuillez réessayer.`);
      setLoading(false);
    }
  };

  const handleSaveComparisonData = async (finalData) => {
    try {
      setLoading(true);
      console.log(`FormValidationList - Sauvegarde des données de comparaison pour la soumission ${selectedSubmission.id}...`);
      
      // Mettre à jour la soumission avec les données finales
      await updateFormSubmissionWithProgrammerData(selectedSubmission.id, finalData);
      
      // Mettre à jour le statut de la soumission
      await updateFormSubmissionStatus(selectedSubmission.id, 'approved');
      
      // Mettre à jour la liste des soumissions
      const updatedSubmissions = submissions.map(submission => 
        submission.id === selectedSubmission.id 
          ? { ...submission, status: 'approved', processedData: finalData } 
          : submission
      );
      setSubmissions(updatedSubmissions);
      
      // Mettre à jour la liste des soumissions en attente
      const updatedPendingSubmissions = pendingSubmissions.filter(
        submission => submission.id !== selectedSubmission.id
      );
      setPendingSubmissions(updatedPendingSubmissions);
      
      // Mettre à jour les statistiques
      const newStats = { ...stats };
      newStats.statusCounts.pending = (newStats.statusCounts.pending || 0) - 1;
      newStats.statusCounts.approved = (newStats.statusCounts.approved || 0) + 1;
      newStats.pendingCount = newStats.pendingCount - 1;
      setStats(newStats);
      
      console.log(`FormValidationList - Données de comparaison sauvegardées pour la soumission ${selectedSubmission.id}`);
      
      // Fermer le tableau de comparaison
      setShowComparisonTable(false);
      setSelectedSubmission(null);
      setLoading(false);
    } catch (error) {
      console.error(`FormValidationList - Erreur lors de la sauvegarde des données de comparaison:`, error);
      setError(`Erreur lors de la sauvegarde des données. Veuillez réessayer.`);
      setLoading(false);
    }
  };

  const handleCancelComparison = () => {
    setShowComparisonTable(false);
    setSelectedSubmission(null);
  };

  const formatDate = (timestamp) => {
    if (!timestamp) return 'Date inconnue';
    
    try {
      let date;
      if (timestamp instanceof Date) {
        date = timestamp;
      } else if (timestamp.seconds) {
        date = new Date(timestamp.seconds * 1000);
      } else if (timestamp.toDate) {
        date = timestamp.toDate();
      } else {
        date = new Date(timestamp);
      }
      
      return date.toLocaleDateString('fr-FR', {
        day: '2-digit',
        month: '2-digit',
        year: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
      });
    } catch (error) {
      console.error('FormValidationList - Erreur lors du formatage de la date:', error);
      return 'Date invalide';
    }
  };

  if (loading && submissions.length === 0) {
    return <div className="loading">Chargement des soumissions de formulaire...</div>;
  }

  if (error) {
    return (
      <div className="error-container">
        <div className="error">{error}</div>
        <button className="refresh-button" onClick={() => window.location.reload()}>
          Rafraîchir la page
        </button>
      </div>
    );
  }

  if (showComparisonTable && selectedSubmission) {
    // Simuler les données du programmateur existant
    // Dans une vraie application, ces données viendraient d'un service
    const existingProgrammerData = {
      id: 'programmer-' + Math.random().toString(36).substr(2, 9),
      businessName: '',
      firstName: selectedSubmission.firstName || '',
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
    
    return (
      <div className="form-validation-container">
        <h1>Validation des données</h1>
        
        <ComparisonTable 
          formData={selectedSubmission} 
          programmerData={existingProgrammerData}
          onSave={handleSaveComparisonData}
          onCancel={handleCancelComparison}
        />
      </div>
    );
  }

  return (
    <div className="form-validation-container">
      <h1>Validation des formulaires</h1>
      
      <div className="stats-panel">
        <h2>Informations de débogage</h2>
        <p>Total des soumissions: {stats.total}</p>
        <p>Soumissions en attente: {stats.pendingCount}</p>
        <p>Distribution des statuts:</p>
        <ul>
          {Object.entries(stats.statusCounts).map(([status, count]) => (
            <li key={status}>{status}: {count}</li>
          ))}
        </ul>
        <p>Avec token commun: {stats.withCommonToken}</p>
        <p>Sans token commun: {stats.withoutCommonToken}</p>
      </div>
      
      {pendingSubmissions.length === 0 ? (
        <div className="no-submissions">
          <p>Aucune soumission en attente de validation.</p>
        </div>
      ) : (
        <div className="submissions-list">
          <h2>Soumissions en attente ({pendingSubmissions.length})</h2>
          
          {pendingSubmissions.map(submission => (
            <div key={submission.id} className="submission-card">
              <div className="submission-header">
                <h3>Soumission #{submission.id.substring(0, 6)}</h3>
                <span className="submission-date">
                  {formatDate(submission.submissionDate)}
                </span>
              </div>
              
              <div className="submission-details">
                <div className="detail-row">
                  <span className="detail-label">Raison sociale:</span>
                  <span className="detail-value">{submission.businessName || 'Non spécifié'}</span>
                </div>
                
                <div className="detail-row">
                  <span className="detail-label">Nom:</span>
                  <span className="detail-value">
                    {submission.firstName || ''} {submission.lastName || ''}
                    {!submission.firstName && !submission.lastName && 'Non spécifié'}
                  </span>
                </div>
                
                <div className="detail-row">
                  <span className="detail-label">Email:</span>
                  <span className="detail-value">{submission.email || 'Non spécifié'}</span>
                </div>
                
                <div className="detail-row">
                  <span className="detail-label">Téléphone:</span>
                  <span className="detail-value">{submission.phone || 'Non spécifié'}</span>
                </div>
                
                <div className="detail-row">
                  <span className="detail-label">Date du concert:</span>
                  <span className="detail-value">
                    {submission.concertDate 
                      ? formatDate(submission.concertDate) 
                      : 'Non spécifiée'}
                  </span>
                </div>
                
                <div className="detail-row">
                  <span className="detail-label">Lieu:</span>
                  <span className="detail-value">{submission.venue || 'Non spécifié'}</span>
                </div>
                
                <div className="detail-row">
                  <span className="detail-label">Ville:</span>
                  <span className="detail-value">{submission.concertCity || 'Non spécifiée'}</span>
                </div>
                
                <div className="detail-row">
                  <span className="detail-label">Token commun:</span>
                  <span className="detail-value">
                    {submission.commonToken || 'Aucun'}
                  </span>
                </div>
                
                {submission.additionalInfo && (
                  <div className="detail-row full-width">
                    <span className="detail-label">Informations supplémentaires:</span>
                    <div className="detail-value additional-info">
                      {submission.additionalInfo}
                    </div>
                  </div>
                )}
              </div>
              
              <div className="submission-actions">
                <button 
                  className="reject-button"
                  onClick={() => handleReject(submission.id)}
                  disabled={loading}
                >
                  Rejeter
                </button>
                <button 
                  className="approve-button"
                  onClick={() => handleApprove(submission.id)}
                  disabled={loading}
                >
                  Approuver
                </button>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
};

export default FormValidationList;
