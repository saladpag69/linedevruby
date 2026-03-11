class Orderable < ApplicationRecord
  belongs_to :service
  belongs_to :cart
end
