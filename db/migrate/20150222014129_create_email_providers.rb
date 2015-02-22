class CreateEmailProviders < ActiveRecord::Migration
  def change
    create_table :email_providers do |t|
      t.string :name, null: false

      t.timestamps null: false
    end
  end
end
