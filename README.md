# BlogAppQa — Express (TypeScript + Drizzle + MySQL) + Flutter

Blog app dengan backend REST API bertipe kuat (TypeScript) dan frontend Flutter.

## Struktur

```
BlogAppQa/
├── Server/                  # Backend REST API
│   ├── src/
│   │   ├── index.ts         # entry point, mount semua route
│   │   ├── config/
│   │   │   ├── db.ts        # koneksi MySQL via Drizzle
│   │   │   ├── schema.ts    # tabel users, posts, comments
│   │   │   └── cloudinary.ts
│   │   ├── controllers/     # authController, postController, commentController, recommendationController
│   │   ├── routes/          # authRoutes, postRoutes, commentRoutes, recommendationRoutes
│   │   ├── middleware/      # auth (JWT), upload (multer), errorHandler
│   │   └── utils/jwt.ts
│   ├── Rekomedasi.json      # data dummy untuk tab "For You"
│   └── .env
└── mobile/                  # Frontend Flutter
    └── lib/
        ├── main.dart
        ├── models/           # Post, Comment, AppUser, Recommendation
        ├── services/         # api_service.dart, auth_service.dart
        └── screens/          # login, register, home (tab), post_detail, post_form
```

## 1. Setup Database

1. Pastikan MySQL jalan lokal (XAMPP/Laragon/dsb), buat database kosong bernama `blogappv1` (atau ganti nama di `.env`).
2. Isi `Server/.env`:
   ```
   DB_HOST=127.0.0.1
   DB_PORT=3306
   DB_USER=root
   DB_PASSWORD=
   DB_NAME=blogappv1

   PORT=3000
   JWT_SECRET=ganti_dengan_string_acak_yang_panjang

   CLOUDINARY_CLOUD_NAME=isi_dari_dashboard_cloudinary
   CLOUDINARY_API_KEY=isi_dari_dashboard_cloudinary
   CLOUDINARY_API_SECRET=isi_dari_dashboard_cloudinary
   ```
   Cloudinary gratis untuk daftar di cloudinary.com — kalau belum sempat daftar, fitur upload gambar akan gagal tapi CRUD post teks tetap jalan normal (field gambar akan tetap null).

3. Push schema ke database (Drizzle akan otomatis membuat tabel `users`, `posts`, `comments`):
   ```bash
   cd Server
   npm install
   npx drizzle-kit push
   ```

## 2. Jalankan Backend

```bash
cd Server
npm run dev
```

Server jalan di `http://localhost:3000`. Endpoint yang tersedia:

| Method | Endpoint | Keterangan | Auth |
|---|---|---|---|
| POST | `/api/auth/register` | Daftar akun baru | - |
| POST | `/api/auth/login` | Login, dapat token | - |
| GET | `/api/auth/me` | Profil user login | wajib |
| GET | `/api/posts` | Semua post (published) | - |
| GET | `/api/posts/:id` | Detail satu post | - |
| GET | `/api/posts/mine` | Post milik saya | wajib |
| POST | `/api/posts` | Buat post (+gambar opsional) | wajib |
| PUT | `/api/posts/:id` | Update post | wajib, pemilik/admin |
| DELETE | `/api/posts/:id` | Hapus post (soft delete) | wajib, pemilik/admin |
| GET | `/api/posts/:postId/comments` | Komentar pada post | - |
| POST | `/api/posts/:postId/comments` | Tambah komentar | wajib |
| DELETE | `/api/comments/:id` | Hapus komentar | wajib, pemilik/admin |
| GET | `/api/recommendations` | Data kartu "For You" | - |

Body `POST/PUT /api/posts` dikirim sebagai `multipart/form-data` dengan field `title`, `content`, dan file opsional bernama `image`.

## 3. Jalankan Frontend (Flutter)

```bash
cd mobile
flutter pub get
flutter run
```

**PENTING — cek base URL di `lib/services/api_service.dart`:**
- Emulator Android → `http://10.0.2.2:3000` (sudah default)
- iOS Simulator → `http://localhost:3000`
- HP fisik → `http://<IP-komputer-kamu>:3000` (HP & komputer harus satu jaringan WiFi)

## Fitur yang sudah berjalan

- Registrasi & login (JWT), sesi tersimpan di HP (SharedPreferences)
- Lihat semua post + rekomendasi tanpa perlu login (tab "For You" & "Semua Post")
- Buat / edit / hapus post sendiri, termasuk upload gambar (tab "Post Saya")
- Komentar pada post (perlu login untuk menulis, semua orang bisa membaca)
- Logout (tab "Profil")
- Validasi input di form (judul/konten wajib, password minimal 6 karakter, dsb)
- Status code REST API yang sesuai (200, 201, 400, 401, 403, 404)

## Mapping ke Kisi-Kisi Ujian

| Materi Kisi-Kisi | Lokasi di Kode |
|---|---|
| REST API & Endpoint | `Server/src/routes/*.ts` |
| HTTP Method (GET/POST/PUT/DELETE) | tiap `router.get/post/put/delete` |
| HTTP Status Code | `res.status(...)` di tiap controller |
| JSON | request body & response di semua controller |
| Express.js & Routing | `src/index.ts`, `src/routes/*.ts` |
| Request & Response | parameter `req, res` di controller |
| CRUD | `postController.ts`, `commentController.ts` |
| CRUD ↔ HTTP Method | GET=Read, POST=Create, PUT=Update, DELETE=Delete |
| Database | Drizzle ORM (`schema.ts`, `db.ts`), koneksi MySQL |
| Validasi Data | pengecekan `if (!title \|\| !content)` dsb di setiap controller |
| Alur Program | Flutter (`ApiService`) → Express Route → Controller → Drizzle → MySQL → Response JSON → tampil di UI |
| Widget, Stateful/StatelessWidget | semua file di `mobile/lib/screens` |
| Input Form | `login_screen.dart`, `register_screen.dart`, `post_form_screen.dart` |
| Navigator | `Navigator.push`/`pop` di semua screen |
| Package | `http`, `shared_preferences`, `image_picker` di `pubspec.yaml` |
| REST API di Flutter | `mobile/lib/services/api_service.dart` |
| Implementasi REST API (tampilkan data) | `FutureBuilder` di `home_screen.dart`, `post_detail_screen.dart` |
