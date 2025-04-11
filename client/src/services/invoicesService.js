import { db } from '../firebase';
import { collection, getDocs, doc, getDoc, addDoc, updateDoc, deleteDoc } from 'firebase/firestore';

// Récupérer toutes les factures
export const getAllInvoices = async () => {
  try {
    const invoicesCollection = collection(db, 'invoices');
    const invoicesSnapshot = await getDocs(invoicesCollection);
    return invoicesSnapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));
  } catch (error) {
    console.error("Erreur lors de la récupération des factures:", error);
    return [];
  }
};

// Récupérer une facture par ID
export const getInvoiceById = async (id) => {
  try {
    const invoiceDoc = doc(db, 'invoices', id);
    const invoiceSnapshot = await getDoc(invoiceDoc);
    
    if (invoiceSnapshot.exists()) {
      return {
        id: invoiceSnapshot.id,
        ...invoiceSnapshot.data()
      };
    } else {
      console.log("Aucune facture trouvée avec cet ID");
      return null;
    }
  } catch (error) {
    console.error("Erreur lors de la récupération de la facture:", error);
    return null;
  }
};

// Créer une nouvelle facture
export const createInvoice = async (invoiceData) => {
  try {
    const invoicesCollection = collection(db, 'invoices');
    const docRef = await addDoc(invoicesCollection, {
      ...invoiceData,
      createdAt: new Date()
    });
    
    return {
      id: docRef.id,
      ...invoiceData
    };
  } catch (error) {
    console.error("Erreur lors de la création de la facture:", error);
    throw error;
  }
};

// Mettre à jour une facture
export const updateInvoice = async (id, invoiceData) => {
  try {
    const invoiceDoc = doc(db, 'invoices', id);
    await updateDoc(invoiceDoc, {
      ...invoiceData,
      updatedAt: new Date()
    });
    
    return {
      id,
      ...invoiceData
    };
  } catch (error) {
    console.error("Erreur lors de la mise à jour de la facture:", error);
    throw error;
  }
};

// Supprimer une facture
export const deleteInvoice = async (id) => {
  try {
    const invoiceDoc = doc(db, 'invoices', id);
    await deleteDoc(invoiceDoc);
    return true;
  } catch (error) {
    console.error("Erreur lors de la suppression de la facture:", error);
    return false;
  }
};
