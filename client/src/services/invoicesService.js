import { db } from '../firebase';
import { collection, getDocs, getDoc, doc, addDoc, updateDoc, deleteDoc } from 'firebase/firestore';

const COLLECTION_NAME = 'invoices';

// Récupérer toutes les factures
export const getInvoices = async () => {
  try {
    console.log('InvoicesService - Récupération de toutes les factures...');
    const invoicesCollection = collection(db, COLLECTION_NAME);
    const invoicesSnapshot = await getDocs(invoicesCollection);
    
    const invoices = invoicesSnapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));
    
    console.log(`InvoicesService - ${invoices.length} factures récupérées`);
    return invoices;
  } catch (error) {
    console.error('InvoicesService - Erreur lors de la récupération des factures:', error);
    throw new Error('Erreur lors de la récupération des factures');
  }
};

// Récupérer une facture par ID
export const getInvoiceById = async (id) => {
  try {
    console.log(`InvoicesService - Récupération de la facture ${id}...`);
    const invoiceDoc = doc(db, COLLECTION_NAME, id);
    const invoiceSnapshot = await getDoc(invoiceDoc);
    
    if (!invoiceSnapshot.exists()) {
      console.error(`InvoicesService - Facture ${id} non trouvée`);
      throw new Error('Facture non trouvée');
    }
    
    const invoice = {
      id: invoiceSnapshot.id,
      ...invoiceSnapshot.data()
    };
    
    console.log(`InvoicesService - Facture ${id} récupérée`);
    return invoice;
  } catch (error) {
    console.error(`InvoicesService - Erreur lors de la récupération de la facture ${id}:`, error);
    throw new Error('Erreur lors de la récupération de la facture');
  }
};

// Ajouter une nouvelle facture
export const addInvoice = async (invoiceData) => {
  try {
    console.log('InvoicesService - Ajout d\'une nouvelle facture:', invoiceData);
    const invoicesCollection = collection(db, COLLECTION_NAME);
    const docRef = await addDoc(invoicesCollection, invoiceData);
    
    const newInvoice = {
      id: docRef.id,
      ...invoiceData
    };
    
    console.log('InvoicesService - Nouvelle facture ajoutée:', newInvoice);
    return newInvoice;
  } catch (error) {
    console.error('InvoicesService - Erreur lors de l\'ajout de la facture:', error);
    throw new Error('Erreur lors de l\'ajout de la facture');
  }
};

// Mettre à jour une facture
export const updateInvoice = async (id, invoiceData) => {
  try {
    console.log(`InvoicesService - Mise à jour de la facture ${id}:`, invoiceData);
    const invoiceDoc = doc(db, COLLECTION_NAME, id);
    
    await updateDoc(invoiceDoc, invoiceData);
    
    const updatedInvoice = {
      id,
      ...invoiceData
    };
    
    console.log(`InvoicesService - Facture ${id} mise à jour`);
    return updatedInvoice;
  } catch (error) {
    console.error(`InvoicesService - Erreur lors de la mise à jour de la facture ${id}:`, error);
    throw new Error('Erreur lors de la mise à jour de la facture');
  }
};

// Supprimer une facture
export const deleteInvoice = async (id) => {
  try {
    console.log(`InvoicesService - Suppression de la facture ${id}...`);
    const invoiceDoc = doc(db, COLLECTION_NAME, id);
    
    await deleteDoc(invoiceDoc);
    
    console.log(`InvoicesService - Facture ${id} supprimée`);
    return { id };
  } catch (error) {
    console.error(`InvoicesService - Erreur lors de la suppression de la facture ${id}:`, error);
    throw new Error('Erreur lors de la suppression de la facture');
  }
};
