/**
 * Tools Routes
 * Routes for managing AI tools
 */

const express = require('express');
const router = express.Router();
const { irisRequest } = require('../config/iris');

/**
 * GET /api/tools
 * List all tools
 */
router.get('/', async (req, res) => {
  try {
    const response = await irisRequest('GET', '/ai-hub/api/tools');
    res.json(response);
  } catch (error) {
    console.error('Failed to get tools:', error.message);
    res.status(500).json({
      error: 'Failed to retrieve tools',
      details: error.message
    });
  }
});

/**
 * GET /api/tools/:id
 * Get specific tool by ID
 */
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const response = await irisRequest('GET', `/ai-hub/api/tools/${id}`);
    res.json(response);
  } catch (error) {
    console.error(`Failed to get tool ${req.params.id}:`, error.message);
    res.status(500).json({
      error: 'Failed to retrieve tool',
      details: error.message
    });
  }
});

/**
 * POST /api/tools
 * Create new tool
 */
router.post('/', async (req, res) => {
  try {
    const { ToolName, Description, ClassName, ToolType } = req.body;
    
    if (!ToolName || !ClassName) {
      return res.status(400).json({
        error: 'ToolName and ClassName are required'
      });
    }
    
    const response = await irisRequest('POST', '/ai-hub/api/tools', {
      ToolName,
      Description: Description || '',
      ClassName,
      ToolType: ToolType || 'function'
    });
    
    res.status(201).json(response);
  } catch (error) {
    console.error('Failed to create tool:', error.message);
    res.status(500).json({
      error: 'Failed to create tool',
      details: error.message
    });
  }
});

/**
 * PUT /api/tools/:id
 * Update tool
 */
router.put('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { ToolName, Description, ClassName, ToolType } = req.body;
    
    const response = await irisRequest('PUT', `/ai-hub/api/tools/${id}`, {
      ToolName,
      Description,
      ClassName,
      ToolType
    });
    
    res.json(response);
  } catch (error) {
    console.error(`Failed to update tool ${req.params.id}:`, error.message);
    res.status(500).json({
      error: 'Failed to update tool',
      details: error.message
    });
  }
});

/**
 * DELETE /api/tools/:id
 * Delete tool
 */
router.delete('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const response = await irisRequest('DELETE', `/ai-hub/api/tools/${id}`);
    res.json(response);
  } catch (error) {
    console.error(`Failed to delete tool ${req.params.id}:`, error.message);
    res.status(500).json({
      error: 'Failed to delete tool',
      details: error.message
    });
  }
});

/**
 * POST /api/tools/:id/execute
 * Execute tool
 */
router.post('/:id/execute', async (req, res) => {
  try {
    const { id } = req.params;
    const { input, parameters } = req.body;
    
    const response = await irisRequest('POST', `/ai-hub/api/tools/${id}/execute`, {
      input: input || '',
      parameters: parameters || {}
    });
    
    res.json(response);
  } catch (error) {
    console.error(`Failed to execute tool ${req.params.id}:`, error.message);
    res.status(500).json({
      error: 'Failed to execute tool',
      details: error.message
    });
  }
});

/**
 * GET /api/tools/categories
 * Get tool categories
 */
router.get('/categories', async (req, res) => {
  try {
    // Mock response for now - will be implemented in IRIS
    const categories = [
      { name: 'database', description: 'Database operations' },
      { name: 'file', description: 'File system operations' },
      { name: 'network', description: 'Network operations' },
      { name: 'ai', description: 'AI and ML operations' },
      { name: 'utility', description: 'Utility functions' }
    ];
    
    res.json(categories);
  } catch (error) {
    console.error('Failed to get tool categories:', error.message);
    res.status(500).json({
      error: 'Failed to retrieve tool categories',
      details: error.message
    });
  }
});

/**
 * GET /api/tools/search
 * Search tools
 */
router.get('/search', async (req, res) => {
  try {
    const { q: query, category, limit = 10 } = req.query;
    
    if (!query) {
      return res.status(400).json({
        error: 'Search query (q) is required'
      });
    }
    
    // Mock response for now
    const results = [
      {
        ToolID: '1',
        ToolName: 'SQL Query',
        Description: 'Execute SQL queries against IRIS database',
        ClassName: 'AIHub.Tool.SQL',
        ToolType: 'function',
        Category: 'database'
      }
    ];
    
    res.json(results);
  } catch (error) {
    console.error('Failed to search tools:', error.message);
    res.status(500).json({
      error: 'Failed to search tools',
      details: error.message
    });
  }
});

module.exports = router;
