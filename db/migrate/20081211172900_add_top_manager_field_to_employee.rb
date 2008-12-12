class AddTopManagerFieldToEmployee < ActiveRecord::Migration
  def self.up
    add_column :employees, 'is_top_manager', :boolean, :default => false
  end

  def self.down
    remove_column :employees, 'is_top_manager'
  end
end
