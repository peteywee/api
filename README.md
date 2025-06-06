# api
API server
# Topshelf API & WebSocket Server

A production-ready TypeScript-based REST API and WebSocket server designed for DigitalOcean droplets. This project provides a clean, modular architecture for building modern backend applications with real-time capabilities.

## 🚀 Features

- **REST API** with Express.js
- **WebSocket server** for real-time communication
- **TypeScript** with strict configuration
- **ESLint** for code quality
- **Systemd service** for production deployment
- **Auto-restart** on failure
- **CORS enabled** for cross-origin requests
- **Production-ready** with proper error handling

## 📋 Requirements

- Ubuntu/Debian-based server (DigitalOcean droplet)
- Node.js 16+ and npm
- Root or sudo access

## 🏗️ Project Structure

```
topshelf-api/
├── src/
│   ├── api/
│   │   └── routes.ts          # REST API endpoints
│   ├── ws/
│   │   └── handler.ts         # WebSocket connection handling
│   ├── server.ts              # Main server entry point
│   └── config.ts              # Environment configuration
├── systemd/
│   └── topshelf-api.service   # Systemd service definition
├── build/                     # Compiled JavaScript output
├── .env                       # Environment variables
├── .eslintrc.json            # ESLint configuration
├── tsconfig.json             # TypeScript configuration
├── package.json              # Dependencies and scripts
└── install.sh                # Automated installation script
```

## ⚡ Quick Start

### Option 1: Automated Installation (Recommended)

Run this single command on your droplet:

```bash
curl -sSL https://raw.githubusercontent.com/your-username/topshelf-api/main/install.sh | bash
```

### Option 2: Manual Installation

1. **Clone the repository:**
```bash
git clone https://github.com/your-username/topshelf-api.git
cd topshelf-api
```

2. **Install dependencies:**
```bash
npm install
```

3. **Configure environment:**
```bash
cp .env.example .env
# Edit .env file as needed
```

4. **Build and start:**
```bash
npm run build
npm start
```

## 🧪 Testing Your Server

### Test REST API
```bash
# Local test
curl http://localhost:3000/api/status

# External test (replace with your server IP)
curl http://YOUR_SERVER_IP:3000/api/status
```

Expected response:
```json
{"status":"ok","timestamp":"2025-06-06T..."}
```

### Test WebSocket
```bash
# Install wscat globally
npm install -g wscat

# Connect to WebSocket
wscat -c ws://YOUR_SERVER_IP:3000
```

## 🔧 Configuration

### Environment Variables (.env)

```bash
PORT=3000
# Add your custom environment variables here
```

### Firewall Setup

```bash
# Allow API port
sudo ufw allow 3000/tcp
sudo ufw reload
```

## 📡 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/status` | Health check endpoint |

## 🔌 WebSocket Events

| Event | Description |
|-------|-------------|
| `connection` | Client connects to WebSocket |
| `message` | Echo received messages back to client |
| `close` | Client disconnects |

## 🛠️ Development

### Available Scripts

```bash
npm run build     # Compile TypeScript
npm run lint      # Run ESLint
npm run lint:fix  # Fix ESLint issues automatically
npm start         # Start the server
npm run dev       # Start with auto-reload (if ts-node-dev is installed)
```

### Adding New API Routes

1. Edit `src/api/routes.ts`:
```typescript
router.get("/users", (req: Request, res: Response) => {
  res.json({ users: [] });
});

router.post("/users", (req: Request, res: Response) => {
  // Handle user creation
  res.json({ success: true });
});
```

2. Rebuild and restart:
```bash
npm run build
sudo systemctl restart topshelf-api
```

### Customizing WebSocket Behavior

Edit `src/ws/handler.ts` to handle custom message types:

```typescript
ws.on("message", (msg) => {
  const data = JSON.parse(msg.toString());
  
  switch(data.type) {
    case "chat":
      // Broadcast to all clients
      wss.clients.forEach(client => {
        client.send(JSON.stringify({ type: "chat", message: data.message }));
      });
      break;
    default:
      ws.send(`Echo: ${msg}`);
  }
});
```

## 🔒 Production Setup

### Using with HTTPS (Recommended)

Install Caddy for automatic HTTPS:

```bash
# Install Caddy
sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo tee /etc/apt/trusted.gpg.d/caddy-stable.asc
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
sudo apt update && sudo apt install caddy

# Create Caddyfile
echo "yourdomain.com {
    reverse_proxy localhost:3000
}" | sudo tee /etc/caddy/Caddyfile

# Restart Caddy
sudo systemctl reload caddy
```

Your API will be available at:
- **REST API:** `https://yourdomain.com/api/status`
- **WebSocket:** `wss://yourdomain.com`

### Service Management

```bash
# Check service status
sudo systemctl status topshelf-api

# View logs
sudo journalctl -u topshelf-api -f

# Restart service
sudo systemctl restart topshelf-api

# Stop service
sudo systemctl stop topshelf-api

# Disable auto-start
sudo systemctl disable topshelf-api
```

## 🧩 Integration Examples

### Frontend JavaScript
```javascript
// REST API call
const response = await fetch('http://your-server:3000/api/status');
const data = await response.json();

// WebSocket connection
const ws = new WebSocket('ws://your-server:3000');
ws.onmessage = (event) => console.log('Server:', event.data);
ws.onopen = () => ws.send('Hello from client');
```

### React Component
```jsx
import { useState, useEffect } from 'react';

function ApiComponent() {
  const [status, setStatus] = useState(null);
  const [wsMessage, setWsMessage] = useState('');

  useEffect(() => {
    // REST API call
    fetch('http://your-server:3000/api/status')
      .then(res => res.json())
      .then(setStatus);

    // WebSocket connection
    const ws = new WebSocket('ws://your-server:3000');
    ws.onmessage = (event) => setWsMessage(event.data);
    
    return () => ws.close();
  }, []);

  return (
    <div>
      <p>API Status: {status?.status}</p>
      <p>WebSocket: {wsMessage}</p>
    </div>
  );
}
```

## 🔄 CI/CD with GitHub Actions

The repository includes GitHub Actions workflows for:
- Automated testing on push
- Deployment to your droplet
- Code quality checks

## 🚨 Troubleshooting

### Common Issues

**ECONNREFUSED when accessing externally:**
- Ensure server binds to `0.0.0.0:3000`, not `localhost:3000`
- Check firewall: `sudo ufw status`
- Verify service is running: `sudo systemctl status topshelf-api`

**TypeScript compilation errors:**
- Run `npm run lint:fix` to auto-fix style issues
- Check `tsconfig.json` for strict settings
- Ensure all type declarations are installed

**Service won't start:**
- Check logs: `sudo journalctl -u topshelf-api -e`
- Verify file permissions in `/root/topshelf-api`
- Test manual start: `node build/server.js`

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Make your changes and test
4. Run linting: `npm run lint`
5. Commit and push
6. Create a Pull Request

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

## 🔗 Related Projects

- [Express.js](https://expressjs.com/) - Web framework
- [ws](https://github.com/websockets/ws) - WebSocket library
- [TypeScript](https://www.typescriptlang.org/) - Type-safe JavaScript

## 💬 Support

- 🐛 [Report bugs](https://github.com/your-username/topshelf-api/issues)
- 💡 [Request features](https://github.com/your-username/topshelf-api/issues)
- 📧 Email: your-email@example.com

---

**Built with ❤️ for modern backend development**
