import React, { useState, useCallback, useRef } from 'react';
import { useTranslation } from 'react-i18next';
import { GoogleMap, useLoadScript, Marker, Circle } from '@react-google-maps/api';
import { TextField, Button, Typography, Slider, Box } from '@material-ui/core';
import { Autocomplete } from '@material-ui/lab';
import axios from 'axios';

const libraries = ['places'];
const mapContainerStyle = {
  width: '100%',
  height: '400px',
};
const center = {
  lat: 46.603354, // Centre de la France
  lng: 1.888334,
};

const MapSearch = ({ onSearch }) => {
  const { t } = useTranslation();
  const [radius, setRadius] = useState(50);
  const [searchLocation, setSearchLocation] = useState('');
  const [selectedLocation, setSelectedLocation] = useState(null);
  const [searchResults, setSearchResults] = useState([]);
  const [mapCenter, setMapCenter] = useState(center);
  const mapRef = useRef();

  const { isLoaded, loadError } = useLoadScript({
    googleMapsApiKey: process.env.REACT_APP_GOOGLE_MAPS_API_KEY,
    libraries,
  });

  const onMapLoad = useCallback((map) => {
    mapRef.current = map;
  }, []);

  const handleAddressSearch = async () => {
    try {
      const geocoder = new window.google.maps.Geocoder();
      geocoder.geocode({ address: searchLocation }, (results, status) => {
        if (status === 'OK' && results[0]) {
          const { lat, lng } = results[0].geometry.location;
          const newCenter = { lat: lat(), lng: lng() };
          setMapCenter(newCenter);
          setSelectedLocation(newCenter);
        }
      });
    } catch (error) {
      console.error('Erreur lors de la recherche d\'adresse', error);
    }
  };

  const handleRadiusChange = (_, newValue) => {
    setRadius(newValue);
  };

  const handleSearch = async () => {
    if (!selectedLocation) return;
    
    try {
      const response = await axios.get('/api/programmers/search/map', {
        params: {
          lat: selectedLocation.lat,
          lng: selectedLocation.lng,
          radius: radius
        }
      });
      
      setSearchResults(response.data);
      if (onSearch) {
        onSearch(response.data);
      }
    } catch (error) {
      console.error('Erreur lors de la recherche sur la carte', error);
    }
  };

  if (loadError) {
    return 
Erreur de chargement de Google Maps
;
  }

  if (!isLoaded) {
    return 
Chargement de la carte...
;
  }

  return (
    

      
        {t('Search for programmers within a specific radius')}
      
      
      

         setSearchLocation(e.target.value)}
          variant="outlined"
          size="small"
          fullWidth
          className="mr-2"
          placeholder={t('Enter city or address')}
        />
        
          {t('Search')}
        
      

      
      
        
          {t('Search radius')}: {radius} km
        
        
      

       {
          setSelectedLocation({
            lat: e.latLng.lat(),
            lng: e.latLng.lng()
          });
        }}
      >
        {selectedLocation && (
          <>
            
            
          
        )}
      
      
      
        
          {searchResults.length > 0 
            ? t('{{count}} programmers found', { count: searchResults.length })
            : selectedLocation 
              ? t('Click "Search" to find programmers')
              : t('Select a location on the map')
          }
        
        
          {t('Search')}
        
      
    

  );
};

export default MapSearch;
