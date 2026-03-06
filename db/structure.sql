CREATE TABLE IF NOT EXISTS "schema_migrations" ("version" varchar NOT NULL PRIMARY KEY);
CREATE TABLE IF NOT EXISTS "ar_internal_metadata" ("key" varchar NOT NULL PRIMARY KEY, "value" varchar, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);
CREATE TABLE IF NOT EXISTS "locations" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar NOT NULL, "district" varchar, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);
CREATE UNIQUE INDEX "index_locations_on_name_and_district" ON "locations" ("name", "district") /*application='Fa'*/;
CREATE INDEX "index_locations_on_name" ON "locations" ("name") /*application='Fa'*/;
CREATE VIRTUAL TABLE locations_fts USING fts5 (name, district, content='locations', content_rowid='id')
/* locations_fts(name,district) */;
CREATE TABLE IF NOT EXISTS 'locations_fts_data'(id INTEGER PRIMARY KEY, block BLOB);
CREATE TABLE IF NOT EXISTS 'locations_fts_idx'(segid, term, pgno, PRIMARY KEY(segid, term)) WITHOUT ROWID;
CREATE TABLE IF NOT EXISTS 'locations_fts_docsize'(id INTEGER PRIMARY KEY, sz BLOB);
CREATE TABLE IF NOT EXISTS 'locations_fts_config'(k PRIMARY KEY, v) WITHOUT ROWID;
CREATE TRIGGER locations_ai AFTER INSERT ON locations BEGIN
        INSERT INTO locations_fts(rowid, name, district)
        VALUES (new.id, new.name, new.district);
      END;
CREATE TRIGGER locations_ad AFTER DELETE ON locations BEGIN
        INSERT INTO locations_fts(locations_fts, rowid, name, district)
        VALUES('delete', old.id, old.name, old.district);
      END;
CREATE TRIGGER locations_au AFTER UPDATE ON locations BEGIN
        INSERT INTO locations_fts(locations_fts, rowid, name, district)
        VALUES('delete', old.id, old.name, old.district);

        INSERT INTO locations_fts(rowid, name, district)
        VALUES (new.id, new.name, new.district);
      END;
CREATE TABLE IF NOT EXISTS "contacts" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "kind" integer DEFAULT 0 NOT NULL, "first_name" varchar, "last_name" varchar, "known_as" varchar, "company_name" varchar, "vat_number" varchar, "sdi_code" varchar, "tax_id" varchar, "email" varchar, "phone" varchar, "notes" text, "display_name" varchar GENERATED ALWAYS AS (CASE WHEN kind = 1 THEN COALESCE(company_name, '') ELSE TRIM(COALESCE(first_name, '') || ' ' || COALESCE(last_name, '') || CASE WHEN known_as IS NOT NULL AND known_as != '' THEN ' (' || known_as || ')' ELSE '' END) END) VIRTUAL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);
CREATE UNIQUE INDEX "index_contacts_on_email" ON "contacts" ("email") WHERE email IS NOT NULL AND email != '' /*application='Fa'*/;
CREATE UNIQUE INDEX "index_contacts_on_tax_id" ON "contacts" ("tax_id") WHERE tax_id IS NOT NULL AND tax_id != '' /*application='Fa'*/;
CREATE UNIQUE INDEX "index_contacts_on_vat_number" ON "contacts" ("vat_number") WHERE vat_number IS NOT NULL AND vat_number != '' /*application='Fa'*/;
CREATE VIRTUAL TABLE contacts_fts USING fts5 (first_name, last_name, known_as, company_name, email, phone, vat_number, tax_id, notes, content='contacts', content_rowid='id')
/* contacts_fts(first_name,last_name,known_as,company_name,email,phone,vat_number,tax_id,notes) */;
CREATE TABLE IF NOT EXISTS 'contacts_fts_data'(id INTEGER PRIMARY KEY, block BLOB);
CREATE TABLE IF NOT EXISTS 'contacts_fts_idx'(segid, term, pgno, PRIMARY KEY(segid, term)) WITHOUT ROWID;
CREATE TABLE IF NOT EXISTS 'contacts_fts_docsize'(id INTEGER PRIMARY KEY, sz BLOB);
CREATE TABLE IF NOT EXISTS 'contacts_fts_config'(k PRIMARY KEY, v) WITHOUT ROWID;
CREATE TRIGGER contacts_ai AFTER INSERT ON contacts BEGIN
        INSERT INTO contacts_fts(rowid, first_name, last_name, known_as, company_name, email, phone, vat_number, tax_id, notes)
        VALUES (new.id, new.first_name, new.last_name, new.known_as, new.company_name, new.email, new.phone, new.vat_number, new.tax_id, new.notes);
      END;
CREATE TRIGGER contacts_ad AFTER DELETE ON contacts BEGIN
        INSERT INTO contacts_fts(contacts_fts, rowid, first_name, last_name, known_as, company_name, email, phone, vat_number, tax_id, notes)
        VALUES('delete', old.id, old.first_name, old.last_name, old.known_as, old.company_name, old.email, old.phone, old.vat_number, old.tax_id, old.notes);
      END;
