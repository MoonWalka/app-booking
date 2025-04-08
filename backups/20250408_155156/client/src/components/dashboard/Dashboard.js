import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { getConcerts } from '../../services/concertsService';
import './Dashboard.css';

const Dashboard = () => {
  const [loading, setLoading] = useState(true);
  const [dashboardData, setDashboardData] = useState({
    upcomingConcerts: [],
    unpaidInvoices: [],
    followupBookings: [],
    missingContracts: []
  });
  const [view, setView] = useState('list'); // 'list' ou 'calendar'

  useEffect(() => {
    const fetchDashboardData = async () => {
      try {
        // Récupérer les concerts depuis Firebase
        console.log("Tentative de récupération des concerts pour le dashboard...");
        const allConcerts = await getConcerts();
        console.log("Concerts récupérés pour le dashboard:", allConcerts);
        
        // Filtrer les concerts à venir (30 prochains jours)
        const today = new Date();
        const thirtyDaysLater = new Date();
        thirtyDaysLater.setDate(today.getDate() + 30);
        
        const upcomingConcerts = allConcerts
          .filter(concert => {
            if (!concert.date) return false;
            const concertDate = new Date(concert.date);
            return concertDate >= today && concertDate <= thirtyDaysLater;
          })
          .sort((a, b) => new Date(a.date) - new Date(b.date));
        
        console.log("Concerts à venir filtrés:", upcomingConcerts);

        // Simuler des données pour les autres sections du dashboard
        const mockData = {
          upcomingConcerts: upcomingConcerts, // Utiliser les données réelles de Firebase
          unpaidInvoices: [
            {
              id: '1',
              concert: { artist: { name: 'Les Harmonies Urbaines' } },
              type: 'balance',
              dueDate: '2025-04-30',
              amount: 1500
            },
            {
              id: '2',
              concert: { artist: { name: 'Échos Poétiques' } },
              type: 'deposit',
              dueDate: '2025-04-15',
              amount: 800
            },
            {
              id: '3',
              concert: { artist: { name: 'Rythmes Solaires' } },
              type: 'balance',
              dueDate: '2025-05-10',
              amount: 1200
            },
            {
              id: '4',
              concert: { artist: { name: 'Jazz Fusion Quartet' } },
              type: 'deposit',
              dueDate: '2025-04-20',
              amount: 600
            },
            {
              id: '5',
              concert: { artist: { name: 'Électro Symphonie' } },
              type: 'balance',
              dueDate: '2025-05-05',
              amount: 2000
            }
          ],
          followupBookings: [
            {
              id: '1',
              artist: { name: 'Mélodies Nocturnes' },
              venue: 'L\'Olympia',
              lastContact: '2025-03-15',
              status: 'en_attente'
            },
            {
              id: '2',
              artist: { name: 'Voix Cristallines' },
              venue: 'Zénith',
              lastContact: '2025-03-20',
              status: 'négociation'
            },
            {
              id: '3',
              artist: { name: 'Percussions Urbaines' },
              venue: 'La Cigale',
              lastContact: '2025-03-10',
              status: 'proposition_envoyée'
            },
            {
              id: '4',
              artist: { name: 'Cordes Sensibles' },
              venue: 'Bataclan',
              lastContact: '2025-03-25',
              status: 'relance_nécessaire'
            },
            {
              id: '5',
              artist: { name: 'Vents d\'Est' },
              venue: 'Théâtre de la Ville',
              lastContact: '2025-03-18',
              status: 'en_attente'
            },
            {
              id: '6',
              artist: { name: 'Quatuor Lumineux' },
              venue: 'Philharmonie',
              lastContact: '2025-03-22',
              status: 'négociation'
            },
            {
              id: '7',
              artist: { name: 'Trio Jazz' },
              venue: 'New Morning',
              lastContact: '2025-03-12',
              status: 'proposition_envoyée'
            },
            {
              id: '8',
              artist: { name: 'Électro Fusion' },
              venue: 'Rex Club',
              lastContact: '2025-03-28',
              status: 'relance_nécessaire'
            }
          ],
          missingContracts: [
            {
              id: '1',
              artist: { name: 'Électro Symphonie' },
              venue: 'Palais des Congrès',
              date: '2025-06-10',
              time: '20:00'
            },
            {
              id: '2',
              artist: { name: 'Jazz Fusion Quartet' },
              venue: 'Duc des Lombards',
              date: '2025-06-15',
              time: '21:30'
            },
            {
              id: '3',
              artist: { name: 'Voix Cristallines' },
              venue: 'Théâtre du Châtelet',
              date: '2025-06-20',
              time: '19:00'
            }
          ]
        };

        setDashboardData(mockData);
        setLoading(false);
      } catch (error) {
        console.error('Erreur de chargement des données du tableau de bord', error);
        setLoading(false);
      }
    };

    fetchDashboardData();
  }, []);

  const formatPrice = (price) => {
    return new Intl.NumberFormat('fr-FR', { style: 'currency', currency: 'EUR' }).format(price);
  };

  const formatDate = (dateString) => {
    const date = new Date(dateString);
    return date.toLocaleDateString('fr-FR');
  };

  if (loading) {
    return <div>Chargement...</div>;
  }

  return (
    <div className="dashboard-container">
      <h1 className="dashboard-title">Tableau de bord</h1>

      <div className="dashboard-view-toggle">
        <button 
          className={`view-toggle-btn ${view === 'list' ? 'active' : ''}`}
          onClick={() => setView('list')}
        >
          Vue Liste
        </button>
        <button 
          className={`view-toggle-btn ${view === 'calendar' ? 'active' : ''}`}
          onClick={() => setView('calendar')}
        >
          Vue Calendrier
        </button>
      </div>

      <div className="dashboard-stats">
        <div className="stat-card">
          <div className="stat-icon concerts-icon">
            <i className="fas fa-calendar-alt"></i>
          </div>
          <div className="stat-content">
            <h3>Concerts à venir</h3>
            <p className="stat-number">{dashboardData.upcomingConcerts.length}</p>
          </div>
        </div>

        <div className="stat-card">
          <div className="stat-icon invoices-icon">
            <i className="fas fa-file-invoice-dollar"></i>
          </div>
          <div className="stat-content">
            <h3>Factures impayées</h3>
            <p className="stat-number">{dashboardData.unpaidInvoices.length}</p>
          </div>
        </div>

        <div className="stat-card">
          <div className="stat-icon bookings-icon">
            <i className="fas fa-exclamation-triangle"></i>
          </div>
          <div className="stat-content">
            <h3>Réservations en attente</h3>
            <p className="stat-number">{dashboardData.followupBookings.length}</p>
          </div>
        </div>

        <div className="stat-card">
          <div className="stat-icon contracts-icon">
            <i className="fas fa-file-contract"></i>
          </div>
          <div className="stat-content">
            <h3>Contrats manquants</h3>
            <p className="stat-number">{dashboardData.missingContracts.length}</p>
          </div>
        </div>
      </div>

      {view === 'calendar' ? (
        <div className="dashboard-calendar">
          <p>Vue calendrier à implémenter</p>
        </div>
      ) : (
        <div className="dashboard-lists">
          {/* Concerts à venir */}
          <div className="dashboard-section">
            <div className="section-card">
              <div className="section-header">
                <h2>
                  <i className="fas fa-calendar-alt"></i>
                  Concerts à venir (30 prochains jours)
                </h2>
                <div className="section-content">
                  {dashboardData.upcomingConcerts.length === 0 ? (
                    <p className="empty-message">Aucun concert à venir</p>
                  ) : (
                    <table className="data-table">
                      <thead>
                        <tr>
                          <th>Date</th>
                          <th>Artiste</th>
                          <th>Lieu</th>
                          <th>Ville</th>
                          <th>Programmateur</th>
                          <th>Statut</th>
                          <th>Actions</th>
                        </tr>
                      </thead>
                      <tbody>
                        {dashboardData.upcomingConcerts.map(concert => (
                          <tr key={concert.id}>
                            <td>{formatDate(concert.date)} | {concert.time}</td>
                            <td>{concert.artist.name}</td>
                            <td>{concert.venue}</td>
                            <td>{concert.city}</td>
                            <td>{concert.programmer.name}</td>
                            <td>
                              <span className={`status-badge status-${concert.status}`}>
                                {concert.status}
                              </span>
                            </td>
                            <td className="actions-cell">
                              <Link to={`/concerts/${concert.id}`} className="action-btn view-btn">
                                <i className="fas fa-eye"></i>
                              </Link>
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  )}
                </div>
                <div className="section-footer">
                  <Link to="/concerts" className="add-btn">
                    <i className="fas fa-plus"></i> Gérer les concerts
                  </Link>
                </div>
              </div>
            </div>
          </div>

          {/* Factures impayées */}
          <div className="dashboard-section">
            <div className="section-card">
              <div className="section-header">
                <h2>
                  <i className="fas fa-file-invoice-dollar"></i>
                  Factures impayées
                </h2>
                <div className="section-content">
                  {dashboardData.unpaidInvoices.length === 0 ? (
                    <p className="empty-message">Aucune facture impayée</p>
                  ) : (
                    <table className="data-table">
                      <thead>
                        <tr>
                          <th>Artiste</th>
                          <th>Type</th>
                          <th>Date d'échéance</th>
                          <th>Montant</th>
                          <th>Actions</th>
                        </tr>
                      </thead>
                      <tbody>
                        {dashboardData.unpaidInvoices.map(invoice => (
                          <tr key={invoice.id}>
                            <td>{invoice.concert.artist.name}</td>
                            <td>{invoice.type === 'deposit' ? 'Acompte' : 'Solde'}</td>
                            <td>{formatDate(invoice.dueDate)}</td>
                            <td>{formatPrice(invoice.amount)}</td>
                            <td className="actions-cell">
                              <button className="action-btn edit-btn">
                                <i className="fas fa-edit"></i>
                              </button>
                              <button className="action-btn view-btn">
                                <i className="fas fa-eye"></i>
                              </button>
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  )}
                </div>
              </div>
            </div>
          </div>

          {/* Réservations nécessitant un suivi */}
          <div className="dashboard-section">
            <div className="section-card">
              <div className="section-header">
                <h2>
                  <i className="fas fa-exclamation-triangle"></i>
                  Réservations en attente
                </h2>
                <div className="section-content">
                  {dashboardData.followupBookings.length === 0 ? (
                    <p className="empty-message">Aucune réservation en attente</p>
                  ) : (
                    <table className="data-table">
                      <thead>
                        <tr>
                          <th>Artiste</th>
                          <th>Lieu</th>
                          <th>Dernier contact</th>
                          <th>Statut</th>
                          <th>Actions</th>
                        </tr>
                      </thead>
                      <tbody>
                        {dashboardData.followupBookings.map(booking => (
                          <tr key={booking.id}>
                            <td>{booking.artist.name}</td>
                            <td>{booking.venue}</td>
                            <td>{formatDate(booking.lastContact)}</td>
                            <td>
                              <span className={`status-badge status-${booking.status}`}>
                                {booking.status.charAt(0).toUpperCase() + booking.status.slice(1).replace('_', ' ')}
                              </span>
                            </td>
                            <td className="actions-cell">
                              <button className="action-btn edit-btn">
                                <i className="fas fa-edit"></i>
                              </button>
                              <button className="action-btn view-btn">
                                <i className="fas fa-eye"></i>
                              </button>
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  )}
                </div>
              </div>
            </div>
          </div>

          {/* Contrats manquants */}
          <div className="dashboard-section">
            <div className="section-card">
              <div className="section-header">
                <h2>
                  <i className="fas fa-file-contract"></i>
                  Contrats manquants
                </h2>
                <div className="section-content">
                  {dashboardData.missingContracts.length === 0 ? (
                    <p className="empty-message">Aucun contrat manquant</p>
                  ) : (
                    <table className="data-table">
                      <thead>
                        <tr>
                          <th>Artiste</th>
                          <th>Lieu</th>
                          <th>Date</th>
                          <th>Actions</th>
                        </tr>
                      </thead>
                      <tbody>
                        {dashboardData.missingContracts.map(contract => (
                          <tr key={contract.id}>
                            <td>{contract.artist.name}</td>
                            <td>{contract.venue}</td>
                            <td>{formatDate(contract.date)} | {contract.time}</td>
                            <td className="actions-cell">
                              <button className="action-btn edit-btn">
                                <i className="fas fa-edit"></i>
                              </button>
                              <button className="action-btn view-btn">
                                <i className="fas fa-eye"></i>
                              </button>
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  )}
                </div>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default Dashboard;
