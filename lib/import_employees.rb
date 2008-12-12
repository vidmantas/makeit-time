class ImportEmployees < Import
  def initialize
    super("employees_081125.csv")
    commit
  end
  
  def commit
    puts "Importing employees..."
    
    default_position = Position.find_by_name("Programuotojas")
    
    import do |row|
      login, sector_id = row[0].strip, row[1].strip
      
      unless Employee.find_by_login(login)
        e = Employee.new(
          :first_name   => login,
          :login        => login,
          :sector       => Sector.find_by_code(sector_id),
          :position     => default_position,
          :password     => login
        )
        e.save(false) # bypass validations
      end
    end
  end
end
