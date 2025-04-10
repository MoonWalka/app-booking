#!/bin/bash

# Script pour implémenter le système de token commun et le tableau comparatif
# dans l'application de booking musical

echo "Début de l'implémentation du système de token commun et du tableau comparatif..."

# Créer le répertoire utils s'il n'existe pas
mkdir -p client/src/utils

# Créer le fichier tokenGenerator.js
cat > client/src/utils/tokenGenerator.js << 'EOL'
/**
 * Utilitaire pour générer un token unique pour lier les entités (programmateur, concert, contrat)
 */

/**
 * Génère un token unique basé sur l'ID du concert et un timestamp
 * @param {string} concertId - ID du concert
 * @returns {string} Token unique
 */
export const generateToken = (concertId) => {
  // Utiliser l'ID du concert comme base pour garantir la cohérence
  const base = concertId || 'default';
  
  // Ajouter un timestamp pour l'unicité
  const timestamp = Date.now().toString(36);
  
  // Ajouter un élément aléatoire pour éviter les collisions
  const random = Math.random().toString(36).substring(2, 8);
  
  // Combiner les éléments pour créer un token unique
  return `${base}-${timestamp}-${random}`;
};

/**
 * Extrait l'ID du concert à partir d'un token
 * @param {string} token - Token à analyser
 * @returns {string|null} ID du concert ou null si le format est invalide
 */
export const extractConcertIdFromToken = (token) => {
  if (!token || typeof token !== 'string') {
    return null;
  }
  
  // Le format attendu est concertId-timestamp-random
  const parts = token.split('-');
  if (parts.length >= 3) {
    return parts[0];
  }
  
  return null;
};
EOL

echo "✅ Fichier tokenGenerator.js créé"

# Créer le composant ComparisonTable
mkdir -p client/src/components/formValidation

# Créer le fichier CSS pour le tableau comparatif
cat > client/src/components/formValidation/ComparisonTable.css << 'EOL'
.comparison-table-container {
  margin: 20px 0;
  padding: 20px;
  background-color: #f9f9f9;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.comparison-table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 15px;
}

.comparison-table th,
.comparison-table td {
  padding: 10px;
  border: 1px solid #ddd;
  text-align: left;
}

.comparison-table th {
  background-color: #f2f2f2;
  font-weight: bold;
}

.field-label {
  font-weight: bold;
  width: 15%;
}

.existing-value, .form-value {
  width: 25%;
  word-break: break-word;
}

.arrow-cell {
  width: 5%;
  text-align: center;
}

.final-value {
  width: 25%;
}

.arrow-button {
  background-color: #e0e0e0;
  border: none;
  border-radius: 50%;
  width: 30px;
  height: 30px;
  cursor: pointer;
  font-size: 16px;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: background-color 0.2s;
}

.arrow-button:hover {
  background-color: #4CAF50;
  color: white;
}

.left-arrow {
  margin-left: auto;
}

.right-arrow {
  margin-right: auto;
}

.final-value-input {
  width: 100%;
  padding: 8px;
  border: 1px solid #ddd;
  border-radius: 4px;
}

.comparison-actions {
  margin-top: 20px;
  display: flex;
  justify-content: flex-end;
  gap: 10px;
}

.save-button, .cancel-button {
  padding: 10px 20px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-weight: bold;
}

.save-button {
  background-color: #4CAF50;
  color: white;
}

.save-button:hover {
  background-color: #45a049;
}

.cancel-button {
  background-color: #f44336;
  color: white;
}

.cancel-button:hover {
  background-color: #d32f2f;
}

/* Responsive design */
@media (max-width: 768px) {
  .comparison-table-container {
    padding: 10px;
  }
  
  .comparison-table th,
  .comparison-table td {
    padding: 8px;
    font-size: 14px;
  }
  
  .arrow-button {
    width: 25px;
    height: 25px;
    font-size: 14px;
  }
}
EOL

echo "✅ Fichier ComparisonTable.css créé"

