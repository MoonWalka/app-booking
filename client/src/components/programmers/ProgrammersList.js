import React, { useState, useEffect, useMemo } from 'react';
import { useTranslation } from 'react-i18next';
import { Link } from 'react-router-dom';
import axios from 'axios';
import { useTable, useSortBy, useFilters, usePagination } from 'react-table';
import {
  TextField, Button, IconButton, Menu, MenuItem, Box,
  Typography, Paper, Table, TableBody, TableCell,
  TableContainer, TableHead, TableRow, TablePagination,
  Dialog, DialogActions, DialogContent, DialogTitle
} from '@material-ui/core';
import { Edit, Delete, FilterList, Add, Map } from '@material-ui/icons';
import ProgrammerForm from './ProgrammerForm';
import MapSearch from './MapSearch';
import { toast } from 'react-toastify';

const ProgrammersList = () => {
  const { t } = useTranslation();
  const [programmers, setProgrammers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [formOpen, setFormOpen] = useState(false);
  const [currentProgrammer, setCurrentProgrammer] = useState(null);
  const [deleteDialog, setDeleteDialog] = useState({ open: false, id: null });
  const [filterMenuAnchor, setFilterMenuAnchor] = useState(null);
  const [filters, setFilters] = useState({ city: '', region: '', musicStyle: '' });
  const [mapDialogOpen, setMapDialogOpen] = useState(false);

  const fetchProgrammers = async () => {
    try {
      const params = new URLSearchParams();
      if (filters.city) params.append('city', filters.city);
      if (filters.region) params.append('region', filters.region);
      if (filters.musicStyle) params.append('musicStyle', filters.musicStyle);

      const response = await axios.get(`/api/programmers?${params.toString()}`);
      setProgrammers(response.data);
      setLoading(false);
    } catch (error) {
      console.error('Erreur lors du chargement des programmateurs', error);
      toast.error(t('Error loading programmers'));
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchProgrammers();
  }, [filters]);

  const handleFilterChange = (e) => {
    const { name, value } = e.target;
    setFilters(prev => ({ ...prev, [name]: value }));
  };

  const clearFilters = () => {
    setFilters({ city: '', region: '', musicStyle: '' });
    setFilterMenuAnchor(null);
  };

  const openFilterMenu = (event) => {
    setFilterMenuAnchor(event.currentTarget);
  };

  const closeFilterMenu = () => {
    setFilterMenuAnchor(null);
  };

  const handleAddProgrammer = () => {
    setCurrentProgrammer(null);
    setFormOpen(true);
  };

  const handleEditProgrammer = (programmer) => {
    setCurrentProgrammer(programmer);
    setFormOpen(true);
  };

  const handleDeleteProgrammer = async () => {
    try {
      await axios.delete(`/api/programmers/${deleteDialog.id}`);
      setProgrammers(programmers.filter(p => p._id !== deleteDialog.id));
      toast.success(t('Programmer deleted successfully'));
      setDeleteDialog({ open: false, id: null });
    } catch (error) {
      console.error('Erreur lors de la suppression du programmateur', error);
      toast.error(t('Error deleting programmer'));
    }
  };

  const handleSaveProgrammer = async (programmerData) => {
    try {
      if (currentProgrammer) {
        await axios.put(`/api/programmers/${currentProgrammer._id}`, programmerData);
        setProgrammers(programmers.map(p =>
          p._id === currentProgrammer._id ? { ...p, ...programmerData } : p
        ));
        toast.success(t('Programmer updated successfully'));
      } else {
        const response = await axios.post('/api/programmers', programmerData);
        setProgrammers([...programmers, response.data]);
        toast.success(t('Programmer added successfully'));
      }
      setFormOpen(false);
    } catch (error) {
      console.error('Erreur lors de la sauvegarde du programmateur', error);
      toast.error(t('Error saving programmer'));
    }
  };

  const handleMapSearch = (results) => {
    setProgrammers(results);
    setMapDialogOpen(false);
  };

  const columns = useMemo(() => [
    {
      Header: t('Name'),
      accessor: 'name'
    },
    {
      Header: t('Structure'),
      accessor: 'structure'
    },
    {
      Header: t('City'),
      accessor: 'city'
    },
    {
      Header: t('Region'),
      accessor: 'region'
    },
    {
      Header: t('Phone'),
      accessor: 'phone'
    },
    {
      Header: t('Email'),
      accessor: 'email'
    },
    {
      Header: t('Music Style'),
      accessor: 'musicStyle',
      Cell: ({ value }) => value && value.join(', ')
    },
    {
      Header: t('Actions'),
      Cell: ({ row }) => (
        <>
          <IconButton onClick={() => handleEditProgrammer(row.original)}><Edit /></IconButton>
          <IconButton onClick={() => setDeleteDialog({ open: true, id: row.original._id })}><Delete /></IconButton>
        </>
      )
    }
  ], [t]);

  const {
    getTableProps,
    getTableBodyProps,
    headerGroups,
    prepareRow,
    page,
    gotoPage,
    setPageSize,
    state: { pageIndex, pageSize }
  } = useTable(
    {
      columns,
      data: programmers,
      initialState: { pageIndex: 0, pageSize: 10 }
    },
    useFilters,
    useSortBy,
    usePagination
  );

  if (loading) return <div>{t('Loading...')}</div>;

  return (
    <Box>
      <Typography variant="h4">{t('Programmers')}</Typography>
      <Button startIcon={<Map />} onClick={() => setMapDialogOpen(true)}>{t('Map Search')}</Button>
      <Button startIcon={<FilterList />} onClick={openFilterMenu}>{t('Filter')}</Button>
      <Button startIcon={<Add />} onClick={handleAddProgrammer}>{t('Add Programmer')}</Button>

      <TableContainer component={Paper}>
        <Table {...getTableProps()}>
          <TableHead>
            {headerGroups.map(headerGroup => (
              <TableRow {...headerGroup.getHeaderGroupProps()}>
                {headerGroup.headers.map(column => (
                  <TableCell {...column.getHeaderProps(column.getSortByToggleProps())}>
                    {column.render('Header')}
                    {column.isSorted ? (column.isSortedDesc ? ' 🔽' : ' 🔼') : ''}
                  </TableCell>
                ))}
              </TableRow>
            ))}
          </TableHead>
          <TableBody {...getTableBodyProps()}>
            {page.map(row => {
              prepareRow(row);
              return (
                <TableRow {...row.getRowProps()}>
                  {row.cells.map(cell => (
                    <TableCell {...cell.getCellProps()}>{cell.render('Cell')}</TableCell>
                  ))}
                </TableRow>
              );
            })}
          </TableBody>
        </Table>
      </TableContainer>

      <TablePagination
        component="div"
        count={programmers.length}
        page={pageIndex}
        onPageChange={(e, newPage) => gotoPage(newPage)}
        rowsPerPage={pageSize}
        onRowsPerPageChange={(e) => setPageSize(Number(e.target.value))}
        labelRowsPerPage={t('Rows per page')}
      />

      <Menu anchorEl={filterMenuAnchor} open={Boolean(filterMenuAnchor)} onClose={closeFilterMenu}>
        <Box p={2}>
          <Typography>{t('Filter Programmers')}</Typography>
          <TextField label={t('City')} name="city" value={filters.city} onChange={handleFilterChange} />
          <TextField label={t('Region')} name="region" value={filters.region} onChange={handleFilterChange} />
          <TextField label={t('Music Style')} name="musicStyle" value={filters.musicStyle} onChange={handleFilterChange} />
          <Button onClick={clearFilters}>{t('Clear Filters')}</Button>
          <Button onClick={closeFilterMenu}>{t('Apply')}</Button>
        </Box>
      </Menu>

      <Dialog open={formOpen} onClose={() => setFormOpen(false)} maxWidth="md" fullWidth>
        <DialogTitle>{currentProgrammer ? t('Edit Programmer') : t('Add New Programmer')}</DialogTitle>
        <DialogContent>
          <ProgrammerForm initialData={currentProgrammer} onSave={handleSaveProgrammer} onCancel={() => setFormOpen(false)} />
        </DialogContent>
      </Dialog>

      <Dialog open={deleteDialog.open} onClose={() => setDeleteDialog({ open: false, id: null })}>
        <DialogTitle>{t('Confirm Deletion')}</DialogTitle>
        <DialogContent>{t('Are you sure you want to delete this programmer? This action cannot be undone.')}</DialogContent>
        <DialogActions>
          <Button onClick={() => setDeleteDialog({ open: false, id: null })} color="primary">{t('Cancel')}</Button>
          <Button onClick={handleDeleteProgrammer} color="secondary">{t('Delete')}</Button>
        </DialogActions>
      </Dialog>

      <Dialog open={mapDialogOpen} onClose={() => setMapDialogOpen(false)} maxWidth="md" fullWidth>
        <DialogTitle>{t('Map Search')}</DialogTitle>
        <DialogContent>
          <MapSearch onSearch={handleMapSearch} />
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setMapDialogOpen(false)} color="primary">{t('Close')}</Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
};

export default ProgrammersList;
