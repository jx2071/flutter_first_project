// Database Constants
const dbName = 'notes.db';
const noteTable = 'note';
const userTable = 'user';
const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';
const textColumn = 'text';
const cloudSyncColumn = 'cloud_sync';

const createNoteTableSQL = '''
      CREATE TABLE IF NOT EXISTS "note"(
      "id" INTEGER NOT NULL,
      "user_id" INTEGER NOT NULL,
      "text" TEXT,
      "cloud_sync" INT NOT NULL DEFAULT 0,
      FOREIGN KEY ("user_id") REFERENCES "user"("id"),
      PRIMARY KEY ("id" AUTOINCREMENT)
      );
      ''';
const createUserTableSQL = '''
      CREATE TABLE IF NOT EXISTS "user"(
      "id" INTEGER NOT NULL,
      "email" TEXT NOT NULL UNIQUE,
      PRIMARY KEY("id" AUTOINCREMENT)
      );
      ''';

const text = "";
