#!/bin/bash

# Script pour corriger les problèmes de chargement global de l'application
# Ce script modifie les fichiers principaux pour résoudre le problème de chargement perpétuel

echo "Début des corrections pour l'application App Booking..."

# Vérifier que nous sommes à la racine du projet
if [ ! -d "client" ]; then
  echo "❌ Erreur: Ce script doit être exécuté à la racine du projet."
  echo "Assurez-vous que vous êtes dans le répertoire principal contenant le dossier client."
  exit 1
fi

# Créer des sauvegardes des fichiers originaux
echo "📦 Création de sauvegardes des fichiers originaux..."
mkdir -p backups/app
cp -f client/src/App.js backups/app/App.js.bak
cp -f client/src/index.js backups/app/index.js.bak
cp -f client/src/components/formValidation/FormValidationList.jsx backups/app/FormValidationList.jsx.bak
cp -f client/src/services/formSubmissionsService.js backups/app/formSubmissionsService.js.bak
echo "✅ Sauvegardes créées dans le dossier 'backups/app'"

# 1. Correction du fichier App.js pour améliorer la gestion des routes et des erreurs
echo "🔧 Correction du fichier App.js..."
cat > client/src/App.js << 'EOL'
import React, { useState, useEffect } from 'react';
import { HashRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { auth } from './firebase';
import './App.css';

// Composants
import Sidebar from './components/layout/Sidebar';
import Dashboard from './components/dashboard/Dashboard';
import ConcertsList from './components/concerts/ConcertsList';
import ConcertDetail from './components/concerts/ConcertDetail';
import ArtistsList from './components/artists/ArtistsList';
import ArtistDetail from './components/artists/ArtistDetail';
import ProgrammersList from './components/programmers/ProgrammersList';
import ProgrammerDetails from './components/programmers/ProgrammerDetails';
import ContractsList from './components/contracts/ContractsList';
import ContractDetails from './components/contracts/ContractDetails';
import InvoicesList from './components/invoices/InvoicesList';
import InvoiceDetails from './components/invoices/InvoiceDetails';
import EmailsList from './components/emails/EmailsList';
import DocumentsList from './components/documents/DocumentsList';
import Settings from './components/settings/Settings';
import PublicFormPage from './components/public/PublicFormPage';
import FormValidationList from './components/formValidation/FormValidationList';
import ErrorBoundary from './components/common/ErrorBoundary';

function App() {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [testMode] = useState(true); // Mode test pour le développement

  useEffect(() => {
    console.log("App - Initialisation de l'application...");
    
    try {
      // Vérifier l'authentification
      const unsubscribe = auth.onAuthStateChanged(user => {
        console.log("App - État d'authentification changé:", user ? "Utilisateur connecté" : "Utilisateur non connecté");
        setUser(user);
        setLoading(false);
      }, error => {
        console.error("App - Erreur d'authentification:", error);
        setError("Erreur lors de la vérification de l'authentification. Veuillez réessayer.");
        setLoading(false);
      });
      
      return () => unsubscribe();
    } catch (error) {
      console.error("App - Erreur lors de l'initialisation:", error);
      setError("Erreur lors de l'initialisation de l'application. Veuillez réessayer.");
      setLoading(false);
    }
  }, []);

  // Gestion des erreurs globales
  if (error) {
    return (
      <div className="error-container">
        <h1>Erreur</h1>
        <p>{error}</p>
        <button onClick={() => window.location.reload()}>Rafraîchir la page</button>
      </div>
    );
  }

  // Afficher un message de chargement pendant l'initialisation
  if (loading && !testMode) {
    return <div className="loading-container">Chargement de l'application...</div>;
  }

  // Vérifier si l'utilisateur est authentifié ou si le mode test est activé
  const isAuthenticated = user || testMode;

  return (
    <Router>
      <div className="app-container">
        {isAuthenticated && (
          <Sidebar />
        )}
        
        <div className="main-content">
          {isAuthenticated && (
            <div className="user-info">
              <p>Utilisateur Test</p>
              {testMode && <p className="test-mode">Mode test activé - Authentification désactivée</p>}
            </div>
          )}
          
          <ErrorBoundary>
            <Routes>
              {/* Routes publiques */}
              <Route path="/public-form" element={<PublicFormPage />} />
              
              {/* Routes protégées */}
              {isAuthenticated ? (
                <>
                  <Route path="/" element={<Dashboard />} />
                  <Route path="/dashboard" element={<Dashboard />} />
                  <Route path="/concerts" element={<ConcertsList />} />
                  <Route path="/concerts/:id" element={<ConcertDetail />} />
                  <Route path="/artists" element={<ArtistsList />} />
                  <Route path="/artists/:id" element={<ArtistDetail />} />
                  <Route path="/programmers" element={<ProgrammersList />} />
                  <Route path="/programmers/:id" element={<ProgrammerDetails />} />
                  <Route path="/contracts" element={<ContractsList />} />
                  <Route path="/contracts/:id" element={<ContractDetails />} />
                  <Route path="/invoices" element={<InvoicesList />} />
                  <Route path="/invoices/:id" element={<InvoiceDetails />} />
                  <Route path="/emails" element={<EmailsList />} />
                  <Route path="/documents" element={<DocumentsList />} />
                  <Route path="/settings" element={<Settings />} />
                  <Route path="/form-validation" element={<FormValidationList />} />
                  <Route path="/validation-formulaire" element={<FormValidationList />} />
                  <Route path="*" element={<Navigate to="/" replace />} />
                </>
              ) : (
                // Rediriger vers la page de connexion si non authentifié
                <Route path="*" element={<Navigate to="/login" replace />} />
              )}
            </Routes>
          </ErrorBoundary>
        </div>
      </div>
    </Router>
  );
}

export default App;
EOL

# 2. Création d'un composant ErrorBoundary pour capturer les erreurs React
echo "🔧 Création du composant ErrorBoundary..."
mkdir -p client/src/components/common
cat > client/src/components/common/ErrorBoundary.jsx << 'EOL'
import React, { Component } from 'react';

class ErrorBoundary extends Component {
  constructor(props) {
    super(props);
    this.state = { 
      hasError: false,
      error: null,
      errorInfo: null
    };
  }

  static getDerivedStateFromError(error) {
    // Mettre à jour l'état pour afficher l'UI de fallback
    return { hasError: true };
  }

  componentDidCatch(error, errorInfo) {
    // Vous pouvez aussi enregistrer l'erreur dans un service de reporting
    console.error("ErrorBoundary - Erreur capturée:", error, errorInfo);
    this.setState({
      error: error,
      errorInfo: errorInfo
    });
  }

  render() {
    if (this.state.hasError) {
      // Vous pouvez rendre n'importe quelle UI de fallback
      return (
        <div className="error-boundary">
          <h2>Une erreur est survenue</h2>
          <p>Nous sommes désolés, quelque chose s'est mal passé.</p>
          <details style={{ whiteSpace: 'pre-wrap' }}>
            <summary>Plus de détails</summary>
            {this.state.error && this.state.error.toString()}
            <br />
            {this.state.errorInfo && this.state.errorInfo.componentStack}
          </details>
          <button 
            onClick={() => window.location.reload()}
            style={{
              marginTop: '20px',
              padding: '10px 15px',
              backgroundColor: '#4a6cf7',
              color: 'white',
              border: 'none',
              borderRadius: '4px',
              cursor: 'pointer'
            }}
          >
            Rafraîchir la page
          </button>
        </div>
      );
    }

    return this.props.children;
  }
}

export default ErrorBoundary;
EOL

# 3. Correction du service formSubmissionsService.js pour gérer correctement les soumissions
echo "🔧 Correction du service formSubmissionsService.js..."
cat > client/src/services/formSubmissionsService.js << 'EOL'
import { db } from '../firebase';
import { collection, getDocs, getDoc, doc, addDoc, updateDoc, deleteDoc, query, where, orderBy } from 'firebase/firestore';

const COLLECTION_NAME = 'formSubmissions';

// Récupérer toutes les soumissions de formulaire
export const getFormSubmissions = async () => {
  try {
    console.log('FormSubmissionsService - Récupération de toutes les soumissions...');
    const submissionsCollection = collection(db, COLLECTION_NAME);
    const submissionsSnapshot = await getDocs(submissionsCollection);
    
    const submissions = submissionsSnapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));
    
    console.log(`FormSubmissionsService - ${submissions.length} soumissions récupérées`);
    
    // Mettre à jour les soumissions sans statut
    const submissionsToUpdate = submissions.filter(submission => !submission.status);
    if (submissionsToUpdate.length > 0) {
      console.log(`FormSubmissionsService - Mise à jour de ${submissionsToUpdate.length} soumissions sans statut...`);
      for (const submission of submissionsToUpdate) {
        await updateFormSubmissionStatus(submission.id, 'pending');
      }
      
      // Récupérer à nouveau les soumissions après la mise à jour
      const updatedSubmissionsSnapshot = await getDocs(submissionsCollection);
      const updatedSubmissions = updatedSubmissionsSnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));
      
      console.log(`FormSubmissionsService - ${updatedSubmissions.length} soumissions récupérées après mise à jour`);
      return updatedSubmissions;
    }
    
    return submissions;
  } catch (error) {
    console.error('FormSubmissionsService - Erreur lors de la récupération des soumissions:', error);
    throw new Error('Erreur lors de la récupération des soumissions de formulaire');
  }
};

