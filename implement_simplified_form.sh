#!/bin/bash

# Script pour implémenter la solution simplifiée utilisant l'ID du concert au lieu d'un token
echo "Début de l'implémentation de la solution simplifiée..."

# Créer des sauvegardes des fichiers originaux
echo "Création des sauvegardes..."
mkdir -p ./backups/$(date +%Y%m%d_%H%M%S)
cp ./client/src/App.js ./backups/$(date +%Y%m%d_%H%M%S)/App.js.backup
cp ./client/src/components/concerts/ConcertDetail.js ./backups/$(date +%Y%m%d_%H%M%S)/ConcertDetail.js.backup
cp ./client/src/components/public/PublicFormPage.jsx ./backups/$(date +%Y%m%d_%H%M%S)/PublicFormPage.jsx.backup

# Vérifier si le composant PublicRoute existe, sinon le créer
if [ ! -f "./client/src/components/public/PublicRoute.jsx" ]; then
  echo "Création du composant PublicRoute.jsx..."
  mkdir -p ./client/src/components/public
  cat > ./client/src/components/public/PublicRoute.jsx << 'EOL'
import React from 'react';
import { useAuth } from '../../context/AuthContext';

// Composant PublicRoute qui rend son contenu indépendamment de l'état d'authentification
const PublicRoute = ({ children }) => {
  const { loading } = useAuth();

  if (loading) {
    return <div>Chargement...</div>;
  }
  
  return children;
};

export default PublicRoute;
EOL
  echo "✅ Composant PublicRoute.jsx créé"
else
  echo "Le composant PublicRoute.jsx existe déjà"
fi

# Modification du fichier App.js
echo "Modification du fichier App.js..."
cat > ./client/src/App.js << 'EOL'
import React from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';
import { useAuth } from './context/AuthContext';
import './App.css';

// Composants protégés
import Layout from './components/common/Layout';
import Login from './components/auth/Login';
import NotFound from './components/common/NotFound';
import Dashboard from './components/dashboard/Dashboard';
import ProgrammersList from './components/programmers/ProgrammersList';
import ProgrammerDetail from './components/programmers/ProgrammerDetail';
import ConcertsList from './components/concerts/ConcertsList';
import ConcertDetail from './components/concerts/ConcertDetail';
import ArtistsList from './components/artists/ArtistsList';
import ArtistDetail from './components/artists/ArtistDetail';
import EmailSystem from './components/emails/EmailSystem';
import DocumentsManager from './components/documents/DocumentsManager';
import TestFirebaseIntegration from './components/tests/TestFirebaseIntegration';
import ArtistEdit from './components/artists/ArtistEdit';
import ContractsTable from './components/contracts/ContractsTable';
import FormValidationList from './components/formValidation/FormValidationList';

// Composants publics (affichés sans authentification)
import PublicFormPage from './components/public/PublicFormPage';
import FormSubmittedPage from './components/public/FormSubmittedPage';
import PublicRoute from './components/public/PublicRoute';

// Composant ProtectedRoute pour sécuriser les routes privées
const ProtectedRoute = ({ children }) => {
  const { isAuthenticated, loading, bypassEnabled } = useAuth();

  if (loading) {
    return <div>Chargement...</div>;
  }
  
  if (bypassEnabled) {
    console.log('Mode bypass d\'authentification activé - Accès autorisé');
    return children;
  }

  if (!isAuthenticated) {
    return <Navigate to="/login" />;
  }
  
  return children;
};

