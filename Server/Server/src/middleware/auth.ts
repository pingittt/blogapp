import { Request, Response, NextFunction } from "express";
import { verifyToken } from "../utils/jwt";

// Extend Express Request agar bisa menyimpan data user yang sedang login
declare global {
  namespace Express {
    interface Request {
      user?: { id: number; role: "user" | "admin" };
    }
  }
}

// Middleware wajib login: menolak request tanpa token yang valid
export function requireAuth(req: Request, res: Response, next: NextFunction) {
  const header = req.headers.authorization;

  if (!header || !header.startsWith("Bearer ")) {
    return res.status(401).json({ message: "Token tidak ditemukan" });
  }

  const token = header.split(" ")[1];

  try {
    const payload = verifyToken(token);
    req.user = { id: payload.id, role: payload.role };
    next();
  } catch (err) {
    return res.status(401).json({ message: "Token tidak valid atau sudah kedaluwarsa" });
  }
}

// Middleware opsional: kalau ada token valid, req.user diisi; kalau tidak ada
// token (atau tidak valid), tetap lanjut sebagai tamu (tidak menolak request).
export function optionalAuth(req: Request, res: Response, next: NextFunction) {
  const header = req.headers.authorization;
  if (header && header.startsWith("Bearer ")) {
    try {
      const payload = verifyToken(header.split(" ")[1]);
      req.user = { id: payload.id, role: payload.role };
    } catch {
      // token tidak valid, lanjut saja sebagai tamu
    }
  }
  next();
}

// Middleware khusus admin: dipakai setelah requireAuth
export function requireAdmin(req: Request, res: Response, next: NextFunction) {
  if (req.user?.role !== "admin") {
    return res.status(403).json({ message: "Akses ditolak, khusus admin" });
  }
  next();
}
