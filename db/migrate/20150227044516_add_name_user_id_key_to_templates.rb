class AddNameUserIdKeyToTemplates < ActiveRecord::Migration
  def change
    add_index :templates, [:name, :user_id], unique: true
  end
end
