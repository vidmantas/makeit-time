class ActivityLimitations < ActiveRecord::Migration
  def self.up
    add_column :activities, 'is_enterable', :boolean, :default => true
    unspecified = Activity.find(:first, :conditions => [ "name = ?", "Nenurodyta" ])
    if unspecified
      unspecified.is_enterable = false
      unspecified.save(false)
    end
    add_index :activities, 'is_enterable'
  end

  def self.down
    remove_column :activities, 'is_enterable'
  end
end
