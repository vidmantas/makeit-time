class Mailer < ActionMailer::Base
  def send_password(employee, password)
    subject    'Jums sukurtas vartotojas laiko apskaitos sistemoje'
    recipients employee.email
    from       'no-reply@makeit-time.com'
    sent_on    Time.now
    
    body       :login => employee.login, :password => password, 
               :url => 'http://www.makeit-time.com/'
  end
end
