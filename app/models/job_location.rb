class JobLocation < ApplicationRecord
  belongs_to :job
  belongs_to :location

  default_scope { order(position: :asc) }
end
