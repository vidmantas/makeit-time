class Sector < ActiveRecord::Base
  belongs_to :manager, :class_name => 'Employee'
  has_many :employees, :order => 'first_name, last_name'
  
  named_scope :all_except, lambda{ |*args| {
    :conditions => ['id != ?', args.first],
    :order      => 'name'
  }}
    
  def self.all_for_project(project_id, manager_sector_id)
    Sector.find_by_sql ["SELECT 
      s.id,
      s.name, 
      SUM(t.hours_spent) AS 'total_hours'
      FROM employees e
      INNER JOIN tasks t ON t.employee_id = e.id 
      INNER JOIN sectors s ON s.id = e.sector_id
      WHERE t.project_id = ?
      GROUP BY e.sector_id
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
	p.id, 
        p.code,
	p.name,
	p.start_date,
	p.end_date,
        p.manager_id
      FROM tasks t
      INNER JOIN employees e ON e.id = t.employee_id
      INNER JOIN projects p ON p.id = t.project_id
      INNER JOIN employees m ON m.id = p.manager_id
      WHERE 
        t.date >= ? AND t.date <= ?
        AND e.id IN(?)
      GROUP BY p.id ORDER BY "
    sql << " m.sector_id = #{self.id} DESC, " if this_sector_first
    sql << " p.name"
    Project.find_by_sql [sql, start_date, end_date, self.employees.map(&:id)]
  end
end
