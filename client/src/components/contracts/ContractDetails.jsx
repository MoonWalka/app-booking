import React from 'react';
import { useParams } from 'react-router-dom';

const ContractDetails = () => {
  const { id } = useParams();
  
  return (
    <div className="contract-details-container">
      <h1>Détails du contrat</h1>
      <p>ID du contrat: {id}</p>
      <p>Cette page est en cours de développement.</p>
    </div>
  );
};

export default ContractDetails;
