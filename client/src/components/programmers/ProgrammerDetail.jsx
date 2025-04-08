// client/src/components/programmers/ProgrammerDetail.jsx
import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { getProgrammerById, deleteProgrammer, updateProgrammer } from '../../services/programmersService';
import './ProgrammerDetail.css';

const ProgrammerDetail = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const [programmer, setProgrammer] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [isEditing, setIsEditing] = useState(false);
  const [formData, setFormData] = useState({
    name: '',
    structure: '',
    email: '',
    phone: '',
    city: '',
    region: '',
    website: '',
    notes: ''
  });

  useEffect(() => {
    const fetchProgrammer = async () => {
      try {
        setLoading(true);
        console.log(`Tentative de récupération du programmateur avec l'ID: ${id}`);
        
        // Utiliser le service Firebase au lieu de fetch
        const data = await getProgrammerById(id);
        
        if (!data) {
          throw new Error('Programmateur non trouvé');
        }
        
        console.log('Programmateur récupéré:', data);
        setProgrammer(data);
        setFormData({
          name: data.name || '',
          structure: data.structure || '',
          email: data.email || '',
          phone: data.phone || '',
          city: data.city || '',
          region: data.region || '',
          website: data.website || '',
          notes: data.notes || ''
        });
        setLoading(false);
      } catch (err) {
        console.error('Erreur lors de la récupération du programmateur:', err);
        setError(err.message);
        setLoading(false);
      }
    };

    fetchProgrammer();
  }, [id]);

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setFormData({
      ...formData,
      [name]: value
    });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      setLoading(true);
      
      // Utiliser le service Firebase pour mettre à jour le programmateur
      await updateProgrammer(id, formData);
      
      // Récupérer les données mises à jour
      const updatedData = await getProgrammerById(id);
      setProgrammer(updatedData);
      
      setIsEditing(false);
      setLoading(false);
    } catch (err) {
      setError(err.message);
      setLoading(false);
    }
  };

  const handleDelete = async () => {
    if (window.confirm('Êtes-vous sûr de vouloir supprimer ce programmateur ?')) {
      try {
        setLoading(true);
        
        // Utiliser le service Firebase pour supprimer le programmateur
        await deleteProgrammer(id);
        
        navigate('/programmateurs');
      } catch (err) {
        setError(err.message);
        setLoading(false);
      }
    }
  };

  if (loading) return <div className="loading">Chargement des détails du programmateur...</div>;
  if (error) return <div className="error-message">Erreur: {error}</div>;
  if (!programmer) return <div className="not-found">Programmateur non trouvé</div>;

  return (
    <div className="programmer-detail-container">
      <h2>Détails du programmateur</h2>
      
      {isEditing ? (
        <form onSubmit={handleSubmit} className="edit-form">
          <div className="form-group">
            <label htmlFor="name">Nom du programmateur *</label>
            <input
              type="text"
              id="name"
              name="name"
              value={formData.name}
              onChange={handleInputChange}
              required
            />
          </div>
          
          <div className="form-group">
            <label htmlFor="structure">Structure *</label>
            <input
              type="text"
              id="structure"
              name="structure"
              value={formData.structure}
              onChange={handleInputChange}
              required
            />
          </div>
          
          <div className="form-group">
            <label htmlFor="email">Email *</label>
            <input
              type="email"
              id="email"
              name="email"
              value={formData.email}
              onChange={handleInputChange}
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
              onChange={handleInputChange}
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
            />
          </div>
          
          <div className="form-group">
            <label htmlFor="region">Région</label>
            <input
              type="text"
              id="region"
              name="region"
              value={formData.region}
              onChange={handleInputChange}
            />
          </div>
          
          <div className="form-group">
            <label htmlFor="website">Site web</label>
            <input
              type="url"
              id="website"
              name="website"
              value={formData.website}
              onChange={handleInputChange}
              placeholder="https://www.exemple.com"
            />
          </div>
          
          <div className="form-group full-width">
            <label htmlFor="notes">Notes</label>
            <textarea
              id="notes"
              name="notes"
              value={formData.notes}
              onChange={handleInputChange}
              rows="4"
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
          <div className="programmer-info">
            <div className="info-row">
              <span className="info-label">Nom:</span>
              <span className="info-value">{programmer.name}</span>
            </div>
            
            <div className="info-row">
              <span className="info-label">Structure:</span>
              <span className="info-value">{programmer.structure}</span>
            </div>
            
            <div className="info-row">
              <span className="info-label">Email:</span>
              <span className="info-value">{programmer.email}</span>
            </div>
            
            <div className="info-row">
              <span className="info-label">Téléphone:</span>
              <span className="info-value">{programmer.phone || 'Non spécifié'}</span>
            </div>
            
            <div className="info-row">
              <span className="info-label">Ville:</span>
              <span className="info-value">{programmer.city}</span>
            </div>
            
            <div className="info-row">
              <span className="info-label">Région:</span>
              <span className="info-value">{programmer.region || 'Non spécifiée'}</span>
            </div>
            
            {programmer.website && (
              <div className="info-row">
                <span className="info-label">Site web:</span>
                <span className="info-value">
                  <a href={programmer.website} target="_blank" rel="noopener noreferrer">
                    {programmer.website}
                  </a>
                </span>
              </div>
            )}
            
            <div className="info-row notes">
              <span className="info-label">Notes:</span>
              <span className="info-value">{programmer.notes || 'Aucune note'}</span>
            </div>
          </div>
          
          <div className="programmer-actions">
            <button onClick={() => setIsEditing(true)} className="edit-btn">
              Modifier
            </button>
            <button onClick={handleDelete} className="delete-btn">
              Supprimer
            </button>
            <button onClick={() => navigate('/programmateurs')} className="back-btn">
              Retour à la liste
            </button>
          </div>
        </>
      )}
    </div>
  );
};

export default ProgrammerDetail;
