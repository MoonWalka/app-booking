// client/src/components/programmers/ProgrammersMap.jsx

import React, { useState, useEffect } from 'react';
import { 
  Dialog, 
  DialogTitle, 
  DialogContent, 
  DialogActions,
  Button, 
  Typography, 
  Slider, 
  Box,
  TextField,
  IconButton
} from '@material-ui/core';
import { Close } from '@material-ui/icons';
import { MapContainer, TileLayer, Circle, Marker, Popup } from 'react-leaflet';
import 'leaflet/dist/leaflet.css';
import axios from 'axios';
import L from 'leaflet';

// Correction des icônes Leaflet
delete L.Icon.Default.prototype._getIconUrl;
L.Icon.Default.mergeOptions({
  iconRetinaUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-icon-2x.png',
  iconUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-icon.png',
  shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-shadow.png',
});

const mapContainerStyle = {
  width: '100%',
  height: '400px',
};

const center = {
  lat: 46.603354, // Centre de la France
  lng: 1.888334,
};

const ProgrammersMap = ({ open, onClose, onSearch, programmers }) => {
  const [radius, setRadius] = useState(50);
  const [location, setLocation] = useState('');
  const [searchCoords, setSearchCoords] = useState(null);
  const [mapCenter, setMapCenter] = useState(center);
  const [confirmDialogOpen, setConfirmDialogOpen] = useState(false);
  const [selectedLocation, setSelectedLocation] = useState(null);
  
  const handleRadiusChange = (event, newValue) => {
    setRadius(newValue);
  };

  const handleLocationChange = (event) => {
    setLocation(event.target.value);
  };

  const searchLocation = async () => {
    if (!location) return;
    
    try {
      const response = await axios.get(
        `https://nominatim.openstreetmap.org/search?format=json&q=${encodeURIComponent(location)}&limit=1`
      );
      
      if (response.data && response.data.length > 0) {
        const { lat, lon } = response.data[0];
        const coords = { lat: parseFloat(lat), lng: parseFloat(lon) };
        setSearchCoords(coords);
        setMapCenter(coords);
        setSelectedLocation(response.data[0].display_name);
      } else {
        alert('Lieu non trouvé. Veuillez essayer avec une description plus précise.');
      }
    } catch (error) {
      console.error('Erreur lors de la recherche du lieu:', error);
      alert('Erreur lors de la recherche du lieu. Veuillez réessayer.');
    }
  };

  const handleApplySearch = () => {
    if (searchCoords) {
      onSearch(searchCoords, radius);
      onClose();
    } else {
      alert('Veuillez d\'abord rechercher un lieu');
    }
  };

  const handleResetSearch = () => {
    setConfirmDialogOpen(true);
  };

  const confirmReset = () => {
    onSearch(null, 0);
    setSearchCoords(null);
    setRadius(50);
    setLocation('');
    setConfirmDialogOpen(false);
    onClose();
  };

  const cancelReset = () => {
    setConfirmDialogOpen(false);
  };
  
  return (
    <>
      <Dialog 
        open={open} 
        onClose={onClose}
        maxWidth="md"
        fullWidth
      >
        <DialogTitle>
          <Box display="flex" justifyContent="space-between" alignItems="center">
            <Typography variant="h6">Recherche sur Carte</Typography>
            <IconButton onClick={onClose} size="small">
              <Close />
            </IconButton>
          </Box>
        </DialogTitle>
        <DialogContent>
          <Box mb={2} display="flex" alignItems="center">
            <TextField
              label="Rechercher un lieu"
              variant="outlined"
              fullWidth
              value={location}
              onChange={handleLocationChange}
              margin="dense"
            />
            <Button 
              variant="contained" 
              color="primary" 
              onClick={searchLocation}
              style={{ marginLeft: '8px', height: '40px' }}
            >
              Rechercher
            </Button>
          </Box>
          
          <Box mb={2}>
            <Typography gutterBottom>
              Rayon de recherche: {radius} km
            </Typography>
            <Slider
              value={radius}
              onChange={handleRadiusChange}
              min={10}
              max={200}
              step={5}
              valueLabelDisplay="auto"
              aria-labelledby="radius-slider"
            />
          </Box>
          
          <MapContainer 
            center={mapCenter} 
            zoom={6} 
            style={mapContainerStyle}
            whenCreated={(mapInstance) => {
              if (searchCoords) {
                mapInstance.setView([searchCoords.lat, searchCoords.lng], 9);
              }
            }}
          >
            <TileLayer
              url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
              attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
            />
            
            {searchCoords && (
              <>
                <Marker position={[searchCoords.lat, searchCoords.lng]}>
                  <Popup>
                    Centre de recherche: {selectedLocation}
                  </Popup>
                </Marker>
                <Circle 
                  center={[searchCoords.lat, searchCoords.lng]}
                  radius={radius * 1000}
                  pathOptions={{ color: 'blue', fillColor: 'blue', fillOpacity: 0.1 }}
                />
              </>
            )}
            
            {programmers && programmers.map(programmer => (
              programmer.coordinates && (
                <Marker 
                  key={programmer._id}
                  position={[programmer.coordinates.lat, programmer.coordinates.lng]}
                >
                  <Popup>
                    <Typography variant="subtitle1">{programmer.name}</Typography>
                    <Typography variant="body2">{programmer.structure}</Typography>
                    <Typography variant="body2">{programmer.city}</Typography>
                  </Popup>
                </Marker>
              )
            ))}
          </MapContainer>
        </DialogContent>
        <DialogActions>
          <Button onClick={handleResetSearch} color="secondary">
            Réinitialiser
          </Button>
          <Button onClick={handleApplySearch} color="primary" variant="contained">
            Appliquer
          </Button>
        </DialogActions>
      </Dialog>

      {/* Dialogue de confirmation pour la réinitialisation */}
      <Dialog open={confirmDialogOpen} onClose={cancelReset}>
        <DialogTitle>Confirmer la réinitialisation</DialogTitle>
        <DialogContent>
          <Typography>
            Êtes-vous sûr de vouloir réinitialiser la recherche? Cette action ne peut pas être annulée.
          </Typography>
        </DialogContent>
        <DialogActions>
          <Button onClick={cancelReset} color="primary">
            Annuler
          </Button>
          <Button onClick={confirmReset} color="secondary">
            Réinitialiser
          </Button>
        </DialogActions>
      </Dialog>
    </>
  );
};

export default ProgrammersMap;
