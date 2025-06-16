import { Router } from "express";

const router = Router();

router.get("/health", (req, res) => {
  res.status(200).json({ status: "UP" });
});

// Add more REST endpoints here
// Example:
// router.get('/users', (req, res) => { ... });

export default router;
