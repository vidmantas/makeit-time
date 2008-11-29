class Task < ActiveRecord::Base
  belongs_to :activity
  belongs_to :employee
  belongs_to :project
  
  validates_presence_of :project_id, :employee_id, :activity_id, :hours_spent, :date
  
  protected
  
  def validate
    # 10 hours per day limit
    total = Task.sum(:hours_spent, :conditions => ['date = ? AND employee_id = ?', self.date, self.employee_id])
    self.errors.add_to_base "Time limit (10 hours) has been reached" if total + self.hours_spent.to_i > 10
  end
end
