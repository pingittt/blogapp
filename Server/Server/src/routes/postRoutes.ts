import { Router } from "express";
import {
  getPosts,
  getPostById,
  getMyPosts,
  createPost,
  updatePost,
  deletePost,
  deletePostImage,
} from "../controllers/postController";
import { getComments, createComment } from "../controllers/commentController";
import { requireAuth } from "../middleware/auth";
import { uploadImages } from "../middleware/upload";

const router = Router();

router.get("/", getPosts);
router.get("/mine", requireAuth, getMyPosts);
router.get("/:id", getPostById);
router.post("/", requireAuth, uploadImages, createPost);
router.put("/:id", requireAuth, uploadImages, updatePost);
router.delete("/:id", requireAuth, deletePost);
router.delete("/:postId/images/:imageId", requireAuth, deletePostImage);

// Komentar bersarang di bawah post: /api/posts/:postId/comments
router.get("/:postId/comments", getComments);
router.post("/:postId/comments", requireAuth, createComment);

export default router;
