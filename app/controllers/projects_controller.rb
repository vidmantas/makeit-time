class ProjectsController < ApplicationController
  PROJECTS_PER_PAGE = 20
  
  before_filter { |c| c.assert_permission :projects_view_some }
  
  # GET /projects
  # GET /projects.xml
  def index
    @projects = Project.paginate :page => params[:page], :per_page => PROJECTS_PER_PAGE, 
      :order => ['-id'], :include => [:manager]
    @project  = Project.new
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @projects }
    end
  end

  def show
    return unless assert_permission :projects_view, :id => params[:id]
    if params[:employee_id]
      return unless assert_permission :employees_view, :id => params[:employee_id]
      @project = Project.find(params[:id])
      @employee = Employee.find(params[:employee_id])
      @start = @employee.started_in_project(@project.id)
      # BUG: this crashes when '--' is returned
      @end   = @employee.finished_in_project(@project.id) + 1.month
      render :template => 'employees/project_report'
    else
      @project = Project.find(params[:id], :include => {:manager => :sector})
      @graph = open_flash_chart_object(600,300,"/graphs/project_intensity/#{@project.id}")
    end    
  end

  # GET /projects/new
  # GET /projects/new.xml
  def new
    return unless assert_permission :projects_create
    @project = Project.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @project }
    end
  end

  # GET /projects/1/edit
  def edit
    return unless assert_permission :projects_edit, :id => params[:id]
    @project = Project.find(params[:id])
    @employees = Employee.find(:all)
  end

  def create
   return unless  assert_permission :projects_create
    @project = Project.new(params[:project])
    
    if @project.save
      flash[:notice] = 'Projektas buvo sėkmingai išsaugotas.'
      render :update do |page|
        page.redirect_to :action => 'index'
      end
    else
      render :partial => 'add_project'
    end
  end

  # PUT /projects/1
  # PUT /projects/1.xml
  def update
    return unless assert_permission :projects_edit, :id => params[:id]
    @project = Project.find(params[:id])
    @project.employees = Employee.find(params[:employee_ids]) if params[:employee_ids]
    respond_to do |format|
      if @project.update_attributes(params[:project])
        flash[:notice] = 'Projekto duomenys buvo sėkmingai atnaujinti.'
        format.html { redirect_to(@project) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @project.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.xml
  def destroy
    return unless assert_permission :projects_destroy, :id => params[:id]
    @project = Project.find(params[:id])
    @project.destroy

    respond_to do |format|
      format.html { redirect_to(projects_url) }
      format.xml  { head :ok }
    end
  end
end