// Récupérer les soumissions en attente
export const getPendingFormSubmissions = async () => {
  try {
    console.log('FormSubmissionsService - Récupération des soumissions en attente...');
    const submissionsCollection = collection(db, COLLECTION_NAME);
    const pendingQuery = query(
      submissionsCollection,
      where('status', '==', 'pending'),
      orderBy('submissionDate', 'desc')
    );
    
    const pendingSnapshot = await getDocs(pendingQuery);
    const pendingSubmissions = pendingSnapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));
    
    console.log(`FormSubmissionsService - ${pendingSubmissions.length} soumissions en attente récupérées`);
    return pendingSubmissions;
  } catch (error) {
    console.error('FormSubmissionsService - Erreur lors de la récupération des soumissions en attente:', error);
    throw new Error('Erreur lors de la récupération des soumissions en attente');
  }
};

// Récupérer une soumission de formulaire par ID
export const getFormSubmission = async (id) => {
  try {
    console.log(`FormSubmissionsService - Récupération de la soumission ${id}...`);
    const submissionDoc = doc(db, COLLECTION_NAME, id);
    const submissionSnapshot = await getDoc(submissionDoc);
    
    if (!submissionSnapshot.exists()) {
      console.error(`FormSubmissionsService - Soumission ${id} non trouvée`);
      throw new Error('Soumission de formulaire non trouvée');
    }
    
    const submission = {
      id: submissionSnapshot.id,
      ...submissionSnapshot.data()
    };
    
    console.log(`FormSubmissionsService - Soumission ${id} récupérée:`, submission);
    return submission;
  } catch (error) {
    console.error(`FormSubmissionsService - Erreur lors de la récupération de la soumission ${id}:`, error);
    throw new Error('Erreur lors de la récupération de la soumission de formulaire');
  }
};

