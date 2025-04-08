import React from 'react';
import ContractsTable from '../contracts/ContractsTable';
import './Dashboard.css';

const Dashboard = () => {
  return (
    <div className="dashboard-container">
      <ContractsTable />
    </div>
  );
};

export default Dashboard;
