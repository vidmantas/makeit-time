class SearchController < ApplicationController
  RESULTS_COUNT = 10
  
  def quick_search
    @words = params[:quick][:search].split
    @results = []
    
    Employee.search(@words).each do |e| 
      if require_permission :employees_view, :id => e.id
        @results << { :name => e.full_name, :url => url_for(e), :kind => :employee } 
      end
    end
    
    Project.search(@words).each do |p|
      if require_permission :projects_view, :id => p.id
        @results << { :name => p.name, :url => url_for(p), :kind => :project }
      end
    end
    
    Sector.search(@words).each do |s|
      if require_permission :sectors_view, :id => s.id
        @results << { :name => s.name, :url => url_for(s), :kind => :sector }
      end
    end
    
    @results = rank(@results, @words)[0..RESULTS_COUNT-1]
    render :layout => false
  end
  
private

  def rank(list, words)
    regexp = Regexp.union(*words)
    list.sort! { |one, two| one[:name].scan(regexp).length <=> two[:name].scan(regexp).length }
  end

end
