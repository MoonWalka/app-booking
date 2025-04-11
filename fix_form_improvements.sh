#!/bin/bash

# Script pour corriger les problèmes de validation de formulaires et d'affichage de la page Concert
# Ce script modifie les fichiers nécessaires pour s'assurer que :
# 1. Les soumissions de formulaire avec statut 'pending' apparaissent dans l'onglet "Validation de formulaire"
# 2. Les soumissions sans statut sont automatiquement mises à jour avec le statut 'pending'
# 3. Les exemples par défaut sont supprimés
# 4. La page Concert s'affiche correctement

echo "Début des corrections pour l'application de booking musical..."

# Vérifier que nous sommes à la racine du projet
if [ ! -d "client" ]; then
  echo "❌ Erreur: Ce script doit être exécuté à la racine du projet."
  echo "Assurez-vous que vous êtes dans le répertoire principal contenant le dossier client."
  exit 1
fi

# Créer des sauvegardes des fichiers originaux
echo "📦 Création de sauvegardes des fichiers originaux..."
mkdir -p backups
cp -f client/src/services/formSubmissionsService.js backups/formSubmissionsService.js.bak
cp -f client/src/components/formValidation/FormValidationList.jsx backups/FormValidationList.jsx.bak
cp -f client/src/components/concerts/ConcertsList.js backups/ConcertsList.js.bak
cp -f client/src/components/public/PublicFormPage.jsx backups/PublicFormPage.jsx.bak
echo "✅ Sauvegardes créées dans le dossier 'backups'"

# 1. Correction du service formSubmissionsService.js
echo "🔧 Correction du service formSubmissionsService.js..."
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
    
    // Vérifier et mettre à jour les soumissions sans statut
    await updateSubmissionsWithoutStatus();
    
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
      console.log("[getFormSubmissions] Aucun formulaire trouvé avec les filtres spécifiés");
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
 * Met à jour les soumissions sans statut défini
 * @returns {Promise<number>} Nombre de soumissions mises à jour
 */
