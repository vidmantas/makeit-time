class Position < ActiveRecord::Base
  has_many :employees
  named_scope :all, :conditions => ['visible = ?', true], :order => 'name'
end
