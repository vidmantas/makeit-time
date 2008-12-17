class ImportProjects < Import
  def initialize
    super("projects_081125.csv")
    commit
  end
  
  def commit
    puts "Importing projects..."
    default_position = Position.find_by_name("Projektų vadovas")
    
    import do |row|
      code, manager_login = row[0].strip, row[1].strip
      
      unless manager_login =~ /NEĮVYKĘS/i
        manager = Employee.find_by_login(manager_login)
        p = Project.new(
          :code       => code.rjust(3, '0'),
          :name       => "#{code.rjust(3, '0')} projektas",
          :manager    => manager,
          :start_date => Time.now, # will be set after 
          :end_date   => Time.now  # tasks import
        )
        
        if p.save
          manager.position = default_position
          manager.save
        else
          puts p.errors.inspect
        end
      end
    end
  end
end
