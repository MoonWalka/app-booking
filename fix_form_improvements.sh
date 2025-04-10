#!/bin/bash

# Script pour améliorer le formulaire public et la page de validation
# dans l'application de booking musical

echo "Début des améliorations du formulaire public et de la page de validation..."

# 1. Modification du PublicFormPage.jsx
echo "Modification du fichier PublicFormPage.jsx..."

cat > client/src/components/public/PublicFormPage.jsx << 'EOL'
import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { createFormSubmission } from '../../services/formSubmissionsService';
import { generateToken } from "../../utils/tokenGenerator";
import './PublicFormPage.css';

// Fonction utilitaire pour extraire le concertId de l'URL avec HashRouter
const extractConcertIdFromHash = () => {
  const hash = window.location.hash;
  
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
  const [submissionSuccess, setSubmissionSuccess] = useState(false);
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
  
  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
  };
  
  // Réinitialiser le formulaire
  const resetForm = () => {
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
      website: ''
    });
    console.log('PublicFormPage - Formulaire réinitialisé');
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
      console.log('PublicFormPage - Vérification de la présence du token commun:', submissionData.commonToken ? 'Présent' : 'Manquant');
      
      // Soumettre le formulaire avec un timeout pour éviter les blocages
      const timeoutPromise = new Promise((_, reject) => 
        setTimeout(() => reject(new Error('Timeout de la soumission du formulaire')), 15000)
      );
      
      const submissionPromise = createFormSubmission(submissionData);
      
      // Utiliser Promise.race pour éviter les blocages
      const result = await Promise.race([submissionPromise, timeoutPromise]);
      
      console.log('PublicFormPage - Résultat de la soumission:', result);
      
      // Afficher le message de succès et réinitialiser le formulaire
      if (result && result.id) {
        console.log('PublicFormPage - Soumission réussie avec ID:', result.id);
        console.log('PublicFormPage - Token commun dans le résultat:', result.commonToken);
        setSubmissionSuccess(true);
        resetForm();
      } else {
        console.error('PublicFormPage - Échec de la soumission du formulaire');
        setError('Une erreur est survenue lors de la soumission du formulaire.');
      }
      
      setLoading(false);
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
        </div>
      </div>
    );
  }
  
  if (submissionSuccess) {
    return (
      <div className="public-form-container">
        <div className="public-form-card success">
          <h2>Merci pour votre soumission</h2>
          <p>Votre formulaire a bien été transmis. Vous pouvez fermer cette fenêtre.</p>
          <button 
            className="form-button"
            onClick={() => {
              setSubmissionSuccess(false);
            }}
          >
            Soumettre un nouveau formulaire
          </button>
          <button 
            className="form-button secondary"
            onClick={() => window.location.href = window.location.origin}
            style={{ marginTop: "10px" }}
          >
            Retour à l'accueil
          </button>
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
      </div>
    </div>
  );
};

export default PublicFormPage;
EOL

echo "✅ Fichier PublicFormPage.jsx modifié"

# 2. Modification du service formSubmissionsService.js
echo "Modification du fichier formSubmissionsService.js..."

cat > client/src/services/formSubmissionsService.js << 'EOL'
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
  Timestamp,
  limit
} from 'firebase/firestore';
import { db } from '../firebase';

// Collection de référence
const FORM_SUBMISSIONS_COLLECTION = 'formSubmissions';

