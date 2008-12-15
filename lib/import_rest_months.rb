class ImportRestMonths < Import
  def initialize
    super("employees_rest_months_081116.csv", false)
    commit
  end
  
  def commit
    puts "Importing rest months..."
    
    sectors = Sector.find(:all, :include => :employees)
    map = []
    
    first_row = true
    import do |row|
      if first_row
        # map possible data
        row.each do |value|
          if value =~ /dirba/
            map << { :sector => value.match(/S(\d)/)[1].to_i, :employee => value.match(/S\d-(\d{2})/)[1].to_i }
          else
            map << nil
          end          
        end
      else 
        date = Date.parse("#{row[0]}-#{row[1]}-01")
        row.each_with_index do |value, index|
          if index > 1 and value.to_i.zero?
            # puts "Rest month #{date} for #{map[index][:employee]} from #{map[index][:sector]}"
            RestMonth.create(
              :date => date, 
              :employee_id => (sectors[map[index-1][:sector]]).employees[map[index-1][:employee]].id
            )
          end
        end
      end
      
      first_row = false
    end
  end
end
