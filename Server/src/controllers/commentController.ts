import { Request, Response } from "express";
import { eq, and, asc } from "drizzle-orm";
import { db } from "../config/db";
import { commentsTable, usersTable } from "../config/schema";

// GET /api/posts/:postId/comments -> semua komentar pada satu post
export async function getComments(req: Request, res: Response) {
  const postId = Number(req.params.postId);

  const comments = await db
    .select({
      id: commentsTable.id,
      comment: commentsTable.comment,
      createdAt: commentsTable.createdAt,
      userId: commentsTable.userId,
      author: usersTable.username,
    })
    .from(commentsTable)
    .innerJoin(usersTable, eq(commentsTable.userId, usersTable.id))
    .where(eq(commentsTable.postId, postId))
    .orderBy(asc(commentsTable.createdAt));

  res.status(200).json(comments);
}

// POST /api/posts/:postId/comments -> tambah komentar baru (butuh login)
export async function createComment(req: Request, res: Response) {
  const postId = Number(req.params.postId);
  const { comment } = req.body;

  if (!comment || !comment.trim()) {
    return res.status(400).json({ message: "Komentar tidak boleh kosong" });
  }

  const [result] = await db.insert(commentsTable).values({
    postId,
    userId: req.user!.id,
    comment,
  });

  const insertId = (result as any).insertId;
  const [created] = await db
    .select()
    .from(commentsTable)
    .where(eq(commentsTable.id, insertId));

  res.status(201).json(created);
}

// DELETE /api/comments/:id -> hapus komentar (pemilik komentar atau admin)
export async function deleteComment(req: Request, res: Response) {
  const id = Number(req.params.id);

  const [existing] = await db.select().from(commentsTable).where(eq(commentsTable.id, id));
  if (!existing) {
    return res.status(404).json({ message: "Komentar tidak ditemukan" });
  }
  if (existing.userId !== req.user!.id && req.user!.role !== "admin") {
    return res.status(403).json({ message: "Kamu tidak punya izin menghapus komentar ini" });
  }

  await db.delete(commentsTable).where(eq(commentsTable.id, id));
  res.status(200).json({ message: "Komentar berhasil dihapus" });
}
