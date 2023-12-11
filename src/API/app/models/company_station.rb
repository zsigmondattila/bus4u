class CompanyStation < ApplicationRecord
  belongs_to :company
  belongs_to :station
end
