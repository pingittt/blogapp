import { Request, Response } from "express";
import { db } from "../config/db";
import { feedbackTable } from "../config/schema";

// POST /api/feedback -> kirim masukan. Boleh anonim (tidak wajib login).
export async function createFeedback(req: Request, res: Response) {
  const { message } = req.body;

  if (!message || !message.trim()) {
    return res.status(400).json({ message: "Masukan tidak boleh kosong" });
  }

  await db.insert(feedbackTable).values({
    userId: req.user?.id ?? null,
    message: message.trim(),
  });

  res.status(201).json({ message: "Terima kasih atas masukanmu!" });
}
