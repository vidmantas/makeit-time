class Task < ActiveRecord::Base
  HOURS_PER_DAY_LIMIT = 10
  
  belongs_to :activity
  belongs_to :employee
  belongs_to :project
  
  validates_presence_of :project_id, :employee_id, :activity_id, :hours_spent, :date
  validates_numericality_of :hours_spent, :only_integer => true, :greater_than => 0
   
  protected
  
  def validate
    # 10 hours per day limit
    total = Task.sum(:hours_spent, :conditions => ['date = ? AND employee_id = ? AND id <> ?', self.date, self.employee_id, self.id])
    self.errors.add_to_base "Time limit (#{HOURS_PER_DAY_LIMIT} hours) has been reached" if total + self.hours_spent.to_i > HOURS_PER_DAY_LIMIT
  end
end
