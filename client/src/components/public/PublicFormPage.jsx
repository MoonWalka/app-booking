import React, { useState, useEffect } from 'react';
import { useLocation } from 'react-router-dom';
import { createFormSubmission } from '../../services/formSubmissionsService';


const PublicFormPage = () => {
  const location = useLocation();
  const [formData, setFormData] = useState({
    firstName: '',
    lastName: '',
    organization: '',
    position: '',
    email: '',
    phone: '',
    address: '',
    postalCode: '',
    city: '',
    country: 'France',
    website: '',
    vatNumber: '',
    siret: '',
    notes: ''
  });
  const [loading, setLoading] = useState(false);
  const [submitted, setSubmitted] = useState(false);
  const [error, setError] = useState('');
  const [commonToken, setCommonToken] = useState('');

  useEffect(() => {
    // Extraire le token commun de l'URL
    const params = new URLSearchParams(location.search);
    const token = params.get('token');
    if (token) {
      setCommonToken(token);
    }
  }, [location]);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prevData => ({
      ...prevData,
      [name]: value
    }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    try {
      setLoading(true);
      setError('');
      
      // Ajouter le token commun aux données du formulaire
      const submissionData = {
        ...formData,
        commonToken: commonToken || null,
        status: 'pending',
        createdAt: new Date()
      };
      
      // Envoyer les données à Firebase
      await createFormSubmission(submissionData);
      
      // Réinitialiser le formulaire et afficher un message de succès
      setFormData({
        firstName: '',
        lastName: '',
        organization: '',
        position: '',
        email: '',
        phone: '',
        address: '',
        postalCode: '',
        city: '',
        country: 'France',
        website: '',
        vatNumber: '',
        siret: '',
        notes: ''
      });
      
      setSubmitted(true);
      setLoading(false);
    } catch (error) {
      console.error("Erreur lors de la soumission du formulaire:", error);
      setError("Une erreur s'est produite lors de la soumission du formulaire. Veuillez réessayer.");
      setLoading(false);
    }
  };

  return (
    <div className="public-form-container">
      <div className="form-header">
        <h1>Formulaire de renseignements</h1>
        <p>Merci de compléter ce formulaire pour nous permettre de préparer votre contrat.</p>
      </div>
      
      {submitted ? (
        <div className="success-message">
          <h2>Formulaire envoyé avec succès !</h2>
          <p>Nous avons bien reçu vos informations et nous les traiterons dans les plus brefs délais.</p>
          <button 
            className="new-form-btn"
            onClick={() => setSubmitted(false)}
          >
            Remplir un nouveau formulaire
          </button>
        </div>
      ) : (
        <form onSubmit={handleSubmit} className="public-form">
          {error && <div className="error-message">{error}</div>}
          
          <div className="form-section">
            <h2>Informations personnelles</h2>
            
            <div className="form-row">
              <div className="form-group">
                <label htmlFor="firstName">Prénom *</label>
                <input
                  type="text"
                  id="firstName"
                  name="firstName"
                  value={formData.firstName}
                  onChange={handleChange}
                  required
                />
              </div>
              
              <div className="form-group">
                <label htmlFor="lastName">Nom *</label>
                <input
                  type="text"
                  id="lastName"
                  name="lastName"
                  value={formData.lastName}
                  onChange={handleChange}
                  required
                />
              </div>
            </div>
            
            <div className="form-row">
              <div className="form-group">
                <label htmlFor="organization">Structure / Organisation *</label>
                <input
                  type="text"
                  id="organization"
                  name="organization"
                  value={formData.organization}
                  onChange={handleChange}
                  required
                />
              </div>
              
              <div className="form-group">
                <label htmlFor="position">Fonction</label>
                <input
                  type="text"
                  id="position"
                  name="position"
                  value={formData.position}
                  onChange={handleChange}
                />
              </div>
            </div>
          </div>
          
          <div className="form-section">
            <h2>Coordonnées</h2>
            
            <div className="form-row">
              <div className="form-group">
                <label htmlFor="email">Email *</label>
                <input
                  type="email"
                  id="email"
                  name="email"
                  value={formData.email}
                  onChange={handleChange}
                  required
                />
              </div>
              
              <div className="form-group">
                <label htmlFor="phone">Téléphone *</label>
                <input
                  type="tel"
                  id="phone"
                  name="phone"
                  value={formData.phone}
                  onChange={handleChange}
                  required
                />
              </div>
            </div>
            
            <div className="form-group full-width">
              <label htmlFor="address">Adresse</label>
              <input
                type="text"
                id="address"
                name="address"
                value={formData.address}
                onChange={handleChange}
              />
            </div>
            
            <div className="form-row">
              <div className="form-group">
                <label htmlFor="postalCode">Code postal</label>
                <input
                  type="text"
                  id="postalCode"
                  name="postalCode"
                  value={formData.postalCode}
                  onChange={handleChange}
                />
              </div>
              
              <div className="form-group">
                <label htmlFor="city">Ville</label>
                <input
                  type="text"
                  id="city"
                  name="city"
                  value={formData.city}
                  onChange={handleChange}
                />
              </div>
            </div>
            
            <div className="form-row">
              <div className="form-group">
                <label htmlFor="country">Pays</label>
                <input
                  type="text"
                  id="country"
                  name="country"
                  value={formData.country}
                  onChange={handleChange}
                />
              </div>
              
              <div className="form-group">
                <label htmlFor="website">Site web</label>
                <input
                  type="url"
                  id="website"
                  name="website"
                  value={formData.website}
                  onChange={handleChange}
                />
              </div>
            </div>
          </div>
          
          <div className="form-section">
            <h2>Informations administratives</h2>
            
            <div className="form-row">
              <div className="form-group">
                <label htmlFor="vatNumber">Numéro de TVA intracommunautaire</label>
                <input
                  type="text"
                  id="vatNumber"
                  name="vatNumber"
                  value={formData.vatNumber}
                  onChange={handleChange}
                />
              </div>
              
              <div className="form-group">
                <label htmlFor="siret">Numéro SIRET</label>
                <input
                  type="text"
                  id="siret"
                  name="siret"
                  value={formData.siret}
                  onChange={handleChange}
                />
              </div>
            </div>
          </div>
          
          <div className="form-section">
            <h2>Informations complémentaires</h2>
            
            <div className="form-group full-width">
              <label htmlFor="notes">Notes ou commentaires</label>
              <textarea
                id="notes"
                name="notes"
                value={formData.notes}
                onChange={handleChange}
                rows="4"
              ></textarea>
            </div>
          </div>
          
          <div className="form-actions">
            <button 
              type="submit" 
              className="submit-btn"
              disabled={loading}
            >
              {loading ? 'Envoi en cours...' : 'Envoyer le formulaire'}
            </button>
          </div>
        </form>
      )}
    </div>
  );
};

export default PublicFormPage;
