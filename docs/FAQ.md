# Frequently Asked Questions (FAQ)

## General Questions

### What is ClaraVerse?

ClaraVerse is a privacy-first, self-hostable AI workspace that combines chat interfaces, visual workflow builders, and multi-agent orchestration. Unlike other AI tools, ClaraVerse stores conversations in your browser's local storage (IndexedDB), meaning even server administrators cannot access your chats.

### How is ClaraVerse different from ChatGPT, Claude, or other AI chatbots?

| Feature | ClaraVerse | ChatGPT/Claude | Open WebUI | LibreChat |
|---------|------------|----------------|------------|-----------|
| **Browser-Local Storage** | ✅ Never touches server | ❌ Cloud-only | ❌ Stored in MongoDB | ❌ Stored in MongoDB |
| **Zero-Knowledge Architecture** | ✅ Server can't read chats | ❌ Full access | ❌ Admin access | ❌ Admin access |
| **Self-Hosting** | ✅ Optional | ❌ Cloud-only | ✅ Required | ✅ Required |
| **Multi-Provider** | ✅ Any LLM provider | ❌ Single provider | ✅ Multi-provider | ✅ Multi-provider |
| **Visual Workflows** | ✅ Built-in | ❌ None | ❌ None | ❌ None |
| **Works Offline** | ✅ Full offline mode | ❌ Internet required | ⚠️ Server required | ⚠️ Server required |

### Is ClaraVerse free?

Yes! ClaraVerse is **100% free and open-source** under the AGPL-3.0 license. You can:

- Use it for personal projects (free)
- Self-host for your team (free)
- Use it commercially in small companies <1000 employees (free)
- Contribute to the project (free)

For large enterprises (1000+ employees) who need to remove AGPL copyleft requirements, we offer commercial licenses with premium support.

### Do I need to pay for API keys?

ClaraVerse supports multiple options:

1. **Bring Your Own Key (BYOK)**: Use your own OpenAI, Anthropic, or Google API keys
2. **Local Models**: Use completely free local models via Ollama or LM Studio
3. **Cloud Edition**: Use our hosted version with included API credits (coming soon)

### Can I use ClaraVerse offline?

Yes! ClaraVerse works in **full offline mode**:

- Conversations are stored in browser IndexedDB (never sent to server)
- After initial load, the frontend works completely offline
- Use local LLM models (Ollama) for offline AI capabilities

---

## Privacy & Security

### Where is my data stored?

**Conversations**: Stored in your browser's IndexedDB (local to your device). They never touch the server or database.

**User Account**: Email and authentication details stored in Supabase (encrypted)

**Settings & Preferences**: Can be stored locally or synced to server (you choose)

### Can the server admin read my conversations?

**No!** ClaraVerse uses a zero-knowledge architecture:

- Messages are never sent to the server for storage
- The server only proxies API calls to LLM providers
- Server logs don't contain message content
- Even database backups don't include conversations

This makes ClaraVerse ideal for hosting teams where admins should not access user conversations.

### Is my data encrypted?

Yes, multiple layers:

1. **In Transit**: All API calls use HTTPS/WSS (TLS encryption)
2. **At Rest**: Browser IndexedDB is encrypted by the OS
3. **API Keys**: Stored encrypted in database with AES-256-GCM
4. **Cloud Edition**: TEE (Trusted Execution Environment) prevents even hosting provider from accessing data

### Does ClaraVerse comply with GDPR/HIPAA?

Browser-local storage makes compliance **much easier**:

- **No message retention**: Conversations aren't stored server-side
- **User data minimization**: Only email and settings stored
- **Right to erasure**: Users can delete local data anytime
- **Data portability**: Export conversations from browser
- **No third-party sharing**: Your data stays with you

However, **you are responsible** for ensuring your deployment meets specific regulatory requirements. We recommend consulting with compliance experts for HIPAA/SOC2.

### Can I export my conversation data?

Yes! Conversations are stored in your browser's IndexedDB. You can:

1. Use browser DevTools to export IndexedDB
2. Use ClaraVerse's built-in export feature (coming soon)
3. Script your own export using the browser's IndexedDB API

---

## Installation & Setup

### What are the system requirements?

**For Development**:
- Go 1.24+
- Node.js 20+
- Python 3.11+ (for E2B service)
- Docker (optional but recommended)

**For Docker Deployment**:
- Docker 20.10+
- Docker Compose 2.0+
- 2GB RAM minimum, 4GB recommended
- 10GB disk space

**For Production**:
- 4GB+ RAM
- 20GB+ disk space
- Reverse proxy (Nginx/Caddy)
- SSL certificate

### How do I install ClaraVerse?

**Quick Start (Docker)**:
```bash
git clone https://github.com/claraverse-space/ClaraVerse-Scarlet.git
cd ClaraVerse-Scarlet
docker compose up -d
```

