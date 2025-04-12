import React, { useState } from 'react';

const EmailComposer = ({ initialData, onSend, onCancel }) => {
  const [formData, setFormData] = useState(
    initialData || {
      to: '',
      subject: '',
      body: '',
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
    onSend(formData);
  };

  return (
    <div className="email-composer">
      <h3>{initialData ? 'Voir l\'email' : 'Composer un nouvel email'}</h3>
      <form onSubmit={handleSubmit}>
        <div className="form-group">
          <label htmlFor="to">Destinataire</label>
          <input
            type="email"
            id="to"
            name="to"
            value={formData.to}
            onChange={handleChange}
            required
            disabled={initialData}
          />
        </div>
        <div className="form-group">
          <label htmlFor="subject">Objet</label>
          <input
            type="text"
            id="subject"
            name="subject"
            value={formData.subject}
            onChange={handleChange}
            required
            disabled={initialData}
          />
        </div>
        <div className="form-group">
          <label htmlFor="body">Message</label>
          <textarea
            id="body"
            name="body"
            value={formData.body}
            onChange={handleChange}
            rows="10"
            required
            disabled={initialData}
          />
        </div>
        <div className="form-actions">
          {!initialData && (
            <button type="submit" className="send-btn">
              Envoyer
            </button>
          )}
          <button type="button" className="cancel-btn" onClick={onCancel}>
            {initialData ? 'Fermer' : 'Annuler'}
          </button>
        </div>
      </form>
    </div>
  );
};

export default EmailComposer;
