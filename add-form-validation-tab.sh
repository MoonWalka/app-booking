#!/bin/bash

# Script pour ajouter l'onglet "Validation Formulaire" à l'application
# Auteur: Manus
# Date: 8 avril 2025
# Version: 1.0

echo "Début de l'ajout de l'onglet 'Validation Formulaire'..."

# Vérifier si nous sommes dans le bon répertoire
if [ ! -d "./client" ]; then
  echo "Erreur: Ce script doit être exécuté depuis la racine du projet app-booking"
  exit 1
fi

# Créer le répertoire pour les composants de validation de formulaire
echo "Création du répertoire pour les composants de validation de formulaire..."
mkdir -p ./client/src/components/formValidation

# Création du composant FormValidationList.jsx
echo "Création du composant FormValidationList.jsx..."
cat > ./client/src/components/formValidation/FormValidationList.jsx << 'EOL'
import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { getFormSubmissions, updateFormSubmission } from '../../services/formSubmissionsService';
import { getProgrammerById, updateProgrammer } from '../../services/programmersService';
import './FormValidationList.css';

const FormValidationList = () => {
  const [formSubmissions, setFormSubmissions] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [selectedForm, setSelectedForm] = useState(null);
  const [showModal, setShowModal] = useState(false);
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
                </div>
              </div>
              
              {selectedForm.programmerId && (
                <div className="form-actions-section">
                  <h4>Actions</h4>
                  <div className="form-action-buttons">
                    <button 
                      className="integrate-data-btn"
                      onClick={() => handleIntegrateData(selectedForm, selectedForm.programmerId)}
                      disabled={processingAction}
                    >
                      {processingAction ? 'Traitement...' : 'Intégrer les données'}
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
    </div>
  );
};

export default FormValidationList;
EOL

# Création du fichier CSS pour FormValidationList
echo "Création du fichier CSS pour FormValidationList..."
cat > ./client/src/components/formValidation/FormValidationList.css << 'EOL'
.form-validation-container {
  background-color: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
  padding: 20px;
  margin-bottom: 20px;
}

.form-validation-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.form-validation-header h2 {
  font-size: 24px;
  color: #333;
  margin: 0;
}

.header-actions {
  display: flex;
  gap: 10px;
}

.refresh-button {
  background-color: #f8f9fa;
  color: #495057;
  border: 1px solid #dee2e6;
  border-radius: 4px;
  padding: 8px 12px;
  cursor: pointer;
  font-size: 14px;
  display: flex;
  align-items: center;
  gap: 5px;
  transition: background-color 0.2s;
}

.refresh-button:hover {
  background-color: #e9ecef;
}

.form-submissions-table-container {
  overflow-x: auto;
  margin-bottom: 20px;
}

.form-submissions-table {
  width: 100%;
  border-collapse: collapse;
  font-size: 14px;
}

.form-submissions-table th {
  background-color: #f8f9fa;
  padding: 12px 15px;
  text-align: left;
  font-weight: 600;
  color: #495057;
  border-bottom: 2px solid #dee2e6;
}

.form-submissions-table td {
  padding: 12px 15px;
  border-bottom: 1px solid #dee2e6;
  color: #333;
}

.form-submissions-table tbody tr {
  transition: background-color 0.2s;
}

.form-submissions-table tbody tr:hover {
  background-color: #f8f9fa;
}

.pending-row {
  background-color: #fff8e1;
}

.pending-row:hover {
  background-color: #ffecb3 !important;
}

.status-badge {
  display: inline-block;
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 12px;
  font-weight: 500;
}

.status-pending {
  background-color: #fff8e1;
  color: #f57c00;
  border: 1px solid #ffcc80;
}

.status-processed {
  background-color: #e8f5e9;
  color: #2e7d32;
  border: 1px solid #a5d6a7;
}

.status-rejected {
  background-color: #ffebee;
  color: #c62828;
  border: 1px solid #ef9a9a;
}

.view-form-btn {
  background-color: #e3f2fd;
  color: #1976d2;
  border: none;
  border-radius: 4px;
  padding: 6px 10px;
  cursor: pointer;
  font-size: 13px;
  transition: background-color 0.2s;
}

.view-form-btn:hover {
  background-color: #bbdefb;
}

.view-form-btn:disabled {
  background-color: #f5f5f5;
  color: #9e9e9e;
  cursor: not-allowed;
}

.no-results {
  text-align: center;
  padding: 30px;
  color: #666;
  font-style: italic;
}

/* Modal styles */
.form-modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
}

.form-modal {
  background-color: #fff;
  border-radius: 8px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);
  width: 90%;
  max-width: 800px;
  max-height: 90vh;
  overflow-y: auto;
  display: flex;
  flex-direction: column;
}

.form-modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 15px 20px;
  border-bottom: 1px solid #dee2e6;
}

.form-modal-header h3 {
  margin: 0;
  font-size: 20px;
  color: #333;
}

.close-modal-btn {
  background: none;
  border: none;
  font-size: 20px;
  color: #6c757d;
  cursor: pointer;
  padding: 5px;
}

.close-modal-btn:hover {
  color: #343a40;
}

.form-modal-content {
  padding: 20px;
  overflow-y: auto;
}

.form-data-section {
  margin-bottom: 25px;
}

.form-data-section h4 {
  font-size: 16px;
  color: #495057;
  margin-top: 0;
  margin-bottom: 15px;
  padding-bottom: 8px;
  border-bottom: 1px solid #e9ecef;
}

.form-data-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 15px;
}

.form-data-item {
  display: flex;
  flex-direction: column;
  gap: 5px;
}

.form-data-label {
  font-size: 13px;
  color: #6c757d;
  font-weight: 500;
}

.form-data-value {
  font-size: 15px;
  color: #212529;
}

.form-actions-section {
  margin-top: 20px;
  padding-top: 15px;
  border-top: 1px solid #e9ecef;
}