// Assurez-vous que la collection existe
const ensureCollection = async (collectionName) => {
  try {
    console.log(`[ensureCollection] Vérification de la collection ${collectionName}...`);
    
    // Vérifier si la collection existe en essayant de récupérer des documents
    const collectionRef = collection(db, collectionName);
    const snapshot = await getDocs(query(collectionRef, limit(1)));
    
    console.log(`[ensureCollection] Résultat de la vérification: ${snapshot.empty ? 'collection vide' : snapshot.size + ' documents trouvés'}`);
    
    return true;
  } catch (error) {
    console.error(`[ensureCollection] Erreur lors de la vérification de la collection ${collectionName}:`, error);
    return false;
  }
};

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
    
    console.log("[getFormSubmissions] Tentative de récupération des formulaires depuis Firebase...");
    console.log("[getFormSubmissions] Filtres appliqués:", filters);
    
    // Création d'une requête de base
    let formQuery = formSubmissionsCollection;
    
    // Application des filtres si nécessaire
    if (filters) {
      // Filtrer par statut
      if (filters.status) {
        console.log(`[getFormSubmissions] Filtrage par statut: ${filters.status}`);
        formQuery = query(formQuery, where('status', '==', filters.status));
      }
      
      // Filtrer par programmateur
      if (filters.programmerId) {
        console.log(`[getFormSubmissions] Filtrage par programmateur: ${filters.programmerId}`);
        formQuery = query(formQuery, where('programmerId', '==', filters.programmerId));
      }
      
      // Filtrer par concert
      if (filters.concertId) {
        console.log(`[getFormSubmissions] Filtrage par concert: ${filters.concertId}`);
        formQuery = query(formQuery, where('concertId', '==', filters.concertId));
      }
      
      // Filtrer par lien de formulaire
      if (filters.formLinkId) {
        console.log(`[getFormSubmissions] Filtrage par lien de formulaire: ${filters.formLinkId}`);
        formQuery = query(formQuery, where('formLinkId', '==', filters.formLinkId));
      }
      
      // Filtrer par token commun
      if (filters.commonToken) {
        console.log(`[getFormSubmissions] Filtrage par token commun: ${filters.commonToken}`);
        formQuery = query(formQuery, where('commonToken', '==', filters.commonToken));
      }
    }
    
    // Ajout d'un tri par date de soumission (du plus récent au plus ancien)
    formQuery = query(formQuery, orderBy('submittedAt', 'desc'));
    
    // Exécution de la requête
    const snapshot = await getDocs(formQuery);
    
    if (snapshot.empty) {
      console.log("[getFormSubmissions] Aucun formulaire trouvé dans Firebase");
      return [];
    }
    
    const formSubmissions = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));
    
    console.log(`[getFormSubmissions] ${formSubmissions.length} formulaires récupérés depuis Firebase`);
    formSubmissions.forEach(form => {
      console.log(`[getFormSubmissions] Formulaire ID: ${form.id}, Token: ${form.commonToken}, Status: ${form.status}`);
    });
    
    return formSubmissions;
  } catch (error) {
    console.error("[getFormSubmissions] Erreur lors de la récupération des formulaires:", error);
    return [];
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
    
    console.log(`[getFormSubmissionById] Tentative de récupération du formulaire ${id} depuis Firebase...`);
    const docRef = doc(db, FORM_SUBMISSIONS_COLLECTION, id);
    const snapshot = await getDoc(docRef);
    
    if (snapshot.exists()) {
      const formData = {
        id: snapshot.id,
        ...snapshot.data()
      };
      console.log(`[getFormSubmissionById] Formulaire ${id} récupéré depuis Firebase:`, formData);
      return formData;
    }
    
    console.log(`[getFormSubmissionById] Formulaire ${id} non trouvé dans Firebase`);
    return null;
  } catch (error) {
    console.error(`[getFormSubmissionById] Erreur lors de la récupération du formulaire ${id}:`, error);
    return null;
  }
};

/**
 * Crée un nouveau formulaire soumis
 * @param {Object} formData - Données du formulaire
 * @returns {Promise<Object>} Formulaire créé avec ID
 */
