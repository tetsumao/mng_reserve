class CreateMngReservations < ActiveRecord::Migration[6.0]
  def change
    create_table :mng_reservations do |t|
      t.string :user_name
      t.references :item, null: false, foreign_key: true
      t.integer :number, null: false, default: 1
      t.string :reservation_name, null: false, default: ''
      t.date :reservation_date, null: false
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.integer :web_reservation_id

      t.timestamps
    end
  end
end
