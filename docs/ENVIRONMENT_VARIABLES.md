# Environment Variables Reference

This document lists all environment variables used in ClaraVerse.

## Table of Contents

- [Frontend Variables](#frontend-variables)
- [Backend Variables](#backend-variables)
- [Docker Compose Variables](#docker-compose-variables)
- [Production Variables](#production-variables)
- [Optional Services](#optional-services)

---

## Frontend Variables

Location: `frontend/.env`

### Required Variables

| Variable | Description | Example | Default |
|----------|-------------|---------|---------|
| `VITE_API_BASE_URL` | Backend API base URL | `http://localhost:3001` | `http://localhost:3001` |
| `VITE_WS_URL` | WebSocket server URL | `ws://localhost:3001/ws` | `ws://localhost:3001/ws` |
| `VITE_SUPABASE_URL` | Supabase project URL | `https://xxx.supabase.co` | *Required* |
| `VITE_SUPABASE_ANON_KEY` | Supabase anonymous key | `eyJh...` | *Required* |

### Optional Variables

| Variable | Description | Example | Default |
|----------|-------------|---------|---------|
| `VITE_APP_NAME` | Application name | `ClaraVerse` | `ClaraVerse` |
| `VITE_APP_VERSION` | Application version | `1.0.0` | From package.json |
| `VITE_PORT` | Development server port | `5173` | `5173` |
| `VITE_ENABLE_ANALYTICS` | Enable usage analytics | `true` | `false` |
| `VITE_SENTRY_DSN` | Sentry error tracking DSN | `https://...` | *None* |

### Example `.env`

```bash
# API Configuration
VITE_API_BASE_URL=http://localhost:3001
VITE_WS_URL=ws://localhost:3001/ws

# Supabase Configuration
VITE_SUPABASE_URL=https://xxxxx.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# Optional
VITE_APP_NAME=ClaraVerse
VITE_APP_VERSION=1.0.0
VITE_ENABLE_ANALYTICS=false
```

---

## Backend Variables

Location: `backend/.env`

### Required Variables

| Variable | Description | Example | Default |
|----------|-------------|---------|---------|
| `PORT` | Server port | `3001` | `3001` |
| `MONGODB_URI` | MongoDB connection string | `mongodb://mongodb:27017/claraverse` | *Required* |
| `SUPABASE_URL` | Supabase project URL | `https://xxx.supabase.co` | *Required* |
| `SUPABASE_SERVICE_ROLE_KEY` | Supabase service role key | `eyJh...` | *Required* |
| `JWT_SECRET` | JWT signing secret | `your-secret-key` | *Required* |

### Optional Variables

| Variable | Description | Example | Default |
|----------|-------------|---------|---------|
| `REDIS_URL` | Redis connection URL | `redis://redis:6379` | *None* |
| `FRONTEND_URL` | Frontend URL (for CORS) | `http://localhost:5173` | `http://localhost:5173` |
| `BACKEND_URL` | Backend public URL | `https://api.claraverse.space` | `http://localhost:3001` |
| `LOG_LEVEL` | Logging level | `debug`, `info`, `warn`, `error` | `info` |
| `ENABLE_CORS` | Enable CORS | `true` | `true` |
| `MAX_FILE_SIZE` | Max upload size (bytes) | `10485760` (10MB) | `10485760` |
| `UPLOAD_DIR` | File upload directory | `./uploads` | `./uploads` |

### AI Provider Variables

| Variable | Description | Example | Default |
|----------|-------------|---------|---------|
| `OPENAI_API_KEY` | OpenAI API key | `sk-...` | *None* |
| `ANTHROPIC_API_KEY` | Anthropic API key | `sk-ant-...` | *None* |
| `GOOGLE_API_KEY` | Google/Gemini API key | `AIza...` | *None* |

**Note**: Provider keys can also be configured in `providers.json` for better multi-provider management.

### Security Variables

| Variable | Description | Example | Default |
|----------|-------------|---------|---------|
| `ENCRYPTION_KEY` | AES encryption key for sensitive data | `32-byte-hex-string` | *Auto-generated* |
| `SESSION_SECRET` | Session cookie secret | `random-string` | *Required* |
| `RATE_LIMIT_MAX` | Max requests per window | `100` | `100` |
| `RATE_LIMIT_WINDOW` | Rate limit window (ms) | `900000` (15 min) | `900000` |

### External Services

| Variable | Description | Example | Default |
|----------|-------------|---------|---------|
| `SEARXNG_URL` | SearXNG search engine URL | `http://searxng:8080` | *None* |
| `E2B_API_KEY` | E2B code execution API key | `e2b_...` | *None* |
| `E2B_SERVICE_URL` | E2B service URL | `http://localhost:8001` | `http://localhost:8001` |

### Example `.env`

```bash
# Server Configuration
PORT=3001
FRONTEND_URL=http://localhost:5173
BACKEND_URL=http://localhost:3001
LOG_LEVEL=info

# Database
MONGODB_URI=mongodb://mongodb:27017/claraverse
REDIS_URL=redis://redis:6379

# Authentication
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
JWT_SECRET=your-very-long-random-secret-key
SESSION_SECRET=another-random-secret

# Security
ENCRYPTION_KEY=0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef
RATE_LIMIT_MAX=100
RATE_LIMIT_WINDOW=900000

# File Uploads
MAX_FILE_SIZE=10485760
UPLOAD_DIR=./uploads

# External Services
SEARXNG_URL=http://searxng:8080
E2B_SERVICE_URL=http://localhost:8001
```

---

## Docker Compose Variables

Location: `.env` (project root)

### Required Variables

| Variable | Description | Example | Default |
|----------|-------------|---------|---------|
| `COMPOSE_PROJECT_NAME` | Docker Compose project name | `claraverse` | `claraverse` |
| `MONGODB_ROOT_USERNAME` | MongoDB root username | `admin` | `admin` |
| `MONGODB_ROOT_PASSWORD` | MongoDB root password | `securepassword` | *Required* |
| `MONGODB_DATABASE` | MongoDB database name | `claraverse` | `claraverse` |

### Optional Variables

| Variable | Description | Example | Default |
|----------|-------------|---------|---------|
| `REDIS_PASSWORD` | Redis password | `redispassword` | *None* |
| `NGINX_PORT` | Nginx external port | `80` | `80` |
| `NGINX_SSL_PORT` | Nginx SSL port | `443` | `443` |

### Example `.env`

```bash
# Docker Compose
COMPOSE_PROJECT_NAME=claraverse

# MongoDB
MONGODB_ROOT_USERNAME=admin
MONGODB_ROOT_PASSWORD=your-secure-mongodb-password
MONGODB_DATABASE=claraverse

# Redis
REDIS_PASSWORD=your-redis-password

# Nginx
NGINX_PORT=80
NGINX_SSL_PORT=443
```

---

## Production Variables

Additional variables for production deployments.

### SSL/TLS

| Variable | Description | Example | Default |
|----------|-------------|---------|---------|
| `SSL_CERT_PATH` | SSL certificate path | `/etc/letsencrypt/live/domain/cert.pem` | *None* |
| `SSL_KEY_PATH` | SSL private key path | `/etc/letsencrypt/live/domain/privkey.pem` | *None* |
| `SSL_CHAIN_PATH` | SSL certificate chain | `/etc/letsencrypt/live/domain/chain.pem` | *None* |

### Domain Configuration

| Variable | Description | Example | Default |
|----------|-------------|---------|---------|
| `DOMAIN` | Primary domain | `claraverse.space` | *None* |
| `API_DOMAIN` | API subdomain | `api.claraverse.space` | *None* |

### Monitoring & Logging

| Variable | Description | Example | Default |
|----------|-------------|---------|---------|
| `SENTRY_DSN` | Sentry error tracking DSN | `https://...@sentry.io/...` | *None* |
| `LOG_FILE_PATH` | Log file location | `/var/log/claraverse/app.log` | *None* |
| `ENABLE_REQUEST_LOGGING` | Log all requests | `true` | `false` |

### Performance

| Variable | Description | Example | Default |
|----------|-------------|---------|---------|
| `NODE_ENV` | Node environment | `production` | `development` |
| `WS_MAX_PAYLOAD` | Max WebSocket payload size | `10485760` | `10485760` |
| `WS_HEARTBEAT_INTERVAL` | WebSocket ping interval (ms) | `30000` | `30000` |
| `ENABLE_COMPRESSION` | Enable gzip compression | `true` | `true` |

### Example Production `.env`

```bash
# Environment
NODE_ENV=production

# Server
PORT=3001
FRONTEND_URL=https://claraverse.space
BACKEND_URL=https://api.claraverse.space

# Database
MONGODB_URI=mongodb://admin:password@mongodb:27017/claraverse?authSource=admin
REDIS_URL=redis://:password@redis:6379

# SSL/TLS
SSL_CERT_PATH=/etc/letsencrypt/live/claraverse.space/cert.pem
SSL_KEY_PATH=/etc/letsencrypt/live/claraverse.space/privkey.pem
SSL_CHAIN_PATH=/etc/letsencrypt/live/claraverse.space/chain.pem

# Domain
DOMAIN=claraverse.space
API_DOMAIN=api.claraverse.space

# Security
JWT_SECRET=super-long-random-production-secret
ENCRYPTION_KEY=0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef
RATE_LIMIT_MAX=50
RATE_LIMIT_WINDOW=900000

# Monitoring
SENTRY_DSN=https://xxxxx@sentry.io/xxxxx
LOG_FILE_PATH=/var/log/claraverse/app.log
LOG_LEVEL=warn

# Performance
ENABLE_COMPRESSION=true
WS_MAX_PAYLOAD=10485760
WS_HEARTBEAT_INTERVAL=30000
```

---

## Optional Services

### Turnstile (Cloudflare CAPTCHA)

| Variable | Description | Example | Default |
|----------|-------------|---------|---------|
| `TURNSTILE_SITE_KEY` | Turnstile site key | `0x4AAA...` | *None* |
| `TURNSTILE_SECRET_KEY` | Turnstile secret key | `0x4BBB...` | *None* |
| `ENABLE_TURNSTILE` | Enable Turnstile | `true` | `false` |

### Composio Integration

| Variable | Description | Example | Default |
|----------|-------------|---------|---------|
| `COMPOSIO_API_KEY` | Composio API key | `comp_...` | *None* |
| `COMPOSIO_LINKEDIN_AUTH_CONFIG_ID` | LinkedIn auth config | `linkedin_...` | *None* |

### Analytics

| Variable | Description | Example | Default |
|----------|-------------|---------|---------|
| `GOOGLE_ANALYTICS_ID` | Google Analytics tracking ID | `G-XXXXXXXXXX` | *None* |
| `PLAUSIBLE_DOMAIN` | Plausible analytics domain | `claraverse.space` | *None* |

---

## Environment-Specific Configurations

### Development

```bash
NODE_ENV=development
LOG_LEVEL=debug
ENABLE_REQUEST_LOGGING=true
ENABLE_CORS=true
FRONTEND_URL=http://localhost:5173
BACKEND_URL=http://localhost:3001
```

### Staging

```bash
NODE_ENV=staging
LOG_LEVEL=info
ENABLE_REQUEST_LOGGING=true
ENABLE_CORS=true
FRONTEND_URL=https://staging.claraverse.space
BACKEND_URL=https://api-staging.claraverse.space
```

### Production

```bash
NODE_ENV=production
LOG_LEVEL=warn
ENABLE_REQUEST_LOGGING=false
ENABLE_CORS=true
FRONTEND_URL=https://claraverse.space
BACKEND_URL=https://api.claraverse.space
```

---

## Security Best Practices

### 1. Never Commit `.env` Files

Add to `.gitignore`:

```
.env
.env.local
.env.*.local
```

### 2. Use Strong Secrets

Generate strong secrets:

```bash
# Generate JWT secret
openssl rand -hex 32

# Generate encryption key
openssl rand -hex 64
```

### 3. Rotate Secrets Regularly

- Rotate JWT secrets every 90 days
- Rotate API keys when team members leave
- Use different keys for different environments

### 4. Use Secret Management

For production, consider:
- **AWS Secrets Manager**
- **HashiCorp Vault**
- **Kubernetes Secrets**
- **Docker Secrets**

### 5. Validate Environment Variables

Backend should validate required variables on startup:

```go
func validateEnv() error {
    required := []string{
        "MONGODB_URI",
        "JWT_SECRET",
        "SUPABASE_URL",
    }

    for _, key := range required {
        if os.Getenv(key) == "" {
            return fmt.Errorf("missing required env var: %s", key)
        }
    }
    return nil
}
```

---

## Troubleshooting

### Variables Not Loading

**Frontend (Vite)**:
- Must prefix with `VITE_`
- Restart dev server after changes
- Check browser console for errors

**Backend**:
- Check file location (`backend/.env`)
- Verify no syntax errors in `.env`
- Use `godotenv` or similar to load

### Docker Compose Not Using Variables

```bash
# Check what Docker Compose sees
docker compose config

# Ensure .env is in same directory as docker-compose.yml
ls -la .env
```

### Production Variables Not Applied

```bash
# For systemd services, set in service file:
[Service]
Environment="NODE_ENV=production"
Environment="PORT=3001"
EnvironmentFile=/path/to/.env
```

---

## Reference

- [Vite Environment Variables](https://vitejs.dev/guide/env-and-mode.html)
- [Docker Compose Environment Variables](https://docs.docker.com/compose/environment-variables/)
- [Go Environment Variables](https://pkg.go.dev/os#Getenv)

---

**Need help?** See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) or ask in [Discord](https://discord.com/invite/j633fsrAne).