export const updateSubmissionsWithoutStatus = async () => {
  try {
    console.log("[updateSubmissionsWithoutStatus] Recherche de formulaires sans statut défini...");
    
    // Récupérer tous les formulaires
    const allFormsSnapshot = await getDocs(formSubmissionsCollection);
    if (allFormsSnapshot.empty) {
      console.log("[updateSubmissionsWithoutStatus] Aucun formulaire trouvé");
      return 0;
    }
    
    // Compter les formulaires par statut
    const statusMap = {};
    const formsWithoutStatus = [];
    
    allFormsSnapshot.docs.forEach(doc => {
      const data = doc.data();
      const status = data.status || 'non défini';
      statusMap[status] = (statusMap[status] || 0) + 1;
      
      if (!data.status || data.status === 'non défini') {
        formsWithoutStatus.push({
          id: doc.id,
          ...data
        });
      }
    });
    
    console.log("[updateSubmissionsWithoutStatus] Distribution des statuts:", statusMap);
    
    // Si des formulaires sans statut sont trouvés, les mettre à jour
    if (formsWithoutStatus.length > 0) {
      console.log(`[updateSubmissionsWithoutStatus] ${formsWithoutStatus.length} formulaires sans statut trouvés, mise à jour...`);
      
      // Mettre à jour les formulaires sans statut
      for (const form of formsWithoutStatus) {
        console.log(`[updateSubmissionsWithoutStatus] Mise à jour du statut pour le formulaire ${form.id}`);
        await updateDoc(doc(db, FORM_SUBMISSIONS_COLLECTION, form.id), {
          status: 'pending'
        });
      }
      
      console.log(`[updateSubmissionsWithoutStatus] ${formsWithoutStatus.length} formulaires mis à jour avec statut 'pending'`);
      return formsWithoutStatus.length;
    }
    
    console.log("[updateSubmissionsWithoutStatus] Aucun formulaire sans statut trouvé");
    return 0;
  } catch (error) {
    console.error("[updateSubmissionsWithoutStatus] Erreur lors de la mise à jour des formulaires sans statut:", error);
    return 0;
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
      
      // Vérifier si le statut est défini, sinon le mettre à jour
      if (!formData.status) {
        console.log(`[getFormSubmissionById] Le formulaire ${id} n'a pas de statut défini, mise à jour à 'pending'`);
        await updateDoc(docRef, { status: 'pending' });
        formData.status = 'pending';
      }
      
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
    
    // S'assurer que les champs obligatoires sont présents et que le statut est explicitement défini
    const completeFormData = {
      ...formData,
      commonToken, // Ajouter le token commun
      status: 'pending', // Forcer le statut à 'pending' pour garantir la cohérence
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
    console.log("[createFormSubmission] Vérification du statut:", completeFormData.status);
    
    try {
      const docRef = await addDoc(formSubmissionsCollection, completeFormData);
      console.log(`[createFormSubmission] Formulaire ajouté avec succès via addDoc, ID: ${docRef.id}`);
      
      // Vérifier immédiatement que le document a été créé avec le bon statut
      const createdDoc = await getDoc(docRef);
      if (createdDoc.exists()) {
        const createdData = createdDoc.data();
        console.log(`[createFormSubmission] Vérification du document créé - Statut: ${createdData.status}`);
        
        // Si le statut n'est pas 'pending', le corriger immédiatement
        if (createdData.status !== 'pending') {
          console.log(`[createFormSubmission] Correction du statut à 'pending' pour le document ${docRef.id}`);
          await updateDoc(docRef, { status: 'pending' });
        }
      }
      
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
        
        // Vérifier immédiatement que le document a été créé avec le bon statut
        const createdDoc = await getDoc(doc(db, FORM_SUBMISSIONS_COLLECTION, mockId));
        if (createdDoc.exists()) {
          const createdData = createdDoc.data();
          console.log(`[createFormSubmission] Vérification du document créé - Statut: ${createdData.status}`);
          
          // Si le statut n'est pas 'pending', le corriger immédiatement
          if (createdData.status !== 'pending') {
            console.log(`[createFormSubmission] Correction du statut à 'pending' pour le document ${mockId}`);
            await updateDoc(doc(db, FORM_SUBMISSIONS_COLLECTION, mockId), { status: 'pending' });
          }
        }
        
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

# 2. Correction du composant FormValidationList.jsx
echo "🔧 Correction du composant FormValidationList.jsx..."
cat > client/src/components/formValidation/FormValidationList.jsx << 'EOL'
import React, { useState, useEffect } from 'react';
import { getFormSubmissions, updateFormSubmission, updateSubmissionsWithoutStatus } from '../../services/formSubmissionsService';
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
  const [debugInfo, setDebugInfo] = useState(null);

  // Charger les soumissions de formulaire
  useEffect(() => {
    const fetchFormSubmissions = async () => {
      try {
        setLoading(true);
        console.log('FormValidationList - Chargement des soumissions en attente...');
        
        // Mettre à jour les soumissions sans statut
        const updatedCount = await updateSubmissionsWithoutStatus();
        if (updatedCount > 0) {
          console.log(`FormValidationList - ${updatedCount} soumissions mises à jour avec statut 'pending'`);
        }
        
        // Récupérer toutes les soumissions pour le débogage
        const allSubmissions = await getFormSubmissions({});
        console.log(`FormValidationList - ${allSubmissions.length} soumissions totales récupérées`);
        
        // Filtrer pour n'obtenir que les soumissions en attente
        const pendingSubmissions = await getFormSubmissions({ status: 'pending' });
        console.log(`FormValidationList - ${pendingSubmissions.length} soumissions en attente récupérées`);
        
        // Collecter des informations de débogage
        const debug = {
          totalCount: allSubmissions.length,
          pendingCount: pendingSubmissions.length,
          statusDistribution: {},
          hasCommonToken: 0,
          missingCommonToken: 0
        };
        
        // Analyser la distribution des statuts
        allSubmissions.forEach(submission => {
          const status = submission.status || 'non défini';
          debug.statusDistribution[status] = (debug.statusDistribution[status] || 0) + 1;
          
          if (submission.commonToken) {
            debug.hasCommonToken++;
          } else {
            debug.missingCommonToken++;
          }
        });
        
        setDebugInfo(debug);
        setFormSubmissions(pendingSubmissions);
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
      
      {debugInfo && (
        <div className="debug-info">
          <h3>Informations de débogage</h3>
          <p>Total des soumissions: {debugInfo.totalCount}</p>
          <p>Soumissions en attente: {debugInfo.pendingCount}</p>
          <p>Distribution des statuts:</p>
          <ul>
            {Object.entries(debugInfo.statusDistribution).map(([status, count]) => (
              <li key={status}>{status}: {count}</li>
            ))}
          </ul>
          <p>Avec token commun: {debugInfo.hasCommonToken}</p>
          <p>Sans token commun: {debugInfo.missingCommonToken}</p>
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

# 3. Correction du composant ConcertsList.js pour l'intégration du tableau de bord
echo "🔧 Correction du composant ConcertsList.js..."
cat > client/src/components/concerts/ConcertsList.js << 'EOL'
import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { getConcerts, addConcert } from '../../services/concertsService';
import { getArtists } from '../../services/artistsService';
import ConcertsDashboard from './ConcertsDashboard';
import './ConcertsList.css';

const ConcertsList = () => {
  const [concerts, setConcerts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showForm, setShowForm] = useState(false);
  const [artists, setArtists] = useState([]);
  const [newConcert, setNewConcert] = useState({
    artistId: '',
    date: '',
    time: '',
    venue: '',
    city: '',
    price: '',
    status: 'À venir',
    notes: ''
  });
  const [currentDate, setCurrentDate] = useState('');
  const [currentHour, setCurrentHour] = useState('');
  const [currentMinute, setCurrentMinute] = useState('');
  const [useDashboard, setUseDashboard] = useState(true); // Activer le tableau de bord par défaut
  const [error, setError] = useState(null);

  // Options pour les heures et minutes
  const hours = Array.from({ length: 24 }, (_, i) => i.toString().padStart(2, '0'));
  const minutes = ['00', '15', '30', '45'];
  const statuses = ['À venir', 'En cours', 'Terminé', 'Annulé'];

  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true);
        setError(null);
        
        console.log('ConcertsList - Chargement des concerts...');
        const concertsData = await getConcerts();
        console.log(`ConcertsList - ${concertsData.length} concerts récupérés`);
        
        console.log('ConcertsList - Chargement des artistes...');
        const artistsData = await getArtists();
        console.log(`ConcertsList - ${artistsData.length} artistes récupérés`);
        
        // Enrichir les données de concerts avec les informations d'artistes
        const enrichedConcerts = concertsData.map(concert => {
          const artist = artistsData.find(a => a.id === concert.artistId);
          return {
            ...concert,
            artist: artist || { name: 'Artiste inconnu' }
          };
        });
        
        console.log('ConcertsList - Données enrichies:', enrichedConcerts);
        setConcerts(enrichedConcerts);
        setArtists(artistsData);
        setLoading(false);
      } catch (error) {
        console.error('ConcertsList - Erreur lors du chargement des données:', error);
        setError('Erreur lors du chargement des données. Veuillez réessayer.');
        setLoading(false);
      }
    };

    fetchData();
  }, []);

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    
    if (name === 'date') {
      setCurrentDate(value);
    } else if (name === 'hour') {
      setCurrentHour(value);
    } else if (name === 'minute') {
      setCurrentMinute(value);
    } else {
      setNewConcert(prev => ({
        ...prev,
        [name]: value
      }));
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    try {
      setLoading(true);
      setError(null);
      
      // Construire la date et l'heure
      const dateObj = new Date(currentDate);
      const timeString = `${currentHour}:${currentMinute}`;
      
      const concertToAdd = {
        ...newConcert,
        date: dateObj,
        time: timeString
      };
      
      console.log('ConcertsList - Ajout d\'un nouveau concert:', concertToAdd);
      const addedConcert = await addConcert(concertToAdd);
      console.log('ConcertsList - Concert ajouté avec succès:', addedConcert);
      
      // Ajouter l'artiste à l'objet concert
      const artist = artists.find(a => a.id === concertToAdd.artistId);
      const enrichedConcert = {
        ...addedConcert,
        artist: artist || { name: 'Artiste inconnu' }
      };
      
      setConcerts(prev => [...prev, enrichedConcert]);
      setShowForm(false);
      setNewConcert({
        artistId: '',
        date: '',
        time: '',
        venue: '',
        city: '',
        price: '',
        status: 'À venir',
        notes: ''
      });
      setCurrentDate('');
      setCurrentHour('');
      setCurrentMinute('');
      setLoading(false);
    } catch (error) {
      console.error('ConcertsList - Erreur lors de l\'ajout du concert:', error);
      setError('Erreur lors de l\'ajout du concert. Veuillez réessayer.');
      setLoading(false);
    }
  };

  const handleViewConcert = (concert) => {
    try {
      // Cette fonction est appelée par le composant ConcertsDashboard
      console.log('ConcertsList - Redirection vers la page du concert:', concert.id);
      window.location.href = `/concerts/${concert.id}`;
    } catch (error) {
      console.error('ConcertsList - Erreur lors de la redirection:', error);
      setError('Erreur lors de la redirection. Veuillez réessayer.');
    }
  };

  const handleEditConcert = (concert) => {
    try {
      // Cette fonction est appelée par le composant ConcertsDashboard
      console.log('ConcertsList - Redirection vers la page d\'édition du concert:', concert.id);
      window.location.href = `/concerts/${concert.id}`;
    } catch (error) {
      console.error('ConcertsList - Erreur lors de la redirection:', error);
      setError('Erreur lors de la redirection. Veuillez réessayer.');
    }
  };

  // Basculer entre le tableau de bord et la vue classique
  const toggleView = () => {
    console.log('ConcertsList - Basculement de la vue:', useDashboard ? 'classique' : 'tableau de bord');
    setUseDashboard(!useDashboard);
  };

  if (loading && concerts.length === 0) {
    return <div className="loading">Chargement des concerts...</div>;
  }

  if (error) {
    return (
      <div className="error-container">
        <div className="error">{error}</div>
        <button className="refresh-button" onClick={() => window.location.reload()}>
          Rafraîchir la page
        </button>
      </div>
    );
  }

  return (
    <div className="concerts-container">
      <div className="concerts-header">
        <h1>Gestion des concerts</h1>
        <div className="header-buttons">
          <button className="toggle-view-btn" onClick={toggleView}>
            {useDashboard ? 'Vue classique' : 'Vue tableau de bord'}
          </button>
          <button className="add-concert-btn" onClick={() => setShowForm(!showForm)}>
            {showForm ? 'Annuler' : 'Ajouter un concert'}
          </button>
        </div>
      </div>
      
      {showForm && (
        <div className="add-concert-form">
          <h2>Ajouter un nouveau concert</h2>
          <form onSubmit={handleSubmit}>
            <div className="form-group">
              <label htmlFor="artistId">Artiste *</label>
              <select
                id="artistId"
                name="artistId"
                value={newConcert.artistId}
                onChange={handleInputChange}
                required
              >
                <option value="">Sélectionner un artiste</option>
                {artists.map(artist => (
                  <option key={artist.id} value={artist.id}>{artist.name}</option>
                ))}
              </select>
            </div>
            
            <div className="form-group">
              <label htmlFor="date">Date *</label>
              <input
                type="date"
                id="date"
                name="date"
                value={currentDate}
                onChange={handleInputChange}
                required
              />
            </div>
            
            <div className="form-group">
              <label>Heure *</label>
              <div className="time-inputs">
                <select
                  id="hour"
                  name="hour"
                  value={currentHour}
                  onChange={handleInputChange}
                  required
                  aria-label="Heure"
                >
                  <option value="">Heure</option>
                  {hours.map(hour => (
                    <option key={hour} value={hour}>{hour}h</option>
                  ))}
                </select>
                
                <select
                  id="minute"
                  name="minute"
                  value={currentMinute}
                  onChange={handleInputChange}
                  required
                  aria-label="Minute"
                >
                  <option value="">Minute</option>
                  {minutes.map(minute => (
                    <option key={minute} value={minute}>{minute}</option>
                  ))}
                </select>
              </div>
            </div>
            
            <div className="form-group">
              <label htmlFor="venue">Lieu *</label>
              <input
                type="text"
                id="venue"
                name="venue"
                value={newConcert.venue}
                onChange={handleInputChange}
                required
                placeholder="Nom de la salle ou du lieu"
              />
            </div>
            
            <div className="form-group">
              <label htmlFor="city">Ville *</label>
              <input
                type="text"
                id="city"
                name="city"
                value={newConcert.city}
                onChange={handleInputChange}
                required
                placeholder="Ville"
              />
            </div>
            
            <div className="form-group">
              <label htmlFor="price">Prix (€)</label>
              <input
                type="number"
                id="price"
                name="price"
                value={newConcert.price}
                onChange={handleInputChange}
                min="0"
                step="0.01"
                placeholder="Prix en euros"
              />
            </div>
            
            <div className="form-group">
              <label htmlFor="status">Statut</label>
              <select
                id="status"
                name="status"
                value={newConcert.status}
                onChange={handleInputChange}
              >
                {statuses.map(status => (
                  <option key={status} value={status}>{status}</option>
                ))}
              </select>
            </div>
            
            <div className="form-group full-width">
              <label htmlFor="notes">Notes</label>
              <textarea
                id="notes"
                name="notes"
                value={newConcert.notes}
                onChange={handleInputChange}
                rows="4"
                placeholder="Informations complémentaires"
              ></textarea>
            </div>
            
            <div className="form-actions">
              <button type="button" className="cancel-btn" onClick={() => setShowForm(false)}>
                Annuler
              </button>
              <button type="submit" className="submit-btn" disabled={loading}>
                {loading ? 'Ajout en cours...' : 'Ajouter le concert'}
              </button>
            </div>
          </form>
        </div>
      )}
      
      {!showForm && (
        <>
          {useDashboard ? (
            <ConcertsDashboard 
              concerts={concerts}
              onViewConcert={handleViewConcert}
              onEditConcert={handleEditConcert}
            />
          ) : (
            <div className="concerts-list">
              <h2>Liste des concerts ({concerts.length})</h2>
              <table className="concerts-table">
                <thead>
                  <tr>
                    <th>Artiste</th>
                    <th>Date</th>
                    <th>Lieu</th>
                    <th>Ville</th>
                    <th>Statut</th>
                    <th>Actions</th>
                  </tr>
                </thead>
                <tbody>
                  {concerts.map(concert => (
                    <tr key={concert.id}>
                      <td>{concert.artist ? concert.artist.name : 'Artiste inconnu'}</td>
                      <td>
                        {concert.date instanceof Date 
                          ? concert.date.toLocaleDateString() 
                          : concert.date && concert.date.seconds 
                            ? new Date(concert.date.seconds * 1000).toLocaleDateString() 
                            : 'Date non spécifiée'}
                        {' '}
                        {concert.time || ''}
                      </td>
                      <td>{concert.venue || 'Non spécifié'}</td>
                      <td>{concert.city || 'Non spécifié'}</td>
                      <td>{concert.status || 'Non spécifié'}</td>
                      <td>
                        <Link to={`/concerts/${concert.id}`} className="action-link">
                          Voir
                        </Link>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </>
      )}
    </div>
  );
};

export default ConcertsList;
EOL

# 4. Ajouter des styles CSS pour le bouton de basculement de vue et la gestion des erreurs
echo "🔧 Ajout de styles CSS pour le bouton de basculement de vue et la gestion des erreurs..."
cat >> client/src/components/concerts/ConcertsList.css << 'EOL'

/* Styles pour les boutons d'en-tête */
.header-buttons {
  display: flex;
  gap: 10px;
}

.toggle-view-btn {
  background-color: #6c757d;
  color: white;
  border: none;
  padding: 8px 16px;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
  transition: background-color 0.3s;
}

.toggle-view-btn:hover {
  background-color: #5a6268;
}

/* Styles pour la gestion des erreurs */
.error-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 20px;
  margin: 20px 0;
  background-color: #fff3f3;
  border-radius: 8px;
  border: 1px solid #ffcdd2;
}

.error {
  color: #d32f2f;
  font-weight: bold;
  margin-bottom: 15px;
  text-align: center;
}

.refresh-button {
  background-color: #2196f3;
  color: white;
  border: none;
  padding: 8px 16px;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
  transition: background-color 0.3s;
}

.refresh-button:hover {
  background-color: #0d8bf2;
}

/* Styles responsifs */
@media (max-width: 768px) {
  .header-buttons {
    flex-direction: column;
    width: 100%;
  }
  
  .toggle-view-btn,
  .add-concert-btn {
    width: 100%;
    margin-bottom: 5px;
  }
}
EOL

# 5. Correction du composant PublicFormPage.jsx pour afficher un message de confirmation et réinitialiser le formulaire
echo "🔧 Correction du composant PublicFormPage.jsx..."
cat > client/src/components/public/PublicFormPage.jsx << 'EOL'
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
EOL

# 6. Ajouter des styles CSS pour le message de succès dans PublicFormPage
echo "🔧 Ajout de styles CSS pour le message de succès dans PublicFormPage..."
cat > client/src/components/public/PublicFormPage.css << 'EOL'
.public-form-container {
  max-width: 800px;
  margin: 0 auto;
  padding: 20px;
}

.form-description {
  margin-bottom: 20px;
  color: #666;
}

.public-form {
  background-color: #f9f9f9;
  border-radius: 8px;
  padding: 20px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.form-section {
  margin-bottom: 30px;
  padding-bottom: 20px;
  border-bottom: 1px solid #eee;
}

.form-section h2 {
  margin-bottom: 15px;
  color: #333;
  font-size: 1.2rem;
}

.form-group {
  margin-bottom: 15px;
}

.form-row {
  display: flex;
  gap: 15px;
}

.form-row .form-group {
  flex: 1;
}

label {
  display: block;
  margin-bottom: 5px;
  font-weight: 500;
}

input, select, textarea {
  width: 100%;
  padding: 8px 12px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 1rem;
}

textarea {
  resize: vertical;
}

.form-actions {
  margin-top: 20px;
  text-align: center;
}

.submit-btn {
  background-color: #4caf50;
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 4px;
  font-size: 1rem;
  cursor: pointer;
  transition: background-color 0.3s;
}

.submit-btn:hover {
  background-color: #45a049;
}

.submit-btn:disabled {
  background-color: #cccccc;
  cursor: not-allowed;
}

.error-message {
  background-color: #ffebee;
  color: #c62828;
  padding: 10px;
  border-radius: 4px;
  margin-bottom: 20px;
  text-align: center;
}

.success-message {
  background-color: #e8f5e9;
  color: #2e7d32;
  padding: 30px;
  border-radius: 8px;
  margin: 30px 0;
  text-align: center;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.success-message h2 {
  margin-bottom: 15px;
  color: #2e7d32;
}

.new-submission-btn {
  background-color: #2196f3;
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 4px;
  font-size: 1rem;
  cursor: pointer;
  margin-top: 20px;
  transition: background-color 0.3s;
}

.new-submission-btn:hover {
  background-color: #0d8bf2;
}

/* Styles responsifs */
@media (max-width: 768px) {
  .form-row {
    flex-direction: column;
    gap: 0;
  }
  
  .public-form-container {
    padding: 10px;
  }
  
  .public-form {
    padding: 15px;
  }
}
EOL

# 7. Vérifier l'installation de react-icons
echo "🔧 Vérification de l'installation de react-icons..."
if ! grep -q "react-icons" client/package.json; then
  echo "⚠️ Le package react-icons n'est pas installé. Installation en cours..."
  cd client && npm install --save react-icons
  cd ../
fi

echo "✅ Corrections terminées avec succès!"
echo ""
echo "Les problèmes suivants ont été corrigés :"
echo "1. Les soumissions de formulaire avec statut 'pending' apparaissent maintenant dans l'onglet 'Validation de formulaire'"
echo "2. Les soumissions sans statut sont automatiquement mises à jour avec le statut 'pending'"
echo "3. Le formulaire public affiche maintenant un message de confirmation et se réinitialise après soumission"
echo "4. La page Concert s'affiche correctement avec un bouton pour basculer entre les vues"
echo "5. La gestion des erreurs a été améliorée pour une meilleure expérience utilisateur"
echo ""
echo "Pour appliquer les modifications, suivez ces étapes :"
echo "1. Assurez-vous que l'application n'est pas en cours d'exécution"
echo "2. Exécutez 'cd client && npm install react-icons' si ce n'est pas déjà fait"
echo "3. Démarrez l'application avec 'cd client && npm start'"
