# 📋 Step-by-Step Implementation Guide

**Project**: IRIS AI Hub Studio  
**Purpose**: Detailed implementation steps for building the unified platform  
**Based on**: PROJECT-GOALS.md roadmap  
**Status**: Ready for Execution  

---

## 🎯 Implementation Overview

This guide provides **detailed, step-by-step instructions** for implementing the IRIS AI Hub Studio platform according to the roadmap in PROJECT-GOALS.md.

**Total Estimated Time**: ~80-100 hours (spread over 5 weeks)
**Daily Commitment**: ~3-4 hours/day
**Difficulty**: Intermediate to Advanced

---

## 📁 Project Structure

```
iris-ai-hub-studio/
├── docker-compose.yml              # Main docker configuration
├── docker-compose.override.yml     # Development overrides
├── .env                            # Environment variables
├── README.md                       # Main documentation
│
├── docs/                          # Documentation (this folder)
│   ├── generic/                   # Generic AI Hub documentation
│   └── project/                  # Project-specific documentation
│
├── src/                           # Source code
│   ├── frontend/                  # React web application
│   │   ├── public/
│   │   ├── src/
│   │   │   ├── components/
│   │   │   │   ├── AgentPlayground/
│   │   │   │   ├── DataExplorer/
│   │   │   │   └── TemplateGenerator/
│   │   │   ├── hooks/
│   │   │   ├── services/
│   │   │   ├── styles/
│   │   │   └── App.tsx
│   │   └── package.json
│   │
│   ├── backend/                   # Node.js backend services
│   │   ├── src/
│   │   │   ├── controllers/
│   │   │   ├── services/
│   │   │   ├── routes/
│   │   │   ├── models/
│   │   │   └── server.ts
│   │   └── package.json
│   │
│   └── iris/                      # IRIS components
│       ├── cls/
│       │   ├── AIHub/
│       │   │   ├── AgentManager.cls
│       │   │   ├── MCP/
│       │   │   │   ├── Bridge.cls
│       │   │   │   ├── GlobalConnector.cls
│       │   │   │   ├── SQLConnector.cls
│       │   │   │   └── DocDBConnector.cls
│       │   │   ├── Templates/
│       │   │   │   ├── StarterAgent.cls
│       │   │   │   └── ...
│       │   │   └── Package.cls
│       │   └── ...
│       └── Dockerfile
│
├── mcp-servers/                   # MCP server implementations
│   ├── iris-data-server/
│   │   ├── src/
│   │   └── package.json
│   └── Dockerfile
│
├── templates/                    # Agent and MCP templates
│   ├── agent-templates/
│   │   ├── basic-agent/
│   │   ├── healthcare-agent/
│   │   └── financial-agent/
│   └── mcp-templates/
│       ├── global-exposure/
│       ├── sql-exposure/
│       └── docdb-exposure/
│
├── examples/                     # Working examples
│   ├── healthcare-demo/
│   ├── financial-demo/
│   └── retail-demo/
│
├── scripts/                      # Utility scripts
│   ├── setup.sh
│   ├── test.sh
│   └── deploy.sh
│
├── config/                       # Configuration files
│   ├── default.yaml
│   ├── agents.yaml
│   └── mcp-servers.yaml
│
└── tests/                       # Test files
    ├── unit/
    └── integration/
```

---

## 🚀 Phase 1: Foundation (Week 1)
**Goal**: Set up infrastructure and create basic functionality for all components

### Day 1: Environment Setup & Project Structure

#### Step 1.1: Set Up Docker Environment

**Time**: 1-2 hours
**Files**: `docker-compose.yml`, `.env`, `Dockerfile`

```bash
# 1. Create project directory
mkdir -p iris-ai-hub-studio/{src/{frontend,backend,iris/{cls,Package}},mcp-servers,templates,examples,scripts,config,tests,docs}

# 2. Create docker-compose.yml (copy from docs/DOCKER-SETUP.md)
cp ../docs/DOCKER-SETUP.md ./docker-compose.yml

# 3. Create .env file
cp ../docs/DOCKER-SETUP.md ./env.example
# Edit env.example and save as .env

# 4. Start the environment
./start.sh up

# 5. Verify AI Hub installation
./verify-ai-hub.sh
```

**Verification**:
- [ ] Docker container is running
- [ ] IRIS is accessible at http://localhost:52773
- [ ] AI Hub classes exist (%AI.Agent, %AI.MCP.Server)

#### Step 1.2: Set Up Version Control

**Time**: 30 minutes

```bash
# 1. Initialize Git repository
cd iris-ai-hub-studio
git init

# 2. Create .gitignore
cat > .gitignore << 'EOF'
# Dependencies
node_modules/
package-lock.json
yarn.lock

# Build outputs
dist/
build/

# IDE
.idea/
.vscode/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# IRIS
*.key
*.dat
*.idx
/durable/

# Environment
.env
.env.local
.env.*.local

# Logs
logs/
*.log
npm-debug.log*

# Test coverage
coverage/
EOF

# 3. Create initial README.md
cat > README.md << 'EOF'
# IRIS AI Hub Studio

A unified AI development platform for InterSystems IRIS, combining:
- 🎯 Generic Agent Test UI for %AI.Agent classes
- 🔌 MCP Data Exposure Toolkit for secure data access
- 🤖 Starter templates for rapid agent development

## Quick Start

```bash
# Start the development environment
docker-compose up -d

# Verify installation
./verify-ai-hub.sh

# Access the platform
open http://localhost:3000
```

## Documentation

- [Project Goals](docs/project/PROJECT-GOALS.md)
- [Implementation Guide](docs/project/IMPLEMENTATION-GUIDE.md)
- [AI Hub Documentation](docs/generic/AI-HUB-OFFICIAL-DOCUMENTATION.md)
- [Docker Setup](docs/DOCKER-SETUP.md)
EOF

# 4. Create initial commit
git add .
git commit -m "Initial project structure and documentation"
```

**Verification**:
- [ ] Git repository initialized
- [ ] .gitignore created
- [ ] README.md created
- [ ] Initial commit made

#### Step 1.3: Set Up Frontend Framework

**Time**: 2-3 hours
**Files**: `src/frontend/package.json`, `src/frontend/tsconfig.json`

```bash
# 1. Navigate to frontend directory
cd src/frontend

# 2. Create package.json
npm init -y

# 3. Install dependencies
npm install react react-dom @types/react @types/react-dom typescript vite @vitejs/plugin-react
npm install @mui/material @emotion/react @emotion/styled @mui/icons-material
npm install axios socket.io-client @modelcontextprotocol/sdk
npm install --save-dev @types/node prettier eslint

# 4. Create tsconfig.json
cat > tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "useDefineForClassFields": true,
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx",
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true,
    "baseUrl": ".",
    "paths": {
      "@/*": ["src/*"]
    }
  },
  "include": ["src"],
  "references": [{ "path": "./tsconfig.node.json" }]
}
EOF

# 5. Create tsconfig.node.json
cat > tsconfig.node.json << 'EOF'
{
  "compilerOptions": {
    "composite": true,
    "skipLibCheck": true,
    "module": "ESNext",
    "moduleResolution": "bundler",
    "allowSyntheticDefaultImports": true
  },
  "include": ["vite.config.ts"]
}
EOF

# 6. Create vite.config.ts
cat > vite.config.ts << 'EOF'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import path from 'path'

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
  server: {
    port: 3000,
    proxy: {
      '/api': {
        target: 'http://localhost:52773',
        changeOrigin: true,
      },
      '/aihub': {
        target: 'http://localhost:52773',
        changeOrigin: true,
      },
    },
  },
})
EOF

# 7. Create index.html
cat > index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <link rel="icon" type="image/svg+xml" href="/vite.svg" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>IRIS AI Hub Studio</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>
EOF

# 8. Create main.tsx
cat > src/main.tsx << 'EOF'
import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App'
import './index.css'

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
)
EOF

# 9. Create index.css
cat > src/index.css << 'EOF'
:root {
  font-family: Inter, system-ui, Avenir, Helvetica, Arial, sans-serif;
  line-height: 1.5;
  font-weight: 400;
  color-scheme: light dark;
  color: rgba(255, 255, 255, 0.87);
  background-color: #242424;
  font-synthesis: none;
  text-rendering: optimizeLegibility;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  margin: 0;
  min-height: 100vh;
}
EOF

# 10. Create App.tsx
cat > src/App.tsx << 'EOF'
import React from 'react';
import { BrowserRouter as Router, Routes, Route, Link } from 'react-router-dom';
import { AppBar, Toolbar, Typography, Container, Box } from '@mui/material';

function App() {
  return (
    <Router>
      <AppBar position="static">
        <Toolbar>
          <Typography variant="h6" component="div" sx={{ flexGrow: 1 }}>
            IRIS AI Hub Studio
          </Typography>
          <Link to="/" style={{ color: 'white', textDecoration: 'none', marginRight: '20px' }}>
            Agent Playground
          </Link>
          <Link to="/data" style={{ color: 'white', textDecoration: 'none', marginRight: '20px' }}>
            Data Explorer
          </Link>
          <Link to="/templates" style={{ color: 'white', textDecoration: 'none' }}>
            Templates
          </Link>
        </Toolbar>
      </AppBar>
      
      <Container maxWidth="xl" sx={{ mt: 4 }}>
        <Routes>
          <Route path="/" element={<div>Agent Playground (Coming Soon)</div>} />
          <Route path="/data" element={<div>Data Explorer (Coming Soon)</div>} />
          <Route path="/templates" element={<div>Template Generator (Coming Soon)</div>} />
        </Routes>
      </Container>
    </Router>
  );
}

export default App;
EOF

# 11. Add scripts to package.json
# Edit package.json and add:
# "scripts": {
#   "dev": "vite",
#   "build": "tsc && vite build",
#   "preview": "vite preview"
# }

# 12. Test the frontend
npm run dev
```

