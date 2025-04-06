// client/src/components/programmers/ProgrammerForm.jsx

import React, { useState, useEffect } from 'react';
import {
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Button,
  TextField,
  Grid,
  Box,
  Typography,
  IconButton,
  Chip,
  InputAdornment
} from '@material-ui/core';
import { Close, Add } from '@material-ui/icons';
import { useTranslation } from 'react-i18next';
import axios from 'axios';

const ProgrammerForm = ({ open, onClose, onSave, programmer }) => {
  const { t } = useTranslation();
  const [formData, setFormData] = useState({
    name: '',
    structure: '',
    email: '',
    phone: '',
    city: '',
    region: '',
    musicStyle: [],
    notes: ''
  });
  const [newStyle, setNewStyle] = useState('');
  const [errors, setErrors] = useState({});
  
  useEffect(() => {
    if (programmer) {
      setFormData({
        name: programmer.name || '',
        structure: programmer.structure || '',
        email: programmer.email || '',
        phone: programmer.phone || '',
        city: programmer.city || '',
        region: programmer.region || '',
        musicStyle: programmer.musicStyle || [],
        notes: programmer.notes || ''
      });
    } else {
      setFormData({
        name: '',
        structure: '',
        email: '',
        phone: '',
        city: '',
        region: '',
        musicStyle: [],
        notes: ''
      });
    }
    setErrors({});
  }, [programmer, open]);
  
  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
    
    // Clear error when field is edited
    if (errors[name]) {
      setErrors(prev => ({
        ...prev,
        [name]: ''
      }));
    }
  };
  
  const handleAddStyle = () => {
    if (newStyle.trim() && !formData.musicStyle.includes(newStyle.trim())) {
      setFormData(prev => ({
        ...prev,
        musicStyle: [...prev.musicStyle, newStyle.trim()]
      }));
      setNewStyle('');
    }
  };
  
  const handleDeleteStyle = (styleToDelete) => {
    setFormData(prev => ({
      ...prev,
      musicStyle: prev.musicStyle.filter(style => style !== styleToDelete)
    }));
  };
  
  const handleKeyPress = (e) => {
    if (e.key === 'Enter') {
      e.preventDefault();
      handleAddStyle();
    }
  };
  
  const validateForm = () => {
    const newErrors = {};
    
    if (!formData.name.trim()) {
      newErrors.name = t('Le nom est requis');
    }
    
    if (!formData.email.trim()) {
      newErrors.email = t('L\'email est requis');
    } else if (!/\S+@\S+\.\S+/.test(formData.email)) {
      newErrors.email = t('Format d\'email invalide');
    }
    
    if (!formData.city.trim()) {
      newErrors.city = t('La ville est requise');
    }
    
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };
  
  const handleSubmit = async () => {
    if (!validateForm()) return;
    
    // Geocode the city
    try {
      const response = await axios.get(
        `https://nominatim.openstreetmap.org/search?format=json&q=${encodeURIComponent(formData.city)},${encodeURIComponent(formData.region || '')}&limit=1`
      );
      
      let coordinates = null;
      if (response.data && response.data.length > 0) {
        const { lat, lon } = response.data[0];
        coordinates = { lat: parseFloat(lat), lng: parseFloat(lon) };
      }
      
      // Call onSave with form data and coordinates
      onSave({
        ...formData,
        coordinates
      });
    } catch (error) {
      console.error('Erreur lors du géocodage de la ville:', error);
      // Even if geocoding fails, save the programmer without coordinates
      onSave(formData);
    }
  };
  
  return (
    <Dialog 
      open={open} 
      onClose={onClose}
      maxWidth="md"
      fullWidth
    >
      <DialogTitle>
        <Box display="flex" justifyContent="space-between" alignItems="center">
          <Typography variant="h6">
            {programmer ? t('Modifier le programmateur') : t('Ajouter un programmateur')}
          </Typography>
          <IconButton onClick={onClose} size="small">
            <Close />
          </IconButton>
        </Box>
      </DialogTitle>
      <DialogContent>
        <Grid container spacing={2}>
          <Grid item xs={12} sm={6}>
            <TextField
              name="name"
              label={t('Nom')}
              value={formData.name}
              onChange={handleChange}
              fullWidth
              margin="normal"
              variant="outlined"
              error={!!errors.name}
              helperText={errors.name}
              required
            />
          </Grid>
          <Grid item xs={12} sm={6}>
            <TextField
              name="structure"
              label={t('Structure')}
              value={formData.structure}
              onChange={handleChange}
              fullWidth
              margin="normal"
              variant="outlined"
            />
          </Grid>
          <Grid item xs={12} sm={6}>
            <TextField
              name="email"
              label={t('Email')}
              value={formData.email}
              onChange={handleChange}
              fullWidth
              margin="normal"
              variant="outlined"
              error={!!errors.email}
              helperText={errors.email}
              required
            />
          </Grid>
          <Grid item xs={12} sm={6}>
            <TextField
              name="phone"
              label={t('Téléphone')}
              value={formData.phone}
              onChange={handleChange}
              fullWidth
              margin="normal"
              variant="outlined"
            />
          </Grid>
          <Grid item xs={12} sm={6}>
            <TextField
              name="city"
              label={t('Ville')}
              value={formData.city}
              onChange={handleChange}
              fullWidth
              margin="normal"
              variant="outlined"
              error={!!errors.city}
              helperText={errors.city}
              required
            />
          </Grid>
          <Grid item xs={12} sm={6}>
            <TextField
              name="region"
              label={t('Région')}
              value={formData.region}
              onChange={handleChange}
              fullWidth
              margin="normal"
              variant="outlined"
            />
          </Grid>
          <Grid item xs={12}>
            <Box mb={1}>
              <Typography variant="subtitle2">{t('Styles Musicaux')}</Typography>
            </Box>
            <Box display="flex" alignItems="center">
              <TextField
                value={newStyle}
                onChange={(e) => setNewStyle(e.target.value)}
                onKeyPress={handleKeyPress}
                placeholder={t('Ajouter un style musical')}
                fullWidth
                margin="normal"
                variant="outlined"
                InputProps={{
                  endAdornment: (
                    <InputAdornment position="end">
                      <IconButton onClick={handleAddStyle} edge="end">
                        <Add />
                      </IconButton>
                    </InputAdornment>
                  ),
                }}
              />
            </Box>
            <Box display="flex" flexWrap="wrap" mt={1}>
              {formData.musicStyle.map((style) => (
                <Chip
                  key={style}
                  label={style}
                  onDelete={() => handleDeleteStyle(style)}
                  style={{ margin: '0 8px 8px 0' }}
                />
              ))}
            </Box>
          </Grid>
          <Grid item xs={12}>
            <TextField
              name="notes"
              label={t('Notes')}
              value={formData.notes}
              onChange={handleChange}
              fullWidth
              margin="normal"
              variant="outlined"
              multiline
              rows={4}
            />
          </Grid>
        </Grid>
      </DialogContent>
      <DialogActions>
        <Button onClick={onClose} color="primary">
          {t('Annuler')}
        </Button>
        <Button onClick={handleSubmit} color="primary" variant="contained">
          {t('Enregistrer')}
        </Button>
      </DialogActions>
    </Dialog>
  );
};

export default ProgrammerForm;
