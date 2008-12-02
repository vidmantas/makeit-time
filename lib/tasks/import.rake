desc "Import client data"
task :import => :environment do
  ImportSectors.new
  ImportEmployees.new
  ImportProjects.new
  ImportTasks.new
end