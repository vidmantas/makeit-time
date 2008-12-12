class CreateManagersSector < ActiveRecord::Migration
  def self.up
    add_column :sectors, 'visible', :boolean, :default => true
    add_column :positions, 'visible', :boolean, :default => true
    
    Sector.reset_column_information 
    Position.reset_column_information 
    
    Sector.create(:code => '0', :name => 'Įmonės vadovybė', :visible => false)
    Position.create(:name => 'Vadovas', :visible => false)
  end

  def self.down
    remove_column :sectors, 'visible'
    remove_column :positions, 'visible'
    
    Sector.find_by_code(0).destroy
    Position.find_by_name('Vadovas').destroy
  end
end
