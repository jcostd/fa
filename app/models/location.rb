class Location < ApplicationRecord
  include FtsSearchable

  broadcasts_refreshes          # turbo

  validates :name, presence: true
  validates :name, uniqueness: { scope: :district, message: "esiste già in questo sestiere" }
end
