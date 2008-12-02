class CreateSectors < ActiveRecord::Migration
  def self.up
    create_table :sectors do |t|
      t.string  :code, :limit => 10
      t.string  :name
      t.integer :manager_id

      t.timestamps
    end
    
    add_index :sectors, 'manager_id'
    add_index :sectors, 'code'
  end

  def self.down
    drop_table :sectors
  end
end
