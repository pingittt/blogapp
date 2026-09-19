import { Request, Response } from "express";
import { eq, desc } from "drizzle-orm";
import { db } from "../config/db";
import { commentsTable, postsTable, usersTable } from "../config/schema";

// GET /api/notifications -> komentar terbaru pada post MILIK user yang sedang login.
// Ini notifikasi asli (bukan dummy): kalau ada orang komen di post kamu, muncul di sini.
export async function getMyNotifications(req: Request, res: Response) {
  const notifications = await db
    .select({
      id: commentsTable.id,
      comment: commentsTable.comment,
      createdAt: commentsTable.createdAt,
      postId: postsTable.id,
      postTitle: postsTable.title,
      commenter: usersTable.username,
    })
    .from(commentsTable)
    .innerJoin(postsTable, eq(commentsTable.postId, postsTable.id))
    .innerJoin(usersTable, eq(commentsTable.userId, usersTable.id))
    .where(eq(postsTable.userId, req.user!.id))
    .orderBy(desc(commentsTable.createdAt))
    .limit(30);

  res.status(200).json(notifications);
}