function App() {
  const { bypassEnabled, isAuthenticated } = useAuth();

  // Fonction pour vérifier si l'utilisateur est sur une route publique
  const isPublicRoute = (pathname) => {
    return pathname.startsWith('/form/') || pathname === '/form-submitted';
  };

  // Vérifier si l'URL actuelle est une route publique
  const currentPath = window.location.hash.substring(1); // Pour HashRouter
  const isOnPublicRoute = isPublicRoute(currentPath);

  // Si l'utilisateur est authentifié et tente d'accéder à une route publique,
  // ne pas rediriger vers le dashboard
  console.log('Current path:', currentPath, 'Is public route:', isOnPublicRoute);

  return (
    <div className="App">
      <Routes>
        {/* Routes publiques accessibles sans authentification */}
        {/* Modification de la route pour utiliser l'ID du concert au lieu d'un token */}
        <Route path="/form/:concertId" element={<PublicRoute><PublicFormPage /></PublicRoute>} />
        <Route path="/form-submitted" element={<PublicRoute><FormSubmittedPage /></PublicRoute>} />

        <Route path="/login" element={ bypassEnabled ? <Navigate to="/" /> : <Login /> } />
        
        {/* Routes protégées accessibles uniquement aux utilisateurs authentifiés */}
        <Route path="/" element={<ProtectedRoute><Layout /></ProtectedRoute>}>
          <Route index element={<Dashboard />} />
          <Route path="contrats" element={<ContractsTable />} />
          <Route path="factures" element={<div>Module Factures à venir</div>} />
          <Route path="programmateurs" element={<ProgrammersList />} />
          <Route path="programmateurs/:id" element={<ProgrammerDetail />} />
          <Route path="concerts" element={<ConcertsList />} />
          <Route path="concerts/:id" element={<ConcertDetail />} />
          <Route path="artistes" element={<ArtistsList />} />
          <Route path="artistes/:id" element={<ArtistDetail />} />
          <Route path="emails" element={<EmailSystem />} />
          <Route path="documents" element={<DocumentsManager />} />
          <Route path="validation-formulaires" element={<FormValidationList />} />
          <Route path="tests" element={<TestFirebaseIntegration />} />
        </Route>
        
        <Route path="*" element={<NotFound />} />
      </Routes>

      {bypassEnabled && (
        <div style={{
          position: 'fixed',
          bottom: 0,
          left: 0,
          right: 0,
          backgroundColor: '#fff3cd',
          color: '#856404',
          padding: '10px',
          textAlign: 'center',
          borderTop: '1px solid #ffeeba',
          zIndex: 1000
        }}>
          Mode test activé - Authentification désactivée
        </div>
      )}
    </div>
  );
}

export default App;
EOL
echo "✅ Fichier App.js modifié"

# Modification du fichier ConcertDetail.js
echo "Modification du fichier ConcertDetail.js..."
cat > ./client/src/components/concerts/ConcertDetail.js << 'EOL'
import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { getConcertById, updateConcert, deleteConcert } from '../../services/concertsService';
import { getArtists } from '../../services/artistsService';
import { getProgrammers } from '../../services/programmersService';
import './ConcertDetail.css';

