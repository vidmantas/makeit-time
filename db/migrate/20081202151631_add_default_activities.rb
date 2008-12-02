class AddDefaultActivities < ActiveRecord::Migration
  def self.up
    %w[Analizė Projektavimas Programavimas Testavimas Vadyba Nenurodyta].each do |name|
      Activity.create(:name => name, :is_billable => true)
    end
  end

  def self.down
    Activity.delete_all
  end
end
