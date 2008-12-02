class AddDefaultPositions < ActiveRecord::Migration
  def self.up
    "Analitikas,Programuotojas,Projektų vadovas,Inžinierius".split(',').each do |name|
      Position.create(:name => name)
    end
  end

  def self.down
    Position.delete_all
  end
end
