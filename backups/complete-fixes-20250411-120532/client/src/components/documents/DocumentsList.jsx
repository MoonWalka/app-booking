import React, { useState, useEffect } from 'react';
import './DocumentsList.css';

const DocumentsList = () => {
  const [documents, setDocuments] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [searchTerm, setSearchTerm] = useState('');
  const [filter, setFilter] = useState('all');
  
  useEffect(() => {
    const fetchDocuments = async () => {
      try {
        setLoading(true);
        setError(null);
        
        // Simuler un chargement de données
        setTimeout(() => {
          const mockDocuments = [
            { id: '1', name: 'Contrat type', type: 'contract', date: '2025-03-15', size: '245 KB' },
            { id: '2', name: 'Facture modèle', type: 'invoice', date: '2025-03-10', size: '120 KB' },
            { id: '3', name: 'Présentation artiste', type: 'presentation', date: '2025-02-28', size: '1.2 MB' },
            { id: '4', name: 'Fiche technique', type: 'technical', date: '2025-02-15', size: '350 KB' },
            { id: '5', name: 'Planning tournée', type: 'planning', date: '2025-04-01', size: '180 KB' }
          ];
          
          setDocuments(mockDocuments);
          setLoading(false);
        }, 1000);
        
      } catch (error) {
        console.error('Erreur lors du chargement des documents:', error);
        setError('Erreur lors du chargement des documents. Veuillez réessayer.');
        setLoading(false);
      }
    };
    
    fetchDocuments();
  }, []);
  
  const handleSearchChange = (e) => {
    setSearchTerm(e.target.value);
  };
  
  const handleFilterChange = (e) => {
    setFilter(e.target.value);
  };
  
  const filteredDocuments = documents.filter(doc => {
    const matchesSearch = doc.name.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesFilter = filter === 'all' || doc.type === filter;
    return matchesSearch && matchesFilter;
  });
  
  const getDocumentIcon = (type) => {
    switch (type) {
      case 'contract':
        return '📝';
      case 'invoice':
        return '💰';
      case 'presentation':
        return '🎭';
      case 'technical':
        return '🔧';
      case 'planning':
        return '📅';
      default:
        return '📄';
    }
  };
  
  if (loading) {
    return <div className="loading">Chargement des documents...</div>;
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
    <div className="documents-container">
      <h1>Documents</h1>
      
      <div className="documents-controls">
        <div className="search-bar">
          <input
            type="text"
            placeholder="Rechercher un document..."
            value={searchTerm}
            onChange={handleSearchChange}
          />
        </div>
        
        <div className="filter-dropdown">
          <select value={filter} onChange={handleFilterChange}>
            <option value="all">Tous les types</option>
            <option value="contract">Contrats</option>
            <option value="invoice">Factures</option>
            <option value="presentation">Présentations</option>
            <option value="technical">Fiches techniques</option>
            <option value="planning">Plannings</option>
          </select>
        </div>
        
        <button className="upload-button">
          Ajouter un document
        </button>
      </div>
      
      {filteredDocuments.length === 0 ? (
        <div className="no-documents">
          Aucun document trouvé.
        </div>
      ) : (
        <div className="documents-list">
          <div className="documents-header">
            <div className="document-cell">Nom</div>
            <div className="document-cell">Type</div>
            <div className="document-cell">Date</div>
            <div className="document-cell">Taille</div>
            <div className="document-cell">Actions</div>
          </div>
          
          {filteredDocuments.map(doc => (
            <div key={doc.id} className="document-row">
              <div className="document-cell document-name">
                <span className="document-icon">{getDocumentIcon(doc.type)}</span>
                {doc.name}
              </div>
              <div className="document-cell document-type">
                {doc.type.charAt(0).toUpperCase() + doc.type.slice(1)}
              </div>
              <div className="document-cell document-date">
                {doc.date}
              </div>
              <div className="document-cell document-size">
                {doc.size}
              </div>
              <div className="document-cell document-actions">
                <button className="action-button view">Voir</button>
                <button className="action-button download">Télécharger</button>
                <button className="action-button delete">Supprimer</button>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
};

export default DocumentsList;
