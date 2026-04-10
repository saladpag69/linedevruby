class User < ApplicationRecord
  validates :username, presence: true, uniqueness: true

  def self.find_or_create_from_siamcosmo(user_data:, token:, shop_id:)
    user = find_or_initialize_by(siamcosmo_user_id: user_data["_id"])
    user.assign_attributes(
      username: user_data["username"],
      siamcosmo_token: token,
      shop_id: shop_id
    )
    user.save!
    user
  end

  def self.find_or_create_from_line(line_id:, display_name:)
    user = find_or_initialize_by(line_id: line_id)
    user.assign_attributes(line_display_name: display_name) if user.new_record?
    user.save!
    user
  end

  def link_line(line_id:, display_name:)
    update!(line_id: line_id, line_display_name: display_name)
  end

  def has_line_linked?
    line_id.present?
  end
end
