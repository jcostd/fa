class Participation < ApplicationRecord
  ROLES = {
    photographer: "Fotografo",
    client: "Cliente",
    character: "Soggetto"
  }.freeze

  belongs_to :job
  belongs_to :contact

  validates :role, presence: true
  validates :contact_id, uniqueness: { scope: [ :job_id, :role ], message: "ha già questo ruolo in questo lavoro" }
end
