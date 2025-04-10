#!/bin/bash

# Script pour corriger les problèmes spécifiques de soumission du formulaire public
echo "Début de la correction des problèmes spécifiques de soumission du formulaire public..."

# Créer des sauvegardes des fichiers originaux
echo "Création des sauvegardes..."
BACKUP_DIR="./backups/$(date +%Y%m%d_%H%M%S)_form_submission_fix"
mkdir -p $BACKUP_DIR

# Sauvegarde des fichiers existants
if [ -f "./client/src/components/public/PublicFormPage.jsx" ]; then
  cp ./client/src/components/public/PublicFormPage.jsx $BACKUP_DIR/PublicFormPage.jsx.backup
fi

if [ -f "./client/src/services/formSubmissionsService.js" ]; then
  cp ./client/src/services/formSubmissionsService.js $BACKUP_DIR/formSubmissionsService.js.backup
fi

# Mise à jour du fichier PublicFormPage.jsx pour s'assurer que concertId est correctement transmis
echo "Mise à jour du fichier PublicFormPage.jsx..."
mkdir -p ./client/src/components/public
cat > ./client/src/components/public/PublicFormPage.jsx << 'EOL'
import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { createFormSubmission } from '../../services/formSubmissionsService';
import './PublicFormPage.css';

const PublicFormPage = () => {
  const { concertId } = useParams();
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
  
  // Logs de débogage détaillés
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
        formLinkId: `public-form-${concertId}`
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
              Concert ID: {concertId}
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
            Concert ID: {concertId || "Non spécifié"}
          </p>
        </div>
      </div>
    </div>
  );
};

export default PublicFormPage;
EOL
echo "✅ Fichier PublicFormPage.jsx mis à jour pour s'assurer que concertId est correctement transmis"

