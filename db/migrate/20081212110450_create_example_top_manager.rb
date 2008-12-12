class CreateExampleTopManager < ActiveRecord::Migration
  def self.up
    e = Employee.create(
      :login          => 'vadovas',
      :password       => 'vadovas',
      :first_name     => 'p.',
      :last_name      => 'Direktorius',
      :email          => 'direktorius@projektai.lt',
      :sector         => Sector.find_by_code(0),
      :position       => Position.find_by_name('Vadovas'),
      :is_top_manager => true
    )
    
    s = Sector.find_by_code(0)
    s.manager = e
    s.save(false)
  end

  def self.down
    Employee.find_by_login('vadovas').destroy
  rescue 
    puts "Vadovo vartotojas nerastas."
  end
end