const ConcertDetail = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const [concert, setConcert] = useState(null);
  const [artists, setArtists] = useState([]);
  const [programmers, setProgrammers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [isEditing, setIsEditing] = useState(false);
  const [showLinkModal, setShowLinkModal] = useState(false);
  const [linkCopied, setLinkCopied] = useState(false);
  const [formUrl, setFormUrl] = useState('');
  const [formData, setFormData] = useState({
    artist: { id: '', name: '' },
    programmer: { id: '', name: '', structure: '' },
    date: '',
    time: '',
    venue: '',
    city: '',
    price: '',
    status: 'En attente',
    notes: ''
  });

  // Statuts possibles pour un concert
  const statuses = [
    'En attente',
    'Confirmé',
    'Contrat envoyé',
    'Contrat signé',
    'Acompte reçu',
    'Soldé',
    'Annulé'
  ];
  
  // Générer les options pour les heures (00h à 23h)
  const hours = Array.from({ length: 24 }, (_, i) => 
    i < 10 ? `0${i}` : `${i}`
  );
  
  // Générer les options pour les minutes (00 à 59)
  const minutes = Array.from({ length: 60 }, (_, i) => 
    i < 10 ? `0${i}` : `${i}`
  );

  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true);
        console.log(`Tentative de récupération du concert avec l'ID: ${id}`);
        
        // Utiliser le service Firebase au lieu de fetch
        const concertData = await getConcertById(id);
        
        if (!concertData) {
          throw new Error('Concert non trouvé');
        }
        
        console.log('Concert récupéré:', concertData);
        setConcert(concertData);
        
        // Initialiser le formulaire avec les données du concert
        setFormData({
          artist: concertData.artist || { id: '', name: '' },
          programmer: concertData.programmer || { id: '', name: '', structure: '' },
          date: concertData.date || '',
          time: concertData.time || '',
          venue: concertData.venue || '',
          city: concertData.city || '',
          price: concertData.price ? concertData.price.toString() : '',
          status: concertData.status || 'En attente',
          notes: concertData.notes || ''
        });
        
        // Récupérer les artistes pour le formulaire d'édition
        console.log("Tentative de récupération des artistes...");
        const artistsData = await getArtists();
        console.log("Artistes récupérés:", artistsData);
        setArtists(artistsData);
        
        // Récupérer les programmateurs pour le formulaire d'édition
        console.log("Tentative de récupération des programmateurs...");
        const programmersData = await getProgrammers();
        console.log("Programmateurs récupérés:", programmersData);
        setProgrammers(programmersData);
        
        // Générer l'URL du formulaire directement avec l'ID du concert
        const baseUrl = window.location.origin;
        setFormUrl(`${baseUrl}/form/${id}`);
        
        setLoading(false);
      } catch (err) {
        console.error('Erreur lors de la récupération du concert:', err);
        setError(err.message);
        setLoading(false);
      }
    };

    fetchData();
  }, [id]);

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    
    if (name === 'artist') {
      const selectedArtist = artists.find(artist => artist.id === value);
      setFormData({
        ...formData,
        artist: {
          id: selectedArtist.id,
          name: selectedArtist.name
        }
      });
    } else if (name === 'programmer') {
      const selectedProgrammer = programmers.find(programmer => programmer.id === value);
      setFormData({
        ...formData,
        programmer: {
          id: selectedProgrammer.id,
          name: selectedProgrammer.name,
          structure: selectedProgrammer.structure || ''
        }
      });
    } else if (name === 'hour' || name === 'minute') {
      // Gérer les sélections d'heure et de minute
      const currentTime = formData.time ? formData.time.split(':') : ['00', '00'];
      const hour = name === 'hour' ? value : currentTime[0];
      const minute = name === 'minute' ? value : currentTime[1];
      
      setFormData({
        ...formData,
        time: `${hour}:${minute}`
      });
    } else {
      setFormData({
        ...formData,
        [name]: value
      });
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      setLoading(true);
      
      // Convertir price en nombre
      const concertData = {
        ...formData,
        price: parseFloat(formData.price) || 0
      };
      
      console.log("Données du concert à mettre à jour:", concertData);
      
      // Utiliser le service Firebase pour mettre à jour le concert
      await updateConcert(id, concertData);
      
      // Récupérer les données mises à jour
      const updatedData = await getConcertById(id);
      setConcert(updatedData);
      
      setIsEditing(false);
      setLoading(false);
    } catch (err) {
      console.error("Erreur lors de la mise à jour du concert:", err);
      setError(err.message);
      setLoading(false);
    }
  };

  const handleDelete = async () => {
    if (window.confirm('Êtes-vous sûr de vouloir supprimer ce concert ?')) {
      try {
        setLoading(true);
        
        // Utiliser le service Firebase pour supprimer le concert
        await deleteConcert(id);
        
        navigate('/concerts');
      } catch (err) {
        console.error("Erreur lors de la suppression du concert:", err);
        setError(err.message);
        setLoading(false);
      }
    }
  };

  // Nouvelle fonction simplifiée pour générer le lien du formulaire
  const handleGenerateFormLink = () => {
    try {
      // Vérifier si le concert a un programmateur associé
      if (!concert.programmer || !concert.programmer.id) {
        alert("Ce concert n'a pas de programmateur associé. Veuillez d'abord ajouter un programmateur.");
        return;
      }
      
      // Afficher la modal avec le lien direct
      setShowLinkModal(true);
    } catch (err) {
      console.error("Erreur lors de la génération du lien de formulaire:", err);
      setError(err.message);
      alert("Une erreur est survenue lors de la génération du lien de formulaire. Veuillez réessayer.");
    }
  };

  const handleCopyLink = () => {
    if (!formUrl) return;
    
    navigator.clipboard.writeText(formUrl)
      .then(() => {
        setLinkCopied(true);
        setTimeout(() => setLinkCopied(false), 3000);
      })
      .catch(err => {
        console.error("Erreur lors de la copie du lien:", err);
        alert("Impossible de copier le lien. Veuillez le sélectionner et le copier manuellement.");
      });
  };

  const closeLinkModal = () => {
    setShowLinkModal(false);
    setLinkCopied(false);
  };

  if (loading && !concert) return <div className="loading">Chargement des détails du concert...</div>;
  if (error) return <div className="error-message">Erreur: {error}</div>;
  if (!concert) return <div className="not-found">Concert non trouvé</div>;

  // Extraire l'heure et les minutes du temps actuel pour le formulaire d'édition
  const currentTime = formData.time ? formData.time.split(':') : ['', ''];
  const currentHour = currentTime[0];
  const currentMinute = currentTime[1];

  return (
    <div className="concert-detail-container">
      <h2>Détails du Concert</h2>
      
      {isEditing ? (
        <form onSubmit={handleSubmit} className="edit-form">
          <div className="form-group">
            <label htmlFor="artist">Artiste *</label>
            <select
              id="artist"
              name="artist"
              value={formData.artist.id}
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
            <label htmlFor="programmer">Programmateur *</label>
            <select
              id="programmer"
              name="programmer"
              value={formData.programmer.id}
              onChange={handleInputChange}
              required
            >
              <option value="">Sélectionner un programmateur</option>
              {programmers.map(programmer => (
                <option key={programmer.id} value={programmer.id}>
                  {programmer.name} ({programmer.structure || 'Structure non spécifiée'})
                </option>
              ))}
            </select>
          </div>
          
          <div className="form-group">
            <label htmlFor="date">Date *</label>
            <input
              type="date"
              id="date"
              name="date"
              value={formData.date}
              onChange={handleInputChange}
              required
            />
          </div>
          
          <div className="form-group time-selects">
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
              value={formData.venue}
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
              value={formData.city}
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
              value={formData.price}
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
              value={formData.status}
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
              value={formData.notes}
              onChange={handleInputChange}
              rows="4"
              placeholder="Informations complémentaires"
            ></textarea>
          </div>
          
          <div className="form-actions">
            <button type="button" className="cancel-btn" onClick={() => setIsEditing(false)}>
              Annuler
            </button>
            <button type="submit" className="save-btn" disabled={loading}>
              {loading ? 'Enregistrement...' : 'Enregistrer'}
            </button>
          </div>
        </form>
      ) : (
        <>
          <div className="concert-info">
            <div className="info-row">
              <span className="info-label">Artiste:</span>
              <span className="info-value">{concert.artist?.name || 'Non spécifié'}</span>
            </div>
            
            <div className="info-row">
              <span className="info-label">Programmateur:</span>
              <span className="info-value">
                {concert.programmer?.name || 'Non spécifié'}
                {concert.programmer?.structure && ` (${concert.programmer.structure})`}
              </span>
            </div>
            
            <div className="info-row">
              <span className="info-label">Date:</span>
              <span className="info-value">
                {concert.date ? new Date(concert.date).toLocaleDateString() : 'Non spécifiée'}
              </span>
            </div>
            
            <div className="info-row">
              <span className="info-label">Heure:</span>
              <span className="info-value">{concert.time || 'Non spécifiée'}</span>
            </div>
            
            <div className="info-row">
              <span className="info-label">Lieu:</span>
              <span className="info-value">{concert.venue || 'Non spécifié'}</span>
            </div>
            
            <div className="info-row">
              <span className="info-label">Ville:</span>
              <span className="info-value">{concert.city || 'Non spécifiée'}</span>
            </div>
            
            <div className="info-row">
              <span className="info-label">Prix:</span>
              <span className="info-value">
                {concert.price ? `${concert.price} €` : 'Non spécifié'}
              </span>
            </div>
            
            <div className="info-row">
              <span className="info-label">Statut:</span>
              <span className="info-value">{concert.status || 'Non spécifié'}</span>
            </div>
            
            {concert.notes && (
              <div className="info-row">
                <span className="info-label">Notes:</span>
                <span className="info-value">{concert.notes}</span>
              </div>
            )}
          </div>
          
          <div className="concert-actions">
            <button onClick={() => setIsEditing(true)} className="edit-btn">
              Modifier
            </button>
            <button onClick={handleDelete} className="delete-btn">
              Supprimer
            </button>
            <button onClick={handleGenerateFormLink} className="form-link-btn">
              Envoyer le formulaire
            </button>
          </div>
        </>
      )}
      
      {/* Modal pour afficher le lien du formulaire */}
      {showLinkModal && (
        <div className="modal-overlay">
          <div className="modal-content">
            <h3>Lien de formulaire</h3>
            <p>Partagez ce lien avec le programmateur pour qu'il puisse remplir le formulaire :</p>
            
            <div className="link-container">
              <input
                type="text"
                value={formUrl}
                readOnly
                onClick={(e) => e.target.select()}
              />
              <button onClick={handleCopyLink} className="copy-btn">
                {linkCopied ? 'Copié !' : 'Copier'}
              </button>
            </div>
            
            <button onClick={closeLinkModal} className="close-btn">
              Fermer
            </button>
          </div>
        </div>
      )}
    </div>
  );
};

export default ConcertDetail;
EOL
echo "✅ Fichier ConcertDetail.js modifié"

# Modification du fichier PublicFormPage.jsx
echo "Modification du fichier PublicFormPage.jsx..."
cat > ./client/src/components/public/PublicFormPage.jsx << 'EOL'
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
EOL
echo "✅ Fichier PublicFormPage.jsx modifié"

# Ajouter un style CSS pour le champ en lecture seule si le fichier CSS existe
if [ -f "./client/src/components/public/PublicFormPage.css" ]; then
  echo "Ajout du style pour le champ en lecture seule dans PublicFormPage.css..."
  cat >> ./client/src/components/public/PublicFormPage.css << 'EOL'

/* Style pour le champ en lecture seule */
.readonly-field {
  background-color: #f0f0f0;
  color: #666;
  cursor: not-allowed;
  border: 1px solid #ddd;
}
EOL
  echo "✅ Style ajouté à PublicFormPage.css"
else
  echo "Création du fichier PublicFormPage.css..."
  mkdir -p ./client/src/components/public
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

echo "✅ Implémentation terminée avec succès!"
echo "Pour tester la solution, redémarrez votre application React."
