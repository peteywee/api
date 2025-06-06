#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[⚠]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
}

log_skip() {
    echo -e "${YELLOW}[SKIP]${NC} $1"
}

# Check if we're in the right directory (should have README.md and LICENSE)
check_repository() {
    if [[ ! -f "README.md" ]] || [[ ! -f "LICENSE" ]]; then
        log_error "This doesn't appear to be your API repository directory."
        log_info "Please run this script from /home/patrick/github/api (or the equivalent root of your API repo)"
        log_info "Expected files: README.md and LICENSE"
        exit 1
    fi
    log_success "Repository structure validated"
}

# Backup existing file if it's different
backup_if_different() {
    local file="$1"
    local new_content="$2"
    
    if [[ -f "$file" ]]; then
        if ! echo "$new_content" | diff -q "$file" - >/dev/null 2>&1; then
            local backup_file="${file}.backup.$(date +%Y%m%d_%H%M%S)"
            log_warning "File $file exists and differs. Backing up to $backup_file"
            cp "$file" "$backup_file"
            return 0  # File was backed up, proceed with overwrite
        else
            return 1  # File exists and is identical, skip
        fi
    fi
    return 0  # File doesn't exist, proceed with creation
}

# Create directory if it doesn't exist
create_dir() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
        log_success "Created directory: $dir"
    else
        log_skip "Directory already exists: $dir"
    fi
}

# Create file with content if it doesn't exist or is different
create_file() {
    local file="$1"
    local content="$2"
    local description="$3"
    
    if backup_if_different "$file" "$content"; then
        echo "$content" > "$file"
        log_success "Created/Updated: $file ($description)"
    else
        log_skip "File unchanged: $file ($description)"
    fi
}

# Main setup function
main() {
    log_info "🚀 Patrick's Topshelf API Smart Setup Script"
    log_info "============================================="
    
    # Validate repository
    check_repository
    
    # Create directory structure
    log_info "📁 Creating directory structure..."
    create_dir ".github"
    create_dir ".github/workflows"
    create_dir "docs"
    create_dir "src"
    create_dir "src/api"
    create_dir "src/ws"
    create_dir "systemd"
    create_dir "build"  # Will be gitignored but needed for local dev
    
    # Package.json
    log_info "📦 Setting up package.json..."
    PACKAGE_JSON='{
  "name": "topshelf-api",
  "version": "1.0.0",
  "description": "Production-ready TypeScript REST API and WebSocket server for DigitalOcean droplets",
  "main": "build/server.js",
  "scripts": {
    "build": "tsc",
    "start": "node build/server.js",
    "dev": "ts-node src/server.ts",
    "lint": "eslint src --ext .ts",
    "lint:fix": "eslint src --ext .ts --fix",
    "test": "echo \"Error: no test specified\" && exit 1",
    "clean": "rm -rf build"
  },
  "keywords": [
    "typescript",
    "nodejs",
    "express",
    "websocket",
    "api",
    "digitalocean",
    "systemd"
  ],
  "author": "Patrick Craven <patrick@topshelfservicepros.com>",
  "license": "MIT",
  "engines": {
    "node": ">=16.0.0",
    "npm": ">=8.0.0"
  },
  "dependencies": {
    "cors": "^2.8.5",
    "dotenv": "^16.0.0",
    "express": "^4.18.0",
    "ws": "^8.13.0"
  },
  "devDependencies": {
    "@types/cors": "^2.8.13",
    "@types/express": "^4.17.17",
    "@types/node": "^18.15.0",
    "@types/ws": "^8.5.4",
    "@typescript-eslint/eslint-plugin": "^5.57.0",
    "@typescript-eslint/parser": "^5.57.0",
    "eslint": "^8.37.0",
    "ts-node": "^10.9.0",
    "typescript": "^5.0.0"
  },
  "repository": {
    "type": "git",
    "url": "git+https://github.com/PatrickCraven/api.git"
  },
  "bugs": {
    "url": "https://github.com/PatrickCraven/api/issues"
  },
  "homepage": "https://github.com/PatrickCraven/api#readme"
}'
    create_file "package.json" "$PACKAGE_JSON" "Node.js package configuration"
    
    # TypeScript config
    log_info "🔧 Setting up TypeScript configuration..."
    TSCONFIG='{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "rootDir": "./src",
    "outDir": "./build",
    "strict": true,
    "esModuleInterop": true,
    "forceConsistentCasingInFileNames": true,
    "skipLibCheck": true,
    "resolveJsonModule": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "build"]
}'
    create_file "tsconfig.json" "$TSCONFIG" "TypeScript configuration"
    
    # ESLint config
    log_info "🔍 Setting up ESLint configuration..."
    ESLINTRC='{
  "parser": "@typescript-eslint/parser",
  "parserOptions": {
    "project": "./tsconfig.json",
    "sourceType": "module"
  },
  "plugins": ["@typescript-eslint"],
  "extends": [
    "eslint:recommended",  
    "@typescript-eslint/recommended"
  ],
  "rules": {
    "@typescript-eslint/no-explicit-any": "error",
    "@typescript-eslint/explicit-function-return-type": "warn"
  },
  "env": {
    "node": true,
    "es2020": true
  }
}'
    create_file ".eslintrc.json" "$ESLINTRC" "ESLint configuration"
    
    # Environment template
    log_info "🌍 Setting up environment template..."
    ENV_EXAMPLE='# Server Configuration
