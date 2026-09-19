import { Request, Response } from "express";
import { desc, eq, sql } from "drizzle-orm";
import { db } from "../config/db";
import { postsTable, usersTable } from "../config/schema";
import { colorForCategory, iconForCategory } from "../utils/categoryStyle";

// GET /api/recommendations -> kartu "For You", diambil dari POST ASLI (bukan data
// dummy) supaya gambarnya nyata dan tidak melanggar hak cipta (gambar milik user
// yang upload sendiri). Post dengan gambar diprioritaskan tampil duluan.
export async function getRecommendations(req: Request, res: Response) {
  const posts = await db
    .select({
      id: postsTable.id,
      title: postsTable.title,
      content: postsTable.content,
      imageUrl: postsTable.imageUrl,
      category: postsTable.category,
    })
    .from(postsTable)
    .innerJoin(usersTable, eq(postsTable.userId, usersTable.id))
    .where(eq(postsTable.status, "published"))
    .orderBy(
      sql`${postsTable.imageUrl} IS NULL`, // yang ada gambar duluan
      desc(postsTable.createdAt)
    )
    .limit(6);

  const recommendations = posts.map((p) => ({
    id: p.id,
    title: p.title,
    teks: p.content.length > 60 ? `${p.content.slice(0, 60)}...` : p.content,
    category: p.category,
    imageUrl: p.imageUrl,
    iconName: iconForCategory(p.category),
    colorHex: colorForCategory(p.category),
  }));

  res.status(200).json(recommendations);
}
