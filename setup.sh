#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

# --- Customizable Variables ---
# IMPORTANT: Change these to match your server environment.
PROJECT_USER="patrick" # The linux user on your server that will run the service.
PROJECT_PATH="/home/patrick/github/api" # The absolute path where the project will live on your server.
COPYRIGHT_HOLDER="Patrick" # The name for the copyright holder in the LICENSE file.
# -----------------------------

# --- Helper Functions for Logging ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

log_info() {
  echo -e "${YELLOW}ℹ  $1${NC}"
}

log_success() {
  echo -e "${GREEN}✅ $1${NC}"
}

log_error() {
  echo -e "${RED}❌ $1${NC}"
  exit 1
}

# --- File Creation Function ---
# $1: File path
# $2: File content
# $3: Log message
create_file() {
  # Create directory if it doesn't exist
  mkdir -p "$(dirname "$1")"
  # Write content to file
  echo -e "$2" > "$1"
  log_success "Created $1: $3"
}

# --- Script Start ---
log_info "🚀 Starting TypeScript API scaffolding..."

# --- package.json ---
PACKAGE_JSON=$(cat <<'EOF'
{
  "name": "topshelf-api",
  "version": "1.0.0",
  "description": "Production-ready TypeScript REST and WebSocket server",
  "main": "build/server.js",
  "scripts": {
    "build": "tsc",
    "start": "node build/server.js",
    "dev": "ts-node-dev --respawn --transpile-only src/server.ts",
    "lint": "eslint . --ext .ts",
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "keywords": ["typescript", "express", "websocket", "systemd"],
  "author": "Patrick",
  "license": "MIT",
  "dependencies": {
    "cors": "^2.8.5",
    "dotenv": "^16.3.1",
    "express": "^4.18.2",
    "ws": "^8.14.2"
  },
  "devDependencies": {
    "@types/cors": "^2.8.15",
    "@types/express": "^4.17.20",
    "@types/node": "^20.8.10",
    "@types/ws": "^8.5.8",
    "@typescript-eslint/eslint-plugin": "^6.9.1",
    "@typescript-eslint/parser": "^6.9.1",
    "eslint": "^8.52.0",
    "ts-node-dev": "^2.0.0",
    "typescript": "^5.2.2"
  }
}
EOF
)
create_file "package.json" "$PACKAGE_JSON" "Project dependencies and scripts"

# --- tsconfig.json ---
TSCONFIG_JSON=$(cat <<'EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "rootDir": "src",
    "outDir": "build",
    "esModuleInterop": true,
    "forceConsistentCasingInFileNames": true,
    "strict": true,
    "skipLibCheck": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "**/*.spec.ts"]
}
EOF
)
create_file "tsconfig.json" "$TSCONFIG_JSON" "TypeScript compiler configuration"

# --- .eslintrc.js ---
ESLINT_RC=$(cat <<'EOF'
module.exports = {
  parser: '@typescript-eslint/parser',
  extends: [
    'plugin:@typescript-eslint/recommended',
  ],
  parserOptions: {
    ecmaVersion: 2020,
    sourceType: 'module',
  },
  rules: {
    // Add custom rules here
  },
};
EOF
)
create_file ".eslintrc.js" "$ESLINT_RC" "ESLint configuration for code quality"

# --- .gitignore ---
GITIGNORE_CONTENT=$(cat <<'EOF'
# Dependencies
/node_modules

# Build output
/build

# Environment variables
.env
.env.*
!.env.example

# Logs
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*
lerna-debug.log*

# OS generated files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db
EOF
)
create_file ".gitignore" "$GITIGNORE_CONTENT" "Git ignore rules"

# --- .env.example ---
ENV_EXAMPLE_CONTENT=$(cat <<'EOF'
# Server Configuration
# The port the application will listen on. Default is 8080.
PORT=8080

# Add other environment variables here
# E.g., DATABASE_URL=...
EOF
)
create_file ".env.example" "$ENV_EXAMPLE_CONTENT" "Example environment variables"

# --- Source Files ---

# src/config.ts
CONFIG_TS=$(cat <<'EOF'
import dotenv from "dotenv";

dotenv.config();

export const PORT = process.env.PORT || 8080;
EOF
)
create_file "src/config.ts" "$CONFIG_TS" "Centralized configuration loader"