**Verification**:
- [ ] Frontend starts without errors
- [ ] http://localhost:3000 shows basic layout
- [ ] Navigation links work

#### Step 1.4: Set Up Backend Framework

**Time**: 2-3 hours
**Files**: `src/backend/package.json`, `src/backend/server.ts`

```bash
# 1. Navigate to backend directory
cd ../backend

# 2. Create package.json
npm init -y

# 3. Install dependencies
npm install express cors body-parser dotenv
npm install @modelcontextprotocol/sdk socket.io
npm install --save-dev @types/express @types/cors @types/body-parser @types/node typescript ts-node nodemon

# 4. Create tsconfig.json
cat > tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "CommonJS",
    "lib": ["ES2020"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
EOF

# 5. Create server.ts
cat > src/server.ts << 'EOF'
import express from 'express';
import cors from 'cors';
import bodyParser from 'body-parser';
import dotenv from 'dotenv';

// Load environment variables
dotenv.config();

const app = express();
const PORT = process.env.PORT || 3001;

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Agent API placeholder
app.get('/api/agents', (req, res) => {
  // TODO: Implement agent listing
  res.json({ agents: [], message: 'Agent API coming soon' });
});

// MCP API placeholder
app.get('/api/mcp/servers', (req, res) => {
  // TODO: Implement MCP server listing
  res.json({ servers: [], message: 'MCP API coming soon' });
});

// Template API placeholder
app.get('/api/templates', (req, res) => {
  // TODO: Implement template listing
  res.json({ templates: [], message: 'Template API coming soon' });
});

// Start server
app.listen(PORT, () => {
  console.log(`Backend server running on port ${PORT}`);
  console.log(`Health check: http://localhost:${PORT}/api/health`);
});
EOF

# 6. Create .env
cat > .env << 'EOF'
PORT=3001
IRIS_HOST=localhost
IRIS_PORT=52773
IRIS_NAMESPACE=USER
IRIS_USERNAME=_SYSTEM
IRIS_PASSWORD=SYS
EOF

# 7. Add scripts to package.json
# Edit package.json and add:
# "scripts": {
#   "dev": "ts-node src/server.ts",
#   "build": "tsc",
#   "start": "node dist/server.js"
# }

# 8. Test the backend
npm run dev
```

**Verification**:
- [ ] Backend starts without errors
- [ ] http://localhost:3001/api/health returns OK
- [ ] API endpoints respond

#### Step 1.5: Set Up IRIS Package Structure

**Time**: 2-3 hours
**Files**: `src/iris/Package.cls`, `src/iris/cls/AIHub/*.cls`

```objectscript
// src/iris/Package.cls
Class AIHub.Studio.Package Extends %Studio.Project
{
    /// Project name
    Property Name As %String [ InitialExpression = "IRIS AI Hub Studio" ];
    
    /// Version
    Property Version As %String [ InitialExpression = "1.0.0" ];
    
    /// Description
    Property Description As %String [ InitialExpression = "Unified AI development platform for IRIS" ];
    
    /// Dependencies
    Property Dependencies As %List [ MultiDimensional ];
    
    /// Initialize the package
    Method %OnNew() As %Status [ CodeMode = objectgenerator ]
    {
        // Set up dependencies
        Do ..Dependencies.SetAt("AI Hub", "ai-hub")
        
        Quit ##super()
    }
    
    /// Install the package
    ClassMethod Install() As %Status
    {
        // Install dependencies
        Set status = ##class(%ZPM.PackageManager).Shell("INSTALL ai-hub")
        If $$$ISERR(status) {
            Quit status
        }
        
        // Import all classes
        Set status = ##class(%File).ImportDir(
            "/src/iris/cls",
            "/src/iris/cls/**/*.cls",
            1,
            ,
            1
        )
        
        Quit status
    }
    
    /// Uninstall the package
    ClassMethod Uninstall() As %Status
    {
        // Delete all classes
        Set status = ##class(%File).Delete("/src/iris/cls/**/*.cls")
        
        Quit status
    }
}
```

```objectscript
// src/iris/cls/AIHub/AgentManager.cls
Class AIHub.Studio.AgentManager Extends %RegisteredObject
{
    /// List all available agent classes
    ClassMethod ListAgents() As %List
    {
        Set agents = $ListNew()
        Set className = ""
        
        // Find all classes that extend %AI.Agent
        For {
            Set className = $Order(^OddCLASS(className), 1)
            Quit:className = ""
            
            // Check if class extends %AI.Agent
            Try {
                Set classDef = ##class(%Dictionary.ClassDefinition).Open(className)
                If classDef.Super = "%AI.Agent" || 
                   $Find(classDef.Super, "%AI.Agent") > 0 {
                    Do agents.SetAt($Increment(agents.Count()), className)
                }
            } Catch ex {
                // Skip classes that can't be opened
            }
        }
        
        Quit agents
    }
    
    /// Get agent instance
    ClassMethod GetAgent(className As %String) As %AI.Agent
    {
        Try {
            Set agent = $ClassMethod(className, "%New")
            Quit agent
        } Catch ex {
            Write "Error creating agent: ", ex.DisplayString()
            Quit ""
        }
    }
    
    /// Create a new agent from template
    ClassMethod CreateAgentFromTemplate(templateName As %String, agentName As %String) As %AI.Agent
    {
        // TODO: Implement template-based agent creation
        Quit ""
    }
}
```

```objectscript
// src/iris/cls/AIHub/MCP/Bridge.cls
Class AIHub.Studio.MCP.Bridge Extends %RegisteredObject
{
    /// Initialize MCP bridge
    ClassMethod Initialize() As %Status
    {
        // TODO: Initialize MCP bridge
        Quit $$$OK
    }
    
    /// Register MCP server
    ClassMethod RegisterServer(serverName As %String, serverClass As %String) As %Status
    {
        // TODO: Register MCP server
        Quit $$$OK
    }
    
    /// Get MCP data
    ClassMethod GetMCPData(serverName As %String, request As %DynamicObject) As %DynamicObject
    {
        // TODO: Get data from MCP server
        Quit {}
    }
}
```

**Verification**:
- [ ] Package.cls created
- [ ] AgentManager.cls created
- [ ] MCP/Bridge.cls created
- [ ] Classes compile without errors

---

### Day 2: Agent Test UI Foundation

#### Step 2.1: Create Agent Discovery Service

**Time**: 2-3 hours
**Files**: `src/backend/src/services/agentService.ts`

```typescript
// src/backend/src/services/agentService.ts
import axios from 'axios';

const IRIS_BASE_URL = process.env.IRIS_HOST || 'http://localhost:52773';
const IRIS_NAMESPACE = process.env.IRIS_NAMESPACE || 'USER';

interface Agent {
  id: string;
  name: string;
  description: string;
  class: string;
  model: string;
  tools: string[];
  skills: string[];
}

export class AgentService {
  private static instance: AgentService;
  
