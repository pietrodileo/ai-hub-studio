# VS Code Configuration for IRIS AI Hub Studio

This folder contains configuration files for connecting to your IRIS instance through VS Code using the InterSystems VS Code extension.

## Prerequisites

1. Install [VS Code](https://code.visualstudio.com/)
2. Install the following extensions:
   - [InterSystems ObjectScript](https://marketplace.visualstudio.com/items?itemName=intersystems-community.vscode-objectscript)
   - [InterSystems Server Manager](https://marketplace.visualstudio.com/items?itemName=intersystems-community.vscode-objectscript-servermanager)

## Quick Start

### Method 1: Using the Workspace File
1. Open VS Code
2. Click "File" > "Open Workspace" and select `.vscode/workspace.code-workspace`
3. The server connection should be automatically configured

### Method 2: Manual Setup
1. Open this project folder in VS Code
2. Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on Mac) to open the Command Palette
3. Type "ObjectScript: Add Server" and press Enter
4. Use the following connection details:
   - **Name**: IRIS AI Hub Studio
   - **Host**: localhost
   - **Port**: 9091
   - **Username**: _SYSTEM
   - **Password**: SYS
   - **Namespace**: USER
   - **HTTPS**: No

## Available Commands

### Server Management
- `ObjectScript: Connect to Server` - Connect to the IRIS instance
- `ObjectScript: Disconnect from Server` - Disconnect from the IRIS instance
- `ObjectScript: Add Server` - Add a new server configuration

### Development
- `ObjectScript: Compile` - Compile the current file
- `ObjectScript: Run` - Run the current file
- `ObjectScript: Debug` - Debug the current file

### Source Control
- `ObjectScript: Import` - Import files from the server
- `ObjectScript: Export` - Export files to the server

## Docker Integration

The project uses Docker Compose to manage the IRIS instance. Use the following commands:

```bash
# Start IRIS only
docker compose up -d iris-ai-hub

# Start full stack (IRIS + backend + frontend)
docker compose up -d

# Stop all containers
docker compose down

# View logs
docker compose logs -f iris-ai-hub
```

## VS Code Tasks

The following tasks are available in VS Code:
- **Start IRIS Container** - Starts the IRIS Docker container
- **Stop IRIS Container** - Stops all Docker containers
- **Import Classes** - Imports ObjectScript classes into IRIS
- **Build Full Stack** - Builds and starts all services

To run a task:
1. Press `Ctrl+Shift+P`
2. Type "Run Task"
3. Select the task you want to run

## Debugging

Two debug configurations are available:
1. **IRIS AI Hub Studio - Attach** - Attaches to the running IRIS instance
2. **IRIS AI Hub Studio - Debug** - Launches and debugs the initialization routine

To start debugging:
1. Set breakpoints in your code
2. Press `F5` or click "Run" > "Start Debugging"
3. Select the debug configuration

## Troubleshooting

### Connection Issues
If you can't connect to the IRIS instance:
1. Verify the container is running: `docker ps`
2. Check the container logs: `docker logs iris-ai-hub-studio`
3. Verify the ports are exposed: `docker port iris-ai-hub-studio`
4. Test the connection manually using the Management Portal: http://localhost:9092/csp/sys/UtilHome.csp

### Authentication Issues
- Default credentials: Username=`_SYSTEM`, Password=`SYS`
- If you changed the password, update the `.vscode/settings.json` file

### Class Import Issues
If classes fail to import:
1. Ensure the IRIS container is running
2. Check that the source files are in the `./src` directory
3. Verify the volume mount in docker-compose.yml maps `./src` to `/opt/irisapp/src`

## Configuration Files

- **settings.json** - VS Code settings including server connections
- **launch.json** - Debug configurations
- **tasks.json** - Build and development tasks
- **extensions.json** - Recommended VS Code extensions
- **workspace.code-workspace** - VS Code workspace configuration

## Tips

1. **Auto-connect**: The workspace is configured to auto-connect to the IRIS instance when opened
2. **Source Control**: Files in the `./src` directory are automatically mapped to the IRIS namespace
3. **Namespace**: All development is done in the `USER` namespace
4. **Ports**: 
   - 9092: Management Portal and REST APIs
   - 9091: SuperServer (for VS Code connection)
   - 52773: Internal IRIS web server

## Additional Resources

- [InterSystems VS Code Extension Documentation](https://github.com/intersystems-community/vscode-objectscript)
- [IRIS Docker Documentation](https://docs.intersystems.com/irislatest/csp/docbook/DockerGuide/index.html)
- [AI Hub Studio Documentation](../docs/)
