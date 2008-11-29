class CreateActivities < ActiveRecord::Migration
  def self.up
    create_table :activities do |t|
      t.string  :name
      t.boolean :is_billable

      t.timestamps
    end
    
    add_index :activities, 'is_billable'
  end

  def self.down
    drop_table :activities
  end
end
