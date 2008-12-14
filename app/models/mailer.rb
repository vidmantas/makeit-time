class Mailer < ActionMailer::Base
  def send_password(employee, password)
    subject    'Jums sukurtas vartotojas laiko apskaitos sistemoje'
    recipients employee.email
    from       'time@projektai.lt'
    sent_on    Time.now
    
    body       :login => employee.login, :password => password, 
               :url => 'http://laikas.projektu-daktaras.lt/'
  end
end
