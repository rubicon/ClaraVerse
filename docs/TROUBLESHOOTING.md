# ClaraVerse Troubleshooting Guide

This guide helps you diagnose and resolve common issues with ClaraVerse.

## Table of Contents

- [Installation Issues](#installation-issues)
- [Docker Issues](#docker-issues)
- [WebSocket Connection Issues](#websocket-connection-issues)
- [Authentication Issues](#authentication-issues)
- [Model/Provider Issues](#modelprovider-issues)
- [Performance Issues](#performance-issues)
- [Database Issues](#database-issues)
- [Frontend Issues](#frontend-issues)
- [Backend Issues](#backend-issues)
- [Getting Help](#getting-help)

---

## Installation Issues

### Dependencies Won't Install

**Problem**: `npm install` or `go mod download` fails

**Solutions**:

1. **Check versions**:
   ```bash
   node --version  # Should be 20+
   go version      # Should be 1.24+
   python --version # Should be 3.11+
   ```

2. **Clear caches**:
   ```bash
   # Frontend
   cd frontend
   rm -rf node_modules package-lock.json
   npm cache clean --force
   npm install

   # Backend
   cd backend
   go clean -modcache
   go mod download
   ```

3. **Check network**:
   - Ensure you're not behind a restrictive firewall
   - Try using a VPN if corporate proxy is blocking
   - Check npm registry: `npm config get registry`

### Port Already in Use

**Problem**: Error: `address already in use` or `port 3001/5173 already allocated`

**Solutions**:

```bash
# Find what's using the port
lsof -i :3001
lsof -i :5173

# Kill the process
kill -9 <PID>

# Or change ports in .env
VITE_PORT=5174
BACKEND_PORT=3002
```

---

## Docker Issues

### Containers Won't Start

**Problem**: `docker compose up` fails or containers exit immediately

**Solutions**:

1. **Check Docker daemon**:
   ```bash
   docker ps
   sudo systemctl status docker
   sudo systemctl start docker
   ```

2. **Validate compose file**:
   ```bash
   docker compose config
   ```

3. **Check logs**:
   ```bash
   docker compose logs backend
   docker compose logs frontend
   docker compose logs mongodb
   ```

4. **Clean restart**:
   ```bash
   docker compose down -v
   docker compose up -d --build
   ```

### MongoDB Connection Failed

**Problem**: Backend can't connect to MongoDB

**Solutions**:

1. **Check MongoDB is running**:
   ```bash
   docker compose ps
   docker compose logs mongodb
   ```

2. **Verify connection string** in `.env`:
   ```bash
   MONGODB_URI=mongodb://mongodb:27017/claraverse
   ```

3. **Check network**:
   ```bash
   docker network ls
   docker network inspect claraverse_default
   ```

### Permission Denied Errors

**Problem**: Docker commands fail with permission errors

**Solutions**:

```bash
# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker

# Or use sudo
sudo docker compose up -d
```

### Build Failures

**Problem**: Docker build fails during image creation

**Solutions**:

1. **Clear Docker cache**:
   ```bash
   docker builder prune -a
   docker compose build --no-cache
   ```

2. **Check disk space**:
   ```bash
   df -h
   docker system df
   docker system prune -a
   ```

---

## WebSocket Connection Issues

### Connection Drops Frequently

**Problem**: WebSocket disconnects every few seconds or minutes

**Solutions**:

1. **Check proxy timeout settings** (Nginx/Apache):
   ```nginx
   # nginx.conf
   location /ws/ {
       proxy_pass http://localhost:3001;
       proxy_http_version 1.1;
       proxy_set_header Upgrade $http_upgrade;
       proxy_set_header Connection "upgrade";
       proxy_read_timeout 300s;
       proxy_send_timeout 300s;
   }
   ```

2. **Check firewall rules**:
   ```bash
   # Allow WebSocket port
   sudo ufw allow 3001/tcp
   ```

3. **Enable keepalive** in backend (already enabled by default)

### WebSocket Connection Refused

**Problem**: Frontend can't establish WebSocket connection

**Solutions**:

1. **Check backend is running**:
   ```bash
   curl http://localhost:3001/health
   ```

2. **Verify WebSocket URL** in frontend `.env`:
   ```bash
   VITE_WS_URL=ws://localhost:3001/ws
   # For production with SSL:
   VITE_WS_URL=wss://yourdomain.com/ws
   ```

3. **Check CORS settings** in backend

4. **Test WebSocket directly**:
   ```bash
   # Using wscat
   npm install -g wscat
   wscat -c ws://localhost:3001/ws/chat
   ```

### Messages Not Streaming

**Problem**: Chat messages appear all at once instead of streaming

**Solutions**:

1. **Check proxy buffering** (Nginx):
   ```nginx
   proxy_buffering off;
   proxy_cache off;
   ```

2. **Verify provider supports streaming**

3. **Check browser console** for JavaScript errors

---

## Authentication Issues

### Can't Login / Token Issues

**Problem**: Login fails or token expires immediately

**Solutions**:

1. **Check Supabase configuration**:
   - Verify `SUPABASE_URL` and `SUPABASE_ANON_KEY` in `.env`
   - Ensure Supabase project is active

2. **Clear browser storage**:
   ```javascript
   // In browser console
   localStorage.clear();
   sessionStorage.clear();
   ```

3. **Check token expiration** settings in Supabase dashboard

4. **Verify JWT secret** is set correctly

### CORS Errors on Login

**Problem**: CORS errors when trying to authenticate

**Solutions**:

1. **Check backend CORS configuration**:
   - Ensure frontend URL is in allowed origins
   - Check `FRONTEND_URL` in backend `.env`

2. **Verify Supabase CORS** settings in dashboard

---

## Model/Provider Issues

### Models Not Appearing in UI

**Problem**: No models show up in the model selector

**Solutions**:

1. **Check providers.json exists**:
   ```bash
   ls backend/providers.json
   # If missing, copy from example:
   cp backend/providers.example.json backend/providers.json
   ```

2. **Verify API keys** in `providers.json`:
   ```json
   {
     "providers": [
       {
         "name": "OpenAI",
         "api_key": "sk-your-actual-key-here",
         "enabled": true
       }
     ]
   }
   ```

3. **Restart backend**:
   ```bash
   docker compose restart backend
   # Or for development:
   cd backend && go run ./cmd/server
   ```

4. **Check backend logs**:
   ```bash
   docker compose logs backend | grep -i "provider\|model"
   ```

5. **Verify API endpoint**:
   ```bash
   curl http://localhost:3001/api/models
   ```

### API Rate Limits / 429 Errors

**Problem**: Too many requests error from LLM provider

**Solutions**:

1. **Check your API usage** in provider dashboard (OpenAI/Anthropic/etc.)

2. **Implement rate limiting** or use different models

3. **Upgrade API tier** with your provider

4. **Use local models** (Ollama) as fallback

### Model Responses Slow

**Problem**: Slow response times from AI models

**Solutions**:

1. **Switch to faster models**:
   - GPT-4o-mini instead of GPT-4
   - Claude Haiku instead of Opus

2. **Check provider status**:
   - OpenAI: https://status.openai.com
   - Anthropic: https://status.anthropic.com

3. **Verify network latency**:
   ```bash
   ping api.openai.com
   ```

4. **Consider using local models** for faster responses

---

## Performance Issues

### High Memory Usage

**Problem**: Backend or frontend consuming too much RAM

**Solutions**:

1. **Backend memory limits** (Docker):
   ```yaml
   # docker-compose.yml
   services:
     backend:
       mem_limit: 512m
   ```

2. **Check for memory leaks**:
   ```bash
   # Monitor backend
   docker stats backend
   ```

3. **Clear conversation history** (browser IndexedDB)

4. **Reduce concurrent connections**

### Slow Frontend Performance

**Problem**: UI feels sluggish or unresponsive

**Solutions**:

1. **Clear browser cache**:
   - Chrome: Ctrl+Shift+Delete
   - Firefox: Ctrl+Shift+Delete

2. **Check browser console** for errors

3. **Disable browser extensions** that might interfere

4. **Update browser** to latest version

5. **Check system resources**:
   ```bash
   # Linux/Mac
   htop
   # Windows
   Task Manager
   ```

### Database Performance

**Problem**: Slow queries or database timeouts

**Solutions**:

1. **Add indexes** (MongoDB):
   ```javascript
   db.conversations.createIndex({ userId: 1, createdAt: -1 })
   ```

2. **Check database size**:
   ```bash
   docker exec -it mongodb mongo
   > db.stats()
   ```

3. **Archive old data**

4. **Increase connection pool** size in backend config

---

## Database Issues

### MongoDB Connection Timeout

**Problem**: Can't connect to MongoDB

**Solutions**:

1. **Check MongoDB is running**:
   ```bash
   docker compose ps mongodb
   ```

2. **Verify connection string**:
   ```bash
   # .env
   MONGODB_URI=mongodb://mongodb:27017/claraverse
   ```

3. **Check MongoDB logs**:
   ```bash
   docker compose logs mongodb
   ```

4. **Restart MongoDB**:
   ```bash
   docker compose restart mongodb
   ```

### Data Loss / Persistence Issues

**Problem**: Data disappears after container restart

**Solutions**:

1. **Check Docker volumes**:
   ```bash
   docker volume ls
   docker volume inspect claraverse_mongodb_data
   ```

2. **Ensure volumes are mounted** in docker-compose.yml:
   ```yaml
   volumes:
     - mongodb_data:/data/db
   ```

3. **Backup database**:
   ```bash
   docker exec mongodb mongodump -o /backup
   ```

---

## Frontend Issues

### Build Failures

**Problem**: `npm run build` fails

**Solutions**:

1. **Check TypeScript errors**:
   ```bash
   npm run type-check
   ```

2. **Fix linting errors**:
   ```bash
   npm run lint:fix
   ```

3. **Clear build cache**:
   ```bash
   rm -rf dist .vite
   npm run build
   ```

### Vite HMR Not Working

**Problem**: Hot module replacement not updating changes

**Solutions**:

1. **Restart dev server**:
   ```bash
   npm run dev
   ```

2. **Check file watchers limit** (Linux):
   ```bash
   echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf
   sudo sysctl -p
   ```

### Import Errors

**Problem**: Module not found or import errors

**Solutions**:

1. **Check path aliases** in `vite.config.ts` and `tsconfig.json`

2. **Reinstall dependencies**:
   ```bash
   rm -rf node_modules package-lock.json
   npm install
   ```

---

## Backend Issues

### Go Build Failures

**Problem**: Backend won't compile

**Solutions**:

1. **Check Go version**:
   ```bash
   go version  # Should be 1.24+
   ```

2. **Clean and rebuild**:
   ```bash
   go clean -cache
   go mod tidy
   go build ./cmd/server
   ```

3. **Check for syntax errors**:
   ```bash
   go vet ./...
   ```

### Air Hot Reload Not Working

**Problem**: Changes not reflected in development

**Solutions**:

1. **Check .air.toml configuration**

2. **Restart Air**:
   ```bash
   pkill air
   air
   ```

3. **Check file permissions**

---

## Getting Help

If you've tried the solutions above and still have issues:

### 1. Search Existing Issues

Check [GitHub Issues](https://github.com/claraverse-space/ClaraVerse-Scarlet/issues) to see if someone else has had the same problem.

### 2. Gather Information

Before reporting, collect:

- **Environment details**:
  ```bash
  # System info
  uname -a  # Linux/Mac
  systeminfo  # Windows

  # Versions
  node --version
  go version
  docker --version

  # Logs
  docker compose logs > logs.txt
  ```

- **Error messages** (full stack trace)
- **Steps to reproduce**
- **Expected vs actual behavior**

### 3. Report the Issue

- **GitHub Issues**: [Create an issue](https://github.com/claraverse-space/ClaraVerse-Scarlet/issues/new)
- **Discord**: [Join our Discord](https://discord.com/invite/j633fsrAne)
- **Email**: [hello@claraverse.space](mailto:hello@claraverse.space)

### 4. Include Debug Info

When reporting, include:

```bash
# System info
docker compose version
docker version
node --version
go version

# Service status
docker compose ps

# Recent logs
docker compose logs --tail=100 backend
docker compose logs --tail=100 frontend

# Environment variables (redact secrets!)
env | grep -E 'VITE_|BACKEND_|MONGODB_' | sed 's/=.*/=***/'
```

---

## Common Error Messages

### "ECONNREFUSED" or "Connection Refused"

**Cause**: Service not running or wrong port

**Fix**: Verify service is running and port is correct

### "Cannot find module"

**Cause**: Missing dependency or wrong import path

**Fix**: Run `npm install` or check import path

### "CORS policy" errors

**Cause**: Cross-origin request blocked

**Fix**: Add origin to CORS whitelist in backend

### "JWT token expired"

**Cause**: Authentication token has expired

**Fix**: Re-login or refresh token

### "Rate limit exceeded"

**Cause**: Too many API requests

**Fix**: Wait or upgrade API tier

---

## Performance Optimization Tips

1. **Use faster models** for development (GPT-4o-mini, Claude Haiku)
2. **Enable caching** for repeated queries
3. **Limit conversation history** length
4. **Use local models** (Ollama) when possible
5. **Optimize database queries** with indexes
6. **Enable compression** in nginx/proxy
7. **Use CDN** for static assets in production

---

**Still stuck?** Don't hesitate to reach out to the community! We're here to help. 🚀
