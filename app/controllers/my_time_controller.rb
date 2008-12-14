class MyTimeController < ApplicationController
  def index
    return unless assert_permission :employees_view, :id => current_user
    @employee = current_user
    @projects = @employee.projects
    @top_project_graph = open_flash_chart_object(300, 200, "/graphs/employee_top_projects/#{@employee.id}")
    render :template => 'employees/show'
  end
end
