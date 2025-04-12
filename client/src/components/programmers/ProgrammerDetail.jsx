import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import from './services/programmersService';


const ProgrammerDetail = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const [programmer, setProgrammer] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [isEditing, setIsEditing] = useState(false);
  const [formData, setFormData] = useState({
    businessName: '',
    contact: '',
    role: '',
    structure: '', // <-- Ajout de la propriété structure
    address: '',
    venue: '',
    vatNumber: '',
    siret: '',
    email: '',
    phone: '',
    website: '',
    notes: ''
  });

  // Options pour le champ "qualité"
  const roleOptions = [
    'Programmateur',
    'Président',
    'Gérant',
    'Directeur',
    'Administrateur',
    'Chargé de production',
    'Autre'
  ];

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
          businessName: data.businessName || '',
          contact: data.contact || '',
          role: data.role || '',
          structure: data.structure || '', // <-- Remplissage de structure
          address: data.address || '',
          venue: data.venue || '',
          vatNumber: data.vatNumber || '',
          siret: data.siret || '',
          email: data.email || '',
          phone: data.phone || '',
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
            <label htmlFor="businessName">Raison sociale</label>
            <input
              type="text"
              id="businessName"
              name="businessName"
              value={formData.businessName}
              onChange={handleInputChange}
              placeholder="Nom de l'entreprise ou de l'organisation"
            />
          </div>
          
          <div className="form-group">
            <label htmlFor="contact">Contact</label>
            <input
              type="text"
              id="contact"
              name="contact"
              value={formData.contact}
              onChange={handleInputChange}
              placeholder="Nom et prénom du contact"
            />
          </div>
          
          <div className="form-group">
            <label htmlFor="role">Qualité</label>
            <select
              id="role"
              name="role"
              value={formData.role}
              onChange={handleInputChange}
            >
              <option value="">Sélectionner une qualité</option>
              {roleOptions.map(role => (
                <option key={role} value={role}>{role}</option>
              ))}
            </select>
          </div>
          
          {/* Nouveau champ pour la structure */}
          <div className="form-group">
            <label htmlFor="structure">Structure</label>
            <input
              type="text"
              id="structure"
              name="structure"
              value={formData.structure}
              onChange={handleInputChange}
              placeholder="Nom de la structure"
            />
          </div>
          
          <div className="form-group">
            <label htmlFor="address">Adresse de la raison sociale</label>
            <textarea
              id="address"
              name="address"
              value={formData.address}
              onChange={handleInputChange}
              rows="3"
              placeholder="Adresse complète"
            ></textarea>
          </div>
          
          <div className="form-group">
            <label htmlFor="venue">Lieu ou festival</label>
            <input
              type="text"
              id="venue"
              name="venue"
              value={formData.venue}
              onChange={handleInputChange}
              placeholder="Nom du lieu ou du festival"
            />
          </div>
          
          <div className="form-group">
            <label htmlFor="vatNumber">Numéro intracommunautaire</label>
            <input
              type="text"
              id="vatNumber"
              name="vatNumber"
              value={formData.vatNumber}
              onChange={handleInputChange}
              placeholder="FR12345678901"
            />
          </div>
          
          <div className="form-group">
            <label htmlFor="siret">SIRET</label>
            <input
              type="text"
              id="siret"
              name="siret"
              value={formData.siret}
              onChange={handleInputChange}
              placeholder="123 456 789 00012"
            />
          </div>
          
          <div className="form-group">
            <label htmlFor="email">Email</label>
            <input
              type="email"
              id="email"
              name="email"
              value={formData.email}
              onChange={handleInputChange}
              placeholder="email@exemple.com"
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
              placeholder="06 12 34 56 78"
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
          <div className="programmer-info">
            <div className="info-row">
              <span className="info-label">Raison sociale:</span>
              <span className="info-value">{programmer.businessName || 'Non spécifié'}</span>
            </div>
            
            <div className="info-row">
              <span className="info-label">Contact:</span>
              <span className="info-value">{programmer.contact || 'Non spécifié'}</span>
            </div>
            
            <div className="info-row">
              <span className="info-label">Qualité:</span>
              <span className="info-value">{programmer.role || 'Non spécifié'}</span>
            </div>
            
            {/* Affichage de la structure */}
            <div className="info-row">
              <span className="info-label">Structure:</span>
              <span className="info-value">{programmer.structure || 'Non spécifiée'}</span>
            </div>
            
            <div className="info-row">
              <span className="info-label">Adresse:</span>
              <span className="info-value">{programmer.address || 'Non spécifié'}</span>
            </div>
            
            <div className="info-row">
              <span className="info-label">Lieu ou festival:</span>
              <span className="info-value">{programmer.venue || 'Non spécifié'}</span>
            </div>
            
            <div className="info-row">
              <span className="info-label">N° intracommunautaire:</span>
              <span className="info-value">{programmer.vatNumber || 'Non spécifié'}</span>
            </div>
            
            <div className="info-row">
              <span className="info-label">SIRET:</span>
              <span className="info-value">{programmer.siret || 'Non spécifié'}</span>
            </div>
            
            <div className="info-row">
              <span className="info-label">Email:</span>
              <span className="info-value">{programmer.email || 'Non spécifié'}</span>
            </div>
            
            <div className="info-row">
              <span className="info-label">Téléphone:</span>
              <span className="info-value">{programmer.phone || 'Non spécifié'}</span>
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