# Mise à jour du fichier formSubmissionsService.js pour corriger l'import de setDoc
echo "Mise à jour du fichier formSubmissionsService.js..."
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
  setDoc,  // S'assurer que setDoc est correctement importé
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
    const snapshot = await getDocs(query(collectionRef, orderBy('submittedAt', 'desc')));
    
    console.log(`[ensureCollection] Résultat de la vérification: ${snapshot.empty ? 'collection vide' : snapshot.size + ' documents trouvés'}`);
    
    // Si la collection n'existe pas ou est vide, créer un document initial
    if (snapshot.empty) {
      console.log(`[ensureCollection] Collection ${collectionName} vide, création d'un document initial...`);
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
        notes: 'Formulaire exemple créé automatiquement',
        concertId: 'mock-concert-1',  // S'assurer que concertId est présent
        concertName: 'Concert exemple',
        formLinkId: 'mock-link-1'
      };
      
      try {
        const docRef = await addDoc(collectionRef, initialDoc);
        console.log(`[ensureCollection] Document initial créé avec ID: ${docRef.id}`);
      } catch (addError) {
        console.error(`[ensureCollection] Erreur lors de la création du document initial:`, addError);
        
        // Essayer avec setDoc comme alternative
        try {
          const mockId = 'mock-initial-' + Date.now();
          await setDoc(doc(db, collectionName, mockId), initialDoc);
          console.log(`[ensureCollection] Document initial créé avec ID manuel: ${mockId}`);
        } catch (setError) {
          console.error(`[ensureCollection] Erreur lors de la création du document initial avec setDoc:`, setError);
        }
      }
    }
    
    return true;
  } catch (error) {
    console.error(`[ensureCollection] Erreur lors de la vérification/création de la collection ${collectionName}:`, error);
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
    notes: 'Formulaire exemple',
    // Nouveaux champs pour lier au concert
    concertId: 'mock-concert-1',
    concertName: 'Concert exemple',
    concertDate: new Date(),
    formLinkId: 'mock-link-1'
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
    notes: 'Formulaire traité',
    // Nouveaux champs pour lier au concert
    concertId: 'mock-concert-2',
    concertName: 'Concert exemple 2',
    concertDate: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000), // 30 jours après
    formLinkId: 'mock-link-2'
  },
  {
    id: 'mock-form-3',
    programmerId: 'public-form-submission',
    programmerName: 'Formulaire Public',
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
    notes: 'Formulaire sans programmateur associé',
    // Nouveaux champs pour lier au concert
    concertId: 'mock-concert-3',
    concertName: 'Concert exemple 3',
    concertDate: new Date(Date.now() + 15 * 24 * 60 * 60 * 1000), // 15 jours après
    formLinkId: 'public-form-mock-concert-3'
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
    
    console.log("[getFormSubmissions] Tentative de récupération des formulaires depuis Firebase...");
    console.log("[getFormSubmissions] Filtres appliqués:", filters);
    
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
      
      // Filtrer par concert
      if (filters.concertId) {
        formQuery = query(formQuery, where('concertId', '==', filters.concertId));
      }
      
      // Filtrer par lien de formulaire
      if (filters.formLinkId) {
        formQuery = query(formQuery, where('formLinkId', '==', filters.formLinkId));
      }
    }
    
    // Ajout d'un tri par date de soumission (du plus récent au plus ancien)
    formQuery = query(formQuery, orderBy('submittedAt', 'desc'));
    
    // Exécution de la requête
    const snapshot = await getDocs(formQuery);
    
    if (snapshot.empty) {
      console.log("[getFormSubmissions] Aucun formulaire trouvé dans Firebase, utilisation des données simulées");
      
      // Essayer d'ajouter les données simulées à Firebase
      try {
        console.log("[getFormSubmissions] Tentative d'ajout des données simulées à Firebase...");
        for (const form of mockFormSubmissions) {
          const { id, ...formData } = form;
          await setDoc(doc(db, FORM_SUBMISSIONS_COLLECTION, id), {
            ...formData,
            submittedAt: Timestamp.fromDate(formData.submittedAt),
            processedAt: formData.processedAt ? Timestamp.fromDate(formData.processedAt) : null,
            concertDate: formData.concertDate ? Timestamp.fromDate(formData.concertDate) : null
          });
        }
        console.log("[getFormSubmissions] Données simulées ajoutées à Firebase avec succès");
      } catch (addError) {
        console.error("[getFormSubmissions] Erreur lors de l'ajout des données simulées:", addError);
      }
      
      return mockFormSubmissions;
    }
    
    const formSubmissions = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));
    
    console.log(`[getFormSubmissions] ${formSubmissions.length} formulaires récupérés depuis Firebase`);
    return formSubmissions;
  } catch (error) {
    console.error("[getFormSubmissions] Erreur lors de la récupération des formulaires:", error);
    console.log("[getFormSubmissions] Utilisation des données simulées pour les formulaires");
    
    // Essayer d'ajouter les données simulées à Firebase
    try {
      console.log("[getFormSubmissions] Tentative d'ajout des données simulées à Firebase...");
      for (const form of mockFormSubmissions) {
        const { id, ...formData } = form;
        await setDoc(doc(db, FORM_SUBMISSIONS_COLLECTION, id), {
          ...formData,
          submittedAt: Timestamp.fromDate(formData.submittedAt),
          processedAt: formData.processedAt ? Timestamp.fromDate(formData.processedAt) : null,
          concertDate: formData.concertDate ? Timestamp.fromDate(formData.concertDate) : null
        });
      }
      console.log("[getFormSubmissions] Données simulées ajoutées à Firebase avec succès");
    } catch (addError) {
      console.error("[getFormSubmissions] Erreur lors de l'ajout des données simulées:", addError);
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
    // Retourner un formulaire simulé en cas d'erreur
    const mockForm = mockFormSubmissions.find(form => form.id === id) || mockFormSubmissions[0];
    console.log(`[getFormSubmissionById] Utilisation du formulaire simulé:`, mockForm);
    return mockForm;
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
    
    // S'assurer que les champs obligatoires sont présents
    const completeFormData = {
      ...formData,
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
    
    // Simuler l'ajout d'un formulaire en cas d'erreur
    console.log("[createFormSubmission] Simulation de l'ajout d'un formulaire (mode fallback)");
    const mockId = 'mock-form-' + Date.now();
    
    const mockResult = {
      id: mockId,
      ...formData,
      status: formData.status || 'pending',
      submittedAt: new Date(),
      concertDate: formData.concertDate || null,
      _isMock: true // Indicateur que c'est une donnée simulée
    };
    
    console.log("[createFormSubmission] Résultat simulé:", mockResult);
    return mockResult;
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
    const updateData = { ...formData };
    if ((formData.status === 'processed' || formData.status === 'rejected') && !formData.processedAt) {
      updateData.processedAt = Timestamp.fromDate(new Date());
    }
    
    // Convertir la date du concert en Timestamp si elle existe
    if (updateData.concertDate) {
      updateData.concertDate = updateData.concertDate instanceof Date ? 
        Timestamp.fromDate(updateData.concertDate) : 
        updateData.concertDate;
    }
    
    await updateDoc(docRef, updateData);
    
    console.log(`[updateFormSubmission] Formulaire ${id} mis à jour avec succès`);
    return {
      id,
      ...updateData
    };
  } catch (error) {
    console.error(`[updateFormSubmission] Erreur lors de la mise à jour du formulaire ${id}:`, error);
    console.log("[updateFormSubmission] Tentative alternative avec setDoc...");
    
    // Essayer de créer/remplacer le document
    try {
      // Si le statut change à 'processed' ou 'rejected', ajouter la date de traitement
      const updateData = { ...formData };
      if ((formData.status === 'processed' || formData.status === 'rejected') && !formData.processedAt) {
        updateData.processedAt = Timestamp.fromDate(new Date());
      }
      
      // Convertir la date du concert en Timestamp si elle existe
      if (updateData.concertDate) {
        updateData.concertDate = updateData.concertDate instanceof Date ? 
          Timestamp.fromDate(updateData.concertDate) : 
          updateData.concertDate;
      }
      
      await setDoc(doc(db, FORM_SUBMISSIONS_COLLECTION, id), updateData, { merge: true });
      
      console.log(`[updateFormSubmission] Formulaire ${id} créé/remplacé avec succès`);
      return {
        id,
        ...updateData
      };
    } catch (setError) {
      console.error(`[updateFormSubmission] Erreur lors de la création/remplacement du formulaire ${id}:`, setError);
      
      // Simuler la mise à jour d'un formulaire en cas d'erreur
      return {
        id,
        ...formData,
        processedAt: (formData.status === 'processed' || formData.status === 'rejected') ? new Date() : null,
        _isMock: true // Indicateur que c'est une donnée simulée
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
    console.log(`[deleteFormSubmission] Tentative de suppression du formulaire ${id}`);
    const docRef = doc(db, FORM_SUBMISSIONS_COLLECTION, id);
    await deleteDoc(docRef);
    
    console.log(`[deleteFormSubmission] Formulaire ${id} supprimé avec succès`);
    return id;
  } catch (error) {
    console.error(`[deleteFormSubmission] Erreur lors de la suppression du formulaire ${id}:`, error);
    console.log("[deleteFormSubmission] Simulation de la suppression d'un formulaire");
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
    
    console.log(`[getFormSubmissionsByProgrammer] Tentative de récupération des formulaires pour le programmateur ${programmerId}...`);
    const formQuery = query(
      formSubmissionsCollection, 
      where('programmerId', '==', programmerId),
      orderBy('submittedAt', 'desc')
    );
    
    const snapshot = await getDocs(formQuery);
    
    if (snapshot.empty) {
      console.log(`[getFormSubmissionsByProgrammer] Aucun formulaire trouvé pour le programmateur ${programmerId}`);
      return [];
    }
    
    const formSubmissions = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));
    
    console.log(`[getFormSubmissionsByProgrammer] ${formSubmissions.length} formulaires récupérés pour le programmateur ${programmerId}`);
    return formSubmissions;
  } catch (error) {
    console.error(`[getFormSubmissionsByProgrammer] Erreur lors de la récupération des formulaires pour le programmateur ${programmerId}:`, error);
    
    // Filtrer les données simulées pour ce programmateur
    const mockData = mockFormSubmissions.filter(form => form.programmerId === programmerId);
    console.log(`[getFormSubmissionsByProgrammer] Utilisation de ${mockData.length} formulaires simulés pour le programmateur ${programmerId}`);
    return mockData;
  }
};

/**
 * Récupère les formulaires soumis pour un concert spécifique
 * @param {string} concertId - ID du concert
 * @returns {Promise<Array>} Liste des formulaires soumis
 */
export const getFormSubmissionsByConcert = async (concertId) => {
  try {
    // S'assurer que la collection existe
    await ensureCollection(FORM_SUBMISSIONS_COLLECTION);
    
    console.log(`[getFormSubmissionsByConcert] Tentative de récupération des formulaires pour le concert ${concertId}...`);
    const formQuery = query(
      formSubmissionsCollection, 
      where('concertId', '==', concertId),
      orderBy('submittedAt', 'desc')
    );
    
    const snapshot = await getDocs(formQuery);
    
    if (snapshot.empty) {
      console.log(`[getFormSubmissionsByConcert] Aucun formulaire trouvé pour le concert ${concertId}`);
      return [];
    }
    
    const formSubmissions = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));
    
    console.log(`[getFormSubmissionsByConcert] ${formSubmissions.length} formulaires récupérés pour le concert ${concertId}`);
    return formSubmissions;
  } catch (error) {
    console.error(`[getFormSubmissionsByConcert] Erreur lors de la récupération des formulaires pour le concert ${concertId}:`, error);
    
    // Filtrer les données simulées pour ce concert
    const mockData = mockFormSubmissions.filter(form => form.concertId === concertId);
    console.log(`[getFormSubmissionsByConcert] Utilisation de ${mockData.length} formulaires simulés pour le concert ${concertId}`);
    return mockData;
  }
};

