class CreateTasks < ActiveRecord::Migration
  def self.up
    create_table :tasks do |t|
      t.integer :project_id
      t.integer :employee_id
      t.integer :activity_id
      t.date    :date
      t.string  :description
      t.integer :hours_spent

      t.timestamps
    end
    
    add_index :tasks, 'project_id'
    add_index :tasks, 'employee_id'
    add_index :tasks, 'activity_id'
    add_index :tasks, 'date'
  end

  def self.down
    drop_table :tasks
  end
end
