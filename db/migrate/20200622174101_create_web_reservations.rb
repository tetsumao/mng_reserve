class CreateWebReservations < ActiveRecord::Migration[6.0]
  def change
    create_table :web_reservations, id: false do |t|
      t.primary_key :id, auto_increment: false
      t.integer :user_id
      t.string :user_name
      t.references :item, null: false, foreign_key: true
      t.integer :number, null: false, default: 1
      t.string :reservation_name, null: false, default: ''
      t.date :reservation_date, null: false
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.datetime :sent_at

      t.timestamps
    end
  end
end
