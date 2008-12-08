class ImportSectors < Import
  DATA_FILE = "#{RAILS_ROOT}/lib/import_data/sectors_081125.csv"
   
  def initialize
    super("sectors_081125.csv")
    commit
  end
  
  def commit
    puts "Importing sectors..."
    default_position = Position.find_by_name("Projektų vadovas")
      
    import do |row|
      sector_code, manager_login = row[0].strip, row[1].strip
      sector  = Sector.create(:code => sector_code, :name => "#{sector_code} skyrius")
      
      e = Employee.new(
        :first_name => manager_login,
        :login      => manager_login,
        :sector     => sector,
        :position   => default_position,
        :password   => manager_login
      )
      e.save(false)
      
      sector.manager = e
      sector.save
    end
  end
end
