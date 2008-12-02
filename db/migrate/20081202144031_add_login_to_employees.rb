class AddLoginToEmployees < ActiveRecord::Migration
  def self.up
    add_column :employees, 'login', :string, :limit => 25
    add_index :employees, 'login'
  end

  def self.down
    remove_column :employees, 'login'
  end
end
