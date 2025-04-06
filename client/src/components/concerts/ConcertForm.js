import React, { useState, useEffect } from 'react';
import { useTranslation } from 'react-i18next';
import { useForm, Controller } from 'react-hook-form';
import axios from 'axios';
import DatePicker, { registerLocale } from 'react-datepicker';
import { fr } from 'date-fns/locale';
import 'react-datepicker/dist/react-datepicker.css';
import { TextField, Button, MenuItem, Grid, Typography, Box } from '@material-ui/core';
import { toast } from 'react-toastify';

// Enregistrement de la locale française pour le DatePicker
registerLocale('fr', fr);

const ConcertForm = ({ concert, onSave, onCancel }) => {
  const { t } = useTranslation();
  const [artists, setArtists] = useState([]);
  const [programmers, setProgrammers] = useState([]);
  const [loading, setLoading] = useState(true);
  
  const { register, handleSubmit, control, formState: { errors }, setValue, reset } = useForm({
    defaultValues: {
      artist: concert?.artist?._id || '',
      programmer: concert?.programmer?._id || '',
      date: concert?.date ? new Date(concert.date) : null,
      venue: concert?.venue || '',
      address: concert?.address || '',
      city: concert?.city || '',
      time: concert?.time || '',
      price: concert?.price || '',
      status: concert?.status || 'prospection',
      hospitalityNeeds: concert?.hospitalityNeeds || '',
      technicalRequirements: concert?.technicalRequirements || '',
      notes: concert?.notes || ''
    }
  });

  useEffect(() => {
    const fetchFormData = async () => {
      try {
        const [artistsRes, programmersRes] = await Promise.all([
          axios.get('/api/artists'),
          axios.get('/api/programmers')
        ]);
        
        setArtists(artistsRes.data);
        setProgrammers(programmersRes.data);
        setLoading(false);
      } catch (error) {
        console.error('Erreur lors du chargement des données du formulaire', error);
        toast.error(t('Error loading form data'));
        setLoading(false);
      }
    };

    fetchFormData();
  }, [t]);

  useEffect(() => {
    if (concert) {
      reset({
        artist: concert.artist._id,
        programmer: concert.programmer._id,
        date: new Date(concert.date),
        venue: concert.venue,
        address: concert.address,
        city: concert.city,
        time: concert.time,
        price: concert.price,
        status: concert.status,
        hospitalityNeeds: concert.hospitalityNeeds,
        technicalRequirements: concert.technicalRequirements,
        notes: concert.notes
      });
    }
  }, [concert, reset]);

  const onSubmit = async (data) => {
    // Formatage du prix pour être sûr qu'il soit un nombre
    data.price = parseFloat(data.price);
    
    try {
      onSave(data);
    } catch (error) {
      console.error('Erreur lors de la soumission du formulaire', error);
      toast.error(t('Error saving concert'));
    }
  };

  const formatPrice = (value) => {
    return new Intl.NumberFormat('fr-FR', { style: 'currency', currency: 'EUR' }).format(value);
  };

  if (loading) {
    return 
Chargement...
;
  }

  const statusOptions = [
    { value: 'prospection', label: t('Prospecting') },
    { value: 'en_attente', label: t('Pending') },
    { value: 'confirme', label: t('Confirmed') },
    { value: 'contrat_envoye', label: t('Contract sent') },
    { value: 'acompte_recu', label: t('Deposit received') },
    { value: 'solde_paye', label: t('Balance paid') }
  ];

  return (
    

      
        
          
            {concert ? t('Edit Concert') : t('Add New Concert')}
          
        

        
           (
              
                {artists.map(artist => (
                  
                    {artist.name}
                  
                ))}
              
            )}
          />
        

        
           (
              
                {programmers.map(programmer => (
                  
                    {programmer.name} - {programmer.structure}
                  
                ))}
              
            )}
          />
        

        
           (
               field.onChange(date)}
                locale="fr"
                dateFormat="dd/MM/yyyy"
                placeholderText={t('Select date')}
                className={`form-control w-full p-2 border rounded ${errors.date ? 'border-red-500' : 'border-gray-300'}`}
                customInput={
                  
                }
              />
            )}
          />
        

        
           (
              
            )}
          />
        

        
           (
              
            )}
          />
        

        
           (
              
            )}
          />
        

        
           (
              
            )}
          />
        

        
           (
              €,
                }}
              />
            )}
          />
        

        
           (
              
                {statusOptions.map(option => (
                  
                    {option.label}
                  
                ))}
              
            )}
          />
        

        
           (
              
            )}
          />
        

        
           (
              
            )}
          />
        

        
           (
              
            )}
          />
        

        
          
            
              {t('Cancel')}
            
            
              {concert ? t('Update Concert') : t('Save Concert')}
            
          
        
      
    

  );
};

export default ConcertForm;
            
