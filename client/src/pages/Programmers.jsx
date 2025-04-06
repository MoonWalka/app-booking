// client/src/pages/Programmers.jsx

import React, { useState, useEffect } from 'react';
import { 
  Container, 
  Typography, 
  Button, 
  Paper, 
  Table, 
  TableBody, 
  TableCell, 
  TableContainer, 
  TableHead, 
  TableRow,
  TextField,
  Box,
  Chip,
  IconButton,
  Tooltip
} from '@material-ui/core';
import { Add, Edit, Delete, Place, FilterList, Clear } from '@material-ui/icons';
import ProgrammerForm from '../components/programmers/ProgrammerForm';
import ProgrammersMap from '../components/programmers/ProgrammersMap';
import FilterDialog from '../components/programmers/FilterDialog';
import DeleteConfirmDialog from '../components/common/DeleteConfirmDialog';
import { useProgrammers } from '../hooks/useProgrammers';
import { useTranslation } from 'react-i18next';

const Programmers = () => {
  const { t } = useTranslation();
  const { 
    programmers, 
    loading, 
    error, 
    fetchProgrammers, 
    addProgrammer, 
    updateProgrammer, 
    deleteProgrammer 
  } = useProgrammers();
  
  const [formOpen, setFormOpen] = useState(false);
  const [mapDialogOpen, setMapDialogOpen] = useState(false);
  const [filterDialogOpen, setFilterDialogOpen] = useState(false);
  const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
  const [currentProgrammer, setCurrentProgrammer] = useState(null);
  const [searchTerm, setSearchTerm] = useState('');
  const [filters, setFilters] = useState({
    region: '',
    city: '',
    musicStyle: ''
  });
  const [mapFilters, setMapFilters] = useState({
    center: null,
    radius: 0
  });
  
  useEffect(() => {
    fetchProgrammers();
  }, [fetchProgrammers]);
  
  const handleOpenForm = (programmer = null) => {
    setCurrentProgrammer(programmer);
    setFormOpen(true);
  };
  
  const handleCloseForm = () => {
    setFormOpen(false);
    setCurrentProgrammer(null);
  };
  
  const handleOpenMapDialog = () => {
    setMapDialogOpen(true);
  };
  
  const handleCloseMapDialog = () => {
    setMapDialogOpen(false);
  };
  
  const handleOpenFilterDialog = () => {
    setFilterDialogOpen(true);
  };
  
  const handleCloseFilterDialog = () => {
    setFilterDialogOpen(false);
  };
  
  const handleOpenDeleteDialog = (programmer) => {
    setCurrentProgrammer(programmer);
    setDeleteDialogOpen(true);
  };
  
  const handleCloseDeleteDialog = () => {
    setDeleteDialogOpen(false);
    setCurrentProgrammer(null);
  };
  
  const handleSaveProgrammer = async (programmerData) => {
    try {
      if (currentProgrammer) {
        await updateProgrammer(currentProgrammer._id, programmerData);
      } else {
        await addProgrammer(programmerData);
      }
      handleCloseForm();
    } catch (err) {
      console.error('Erreur lors de l\'enregistrement du programmateur:', err);
      // Gérer l'erreur (afficher un message d'erreur, etc.)
    }
  };
  
  const handleDeleteProgrammer = async () => {
    try {
      await deleteProgrammer(currentProgrammer._id);
      handleCloseDeleteDialog();
    } catch (err) {
      console.error('Erreur lors de la suppression du programmateur:', err);
      // Gérer l'erreur
    }
  };
  
  const handleSearchChange = (event) => {
    setSearchTerm(event.target.value);
  };
  
  const handleApplyFilters = (newFilters) => {
    setFilters(newFilters);
    handleCloseFilterDialog();
  };
  
  const handleMapSearch = (center, radius) => {
    setMapFilters({ center, radius });
  };
  
  const handleClearFilters = () => {
    setFilters({
      region: '',
      city: '',
      musicStyle: ''
    });
    setMapFilters({
      center: null,
      radius: 0
    });
    setSearchTerm('');
  };
  
  // Filtrage des programmateurs
  const filteredProgrammers = programmers.filter(programmer => {
    // Recherche textuelle
    const matchesSearch = 
      searchTerm === '' || 
      programmer.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      programmer.structure.toLowerCase().includes(searchTerm.toLowerCase()) ||
      programmer.email.toLowerCase().includes(searchTerm.toLowerCase());
    
    // Filtres standard
    const matchesRegion = filters.region === '' || programmer.region === filters.region;
    const matchesCity = filters.city === '' || programmer.city === filters.city;
    const matchesMusicStyle = filters.musicStyle === '' || 
      (programmer.musicStyle && programmer.musicStyle.includes(filters.musicStyle));
    
    // Filtre géographique
    let matchesGeo = true;
    if (mapFilters.center && mapFilters.radius > 0 && programmer.coordinates) {
      // Calcul de la distance entre le point central et les coordonnées du programmateur
      const distance = calculateDistance(
        mapFilters.center.lat, 
        mapFilters.center.lng, 
        programmer.coordinates.lat, 
        programmer.coordinates.lng
      );
      matchesGeo = distance <= mapFilters.radius;
    }
    
    return matchesSearch && matchesRegion && matchesCity && matchesMusicStyle && matchesGeo;
  });
  
  // Fonction pour calculer la distance en kilomètres entre deux points (formule de Haversine)
  const calculateDistance = (lat1, lon1, lat2, lon2) => {
    const R = 6371; // Rayon de la Terre en km
    const dLat = (lat2 - lat1) * Math.PI / 180;
    const dLon = (lon2 - lon1) * Math.PI / 180;
    const a = 
      Math.sin(dLat/2) * Math.sin(dLat/2) +
      Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) * 
      Math.sin(dLon/2) * Math.sin(dLon/2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
    return R * c;
  };
  
  const isFiltering = 
    searchTerm !== '' || 
    filters.region !== '' || 
    filters.city !== '' || 
    filters.musicStyle !== '' ||
    (mapFilters.center && mapFilters.radius > 0);
  
  if (loading) return <Typography>Chargement...</Typography>;
  if (error) return <Typography color="error">Erreur: {error}</Typography>;
  
  return (
    <Container maxWidth="lg">
      <Box my={4}>
        <Box display="flex" justifyContent="space-between" alignItems="center" mb={3}>
          <Typography variant="h4">{t('Programmateurs')}</Typography>
          <Button
            variant="contained"
            color="primary"
            startIcon={<Add />}
            onClick={() => handleOpenForm()}
          >
            {t('Ajouter un Programmateur')}
          </Button>
        </Box>
        
        <Box display="flex" alignItems="center" mb={3}>
          <TextField
            variant="outlined"
            size="small"
            placeholder={t('Rechercher des programmateurs...')}
            value={searchTerm}
            onChange={handleSearchChange}
            style={{ marginRight: '16px', flexGrow: 1 }}
          />
          <Tooltip title={t('Filtre avancé')}>
            <IconButton 
              color={Object.values(filters).some(v => v !== '') ? 'primary' : 'default'} 
              onClick={handleOpenFilterDialog}
            >
              <FilterList />
            </IconButton>
          </Tooltip>
          <Tooltip title={t('Recherche sur carte')}>
            <IconButton 
              color={mapFilters.center ? 'primary' : 'default'} 
              onClick={handleOpenMapDialog}
            >
              <Place />
            </IconButton>
          </Tooltip>
          {isFiltering && (
            <Tooltip title={t('Effacer les filtres')}>
              <IconButton color="secondary" onClick={handleClearFilters}>
                <Clear />
              </IconButton>
            </Tooltip>
          )}
        </Box>
        
        {/* Affichage des filtres actifs */}
        {isFiltering && (
          <Box display="flex" flexWrap="wrap" mb={2}>
            {searchTerm && (
              <Chip 
                label={`Recherche: ${searchTerm}`} 
                onDelete={() => setSearchTerm('')}
                style={{ margin: '0 8px 8px 0' }}
              />
            )}
            {filters.region && (
              <Chip 
                label={`Région: ${filters.region}`} 
                onDelete={() => setFilters({...filters, region: ''})}
                style={{ margin: '0 8px 8px 0' }}
              />
            )}
            {filters.city && (
              <Chip 
                label={`Ville: ${filters.city}`} 
                onDelete={() => setFilters({...filters, city: ''})}
                style={{ margin: '0 8px 8px 0' }}
              />
            )}
            {filters.musicStyle && (
              <Chip 
                label={`Style: ${filters.musicStyle}`} 
                onDelete={() => setFilters({...filters, musicStyle: ''})}
                style={{ margin: '0 8px 8px 0' }}
              />
            )}
            {mapFilters.center && (
              <Chip 
                label={`Rayon: ${mapFilters.radius} km`} 
                onDelete={() => setMapFilters({center: null, radius: 0})}
                style={{ margin: '0 8px 8px 0' }}
                color="primary"
                icon={<Place />}
              />
            )}
          </Box>
        )}
        
        <TableContainer component={Paper}>
          <Table>
            <TableHead>
              <TableRow>
                <TableCell>{t('Nom')}</TableCell>
                <TableCell>{t('Structure')}</TableCell>
                <TableCell>{t('Email')}</TableCell>
                <TableCell>{t('Téléphone')}</TableCell>
                <TableCell>{t('Ville')}</TableCell>
                <TableCell>{t('Style Musical')}</TableCell>
                <TableCell align="right">{t('Actions')}</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {filteredProgrammers.length > 0 ? (
                filteredProgrammers.map((programmer) => (
                  <TableRow key={programmer._id}>
                    <TableCell>{programmer.name}</TableCell>
                    <TableCell>{programmer.structure}</TableCell>
                    <TableCell>{programmer.email}</TableCell>
                    <TableCell>{programmer.phone}</TableCell>
                    <TableCell>{programmer.city}</TableCell>
                    <TableCell>
                      {programmer.musicStyle && programmer.musicStyle.map(style => (
                        <Chip 
                          key={style} 
                          label={style} 
                          size="small" 
                          style={{ margin: '2px' }}
                        />
                      ))}
                    </TableCell>
                    <TableCell align="right">
                      <Tooltip title={t('Modifier')}>
                        <IconButton 
                          size="small" 
                          onClick={() => handleOpenForm(programmer)}
                        >
                          <Edit fontSize="small" />
                        </IconButton>
                      </Tooltip>
                      <Tooltip title={t('Supprimer')}>
                        <IconButton 
                          size="small" 
                          onClick={() => handleOpenDeleteDialog(programmer)}
                        >
                          <Delete fontSize="small" />
                        </IconButton>
                      </Tooltip>
                    </TableCell>
                  </TableRow>
                ))
              ) : (
                <TableRow>
                  <TableCell colSpan={7} align="center">
                    {isFiltering 
                      ? t('Aucun programmateur ne correspond aux critères de recherche.') 
                      : t('Aucun programmateur trouvé. Ajoutez-en un pour commencer.')}
                  </TableCell>
                </TableRow>
              )}
            </TableBody>
          </Table>
        </TableContainer>
      </Box>
      
      {/* Dialogs */}
      <ProgrammerForm 
        open={formOpen} 
        onClose={handleCloseForm} 
        onSave={handleSaveProgrammer}
        programmer={currentProgrammer}
      />
      
      <ProgrammersMap 
        open={mapDialogOpen} 
        onClose={handleCloseMapDialog}
        onSearch={handleMapSearch}
        programmers={programmers}
      />
      
      <FilterDialog 
        open={filterDialogOpen} 
        onClose={handleCloseFilterDialog}
        filters={filters}
        onApply={handleApplyFilters}
        programmers={programmers}
      />
      
      <DeleteConfirmDialog 
        open={deleteDialogOpen}
        onClose={handleCloseDeleteDialog}
        onConfirm={handleDeleteProgrammer}
        title={t('Supprimer le programmateur')}
        content={t('Êtes-vous sûr de vouloir supprimer ce programmateur ? Cette action ne peut pas être annulée.')}
      />
    </Container>
  );
};

export default Programmers;
