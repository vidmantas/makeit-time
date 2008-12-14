class Sector < ActiveRecord::Base
  extend ActiveSupport::Memoizable

  NORMAL_WORK_LOAD = 130
  
  belongs_to :manager, :class_name => 'Employee'
  has_many :employees, :order => 'first_name, last_name'
  
  named_scope :all_except, lambda{ |*args| {
      :conditions => ['visible = ? AND id != ?', true, args.first],
      :order      => 'name'
  }}

  named_scope :all, :conditions => ['visible = ?', true], :order => 'name'
    
  def self.all_for_project(project_id, manager_sector_id)
    # We must receive all sectors, even those where sum(hours_spent) = 0.
    Sector.find_by_sql ["SELECT 
        s.id,
        s.name,
        SUM(t.hours_spent)  AS 'total_hours'
      FROM tasks t 
      INNER JOIN employees e ON e.id = t.employee_id
      INNER JOIN sectors s ON s.id = e.sector_id
      WHERE t.project_id = ?
      GROUP BY s.id
      ORDER BY s.id = ? DESC, total_hours DESC", 
      project_id, manager_sector_id
    ]
  end
  
  def hours_spent(start_date, end_date, manager_sector = true)
    manager_projects_ids = Project.find(:all, :conditions => ['manager_id IN(?)', self.employees.map(&:id)]).map(&:id)
      
    sql = "
        SELECT 
          SUM(hours_spent) AS 'total'
        FROM tasks t
        INNER JOIN employees e ON e.id = t.employee_id
        WHERE e.sector_id = ? AND t.date >= ? AND t.date <= ?"
    if manager_sector
      sql << " AND t.project_id IN(?)"
    else
      sql << " AND t.project_id NOT IN(?)"
    end
    
    Sector.find_by_sql([sql, self.id, start_date, end_date, manager_projects_ids]).first.total
  end
  
  def other_sectors_hours(start_date, end_date)
    manager_projects_ids = Project.find(:all, :conditions => ['manager_id IN(?)', self.employees.map(&:id)]).map(&:id)
    
    sql = "
        SELECT 
          SUM(hours_spent) AS 'total'
        FROM tasks t
        INNER JOIN employees e ON e.id = t.employee_id
        WHERE e.sector_id != ? AND t.date >= ? AND t.date <= ? AND t.project_id IN(?)"
    Sector.find_by_sql([sql, self.id, start_date, end_date, manager_projects_ids]).first.total
  end
  
  def hours_for_sector(sector, start_date, end_date)
    manager_projects_ids = Project.find(:all, :conditions => ['manager_id IN(?)', sector.employees.map(&:id)]).map(&:id)
    sql = "
        SELECT 
          SUM(hours_spent) AS 'total'
        FROM tasks t
        INNER JOIN employees e ON e.id = t.employee_id
        WHERE e.sector_id = ? AND t.date >= ? AND t.date <= ? AND t.project_id IN(?)"
    Sector.find_by_sql([sql, self.id, start_date, end_date, manager_projects_ids]).first.total
  end
  
  def projects(start_date, end_date, this_sector_first = true)
    sql = "
      SELECT 
	p.*
      FROM tasks t
      INNER JOIN projects p ON p.id = t.project_id
      INNER JOIN employees m ON m.id = p.manager_id
      WHERE 
        t.date >= ? AND t.date <= ?
        AND t.employee_id IN(?)
      GROUP BY p.id ORDER BY "
    sql << " m.sector_id = #{self.id} DESC, " if this_sector_first
    sql << " p.name"
    Project.find_by_sql [sql, start_date, end_date, self.employees.map(&:id)]
  end
  
  def has_projects(start_date, end_date)
    employees_ids = self.employees.map(&:id)
    conditions = 'manager_id IN(?) 
      AND ((start_date BETWEEN DATE(?) AND DATE(?) OR end_date BETWEEN DATE(?) AND DATE(?))
      OR (DATE(?) BETWEEN start_date AND end_date OR DATE(?) BETWEEN start_date AND end_date))'
    Project.find(:all, 
      :conditions => [conditions, employees_ids, start_date, end_date, start_date, end_date, start_date, end_date])
  end
  
  def time_usage_for(start_date, end_date)
    employees_ids = self.employees.map(&:id)
    sql = "
      SELECT SUM(`hours_spent`) AS `total_hours`
      FROM tasks t
      WHERE t.employee_id IN(?) AND t.date >= ? AND t.date <= ?
    "
    Sector.find_by_sql([sql, employees_ids, start_date, end_date]).first.total_hours
  end
  
  def theoretical_hours(start_date, end_date)
    period = Time.parse(end_date).month - Time.parse(start_date).month + 1    
    self.employees.size * period * NORMAL_WORK_LOAD
  end
  
  def overtime(start_date, end_date)
    sql = "SELECT t.employee_id, (SUM(hours_spent) - #{NORMAL_WORK_LOAD}) AS overtime, DATE_FORMAT(date, \"%Y-%m\") AS month
      FROM tasks t
      WHERE t.employee_id IN(?) AND t.date >= ? AND t.date <= ?
      GROUP BY month, t.employee_id
      ORDER BY t.employee_id, month"
    times = Task.find_by_sql([sql, self.employees.map(&:id), start_date, end_date])
    
    total = 0
    times.each do |t|
      total += t.overtime.to_i if t.overtime.to_i > 0
    end
    total
  end
  
  def inactivity_percent(start_date, end_date)
    theor_hours  = theoretical_hours(start_date, end_date).to_f
    actual_hours = time_usage_for(start_date, end_date).to_f # will be cached
    return (((theor_hours - actual_hours) * 100) / theor_hours).round
  end
  
  def overtime_percent(start_date, end_date)
    theor_hours    = theoretical_hours(start_date, end_date).to_f
    overtime_hours = overtime(start_date, end_date).to_f
    return ((overtime_hours * 100)/theor_hours).round
  end
  
  def total_switches(start_date, end_date)
    total = 0
    
    self.employees.each do |employee|
      ids = Task.find(:all, :select => 'project_id', 
        :conditions => ['employee_id = ? AND date >= ? AND date <= ?',
          employee.id, start_date, end_date], :order => 'date').map(&:project_id)
      
      #logger.warn "IDS=#{ids.inspect}"
      
      # Sugrupuojam ids pagal persijungimus, tarpinius "ignoruojam"
      # rezultatas: [[1, 2], [2, 1], [1, 3], [3, 4], [4, 8]] ir t.t.
      switches = []
      ids.each_with_index do |task, index|
        switches << [task, ids[index+1]] if task != ids[index+1] 
      end
      
      # Jeigu yra situacija [1, 2], [2, 1] - tai yra persijungimas
      switches.each_with_index do |switch, index|
        total += 1 if !switches[index+1].nil? and switch.first == switches[index+1].last
      end
    end
    
    total
  end
  
  def switches_for_hours(start_date, end_date, hours = 1000)
    total_switches = total_switches(start_date, end_date)
    total_hours    = time_usage_for(start_date, end_date).to_f
    sprintf("%.2f", total_switches/(total_hours/hours))
  end
  
  def income(start_date, end_date)
    income_for_short_projects(start_date, end_date).to_f + 
      income_for_medium_projects(start_date, end_date).to_f + 
      income_for_long_projects(start_date, end_date).to_f
  end
  
   # iki 6 men trukmes
  def income_for_short_projects(start_date, end_date)
    projects_ids = self.has_projects(start_date, end_date).map(&:id)
    sql = "SELECT SUM(t.hours_spent) AS 'total_hours' 
      FROM tasks t
      INNER JOIN projects p ON p.id = t.project_id
      WHERE p.id IN(?) AND p.duration <= 6 AND p.end_date <= ?
    "
    Sector.find_by_sql([sql, projects_ids, end_date]).first.total_hours 
  end
  
  # 7-18 men trukmes: 40% projekto vidury, 60% - pasibaigus
  def income_for_medium_projects(start_date, end_date)
    total = 0.0
    
    start_date = to_date(start_date)
    end_date   = to_date(end_date)
    
    self.has_projects(start_date, end_date).each do |project|
      if project.duration.to_i >= 7 and project.duration.to_i <= 18
        # 40%
        first_payment_on = project.start_date + (project.duration / 2).months
        if first_payment_on >= start_date and first_payment_on <= end_date
          total += project.total_value * 0.4
        end
        
        # 60%
        if project.end_date >= start_date and project.end_date <= end_date
          total += project.total_value * 0.6
        end
      end
    end

    total
  end
  
  def income_for_long_projects(start_date, end_date)
    total = 0.0
    
    start_date = to_date(start_date)
    end_date   = to_date(end_date)
    
    self.has_projects(start_date, end_date).each do |project|
      if project.duration.to_i > 18
        # 20% - 8 menesi
        payment_on = project.start_date + 7.months
        if payment_on >= start_date and payment_on <= end_date
          total += project.total_value * 0.2
        end
        
        # 20% - 15 menesi
        payment_on = project.start_date + 14.months
        if payment_on >= start_date and payment_on <= end_date
          total += project.total_value * 0.2
        end
        
        # 60% - pabaigoje
        if project.end_date >= start_date and project.end_date <= end_date
          total += project.total_value * 0.6
        end
      end
    end
    
    total
  end
  
  protected
  
  def to_date(date)
    if date.respond_to?(:month)
      date
    else
      Time.parse(date).to_date
    end
  end
  
  memoize :overtime, :theoretical_hours, :time_usage_for, :has_projects
end
