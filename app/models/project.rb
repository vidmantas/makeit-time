class Project < ActiveRecord::Base
  has_many :tasks, :dependent => :destroy
  has_and_belongs_to_many :employees
  belongs_to :manager, :class_name => 'Employee'
  
  validates_uniqueness_of :code
  validates_presence_of :code, :name, :start_date, :end_date, :manager_id
  
  def employee_hours_by_month_and_activity(employee, month, activity)
    employee.tasks.sum(:hours_spent, 
      :conditions => ['project_id = ? AND activity_id = ? AND DATE_FORMAT(date, "%Y-%m") = ?', self.id, activity.id, month.to_s[0..6]])
  end
  
  def sectors
    Sector.all_for_project(self.id, self.manager.sector_id)
  end
  
  def graph_data_for_sector(sector_id)
    data = []
    
    self.start_date.each_month_until(self.end_date) do |month|
      sum = Task.find_by_sql(['
        SELECT
          SUM(t.hours_spent) AS `total`
        FROM tasks t
        INNER JOIN employees e ON e.id = t.employee_id
        WHERE e.sector_id = ? 
          AND t.project_id = ?
          AND DATE_FORMAT(t.date, "%Y-%m") = ?',
          sector_id, self.id, month.to_s[0..6]
      ]).first.total.to_i
      data << sum
    end
      
    data
  end
  
  def graph_data_for_sector_other_than(sector_id)
    # COPY PASTE - kaip negrazu :-)
    data = []
    
    self.start_date.each_month_until(self.end_date) do |month|
      sum = Task.find_by_sql(['
        SELECT
          SUM(t.hours_spent) AS `total`
        FROM tasks t
        INNER JOIN employees e ON e.id = t.employee_id
        WHERE e.sector_id != ? 
          AND t.project_id = ?
          AND DATE_FORMAT(t.date, "%Y-%m") = ?',
          sector_id, self.id, month.to_s[0..6]
      ]).first.total.to_i
      data << sum
    end
      
    data
  end
  
  def self.distinct_years
    start_dates = Project.find(:all, :select => "DISTINCT(YEAR(start_date)) AS 'year'").map(&:year)
    end_dates   = Project.find(:all, :select => "DISTINCT(YEAR(end_date)) AS 'year'").map(&:year)
    
    (start_dates + end_dates).uniq.sort.reverse
  end
  
  def all_hours
    self.tasks.sum(:hours_spent)
  end
  
  def hours(start_date, end_date, sectors_ids)
    sql = "
      SELECT
	SUM(t.hours_spent) AS 'total_hours'
      FROM tasks t
      INNER JOIN employees e ON e.id = t.employee_id
      WHERE e.sector_id IN(?) AND t.date >= ? AND t.date <= ? AND t.project_id = ?"
    
    Project.find_by_sql([sql, sectors_ids, start_date, end_date, self.id]).first.total_hours.to_i
  end
end
