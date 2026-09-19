import { Router } from "express";
import { register, login, me, updateProfile, updateAvatar } from "../controllers/authController";
import { requireAuth } from "../middleware/auth";
import { upload } from "../middleware/upload";

const router = Router();

router.post("/register", register);
router.post("/login", login);
router.get("/me", requireAuth, me);
router.put("/me", requireAuth, updateProfile);
router.put("/me/avatar", requireAuth, upload.single("avatar"), updateAvatar);

export default router;
