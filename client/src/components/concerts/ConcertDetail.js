import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { getConcertById, updateConcert, deleteConcert } from '../../services/concertsService';
import { getArtists } from '../../services/artistsService';
import { getProgrammers } from '../../services/programmersService';
import { createFormLink, getFormLinkByConcertId } from "../../services/formLinkService";
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
  const [formLink, setFormLink] = useState(null);
  const [showLinkModal, setShowLinkModal] = useState(false);
  const [linkCopied, setLinkCopied] = useState(false);
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
        
        // Vérifier si un lien de formulaire existe déjà pour ce concert
        const existingLink = await getFormLinkByConcertId(id);
        if (existingLink) {
          console.log("Lien de formulaire existant trouvé:", existingLink);
          setFormLink(existingLink);
        }
        
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

  const handleGenerateFormLink = async () => {
    try {
      setLoading(true);
      
      // Vérifier si le concert a un programmateur associé
      if (!concert.programmer || !concert.programmer.id) {
        alert("Ce concert n'a pas de programmateur associé. Veuillez d'abord ajouter un programmateur.");
        setLoading(false);
        return;
      }
      
      // Vérifier si un lien existe déjà
      if (formLink) {
        setShowLinkModal(true);
        setLoading(false);
        return;
      }
      
      // Générer un nouveau lien
      const newLink = await createFormLink(
        id,
        concert,
        concert.programmer.id,
        concert.programmer.name
      );
      
      setFormLink(newLink);
      setShowLinkModal(true);
      setLoading(false);
    } catch (err) {
      console.error("Erreur lors de la génération du lien de formulaire:", err);
      setError(err.message);
      setLoading(false);
      alert("Une erreur est survenue lors de la génération du lien de formulaire. Veuillez réessayer.");
    }
  };

  const handleCopyLink = () => {
    if (!formLink) return;
    
    const baseUrl = window.location.origin;
    const fullUrl = `${baseUrl}/form/${formLink.token}`;
    
    navigator.clipboard.writeText(fullUrl)
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

  // Construire l'URL complète du formulaire
  const baseUrl = window.location.origin;
  const formUrl = formLink ? `${baseUrl}/form/${formLink.token}` : '';

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
            
            <div className="info-row notes">
              <span className="info-label">Notes:</span>
              <span className="info-value">{concert.notes || 'Aucune note'}</span>
            </div>
            
            <div className="info-row form-link-status">
              <span className="info-label">Formulaire:</span>
              <span className="info-value">
                {formLink ? (
                  formLink.isSubmitted ? (
                    <span className="form-submitted">Formulaire soumis</span>
                  ) : (
                    <span className="form-pending">Formulaire envoyé, en attente de réponse</span>
                  )
                ) : (
                  <span className="form-not-sent">Formulaire non envoyé</span>
                )}
              </span>
            </div>
          </div>
          
          <div className="concert-actions">
            <button onClick={() => setIsEditing(true)} className="edit-btn">
              Modifier
            </button>
            <button onClick={handleDelete} className="delete-btn">
              Supprimer
            </button>
            <button 
              onClick={handleGenerateFormLink} 
              className="send-form-btn"
              disabled={loading || !concert.programmer?.id}
            >
              {formLink ? 'Voir le lien du formulaire' : 'Envoyer le formulaire'}
            </button>
            <button onClick={() => navigate('/concerts')} className="back-btn">
              Retour à la liste
            </button>
          </div>
        </>
      )}
      
      {/* Modal pour afficher le lien du formulaire */}
      {showLinkModal && formLink && (
        <div className="form-link-modal-overlay">
          <div className="form-link-modal">
            <div className="form-link-modal-header">
              <h3>{formLink.isSubmitted ? 'Formulaire déjà soumis' : 'Lien du formulaire'}</h3>
              <button className="close-modal-btn" onClick={closeLinkModal}>
                <i className="fas fa-times"></i>
              </button>
            </div>
            
            <div className="form-link-modal-content">
              {formLink.isSubmitted ? (
                <div className="form-submitted-message">
                  <p>
                    <i className="fas fa-check-circle"></i>
                    Ce formulaire a déjà été soumis par le programmateur.
                  </p>
                  <p>
                    Vous pouvez consulter les informations soumises dans l'onglet 
                    <strong> Validation Formulaire</strong>.
                  </p>
                </div>
              ) : (
                <>
                  <p className="form-link-instructions">
                    Voici le lien unique à envoyer au programmateur pour qu'il puisse remplir le formulaire :
                  </p>
                  
                  <div className="form-link-container">
                    <input
                      type="text"
                      value={formUrl}
                      readOnly
                      className="form-link-input"
                    />
                    <button 
                      className="copy-link-btn"
                      onClick={handleCopyLink}
                    >
                      {linkCopied ? (
                        <>
                          <i className="fas fa-check"></i> Copié
                        </>
                      ) : (
                        <>
                          <i className="fas fa-copy"></i> Copier
                        </>
                      )}
                    </button>
                  </div>
                  
                  <div className="form-link-info">
                    <p>
                      <i className="fas fa-info-circle"></i>
                      Ce lien est unique et associé à ce concert. Il permet au programmateur de remplir 
                      ses informations sans avoir besoin de créer un compte.
                    </p>
                    <p>
                      Une fois le formulaire soumis, les informations apparaîtront dans l'onglet 
                      <strong> Validation Formulaire</strong>.
                    </p>
                  </div>
                </>
              )}
            </div>
            
            <div className="form-link-modal-actions">
              <button className="close-btn" onClick={closeLinkModal}>
                Fermer
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default ConcertDetail;
