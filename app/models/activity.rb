class Activity < ActiveRecord::Base
  has_many :tasks
  
  def self.enterable
    Activity.find(:all, :conditions => [ "is_enterable = ?", true ])
  end
end
