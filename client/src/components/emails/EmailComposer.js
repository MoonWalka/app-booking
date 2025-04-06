import React, { useState, useEffect } from 'react';
import { useTranslation } from 'react-i18next';
import { useForm, Controller } from 'react-hook-form';
import axios from 'axios';
import { 
  TextField, Button, Grid, Typography, Box, Select,
  MenuItem, FormControl, InputLabel, FormHelperText,
  Chip, IconButton, Paper
} from '@material-ui/core';
import { Autocomplete } from '@material-ui/lab';
import { AttachFile, Close, Save } from '@material-ui/icons';
import EmailTemplateSelector from './EmailTemplateSelector';
import { toast } from 'react-toastify';

const EmailComposer = ({ initialData = {}, onSend, onCancel }) => {
  const { t } = useTranslation();
  const [programmers, setProgrammers] = useState([]);
  const [artists, setArtists] = useState([]);
  const [templates, setTemplates] = useState([]);
  const [attachments, setAttachments] = useState([]);
  const [saveAsTemplate, setSaveAsTemplate] = useState(false);
  const [templateName, setTemplateName] = useState('');
  const fileInputRef = React.createRef();
  
  const { register, handleSubmit, control, formState: { errors }, setValue, watch } = useForm({
    defaultValues: {
      sender: initialData.sender || 'contact@label-musical.fr',
      recipient: initialData.recipient || '',
      programmerId: initialData.programmerId || '',
      subject: initialData.subject || '',
      body: initialData.body || '',
    }
  });
  
  const watchBody = watch('body');
  
  useEffect(() => {
    const fetchFormData = async () => {
      try {
        const [programmersRes, artistsRes, templatesRes] = await Promise.all([
          axios.get('/api/programmers'),
          axios.get('/api/artists'),
          axios.get('/api/emails/templates')
        ]);
        
        setProgrammers(programmersRes.data);
        setArtists(artistsRes.data);
        setTemplates(templatesRes.data);
      } catch (error) {
        console.error('Erreur lors du chargement des données', error);
        toast.error(t('Error loading data'));
      }
    };

    fetchFormData();
  }, [t]);

  const handleFileChange = (event) => {
    const files = Array.from(event.target.files);
    
    if (files.length > 0) {
      const newAttachments = files.map(file => ({
        name: file.name,
        size: file.size,
        type: file.type,
        file: file
      }));
      
      setAttachments([...attachments, ...newAttachments]);
    }
    
    // Réinitialiser l'input file
    event.target.value = '';
  };
  
  const removeAttachment = (index) => {
    const newAttachments = [...attachments];
    newAttachments.splice(index, 1);
    setAttachments(newAttachments);
  };
  
  const handleTemplateSelect = (template) => {
    setValue('subject', template.subject);
    setValue('body', template.body);
  };
  
  const onSubmit = async (data) => {
    // Préparation des données pour l'envoi
    const formData = new FormData();
    
    Object.keys(data).forEach(key => {
      formData.append(key, data[key]);
    });
    
    // Ajout des pièces jointes
    attachments.forEach((attachment, index) => {
      formData.append(`attachment${index}`, attachment.file);
    });
    
    // Si on sauvegarde comme modèle
    if (saveAsTemplate && templateName) {
      formData.append('saveAsTemplate', 'true');
      formData.append('templateName', templateName);
    }
    
    try {
      onSend(formData);
    } catch (error) {
      console.error('Erreur lors de l\'envoi de l\'email', error);
      toast.error(t('Error sending email'));
    }
  };

  return (
    

      
        
          
            {t('Compose Email')}
          
        

        
           (
              
                {t('From')}
                
                {errors.sender && {errors.sender.message}}
              
            )}
          />
        

        
           (
               `${option.name} - ${option.structure}`}
                value={programmers.find(p => p._id === field.value) || null}
                onChange={(_, newValue) => {
                  field.onChange(newValue ? newValue._id : '');
                  if (newValue) {
                    setValue('recipient', newValue.email);
                  }
                }}
                renderInput={(params) => (
                  
                )}
              />
            )}
          />
        

        
           (
              
            )}
          />
        

        
           (
              
            )}
          />
        

        
          
            {t('Email Templates')}
          
          
        

        
           (
              
            )}
          />
        

        
          
            {t('Attachments')}
          
          
          }
            onClick={() => fileInputRef.current.click()}
          >
            {t('Attach files')}
          
          
          {attachments.length > 0 && (
            
              
                {attachments.map((file, index) => (
                   removeAttachment(index)}
                    className="m-1"
                  />
                ))}
              
            
          )}
        

        
          
            
              {t('Save as Template')}
            
             setSaveAsTemplate(!saveAsTemplate)}
            />
            
            {saveAsTemplate && (
               setTemplateName(e.target.value)}
                label={t('Template Name')}
                variant="outlined"
                size="small"
                className="ml-3"
              />
            )}
          
        

        
          
            
              {t('Cancel')}
            
            
              {t('Send')}
            
          
        
      
    

  );
};

export default EmailComposer;
            
