// import React, { useState, useEffect } from 'react';
// import { useParams, useNavigate } from 'react-router-dom';
// import { getFormLinkByToken } from '../../services/formLinkService';
// import { createFormSubmission } from '../../services/formSubmissionsService';
// import './PublicFormPage.css';

// const PublicFormPage = () => {
//   const { token } = useParams();
//   const navigate = useNavigate();
//   const [formLink, setFormLink] = useState(null);
//   const [loading, setLoading] = useState(true);
//   const [error, setError] = useState(null);
//   const [formData, setFormData] = useState({
//     businessName: '',
//     contact: '',
//     role: '',
//     address: '',
//     venue: '',
//     vatNumber: '',
//     siret: '',
//     email: '',
//     phone: '',
//     website: ''
//   });
  
//   // Ajout de logs pour le débogage
//   console.log('PublicFormPage rendered, token:', token);
  
//   useEffect(() => {
//     const fetchFormLink = async () => {
//       try {
//         console.log('Fetching form link for token:', token);
//         setLoading(true);
//         const link = await getFormLinkByToken(token);
//         console.log('Form link result:', link);
        
//         if (!link) {
//           console.error('No form link found for token:', token);
//           setError('Ce lien de formulaire n\'est pas valide ou a expiré.');
//         } else if (link.isSubmitted) {
//           console.log('Form already submitted for token:', token);
//           setError('Ce formulaire a déjà été soumis.');
//         } else {
//           console.log('Form link found and valid:', link);
//           setFormLink(link);
//         }
//       } catch (err) {
//         console.error('Error fetching form link:', err);
//         setError('Une erreur est survenue lors du chargement du formulaire.');
//       } finally {
//         setLoading(false);
//       }
//     };
    
//     if (token) {
//       fetchFormLink();
//     } else {
//       console.error('No token provided in URL');
//       setError('Aucun identifiant de formulaire fourni.');
//       setLoading(false);
//     }
//   }, [token]);
  
//   const handleChange = (e) => {
//     const { name, value } = e.target;
//     setFormData(prev => ({
//       ...prev,
//       [name]: value
//     }));
//   };
  
//   const handleSubmit = async (e) => {
//     e.preventDefault();
    
//     if (!formLink) return;
    
//     try {
//       setLoading(true);
//       console.log('Submitting form data:', formData);
      
//       // Préparer les données à soumettre
//       const submissionData = {
//         ...formData,
//         programmerId: formLink.programmerId,
//         programmerName: formLink.programmerName,
//         formLinkId: formLink.id,
//         concertId: formLink.concertId,
//         concertName: formLink.concertName,
//         concertDate: formLink.concertDate,
//         status: 'pending'
//       };
      
//       // Soumettre le formulaire
//       const result = await createFormSubmission(submissionData);
//       console.log('Form submission result:', result);
      
//       if (result) {
//         // Rediriger vers la page de confirmation
//         console.log('Redirecting to form-submitted page');
//         navigate('/form-submitted');
//       } else {
//         console.error('Form submission failed');
//         setError('Une erreur est survenue lors de la soumission du formulaire.');
//         setLoading(false);
//       }
//     } catch (err) {
//       console.error('Error submitting form:', err);
//       setError('Une erreur est survenue lors de la soumission du formulaire.');
//       setLoading(false);
//     }
//   };
  
//   if (loading) {
//     return (
//       <div className="public-form-container">
//         <div className="public-form-card">
//           <h2>Chargement...</h2>
//           <p>Veuillez patienter pendant le chargement du formulaire.</p>
//         </div>
//       </div>
//     );
//   }
  
//   if (error) {
//     return (
//       <div className="public-form-container">
//         <div className="public-form-card error">
//           <h2>Erreur</h2>
//           <p>{error}</p>
//           <button 
//             className="form-button"
//             onClick={() => window.location.href = window.location.origin}
//           >
//             Retour à l'accueil
//           </button>
//         </div>
//       </div>
//     );
//   }
  