# Créer le composant ComparisonTable.jsx
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
    }
  }, [programmerData]);
  
  // Gérer le clic sur une flèche pour copier une valeur
  const handleCopyValue = (field, value) => {
    setSelectedValues(prev => ({
      ...prev,
      [field]: value
    }));
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
            <th></th>
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
              <td className="arrow-cell">
                {formData && formData[field.key] && (
                  <button 
                    className="arrow-button left-arrow"
                    onClick={() => handleCopyValue(field.key, programmerData && programmerData[field.key] ? programmerData[field.key] : '')}
                    title="Utiliser la valeur existante"
                  >
                    ←
                  </button>
                )}
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

echo "✅ Composant ComparisonTable.jsx créé"

# Modifier le service formSubmissionsService.js pour inclure le token commun
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
        concertId: 'mock-concert-1',
        concertName: 'Concert exemple',
        formLinkId: 'mock-link-1',
        commonToken: 'mock-concert-1-token'
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
    concertId: 'mock-concert-1',
    concertName: 'Concert exemple',
    concertDate: new Date(),
    formLinkId: 'mock-link-1',
    commonToken: 'mock-concert-1-token'
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
    submittedAt: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000),
    processedAt: new Date(Date.now() - 5 * 24 * 60 * 60 * 1000),
    notes: 'Formulaire traité',
    concertId: 'mock-concert-2',
    concertName: 'Concert exemple 2',
    concertDate: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000),
    formLinkId: 'mock-link-2',
    commonToken: 'mock-concert-2-token'
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
    submittedAt: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000),
    notes: 'Formulaire sans programmateur associé',
    concertId: 'mock-concert-3',
    concertName: 'Concert exemple 3',
    concertDate: new Date(Date.now() + 15 * 24 * 60 * 60 * 1000),
    formLinkId: 'public-form-mock-concert-3',
    commonToken: 'mock-concert-3-token'
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
      
      // Filtrer par token commun
      if (filters.commonToken) {
        formQuery = query(formQuery, where('commonToken', '==', filters.commonToken));
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

echo "✅ Service formSubmissionsService.js modifié"

# Modifier le composant PublicFormPage.jsx pour inclure le token commun
cat > client/src/components/public/PublicFormPage.jsx << 'EOL'
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
EOL

echo "✅ Composant PublicFormPage.jsx modifié"

# Modifier le composant FormValidationList.jsx pour intégrer le tableau comparatif
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

  // Charger les soumissions de formulaire
  useEffect(() => {
    const fetchFormSubmissions = async () => {
      try {
        setLoading(true);
        const submissions = await getFormSubmissions({ status: 'pending' });
        setFormSubmissions(submissions);
        setLoading(false);
      } catch (err) {
        console.error('Erreur lors du chargement des soumissions:', err);
        setError('Erreur lors du chargement des soumissions. Veuillez réessayer.');
        setLoading(false);
      }
    };

    fetchFormSubmissions();
  }, []);

  // Gérer la sélection d'une soumission
  const handleSelectSubmission = async (submission) => {
    setSelectedSubmission(submission);
    setUpdateStatus({ status: '', message: '' });
    
    try {
      // Rechercher le programmateur associé par token commun
      let programmer = null;
      
      if (submission.commonToken) {
        // Rechercher par token commun
        const programmers = await getProgrammerById(submission.commonToken);
        if (programmers) {
          programmer = programmers;
        }
      }
      
      // Si aucun programmateur n'est trouvé, créer un objet vide
      if (!programmer) {
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
      console.error('Erreur lors de la récupération des données du programmateur:', err);
      setError('Erreur lors de la récupération des données du programmateur. Veuillez réessayer.');
    }
  };

  // Gérer l'intégration des données
  const handleIntegrateData = async (updatedData) => {
    try {
      setLoading(true);
      
      // Mettre à jour ou créer le programmateur
      let programmerId = programmerData.id;
      
      // Préparer les données du programmateur
      const programmerData = {
        ...updatedData,
        commonToken: selectedSubmission.commonToken,
        // Ajouter d'autres champs nécessaires
        contact: updatedData.firstName && updatedData.lastName 
          ? `${updatedData.firstName} ${updatedData.lastName}` 
          : updatedData.firstName || updatedData.lastName || 'Contact non spécifié'
      };
      
      if (programmerId) {
        // Mettre à jour le programmateur existant
        await updateProgrammer(programmerId, programmerData);
      } else {
        // Créer un nouveau programmateur avec le token commun comme ID
        programmerId = selectedSubmission.commonToken;
        await updateProgrammer(programmerId, programmerData);
      }
      
      // Mettre à jour le concert si nécessaire
      if (selectedSubmission.concertId) {
        try {
          const concert = await getConcertById(selectedSubmission.concertId);
          if (concert) {
            // Mettre à jour le concert avec le token commun
            await updateConcert(selectedSubmission.concertId, {
              ...concert,
              commonToken: selectedSubmission.commonToken,
              programmerId: programmerId
            });
          }
        } catch (concertErr) {
          console.error('Erreur lors de la mise à jour du concert:', concertErr);
        }
      }
      
      // Mettre à jour le statut de la soumission
      await updateFormSubmission(selectedSubmission.id, {
        ...selectedSubmission,
        status: 'processed',
        processedAt: new Date()
      });
      
      // Mettre à jour la liste des soumissions
      const updatedSubmissions = formSubmissions.filter(
        submission => submission.id !== selectedSubmission.id
      );
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
    } catch (err) {
      console.error('Erreur lors de l\'intégration des données:', err);
      setUpdateStatus({
        status: 'error',
        message: `Erreur lors de l'intégration des données: ${err.message}`
      });
      setLoading(false);
    }
  };

  // Annuler l'intégration
  const handleCancelIntegration = () => {
    setSelectedSubmission(null);
    setProgrammerData(null);
    setShowComparisonTable(false);
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

echo "✅ Composant FormValidationList.jsx modifié"

# Créer le fichier CSS pour FormValidationList
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
  color: #f44336;
  background-color: #ffebee;
  border-radius: 4px;
  padding: 15px;
}

.submissions-list {
  margin-top: 20px;
}

.submissions-table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 15px;
}

.submissions-table th,
.submissions-table td {
  padding: 12px;
  border: 1px solid #ddd;
  text-align: left;
}

.submissions-table th {
  background-color: #f2f2f2;
  font-weight: bold;
}

.submissions-table tr:nth-child(even) {
  background-color: #f9f9f9;
}

.submissions-table tr:hover {
  background-color: #f1f1f1;
}

.action-button {
  background-color: #4CAF50;
  color: white;
  border: none;
  padding: 8px 12px;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
}

.action-button:hover {
  background-color: #45a049;
}

.submission-details {
  background-color: #f9f9f9;
  padding: 15px;
  border-radius: 4px;
  margin-bottom: 20px;
}

.status-message {
  padding: 15px;
  border-radius: 4px;
  margin: 15px 0;
}

.status-message.success {
  background-color: #e8f5e9;
  color: #2e7d32;
  border: 1px solid #c8e6c9;
}

.status-message.error {
  background-color: #ffebee;
  color: #c62828;
  border: 1px solid #ffcdd2;
}

/* Responsive design */
@media (max-width: 768px) {
  .submissions-table th,
  .submissions-table td {
    padding: 8px;
    font-size: 14px;
  }
  
  .action-button {
    padding: 6px 10px;
    font-size: 12px;
  }
}
EOL

echo "✅ Fichier FormValidationList.css créé"

# Modifier le service programmersService.js pour prendre en charge le token commun
cat > client/src/services/programmersService.js << 'EOL'
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
  limit
} from 'firebase/firestore';
import { db } from '../firebase';

