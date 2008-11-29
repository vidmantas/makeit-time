class CreateEmployees < ActiveRecord::Migration
  def self.up
    create_table :employees do |t|
      t.string  :first_name
      t.string  :last_name
      t.integer :sector_id
      t.string  :email
      t.integer :position_id

      t.timestamps
    end
    
    add_index :employees, 'sector_id'
    add_index :employees, 'position_id'
  end

  def self.down
    drop_table :employees
  end
end
