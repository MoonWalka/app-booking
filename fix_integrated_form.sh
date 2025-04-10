#!/bin/bash

# Script pour implémenter les améliorations de gestion des formulaires publics
# dans l'application de booking musical

echo "Début de l'implémentation des améliorations..."

# Création du répertoire utils s'il n'existe pas
mkdir -p ./client/src/utils

# Création du fichier tokenGenerator.js
echo "Création du système de token commun..."
cat > ./client/src/utils/tokenGenerator.js << 'EOL'
/**
 * Utilitaire pour générer et gérer les tokens communs entre les entités
 * (programmateur, concert, contrat)
 */

/**
 * Génère un token unique basé sur l'ID du concert et un timestamp
 * @param {string} concertId - ID du concert
 * @returns {string} Token unique
 */
export const generateToken = (concertId) => {
  const timestamp = Date.now();
  const randomPart = Math.random().toString(36).substring(2, 8);
  return `${concertId}-${timestamp}-${randomPart}`;
};

/**
 * Extrait l'ID du concert à partir d'un token
 * @param {string} token - Token à analyser
 * @returns {string|null} ID du concert ou null si le format est invalide
 */
export const extractConcertIdFromToken = (token) => {
  if (!token || typeof token !== 'string') return null;
  
  const parts = token.split('-');
  if (parts.length < 3) return null;
  
  return parts[0];
};

/**
 * Vérifie si un token est valide
 * @param {string} token - Token à vérifier
 * @returns {boolean} True si le token est valide, false sinon
 */
export const isValidToken = (token) => {
  if (!token || typeof token !== 'string') return false;
  
  // Format attendu: concertId-timestamp-random
  const parts = token.split('-');
  if (parts.length < 3) return false;
  
  // Vérifier que le timestamp est un nombre
  const timestamp = parseInt(parts[1], 10);
  if (isNaN(timestamp)) return false;
  
  return true;
};

/**
 * Génère un token pour un nouveau formulaire
 * @param {string} concertId - ID du concert
 * @returns {Object} Objet contenant le token et des métadonnées
 */
export const generateFormToken = (concertId) => {
  const token = generateToken(concertId);
  return {
    token,
    concertId,
    createdAt: new Date(),
    type: 'form'
  };
};
EOL

# Modification du fichier PublicFormPage.jsx
echo "Modification du formulaire public pour intégrer le token commun..."
# Sauvegarde du fichier original
cp ./client/src/components/public/PublicFormPage.jsx ./client/src/components/public/PublicFormPage.jsx.bak

# Ajout de l'import pour le générateur de token
sed -i '3s/import { createFormSubmission } from/import { createFormSubmission } from/' ./client/src/components/public/PublicFormPage.jsx
sed -i '3a import { generateToken } from "../../utils/tokenGenerator";' ./client/src/components/public/PublicFormPage.jsx

