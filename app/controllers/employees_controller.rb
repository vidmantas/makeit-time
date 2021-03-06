class EmployeesController < ApplicationController
  EMPLOYEES_PER_PAGE = 20
  
  # GET /employees
  # GET /employees.xml
  def index
    return unless assert_permission :employees_view_some
    
    # Select only viewable employees
    conditions = []
    if not current_user.is_top_manager
      sql = ""; bound = []
      if current_user.is_sector_manager
        sql << "employees.sector_id = ? OR employees.id IN (?) OR "
        bound << current_user.sector.id
        sector_employee_ids = current_user.sector.employees.map(&:id).uniq
        sector_project_ids = Project.find(:all,
          :conditions => ['manager_id IN (?)', sector_employee_ids]).map(&:id)
        bound << EmployeesProjects.find(:all,
          :conditions => ['project_id IN (?)', sector_project_ids]).map(&:employee_id)
      end
      sql << "employees.id = ? OR employees.id IN (?)"
      bound << current_user.id
      bound << EmployeesProjects.find(:all, 
        :conditions => ['project_id IN (?)', current_user.managed_projects.map(&:id)]).map(&:employee_id).uniq
      conditions = [sql] + bound
    end
    
    @employees = Employee.paginate :page => params[:page], :per_page => EMPLOYEES_PER_PAGE, 
      :order => sort_order, :include => [:sector, :position],
      :conditions => conditions
    @employee = Employee.new

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @employees }
    end
  end

  # GET /employees/1
  # GET /employees/1.xml
  def show
    return unless assert_permission :employees_view, :id => params[:id]
    @employee = Employee.find(params[:id], :include => [:sector, :position])
    @projects = @employee.projects
    @top_project_graph = open_flash_chart_object(300, 200, "/graphs/employee_top_projects/#{@employee.id}")
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @employee }
    end
  end

  # GET /employees/new
  # GET /employees/new.xml
  def new
    return unless assert_permission :employees_create
    @employee = Employee.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @employee }
    end
  end

  # GET /employees/1/edit
  def edit
    return unless assert_permission :employees_edit, :id => params[:id]
    @employee = Employee.find(params[:id])
  end

  # POST /employees
  # POST /employees.xml
  def create
    return unless assert_permission :employees_create
    @employee = Employee.new(params[:employee])

    if @employee.save
      flash[:notice] = 'Darbuotojas sukurtas sėkmingai.'
      render :update do |page|
        page.remove 'add_employee'
        page.redirect_to :action => 'index'
      end
    else
      render :partial => 'add_employee'
    end
  end

  # PUT /employees/1
  # PUT /employees/1.xml
  def update
    return unless assert_permission :employees_edit, :id => params[:id]
    @employee = Employee.find(params[:id])

    respond_to do |format|
      if @employee.update_attributes(params[:employee])
        flash[:notice] = 'Darbuotojo duomenys buvo išsaugoti sėkmingai.'
        format.html { redirect_to(@employee) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @employee.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /employees/1
  # DELETE /employees/1.xml
  def destroy
    return unless assert_permission :employees_destroy, :id => params[:id]
    @employee = Employee.find(params[:id])
    @employee.destroy

    respond_to do |format|
      format.html { redirect_to(employees_url) }
      format.xml  { head :ok }
    end
  end
  
  def change_password
    @employee = Employee.find(params[:id])
    if request.post? and @employee == current_user
      @employee.password  = params[:employee][:password]
      @employee.password_confirmation = params[:employee][:password_confirmation]
      @employee.dont_validate_credentials = true

      # check password
      es = EmployeeSession.new(:login => current_user.login, :password => params[:employee][:current_password])
      @employee.errors.add(:current_password, :invalid) unless es.valid?
        
      if @employee.errors.empty? && @employee.save
        flash[:notice] = t('employee.pass_changed')
        render :update do |page|
          page.remove 'change_password'
          page.redirect_to :back rescue redirect_to :action => 'show', :id => @employee
        end        
      else
        render :partial => 'change_password'
      end
    else
      # should never happen :-)
      render :nothing => true
    end
  end
end
