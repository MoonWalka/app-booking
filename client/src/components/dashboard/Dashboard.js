import React, { useState, useEffect } from 'react';
import { useTranslation } from 'react-i18next';
import { Link } from 'react-router-dom';
import { format } from 'date-fns';
import { fr } from 'date-fns/locale';
import axios from 'axios';
import DashboardCalendar from './DashboardCalendar';
import DashboardStats from './DashboardStats';
import { Card, CardContent, Typography, Button, Grid, Box } from '@material-ui/core';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faCalendarAlt, faFileInvoiceDollar, faExclamationTriangle, faFileContract, faPlus } from '@fortawesome/free-solid-svg-icons';

const Dashboard = () => {
  const { t } = useTranslation();
  const [loading, setLoading] = useState(true);
  const [dashboardData, setDashboardData] = useState({
    upcomingConcerts: [],
    unpaidInvoices: [],
    followupBookings: [],
    missingContracts: []
  });
  const [view, setView] = useState('list'); // 'list' ou 'calendar'

  useEffect(() => {
    const fetchDashboardData = async () => {
      try {
        const response = await axios.get('/api/dashboard');
        setDashboardData(response.data);
        setLoading(false);
      } catch (error) {
        console.error('Erreur de chargement des données du tableau de bord', error);
        setLoading(false);
      }
    };

    fetchDashboardData();
  }, []);

  const formatPrice = (price) => {
    return new Intl.NumberFormat('fr-FR', { style: 'currency', currency: 'EUR' }).format(price);
  };

  if (loading) {
    return 
Chargement...
;
  }

  return (
    

      

        
{t('Dashboard')}

        

           setView('list')}
          >
            {t('List View')}
          
           setView('calendar')}
          >
            {t('Calendar View')}
          
        

      


      

      {view === 'calendar' ? (
        
      ) : (
        
          {/* Concerts à venir */}
          
            
              
                
                  
                  {t('Upcoming Concerts')}
                
                {dashboardData.upcomingConcerts.length === 0 ? (
                  {t('No upcoming concerts')}
                ) : (
                  dashboardData.upcomingConcerts.map(concert => (
                    
                      
                        {concert.artist.name} @ {concert.venue}
                      
                      

                        {format(new Date(concert.date), 'dd/MM/yyyy', { locale: fr })} | {concert.time}
                      

                      

                        
                          {t(concert.status.charAt(0).toUpperCase() + concert.status.slice(1).replace('_', ' '))}
                        
                      

                    
                  ))
                )}
                
                  }
                  >
                    {t('Add Concert')}
                  
                
              
            
          

          {/* Factures impayées */}
          
            
              
                
                  
                  {t('Unpaid Invoices')}
                
                {dashboardData.unpaidInvoices.length === 0 ? (
                  {t('No unpaid invoices')}
                ) : (
                  dashboardData.unpaidInvoices.map(invoice => (
                    
                      
                        {invoice.type === 'deposit' ? t('Deposit') : t('Balance')}: {invoice.concert.artist.name}
                      
                      

                        {t('Due date')}: {format(new Date(invoice.dueDate), 'dd/MM/yyyy', { locale: fr })}
                      

                      

                        {formatPrice(invoice.amount)}
                      

                    
                  ))
                )}
              
            
          

          {/* Réservations nécessitant un suivi */}
          
            
              
                
                  
                  {t('Bookings Needing Follow-up')}
                
                {dashboardData.followupBookings.length === 0 ? (
                  {t('No bookings needing follow-up')}
                ) : (
                  dashboardData.followupBookings.map(booking => (
                    
                      
                        {booking.artist.name} @ {booking.venue}
                      
                      

                        {t('Last contact')}: {format(new Date(booking.lastContact), 'dd/MM/yyyy', { locale: fr })}
                      

                      

                        {t('Status')}: {t(booking.status.charAt(0).toUpperCase() + booking.status.slice(1).replace('_', ' '))}
                      

                    
                  ))
                )}
              
            
          

          {/* Contrats manquants */}
          
            
              
                
                  
                  {t('Missing Contracts')}
                
                {dashboardData.missingContracts.length === 0 ? (
                  {t('No missing contracts')}
                ) : (
                  dashboardData.missingContracts.map(concert => (
                    
                      
                        {concert.artist.name} @ {concert.venue}
                      
                      

                        {format(new Date(concert.date), 'dd/MM/yyyy', { locale: fr })} | {concert.time}
                      

                      

                        
                          {t('Generate Contract')}
                        
                      

                    
                  ))
                )}
              
            
          
        
      )}

      
        
          {t('Quick Actions')}
        
        

          }
            fullWidth
          >
            {t('Send Email')}
          
          }
            fullWidth
          >
            {t('Create Contract')}
          
          }
            fullWidth
          >
            {t('Generate Invoice')}
          
          }
            fullWidth
          >
            {t('Add Concert')}
          
        

      
    

  );
};

export default Dashboard;
