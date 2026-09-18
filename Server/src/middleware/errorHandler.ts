import { Request, Response, NextFunction } from "express";

// Middleware error handler global. Diletakkan paling akhir di index.ts.
export function errorHandler(
  err: any,
  req: Request,
  res: Response,
  next: NextFunction
) {
  console.error(err);
  const status = err.status || 500;
  res.status(status).json({ message: err.message || "Terjadi kesalahan pada server" });
}
