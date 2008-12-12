# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '29bb43e3e3a035d9ea73bf45febaf1b4'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  filter_parameter_logging :password, :password_confirmation
  helper_method :current_user_session, :current_user, :require_permission, :assert_permission
  before_filter :set_user_language

  def require_permission(key, options = {})
    return false unless current_user
    c = current_user
    case key
    when :task_enter_personal
      not c.is_top_manager
    when :employees_view_some
      c.is_sector_manager or c.is_top_manager or c.is_project_manager
    when :employees_view_all
      c.is_top_manager
    when :employees_view
      e = Employee.find(options[:id])
      c == e or 
        e.in_project_managed_by(c) or
        (c.is_sector_manager and e.sector == c.sector) or
        (c.is_top_manager)
      # TODO: is sector manager and e participates in project of that sector
    when :employees_create
      c.is_sector_manager
    when :employees_edit
      c.is_sector_manager and Employee.find(options[:id]).sector == c.sector
    when :employees_destroy
      c.is_sector_manager and Employee.find(options[:id]).sector == c.sector
    when :projects_view_some
      true
    when :projects_view
      project = Project.find(options[:id])
      project.employees.include?(c) or 
        project.manager == c or
        (c.is_sector_manager and project.manager.sector == c.sector) or
        c.is_top_manager
    when :projects_create
      c.is_sector_manager
    when :projects_edit
      project = Project.find(options[:id])
      (c.is_sector_manager and project.manager.sector == c.sector) or
          project.manager == c
    when :projects_destroy
      c.is_sector_manager and Project.find(options[:id]).sector == c.sector
    when :sectors_view
      c.is_sector_manager or c.is_top_manager
    when :sectors_edit
      false
    when :reports_view
      c.is_sector_manager or c.is_top_manager
    else
      false
    end
  end
  
  def assert_permission(key, options = {})
    if not require_permission(key, options)
      flash[:notice] = "Neturite teisių peržiūrėti šį puslapį."
      if not current_user
        redirect_to url_for(:controller => 'employee_sessions', :action => 'new')
      else
        redirect_to options.fetch(:url, '/')
      end
      false
    else
      true
    end
  end
  
  private
  
  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = EmployeeSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.employee
  end
  
  def store_location
    session[:return_to] = request.request_uri
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  def set_user_language
    I18n.locale = 'lt'
  end
end
