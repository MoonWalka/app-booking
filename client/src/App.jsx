import React from 'react';
import { HashRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import from './context/AuthContext';

// Composants
import Layout from './components/common/Layout';
import Dashboard from './components/dashboard/Dashboard';
import ConcertsList from './components/concerts/ConcertsList';
import ConcertDetail from './components/concerts/ConcertDetail';
import ArtistsList from './components/artists/ArtistsList';
import ArtistDetail from './components/artists/ArtistDetail';
import ProgrammersList from './components/programmers/ProgrammersList';
import ProgrammerDetail from './components/programmers/ProgrammerDetail';
import ContractsList from './components/contracts/ContractsList';
import ContractDetails from './components/contracts/ContractDetails';
import InvoicesList from './components/invoices/InvoicesList';
import InvoiceDetails from './components/invoices/InvoiceDetails';
import EmailsList from './components/emails/EmailsList';
import DocumentsList from './components/documents/DocumentsList';
import Settings from './components/settings/Settings';
import PublicFormPage from './components/public/PublicFormPage';
import FormValidationList from './components/formValidation/FormValidationList';
import ErrorBoundary from './components/common/ErrorBoundary';

function App() {
  console.log("App - Initialisation de l'application...");
  
  return (
    <ErrorBoundary>
      <AuthProvider>
        <Router>
          <Routes>
            {/* Routes publiques */}
            <Route path="/public-form" element={<PublicFormPage />} />
            
            {/* Routes protégées avec Layout */}
            <Route path="/" element={<Layout />}>
              <Route index element={<Dashboard />} />
              <Route path="dashboard" element={<Dashboard />} />
              <Route path="concerts" element={<ConcertsList />} />
              <Route path="concerts/:id" element={<ConcertDetail />} />
              <Route path="artists" element={<ArtistsList />} />
              <Route path="artists/:id" element={<ArtistDetail />} />
              <Route path="programmers" element={<ProgrammersList />} />
              <Route path="programmers/:id" element={<ProgrammerDetail />} />
              <Route path="contracts" element={<ContractsList />} />
              <Route path="contracts/:id" element={<ContractDetails />} />
              <Route path="invoices" element={<InvoicesList />} />
              <Route path="invoices/:id" element={<InvoiceDetails />} />
              <Route path="emails" element={<EmailsList />} />
              <Route path="documents" element={<DocumentsList />} />
              <Route path="settings" element={<Settings />} />
              <Route path="form-validation" element={<FormValidationList />} />
              <Route path="validation-formulaire" element={<FormValidationList />} />
              <Route path="*" element={<Navigate to="/" replace />} />
            </Route>
          </Routes>
        </Router>
      </AuthProvider>
    </ErrorBoundary>
  );
}

export default App;
