namespace :db do
  desc "Erase and fill database"
  task :populate => :environment do
    require 'populator'
    require 'faker'
    
    [Activity, Employee, EmployeesProjects, Position, Project, Sector, Task].each(&:delete_all)
    
    %w[Analizė Projektavimas Programavimas Testavimas Vadyba].each do |name|
      Activity.create(:name => name, :is_billable => true)
    end
    
    # skyriai
    %w[Department1 Department2 Department3].each_with_index do |name, index|
      Sector.create(:name => name, :code => "##{index}")
    end
    
    "Analitikas,Programuotojas,Projektų vadovas,Inžinierius".split(',').each do |name|
      Position.create(:name => name)
    end
    
    Employee.populate 25 do |e|
      e.first_name  = Faker::Name.first_name
      e.last_name   = Faker::Name.last_name
      e.sector_id   = random_sector.id
      e.email       = Faker::Internet.free_email
      e.position_id = random_position.id
      e.login       = Faker::Internet.user_name
    end
    
    Employee.all.each { |e| e.update_attribute(:password, 'test') } 
    
    Sector.all.each do |s|
      s.manager_id = random_employee.id
      s.save
    end
    
    %w[Projektas1 Projektas2 Projektas3 Projektas4 Projektas5].each_with_index do |name, i|
      rand_date = rand(400).days.ago
      Project.create(
        :name       => name,
        :code       => "##{i}",
        :manager_id => random_employee.id,
        :start_date => rand_date.to_s(:db),
        :end_date   => (rand_date + (rand(100)+2).days).to_s(:db)
      )
    end
    
    Task.populate 1000 do |t|
      project       = random_project
      t.project_id  = project.id
      t.employee_id = random_employee.id
      t.activity_id = random_activity.id
      begin
        date = project.start_date + rand(100).days 
      end until date < project.end_date
      t.date        = date
      t.description = Faker::Lorem.sentence
      t.hours_spent = rand(10) + 1
    end
    
    Task.all.each do |t|
      EmployeesProjects.create(
        :employee_id => t.employee_id,
        :project_id  => t.project_id
      ) unless EmployeesProjects.find_by_employee_id_and_project_id(t.employee_id, t.project_id)
    end
  end
end

def random_employee
  @employees ||= Employee.all
  @employees[rand(@employees.size)]
end

def random_sector
  @sectors ||= Sector.all
  @sectors[rand(@sectors.size)]
end

def random_position
  @positions ||= Position.all
  @positions[rand(@positions.size)]
end

def random_project
  @projects ||= Project.all
  @projects[rand(@projects.size)]
end

def random_activity
  @activities ||= Activity.all
  @activities[rand(@activities.size)]
end
