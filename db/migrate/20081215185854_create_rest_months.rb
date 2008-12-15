class CreateRestMonths < ActiveRecord::Migration
  def self.up
    create_table :rest_months do |t|
      t.integer :employee_id
      t.date :date

      t.timestamps
    end
    
    add_index :rest_months, :employee_id
    add_index :rest_months, :date
  end

  def self.down
    drop_table :rest_months
  end
end
