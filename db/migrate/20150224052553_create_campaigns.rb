class CreateCampaigns < ActiveRecord::Migration
  def change
    create_table :campaigns do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.string :queue, default: "medium"

      t.timestamps null: false
    end
    add_index :campaigns, :slug, unique: true
  end
end
