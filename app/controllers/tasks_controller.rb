class TasksController < ApplicationController
  # GET /tasks
  # GET /tasks.xml
  def index
    @tasks = Task.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @tasks }
    end
  end

  # GET /tasks/1
  # GET /tasks/1.xml
  def show
    @task = Task.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @task }
    end
  end

  # GET /tasks/new
  # GET /tasks/new.xml
  def new
    @task = Task.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @task }
    end
  end

  # GET /tasks/1/edit
  def edit
    return unless assert_permission :task_edit, :id => params[:id]
    @task = Task.find(params[:id])
  end

  # POST /tasks
  # POST /tasks.xml
  def create
    @task = Task.new(params[:task].merge(:employee_id => current_user.id))

    if @task.save
      flash[:notice] = 'Užduotis sėkmingai įvesta.'
      render :update do |page|
        page.remove 'add_task'
        page.redirect_to :back rescue redirect_to '/'
      end      
    else
      render :partial => 'add_task'
    end
  end

  # PUT /tasks/1
  # PUT /tasks/1.xml
  def update
    return unless assert_permission :task_edit, :id => params[:id]
    @task = Task.find(params[:id])

    if @task.update_attributes(params[:task].merge(:employee_id => current_user.id))
      flash[:notice] = 'Užduotis sėkmingai išsaugota.'
      render :update do |page|
        page.remove "task-#{@task.id}-edit"
        page.redirect_to :back rescue redirect_to '/'
      end      
    else
      # TODO: odd gets lost...
      render :partial => 'edit_task', :locals => { :task => @task, :odd => false }
    end
  end

  # DELETE /tasks/1
  # DELETE /tasks/1.xml
  def destroy
    @task = Task.find(params[:id])
    @task.destroy

    respond_to do |format|
      format.html { redirect_to(tasks_url) }
      format.xml  { head :ok }
    end
  end
end
