require "csv"

namespace :db do
  desc "Importazione totale, ottimizzata e sequenziale del database legacy"
  task import_all: :environment do
    puts "🚀 Inizio Super Importazione Legacy...\n\n"

    # Fase 1: LOCATIONS
    import_locations

    # Fase 2: CONTACTS
    import_contacts

    # Fase 3: JOBS & JOB_LOCATIONS
    import_jobs_and_itineraries

    # Fase 4: PARTICIPATIONS
    import_participations

    puts "\n🎉 IMPORTAZIONE COMPLETATA CON SUCCESSO! IL DATABASE È PRONTO."
  end

  # --- METODI PRIVATI DEL TASK ---

  def import_locations
    puts "📍 1/4 - Importazione Locations..."
    filepath = Rails.root.join("db", "locations", "locations.csv")
    locations_data = []
    now = Time.current

    CSV.foreach(filepath, headers: true, encoding: "UTF-8") do |row|
      next if row["name"].blank?
      locations_data << {
        name: row["name"].strip,
        district: row["district"]&.strip,
        created_at: now,
        updated_at: now
      }
    end

    Location.upsert_all(locations_data, unique_by: [ :name, :district ])
    puts "   ✅ Locations a database: #{Location.count}"
  end


  def import_contacts
    puts "\n👤 2/4 - Importazione Contatti..."
    filepath = Rails.root.join("db", "legacy_data", "legacy_contacts.csv")
    contacts_data = []
    now = Time.current

    CSV.foreach(filepath, headers: true) do |row|
      is_company = (row["is_company"] == "t")
      first_name = row["first_name"]&.strip
      last_name = row["last_name"]&.strip

      # Gestione placeholder per persone fisiche
      unless is_company
        first_name = "SCONOSCIUTO" if first_name.blank?
        last_name  = "SCONOSCIUTO" if last_name.blank?
      end

      contacts_data << {
        id: row["id"],
        kind: is_company ? 1 : 0,
        first_name: first_name,
        last_name: last_name,
        company_name: row["company_name"]&.strip,
        created_at: now,
        updated_at: now
      }
    end

    contacts_data.each_slice(5000) { |batch| Contact.upsert_all(batch) }
    puts "   ✅ Contatti importati: #{Contact.count}"
  end


  def import_jobs_and_itineraries
    puts "\n📸 3/4 - Importazione Lavori e Tappe (JobLocations)..."
    filepath = Rails.root.join("db", "legacy_data", "legacy_jobs.csv")

    location_map = Location.pluck(Arel.sql("LOWER(name)"), :id).to_h

    jobs_data = []
    job_locations_data = []
    now = Time.current

    CSV.foreach(filepath, headers: true) do |row|
      raw_json = row["legacy_data"].to_s.strip
      raw_location = row["location"].to_s.strip

      # Parsing Sicuro del JSON
      parsed_json = {}
      begin
        clean_json = raw_json.gsub(/[\x00-\x1F\x7F]/, "")
        parsed_json = JSON.parse(clean_json) if clean_json.present?
      rescue JSON::ParserError
        parsed_json = { "error" => "JSON corrotto", "raw_original" => raw_json }
      end

      # Estraiamo i campi reali se ci sono, altrimenti Nil o False
      start_at = parsed_json["from_time"].present? ? Time.zone.parse(parsed_json["from_time"]) : nil
      end_at = parsed_json["to_time"].present? ? Time.zone.parse(parsed_json["to_time"]) : nil
      with_video = parsed_json["with_video"] == true

      # Salviamo la location vecchia testuale nel JSON just-in-case
      parsed_json["legacy_location_text"] = raw_location if raw_location.present?

      jobs_data << {
        id: row["id"],
        date: row["date"],
        start_at: start_at,
        end_at: end_at,
        description: row["description"]&.strip,
        notes: row["notes"]&.strip,
        with_video: with_video,
        legacy_data: parsed_json,
        created_at: row["created_at"] || now,
        updated_at: row["updated_at"] || now
      }

      # Costruiamo la JobLocation se abbiamo un match nel dizionario in RAM
      if raw_location.present?
        matched_location_id = location_map[raw_location.downcase]

        if matched_location_id
          job_locations_data << {
            job_id: row["id"],
            location_id: matched_location_id,
            position: 1, # È l'unica tappa storica!
            created_at: now,
            updated_at: now
          }
        end
      end
    end

    # Inserimento a blocchi
    jobs_data.each_slice(3000) { |batch| Job.upsert_all(batch) }
    job_locations_data.each_slice(3000) { |batch| JobLocation.insert_all(batch) }

    puts "   ✅ Lavori importati: #{Job.count}"
    puts "   ✅ Tappe (JobLocations) collegate: #{JobLocation.count}"
  end


  def import_participations
    puts "\n🔗 4/4 - Importazione Partecipazioni (Pivot)..."
    filepath = Rails.root.join("db", "legacy_data", "legacy_participations.csv")
    participations_data = []
    now = Time.current

    CSV.foreach(filepath, headers: true) do |row|
      participations_data << {
        job_id: row["job_id"],
        contact_id: row["contact_id"],
        role: row["role"]&.strip || "unknown",
        created_at: now,
        updated_at: now
      }
    end

    # Qui usiamo insert_all che è un po' più veloce di upsert_all
    # se sappiamo di avere un DB vuoto e constraint univoci rispettati nel CSV
    participations_data.each_slice(5000) { |batch| Participation.insert_all(batch, unique_by: [ :job_id, :contact_id, :role ]) }

    puts "   ✅ Partecipazioni importate: #{Participation.count}"
  end
end
