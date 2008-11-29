class SectorsController < ApplicationController
  # GET /sectors
  # GET /sectors.xml
  def index
    @sectors = Sector.find(:all, :include => :manager)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @sectors }
    end
  end

  # GET /sectors/1
  # GET /sectors/1.xml
  def show
    @sector = Sector.find(params[:id])
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @sector }
    end
  end

  # GET /sectors/new
  # GET /sectors/new.xml
  def new
    @sector = Sector.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @sector }
    end
  end

  # GET /sectors/1/edit
  def edit
    @sector = Sector.find(params[:id])
  end

  # POST /sectors
  # POST /sectors.xml
  def create
    @sector = Sector.new(params[:sector])

    respond_to do |format|
      if @sector.save
        flash[:notice] = 'Sector was successfully created.'
        format.html { redirect_to(@sector) }
        format.xml  { render :xml => @sector, :status => :created, :location => @sector }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @sector.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /sectors/1
  # PUT /sectors/1.xml
  def update
    @sector = Sector.find(params[:id])

    respond_to do |format|
      if @sector.update_attributes(params[:sector])
        flash[:notice] = 'Sector was successfully updated.'
        format.html { redirect_to(@sector) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @sector.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /sectors/1
  # DELETE /sectors/1.xml
  def destroy
    @sector = Sector.find(params[:id])
    @sector.destroy

    respond_to do |format|
      format.html { redirect_to(sectors_url) }
      format.xml  { head :ok }
    end
  end
  
  def seo_report
    # TODO
  end
  
  def report
    if request.post?
      @start_date, @end_date = report_range
      
      @sector = Sector.find(params[:id])

      @this_sector    = @sector.hours_spent(@start_date, @end_date).to_i
      @other_sectors  = @sector.hours_spent(@start_date, @end_date, false).to_i
      @theory_hours   = @sector.employees.size * 160 * (@end_date.month - @start_date.month + 1)
      
      render :partial => 'report'
    else
      render :nothing => true
    end
  end
  
  protected
  
  def report_range
    start_year = Time.parse("#{params[:year]}-01-01").to_date
    end_year   = Time.parse("#{params[:year]}-12-31").to_date
    
    if params[:duration].blank?
      [start_year, end_year]
    else
      case params[:duration]
      when 'half'
        if params[:half].to_i == 1
          [start_year, Time.parse("#{params[:year]}-05-31").to_date]
        else
          [Time.parse("#{params[:year]}-06-01").to_date, end_year]
        end
      when 'quarter'
        case params[:quarter].to_i
        when 1
          [start_year, Time.parse("#{params[:year]}-03-31").to_date]
        when 2
          [Time.parse("#{params[:year]}-04-01").to_date, Time.parse("#{params[:year]}-06-30").to_date]
        when 3
          [Time.parse("#{params[:year]}-07-01").to_date, Time.parse("#{params[:year]}-09-30").to_date]
        when 4          
          [Time.parse("#{params[:year]}-10-01").to_date, end_year]
        end
      when 'month'
        month = Time.parse("#{params[:year]}-#{params[:month]}-01")
        [month.to_date, month.end_of_month.to_date]
      end
    end    
  end
end
