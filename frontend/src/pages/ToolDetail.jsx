import React, { useState, useEffect } from 'react';
import { useParams, Link } from 'react-router-dom';
import { Wrench, ArrowLeft, PlayCircle, Edit, Trash2, Clock, Code, FileText, Tag } from 'lucide-react';
import axios from 'axios';

function ToolDetail() {
  const { id } = useParams();
  const [tool, setTool] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [executionResult, setExecutionResult] = useState(null);
  const [executionLoading, setExecutionLoading] = useState(false);
  const [input, setInput] = useState('');

  useEffect(() => {
    fetchTool();
  }, [id]);

  const fetchTool = async () => {
    try {
      setLoading(true);
      const response = await axios.get(`/api/tools/${id}`);
      setTool(response.data);
      setLoading(false);
    } catch (err) {
      setError(err.message);
      setLoading(false);
    }
  };

  const handleExecute = async () => {
    try {
      setExecutionLoading(true);
      setExecutionResult(null);
      
      const response = await axios.post(`/api/tools/${id}/execute`, {
        input: input || 'Test input'
      });
      
      setExecutionResult(response.data);
      setExecutionLoading(false);
    } catch (err) {
      setExecutionResult({ error: err.message });
      setExecutionLoading(false);
    }
  };

  const handleDelete = async () => {
    try {
      if (window.confirm('Are you sure you want to delete this tool?')) {
        await axios.delete(`/api/tools/${id}`);
        window.location.href = '/tools';
      }
    } catch (err) {
      setError(err.message);
    }
  };

  if (loading) {
    return (
      <div className="space-y-6 animate-fade-in">
        <div className="flex items-center justify-between">
          <Link to="/tools" className="btn btn-secondary flex items-center space-x-2">
            <ArrowLeft className="w-4 h-4" />
            <span>Back to Tools</span>
          </Link>
        </div>
        
        <div className="card">
          <div className="flex items-center justify-center py-12">
            <div className="spinner" />
            <span className="ml-3">Loading tool details...</span>
          </div>
        </div>
      </div>
    );
  }

  if (error || !tool) {
    return (
      <div className="space-y-6 animate-fade-in">
        <div className="flex items-center justify-between">
          <Link to="/tools" className="btn btn-secondary flex items-center space-x-2">
            <ArrowLeft className="w-4 h-4" />
            <span>Back to Tools</span>
          </Link>
        </div>
        
        <div className="card bg-red-50 border-red-200">
          <p className="text-red-600">{error || 'Tool not found'}</p>
          <button onClick={fetchTool} className="btn btn-secondary mt-2">
            Retry
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6 animate-fade-in">
      {/* Header */}
      <div className="flex items-center justify-between">
        <Link to="/tools" className="btn btn-secondary flex items-center space-x-2">
          <ArrowLeft className="w-4 h-4" />
          <span>Back to Tools</span>
        </Link>
        
        <div className="flex items-center space-x-4">
          <Link
            to={`/tools/${id}/edit`}
            className="btn btn-secondary flex items-center space-x-2"
          >
            <Edit className="w-4 h-4" />
            <span>Edit</span>
          </Link>
          <button
            onClick={handleDelete}
            className="btn btn-danger flex items-center space-x-2"
          >
            <Trash2 className="w-4 h-4" />
            <span>Delete</span>
          </button>
        </div>
      </div>

      {/* Tool header */}
      <div className="card">
        <div className="flex items-center space-x-4">
          <div className="w-16 h-16 bg-green-100 rounded-lg flex items-center justify-center">
            <Wrench className="w-8 h-8 text-green-600" />
          </div>
          <div>
            <h1 className="text-2xl font-bold text-gray-900">{tool.ToolName}</h1>
            <p className="text-gray-500 mt-1">{tool.Description || 'No description'}</p>
          </div>
        </div>
      </div>

      {/* Tool details */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Tool information */}
        <div className="card">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">Tool Information</h2>
          
          <div className="space-y-4">
            <div className="flex items-center space-x-3">
              <Tag className="w-5 h-5 text-gray-400" />
              <div>
                <p className="text-sm text-gray-500">Tool Type</p>
                <p className="font-medium">
                  <span className={`badge badge-${tool.ToolType === 'function' ? 'info' : 'success'}`}>
                    {tool.ToolType}
                  </span>
                </p>
              </div>
            </div>
            
            <div className="flex items-center space-x-3">
              <Code className="w-5 h-5 text-gray-400" />
              <div>
                <p className="text-sm text-gray-500">Class Name</p>
                <p className="font-medium">{tool.ClassName}</p>
              </div>
            </div>
            
            <div className="flex items-center space-x-3">
              <Clock className="w-5 h-5 text-gray-400" />
              <div>
                <p className="text-sm text-gray-500">Created</p>
                <p className="font-medium">
                  {new Date(tool.CreatedAt).toLocaleString()}
                </p>
              </div>
            </div>
            
            <div className="flex items-center space-x-3">
              <FileText className="w-5 h-5 text-gray-400" />
              <div>
                <p className="text-sm text-gray-500">Tool ID</p>
                <p className="font-medium">{tool.ToolID}</p>
              </div>
            </div>
          </div>
        </div>

        {/* Execution */}
        <div className="card">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">Test Execution</h2>
          
          <div className="space-y-4">
            <div>
              <label htmlFor="input" className="block text-sm font-medium text-gray-700 mb-1">
                Input
              </label>
              <textarea
                id="input"
                value={input}
                onChange={(e) => setInput(e.target.value)}
                placeholder="Enter input for the tool..."
                rows={3}
                className="input"
              />
            </div>
            
            <button
              onClick={handleExecute}
              disabled={executionLoading}
              className="btn btn-primary flex items-center space-x-2 w-full"
            >
              {executionLoading ? (
                <div className="spinner !w-4 !h-4 !border-2" />
              ) : (
                <PlayCircle className="w-4 h-4" />
              )}
              <span>{executionLoading ? 'Executing...' : 'Execute Tool'}</span>
            </button>
          </div>

          {/* Execution result */}
          {executionResult && (
            <div className="mt-6 p-4 bg-gray-50 rounded-lg">
              <h3 className="font-semibold text-gray-900 mb-2">Execution Result</h3>
              <pre className="code-block whitespace-pre-wrap">
                {JSON.stringify(executionResult, null, 2)}
              </pre>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

export default ToolDetail;
