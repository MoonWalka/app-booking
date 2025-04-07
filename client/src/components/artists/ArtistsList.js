// client/src/components/artists/ArtistsList.js
import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { getArtists } from '../../services/artistsService';

const ArtistsList = () => {
  const [artists, setArtists] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchArtists = async () => {
      try {
        setLoading(true);
        const data = await getArtists();
        setArtists(data);
        setLoading(false);
      } catch (err) {
        setError(err.message);
        setLoading(false);
      }
    };

    fetchArtists();
  }, []);

  // Le reste du composant reste inchangé
  // ...
};

export default ArtistsList;
