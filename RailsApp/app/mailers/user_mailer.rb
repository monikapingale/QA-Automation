class UserMailer < ApplicationMailer
  default from: 'monika.pingale@enzigma.in'
  def welcome_email
    @user = params[:user]
    @url  = 'http://192.168.193.121:3000/app#!/users_view'
    mail(to: @user.email, subject: 'Welcome to My Awesome Site')
  end
end
