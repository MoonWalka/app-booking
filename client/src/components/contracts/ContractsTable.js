import React, { useState, useEffect, useMemo } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import './ContractsTable.css';

// Services
import { getAllContracts, updateContract, deleteContract } from '../../services/contractsService';

const ContractsTable = () => {
  const [contracts, setContracts] = useState([]);
  const [loading, setLoading] = useState(true);
  const navigate = useNavigate();

  // Récupération des données
  useEffect(() => {
    const loadContracts = async () => {
      try {
        setLoading(true);
        // Utiliser le service pour récupérer les contrats depuis Firebase
        const contractsData = await getAllContracts();
        setContracts(contractsData);
        setLoading(false);
      } catch (error) {
        console.error('Erreur lors du chargement des contrats:', error);
        setLoading(false);
      }
    };

    loadContracts();
  }, []);

  // Formatage de la date
  const formatDate = (dateString) => {
    if (!dateString) return '-';
    const date = new Date(dateString);
    return date.toLocaleDateString('fr-FR');
  };

  // Formatage du montant
  const formatAmount = (amount) => {
    if (!amount && amount !== 0) return '-';
    return new Intl.NumberFormat('fr-FR', { style: 'currency', currency: 'EUR' }).format(amount);
  };

  // Gestion du changement de statut
  const handleStatusChange = async (contractId, field, newStatus) => {
    try {
      // Trouver le contrat à mettre à jour
      const contractToUpdate = contracts.find(c => c.id === contractId);
      if (!contractToUpdate) return;

      // Créer une copie du contrat avec le statut mis à jour
      const updatedContract = { ...contractToUpdate };
      
      // Mettre à jour le statut selon le champ
      switch (field) {
        case 'formStatus':
          updatedContract.formStatus = newStatus;
          break;
        case 'contractSentStatus':
          updatedContract.contractSentStatus = newStatus;
          break;
        case 'contractSignedStatus':
          updatedContract.contractSignedStatus = newStatus;
          break;
        case 'invoiceStatus':
          updatedContract.invoiceStatus = newStatus;
          break;
        default:
          break;
      }

      // Mettre à jour le contrat dans Firebase
      await updateContract(contractId, updatedContract);

      // Mettre à jour l'état local
      setContracts(prevContracts => 
        prevContracts.map(c => c.id === contractId ? updatedContract : c)
      );
    } catch (error) {
      console.error('Erreur lors de la mise à jour du statut:', error);
    }
  };

  // Fonction pour visualiser le concert associé
  const viewConcert = (concertId) => {
    if (concertId) {
      navigate(`/concerts/${concertId}`);
    } else {
      alert('Aucun concert associé à ce contrat');
    }
  };

  // Fonction pour supprimer un contrat
  const handleDeleteContract = async (contractId) => {
    if (window.confirm('Êtes-vous sûr de vouloir supprimer ce contrat ?')) {
      try {
        await deleteContract(contractId);
        // Mettre à jour l'état local en supprimant le contrat
        setContracts(prevContracts => prevContracts.filter(c => c.id !== contractId));
      } catch (error) {
        console.error('Erreur lors de la suppression du contrat:', error);
        alert('Erreur lors de la suppression du contrat');
      }
    }
  };

  // Rendu des icônes de statut
  const renderStatusIcon = (status, contractId, field) => {
    let icon, color, title;

    switch (status) {
      case 'validated':
        icon = 'fas fa-check-circle';
        color = '#28a745';
        title = 'Validé';
        break;
      case 'pending':
        icon = 'fas fa-clock';
        color = '#ffc107';
        title = 'À faire';
        break;
      case 'cancelled':
        icon = 'fas fa-times-circle';
        color = '#dc3545';
        title = 'Annulé';
        break;
      default:
        icon = 'fas fa-question-circle';
        color = '#6c757d';
        title = 'Non défini';
        break;
    }

    // Déterminer le prochain statut lors du clic
    const getNextStatus = (currentStatus) => {
      switch (currentStatus) {
        case 'validated': return 'pending';
        case 'pending': return 'cancelled';
        case 'cancelled': return 'validated';
        default: return 'validated';
      }
    };

    return (
      <span 
        className="status-icon" 
        style={{ color }}
        title={title}
        onClick={(e) => {
          e.stopPropagation();
          handleStatusChange(contractId, field, getNextStatus(status));
        }}
      >
        <i className={icon}></i>
      </span>
    );
  };

  if (loading) {
    return <div className="loading-container">Chargement des contrats...</div>;
  }

  return (
    <div className="contracts-dashboard">
      <div className="contracts-header">
        <h1>Gestion des Contrats</h1>
        <div className="header-actions">
          <Link to="/concerts/new" className="add-button">
            <i className="fas fa-plus"></i> Nouveau concert
          </Link>
        </div>
      </div>
      
      <div className="table-responsive">
        <table className="contracts-table">
          <thead>
            <tr>
              <th className="col-artist">Artiste</th>
              <th className="col-project">Projet</th>
              <th className="col-venue">Lieu (concert)</th>
              <th className="col-option-date">Prise d'option</th>
              <th className="col-start-date">Début</th>
              <th className="col-amount">Montant (€)</th>
              <th className="col-status">Formulaire</th>
              <th className="col-status">Contrat envoyé</th>
              <th className="col-status">Contrat signé</th>
              <th className="col-status">Facture émise</th>
              <th className="col-actions">Actions</th>
            </tr>
          </thead>
          <tbody>
            {contracts.length === 0 ? (
              <tr>
                <td colSpan="11" className="no-data">Aucun contrat trouvé</td>
              </tr>
            ) : (
              contracts.map(contract => (
                <tr key={contract.id}>
                  <td className="col-artist">{contract.artist?.name || '-'}</td>
                  <td className="col-project">{contract.project || '-'}</td>
                  <td className="col-venue">{contract.venue || '-'}</td>
                  <td className="col-option-date">{formatDate(contract.optionDate)}</td>
                  <td className="col-start-date">{formatDate(contract.date)}</td>
                  <td className="col-amount">{formatAmount(contract.amount)}</td>
                  <td className="col-status status-cell">
                    {renderStatusIcon(contract.formStatus || 'pending', contract.id, 'formStatus')}
                  </td>
                  <td className="col-status status-cell">
                    {renderStatusIcon(contract.contractSentStatus || 'pending', contract.id, 'contractSentStatus')}
                  </td>
                  <td className="col-status status-cell">
                    {renderStatusIcon(contract.contractSignedStatus || 'pending', contract.id, 'contractSignedStatus')}
                  </td>
                  <td className="col-status status-cell">
                    {renderStatusIcon(contract.invoiceStatus || 'pending', contract.id, 'invoiceStatus')}
                  </td>
                  <td className="col-actions actions-cell">
                    <button 
                      className="action-btn view-btn" 
                      title="Voir le concert" 
                      onClick={(e) => { 
                        e.stopPropagation(); 
                        viewConcert(contract.concertId);
                      }}
                    >
                      <i className="fas fa-eye"></i>
                    </button>
                    <button 
                      className="action-btn delete-btn" 
                      title="Supprimer" 
                      onClick={(e) => { 
                        e.stopPropagation(); 
                        handleDeleteContract(contract.id);
                      }}
                    >
                      <i className="fas fa-trash"></i>
                    </button>
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default ContractsTable;
