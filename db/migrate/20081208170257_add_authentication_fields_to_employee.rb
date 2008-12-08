class AddAuthenticationFieldsToEmployee < ActiveRecord::Migration
  def self.up
    # already have 'login' field
    add_column :employees, 'crypted_password',  :string
    add_column :employees, 'password_salt',     :string
    add_column :employees, 'persistence_token', :string
    add_column :employees, 'login_count',       :integer
    add_column :employees, 'last_request_at',   :datetime
    add_column :employees, 'last_login_at',     :datetime
    add_column :employees, 'current_login_at',  :datetime
    add_column :employees, 'last_login_ip',     :string
    add_column :employees, 'current_login_ip',  :string
  end

  def self.down
    remove_column :employees, 'crypted_password'
    remove_column :employees, 'password_salt'
    remove_column :employees, 'persistence_token'
    remove_column :employees, 'login_count'
    remove_column :employees, 'last_request_at'
    remove_column :employees, 'last_login_at'
    remove_column :employees, 'current_login_at'
    remove_column :employees, 'last_login_ip'
    remove_column :employees, 'current_login_ip'
  end
end
