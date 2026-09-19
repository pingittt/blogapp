import multer from "multer";

// Simpan file di memory sementara, lalu di-upload ke Cloudinary dari controller.
// Batas ukuran 5MB, hanya menerima gambar.
const storage = multer.memoryStorage();

export const upload = multer({
  storage,
  limits: { fileSize: 5 * 1024 * 1024 },
  fileFilter: (req, file, cb) => {
    if (file.mimetype.startsWith("image/")) {
      cb(null, true);
    } else {
      cb(new Error("File harus berupa gambar"));
    }
  },
});

// Dipakai untuk create/update post: menerima beberapa gambar sekaligus (maks 6)
export const uploadImages = upload.array("images", 6);
