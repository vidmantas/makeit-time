class MarkNenurodytaActivityAsUnenterable < ActiveRecord::Migration
  def self.up
    a = Activity.find_by_name("Nenurodyta")
    a.is_enterable = false
    a.save(false)
  rescue
    puts "Activity not found"
  end

  def self.down
    a = Activity.find_by_name("Nenurodyta")
    a.is_enterable = true
    a.save(false)
  rescue
    puts "Activity not found"
  end
end