**Development Setup**:
```bash
./dev.sh  # Starts all services in tmux
```

See [README.md](../README.md) for detailed installation instructions.

### Can I deploy ClaraVerse to the cloud?

Yes! ClaraVerse can be deployed to:

- **AWS Lightsail** (see [LIGHTSAIL_SETUP.md](../LIGHTSAIL_SETUP.md))
- **DigitalOcean Droplets**
- **Linode**
- **Google Cloud Platform**
- **Azure**
- **Self-hosted VPS**

See [deployment documentation](../DEPLOYMENT_PLAN.md) for guides.

### Do I need MongoDB?

For the **full version**, yes. MongoDB stores:
- User accounts
- Provider configurations
- Model metadata
- Workflow definitions

**But conversations are NOT stored in MongoDB** - they stay in the browser.

A **standalone mode** without database requirements is planned for future releases.

---

## Features & Usage

### What AI models can I use?

ClaraVerse supports **400+ models** including:

**Commercial APIs**:
- OpenAI: GPT-4o, GPT-4o-mini, GPT-4, GPT-3.5
- Anthropic: Claude 3.5 Sonnet, Claude 3 Opus, Claude 3 Haiku
- Google: Gemini 1.5 Pro, Gemini 1.5 Flash
- Any OpenAI-compatible endpoint

**Local Models** (via Ollama/LM Studio):
- Llama 3, Llama 2
- Mistral, Mixtral
- CodeLlama
- And hundreds more

### How do I add new AI providers?

1. Edit `backend/providers.json`:
   ```json
   {
     "providers": [
       {
         "name": "My Provider",
         "base_url": "https://api.example.com/v1",
         "api_key": "your-key-here",
         "enabled": true
       }
     ]
   }
   ```

2. Restart backend:
   ```bash
   docker compose restart backend
   ```

See [PROVIDER_SETUP_GUIDE.md](../backend/docs/PROVIDER_SETUP_GUIDE.md) for details.

### What is the Visual Workflow Builder?

The Visual Workflow Builder lets you create complex AI workflows with a drag-and-drop interface:

- **Variable Blocks**: Store and transform data
- **LLM Blocks**: Call AI models with custom prompts
- **Code Blocks**: Execute JavaScript/Python
- **Conditional Logic**: Branch based on results
- **Loops**: Iterate over data

**Use Cases**:
- Content generation pipelines
- Data analysis workflows
- Multi-step research tasks
- Automated reporting

### What are Interactive Prompts?

Interactive Prompts allow AI to **ask you questions mid-conversation** using typed forms:

- **Text Input**: Ask for specific details
- **Select Dropdown**: Choose from options
- **Checkboxes**: Multi-select options
- **Radio Buttons**: Single choice

**Example**: AI asks "What tone should I use?" with options: Professional, Casual, Technical

See [INTERACTIVE_PROMPTS.md](INTERACTIVE_PROMPTS.md) for implementation details.

### How does Clara Memory work?

Clara Memory is an intelligent context management system:

- **Short-Term Memory**: Active conversation context
- **Auto-Archival**: Automatically archives less-used memories
- **Memory Scoring**: Prioritizes important information
- **Context Windows**: Manages token limits intelligently

See [MEMORY_SYSTEM_SUMMARY.md](MEMORY_SYSTEM_SUMMARY.md) for details.

### Can I use ClaraVerse for coding tasks?

Yes! ClaraVerse has extensive code support:

- **Code Generation**: Generate code in any language
- **Code Execution**: Run Python, JavaScript, Go in sandboxed E2B environment
- **Code Analysis**: Review and debug code
- **Documentation**: Generate docs from codebases
- **Syntax Highlighting**: Beautiful code rendering

---

## Development & Contributing

### Can I contribute to ClaraVerse?

Absolutely! We welcome contributions:

- 🐛 Bug fixes
- ✨ New features
- 📝 Documentation improvements
- 🧪 Tests
- 🌍 Translations

See [CONTRIBUTING.md](../CONTRIBUTING.md) for guidelines.

### How is ClaraVerse architected?

**Frontend**: React 19 + TypeScript + Tailwind CSS + Zustand
**Backend**: Go 1.24 + Fiber + WebSocket
**Database**: MongoDB + Redis
**Services**: SearXNG (search), E2B (code execution)

See [Architecture Documentation](../backend/docs/ARCHITECTURE.md) for details.

### How do I build a plugin for ClaraVerse?

ClaraVerse supports plugins via:

1. **MCP Bridge**: Model Context Protocol integration
2. **REST API**: Build external services
3. **Custom Tools**: Extend tool execution engine

Plugin development guide coming soon!

### Where can I find API documentation?

