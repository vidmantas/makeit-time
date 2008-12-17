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
      
      name = login.scan(/(\w+)([A-Z])|(\w+)/).flatten.compact
      last_name = name.size == 2 ? name.last : ''
      
      unless Employee.find_by_login(login)
        e = Employee.new(
          :first_name   => name.first,
          :last_name    => last_name,
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