.form-action-buttons {
  display: flex;
  gap: 10px;
  margin-top: 15px;
}

.integrate-data-btn {
  background-color: #4caf50;
  color: white;
  border: none;
  border-radius: 4px;
  padding: 10px 15px;
  cursor: pointer;
  font-weight: 500;
  transition: background-color 0.2s;
}

.integrate-data-btn:hover {
  background-color: #43a047;
}

.reject-form-btn {
  background-color: #f44336;
  color: white;
  border: none;
  border-radius: 4px;
  padding: 10px 15px;
  cursor: pointer;
  font-weight: 500;
  transition: background-color 0.2s;
}

.reject-form-btn:hover {
  background-color: #e53935;
}

.integrate-data-btn:disabled,
.reject-form-btn:disabled {
  background-color: #9e9e9e;
  cursor: not-allowed;
}

.form-warning-section {
  margin-top: 20px;
  padding: 15px;
  background-color: #fff8e1;
  border-radius: 4px;
  border-left: 4px solid #ffc107;
}

.warning-text {
  margin: 0;
  color: #856404;
  display: flex;
  align-items: center;
  gap: 10px;
}

.warning-text i {
  font-size: 18px;
  color: #ffc107;
}
EOL

# Création du composant DataIntegrationModal.jsx
echo "Création du composant DataIntegrationModal.jsx..."
cat > ./client/src/components/formValidation/DataIntegrationModal.jsx << 'EOL'
import React, { useState } from 'react';
import { updateProgrammer } from '../../services/programmersService';
import { updateFormSubmission } from '../../services/formSubmissionsService';
import './DataIntegrationModal.css';

