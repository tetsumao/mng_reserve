class Item < ApplicationRecord
  acts_as_paranoid
  default_scope {order(:dspo)}

  has_many :web_reservations
  has_many :mng_reservations

  def self.next_dspo
    max_dspo = Item.maximum(:dspo)
    max_dspo.present? ? (max_dspo + 1) : 1
  end

  def self.web_master(web_updated_at)
    if web_updated_at.present?
      Item.with_deleted.where('updated_at > ?', Time.zone.parse(web_updated_at))
    else
      Item.with_deleted
    end
  end
end
