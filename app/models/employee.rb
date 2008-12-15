class Employee < ActiveRecord::Base
  include RFC822
  
  acts_as_authentic :validate_fields => false

  has_many :tasks, :dependent => :destroy
  belongs_to :sector
  belongs_to :position
  has_and_belongs_to_many :projects
  
  validates_presence_of :first_name, :sector_id, :position_id, :last_name, :email
  validates_uniqueness_of :email, :if => lambda{ |e| !e.email.blank? }
  validates_format_of :email, :with => RFC822::EmailAddress, :if => lambda{ |e| !e.email.blank? }
  validates_confirmation_of :password, :if => lambda{ |e| !e.password.blank? }
  validates_length_of :password, :minimum => 3, :on => :update
  
  attr_protected :is_top_manager # can't be mass-assigned
  attr_accessor :current_password # for changing password
  
  named_scope :all_sorted, :order => 'first_name, last_name'
  
  before_create :set_login
  after_create :set_password_and_email
  
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
    if self.sector
      "#{self.full_name} (#{self.sector.name})"
    else
      self.full_name
    end
  end
  
  def managed_projects
    Project.find(:all, :conditions => ['manager_id = ?', self.id])
  end
  
  def self.search(words)
    self.find(:all, :conditions => Where { |w|
      words.each do |word|
        w.and 'first_name LIKE ? OR last_name LIKE ?', "%#{word}%", "%#{word}%"
      end
    })
  end

  # Permissions
  # is_project_manager says if users manages/-ed a project
  # is_sector_manager says if user manages a sector
  # is_top_manager (a field) says where user is in top management
  
  def is_project_manager
    Project.count(:conditions => ['manager_id = ?', self.id]) > 0
  end
  
  def is_sector_manager
    self.sector.manager == self
  end
  
  def in_project_managed_by(project_manager_id)
    self.projects.exists?(:manager_id => project_manager_id)
  end

  protected
  
  def set_login
    login = self.first_name.dup # not by reference
    index = number = 0
    
    while true
      if Employee.find_by_login(login)
        if self.last_name[index]
          login << self.last_name[index].chr
        else
          number += 1
          login << number.to_s
        end
        index += 1
      else
        break
      end
    end
    
    self.login = login
  end
  
  def set_password_and_email
    password = String.random
    update_attribute(:password, password)
    Mailer.deliver_send_password(self, password)
  end
end

class String
  def self.random(length = 6)
    list    = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    random  = ''
    1.upto(length) { random << list[rand(list.size-1)] }
    return random
  end
end