//   return (
//     <div className="public-form-container">
//       <div className="public-form-card">
//         <h2>Formulaire de renseignements</h2>
//         {formLink && (
//           <>
//             <div className="form-header">
//               <p><strong>Concert :</strong> {formLink.concertName}</p>
//               {formLink.concertDate && (
//                 <p><strong>Date :</strong> {
//                   formLink.concertDate.seconds 
//                     ? new Date(formLink.concertDate.seconds * 1000).toLocaleDateString()
//                     : new Date(formLink.concertDate).toLocaleDateString()
//                 }</p>
//               )}
//             </div>
            
//             <form onSubmit={handleSubmit}>
//               <div className="form-group">
//                 <label htmlFor="businessName">Raison sociale *</label>
//                 <input
//                   type="text"
//                   id="businessName"
//                   name="businessName"
//                   value={formData.businessName}
//                   onChange={handleChange}
//                   required
//                 />
//               </div>
              
//               <div className="form-group">
//                 <label htmlFor="contact">Contact *</label>
//                 <input
//                   type="text"
//                   id="contact"
//                   name="contact"
//                   value={formData.contact}
//                   onChange={handleChange}
//                   required
//                 />
//               </div>
              
//               <div className="form-group">
//                 <label htmlFor="role">Qualité (président, programmateur, gérant...)</label>
//                 <input
//                   type="text"
//                   id="role"
//                   name="role"
//                   value={formData.role}
//                   onChange={handleChange}
//                 />
//               </div>
              
//               <div className="form-group">
//                 <label htmlFor="address">Adresse de la raison sociale</label>
//                 <textarea
//                   id="address"
//                   name="address"
//                   value={formData.address}
//                   onChange={handleChange}
//                   rows="3"
//                 />
//               </div>
              
//               <div className="form-group">
//                 <label htmlFor="venue">Lieu ou festival</label>
//                 <input
//                   type="text"
//                   id="venue"
//                   name="venue"
//                   value={formData.venue}
//                   onChange={handleChange}
//                 />
//               </div>
              
//               <div className="form-group">
//                 <label htmlFor="vatNumber">Numéro intracommunautaire</label>
//                 <input
//                   type="text"
//                   id="vatNumber"
//                   name="vatNumber"
//                   value={formData.vatNumber}
//                   onChange={handleChange}
//                 />
//               </div>
              
//               <div className="form-group">
//                 <label htmlFor="siret">SIRET</label>
//                 <input
//                   type="text"
//                   id="siret"
//                   name="siret"
//                   value={formData.siret}
//                   onChange={handleChange}
//                 />
//               </div>
              
//               <div className="form-group">
//                 <label htmlFor="email">Email *</label>
//                 <input
//                   type="email"
//                   id="email"
//                   name="email"
//                   value={formData.email}
//                   onChange={handleChange}
//                   required
//                 />
//               </div>
              
//               <div className="form-group">
//                 <label htmlFor="phone">Téléphone</label>
//                 <input
//                   type="tel"
//                   id="phone"
//                   name="phone"
//                   value={formData.phone}
//                   onChange={handleChange}
//                 />
//               </div>
              
//               <div className="form-group">
//                 <label htmlFor="website">Site web</label>
//                 <input
//                   type="url"
//                   id="website"
//                   name="website"
//                   value={formData.website}
//                   onChange={handleChange}
//                 />
//               </div>
              
//               <div className="form-footer">
//                 <p>* Champs obligatoires</p>
//                 <button 
//                   type="submit" 
//                   className="form-button"
//                   disabled={loading}
//                 >
//                   {loading ? 'Envoi en cours...' : 'Envoyer'}
//                 </button>
//               </div>
//             </form>
//           </>
//         )}
//       </div>
//     </div>
//   );
// };

// export default PublicFormPage;

//code simplifié
import React from 'react';
const PublicFormPage = () => {
  console.log("PublicFormPage loaded, token:", window.location.pathname);
  return (
    <div style={{ padding: "20px", textAlign: "center" }}>
      <h2>Public Form Page Loaded</h2>
    </div>
  );
};
export default PublicFormPage;