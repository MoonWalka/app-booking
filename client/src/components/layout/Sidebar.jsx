import React from 'react';
import { Link, useLocation } from 'react-router-dom';
import { FaChartLine, FaFileContract, FaFileInvoiceDollar, FaMusic, FaUserTie, FaUsers, FaClipboardCheck, FaEnvelope, FaFile, FaCog } from 'react-icons/fa';
import './Sidebar.css';

const Sidebar = () => {
  const location = useLocation();
  const path = location.pathname;

  const isActive = (route) => {
    return path === route || (path.startsWith(route) && route !== '/');
  };

  return (
    <div className="sidebar">
      <div className="logo-container">
        <Link to="/" className="logo">
          <div className="logo-badge">+</div>
          <div>Label Musical</div>
        </Link>
        <div className="logo-subtitle">Gestion des concerts et artistes</div>
      </div>
      
      <nav className="sidebar-nav">
        <Link to="/" className={isActive('/') ? 'active' : ''}>
          <FaChartLine className="nav-icon" />
          <span>Tableau de bord</span>
        </Link>
        
        <Link to="/contrats" className={isActive('/contrats') ? 'active' : ''}>
          <FaFileContract className="nav-icon" />
          <span>Contrats</span>
        </Link>
        
        <Link to="/factures" className={isActive('/factures') ? 'active' : ''}>
          <FaFileInvoiceDollar className="nav-icon" />
          <span>Factures</span>
        </Link>
        
        <Link to="/concerts" className={isActive('/concerts') ? 'active' : ''}>
          <FaMusic className="nav-icon" />
          <span>Concerts</span>
        </Link>
        
        <Link to="/artistes" className={isActive('/artistes') ? 'active' : ''}>
          <FaUserTie className="nav-icon" />
          <span>Artistes</span>
        </Link>
        
        <Link to="/programmateurs" className={isActive('/programmateurs') ? 'active' : ''}>
          <FaUsers className="nav-icon" />
          <span>Programmateurs</span>
        </Link>
        
        <Link to="/validation-formulaire" className={isActive('/validation-formulaire') ? 'active' : ''}>
          <FaClipboardCheck className="nav-icon" />
          <span>Validation Formulaire</span>
        </Link>
        
        <Link to="/emails" className={isActive('/emails') ? 'active' : ''}>
          <FaEnvelope className="nav-icon" />
          <span>Emails</span>
        </Link>
        
        <Link to="/documents" className={isActive('/documents') ? 'active' : ''}>
          <FaFile className="nav-icon" />
          <span>Documents</span>
        </Link>
        
        <Link to="/parametres" className={isActive('/parametres') ? 'active' : ''}>
          <FaCog className="nav-icon" />
          <span>Paramètres</span>
        </Link>
      </nav>
    </div>
  );
};

export default Sidebar;
