import {
  mysqlTable,
  mysqlEnum,
  int,
  varchar,
  text,
  timestamp,
} from "drizzle-orm/mysql-core";

export const USER_ROLES = ["user", "admin"] as const;

export const POST_STATUS = ["delete", "published"] as const;

export const POST_CATEGORIES = [
  "Umum",
  "Review",
  "Berita",
  "Tips & Trik",
  "Rilis Baru",
  "Esports",
] as const;

// USERS
export const usersTable = mysqlTable("users", {
  id: int("id").autoincrement().primaryKey(),
  username: varchar("username", { length: 50 }).notNull(),
  email: varchar("email", { length: 100 }).notNull().unique(),
  password: varchar("password", { length: 255 }).notNull(),
  role: mysqlEnum("role", USER_ROLES).notNull().default("user"),
  avatarUrl: text("avatar_url"),
  avatarPublicId: varchar("avatar_public_id", { length: 255 }),
  createdAt: timestamp("created_at").defaultNow(),
  updatedAt: timestamp("updated_at").defaultNow().onUpdateNow(),
});

// POSTS
export const postsTable = mysqlTable("posts", {
  id: int("id").autoincrement().primaryKey(),
  userId: int("user_id")
    .notNull()
    .references(() => usersTable.id, { onDelete: "cascade" }),
  title: varchar("title", { length: 255 }).notNull(),
  content: text("content").notNull(),
  imageUrl: text("image_url"), // Kolom untuk simpan URL gambar
  imagePublicId: varchar("image_public_id", { length: 255 }), // Nama file lokal (untuk hapus file saat post dihapus)
  category: mysqlEnum("category", POST_CATEGORIES).notNull().default("Umum"),
  status: mysqlEnum("status", POST_STATUS).notNull().default("published"),
  createdAt: timestamp("created_at").defaultNow(),
  updatedAt: timestamp("updated_at").defaultNow().onUpdateNow(),
});

// POST IMAGES (galeri - 1 post bisa punya banyak gambar)
export const postImagesTable = mysqlTable("post_images", {
  id: int("id").autoincrement().primaryKey(),
  postId: int("post_id")
    .notNull()
    .references(() => postsTable.id, { onDelete: "cascade" }),
  imageUrl: text("image_url").notNull(),
  imagePublicId: varchar("image_public_id", { length: 255 }),
  sortOrder: int("sort_order").notNull().default(0),
  createdAt: timestamp("created_at").defaultNow(),
});

// FEEDBACK (dari menu "Kirim Masukan" di drawer)
export const feedbackTable = mysqlTable("feedback", {
  id: int("id").autoincrement().primaryKey(),
  userId: int("user_id").references(() => usersTable.id, { onDelete: "set null" }),
  message: text("message").notNull(),
  createdAt: timestamp("created_at").defaultNow(),
});

// COMMENTS
export const commentsTable = mysqlTable("comments", {
  id: int("id").autoincrement().primaryKey(),
  postId: int("post_id")
    .notNull()
    .references(() => postsTable.id, { onDelete: "cascade" }),
  userId: int("user_id")
    .notNull()
    .references(() => usersTable.id, { onDelete: "cascade" }),
  comment: text("comment").notNull(),
  createdAt: timestamp("created_at").defaultNow(),
  updatedAt: timestamp("updated_at").defaultNow().onUpdateNow(),
});