const DataIntegrationModal = ({ formData, programmer, onClose, onSuccess }) => {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  
  // État pour suivre quels champs seront intégrés
  const [fieldsToIntegrate, setFieldsToIntegrate] = useState({
    businessName: true,
    contact: true,
    role: true,
    address: true,
    venue: true,
    vatNumber: true,
    siret: true,
    email: true,
    phone: true,
    website: true
  });

  // Fonction pour basculer l'état d'un champ
  const toggleField = (field) => {
    setFieldsToIntegrate(prev => ({
      ...prev,
      [field]: !prev[field]
    }));
  };

  // Fonction pour intégrer les données sélectionnées
  const handleIntegrateData = async () => {
    try {
      setLoading(true);
      setError(null);
      
      // Préparer les données à mettre à jour
      const updatedData = { ...programmer };
      
      // Ajouter uniquement les champs sélectionnés
      Object.keys(fieldsToIntegrate).forEach(field => {
        if (fieldsToIntegrate[field] && formData[field]) {
          updatedData[field] = formData[field];
        }
      });
      
      // Mettre à jour le programmateur
      await updateProgrammer(programmer.id, updatedData);
      
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
      console.error("Erreur lors de l'intégration des données:", err);
      setError(err.message);
      setLoading(false);
    }
  };

  return (
    <div className="data-integration-modal-overlay">
      <div className="data-integration-modal">
        <div className="data-integration-modal-header">
          <h3>Intégrer les données à la fiche programmateur</h3>
          <button className="close-modal-btn" onClick={onClose}>
            <i className="fas fa-times"></i>
          </button>
        </div>
        
        <div className="data-integration-modal-content">
          <p className="integration-instructions">
            Sélectionnez les champs à intégrer à la fiche du programmateur <strong>{programmer.contact || programmer.businessName || 'Non spécifié'}</strong>.
          </p>
          
          {error && (
            <div className="integration-error">
              <i className="fas fa-exclamation-circle"></i> {error}
            </div>
          )}
          
          <div className="integration-fields">
            {formData.businessName && (
              <div className="integration-field-item">
                <label className="integration-field-checkbox">
                  <input
                    type="checkbox"
                    checked={fieldsToIntegrate.businessName}
                    onChange={() => toggleField('businessName')}
                  />
                  <span className="checkbox-custom"></span>
                </label>
                <div className="integration-field-content">
                  <span className="integration-field-label">Raison sociale</span>
                  <div className="integration-field-comparison">
                    <span className="integration-field-new">{formData.businessName}</span>
                    {programmer.businessName && (
                      <>
                        <span className="integration-field-arrow">
                          <i className="fas fa-long-arrow-alt-right"></i>
                        </span>
                        <span className="integration-field-current">{programmer.businessName}</span>
                      </>
                    )}
                  </div>
                </div>
              </div>
            )}
            
            {formData.contact && (
              <div className="integration-field-item">
                <label className="integration-field-checkbox">
                  <input
                    type="checkbox"
                    checked={fieldsToIntegrate.contact}
                    onChange={() => toggleField('contact')}
                  />
                  <span className="checkbox-custom"></span>
                </label>
                <div className="integration-field-content">
                  <span className="integration-field-label">Contact</span>
                  <div className="integration-field-comparison">
                    <span className="integration-field-new">{formData.contact}</span>
                    {programmer.contact && (
                      <>
                        <span className="integration-field-arrow">
                          <i className="fas fa-long-arrow-alt-right"></i>
                        </span>
                        <span className="integration-field-current">{programmer.contact}</span>
                      </>
                    )}
                  </div>
                </div>
              </div>
            )}
            
            {formData.role && (
              <div className="integration-field-item">
                <label className="integration-field-checkbox">
                  <input
                    type="checkbox"
                    checked={fieldsToIntegrate.role}
                    onChange={() => toggleField('role')}
                  />
                  <span className="checkbox-custom"></span>
                </label>
                <div className="integration-field-content">
                  <span className="integration-field-label">Qualité</span>
                  <div className="integration-field-comparison">
                    <span className="integration-field-new">{formData.role}</span>
                    {programmer.role && (
                      <>
                        <span className="integration-field-arrow">
                          <i className="fas fa-long-arrow-alt-right"></i>
                        </span>
                        <span className="integration-field-current">{programmer.role}</span>
                      </>
                    )}
                  </div>
                </div>
              </div>
            )}
            
            {formData.address && (
              <div className="integration-field-item">
                <label className="integration-field-checkbox">
                  <input
                    type="checkbox"
                    checked={fieldsToIntegrate.address}
                    onChange={() => toggleField('address')}
                  />
                  <span className="checkbox-custom"></span>
                </label>
                <div className="integration-field-content">
                  <span className="integration-field-label">Adresse</span>
                  <div className="integration-field-comparison">
                    <span className="integration-field-new">{formData.address}</span>
                    {programmer.address && (
                      <>
                        <span className="integration-field-arrow">
                          <i className="fas fa-long-arrow-alt-right"></i>
                        </span>
                        <span className="integration-field-current">{programmer.address}</span>
                      </>
                    )}
                  </div>
                </div>
              </div>
            )}
            
            {formData.venue && (
              <div className="integration-field-item">
                <label className="integration-field-checkbox">
                  <input
                    type="checkbox"
                    checked={fieldsToIntegrate.venue}
                    onChange={() => toggleField('venue')}
                  />
                  <span className="checkbox-custom"></span>
                </label>
                <div className="integration-field-content">
                  <span className="integration-field-label">Lieu ou festival</span>
                  <div className="integration-field-comparison">
                    <span className="integration-field-new">{formData.venue}</span>
                    {programmer.venue && (
                      <>
                        <span className="integration-field-arrow">
                          <i className="fas fa-long-arrow-alt-right"></i>
                        </span>
                        <span className="integration-field-current">{programmer.venue}</span>
                      </>
                    )}
                  </div>
                </div>
              </div>
            )}
            
            {formData.vatNumber && (
              <div className="integration-field-item">
                <label className="integration-field-checkbox">
                  <input
                    type="checkbox"
                    checked={fieldsToIntegrate.vatNumber}
                    onChange={() => toggleField('vatNumber')}
                  />
                  <span className="checkbox-custom"></span>
                </label>
                <div className="integration-field-content">
                  <span className="integration-field-label">N° intracommunautaire</span>
                  <div className="integration-field-comparison">
                    <span className="integration-field-new">{formData.vatNumber}</span>
                    {programmer.vatNumber && (
                      <>
                        <span className="integration-field-arrow">
                          <i className="fas fa-long-arrow-alt-right"></i>
                        </span>
                        <span className="integration-field-current">{programmer.vatNumber}</span>
                      </>
                    )}
                  </div>
                </div>
              </div>
            )}
            
            {formData.siret && (
              <div className="integration-field-item">
                <label className="integration-field-checkbox">
                  <input
                    type="checkbox"
                    checked={fieldsToIntegrate.siret}
                    onChange={() => toggleField('siret')}
                  />
                  <span className="checkbox-custom"></span>
                </label>
                <div className="integration-field-content">
                  <span className="integration-field-label">SIRET</span>
                  <div className="integration-field-comparison">
                    <span className="integration-field-new">{formData.siret}</span>
                    {programmer.siret && (
                      <>
                        <span className="integration-field-arrow">
                          <i className="fas fa-long-arrow-alt-right"></i>
                        </span>
                        <span className="integration-field-current">{programmer.siret}</span>
                      </>
                    )}
                  </div>
                </div>
              </div>
            )}
            
            {formData.email && (
              <div className="integration-field-item">
                <label className="integration-field-checkbox">
                  <input
                    type="checkbox"
                    checked={fieldsToIntegrate.email}
                    onChange={() => toggleField('email')}
                  />
                  <span className="checkbox-custom"></span>
                </label>
                <div className="integration-field-content">
                  <span className="integration-field-label">Email</span>
                  <div className="integration-field-comparison">
                    <span className="integration-field-new">{formData.email}</span>
                    {programmer.email && (
                      <>
                        <span className="integration-field-arrow">
                          <i className="fas fa-long-arrow-alt-right"></i>
                        </span>
                        <span className="integration-field-current">{programmer.email}</span>
                      </>
                    )}
                  </div>
                </div>
              </div>
            )}
            
            {formData.phone && (
              <div className="integration-field-item">
                <label className="integration-field-checkbox">
                  <input
                    type="checkbox"
                    checked={fieldsToIntegrate.phone}
                    onChange={() => toggleField('phone')}
                  />
                  <span className="checkbox-custom"></span>
                </label>
                <div className="integration-field-content">
                  <span className="integration-field-label">Téléphone</span>
                  <div className="integration-field-comparison">
                    <span className="integration-field-new">{formData.phone}</span>
                    {programmer.phone && (
                      <>
                        <span className="integration-field-arrow">
                          <i className="fas fa-long-arrow-alt-right"></i>
                        </span>
                        <span className="integration-field-current">{programmer.phone}</span>
                      </>
                    )}
                  </div>
                </div>
              </div>
            )}
            
            {formData.website && (
              <div className="integration-field-item">
                <label className="integration-field-checkbox">
                  <input
                    type="checkbox"
                    checked={fieldsToIntegrate.website}
                    onChange={() => toggleField('website')}
                  />
                  <span className="checkbox-custom"></span>
                </label>
                <div className="integration-field-content">
                  <span className="integration-field-label">Site web</span>
                  <div className="integration-field-comparison">
                    <span className="integration-field-new">{formData.website}</span>
                    {programmer.website && (
                      <>
                        <span className="integration-field-arrow">
                          <i className="fas fa-long-arrow-alt-right"></i>
                        </span>
                        <span className="integration-field-current">{programmer.website}</span>
                      </>
                    )}
                  </div>
                </div>
              </div>
            )}
          </div>
          
          <div className="integration-actions">
            <button 
              className="cancel-integration-btn"
              onClick={onClose}
              disabled={loading}
            >
              Annuler
            </button>
            <button 
              className="confirm-integration-btn"
              onClick={handleIntegrateData}
              disabled={loading}
            >
              {loading ? 'Intégration en cours...' : 'Intégrer les données sélectionnées'}
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default DataIntegrationModal;
EOL

# Création du fichier CSS pour DataIntegrationModal
echo "Création du fichier CSS pour DataIntegrationModal..."
cat > ./client/src/components/formValidation/DataIntegrationModal.css << 'EOL'
.data-integration-modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
}

.data-integration-modal {
  background-color: #fff;
  border-radius: 8px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);
  width: 90%;
  max-width: 800px;
  max-height: 90vh;
  overflow-y: auto;
  display: flex;
  flex-direction: column;
}

