require 'mail'
class UserNotifierMailer < ApplicationMailer
  default :from => 'monikapingale08.mp@gmail.com'
  layout 'user_notifier_mailer'
  # send a signup email to the @@users, pass in the @@users object that   contains the @@users's email address
  def send_signup_email(user)
    puts "@@users is #{user.email}"
    @users = user
    mailToSend = mail(
          :to => user.email,
          :subject => 'Thanks for signing up for our amazing app',
          :content_type => 'text/html',
          :template_path => 'user_notifier_mailer',
          :template_name => 'send_signup_email.html.erb'
          )
   puts  ActionMailer::Base::deliver_mail(mailToSend)
  end
end
