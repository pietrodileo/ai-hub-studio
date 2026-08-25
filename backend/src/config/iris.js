/**
 * IRIS Connection Configuration
 * Configuration for connecting to InterSystems IRIS
 */

const irisConfig = {
  // Connection settings
  host: process.env.IRIS_HOST || 'localhost',
  port: parseInt(process.env.IRIS_PORT) || 1972,
  webPort: parseInt(process.env.IRIS_WEB_PORT) || 52773,
  
  // Authentication
  namespace: process.env.IRIS_NAMESPACE || 'USER',
  username: process.env.IRIS_USERNAME || '_SYSTEM',
  password: process.env.IRIS_PASSWORD || 'SYS',
  
  // AI Hub settings
  aiHubEnabled: process.env.AI_HUB_ENABLED === 'false' ? false : true,
  aiHubPort: parseInt(process.env.AI_HUB_PORT) || 53773,
  aiHubWebSocketPort: parseInt(process.env.AI_HUB_WS_PORT) || 53773,
  
  // Timeouts
  connectionTimeout: parseInt(process.env.IRIS_CONNECTION_TIMEOUT) || 5000,
  requestTimeout: parseInt(process.env.IRIS_REQUEST_TIMEOUT) || 30000,
  
  // SSL/TLS
  useSSL: process.env.IRIS_USE_SSL === 'true' ? true : false,
  rejectUnauthorized: process.env.NODE_TLS_REJECT_UNAUTHORIZED !== '0'
};

// IRIS REST API base URL
const irisRestBaseUrl = `http${irisConfig.useSSL ? 's' : ''}://${irisConfig.host}:${irisConfig.webPort}`;

// AI Hub API base URL
const aiHubBaseUrl = `http${irisConfig.useSSL ? 's' : ''}://${irisConfig.host}:${irisConfig.aiHubPort}`;

// IRIS Native API connection string
const irisConnectionString = `${irisConfig.host}:${irisConfig.port}[${irisConfig.namespace}]`;

// Authentication token (for caching)
let authToken = null;
let authTokenExpiry = null;

/**
 * Get authentication token for IRIS REST API
 */
async function getAuthToken() {
  // Return cached token if still valid
  if (authToken && authTokenExpiry && authTokenExpiry > Date.now()) {
    return authToken;
  }
  
  try {
    const axios = require('axios');
    const authUrl = `${irisRestBaseUrl}/csp/sys/login`;
    
    const response = await axios.post(authUrl, null, {
      auth: {
        username: irisConfig.username,
        password: irisConfig.password
      },
      timeout: irisConfig.connectionTimeout
    });
    
    // Extract token from response (implementation depends on IRIS version)
    // This is a placeholder - actual implementation may vary
    authToken = response.data.token || response.data.access_token;
    authTokenExpiry = Date.now() + (response.data.expires_in || 3600) * 1000;
    
    return authToken;
  } catch (error) {
    console.error('Failed to get IRIS auth token:', error.message);
    throw error;
  }
}

/**
 * Make a request to IRIS REST API
 */
async function irisRequest(method, endpoint, data = null, params = null) {
  const axios = require('axios');
  
  const url = `${irisRestBaseUrl}${endpoint}`;
  
  const config = {
    method,
    url,
    timeout: irisConfig.requestTimeout,
    headers: {
      'Content-Type': 'application/json'
    }
  };
  
  // Add authentication
  try {
    const token = await getAuthToken();
    if (token) {
      config.headers['Authorization'] = `Bearer ${token}`;
    } else {
      // Fallback to basic auth
      config.auth = {
        username: irisConfig.username,
        password: irisConfig.password
      };
    }
  } catch (error) {
    // Fallback to basic auth if token retrieval fails
    config.auth = {
      username: irisConfig.username,
      password: irisConfig.password
    };
  }
  
  // Add request data
  if (data) {
    config.data = data;
  }
  
  if (params) {
    config.params = params;
  }
  
  try {
    const response = await axios(config);
    return response.data;
  } catch (error) {
    console.error(`IRIS ${method} ${endpoint} failed:`, error.message);
    
    // Enhance error with more details
    if (error.response) {
      error.message = `IRIS API Error: ${error.response.status} - ${JSON.stringify(error.response.data)}`;
    }
    
    throw error;
  }
}

/**
 * Execute ObjectScript code via REST API
 */
async function executeObjectScript(code) {
  try {
    const endpoint = '/csp/user/AIHub.REST.Execute';
    const response = await irisRequest('POST', endpoint, { code });
    return response;
  } catch (error) {
    console.error('Failed to execute ObjectScript:', error.message);
    throw error;
  }
}

/**
 * Call AI Hub API
 */
async function aiHubRequest(method, endpoint, data = null) {
  const axios = require('axios');
  
  const url = `${aiHubBaseUrl}${endpoint}`;
  
  const config = {
    method,
    url,
    timeout: irisConfig.requestTimeout,
    headers: {
      'Content-Type': 'application/json'
    }
  };
  
  if (data) {
    config.data = data;
  }
  
  try {
    const response = await axios(config);
    return response.data;
  } catch (error) {
    console.error(`AI Hub ${method} ${endpoint} failed:`, error.message);
    throw error;
  }
}

module.exports = {
  irisConfig,
  irisRestBaseUrl,
  aiHubBaseUrl,
  irisConnectionString,
  getAuthToken,
  irisRequest,
  executeObjectScript,
  aiHubRequest
};