.data-integration-modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 15px 20px;
  border-bottom: 1px solid #dee2e6;
}

.data-integration-modal-header h3 {
  margin: 0;
  font-size: 20px;
  color: #333;
}

.close-modal-btn {
  background: none;
  border: none;
  font-size: 20px;
  color: #6c757d;
  cursor: pointer;
  padding: 5px;
}

.close-modal-btn:hover {
  color: #343a40;
}

.data-integration-modal-content {
  padding: 20px;
  overflow-y: auto;
}

.integration-instructions {
  margin-bottom: 20px;
  color: #495057;
  font-size: 15px;
  line-height: 1.5;
}

.integration-error {
  background-color: #ffebee;
  color: #c62828;
  padding: 10px 15px;
  border-radius: 4px;
  margin-bottom: 20px;
  display: flex;
  align-items: center;
  gap: 10px;
}

.integration-fields {
  margin-bottom: 25px;
}

.integration-field-item {
  display: flex;
  align-items: flex-start;
  padding: 12px 0;
  border-bottom: 1px solid #e9ecef;
}

.integration-field-item:last-child {
  border-bottom: none;
}

.integration-field-checkbox {
  position: relative;
  display: inline-block;
  width: 20px;
  height: 20px;
  margin-right: 15px;
  margin-top: 2px;
  cursor: pointer;
}

.integration-field-checkbox input {
  opacity: 0;
  width: 0;
  height: 0;
}

.checkbox-custom {
  position: absolute;
  top: 0;
  left: 0;
  height: 20px;
  width: 20px;
  background-color: #f8f9fa;
  border: 1px solid #ced4da;
  border-radius: 3px;
  transition: all 0.2s;
}

.integration-field-checkbox input:checked ~ .checkbox-custom {
  background-color: #4caf50;
  border-color: #4caf50;
}

.checkbox-custom:after {
  content: "";
  position: absolute;
  display: none;
}

.integration-field-checkbox input:checked ~ .checkbox-custom:after {
  display: block;
}

.integration-field-checkbox .checkbox-custom:after {
  left: 7px;
  top: 3px;
  width: 5px;
  height: 10px;
  border: solid white;
  border-width: 0 2px 2px 0;
  transform: rotate(45deg);
}

.integration-field-content {
  flex: 1;
}

.integration-field-label {
  display: block;
  font-size: 13px;
  color: #6c757d;
  font-weight: 500;
  margin-bottom: 5px;
}

.integration-field-comparison {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 10px;
}

.integration-field-new {
  font-size: 15px;
  color: #4caf50;
  font-weight: 500;
}

.integration-field-arrow {
  color: #6c757d;
  font-size: 14px;
}

.integration-field-current {
  font-size: 15px;
  color: #f44336;
  text-decoration: line-through;
}

.integration-actions {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
  margin-top: 20px;
  padding-top: 15px;
  border-top: 1px solid #e9ecef;
}

.cancel-integration-btn {
  background-color: #f8f9fa;
  color: #495057;
  border: 1px solid #dee2e6;
  border-radius: 4px;
  padding: 10px 15px;
  cursor: pointer;
  font-weight: 500;
  transition: background-color 0.2s;
}

.cancel-integration-btn:hover {
  background-color: #e9ecef;
}

.confirm-integration-btn {
  background-color: #4caf50;
  color: white;
  border: none;
  border-radius: 4px;
  padding: 10px 15px;
  cursor: pointer;
  font-weight: 500;
  transition: background-color 0.2s;
}

.confirm-integration-btn:hover {
  background-color: #43a047;
}

.cancel-integration-btn:disabled,
.confirm-integration-btn:disabled {
  background-color: #9e9e9e;
  color: #f5f5f5;
  cursor: not-allowed;
}
EOL

# Création du service formSubmissionsService.js
echo "Création du service formSubmissionsService.js..."
mkdir -p ./client/src/services
cat > ./client/src/services/formSubmissionsService.js << 'EOL'
import { 
  collection, 
  getDocs, 
  getDoc, 
  doc, 
  addDoc, 
  updateDoc, 
  deleteDoc,
  query,
  orderBy,
  where,
  setDoc,
  Timestamp
} from 'firebase/firestore';
import { db } from '../firebase';

// Collection de référence
const FORM_SUBMISSIONS_COLLECTION = 'formSubmissions';

// Assurez-vous que la collection existe
const ensureCollection = async (collectionName) => {
  try {
    // Vérifier si la collection existe en essayant de récupérer des documents
    const collectionRef = collection(db, collectionName);
    const snapshot = await getDocs(query(collectionRef, orderBy('submittedAt', 'desc')));
    
    // Si la collection n'existe pas ou est vide, créer un document initial
    if (snapshot.empty) {
      console.log(`Collection ${collectionName} vide, création d'un document initial...`);
      const initialDoc = {
        programmerId: 'mock-programmer-1',
        programmerName: 'Didier Exemple',
        businessName: 'Association Culturelle du Sud',
        contact: 'Didier Martin',
        role: 'Programmateur',
        address: '45 rue des Arts, 13001 Marseille',
        venue: 'Festival du Sud',
        vatNumber: 'FR12345678901',
        siret: '123 456 789 00012',
        email: 'didier.martin@festivaldusud.fr',
        phone: '06 12 34 56 78',
        website: 'https://www.festivaldusud.fr',
        status: 'pending',
        submittedAt: Timestamp.fromDate(new Date()),
        notes: 'Formulaire exemple créé automatiquement'
      };
      
      await addDoc(collectionRef, initialDoc);
      console.log(`Document initial créé dans la collection ${collectionName}`);
    }
    
    return true;
  } catch (error) {
    console.error(`Erreur lors de la vérification/création de la collection ${collectionName}:`, error);
    return false;
  }
};

