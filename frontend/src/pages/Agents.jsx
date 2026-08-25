import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { Bot, Plus, Search, MoreVertical, Edit, Trash2, PlayCircle } from 'lucide-react';
import axios from 'axios';

function Agents() {
  const [agents, setAgents] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [searchQuery, setSearchQuery] = useState('');

  useEffect(() => {
    fetchAgents();
  }, []);

  const fetchAgents = async () => {
    try {
      setLoading(true);
      const response = await axios.get('/api/agents');
      setAgents(response.data || []);
      setLoading(false);
    } catch (err) {
      setError(err.message);
      setLoading(false);
    }
  };

  const filteredAgents = agents.filter(agent => 
    agent.AgentName.toLowerCase().includes(searchQuery.toLowerCase()) ||
    agent.Description.toLowerCase().includes(searchQuery.toLowerCase())
  );

  const handleDelete = async (id) => {
    try {
      if (window.confirm('Are you sure you want to delete this agent?')) {
        await axios.delete(`/api/agents/${id}`);
        fetchAgents();
      }
    } catch (err) {
      setError(err.message);
    }
  };

  return (
    <div className="space-y-6 animate-fade-in">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Agents</h1>
          <p className="text-gray-500 mt-1">
            Manage your AI agents for automated tasks and workflows
          </p>
        </div>
        <Link
          to="/agents/new"
          className="btn btn-primary flex items-center space-x-2"
        >
          <Plus className="w-4 h-4" />
          <span>Create Agent</span>
        </Link>
      </div>

      {/* Search */}
      <div className="card">
        <div className="relative">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
          <input
            type="text"
            placeholder="Search agents..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="input pl-10"
          />
        </div>
      </div>

      {/* Agents table */}
      <div className="card">
        <div className="table-container">
          <table className="table">
            <thead className="table-header">
              <tr>
                <th className="table-header-cell">Name</th>
                <th className="table-header-cell">Description</th>
                <th className="table-header-cell">Class</th>
                <th className="table-header-cell">Created</th>
                <th className="table-header-cell">Actions</th>
              </tr>
            </thead>
            <tbody className="table-body">
              {loading ? (
                <tr>
                  <td colSpan="5" className="table-cell">
                    <div className="flex items-center justify-center py-8">
                      <div className="spinner" />
                      <span className="ml-3">Loading agents...</span>
                    </div>
                  </td>
                </tr>
              ) : filteredAgents.length === 0 ? (
                <tr>
                  <td colSpan="5" className="table-cell">
                    <div className="text-center py-8 text-gray-500">
                      <Bot className="w-12 h-12 mx-auto mb-4 text-gray-300" />
                      <p>No agents found</p>
                      <p className="text-sm mt-1">
                        Create your first agent to get started
                      </p>
                    </div>
                  </td>
                </tr>
              ) : (
                filteredAgents.map((agent) => (
                  <tr key={agent.AgentID} className="table-row">
                    <td className="table-cell">
                      <Link
                        to={`/agents/${agent.AgentID}`}
                        className="font-medium text-primary-600 hover:text-primary-800"
                      >
                        {agent.AgentName}
                      </Link>
                    </td>
                    <td className="table-cell">
                      <p className="text-gray-600 truncate max-w-xs">
                        {agent.Description || 'No description'}
                      </p>
                    </td>
                    <td className="table-cell">
                      <code className="text-sm bg-gray-100 px-2 py-1 rounded">
                        {agent.ClassName}
                      </code>
                    </td>
                    <td className="table-cell">
                      {new Date(agent.CreatedAt).toLocaleDateString()}
                    </td>
                    <td className="table-cell">
                      <div className="flex items-center space-x-2">
                        <button
                          onClick={() => handleDelete(agent.AgentID)}
                          className="p-2 text-gray-400 hover:text-red-600 hover:bg-red-50 rounded"
                          title="Delete"
                        >
                          <Trash2 className="w-4 h-4" />
                        </button>
                        <Link
                          to={`/agents/${agent.AgentID}/edit`}
                          className="p-2 text-gray-400 hover:text-blue-600 hover:bg-blue-50 rounded"
                          title="Edit"
                        >
                          <Edit className="w-4 h-4" />
                        </Link>
                        <button
                          className="p-2 text-gray-400 hover:text-green-600 hover:bg-green-50 rounded"
                          title="Execute"
                        >
                          <PlayCircle className="w-4 h-4" />
                        </button>
                      </div>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Error message */}
      {error && (
        <div className="card bg-red-50 border-red-200">
          <p className="text-red-600">{error}</p>
          <button
            onClick={fetchAgents}
            className="btn btn-secondary mt-2"
          >
            Retry
          </button>
        </div>
      )}
    </div>
  );
}

export default Agents;
