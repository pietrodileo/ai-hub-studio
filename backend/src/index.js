/**
 * IRIS AI Hub Studio - Backend API
 * Main entry point for the Express server
 */

const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const helmet = require('helmet');
const morgan = require('morgan');
const path = require('path');
const fs = require('fs');

// Load environment variables
require('dotenv').config();

// Create Express app
const app = express();
const PORT = process.env.PORT || 3000;

// ============================================================================
// Middleware Configuration
// ============================================================================

// Security middleware
app.use(helmet());

// CORS configuration
app.use(cors({
  origin: process.env.CORS_ORIGIN || '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

// Body parsing middleware
app.use(bodyParser.json({ limit: '10mb' }));
app.use(bodyParser.urlencoded({ extended: true, limit: '10mb' }));

// Request logging
const accessLogStream = fs.createWriteStream(path.join(__dirname, '../logs/access.log'), { flags: 'a' });
app.use(morgan('combined', { stream: accessLogStream }));

// Error handling middleware
app.use((err, req, res, next) => {
  console.error('Error:', err);
  res.status(500).json({
    error: 'Internal Server Error',
    message: process.env.NODE_ENV === 'development' ? err.message : 'Something went wrong'
  });
});

// ============================================================================
// Import Routes
// ============================================================================

const agentsRouter = require('./routes/agents');
const toolsRouter = require('./routes/tools');
const skillsRouter = require('./routes/skills');

// ============================================================================
// API Routes
// ============================================================================

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    service: 'iris-ai-hub-backend',
    version: '1.0.0',
    uptime: process.uptime()
  });
});

// API info endpoint
app.get('/api-info', (req, res) => {
  res.json({
    name: 'IRIS AI Hub Studio API',
    version: '1.0.0',
    description: 'Backend API for IRIS AI Hub Studio',
    endpoints: {
      health: '/health',
      agents: '/api/agents',
      tools: '/api/tools',
      skills: '/api/skills'
    }
  });
});

// Mount route handlers
app.use('/api/agents', agentsRouter);
app.use('/api/tools', toolsRouter);
app.use('/api/skills', skillsRouter);

// ============================================================================
// IRIS Proxy Routes (for development)
// ============================================================================

// Proxy to IRIS Management Portal
app.get('/iris/*', async (req, res) => {
  try {
    const irisConfig = require('./config/iris').irisConfig;
    const path = req.params[0];
    const url = `http://${irisConfig.host}:${irisConfig.webPort}/${path}`;
    
    const axios = require('axios');
    const response = await axios.get(url, {
      responseType: 'arraybuffer',
      headers: {
        'Authorization': 'Basic ' + Buffer.from(`${irisConfig.username}:${irisConfig.password}`).toString('base64')
      }
    });
    
    // Set appropriate headers for the response
    res.set('Content-Type', response.headers['content-type'] || 'text/html');
    res.send(response.data);
  } catch (error) {
    console.error('IRIS proxy error:', error.message);
    res.status(500).json({ error: error.message });
  }
});

// ============================================================================
// 404 Handler
// ============================================================================

app.use('*', (req, res) => {
  res.status(404).json({
    error: 'Not Found',
    message: `Route ${req.method} ${req.path} not found`
  });
});

// ============================================================================
// Start Server
// ============================================================================

// Ensure logs directory exists
const logsDir = path.join(__dirname, '../logs');
if (!fs.existsSync(logsDir)) {
  fs.mkdirSync(logsDir, { recursive: true });
}

// Start the server
const server = app.listen(PORT, () => {
  console.log(`🚀 IRIS AI Hub Backend API server running on port ${PORT}`);
  console.log(`📚 Health check: http://localhost:${PORT}/health`);
  console.log(`📖 API info: http://localhost:${PORT}/api-info`);
  console.log(`🔗 API base URL: http://localhost:${PORT}/api`);
  console.log(`📝 Logs: ${logsDir}`);
});

// Export app for testing
module.exports = app;
