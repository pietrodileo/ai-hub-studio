import React from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';
import Layout from './components/Layout';
import Dashboard from './pages/Dashboard';
import Agents from './pages/Agents';
import Tools from './pages/Tools';
import Skills from './pages/Skills';
import Configuration from './pages/Configuration';
import AgentDetail from './pages/AgentDetail';
import ToolDetail from './pages/ToolDetail';
import SkillDetail from './pages/SkillDetail';
import NotFound from './pages/NotFound';

function App() {
  return (
    <Layout>
      <Routes>
        <Route path="/" element={<Dashboard />} />
        <Route path="/agents" element={<Agents />} />
        <Route path="/agents/:id" element={<AgentDetail />} />
        <Route path="/tools" element={<Tools />} />
        <Route path="/tools/:id" element={<ToolDetail />} />
        <Route path="/skills" element={<Skills />} />
        <Route path="/skills/:id" element={<SkillDetail />} />
        <Route path="/configuration" element={<Configuration />} />
        <Route path="/404" element={<NotFound />} />
        <Route path="*" element={<Navigate to="/404" replace />} />
      </Routes>
    </Layout>
  );
}

export default App;
