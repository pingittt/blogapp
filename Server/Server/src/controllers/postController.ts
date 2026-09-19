import { Request, Response } from "express";
import { eq, asc, desc } from "drizzle-orm";
import { db } from "../config/db";
import { postsTable, usersTable, postImagesTable, POST_CATEGORIES } from "../config/schema";
import { uploadBufferToCloudinary, deleteFromCloudinary } from "../config/cloudinary";

// Ambil semua gambar galeri milik satu post, urut berdasarkan sortOrder
async function getImagesForPost(postId: number) {
  return db
    .select({
      id: postImagesTable.id,
      imageUrl: postImagesTable.imageUrl,
      imagePublicId: postImagesTable.imagePublicId,
    })
    .from(postImagesTable)
    .where(eq(postImagesTable.postId, postId))
    .orderBy(asc(postImagesTable.sortOrder));
}

// GET /api/posts -> semua post yang statusnya published, terbaru dulu
export async function getPosts(req: Request, res: Response) {
  const posts = await db
    .select({
      id: postsTable.id,
      title: postsTable.title,
      content: postsTable.content,
      imageUrl: postsTable.imageUrl,
      category: postsTable.category,
      status: postsTable.status,
      createdAt: postsTable.createdAt,
      updatedAt: postsTable.updatedAt,
      author: usersTable.username,
      authorRole: usersTable.role,
      userId: postsTable.userId,
    })
    .from(postsTable)
    .innerJoin(usersTable, eq(postsTable.userId, usersTable.id))
    .where(eq(postsTable.status, "published"))
    .orderBy(desc(postsTable.createdAt));

  res.status(200).json(posts);
}

// GET /api/posts/:id -> satu post lengkap dengan galeri semua gambarnya
// (images dikirim sebagai {id, imageUrl} supaya frontend bisa hapus per-gambar)
export async function getPostById(req: Request, res: Response) {
  const id = Number(req.params.id);

  const [post] = await db
    .select({
      id: postsTable.id,
      title: postsTable.title,
      content: postsTable.content,
      imageUrl: postsTable.imageUrl,
      category: postsTable.category,
      status: postsTable.status,
      createdAt: postsTable.createdAt,
      updatedAt: postsTable.updatedAt,
      author: usersTable.username,
      authorRole: usersTable.role,
      userId: postsTable.userId,
    })
    .from(postsTable)
    .innerJoin(usersTable, eq(postsTable.userId, usersTable.id))
    .where(eq(postsTable.id, id));

  if (!post) {
    return res.status(404).json({ message: "Post tidak ditemukan" });
  }

  const images = await getImagesForPost(id);
  res.status(200).json({
    ...post,
    images: images.map((i) => ({ id: i.id, imageUrl: i.imageUrl })),
  });
}

// GET /api/posts/mine -> post milik user yang sedang login (untuk halaman "Post saya")
// PENTING: harus ikut sertakan galeri gambar (images), karena ini yang dipakai
// form edit untuk menampilkan & menghapus foto lama.
export async function getMyPosts(req: Request, res: Response) {
  const posts = await db
    .select({
      id: postsTable.id,
      title: postsTable.title,
      content: postsTable.content,
      imageUrl: postsTable.imageUrl,
      category: postsTable.category,
      status: postsTable.status,
      createdAt: postsTable.createdAt,
      updatedAt: postsTable.updatedAt,
      author: usersTable.username,
      authorRole: usersTable.role,
      userId: postsTable.userId,
    })
    .from(postsTable)
    .innerJoin(usersTable, eq(postsTable.userId, usersTable.id))
    .where(eq(postsTable.userId, req.user!.id))
    .orderBy(desc(postsTable.createdAt));

  const postsWithImages = await Promise.all(
    posts.map(async (post) => {
      const images = await getImagesForPost(post.id);
      return { ...post, images: images.map((i) => ({ id: i.id, imageUrl: i.imageUrl })) };
    })
  );

  res.status(200).json(postsWithImages);
}

// POST /api/posts -> buat post baru, boleh upload beberapa gambar sekaligus (field "images")
export async function createPost(req: Request, res: Response) {
  const { title, content } = req.body;
  const rawCategory = req.body.category as string | undefined;
  const category = (POST_CATEGORIES as readonly string[]).includes(rawCategory ?? "")
    ? (rawCategory as (typeof POST_CATEGORIES)[number])
    : "Umum";

  if (!title || !content) {
    return res.status(400).json({ message: "Title dan content wajib diisi" });
  }

  const files = (req.files as Express.Multer.File[] | undefined) || [];
  const uploaded = await Promise.all(
    files.map((file) => uploadBufferToCloudinary(file.buffer))
  );

  const cover = uploaded[0];

  const [result] = await db.insert(postsTable).values({
    userId: req.user!.id,
    title,
    content,
    category,
    imageUrl: cover?.url ?? null,
    imagePublicId: cover?.publicId ?? null,
  });

  const insertId = (result as any).insertId;

  if (uploaded.length > 0) {
    await db.insert(postImagesTable).values(
      uploaded.map((img, index) => ({
        postId: insertId,
        imageUrl: img.url,
        imagePublicId: img.publicId,
        sortOrder: index,
      }))
    );
  }

  const [post] = await db.select().from(postsTable).where(eq(postsTable.id, insertId));
  const images = await getImagesForPost(insertId);

  res.status(201).json({
    ...post,
    images: images.map((i) => ({ id: i.id, imageUrl: i.imageUrl })),
  });
}

