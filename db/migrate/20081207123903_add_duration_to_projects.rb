class AddDurationToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, 'duration', :integer
    add_index :projects, 'duration'
    
    Project.all.each do |p|
      p.duration_will_change!
      p.save
    end
  end

  def self.down
    remove_column :projects, 'duration'
  end
end
