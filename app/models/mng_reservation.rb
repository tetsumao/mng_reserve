class MngReservation < ApplicationRecord
  belongs_to :item
  belongs_to :web_reservation, touch: true, optional: true
  validates :number, numericality: {greater_than: 0}

  include StartEndDateHolder

  validate :validate_item_stock

  before_save do
    self.reservation_name = "#{self.item.item_name} x #{self.number}：#{self.start_end_date_to_s}"
    self.reservation_date = Date.today if self.reservation_date.nil?
  end
  
  scope :belongs_not_web, -> {left_joins(:web_reservation).where('web_reservations.id IS NULL')}

  private
    def validate_item_stock
      if number > 0
        map = ReservedMap.new(item, start_date, end_date, id)
        errors.add(:item_id, 'は予約一杯の日付があります') unless map.permit_all?(number)
      end
    end
end