  private constructor() {}
  
  public static getInstance(): AgentService {
    if (!AgentService.instance) {
      AgentService.instance = new AgentService();
    }
    return AgentService.instance;
  }
  
  async listAgents(): Promise<Agent[]> {
    try {
      // Call IRIS to list agents
      const response = await axios.get(`${IRIS_BASE_URL}/aihub/v1/agents`, {
        headers: {
          'Content-Type': 'application/json',
        },
      });
      
      return response.data.agents || [];
    } catch (error) {
      console.error('Error listing agents:', error);
      // Fallback: Return hardcoded list for development
      return [
        {
          id: 'MyAgent',
          name: 'MyAgent',
          description: 'My first AI agent',
          class: 'MyApp.MyAgent',
          model: 'gpt-4',
          tools: ['Calculator'],
          skills: [],
        },
      ];
    }
  }
  
  async getAgent(agentId: string): Promise<Agent | null> {
    try {
      const response = await axios.get(`${IRIS_BASE_URL}/aihub/v1/agents/${agentId}`);
      return response.data;
    } catch (error) {
      console.error('Error getting agent:', error);
      return null;
    }
  }
  
  async chatWithAgent(agentId: string, message: string, conversationId: string = ''): Promise<any> {
    try {
      const response = await axios.post(`${IRIS_BASE_URL}/aihub/v1/agents/${agentId}/chat`, {
        message,
        conversationId,
      });
      return response.data;
    } catch (error) {
      console.error('Error chatting with agent:', error);
      throw error;
    }
  }
}
```

#### Step 2.2: Create Agent Playground Component

**Time**: 3-4 hours
**Files**: `src/frontend/src/components/AgentPlayground/*.tsx`

```typescript
// src/frontend/src/components/AgentPlayground/AgentSelector.tsx
import React, { useState, useEffect } from 'react';
import { FormControl, InputLabel, Select, MenuItem, SelectChangeEvent } from '@mui/material';
import { AgentService } from '../../services/agentService';

interface Agent {
  id: string;
  name: string;
  description: string;
}

export const AgentSelector: React.FC<{
  selectedAgent: string;
  onSelectAgent: (agentId: string) => void;
}> = ({ selectedAgent, onSelectAgent }) => {
  const [agents, setAgents] = useState<Agent[]>([]);
  const [loading, setLoading] = useState(true);
  
  useEffect(() => {
    const fetchAgents = async () => {
      try {
        const agentService = AgentService.getInstance();
        const agentsList = await agentService.listAgents();
        setAgents(agentsList);
      } catch (error) {
        console.error('Error fetching agents:', error);
      } finally {
        setLoading(false);
      }
    };
    
    fetchAgents();
  }, []);
  
  const handleChange = (event: SelectChangeEvent) => {
    onSelectAgent(event.target.value);
  };
  
  return (
    <FormControl fullWidth>
      <InputLabel id="agent-selector-label">Select Agent</InputLabel>
      <Select
        labelId="agent-selector-label"
        value={selectedAgent}
        label="Select Agent"
        onChange={handleChange}
        disabled={loading}
      >
        {loading ? (
          <MenuItem value="">Loading agents...</MenuItem>
        ) : (
          agents.map((agent) => (
            <MenuItem key={agent.id} value={agent.id}>
              {agent.name}
            </MenuItem>
          ))
        )}
      </Select>
    </FormControl>
  );
};
```

```typescript
// src/frontend/src/components/AgentPlayground/ChatInterface.tsx
import React, { useState, useRef, useEffect } from 'react';
import { Box, TextField, Button, Paper, Typography, CircularProgress } from '@mui/material';
import { AgentService } from '../../services/agentService';

interface Message {
  id: string;
  role: 'user' | 'assistant' | 'system';
  content: string;
  timestamp: Date;
  toolCalls?: any[];
}

interface ChatInterfaceProps {
  agentId: string;
}

export const ChatInterface: React.FC<ChatInterfaceProps> = ({ agentId }) => {
  const [messages, setMessages] = useState<Message[]>([]);
  const [input, setInput] = useState('');
  const [loading, setLoading] = useState(false);
  const messagesEndRef = useRef<HTMLDivElement>(null);
  
  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  };
  
  useEffect(() => {
    scrollToBottom();
  }, [messages]);
  
  const handleSend = async () => {
    if (!input.trim() || !agentId) return;
    
    const userMessage: Message = {
      id: `msg-${Date.now()}`,
      role: 'user',
      content: input.trim(),
      timestamp: new Date(),
    };
    
    setMessages((prev) => [...prev, userMessage]);
    setInput('');
    setLoading(true);
    
    try {
      const agentService = AgentService.getInstance();
      const response = await agentService.chatWithAgent(agentId, userMessage.content);
      
      const assistantMessage: Message = {
        id: `msg-${Date.now() + 1}`,
        role: 'assistant',
        content: response.content || 'No response',
        timestamp: new Date(),
        toolCalls: response.toolCalls,
      };
      
      setMessages((prev) => [...prev, assistantMessage]);
    } catch (error) {
      console.error('Error:', error);
      const errorMessage: Message = {
        id: `msg-${Date.now() + 1}`,
        role: 'system',
        content: 'Error: Could not get response from agent',
        timestamp: new Date(),
      };
      setMessages((prev) => [...prev, errorMessage]);
    } finally {
      setLoading(false);
    }
  };
  
  const handleKeyPress = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      handleSend();
    }
  };
  
  return (
    <Box sx={{ display: 'flex', flexDirection: 'column', height: '100%', gap: 2 }}>
      <Paper sx={{ flex: 1, overflow: 'auto', p: 2 }}>
        {messages.length === 0 ? (
          <Typography variant="body1" color="text.secondary" sx={{ textAlign: 'center', py: 4 }}>
            Select an agent and start chatting!
          </Typography>
        ) : (
          messages.map((message) => (
            <Box
              key={message.id}
              sx={{
                mb: 2,
                display: 'flex',
                justifyContent: message.role === 'user' ? 'flex-end' : 'flex-start',
              }}
            >
              <Paper
                sx={{
                  p: 2,
                  maxWidth: '80%',
                  backgroundColor: message.role === 'user' ? 'primary.light' : 'background.paper',
                }}
              >
                <Typography variant="body1">{message.content}</Typography>
                {message.toolCalls && message.toolCalls.length > 0 && (
                  <Box sx={{ mt: 1, pl: 2, borderLeft: '2px solid', borderColor: 'divider' }}>
                    <Typography variant="caption" color="text.secondary">
                      Tool Calls:
                    </Typography>
                    {message.toolCalls.map((toolCall: any, index: number) => (
                      <Typography key={index} variant="body2" sx={{ ml: 2 }}>
                        - {toolCall.tool}: {JSON.stringify(toolCall.input)}
                      </Typography>
                    ))}
                  </Box>
                )}
              </Paper>
            </Box>
          ))
        )}
        <div ref={messagesEndRef} />
      </Paper>
      
      <Box sx={{ display: 'flex', gap: 2 }}>
        <TextField
          fullWidth
          variant="outlined"
          placeholder="Type your message..."
          value={input}
          onChange={(e) => setInput(e.target.value)}
          onKeyPress={handleKeyPress}
          disabled={loading || !agentId}
          multiline
          maxRows={4}
        />
        <Button
          variant="contained"
          onClick={handleSend}
          disabled={loading || !input.trim() || !agentId}
          sx={{ height: '100%' }}
        >
          {loading ? <CircularProgress size={24} /> : 'Send'}
        </Button>
      </Box>
    </Box>
  );
};
```

```typescript
// src/frontend/src/components/AgentPlayground/index.tsx
import React, { useState } from 'react';
import { Box, Paper, Typography } from '@mui/material';
import { AgentSelector } from './AgentSelector';
import { ChatInterface } from './ChatInterface';

export const AgentPlayground: React.FC = () => {
  const [selectedAgent, setSelectedAgent] = useState('');
  
  return (
    <Box sx={{ display: 'flex', flexDirection: 'column', height: '100%', gap: 2 }}>
      <Typography variant="h4" gutterBottom>
        Agent Playground
      </Typography>
      
      <Paper sx={{ p: 2 }}>
        <AgentSelector
          selectedAgent={selectedAgent}
          onSelectAgent={setSelectedAgent}
        />
      </Paper>
      
      <Paper sx={{ flex: 1, p: 2 }}>
        <ChatInterface agentId={selectedAgent} />
      </Paper>
    </Box>
  );
};
```

#### Step 2.3: Update App.tsx to Use Agent Playground

```typescript
// Update src/frontend/src/App.tsx
import React from 'react';
import { BrowserRouter as Router, Routes, Route, Link } from 'react-router-dom';
import { AppBar, Toolbar, Typography, Container, Box } from '@mui/material';
import { AgentPlayground } from './components/AgentPlayground';

function App() {
  return (
    <Router>
      <AppBar position="static">
        <Toolbar>
          <Typography variant="h6" component="div" sx={{ flexGrow: 1 }}>
            IRIS AI Hub Studio
          </Typography>
          <Link to="/" style={{ color: 'white', textDecoration: 'none', marginRight: '20px' }}>
            Agent Playground
          </Link>
          <Link to="/data" style={{ color: 'white', textDecoration: 'none', marginRight: '20px' }}>
            Data Explorer
          </Link>
          <Link to="/templates" style={{ color: 'white', textDecoration: 'none' }}>
            Templates
          </Link>
        </Toolbar>
      </AppBar>
      
      <Container maxWidth="xl" sx={{ mt: 4, height: 'calc(100vh - 64px)' }}>
        <Routes>
          <Route path="/" element={<AgentPlayground />} />
          <Route path="/data" element={<div>Data Explorer (Coming Soon)</div>} />
          <Route path="/templates" element={<div>Template Generator (Coming Soon)</div>} />
        </Routes>
      </Container>
    </Router>
  );
}

export default App;
```

#### Step 2.4: Create Backend API for Agents

```typescript
// src/backend/src/routes/agents.ts
import express from 'express';
import { AgentService } from '../services/agentService';

const router = express.Router();
const agentService = AgentService.getInstance();

// List all agents
router.get('/', async (req, res) => {
  try {
    const agents = await agentService.listAgents();
    res.json({ agents, count: agents.length });
  } catch (error) {
    console.error('Error listing agents:', error);
    res.status(500).json({ error: 'Failed to list agents' });
  }
});

// Get specific agent
router.get('/:agentId', async (req, res) => {
  try {
    const { agentId } = req.params;
    const agent = await agentService.getAgent(agentId);
    
    if (!agent) {
      return res.status(404).json({ error: 'Agent not found' });
    }
    
    res.json(agent);
  } catch (error) {
    console.error('Error getting agent:', error);
    res.status(500).json({ error: 'Failed to get agent' });
  }
});

// Chat with agent
router.post('/:agentId/chat', async (req, res) => {
  try {
    const { agentId } = req.params;
    const { message, conversationId } = req.body;
    
    if (!message) {
      return res.status(400).json({ error: 'Message is required' });
    }
    
    const response = await agentService.chatWithAgent(agentId, message, conversationId);
    res.json(response);
  } catch (error) {
    console.error('Error chatting with agent:', error);
    res.status(500).json({ error: 'Failed to chat with agent' });
  }
});

export default router;
```

```typescript
// Update src/backend/src/server.ts
import express from 'express';
import cors from 'cors';
import bodyParser from 'body-parser';
import dotenv from 'dotenv';
import agentsRouter from './routes/agents';

// ... existing code ...

// Mount routes
app.use('/api/agents', agentsRouter);

// ... rest of the file ...
```

**Verification**:
- [ ] AgentSelector component works
- [ ] ChatInterface component works
- [ ] Agent Playground integrated into App
- [ ] Backend agent API works
- [ ] Can select agent and see chat interface

---

### Day 3: MCP Toolkit Foundation

#### Step 3.1: Create MCP Service

**Time**: 2-3 hours
**Files**: `src/backend/src/services/mcpService.ts`

```typescript
// src/backend/src/services/mcpService.ts
import axios from 'axios';

const IRIS_BASE_URL = process.env.IRIS_HOST || 'http://localhost:52773';

interface MCPServer {
  id: string;
  name: string;
  description: string;
  class: string;
  connectors: any[];
  tools: any[];
  resources: any[];
}

interface MCPResource {
  uri: string;
  name: string;
  description: string;
  mimeType: string;
}

export class MCPService {
  private static instance: MCPService;
  
  private constructor() {}
  
  public static getInstance(): MCPService {
    if (!MCPService.instance) {
      MCPService.instance = new MCPService();
    }
    return MCPService.instance;
  }
  
  async listServers(): Promise<MCPServer[]> {
    try {
      const response = await axios.get(`${IRIS_BASE_URL}/aihub/v1/mcp/servers`);
      return response.data.servers || [];
    } catch (error) {
      console.error('Error listing MCP servers:', error);
      return [];
    }
  }
  
  async listResources(serverId: string): Promise<MCPResource[]> {
    try {
      const response = await axios.get(`${IRIS_BASE_URL}/aihub/v1/mcp/servers/${serverId}/resources`);
      return response.data.resources || [];
    } catch (error) {
      console.error('Error listing resources:', error);
      return [];
    }
  }
  
  async readResource(serverId: string, resourceUri: string): Promise<any> {
    try {
      const response = await axios.get(
        `${IRIS_BASE_URL}/aihub/v1/mcp/servers/${serverId}/resources/${encodeURIComponent(resourceUri)}`
      );
      return response.data;
    } catch (error) {
      console.error('Error reading resource:', error);
      throw error;
    }
  }
  
  async callTool(serverId: string, toolName: string, arguments: any): Promise<any> {
    try {
      const response = await axios.post(
        `${IRIS_BASE_URL}/aihub/v1/mcp/servers/${serverId}/tools/${toolName}/call`,
        { arguments }
      );
      return response.data;
    } catch (error) {
      console.error('Error calling tool:', error);
      throw error;
    }
  }
}
```

#### Step 3.2: Create IRIS MCP Bridge

**Time**: 3-4 hours
**Files**: `src/iris/cls/AIHub/MCP/*.cls`

```objectscript
// src/iris/cls/AIHub/MCP/Server.cls
Class AIHub.Studio.MCP.Server Extends %AI.MCP.Server
{
    Property Name As %String [ InitialExpression = "AIHubStudioServer" ];
    Property Description As %String [ InitialExpression = "MCP Server for AI Hub Studio" ];
    
    Method %OnNew() As %Status [ CodeMode = objectgenerator ]
    {
        // Set up server properties
        Set ..Name = "AIHubStudioServer"
        Set ..Description = "MCP Server for AI Hub Studio - Exposes IRIS data for the platform"
        
        // Add connectors
        Do ..AddConnector(##class(AIHub.Studio.MCP.GlobalConnector).%New())
        Do ..AddConnector(##class(AIHub.Studio.MCP.SQLConnector).%New())
        Do ..AddConnector(##class(AIHub.Studio.MCP.DocDBConnector).%New())
        
        Quit ##super()
    }
    
    Method Initialize() As %Status
    {
        // Initialize all connectors
        For i = 1:1:..Connectors.Count() {
            Set connector = ..Connectors.GetAt(i)
            Set status = connector.Initialize()
            If $$$ISERR(status) {
                Quit status
            }
        }
        
        Quit $$$OK
    }
}
```

```objectscript
// src/iris/cls/AIHub/MCP/GlobalConnector.cls
Class AIHub.Studio.MCP.GlobalConnector Extends %AI.MCP.Connector.Global
{
    Property Name As %String [ InitialExpression = "GlobalConnector" ];
    Property Description As %String [ InitialExpression = "Exposes IRIS global storage via MCP" ];
    Property GlobalName As %String [ InitialExpression = "^AIHub.Studio.Data" ];
    
    Method %OnNew() As %Status [ CodeMode = objectgenerator ]
    {
        Set ..Name = "GlobalConnector"
        Set ..Description = "Exposes IRIS global storage via MCP"
        Quit ##super()
    }
    
    Method Initialize() As %Status
    {
        // Create resource for the global
        Set resource = ##class(%AI.MCP.Resource).%New()
        Set resource.URI = "global://AIHub.Studio.Data"
        Set resource.Name = "AI Hub Studio Data"
        Set resource.Description = "Global storage for AI Hub Studio"
        Set resource.MimeType = "application/json"
        
        // Add to parent server
        Set server = $Get(..%Parent)
        If server '= "" {
            Do server.AddResource(resource)
        }
        
        Quit $$$OK
    }
    
    Method HandleRequest(request As %DynamicObject) As %DynamicObject
    {
        Set action = request.action
        Set subscripts = $Get(request.subscripts, $ListNew())
        
        // Build global reference
        Set globalRef = ..GlobalName
        For i = 1:1:subscripts.Count() {
            Set globalRef = globalRef _ "("_ subscripts.GetAt(i) _ ")"
        }
        
        If action = "read" {
            Set value = $Get(@globalRef)
            Quit {"action": "read", "value": value, "exists": '$Data(@globalRef)}
        }
        
        If action = "list" {
            Set results = []
            Set subscript = ""
            For {
                Set subscript = $Order(@globalRef@(subscript), 1)
                Quit:subscript = ""
                Do results.Push(subscript)
            }
            Quit {"action": "list", "subscripts": results}
        }
        
        If action = "write" {
            Set @globalRef = request.value
            Quit {"action": "write", "success": 1}
        }
        
        If action = "delete" {
            Kill @globalRef
            Quit {"action": "delete", "success": 1}
        }
        
        Quit {"error": "Unknown action: " _ action}
    }
}
```

```objectscript
// src/iris/cls/AIHub/MCP/SQLConnector.cls
Class AIHub.Studio.MCP.SQLConnector Extends %AI.MCP.Connector.SQL
{
    Property Name As %String [ InitialExpression = "SQLConnector" ];
    Property Description As %String [ InitialExpression = "Exposes SQL tables via MCP" ];
    Property Namespace As %String [ InitialExpression = "USER" ];
    Property TableName As %String;
    
    Method %OnNew() As %Status [ CodeMode = objectgenerator ]
    {
        Set ..Name = "SQLConnector"
        Set ..Description = "Exposes SQL tables via MCP"
        Quit ##super()
    }
    
    Method Initialize() As %Status
    {
        // This will be called with specific table name
        // For now, just initialize base functionality
        Quit $$$OK
    }
    
    Method HandleRequest(request As %DynamicObject) As %DynamicObject
    {
        Set action = request.action
        Set query = $Get(request.query, "")
        
        If action = "query" {
            Set stmt = ##class(%SQL.Statement).%New()
            Set stmt.Namespace = ..Namespace
            
            // Execute query
            Set rs = stmt.%ExecDirect(, query)
            
            // Convert to JSON
            Set results = []
            While rs.%Next() {
                Set row = {}
                For i = 1:1:rs.%ColumnCount() {
                    Set colName = rs.%ColumnName(i)
                    Set row(colName) = rs.%Get(colName)
                }
                Do results.Push(row)
            }
            
            Quit {"action": "query", "results": results, "rowCount": $Length(results)}
        }
        
        If action = "schema" {
            // Get table schema
            Set stmt = ##class(%SQL.Statement).%New()
            Set stmt.Namespace = ..Namespace
            
            // Get column information
            Set rs = stmt.%ExecDirect(, "SELECT * FROM " _ ..TableName _ " WHERE 1=0")
            
            Set schema = {
                "table": ..TableName,
                "columns": []
            }
            
            For i = 1:1:rs.%ColumnCount() {
                Do schema.columns.Push({
                    "name": rs.%ColumnName(i),
                    "type": rs.%ColumnType(i),
                    "size": rs.%ColumnSize(i)
                })
            }
            
            Quit schema
        }
        
        Quit {"error": "Unknown action: " _ action}
    }
}
```

```objectscript
// src/iris/cls/AIHub/MCP/DocDBConnector.cls
Class AIHub.Studio.MCP.DocDBConnector Extends %AI.MCP.Connector.DocDB
{
    Property Name As %String [ InitialExpression = "DocDBConnector" ];
    Property Description As %String [ InitialExpression = "Exposes Document Database collections via MCP" ];
    Property Namespace As %String [ InitialExpression = "USER" ];
    Property CollectionName As %String;
    
    Method %OnNew() As %Status [ CodeMode = objectgenerator ]
    {
        Set ..Name = "DocDBConnector"
        Set ..Description = "Exposes Document Database collections via MCP"
        Quit ##super()
    }
    
    Method Initialize() As %Status
    {
        Quit $$$OK
    }
    
    Method HandleRequest(request As %DynamicObject) As %DynamicObject
    {
        Set action = request.action
        Set query = $Get(request.query, {})
        
        If action = "query" {
            // Query documents
            Set className = ..CollectionName
            
            // Use dynamic SQL to query documents
            Set stmt = ##class(%SQL.Statement).%New()
            Set stmt.Namespace = ..Namespace
            
            // Build query
            Set sql = "SELECT * FROM " _ className
            Set conditions = ""
            For key = "":query.%Next(.key) {
                If conditions '= "" {
                    Set conditions = conditions _ " AND "
                }
                Set conditions = conditions _ key _ " = :" _ key
            }
            
            If conditions '= "" {
                Set sql = sql _ " WHERE " _ conditions
            }
            
            // Prepare and execute
            Set rs = stmt.%Prepare(sql)
            For key = "":query.%Next(.key) {
                Do stmt.%Bind(key, query(key))
            }
            Set rs = stmt.%Execute()
            
            // Convert to JSON
            Set results = []
            While rs.%Next() {
                Set doc = rs.%Get("Document")
                Do results.Push(doc)
            }
            
            Quit {"action": "query", "documents": results, "count": $Length(results)}
        }
        
        Quit {"error": "Unknown action: " _ action}
    }
}
```

#### Step 3.3: Create MCP Backend API

```typescript
// src/backend/src/routes/mcp.ts
import express from 'express';
import { MCPService } from '../services/mcpService';

const router = express.Router();
const mcpService = MCPService.getInstance();

// List all MCP servers
router.get('/servers', async (req, res) => {
  try {
    const servers = await mcpService.listServers();
    res.json({ servers, count: servers.length });
  } catch (error) {
    console.error('Error listing MCP servers:', error);
    res.status(500).json({ error: 'Failed to list MCP servers' });
  }
});

// List resources for a server
router.get('/servers/:serverId/resources', async (req, res) => {
  try {
    const { serverId } = req.params;
    const resources = await mcpService.listResources(serverId);
    res.json({ resources, count: resources.length });
  } catch (error) {
    console.error('Error listing resources:', error);
    res.status(500).json({ error: 'Failed to list resources' });
  }
});

// Read a resource
router.get('/servers/:serverId/resources/:resourceUri', async (req, res) => {
  try {
    const { serverId, resourceUri } = req.params;
    const data = await mcpService.readResource(serverId, decodeURIComponent(resourceUri));
    res.json(data);
  } catch (error) {
    console.error('Error reading resource:', error);
    res.status(500).json({ error: 'Failed to read resource' });
  }
});

// Call a tool
router.post('/servers/:serverId/tools/:toolName/call', async (req, res) => {
  try {
    const { serverId, toolName } = req.params;
    const { arguments: args } = req.body;
    const result = await mcpService.callTool(serverId, toolName, args);
    res.json(result);
  } catch (error) {
    console.error('Error calling tool:', error);
    res.status(500).json({ error: 'Failed to call tool' });
  }
});

export default router;
```

```typescript
// Update src/backend/src/server.ts
import agentsRouter from './routes/agents';
import mcpRouter from './routes/mcp';

// ... existing code ...

// Mount routes
app.use('/api/agents', agentsRouter);
app.use('/api/mcp', mcpRouter);

// ... rest of the file ...
```

#### Step 3.4: Create Data Explorer Component

```typescript
// src/frontend/src/components/DataExplorer/index.tsx
import React, { useState, useEffect } from 'react';
import { Box, Paper, Typography, List, ListItem, ListItemButton, ListItemText, CircularProgress } from '@mui/material';
import { MCPService } from '../../services/mcpService';

interface MCPServer {
  id: string;
  name: string;
  description: string;
}

interface MCPResource {
  uri: string;
  name: string;
  description: string;
  mimeType: string;
}

export const DataExplorer: React.FC = () => {
  const [servers, setServers] = useState<MCPServer[]>([]);
  const [selectedServer, setSelectedServer] = useState<string>('');
  const [resources, setResources] = useState<MCPResource[]>([]);
  const [loading, setLoading] = useState(true);
  const [loadingResources, setLoadingResources] = useState(false);
  const [selectedResource, setSelectedResource] = useState<string>('');
  const [resourceData, setResourceData] = useState<any>(null);
  
  useEffect(() => {
    const fetchServers = async () => {
      try {
        const mcpService = MCPService.getInstance();
        const serversList = await mcpService.listServers();
        setServers(serversList);
      } catch (error) {
        console.error('Error fetching servers:', error);
      } finally {
        setLoading(false);
      }
    };
    
    fetchServers();
  }, []);
  
  useEffect(() => {
    if (!selectedServer) return;
    
    const fetchResources = async () => {
      setLoadingResources(true);
      try {
        const mcpService = MCPService.getInstance();
        const resourcesList = await mcpService.listResources(selectedServer);
        setResources(resourcesList);
      } catch (error) {
        console.error('Error fetching resources:', error);
      } finally {
        setLoadingResources(false);
      }
    };
    
    fetchResources();
  }, [selectedServer]);
  
  useEffect(() => {
    if (!selectedServer || !selectedResource) return;
    
    const fetchResourceData = async () => {
      try {
        const mcpService = MCPService.getInstance();
        const data = await mcpService.readResource(selectedServer, selectedResource);
        setResourceData(data);
      } catch (error) {
        console.error('Error fetching resource data:', error);
        setResourceData({ error: 'Failed to load resource data' });
      }
    };
    
    fetchResourceData();
  }, [selectedServer, selectedResource]);
  
  return (
    <Box sx={{ display: 'flex', height: '100%', gap: 2 }}>
      {/* Server List */}
      <Paper sx={{ width: 250, overflow: 'auto' }}>
        <Typography variant="h6" sx={{ p: 2 }}>MCP Servers</Typography>
        {loading ? (
          <CircularProgress sx={{ m: 2 }} />
        ) : (
          <List>
            {servers.map((server) => (
              <ListItem key={server.id} disablePadding>
                <ListItemButton
                  selected={selectedServer === server.id}
                  onClick={() => setSelectedServer(server.id)}
                >
                  <ListItemText primary={server.name} secondary={server.description} />
                </ListItemButton>
              </ListItem>
            ))}
          </List>
        )}
      </Paper>
      
      {/* Resource List */}
      <Paper sx={{ width: 300, overflow: 'auto' }}>
        <Typography variant="h6" sx={{ p: 2 }}>Resources</Typography>
        {loadingResources ? (
          <CircularProgress sx={{ m: 2 }} />
        ) : selectedServer ? (
          <List>
            {resources.map((resource) => (
              <ListItem key={resource.uri} disablePadding>
                <ListItemButton
                  selected={selectedResource === resource.uri}
                  onClick={() => setSelectedResource(resource.uri)}
                >
                  <ListItemText primary={resource.name} secondary={resource.uri} />
                </ListItemButton>
              </ListItem>
            ))}
          </List>
        ) : (
          <Typography variant="body2" sx={{ p: 2, color: 'text.secondary' }}>
            Select a server to view resources
          </Typography>
        )}
      </Paper>
      
      {/* Resource Data */}
      <Paper sx={{ flex: 1, overflow: 'auto', p: 2 }}>
        <Typography variant="h6" gutterBottom>Resource Data</Typography>
        {selectedResource ? (
          <Box sx={{ whiteSpace: 'pre-wrap', fontFamily: 'monospace' }}>
            {resourceData ? (
              <pre>{JSON.stringify(resourceData, null, 2)}</pre>
            ) : (
              <Typography variant="body2" color="text.secondary">
                Select a resource to view data
              </Typography>
            )}
          </Box>
        ) : (
          <Typography variant="body2" color="text.secondary">
            Select a server and resource to view data
          </Typography>
        )}
      </Paper>
    </Box>
  );
};
```

```typescript
// Update src/frontend/src/App.tsx
import { AgentPlayground } from './components/AgentPlayground';
import { DataExplorer } from './components/DataExplorer';