PORT=3000
NODE_ENV=production

# Add your custom environment variables here
# DATABASE_URL=postgresql://username:password@localhost:5432/database_name
# JWT_SECRET=your-super-secret-jwt-key
# API_KEY=your-api-key'
    create_file ".env.example" "$ENV_EXAMPLE" "Environment template"
    
    # Enhanced .gitignore
    log_info "🚫 Setting up .gitignore..."
    GITIGNORE='# Dependencies
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Build output
build/
dist/

# Environment files
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# Logs
logs/
*.log

# Runtime data
pids/
*.pid
*.seed

# Coverage directory used by tools like istanbul
coverage/

# nyc test coverage
.nyc_output/

# ESLint cache
.eslintcache

# Optional npm cache directory
.npm

# Optional REPL history
.node_repl_history

# Output of npm pack
*.tgz

# Yarn Integrity file
.yarn-integrity

# Editor directories and files
.vscode/
.idea/
*.swp
*.swo
*~'
    
    # Only update .gitignore if it doesn't exist or is missing key entries
    if [[ ! -f ".gitignore" ]] || ! grep -q "node_modules" .gitignore 2>/dev/null; then
        create_file ".gitignore" "$GITIGNORE" "Git ignore rules"
    else
        log_skip "File unchanged: .gitignore (appears to be properly configured)"
    fi
    
    # Source files
    log_info "📝 Creating TypeScript source files..."
    
    # Config file
    CONFIG_TS='import dotenv from "dotenv";
dotenv.config();

export const PORT: string | number = process.env.PORT || 3000;
export const NODE_ENV: string = process.env.NODE_ENV || "development";'
    create_file "src/config.ts" "$CONFIG_TS" "Configuration module"
    
    # API routes
    ROUTES_TS='import { Router, Request, Response } from "express";

const router = Router();

// Health check endpoint
router.get("/status", (req: Request, res: Response): void => {
  res.json({  
    status: "ok",  
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: process.env.NODE_ENV || "development"
  });
});

// Server info endpoint
router.get("/info", (req: Request, res: Response): void => {
  res.json({
    name: "Topshelf API Server",
    version: "1.0.0",
    description: "REST API and WebSocket server by Patrick Craven",
    endpoints: {
      status: "/api/status",
      info: "/api/info"
    },
    websocket: {
      url: "ws://localhost:3000",
      description: "Real-time WebSocket connection"
    }
  });
});

export default router;'
    create_file "src/api/routes.ts" "$ROUTES_TS" "API routes"
    
    # WebSocket handler
    WS_HANDLER_TS='import { WebSocketServer, WebSocket } from "ws";