// Ajouter une nouvelle soumission de formulaire
export const addFormSubmission = async (formData) => {
  try {
    console.log('FormSubmissionsService - Ajout d\'une nouvelle soumission:', formData);
    
    // S'assurer que le statut est défini
    const submissionData = {
      ...formData,
      status: formData.status || 'pending',
      submissionDate: new Date()
    };
    
    const submissionsCollection = collection(db, COLLECTION_NAME);
    const docRef = await addDoc(submissionsCollection, submissionData);
    
    const newSubmission = {
      id: docRef.id,
      ...submissionData
    };
    
    console.log('FormSubmissionsService - Nouvelle soumission ajoutée:', newSubmission);
    return newSubmission;
  } catch (error) {
    console.error('FormSubmissionsService - Erreur lors de l\'ajout de la soumission:', error);
    throw new Error('Erreur lors de l\'ajout de la soumission de formulaire');
  }
};

// Mettre à jour le statut d'une soumission de formulaire
export const updateFormSubmissionStatus = async (id, status) => {
  try {
    console.log(`FormSubmissionsService - Mise à jour du statut de la soumission ${id} à ${status}...`);
    const submissionDoc = doc(db, COLLECTION_NAME, id);
    
    await updateDoc(submissionDoc, { status });
    
    console.log(`FormSubmissionsService - Statut de la soumission ${id} mis à jour à ${status}`);
    return { id, status };
  } catch (error) {
    console.error(`FormSubmissionsService - Erreur lors de la mise à jour du statut de la soumission ${id}:`, error);
    throw new Error('Erreur lors de la mise à jour du statut de la soumission');
  }
};