// ... existing imports ...

function App() {
  return (
    <Router>
      {/* ... existing AppBar ... */}
      
      <Container maxWidth="xl" sx={{ mt: 4, height: 'calc(100vh - 64px)' }}>
        <Routes>
          <Route path="/" element={<AgentPlayground />} />
          <Route path="/data" element={<DataExplorer />} />
          <Route path="/templates" element={<div>Template Generator (Coming Soon)</div>} />
        </Routes>
      </Container>
    </Router>
  );
}
```

**Verification**:
- [ ] MCP Service created
- [ ] IRIS MCP connectors created (Global, SQL, DocDB)
- [ ] MCP backend API created
- [ ] Data Explorer component works
- [ ] Can view MCP servers and resources

---

### Day 4: Template Generator Foundation

#### Step 4.1: Create Template Service

**Time**: 2-3 hours
**Files**: `src/backend/src/services/templateService.ts`

```typescript
// src/backend/src/services/templateService.ts
import fs from 'fs';
import path from 'path';

interface AgentTemplate {
  id: string;
  name: string;
  description: string;
  category: string;
  className: string;
  filePath: string;
  config: any;
}

export class TemplateService {
  private static instance: TemplateService;
  private templates: AgentTemplate[] = [];
  private templatesDir: string;
  
