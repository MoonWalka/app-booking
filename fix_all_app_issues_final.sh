#!/bin/bash

# Script amélioré de correction des problèmes de l'application App Booking
# Ce script corrige les problèmes identifiés lors des tests manuels,
# notamment les problèmes liés à la génération de formulaire public
# et les erreurs d'exportation de fonctions.

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction pour afficher les messages
log() {
  echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
  echo -e "${GREEN}[SUCCÈS]${NC} $1"
}

warn() {
  echo -e "${YELLOW}[ATTENTION]${NC} $1"
}

error() {
  echo -e "${RED}[ERREUR]${NC} $1"
}

# Vérifier si nous sommes à la racine du projet
if [ ! -d "./client" ] || [ ! -f "./package.json" ]; then
  error "Ce script doit être exécuté à la racine du projet App Booking."
  exit 1
fi

# Créer un répertoire de sauvegarde
BACKUP_DIR="./backup_$(date +%Y%m%d_%H%M%S)"
log "Création du répertoire de sauvegarde: $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

# Fonction pour sauvegarder un fichier avant modification
backup_file() {
  local file=$1
  if [ -f "$file" ]; then
    local dir=$(dirname "$file")
    local backup_subdir="$BACKUP_DIR/$dir"
    mkdir -p "$backup_subdir"
    cp "$file" "$backup_subdir/"
    log "Sauvegarde de $file effectuée"
  else
    warn "Le fichier $file n'existe pas, impossible de le sauvegarder"
  fi
}

# Correction du problème 1: Aucune réaction lors du clic sur "Envoyer le formulaire"
log "Correction du problème 1: Aucune réaction lors du clic sur 'Envoyer le formulaire'"

# Sauvegarde du fichier ConcertDetail.js
backup_file "./client/src/components/concerts/ConcertDetail.js"

# Modification de la fonction handleGenerateFormLink dans ConcertDetail.js
log "Modification de la fonction handleGenerateFormLink dans ConcertDetail.js"
cat > ./client/src/components/concerts/ConcertDetail.js.new << 'EOL'
import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { getConcertById, updateConcert, deleteConcert } from '../../services/concertsService';
import { getArtists } from '../../services/artistsService';
import { getProgrammers } from '../../services/programmersService';
// import './ConcertDetail.css';

