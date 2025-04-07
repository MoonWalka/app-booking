// client/src/components/common/Layout.js
import React from 'react';
import { Outlet, Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../../context/AuthContext';

const Layout = () => {
  const { currentUser, logout } = useAuth();
  const navigate = useNavigate();

  const handleLogout = () => {
    logout();
    navigate('/login');
  };

  return (
    <div className="app-layout">
      <header className="app-header">
        <div className="logo-container">
          <Link to="/" className="logo">App Booking</Link>
        </div>
        <nav className="main-nav">
          <ul>
            <li>
              <Link to="/">Dashboard</Link>
            </li>
            <li>
              <Link to="/programmateurs">Programmateurs</Link>
            </li>
            <li>
              <Link to="/concerts">Concerts</Link>
            </li>
            <li>
              <Link to="/artistes">Artistes</Link>
            </li>
            <li>
              <Link to="/emails">Emails</Link>
            </li>
            <li>
              <Link to="/documents">Documents</Link>
            </li>
          </ul>
        </nav>
        <div className="user-menu">
          {currentUser && (
            <>
              <span className="user-name">{currentUser.name}</span>
              <button onClick={handleLogout} className="logout-btn">
                Déconnexion
              </button>
            </>
          )}
        </div>
      </header>
      
      <main className="app-content">
        <Outlet />
      </main>
      
      <footer className="app-footer">
        <p>&copy; {new Date().getFullYear()} App Booking - Tous droits réservés</p>
      </footer>
    </div>
  );
};

export default Layout;
