class HomeController < ApplicationController
  TASKS_PER_PAGE = 10
  
  before_filter { |c| c.assert_permission :tasks_enter_personal, 
                                          :show_message => false,
                                          :url => c.url_for(:controller => 'projects') }
  
  def index
    @task   = Task.new(:date => Time.now.to_s(:date))
    @tasks  = Task.paginate :page => params[:page], :per_page => TASKS_PER_PAGE,
      :conditions => ['employee_id = ?', current_user.id], 
      :order      => 'date DESC, created_at DESC',
      :include    => [:activity, :project]
  end
end