CREATE TRIGGER contacts_au AFTER UPDATE ON contacts BEGIN
        INSERT INTO contacts_fts(contacts_fts, rowid, first_name, last_name, known_as, company_name, email, phone, vat_number, tax_id, notes)
        VALUES('delete', old.id, old.first_name, old.last_name, old.known_as, old.company_name, old.email, old.phone, old.vat_number, old.tax_id, old.notes);

        INSERT INTO contacts_fts(rowid, first_name, last_name, known_as, company_name, email, phone, vat_number, tax_id, notes)
        VALUES (new.id, new.first_name, new.last_name, new.known_as, new.company_name, new.email, new.phone, new.vat_number, new.tax_id, new.notes);
      END;
CREATE TABLE IF NOT EXISTS "jobs" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "date" date NOT NULL, "start_at" datetime(6), "end_at" datetime(6), "description" text, "notes" text, "with_video" boolean DEFAULT FALSE NOT NULL, "location_id" integer, "legacy_data" json DEFAULT '{}', "display_title" varchar GENERATED ALWAYS AS (COALESCE(NULLIF(TRIM(description), ''), 'Servizio del ' || strftime('%d/%m/%Y', date))) VIRTUAL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_e1588fa548"
FOREIGN KEY ("location_id")
  REFERENCES "locations" ("id")
);
CREATE INDEX "index_jobs_on_location_id" ON "jobs" ("location_id") /*application='Fa'*/;
CREATE INDEX "index_jobs_on_date" ON "jobs" ("date") /*application='Fa'*/;
CREATE INDEX "index_jobs_on_with_video" ON "jobs" ("with_video") /*application='Fa'*/;
CREATE VIRTUAL TABLE jobs_fts USING fts5 (description, notes, legacy_data, content='jobs', content_rowid='id')
/* jobs_fts(description,notes,legacy_data) */;
CREATE TABLE IF NOT EXISTS 'jobs_fts_data'(id INTEGER PRIMARY KEY, block BLOB);
CREATE TABLE IF NOT EXISTS 'jobs_fts_idx'(segid, term, pgno, PRIMARY KEY(segid, term)) WITHOUT ROWID;
CREATE TABLE IF NOT EXISTS 'jobs_fts_docsize'(id INTEGER PRIMARY KEY, sz BLOB);
CREATE TABLE IF NOT EXISTS 'jobs_fts_config'(k PRIMARY KEY, v) WITHOUT ROWID;
CREATE TRIGGER jobs_ai AFTER INSERT ON jobs BEGIN
        INSERT INTO jobs_fts(rowid, description, notes, legacy_data)
        VALUES (new.id, new.description, new.notes, new.legacy_data);
      END;
CREATE TRIGGER jobs_ad AFTER DELETE ON jobs BEGIN
        INSERT INTO jobs_fts(jobs_fts, rowid, description, notes, legacy_data)
        VALUES('delete', old.id, old.description, old.notes, old.legacy_data);
      END;
CREATE TRIGGER jobs_au AFTER UPDATE ON jobs BEGIN
        INSERT INTO jobs_fts(jobs_fts, rowid, description, notes, legacy_data)
        VALUES('delete', old.id, old.description, old.notes, old.legacy_data);

        INSERT INTO jobs_fts(rowid, description, notes, legacy_data)
        VALUES (new.id, new.description, new.notes, new.legacy_data);
      END;
CREATE TABLE IF NOT EXISTS "participations" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "job_id" integer NOT NULL, "contact_id" integer NOT NULL, "role" varchar NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_3c57aa2e63"
FOREIGN KEY ("job_id")
  REFERENCES "jobs" ("id")
, CONSTRAINT "fk_rails_fb5eac5bc1"
FOREIGN KEY ("contact_id")
  REFERENCES "contacts" ("id")
);
CREATE INDEX "index_participations_on_job_id" ON "participations" ("job_id") /*application='Fa'*/;
CREATE INDEX "index_participations_on_contact_id" ON "participations" ("contact_id") /*application='Fa'*/;
CREATE UNIQUE INDEX "idx_participations_unique_role" ON "participations" ("job_id", "contact_id", "role") /*application='Fa'*/;
CREATE TABLE IF NOT EXISTS "users" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "nickname" varchar NOT NULL, "password_digest" varchar NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);
CREATE UNIQUE INDEX "index_users_on_nickname" ON "users" ("nickname") /*application='Fa'*/;
CREATE TABLE IF NOT EXISTS "sessions" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer NOT NULL, "ip_address" varchar, "user_agent" varchar, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_758836b4f0"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_sessions_on_user_id" ON "sessions" ("user_id") /*application='Fa'*/;
INSERT INTO "schema_migrations" (version) VALUES
('20260228234330'),
('20260228234329'),
('20260228183359'),
('20260228182212'),
('20260228182023'),
('20260228175407'),
('20260228174741'),
('20260228164800'),
('20260228164617');

