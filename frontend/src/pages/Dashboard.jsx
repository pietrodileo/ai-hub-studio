import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { 
  LayoutDashboard, 
  Bot, 
  Wrench, 
  BookOpen,
  TrendingUp,
  Clock,
  CheckCircle,
  AlertCircle
} from 'lucide-react';
import axios from 'axios';

function Dashboard() {
  const [stats, setStats] = useState({
    agents: 0,
    tools: 0,
    skills: 0,
    health: 'loading'
  });
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    fetchStats();
  }, []);

  const fetchStats = async () => {
    try {
      setLoading(true);
      
      // Fetch health check
      const healthResponse = await axios.get('/api/health');
      
      // Mock agent count (will be replaced with actual API calls)
      const agentsResponse = await axios.get('/api/agents');
      const toolsResponse = await axios.get('/api/tools');
      const skillsResponse = await axios.get('/api/skills');
      
      setStats({
        agents: agentsResponse.data.length || 0,
        tools: toolsResponse.data.length || 0,
        skills: skillsResponse.data.length || 0,
        health: healthResponse.data.status || 'unknown'
      });
      
      setLoading(false);
    } catch (err) {
      setError(err.message);
      setLoading(false);
      setStats({ ...stats, health: 'error' });
    }
  };

  const statCards = [
    {
      name: 'Agents',
      value: stats.agents,
      icon: Bot,
      color: 'blue',
      href: '/agents'
    },
    {
      name: 'Tools',
      value: stats.tools,
      icon: Wrench,
      color: 'green',
      href: '/tools'
    },
    {
      name: 'Skills',
      value: stats.skills,
      icon: BookOpen,
      color: 'purple',
      href: '/skills'
    },
    {
      name: 'Status',
      value: stats.health,
      icon: stats.health === 'healthy' ? CheckCircle : AlertCircle,
      color: stats.health === 'healthy' ? 'green' : 'red',
      href: '/health'
    }
  ];

  const colorClasses = {
    blue: 'bg-blue-100 text-blue-600',
    green: 'bg-green-100 text-green-600',
    purple: 'bg-purple-100 text-purple-600',
    red: 'bg-red-100 text-red-600'
  };

  const iconClasses = {
    blue: 'text-blue-600',
    green: 'text-green-600',
    purple: 'text-purple-600',
    red: 'text-red-600'
  };

  return (
    <div className="space-y-6 animate-fade-in">
      {/* Welcome section */}
      <div className="bg-gradient-primary rounded-lg p-6 text-white">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-2xl font-bold mb-2">Welcome to IRIS AI Hub Studio</h1>
            <p className="text-primary-100">
              Build, manage, and deploy AI agents with InterSystems IRIS
            </p>
          </div>
          <div className="w-12 h-12 bg-white bg-opacity-20 rounded-lg flex items-center justify-center">
            <LayoutDashboard className="w-6 h-6 text-white" />
          </div>
        </div>
      </div>

      {/* Stats cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
        {statCards.map((stat) => (
          <Link
            key={stat.name}
            to={stat.href}
            className="card group hover:shadow-lg transition-shadow"
          >
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-gray-500 mb-1">{stat.name}</p>
                <p className="text-2xl font-bold text-gray-900">
                  {typeof stat.value === 'number' ? stat.value : stat.value}
                </p>
              </div>
              <div className={`p-3 rounded-lg ${colorClasses[stat.color]}`}>
                <stat.icon className={`w-5 h-5 ${iconClasses[stat.color]}`} />
              </div>
            </div>
          </Link>
        ))}
      </div>

      {/* Quick actions */}
      <div className="card">
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-lg font-semibold text-gray-900">Quick Actions</h2>
          <TrendingUp className="w-5 h-5 text-gray-400" />
        </div>
        
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <Link
            to="/agents/new"
            className="flex items-center space-x-3 p-4 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors"
          >
            <div className="w-10 h-10 bg-blue-100 rounded-lg flex items-center justify-center">
              <Bot className="w-5 h-5 text-blue-600" />
            </div>
            <div>
              <p className="font-medium text-gray-900">Create Agent</p>
              <p className="text-sm text-gray-500">Build a new AI agent</p>
            </div>
          </Link>
          
          <Link
            to="/tools/new"
            className="flex items-center space-x-3 p-4 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors"
          >
            <div className="w-10 h-10 bg-green-100 rounded-lg flex items-center justify-center">
              <Wrench className="w-5 h-5 text-green-600" />
            </div>
            <div>
              <p className="font-medium text-gray-900">Add Tool</p>
              <p className="text-sm text-gray-500">Create a new tool</p>
            </div>
          </Link>
          
          <Link
            to="/skills/new"
            className="flex items-center space-x-3 p-4 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors"
          >
            <div className="w-10 h-10 bg-purple-100 rounded-lg flex items-center justify-center">
              <BookOpen className="w-5 h-5 text-purple-600" />
            </div>
            <div>
              <p className="font-medium text-gray-900">Add Skill</p>
              <p className="text-sm text-gray-500">Add new knowledge</p>
            </div>
          </Link>
        </div>
      </div>

      {/* Recent activity (placeholder) */}
      <div className="card">
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-lg font-semibold text-gray-900">Recent Activity</h2>
          <Clock className="w-5 h-5 text-gray-400" />
        </div>
        
        <div className="space-y-4">
          <div className="flex items-center space-x-3 p-3 bg-gray-50 rounded-lg">
            <div className="w-8 h-8 bg-blue-100 rounded-full flex items-center justify-center">
              <Bot className="w-4 h-4 text-blue-600" />
            </div>
            <div className="flex-1">
              <p className="font-medium text-gray-900">Agent created</p>
              <p className="text-sm text-gray-500">Test Agent was created</p>
            </div>
            <span className="text-xs text-gray-400">2 min ago</span>
          </div>
          
          <div className="flex items-center space-x-3 p-3 bg-gray-50 rounded-lg">
            <div className="w-8 h-8 bg-green-100 rounded-full flex items-center justify-center">
              <Wrench className="w-4 h-4 text-green-600" />
            </div>
            <div className="flex-1">
              <p className="font-medium text-gray-900">Tool added</p>
              <p className="text-sm text-gray-500">SQL Query tool was added</p>
            </div>
            <span className="text-xs text-gray-400">5 min ago</span>
          </div>
          
          <div className="flex items-center space-x-3 p-3 bg-gray-50 rounded-lg">
            <div className="w-8 h-8 bg-purple-100 rounded-full flex items-center justify-center">
              <BookOpen className="w-4 h-4 text-purple-600" />
            </div>
            <div className="flex-1">
              <p className="font-medium text-gray-900">Skill imported</p>
              <p className="text-sm text-gray-500">Medical Knowledge skill imported</p>
            </div>
            <span className="text-xs text-gray-400">10 min ago</span>
          </div>
        </div>
      </div>

      {/* Error message */}
      {error && (
        <div className="card bg-red-50 border-red-200">
          <p className="text-red-600">{error}</p>
        </div>
      )}
    </div>
  );
}

export default Dashboard;
