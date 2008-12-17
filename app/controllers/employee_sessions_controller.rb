class EmployeeSessionsController < ApplicationController
  def new
    @user_session = EmployeeSession.new
  end

  def create
    @user_session = EmployeeSession.new(params[:employee_session])
    if @user_session.save
      flash[:notice] = I18n.t "login_successful"
      if current_user.is_top_manager
        redirect_back_or_default url_for(:controller => 'projects')
      else
        redirect_back_or_default url_for(:controller => 'home')
      end      
    else
      render :action => :new
    end
  end

  def destroy
    current_user_session.destroy
    # flash[:notice] = I18n.t "logout_successful"
    # doesn't make sense now
    reset_session
    redirect_back_or_default new_employee_sessions_url
  end
  
  protected
  
  def allow_tools?
    false
  end
  
  def show_notices?
    # we render that in our template, so behold master!
    false
  end
  
end