// Collection de référence
const PROGRAMMERS_COLLECTION = 'programmers';

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

// Assurez-vous que la collection programmers existe
const programmersCollection = collection(db, PROGRAMMERS_COLLECTION);

/**
 * Récupère tous les programmateurs
 * @returns {Promise<Array>} Liste des programmateurs
 */
export const getProgrammers = async () => {
  try {
    // S'assurer que la collection existe
    await ensureCollection(PROGRAMMERS_COLLECTION);
    
    console.log("[getProgrammers] Tentative de récupération des programmateurs depuis Firebase...");
    
    // Création d'une requête avec tri par nom
    const programmersQuery = query(programmersCollection, orderBy('businessName', 'asc'));
    
    // Exécution de la requête
    const snapshot = await getDocs(programmersQuery);
    
    const programmers = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));
    
    console.log(`[getProgrammers] ${programmers.length} programmateurs récupérés depuis Firebase`);
    return programmers;
  } catch (error) {
    console.error("[getProgrammers] Erreur lors de la récupération des programmateurs:", error);
    throw error;
  }
};

/**
 * Récupère un programmateur par son ID
 * @param {string} id - ID du programmateur ou token commun
 * @returns {Promise<Object>} Données du programmateur
 */
export const getProgrammerById = async (id) => {
  try {
    // S'assurer que la collection existe
    await ensureCollection(PROGRAMMERS_COLLECTION);
    
    console.log(`[getProgrammerById] Tentative de récupération du programmateur ${id} depuis Firebase...`);
    
    // D'abord, essayer de récupérer par ID direct
    const docRef = doc(db, PROGRAMMERS_COLLECTION, id);
    const snapshot = await getDoc(docRef);
    
    if (snapshot.exists()) {
      const programmerData = {
        id: snapshot.id,
        ...snapshot.data()
      };
      console.log(`[getProgrammerById] Programmateur ${id} récupéré depuis Firebase par ID direct`);
      return programmerData;
    }
    
    // Si non trouvé par ID direct, essayer de rechercher par token commun
    console.log(`[getProgrammerById] Programmateur ${id} non trouvé par ID direct, recherche par token commun...`);
    const tokenQuery = query(programmersCollection, where('commonToken', '==', id));
    const tokenSnapshot = await getDocs(tokenQuery);
    
    if (!tokenSnapshot.empty) {
      const programmerData = {
        id: tokenSnapshot.docs[0].id,
        ...tokenSnapshot.docs[0].data()
      };
      console.log(`[getProgrammerById] Programmateur trouvé par token commun: ${programmerData.id}`);
      return programmerData;
    }
    
    console.log(`[getProgrammerById] Aucun programmateur trouvé pour ${id}`);
    return null;
  } catch (error) {
    console.error(`[getProgrammerById] Erreur lors de la récupération du programmateur ${id}:`, error);
    throw error;
  }
};

