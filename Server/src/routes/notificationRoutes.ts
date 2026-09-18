import { Router } from "express";
import { getMyNotifications } from "../controllers/notificationController";
import { requireAuth } from "../middleware/auth";

const router = Router();

router.get("/", requireAuth, getMyNotifications);

export default router;
