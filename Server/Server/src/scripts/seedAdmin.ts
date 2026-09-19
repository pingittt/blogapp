import bcrypt from "bcryptjs";
import { eq } from "drizzle-orm";
import { db } from "../config/db";
import { usersTable } from "../config/schema";

// Data akun admin — jalankan sekali lewat: npm run seed:admin
const ADMIN = {
  username: "Pingit",
  email: "adriyanhega@gmail.com",
  password: "Hanzzwiby123",
};

async function main() {
  const [existing] = await db
    .select()
    .from(usersTable)
    .where(eq(usersTable.email, ADMIN.email));

  const hashed = await bcrypt.hash(ADMIN.password, 10);

  if (existing) {
    // Kalau akunnya udah ada (misal dulu daftar biasa), upgrade jadi admin
    // dan sinkronkan username/password sesuai data di atas.
    await db
      .update(usersTable)
      .set({ role: "admin", username: ADMIN.username, password: hashed })
      .where(eq(usersTable.id, existing.id));
    console.log(`Akun ${ADMIN.email} sudah ada -> di-upgrade jadi admin.`);
  } else {
    await db.insert(usersTable).values({
      username: ADMIN.username,
      email: ADMIN.email,
      password: hashed,
      role: "admin",
    });
    console.log(`Akun admin baru berhasil dibuat: ${ADMIN.email}`);
  }

  console.log("Selesai. Kamu sekarang bisa login pakai akun ini di app.");
  process.exit(0);
}

main().catch((err) => {
  console.error("Gagal membuat akun admin:", err);
  process.exit(1);
});
