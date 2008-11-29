class CreateProjects < ActiveRecord::Migration
  def self.up
    create_table :projects do |t|
      t.integer :manager_id
      t.string  :code, :limit => 10
      t.string  :name
      t.date    :start_date
      t.date    :end_date

      t.timestamps
    end
    
    add_index :projects, 'code'
    add_index :projects, 'manager_id'
    add_index :projects, 'start_date'
    add_index :projects, 'end_date'
  end

  def self.down
    drop_table :projects
  end
end
