import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { getFormSubmissions, updateFormSubmission } from '../../services/formSubmissionsService';
import { getProgrammerById, updateProgrammer } from '../../services/programmersService';
import ComparisonTable from "./ComparisonTable";
import './FormValidationList.css';

const FormValidationList = () => {
  const [formSubmissions, setFormSubmissions] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [selectedForm, setSelectedForm] = useState(null);
  const [showModal, setShowModal] = useState(false);
  const [showComparisonTable, setShowComparisonTable] = useState(false);
  const [programmerData, setProgrammerData] = useState(null);
  const [processingAction, setProcessingAction] = useState(false);

  useEffect(() => {
    const fetchFormSubmissions = async () => {
      try {
        setLoading(true);
        const data = await getFormSubmissions();
        setFormSubmissions(data);
        setLoading(false);
      } catch (err) {
        console.error("Erreur lors de la récupération des formulaires:", err);
        setError(err.message);
        setLoading(false);
      }
    };

    fetchFormSubmissions();
  }, []);

  const handleViewForm = (form) => {
    setSelectedForm(form);
    setShowModal(true);
  };

  const closeModal = () => {
    setSelectedForm(null);
    setShowModal(false);
    setShowComparisonTable(false);
    setProgrammerData(null);
  };
  
  const handleShowComparisonTable = async (form) => {
    try {
      setProcessingAction(true);
      
      // Récupérer les données du programmateur
      if (form.programmerId) {
        const programmer = await getProgrammerById(form.programmerId);
        if (programmer) {
          setProgrammerData(programmer);
          setShowComparisonTable(true);
          setShowModal(false);
        } else {
          alert("Impossible de récupérer les données du programmateur.");
        }
      } else {
        alert("Ce formulaire n'est pas associé à un programmateur existant.");
      }
      
      setProcessingAction(false);
    } catch (err) {
      console.error("Erreur lors de la récupération des données du programmateur:", err);
      setError(err.message);
      setProcessingAction(false);
      alert(`Erreur: ${err.message}`);
    }
  };

  const formatDate = (timestamp) => {
    if (!timestamp) return 'Date inconnue';
    
    const date = timestamp instanceof Date 
      ? timestamp 
      : new Date(timestamp.seconds ? timestamp.seconds * 1000 : timestamp);
    
    return date.toLocaleDateString('fr-FR', {
      day: '2-digit',
      month: '2-digit',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });
  };

  const handleIntegrateData = async (formData, programmerId) => {
    try {
      setProcessingAction(true);
      
      // 1. Récupérer les données actuelles du programmateur
      const programmer = await getProgrammerById(programmerId);
      
      if (!programmer) {
        throw new Error('Programmateur non trouvé');
      }
      
      // 2. Préparer les données à mettre à jour
      const updatedData = {
        ...programmer,
        businessName: formData.businessName || programmer.businessName,
        contact: formData.contact || programmer.contact,
        role: formData.role || programmer.role,
        address: formData.address || programmer.address,
        venue: formData.venue || programmer.venue,
        vatNumber: formData.vatNumber || programmer.vatNumber,
        siret: formData.siret || programmer.siret,
        email: formData.email || programmer.email,
        phone: formData.phone || programmer.phone,
        website: formData.website || programmer.website
      };
      
      // 3. Mettre à jour le programmateur
      await updateProgrammer(programmerId, updatedData);
      
      // 4. Marquer le formulaire comme traité
      await updateFormSubmission(formData.id, {
        status: 'processed',
        processedAt: new Date()
      });
      
      // 5. Mettre à jour l'état local
      setFormSubmissions(prevForms => 
        prevForms.map(form => 
          form.id === formData.id 
            ? { ...form, status: 'processed', processedAt: new Date() } 
            : form
        )
      );
      
      // 6. Fermer le modal
      closeModal();
      setProcessingAction(false);
      
      // Afficher un message de succès
      alert('Les données ont été intégrées avec succès à la fiche du programmateur.');
      
    } catch (err) {
      console.error("Erreur lors de l'intégration des données:", err);
      setError(err.message);
      setProcessingAction(false);
      alert(`Erreur lors de l'intégration des données: ${err.message}`);
    }
  };

  const handleRejectForm = async (formId) => {
    try {
      setProcessingAction(true);
      
      // Marquer le formulaire comme rejeté
      await updateFormSubmission(formId, {
        status: 'rejected',
        processedAt: new Date()
      });
      
      // Mettre à jour l'état local
      setFormSubmissions(prevForms => 
        prevForms.map(form => 
          form.id === formId 
            ? { ...form, status: 'rejected', processedAt: new Date() } 
            : form
        )
      );
      
      // Fermer le modal
      closeModal();
      setProcessingAction(false);
      
      // Afficher un message de succès
      alert('Le formulaire a été rejeté.');
      
    } catch (err) {
      console.error("Erreur lors du rejet du formulaire:", err);
      setError(err.message);
      setProcessingAction(false);
      alert(`Erreur lors du rejet du formulaire: ${err.message}`);
    }
  };

  if (loading) return <div className="loading">Chargement des formulaires...</div>;
  if (error) return <div className="error-message">Erreur: {error}</div>;

  return (
    <div className="form-validation-container">
      <div className="form-validation-header">
        <h2>Validation des Formulaires</h2>
        <div className="header-actions">
          <button 
            className="refresh-button"
            onClick={() => window.location.reload()}
          >
            <i className="fas fa-sync-alt"></i> Rafraîchir
          </button>
        </div>
      </div>
      
      {formSubmissions.length === 0 ? (
        <p className="no-results">Aucun formulaire en attente de validation.</p>
      ) : (
        <div className="form-submissions-table-container">
          <table className="form-submissions-table">
            <thead>
              <tr>
                <th>Date de soumission</th>
                <th>Programmateur</th>
                <th>Raison sociale</th>
                <th>Contact</th>
                <th>Statut</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {formSubmissions.map((form) => (
                <tr key={form.id} className={form.status === 'pending' ? 'pending-row' : ''}>
                  <td>{formatDate(form.submittedAt)}</td>
                  <td>{form.programmerId ? form.programmerName : 'Non associé'}</td>
                  <td>{form.businessName || 'Non spécifié'}</td>
                  <td>{form.contact || 'Non spécifié'}</td>
                  <td>
                    <span className={`status-badge status-${form.status}`}>
                      {form.status === 'pending' && 'En attente'}
                      {form.status === 'processed' && 'Traité'}
                      {form.status === 'rejected' && 'Rejeté'}
                    </span>
                  </td>
                  <td>
                    <button 
                      className="view-form-btn"
                      onClick={() => handleViewForm(form)}
                      disabled={form.status !== 'pending'}
                    >
                      <i className="fas fa-eye"></i> Voir
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
      
      {/* Modal pour afficher les détails du formulaire */}
      {showModal && selectedForm && (
        <div className="form-modal-overlay">
          <div className="form-modal">
            <div className="form-modal-header">
              <h3>Détails du formulaire</h3>
              <button className="close-modal-btn" onClick={closeModal}>
                <i className="fas fa-times"></i>
              </button>
            </div>
            
            <div className="form-modal-content">
              <div className="form-data-section">
                <h4>Informations soumises</h4>
                
                <div className="form-data-grid">
                  <div className="form-data-item">
                    <span className="form-data-label">Raison sociale:</span>
                    <span className="form-data-value">{selectedForm.businessName || 'Non spécifié'}</span>
                  </div>
                  
                  <div className="form-data-item">
                    <span className="form-data-label">Contact:</span>
                    <span className="form-data-value">{selectedForm.contact || 'Non spécifié'}</span>
                  </div>
                  
                  <div className="form-data-item">
                    <span className="form-data-label">Qualité:</span>
                    <span className="form-data-value">{selectedForm.role || 'Non spécifié'}</span>
                  </div>
                  
                  <div className="form-data-item">
                    <span className="form-data-label">Adresse:</span>
                    <span className="form-data-value">{selectedForm.address || 'Non spécifié'}</span>
                  </div>
                  
                  <div className="form-data-item">
                    <span className="form-data-label">Lieu/Festival:</span>
                    <span className="form-data-value">{selectedForm.venue || 'Non spécifié'}</span>
                  </div>
                  
                  <div className="form-data-item">
                    <span className="form-data-label">N° intracommunautaire:</span>
                    <span className="form-data-value">{selectedForm.vatNumber || 'Non spécifié'}</span>
                  </div>
                  
                  <div className="form-data-item">
                    <span className="form-data-label">SIRET:</span>
                    <span className="form-data-value">{selectedForm.siret || 'Non spécifié'}</span>
                  </div>
                  
                  <div className="form-data-item">
                    <span className="form-data-label">Email:</span>
                    <span className="form-data-value">{selectedForm.email || 'Non spécifié'}</span>
                  </div>
                  
                  <div className="form-data-item">
                    <span className="form-data-label">Téléphone:</span>
                    <span className="form-data-value">{selectedForm.phone || 'Non spécifié'}</span>
                  </div>
                  
                  <div className="form-data-item">
                    <span className="form-data-label">Site web:</span>
                    <span className="form-data-value">
                      {selectedForm.website ? (
                        <a href={selectedForm.website} target="_blank" rel="noopener noreferrer">
                          {selectedForm.website}
                        </a>
                      ) : 'Non spécifié'}
                    </span>
                  </div>
                  
                  {selectedForm.commonToken && (
                    <div className="form-data-item">
                      <span className="form-data-label">Token commun:</span>
                      <span className="form-data-value">{selectedForm.commonToken}</span>
                    </div>
                  )}
                </div>
              </div>
              
              {selectedForm.programmerId && (
                <div className="form-actions-section">
                  <h4>Actions</h4>
                  <div className="form-action-buttons">
                    <button 
                      className="compare-data-btn"
                      onClick={() => handleShowComparisonTable(selectedForm)}
                      disabled={processingAction}
                    >
                      {processingAction ? 'Chargement...' : 'Comparer et intégrer les données'}
                    </button>
                    <button 
                      className="reject-form-btn"
                      onClick={() => handleRejectForm(selectedForm.id)}
                      disabled={processingAction}
                    >
                      {processingAction ? 'Traitement...' : 'Rejeter le formulaire'}
                    </button>
                  </div>
                </div>
              )}
              
              {!selectedForm.programmerId && (
                <div className="form-warning-section">
                  <p className="warning-text">
                    <i className="fas fa-exclamation-triangle"></i>
                    Ce formulaire n'est pas associé à un programmateur existant.
                  </p>
                </div>
              )}
            </div>
          </div>
        </div>
      )}
      
      {/* Tableau de comparaison */}
      {showComparisonTable && selectedForm && programmerData && (
        <div className="form-modal-overlay">
          <ComparisonTable 
            formData={selectedForm}
            programmer={programmerData}
            onClose={closeModal}
            onSuccess={() => {
              // Rafraîchir la liste des formulaires après une intégration réussie
              setFormSubmissions(prevForms => 
                prevForms.map(form => 
                  form.id === selectedForm.id 
                    ? { ...form, status: "processed", processedAt: new Date() } 
                    : form
                )
              );
              closeModal();
              alert("Les données ont été intégrées avec succès à la fiche du programmateur.");
            }}
          />
        </div>
      )}
    </div>
  );
};

export default FormValidationList;
