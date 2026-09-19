import { Request, Response } from "express";
import bcrypt from "bcryptjs";
import { eq } from "drizzle-orm";
import { db } from "../config/db";
import { usersTable } from "../config/schema";
import { signToken } from "../utils/jwt";
import { uploadBufferToCloudinary, deleteFromCloudinary } from "../config/cloudinary";

export async function register(req: Request, res: Response) {
  const { username, email, password } = req.body;

  if (!username || !email || !password) {
    return res.status(400).json({ message: "Username, email, dan password wajib diisi" });
  }
  if (password.length < 6) {
    return res.status(400).json({ message: "Password minimal 6 karakter" });
  }

  const existing = await db
    .select()
    .from(usersTable)
    .where(eq(usersTable.email, email));

  if (existing.length > 0) {
    return res.status(400).json({ message: "Email sudah terdaftar" });
  }

  const hashed = await bcrypt.hash(password, 10);

  const [result] = await db.insert(usersTable).values({
    username,
    email,
    password: hashed,
  });

  const insertId = (result as any).insertId;

  const token = signToken({ id: insertId, role: "user" });

  res.status(201).json({
    message: "Registrasi berhasil",
    token,
    user: { id: insertId, username, email, role: "user", avatarUrl: null },
  });
}

export async function login(req: Request, res: Response) {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ message: "Email dan password wajib diisi" });
  }

  const [user] = await db
    .select()
    .from(usersTable)
    .where(eq(usersTable.email, email));

  if (!user) {
    return res.status(401).json({ message: "Email atau password salah" });
  }

  const match = await bcrypt.compare(password, user.password);
  if (!match) {
    return res.status(401).json({ message: "Email atau password salah" });
  }

  const token = signToken({ id: user.id, role: user.role });

  res.status(200).json({
    message: "Login berhasil",
    token,
    user: {
      id: user.id,
      username: user.username,
      email: user.email,
      role: user.role,
      avatarUrl: user.avatarUrl,
    },
  });
}

// PUT /api/auth/me -> update username dan/atau password (fitur "Pengaturan Akun")
export async function updateProfile(req: Request, res: Response) {
  const { username, currentPassword, newPassword } = req.body;

  const [existing] = await db
    .select()
    .from(usersTable)
    .where(eq(usersTable.id, req.user!.id));

  if (!existing) {
    return res.status(404).json({ message: "User tidak ditemukan" });
  }

  const updates: { username?: string; password?: string } = {};

  if (username !== undefined) {
    if (!username.trim()) {
      return res.status(400).json({ message: "Username tidak boleh kosong" });
    }
    updates.username = username.trim();
  }

  if (newPassword) {
    if (!currentPassword) {
      return res
        .status(400)
        .json({ message: "Password saat ini wajib diisi untuk mengganti password" });
    }
    const match = await bcrypt.compare(currentPassword, existing.password);
    if (!match) {
      return res.status(401).json({ message: "Password saat ini salah" });
    }
    if (newPassword.length < 6) {
      return res.status(400).json({ message: "Password baru minimal 6 karakter" });
    }
    updates.password = await bcrypt.hash(newPassword, 10);
  }

  if (Object.keys(updates).length === 0) {
    return res.status(400).json({ message: "Tidak ada perubahan yang dikirim" });
  }

  await db.update(usersTable).set(updates).where(eq(usersTable.id, req.user!.id));

  const [user] = await db
    .select({
      id: usersTable.id,
      username: usersTable.username,
      email: usersTable.email,
      role: usersTable.role,
      avatarUrl: usersTable.avatarUrl,
    })
    .from(usersTable)
    .where(eq(usersTable.id, req.user!.id));

  res.status(200).json({ message: "Profil berhasil diperbarui", user });
}

// PUT /api/auth/me/avatar -> ganti foto profil (multipart, field "avatar")
export async function updateAvatar(req: Request, res: Response) {
  const file = req.file as Express.Multer.File | undefined;
  if (!file) {
    return res.status(400).json({ message: "File gambar wajib diupload" });
  }

  const [existing] = await db
    .select()
    .from(usersTable)
    .where(eq(usersTable.id, req.user!.id));

  if (!existing) {
    return res.status(404).json({ message: "User tidak ditemukan" });
  }

  const uploaded = await uploadBufferToCloudinary(file.buffer, "levelup/avatars");

  if (existing.avatarPublicId) {
    await deleteFromCloudinary(existing.avatarPublicId);
  }

  await db
    .update(usersTable)
    .set({ avatarUrl: uploaded.url, avatarPublicId: uploaded.publicId })
    .where(eq(usersTable.id, req.user!.id));

  res.status(200).json({
    message: "Foto profil berhasil diperbarui",
    avatarUrl: uploaded.url,
  });
}

// GET /api/auth/me -> ambil profil user yang sedang login (butuh token)
export async function me(req: Request, res: Response) {
  const [user] = await db
    .select({
      id: usersTable.id,
      username: usersTable.username,
      email: usersTable.email,
      role: usersTable.role,
      avatarUrl: usersTable.avatarUrl,
    })
    .from(usersTable)
    .where(eq(usersTable.id, req.user!.id));

  if (!user) {
    return res.status(404).json({ message: "User tidak ditemukan" });
  }
  res.status(200).json(user);
}
