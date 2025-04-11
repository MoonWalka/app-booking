import React, { useState, useEffect } from 'react';
import './EmailsList.css';

const EmailsList = () => {
  const [emails, setEmails] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [selectedEmail, setSelectedEmail] = useState(null);
  const [searchTerm, setSearchTerm] = useState('');
  
  useEffect(() => {
    const fetchEmails = async () => {
      try {
        setLoading(true);
        setError(null);
        
        // Simuler un chargement de données
        setTimeout(() => {
          const mockEmails = [
            {
              id: '1',
              from: 'jean.dupont@example.com',
              to: 'contact@booking-app.com',
              subject: 'Demande de réservation',
              date: '2025-04-10T14:30:00',
              read: true,
              content: 'Bonjour,\n\nJe souhaiterais réserver une date pour le concert de l\'artiste XYZ.\n\nCordialement,\nJean Dupont'
            },
            {
              id: '2',
              from: 'marie.martin@example.com',
              to: 'contact@booking-app.com',
              subject: 'Question sur la disponibilité',
              date: '2025-04-09T10:15:00',
              read: false,
              content: 'Bonjour,\n\nPouvez-vous me confirmer la disponibilité de l\'artiste ABC pour le 15 juin 2025 ?\n\nMerci d\'avance,\nMarie Martin'
            },
            {
              id: '3',
              from: 'contact@booking-app.com',
              to: 'paul.durand@example.com',
              subject: 'Confirmation de réservation',
              date: '2025-04-08T16:45:00',
              read: true,
              content: 'Bonjour Paul,\n\nNous vous confirmons la réservation pour le concert du 20 mai 2025.\n\nCordialement,\nL\'équipe Booking App'
            },
            {
              id: '4',
              from: 'sophie.leroy@example.com',
              to: 'contact@booking-app.com',
              subject: 'Annulation de réservation',
              date: '2025-04-07T09:20:00',
              read: false,
              content: 'Bonjour,\n\nJe dois malheureusement annuler ma réservation pour le concert du 5 juin 2025.\n\nCordialement,\nSophie Leroy'
            },
            {
              id: '5',
              from: 'contact@booking-app.com',
              to: 'thomas.petit@example.com',
              subject: 'Facture #F2025-042',
              date: '2025-04-06T11:30:00',
              read: true,
              content: 'Bonjour Thomas,\n\nVeuillez trouver ci-joint la facture pour le concert du 10 avril 2025.\n\nCordialement,\nL\'équipe Booking App'
            }
          ];
          
          setEmails(mockEmails);
          setLoading(false);
        }, 1000);
        
      } catch (error) {
        console.error('Erreur lors du chargement des emails:', error);
        setError('Erreur lors du chargement des emails. Veuillez réessayer.');
        setLoading(false);
      }
    };
    
    fetchEmails();
  }, []);
  
  const handleEmailClick = (email) => {
    setSelectedEmail(email);
    
    // Marquer l'email comme lu
    if (!email.read) {
      setEmails(emails.map(e => 
        e.id === email.id ? { ...e, read: true } : e
      ));
    }
  };
  
  const handleSearchChange = (e) => {
    setSearchTerm(e.target.value);
  };
  
  const handleBackToList = () => {
    setSelectedEmail(null);
  };
  
  const formatDate = (dateString) => {
    const date = new Date(dateString);
    return date.toLocaleDateString('fr-FR', {
      day: '2-digit',
      month: '2-digit',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });
  };
  
  const filteredEmails = emails.filter(email => 
    email.subject.toLowerCase().includes(searchTerm.toLowerCase()) ||
    email.from.toLowerCase().includes(searchTerm.toLowerCase()) ||
    email.to.toLowerCase().includes(searchTerm.toLowerCase())
  );
  
  if (loading) {
    return <div className="loading">Chargement des emails...</div>;
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
    <div className="emails-container">
      <h1>Emails</h1>
      
      {selectedEmail ? (
        <div className="email-detail">
          <button className="back-button" onClick={handleBackToList}>
            Retour à la liste
          </button>
          
          <div className="email-header">
            <h2>{selectedEmail.subject}</h2>
            <div className="email-meta">
              <div><strong>De:</strong> {selectedEmail.from}</div>
              <div><strong>À:</strong> {selectedEmail.to}</div>
              <div><strong>Date:</strong> {formatDate(selectedEmail.date)}</div>
            </div>
          </div>
          
          <div className="email-content">
            {selectedEmail.content.split('\n').map((line, index) => (
              <p key={index}>{line}</p>
            ))}
          </div>
          
          <div className="email-actions">
            <button className="reply-button">Répondre</button>
            <button className="forward-button">Transférer</button>
            <button className="delete-button">Supprimer</button>
          </div>
        </div>
      ) : (
        <>
          <div className="emails-controls">
            <div className="search-bar">
              <input
                type="text"
                placeholder="Rechercher un email..."
                value={searchTerm}
                onChange={handleSearchChange}
              />
            </div>
            
            <button className="compose-button">
              Nouveau message
            </button>
          </div>
          
          {filteredEmails.length === 0 ? (
            <div className="no-emails">
              Aucun email trouvé.
            </div>
          ) : (
            <div className="emails-list">
              {filteredEmails.map(email => (
                <div 
                  key={email.id} 
                  className={`email-item ${email.read ? 'read' : 'unread'}`}
                  onClick={() => handleEmailClick(email)}
                >
                  <div className="email-sender">{email.from}</div>
                  <div className="email-subject">{email.subject}</div>
                  <div className="email-date">{formatDate(email.date)}</div>
                </div>
              ))}
            </div>
          )}
        </>
      )}
    </div>
  );
};

export default EmailsList;
