// client/src/components/common/Layout.js
import React from 'react';
import { Outlet, Link, useNavigate, useLocation } from 'react-router-dom';
import { useAuth } from '../../context/AuthContext';


const Layout = () => {
  const { currentUser, logout } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();

  const handleLogout = () => {
    logout();
    navigate('/login');
  };

  const isActive = (path) => {
    return location.pathname === path;
  };

  return (
    <div className="app-container">
      <aside className="sidebar">
        <div className="sidebar-header">
          <Link to="/" className="logo">
            <span className="logo-text">Label Musical</span>
          </Link>
          <div className="sidebar-subtitle">Gestion des concerts et artistes</div>
        </div>
        
        <nav className="sidebar-nav">
          <Link to="/" className={`nav-item ${isActive('/') ? 'active' : ''}`}>
            <span className="nav-icon">
              <i className="fas fa-chart-line"></i>
            </span>
            Tableau de bord
          </Link>
          <Link to="/contrats" className={`nav-item ${isActive('/contrats') ? 'active' : ''}`}>
            <span className="nav-icon">
              <i className="fas fa-file-contract"></i>
            </span>
            Contrats
          </Link>
          <Link to="/factures" className={`nav-item ${isActive('/factures') ? 'active' : ''}`}>
            <span className="nav-icon">
              <i className="fas fa-file-invoice-dollar"></i>
            </span>
            Factures
          </Link>
          <Link to="/concerts" className={`nav-item ${isActive('/concerts') ? 'active' : ''}`}>
            <span className="nav-icon">
              <i className="fas fa-calendar-alt"></i>
            </span>
            Concerts
          </Link>
          <Link to="/artistes" className={`nav-item ${isActive('/artistes') ? 'active' : ''}`}>
            <span className="nav-icon">
              <i className="fas fa-music"></i>
            </span>
            Artistes
          </Link>
          <Link to="/programmateurs" className={`nav-item ${isActive('/programmateurs') ? 'active' : ''}`}>
            <span className="nav-icon">
              <i className="fas fa-user-tie"></i>
            </span>
            Programmateurs
          </Link>
          <Link to="/validation-formulaires" className={`nav-item ${isActive('/validation-formulaires') ? 'active' : ''}`}>
            <span className="nav-icon">
              <i className="fas fa-clipboard-check"></i>
            </span>
            Validation Formulaire
          </Link>
          <Link to="/emails" className={`nav-item ${isActive('/emails') ? 'active' : ''}`}>
            <span className="nav-icon">
              <i className="fas fa-envelope"></i>
            </span>
            Emails
          </Link>
          <Link to="/documents" className={`nav-item ${isActive('/documents') ? 'active' : ''}`}>
            <span className="nav-icon">
              <i className="fas fa-file-alt"></i>
            </span>
            Documents
          </Link>
          <Link to="/parametres" className={`nav-item ${isActive('/parametres') ? 'active' : ''}`}>
            <span className="nav-icon">
              <i className="fas fa-cog"></i>
            </span>
            Paramètres
          </Link>
        </nav>
      </aside>
      
      <div className="main-content">
        <header className="main-header">
          <div className="page-title">
            {location.pathname === '/' && 'Tableau de bord'}
            {location.pathname === '/contrats' && 'Gestion des contrats'}
            {location.pathname === '/factures' && 'Gestion des factures'}
            {location.pathname === '/concerts' && 'Gestion des concerts'}
            {location.pathname === '/artistes' && 'Gestion des artistes'}
            {location.pathname === '/programmateurs' && 'Gestion des programmateurs'}
            {location.pathname === '/validation-formulaires' && 'Validation des formulaires'}
            {location.pathname === '/emails' && 'Système d\'emails'}
            {location.pathname === '/documents' && 'Gestion des documents'}
            {location.pathname === '/parametres' && 'Paramètres'}
          </div>
          
          <div className="user-menu">
          {currentUser && (
  <>
    <span className="user-name">{currentUser.name || 'Utilisateur'}</span>
    <button onClick={handleLogout} className="logout-btn">
      Déconnexion
    </button>
  </>
)}
          </div>
        </header>
        
        <main className="main-container">
          <Outlet />
        </main>
        
        <footer className="app-footer">
          <p>&copy; {new Date().getFullYear()} App Booking - Tous droits réservés</p>
        </footer>
      </div>
    </div>
  );
};

export default Layout;