import { Server as HTTPServer } from "http";

interface ClientMessage {
  type: string;
  data?: any;
  timestamp?: string;
}

export function setupWebSocket(server: HTTPServer): WebSocketServer {
  const wss = new WebSocketServer({ server });

  wss.on("connection", (ws: WebSocket, req) => {
    const clientIP = req.socket.remoteAddress;
    console.log(`[WebSocket] New connection from ${clientIP}`);

    // Send welcome message
    ws.send(JSON.stringify({
      type: "welcome",
      message: "Connected to Patrick'\''s Topshelf WebSocket server",
      timestamp: new Date().toISOString()
    }));

    // Handle incoming messages
    ws.on("message", (data: Buffer) => {
      try {
        const message: ClientMessage = JSON.parse(data.toString());
        console.log(`[WebSocket] Received:`, message);

        // Handle different message types
        switch (message.type) {
          case "ping":
            ws.send(JSON.stringify({
              type: "pong",
              timestamp: new Date().toISOString()
            }));
            break;
          
          case "broadcast":
            // Broadcast to all connected clients
            wss.clients.forEach((client) => {
              if (client !== ws && client.readyState === WebSocket.OPEN) {
                client.send(JSON.stringify({
                  type: "broadcast",
                  message: message.data,
                  from: "server",
                  timestamp: new Date().toISOString()
                }));
              }
            });
            break;

          default:
            // Echo message back with timestamp
            ws.send(JSON.stringify({
              type: "echo",
              originalMessage: message,
              timestamp: new Date().toISOString(),
              echo: `Server received: ${JSON.stringify(message)}`
            }));
        }
      } catch (error) {
        console.error("[WebSocket] Error parsing message:", error);
        ws.send(JSON.stringify({
          type: "error",
          message: "Invalid JSON format",
          timestamp: new Date().toISOString()
        }));
      }
    });

    // Handle connection close
    ws.on("close", (code: number, reason: Buffer) => {
      console.log(`[WebSocket] Connection closed: ${code} - ${reason.toString()}`);
    });

    // Handle errors
    ws.on("error", (error: Error) => {
      console.error("[WebSocket] Connection error:", error);
    });
  });

  console.log("[WebSocket] Server initialized and ready");
  return wss;
}'
    create_file "src/ws/handler.ts" "$WS_HANDLER_TS" "WebSocket handler"
    
    # Main server file
    SERVER_TS='import express, { Application } from "express";
import http from "http";
import cors from "cors";
import routes from "./api/routes";
import { setupWebSocket } from "./ws/handler";
import { PORT, NODE_ENV } from "./config";

// Create Express application
const app: Application = express();

// Middleware
app.use(cors({
  origin: "*", // Configure this for production (e.g., "https://yourfrontend.com")
  methods: ["GET", "POST", "PUT", "DELETE"],
  allowedHeaders: ["Content-Type", "Authorization"]
}));

app.use(express.json({ limit: "10mb" }));
app.use(express.urlencoded({ extended: true }));

// API routes
app.use("/api", routes);

// Root endpoint
app.get("/", (req, res) => {
  res.json({
    message: "🚀 Patrick'\''s Topshelf API Server is running!",
    status: "ok",
    timestamp: new Date().toISOString(),
    environment: NODE_ENV,
    author: "Patrick Craven",
    endpoints: {
      api: "/api",
      status: "/api/status",
      info: "/api/info",
      websocket: "ws://localhost:3000" // This will be your server's public IP/domain
    }
  });
});

// Create HTTP server
const server = http.createServer(app);

// Setup WebSocket
setupWebSocket(server);

// Start server - IMPORTANT: bind to 0.0.0.0 for external access
server.listen(Number(PORT), "0.0.0.0", () => {
  console.log(`🚀 Patrick'\''s REST API & WebSocket server running on port ${PORT}`);
  console.log(`🌐 Environment: ${NODE_ENV}`);
  console.log(`📡 API endpoint: http://localhost:${PORT}/api`);
  console.log(`🔌 WebSocket: ws://localhost:${PORT}`);
  console.log(`👨‍💻 Built by Patrick Craven`);
});

