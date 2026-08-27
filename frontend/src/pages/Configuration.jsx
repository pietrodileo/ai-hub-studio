import React, { useState, useEffect } from 'react';
import { CheckCircle2, XCircle, Globe, Settings } from 'lucide-react';
import { toast } from 'sonner';

const API_BASE = import.meta.env.VITE_API_BASE || '/api';

const Card = ({ children }) => <section className="card">{children}</section>;
const CardHeader = ({ children }) => <header className="mb-4">{children}</header>;
const CardTitle = ({ children, className = '' }) => <h2 className={`text-lg font-semibold ${className}`}>{children}</h2>;
const CardDescription = ({ children }) => <p className="text-sm text-gray-500">{children}</p>;
const CardContent = ({ children, className = '' }) => <div className={className}>{children}</div>;
const Label = ({ children, ...props }) => <label className="block text-sm font-medium text-gray-700" {...props}>{children}</label>;
const Input = (props) => <input className="w-full rounded-md border border-gray-300 px-3 py-2" {...props} />;
const Button = ({ children, variant = 'primary', ...props }) => {
  const variants = {
    primary: 'bg-blue-600 text-white',
    outline: 'border border-gray-300 bg-white text-gray-700',
    destructive: 'bg-red-600 text-white',
    secondary: 'bg-gray-200 text-gray-800'
  };
  return <button className={`rounded-md px-3 py-2 text-sm disabled:opacity-50 ${variants[variant]}`} {...props}>{children}</button>;
};

// Supported providers with their models
const PROVIDERS = {
  openai: {
    name: 'OpenAI',
    models: ['gpt-4o', 'gpt-4o-mini', 'gpt-3.5-turbo'],
    apiKeyFormat: 'sk-...',
    requiresKey: true
  },
  azure: {
    name: 'Azure OpenAI',
    models: ['gpt-4o', 'gpt-35-turbo'],
    apiKeyFormat: 'alphanumeric',
    requiresKey: true
  },
  anthropic: {
    name: 'Anthropic',
    models: ['claude-3-sonnet', 'claude-3-haiku', 'claude-3-opus'],
    apiKeyFormat: 'sk-ant-...',
    requiresKey: true
  },
  google: {
    name: 'Google',
    models: ['gemini-1.5-pro', 'gemini-1.5-flash'],
    apiKeyFormat: 'base64-like',
    requiresKey: true
  },
  local: {
    name: 'Local (Ollama)',
    models: ['llama3.2', 'mistral', 'phi3'],
    apiKeyFormat: 'none',
    requiresKey: false
  }
};

