import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { createFormSubmission } from '../../services/formSubmissionsService';
import { generateToken } from "../../utils/tokenGenerator";
import './PublicFormPage.css';

// Fonction utilitaire pour extraire le concertId de l'URL avec HashRouter
const extractConcertIdFromHash = () => {
  const hash = window.location.hash;
  console.log('extractConcertIdFromHash - hash brut:', hash);
  
  // Format attendu: /#/form/CONCERT_ID
  const match = hash.match(/\/#\/form\/([^\/\?]+)/);
  if (match && match[1]) {
    console.log('extractConcertIdFromHash - concertId extrait:', match[1]);
    return match[1];
  }
  
  // Essayer un autre format possible: #/form/CONCERT_ID
  const altMatch = hash.match(/#\/form\/([^\/\?]+)/);
  if (altMatch && altMatch[1]) {
    console.log('extractConcertIdFromHash - concertId extrait (format alt):', altMatch[1]);
    return altMatch[1];
  }
  
  console.log('extractConcertIdFromHash - aucun concertId trouvé dans le hash');
  return null;
};

const PublicFormPage = (props) => {
  // Extraction robuste du concertId
  const params = useParams();
  const [concertId, setConcertId] = useState(null);
  const navigate = useNavigate();
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [submissionResult, setSubmissionResult] = useState(null);
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
  
  // Déterminer le concertId de manière robuste
  useEffect(() => {
    // Priorité 1: Props passées directement
    if (props.concertId) {
      console.log('PublicFormPage - concertId depuis props:', props.concertId);
      setConcertId(props.concertId);
      return;
    }
    
    // Priorité 2: Paramètres de route via useParams()
    if (params.concertId) {
      console.log('PublicFormPage - concertId depuis useParams:', params.concertId);
      setConcertId(params.concertId);
      return;
    }
    
    // Priorité 3: Extraction directe depuis l'URL
    const extractedId = extractConcertIdFromHash();
    if (extractedId) {
      console.log('PublicFormPage - concertId extrait de l\'URL:', extractedId);
      setConcertId(extractedId);
      return;
    }
    
    console.log('PublicFormPage - AUCUN concertId trouvé!');
    setError("Erreur: ID du concert manquant. Veuillez accéder à ce formulaire via un lien valide.");
  }, [props.concertId, params.concertId]);
  
  // Logs de débogage détaillés
  useEffect(() => {
    console.log('PublicFormPage - CHARGÉE AVEC:');
    console.log('PublicFormPage - concertId final:', concertId);
    console.log('PublicFormPage - concertId depuis props:', props.concertId);
    console.log('PublicFormPage - concertId depuis useParams:', params.concertId);
    console.log('PublicFormPage - Hash brut:', window.location.hash);
    console.log('PublicFormPage - Hash nettoyé:', window.location.hash.replace(/^#/, ''));
    console.log('PublicFormPage - Pathname:', window.location.pathname);
    console.log('PublicFormPage - URL complète:', window.location.href);
    
    // Vérifier si nous sommes dans un contexte HashRouter
    const isHashRouter = window.location.hash.includes('/form/');
    console.log('PublicFormPage - Utilisation de HashRouter détectée:', isHashRouter);
  }, [concertId, props.concertId, params.concertId]);
  
  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
  };
  
  const handleSubmit = async (e) => {
    e.preventDefault();
    
    // Vérifier que concertId est disponible
    if (!concertId) {
      setError("Erreur: ID du concert manquant. Veuillez accéder à ce formulaire via un lien valide.");
      return;
    }
    
    try {
      setLoading(true);
      setError(null);
      setSubmissionResult(null);
      
      console.log('PublicFormPage - Début de la soumission du formulaire');
      console.log('PublicFormPage - Données du formulaire:', formData);
      console.log('PublicFormPage - concertId utilisé pour la soumission:', concertId);
      
      // Générer un token commun pour lier les entités
      const commonToken = generateToken(concertId);
      console.log('PublicFormPage - Token commun généré:', commonToken);
      
      // Préparer les données à soumettre avec tous les champs requis
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
        status: 'pending',
        // Ajouter un formLinkId fictif si nécessaire
        formLinkId: `public-form-${concertId}`,
        // Ajouter le token commun pour lier les entités
        commonToken: commonToken
      };
      
      console.log('PublicFormPage - Données préparées pour la soumission:', submissionData);
      console.log('PublicFormPage - Vérification de la présence de concertId:', submissionData.concertId ? 'Présent' : 'Manquant');
      
      // Soumettre le formulaire avec un timeout pour éviter les blocages
      const timeoutPromise = new Promise((_, reject) => 
        setTimeout(() => reject(new Error('Timeout de la soumission du formulaire')), 15000)
      );
      
      const submissionPromise = createFormSubmission(submissionData);
      
      // Utiliser Promise.race pour éviter les blocages
      const result = await Promise.race([submissionPromise, timeoutPromise]);
      
      console.log('PublicFormPage - Résultat de la soumission:', result);
      setSubmissionResult(result);
      
      // Attendre un peu pour que l'utilisateur puisse voir le résultat
      setTimeout(() => {
        setLoading(false);
        if (result && result.id) {
          // Rediriger vers la page de confirmation
          console.log('PublicFormPage - Redirection vers la page de confirmation');
          navigate('/form-submitted');
        } else {
          console.error('PublicFormPage - Échec de la soumission du formulaire');
          setError('Une erreur est survenue lors de la soumission du formulaire.');
        }
      }, 1000);
    } catch (err) {
      console.error('PublicFormPage - Erreur lors de la soumission du formulaire:', err);
      setError(`Une erreur est survenue lors de la soumission du formulaire: ${err.message}`);
      setLoading(false);
    }
  };
  
  if (loading) {
    return (
      <div className="public-form-container">
        <div className="public-form-card">
          <h2>Chargement...</h2>
          <p>Veuillez patienter pendant le traitement de votre demande.</p>
          {submissionResult && (
            <div style={{ 
              marginTop: "20px", 
              padding: "15px", 
              backgroundColor: "#e8f4fd", 
              borderRadius: "5px", 
              border: "1px solid #c5e1f9" 
            }}>
              <p style={{ margin: "0", color: "#2c76c7" }}>
                Soumission réussie! Redirection en cours...
              </p>
              <pre style={{ 
                margin: "10px 0 0 0", 
                color: "#2c76c7", 
                fontSize: "12px", 
                textAlign: "left",
                overflow: "auto",
                maxHeight: "200px"
              }}>
                {JSON.stringify(submissionResult, null, 2)}
              </pre>
            </div>
          )}
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
            onClick={() => {
              setError(null);
              setLoading(false);
            }}
          >
            Réessayer
          </button>
          <button 
            className="form-button secondary"
            onClick={() => window.location.href = window.location.origin}
            style={{ marginTop: "10px" }}
          >
            Retour à l'accueil
          </button>
          
          <div style={{ 
            marginTop: "30px", 
            padding: "15px", 
            backgroundColor: "#f9e8e8", 
            borderRadius: "5px", 
            border: "1px solid #f9c5c5" 
          }}>
            <p style={{ margin: "0", color: "#c72c2c" }}>
              Informations de débogage:
            </p>
            <p style={{ margin: "10px 0 0 0", color: "#c72c2c", fontSize: "14px", textAlign: "left" }}>
              Hash: {window.location.hash}<br />
              Pathname: {window.location.pathname}<br />
              URL complète: {window.location.href}<br />
              Concert ID: {concertId || "Non spécifié"}<br />
              Concert ID (props): {props.concertId || "Non spécifié"}<br />
              Concert ID (params): {params.concertId || "Non spécifié"}
            </p>
          </div>
        </div>
      </div>
    );
  }
  
  return (
    <div className="public-form-container">
      <div className="public-form-card">
        <h2>Formulaire de renseignements</h2>
        <div className="form-header">
          <p><strong>ID du Concert :</strong> {concertId || "Non spécifié"}</p>
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
              disabled={loading || !concertId}
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
            Concert ID: {concertId || "Non spécifié"}<br />
            Concert ID (props): {props.concertId || "Non spécifié"}<br />
            Concert ID (params): {params.concertId || "Non spécifié"}
          </p>
        </div>
      </div>
    </div>
  );
};

export default PublicFormPage;