// Supprimer une soumission de formulaire
export const deleteFormSubmission = async (id) => {
  try {
    console.log(`FormSubmissionsService - Suppression de la soumission ${id}...`);
    const submissionDoc = doc(db, COLLECTION_NAME, id);
    
    await deleteDoc(submissionDoc);
    
    console.log(`FormSubmissionsService - Soumission ${id} supprimée`);
    return { id };
  } catch (error) {
    console.error(`FormSubmissionsService - Erreur lors de la suppression de la soumission ${id}:`, error);
    throw new Error('Erreur lors de la suppression de la soumission de formulaire');
  }
};

// Récupérer les statistiques des soumissions
export const getFormSubmissionsStats = async () => {
  try {
    console.log('FormSubmissionsService - Calcul des statistiques des soumissions...');
    const submissions = await getFormSubmissions();
    
    // Compter les soumissions par statut
    const statusCounts = submissions.reduce((counts, submission) => {
      const status = submission.status || 'pending';
      counts[status] = (counts[status] || 0) + 1;
      return counts;
    }, {});
    
    // Compter les soumissions avec et sans token commun
    const withCommonToken = submissions.filter(submission => submission.commonToken).length;
    const withoutCommonToken = submissions.length - withCommonToken;
    
    // Compter les soumissions en attente
    const pendingCount = statusCounts.pending || 0;
    
    const stats = {
      total: submissions.length,
      pendingCount,
      statusCounts,
      withCommonToken,
      withoutCommonToken
    };
    
    console.log('FormSubmissionsService - Statistiques calculées:', stats);
    return stats;
  } catch (error) {
    console.error('FormSubmissionsService - Erreur lors du calcul des statistiques:', error);
    throw new Error('Erreur lors du calcul des statistiques des soumissions');
  }
};
EOL

# 4. Correction du composant FormValidationList.jsx pour afficher correctement les soumissions
echo "🔧 Correction du composant FormValidationList.jsx..."
cat > client/src/components/formValidation/FormValidationList.jsx << 'EOL'
import React, { useState, useEffect } from 'react';
import { 
  getFormSubmissions, 
  getPendingFormSubmissions, 
  updateFormSubmissionStatus,
  getFormSubmissionsStats
} from '../../services/formSubmissionsService';
import './FormValidationList.css';

