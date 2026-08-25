import React, { useState, useEffect } from 'react';
import { useParams, Link } from 'react-router-dom';
import { BookOpen, ArrowLeft, Edit, Trash2, Clock, Code, FileText, Brain } from 'lucide-react';
import axios from 'axios';

function SkillDetail() {
  const { id } = useParams();
  const [skill, setSkill] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    fetchSkill();
  }, [id]);

  const fetchSkill = async () => {
    try {
      setLoading(true);
      const response = await axios.get(`/api/skills/${id}`);
      setSkill(response.data);
      setLoading(false);
    } catch (err) {
      setError(err.message);
      setLoading(false);
    }
  };

  const handleDelete = async () => {
    try {
      if (window.confirm('Are you sure you want to delete this skill?')) {
        await axios.delete(`/api/skills/${id}`);
        window.location.href = '/skills';
      }
    } catch (err) {
      setError(err.message);
    }
  };

  if (loading) {
    return (
      <div className="space-y-6 animate-fade-in">
        <div className="flex items-center justify-between">
          <Link to="/skills" className="btn btn-secondary flex items-center space-x-2">
            <ArrowLeft className="w-4 h-4" />
            <span>Back to Skills</span>
          </Link>
        </div>
        
        <div className="card">
          <div className="flex items-center justify-center py-12">
            <div className="spinner" />
            <span className="ml-3">Loading skill details...</span>
          </div>
        </div>
      </div>
    );
  }

  if (error || !skill) {
    return (
      <div className="space-y-6 animate-fade-in">
        <div className="flex items-center justify-between">
          <Link to="/skills" className="btn btn-secondary flex items-center space-x-2">
            <ArrowLeft className="w-4 h-4" />
            <span>Back to Skills</span>
          </Link>
        </div>
        
        <div className="card bg-red-50 border-red-200">
          <p className="text-red-600">{error || 'Skill not found'}</p>
          <button onClick={fetchSkill} className="btn btn-secondary mt-2">
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
        <Link to="/skills" className="btn btn-secondary flex items-center space-x-2">
          <ArrowLeft className="w-4 h-4" />
          <span>Back to Skills</span>
        </Link>
        
        <div className="flex items-center space-x-4">
          <Link
            to={`/skills/${id}/edit`}
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

      {/* Skill header */}
      <div className="card">
        <div className="flex items-center space-x-4">
          <div className="w-16 h-16 bg-purple-100 rounded-lg flex items-center justify-center">
            <Brain className="w-8 h-8 text-purple-600" />
          </div>
          <div>
            <h1 className="text-2xl font-bold text-gray-900">{skill.SkillName}</h1>
            <p className="text-gray-500 mt-1">{skill.Description || 'No description'}</p>
          </div>
        </div>
      </div>

      {/* Skill details */}
      <div className="card">
        <h2 className="text-lg font-semibold text-gray-900 mb-4">Skill Information</h2>
        
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div className="space-y-4">
            <div className="flex items-center space-x-3">
              <Code className="w-5 h-5 text-gray-400" />
              <div>
                <p className="text-sm text-gray-500">Class Name</p>
                <p className="font-medium">{skill.ClassName}</p>
              </div>
            </div>
            
            <div className="flex items-center space-x-3">
              <Clock className="w-5 h-5 text-gray-400" />
              <div>
                <p className="text-sm text-gray-500">Created</p>
                <p className="font-medium">
                  {new Date(skill.CreatedAt).toLocaleString()}
                </p>
              </div>
            </div>
          </div>
          
          <div className="space-y-4">
            <div className="flex items-center space-x-3">
              <FileText className="w-5 h-5 text-gray-400" />
              <div>
                <p className="text-sm text-gray-500">Skill ID</p>
                <p className="font-medium">{skill.SkillID}</p>
              </div>
            </div>
            
            <div className="flex items-center space-x-3">
              <span className="w-5 h-5 text-gray-400" />
              <div>
                <p className="text-sm text-gray-500">Skill Type</p>
                <p className="font-medium">
                  <span className="badge badge-info">{skill.SkillType}</span>
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Additional information */}
      <div className="card">
        <h2 className="text-lg font-semibold text-gray-900 mb-4">About This Skill</h2>
        <p className="text-gray-600">
          This skill provides {skill.SkillType} capabilities for your AI agents.
          It can be used to enhance agent performance and provide specialized knowledge.
        </p>
      </div>
    </div>
  );
}

export default SkillDetail;
