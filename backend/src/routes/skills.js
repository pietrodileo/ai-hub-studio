/**
 * Skills Routes
 * Routes for managing AI skills
 */

const express = require('express');
const router = express.Router();
const { irisRequest } = require('../config/iris');

/**
 * GET /api/skills
 * List all skills
 */
router.get('/', async (req, res) => {
  try {
    const response = await irisRequest('GET', '/ai-hub/api/studio/skills');
    res.json(response);
  } catch (error) {
    console.error('Failed to get skills:', error.message);
    res.status(500).json({
      error: 'Failed to retrieve skills',
      details: error.message
    });
  }
});

/**
 * GET /api/skills/:id
 * Get specific skill by ID
 */
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const response = await irisRequest('GET', `/ai-hub/api/studio/skills/${id}`);
    res.json(response);
  } catch (error) {
    console.error(`Failed to get skill ${req.params.id}:`, error.message);
    res.status(500).json({
      error: 'Failed to retrieve skill',
      details: error.message
    });
  }
});

/**
 * POST /api/skills
 * Create new skill
 */
router.post('/', async (req, res) => {
  try {
    const { SkillName, Description, ClassName, SkillType } = req.body;
    
    if (!SkillName || !ClassName) {
      return res.status(400).json({
        error: 'SkillName and ClassName are required'
      });
    }
    
    const response = await irisRequest('POST', '/ai-hub/api/studio/skills', {
      SkillName,
      Description: Description || '',
      ClassName,
      SkillType: SkillType || 'knowledge'
    });
    
    res.status(201).json(response);
  } catch (error) {
    console.error('Failed to create skill:', error.message);
    res.status(500).json({
      error: 'Failed to create skill',
      details: error.message
    });
  }
});

/**
 * PUT /api/skills/:id
 * Update skill
 */
router.put('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { SkillName, Description, ClassName, SkillType } = req.body;
    
    const response = await irisRequest('PUT', `/ai-hub/api/studio/skills/${id}`, {
      SkillName,
      Description,
      ClassName,
      SkillType
    });
    
    res.json(response);
  } catch (error) {
    console.error(`Failed to update skill ${req.params.id}:`, error.message);
    res.status(500).json({
      error: 'Failed to update skill',
      details: error.message
    });
  }
});

/**
 * DELETE /api/skills/:id
 * Delete skill
 */
router.delete('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const response = await irisRequest('DELETE', `/ai-hub/api/studio/skills/${id}`);
    res.json(response);
  } catch (error) {
    console.error(`Failed to delete skill ${req.params.id}:`, error.message);
    res.status(500).json({
      error: 'Failed to delete skill',
      details: error.message
    });
  }
});

/**
 * GET /api/skills/types
 * Get skill types
 */
router.get('/types', async (req, res) => {
  try {
    // Mock response for now
    const types = [
      { name: 'knowledge', description: 'Domain knowledge and information' },
      { name: 'reasoning', description: 'Reasoning and problem-solving skills' },
      { name: 'memory', description: 'Memory and context management' },
      { name: 'tool-use', description: 'Tool usage and orchestration' },
      { name: 'communication', description: 'Communication and language skills' }
    ];
    
    res.json(types);
  } catch (error) {
    console.error('Failed to get skill types:', error.message);
    res.status(500).json({
      error: 'Failed to retrieve skill types',
      details: error.message
    });
  }
});

/**
 * GET /api/skills/search
 * Search skills
 */
router.get('/search', async (req, res) => {
  try {
    const { q: query, type, limit = 10 } = req.query;
    
    if (!query) {
      return res.status(400).json({
        error: 'Search query (q) is required'
      });
    }
    
    // Mock response for now
    const results = [
      {
        SkillID: '1',
        SkillName: 'Medical Knowledge',
        Description: 'Comprehensive medical domain knowledge',
        ClassName: 'AIHub.Skill.Medical',
        SkillType: 'knowledge'
      }
    ];
    
    res.json(results);
  } catch (error) {
    console.error('Failed to search skills:', error.message);
    res.status(500).json({
      error: 'Failed to search skills',
      details: error.message
    });
  }
});

module.exports = router;
