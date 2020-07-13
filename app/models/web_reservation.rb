class WebReservation < ApplicationRecord
  belongs_to :item
  has_one :mng_reservation
  # 削除時は0にする
  validates :number, numericality: {greater_than_or_equal_to: 0}

  include StartEndDateHolder

  scope :has_not_mng, -> {left_joins(:mng_reservation).where('mng_reservations.id IS NULL')}
end
