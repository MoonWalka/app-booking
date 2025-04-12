import React, { useState } from 'react';

const DocumentGenerator = ({ initialData, onGenerate, onCancel }) => {
  const [formData, setFormData] = useState(
    initialData || {
      title: '',
      type: 'contrat',
      content: '',
    }
  );

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData({
      ...formData,
      [name]: value,
    });
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    onGenerate(formData);
  };

  return (
    <div className="document-generator">
      <h3>{initialData ? 'Modifier le document' : 'Générer un nouveau document'}</h3>
      <form onSubmit={handleSubmit}>
        <div className="form-group">
          <label htmlFor="title">Titre</label>
          <input
            type="text"
            id="title"
            name="title"
            value={formData.title}
            onChange={handleChange}
            required
          />
        </div>
        <div className="form-group">
          <label htmlFor="type">Type de document</label>
          <select
            id="type"
            name="type"
            value={formData.type}
            onChange={handleChange}
            required
          >
            <option value="contrat">Contrat</option>
            <option value="facture">Facture</option>
            <option value="devis">Devis</option>
            <option value="fiche_technique">Fiche technique</option>
          </select>
        </div>
        <div className="form-group">
          <label htmlFor="content">Contenu</label>
          <textarea
            id="content"
            name="content"
            value={formData.content}
            onChange={handleChange}
            rows="10"
            required
          />
        </div>
        <div className="form-actions">
          <button type="submit" className="generate-btn">
            {initialData ? 'Mettre à jour' : 'Générer'}
          </button>
          <button type="button" className="cancel-btn" onClick={onCancel}>
            Annuler
          </button>
        </div>
      </form>
    </div>
  );
};

export default DocumentGenerator;
