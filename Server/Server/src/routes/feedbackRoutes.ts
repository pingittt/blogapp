import { Router } from "express";
import { createFeedback } from "../controllers/feedbackController";
import { optionalAuth } from "../middleware/auth";

const router = Router();

router.post("/", optionalAuth, createFeedback);

export default router;
