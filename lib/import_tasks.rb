class ImportTasks < Import
  def initialize
    super("tasks_081125.csv")
    commit
    set_project_ranges
  end
  
  def commit
    default_activity = Activity.find_by_name("Nenurodyta")
    index = 1
    
    import do |row|
      puts "Importing task #{index}..."
      project_code, login, year, month, hours = 
        row[0].strip, row[1].strip, row[2].strip, row[3].strip, row[4].strip.to_i
      
      project   = Project.find_by_code(project_code.rjust(3, '0'))
      employee  = Employee.find_by_login(login)
      
      if !project.nil? and !employee.nil?
        date = Time.parse("#{year}-#{month}-01")
        
        while hours > 0
          t = Task.new(
            :project    => project,
            :employee   => employee,
            :activity   => default_activity,
            :date       => date.to_date,
            :hours_spent=> (hours - 7) > 0 ? 7 : hours
          )
          
          if t.save(false) # bypass validation
            project.employees << employee unless project.employees.include?(employee)
          else
            puts t.errors.inspect
          end
          
          hours -= 7
          date += 1.day
        end
      else
        puts "Employee #{login}"
        exit
      end
      index += 1
    end
  end
  
  def set_project_ranges
    Project.all.each do |project|
      project.start_date = project.tasks.minimum(:date)
      project.end_date   = project.tasks.maximum(:date)
      project.save
    end
  end
end