  private constructor() {
    this.templatesDir = path.join(__dirname, '../../../templates/agent-templates');
    this.loadTemplates();
  }
  
  public static getInstance(): TemplateService {
    if (!TemplateService.instance) {
      TemplateService.instance = new TemplateService();
    }
    return TemplateService.instance;
  }
  
  private loadTemplates(): void {
    try {
      const templateDirs = fs.readdirSync(this.templatesDir);
      
      for (const dir of templateDirs) {
        const templatePath = path.join(this.templatesDir, dir);
        const stat = fs.statSync(templatePath);
        
        if (!stat.isDirectory()) continue;
        
        const manifestPath = path.join(templatePath, 'template.json');
        if (!fs.existsSync(manifestPath)) continue;
        
        const manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));
        
        this.templates.push({
          id: dir,
          name: manifest.name || dir,
          description: manifest.description || '',
          category: manifest.category || 'general',
          className: manifest.className || `MyApp.Agents.${dir}`,
          filePath: templatePath,
          config: manifest.config || {},
        });
      }
    } catch (error) {
      console.error('Error loading templates:', error);
    }
  }
  
  listTemplates(): AgentTemplate[] {
    return this.templates;
  }
  
  getTemplate(templateId: string): AgentTemplate | null {
    return this.templates.find(t => t.id === templateId) || null;
  }
  
  async generateAgent(templateId: string, agentName: string, config: any = {}): Promise<string> {
    const template = this.getTemplate(templateId);
    if (!template) {
      throw new Error(`Template not found: ${templateId}`);
    }
    
    // Generate agent class from template
    const className = agentName || template.className;
    const outputPath = path.join(__dirname, '../../../src/iris/cls', className.split('.').join('/') + '.cls');
    
    // Ensure directory exists
    const outputDir = path.dirname(outputPath);
    if (!fs.existsSync(outputDir)) {
      fs.mkdirSync(outputDir, { recursive: true });
    }
    
    // Copy template files
    this.copyTemplateFiles(template.filePath, outputDir, className, config);
    
    return className;
  }
  
  private copyTemplateFiles(sourceDir: string, targetDir: string, className: string, config: any): void {
    const files = fs.readdirSync(sourceDir);
    
    for (const file of files) {
      const sourcePath = path.join(sourceDir, file);
      const stat = fs.statSync(sourcePath);
      
      if (stat.isDirectory()) {
        const targetSubDir = path.join(targetDir, file);
        if (!fs.existsSync(targetSubDir)) {
          fs.mkdirSync(targetSubDir, { recursive: true });
        }
        this.copyTemplateFiles(sourcePath, targetSubDir, className, config);
      } else {
        // Process template files
        let content = fs.readFileSync(sourcePath, 'utf8');
        
        // Replace placeholders
        content = content.replace(/{{CLASS_NAME}}/g, className);
        content = content.replace(/{{AGENT_NAME}}/g, className.split('.').pop() || className);
        
        // Replace config placeholders
        for (const [key, value] of Object.entries(config)) {
          content = content.replace(new RegExp(`{{CONFIG.${key}}}`, 'g'), JSON.stringify(value));
        }
        
        // Write to target
        const targetPath = path.join(targetDir, file);
        fs.writeFileSync(targetPath, content);
      }
    }
  }
}
```

#### Step 4.2: Create Basic Agent Templates

**Time**: 2-3 hours
**Files**: `templates/agent-templates/basic-agent/*`

```bash
# Create template directory structure
mkdir -p templates/agent-templates/basic-agent
mkdir -p templates/agent-templates/data-analyst-agent
mkdir -p templates/agent-templates/healthcare-agent
```

```json
// templates/agent-templates/basic-agent/template.json
{
  "name": "Basic Agent",
  "description": "A minimal AI agent with basic chat functionality",
  "category": "starter",
  "className": "MyApp.Agents.BasicAgent",
  "config": {
    "model": "gpt-4",
    "temperature": 0.7,
    "maxTokens": 4000
  }
}
```

```objectscript
// templates/agent-templates/basic-agent/BasicAgent.cls
Class {{CLASS_NAME}} Extends %AI.Agent
{
    Property Name As %String [ InitialExpression = "{{AGENT_NAME}}" ];
    Property Description As %String [ InitialExpression = "A basic AI agent for general purposes" ];
    
    Method %OnNew() As %Status [ CodeMode = objectgenerator ]
    {
        Set ..Name = "{{AGENT_NAME}}"
        Set ..Description = "A basic AI agent for general purposes"
        Set ..Model = "{{CONFIG.model}}"
        Set ..Temperature = {{CONFIG.temperature}}
        Set ..MaxTokens = {{CONFIG.maxTokens}}
        Set ..SystemPrompt = "You are a helpful AI assistant. Be concise and accurate in your responses."
        
        Quit ##super()
    }
}
```

```json
// templates/agent-templates/data-analyst-agent/template.json
{
  "name": "Data Analyst Agent",
  "description": "An agent specialized in data analysis with tools for querying and processing data",
  "category": "specialized",
  "className": "MyApp.Agents.DataAnalystAgent",
  "config": {
    "model": "gpt-4",
    "temperature": 0.3,
    "maxTokens": 4000,
    "tools": ["DataQuery", "Calculator"],
    "skills": ["DataAnalysis"]
  }
}
```

```objectscript
// templates/agent-templates/data-analyst-agent/DataAnalystAgent.cls
Class {{CLASS_NAME}} Extends %AI.Agent
{
    Property Name As %String [ InitialExpression = "{{AGENT_NAME}}" ];
    Property Description As %String [ InitialExpression = "An agent specialized in data analysis" ];
    
    Method %OnNew() As %Status [ CodeMode = objectgenerator ]
    {
        Set ..Name = "{{AGENT_NAME}}"
        Set ..Description = "An agent specialized in data analysis"
        Set ..Model = "{{CONFIG.model}}"
        Set ..Temperature = {{CONFIG.temperature}}
        Set ..MaxTokens = {{CONFIG.maxTokens}}
        Set ..SystemPrompt = "You are a data analyst AI assistant. Use the available tools to analyze data and provide insights. Always show your work and explain your reasoning."
        
        // Add tools
        Do ..AddTool("DataQuery", "MyApp.Tools.DataQuery")
        Do ..AddTool("Calculator", "MyApp.Tools.Calculator")
        
        // Add skills
        Do ..AddSkill("DataAnalysis", "MyApp.Skills.DataAnalysis")
        
        Quit ##super()
    }
    
    /// Custom method for data analysis
    Method AnalyzeData(query As %String) As %DynamicObject
    {
        // Use tools to execute data query
        Set result = ..ExecuteTool("DataQuery", {"query": query})
        
        // Use agent to interpret results
        Set interpretation = ..Chat("Based on these data results: " _ $Replace(result, """, " ") _ 
                          ", provide analysis and insights.")
        
        Quit {
            "data": result,
            "analysis": interpretation
        }
    }
}
```

#### Step 4.3: Create Template Generator Component

```typescript
// src/frontend/src/components/TemplateGenerator/index.tsx
import React, { useState, useEffect } from 'react';
import { Box, Paper, Typography, List, ListItem, ListItemButton, ListItemText, Button, Dialog, DialogTitle, DialogContent, DialogActions, TextField, CircularProgress } from '@mui/material';
import { TemplateService } from '../../services/templateService';

interface AgentTemplate {
  id: string;
  name: string;
  description: string;
  category: string;
}

export const TemplateGenerator: React.FC = () => {
  const [templates, setTemplates] = useState<AgentTemplate[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedTemplate, setSelectedTemplate] = useState<string>('');
  const [openDialog, setOpenDialog] = useState(false);
  const [agentName, setAgentName] = useState('');
  const [generating, setGenerating] = useState(false);
  const [generatedClass, setGeneratedClass] = useState('');
  
  useEffect(() => {
    const fetchTemplates = async () => {
      try {
        const templateService = TemplateService.getInstance();
        const templatesList = templateService.listTemplates();
        setTemplates(templatesList);
      } catch (error) {
        console.error('Error fetching templates:', error);
      } finally {
        setLoading(false);
      }
    };
    
    fetchTemplates();
  }, []);
  
  const handleGenerate = async () => {
    if (!selectedTemplate || !agentName) return;
    
    setGenerating(true);
    try {
      const templateService = TemplateService.getInstance();
      const className = await templateService.generateAgent(
        selectedTemplate,
        agentName,
        {} // Default config
      );
      setGeneratedClass(className);
      setOpenDialog(false);
      setAgentName('');
      setSelectedTemplate('');
    } catch (error) {
      console.error('Error generating agent:', error);
    } finally {
      setGenerating(false);
    }
  };
  
  const handleCloseDialog = () => {
    setOpenDialog(false);
    setAgentName('');
  };
  
  const handleOpenDialog = (templateId: string) => {
    setSelectedTemplate(templateId);
    setAgentName(`MyApp.Agents.${templateId.split('-').map(w => w.charAt(0).toUpperCase() + w.slice(1)).join('')}`);
    setOpenDialog(true);
  };
  
  return (
    <Box sx={{ display: 'flex', flexDirection: 'column', height: '100%', gap: 2 }}>
      <Typography variant="h4" gutterBottom>
        Template Generator
      </Typography>
      
      <Typography variant="body1" paragraph>
        Select a template to create a new AI agent with pre-configured tools, skills, and settings.
      </Typography>
      
      <Paper sx={{ flex: 1, overflow: 'auto' }}>
        {loading ? (
          <CircularProgress sx={{ m: 4 }} />
        ) : (
          <List>
            {templates.map((template) => (
              <ListItem key={template.id} disablePadding>
                <ListItemButton onClick={() => handleOpenDialog(template.id)}>
                  <ListItemText
                    primary={template.name}
                    secondary={template.description}
                  />
                </ListItemButton>
              </ListItem>
            ))}
          </List>
        )}
      </Paper>
      
      {generatedClass && (
        <Paper sx={{ p: 2, backgroundColor: 'success.light' }}>
          <Typography variant="body1">
            ✅ Agent generated: {generatedClass}
          </Typography>
          <Typography variant="body2" color="text.secondary">
            The agent class has been created in src/iris/cls/. You can now use it in the Agent Playground.
          </Typography>
        </Paper>
      )}
      
      {/* Generate Agent Dialog */}
      <Dialog open={openDialog} onClose={handleCloseDialog}>
        <DialogTitle>Generate Agent from Template</DialogTitle>
        <DialogContent>
          <Typography variant="body1" gutterBottom>
            Template: {templates.find(t => t.id === selectedTemplate)?.name}
          </Typography>
          <TextField
            autoFocus
            margin="dense"
            label="Agent Class Name"
            fullWidth
            value={agentName}
            onChange={(e) => setAgentName(e.target.value)}
            helperText="Enter the full class name (e.g., MyApp.Agents.MyAgent)"
          />
        </DialogContent>
        <DialogActions>
          <Button onClick={handleCloseDialog} disabled={generating}>
            Cancel
          </Button>
          <Button
            onClick={handleGenerate}
            disabled={generating || !agentName}
            variant="contained"
            color="primary"
          >
            {generating ? <CircularProgress size={24} /> : 'Generate'}
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
};
```

```typescript
// Update src/frontend/src/App.tsx
import { TemplateGenerator } from './components/TemplateGenerator';

