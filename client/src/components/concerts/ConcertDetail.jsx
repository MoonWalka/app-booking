import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import from './services/concertsService';
import { getArtists } from '../../services/artistsService';
import from './services/programmersService';
// 

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
