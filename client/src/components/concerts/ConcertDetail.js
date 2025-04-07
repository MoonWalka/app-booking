// client/src/components/concerts/ConcertDetail.js
import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';

const ConcertDetail = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const [concert, setConcert] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchConcert = async () => {
      try {
        setLoading(true);
        const response = await fetch(`/api/concerts/${id}`);
        if (!response.ok) {
          throw new Error('Erreur lors de la récupération des détails du concert');
        }
        const data = await response.json();
        setConcert(data);
        setLoading(false);
      } catch (err) {
        setError(err.message);
        setLoading(false);
      }
    };

    fetchConcert();
  }, [id]);

  const handleDelete = async () => {
    if (window.confirm('Êtes-vous sûr de vouloir supprimer ce concert ?')) {
      try {
        const response = await fetch(`/api/concerts/${id}`, {
          method: 'DELETE',
        });
        if (!response.ok) {
          throw new Error('Erreur lors de la suppression du concert');
        }
        navigate('/concerts');
      } catch (err) {
        setError(err.message);
      }
    }
  };

  if (loading) return <div>Chargement des détails du concert...</div>;
  if (error) return <div>Erreur: {error}</div>;
  if (!concert) return <div>Concert non trouvé</div>;

  return (
    <div className="concert-detail-container">
      <h2>Détails du Concert</h2>
      <div className="concert-info">
        <p><strong>Artiste:</strong> {concert.artist?.name || 'Non spécifié'}</p>
        <p><strong>Date:</strong> {new Date(concert.date).toLocaleDateString()}</p>
        <p><strong>Heure:</strong> {concert.time || 'Non spécifiée'}</p>
        <p><strong>Lieu:</strong> {concert.venue}</p>
        <p><strong>Ville:</strong> {concert.city}</p>
        <p><strong>Prix:</strong> {concert.price ? `${concert.price} €` : 'Non spécifié'}</p>
        <p><strong>Statut:</strong> {concert.status || 'Non spécifié'}</p>
        <p><strong>Notes:</strong> {concert.notes || 'Aucune note'}</p>
      </div>

      <div className="concert-actions">
        <button
          onClick={() => navigate(`/concerts/modifier/${id}`)}
          className="edit-btn"
        >
          Modifier
        </button>
        <button onClick={handleDelete} className="delete-btn">
          Supprimer
        </button>
        <button onClick={() => navigate('/concerts')} className="back-btn">
          Retour à la liste
        </button>
      </div>
    </div>
  );
};

export default ConcertDetail;
