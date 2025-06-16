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