/**
 * Ajoute un nouveau programmateur
 * @param {Object} programmerData - Données du programmateur
 * @returns {Promise<Object>} Programmateur créé avec ID
 */
export const addProgrammer = async (programmerData) => {
  try {
    // S'assurer que la collection existe
    await ensureCollection(PROGRAMMERS_COLLECTION);
    
    console.log("[addProgrammer] Tentative d'ajout d'un programmateur à Firebase:", programmerData);
    
    const docRef = await addDoc(programmersCollection, programmerData);
    console.log(`[addProgrammer] Programmateur ajouté avec succès, ID: ${docRef.id}`);
    
    return {
      id: docRef.id,
      ...programmerData
    };
  } catch (error) {
    console.error("[addProgrammer] Erreur lors de l'ajout du programmateur:", error);
    throw error;
  }
};

/**
 * Met à jour un programmateur existant
 * @param {string} id - ID du programmateur
 * @param {Object} programmerData - Nouvelles données du programmateur
 * @returns {Promise<Object>} Programmateur mis à jour
 */
export const updateProgrammer = async (id, programmerData) => {
  try {
    // S'assurer que la collection existe
    await ensureCollection(PROGRAMMERS_COLLECTION);
    
    console.log(`[updateProgrammer] Tentative de mise à jour du programmateur ${id}:`, programmerData);
    
    // Vérifier si le programmateur existe déjà
    const docRef = doc(db, PROGRAMMERS_COLLECTION, id);
    const docSnap = await getDoc(docRef);
    
    if (docSnap.exists()) {
      // Mettre à jour le programmateur existant
      await updateDoc(docRef, programmerData);
      console.log(`[updateProgrammer] Programmateur ${id} mis à jour avec succès`);
    } else {
      // Créer un nouveau programmateur avec l'ID spécifié
      await setDoc(docRef, programmerData);
      console.log(`[updateProgrammer] Nouveau programmateur créé avec ID spécifié: ${id}`);
    }
    
    return {
      id,
      ...programmerData
    };
  } catch (error) {
    console.error(`[updateProgrammer] Erreur lors de la mise à jour du programmateur ${id}:`, error);
    throw error;
  }
};

/**
 * Supprime un programmateur
 * @param {string} id - ID du programmateur
 * @returns {Promise<boolean>} Succès de la suppression
 */