export default function Configuration() {
  const [providers, setProviders] = useState([]);
  const [apiKeys, setApiKeys] = useState({});
  const [defaultProvider, setDefaultProvider] = useState('openai');
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [activeTab, setActiveTab] = useState('providers');

  // Fetch configuration on mount
  useEffect(() => {
    fetchConfiguration();
  }, []);

  const fetchConfiguration = async () => {
    try {
      setLoading(true);
      
      // Fetch providers info
      const providersRes = await fetch(`${API_BASE}/config/providers`);
      if (providersRes.ok) {
        const providersData = await providersRes.json();
        setProviders(providersData);
      }
      
      // Fetch API keys
      const apiKeysRes = await fetch(`${API_BASE}/config/apikeys`);
      if (apiKeysRes.ok) {
        const apiKeysData = await apiKeysRes.json();
        const keysMap = {};
        apiKeysData.forEach(key => {
          keysMap[key.provider] = {
            defaultModel: key.defaultModel,
            isActive: key.isActive
          };
        });
        setApiKeys(keysMap);
      }
      
      // Fetch default provider
      const defaultRes = await fetch(`${API_BASE}/config/default-provider`);
      if (defaultRes.ok) {
        const defaultData = await defaultRes.json();
        setDefaultProvider(defaultData.defaultProvider || 'openai');
      }
    } catch (error) {
      toast.error('Failed to load configuration', { description: error.message });
    } finally {
      setLoading(false);
    }
  };

  const handleSaveAPIKey = async (provider) => {
    const apiKey = document.getElementById(`apiKey-${provider}`)?.value || '';
    const defaultModel = document.getElementById(`model-${provider}`)?.value || PROVIDERS[provider]?.models[0];
    
    if (!apiKey && PROVIDERS[provider]?.requiresKey) {
      toast.error('API Key is required for this provider');
      return;
    }
    
    try {
      setSaving(true);
      const response = await fetch(`${API_BASE}/config/apikeys/${provider}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ apiKey, defaultModel })
      });
      
      if (response.ok) {
        toast.success(`API Key for ${PROVIDERS[provider]?.name || provider} saved successfully`);
        // Refresh the API keys
        const apiKeysRes = await fetch(`${API_BASE}/config/apikeys`);
        if (apiKeysRes.ok) {
          const apiKeysData = await apiKeysRes.json();
          const keysMap = {};
          apiKeysData.forEach(key => {
            keysMap[key.provider] = {
              defaultModel: key.defaultModel,
              isActive: key.isActive
            };
          });
          setApiKeys(keysMap);
        }
      } else {
        const error = await response.json();
        toast.error('Failed to save API Key', { description: error.error || 'Unknown error' });
      }
    } catch (error) {
      toast.error('Failed to save API Key', { description: error.message });
    } finally {
      setSaving(false);
    }
  };

  const handleDeleteAPIKey = async (provider) => {
    try {
      setSaving(true);
      const response = await fetch(`${API_BASE}/config/apikeys/${provider}`, {
        method: 'DELETE'
      });
      
      if (response.ok) {
        toast.success(`API Key for ${PROVIDERS[provider]?.name || provider} deleted`);
        // Update local state
        const newApiKeys = { ...apiKeys };
        delete newApiKeys[provider];
        setApiKeys(newApiKeys);
      } else {
        const error = await response.json();
        toast.error('Failed to delete API Key', { description: error.error || 'Unknown error' });
      }
    } catch (error) {
      toast.error('Failed to delete API Key', { description: error.message });
    } finally {
      setSaving(false);
    }
  };

  const handleSetDefaultProvider = async (provider) => {
    try {
      setSaving(true);
      const response = await fetch(`${API_BASE}/config/default-provider`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ provider })
      });
      
      if (response.ok) {
        toast.success(`Default provider set to ${PROVIDERS[provider]?.name || provider}`);
        setDefaultProvider(provider);
      } else {
        const error = await response.json();
        toast.error('Failed to set default provider', { description: error.error || 'Unknown error' });
      }
    } catch (error) {
      toast.error('Failed to set default provider', { description: error.message });
    } finally {
      setSaving(false);
    }
  };

  const handleValidateAPIKey = async (provider) => {
    const apiKey = document.getElementById(`apiKey-${provider}`)?.value || '';
    
    if (!apiKey && PROVIDERS[provider]?.requiresKey) {
      toast.error('API Key is required for validation');
      return;
    }
    
    try {
      setSaving(true);
      const response = await fetch(`${API_BASE}/config/apikeys/validate/${provider}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ apiKey })
      });
      
      if (response.ok) {
        const result = await response.json();
        if (result.isValid) {
          toast.success(`API Key for ${PROVIDERS[provider]?.name || provider} is valid`);
        } else {
          toast.error(`API Key for ${PROVIDERS[provider]?.name || provider} is invalid`);
        }
      } else {
        const error = await response.json();
        toast.error('Validation failed', { description: error.error || 'Unknown error' });
      }
    } catch (error) {
      toast.error('Validation failed', { description: error.message });
    } finally {
      setSaving(false);
    }
  };

  const getProviderStatus = (provider) => {
    return apiKeys[provider] ? 'configured' : 'not-configured';
  };

  return (
    <div className="container mx-auto px-4 py-8 max-w-6xl">
      <div className="space-y-6">
        <div>
          <h1 className="text-3xl font-bold tracking-tight">AI Hub Studio Configuration</h1>
          <p className="text-muted-foreground">
            Configure your AI providers, API keys, and default settings
          </p>
        </div>

        <div className="space-y-4">
          <div className="flex gap-2">
            <Button variant={activeTab === 'providers' ? 'primary' : 'outline'} onClick={() => setActiveTab('providers')}>
              <Globe className="mr-2 h-4 w-4" />
              AI Providers
            </Button>
            <Button variant={activeTab === 'settings' ? 'primary' : 'outline'} onClick={() => setActiveTab('settings')}>
              <Settings className="mr-2 h-4 w-4" />
              Settings
            </Button>
          </div>

          {/* Providers Tab */}
          {activeTab === 'providers' && <div className="space-y-4">
            <div className="rounded-md border border-blue-200 bg-blue-50 p-4">
              <CheckCircle2 className="h-4 w-4" />
              <h3 className="font-semibold">Security Notice</h3>
              <p className="text-sm text-gray-600">
                API keys are stored securely and are never transmitted to the client. 
                All validation happens server-side.
              </p>
            </div>

            <div className="space-y-4">
              {Object.entries(PROVIDERS).map(([provider, info]) => (
                <Card key={provider}>
                  <CardHeader>
                    <div className="flex items-center justify-between">
                      <div>
                        <CardTitle className="flex items-center gap-2">
                          {info.name}
                          {getProviderStatus(provider) === 'configured' && (
                            <CheckCircle2 className="h-5 w-5 text-green-500" />
                          )}
                          {getProviderStatus(provider) === 'not-configured' && (
                            <XCircle className="h-5 w-5 text-gray-400" />
                          )}
                        </CardTitle>
                        <CardDescription>
                          {info.apiKeyFormat}
                        </CardDescription>
                      </div>
                      {defaultProvider === provider && (
                        <span className="text-sm font-medium bg-primary/10 text-primary px-2 py-1 rounded-full">
                          Default
                        </span>
                      )}
                    </div>
                  </CardHeader>
                  
                  <CardContent className="space-y-4">
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                      <div className="space-y-2">
                        <Label htmlFor={`apiKey-${provider}`}>
                          API Key
                        </Label>
                        <Input
                          id={`apiKey-${provider}`}
                          type="password"
                          placeholder={info.requiresKey ? info.apiKeyFormat : 'Not required'}
                          defaultValue={apiKeys[provider]?.apiKey || ''}
                          disabled={!info.requiresKey}
                        />
                        {!info.requiresKey && (
                          <p className="text-sm text-muted-foreground">
                            No API key required for local providers
                          </p>
                        )}
                      </div>
                      
                      <div className="space-y-2">
                        <Label htmlFor={`model-${provider}`}>
                          Default Model
                        </Label>
                        <select id={`model-${provider}`} defaultValue={apiKeys[provider]?.defaultModel || info.models[0]} className="w-full rounded-md border border-gray-300 px-3 py-2">
                          {info.models.map((model) => <option key={model} value={model}>{model}</option>)}
                        </select>
                      </div>
                    </div>
                    
                    <div className="flex gap-2">
                      <Button
                        variant="outline"
                        onClick={() => handleValidateAPIKey(provider)}
                        disabled={saving || (!info.requiresKey && !document.getElementById(`apiKey-${provider}`)?.value)}
                      >
                        Validate
                      </Button>
                      <Button
                        onClick={() => handleSaveAPIKey(provider)}
                        disabled={saving}
                      >
                        Save
                      </Button>
                      {getProviderStatus(provider) === 'configured' && (
                        <Button
                          variant="destructive"
                          onClick={() => handleDeleteAPIKey(provider)}
                          disabled={saving}
                        >
                          Delete
                        </Button>
                      )}
                      {defaultProvider !== provider && (
                        <Button
                          variant="secondary"
                          onClick={() => handleSetDefaultProvider(provider)}
                          disabled={saving}
                        >
                          Set as Default
                        </Button>
                      )}
                    </div>
                  </CardContent>
                </Card>
              ))}
            </div>
          </div>}

          {/* Settings Tab */}
          {activeTab === 'settings' && <div className="space-y-4">
            <Card>
              <CardHeader>
                <CardTitle>General Settings</CardTitle>
                <CardDescription>
                  Configure global AI Hub Studio settings
                </CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="space-y-2">
                  <Label>Default AI Provider</Label>
                  <select value={defaultProvider} onChange={(event) => handleSetDefaultProvider(event.target.value)} className="w-full rounded-md border border-gray-300 px-3 py-2">
                    {Object.entries(PROVIDERS).map(([provider, info]) => <option key={provider} value={provider}>{info.name}</option>)}
                  </select>
                  <p className="text-sm text-muted-foreground">
                    This provider will be used by default for new agents
                  </p>
                </div>
              </CardContent>
            </Card>
          </div>}
        </div>
      </div>
    </div>
  );
}
