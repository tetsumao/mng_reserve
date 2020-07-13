class CreateStaffs < ActiveRecord::Migration[6.0]
  def change
    create_table :staffs do |t|
      t.string :login_name, null: false
      t.string :password_digest
      t.string :staff_name
      t.integer :dspo, default: 0

      t.timestamps
    end

    add_index :staffs, 'LOWER(login_name)', unique: true
  end
end
