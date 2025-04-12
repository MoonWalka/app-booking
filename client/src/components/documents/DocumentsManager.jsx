// client/src/components/documents/DocumentsManager.js
import React, { useState } from 'react';
import DocumentGenerator from './DocumentGenerator';

const DocumentsManager = () => {
  const [documents, setDocuments] = useState([]);
  const [showGenerator, setShowGenerator] = useState(false);
  const [selectedDocument, setSelectedDocument] = useState(null);

  // Fonction pour simuler la génération d'un document
  const handleGenerateDocument = (documentData) => {
    // Dans une application réelle, ceci serait une requête API
    const newDocument = {
      id: Date.now(),
      ...documentData,
      createdAt: new Date().toISOString()
    };
    
    setDocuments([newDocument, ...documents]);
    setShowGenerator(false);
  };

  return (
    <div className="documents-manager-container">
      <h2>Gestionnaire de Documents</h2>
      
      <div className="document-actions">
        <button 
          className="generate-btn"
          onClick={() => {
            setSelectedDocument(null);
            setShowGenerator(true);
          }}
        >
          Générer un nouveau document
        </button>
      </div>
      
      {showGenerator && (
        <div className="document-generator-wrapper">
          <DocumentGenerator 
            initialData={selectedDocument}
            onGenerate={handleGenerateDocument}
            onCancel={() => setShowGenerator(false)}
          />
        </div>
      )}
      
      <div className="documents-list">
        <h3>Documents générés</h3>
        {documents.length === 0 ? (
          <p>Aucun document généré.</p>
        ) : (
          <table className="documents-table">
            <thead>
              <tr>
                <th>Titre</th>
                <th>Type</th>
                <th>Date de création</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {documents.map((document) => (
                <tr key={document.id}>
                  <td>{document.title}</td>
                  <td>{document.type}</td>
                  <td>{new Date(document.createdAt).toLocaleString()}</td>
                  <td>
                    <button
                      onClick={() => {
                        setSelectedDocument(document);
                        setShowGenerator(true);
                      }}
                      className="view-btn"
                    >
                      Voir
                    </button>
                    <button
                      onClick={() => {
                        // Simuler un téléchargement
                        alert(`Téléchargement du document "${document.title}" en cours...`);
                      }}
                      className="download-btn"
                    >
                      Télécharger
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>
    </div>
  );
};

export default DocumentsManager;
