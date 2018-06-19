
class DashboardController < ApplicationController
=begin

  require 'google/apis/gmail_v1'
  require 'googleauth'
  require 'googleauth/stores/file_token_store'

  require 'fileutils'
  OOB_URI = 'http://localhost:3000'
  APPLICATION_NAME = 'Gmail API Ruby Quickstart'
  CLIENT_SECRETS_PATH = 'client_secret.json'
  CREDENTIALS_PATH = File.join(Dir.home, '.credentials',
                               "gmail-ruby-quickstart.yaml")
  SCOPE = Google::Apis::GmailV1::AUTH_GMAIL_READONLY

##https://accounts.google.com/o/oauth2/auth?access_type=offline&approval_prompt=force&client_id=388234064505-1tp3vms4afh8m2lc2d630oq7dr40st86.apps.googleusercontent.com&include_granted_scopes=true&redirect_uri=http://localhost:3000&response_type=code&scope=https://www.googleapis.com/auth/gmail.readonly
# Ensure valid credentials, either by restoring from the saved credentials
# files or intitiating an OAuth2 authorization. If authorization is required,
# the @@users's default browser will be launched to approve the request.
#
# @return [Google::Auth::UserRefreshCredentials] OAuth2 credentials
#
  def authorize
    FileUtils.mkdir_p(File.dirname(CREDENTIALS_PATH))
    puts CLIENT_SECRETS_PATH
    client_id = Google::Auth::ClientId.from_file(CLIENT_SECRETS_PATH)
    token_store = Google::Auth::Stores::FileTokenStore.new(file: CREDENTIALS_PATH)
    authorizer = Google::Auth::UserAuthorizer.new(
        client_id, SCOPE, token_store)
    user_id = 'default'
    credentials = authorizer.get_credentials(user_id)
    if credentials.nil?
      url = authorizer.get_authorization_url(
          base_url: OOB_URI)
      code = gets
      #credentials = authorizer.get_and_store_credentials_from_code(
      #user_id: user_id, code: code, base_url: OOB_URI)
    end
    return url.gsub('/oauth2callback','')
  end
=end
  def index
    puts "Session is #{session[:email_address]}"
    if session[:email_address].nil?
      #redirect_to('/autherize')
      render :template => 'home.html.erb'
    else
      puts "Querying"
      puts User.where(email: session[:email_address]).empty?
      if !User.where(email: session[:email_address]).empty?
        puts "Valid User"
      else
        puts 'Invalid User'
        user = User.new();
        user.email = session[:email_address]
        tempEmailHolder = []
        User.where(:admin => true).each do |user|
          tempEmailHolder.push(user['email'])
        end
        MailUtility.new('monika.pingale@enzigma.in' , 'arya@1994').sendMail( tempEmailHolder.join(','), UserMailer.with(user: user).welcome_email.to_s,'Add New User')
        render :template => 'permission.html.erb'
      end
    end
    #redirect_to authorize
    #redirect_to 'https://test.salesforce.com/services/oauth2/authorize?response_type=code&client_id=3MVG9PE4xB9wtoY9IbhNtYSuAVOegE_yR6h8s4fwIITYduuN1V8Tt84iUykgOM_X3lj7md_cCbNBlsN6D6LSc&redirect_uri=http://localhost:3000'

    #@@@users = Profiles
  	#puts Profiles
  	#puts "hey....."
  	#puts @User
  end
end
