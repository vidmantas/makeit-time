require 'csv'

class Import
  def initialize(filename)
    @csv = CSV.open("#{RAILS_ROOT}/lib/import_data/#{filename}", 'r')
    @csv.shift # ignore first line (column names)
  end
  
  def import
    raise "Not implemented" unless block_given?
    @csv.each do |row|
      yield(row)
    end
    
    @csv.close
  end
end
