class CreateTemplates < ActiveRecord::Migration
  def change
    create_table :templates do |t|
      t.string :name, :null => false, :limit => 255
      t.string :subject, :limit => 255, :default => "No subject"
      t.text :html, :limit => 65535
      t.text :text, :limit => 65535

      t.timestamps null: false
    end
  end
end
