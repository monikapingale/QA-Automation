require 'json'
require 'pg'
require 'salesforce'
require 'mail'
require 'pathname'
require 'enziJenkinsUtility'
require 'enziMailUtility'
require 'git'
require_relative File.expand_path(Dir.pwd + "/src/GemUtilities/ZipFileGenerator/lib/Zip_file_generator.rb")
require_relative File.expand_path("fileutils.rb")
require_relative File.expand_path(Dir.pwd + "/src/GemUtilities/EnziTestRailUtility/lib/EnziTestRailUtility.rb")
require 'google/apis/gmail_v1'
require 'google/apis/plus_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'google/api_client/client_secrets'
require 'fileutils'
class GetdataController < ApplicationController
  protect_from_forgery with: :null_session
  @@projectId = nil
  @@suitId = nil
  @@sectionId = nil
  @@caseId = nil
  @@runId = nil
  @@browsers = nil
  CLIENT_SECRETS_PATH = 'client_secret.json'

  puts "Starting.................."
  @@testRailUtility = ''
  #The database configuration defined in database file
  #@@config   = Rails.configuration.database_configuration
  #We need PG REsult class object to store result returned by query
  #@@res = PG::Result.new
  #Connect to database
  #@@con = PG.connect :dbname => @@config[Rails.env]["database"], :user => @@config[Rails.env]["username"], :password => @@config[Rails.env]["password"]
  #OOB_URI = 'http://localhost:3000/application/advancedOptions'
  #APPLICATION_NAME = 'Gmail API Ruby Quickstart'

  #CREDENTIALS_PATH = File.join(Dir.home, '.credentials', "gmail-ruby-quickstart.yaml")
  #SCOPE = Google::Apis::GmailV1::AUTH_GMAIL_READONLY
  def authorize
    client_secrets = Google::APIClient::ClientSecrets.load(CLIENT_SECRETS_PATH)
    @@auth_client = client_secrets.to_authorization
    #client_id = Google::Auth::ClientId.from_file(CLIENT_SECRETS_PATH)
=begin
      token_store = Google::Auth::Stores::FileTokenStore.new(file: CREDENTIALS_PATH)
      authorizer = Google::Auth::UserAuthorizer.new(
          auth_client.client_id, SCOPE, token_store)
=end
    @@auth_client.update!(
        :scope => 'https://www.googleapis.com/auth/gmail.readonly https://www.googleapis.com/auth/plus.login',
        :redirect_uri => 'http://localhost:3000/goToApp')
    if request['code'] == nil
      auth_uri = @@auth_client.authorization_uri.to_s
      redirect_to(auth_uri.gsub('/oauth2callback', '/goToApp'))
      #userMail = Google::Apis::GmailV1::GmailService.new
      # userMail.authorization = authorizer
      #puts userMail.get_user_profile('me')
    else
      redirect_to('/goToApp')
    end
=begin
    client_secrets = Google::APIClient::ClientSecrets.load(CLIENT_SECRETS_PATH)
    auth_client = client_secrets.to_authorization
    auth_client.update!(
        :scope => 'https://www.googleapis.com/auth/gmail.readonly',
        :redirect_uri => 'http://localhost:3000/application/advancedOptions')
=end #return url.gsub('/oauth2callback','')
  end

  def sendZip
    send_file(File.join("#{Rails.root}/AllZips/", "#{params['zip']}.zip"), :type => 'application/zip', :filename => "#{params['zip']}.zip")
  end
  def home()
    render :template => 'home.html.erb'
    #redirect_to('/home')

=begin
    uri    = URI.parse(request.url)
    params = CGI.parse(uri.query)
    puts request.url
=end
    # params is now {"id"=>["4"], "empid"=>["6"]}

    #id     = params['id'].first
=begin
    puts params
    @@params = params
    @@projectId = params['PROJECT_ID'][0]
    puts @@projectId
    @@suitId = params['SUIT_ID'][0]
    puts @@suitId
    @@sectionId = params['SECTION_ID'][0]
    puts @@sectionId
    @@caseId = params['CASE_ID'][0]
    puts @@caseId
    @@runId = params['RUN_ID'][0]
    puts @@runId
    @@browsers = params['BROWSERS'][0]
    puts @@browsers
    ENV['RUN_ID']= @@runId
=end
    #authorize
=begin
    client_secrets = Google::APIClient::ClientSecrets.load(CLIENT_SECRETS_PATH)
    auth_client = client_secrets.to_authorization
    auth_client.update!(
        :scope => 'https://www.googleapis.com/auth/gmail.readonly',
        :redirect_uri => 'http://localhost:3000',
        :additional_parameters => {        # offline access
            "include_granted_scopes" => "true"  # incremental auth
        }
    )
    puts auth_client
    auth_uri = auth_client.authorization_uri.to_s
    if request['code'] == nil
      puts "me #{auth_client} me too #{auth_uri}"
      #@auth_uri = auth_client.authorization_uri.to_s
      redirect_to auth_uri
    else
      auth_client.code = request['code']
      auth_client.fetch_access_token!
      auth_client.client_secret = nil
      session[:credentials] = auth_client.to_json
      redirect to('/')
    end