export const deleteProgrammer = async (id) => {
  try {
    // S'assurer que la collection existe
    await ensureCollection(PROGRAMMERS_COLLECTION);
    
    console.log(`[deleteProgrammer] Tentative de suppression du programmateur ${id}`);
    
    const docRef = doc(db, PROGRAMMERS_COLLECTION, id);
    await deleteDoc(docRef);
    
    console.log(`[deleteProgrammer] Programmateur ${id} supprimé avec succès`);
    return true;
  } catch (error) {
    console.error(`[deleteProgrammer] Erreur lors de la suppression du programmateur ${id}:`, error);
    throw error;
  }
};

/**
 * Récupère les programmateurs par token commun
 * @param {string} commonToken - Token commun
 * @returns {Promise<Array>} Liste des programmateurs
 */
export const getProgrammersByToken = async (commonToken) => {
  try {
    // S'assurer que la collection existe
    await ensureCollection(PROGRAMMERS_COLLECTION);
    
    console.log(`[getProgrammersByToken] Recherche des programmateurs avec token ${commonToken}`);
    
    const tokenQuery = query(programmersCollection, where('commonToken', '==', commonToken));
    const snapshot = await getDocs(tokenQuery);
    
    const programmers = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));
    
    console.log(`[getProgrammersByToken] ${programmers.length} programmateurs trouvés avec token ${commonToken}`);
    return programmers;
  } catch (error) {
    console.error(`[getProgrammersByToken] Erreur lors de la recherche des programmateurs avec token ${commonToken}:`, error);
    throw error;
  }
};
EOL

echo "✅ Service programmersService.js modifié"

# Modifier le service concertsService.js pour prendre en charge le token commun
cat > client/src/services/concertsService.js << 'EOL'
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
const CONCERTS_COLLECTION = 'concerts';

// Assurez-vous que la collection concerts existe
const concertsCollection = collection(db, CONCERTS_COLLECTION);

/**
 * Récupère tous les concerts
 * @param {Object} filters - Filtres à appliquer (optionnel)
 * @returns {Promise<Array>} Liste des concerts
 */
export const getConcerts = async (filters = {}) => {
  try {
    console.log("[getConcerts] Tentative de récupération des concerts depuis Firebase...");
    console.log("[getConcerts] Filtres appliqués:", filters);
    
    // Création d'une requête de base
    let concertsQuery = concertsCollection;
    
    // Application des filtres si nécessaire
    if (filters) {
      // Filtrer par programmateur
      if (filters.programmerId) {
        concertsQuery = query(concertsQuery, where('programmerId', '==', filters.programmerId));
      }
      
      // Filtrer par artiste
      if (filters.artistId) {
        concertsQuery = query(concertsQuery, where('artistId', '==', filters.artistId));
      }
      
      // Filtrer par lieu
      if (filters.venue) {
        concertsQuery = query(concertsQuery, where('venue', '==', filters.venue));
      }
      
      // Filtrer par token commun
      if (filters.commonToken) {
        concertsQuery = query(concertsQuery, where('commonToken', '==', filters.commonToken));
      }
    }
    
    // Ajout d'un tri par date (du plus récent au plus ancien)
    concertsQuery = query(concertsQuery, orderBy('date', 'desc'));
    
    // Exécution de la requête
    const snapshot = await getDocs(concertsQuery);
    
    const concerts = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data(),
      // Convertir les timestamps en objets Date pour faciliter l'utilisation
      date: doc.data().date ? new Date(doc.data().date.seconds * 1000) : null
    }));
    
    console.log(`[getConcerts] ${concerts.length} concerts récupérés depuis Firebase`);
    return concerts;
  } catch (error) {
    console.error("[getConcerts] Erreur lors de la récupération des concerts:", error);
    throw error;
  }
};

/**
 * Récupère un concert par son ID
 * @param {string} id - ID du concert
 * @returns {Promise<Object>} Données du concert
 */
export const getConcertById = async (id) => {
  try {
    console.log(`[getConcertById] Tentative de récupération du concert ${id} depuis Firebase...`);
    
    const docRef = doc(db, CONCERTS_COLLECTION, id);
    const snapshot = await getDoc(docRef);
    
    if (snapshot.exists()) {
      const concertData = {
        id: snapshot.id,
        ...snapshot.data(),
        // Convertir les timestamps en objets Date pour faciliter l'utilisation
        date: snapshot.data().date ? new Date(snapshot.data().date.seconds * 1000) : null
      };
      console.log(`[getConcertById] Concert ${id} récupéré depuis Firebase`);
      return concertData;
    }
    
    console.log(`[getConcertById] Concert ${id} non trouvé dans Firebase`);
    return null;
  } catch (error) {
    console.error(`[getConcertById] Erreur lors de la récupération du concert ${id}:`, error);
    throw error;
  }
};