// Graceful shutdown
process.on("SIGTERM", () => {
  console.log("SIGTERM received, shutting down gracefully");
  server.close(() => {
    console.log("Server closed");
    process.exit(0);
  });
});

process.on("SIGINT", () => {
  console.log("SIGINT received, shutting down gracefully");
  server.close(() => {
    console.log("Server closed");
    process.exit(0);
  });
});'
    create_file "src/server.ts" "$SERVER_TS" "Main server file"
    
    # Systemd service
    log_info "⚙️ Setting up systemd service..."
    SYSTEMD_SERVICE='[Unit]
Description=Patrick'\''s Topshelf API & WebSocket Server
After=network.target
StartLimitIntervalSec=0

[Service]
Type=simple
Restart=always
RestartSec=1
User=nodeuser
WorkingDirectory=/home/nodeuser/topshelf-api
ExecStart=/usr/bin/node /home/nodeuser/topshelf-api/build/server.js
Environment=NODE_ENV=production

# Security settings
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=/home/nodeuser/topshelf-api
# Note: If your app needs to write elsewhere, add paths here.

[Install]
WantedBy=multi-user.target'
    create_file "systemd/topshelf-api.service" "$SYSTEMD_SERVICE" "Systemd service definition"
    
    # GitHub Actions CI
    log_info "🔄 Setting up GitHub Actions..."
    CI_YML='name: CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    strategy:
      matrix:
        node-version: [16.x, 18.x, 20.x]
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Use Node.js ${{ matrix.node-version }}
      uses: actions/setup-node@v3
      with:
        node-version: ${{ matrix.node-version }}
        cache: '\''npm'\''
    
    - name: Install dependencies
      run: npm ci
    
    - name: Run ESLint
      run: npm run lint
    
    - name: Build TypeScript
      run: npm run build
    
    - name: Test build output
      run: |
        if [ ! -f "build/server.js" ]; then
          echo "Build failed - server.js not found"
          exit 1
        fi
        echo "✅ Build successful - server.js created"

  deploy:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == '\''refs/heads/main'\''
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Deploy to DigitalOcean
      uses: appleboy/ssh-action@v0.1.6
      with:
        host: ${{ secrets.DROPLET_IP }}
        username: root # Or the nodeuser if you configure SSH for it
        key: ${{ secrets.DROPLET_SSH_KEY }}
        script: |
          # The install.sh handles user creation and initial setup.
          # For updates, pull and restart.
          cd /home/nodeuser/topshelf-api # Change to the app's user directory
          git pull origin main
          npm install --production
          npm run build
          sudo systemctl restart topshelf-api
          sudo systemctl status topshelf-api
          echo "Deployment completed!"'
    create_file ".github/workflows/ci.yml" "$CI_YML" "GitHub Actions CI/CD"
    
    # Security workflow
    SECURITY_YML='name: Security Audit

on:
  schedule:
    - cron: '\''0 0 * * 1'\''  # Weekly on Monday
  push:
    branches: [ main ]

jobs:
  security:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Use Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '\''18'\''
        cache: '\''npm'\''
    
    - name: Install dependencies
      run: npm ci
    
    - name: Run security audit
      run: npm audit --audit-level high
      continue-on-error: true
    
    - name: Check for vulnerabilities
      run: npm audit --audit-level critical'
    create_file ".github/workflows/security.yml" "$SECURITY_YML" "Security audit workflow"
    
    # API Documentation
    log_info "📚 Setting up documentation..."
    API_DOC='# Topshelf API Documentation

**Author:** Patrick Craven  
**Base URL:** `http://your-server-ip:3000`

## REST API Endpoints

### Root Endpoint
**GET** `/`

Returns server information and available endpoints.

### Health Check
**GET** `/api/status`

Returns server status and uptime information.

### Server Information
**GET** `/api/info`

Returns detailed server information.

## WebSocket API

### Connection
```javascript
const ws = new WebSocket('\''ws://your-server-ip:3000'\'');
