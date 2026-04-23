class Orderable < ApplicationRecord
  belongs_to :service, class_name: "CommunicateService"
  belongs_to :cart
end
