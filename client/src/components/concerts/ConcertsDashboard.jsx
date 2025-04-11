import React, { useState, useEffect } from 'react';
import { FaCalendarAlt, FaUsers, FaMoneyBillWave, FaChartLine } from 'react-icons/fa';
import './ConcertsDashboard.css';

const ConcertsDashboard = ({ concerts }) => {
  const [stats, setStats] = useState({
    totalConcerts: 0,
    upcomingConcerts: 0,
    totalRevenue: 0,
    averageAttendance: 0
  });

  useEffect(() => {
    if (concerts && concerts.length > 0) {
      // Calculer les statistiques
      const now = new Date();
      const upcoming = concerts.filter(concert => {
        const concertDate = new Date(concert.date);
        return concertDate > now;
      });
      
      const revenue = concerts.reduce((total, concert) => {
        return total + (parseFloat(concert.amount) || 0);
      }, 0);
      
      const attendance = concerts.reduce((total, concert) => {
        return total + (parseInt(concert.attendance) || 0);
      }, 0);
      
      setStats({
        totalConcerts: concerts.length,
        upcomingConcerts: upcoming.length,
        totalRevenue: revenue,
        averageAttendance: concerts.length > 0 ? Math.round(attendance / concerts.length) : 0
      });
    }
  }, [concerts]);

  // Fonction pour formater les montants en euros
  const formatCurrency = (amount) => {
    return new Intl.NumberFormat('fr-FR', { style: 'currency', currency: 'EUR' }).format(amount);
  };

  return (
    <div className="concerts-dashboard">
      <h2 className="dashboard-title">Tableau de bord des concerts</h2>
      
      <div className="stats-container">
        <div className="stat-card">
          <div className="stat-icon">
            <FaCalendarAlt />
          </div>
          <div className="stat-content">
            <h3>Concerts totaux</h3>
            <p className="stat-value">{stats.totalConcerts}</p>
          </div>
        </div>
        
        <div className="stat-card">
          <div className="stat-icon">
            <FaCalendarAlt />
          </div>
          <div className="stat-content">
            <h3>Concerts à venir</h3>
            <p className="stat-value">{stats.upcomingConcerts}</p>
          </div>
        </div>
        
        <div className="stat-card">
          <div className="stat-icon">
            <FaMoneyBillWave />
          </div>
          <div className="stat-content">
            <h3>Revenus totaux</h3>
            <p className="stat-value">{formatCurrency(stats.totalRevenue)}</p>
          </div>
        </div>
        
        <div className="stat-card">
          <div className="stat-icon">
            <FaUsers />
          </div>
          <div className="stat-content">
            <h3>Audience moyenne</h3>
            <p className="stat-value">{stats.averageAttendance}</p>
          </div>
        </div>
      </div>
      
      <div className="recent-concerts">
        <h3>Concerts récents</h3>
        <div className="concerts-table-container">
          <table className="concerts-table">
            <thead>
              <tr>
                <th>Artiste</th>
                <th>Lieu</th>
                <th>Date</th>
                <th>Montant</th>
                <th>Statut</th>
              </tr>
            </thead>
            <tbody>
              {concerts && concerts.length > 0 ? (
                concerts.slice(0, 5).map((concert, index) => (
                  <tr key={index}>
                    <td>{concert.artist || 'Artiste inconnu'}</td>
                    <td>{concert.venue || 'Lieu non spécifié'}</td>
                    <td>{concert.date || 'Date non spécifiée'}</td>
                    <td>{formatCurrency(parseFloat(concert.amount) || 0)}</td>
                    <td>
                      <span className={`status-badge ${concert.status || 'pending'}`}>
                        {concert.status || 'En attente'}
                      </span>
                    </td>
                  </tr>
                ))
              ) : (
                <tr>
                  <td colSpan="5" className="no-data">Aucun concert trouvé</td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};

export default ConcertsDashboard;
