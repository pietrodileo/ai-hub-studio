# AI Hub Configuration Directory

This directory contains configuration files for the AI Hub pre-release.

## Files

- **iris.cfg** - Main IRIS configuration file with AI Hub settings

## Configuration Overview

### Port Configuration
- **1972** - IRIS SuperServer (ODBC, JDBC, etc.)
- **52773** - Management Portal / Web Apps
- **53773** - AI Hub WebSocket

### AI Hub Settings
- **AIHubEnabled**: 1 (Enabled)
- **AIHubPort**: 53773
- **AIHubWebSocketPort**: 53773
- **DefaultNamespace**: AIHubStudio

### Resource Limits
- **MaxAgents**: 50
- **MaxTools**: 100
- **MaxSkills**: 50

## Usage

The configuration files in this directory are automatically mounted into the container at `/opt/irisapp/ai-hub/` and used by the AI Hub entrypoint script.

## Customization

You can modify the `iris.cfg` file to adjust:
- Port numbers
- Memory settings
- Resource limits
- Logging configuration
- Security settings

## API Key Management

API keys for different providers (OpenAI, Azure, Anthropic, Google, Local/Ollama) are managed through the `AIHubStudio.Config` class and stored in the `AIHubStudio_APIKeys` table.

## Multi-Provider Support

The system supports the following AI providers:
- **OpenAI** - OpenAI API
- **Azure** - Azure OpenAI Service
- **Anthropic** - Anthropic API
- **Google** - Google Vertex AI
- **Local** - Local models (Ollama, etc.)

Each provider can have multiple API keys configured, with one marked as default per provider.