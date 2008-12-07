class ReportsController < ApplicationController
  def time_usage
    if request.post?
      @sectors = Sector.all
      set_periods params[:period]['periods']
      render :partial => 'time_usage_report'
    end
  end
  
  def switching
    @sectors = Sector.all
    set_periods 'years'
  end
  
  def progress
    if request.post?
      @sectors = Sector.all
      set_periods params[:period]['periods']
      render :partial => 'progress_report'
    end
  end
  
  protected
  
  def set_periods(period)
    @periods = []
    
    start_date = Task.minimum(:date).to_date
    end_date   = Task.maximum(:date).to_date
    
    case period
    when 'years'
      start_date.each_year_until(end_date) do |year|
        @periods << {:name => "#{year} metai", :starts => "#{year}-01-01", :ends => "#{year}-12-31"}
      end
      
    when 'quarters'
      start_date.each_quarter_until(end_date) do |quarter|
        @periods << {
          :name   => "#{quarter.year} metai, #{quarter.month/3+1} ketv.",
          :starts => "#{quarter.beginning_of_quarter}",
          :ends   => "#{quarter.end_of_quarter}"
        }
      end
      
    when 'months'
      start_date.each_month_until(end_date) do |month|
        @periods << {
          :name   => "#{month.year} metai, #{month.month} mėn.",
          :starts => "#{month.beginning_of_month}",
          :ends   => "#{month.end_of_month}"
        }
      end
    end
  end
end