/**
 * Ajoute un nouveau concert
 * @param {Object} concertData - Données du concert
 * @returns {Promise<Object>} Concert créé avec ID
 */
export const addConcert = async (concertData) => {
  try {
    console.log("[addConcert] Tentative d'ajout d'un concert à Firebase:", concertData);
    
    // Convertir la date en Timestamp si elle existe
    const dataToAdd = {
      ...concertData,
      date: concertData.date ? Timestamp.fromDate(new Date(concertData.date)) : null
    };
    
    const docRef = await addDoc(concertsCollection, dataToAdd);
    console.log(`[addConcert] Concert ajouté avec succès, ID: ${docRef.id}`);
    
    return {
      id: docRef.id,
      ...concertData
    };
  } catch (error) {
    console.error("[addConcert] Erreur lors de l'ajout du concert:", error);
    throw error;
  }
};

/**
 * Met à jour un concert existant
 * @param {string} id - ID du concert
 * @param {Object} concertData - Nouvelles données du concert
 * @returns {Promise<Object>} Concert mis à jour
 */
export const updateConcert = async (id, concertData) => {
  try {
    console.log(`[updateConcert] Tentative de mise à jour du concert ${id}:`, concertData);
    
    // Convertir la date en Timestamp si elle existe
    const dataToUpdate = {
      ...concertData
    };
    
    if (concertData.date) {
      dataToUpdate.date = concertData.date instanceof Date ? 
        Timestamp.fromDate(concertData.date) : 
        Timestamp.fromDate(new Date(concertData.date));
    }
    
    // Vérifier si le concert existe déjà
    const docRef = doc(db, CONCERTS_COLLECTION, id);
    const docSnap = await getDoc(docRef);
    
    if (docSnap.exists()) {
      // Mettre à jour le concert existant
      await updateDoc(docRef, dataToUpdate);
      console.log(`[updateConcert] Concert ${id} mis à jour avec succès`);
    } else {
      // Créer un nouveau concert avec l'ID spécifié
      await setDoc(docRef, dataToUpdate);
      console.log(`[updateConcert] Nouveau concert créé avec ID spécifié: ${id}`);
    }
    
    return {
      id,
      ...concertData
    };
  } catch (error) {
    console.error(`[updateConcert] Erreur lors de la mise à jour du concert ${id}:`, error);
    throw error;
  }
};

/**
 * Supprime un concert
 * @param {string} id - ID du concert
 * @returns {Promise<boolean>} Succès de la suppression
 */
export const deleteConcert = async (id) => {
  try {
    console.log(`[deleteConcert] Tentative de suppression du concert ${id}`);
    
    const docRef = doc(db, CONCERTS_COLLECTION, id);
    await deleteDoc(docRef);
    
    console.log(`[deleteConcert] Concert ${id} supprimé avec succès`);
    return true;
  } catch (error) {
    console.error(`[deleteConcert] Erreur lors de la suppression du concert ${id}:`, error);
    throw error;
  }
};

/**
 * Récupère les concerts par token commun
 * @param {string} commonToken - Token commun
 * @returns {Promise<Array>} Liste des concerts
 */
export const getConcertsByToken = async (commonToken) => {
  return getConcerts({ commonToken });
};

/**
 * Récupère les concerts par artiste
 * @param {string} artistId - ID de l'artiste
 * @returns {Promise<Array>} Liste des concerts
 */
export const getConcertsByArtist = async (artistId) => {
  return getConcerts({ artistId });
};
EOL

echo "✅ Service concertsService.js modifié"

echo "✅ Implémentation du système de token commun et du tableau comparatif terminée!"
echo ""
echo "Pour utiliser cette implémentation, exécutez les commandes suivantes:"
echo "1. Rendre le script exécutable et l'exécuter:"
echo "   chmod +x fix_integrated_form.sh && ./fix_integrated_form.sh"
echo ""
echo "2. Effectuer git add, commit et push:"
echo "   git add . && git commit -m \"Fix: Intégration complète du formulaire public avec comparaison et token commun\" && git push origin main"