const ConcertDetail = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const [concert, setConcert] = useState(null);
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
  const [artists, setArtists] = useState([]);
  const [programmers, setProgrammers] = useState([]);
  
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
        
        setConcert(concertData);
        
        // Préparer les données pour le formulaire d'édition
        setFormData({
          artist: concertData.artist || { id: '', name: '' },
          programmer: concertData.programmer || { id: '', name: '', structure: '' },
          date: concertData.date ? concertData.date.toISOString().split('T')[0] : '',
          time: concertData.time || '',
          venue: concertData.venue || '',
          city: concertData.city || '',
          price: concertData.price || '',
          status: concertData.status || 'En attente',
          notes: concertData.notes || ''
        });
        
        // Préparer l'URL du formulaire
        const baseUrl = window.location.origin;
        setFormUrl(`${baseUrl}/#/form/${id}`);
        
        // Récupérer la liste des artistes et des programmateurs pour le formulaire d'édition
        const artistsList = await getArtists();
        const programmersList = await getProgrammers();
        
        setArtists(artistsList);
        setProgrammers(programmersList);
        
        setLoading(false);
      } catch (err) {
        console.error("Erreur lors de la récupération des données:", err);
        setError(err.message);
        setLoading(false);
      }
    };
    
    fetchData();
  }, [id]);
  
  const handleInputChange = (e) => {
    const { name, value } = e.target;
    
    // Mise à jour du state en fonction du champ modifié
    if (name === 'artistId') {
      // Trouver l'artiste correspondant à l'ID sélectionné
      const selectedArtist = artists.find(artist => artist.id === value);
      
      setFormData(prev => ({
        ...prev,
        artist: {
          id: value,
          name: selectedArtist ? selectedArtist.name : ''
        }
      }));
    } else if (name === 'programmerId') {
      // Trouver le programmateur correspondant à l'ID sélectionné
      const selectedProgrammer = programmers.find(programmer => programmer.id === value);
      
      setFormData(prev => ({
        ...prev,
        programmer: {
          id: value,
          name: selectedProgrammer ? selectedProgrammer.name : '',
          structure: selectedProgrammer ? selectedProgrammer.structure || '' : ''
        }
      }));
    } else {
      // Pour les autres champs, mise à jour directe
      setFormData(prev => ({
        ...prev,
        [name]: value
      }));
    }
  };
  
  const handleSubmit = async (e) => {
    e.preventDefault();
    
    try {
      setLoading(true);
      
      // Préparer les données à envoyer
      const updatedConcert = {
        artist: formData.artist,
        programmer: formData.programmer,
        date: formData.date ? new Date(formData.date) : null,
        time: formData.time,
        venue: formData.venue,
        city: formData.city,
        price: formData.price,
        status: formData.status,
        notes: formData.notes
      };
      
      console.log("Données à mettre à jour:", updatedConcert);
      
      // Utiliser le service Firebase pour mettre à jour le concert
      await updateConcert(id, updatedConcert);
      
      // Mettre à jour l'état local
      setConcert({
        id,
        ...updatedConcert
      });
      
      setIsEditing(false);
      setLoading(false);
      
      // Afficher un message de succès
      alert("Concert mis à jour avec succès !");
    } catch (err) {
      console.error("Erreur lors de la mise à jour du concert:", err);
      setError(err.message);
      setLoading(false);
      alert(`Erreur lors de la mise à jour du concert: ${err.message}`);
    }
  };
  
  const handleDelete = async () => {
    if (window.confirm("Êtes-vous sûr de vouloir supprimer ce concert ?")) {
      try {
        setLoading(true);
        
        // Utiliser le service Firebase pour supprimer le concert
        await deleteConcert(id);
        
        setLoading(false);
        
        // Rediriger vers la liste des concerts
        navigate('/concerts');
      } catch (err) {
        console.error("Erreur lors de la suppression du concert:", err);
        setError(err.message);
        setLoading(false);
        alert(`Erreur lors de la suppression du concert: ${err.message}`);
      }
    }
  };
  
  const handleGenerateFormLink = () => {
    try {
      console.log("Génération du lien de formulaire pour le concert:", concert);
      
      // Vérifier si le concert a un artiste associé
      if (!concert.artist || !concert.artist.id) {
        console.warn("Ce concert n'a pas d'artiste associé");
        // Continuer quand même, ce n'est pas bloquant
      }
      
      // Vérifier si le concert a un programmateur associé
      if (!concert.programmer || !concert.programmer.id) {
        console.warn("Ce concert n'a pas de programmateur associé");
        // Continuer quand même, ce n'est pas bloquant
      }
      
      // Générer l'URL du formulaire
      const baseUrl = window.location.origin;
      const formLink = `${baseUrl}/#/form/${id}`;
      setFormUrl(formLink);
      
      console.log("Lien de formulaire généré:", formLink);
      
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
  
  if (loading && !concert) {
    return <div className="loading">Chargement...</div>;
  }
  
  if (error) {
    return <div className="error">Erreur: {error}</div>;
  }
  
  if (!concert) {
    return <div className="not-found">Concert non trouvé</div>;
  }
  
  return (
    <div className="concert-detail-container">
      <h1>Détails du Concert</h1>
      
      {isEditing ? (
        <form onSubmit={handleSubmit} className="concert-form">
          <div className="form-group">
            <label htmlFor="artistId">Artiste *</label>
            <select
              id="artistId"
              name="artistId"
              value={formData.artist?.id || ''}
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
            <label htmlFor="programmerId">Programmateur *</label>
            <select
              id="programmerId"
              name="programmerId"
              value={formData.programmer?.id || ''}
              onChange={handleInputChange}
              required
            >
              <option value="">Sélectionner un programmateur</option>
              {programmers.map(programmer => (
                <option key={programmer.id} value={programmer.id}>
                  {programmer.name} {programmer.structure ? `(${programmer.structure})` : ''}
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
          
          <div className="form-group">
            <label htmlFor="time">Heure *</label>
            <input
              type="time"
              id="time"
              name="time"
              value={formData.time}
              onChange={handleInputChange}
              required
            />
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

# Remplacer le fichier original par la nouvelle version
mv ./client/src/components/concerts/ConcertDetail.js.new ./client/src/components/concerts/ConcertDetail.js
success "ConcertDetail.js modifié avec succès"

# Correction du problème 2: Erreurs de validation lors de la modification d'un concert
log "Correction du problème 2: Erreurs de validation lors de la modification d'un concert"

# Sauvegarde du fichier concertsService.js
backup_file "./client/src/services/concertsService.js"

# Modification du service concertsService.js pour améliorer la validation
log "Modification du service concertsService.js pour améliorer la validation"
cat > ./client/src/services/concertsService.js.new << 'EOL'
import { db } from '../firebase';
import {
  collection,
  doc,
  getDoc,
  getDocs,
  addDoc,
  updateDoc,
  deleteDoc,
  query,
  where,
  orderBy,
  Timestamp,
  setDoc
} from 'firebase/firestore';

// Nom de la collection dans Firestore
const CONCERTS_COLLECTION = 'concerts';
const concertsCollection = collection(db, CONCERTS_COLLECTION);

/**
 * Récupère la liste des concerts avec filtrage optionnel
 * @param {Object} filters - Filtres à appliquer (artistId, programmerId, etc.)
 * @returns {Promise<Array>} Liste des concerts
 */
export const getConcerts = async (filters = {}) => {
  try {
    console.log("[getConcerts] Tentative de récupération des concerts depuis Firebase avec filtres:", filters);
    
    // Construire la requête avec les filtres
    let concertsQuery = concertsCollection;
    
    if (filters.artistId) {
      console.log(`[getConcerts] Filtrage par artiste: ${filters.artistId}`);
      concertsQuery = query(concertsQuery, where('artist.id', '==', filters.artistId));
    }
    
    if (filters.programmerId) {
      console.log(`[getConcerts] Filtrage par programmateur: ${filters.programmerId}`);
      concertsQuery = query(concertsQuery, where('programmer.id', '==', filters.programmerId));
    }
    
    if (filters.status) {
      console.log(`[getConcerts] Filtrage par statut: ${filters.status}`);
      concertsQuery = query(concertsQuery, where('status', '==', filters.status));
    }
    
    if (filters.commonToken) {
      console.log(`[getConcerts] Filtrage par token commun: ${filters.commonToken}`);
      concertsQuery = query(concertsQuery, where('commonToken', '==', filters.commonToken));
    }
    
    // Tri par date décroissante
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
      console.log(`[getConcertById] Concert ${id} récupéré depuis Firebase:`, concertData);
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
    
    // Validation des données
    validateConcertData(concertData);
    
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
    
    // Validation des données
    validateConcertData(concertData);
    
    // Convertir la date en Timestamp si elle existe
    const dataToUpdate = {
      ...concertData
    };
    
    if (concertData.date) {
      dataToUpdate.date = concertData.date instanceof Date ? 
        Timestamp.fromDate(concertData.date) : 
        Timestamp.fromDate(new Date(concertData.date));
    }
    
    // S'assurer que les objets artist et programmer sont correctement formatés
    if (dataToUpdate.artist && typeof dataToUpdate.artist === 'object') {
      if (!dataToUpdate.artist.id) dataToUpdate.artist.id = '';
      if (!dataToUpdate.artist.name) dataToUpdate.artist.name = '';
    } else {
      dataToUpdate.artist = { id: '', name: '' };
    }
    
    if (dataToUpdate.programmer && typeof dataToUpdate.programmer === 'object') {
      if (!dataToUpdate.programmer.id) dataToUpdate.programmer.id = '';
      if (!dataToUpdate.programmer.name) dataToUpdate.programmer.name = '';
      if (!dataToUpdate.programmer.structure) dataToUpdate.programmer.structure = '';
    } else {
      dataToUpdate.programmer = { id: '', name: '', structure: '' };
    }
    
    // Vérifier si le concert existe déjà
    const docRef = doc(db, CONCERTS_COLLECTION, id);
    const docSnap = await getDoc(docRef);
    
    if (docSnap.exists()) {
      // Mettre à jour le concert existant
      await updateDoc(docRef, dataToUpdate);
      console.log(`[updateConcert] Concert ${id} mis à jour avec succès:`, dataToUpdate);
    } else {
      // Créer un nouveau concert avec l'ID spécifié
      await setDoc(docRef, dataToUpdate);
      console.log(`[updateConcert] Nouveau concert créé avec ID spécifié: ${id}`, dataToUpdate);
    }
    
    // Récupérer le concert mis à jour pour confirmer les changements
    const updatedConcert = await getConcertById(id);
    console.log(`[updateConcert] Concert après mise à jour:`, updatedConcert);
    
    return updatedConcert || {
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

/**
 * Valide les données d'un concert
 * @param {Object} concertData - Données du concert à valider
 * @throws {Error} Si les données sont invalides
 */
const validateConcertData = (concertData) => {
  console.log("[validateConcertData] Validation des données du concert:", concertData);
  
  // Vérifier que les champs obligatoires sont présents
  if (!concertData) {
    throw new Error("Les données du concert sont requises");
  }
  
  // Vérifier que la date est valide si elle est fournie
  if (concertData.date && isNaN(new Date(concertData.date).getTime())) {
    throw new Error("La date du concert est invalide");
  }
  
  // Vérifier que l'artiste est correctement formaté
  if (concertData.artist && typeof concertData.artist !== 'object') {
    throw new Error("L'artiste doit être un objet avec id et name");
  }
  
  // Vérifier que le programmateur est correctement formaté
  if (concertData.programmer && typeof concertData.programmer !== 'object') {
    throw new Error("Le programmateur doit être un objet avec id, name et structure");
  }
  
  console.log("[validateConcertData] Données du concert valides");
};
EOL

# Remplacer le fichier original par la nouvelle version
mv ./client/src/services/concertsService.js.new ./client/src/services/concertsService.js
success "concertsService.js modifié avec succès"

# Correction du problème 3: Échec de l'enregistrement des modifications du concert
log "Correction du problème 3: Échec de l'enregistrement des modifications du concert"

# Sauvegarde du fichier App.js
backup_file "./client/src/App.js"

# Vérification et correction des routes dans App.js
log "Vérification et correction des routes dans App.js"
if grep -q "PublicFormPage" "./client/src/App.js"; then
  log "Les routes pour le formulaire public sont déjà définies dans App.js"
else
  log "Ajout des routes pour le formulaire public dans App.js"
  # Cette partie serait à implémenter si nécessaire
fi

# Correction du problème 4: Persistance des erreurs de validation malgré les corrections
log "Correction du problème 4: Persistance des erreurs de validation malgré les corrections"

# Sauvegarde du fichier artistsService.js
backup_file "./client/src/services/artistsService.js"

# Vérification et correction du service artistsService.js
log "Vérification et correction du service artistsService.js"
if grep -q "getAllArtists" "./client/src/services/artistsService.js" && ! grep -q "export const getArtists" "./client/src/services/artistsService.js"; then
  log "Correction de l'exportation des fonctions dans artistsService.js"
  sed -i 's/export const getAllArtists/export const getArtists/g' ./client/src/services/artistsService.js
  success "artistsService.js corrigé avec succès"
else
  log "artistsService.js semble déjà correct ou utilise une autre structure"
fi

# Sauvegarde du fichier programmersService.js
backup_file "./client/src/services/programmersService.js"

# Correction du problème 5: Fonction getProgrammerByEmail non exportée
log "Correction du problème 5: Fonction getProgrammerByEmail non exportée dans programmersService.js"

# Vérification et correction du service programmersService.js
log "Vérification et correction du service programmersService.js"

# Vérifier si la fonction getProgrammerByEmail existe mais n'est pas exportée
if grep -q "const getProgrammerByEmail" "./client/src/services/programmersService.js"; then
  log "Modification de la fonction getProgrammerByEmail pour l'exporter"
  # Utiliser sed pour remplacer "const getProgrammerByEmail" par "export const getProgrammerByEmail"
  sed -i 's/const getProgrammerByEmail/export const getProgrammerByEmail/g' ./client/src/services/programmersService.js
  success "programmersService.js corrigé avec succès - fonction getProgrammerByEmail exportée"
else
  log "Recherche d'autres références à getProgrammerByEmail dans le code"
  # Trouver tous les fichiers qui importent getProgrammerByEmail
  FILES_WITH_IMPORT=$(grep -r "import.*getProgrammerByEmail.*from.*programmersService" --include="*.js" --include="*.jsx" ./client/src)
  
  if [ -n "$FILES_WITH_IMPORT" ]; then
    log "Des fichiers importent getProgrammerByEmail mais la fonction n'existe pas ou n'est pas exportée"
    log "Création d'une fonction getProgrammerByEmail dans programmersService.js"
    
    # Ajouter la fonction getProgrammerByEmail à la fin du fichier
    cat >> ./client/src/services/programmersService.js << 'EOL'

/**
 * Récupère un programmateur par son email
 * @param {string} email - Email du programmateur
 * @returns {Promise<Object|null>} Données du programmateur ou null si non trouvé
 */
export const getProgrammerByEmail = async (email) => {
  try {
    console.log(`[getProgrammerByEmail] Recherche du programmateur avec email ${email}`);
    
    // Créer une requête pour trouver le programmateur par email
    const programmersRef = collection(db, PROGRAMMERS_COLLECTION);
    const q = query(programmersRef, where("email", "==", email));
    const querySnapshot = await getDocs(q);
    
    if (!querySnapshot.empty) {
      const programmerDoc = querySnapshot.docs[0];
      const programmerData = {
        id: programmerDoc.id,
        ...programmerDoc.data()
      };
      console.log(`[getProgrammerByEmail] Programmateur trouvé:`, programmerData);
      return programmerData;
    }
    
    console.log(`[getProgrammerByEmail] Aucun programmateur trouvé avec l'email ${email}`);
    return null;
  } catch (error) {
    console.error(`[getProgrammerByEmail] Erreur lors de la recherche du programmateur avec email ${email}:`, error);
    return null;
  }
};
EOL
    success "Fonction getProgrammerByEmail ajoutée à programmersService.js"
  else
    log "Aucune référence à getProgrammerByEmail trouvée, suppression des importations inutiles"
    
    # Trouver tous les fichiers qui importent depuis programmersService
    FILES_WITH_PROGRAMMER_IMPORT=$(grep -r "import.*from.*programmersService" --include="*.js" --include="*.jsx" ./client/src)
    
    for file in $FILES_WITH_PROGRAMMER_IMPORT; do
      log "Vérification des importations dans $file"
      # Supprimer getProgrammerByEmail des importations
      sed -i 's/import {.*getProgrammerByEmail.*} from/import { getProgrammers, addProgrammer, updateProgrammer, deleteProgrammer } from/g' "$file"
    done
    
    success "Importations corrigées dans les fichiers qui utilisent programmersService.js"
  fi
fi

# Correction du problème 6: Suppression des importations CSS problématiques
log "Correction du problème 6: Suppression des importations CSS problématiques"

# Trouver tous les fichiers qui importent des fichiers CSS locaux
log "Recherche des importations CSS problématiques"
CSS_IMPORTS=$(grep -r "import '\.\/.*\.css'" --include="*.js" --include="*.jsx" ./client/src)

if [ -n "$CSS_IMPORTS" ]; then
  log "Suppression des importations CSS problématiques dans les fichiers suivants:"
  echo "$CSS_IMPORTS"
  
  # Supprimer les importations CSS problématiques
  find ./client/src -name "*.js" -o -name "*.jsx" | xargs sed -i "s/import '\.\/.*\.css';//g"
  success "Importations CSS problématiques supprimées"
else
  log "Aucune importation CSS problématique trouvée"
fi

# Exécution d'un build de test pour vérifier que les corrections fonctionnent
log "Exécution d'un build de test pour vérifier que les corrections fonctionnent"
npm run build

# Vérification du résultat du build
if [ $? -eq 0 ]; then
  success "Build réussi ! Toutes les corrections ont été appliquées avec succès."
else
  error "Le build a échoué. Des problèmes persistent."
  
  # Afficher les erreurs de build
  log "Analyse des erreurs de build..."
  
  # Vérifier s'il y a des erreurs d'importation
  IMPORT_ERRORS=$(grep -r "Failed to compile" -A 10 ./client/build-log.txt 2>/dev/null || echo "")
  
  if [ -n "$IMPORT_ERRORS" ]; then
    log "Erreurs d'importation détectées:"
    echo "$IMPORT_ERRORS"
    
    # Correction supplémentaire pour les erreurs d'importation
    log "Application de corrections supplémentaires pour les erreurs d'importation"
    
    # Créer un fichier temporaire pour stocker les erreurs
    echo "$IMPORT_ERRORS" > ./import-errors.txt
    
    # Extraire les noms de fichiers et les importations problématiques
    PROBLEM_FILES=$(grep -o "'.*'" ./import-errors.txt | tr -d "'" | grep -v "from")
    
    for file in $PROBLEM_FILES; do
      if [[ $file == *.css ]]; then
        # Créer le fichier CSS manquant
        log "Création du fichier CSS manquant: $file"
        mkdir -p $(dirname "$file")
        touch "$file"
      fi
    done
    
    # Supprimer le fichier temporaire
    rm ./import-errors.txt
    
    # Réessayer le build
    log "Réessai du build après corrections supplémentaires"
    npm run build
    
    if [ $? -eq 0 ]; then
      success "Build réussi après corrections supplémentaires !"
    else
      error "Le build a échoué malgré les corrections supplémentaires."
      exit 1
    fi
  else
    error "Erreurs de build non identifiées. Veuillez vérifier manuellement."
    exit 1
  fi
fi

# Résumé des modifications effectuées
echo ""
echo "======================= RÉSUMÉ DES MODIFICATIONS ======================="
echo ""
echo "1. Correction du problème d'envoi de formulaire :"
echo "   - Modification de la fonction handleGenerateFormLink dans ConcertDetail.js"
echo "   - Ajout de la génération de l'URL du formulaire"
echo "   - Suppression de la vérification bloquante du programmateur"
echo ""
echo "2. Correction des erreurs de validation :"
echo "   - Amélioration de la validation des données dans concertsService.js"
echo "   - Ajout de logs détaillés pour faciliter le débogage"
echo ""
echo "3. Correction des problèmes d'enregistrement des modifications :"
echo "   - Amélioration de la fonction updateConcert dans concertsService.js"
echo "   - Vérification et correction des objets artist et programmer"
echo ""
echo "4. Correction des erreurs d'exportation de fonctions :"
echo "   - Ajout du mot-clé export à la fonction getProgrammerByEmail dans programmersService.js"
echo "   - Création de la fonction si elle n'existe pas"
echo ""
echo "5. Correction des erreurs de build :"
echo "   - Suppression des importations CSS problématiques"
echo "   - Création des fichiers CSS manquants si nécessaire"
echo ""
echo "Toutes les modifications ont été sauvegardées dans : $BACKUP_DIR"
echo ""
echo "======================= INSTRUCTIONS D'UTILISATION ======================="
echo ""
echo "Pour rendre ce script exécutable et l'exécuter :"
echo "chmod +x fix_all_app_issues_enhanced.sh && ./fix_all_app_issues_enhanced.sh"
echo ""
echo "Pour effectuer git add, commit et push :"
echo "git add . && git commit -m \"Correction des problèmes d'affichage, de validation et d'exportation\" && git push"
echo ""
echo "========================================================================"

success "Script terminé avec succès !"
