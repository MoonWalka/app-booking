import React, { useState } from 'react';
import { updateProgrammer } from '../../services/programmersService';
import { updateFormSubmission } from '../../services/formSubmissionsService';


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
