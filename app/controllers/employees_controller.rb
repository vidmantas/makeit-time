class EmployeesController < ApplicationController
  EMPLOYEES_PER_PAGE = 20
  
  before_filter { |c| c.assert_permission :employees_view_some }
  
  # GET /employees
  # GET /employees.xml
  def index
    @employees = Employee.paginate :page => params[:page], :per_page => EMPLOYEES_PER_PAGE, 
      :order => 'first_name, last_name', :include => [:sector, :position]
    @employee = Employee.new

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @employees }
    end
  end

  # GET /employees/1
  # GET /employees/1.xml
  def show
    assert_permission :employees_view, :id => params[:id]
    @employee = Employee.find(params[:id], :include => [:sector, :position])
    @projects = @employee.projects
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @employee }
    end
  end

  # GET /employees/new
  # GET /employees/new.xml
  def new
    assert_permission :employees_create
    @employee = Employee.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @employee }
    end
  end

  # GET /employees/1/edit
  def edit
    assert_permission :employees_edit, :id => params[:id]
    @employee = Employee.find(params[:id])
  end

  # POST /employees
  # POST /employees.xml
  def create
    assert_permission :employees_create
    @employee = Employee.new(params[:employee])

    if @employee.save
      flash[:notice] = 'Darbuotojas sukurtas sėkmingai.'
      render :update do |page|
        page.redirect_to :action => 'index'
      end
    else
      render :partial => 'add_employee'
    end
  end

  # PUT /employees/1
  # PUT /employees/1.xml
  def update
    assert_permission :employees_edit, :id => params[:id]
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
    assert_permission :employees_destroy, :id => params[:id]
    @employee = Employee.find(params[:id])
    @employee.destroy

    respond_to do |format|
      format.html { redirect_to(employees_url) }
      format.xml  { head :ok }
    end
  end
end
