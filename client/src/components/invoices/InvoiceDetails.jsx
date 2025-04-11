import React from 'react';
import { useParams } from 'react-router-dom';

const InvoiceDetails = () => {
  const { id } = useParams();
  
  return (
    <div className="invoice-details-container">
      <h1>Détails de la facture</h1>
      <p>ID de la facture: {id}</p>
      <p>Cette page est en cours de développement.</p>
    </div>
  );
};

export default InvoiceDetails;