export const createFormSubmission = async (formData) => {
  console.log("[createFormSubmission] Début de la création d'un nouveau formulaire");
  console.log("[createFormSubmission] Données reçues:", formData);
  
  try {
    // S'assurer que la collection existe
    console.log("[createFormSubmission] Vérification de l'existence de la collection...");
    const collectionExists = await ensureCollection(FORM_SUBMISSIONS_COLLECTION);
    console.log(`[createFormSubmission] Résultat de la vérification: ${collectionExists ? 'collection existe' : 'échec de la vérification'}`);
    
    // Vérifier les champs obligatoires
    const requiredFields = ['concertId'];
    const missingFields = requiredFields.filter(field => !formData[field]);
    
    if (missingFields.length > 0) {
      console.error(`[createFormSubmission] Champs obligatoires manquants: ${missingFields.join(', ')}`);
      throw new Error(`Champs obligatoires manquants: ${missingFields.join(', ')}`);
    }
    
    // Générer un token commun si non fourni
    let commonToken = formData.commonToken;
    if (!commonToken) {
      // Importer dynamiquement pour éviter les dépendances circulaires
      const { generateToken } = await import('../utils/tokenGenerator');
      commonToken = generateToken(formData.concertId);
      console.log(`[createFormSubmission] Génération d'un nouveau token commun: ${commonToken}`);
    }
    
    // S'assurer que les champs obligatoires sont présents
    const completeFormData = {
      ...formData,
      commonToken, // Ajouter le token commun
      status: formData.status || 'pending',
      submittedAt: Timestamp.fromDate(new Date()),
      // Convertir la date du concert en Timestamp si elle existe
      concertDate: formData.concertDate ? 
        (formData.concertDate instanceof Date ? 
          Timestamp.fromDate(formData.concertDate) : 
          formData.concertDate) : 
        null
    };
    
    console.log("[createFormSubmission] Tentative d'ajout d'un formulaire à Firebase avec addDoc:", completeFormData);
    console.log("[createFormSubmission] Vérification de la présence de concertId:", completeFormData.concertId ? 'Présent' : 'Manquant');
    console.log("[createFormSubmission] Vérification de la présence du token commun:", completeFormData.commonToken ? 'Présent' : 'Manquant');
    
    try {
      const docRef = await addDoc(formSubmissionsCollection, completeFormData);
      console.log(`[createFormSubmission] Formulaire ajouté avec succès via addDoc, ID: ${docRef.id}`);
      
      return {
        id: docRef.id,
        ...completeFormData
      };
    } catch (addDocError) {
      console.error("[createFormSubmission] Erreur lors de l'ajout du formulaire avec addDoc:", addDocError);
      
      // Essayer d'ajouter le formulaire avec un ID généré manuellement
      console.log("[createFormSubmission] Tentative alternative avec setDoc...");
      const mockId = 'form-' + Date.now();
      
      try {
        await setDoc(doc(db, FORM_SUBMISSIONS_COLLECTION, mockId), completeFormData);
        console.log(`[createFormSubmission] Formulaire ajouté avec succès via setDoc, ID: ${mockId}`);
        
        return {
          id: mockId,
          ...completeFormData
        };
      } catch (setDocError) {
        console.error("[createFormSubmission] Erreur lors de l'ajout du formulaire avec setDoc:", setDocError);
        throw setDocError; // Propager l'erreur pour la gestion dans le composant
      }
    }
  } catch (error) {
    console.error("[createFormSubmission] Erreur générale lors de l'ajout du formulaire:", error);
    
    // Vérifier si l'erreur est liée à un champ manquant
    if (error.message && error.message.includes('Champs obligatoires manquants')) {
      throw error; // Propager l'erreur spécifique
    }
    
    throw error;
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
    
    console.log(`[updateFormSubmission] Tentative de mise à jour du formulaire ${id}:`, formData);
    const docRef = doc(db, FORM_SUBMISSIONS_COLLECTION, id);
    
    // Si le statut change à 'processed' ou 'rejected', ajouter la date de traitement
    const updatedData = {
      ...formData
    };
    
    if (formData.status === 'processed' || formData.status === 'rejected') {
      updatedData.processedAt = Timestamp.fromDate(new Date());
    }
    
    // Convertir la date du concert en Timestamp si elle existe
    if (formData.concertDate) {
      updatedData.concertDate = formData.concertDate instanceof Date ? 
        Timestamp.fromDate(formData.concertDate) : 
        formData.concertDate;
    }
    
    await updateDoc(docRef, updatedData);
    console.log(`[updateFormSubmission] Formulaire ${id} mis à jour avec succès`);
    
    return {
      id,
      ...updatedData
    };
  } catch (error) {
    console.error(`[updateFormSubmission] Erreur lors de la mise à jour du formulaire ${id}:`, error);
    throw error;
  }
};

/**
 * Supprime un formulaire soumis
 * @param {string} id - ID du formulaire
 * @returns {Promise<boolean>} Succès de la suppression
 */
export const deleteFormSubmission = async (id) => {
  try {
    // S'assurer que la collection existe
    await ensureCollection(FORM_SUBMISSIONS_COLLECTION);
    
    console.log(`[deleteFormSubmission] Tentative de suppression du formulaire ${id}`);
    const docRef = doc(db, FORM_SUBMISSIONS_COLLECTION, id);
    await deleteDoc(docRef);
    console.log(`[deleteFormSubmission] Formulaire ${id} supprimé avec succès`);
    
    return true;
  } catch (error) {
    console.error(`[deleteFormSubmission] Erreur lors de la suppression du formulaire ${id}:`, error);
    throw error;
  }
};

