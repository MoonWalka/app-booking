import React, { useEffect } from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';
import { useAuth } from './context/AuthContext';
import Dashboard from './components/dashboard/Dashboard';
import ProgrammersList from './components/programmers/ProgrammersList';
import ProgrammerDetail from './components/programmers/ProgrammerDetail';
import ConcertsList from './components/concerts/ConcertsList';
import ConcertDetail from './components/concerts/ConcertDetail';
import EmailSystem from './components/emails/EmailSystem';
import DocumentsManager from './components/documents/DocumentsManager';
import Layout from './components/common/Layout';
import Login from './components/auth/Login';
import ArtistsList from './components/artists/ArtistsList';
import ArtistDetail from './components/artists/ArtistDetail';
import NotFound from './components/common/NotFound';
import './App.css';

const ProtectedRoute = ({ children }) => {
  const { isAuthenticated, loading } = useAuth();
  
  if (loading) {
    return 
Chargement...
;
  }
  
  return isAuthenticated ? children : ;
};

function App() {
  return (
    
      } />
      
      
          
        
      }>
        } />
        } />
        } />
        } />
        } />
        } />
        } />
        } />
        } />
      
      
      } />
    
  );
}

export default App;
