// client/src/components/emails/EmailSystem.js
import React, { useState } from 'react';
import EmailComposer from './EmailComposer';

const EmailSystem = () => {
  const [emails, setEmails] = useState([]);
  const [showComposer, setShowComposer] = useState(false);
  const [selectedEmail, setSelectedEmail] = useState(null);

  // Fonction pour simuler l'envoi d'un email
  const handleSendEmail = (emailData) => {
    // Dans une application réelle, ceci serait une requête API
    const newEmail = {
      id: Date.now(),
      ...emailData,
      status: 'sent',
      date: new Date().toISOString()
    };
    
    setEmails([newEmail, ...emails]);
    setShowComposer(false);
  };

  return (
    <div className="email-system-container">
      <h2>Système d'Emails</h2>
      
      <div className="email-actions">
        <button 
          className="compose-btn"
          onClick={() => {
            setSelectedEmail(null);
            setShowComposer(true);
          }}
        >
          Composer un nouvel email
        </button>
      </div>
      
      {showComposer && (
        <div className="email-composer-wrapper">
          <EmailComposer 
            initialData={selectedEmail}
            onSend={handleSendEmail}
            onCancel={() => setShowComposer(false)}
          />
        </div>
      )}
      
      <div className="emails-list">
        <h3>Emails envoyés</h3>
        {emails.length === 0 ? (
          <p>Aucun email envoyé.</p>
        ) : (
          <table className="emails-table">
            <thead>
              <tr>
                <th>Destinataire</th>
                <th>Objet</th>
                <th>Date</th>
                <th>Statut</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {emails.map((email) => (
                <tr key={email.id}>
                  <td>{email.to}</td>
                  <td>{email.subject}</td>
                  <td>{new Date(email.date).toLocaleString()}</td>
                  <td>{email.status}</td>
                  <td>
                    <button
                      onClick={() => {
                        setSelectedEmail(email);
                        setShowComposer(true);
                      }}
                      className="view-btn"
                    >
                      Voir
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

export default EmailSystem;
