class Job < ApplicationRecord
  include FtsSearchable, JsonAttributesAccessor

  broadcasts_refreshes          # turbo

  has_many :job_locations, dependent: :destroy
  has_many :locations, through: :job_locations

  accepts_nested_attributes_for :job_locations, allow_destroy: true

  has_many :participations, dependent: :destroy
  has_many :contacts, through: :participations

  accepts_nested_attributes_for :participations, allow_destroy: true

  has_many :photographer_participations, -> { where(role: Participation::ROLES[:photographer]) }, class_name: "Participation"
  has_many :photographers, through: :photographer_participations, source: :contact

  has_many :client_participations, -> { where(role: Participation::ROLES[:client]) }, class_name: "Participation"
  has_many :clients, through: :client_participations, source: :contact

  has_many :subject_participations, -> { where(role: Participation::ROLES[:subject]) }, class_name: "Participation"
  has_many :subjects, through: :subject_participations, source: :contact

  validates :date, presence: true

  scope :with_video, -> { where(with_video: true) }
  scope :recent, -> { order(date: :desc) }

  json_accessor :legacy_data, :from_time, :to_time, :legacy_location_text

  def legacy_from_time
    return nil if from_time.blank?
    Time.parse(from_time) rescue nil
  end

  def legacy_to_time
    return nil if to_time.blank?
    Time.parse(to_time) rescue nil
  end

  def display_location
    return locations.map(&:name).join(" - ") if locations.any?

    legacy_location_text.presence || "Location sconosciuta"
  end

  def self.global_search(query)
    return all if query.blank?

    # 1. Cerca nei Job (descrizione, note)
    job_ids = search_text(query).pluck(:id)

    # 2. Cerca nelle Locations (AGGIORNATO: Usa la tabella ponte)
    loc_ids = Location.search_text(query).select(:id)
    job_ids_from_loc = joins(:job_locations).where(job_locations: { location_id: loc_ids }).pluck(:id)

    # 3. Cerca nei Contatti (nome, azienda, p.iva)
    contact_ids = Contact.search_text(query).select(:id)
    job_ids_from_contacts = joins(:participations).where(participations: { contact_id: contact_ids }).pluck(:id)

    # 4. Cerca nelle Partecipazioni (es. title: "Sindaco")
    participation_ids = Participation.search_text(query).select(:id)
    job_ids_from_parts = joins(:participations).where(participations: { id: participation_ids }).pluck(:id)

    # Uniamo tutti gli ID trovati e rimuoviamo i duplicati in RAM (veloce)
    all_matching_job_ids = (job_ids + job_ids_from_loc + job_ids_from_contacts + job_ids_from_parts).uniq

    # Restituiamo una Relation nativa ordinata per data (dal più recente al più vecchio)
    where(id: all_matching_job_ids).order(date: :desc)
  end
end
