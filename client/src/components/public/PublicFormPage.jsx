import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { getFormLinkByToken } from '../../services/formLinkService';
import { createFormSubmission } from '../../services/formSubmissionsService';
import { markFormLinkAsSubmitted } from '../../services/formLinkService';
import './PublicFormPage.css';

const PublicFormPage = () => {
  const { token } = useParams();
  const navigate = useNavigate();
  const [formLink, setFormLink] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [submitting, setSubmitting] = useState(false);
  const [submitted, setSubmitted] = useState(false);
  const [formData, setFormData] = useState({
    businessName: '',
    contact: '',
    role: '',
    address: '',
    venue: '',
    vatNumber: '',
    siret: '',
    email: '',
    phone: '',
    website: ''
  });

  useEffect(() => {
    const fetchFormLink = async () => {
      try {
        setLoading(true);
        console.log(`Tentative de récupération du lien avec le token: ${token}`);
        
        const linkData = await getFormLinkByToken(token);
        
        if (!linkData) {
          throw new Error('Lien de formulaire non trouvé ou expiré');
        }
        
        if (linkData.isSubmitted) {
          throw new Error('Ce formulaire a déjà été soumis');
        }
        
        console.log('Lien de formulaire récupéré:', linkData);
        setFormLink(linkData);
        setLoading(false);
      } catch (err) {
        console.error('Erreur lors de la récupération du lien de formulaire:', err);
        setError(err.message);
        setLoading(false);
      }
    };

    fetchFormLink();
  }, [token]);

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setFormData({
      ...formData,
      [name]: value
    });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    try {
      setSubmitting(true);
      
      // Créer la soumission de formulaire
      const submissionData = {
        ...formData,
        programmerId: formLink.programmerId,
        programmerName: formLink.programmerName,
        concertId: formLink.concertId,
        concertName: formLink.concertName,
        concertDate: formLink.concertDate,
        status: 'pending',
        formLinkId: formLink.id
      };
      
      console.log("Données du formulaire à soumettre:", submissionData);
      
      // Envoyer les données à Firebase
      const submission = await createFormSubmission(submissionData);
      
      // Marquer le lien comme soumis
      await markFormLinkAsSubmitted(formLink.id, submission.id);
      
      console.log("Formulaire soumis avec succès:", submission);
      
      setSubmitting(false);
      setSubmitted(true);
      
      // Rediriger vers la page de confirmation après 3 secondes
      setTimeout(() => {
        navigate('/form-submitted');
      }, 3000);
      
    } catch (err) {
      console.error("Erreur lors de la soumission du formulaire:", err);
      setError(`Erreur lors de la soumission du formulaire: ${err.message}`);
      setSubmitting(false);
    }
  };

  if (loading) return <div className="public-form-loading">Chargement du formulaire...</div>;
  if (error) return <div className="public-form-error">{error}</div>;
  if (submitted) return (
    <div className="public-form-submitted">
      <div className="submitted-icon">
        <i className="fas fa-check-circle"></i>
      </div>
      <h2>Formulaire soumis avec succès !</h2>
      <p>Merci d'avoir complété ce formulaire. Vos informations ont été enregistrées.</p>
      <p>Vous allez être redirigé automatiquement...</p>
    </div>
  );

  return (
    <div className="public-form-container">
      <div className="public-form-header">
        <h1>Formulaire de renseignements</h1>
        <p className="form-description">
          Merci de compléter ce formulaire pour le concert : 
          <strong> {formLink.concertName}</strong>
          {formLink.concertDate && (
            <span> le {new Date(formLink.concertDate).toLocaleDateString()}</span>
          )}
        </p>
      </div>
      
      <form onSubmit={handleSubmit} className="public-form">
        <div className="form-section">
          <h2>Informations générales</h2>
          
          <div className="form-group">
            <label htmlFor="businessName">Raison sociale</label>
            <input
              type="text"
              id="businessName"
              name="businessName"
              value={formData.businessName}
              onChange={handleInputChange}
              placeholder="Nom de votre structure (association, entreprise, etc.)"
            />
          </div>
          
          <div className="form-group">
            <label htmlFor="contact">Contact</label>
            <input
              type="text"
              id="contact"
              name="contact"
              value={formData.contact}
              onChange={handleInputChange}
              placeholder="Nom et prénom de la personne à contacter"
            />
          </div>
          
          <div className="form-group">
            <label htmlFor="role">Qualité</label>
            <select
              id="role"
              name="role"
              value={formData.role}
              onChange={handleInputChange}
            >
              <option value="">Sélectionnez votre fonction</option>
              <option value="Président">Président</option>
              <option value="Programmateur">Programmateur</option>
              <option value="Gérant">Gérant</option>
              <option value="Directeur">Directeur</option>
              <option value="Autre">Autre</option>
            </select>
          </div>
        </div>
        
        <div className="form-section">
          <h2>Coordonnées</h2>
          
          <div className="form-group">
            <label htmlFor="address">Adresse de la raison sociale</label>
            <textarea
              id="address"
              name="address"
              value={formData.address}
              onChange={handleInputChange}
              placeholder="Adresse complète de votre structure"
              rows="3"
            ></textarea>
          </div>
          
          <div className="form-group">
            <label htmlFor="venue">Lieu ou festival</label>
            <input
              type="text"
              id="venue"
              name="venue"
              value={formData.venue}
              onChange={handleInputChange}
              placeholder="Nom du lieu ou du festival"
            />
          </div>
          
          <div className="form-group">
            <label htmlFor="email">Email</label>
            <input
              type="email"
              id="email"
              name="email"
              value={formData.email}
              onChange={handleInputChange}
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
              onChange={handleInputChange}
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
              onChange={handleInputChange}
              placeholder="URL de votre site web (commençant par http:// ou https://)"
            />
          </div>
        </div>
        
        <div className="form-section">
          <h2>Informations administratives</h2>
          
          <div className="form-group">
            <label htmlFor="vatNumber">Numéro intracommunautaire</label>
            <input
              type="text"
              id="vatNumber"
              name="vatNumber"
              value={formData.vatNumber}
              onChange={handleInputChange}
              placeholder="Numéro de TVA intracommunautaire (ex: FR12345678901)"
            />
          </div>
          
          <div className="form-group">
            <label htmlFor="siret">SIRET</label>
            <input
              type="text"
              id="siret"
              name="siret"
              value={formData.siret}
              onChange={handleInputChange}
              placeholder="Numéro SIRET (14 chiffres)"
            />
          </div>
        </div>
        
        <div className="form-actions">
          <button 
            type="submit" 
            className="submit-btn"
            disabled={submitting}
          >
            {submitting ? 'Envoi en cours...' : 'Envoyer le formulaire'}
          </button>
        </div>
      </form>
      
      <div className="public-form-footer">
        <p>
          Les informations recueillies sur ce formulaire sont enregistrées dans un fichier informatisé 
          pour la gestion des contrats et la facturation. Elles sont conservées pendant la durée nécessaire 
          à la gestion de la relation contractuelle et sont destinées aux services concernés.
        </p>
      </div>
    </div>
  );
};

export default PublicFormPage;