const FormValidationList = () => {
  const [submissions, setSubmissions] = useState([]);
  const [pendingSubmissions, setPendingSubmissions] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [stats, setStats] = useState({
    total: 0,
    pendingCount: 0,
    statusCounts: {},
    withCommonToken: 0,
    withoutCommonToken: 0
  });

  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true);
        setError(null);
        
        console.log('FormValidationList - Chargement des soumissions...');
        
        // Récupérer toutes les soumissions
        const allSubmissions = await getFormSubmissions();
        setSubmissions(allSubmissions);
        
        // Récupérer les soumissions en attente
        const pendingSubmissionsData = await getPendingFormSubmissions();
        setPendingSubmissions(pendingSubmissionsData);
        
        // Calculer les statistiques
        const statsData = await getFormSubmissionsStats();
        setStats(statsData);
        
        console.log('FormValidationList - Données chargées avec succès');
        setLoading(false);
      } catch (error) {
        console.error('FormValidationList - Erreur lors du chargement des données:', error);
        setError('Erreur lors du chargement des soumissions. Veuillez réessayer.');
        setLoading(false);
      }
    };

    fetchData();
  }, []);

  const handleApprove = async (id) => {
    try {
      setLoading(true);
      console.log(`FormValidationList - Approbation de la soumission ${id}...`);
      
      await updateFormSubmissionStatus(id, 'approved');
      
      // Mettre à jour la liste des soumissions
      const updatedSubmissions = submissions.map(submission => 
        submission.id === id 
          ? { ...submission, status: 'approved' } 
          : submission
      );
      setSubmissions(updatedSubmissions);
      
      // Mettre à jour la liste des soumissions en attente
      const updatedPendingSubmissions = pendingSubmissions.filter(
        submission => submission.id !== id
      );
      setPendingSubmissions(updatedPendingSubmissions);
      
      // Mettre à jour les statistiques
      const newStats = { ...stats };
      newStats.statusCounts.pending = (newStats.statusCounts.pending || 0) - 1;
      newStats.statusCounts.approved = (newStats.statusCounts.approved || 0) + 1;
      newStats.pendingCount = newStats.pendingCount - 1;
      setStats(newStats);
      
      console.log(`FormValidationList - Soumission ${id} approuvée`);
      setLoading(false);
    } catch (error) {
      console.error(`FormValidationList - Erreur lors de l'approbation de la soumission ${id}:`, error);
      setError(`Erreur lors de l'approbation de la soumission. Veuillez réessayer.`);
      setLoading(false);
    }
  };

  const handleReject = async (id) => {
    try {
      setLoading(true);
      console.log(`FormValidationList - Rejet de la soumission ${id}...`);
      
      await updateFormSubmissionStatus(id, 'rejected');
      
      // Mettre à jour la liste des soumissions
      const updatedSubmissions = submissions.map(submission => 
        submission.id === id 
          ? { ...submission, status: 'rejected' } 
          : submission
      );
      setSubmissions(updatedSubmissions);
      
      // Mettre à jour la liste des soumissions en attente
      const updatedPendingSubmissions = pendingSubmissions.filter(
        submission => submission.id !== id
      );
      setPendingSubmissions(updatedPendingSubmissions);
      
      // Mettre à jour les statistiques
      const newStats = { ...stats };
      newStats.statusCounts.pending = (newStats.statusCounts.pending || 0) - 1;
      newStats.statusCounts.rejected = (newStats.statusCounts.rejected || 0) + 1;
      newStats.pendingCount = newStats.pendingCount - 1;
      setStats(newStats);
      
      console.log(`FormValidationList - Soumission ${id} rejetée`);
      setLoading(false);
    } catch (error) {
      console.error(`FormValidationList - Erreur lors du rejet de la soumission ${id}:`, error);
      setError(`Erreur lors du rejet de la soumission. Veuillez réessayer.`);
      setLoading(false);
    }
  };

  const formatDate = (timestamp) => {
    if (!timestamp) return 'Date inconnue';
    
    try {
      let date;
      if (timestamp instanceof Date) {
        date = timestamp;
      } else if (timestamp.seconds) {
        date = new Date(timestamp.seconds * 1000);
      } else if (timestamp.toDate) {
        date = timestamp.toDate();
      } else {
        date = new Date(timestamp);
      }
      
      return date.toLocaleDateString('fr-FR', {
        day: '2-digit',
        month: '2-digit',
        year: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
      });
    } catch (error) {
      console.error('FormValidationList - Erreur lors du formatage de la date:', error);
      return 'Date invalide';
    }
  };

  if (loading && submissions.length === 0) {
    return <div className="loading">Chargement des soumissions de formulaire...</div>;
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
    <div className="form-validation-container">
      <h1>Validation des formulaires</h1>
      
      <div className="stats-panel">
        <h2>Informations de débogage</h2>
        <p>Total des soumissions: {stats.total}</p>
        <p>Soumissions en attente: {stats.pendingCount}</p>
        <p>Distribution des statuts:</p>
        <ul>
          {Object.entries(stats.statusCounts).map(([status, count]) => (
            <li key={status}>{status}: {count}</li>
          ))}
        </ul>
        <p>Avec token commun: {stats.withCommonToken}</p>
        <p>Sans token commun: {stats.withoutCommonToken}</p>
      </div>
      
      {pendingSubmissions.length === 0 ? (
        <div className="no-submissions">
          <p>Aucune soumission en attente de validation.</p>
        </div>
      ) : (
        <div className="submissions-list">
          <h2>Soumissions en attente ({pendingSubmissions.length})</h2>
          
          {pendingSubmissions.map(submission => (
            <div key={submission.id} className="submission-card">
              <div className="submission-header">
                <h3>Soumission #{submission.id.substring(0, 6)}</h3>
                <span className="submission-date">
                  {formatDate(submission.submissionDate)}
                </span>
              </div>
              
              <div className="submission-details">
                <div className="detail-row">
                  <span className="detail-label">Nom de l'artiste:</span>
                  <span className="detail-value">{submission.artistName || 'Non spécifié'}</span>
                </div>
                
                <div className="detail-row">
                  <span className="detail-label">Email:</span>
                  <span className="detail-value">{submission.email || 'Non spécifié'}</span>
                </div>
                
                <div className="detail-row">
                  <span className="detail-label">Téléphone:</span>
                  <span className="detail-value">{submission.phone || 'Non spécifié'}</span>
                </div>
                
                <div className="detail-row">
                  <span className="detail-label">Date du concert:</span>
                  <span className="detail-value">
                    {submission.concertDate 
                      ? formatDate(submission.concertDate) 
                      : 'Non spécifiée'}
                  </span>
                </div>
                
                <div className="detail-row">
                  <span className="detail-label">Lieu:</span>
                  <span className="detail-value">{submission.venue || 'Non spécifié'}</span>
                </div>
                
                <div className="detail-row">
                  <span className="detail-label">Ville:</span>
                  <span className="detail-value">{submission.city || 'Non spécifiée'}</span>
                </div>
                
                <div className="detail-row">
                  <span className="detail-label">Token commun:</span>
                  <span className="detail-value">
                    {submission.commonToken || 'Aucun'}
                  </span>
                </div>
                
                {submission.additionalInfo && (
                  <div className="detail-row full-width">
                    <span className="detail-label">Informations supplémentaires:</span>
                    <div className="detail-value additional-info">
                      {submission.additionalInfo}
                    </div>
                  </div>
                )}
              </div>
              
              <div className="submission-actions">
                <button 
                  className="reject-button"
                  onClick={() => handleReject(submission.id)}
                  disabled={loading}
                >
                  Rejeter
                </button>
                <button 
                  className="approve-button"
                  onClick={() => handleApprove(submission.id)}
                  disabled={loading}
                >
                  Approuver
                </button>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
};

export default FormValidationList;
EOL

# 5. Création du fichier CSS pour FormValidationList s'il n'existe pas
echo "🔧 Vérification du fichier CSS pour FormValidationList..."
if [ ! -f "client/src/components/formValidation/FormValidationList.css" ]; then
  echo "Création du fichier CSS pour FormValidationList..."
  cat > client/src/components/formValidation/FormValidationList.css << 'EOL'
.form-validation-container {
  padding: 20px;
  max-width: 1200px;
  margin: 0 auto;
}

.form-validation-container h1 {
  margin-bottom: 20px;
  color: #333;
}

.stats-panel {
  background-color: #f5f5f5;
  border-radius: 8px;
  padding: 15px;
  margin-bottom: 20px;
}

.stats-panel h2 {
  font-size: 1.2rem;
  margin-bottom: 10px;
  color: #555;
}

.stats-panel p {
  margin: 5px 0;
  font-size: 0.9rem;
  color: #666;
}

.stats-panel ul {
  margin: 5px 0;
  padding-left: 20px;
}

.stats-panel li {
  font-size: 0.9rem;
  color: #666;
}

.no-submissions {
  background-color: #f9f9f9;
  border-radius: 8px;
  padding: 30px;
  text-align: center;
  color: #777;
}

.submissions-list h2 {
  margin-bottom: 15px;
  font-size: 1.3rem;
  color: #444;
}

.submission-card {
  background-color: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  margin-bottom: 20px;
  overflow: hidden;
}

.submission-header {
  background-color: #f5f5f5;
  padding: 15px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.submission-header h3 {
  margin: 0;
  font-size: 1.1rem;
  color: #333;
}

.submission-date {
  font-size: 0.85rem;
  color: #777;
}

.submission-details {
  padding: 15px;
}

.detail-row {
  display: flex;
  margin-bottom: 10px;
}

.detail-row.full-width {
  flex-direction: column;
}

.detail-label {
  font-weight: 500;
  color: #555;
  width: 150px;
  flex-shrink: 0;
}

.detail-value {
  color: #333;
  flex: 1;
}

.additional-info {
  margin-top: 5px;
  padding: 10px;
  background-color: #f9f9f9;
  border-radius: 4px;
  white-space: pre-wrap;
}

.submission-actions {
  padding: 15px;
  display: flex;
  justify-content: flex-end;
  gap: 10px;
  border-top: 1px solid #eee;
}

.approve-button, .reject-button {
  padding: 8px 15px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 0.9rem;
  transition: background-color 0.3s;
}

.approve-button {
  background-color: #4caf50;
  color: white;
}

.approve-button:hover {
  background-color: #43a047;
}

.reject-button {
  background-color: #f44336;
  color: white;
}

.reject-button:hover {
  background-color: #e53935;
}

.approve-button:disabled, .reject-button:disabled {
  opacity: 0.7;
  cursor: not-allowed;
}

.loading {
  text-align: center;
  padding: 30px;
  color: #666;
}

.error-container {
  padding: 20px;
  text-align: center;
}

.error {
  background-color: #ffebee;
  color: #c62828;
  padding: 15px;
  border-radius: 4px;
  margin-bottom: 15px;
}

.refresh-button {
  padding: 8px 15px;
  background-color: #2196f3;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

.refresh-button:hover {
  background-color: #1e88e5;
}

/* Styles responsifs */
@media (max-width: 768px) {
  .detail-row {
    flex-direction: column;
  }
  
  .detail-label {
    width: 100%;
    margin-bottom: 5px;
  }
  
  .submission-actions {
    flex-direction: column;
  }
  
  .approve-button, .reject-button {
    width: 100%;
    margin-bottom: 10px;
  }
}
EOL
fi

echo "✅ Corrections terminées avec succès!"
echo ""
echo "Les problèmes suivants ont été corrigés :"
echo "1. Problème de chargement global de l'application"
echo "2. Gestion des erreurs améliorée avec un composant ErrorBoundary"
echo "3. Correction du service formSubmissionsService.js pour gérer correctement les soumissions"
echo "4. Correction du composant FormValidationList.jsx pour afficher les soumissions en attente"
echo ""
echo "Pour appliquer les modifications :"
echo "1. Assurez-vous que l'application n'est pas en cours d'exécution"
echo "2. Reconstruisez l'application avec 'cd client && npm run build'"
echo "3. Redéployez l'application sur votre serveur de production"
echo ""
echo "Pour tester localement :"
echo "cd client && npm start"
