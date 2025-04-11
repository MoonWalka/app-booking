import React, { useState, useEffect } from 'react';
import { getAllFormSubmissions, getPendingFormSubmissions, updateFormSubmissionStatus } from '../../services/formSubmissionsService';
import ComparisonTable from './ComparisonTable';
import './FormValidationList.css';

const FormValidationList = () => {
  const [submissions, setSubmissions] = useState([]);
  const [pendingSubmissions, setPendingSubmissions] = useState([]);
  const [loading, setLoading] = useState(true);
  const [selectedSubmission, setSelectedSubmission] = useState(null);
  const [showComparisonModal, setShowComparisonModal] = useState(false);
  const [debugInfo, setDebugInfo] = useState('');

  useEffect(() => {
    const fetchSubmissions = async () => {
      try {
        setLoading(true);
        
        // Récupérer toutes les soumissions
        const allSubmissions = await getAllFormSubmissions();
        setSubmissions(allSubmissions || []);
        
        // Récupérer les soumissions en attente
        const pendingSubmissionsData = await getPendingFormSubmissions();
        setPendingSubmissions(pendingSubmissionsData || []);
        
        // Générer des informations de débogage
        const pendingCount = pendingSubmissionsData ? pendingSubmissionsData.length : 0;
        const statusCounts = {};
        const withCommonToken = allSubmissions.filter(s => s.commonToken).length;
        const withoutCommonToken = allSubmissions.filter(s => !s.commonToken).length;
        
        allSubmissions.forEach(submission => {
          const status = submission.status || 'unknown';
          statusCounts[status] = (statusCounts[status] || 0) + 1;
        });
        
        const statusDistribution = Object.entries(statusCounts)
          .map(([status, count]) => `${status}: ${count}`)
          .join('\n');
        
        const debugText = `
Total des soumissions: ${allSubmissions.length}
Soumissions en attente: ${pendingCount}
Distribution des statuts:
${statusDistribution}
Avec token commun: ${withCommonToken}
Sans token commun: ${withoutCommonToken}
${pendingCount === 0 ? 'Aucune soumission en attente de validation.' : ''}
        `;
        
        setDebugInfo(debugText);
        setLoading(false);
      } catch (error) {
        console.error("Erreur lors du chargement des soumissions:", error);
        setLoading(false);
      }
    };

    fetchSubmissions();
  }, []);

  const handleValidateClick = (submission) => {
    setSelectedSubmission(submission);
    setShowComparisonModal(true);
  };

  const handleRejectSubmission = async (submissionId) => {
    try {
      const success = await updateFormSubmissionStatus(submissionId, 'rejected');
      if (success) {
        // Mettre à jour la liste des soumissions
        setPendingSubmissions(prevSubmissions => 
          prevSubmissions.filter(sub => sub.id !== submissionId)
        );
        
        // Mettre à jour la liste complète
        setSubmissions(prevSubmissions => 
          prevSubmissions.map(sub => 
            sub.id === submissionId ? { ...sub, status: 'rejected' } : sub
          )
        );
      }
    } catch (error) {
      console.error("Erreur lors du rejet de la soumission:", error);
    }
  };

  const closeComparisonModal = () => {
    setShowComparisonModal(false);
    setSelectedSubmission(null);
  };

  const handleValidationComplete = () => {
    // Rafraîchir les données après validation
    closeComparisonModal();
    
    // Mettre à jour la liste des soumissions en attente
    setPendingSubmissions(prevSubmissions => 
      prevSubmissions.filter(sub => sub.id !== selectedSubmission.id)
    );
    
    // Mettre à jour la liste complète
    setSubmissions(prevSubmissions => 
      prevSubmissions.map(sub => 
        sub.id === selectedSubmission.id ? { ...sub, status: 'validated' } : sub
      )
    );
  };

  if (loading) {
    return <div className="loading">Chargement des soumissions...</div>;
  }

  return (
    <div className="form-validation-container">
      <h1>Validation des formulaires</h1>
      
      <div className="debug-info">
        <h3>Informations de débogage</h3>
        <pre>{debugInfo}</pre>
      </div>
      
      <div className="pending-submissions">
        <h2>Soumissions en attente de validation</h2>
        
        {pendingSubmissions.length > 0 ? (
          <table className="submissions-table">
            <thead>
              <tr>
                <th>Date</th>
                <th>Nom</th>
                <th>Prénom</th>
                <th>Structure</th>
                <th>Email</th>
                <th>Téléphone</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {pendingSubmissions.map((submission) => (
                <tr key={submission.id}>
                  <td>{submission.createdAt ? new Date(submission.createdAt.seconds * 1000).toLocaleDateString() : 'N/A'}</td>
                  <td>{submission.lastName || 'N/A'}</td>
                  <td>{submission.firstName || 'N/A'}</td>
                  <td>{submission.organization || 'N/A'}</td>
                  <td>{submission.email || 'N/A'}</td>
                  <td>{submission.phone || 'N/A'}</td>
                  <td className="action-buttons">
                    <button 
                      className="validate-btn"
                      onClick={() => handleValidateClick(submission)}
                    >
                      Valider
                    </button>
                    <button 
                      className="reject-btn"
                      onClick={() => handleRejectSubmission(submission.id)}
                    >
                      Rejeter
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        ) : (
          <p className="no-submissions">Aucune soumission en attente de validation.</p>
        )}
      </div>
      
      {showComparisonModal && selectedSubmission && (
        <div className="modal-overlay">
          <div className="comparison-modal">
            <button className="close-modal" onClick={closeComparisonModal}>×</button>
            <h2>Validation des données</h2>
            <ComparisonTable 
              submission={selectedSubmission} 
              onValidationComplete={handleValidationComplete}
            />
          </div>
        </div>
      )}
    </div>
  );
};

export default FormValidationList;
