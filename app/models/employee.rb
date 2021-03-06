class Employee < ActiveRecord::Base
  include RFC822
  
  acts_as_authentic do |c|
    c.validate_email_field = false
    c.validate_login_field = false
    c.validate_password_field = false
  end

  has_many :tasks, :dependent => :destroy
  has_many :rest_months, :dependent => :destroy
  belongs_to :sector
  belongs_to :position
  has_and_belongs_to_many :projects
  
  validates_presence_of :first_name, :sector_id, :position_id
  validates_presence_of :last_name, :email, :if => lambda{ |e| e.dont_validate_credentials.blank? }
  validates_uniqueness_of :email, :if => lambda{ |e| !e.email.blank? }
  validates_format_of :email, :with => RFC822::EmailAddress, :if => lambda{ |e| !e.email.blank? }
  validates_confirmation_of :password, :if => lambda{ |e| !e.password.blank? }
  validates_length_of :password, :minimum => 3, :on => :update, :if => lambda{ |e| !e.password.blank? }
  
  attr_protected :is_top_manager, :dont_validate_credentials # can't be mass-assigned
  attr_accessor :current_password, :dont_validate_credentials # for changing password
  
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
  
  def self.total_rest_months(employees_ids, start_date, end_date)
    RestMonth.count(:id, :conditions => ['employee_id IN(?) AND (date BETWEEN DATE(?) AND DATE(?))', employees_ids, start_date, end_date])
  end
  
  def self.of_sector_sorted(sector)
    self.find(:all, :conditions => ['sector_id = ?', sector.id], :order => 'first_name, last_name')
  end

  # Permissions
  # is_project_manager says if users manages/-ed a project
  # is_sector_manager says if user manages a sector
  # is_top_manager (a field) says where user is in top management
  
  def is_project_manager
    Project.count(:conditions => ['manager_id = ?', self.id]) > 0
  end
  
  def is_sector_manager
    not self.is_top_manager and self.sector.manager == self
  end
  
  def in_project_managed_by(project_manager_id)
    self.projects.exists?(:manager_id => project_manager_id)
  end
  
  def in_project_of_sector(sector_id)
    project_ids = Project.find(:all, :select => 'id', 
      :conditions => ['employees.sector_id = ?', sector_id],
      :include => ['manager']).map(&:id)
    self.projects.exists?(['id IN (?)', project_ids])
  end

  protected
  
  def set_login
    return unless login.nil?
    
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
    if password.nil?
      password = String.random
      update_attribute(:password, password)
      Mailer.deliver_send_password(self, password)
    end
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
