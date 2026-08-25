import React from 'react';
import { Link } from 'react-router-dom';
import { AlertCircle, Home } from 'lucide-react';

function NotFound() {
  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50 py-12 px-4 sm:px-6 lg:px-8">
      <div className="text-center">
        <div className="w-24 h-24 bg-red-100 rounded-full flex items-center justify-center mx-auto mb-6">
          <AlertCircle className="w-12 h-12 text-red-600" />
        </div>
        
        <h1 className="text-4xl font-bold text-gray-900 mb-2">404 - Page Not Found</h1>
        <p className="text-xl text-gray-500 mb-8">
          Oops! The page you're looking for doesn't exist.
        </p>
        
        <div className="flex flex-col sm:flex-row gap-4 justify-center">
          <Link
            to="/"
            className="btn btn-primary flex items-center justify-center space-x-2"
          >
            <Home className="w-4 h-4" />
            <span>Go Home</span>
          </Link>
          
          <Link
            to="/agents"
            className="btn btn-secondary flex items-center justify-center space-x-2"
          >
            <span>Browse Agents</span>
          </Link>
        </div>
      </div>
    </div>
  );
}

export default NotFound;
