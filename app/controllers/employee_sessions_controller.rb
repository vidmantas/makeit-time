class EmployeeSessionsController < ApplicationController
  def new
    @user_session = EmployeeSession.new
  end

  def create
    @user_session = EmployeeSession.new(params[:employee_session])
    if @user_session.save
      flash[:notice] = I18n.t "login_successful"
      redirect_back_or_default url_for(:controller => 'home')
    else
      render :action => :new
    end
  end

  def destroy
    current_user_session.destroy
    flash[:notice] = I18n.t "logout_successful"
    redirect_back_or_default new_employee_sessions_url
  end
end