// ... existing code ...

function App() {
  return (
    <Router>
      {/* ... existing AppBar ... */}
      
      <Container maxWidth="xl" sx={{ mt: 4, height: 'calc(100vh - 64px)' }}>
        <Routes>
          <Route path="/" element={<AgentPlayground />} />
          <Route path="/data" element={<DataExplorer />} />
          <Route path="/templates" element={<TemplateGenerator />} />
        </Routes>
      </Container>
    </Router>
  );
}
```

#### Step 4.4: Create Template Backend API

```typescript
// src/backend/src/routes/templates.ts
import express from 'express';
import { TemplateService } from '../services/templateService';

const router = express.Router();
const templateService = TemplateService.getInstance();

// List all templates
router.get('/', (req, res) => {
  try {
    const templates = templateService.listTemplates();
    res.json({ templates, count: templates.length });
  } catch (error) {
    console.error('Error listing templates:', error);
    res.status(500).json({ error: 'Failed to list templates' });
  }
});

// Get specific template
router.get('/:templateId', (req, res) => {
  try {
    const { templateId } = req.params;
    const template = templateService.getTemplate(templateId);
    
    if (!template) {
      return res.status(404).json({ error: 'Template not found' });
    }
    
    res.json(template);
  } catch (error) {
    console.error('Error getting template:', error);
    res.status(500).json({ error: 'Failed to get template' });
  }
});

