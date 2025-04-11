import React, { useState } from 'react';
import { NavLink, useLocation } from 'react-router-dom';
import './Sidebar.css';

const Sidebar = () => {
  const [isCollapsed, setIsCollapsed] = useState(false);
  const location = useLocation();
  
  const toggleSidebar = () => {
    setIsCollapsed(!isCollapsed);
  };
  
  const isActive = (path) => {
    return location.pathname === path;
  };
  
  return (
    <div className={`sidebar ${isCollapsed ? 'collapsed' : ''}`}>
      <div className="sidebar-header">
        <h2 className="app-title">Booking App</h2>
        <button className="toggle-button" onClick={toggleSidebar}>
          {isCollapsed ? '→' : '←'}
        </button>
      </div>
      
      <nav className="sidebar-nav">
        <ul>
          <li>
            <NavLink to="/dashboard" className={isActive('/dashboard') ? 'active' : ''}>
              <span className="icon">📊</span>
              <span className="text">Tableau de bord</span>
            </NavLink>
          </li>
          <li>
            <NavLink to="/concerts" className={isActive('/concerts') ? 'active' : ''}>
              <span className="icon">🎵</span>
              <span className="text">Concerts</span>
            </NavLink>
          </li>
          <li>
            <NavLink to="/artists" className={isActive('/artists') ? 'active' : ''}>
              <span className="icon">🎤</span>
              <span className="text">Artistes</span>
            </NavLink>
          </li>
          <li>
            <NavLink to="/programmers" className={isActive('/programmers') ? 'active' : ''}>
              <span className="icon">👥</span>
              <span className="text">Programmateurs</span>
            </NavLink>
          </li>
          <li>
            <NavLink to="/contracts" className={isActive('/contracts') ? 'active' : ''}>
              <span className="icon">📝</span>
              <span className="text">Contrats</span>
            </NavLink>
          </li>
          <li>
            <NavLink to="/invoices" className={isActive('/invoices') ? 'active' : ''}>
              <span className="icon">💰</span>
              <span className="text">Factures</span>
            </NavLink>
          </li>
          <li>
            <NavLink to="/emails" className={isActive('/emails') ? 'active' : ''}>
              <span className="icon">✉️</span>
              <span className="text">Emails</span>
            </NavLink>
          </li>
          <li>
            <NavLink to="/documents" className={isActive('/documents') ? 'active' : ''}>
              <span className="icon">📄</span>
              <span className="text">Documents</span>
            </NavLink>
          </li>
          <li>
            <NavLink to="/form-validation" className={isActive('/form-validation') ? 'active' : ''}>
              <span className="icon">✓</span>
              <span className="text">Validation de formulaire</span>
            </NavLink>
          </li>
          <li>
            <NavLink to="/settings" className={isActive('/settings') ? 'active' : ''}>
              <span className="icon">⚙️</span>
              <span className="text">Paramètres</span>
            </NavLink>
          </li>
        </ul>
      </nav>
      
      <div className="sidebar-footer">
        <p className="version">v1.0.0</p>
      </div>
    </div>
  );
};

export default Sidebar;
