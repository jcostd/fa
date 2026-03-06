class CreateLocationsFts < ActiveRecord::Migration[8.1]
  def up
    create_virtual_table :locations_fts, :fts5, [
                           "name", "district", "content='locations'", "content_rowid='id'"
                         ]

    execute <<-SQL
      CREATE TRIGGER locations_ai AFTER INSERT ON locations BEGIN
        INSERT INTO locations_fts(rowid, name, district)
        VALUES (new.id, new.name, new.district);
      END;
    SQL

    execute <<-SQL
      CREATE TRIGGER locations_ad AFTER DELETE ON locations BEGIN
        INSERT INTO locations_fts(locations_fts, rowid, name, district)
        VALUES('delete', old.id, old.name, old.district);
      END;
    SQL

    execute <<-SQL
      CREATE TRIGGER locations_au AFTER UPDATE ON locations BEGIN
        INSERT INTO locations_fts(locations_fts, rowid, name, district)
        VALUES('delete', old.id, old.name, old.district);

        INSERT INTO locations_fts(rowid, name, district)
        VALUES (new.id, new.name, new.district);
      END;
    SQL
  end

  def down
    execute "DROP TRIGGER IF EXISTS locations_ai;"
    execute "DROP TRIGGER IF EXISTS locations_ad;"
    execute "DROP TRIGGER IF EXISTS locations_au;"

    drop_virtual_table :locations_fts
  end
end