// Generate agent from template
router.post('/:templateId/generate', async (req, res) => {
  try {
    const { templateId } = req.params;
    const { agentName, config } = req.body;
    
    if (!agentName) {
      return res.status(400).json({ error: 'Agent name is required' });
    }
    
    const className = await templateService.generateAgent(templateId, agentName, config);
    res.json({ className, message: 'Agent generated successfully' });
  } catch (error) {
    console.error('Error generating agent:', error);
    res.status(500).json({ error: 'Failed to generate agent' });
  }
});

export default router;
```

```typescript
// Update src/backend/src/server.ts
import templatesRouter from './routes/templates';

// ... existing code ...

// Mount routes
app.use('/api/agents', agentsRouter);
app.use('/api/mcp', mcpRouter);
app.use('/api/templates', templatesRouter);

// ... rest of the file ...
```

**Verification**:
- [ ] Template Service created
- [ ] Basic agent templates created
- [ ] Template Generator component works
- [ ] Can generate agents from templates
- [ ] Generated agents appear in Agent Playground

---

### Day 5: Integration & Testing

#### Step 5.1: Integrate All Components

**Time**: 2-3 hours

```typescript
// Update src/frontend/src/App.tsx
import { AgentPlayground } from './components/AgentPlayground';
import { DataExplorer } from './components/DataExplorer';
import { TemplateGenerator } from './components/TemplateGenerator';