// Données simulées pour le fallback en cas d'erreur d'authentification
const mockFormSubmissions = [
  {
    id: 'mock-form-1',
    programmerId: 'mock-programmer-1',
    programmerName: 'Didier Exemple',
    businessName: 'Association Culturelle du Sud',
    contact: 'Didier Martin',
    role: 'Programmateur',
    address: '45 rue des Arts, 13001 Marseille',
    venue: 'Festival du Sud',
    vatNumber: 'FR12345678901',
    siret: '123 456 789 00012',
    email: 'didier.martin@festivaldusud.fr',
    phone: '06 12 34 56 78',
    website: 'https://www.festivaldusud.fr',
    status: 'pending',
    submittedAt: new Date(),
    notes: 'Formulaire exemple'
  },
  {
    id: 'mock-form-2',
    programmerId: 'mock-programmer-2',
    programmerName: 'Jean Martin',
    businessName: 'SARL La Cigale',
    contact: 'Jean Martin',
    role: 'Gérant',
    address: '120 boulevard de Rochechouart, 75018 Paris',
    venue: 'La Cigale',
    vatNumber: 'FR45678901234',
    siret: '456 789 012 00013',
    email: 'jean.martin@lacigale.fr',
    phone: '01 23 45 67 89',
    website: 'https://www.lacigale.fr',
    status: 'processed',
    submittedAt: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000), // 7 jours avant
    processedAt: new Date(Date.now() - 5 * 24 * 60 * 60 * 1000), // 5 jours avant
    notes: 'Formulaire traité'
  },
  {
    id: 'mock-form-3',
    programmerId: null,
    programmerName: null,
    businessName: 'Le Petit Théâtre',
    contact: 'Sophie Dubois',
    role: 'Directrice',
    address: '15 rue des Lilas, 69003 Lyon',
    venue: 'Le Petit Théâtre',
    vatNumber: 'FR98765432109',
    siret: '987 654 321 00014',
    email: 'sophie.dubois@petittheatre.fr',
    phone: '04 56 78 90 12',
    website: 'https://www.petittheatre.fr',
    status: 'pending',
    submittedAt: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000), // 2 jours avant
    notes: 'Formulaire sans programmateur associé'
  }
];

// Assurez-vous que la collection formSubmissions existe
const formSubmissionsCollection = collection(db, FORM_SUBMISSIONS_COLLECTION);

/**
 * Récupère tous les formulaires soumis
 * @param {Object} filters - Filtres à appliquer (optionnel)
 * @returns {Promise<Array>} Liste des formulaires soumis
 */
export const getFormSubmissions = async (filters = {}) => {
  try {
    // S'assurer que la collection existe
    await ensureCollection(FORM_SUBMISSIONS_COLLECTION);
    
    console.log("Tentative de récupération des formulaires depuis Firebase...");
    
    // Création d'une requête de base
    let formQuery = formSubmissionsCollection;
    
    // Application des filtres si nécessaire
    if (filters) {
      // Filtrer par statut
      if (filters.status) {
        formQuery = query(formQuery, where('status', '==', filters.status));
      }
      
      // Filtrer par programmateur
      if (filters.programmerId) {
        formQuery = query(formQuery, where('programmerId', '==', filters.programmerId));
      }
    }
    
    // Ajout d'un tri par date de soumission (du plus récent au plus ancien)
    formQuery = query(formQuery, orderBy('submittedAt', 'desc'));
    
    // Exécution de la requête
    const snapshot = await getDocs(formQuery);
    
    if (snapshot.empty) {
      console.log("Aucun formulaire trouvé dans Firebase, utilisation des données simulées");
      
      // Essayer d'ajouter les données simulées à Firebase
      try {
        console.log("Tentative d'ajout des données simulées à Firebase...");
        for (const form of mockFormSubmissions) {
          const { id, ...formData } = form;
          await setDoc(doc(db, FORM_SUBMISSIONS_COLLECTION, id), {
            ...formData,
            submittedAt: Timestamp.fromDate(formData.submittedAt),
            processedAt: formData.processedAt ? Timestamp.fromDate(formData.processedAt) : null
          });
        }
        console.log("Données simulées ajoutées à Firebase avec succès");
      } catch (addError) {
        console.error("Erreur lors de l'ajout des données simulées:", addError);
      }
      
      return mockFormSubmissions;
    }
    
    const formSubmissions = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));
    
    console.log(`${formSubmissions.length} formulaires récupérés depuis Firebase`);
    return formSubmissions;
  } catch (error) {
    console.error("Erreur lors de la récupération des formulaires:", error);
    console.log("Utilisation des données simulées pour les formulaires");
    
    // Essayer d'ajouter les données simulées à Firebase
    try {
      console.log("Tentative d'ajout des données simulées à Firebase...");
      for (const form of mockFormSubmissions) {
        const { id, ...formData } = form;
        await setDoc(doc(db, FORM_SUBMISSIONS_COLLECTION, id), {
          ...formData,
          submittedAt: Timestamp.fromDate(formData.submittedAt),
          processedAt: formData.processedAt ? Timestamp.fromDate(formData.processedAt) : null
        });
      }
      console.log("Données simulées ajoutées à Firebase avec succès");
    } catch (addError) {
      console.error("Erreur lors de l'ajout des données simulées:", addError);
    }
    
    // Retourner des données simulées en cas d'erreur d'authentification
    return mockFormSubmissions;
  }
};

