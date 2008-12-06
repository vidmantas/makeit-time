class ReportsController < ApplicationController
  def index
  end

  def time_usage
    if request.post?
      @periods = []
      @sectors = Sector.all
      
      start_date = Task.minimum(:date).to_date
      end_date   = Task.maximum(:date).to_date
      
      if params[:period]['periods'] == 'years'
        start_date.each_year_until(end_date) do |year|
          @periods << {:name => "#{year} metai", :starts => "#{year}-01-01", :ends => "#{year}-12-31"}
        end
      else
        # quarters
        start_date.each_quarter_until(end_date) do |quarter|
          @periods << {
            :name   => "#{quarter.year} metai, #{quarter.month/3+1} ketv.",
            :starts => "#{quarter.beginning_of_quarter}",
            :ends   => "#{quarter.end_of_quarter}"
          }
        end
      end
      render :partial => 'time_usage_report'
    end
  end
  
  def switching
    @sectors = Sector.all
    @periods = []
    
    start_date = Task.minimum(:date).to_date
    end_date   = Task.maximum(:date).to_date
    
    start_date.each_year_until(end_date) do |year|
      @periods << {:name => "#{year} metai", :starts => "#{year}-01-01", :ends => "#{year}-12-31"}
    end
  end
end
