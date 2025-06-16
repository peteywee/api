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
