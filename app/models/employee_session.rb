class EmployeeSession < Authlogic::Session::Base
  login_blank_message I18n.translate('activerecord.errors.messages')[:blank]
  password_blank_message I18n.translate('activerecord.errors.messages')[:blank]
end