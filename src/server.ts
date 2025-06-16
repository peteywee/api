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
