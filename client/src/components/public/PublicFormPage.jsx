import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { getConcertById } from '../../services/concertsService';
import { createFormSubmission } from '../../services/formSubmissionsService';
import './PublicFormPage.css';

const PublicFormPage = () => {
  const { concertId } = useParams(); // Récupérer l'ID du concert directement de l'URL
  const navigate = useNavigate();
  const [concert, setConcert] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
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
  
  // Ajout de logs pour le débogage
  console.log('PublicFormPage rendered, concertId:', concertId);
  
  useEffect(() => {
    const fetchConcert = async () => {
      try {
        console.log('Fetching concert with ID:', concertId);
        setLoading(true);
        
        const concertData = await getConcertById(concertId);
        console.log('Concert data result:', concertData);
        
        if (!concertData) {
          console.error('No concert found with ID:', concertId);
          setError('Ce concert n\'existe pas ou a été supprimé.');
        } else {
          console.log('Concert found and valid:', concertData);
          setConcert(concertData);
        }
      } catch (err) {
        console.error('Error fetching concert:', err);
        setError('Une erreur est survenue lors du chargement des informations du concert.');
      } finally {
        setLoading(false);
      }
    };
    
    if (concertId) {
      fetchConcert();
    } else {
      console.error('No concert ID provided in URL');
      setError('Aucun identifiant de concert fourni.');
      setLoading(false);
    }
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
    
    if (!concert) return;
    
    try {
      setLoading(true);
      console.log('Submitting form data:', formData);
      
      // Préparer les données à soumettre
      const submissionData = {
        ...formData,
        programmerId: concert.programmer?.id || null,
        programmerName: concert.programmer?.name || null,
        concertId: concertId,
        concertName: concert.venue || "",
        concertDate: concert.date || "",
        status: 'pending'
      };
      
      // Soumettre le formulaire
      const result = await createFormSubmission(submissionData);
      console.log('Form submission result:', result);
      
      if (result) {
        // Rediriger vers la page de confirmation
        console.log('Redirecting to form-submitted page');
        navigate('/form-submitted');
      } else {
        console.error('Form submission failed');
        setError('Une erreur est survenue lors de la soumission du formulaire.');
        setLoading(false);
      }
    } catch (err) {
      console.error('Error submitting form:', err);
      setError('Une erreur est survenue lors de la soumission du formulaire.');
      setLoading(false);
    }
  };
  
  if (loading) {
    return (
      <div className="public-form-container">
        <div className="public-form-card">
          <h2>Chargement...</h2>
          <p>Veuillez patienter pendant le chargement du formulaire.</p>
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
        {concert && (
          <>
            <div className="form-header">
              <p><strong>Concert :</strong> {concert.venue || "Non spécifié"}</p>
              {concert.date && (
                <p><strong>Date :</strong> {
                  concert.date.seconds 
                    ? new Date(concert.date.seconds * 1000).toLocaleDateString()
                    : new Date(concert.date).toLocaleDateString()
                }</p>
              )}
            </div>
            
            <form onSubmit={handleSubmit}>
              {/* Champ en lecture seule pour afficher l'ID du concert */}
              <div className="form-group">
                <label htmlFor="concertId">ID du Concert</label>
                <input
                  type="text"
                  id="concertId"
                  name="concertId"
                  value={concertId}
                  readOnly
                  disabled
                  className="readonly-field"
                />
              </div>
              
              <div className="form-group">
                <label htmlFor="businessName">Raison sociale *</label>
                <input
                  type="text"
                  id="businessName"
                  name="businessName"
                  value={formData.businessName}
                  onChange={handleChange}
                  required
                />
              </div>
              
              <div className="form-group">
                <label htmlFor="contact">Contact *</label>
                <input
                  type="text"
                  id="contact"
                  name="contact"
                  value={formData.contact}
                  onChange={handleChange}
                  required
                />
              </div>
              
              <div className="form-group">
                <label htmlFor="role">Qualité (président, programmateur, gérant...)</label>
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
                <label htmlFor="siret">SIRET</label>
                <input
                  type="text"
                  id="siret"
                  name="siret"
                  value={formData.siret}
                  onChange={handleChange}
                />
              </div>
              
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
                <p>* Champs obligatoires</p>
                <button 
                  type="submit" 
                  className="form-button"
                  disabled={loading}
                >
                  {loading ? 'Envoi en cours...' : 'Envoyer'}
                </button>
              </div>
            </form>
          </>
        )}
      </div>
    </div>
  );
};

export default PublicFormPage;