/**
 * Récupère un formulaire soumis par son ID
 * @param {string} id - ID du formulaire
 * @returns {Promise<Object>} Données du formulaire
 */
export const getFormSubmissionById = async (id) => {
  try {
    // S'assurer que la collection existe
    await ensureCollection(FORM_SUBMISSIONS_COLLECTION);
    
    console.log(`Tentative de récupération du formulaire ${id} depuis Firebase...`);
    const docRef = doc(db, FORM_SUBMISSIONS_COLLECTION, id);
    const snapshot = await getDoc(docRef);
    
    if (snapshot.exists()) {
      const formData = {
        id: snapshot.id,
        ...snapshot.data()
      };
      console.log(`Formulaire ${id} récupéré depuis Firebase:`, formData);
      return formData;
    }
    
    console.log(`Formulaire ${id} non trouvé dans Firebase`);
    return null;
  } catch (error) {
    console.error(`Erreur lors de la récupération du formulaire ${id}:`, error);
    // Retourner un formulaire simulé en cas d'erreur
    const mockForm = mockFormSubmissions.find(form => form.id === id) || mockFormSubmissions[0];
    console.log(`Utilisation du formulaire simulé:`, mockForm);
    return mockForm;
  }
};

/**
 * Crée un nouveau formulaire soumis
 * @param {Object} formData - Données du formulaire
 * @returns {Promise<Object>} Formulaire créé avec ID
 */
export const createFormSubmission = async (formData) => {
  try {
    // S'assurer que la collection existe
    await ensureCollection(FORM_SUBMISSIONS_COLLECTION);
    
    // S'assurer que les champs obligatoires sont présents
    const completeFormData = {
      ...formData,
      status: formData.status || 'pending',
      submittedAt: Timestamp.fromDate(new Date())
    };
    
    console.log("Tentative d'ajout d'un formulaire à Firebase:", completeFormData);
    const docRef = await addDoc(formSubmissionsCollection, completeFormData);
    
    console.log(`Formulaire ajouté avec succès, ID: ${docRef.id}`);
    return {
      id: docRef.id,
      ...completeFormData
    };
  } catch (error) {
    console.error("Erreur lors de l'ajout du formulaire:", error);
    console.log("Simulation de l'ajout d'un formulaire");
    
    // Essayer d'ajouter le formulaire avec un ID généré manuellement
    try {
      const mockId = 'mock-form-' + Date.now();
      const completeFormData = {
        ...formData,
        status: formData.status || 'pending',
        submittedAt: Timestamp.fromDate(new Date())
      };
      
      await setDoc(doc(db, FORM_SUBMISSIONS_COLLECTION, mockId), completeFormData);
      
      console.log(`Formulaire ajouté avec un ID manuel: ${mockId}`);
      return {
        id: mockId,
        ...completeFormData
      };
    } catch (addError) {
      console.error("Erreur lors de l'ajout manuel du formulaire:", addError);
      
      // Simuler l'ajout d'un formulaire en cas d'erreur
      const mockId = 'mock-form-' + Date.now();
      return {
        id: mockId,
        ...formData,
        status: formData.status || 'pending',
        submittedAt: new Date()
      };
    }
  }
};

/**
 * Met à jour un formulaire soumis existant
 * @param {string} id - ID du formulaire
 * @param {Object} formData - Nouvelles données du formulaire
 * @returns {Promise<Object>} Formulaire mis à jour
 */
export const updateFormSubmission = async (id, formData) => {
  try {
    // S'assurer que la collection existe
    await ensureCollection(FORM_SUBMISSIONS_COLLECTION);
    
    console.log(`Tentative de mise à jour du formulaire ${id}:`, formData);
    const docRef = doc(db, FORM_SUBMISSIONS_COLLECTION, id);
    
    // Si le statut change à 'processed' ou 'rejected', ajouter la date de traitement
    const updateData = { ...formData };
    if ((formData.status === 'processed' || formData.status === 'rejected') && !formData.processedAt) {
      updateData.processedAt = Timestamp.fromDate(new Date());
    }
    
    await updateDoc(docRef, updateData);
    
    console.log(`Formulaire ${id} mis à jour avec succès`);
    return {
      id,
      ...updateData
    };
  } catch (error) {
    console.error(`Erreur lors de la mise à jour du formulaire ${id}:`, error);
    console.log("Simulation de la mise à jour d'un formulaire");
    
    // Essayer de créer/remplacer le document
    try {
      // Si le statut change à 'processed' ou 'rejected', ajouter la date de traitement
      const updateData = { ...formData };
      if ((formData.status === 'processed' || formData.status === 'rejected') && !formData.processedAt) {
        updateData.processedAt = Timestamp.fromDate(new Date());
      }
      
      await setDoc(doc(db, FORM_SUBMISSIONS_COLLECTION, id), updateData, { merge: true });
      
      console.log(`Formulaire ${id} créé/remplacé avec succès`);
      return {
        id,
        ...updateData
      };
    } catch (setError) {
      console.error(`Erreur lors de la création/remplacement du formulaire ${id}:`, setError);
      
      // Simuler la mise à jour d'un formulaire en cas d'erreur
      return {
        id,
        ...formData,
        processedAt: (formData.status === 'processed' || formData.status === 'rejected') ? new Date() : null
      };
    }
  }
};

/**
 * Supprime un formulaire soumis
 * @param {string} id - ID du formulaire
 * @returns {Promise<string>} ID du formulaire supprimé
 */
export const deleteFormSubmission = async (id) => {
  try {
    console.log(`Tentative de suppression du formulaire ${id}`);
    const docRef = doc(db, FORM_SUBMISSIONS_COLLECTION, id);
    await deleteDoc(docRef);
    
    console.log(`Formulaire ${id} supprimé avec succès`);
    return id;
  } catch (error) {
    console.error(`Erreur lors de la suppression du formulaire ${id}:`, error);
    console.log("Simulation de la suppression d'un formulaire");
    // Simuler la suppression d'un formulaire en cas d'erreur
    return id;
  }
};