/**
 * Récupère les formulaires soumis par un programmateur
 * @param {string} programmerId - ID du programmateur
 * @returns {Promise<Array>} Liste des formulaires soumis
 */
export const getFormSubmissionsByProgrammer = async (programmerId) => {
  return getFormSubmissions({ programmerId });
};

/**
 * Récupère les formulaires soumis par statut
 * @param {string} status - Statut des formulaires
 * @returns {Promise<Array>} Liste des formulaires soumis
 */
export const getFormSubmissionsByStatus = async (status) => {
  return getFormSubmissions({ status });
};

/**
 * Récupère les formulaires soumis pour un concert
 * @param {string} concertId - ID du concert
 * @returns {Promise<Array>} Liste des formulaires soumis
 */
export const getFormSubmissionsByConcert = async (concertId) => {
  return getFormSubmissions({ concertId });
};

/**
 * Récupère les formulaires soumis par token commun
 * @param {string} commonToken - Token commun
 * @returns {Promise<Array>} Liste des formulaires soumis
 */
export const getFormSubmissionsByToken = async (commonToken) => {
  return getFormSubmissions({ commonToken });
};

/**
 * Récupère un formulaire soumis par son ID de lien
 * @param {string} formLinkId - ID du lien de formulaire
 * @returns {Promise<Object>} Formulaire soumis
 */
export const getFormSubmissionByFormLinkId = async (formLinkId) => {
  try {
    const submissions = await getFormSubmissions({ formLinkId });
    return submissions.length > 0 ? submissions[0] : null;
  } catch (error) {
    console.error(`[getFormSubmissionByFormLinkId] Erreur lors de la récupération du formulaire avec formLinkId ${formLinkId}:`, error);
    throw error;
  }
};
EOL

echo "✅ Fichier formSubmissionsService.js modifié"

# 3. Modification du ComparisonTable.jsx
echo "Modification du fichier ComparisonTable.jsx..."

cat > client/src/components/formValidation/ComparisonTable.jsx << 'EOL'
import React, { useState, useEffect } from 'react';
import './ComparisonTable.css';

/**
 * Composant de tableau comparatif pour comparer et intégrer les données du formulaire
 * avec les données existantes du programmateur
 */
const ComparisonTable = ({ formData, programmerData, onSave, onCancel }) => {
  // État pour stocker les valeurs sélectionnées
  const [selectedValues, setSelectedValues] = useState({});
  
  // Initialiser les valeurs sélectionnées avec les valeurs du programmateur
  useEffect(() => {
    if (programmerData) {
      const initialValues = {};
      // Pour chaque champ du programmateur, utiliser sa valeur comme valeur initiale
      Object.keys(programmerData).forEach(key => {
        if (key !== 'id' && key !== 'submittedAt' && key !== 'status' && 
            key !== 'processedAt' && key !== 'commonToken' && key !== 'formLinkId') {
          initialValues[key] = programmerData[key] || '';
        }
      });
      setSelectedValues(initialValues);
      console.log('ComparisonTable - Valeurs initiales chargées:', initialValues);
    }
  }, [programmerData]);
  
  // Gérer le clic sur une flèche pour copier une valeur
  const handleCopyValue = (field, value) => {
    setSelectedValues(prev => ({
      ...prev,
      [field]: value
    }));
    console.log(`ComparisonTable - Valeur copiée pour le champ ${field}:`, value);
  };
  
  // Gérer la modification manuelle d'une valeur
  const handleChange = (field, value) => {
    setSelectedValues(prev => ({
      ...prev,
      [field]: value
    }));
  };
  
  // Gérer la sauvegarde des valeurs sélectionnées
  const handleSave = () => {
    // Conserver le token commun et l'ID du formulaire
    const updatedData = {
      ...selectedValues,
      commonToken: formData.commonToken,
      formLinkId: formData.formLinkId
    };
    console.log('ComparisonTable - Données finales à sauvegarder:', updatedData);
    onSave(updatedData);
  };
  
  // Définir les champs à comparer et leur libellé
  const fieldDefinitions = [
    { key: 'businessName', label: 'Raison sociale' },
    { key: 'firstName', label: 'Prénom' },
    { key: 'lastName', label: 'Nom' },
    { key: 'role', label: 'Qualité' },
    { key: 'address', label: 'Adresse' },
    { key: 'venue', label: 'Lieu ou festival' },
    { key: 'venueAddress', label: 'Adresse du lieu' },
    { key: 'vatNumber', label: 'Numéro intracommunautaire' },
    { key: 'siret', label: 'Siret' },
    { key: 'email', label: 'Email' },
    { key: 'phone', label: 'Téléphone' },
    { key: 'website', label: 'Site web' }
  ];
  
  return (
    <div className="comparison-table-container">
      <h3>Comparaison et intégration des données</h3>
      <p>Comparez les données du formulaire avec les données existantes et choisissez les valeurs à conserver.</p>
      
      <table className="comparison-table">
        <thead>
          <tr>
            <th>Champ</th>
            <th>Valeur existante</th>
            <th>Valeur du formulaire</th>
            <th></th>
            <th>Valeur finale</th>
          </tr>
        </thead>
        <tbody>
          {fieldDefinitions.map(field => (
            <tr key={field.key}>
              <td className="field-label">{field.label}</td>
              <td className="existing-value">
                {programmerData && programmerData[field.key] ? programmerData[field.key] : '-'}
              </td>
              <td className="form-value">
                {formData && formData[field.key] ? formData[field.key] : '-'}
              </td>
              <td className="arrow-cell">
                {formData && formData[field.key] && (
                  <button 
                    className="arrow-button right-arrow"
                    onClick={() => handleCopyValue(field.key, formData[field.key])}
                    title="Utiliser la valeur du formulaire"
                  >
                    →
                  </button>
                )}
              </td>
              <td className="final-value">
                <input 
                  type="text" 
                  value={selectedValues[field.key] || ''} 
                  onChange={(e) => handleChange(field.key, e.target.value)}
                  className="final-value-input"
                />
              </td>
            </tr>
          ))}
        </tbody>
      </table>
      
      <div className="comparison-actions">
        <button className="cancel-button" onClick={onCancel}>Annuler</button>
        <button className="save-button" onClick={handleSave}>Valider et intégrer</button>
      </div>
    </div>
  );
};