// PUT /api/posts/:id -> update post (hanya pemilik post). Gambar baru DITAMBAHKAN
// ke galeri (hapus gambar lama pakai endpoint terpisah DELETE .../images/:imageId).
export async function updatePost(req: Request, res: Response) {
  const id = Number(req.params.id);
  const { title, content } = req.body;
  const rawCategory = req.body.category as string | undefined;

  const [existing] = await db.select().from(postsTable).where(eq(postsTable.id, id));
  if (!existing) {
    return res.status(404).json({ message: "Post tidak ditemukan" });
  }
  if (existing.userId !== req.user!.id && req.user!.role !== "admin") {
    return res.status(403).json({ message: "Kamu tidak punya izin mengubah post ini" });
  }
  if (!title || !content) {
    return res.status(400).json({ message: "Title dan content wajib diisi" });
  }

  const category = (POST_CATEGORIES as readonly string[]).includes(rawCategory ?? "")
    ? (rawCategory as (typeof POST_CATEGORIES)[number])
    : existing.category;

  const files = (req.files as Express.Multer.File[] | undefined) || [];
  const uploaded = await Promise.all(
    files.map((file) => uploadBufferToCloudinary(file.buffer))
  );

  let imageUrl = existing.imageUrl;
  let imagePublicId = existing.imagePublicId;

  if (uploaded.length > 0) {
    const existingImages = await getImagesForPost(id);
    await db.insert(postImagesTable).values(
      uploaded.map((img, index) => ({
        postId: id,
        imageUrl: img.url,
        imagePublicId: img.publicId,
        sortOrder: existingImages.length + index,
      }))
    );
    if (!imageUrl) {
      imageUrl = uploaded[0].url;
      imagePublicId = uploaded[0].publicId;
    }
  }

  await db
    .update(postsTable)
    .set({ title, content, category, imageUrl, imagePublicId })
    .where(eq(postsTable.id, id));

  const [updated] = await db.select().from(postsTable).where(eq(postsTable.id, id));
  const images = await getImagesForPost(id);
  res.status(200).json({
    ...updated,
    images: images.map((i) => ({ id: i.id, imageUrl: i.imageUrl })),
  });
}

// DELETE /api/posts/:id -> soft delete (ubah status jadi "delete")
export async function deletePost(req: Request, res: Response) {
  const id = Number(req.params.id);

  const [existing] = await db.select().from(postsTable).where(eq(postsTable.id, id));
  if (!existing) {
    return res.status(404).json({ message: "Post tidak ditemukan" });
  }
  if (existing.userId !== req.user!.id && req.user!.role !== "admin") {
    return res.status(403).json({ message: "Kamu tidak punya izin menghapus post ini" });
  }

  await db.update(postsTable).set({ status: "delete" }).where(eq(postsTable.id, id));
  res.status(200).json({ message: "Post berhasil dihapus" });
}

// DELETE /api/posts/:postId/images/:imageId -> hapus satu gambar dari galeri
// (dipakai saat edit post: hapus/ganti foto lama)
export async function deletePostImage(req: Request, res: Response) {
  const postId = Number(req.params.postId);
  const imageId = Number(req.params.imageId);

  const [post] = await db.select().from(postsTable).where(eq(postsTable.id, postId));
  if (!post) {
    return res.status(404).json({ message: "Post tidak ditemukan" });
  }
  if (post.userId !== req.user!.id && req.user!.role !== "admin") {
    return res.status(403).json({ message: "Kamu tidak punya izin mengubah post ini" });
  }

  const [image] = await db
    .select()
    .from(postImagesTable)
    .where(eq(postImagesTable.id, imageId));
  if (!image || image.postId !== postId) {
    return res.status(404).json({ message: "Gambar tidak ditemukan" });
  }

  if (image.imagePublicId) {
    await deleteFromCloudinary(image.imagePublicId);
  }
  await db.delete(postImagesTable).where(eq(postImagesTable.id, imageId));

  if (post.imageUrl === image.imageUrl) {
    const remaining = await getImagesForPost(postId);
    await db
      .update(postsTable)
      .set({
        imageUrl: remaining[0]?.imageUrl ?? null,
        imagePublicId: remaining[0]?.imagePublicId ?? null,
      })
      .where(eq(postsTable.id, postId));
  }

  res.status(200).json({ message: "Gambar berhasil dihapus" });
}