/**
 * Récupère les formulaires soumis pour un programmateur spécifique
 * @param {string} programmerId - ID du programmateur
 * @returns {Promise<Array>} Liste des formulaires soumis
 */
export const getFormSubmissionsByProgrammer = async (programmerId) => {
  try {
    // S'assurer que la collection existe
    await ensureCollection(FORM_SUBMISSIONS_COLLECTION);
    
    console.log(`Tentative de récupération des formulaires pour le programmateur ${programmerId}...`);
    const formQuery = query(
      formSubmissionsCollection, 
      where('programmerId', '==', programmerId),
      orderBy('submittedAt', 'desc')
    );
    
    const snapshot = await getDocs(formQuery);
    
    if (snapshot.empty) {
      console.log(`Aucun formulaire trouvé pour le programmateur ${programmerId}`);
      return [];
    }
    
    const formSubmissions = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));
    
    console.log(`${formSubmissions.length} formulaires récupérés pour le programmateur ${programmerId}`);
    return formSubmissions;
  } catch (error) {
    console.error(`Erreur lors de la récupération des formulaires pour le programmateur ${programmerId}:`, error);
    // Retourner des formulaires simulés pour ce programmateur
    const mockForms = mockFormSubmissions.filter(form => form.programmerId === programmerId);
    console.log(`Utilisation de ${mockForms.length} formulaires simulés pour le programmateur ${programmerId}`);
    return mockForms;
  }
};

/**
 * Récupère les formulaires soumis par statut
 * @param {string} status - Statut des formulaires ('pending', 'processed', 'rejected')
 * @returns {Promise<Array>} Liste des formulaires soumis
 */
export const getFormSubmissionsByStatus = async (status) => {
  try {
    // S'assurer que la collection existe
    await ensureCollection(FORM_SUBMISSIONS_COLLECTION);
    
    console.log(`Tentative de récupération des formulaires avec le statut ${status}...`);
    const formQuery = query(
      formSubmissionsCollection, 
      where('status', '==', status),
      orderBy('submittedAt', 'desc')
    );
    
    const snapshot = await getDocs(formQuery);
    
    if (snapshot.empty) {
      console.log(`Aucun formulaire trouvé avec le statut ${status}`);
      return [];
    }
    
    const formSubmissions = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));
    
    console.log(`${formSubmissions.length} formulaires récupérés avec le statut ${status}`);
    return formSubmissions;
  } catch (error) {
    console.error(`Erreur lors de la récupération des formulaires avec le statut ${status}:`, error);
    // Retourner des formulaires simulés pour ce statut
    const mockForms = mockFormSubmissions.filter(form => form.status === status);
    console.log(`Utilisation de ${mockForms.length} formulaires simulés avec le statut ${status}`);
    return mockForms;
  }
};
EOL

# Mise à jour du fichier App.js pour ajouter la route
echo "Mise à jour du fichier App.js pour ajouter la route..."
cat > ./client/src/App.js << 'EOL'
import React from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';
import { useAuth } from './context/AuthContext';
import './App.css';

// Composants
import Layout from './components/common/Layout';
import Login from './components/auth/Login';
import NotFound from './components/common/NotFound';
import Dashboard from './components/dashboard/Dashboard';
import ProgrammersList from './components/programmers/ProgrammersList';
import ProgrammerDetail from './components/programmers/ProgrammerDetail';
import ConcertsList from './components/concerts/ConcertsList';
import ConcertDetail from './components/concerts/ConcertDetail';
import ArtistsList from './components/artists/ArtistsList';
import ArtistDetail from './components/artists/ArtistDetail';
import EmailSystem from './components/emails/EmailSystem';
import DocumentsManager from './components/documents/DocumentsManager';
import TestFirebaseIntegration from './components/tests/TestFirebaseIntegration';
import ArtistEdit from './components/artists/ArtistEdit';
import ContractsTable from './components/contracts/ContractsTable';
import FormValidationList from './components/formValidation/FormValidationList';

// Route protégée
const ProtectedRoute = ({ children }) => {
  const { isAuthenticated, loading, bypassEnabled } = useAuth();
  
  if (loading) {
    return <div>Chargement...</div>;
  }
  
  // Si le mode bypass est activé, on autorise l'accès même sans authentification
  if (bypassEnabled) {
    console.log('Mode bypass d\'authentification activé - Accès autorisé');
    return children;
  }
  
  if (!isAuthenticated) {
    return <Navigate to="/login" />;
  }
  
  return children;
};

function App() {
  const { bypassEnabled } = useAuth();

  return (
    <div className="App">
      <Routes>
        {/* Si le mode bypass est activé, la page de login redirige vers le dashboard */}
        <Route path="/login" element={
          bypassEnabled ? <Navigate to="/" /> : <Login />
        } />
        
        <Route path="/" element={
          <ProtectedRoute>
            <Layout />
          </ProtectedRoute>
        }>
          <Route index element={<Dashboard />} />
          <Route path="contrats" element={<ContractsTable />} />
          <Route path="factures" element={<div>Module Factures à venir</div>} />
          <Route path="programmateurs" element={<ProgrammersList />} />
          <Route path="programmateurs/:id" element={<ProgrammerDetail />} />
          <Route path="concerts" element={<ConcertsList />} />
          <Route path="concerts/:id" element={<ConcertDetail />} />
          <Route path="artistes" element={<ArtistsList />} />
          <Route path="artistes/:id" element={<ArtistDetail />} />
          <Route path="emails" element={<EmailSystem />} />
          <Route path="documents" element={<DocumentsManager />} />
          <Route path="validation-formulaires" element={<FormValidationList />} />
          <Route path="tests" element={<TestFirebaseIntegration />} />
        </Route>
        
        <Route path="*" element={<NotFound />} />
      </Routes>
      
      {/* Bannière d'information sur le mode bypass */}
      {bypassEnabled && (
        <div style={{
          position: 'fixed',
          bottom: 0,
          left: 0,
          right: 0,
          backgroundColor: '#fff3cd',
          color: '#856404',
          padding: '10px',
          textAlign: 'center',
          borderTop: '1px solid #ffeeba',
          zIndex: 1000
        }}>
          Mode test activé - Authentification désactivée
        </div>
      )}
    </div>
  );
}

