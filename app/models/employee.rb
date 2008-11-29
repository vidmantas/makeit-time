class Employee < ActiveRecord::Base
  has_many :tasks, :dependent => :destroy
  belongs_to :sector
  belongs_to :position
  has_and_belongs_to_many :projects
  
  validates_presence_of :first_name, :last_name, :sector_id, :email, :position_id
  
  named_scope :all_sorted, :order => 'first_name, last_name'
  
  def full_name
    "#{self.first_name} #{self.last_name}"
  end
  
  def hours_spent_in_project(project_id)
    self.tasks.sum(:hours_spent, :conditions => ['project_id = ?', project_id])
  end
  
  def hours_spent_in_project_with_months(project_id)
    Employee.find_by_sql ["SELECT 
      sum(t.hours_spent) AS sum_hours_spent ,
      p.start_date,
      p.end_date,
      DATE_FORMAT(t.date, \"%Y-%m\") AS 'month'
      FROM `tasks` t
      INNER JOIN projects p ON p.id = t.project_id
      WHERE (t.project_id = ?) AND (t.employee_id = ?)
      GROUP BY month", project_id, self.id]    
  end
  
  def started_in_project(project_id)
    self.tasks.minimum(:date, :conditions => ['project_id = ?', project_id])
  end
  
  def finished_in_project(project_id)
    date = self.tasks.maximum(:date, :conditions => ['project_id = ?', project_id])
    return same_month?(Date.today, date) ? '--' : date
  end

  def same_month?(first_date, second_date)
    first_date.to_s[0..6] == second_date.to_s[0..6]
  end
  
  def name_with_sector
    "#{self.full_name} (#{self.sector.name})"
  end
end
