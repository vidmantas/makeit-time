class SearchController < ApplicationController
  def quick_search
    words = params[:quick][:search].split
    @results = []
    
    Employee.search(words).each do |e| 
      @results << { :name => e.full_name, :url => url_for(e) } 
    end
    
    Project.search(words).each do |p|
      @results << { :name => p.name, :url => url_for(p) }
    end
    
    Sector.search(words).each do |s|
      @results << { :name => s.name, :url => url_for(s) }
    end
    render :layout => false
  end

end