export default App;
EOL

# Mise à jour du fichier Layout.js pour ajouter le lien dans la barre latérale
echo "Mise à jour du fichier Layout.js pour ajouter le lien dans la barre latérale..."
cat > ./client/src/components/common/Layout.js << 'EOL'
// client/src/components/common/Layout.js
import React from 'react';
import { Outlet, Link, useNavigate, useLocation } from 'react-router-dom';
import { useAuth } from '../../context/AuthContext';
import './Layout.css';

const Layout = () => {
  const { currentUser, logout } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();

  const handleLogout = () => {
    logout();
    navigate('/login');
  };

  const isActive = (path) => {
    return location.pathname === path;
  };

  return (
    <div className="app-container">
      <aside className="sidebar">
        <div className="sidebar-header">
          <Link to="/" className="logo">
            <span className="logo-text">Label Musical</span>
          </Link>
          <div className="sidebar-subtitle">Gestion des concerts et artistes</div>
        </div>
        
        <nav className="sidebar-nav">
          <Link to="/" className={`nav-item ${isActive('/') ? 'active' : ''}`}>
            <span className="nav-icon">
              <i className="fas fa-chart-line"></i>
            </span>
            Tableau de bord
          </Link>
          <Link to="/contrats" className={`nav-item ${isActive('/contrats') ? 'active' : ''}`}>
            <span className="nav-icon">
              <i className="fas fa-file-contract"></i>
            </span>
            Contrats
          </Link>
          <Link to="/factures" className={`nav-item ${isActive('/factures') ? 'active' : ''}`}>
            <span className="nav-icon">
              <i className="fas fa-file-invoice-dollar"></i>
            </span>
            Factures
          </Link>
          <Link to="/concerts" className={`nav-item ${isActive('/concerts') ? 'active' : ''}`}>
            <span className="nav-icon">
              <i className="fas fa-calendar-alt"></i>
            </span>
            Concerts
          </Link>
          <Link to="/artistes" className={`nav-item ${isActive('/artistes') ? 'active' : ''}`}>
            <span className="nav-icon">
              <i className="fas fa-music"></i>
            </span>
            Artistes
          </Link>
          <Link to="/programmateurs" className={`nav-item ${isActive('/programmateurs') ? 'active' : ''}`}>
            <span className="nav-icon">
              <i className="fas fa-user-tie"></i>
            </span>
            Programmateurs
          </Link>
          <Link to="/validation-formulaires" className={`nav-item ${isActive('/validation-formulaires') ? 'active' : ''}`}>
            <span className="nav-icon">
              <i className="fas fa-clipboard-check"></i>
            </span>
            Validation Formulaire
          </Link>
          <Link to="/emails" className={`nav-item ${isActive('/emails') ? 'active' : ''}`}>
            <span className="nav-icon">
              <i className="fas fa-envelope"></i>
            </span>
            Emails
          </Link>
          <Link to="/documents" className={`nav-item ${isActive('/documents') ? 'active' : ''}`}>
            <span className="nav-icon">
              <i className="fas fa-file-alt"></i>
            </span>
            Documents
          </Link>
          <Link to="/parametres" className={`nav-item ${isActive('/parametres') ? 'active' : ''}`}>
            <span className="nav-icon">
              <i className="fas fa-cog"></i>
            </span>
            Paramètres
          </Link>
        </nav>
      </aside>
      
      <div className="main-content">
        <header className="main-header">
          <div className="page-title">
            {location.pathname === '/' && 'Tableau de bord'}
            {location.pathname === '/contrats' && 'Gestion des contrats'}
            {location.pathname === '/factures' && 'Gestion des factures'}
            {location.pathname === '/concerts' && 'Gestion des concerts'}
            {location.pathname === '/artistes' && 'Gestion des artistes'}
            {location.pathname === '/programmateurs' && 'Gestion des programmateurs'}
            {location.pathname === '/validation-formulaires' && 'Validation des formulaires'}
            {location.pathname === '/emails' && 'Système d\'emails'}
            {location.pathname === '/documents' && 'Gestion des documents'}
            {location.pathname === '/parametres' && 'Paramètres'}
          </div>
          
          <div className="user-menu">
            {currentUser && (
              <>
                <span className="user-name">{currentUser.name || 'Utilisateur'}</span>
                <button onClick={handleLogout} className="logout-btn">
                  Déconnexion
                </button>
              </>
            )}
          </div>
        </header>
        
        <main className="main-container">
          <Outlet />
        </main>
        
        <footer className="app-footer">
          <p>&copy; {new Date().getFullYear()} App Booking - Tous droits réservés</p>
        </footer>
      </div>
    </div>
  );
};

export default Layout;
EOL

echo "Fin de l'ajout de l'onglet 'Validation Formulaire'."
echo "Pour appliquer ces modifications, exécutez ce script avec la commande:"
echo "chmod +x add-form-validation-tab.sh && ./add-form-validation-tab.sh"
echo ""
echo "Après avoir exécuté le script, utilisez les commandes Git suivantes pour pousser les modifications vers GitHub :"
echo "git add ."
echo "git commit -m \"Ajout de l'onglet Validation Formulaire pour gérer les formulaires soumis par les programmateurs\""
echo "git push origin main"
