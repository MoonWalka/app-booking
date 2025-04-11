import React, { useState } from 'react';
import { useParams } from 'react-router-dom';
import { createFormSubmission } from '../../services/formSubmissionsService';
import './PublicFormPage.css';

const PublicFormPage = () => {
  const { concertId } = useParams();
  const [formData, setFormData] = useState({
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
    website: '',
    concertDate: '',
    concertTime: '',
    concertVenue: '',
    concertCity: '',
    concertPrice: '',
    concertNotes: '',
    additionalInfo: ''
  });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [success, setSuccess] = useState(false);

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
      setError(null);
      
      console.log('PublicFormPage - Soumission du formulaire pour le concert:', concertId);
      
      // Préparer les données à envoyer
      const submissionData = {
        ...formData,
        // Champs obligatoires pour la compatibilité avec le système existant
        programmerId: 'public-form-submission',
        programmerName: 'Formulaire Public',
        concertId: concertId, // S'assurer que concertId est explicitement inclus
        concertName: `Concert ID: ${concertId}`,
        // Créer un champ contact à partir du prénom et du nom
        contact: formData.firstName && formData.lastName 
          ? `${formData.firstName} ${formData.lastName}` 
          : formData.firstName || formData.lastName || 'Contact non spécifié',
        status: 'pending', // Forcer le statut à 'pending'
        // Ajouter un formLinkId fictif si nécessaire
        formLinkId: `public-form-${concertId}`
      };
      
      console.log('PublicFormPage - Données à envoyer:', submissionData);
      
      // Envoyer les données
      const result = await createFormSubmission(submissionData);
      console.log('PublicFormPage - Résultat de la soumission:', result);
      
      // Réinitialiser le formulaire et afficher un message de succès
      setFormData({
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
        website: '',
        concertDate: '',
        concertTime: '',
        concertVenue: '',
        concertCity: '',
        concertPrice: '',
        concertNotes: '',
        additionalInfo: ''
      });
      
      setSuccess(true);
      setLoading(false);
    } catch (err) {
      console.error('PublicFormPage - Erreur lors de la soumission du formulaire:', err);
      setError('Une erreur est survenue lors de la soumission du formulaire. Veuillez réessayer.');
      setLoading(false);
    }
  };

  if (success) {
    return (
      <div className="public-form-container">
        <div className="success-message">
          <h2>Merci pour votre soumission !</h2>
          <p>Votre formulaire a bien été transmis. Vous pouvez fermer cette fenêtre.</p>
          <button 
            className="new-submission-btn"
            onClick={() => setSuccess(false)}
          >
            Soumettre un nouveau formulaire
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="public-form-container">
      <h1>Formulaire de soumission pour le concert</h1>
      <p className="form-description">
        Veuillez remplir ce formulaire pour soumettre vos informations concernant le concert.
        Les champs marqués d'un astérisque (*) sont obligatoires.
      </p>
      
      {error && <div className="error-message">{error}</div>}
      
      <form onSubmit={handleSubmit} className="public-form">
        <div className="form-section">
          <h2>Informations sur l'organisateur</h2>
          
          <div className="form-group">
            <label htmlFor="businessName">Raison sociale / Nom de l'organisation *</label>
            <input
              type="text"
              id="businessName"
              name="businessName"
              value={formData.businessName}
              onChange={handleChange}
              required
              placeholder="Nom de votre organisation"
            />
          </div>
          
          <div className="form-row">
            <div className="form-group">
              <label htmlFor="firstName">Prénom</label>
              <input
                type="text"
                id="firstName"
                name="firstName"
                value={formData.firstName}
                onChange={handleChange}
                placeholder="Prénom du contact"
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
                placeholder="Nom du contact"
              />
            </div>
          </div>
          
          <div className="form-group">
            <label htmlFor="role">Fonction</label>
            <input
              type="text"
              id="role"
              name="role"
              value={formData.role}
              onChange={handleChange}
              placeholder="Votre fonction dans l'organisation"
            />
          </div>
          
          <div className="form-group">
            <label htmlFor="address">Adresse</label>
            <textarea
              id="address"
              name="address"
              value={formData.address}
              onChange={handleChange}
              rows="3"
              placeholder="Adresse complète de l'organisation"
            ></textarea>
          </div>
          
          <div className="form-group">
            <label htmlFor="venue">Nom de la salle</label>
            <input
              type="text"
              id="venue"
              name="venue"
              value={formData.venue}
              onChange={handleChange}
              placeholder="Nom de la salle de concert"
            />
          </div>
          
          <div className="form-group">
            <label htmlFor="venueAddress">Adresse de la salle</label>
            <textarea
              id="venueAddress"
              name="venueAddress"
              value={formData.venueAddress}
              onChange={handleChange}
              rows="3"
              placeholder="Adresse complète de la salle de concert"
            ></textarea>
          </div>
          
          <div className="form-row">
            <div className="form-group">
              <label htmlFor="vatNumber">Numéro de TVA</label>
              <input
                type="text"
                id="vatNumber"
                name="vatNumber"
                value={formData.vatNumber}
                onChange={handleChange}
                placeholder="Numéro de TVA"
              />
            </div>
            
            <div className="form-group">
              <label htmlFor="siret">SIRET</label>
              <input
                type="text"
                id="siret"
                name="siret"
                value={formData.siret}
                onChange={handleChange}
                placeholder="Numéro SIRET"
              />
            </div>
          </div>
        </div>
        
        <div className="form-section">
          <h2>Coordonnées</h2>
          
          <div className="form-group">
            <label htmlFor="email">Email *</label>
            <input
              type="email"
              id="email"
              name="email"
              value={formData.email}
              onChange={handleChange}
              required
              placeholder="Adresse email de contact"
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
              placeholder="Numéro de téléphone"
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
              placeholder="Site web (avec http:// ou https://)"
            />
          </div>
        </div>
        
        <div className="form-section">
          <h2>Informations sur le concert</h2>
          
          <div className="form-row">
            <div className="form-group">
              <label htmlFor="concertDate">Date</label>
              <input
                type="date"
                id="concertDate"
                name="concertDate"
                value={formData.concertDate}
                onChange={handleChange}
              />
            </div>
            
            <div className="form-group">
              <label htmlFor="concertTime">Heure</label>
              <input
                type="time"
                id="concertTime"
                name="concertTime"
                value={formData.concertTime}
                onChange={handleChange}
              />
            </div>
          </div>
          
          <div className="form-group">
            <label htmlFor="concertVenue">Lieu du concert</label>
            <input
              type="text"
              id="concertVenue"
              name="concertVenue"
              value={formData.concertVenue}
              onChange={handleChange}
              placeholder="Nom du lieu du concert"
            />
          </div>
          
          <div className="form-group">
            <label htmlFor="concertCity">Ville</label>
            <input
              type="text"
              id="concertCity"
              name="concertCity"
              value={formData.concertCity}
              onChange={handleChange}
              placeholder="Ville du concert"
            />
          </div>
          
          <div className="form-group">
            <label htmlFor="concertPrice">Prix (€)</label>
            <input
              type="number"
              id="concertPrice"
              name="concertPrice"
              value={formData.concertPrice}
              onChange={handleChange}
              min="0"
              step="0.01"
              placeholder="Prix en euros"
            />
          </div>
          
          <div className="form-group">
            <label htmlFor="concertNotes">Notes sur le concert</label>
            <textarea
              id="concertNotes"
              name="concertNotes"
              value={formData.concertNotes}
              onChange={handleChange}
              rows="4"
              placeholder="Informations complémentaires sur le concert"
            ></textarea>
          </div>
        </div>
        
        <div className="form-section">
          <h2>Informations supplémentaires</h2>
          
          <div className="form-group">
            <label htmlFor="additionalInfo">Commentaires ou demandes particulières</label>
            <textarea
              id="additionalInfo"
              name="additionalInfo"
              value={formData.additionalInfo}
              onChange={handleChange}
              rows="4"
              placeholder="Toute information supplémentaire que vous souhaitez partager"
            ></textarea>
          </div>
        </div>
        
        <div className="form-actions">
          <button type="submit" className="submit-btn" disabled={loading}>
            {loading ? 'Envoi en cours...' : 'Soumettre le formulaire'}
          </button>
        </div>
      </form>
    </div>
  );
};

export default PublicFormPage;