function App() {
  return (
    <Router>
      <AppBar position="static">
        <Toolbar>
          <Typography variant="h6" component="div" sx={{ flexGrow: 1 }}>
            IRIS AI Hub Studio
          </Typography>
          <Button color="inherit" component={Link} to="/">
            Agent Playground
          </Button>
          <Button color="inherit" component={Link} to="/data">
            Data Explorer
          </Button>
          <Button color="inherit" component={Link} to="/templates">
            Templates
          </Button>
        </Toolbar>
      </AppBar>
      
      <Container maxWidth="xl" sx={{ mt: 4, height: 'calc(100vh - 64px)' }}>
        <Routes>
          <Route path="/" element={<AgentPlayground />} />
          <Route path="/data" element={<DataExplorer />} />
          <Route path="/templates" element={<TemplateGenerator />} />
        </Routes>
      </Container>
    </Router>
  );
}
```

#### Step 5.2: Create Shared Services

```typescript
// src/frontend/src/services/api.ts
import axios from 'axios';

const API_BASE_URL = '/api';

export const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Add request interceptor for error handling
api.interceptors.response.use(
  (response) => response,
  (error) => {
    console.error('API Error:', error);
    return Promise.reject(error);
  }
);

export default api;
```

```typescript
// Update all services to use the shared API
// src/frontend/src/services/agentService.ts
import { api } from './api';

// Replace axios.get/post with api.get/post
```

#### Step 5.3: Add Error Handling

```typescript
// src/frontend/src/components/ErrorBoundary.tsx
import React, { Component, ErrorInfo, ReactNode } from 'react';
import { Box, Typography, Button } from '@mui/material';

interface Props {
  children: ReactNode;
}

interface State {
  hasError: boolean;
  error: Error | null;
}

export class ErrorBoundary extends Component<Props, State> {
  public state: State = {
    hasError: false,
    error: null,
  };

  public static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error };
  }

  public componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    console.error('ErrorBoundary caught an error:', error, errorInfo);
  }

  public render() {
    if (this.state.hasError) {
      return (
        <Box sx={{ p: 4, textAlign: 'center' }}>
          <Typography variant="h4" color="error" gutterBottom>
            Something went wrong
          </Typography>
          <Typography variant="body1" paragraph>
            {this.state.error?.message}
          </Typography>
          <Button
            variant="contained"
            onClick={() => window.location.reload()}
          >
            Reload Page
          </Button>
        </Box>
      );
    }

    return this.props.children;
  }
}
```

```typescript
// Update src/frontend/src/main.tsx
import { ErrorBoundary } from './ErrorBoundary';

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <ErrorBoundary>
      <App />
    </ErrorBoundary>
  </React.StrictMode>,
);
```

#### Step 5.4: Add Loading States

```typescript
// Create a reusable loading component
// src/frontend/src/components/Loading.tsx
import React from 'react';
import { CircularProgress, Box, Typography } from '@mui/material';

interface LoadingProps {
  message?: string;
}

export const Loading: React.FC<LoadingProps> = ({ message = 'Loading...' }) => {
  return (
    <Box sx={{ display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', p: 4 }}>
      <CircularProgress />
      <Typography variant="body1" sx={{ mt: 2 }}>
        {message}
      </Typography>
    </Box>
  );
};
```

#### Step 5.5: Test End-to-End Flow

**Test Checklist**:

1. **Agent Playground**
   - [ ] Can select agent from dropdown
   - [ ] Can send messages to agent
   - [ ] Receives responses from agent
   - [ ] Shows tool calls when executed
   - [ ] Handles errors gracefully

2. **Data Explorer**
   - [ ] Can view MCP servers
   - [ ] Can view resources for each server
   - [ ] Can view resource data
   - [ ] Handles errors gracefully

3. **Template Generator**
   - [ ] Can view available templates
   - [ ] Can generate agent from template
   - [ ] Generated agent appears in Agent Playground
   - [ ] Handles errors gracefully

4. **Integration**
   - [ ] Navigation between components works
   - [ ] Shared state is maintained
   - [ ] All APIs respond correctly
   - [ ] Error handling works across all components

---

## ✅ Phase 1 Completion Checklist

### Infrastructure
- [ ] Docker environment set up and verified
- [ ] Project structure created
- [ ] Version control initialized
- [ ] Frontend framework (React + TypeScript) set up
- [ ] Backend framework (Express + TypeScript) set up
- [ ] IRIS package structure created

### Agent Test UI
- [ ] Agent discovery service created
- [ ] Agent selector component created
- [ ] Chat interface component created
- [ ] Agent playground integrated
- [ ] Backend API for agents created

### MCP Toolkit
- [ ] MCP service created
- [ ] IRIS MCP connectors created (Global, SQL, DocDB)
- [ ] MCP backend API created
- [ ] Data explorer component created

### Template Generator
- [ ] Template service created
- [ ] Basic agent templates created
- [ ] Template generator component created
- [ ] Backend API for templates created

### Integration
- [ ] All components integrated
- [ ] Shared services created
- [ ] Error handling added
- [ ] Loading states added
- [ ] End-to-end flow tested

---

## 🎯 Phase 1 Success Criteria

By the end of Week 1, you should have:

✅ **Working development environment** with Docker and AI Hub
✅ **Basic Agent Test UI** that can list agents and chat with them
✅ **Basic MCP Toolkit** that can expose global data
✅ **Basic Template Generator** that can create agents from templates
✅ **All components integrated** and working together
✅ **End-to-end flow tested** from template generation to agent testing

**This completes Phase 1: Foundation!** 🎉

---

## 📚 Next Steps

After completing Phase 1, proceed to:

1. **Phase 2: Core Features** (Week 2)
   - Enhance Agent Test UI with advanced features
   - Implement SQL and DocDB connectors
   - Add security controls
   - Create advanced templates
   - Implement conversation management

2. **Review the full roadmap** in [PROJECT-GOALS.md](../project/PROJECT-GOALS.md)

---

**Document Information**
- **Version**: 1.0
- **Purpose**: Step-by-step implementation guide for IRIS AI Hub Studio
- **Based on**: PROJECT-GOALS.md roadmap
- **Status**: Ready for Execution
- **Author**: AI Assistant for Pietro Dileo
- **Last Updated**: July 2026