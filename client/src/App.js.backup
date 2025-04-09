import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import Layout from './components/common/Layout';
import ArtistsList from './components/artists/ArtistsList';
import ArtistDetail from './components/artists/ArtistDetail';
import ProgrammersList from './components/programmers/ProgrammersList';
import ProgrammerDetail from './components/programmers/ProgrammerDetail';
import ConcertsList from './components/concerts/ConcertsList';
import ConcertDetail from './components/concerts/ConcertDetail';
import ContractsTable from './components/contracts/ContractsTable';
import FormValidationList from './components/formValidation/FormValidationList';
import PublicFormPage from './components/public/PublicFormPage';
import FormSubmittedPage from './components/public/FormSubmittedPage';
import './App.css';

function App() {
  return (
    <Router>
      <Routes>
        {/* Routes publiques pour les formulaires */}
        <Route path="/form/:token" element={<PublicFormPage />} />
        <Route path="/form-submitted" element={<FormSubmittedPage />} />
        
        {/* Routes protégées par le layout */}
        <Route path="/" element={<Layout />}>
          <Route index element={<Navigate to="/concerts" replace />} />
          <Route path="artists" element={<ArtistsList />} />
          <Route path="artists/:id" element={<ArtistDetail />} />
          <Route path="programmers" element={<ProgrammersList />} />
          <Route path="programmers/:id" element={<ProgrammerDetail />} />
          <Route path="concerts" element={<ConcertsList />} />
          <Route path="concerts/:id" element={<ConcertDetail />} />
          <Route path="contrats" element={<ContractsTable />} />
          <Route path="form-validation" element={<FormValidationList />} />
        </Route>
      </Routes>
    </Router>
  );
}

export default App;
