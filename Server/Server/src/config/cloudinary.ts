import { v2 as cloudinary } from "cloudinary";
import streamifier from "streamifier";
import dotenv from "dotenv";

dotenv.config();

// PENTING: cloudinary.config() tanpa argumen mengandalkan SDK mem-parse
// CLOUDINARY_URL otomatis SAAT MODULE DI-IMPORT — tapi import selalu
// dieksekusi SEBELUM dotenv.config() sempat mengisi process.env (karena
// semua `import`/`require` di-hoist ke atas file oleh compiler). Akibatnya
// nilai CLOUDINARY_URL yang terbaca kosong/undefined walau .env sudah benar.
// Makanya di sini kita parse manual, dieksekusi setelah dotenv.config().
const cloudinaryUrl = process.env.CLOUDINARY_URL;
const parsed = cloudinaryUrl?.match(/^cloudinary:\/\/([^:]+):([^@]+)@(.+)$/);

if (parsed) {
  const [, apiKey, apiSecret, cloudName] = parsed;
  cloudinary.config({
    cloud_name: cloudName,
    api_key: apiKey,
    api_secret: apiSecret,
  });
  console.log(`[Cloudinary] Terkonfigurasi dengan cloud_name: ${cloudName}`);
} else {
  // Fallback: setup manual dari dashboard (3 variabel terpisah)
  cloudinary.config({
    cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
    api_key: process.env.CLOUDINARY_API_KEY,
    api_secret: process.env.CLOUDINARY_API_SECRET,
  });
  console.log(
    `[Cloudinary] Terkonfigurasi (manual) dengan cloud_name: ${process.env.CLOUDINARY_CLOUD_NAME}`
  );
}

// Upload buffer (dari multer memoryStorage) ke Cloudinary, dibungkus sebagai Promise
export function uploadBufferToCloudinary(
  buffer: Buffer,
  folder = "levelup/posts"
): Promise<{ url: string; publicId: string }> {
  return new Promise((resolve, reject) => {
    const stream = cloudinary.uploader.upload_stream(
      { folder },
      (error, result) => {
        if (error || !result) return reject(error);
        resolve({ url: result.secure_url, publicId: result.public_id });
      }
    );
    streamifier.createReadStream(buffer).pipe(stream);
  });
}

export async function deleteFromCloudinary(publicId: string) {
  try {
    await cloudinary.uploader.destroy(publicId);
  } catch (err) {
    console.error("Gagal menghapus gambar di Cloudinary:", err);
  }
}

export default cloudinary;
