import React, { useEffect, useMemo, useState } from 'react';
import axios from 'axios';
import { Bot, Database, RotateCcw, Send, Sparkles } from 'lucide-react';

export default function Agents() {
  const [agents, setAgents] = useState([]);
  const [selectedKey, setSelectedKey] = useState('');
  const [conversationId, setConversationId] = useState('');
  const [model, setModel] = useState('');
  const [message, setMessage] = useState('');
  const [messages, setMessages] = useState([]);
  const [stats, setStats] = useState(null);
  const [error, setError] = useState('');
  const [busy, setBusy] = useState(false);

  const selected = useMemo(
    () => agents.find((agent) => agent.key === selectedKey),
    [agents, selectedKey]
  );

  useEffect(() => {
    axios.get('/api/agents')
      .then(({ data }) => {
        setAgents(data);
        const preferred = data.find((item) => item.key === 'native:AIHubStudio.Agent.StudioAssistant') || data[0];
        if (preferred) setSelectedKey(preferred.key);
      })
      .catch((err) => setError(readError(err)));
  }, []);

  useEffect(() => {
    setConversationId('');
    setMessages([]);
    setStats(null);
    setError('');
    setModel('');
  }, [selectedKey]);

  async function ensureConversation() {
    if (conversationId) return conversationId;
    const { data } = await axios.post('/api/conversations', {
      agentKey: selectedKey,
      model: model.trim()
    });
    setConversationId(data.conversationId);
    return data.conversationId;
  }

  async function sendMessage(event) {
    event.preventDefault();
    const text = message.trim();
    if (!text || !selectedKey || busy) return;
    setBusy(true);
    setError('');
    setMessage('');
    setMessages((current) => [...current, { role: 'user', content: text }]);
    try {
      const id = await ensureConversation();
      const { data } = await axios.post(`/api/conversations/${id}/messages`, { message: text });
      setMessages((current) => [...current, { role: 'assistant', content: data.content }]);
      setStats(data.stats);
    } catch (err) {
      setError(readError(err));
    } finally {
      setBusy(false);
    }
  }

  async function resetConversation() {
    if (conversationId) {
      try { await axios.delete(`/api/conversations/${conversationId}`); } catch (_) { /* already gone */ }
    }
    setConversationId('');
    setMessages([]);
    setStats(null);
    setError('');
  }

  return (
    <div className="min-h-screen bg-slate-950 text-slate-100">
      <header className="border-b border-slate-800 bg-slate-900/80 px-6 py-5">
        <div className="mx-auto flex max-w-7xl items-center gap-3">
          <Sparkles className="h-7 w-7 text-cyan-400" />
          <div><h1 className="text-xl font-semibold">IRIS AI Hub Studio</h1><p className="text-sm text-slate-400">Generic %AI.Agent playground</p></div>
        </div>
      </header>
      <main className="mx-auto grid max-w-7xl gap-5 p-5 lg:grid-cols-[340px_1fr]">
        <aside className="rounded-2xl border border-slate-800 bg-slate-900 p-4">
          <label className="mb-2 block text-xs font-semibold uppercase tracking-wider text-slate-400">Agent</label>
          <select className="w-full rounded-lg border border-slate-700 bg-slate-950 p-3" value={selectedKey} onChange={(event) => setSelectedKey(event.target.value)}>
            {agents.map((agent) => <option key={agent.key} value={agent.key}>{agent.name} ({agent.source})</option>)}
          </select>
          {selected && <AgentSummary agent={selected} />}
          <label className="mt-5 mb-2 block text-xs font-semibold uppercase tracking-wider text-slate-400">Model override</label>
          <input className="w-full rounded-lg border border-slate-700 bg-slate-950 p-3" value={model} onChange={(event) => setModel(event.target.value)} disabled={Boolean(conversationId)} placeholder={selected?.model || 'Use agent default'} />
          <button onClick={resetConversation} className="mt-4 flex w-full items-center justify-center gap-2 rounded-lg bg-slate-800 px-4 py-3 hover:bg-slate-700"><RotateCcw className="h-4 w-4" />Reset conversation</button>
        </aside>
        <section className="flex min-h-[70vh] flex-col rounded-2xl border border-slate-800 bg-slate-900">
          <div className="flex-1 space-y-4 overflow-y-auto p-5">
            {messages.length === 0 && <div className="grid h-full place-items-center text-center text-slate-400"><div><Bot className="mx-auto mb-3 h-12 w-12 text-cyan-400" /><p>Select agent and start chatting.</p></div></div>}
            {messages.map((item, index) => <div key={index} className={`max-w-[85%] rounded-2xl px-4 py-3 whitespace-pre-wrap ${item.role === 'user' ? 'ml-auto bg-cyan-600 text-white' : 'bg-slate-800'}`}>{item.content}</div>)}
            {busy && <div className="rounded-2xl bg-slate-800 px-4 py-3 text-slate-400">Agent working…</div>}
          </div>
          {error && <div className="mx-5 rounded-lg border border-red-800 bg-red-950/50 p-3 text-sm text-red-300">{error}</div>}
          {stats && <div className="mx-5 mt-3 flex flex-wrap gap-4 text-xs text-slate-400"><span>Prompt: {stats.total_prompt_tokens}</span><span>Completion: {stats.total_completion_tokens}</span><span>Tools: {stats.total_tool_calls}</span><span>LLM: {stats.total_llm_duration_ms} ms</span></div>}
          <form onSubmit={sendMessage} className="flex gap-3 border-t border-slate-800 p-5">
            <textarea className="min-h-20 flex-1 resize-none rounded-xl border border-slate-700 bg-slate-950 p-3" value={message} onChange={(event) => setMessage(event.target.value)} placeholder="Message selected agent…" />
            <button disabled={busy || !selectedKey || !message.trim()} className="self-end rounded-xl bg-cyan-500 p-3 text-slate-950 disabled:opacity-40"><Send className="h-5 w-5" /></button>
          </form>
        </section>
      </main>
    </div>
  );
}

function AgentSummary({ agent }) {
  return <div className="mt-4 space-y-3 rounded-xl bg-slate-950 p-4 text-sm">
    <div className="flex items-center gap-2 text-cyan-300"><Database className="h-4 w-4" />{agent.source}</div>
    <p className="text-slate-400">{agent.description}</p>
    <Info label="Provider" value={agent.provider || 'configured at runtime'} />
    <Info label="Model" value={agent.model || 'configured at runtime'} />
    <Info label="ToolSets" value={(agent.toolSets || []).join(', ') || 'None'} />
    <Info label="Skills" value={(agent.skills || []).join(', ') || 'None'} />
  </div>;
}

function Info({ label, value }) { return <div><span className="text-xs uppercase text-slate-500">{label}</span><p className="break-words">{value}</p></div>; }
function readError(error) { return error.response?.data?.message || error.message || 'Request failed'; }
