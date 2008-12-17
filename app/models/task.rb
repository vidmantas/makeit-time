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
    conditions = if self.new_record?
      ['date = ? AND employee_id = ?', self.date, self.employee_id]
    else
      ['date = ? AND employee_id = ? AND id != ?', self.date, self.employee_id, self.id]
    end
    
    total = Task.sum(:hours_spent, :conditions => conditions)
    self.errors.add_to_base "Dienos laiko limitas (#{HOURS_PER_DAY_LIMIT} val.) viršytas" if total + self.hours_spent.to_i > HOURS_PER_DAY_LIMIT
    
    # Future?
    if self.date and self.date > Date.today
      self.errors.add(:date, :cant_be_in_future)
    end
  end
end