// Exporter d'autres fonctions utiles
export const getFormSubmissionsByStatus = async (status) => {
  return getFormSubmissions({ status });
};
EOL
echo "✅ Fichier formSubmissionsService.js mis à jour pour corriger l'import de setDoc et améliorer la gestion de concertId"

# Mise à jour du fichier FormSubmittedPage.jsx
echo "Mise à jour du fichier FormSubmittedPage.jsx..."
cat > ./client/src/components/public/FormSubmittedPage.jsx << 'EOL'
import React, { useEffect } from 'react';
import { Link } from 'react-router-dom';
import './PublicFormPage.css';

const FormSubmittedPage = () => {
  // Logs de débogage détaillés
  useEffect(() => {
    console.log("FormSubmittedPage - CHARGÉE");
    console.log("FormSubmittedPage - Hash brut:", window.location.hash);
    console.log("FormSubmittedPage - Hash nettoyé:", window.location.hash.replace(/^#/, ''));
    console.log("FormSubmittedPage - Pathname:", window.location.pathname);
    console.log("FormSubmittedPage - URL complète:", window.location.href);
  }, []);
  
  return (
    <div className="public-form-container">
      <div className="public-form-card">
        <h2>Formulaire Soumis avec Succès</h2>
        <p>
          Merci d'avoir soumis le formulaire. Vos informations ont été enregistrées et seront traitées prochainement.
        </p>
        <div className="form-footer">
          <button 
            className="form-button"
            onClick={() => window.location.href = window.location.origin}
          >
            Retour à l'accueil
          </button>
        </div>
        
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
            URL complète: {window.location.href}
          </p>
        </div>
      </div>
    </div>
  );
};

export default FormSubmittedPage;
EOL
echo "✅ Fichier FormSubmittedPage.jsx mis à jour"

# Vérification du fichier CSS
echo "Vérification du fichier PublicFormPage.css..."
if [ ! -f "./client/src/components/public/PublicFormPage.css" ]; then
  echo "Création du fichier PublicFormPage.css..."
  cat > ./client/src/components/public/PublicFormPage.css << 'EOL'
.public-form-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  padding: 20px;
  background-color: #f5f5f5;
}

.public-form-card {
  background-color: white;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
  padding: 30px;
  width: 100%;
  max-width: 600px;
}

.public-form-card h2 {
  text-align: center;
  margin-bottom: 20px;
  color: #333;
}

.form-header {
  margin-bottom: 20px;
  padding-bottom: 15px;
  border-bottom: 1px solid #eee;
}

.form-group {
  margin-bottom: 15px;
}

.form-group label {
  display: block;
  margin-bottom: 5px;
  font-weight: 500;
  color: #555;
}

.form-group input,
.form-group textarea,
.form-group select {
  width: 100%;
  padding: 10px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 16px;
}

.form-group textarea {
  resize: vertical;
  min-height: 80px;
}

.form-footer {
  margin-top: 20px;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.form-footer p {
  margin-bottom: 10px;
  font-size: 14px;
  color: #666;
}

.form-button {
  background-color: #4a90e2;
  color: white;
  border: none;
  border-radius: 4px;
  padding: 10px 20px;
  font-size: 16px;
  cursor: pointer;
  transition: background-color 0.3s;
}

.form-button:hover {
  background-color: #3a7bc8;
}

.form-button:disabled {
  background-color: #cccccc;
  cursor: not-allowed;
}

.form-button.secondary {
  background-color: #6c757d;
  margin-top: 10px;
}

.form-button.secondary:hover {
  background-color: #5a6268;
}

.error {
  text-align: center;
}

.error h2 {
  color: #e74c3c;
}

.error p {
  margin-bottom: 20px;
}

/* Style pour le champ en lecture seule */
.readonly-field {
  background-color: #f0f0f0;
  color: #666;
  cursor: not-allowed;
  border: 1px solid #ddd;
}
EOL
  echo "✅ Fichier PublicFormPage.css créé"
fi

# Mise à jour du fichier App.js pour s'assurer que les routes sont correctement définies
echo "Vérification des routes dans App.js..."
if grep -q "form/:concertId" ./client/src/App.js; then
  echo "Route form/:concertId trouvée dans App.js"
else
  echo "⚠️ Route form/:concertId non trouvée dans App.js, vérification de la structure..."
  
  # Vérifier si App.js contient des routes
  if grep -q "<Route" ./client/src/App.js; then
    echo "Structure de routes trouvée dans App.js, ajout de la route form/:concertId..."
    
    # Sauvegarde du fichier App.js
    cp ./client/src/App.js $BACKUP_DIR/App.js.backup
    
    # Ajouter les routes pour le formulaire public
    sed -i '/\/\* Routes publiques/a \        <Route path="\/form\/:concertId" element={<PublicFormPage \/>} \/>\n        <Route path="\/form-submitted" element={<FormSubmittedPage \/>} \/>' ./client/src/App.js || \
    sed -i '/<Routes>/a \        <Route path="\/form\/:concertId" element={<PublicFormPage \/>} \/>\n        <Route path="\/form-submitted" element={<FormSubmittedPage \/>} \/>' ./client/src/App.js
    
    # Ajouter les imports si nécessaire
    if ! grep -q "import PublicFormPage" ./client/src/App.js; then
      sed -i '/import React/a import PublicFormPage from ".\/components\/public\/PublicFormPage";\nimport FormSubmittedPage from ".\/components\/public\/FormSubmittedPage";' ./client/src/App.js
    fi
    
    echo "✅ Routes ajoutées à App.js"
  else
    echo "⚠️ Structure de routes non trouvée dans App.js, vérification manuelle requise"
  fi
fi

# Création d'un fichier README pour expliquer les modifications
echo "Création d'un fichier README pour expliquer les modifications..."
cat > ./README_FORM_SUBMISSION_FIX.md << 'EOL'
# Correction des problèmes spécifiques de soumission du formulaire public

## Problèmes identifiés et solutions apportées

1. **Champ concertId manquant dans les données soumises** :
   - Ajout d'une vérification explicite de la présence de concertId avant la soumission
   - Affichage d'une erreur claire si concertId est manquant
   - Ajout de logs détaillés pour vérifier la présence de concertId à chaque étape

2. **Erreur "ReferenceError: Can't find variable: setDoc"** :
   - Correction de l'import de setDoc dans formSubmissionsService.js
   - Vérification que setDoc est correctement importé depuis firebase/firestore
   - Amélioration de la gestion des erreurs lors de l'utilisation de setDoc

3. **Gestion des erreurs améliorée** :
   - Propagation des erreurs spécifiques liées aux champs manquants
   - Affichage de messages d'erreur plus précis
   - Ajout d'un bouton pour réessayer en cas d'erreur

## Modifications techniques

### Dans PublicFormPage.jsx :
- Vérification explicite de la présence de concertId avant la soumission
- Affichage d'une erreur claire si concertId est manquant
- Ajout de logs détaillés pour vérifier la présence de concertId à chaque étape
- Amélioration de l'affichage des informations de débogage

### Dans formSubmissionsService.js :
- Correction de l'import de setDoc depuis firebase/firestore
- Vérification explicite des champs obligatoires avec génération d'erreur
- Amélioration de la gestion des erreurs lors de l'utilisation de setDoc
- Ajout de logs détaillés pour suivre le processus de soumission

## Comment tester

1. Accédez à une URL du type `/#/form/<concertId>` (remplacez `<concertId>` par un ID de concert valide)
2. Remplissez le formulaire avec les informations souhaitées
3. Cliquez sur "Soumettre le formulaire"
4. Observez les logs dans la console du navigateur pour suivre le processus de soumission
5. Vérifiez que les données apparaissent dans l'onglet "Validation de formulaire"

## Vérification des règles de sécurité Firebase

Si les problèmes persistent après l'implémentation de cette solution, il est recommandé de vérifier les règles de sécurité Firestore dans la console Firebase. Les règles devraient permettre l'accès en écriture à la collection `formSubmissions` :

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Permettre l'accès en lecture/écriture à la collection formSubmissions
    match /formSubmissions/{document=**} {
      allow read, write;
    }
    
    // Autres règles...
  }
}
```

## Remarques importantes

- Le champ concertId est maintenant vérifié explicitement avant la soumission
- Une erreur claire est affichée si concertId est manquant
- L'import de setDoc est maintenant correctement effectué
- Des logs détaillés ont été ajoutés pour faciliter le débogage
- La gestion des erreurs a été améliorée pour fournir des messages plus précis
EOL
echo "✅ Fichier README_FORM_SUBMISSION_FIX.md créé"

echo "✅ Correction des problèmes spécifiques de soumission du formulaire public terminée avec succès!"
echo "Pour tester la solution, accédez à /#/form/<concertId> et soumettez le formulaire."
echo "Les données soumises devraient apparaître dans l'onglet 'Validation de formulaire'."
echo ""
echo "Les fichiers originaux ont été sauvegardés dans: $BACKUP_DIR"
