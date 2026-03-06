class Contact < ApplicationRecord
  include FtsSearchable

  enum :kind, { person: 0, company: 1 }

  has_many :participations, dependent: :destroy
  has_many :jobs, through: :participations

  validates :first_name, presence: true, if: :person?
  validates :last_name, presence: true, if: :person?

  validates :company_name, presence: true, if: :company?

  normalizes :email, with: ->(e) { e.strip.downcase }
  normalizes :vat_number, :tax_id, with: ->(e) { e.strip.upcase }

  # display_name virtual col

  private
    def strip_blanks
      self.email = email.strip.downcase if email.present?
      self.vat_number = vat_number.strip.upcase if vat_number.present?
      self.tax_id = tax_id.strip.upcase if tax_id.present?
    end
end
