import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { getFormLinkByToken } from '../../services/formLinkService';
import { createFormSubmission } from '../../services/formSubmissionsService';
import './PublicFormPage.css';

const PublicFormPage = () => {
  const { concertId } = useParams();
  const navigate = useNavigate();
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [formData, setFormData] = useState({
    businessName: '',      // Raison sociale
    firstName: '',         // Prénom
    lastName: '',          // Nom
    role: '',              // Qualité
    address: '',           // Adresse de la raison sociale
    venue: '',             // Lieu ou festival
    venueAddress: '',      // Adresse du lieu ou festival
    vatNumber: '',         // Numéro intracommunautaire
    siret: '',             // Siret
    email: '',             // Mail
    phone: '',             // Téléphone
    website: ''            // Site web
  });
  
  // Logs de débogage
  useEffect(() => {
    console.log('PublicFormPage - CHARGÉE AVEC:');
    console.log('PublicFormPage - concertId:', concertId);
    console.log('PublicFormPage - Hash brut:', window.location.hash);
    console.log('PublicFormPage - Hash nettoyé:', window.location.hash.replace(/^#/, ''));
    console.log('PublicFormPage - Pathname:', window.location.pathname);
    console.log('PublicFormPage - URL complète:', window.location.href);
  }, [concertId]);
  
  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
  };
  
  const handleSubmit = async (e) => {
    e.preventDefault();
    
    try {
      setLoading(true);
      console.log('Soumission du formulaire avec les données:', formData);
      
      // Préparer les données à soumettre
      const submissionData = {
        ...formData,
        concertId: concertId,
        // Ajouter des champs supplémentaires pour la compatibilité avec le service existant
        contact: formData.firstName && formData.lastName 
          ? `${formData.firstName} ${formData.lastName}` 
          : formData.firstName || formData.lastName || '',
        status: 'pending',
        // Ajouter des informations de concert fictives si nécessaire
        concertName: `Concert ID: ${concertId}`
      };
      
      // Soumettre le formulaire
      const result = await createFormSubmission(submissionData);
      console.log('Résultat de la soumission du formulaire:', result);
      
      if (result) {
        // Rediriger vers la page de confirmation
        console.log('Redirection vers la page de confirmation');
        navigate('/form-submitted');
      } else {
        console.error('Échec de la soumission du formulaire');
        setError('Une erreur est survenue lors de la soumission du formulaire.');
        setLoading(false);
      }
    } catch (err) {
      console.error('Erreur lors de la soumission du formulaire:', err);
      setError('Une erreur est survenue lors de la soumission du formulaire.');
      setLoading(false);
    }
  };
  
  if (loading) {
    return (
      <div className="public-form-container">
        <div className="public-form-card">
          <h2>Chargement...</h2>
          <p>Veuillez patienter pendant le traitement de votre demande.</p>
        </div>
      </div>
    );
  }
  
  if (error) {
    return (
      <div className="public-form-container">
        <div className="public-form-card error">
          <h2>Erreur</h2>
          <p>{error}</p>
          <button 
            className="form-button"
            onClick={() => window.location.href = window.location.origin}
          >
            Retour à l'accueil
          </button>
        </div>
      </div>
    );
  }
  
  return (
    <div className="public-form-container">
      <div className="public-form-card">
        <h2>Formulaire de renseignements</h2>
        <div className="form-header">
          <p><strong>ID du Concert :</strong> {concertId}</p>
        </div>
        
        <form onSubmit={handleSubmit}>
          <div className="form-group">
            <label htmlFor="businessName">Raison sociale</label>
            <input
              type="text"
              id="businessName"
              name="businessName"
              value={formData.businessName}
              onChange={handleChange}
            />
          </div>
          
          <div className="form-group">
            <label htmlFor="lastName">Nom</label>
            <input
              type="text"
              id="lastName"
              name="lastName"
              value={formData.lastName}
              onChange={handleChange}
            />
          </div>
          
          <div className="form-group">
            <label htmlFor="firstName">Prénom</label>
            <input
              type="text"
              id="firstName"
              name="firstName"
              value={formData.firstName}
              onChange={handleChange}
            />
          </div>
          
          <div className="form-group">
            <label htmlFor="role">Qualité</label>
            <input
              type="text"
              id="role"
              name="role"
              value={formData.role}
              onChange={handleChange}
            />
          </div>
          
          <div className="form-group">
            <label htmlFor="address">Adresse de la raison sociale</label>
            <textarea
              id="address"
              name="address"
              value={formData.address}
              onChange={handleChange}
              rows="3"
            />
          </div>
          
          <div className="form-group">
            <label htmlFor="venue">Lieu ou festival</label>
            <input
              type="text"
              id="venue"
              name="venue"
              value={formData.venue}
              onChange={handleChange}
            />
          </div>
          
          <div className="form-group">
            <label htmlFor="venueAddress">Adresse du lieu ou festival</label>
            <textarea
              id="venueAddress"
              name="venueAddress"
              value={formData.venueAddress}
              onChange={handleChange}
              rows="3"
            />
          </div>
          
          <div className="form-group">
            <label htmlFor="vatNumber">Numéro intracommunautaire</label>
            <input
              type="text"
              id="vatNumber"
              name="vatNumber"
              value={formData.vatNumber}
              onChange={handleChange}
            />
          </div>
          
          <div className="form-group">
            <label htmlFor="siret">Siret</label>
            <input
              type="text"
              id="siret"
              name="siret"
              value={formData.siret}
              onChange={handleChange}
            />
          </div>
          
          <div className="form-group">
            <label htmlFor="email">Mail</label>
            <input
              type="email"
              id="email"
              name="email"
              value={formData.email}
              onChange={handleChange}
            />
          </div>
          
          <div className="form-group">
            <label htmlFor="phone">Téléphone</label>
            <input
              type="tel"
              id="phone"
              name="phone"
              value={formData.phone}
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
          
          <div className="form-footer">
            <p>Tous les champs sont facultatifs</p>
            <button 
              type="submit" 
              className="form-button"
              disabled={loading}
            >
              {loading ? 'Envoi en cours...' : 'Soumettre le formulaire'}
            </button>
          </div>
        </form>
        
        <div style={{ 
          marginTop: "30px", 
          padding: "15px", 
          backgroundColor: "#e8f4fd", 
          borderRadius: "5px", 
          border: "1px solid #c5e1f9" 
        }}>
          <p style={{ margin: "0", color: "#2c76c7" }}>
            Informations de débogage:
          </p>
          <p style={{ margin: "10px 0 0 0", color: "#2c76c7", fontSize: "14px", textAlign: "left" }}>
            Hash: {window.location.hash}<br />
            Pathname: {window.location.pathname}<br />
            URL complète: {window.location.href}<br />
            Concert ID: {concertId}
          </p>
        </div>
      </div>
    </div>
  );
};

export default PublicFormPage;