# Création du fichier temporaire pour la fonction handleSubmit modifiée
cat > ./temp_handleSubmit.txt << 'EOL'
  const handleSubmit = async (e) => {
    e.preventDefault();
    
    // Vérifier que concertId est disponible
    if (!concertId) {
      setError("Erreur: ID du concert manquant. Veuillez accéder à ce formulaire via un lien valide.");
      return;
    }
    
    try {
      setLoading(true);
      setError(null);
      setSubmissionResult(null);
      
      console.log('PublicFormPage - Début de la soumission du formulaire');
      console.log('PublicFormPage - Données du formulaire:', formData);
      console.log('PublicFormPage - concertId utilisé pour la soumission:', concertId);
      
      // Générer un token commun pour lier les entités
      const commonToken = generateToken(concertId);
      console.log('PublicFormPage - Token commun généré:', commonToken);
      
      // Préparer les données à soumettre avec tous les champs requis
      const submissionData = {
        ...formData,
        // Champs obligatoires pour la compatibilité avec le système existant
        programmerId: 'public-form-submission',
        programmerName: 'Formulaire Public',
        concertId: concertId, // S'assurer que concertId est explicitement inclus
        concertName: `Concert ID: ${concertId}`,
        // Créer un champ contact à partir du prénom et du nom
        contact: formData.firstName && formData.lastName 
          ? `${formData.firstName} ${formData.lastName}` 
          : formData.firstName || formData.lastName || 'Contact non spécifié',
        status: 'pending',
        // Ajouter un formLinkId fictif si nécessaire
        formLinkId: `public-form-${concertId}`,
        // Ajouter le token commun pour lier les entités
        commonToken: commonToken
      };
EOL

# Remplacer la fonction handleSubmit
awk '
/const handleSubmit = async \(e\) => {/ {
  print;
  system("cat ./temp_handleSubmit.txt");
  skip = 1;
  next;
}
/const submissionData = {/ {
  skip = 0;
  next;
}
!skip {
  print;
}
' ./client/src/components/public/PublicFormPage.jsx > ./client/src/components/public/PublicFormPage.jsx.new
mv ./client/src/components/public/PublicFormPage.jsx.new ./client/src/components/public/PublicFormPage.jsx
rm ./temp_handleSubmit.txt

# Modification du service formSubmissionsService.js
echo "Modification du service de soumission de formulaire pour utiliser le token commun..."
# Sauvegarde du fichier original
cp ./client/src/services/formSubmissionsService.js ./client/src/services/formSubmissionsService.js.bak

# Création du fichier temporaire pour la fonction createFormSubmission modifiée
cat > ./temp_createFormSubmission.txt << 'EOL'
export const createFormSubmission = async (formData) => {
  console.log("[createFormSubmission] Début de la création d'un nouveau formulaire");
  console.log("[createFormSubmission] Données reçues:", formData);
  
  try {
    // S'assurer que la collection existe
    console.log("[createFormSubmission] Vérification de l'existence de la collection...");
    const collectionExists = await ensureCollection(FORM_SUBMISSIONS_COLLECTION);
    console.log(`[createFormSubmission] Résultat de la vérification: ${collectionExists ? 'collection existe' : 'échec de la vérification'}`);
    
    // Vérifier les champs obligatoires
    const requiredFields = ['concertId'];
    const missingFields = requiredFields.filter(field => !formData[field]);
    
    if (missingFields.length > 0) {
      console.error(`[createFormSubmission] Champs obligatoires manquants: ${missingFields.join(', ')}`);
      throw new Error(`Champs obligatoires manquants: ${missingFields.join(', ')}`);
    }
    
    // Générer un token commun si non fourni
    let commonToken = formData.commonToken;
    if (!commonToken) {
      // Importer dynamiquement pour éviter les dépendances circulaires
      const { generateToken } = await import('../utils/tokenGenerator');
      commonToken = generateToken(formData.concertId);
      console.log(`[createFormSubmission] Génération d'un nouveau token commun: ${commonToken}`);
    }
    
    // S'assurer que les champs obligatoires sont présents
    const completeFormData = {
      ...formData,
      commonToken, // Ajouter le token commun
      status: formData.status || 'pending',
      submittedAt: Timestamp.fromDate(new Date()),
      // Convertir la date du concert en Timestamp si elle existe
      concertDate: formData.concertDate ? 
        (formData.concertDate instanceof Date ? 
          Timestamp.fromDate(formData.concertDate) : 
          formData.concertDate) : 
        null
    };
EOL

# Remplacer la fonction createFormSubmission
awk '
/export const createFormSubmission = async \(formData\) => {/ {
  system("cat ./temp_createFormSubmission.txt");
  skip = 1;
  next;
}
/const completeFormData = {/ {
  skip = 0;
  next;
}
!skip {
  print;
}
' ./client/src/services/formSubmissionsService.js > ./client/src/services/formSubmissionsService.js.new
mv ./client/src/services/formSubmissionsService.js.new ./client/src/services/formSubmissionsService.js
rm ./temp_createFormSubmission.txt

# Ajout du log pour le token commun
sed -i '/console.log("\[createFormSubmission\] Vérification de la présence de concertId:", completeFormData.concertId ? "Présent" : "Manquant");/a \    console.log("[createFormSubmission] Token commun utilisé:", completeFormData.commonToken);' ./client/src/services/formSubmissionsService.js

# Création du composant ComparisonTable
echo "Création de l'interface de comparaison..."
mkdir -p ./client/src/components/formValidation

# Création du fichier ComparisonTable.jsx
cat > ./client/src/components/formValidation/ComparisonTable.jsx << 'EOL'
import React, { useState } from 'react';
import { updateProgrammer } from '../../services/programmersService';
import { updateFormSubmission } from '../../services/formSubmissionsService';
import './ComparisonTable.css';

/**
 * Composant d'interface de comparaison entre les données du formulaire et la fiche programmateur
 * Permet de visualiser côte à côte les données et de copier les valeurs avec des flèches
 */
const ComparisonTable = ({ formData, programmer, onClose, onSuccess }) => {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  
  // État pour stocker les données modifiées du programmateur
  const [updatedProgrammerData, setUpdatedProgrammerData] = useState({...programmer});
  
  // Liste des champs à comparer
  const fieldsToCompare = [
    { key: 'businessName', label: 'Raison sociale' },
    { key: 'firstName', label: 'Prénom', programmerKey: 'firstName' },
    { key: 'lastName', label: 'Nom', programmerKey: 'lastName' },
    { key: 'role', label: 'Qualité' },
    { key: 'address', label: 'Adresse de la raison sociale' },
    { key: 'venue', label: 'Lieu ou festival' },
    { key: 'venueAddress', label: 'Adresse du lieu ou festival', programmerKey: 'venueAddress' },
    { key: 'vatNumber', label: 'Numéro intracommunautaire' },
    { key: 'siret', label: 'Siret' },
    { key: 'email', label: 'Mail' },
    { key: 'phone', label: 'Téléphone' },
    { key: 'website', label: 'Site web' }
  ];
  
  // Fonction pour copier une valeur du formulaire vers la fiche programmateur
  const copyValueToProgrammer = (field) => {
    const sourceKey = field.key;
    const targetKey = field.programmerKey || field.key;
    
    if (formData[sourceKey]) {
      setUpdatedProgrammerData(prev => ({
        ...prev,
        [targetKey]: formData[sourceKey]
      }));
    }
  };
  
  // Fonction pour valider les modifications
  const handleValidate = async () => {
    try {
      setLoading(true);
      setError(null);
      
      // Mettre à jour la fiche programmateur avec les données modifiées
      await updateProgrammer(programmer.id, {
        ...updatedProgrammerData,
        // Ajouter le token commun pour lier les entités
        commonToken: formData.commonToken
      });
      
      // Marquer le formulaire comme traité
      await updateFormSubmission(formData.id, {
        status: 'processed',
        processedAt: new Date()
      });
      
      setLoading(false);
      
      // Appeler le callback de succès
      if (onSuccess) {
        onSuccess();
      }
      
    } catch (err) {
      console.error("Erreur lors de la validation des modifications:", err);
      setError(err.message);
      setLoading(false);
    }
  };
  
  return (
    <div className="comparison-table-container">
      <div className="comparison-table-header">
        <h3>Comparaison des données</h3>
        <button className="close-btn" onClick={onClose}>
          <i className="fas fa-times"></i>
        </button>
      </div>
      
      {error && (
        <div className="comparison-error">
          <i className="fas fa-exclamation-circle"></i> {error}
        </div>
      )}
      
      <div className="comparison-table">
        <div className="comparison-table-row header">
          <div className="comparison-field">Champ</div>
          <div className="comparison-form-value">Valeur du formulaire</div>
          <div className="comparison-action"></div>
          <div className="comparison-programmer-value">Fiche programmateur</div>
        </div>
        
        {fieldsToCompare.map((field) => {
          const formValue = formData[field.key];
          const programmerKey = field.programmerKey || field.key;
          const programmerValue = updatedProgrammerData[programmerKey];
          
          return (
            <div className="comparison-table-row" key={field.key}>
              <div className="comparison-field">{field.label}</div>
              <div className="comparison-form-value">
                {formValue || <span className="empty-value">Non renseigné</span>}
              </div>
              <div className="comparison-action">
                {formValue && (
                  <button 
                    className="copy-arrow-btn"
                    onClick={() => copyValueToProgrammer(field)}
                    disabled={loading}
                  >
                    <i className="fas fa-arrow-right"></i>
                  </button>
                )}
              </div>
              <div className="comparison-programmer-value">
                {programmerValue || <span className="empty-value">Non renseigné</span>}
              </div>
            </div>
          );
        })}
      </div>
      
      <div className="comparison-actions">
        <button 
          className="cancel-btn"
          onClick={onClose}
          disabled={loading}
        >
          Annuler
        </button>
        <button 
          className="validate-btn"
          onClick={handleValidate}
          disabled={loading}
        >
          {loading ? 'Validation en cours...' : 'Valider les modifications'}
        </button>
      </div>
    </div>
  );
};

export default ComparisonTable;
EOL

# Création du fichier CSS pour ComparisonTable
cat > ./client/src/components/formValidation/ComparisonTable.css << 'EOL'
.comparison-table-container {
  background-color: #fff;
  border-radius: 8px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  max-width: 900px;
  margin: 0 auto;
  padding: 20px;
  position: relative;
}

.comparison-table-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  padding-bottom: 15px;
  border-bottom: 1px solid #eaeaea;
}

.comparison-table-header h3 {
  margin: 0;
  font-size: 1.5rem;
  color: #333;
}

.close-btn {
  background: none;
  border: none;
  font-size: 1.2rem;
  color: #666;
  cursor: pointer;
  padding: 5px;
}

.close-btn:hover {
  color: #333;
}

.comparison-error {
  background-color: #fff3f3;
  border-left: 4px solid #e74c3c;
  padding: 12px 15px;
  margin-bottom: 20px;
  color: #e74c3c;
  border-radius: 4px;
}

.comparison-table {
  width: 100%;
  border-collapse: collapse;
  margin-bottom: 20px;
}

.comparison-table-row {
  display: grid;
  grid-template-columns: 1fr 2fr 80px 2fr;
  border-bottom: 1px solid #eaeaea;
  padding: 12px 0;
}

.comparison-table-row.header {
  font-weight: bold;
  background-color: #f8f9fa;
  border-bottom: 2px solid #ddd;
  padding: 15px 0;
}

.comparison-field, 
.comparison-form-value, 
.comparison-action, 
.comparison-programmer-value {
  padding: 8px 12px;
  display: flex;
  align-items: center;
}

.comparison-field {
  font-weight: 500;
  color: #555;
}

.comparison-form-value {
  background-color: #f8f9fa;
  border-radius: 4px;
  word-break: break-word;
}

.comparison-programmer-value {
  background-color: #fff;
  border: 1px solid #eaeaea;
  border-radius: 4px;
  word-break: break-word;
}

.empty-value {
  color: #999;
  font-style: italic;
}

.copy-arrow-btn {
  background-color: #3498db;
  color: white;
  border: none;
  border-radius: 50%;
  width: 36px;
  height: 36px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: background-color 0.2s;
}

.copy-arrow-btn:hover {
  background-color: #2980b9;
}

.copy-arrow-btn:disabled {
  background-color: #95a5a6;
  cursor: not-allowed;
}

.comparison-actions {
  display: flex;
  justify-content: flex-end;
  gap: 15px;
  margin-top: 20px;
}

.cancel-btn, .validate-btn {
  padding: 10px 20px;
  border-radius: 4px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s;
}

.cancel-btn {
  background-color: #f8f9fa;
  border: 1px solid #ddd;
  color: #555;
}

.cancel-btn:hover {
  background-color: #eaeaea;
}

.validate-btn {
  background-color: #2ecc71;
  border: none;
  color: white;
}

.validate-btn:hover {
  background-color: #27ae60;
}

.validate-btn:disabled, .cancel-btn:disabled {
  opacity: 0.7;
  cursor: not-allowed;
}

/* Responsive design */
@media (max-width: 768px) {
  .comparison-table-row {
    grid-template-columns: 1fr;
    gap: 10px;
    padding: 15px 0;
  }
  
  .comparison-table-row.header {
    display: none;
  }
  
  .comparison-field, 
  .comparison-form-value, 
  .comparison-action, 
  .comparison-programmer-value {
    padding: 8px;
  }
  
  .comparison-field {
    font-weight: bold;
    background-color: #f8f9fa;
    border-radius: 4px 4px 0 0;
    margin-top: 10px;
  }
  
  .comparison-action {
    display: flex;
    justify-content: center;
  }
  
  .comparison-programmer-value {
    border-radius: 0 0 4px 4px;
  }
}
EOL

# Modification du fichier FormValidationList.jsx
echo "Intégration de l'interface de comparaison dans la page de validation..."
# Sauvegarde du fichier original
cp ./client/src/components/formValidation/FormValidationList.jsx ./client/src/components/formValidation/FormValidationList.jsx.bak

# Ajout de l'import pour ComparisonTable
sed -i '4s/import { getProgrammerById, updateProgrammer } from/import { getProgrammerById, updateProgrammer } from/' ./client/src/components/formValidation/FormValidationList.jsx
sed -i '4a import ComparisonTable from "./ComparisonTable";' ./client/src/components/formValidation/FormValidationList.jsx

# Ajout des états pour la table de comparaison
sed -i '/const \[showModal, setShowModal\] = useState(false);/a \  const [showComparisonTable, setShowComparisonTable] = useState(false);\n  const [programmerData, setProgrammerData] = useState(null);' ./client/src/components/formValidation/FormValidationList.jsx

# Création du fichier temporaire pour la fonction closeModal modifiée
cat > ./temp_closeModal.txt << 'EOL'
  const closeModal = () => {
    setSelectedForm(null);
    setShowModal(false);
    setShowComparisonTable(false);
    setProgrammerData(null);
  };
EOL

# Remplacer la fonction closeModal
awk '
/const closeModal = \(\) => {/ {
  system("cat ./temp_closeModal.txt");
  skip = 1;
  next;
}
/};/ {
  if (skip) {
    skip = 0;
    next;
  }
  print;
  next;
}
!skip {
  print;
}
' ./client/src/components/formValidation/FormValidationList.jsx > ./client/src/components/formValidation/FormValidationList.jsx.new
mv ./client/src/components/formValidation/FormValidationList.jsx.new ./client/src/components/formValidation/FormValidationList.jsx
rm ./temp_closeModal.txt

# Ajout de la fonction handleShowComparisonTable après closeModal
sed -i '/const closeModal = () => {/,/};/!b;/};/a \
  \
  const handleShowComparisonTable = async (form) => {\
    try {\
      setProcessingAction(true);\
      \
      // Récupérer les données du programmateur\
      if (form.programmerId) {\
        const programmer = await getProgrammerById(form.programmerId);\
        if (programmer) {\
          setProgrammerData(programmer);\
          setShowComparisonTable(true);\
          setShowModal(false);\
        } else {\
          alert("Impossible de récupérer les données du programmateur.");\
        }\
      } else {\
        alert("Ce formulaire n'\''est pas associé à un programmateur existant.");\
      }\
      \
      setProcessingAction(false);\
    } catch (err) {\
      console.error("Erreur lors de la récupération des données du programmateur:", err);\
      setError(err.message);\
      setProcessingAction(false);\
      alert(`Erreur: ${err.message}`);\
    }\
  };' ./client/src/components/formValidation/FormValidationList.jsx

# Création du fichier temporaire pour l'affichage du token commun
cat > ./temp_token_display.txt << 'EOL'
                  
                  {selectedForm.commonToken && (
                    <div className="form-data-item">
                      <span className="form-data-label">Token commun:</span>
                      <span className="form-data-value">{selectedForm.commonToken}</span>
                    </div>
                  )}
EOL

# Ajout de l'affichage du token commun dans le modal
sed -i '/<div className="form-data-item">/,/<\/div>/!b;/<\/div>/h;/<div className="form-data-item">/,/<\/div>/!d;x;/Site web/!b;x;G;s/\(.*Site web.*\n.*\)/\1\n                  \
                  {selectedForm.commonToken \&\& (\
                    <div className="form-data-item">\
                      <span className="form-data-label">Token commun:<\/span>\
                      <span className="form-data-value">{selectedForm.commonToken}<\/span>\
                    <\/div>\
                  )}/' ./client/src/components/formValidation/FormValidationList.jsx

# Modification du bouton d'intégration pour utiliser la table de comparaison
sed -i '/<button.*className="integrate-data-btn"/,/<\/button>/c\                    <button \
                      className="compare-data-btn"\
                      onClick={() => handleShowComparisonTable(selectedForm)}\
                      disabled={processingAction}\
                    >\
                      {processingAction ? "Chargement..." : "Comparer et intégrer les données"}\
                    </button>' ./client/src/components/formValidation/FormValidationList.jsx

# Création du fichier temporaire pour le composant ComparisonTable
cat > ./temp_comparison_component.txt << 'EOL'
      
      {/* Tableau de comparaison */}
      {showComparisonTable && selectedForm && programmerData && (
        <div className="form-modal-overlay">
          <ComparisonTable 
            formData={selectedForm}
            programmer={programmerData}
            onClose={closeModal}
            onSuccess={() => {
              // Rafraîchir la liste des formulaires après une intégration réussie
              setFormSubmissions(prevForms => 
                prevForms.map(form => 
                  form.id === selectedForm.id 
                    ? { ...form, status: 'processed', processedAt: new Date() } 
                    : form
                )
              );
              closeModal();
              alert('Les données ont été intégrées avec succès à la fiche du programmateur.');
            }}
          />
        </div>
      )}
EOL

# Ajout du composant ComparisonTable à la fin du composant FormValidationList
sed -i '/return (/,/);/!b;/);/i \
      \
      {/* Tableau de comparaison */}\
      {showComparisonTable && selectedForm && programmerData && (\
        <div className="form-modal-overlay">\
          <ComparisonTable \
            formData={selectedForm}\
            programmer={programmerData}\
            onClose={closeModal}\
            onSuccess={() => {\
              // Rafraîchir la liste des formulaires après une intégration réussie\
              setFormSubmissions(prevForms => \
                prevForms.map(form => \
                  form.id === selectedForm.id \
                    ? { ...form, status: "processed", processedAt: new Date() } \
                    : form\
                )\
              );\
              closeModal();\
              alert("Les données ont été intégrées avec succès à la fiche du programmateur.");\
            }}\
          />\
        </div>\
      )}' ./client/src/components/formValidation/FormValidationList.jsx

echo "Toutes les modifications ont été appliquées avec succès!"
echo "Vous pouvez maintenant tester l'application avec les nouvelles fonctionnalités."