#render json: { status: 200, output:params}
=end
    #redirect_to 'https://test.salesforce.com/services/oauth2/authorize?response_type=code&client_id=3MVG9PE4xB9wtoY9IbhNtYSuAVOegE_yR6h8s4fwIITYduuN1V8Tt84iUykgOM_X3lj7md_cCbNBlsN6D6LSc&redirect_uri=http://localhost:3000'


  end

=begin
  def readFile()
    puts "in getDataController#readFile"
    data = open("#{Rails.root}/log/development.log")
    puts data
    render  json: { status: 200, output:data}
  end
=end
  def goToApp()

    #Check for alredy autherized or not
    if request['code'] == nil
      auth_uri = @@auth_client.authorization_uri.to_s
      redirect_to(auth_uri.gsub('/oauth2callback', '/goToApp'))
      #userMail = Google::Apis::GmailV1::GmailService.new
      # userMail.authorization = authorizer
      #puts userMail.get_user_profile('me')
    else
      @@auth_client.code = request['code']
      #After connection request for token with code(Access token not refresh token)
      @@auth_client.fetch_access_token!
      @@auth_client.client_secret = nil
      session[:user] = @@auth_client.to_json
    end
    client_opts = JSON.parse(session[:user])
    @@auth_client = Signet::OAuth2::Client.new(client_opts)

    #Service of google we are going to consume after connection and it should specified within scope
    userMail = Google::Apis::GmailV1::GmailService.new
    userProfile = Google::Apis::PlusV1::PlusService.new
    userProfile.authorization = @@auth_client
    session[:userProfile] = userProfile.get_person('me').to_h
    userMail.authorization = @@auth_client
    response = userMail.get_user_profile('me')
    #Get query result(list of rows)
    #@@res =  @@con.exec('SELECT "Auth"."Email" AS Email from "QAAuto"."Auth"')
    #Process returned result
    session[:email_address] = response.to_h[:email_address]
    if !User.where(email: session[:email_address]).nil?
      session[:user] = User.where(:email => response.to_h[:email_address])
      redirect_to '/app'
    else
      user = User.new();
      user.email = response.to_h[:email_address]
      UserMailer.with(user: user).welcome_email.deliver_now
      render :template => 'permission.html.erb'
    end
  end

  def getParams()
    unless session.has_key?(:user)
      redirec_ to('/autherize')
    end
    render json: {status: 200, output: @@params}
  end

  def generateSpec
    project = params['Project'].split('-')
    suit = params['Suit'].split('-')
    fileUtils = FileUtils
    currentDirectory = fileUtils.pwd()
    fileUtils.cd currentDirectory
    # puts fileUtils.pwd
=begin
    Dir.chdir params['specPath']
    fileUtils.cd File.expand_path(params['specPath'])
    fileUtils.cd Pathname.new(params['specPath']).realpath
