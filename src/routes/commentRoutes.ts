import { Router } from "express";
import { deleteComment } from "../controllers/commentController";
import { requireAuth } from "../middleware/auth";

const router = Router();

router.delete("/:id", requireAuth, deleteComment);

export default router;
