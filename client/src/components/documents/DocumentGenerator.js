import React, { useState, useEffect } from 'react';
import { useTranslation } from 'react-i18next';
import { useForm, Controller } from 'react-hook-form';
import axios from 'axios';
import { format } from 'date-fns';
import { fr } from 'date-fns/locale';
import { 
  TextField, Button, Grid, Typography, Box, Select,
  MenuItem, FormControl, InputLabel, FormHelperText,
  Checkbox, FormControlLabel, Paper
} from '@material-ui/core';
import { Autocomplete } from '@material-ui/lab';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faFilePdf, faDownload, faEnvelope, faEye } from '@fortawesome/free-solid-svg-icons';
import { toast } from 'react-toastify';

const DocumentGenerator = ({ initialData = {}, onGenerate, onCancel }) => {
  const { t } = useTranslation();
  const [concerts, setConcerts] = useState([]);
  const [selectedConcert, setSelectedConcert] = useState(null);
  const [sendEmail, setSendEmail] = useState(false);
  const [loading, setLoading] = useState(true);
  const [previewUrl, setPreviewUrl] = useState('');
  
  const { register, handleSubmit, control, formState: { errors }, setValue, watch } = useForm({
    defaultValues: {
      concertId: initialData.concertId || '',
      documentType: initialData.documentType || 'contract',
      includeSignature: true,
      customNotes: '',
    }
  });
  
  const documentType = watch('documentType');
  
  useEffect(() => {
    const fetchConcerts = async () => {
      try {
        const response = await axios.get('/api/concerts', {
          params: { status: 'confirmed,contract_sent,deposit_received' }
        });
        setConcerts(response.data);
        setLoading(false);
        
        // Si un ID de concert est fourni dans les données initiales, sélectionner ce concert
        if (initialData.concertId) {
          const concert = response.data.find(c => c._id === initialData.concertId);
          if (concert) {
            setSelectedConcert(concert);
          }
        }
      } catch (error) {
        console.error('Erreur lors du chargement des concerts', error);
        toast.error(t('Error loading concerts'));
        setLoading(false);
      }
    };

    fetchConcerts();
  }, [initialData.concertId, t]);

  const handleConcertSelect = (concertId) => {
    const concert = concerts.find(c => c._id === concertId);
    setSelectedConcert(concert);
  };

  const formatPrice = (price) => {
    return new Intl.NumberFormat('fr-FR', { style: 'currency', currency: 'EUR' }).format(price);
  };

  const handleGeneratePreview = async () => {
    if (!selectedConcert) return;
    
    try {
      const response = await axios.post(
        '/api/documents/preview',
        {
          concertId: selectedConcert._id,
          documentType,
          includeSignature: watch('includeSignature'),
          customNotes: watch('customNotes')
        },
        { responseType: 'blob' }
      );
      
      const url = URL.createObjectURL(response.data);
      setPreviewUrl(url);
    } catch (error) {
      console.error('Erreur lors de la génération de l\'aperçu', error);
      toast.error(t('Error generating preview'));
    }
  };
  
  const onSubmit = async (data) => {
    if (!selectedConcert) {
      toast.error(t('Please select a concert'));
      return;
    }
    
    try {
      const documentData = {
        ...data,
        sendEmail,
        concertId: selectedConcert._id
      };
      
      onGenerate(documentData);
    } catch (error) {
      console.error('Erreur lors de la génération du document', error);
      toast.error(t('Error generating document'));
    }
  };

  if (loading) {
    return 
Chargement...
;
  }

  return (
    

      
        
          
            {t('Generate Document')}
          
        

        
           (
              
                {t('Document Type')}
                
                {errors.documentType && {errors.documentType.message}}
              
            )}
          />
        

        
           (
               {
                  const artist = option.artist?.name || '';
                  const venue = option.venue || '';
                  const date = option.date ? format(new Date(option.date), 'dd/MM/yyyy', { locale: fr }) : '';
                  return `${artist} @ ${venue} (${date})`;
                }}
                value={selectedConcert}
                onChange={(_, newValue) => {
                  field.onChange(newValue ? newValue._id : '');
                  handleConcertSelect(newValue ? newValue._id : null);
                }}
                renderInput={(params) => (
                  
                )}
              />
            )}
          />
        

        {selectedConcert && (
          
            
              
                {t('Concert Details')}
              
              
                
                  
                    {t('Artist')}: {selectedConcert.artist?.name}
                  
                  
                    {t('Venue')}: {selectedConcert.venue}
                  
                  
                    {t('Date')}: {format(new Date(selectedConcert.date), 'dd/MM/yyyy', { locale: fr })}
                  
                  
                    {t('Time')}: {selectedConcert.time}
                  
                
                
                  
                    {t('Programmer')}: {selectedConcert.programmer?.name}
                  
                  
                    {t('Price')}: {formatPrice(selectedConcert.price)}
                  
                  
                    {t('Status')}: {t(selectedConcert.status.charAt(0).toUpperCase() + selectedConcert.status.slice(1).replace('_', ' '))}
                  
                
              
            
          
        )}

        
           (
              
                }
                label={t('Include digital signature')}
              />
            )}
          />
        

        
           (
              
            )}
          />
        

        
           setSendEmail(e.target.checked)}
                color="primary"
              />
            }
            label={t('Send document via email automatically')}
          />
          {sendEmail && (
            
              {t('The document will be sent from contrats@label-musical.fr to {{email}}', 
                { email: selectedConcert?.programmer?.email || '' })}
            
          )}
        

        {selectedConcert && (
          
            
              }
              >
                {t('Preview')}
              
              
              {previewUrl && (
                }
                >
                  {t('Download Preview')}
                
              )}
            
            
            {previewUrl && (
              
                
              
            )}
          
        )}

        
          
            
              {t('Cancel')}
            
            }
              disabled={!selectedConcert}
            >
              {documentType === 'contract' ? t('Generate Contract') : t('Generate Invoice')}
            
          
        
      
    

  );
};

export default DocumentGenerator;
