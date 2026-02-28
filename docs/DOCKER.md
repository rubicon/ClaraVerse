# ClaraVerse Docker Deployment Guide

This guide will help you deploy ClaraVerse using Docker and Docker Compose.

## Prerequisites

- **Docker** 20.10+ ([Install Docker](https://docs.docker.com/get-docker/))
- **Docker Compose** v2.0+ (included with Docker Desktop)
- AI provider API keys (OpenAI, Anthropic, etc.)
- (Optional) Supabase account for authentication

## Quick Start

### 1. Run the Setup Script

The easiest way to get started is with our interactive setup script:

```bash
./setup.sh
```

This script will:
- Check Docker prerequisites
- Create `.env` and `providers.json` from examples
- Prompt you to configure both files
- Validate your configuration
- Start the containers

### 2. Manual Setup (Alternative)

If you prefer to set up manually:

```bash
# Copy environment template
cp backend/.env.example backend/.env

# Copy providers template
cp backend/providers.example.json backend/providers.json

# Edit configuration files
nano backend/.env              # Configure Supabase, SearXNG, CORS, etc.
nano backend/providers.json    # Add your AI provider API keys

# Start containers
docker compose up -d

# Check logs
docker compose logs -f backend
```

## Configuration

### Environment Variables (`backend/.env`)

**Essential Settings:**
```env
ENVIRONMENT=production         # Options: development, testing, production
PORT=3001                     # Backend port

# Supabase Authentication (required for production)
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_KEY=your-service-role-key

# CORS Configuration
ALLOWED_ORIGINS=https://yourdomain.com,https://www.yourdomain.com
```

**Optional Settings:**
```env
# Web Search (optional)
SEARXNG_URL=http://localhost:8080

# File Uploads
UPLOAD_DIR=./uploads
MAX_FILE_SIZE=20971520         # 20MB in bytes

# Database
DATABASE_PATH=model_capabilities.db
PROVIDERS_FILE=providers.json
```

### Provider Configuration (`backend/providers.json`)

Add your AI providers and API keys:

```json
{
  "providers": [
    {
      "name": "OpenAI",
      "base_url": "https://api.openai.com/v1",
      "api_key": "sk-your-actual-openai-key",
      "enabled": true,
      "filters": [
        {
          "pattern": "gpt-4o",
          "action": "include",
          "priority": 20
        },
        {
          "pattern": "gpt-4o-mini",
          "action": "include",
          "priority": 15
        }
      ]
    },
    {
      "name": "Anthropic",
      "base_url": "https://api.anthropic.com/v1",
      "api_key": "your-anthropic-api-key",
      "enabled": true,
      "filters": [
        {
          "pattern": "claude-3-*",
          "action": "include",
          "priority": 10
        }
      ]
    }
  ]
}
```

## Docker Commands

### Starting/Stopping

```bash
# Start all services
docker compose up -d

# Start specific service
docker compose up -d backend

# Stop all services
docker compose down

# Stop and remove volumes (WARNING: deletes data)
docker compose down -v
```

### Viewing Logs

```bash
# View all logs
docker compose logs

# Follow backend logs in real-time
docker compose logs -f backend

# View last 100 lines
docker compose logs --tail=100 backend
```

### Rebuilding

```bash
# Rebuild after code changes
docker compose up -d --build

# Force rebuild (no cache)
docker compose build --no-cache backend
```

### Container Management

```bash
# View container status
docker compose ps

# Restart backend
docker compose restart backend

# Access container shell
docker compose exec backend sh

# View resource usage
docker stats claraverse-backend
```

### Health Checks

```bash
# Check container health status
docker inspect --format='{{.State.Health.Status}}' claraverse-backend

# View health check logs
docker inspect --format='{{json .State.Health}}' claraverse-backend | jq

# Test health endpoint directly
curl http://localhost:3001/health
```

## Updating Configuration

### Updating Providers

```bash
# Edit providers.json
nano backend/providers.json

# Restart backend to apply changes
docker compose restart backend
```

### Updating Environment Variables

```bash
# Edit .env file
nano backend/.env

# Recreate container with new environment
docker compose up -d --force-recreate backend
```

## Development Mode

Docker Compose automatically loads `docker-compose.override.yml` for local development.

**Development Features:**
- Source code mounted for live updates
- Relaxed CORS settings
- No restart policy (easier debugging)
- Development environment variables

**To disable development mode:**
```bash
# Rename or remove the override file
mv docker-compose.override.yml docker-compose.override.yml.disabled

# Or specify only the main compose file
docker compose -f docker-compose.yml up -d
```

## Production Deployment

### 1. Configure for Production

**backend/.env:**
```env
ENVIRONMENT=production
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_KEY=your-service-role-key
ALLOWED_ORIGINS=https://yourdomain.com
```

### 2. Disable Development Override

```bash
# Remove development overrides
rm docker-compose.override.yml

# Or rename it
mv docker-compose.override.yml docker-compose.override.yml.dev
```

### 3. Use Production Compose File (Optional)

```bash
# Start with production settings
docker compose -f docker-compose.yml up -d
```

### 4. Enable SSL/TLS

Use a reverse proxy like Nginx or Traefik for HTTPS:

```nginx
server {
    listen 443 ssl http2;
    server_name api.yourdomain.com;

    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;

    location / {
        proxy_pass http://localhost:3001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

## Persistent Data

Docker Compose creates three named volumes for persistent storage:

```
claraverse-scarlet_backend-data       # SQLite database
claraverse-scarlet_backend-uploads    # User uploads
claraverse-scarlet_backend-logs       # Application logs
```

### Backing Up Data

```bash
# List volumes
docker volume ls | grep claraverse

# Backup database volume
docker run --rm -v claraverse-scarlet_backend-data:/data -v $(pwd):/backup alpine tar czf /backup/database-backup.tar.gz /data

# Restore database volume
docker run --rm -v claraverse-scarlet_backend-data:/data -v $(pwd):/backup alpine tar xzf /backup/database-backup.tar.gz -C /
```

### Inspecting Volumes

```bash
# View volume details
docker volume inspect claraverse-scarlet_backend-data

# Access volume data
docker run --rm -it -v claraverse-scarlet_backend-data:/data alpine sh
ls -la /data
```

## Troubleshooting

### Container Won't Start

```bash
# View detailed logs
docker compose logs backend

# Check if port is in use
lsof -i :3001

# Validate compose configuration
docker compose config
```

### Database Issues

```bash
# Access container shell
docker compose exec backend sh

# Check database file
ls -lh /app/data/model_capabilities.db

# Test database connection
sqlite3 /app/data/model_capabilities.db "SELECT COUNT(*) FROM providers;"
```

### Provider API Issues

```bash
# Test provider connectivity from container
docker compose exec backend wget -O- https://api.openai.com/v1/models

# Check providers.json syntax
docker compose exec backend cat /app/config/providers.json | python3 -m json.tool
```

### Network Issues

```bash
# Inspect network
docker network inspect claraverse-scarlet_claraverse-network

# Test connectivity
docker compose exec backend wget -qO- http://localhost:3001/health
```

### Reset Everything

```bash
# Complete reset (WARNING: destroys all data)
docker compose down -v
docker rmi claraverse-scarlet-backend
rm -rf backend/providers.json backend/.env
docker compose up -d --build
```

## Architecture

### Multi-Stage Build

**Stage 1: Builder**
- Base: `golang:1.24.1-alpine`
- Installs build dependencies (gcc, musl-dev)
- Compiles Go binary with CGO support

**Stage 2: Runtime**
- Base: `alpine:latest` (~30MB)
- Non-root user (claraverse:1000)
- Only runtime dependencies
- Health checks enabled

### Volume Mounts

```
Host                              Container
-----------------------------------------
backend/.env                  →   /app/.env (read-only)
backend/providers.json        →   /app/config/providers.json (read-write)
backend-data volume           →   /app/data (SQLite database)
backend-uploads volume        →   /app/uploads (user files)
backend-logs volume           →   /app/logs (application logs)
```

### Network

```
Host:3001  →  Container:3001  →  Fiber HTTP Server
                                   ├── REST API
                                   ├── WebSocket (/ws/chat)
                                   ├── MCP (/mcp/connect)
                                   └── Health (/health)
```

## Monitoring

### Resource Usage

```bash
# View real-time stats
docker stats claraverse-backend

# View resource limits
docker inspect claraverse-backend | jq '.[0].HostConfig.Memory'
```

### Health Status

```bash
# Health check status
docker inspect --format='{{.State.Health.Status}}' claraverse-backend

# Health check history
docker inspect --format='{{range .State.Health.Log}}{{.Start}}: {{.Output}}{{end}}' claraverse-backend
```

### Application Logs

```bash
# Real-time logs
docker compose logs -f backend

# Export logs to file
docker compose logs backend > backend-logs.txt

# Filter logs by timestamp
docker compose logs --since 1h backend
```

## Next Steps

- [ ] Set up frontend container (React app)
- [ ] Add SearXNG container for web search
- [ ] Configure SSL/TLS with reverse proxy
- [ ] Set up automated backups
- [ ] Configure monitoring (Prometheus, Grafana)
- [ ] Set up CI/CD pipeline
- [ ] Deploy to cloud (AWS, GCP, Azure)

## Support

For issues and questions:
- **Backend Issues**: See [backend/README.md](backend/README.md)
- **Frontend Issues**: See [frontend/README.md](frontend/README.md)
- **Docker Issues**: Check this guide's troubleshooting section
- **API Documentation**: See [backend/docs/API_DOCUMENTATION.md](backend/docs/API_DOCUMENTATION.md)

## License

See [LICENSE](LICENSE) file for details.
