class AddProviderToTemplate < ActiveRecord::Migration
  def change
    add_column :templates, :provider, :integer, default: 0
  end
end
