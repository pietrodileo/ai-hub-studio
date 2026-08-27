/**
 * Agents Routes
 * Routes for managing AI agents
 */

const express = require('express');
const router = express.Router();
const { irisRequest } = require('../config/iris');

/**
 * GET /api/agents
 * List all agents
 */
router.get('/', async (req, res) => {
  try {
    // Call IRIS REST API to get agents
    const response = await irisRequest('GET', '/ai-hub/api/studio/agents');
    res.json(response);
  } catch (error) {
    console.error('Failed to get agents:', error.message);
    res.status(500).json({
      error: 'Failed to retrieve agents',
      details: error.message
    });
  }
});

/**
 * GET /api/agents/:id
 * Get specific agent by ID
 */
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const response = await irisRequest('GET', `/ai-hub/api/studio/agents/${id}`);
    res.json(response);
  } catch (error) {
    console.error(`Failed to get agent ${req.params.id}:`, error.message);
    res.status(500).json({
      error: 'Failed to retrieve agent',
      details: error.message
    });
  }
});

/**
 * POST /api/agents
 * Create new agent
 */
router.post('/', async (req, res) => {
  try {
    const { AgentName, Description, ClassName } = req.body;
    
    if (!AgentName || !ClassName) {
      return res.status(400).json({
        error: 'AgentName and ClassName are required'
      });
    }
    
    const response = await irisRequest('POST', '/ai-hub/api/studio/agents', {
      AgentName,
      Description: Description || '',
      ClassName
    });
    
    res.status(201).json(response);
  } catch (error) {
    console.error('Failed to create agent:', error.message);
    res.status(500).json({
      error: 'Failed to create agent',
      details: error.message
    });
  }
});

/**
 * PUT /api/agents/:id
 * Update agent
 */
router.put('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { AgentName, Description, ClassName } = req.body;
    
    const response = await irisRequest('PUT', `/ai-hub/api/studio/agents/${id}`, {
      AgentName,
      Description,
      ClassName
    });
    
    res.json(response);
  } catch (error) {
    console.error(`Failed to update agent ${req.params.id}:`, error.message);
    res.status(500).json({
      error: 'Failed to update agent',
      details: error.message
    });
  }
});

/**
 * DELETE /api/agents/:id
 * Delete agent
 */
router.delete('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const response = await irisRequest('DELETE', `/ai-hub/api/studio/agents/${id}`);
    res.json(response);
  } catch (error) {
    console.error(`Failed to delete agent ${req.params.id}:`, error.message);
    res.status(500).json({
      error: 'Failed to delete agent',
      details: error.message
    });
  }
});

/**
 * POST /api/agents/:id/execute
 * Execute agent
 */
router.post('/:id/execute', async (req, res) => {
  try {
    const { id } = req.params;
    const { input, parameters } = req.body;
    
    const response = await irisRequest('POST', `/ai-hub/api/agents/${id}/execute`, {
      input: input || '',
      parameters: parameters || {}
    });
    
    res.json(response);
  } catch (error) {
    console.error(`Failed to execute agent ${req.params.id}:`, error.message);
    res.status(500).json({
      error: 'Failed to execute agent',
      details: error.message
    });
  }
});

/**
 * GET /api/agents/:id/history
 * Get agent execution history
 */
router.get('/:id/history', async (req, res) => {
  try {
    const { id } = req.params;
    const { limit = 10, offset = 0 } = req.query;
    
    const response = await irisRequest('GET', `/ai-hub/api/agents/${id}/history`, null, {
      limit,
      offset
    });
    
    res.json(response);
  } catch (error) {
    console.error(`Failed to get agent history for ${req.params.id}:`, error.message);
    res.status(500).json({
      error: 'Failed to retrieve agent history',
      details: error.message
    });
  }
});

module.exports = router;
