# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include HoptoadNotifier::Catcher
  
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '29bb43e3e3a035d9ea73bf45febaf1b4'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  filter_parameter_logging :password, :password_confirmation
  helper_method :current_user_session, :current_user, :require_permission, :assert_permission,
    :allow_tools?, :show_notices?
  before_filter :set_user_language

  def require_permission(key, options = {})
    return false unless current_user
    c = current_user
    case key
    when :task_enter_personal
      not c.is_top_manager
    when :task_edit
      t = Task.find(options[:id])
      t.employee == c and
        t.created_at > 5.days.ago # rails way
      # (Time.now - t.created_at).round / (60 * 60 * 24) <= 5
    when :employees_view_some
      e = Employee.find(params[:id]) rescue false # if has params[:id] and trying to access report of himself
      c.is_sector_manager or c.is_top_manager or c.is_project_manager or c == e
    when :employees_view_all
      c.is_top_manager
    when :employees_view
      e = Employee.find(options[:id])
      # TODO: is sector manager and e participates in project of that sector
      e == c or 
        e.in_project_managed_by(c) or
        (c.is_sector_manager and e.sector == c.sector) or
        (c.is_top_manager)
    when :employees_project_view_hours
      e = Employee.find(options[:employee_id])
      p = Project.find(options[:project_id])
      e == c or
        (p.manager == c) or
        (c.is_sector_manager and p.manager.sector == c.sector) or
        c.is_top_manager
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
    when :sectors_view_some
      c.is_sector_manager or c.is_top_manager
    when :sectors_view
      s = Sector.find(options[:id])
      s.visible and (c.is_sector_manager or c.is_top_manager)
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
      if not current_user
        message = 'Prašome prisijungti'
        redirect_to :controller => 'employee_sessions', :action => 'new'
      else
        message = "Neturite teisių peržiūrėti šį puslapį."
        redirect_to :back rescue redirect_to options.fetch(:url, '/')
      end
      if options.fetch(:show_message, true)
        flash[:notice] = message
      end
      false
    else
      true
    end
  end
  
  def sort
    if params[:id]
      if session["#{self.controller_name}_sort_column"] == params[:id]
        switch_order_by
      else
        session["#{self.controller_name}_sort_column"] = params[:id]
        session["#{self.controller_name}_sort_by"] = 'asc'
      end
      
      redirect_to :back rescue redirect_to :action => 'index'
    end
  end
  
  protected
  
  def allow_tools?
    true
  end
  
  def show_notices?
    true
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
  
  def switch_order_by
    session["#{self.controller_name}_sort_by"] = if session["#{self.controller_name}_sort_by"] == 'asc'
      'desc'
    else
      'asc'
    end
  end
  
  def sort_order  
    if session["#{self.controller_name}_sort_column"]
      order = "#{session["#{self.controller_name}_sort_column"].gsub('-', '.')} "
      order << session["#{self.controller_name}_sort_by"]
    else
      order = "#{self.controller_name}.id DESC"
    end
    order << ", #{self.controller_name}.created_at DESC"
  end
end