# src/api/routes.ts
API_ROUTES_TS=$(cat <<'EOF'
import { Router } from "express";

const router = Router();

router.get("/health", (req, res) => {
  res.status(200).json({ status: "UP" });
});

// Add more REST endpoints here
// Example:
// router.get('/users', (req, res) => { ... });

export default router;
EOF
)
create_file "src/api/routes.ts" "$API_ROUTES_TS" "REST API route definitions"

# src/ws/handler.ts
WS_HANDLER_TS=$(cat <<'EOF'
import { WebSocketServer, WebSocket } from "ws";
import type { Server } from "http";

export function setupWebSocket(server: Server) {
  const wss = new WebSocketServer({ server });

  wss.on("connection", (ws: WebSocket) => {
    console.log("🔌 New client connected to WebSocket");

    ws.on("message", (message: string) => {
      console.log(`Received message: ${message}`);
      // Broadcast to all clients
      wss.clients.forEach(client => {
        if (client !== ws && client.readyState === WebSocket.OPEN) {
          client.send(`Broadcast: ${message}`);
        }
      });
    });

    ws.on("close", () => {
      console.log("Client disconnected");
    });

    ws.on("error", (error) => {
      console.error("WebSocket error:", error);
    });

    ws.send("Welcome to the WebSocket server!");
  });

  console.log("✅ WebSocket server setup complete.");
}
EOF
)
create_file "src/ws/handler.ts" "$WS_HANDLER_TS" "WebSocket connection handler"

# --- Final Scaffolding Files ---

# src/server.ts
SERVER_TS=$(cat <<'EOF'
import express from "express";
import http from "http";
import cors from "cors";
import { PORT } from "./config";
import apiRoutes from "./api/routes";
import { setupWebSocket } from "./ws/handler";

const app = express();
const server = http.createServer(app);

// Middleware
app.use(cors());
app.use(express.json());

// Routes
app.use("/api", apiRoutes);

// WebSocket
setupWebSocket(server);

// Start server
server.listen(PORT, () => {
  console.log(`🚀 Server running on http://localhost:${PORT}`);
});
EOF
)
create_file "src/server.ts" "$SERVER_TS" "Main server entry point"

# systemd/topshelf-api.service
# Template with placeholders to be replaced
SYSTEMD_SERVICE_TEMPLATE=$(cat <<'EOF'
[Unit]
Description=Topshelf API and WebSocket Server
After=network.target

[Service]
Environment=NODE_ENV=production
# The systemd service expects the .env file in /etc/. You can change this path if needed.
EnvironmentFile=/etc/topshelf.env
WorkingDirectory=__PROJECT_PATH__
ExecStart=/usr/bin/node __PROJECT_PATH__/build/server.js
Restart=always
User=__PROJECT_USER__
Group=__PROJECT_USER__

[Install]
WantedBy=multi-user.target
EOF
)
# Process the template, replacing placeholders with variables
PROCESSED_SYSTEMD_SERVICE=$(echo "$SYSTEMD_SERVICE_TEMPLATE" | sed "s|__PROJECT_PATH__|$PROJECT_PATH|g" | sed "s|__PROJECT_USER__|$PROJECT_USER|g")
create_file "systemd/topshelf-api.service" "$PROCESSED_SYSTEMD_SERVICE" "Systemd service for production"

# README.md
README_MD=$(cat <<'EOF'
# Topshelf API

Production-ready TypeScript REST and WebSocket server, deployable to a Linux server (e.g., DigitalOcean) with `systemd`.

## Features

- TypeScript, Express, WebSocket (`ws`)
- `.env`-driven configuration
- Systemd service for production deployment
- ESLint and strict typing for code quality
- Future-proof for CI/CD and further expansion

## Getting Started (Local Development)

1.  **Install dependencies:**
    ```bash
    npm install
    ```

2.  **Create your local environment file:**
    ```bash
    cp .env.example .env
    ```
    *Modify `.env` as needed.*

3.  **Run the development server:**
    ```bash
    npm run dev
    ```
    *The server will be available at `http://localhost:8080` (or your configured `PORT`).*

## Build & Run for Production

1.  **Build the project:**
    ```bash
    npm run build
    ```

2.  **Run the production server:**
    ```bash
    node build/server.js
    ```
    *This is the command that the `systemd` service will run on your server.*

## License

MIT
EOF
)
create_file "README.md" "$README_MD" "Project README"

# LICENSE
LICENSE_CONTENT=$(cat <<EOF
MIT License

Copyright (c) $(date +%Y) $COPYRIGHT_HOLDER

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF
)
create_file "LICENSE" "$LICENSE_CONTENT" "MIT License file"


log_success "🏁 All setup steps completed successfully."
