import React from 'react';

const PublicFormPage = () => {
  console.log("PublicFormPage loaded");
  return (
    <div style={{ padding: "20px", textAlign: "center" }}>
      <h2>Public Form Page Loaded</h2>
      <p>Ce message doit s'afficher si la route /form/:token est correctement atteinte.</p>
    </div>
  );
};

export default PublicFormPage;