- [API Reference](../backend/docs/API_REFERENCE.md)
- [WebSocket API](../backend/docs/WEBSOCKET_API_REFERENCE.md)
- [Developer Guide](../backend/docs/DEVELOPER_GUIDE.md)

---

## Pricing & Licensing

### What is AGPL-3.0 and how does it affect me?

AGPL-3.0 is a copyleft open-source license:

**You CAN**:
- ✅ Use ClaraVerse for free (personal, commercial, enterprise)
- ✅ Modify the source code
- ✅ Self-host for your organization
- ✅ Build on top of ClaraVerse

**You MUST**:
- 📤 Share modifications if you distribute or host it as a service
- 📝 Keep copyright notices
- 🔓 Provide source code to users

### Do I need a commercial license?

**No** for most users:
- Personal use: Free
- Small companies (<1000 employees): Free
- Internal use (not SaaS): Free

**Yes** if you want to:
- Remove AGPL copyleft requirements
- Build proprietary SaaS on ClaraVerse
- Get enterprise support & SLAs
- White-label without attribution

Contact [enterprise@claraverse.space](mailto:enterprise@claraverse.space) for commercial licensing.

### How much does hosting cost?

**Self-Hosted**: Only infrastructure costs
- VPS: $5-20/month (DigitalOcean, Linode)
- AWS Lightsail: $10-40/month
- Home server: Free (electricity cost)

**API Costs**: Pay your LLM provider directly
- OpenAI: $0.03-$60 per 1M tokens (model dependent)
- Anthropic: Similar pricing
- Local models: Free

**Cloud Edition** (coming soon): Hosted version with included credits

---

## Troubleshooting

### Why aren't models showing up?

1. Check `backend/providers.json` exists
2. Verify API keys are correct
3. Ensure `enabled: true` for providers
4. Restart backend: `docker compose restart backend`

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for more solutions.

### WebSocket keeps disconnecting

1. Check proxy timeout settings (Nginx: `proxy_read_timeout 300s;`)
2. Verify firewall isn't blocking WebSocket
3. Enable WebSocket keepalive

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md#websocket-connection-issues).

### How do I update ClaraVerse?

```bash
# Pull latest changes
git pull origin main

# Rebuild containers
docker compose down
docker compose up -d --build

# For development
npm install  # Frontend
go mod tidy  # Backend
```

---

## Community & Support

### Where can I get help?

- **Discord**: [Join our Discord](https://discord.com/invite/j633fsrAne) for real-time help
- **GitHub Issues**: [Report bugs](https://github.com/claraverse-space/ClaraVerse-Scarlet/issues)
- **Discussions**: [Ask questions](https://github.com/claraverse-space/ClaraVerse-Scarlet/discussions)
- **Email**: [hello@claraverse.space](mailto:hello@claraverse.space)
- **Documentation**: [Full docs](../README.md#-documentation)

### How can I stay updated?

- **Newsletter**: [Subscribe](https://claraverse.space/newsletter)
- **Twitter/X**: [@clara_verse_](https://x.com/clara_verse_)
- **GitHub**: [Watch releases](https://github.com/claraverse-space/ClaraVerse-Scarlet)
- **Discord**: [Join community](https://discord.com/invite/j633fsrAne)

### Can I hire someone to set up ClaraVerse for me?

Yes! Options:

1. **Community Support**: Ask in Discord
2. **Professional Services**: Contact [enterprise@claraverse.space](mailto:enterprise@claraverse.space)
3. **Freelancers**: Many community members offer setup services

---

## Roadmap & Future

### What's coming next?

**v1.1** (Q1 2026):
- Desktop applications (Windows, macOS, Linux)
- Mobile apps (iOS, Android)
- P2P device synchronization
- Plugin marketplace

**v2.0** (Q2-Q3 2026):
- Native local LLM support (Ollama/LM Studio)
- Voice input/output
- Advanced RAG
- Browser extension

See [full roadmap](https://github.com/claraverse-space/ClaraVerse-Scarlet/projects).

### Can I request features?

Yes! Please:

1. Check [existing feature requests](https://github.com/claraverse-space/ClaraVerse-Scarlet/issues?q=is%3Aissue+label%3Aenhancement)
2. If not found, [open a new issue](https://github.com/claraverse-space/ClaraVerse-Scarlet/issues/new)
3. Describe your use case and why it's valuable
4. Consider contributing if you can!

---

## Didn't find your answer?

- **Search**: Use GitHub search or Ctrl+F on docs
- **Ask**: Join [Discord](https://discord.com/invite/j633fsrAne) to ask the community
- **Report**: [Open an issue](https://github.com/claraverse-space/ClaraVerse-Scarlet/issues/new) if you think this FAQ should include your question

**Help improve this FAQ**: Submit a PR to add commonly asked questions!
