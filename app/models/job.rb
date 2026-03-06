class Job < ApplicationRecord
  include FtsSearchable, JsonAttributesAccessor

  broadcasts_refreshes          # turbo

  belongs_to :location, optional: true

  has_many :participations, dependent: :destroy
  has_many :contacts, through: :participations

  has_many :photographer_participations, -> { where(role: Participation::ROLES[:photographer]) }, class_name: "Participation"
  has_many :photographers, through: :photographer_participations, source: :contact

  has_many :client_participations, -> { where(role: Participation::ROLES[:client]) }, class_name: "Participation"
  has_many :clients, through: :client_participations, source: :contact

  has_many :character_participations, -> { where.not(role: [ Participation::ROLES[:photographer], Participation::ROLES[:client] ]) }, class_name: "Participation"
  has_many :characters, through: :character_participations, source: :contact

  validates :date, presence: true

  scope :with_video, -> { where(with_video: true) }
  scope :recent, -> { order(date: :desc) }

  json_accessor :legacy_data, :from_time, :to_time, :legacy_location

  def legacy_from_time
    return nil if from_time.blank?
    Time.parse(from_time) rescue nil
  end

  def legacy_to_time
    return nil if to_time.blank?
    Time.parse(to_time) rescue nil
  end

  def display_location
    return location.name if location_id.present?

    legacy_location.presence || "Location sconosciuta"
  end
end
