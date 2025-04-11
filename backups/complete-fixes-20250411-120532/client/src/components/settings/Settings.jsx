import React, { useState, useEffect } from 'react';
import './Settings.css';

const Settings = () => {
  const [settings, setSettings] = useState({
    notifications: true,
    darkMode: false,
    language: 'fr',
    emailNotifications: true,
    autoSave: true
  });
  
  const [isSaving, setIsSaving] = useState(false);
  const [saveMessage, setSaveMessage] = useState('');
  
  useEffect(() => {
    // Simuler le chargement des paramètres depuis le stockage local
    const savedSettings = localStorage.getItem('appSettings');
    if (savedSettings) {
      try {
        setSettings(JSON.parse(savedSettings));
      } catch (error) {
        console.error('Erreur lors du chargement des paramètres:', error);
      }
    }
  }, []);
  
  const handleChange = (e) => {
    const { name, value, type, checked } = e.target;
    setSettings(prev => ({
      ...prev,
      [name]: type === 'checkbox' ? checked : value
    }));
  };
  
  const handleSubmit = (e) => {
    e.preventDefault();
    setIsSaving(true);
    
    // Simuler une sauvegarde asynchrone
    setTimeout(() => {
      try {
        localStorage.setItem('appSettings', JSON.stringify(settings));
        setSaveMessage('Paramètres enregistrés avec succès');
        setIsSaving(false);
        
        // Effacer le message après 3 secondes
        setTimeout(() => {
          setSaveMessage('');
        }, 3000);
      } catch (error) {
        console.error('Erreur lors de la sauvegarde des paramètres:', error);
        setSaveMessage('Erreur lors de la sauvegarde des paramètres');
        setIsSaving(false);
      }
    }, 1000);
  };
  
  const resetSettings = () => {
    const defaultSettings = {
      notifications: true,
      darkMode: false,
      language: 'fr',
      emailNotifications: true,
      autoSave: true
    };
    
    setSettings(defaultSettings);
    localStorage.setItem('appSettings', JSON.stringify(defaultSettings));
    setSaveMessage('Paramètres réinitialisés');
    
    // Effacer le message après 3 secondes
    setTimeout(() => {
      setSaveMessage('');
    }, 3000);
  };
  
  return (
    <div className="settings-container">
      <h1>Paramètres</h1>
      
      <form onSubmit={handleSubmit} className="settings-form">
        <div className="settings-section">
          <h2>Général</h2>
          
          <div className="form-group">
            <label htmlFor="language">Langue</label>
            <select 
              id="language" 
              name="language" 
              value={settings.language} 
              onChange={handleChange}
            >
              <option value="fr">Français</option>
              <option value="en">English</option>
              <option value="es">Español</option>
              <option value="de">Deutsch</option>
            </select>
          </div>
          
          <div className="form-group checkbox">
            <input 
              type="checkbox" 
              id="darkMode" 
              name="darkMode" 
              checked={settings.darkMode} 
              onChange={handleChange}
            />
            <label htmlFor="darkMode">Mode sombre</label>
          </div>
          
          <div className="form-group checkbox">
            <input 
              type="checkbox" 
              id="autoSave" 
              name="autoSave" 
              checked={settings.autoSave} 
              onChange={handleChange}
            />
            <label htmlFor="autoSave">Sauvegarde automatique</label>
          </div>
        </div>
        
        <div className="settings-section">
          <h2>Notifications</h2>
          
          <div className="form-group checkbox">
            <input 
              type="checkbox" 
              id="notifications" 
              name="notifications" 
              checked={settings.notifications} 
              onChange={handleChange}
            />
            <label htmlFor="notifications">Activer les notifications</label>
          </div>
          
          <div className="form-group checkbox">
            <input 
              type="checkbox" 
              id="emailNotifications" 
              name="emailNotifications" 
              checked={settings.emailNotifications} 
              onChange={handleChange}
            />
            <label htmlFor="emailNotifications">Notifications par email</label>
          </div>
        </div>
        
        <div className="settings-actions">
          <button type="submit" className="save-button" disabled={isSaving}>
            {isSaving ? 'Enregistrement...' : 'Enregistrer les paramètres'}
          </button>
          <button type="button" className="reset-button" onClick={resetSettings}>
            Réinitialiser
          </button>
        </div>
        
        {saveMessage && (
          <div className="save-message">
            {saveMessage}
          </div>
        )}
      </form>
    </div>
  );
};

export default Settings;
