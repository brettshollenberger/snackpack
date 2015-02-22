class CreateDeliveries < ActiveRecord::Migration
  def change
    create_table :deliveries do |t|
      t.integer :template_id, null: false
      t.integer :recipient_id, null: false, references: :users
      t.integer :sender_id, null: false, references: :users
      t.datetime :send_at
      t.datetime :sent_at
      t.text :data, limit: 65535
      t.integer :status, limit: 4, default: 0

      t.timestamps null: false
    end
  end
end