export default ComparisonTable;
EOL

echo "✅ Fichier ComparisonTable.jsx modifié"

# 4. Modification du FormValidationList.jsx
echo "Modification du fichier FormValidationList.jsx..."

cat > client/src/components/formValidation/FormValidationList.jsx << 'EOL'
import React, { useState, useEffect } from 'react';
import { getFormSubmissions, updateFormSubmission } from '../../services/formSubmissionsService';
import { getProgrammerById, updateProgrammer } from '../../services/programmersService';
import { getConcertById, updateConcert } from '../../services/concertsService';
import ComparisonTable from './ComparisonTable';
import './FormValidationList.css';

const FormValidationList = () => {
  const [formSubmissions, setFormSubmissions] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [selectedSubmission, setSelectedSubmission] = useState(null);
  const [programmerData, setProgrammerData] = useState(null);
  const [showComparisonTable, setShowComparisonTable] = useState(false);
  const [updateStatus, setUpdateStatus] = useState({ status: '', message: '' });
  const [refreshCount, setRefreshCount] = useState(0);

  // Charger les soumissions de formulaire
  useEffect(() => {
    const fetchFormSubmissions = async () => {
      try {
        setLoading(true);
        console.log('FormValidationList - Chargement des soumissions en attente...');
        const submissions = await getFormSubmissions({ status: 'pending' });
        console.log(`FormValidationList - ${submissions.length} soumissions récupérées`);
        setFormSubmissions(submissions);
        setLoading(false);
      } catch (err) {
        console.error('FormValidationList - Erreur lors du chargement des soumissions:', err);
        setError('Erreur lors du chargement des soumissions. Veuillez réessayer.');
        setLoading(false);
      }
    };

    fetchFormSubmissions();
    
    // Mettre en place un intervalle pour rafraîchir les soumissions toutes les 30 secondes
    const refreshInterval = setInterval(() => {
      console.log('FormValidationList - Rafraîchissement automatique des soumissions');
      setRefreshCount(prev => prev + 1);
    }, 30000);
    
    // Nettoyer l'intervalle lors du démontage du composant
    return () => clearInterval(refreshInterval);
  }, [refreshCount]);

  // Gérer la sélection d'une soumission
  const handleSelectSubmission = async (submission) => {
    console.log('FormValidationList - Sélection de la soumission:', submission);
    setSelectedSubmission(submission);
    setUpdateStatus({ status: '', message: '' });
    
    try {
      // Rechercher le programmateur associé par token commun
      let programmer = null;
      
      if (submission.commonToken) {
        console.log(`FormValidationList - Recherche du programmateur avec token: ${submission.commonToken}`);
        // Rechercher par token commun
        const programmers = await getProgrammerById(submission.commonToken);
        if (programmers) {
          programmer = programmers;
          console.log('FormValidationList - Programmateur trouvé:', programmer);
        } else {
          console.log('FormValidationList - Aucun programmateur trouvé avec ce token');
        }
      } else {
        console.log('FormValidationList - Pas de token commun dans la soumission');
      }
      
      // Si aucun programmateur n'est trouvé, créer un objet vide
      if (!programmer) {
        console.log('FormValidationList - Création d\'un objet programmateur vide');
        programmer = {
          id: null,
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
          website: ''
        };
      }
      
      setProgrammerData(programmer);
      setShowComparisonTable(true);
    } catch (err) {
      console.error('FormValidationList - Erreur lors de la récupération des données du programmateur:', err);
      setError('Erreur lors de la récupération des données du programmateur. Veuillez réessayer.');
    }
  };

  // Gérer l'intégration des données
  const handleIntegrateData = async (updatedData) => {
    try {
      setLoading(true);
      console.log('FormValidationList - Début de l\'intégration des données');
      
      // Mettre à jour ou créer le programmateur
      let programmerId = programmerData.id;
      
      // Préparer les données du programmateur
      const programmerDataToUpdate = {
        ...updatedData,
        commonToken: selectedSubmission.commonToken,
        // Ajouter d'autres champs nécessaires
        contact: updatedData.firstName && updatedData.lastName 
          ? `${updatedData.firstName} ${updatedData.lastName}` 
          : updatedData.firstName || updatedData.lastName || 'Contact non spécifié'
      };
      
      console.log('FormValidationList - Données du programmateur à mettre à jour:', programmerDataToUpdate);
      
      if (programmerId) {
        // Mettre à jour le programmateur existant
        console.log(`FormValidationList - Mise à jour du programmateur existant: ${programmerId}`);
        await updateProgrammer(programmerId, programmerDataToUpdate);
      } else {
        // Créer un nouveau programmateur avec le token commun comme ID
        programmerId = selectedSubmission.commonToken;
        console.log(`FormValidationList - Création d'un nouveau programmateur avec ID: ${programmerId}`);
        await updateProgrammer(programmerId, programmerDataToUpdate);
      }
      
      // Mettre à jour le concert si nécessaire
      if (selectedSubmission.concertId) {
        try {
          console.log(`FormValidationList - Récupération du concert: ${selectedSubmission.concertId}`);
          const concert = await getConcertById(selectedSubmission.concertId);
          if (concert) {
            // Mettre à jour le concert avec le token commun
            console.log(`FormValidationList - Mise à jour du concert: ${selectedSubmission.concertId}`);
            await updateConcert(selectedSubmission.concertId, {
              ...concert,
              commonToken: selectedSubmission.commonToken,
              programmerId: programmerId
            });
          } else {
            console.log(`FormValidationList - Concert non trouvé: ${selectedSubmission.concertId}`);
          }
        } catch (concertErr) {
          console.error('FormValidationList - Erreur lors de la mise à jour du concert:', concertErr);
        }
      }
      
      // Mettre à jour le statut de la soumission
      console.log(`FormValidationList - Mise à jour du statut de la soumission: ${selectedSubmission.id}`);
      await updateFormSubmission(selectedSubmission.id, {
        ...selectedSubmission,
        status: 'processed',
        processedAt: new Date()
      });
      
      // Mettre à jour la liste des soumissions
      const updatedSubmissions = formSubmissions.filter(
        submission => submission.id !== selectedSubmission.id
      );
      console.log(`FormValidationList - Mise à jour de la liste des soumissions: ${updatedSubmissions.length} restantes`);
      setFormSubmissions(updatedSubmissions);
      
      // Réinitialiser l'état
      setSelectedSubmission(null);
      setProgrammerData(null);
      setShowComparisonTable(false);
      setUpdateStatus({
        status: 'success',
        message: 'Données intégrées avec succès!'
      });
      setLoading(false);
      
      // Forcer un rafraîchissement de la liste
      setRefreshCount(prev => prev + 1);
    } catch (err) {
      console.error('FormValidationList - Erreur lors de l\'intégration des données:', err);
      setUpdateStatus({
        status: 'error',
        message: `Erreur lors de l'intégration des données: ${err.message}`
      });
      setLoading(false);
    }
  };

  // Annuler l'intégration
  const handleCancelIntegration = () => {
    console.log('FormValidationList - Annulation de l\'intégration');
    setSelectedSubmission(null);
    setProgrammerData(null);
    setShowComparisonTable(false);
  };

  // Rafraîchir manuellement la liste
  const handleRefresh = () => {
    console.log('FormValidationList - Rafraîchissement manuel de la liste');
    setRefreshCount(prev => prev + 1);
  };

  if (loading && !showComparisonTable) {
    return <div className="loading">Chargement des soumissions...</div>;
  }

  if (error) {
    return <div className="error">{error}</div>;
  }

  if (showComparisonTable && selectedSubmission && programmerData) {
    return (
      <div className="form-validation-container">
        <h2>Intégration des données</h2>
        <div className="submission-details">
          <h3>Détails de la soumission</h3>
          <p><strong>ID:</strong> {selectedSubmission.id}</p>
          <p><strong>Date de soumission:</strong> {selectedSubmission.submittedAt instanceof Date 
            ? selectedSubmission.submittedAt.toLocaleString() 
            : new Date(selectedSubmission.submittedAt.seconds * 1000).toLocaleString()}</p>
          <p><strong>Token commun:</strong> {selectedSubmission.commonToken}</p>
          <p><strong>Concert ID:</strong> {selectedSubmission.concertId}</p>
        </div>
        
        <ComparisonTable 
          formData={selectedSubmission} 
          programmerData={programmerData}
          onSave={handleIntegrateData}
          onCancel={handleCancelIntegration}
        />
      </div>
    );
  }

  return (
    <div className="form-validation-container">
      <h2>Validation des formulaires</h2>
      
      {updateStatus.message && (
        <div className={`status-message ${updateStatus.status}`}>
          {updateStatus.message}
        </div>
      )}
      
      <div className="refresh-button-container">
        <button className="refresh-button" onClick={handleRefresh}>
          Rafraîchir la liste
        </button>
      </div>
      
      {formSubmissions.length === 0 ? (
        <p>Aucune soumission en attente de validation.</p>
      ) : (
        <div className="submissions-list">
          <h3>Soumissions en attente ({formSubmissions.length})</h3>
          <table className="submissions-table">
            <thead>
              <tr>
                <th>Date</th>
                <th>Raison sociale</th>
                <th>Contact</th>
                <th>Token</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {formSubmissions.map(submission => (
                <tr key={submission.id}>
                  <td>
                    {submission.submittedAt instanceof Date 
                      ? submission.submittedAt.toLocaleString() 
                      : new Date(submission.submittedAt.seconds * 1000).toLocaleString()}
                  </td>
                  <td>{submission.businessName || 'Non spécifié'}</td>
                  <td>{submission.contact || 'Non spécifié'}</td>
                  <td>{submission.commonToken ? submission.commonToken.substring(0, 10) + '...' : 'Non spécifié'}</td>
                  <td>
                    <button 
                      className="action-button"
                      onClick={() => handleSelectSubmission(submission)}
                    >
                      Comparer et intégrer
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
};

export default FormValidationList;
EOL

echo "✅ Fichier FormValidationList.jsx modifié"

# 5. Ajout d'un style CSS pour le bouton de rafraîchissement
echo "Ajout du style CSS pour le bouton de rafraîchissement..."

cat > client/src/components/formValidation/FormValidationList.css << 'EOL'
.form-validation-container {
  padding: 20px;
  max-width: 1200px;
  margin: 0 auto;
}

.loading, .error {
  text-align: center;
  padding: 20px;
  margin: 20px 0;
}

.error {
  color: #d32f2f;
  background-color: #ffebee;
  border-radius: 4px;
  padding: 15px;
}

.status-message {
  padding: 15px;
  margin: 15px 0;
  border-radius: 4px;
  text-align: center;
}

.status-message.success {
  background-color: #e8f5e9;
  color: #2e7d32;
}

.status-message.error {
  background-color: #ffebee;
  color: #d32f2f;
}

.submissions-list {
  margin-top: 20px;
}

.submissions-table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 10px;
}

.submissions-table th, .submissions-table td {
  padding: 12px 15px;
  text-align: left;
  border-bottom: 1px solid #ddd;
}

.submissions-table th {
  background-color: #f5f5f5;
  font-weight: bold;
}

.submissions-table tr:hover {
  background-color: #f9f9f9;
}

.action-button {
  background-color: #1976d2;
  color: white;
  border: none;
  padding: 8px 12px;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
}

.action-button:hover {
  background-color: #1565c0;
}

.submission-details {
  background-color: #f5f5f5;
  padding: 15px;
  border-radius: 4px;
  margin-bottom: 20px;
}

.submission-details h3 {
  margin-top: 0;
  margin-bottom: 10px;
}

.submission-details p {
  margin: 5px 0;
}

.refresh-button-container {
  display: flex;
  justify-content: flex-end;
  margin-bottom: 15px;
}

.refresh-button {
  background-color: #4caf50;
  color: white;
  border: none;
  padding: 8px 15px;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
  display: flex;
  align-items: center;
}

.refresh-button:hover {
  background-color: #388e3c;
}
EOL

echo "✅ Fichier FormValidationList.css modifié"

# 6. Ajout du style CSS pour le tableau comparatif
echo "Ajout du style CSS pour le tableau comparatif..."

cat > client/src/components/formValidation/ComparisonTable.css << 'EOL'
.comparison-table-container {
  margin-top: 20px;
}

.comparison-table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 15px;
}

.comparison-table th, .comparison-table td {
  padding: 12px 15px;
  text-align: left;
  border-bottom: 1px solid #ddd;
}

.comparison-table th {
  background-color: #f5f5f5;
  font-weight: bold;
}

.comparison-table tr:hover {
  background-color: #f9f9f9;
}

.field-label {
  font-weight: bold;
  width: 15%;
}

.existing-value, .form-value {
  width: 25%;
  color: #555;
}

.arrow-cell {
  width: 10%;
  text-align: center;
}

.final-value {
  width: 25%;
}

.arrow-button {
  background-color: #1976d2;
  color: white;
  border: none;
  width: 30px;
  height: 30px;
  border-radius: 50%;
  cursor: pointer;
  font-size: 16px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto;
}

.arrow-button:hover {
  background-color: #1565c0;
}

.final-value-input {
  width: 100%;
  padding: 8px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 14px;
}

.comparison-actions {
  display: flex;
  justify-content: flex-end;
  margin-top: 20px;
  gap: 10px;
}

.cancel-button, .save-button {
  padding: 10px 20px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
}

.cancel-button {
  background-color: #f5f5f5;
  color: #333;
}

.save-button {
  background-color: #1976d2;
  color: white;
}

.cancel-button:hover {
  background-color: #e0e0e0;
}

.save-button:hover {
  background-color: #1565c0;
}
EOL

echo "✅ Fichier ComparisonTable.css modifié"

echo "✅ Améliorations du formulaire public et de la page de validation terminées!"
echo ""
echo "Résumé des modifications:"
echo "1. Formulaire public:"
echo "   - Ajout d'un message de confirmation après soumission"
echo "   - Réinitialisation des champs du formulaire"
echo "   - Suppression des informations de débogage"
echo "   - Ajout de logs pour vérifier la transmission du token"
echo ""
echo "2. Page de validation:"
echo "   - Suppression complète des exemples par défaut"
echo "   - Rafraîchissement automatique des soumissions toutes les 30 secondes"
echo "   - Ajout d'un bouton de rafraîchissement manuel"
echo "   - Ajout de logs pour vérifier la récupération des soumissions"
echo ""
echo "3. Tableau comparatif:"
echo "   - Suppression de la flèche gauche"
echo "   - Affichage par défaut des valeurs existantes dans la colonne 'Valeur finale'"
echo "   - Conservation de la fonctionnalité de copie de la 'Valeur du formulaire' vers la 'Valeur finale'"
echo "   - Ajout de logs pour vérifier le fonctionnement du tableau"
echo ""
echo "Pour utiliser ces améliorations, exécutez les commandes suivantes:"
echo "1. Rendre le script exécutable et l'exécuter:"
echo "   chmod +x fix_form_improvements.sh && ./fix_form_improvements.sh"
echo ""
echo "2. Effectuer git add, commit et push:"
echo "   git add . && git commit -m \"Fix: Améliorations du formulaire public et de la page de validation\" && git push origin main"