=end
    if !File.directory? project[0]
      fileUtils.mkdir [project[0]], :mode => 0700
    end
    fileUtils.cd project[0]
    if !File.directory? 'Modules'
      fileUtils.mkdir ['Modules'], :mode => 0700
    end
    fileUtils.cd 'Modules'
    if !File.directory? suit[0]
      fileUtils.mkdir [suit[0]], :mode => 0700
    end
    fileUtils.cd suit[0]
    if !File.directory? "Page Objects"
      fileUtils.mkdir ["Page Objects"], :mode => 0700
    end
    if !File.directory? "Test Data"
      fileUtils.mkdir ["Test Data"], :mode => 0700
    end
    if !File.directory? "Specs"
      fileUtils.mkdir ["Specs"], :mode => 0700
    end
    fileUtils.cd "Specs"
    params['Section'].each do |section|
      if !File.exist? "#{section['name']}_spec.rb"
        file = File.new("#{section['name']}_spec.rb", 'a+')
        file.write("require 'json'
require 'selenium-webdriver'
require 'rspec'
require_relative File.expand_path('..',Dir.pwd )+'/specHelper.rb'
include RSpec::Expectations
describe 'Project' do
  before(:all) do
    @helper = Helper.new
    @driver = ARGV[0]
    @testDataJSON = @helper.getRecordJSON()
    @accept_next_alert = true
    @wait = @helper.instance_variable_get(:@wait)
    @verification_errors = []
  end
  after(:each) do
    @verification_errors.should == []
  end\n")
        credetialObj = Credential.where(:username => params['TestRailServer']).take
        testRailUtility = EnziTestRailUtility::TestRailUtility.new(credetialObj.username, credetialObj.password)
        testRailUtility.getCases(project[project.length - 1], section['suite_id'], section['id']).each do |caseid|
          file.write("\tit '#{caseid['title']}', :'#{caseid['id']}'=> 'true' do
  begin
    #
    #Add steps for test case execution
    #
    @helper.addLogs('Success')
    @helper.postSuccessResult(#{caseid['id']})
  rescue Exception => e
    @helper.addLogs('Error')
    @helper.postFailResult(e,#{caseid['id']})
    raise e
  end
\tend\n")
        end
        file.write("end")
      else

      end
    end
    fileUtils.cd currentDirectory
    fileUtils.remove_dir("#{Dir.pwd}/AllZips", force = true)
    fileUtils.mkdir ["AllZips"], :mode => 0700
    zf = ZipGenerator.new("#{project[0]}", "AllZips/#{project[0]}-#{Time.now.to_date}.zip")
    zf.write()
    render json: {status: 200, output: "#{project[0]}-#{Time.now.to_date}.zip"}
  end
=begin
  def runSpec()
    unless session.has_key?(:user)
      redirect_to('/autherize')
    end
    uri    = URI.parse(request.url)
    params = CGI.parse(uri.query)

    puts params
    puts @@projectId
    puts @@suitId
    puts @@sectionId
    puts @@caseId
    puts @@browsers
    puts @@runId
    pid = spawn("ruby specManager.rb project:#{@@projectId} suit:#{@@suitId} section:#{@@sectionId} case:#{@@caseId} browser:#{@@browsers}")
    #puts "#{pid}"
    Process.detach(pid)

    render json: { status: 200, output:params}

  end
=end
  def connectToTestRail
    credetialObj = Credential.where(username: "#{params[:username]}.com", entity: 'testrail').take
    @@testRailUtility = EnziTestRailUtility::TestRailUtility.new(credetialObj.username, credetialObj.password)
    puts @@testRailUtility
    render json: {status: 200, output: 'Connected'}
  end

  def getFromTestRail()
    unless session.has_key?(:user)
      redirect_to('/autherize')
    end
=begin
    input = params[:dataToGet].gsub('"', '').split('&')
    tempIdHolder = []
    if input[1].eql?('Suit') then
      @@testRailUtility.getSuites(input[0]).uniq.each do |suite|
        @@testRailUtility.getSections(suite['id'] , suite['project_id']).uniq.each do |section|
          caseInfo = @@testRailUtility.getCases(input[0],suite['id'],section["id"])[0]
          if !caseInfo.nil? && caseInfo.key?('custom_spec_location') && !caseInfo.fetch('custom_spec_location').nil?
            tempIdHolder.push(suite)
            break;
          end
=end
          input = params[:dataToGet].gsub('"', '').split('&')
          if input[1].eql?('Suit') then
            output = @@testRailUtility.getSuites(input[0])
          else
            if input[1].eql?('Section')
              output = @@testRailUtility.getSections(input[0], input[2]);
            else
              output = @@testRailUtility.getProjects();
            end
          end
          render json: {status: 200, output: output}
  end
=begin
        end
      end
    else
      if input[1].eql?('Section')
        tempIdHolder = []
        @@testRailUtility.getSections(input[0], input[2]).uniq.each do |section|
          @@testRailUtility.getCases(input[2],input[0],section["id"]).uniq.each do |caseInfo|
            if caseInfo.key?('custom_spec_location') && !caseInfo.fetch('custom_spec_location').nil?
              tempIdHolder.push(section)
              break;
            end
          end
        end
      else
        tempIdHolder = []
        tempIdHolder = @@testRailUtility.getProjects()
      end
    end
    puts tempIdHolder
    render json: {status: 200, output: tempIdHolder}
=end
  #end
=begin
  def getSalesforceInstances()
    unless session.has_key?(:user)
      redirect_to('/autherize')
    end
    @@res =  @@con.exec('SELECT "Credentials"."hostName" FROM "QAAuto"."Credentials" WHERE "Credentials"."type" = '+"'salesforce'")
    puts @@res.column_values(0)
    render json: { status: 200, output:@@res.column_values(0)}
  end
=end
=begin
  def getProfiles
    unless session.has_key?(:user)
      redirect_to('/autherize')
    end
    puts params[:instance]
    @@res =  @@con.exec('SELECT "Credentials"."username" , "Credentials"."password" FROM "QAAuto"."Credentials" WHERE "Credentials"."type" = '+"'salesforce' "+'AND "Credentials"."hostName" = '+"'#{params[:instance]}'")

    sfBulk = Salesforce.login(@@res.column_values(0)[0],@@res.column_values(1)[0],true)
    profiles = Salesforce.getRecords(sfBulk,"Profile", "SELECT id,name FROM Profile WHERE id IN (SELECT profileid FROM User WHERE IsActive = true) and UserLicense.name = 'Salesforce'")
    arrProfiles = []
    profiles.result.records.each do |profile|
      arrProfiles.push(profile.to_hash())
    end
    render json: { status: 200, output: arrProfiles}
  end

  def getUsers
    unless session.has_key?(:user)
      redirect_to('/autherize')
    end
  	render json: { status: 200, output:Users}
  end
=end
=begin
  def insertData
    unless session.has_key?(:credentials)
      redirect_to('/autherize')
    end
    json = ActiveSupport::JSON
    parsedData = json.decode(params[:dataToInsert])
    template = Template.new(parsedData)
      respond_to do |format|
        if template.save
          format.html { redirect_to template, notice: 'Template was successfully created.' }
          format.json { render :show, status: :created, location: template }
        else
          format.html { render :new }
          format.json { render json: template.errors, status: :unprocessable_entity }
        end
      end
=begin

    @@res = @@con.exec('SELECT column_name FROM information_schema.columns WHERE table_name = '+"'#{parsedData['Table']}'")
    if @@res.column_values(0).length > 0 then
      insertQuery = '';
      @@res.column_values(0).each do |key|

        if(parsedData[key] != nil)
          insertQuery += "array["
          insertQuery += parsedData[key].join(",").to_s.gsub('{',"'").gsub('}',"'")
          insertQuery += "] ,"
        end

      end
      insertQuery = insertQuery.chomp(',')
      response = ''
      jobName = ''
      if parsedData['Table'].eql? 'User' then
        jobName = rand(9999)
        response = createJob("#{parsedData['Name'][0]['name']}-#{jobName}" , parsedData)
      end
      if !(response.nil?)
        @@res =  @@con.exec('INSERT INTO "QAAuto".'+'"'+"#{parsedData['Table']}"+'"'+' VALUES ('+"#{insertQuery} , '#{parsedData['Name'][0]['name']}-#{jobName}') ON CONFLICT ("+'"'+"Suit"+'"'+") DO UPDATE SET "+'"Suit" = '+'"'+"#{parsedData['Table']}"+'"'+'."Suit"')
      end
      params[:options] = parsedData['Table']
      getResult();
    end
 end
=end
=begin
  def getResult()
    options = params[:options].split('&')

    if options[0].eql?('Templates')
      @@res =  @@con.exec('SELECT * FROM "QAAuto"."Templates"')
      allTemplates = []
      @@res.each do |row|
        row.keys.each do |key|
          if !(key.eql? 'Job')
            row[key] = eval(row[key].gsub('/','').gsub('\\','').gsub('""','"'))
          else
            row[key] = {"name" => row[key]}
          end
        end
        allTemplates.push(row)
      end
      render json: { status: 200, output:allTemplates}
    end
    if options[0].eql?('Credentials')
      @@res =  @@con.exec('SELECT "Credentials"."hostName" FROM "QAAuto"."Credentials" WHERE "Credentials"."entity" = '+"'#{options[1]}'")
      render json: { status: 200, output:@@res}
    end

  end
=end
=begin
  def inserRow
    parsedInput = ActiveSupport::json_encoder(params[:options])
    @@res =  @@con.exec('INSERT INTO "QAAuto".'+'"'+"#{parsedInput['table']}"+'"'+' VALUES ('+"#{insertQuery}")

  end
  def insertSalesforceInstance
    json = ActiveSupport::JSON
    parsedData = json.decode(params[:dataToInsert])
    puts params[:dataToInsert]
    instance = parsedData['username'].split('.')
    @@res =  @@con.exec('SELECT "Credentials"."hostName" FROM "QAAuto"."Credentials" WHERE "Credentials"."hostName" = '+"'#{instance[instance.length-1]}'")
    if @@res.column_values(0).length == 0
      sfBulk = Salesforce.login(parsedData['username'],parsedData['password'],true)
      result = Salesforce.getRecords(sfBulk,'User',"SELECT 	Profile FROM User WHERE Username = #{parsedData['username']}")
      puts result.result.records.inspect
    end
  end
=end
=begin
  def deleteRow()
    options = params[:options].split('&')
    @@res =  @@con.exec('DELETE FROM "QAAuto"'+'."'+"#{options[0]}"+'"'+" WHERE "+'"'+"#{options[0]}"+'".'+'"'+"#{options[1]}"+'"'+" = '#{options[2]}'")
    puts @@res
    jenkinsClient = connectToJenkins('abc')
    jenkinsClient.deleteJob(options[2])
    getResult();
  end
=end
  def logout
    puts session[:user]
    reset_session
    puts session[:user]
    render :template => 'home.html.erb'
  end
end
