require 'json'
require 'selenium-webdriver'
require 'rspec'
require 'date'
require 'enziUIUtility'
require 'csv'
require_relative File.expand_path('../../../../', Dir.pwd) + '/specHelper.rb'
require_relative File.expand_path('..',Dir.pwd) + '/Page Objects/kickbox_importer.rb'
include RSpec::Expectations
describe 'Project' do
  before(:all) do
    @helper = Helper.new
    #@driver = ARGV[0]
    @driver = Selenium::WebDriver.for :chrome
    @driver.get "https://test.salesforce.com/login.jsp?pw=Wework@16&un=veena.hegane@wework.com.staging"
    @testDataJSON = @helper.getRecordJSON()
    @userInfo = @helper.instance_variable_get(:@restForce).getUserInfo
    @accept_next_alert = true
    @wait = @helper.instance_variable_get(:@wait)
    @verification_errors = []
    @isSourceHasPermission = nil
    @overrideLeadSource = nil
    @userHasPermission = nil
    @pageObject = Kickbox_Importer.new(@driver,@helper)
    EnziUIUtility.switchToClassic(@driver)
    @helper.go_to_app(@driver,"Sales Console")
    if @helper.alert_present? @driver
      @helper.close_alert_and_get_its_text(@driver,"id","RPPWarning")
    end
    @building = @helper.instance_variable_get(:@restForce).getRecords("SELECT id FROM Building__c WHERE Name = '#{@testDataJSON['Lead'][0]["Building_Interested_In__c"]}'")[0].fetch("Id")
  end
  before(:each) do
    @pageObject.open_tab("KickBox Verification","journey_importer")
  end
  after(:all) do
    @verification_errors.should == []
    @helper.deleteSalesforceRecordBySfbulk("Journey__c", EnziRestforce.class_variable_get(:@@createdRecordsIds)["Journey__c"])
    @helper.deleteSalesforceRecordBySfbulk("Lead", EnziRestforce.class_variable_get(:@@createdRecordsIds)["Lead"])
  end
  context "Kickbox Importer While Insertion of Existing Lead Which is Owned By Susie Romero from Kickbox and assign to the Particular Campaign Based on Lead Owner Criterias",'317'=>'true' do
    before(:all) do
      @testDataJSON['Campaign'][0]['Lead Owner'] = '0051g000000tSCu'
      @testDataJSON['Campaign'][0]['Email Address'] = ''
      @testDataJSON['Campaign'][0]['City'] = ''
      @campaignId = @helper.instance_variable_get(:@restForce).getRecords("SELECT id FROM Campaign WHERE Name = '#{@testDataJSON['Campaign'][0]['Name']}'")[0]
      @helper.update_campaign(@campaignId.fetch('Id'), @testDataJSON['Campaign'][0]['Lead Owner'])
    end
    it 'To Check Journey is Created While Importing Existing Lead  Which is Owned By Susie Romero Where Activity is Not present on Existing Lead, when the Generate Journey on UI is Checked and Generate Journey in CSV is Blank and assign to the Campaign.', :'2608' => 'true' do
      begin
        @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Generate_Journey__c'] = true
        leadInfo = nil
        @helper.getExistingLead(nil,nil,"Susie Romero",true).each do |lead|
          if lead['Tasks'].nil?
            leadInfo = lead
            break;
          end
        end
        leadInfo.nil? ? email = "John.Smith_QAAuto#{rand(9999999999999999)}@example.com" : email = leadInfo.fetch('Email')
        if leadInfo.nil?
          @testDataJSON['Lead'][0]['Email'] = email
          @testDataJSON['Lead'][0]['Generate_Journey__c'] = false
          leadInfo = {"lastName"=>@testDataJSON['Lead'][0]['FirstName'],"firstName"=>@testDataJSON['Lead'][0]['LastName'],"website"=>"http://www.Testgmail.com","email"=>email,"phone"=>"8146185355","company"=>@testDataJSON['Lead'][0]['Company'],"company_Size__c"=>@testDataJSON['Lead'][0]['Number_of_Full_Time_Employees__c'],"lead_Source_Detail__c"=>@testDataJSON['Lead'][0]['lead_Source_Detail__c'],"utm_campaign__c"=>"San Francisco - Modifier","utm_content__c"=>"utm contents","utm_medium__c"=>"cpc","utm_source__c"=>"ads-google","utm_term__c"=>"virtual +office +san +francisco","locale__c"=>@testDataJSON['Lead'][0]['Locale__c'],"country_Code__c"=>@testDataJSON['Lead'][0]['Country_Code__c'] ,"number_of_Desks__c"=>@testDataJSON['Lead'][0]['Interested_in_Number_of_Desks__c'],"leadSource"=>@testDataJSON['Lead'][0]['LeadSource'],"Generate_Journey__c"=>false,"OwnerId"=>"005F0000003Kmbw"}
          leadInfo['Id'] = @helper.instance_variable_get(:@restForce).createRecord("Lead",leadInfo)
          Helper.addRecordsToDelete("Lead",leadInfo['Id'])
        end
        @pageObject.upload_csv(email, "", @testDataJSON['Campaign'][0]['Name'],false,false,"Lead")[0]
        expect(leadInfo).to_not eql nil
        @helper.addLogs("[Validate ] : Checking Lead owner should be lead owner on campaign")
        @helper.addLogs("[Expected ] : Owner of lead should be according to campaign assignment")
        @pageObject.checkJobStatus
        leadInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Owner.Name, Generate_Journey__c,Owner.id,LeadSource , Lead_Source_Detail__c , Building_Interested_In__c , Building_Interested_Name__c ,Journey_Created_On__c, Locations_Interested__c , Number_of_Full_Time_Employees__c , Interested_in_Number_of_Desks__c , Email , Phone , Company , Name , RecordType.Name , Status , Type__c FROM Lead WHERE id = '#{leadInfo.fetch("Id")}'")[0]
        @helper.addLogs("[Actual ]   : Owner of lead is #{leadInfo.fetch("Owner").fetch("Id")}")
        owner = @pageObject.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
        expect(leadInfo.fetch("Owner").fetch("Id")).to eql owner
        @helper.addLogs("[Result ]   : Owner checked successfully\n")
        @helper.addLogs("[Validate ] : Checking create Journey on lead")
        @helper.addLogs("[Expected ] : Create Journey should #{@testDataJSON['Lead'][0]['Generate_Journey__c']}")
        @helper.addLogs("[Actual ]   : Create Journey on lead is #{leadInfo.fetch("Generate_Journey__c").inspect}")
        expect(leadInfo.fetch("Generate_Journey__c")).to eql false
        insertedJourneyInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,CampaignId__c,Owner.id, Owner.Name,CreatedDate ,Status__c , NMD_Next_Contact_Date__c ,Primary_Email__c , Lead_Source__c , Lead_Source_Detail__c , Primary_Phone__c , Company_Name__c , Building_Interested_In__c , Locations_Interested__c , Interested_in_Number_of_Desks__c , Full_Time_Employees__c, Name   FROM Journey__c WHERE Primary_Email__c = '#{leadInfo.fetch("Email")}'")[0]
        Helper.addRecordsToDelete("Journey__c", insertedJourneyInfo.fetch('Id'))
        @helper.addLogs("[Validate ] : Checking Journey is created on lead")
        @helper.addLogs("[Expected ] : Journey should be created")
        @helper.addLogs("[Actual ]   : Journey is created with name #{insertedJourneyInfo.fetch("Name")}")
        expect(insertedJourneyInfo).to_not eql nil
        Helper.addRecordsToDelete("Journey__c", insertedJourneyInfo.fetch('Id'))
        @helper.addLogs("[Result ]   : Journey created successfully\n")
        @helper.addLogs("[Validate ] : Checking Journey owner should be lead owner")
        @helper.addLogs("[Expected ] : Owner of Journey should be owner of lead")
        @helper.addLogs("[Actual ]   : Owner of Journey is #{insertedJourneyInfo.fetch("Owner").fetch("Id")}")
        expect(insertedJourneyInfo.fetch("Owner").fetch("Id")).to match owner
        @helper.addLogs("[Result ]   : Owner checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Campaign on journey")
        @helper.addLogs("[Expected ] : Campaign on Journey should be campaign selected while importing lead")
        @helper.addLogs("[Actual ]   : Campaign on Journey is #{insertedJourneyInfo.fetch("CampaignId__c")}")
        expect(insertedJourneyInfo.fetch("CampaignId__c")).to eql @campaignId.fetch('Id')
        @helper.addLogs("[Result ]   : Campaign checked successfully\n")
        @pageObject.instance_variable_get(:@testDataJSON)['Journey'][0]
        generatedActivityForLead = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Subject , CreatedDate,Status ,Lead_Source__c , Lead_Source_Detail__c,Owner.Name,Locations_Interested__c, Number_of_Full_Time_Employees__c,Interested_in_Number_of_Desks__c,Company__c,WhoId FROM Task WHERE WhoId = '#{leadInfo.fetch('Id')}'")[0]
        @helper.addLogs("[Validate ] : Checking Subject on acitivity")
        @helper.addLogs("[Expected ] : Subject on activity should be inboound lead submission")
        @helper.addLogs("[Actual ]   : Subject on activity  is #{generatedActivityForLead.fetch("Subject")}")
        expect(generatedActivityForLead.fetch("Subject")).to eql "Inbound Lead submission"
        @helper.addLogs("[Result ]   : Activity subject checked successfully")
        @helper.addLogs("[Validate ] : Checking lead source on activity")
        @helper.addLogs("[Expected ] : Lead source on activity should be lead source of created lead")
        @helper.addLogs("[Actual ]   : Lead source on activity is #{generatedActivityForLead.fetch("Lead_Source__c")}")
        expect(generatedActivityForLead.fetch("Lead_Source__c")).to eql "Inbound Call"
        @helper.addLogs("[Result ]   : Activity lead source checked successfully")
        @helper.addLogs("[Validate ] : Checking lead source detail on activity")
        @helper.addLogs("[Expected ] : Lead source detail on activity should be lead source of created lead")
        @helper.addLogs("[Actual ]   : Lead source detail on activity is #{generatedActivityForLead.fetch("Lead_Source__c")}")
        expect(generatedActivityForLead.fetch("Lead_Source_Detail__c")).to eql "Inbound Call Page"
        @helper.addLogs("[Result ]   : Activity lead source detail checked successfully")
        @helper.addLogs("[Validate ] : Checking status on activity")
        @helper.addLogs("[Expected ] : Status on activity should be Open")
        @helper.addLogs("[Actual ]   : Status on activity is #{generatedActivityForLead.fetch("Status")}")
        expect(generatedActivityForLead.fetch("Status")).to eql "Open"
        @helper.addLogs("[Result ]   : Activity assigned to field checked successfully")
        @helper.addLogs("[Validate ] : Checking Company on activity")
        @helper.addLogs("[Expected ] : Company on activity should be #{leadInfo.fetch('Company')}")
        @helper.addLogs("[Actual ]   : Status on activity is #{generatedActivityForLead.fetch("Company__c")}")
        expect(generatedActivityForLead.fetch("Company__c")).to eql leadInfo.fetch('Company')
        @helper.addLogs("[Result ]   : Activity Status field checked successfully")
        @helper.addLogs("[Validate ] : Checking Location interested on activity")
        @helper.addLogs("[Expected ] : Location interested on activity should be #{@testDataJSON['Lead'][0]['Locations_Interested__c']}")
        @helper.addLogs("[Actual ]   : Location interested on activity is #{generatedActivityForLead.fetch("Locations_Interested__c")}")
        expect(generatedActivityForLead.fetch("Locations_Interested__c")).to eql @testDataJSON['Lead'][0]['Locations_Interested__c']
        @helper.addLogs("[Result ]   : Activity Location interested field checked successfully")
        @helper.addLogs('Success')
        @helper.postSuccessResult(2575)
      rescue Exception => e
        @helper.addLogs('Error')
        @helper.postFailResult(e, 2575)
        raise e
      end
    end
    it 'To Check Journey is Created While Importing Existing Lead Which is Owned By Susie Romero Where Activity is Not present on Existing Lead, when the Generate Journey on UI is UnChecked and Generate Journey in CSV is True and assign to the Campaign.', :'2618' => 'true' do
      begin
        @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Generate_Journey__c'] = true
        leadInfo = nil
        @helper.getExistingLead(nil,nil,"Susie Romero",true).each do |lead|
          if lead['Tasks'].nil?
            leadInfo = lead
            break;
          end
        end
        leadInfo.nil? ? email = "John.Smith_QAAuto#{rand(9999999999999999)}@example.com" : email = leadInfo.fetch('Email')
        if leadInfo.nil?
          @testDataJSON['Lead'][0]['Email'] = email
          leadInfo = {"lastName"=>@testDataJSON['Lead'][0]['FirstName'],"firstName"=>@testDataJSON['Lead'][0]['LastName'],"website"=>"http://www.Testgmail.com","email"=>email,"phone"=>"8146185355","company"=>@testDataJSON['Lead'][0]['Company'],"company_Size__c"=>@testDataJSON['Lead'][0]['Number_of_Full_Time_Employees__c'],"lead_Source_Detail__c"=>@testDataJSON['Lead'][0]['lead_Source_Detail__c'],"utm_campaign__c"=>"San Francisco - Modifier","utm_content__c"=>"utm contents","utm_medium__c"=>"cpc","utm_source__c"=>"ads-google","utm_term__c"=>"virtual +office +san +francisco","locale__c"=>@testDataJSON['Lead'][0]['Locale__c'],"country_Code__c"=>@testDataJSON['Lead'][0]['Country_Code__c'] ,"number_of_Desks__c"=>@testDataJSON['Lead'][0]['Interested_in_Number_of_Desks__c'],"leadSource"=>@testDataJSON['Lead'][0]['LeadSource'],"Generate_Journey__c"=>false,"OwnerId"=>"005F0000003Kmbw"}
          leadInfo['Id'] = @helper.instance_variable_get(:@restForce).createRecord("Lead",leadInfo)
          Helper.addRecordsToDelete("Lead",leadInfo['Id'])
        end
        @pageObject.upload_csv(email, "TRUE", @testDataJSON['Campaign'][0]['Name'],true,false,"Lead")[0]
        expect(leadInfo).to_not eql nil
        @helper.addLogs("[Validate ] : Checking Lead owner should be lead owner on campaign")
        @helper.addLogs("[Expected ] : Owner of lead should be Logged in user")
        @pageObject.checkJobStatus
        leadInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Owner.Name, Generate_Journey__c,Owner.id,LeadSource , Lead_Source_Detail__c , Building_Interested_In__c , Building_Interested_Name__c ,Journey_Created_On__c, Locations_Interested__c , Number_of_Full_Time_Employees__c , Interested_in_Number_of_Desks__c , Email , Phone , Company , Name , RecordType.Name , Status , Type__c FROM Lead WHERE id = '#{leadInfo.fetch("Id")}'")[0]
        @helper.addLogs("[Actual ]   : Owner of lead is #{leadInfo.fetch("Owner").fetch("Id")}")
        owner = @pageObject.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
        expect(leadInfo.fetch("Owner").fetch("Id")).to eql owner
        @helper.addLogs("[Result ]   : Owner checked successfully\n")
        @helper.addLogs("[Validate ] : Checking create Journey on lead")
        @helper.addLogs("[Expected ] : Create Journey should #{@testDataJSON['Lead'][0]['Generate_Journey__c']}")
        @helper.addLogs("[Actual ]   : Create Journey on lead is #{leadInfo.fetch("Generate_Journey__c").inspect}")
        expect(leadInfo.fetch("Generate_Journey__c")).to eql false
        insertedJourneyInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,CampaignId__c,Owner.id, Owner.Name,CreatedDate ,Status__c , NMD_Next_Contact_Date__c ,Primary_Email__c , Lead_Source__c , Lead_Source_Detail__c , Primary_Phone__c , Company_Name__c , Building_Interested_In__c , Locations_Interested__c , Interested_in_Number_of_Desks__c , Full_Time_Employees__c, Name   FROM Journey__c WHERE Primary_Email__c = '#{leadInfo.fetch("Email")}'")[0]
        Helper.addRecordsToDelete("Journey__c", insertedJourneyInfo.fetch('Id'))
        @helper.addLogs("[Validate ] : Checking Journey is created on lead")
        @helper.addLogs("[Expected ] : Journey should be created")
        @helper.addLogs("[Actual ]   : Journey is created with name #{insertedJourneyInfo.fetch("Name")}")
        expect(insertedJourneyInfo).to_not eql nil
        Helper.addRecordsToDelete("Journey__c", insertedJourneyInfo.fetch('Id'))
        @helper.addLogs("[Result ]   : Journey created successfully\n")
        @helper.addLogs("[Validate ] : Checking Journey owner should be lead owner")
        @helper.addLogs("[Expected ] : Owner of Journey should be owner of lead")
        @helper.addLogs("[Actual ]   : Owner of Journey is #{insertedJourneyInfo.fetch("Owner").fetch("Id")}")
        expect(insertedJourneyInfo.fetch("Owner").fetch("Id")).to match owner
        @helper.addLogs("[Result ]   : Owner checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Campaign on journey")
        @helper.addLogs("[Expected ] : Campaign on Journey should be campaign selected while importing lead")
        @helper.addLogs("[Actual ]   : Campaign on Journey is #{insertedJourneyInfo.fetch("CampaignId__c")}")
        expect(insertedJourneyInfo.fetch("CampaignId__c")).to eql @campaignId.fetch('Id')
        @helper.addLogs("[Result ]   : Campaign checked successfully\n")
        @pageObject.instance_variable_get(:@testDataJSON)['Journey'][0]
        generatedActivityForLead = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Subject , CreatedDate,Status ,Lead_Source__c , Lead_Source_Detail__c,Owner.Name,Locations_Interested__c, Number_of_Full_Time_Employees__c,Interested_in_Number_of_Desks__c,Company__c,WhoId FROM Task WHERE WhoId = '#{leadInfo.fetch('Id')}'")[0]
        @helper.addLogs("[Validate ] : Checking Subject on acitivity")
        @helper.addLogs("[Expected ] : Subject on activity should be inboound lead submission")
        @helper.addLogs("[Actual ]   : Subject on activity  is #{generatedActivityForLead.fetch("Subject")}")
        expect(generatedActivityForLead.fetch("Subject")).to eql "Inbound Lead submission"
        @helper.addLogs("[Result ]   : Activity subject checked successfully")
        @helper.addLogs("[Validate ] : Checking lead source on activity")
        @helper.addLogs("[Expected ] : Lead source on activity should be lead source of created lead")
        @helper.addLogs("[Actual ]   : Lead source on activity is #{generatedActivityForLead.fetch("Lead_Source__c")}")
        expect(generatedActivityForLead.fetch("Lead_Source__c")).to eql "Inbound Call"
        @helper.addLogs("[Result ]   : Activity lead source checked successfully")
        @helper.addLogs("[Validate ] : Checking lead source detail on activity")
        @helper.addLogs("[Expected ] : Lead source detail on activity should be lead source of created lead")
        @helper.addLogs("[Actual ]   : Lead source detail on activity is #{generatedActivityForLead.fetch("Lead_Source__c")}")
        expect(generatedActivityForLead.fetch("Lead_Source_Detail__c")).to eql "Inbound Call Page"
        @helper.addLogs("[Result ]   : Activity lead source detail checked successfully")
        @helper.addLogs("[Validate ] : Checking status on activity")
        @helper.addLogs("[Expected ] : Status on activity should be Open")
        @helper.addLogs("[Actual ]   : Status on activity is #{generatedActivityForLead.fetch("Status")}")
        expect(generatedActivityForLead.fetch("Status")).to eql "Open"
        @helper.addLogs("[Result ]   : Activity assigned to field checked successfully")
        @helper.addLogs("[Validate ] : Checking Company on activity")
        @helper.addLogs("[Expected ] : Company on activity should be #{leadInfo.fetch('Company')}")
        @helper.addLogs("[Actual ]   : Status on activity is #{generatedActivityForLead.fetch("Company__c")}")
        expect(generatedActivityForLead.fetch("Company__c")).to eql leadInfo.fetch('Company')
        @helper.addLogs("[Result ]   : Activity Status field checked successfully")
        @helper.addLogs('Success')
        @helper.postSuccessResult(2578)
      rescue Exception => e
        @helper.addLogs('Error')
        @helper.postFailResult(e, 2578)
        raise e
      end
    end
    it 'To Check Journey is Created While Importing Existing Lead Which is Owned By Susie Romero Where Activity is present on Existing Lead, when the Generate Journey on UI is Checked and Generate Journey in CSV is Blank and assign to the Campaign.', :'2634' => 'true' do
      begin
        @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Generate_Journey__c'] = true
        leadInfo = nil
        @helper.getExistingLead(nil,nil,"Susie Romero",true).each do |lead|
          if !lead['Tasks'].nil?
            leadInfo = lead
            break;
          end
        end
        leadInfo.nil? ? email = "John.Smith_QAAuto#{rand(9999999999999999)}@example.com" : email = leadInfo.fetch('Email')
        if leadInfo.nil?
          @testDataJSON['Lead'][0]['Email'] = email
          leadInfo = {"lastName"=>@testDataJSON['Lead'][0]['FirstName'],"firstName"=>@testDataJSON['Lead'][0]['LastName'],"website"=>"http://www.Testgmail.com","email"=>email,"phone"=>"8146185355","company"=>@testDataJSON['Lead'][0]['Company'],"company_Size__c"=>@testDataJSON['Lead'][0]['Number_of_Full_Time_Employees__c'],"lead_Source_Detail__c"=>@testDataJSON['Lead'][0]['lead_Source_Detail__c'],"utm_campaign__c"=>"San Francisco - Modifier","utm_content__c"=>"utm contents","utm_medium__c"=>"cpc","utm_source__c"=>"ads-google","utm_term__c"=>"virtual +office +san +francisco","locale__c"=>@testDataJSON['Lead'][0]['Locale__c'],"country_Code__c"=>@testDataJSON['Lead'][0]['Country_Code__c'] ,"number_of_Desks__c"=>@testDataJSON['Lead'][0]['Interested_in_Number_of_Desks__c'],"leadSource"=>@testDataJSON['Lead'][0]['LeadSource'],"Generate_Journey__c"=>false,"OwnerId"=>"005F0000003Kmbw"}
          leadInfo['Id'] = @helper.instance_variable_get(:@restForce).createRecord("Lead",leadInfo)
          Helper.addRecordsToDelete("Lead",leadInfo['Id'])
        end
        @pageObject.upload_csv(email, "TRUE", @testDataJSON['Campaign'][0]['Name'],true,false,"Lead")[0]
        expect(leadInfo).to_not eql nil
        @helper.addLogs("[Validate ] : Checking Lead owner should be lead owner on campaign")
        @helper.addLogs("[Expected ] : Owner of lead should be Logged in user")
        @pageObject.checkJobStatus
        leadInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Owner.Name, Generate_Journey__c,Owner.id,LeadSource , Lead_Source_Detail__c , Building_Interested_In__c , Building_Interested_Name__c ,Journey_Created_On__c, Locations_Interested__c , Number_of_Full_Time_Employees__c , Interested_in_Number_of_Desks__c , Email , Phone , Company , Name , RecordType.Name , Status , Type__c FROM Lead WHERE id = '#{leadInfo.fetch("Id")}'")[0]
        @helper.addLogs("[Actual ]   : Owner of lead is #{leadInfo.fetch("Owner").fetch("Id")}")
        owner = @pageObject.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
        expect(leadInfo.fetch("Owner").fetch("Id")).to eql owner
        @helper.addLogs("[Result ]   : Owner checked successfully\n")
        @helper.addLogs("[Validate ] : Checking create Journey on lead")
        @helper.addLogs("[Expected ] : Create Journey should #{@testDataJSON['Lead'][0]['Generate_Journey__c']}")
        @helper.addLogs("[Actual ]   : Create Journey on lead is #{leadInfo.fetch("Generate_Journey__c").inspect}")
        expect(leadInfo.fetch("Generate_Journey__c")).to eql false
        insertedJourneyInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,CampaignId__c,Owner.id, Owner.Name,CreatedDate ,Status__c , NMD_Next_Contact_Date__c ,Primary_Email__c , Lead_Source__c , Lead_Source_Detail__c , Primary_Phone__c , Company_Name__c , Building_Interested_In__c , Locations_Interested__c , Interested_in_Number_of_Desks__c , Full_Time_Employees__c, Name   FROM Journey__c WHERE Primary_Email__c = '#{leadInfo.fetch("Email")}'")[0]
        Helper.addRecordsToDelete("Journey__c", insertedJourneyInfo.fetch('Id'))
        @helper.addLogs("[Validate ] : Checking Journey is created on lead")
        @helper.addLogs("[Expected ] : Journey should be created")
        @helper.addLogs("[Actual ]   : Journey is created with name #{insertedJourneyInfo.fetch("Name")}")
        expect(insertedJourneyInfo).to_not eql nil
        Helper.addRecordsToDelete("Journey__c", insertedJourneyInfo.fetch('Id'))
        @helper.addLogs("[Result ]   : Journey created successfully\n")
        @helper.addLogs("[Validate ] : Checking Journey owner should be according to lead owner criteria")
        @helper.addLogs("[Expected ] : Owner of Journey should be owner of lead")
        @helper.addLogs("[Actual ]   : Owner of Journey is #{insertedJourneyInfo.fetch("Owner").fetch("Name")}")
        expect(insertedJourneyInfo.fetch("Owner").fetch("Id")).to match owner
        @helper.addLogs("[Result ]   : Owner checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Campaign on journey")
        @helper.addLogs("[Expected ] : Campaign on Journey should be campaign selected while importing lead")
        @helper.addLogs("[Actual ]   : Campaign on Journey is #{insertedJourneyInfo.fetch("CampaignId__c")}")
        expect(insertedJourneyInfo.fetch("CampaignId__c")).to eql @campaignId.fetch('Id')
        @helper.addLogs("[Result ]   : Campaign checked successfully\n")
        @pageObject.instance_variable_get(:@testDataJSON)['Journey'][0]
        generatedActivityForLead = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Subject , CreatedDate,Status ,Lead_Source__c , Lead_Source_Detail__c,Owner.Name,Locations_Interested__c, Number_of_Full_Time_Employees__c,Interested_in_Number_of_Desks__c,Company__c,WhoId FROM Task WHERE WhoId = '#{leadInfo.fetch('Id')}'")[0]
        @helper.addLogs("[Validate ] : Checking Subject on acitivity")
        @helper.addLogs("[Expected ] : Subject on activity should be inboound lead submission")
        @helper.addLogs("[Actual ]   : Subject on activity  is #{generatedActivityForLead.fetch("Subject")}")
        expect(generatedActivityForLead.fetch("Subject")).to eql "Inbound Lead submission"
        @helper.addLogs("[Result ]   : Activity subject checked successfully")
        @helper.addLogs("[Validate ] : Checking lead source on activity")
        @helper.addLogs("[Expected ] : Lead source on activity should be lead source of created lead")
        @helper.addLogs("[Actual ]   : Lead source on activity is #{generatedActivityForLead.fetch("Lead_Source__c")}")
        expect(generatedActivityForLead.fetch("Lead_Source__c")).to eql "Inbound Call"
        @helper.addLogs("[Result ]   : Activity lead source checked successfully")
        @helper.addLogs("[Validate ] : Checking lead source detail on activity")
        @helper.addLogs("[Expected ] : Lead source detail on activity should be lead source of created lead")
        @helper.addLogs("[Actual ]   : Lead source detail on activity is #{generatedActivityForLead.fetch("Lead_Source__c")}")
        expect(generatedActivityForLead.fetch("Lead_Source_Detail__c")).to eql "Inbound Call Page"
        @helper.addLogs("[Result ]   : Activity lead source detail checked successfully")
        @helper.addLogs("[Validate ] : Checking status on activity")
        @helper.addLogs("[Expected ] : Status on activity should be Open")
        @helper.addLogs("[Actual ]   : Status on activity is #{generatedActivityForLead.fetch("Status")}")
        expect(generatedActivityForLead.fetch("Status")).to eql "Open"
        @helper.addLogs("[Result ]   : Activity assigned to field checked successfully")
        @helper.addLogs("[Validate ] : Checking Company on activity")
        @helper.addLogs("[Expected ] : Company on activity should be #{@testDataJSON['Lead'][0]['Company']}")
        @helper.addLogs("[Actual ]   : Status on activity is #{generatedActivityForLead.fetch("Company__c")}")
        expect(generatedActivityForLead.fetch("Company__c")).to eql @testDataJSON['Lead'][0]['Company']
        @helper.addLogs("[Result ]   : Activity Status field checked successfully")
        @helper.addLogs('Success')
        @helper.postSuccessResult(2578)
      rescue Exception => e
        @helper.addLogs('Error')
        @helper.postFailResult(e, 2578)
        raise e
      end
    end
    it 'To Check Journey Created for Existing Lead Owned By Susie Romero Where Activity is not present and which is assigned to the particular Campaign, When the generate Journey on UI is Checked & Generate Journey in CSV is Blank & inserted into diff Campgn.', :'2644' => 'true' do
      begin
        @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Generate_Journey__c'] = false
        leadInfo = nil
        leadInfo = @helper.instance_variable_get(:@restForce).getRecords("select lead.email,lead.Id from campaignmember where campaignid != '7010G000001V6lGQAS' and lead.email like '%example.com' and lead.owner.name = 'Susie Romero'")[0]
        leadInfo['Id'] = leadInfo.fetch('Lead').fetch('Id') if !leadInfo.nil?
        leadInfo.nil? ? email = "John.Smith_QAAuto#{rand(9999999999999999)}@example.com" : email = leadInfo.fetch('Lead').fetch('Email')
        if leadInfo.nil?
          @testDataJSON['Lead'][0]['Email'] = email
          leadInfo = {"lastName"=>@testDataJSON['Lead'][0]['FirstName'],"firstName"=>@testDataJSON['Lead'][0]['LastName'],"website"=>"http://www.Testgmail.com","email"=>email,"phone"=>"8146185355","company"=>@testDataJSON['Lead'][0]['Company'],"company_Size__c"=>@testDataJSON['Lead'][0]['Number_of_Full_Time_Employees__c'],"lead_Source_Detail__c"=>@testDataJSON['Lead'][0]['lead_Source_Detail__c'],"utm_campaign__c"=>"San Francisco - Modifier","utm_content__c"=>"utm contents","utm_medium__c"=>"cpc","utm_source__c"=>"ads-google","utm_term__c"=>"virtual +office +san +francisco","locale__c"=>@testDataJSON['Lead'][0]['Locale__c'],"country_Code__c"=>@testDataJSON['Lead'][0]['Country_Code__c'] ,"number_of_Desks__c"=>@testDataJSON['Lead'][0]['Interested_in_Number_of_Desks__c'],"leadSource"=>@testDataJSON['Lead'][0]['LeadSource'],"Generate_Journey__c"=>false,"OwnerId"=>"005F0000003Kmbw"}
          leadInfo['Id'] = @helper.instance_variable_get(:@restForce).createRecord("Lead",leadInfo)
          @helper.instance_variable_get(:@restForce).createRecord("CampaignMember",{"lead"=>leadInfo.fetch("Id"),"campaignId"=>"7010G000000Ccln"})
          Helper.addRecordsToDelete("Lead",leadInfo['Id'])
        end
        @pageObject.upload_csv(email, "TRUE", @testDataJSON['Campaign'][0]['Name'],true,false,"Lead")[0]
        expect(leadInfo).to_not eql nil
        @helper.addLogs("[Validate ] : Checking Lead owner should be lead owner on campaign")
        @helper.addLogs("[Expected ] : Owner of lead should be Logged in user")
        @pageObject.checkJobStatus
        leadInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Owner.Name, Generate_Journey__c,Owner.id,LeadSource , Lead_Source_Detail__c , Building_Interested_In__c , Building_Interested_Name__c ,Journey_Created_On__c, Locations_Interested__c , Number_of_Full_Time_Employees__c , Interested_in_Number_of_Desks__c , Email , Phone , Company , Name , RecordType.Name , Status , Type__c FROM Lead WHERE id = '#{leadInfo.fetch("Id")}'")[0]
        @helper.addLogs("[Actual ]   : Owner of lead is #{leadInfo.fetch("Owner").fetch("Id")}")
        owner = @pageObject.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
        expect(leadInfo.fetch("Owner").fetch("Id")).to eql owner
        @helper.addLogs("[Result ]   : Owner checked successfully\n")
        @helper.addLogs("[Validate ] : Checking create Journey on lead")
        @helper.addLogs("[Expected ] : Create Journey should #{@testDataJSON['Lead'][0]['Generate_Journey__c']}")
        @helper.addLogs("[Actual ]   : Create Journey on lead is #{leadInfo.fetch("Generate_Journey__c").inspect}")
        expect(leadInfo.fetch("Generate_Journey__c")).to eql false
        insertedJourneyInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,CampaignId__c,Owner.id, Owner.Name,CreatedDate ,Status__c , NMD_Next_Contact_Date__c ,Primary_Email__c , Lead_Source__c , Lead_Source_Detail__c , Primary_Phone__c , Company_Name__c , Building_Interested_In__c , Locations_Interested__c , Interested_in_Number_of_Desks__c , Full_Time_Employees__c, Name   FROM Journey__c WHERE Primary_Email__c = '#{leadInfo.fetch("Email")}'")[0]
        Helper.addRecordsToDelete("Journey__c", insertedJourneyInfo.fetch('Id'))
        @helper.addLogs("[Validate ] : Checking Journey is created on lead")
        @helper.addLogs("[Expected ] : Journey should be created")
        @helper.addLogs("[Actual ]   : Journey is created with name #{insertedJourneyInfo.fetch("Name")}")
        expect(insertedJourneyInfo).to_not eql nil
        Helper.addRecordsToDelete("Journey__c", insertedJourneyInfo.fetch('Id'))
        @helper.addLogs("[Result ]   : Journey created successfully\n")
        @helper.addLogs("[Validate ] : Checking Journey owner should be lead owner")
        @helper.addLogs("[Expected ] : Owner of Journey should be owner of lead")
        @helper.addLogs("[Actual ]   : Owner of Journey is #{insertedJourneyInfo.fetch("Owner").fetch("Id")}")
        expect(insertedJourneyInfo.fetch("Owner").fetch("Id")).to match owner
        @helper.addLogs("[Result ]   : Owner checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Campaign on journey")
        @helper.addLogs("[Expected ] : Campaign on Journey should be campaign selected while importing lead")
        @helper.addLogs("[Actual ]   : Campaign on Journey is #{insertedJourneyInfo.fetch("CampaignId__c")}")
        expect(insertedJourneyInfo.fetch("CampaignId__c")).to eql @campaignId.fetch('Id')
        @helper.addLogs("[Result ]   : Campaign checked successfully\n")
        @pageObject.instance_variable_get(:@testDataJSON)['Journey'][0]
        generatedActivityForLead = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Subject , CreatedDate,Status ,Lead_Source__c , Lead_Source_Detail__c,Owner.Name,Locations_Interested__c, Number_of_Full_Time_Employees__c,Interested_in_Number_of_Desks__c,Company__c,WhoId FROM Task WHERE WhoId = '#{leadInfo.fetch('Id')}'")[0]
        @helper.addLogs("[Validate ] : Checking Subject on acitivity")
        @helper.addLogs("[Expected ] : Subject on activity should be inboound lead submission")
        @helper.addLogs("[Actual ]   : Subject on activity  is #{generatedActivityForLead.fetch("Subject")}")
        expect(generatedActivityForLead.fetch("Subject")).to eql "Inbound Lead submission"
        @helper.addLogs("[Result ]   : Activity subject checked successfully")
        @helper.addLogs("[Validate ] : Checking lead source on activity")
        @helper.addLogs("[Expected ] : Lead source on activity should be lead source of created lead")
        @helper.addLogs("[Actual ]   : Lead source on activity is #{generatedActivityForLead.fetch("Lead_Source__c")}")
        expect(generatedActivityForLead.fetch("Lead_Source__c")).to eql "Inbound Call"
        @helper.addLogs("[Result ]   : Activity lead source checked successfully")
        @helper.addLogs("[Validate ] : Checking lead source detail on activity")
        @helper.addLogs("[Expected ] : Lead source detail on activity should be lead source of created lead")
        @helper.addLogs("[Actual ]   : Lead source detail on activity is #{generatedActivityForLead.fetch("Lead_Source__c")}")
        expect(generatedActivityForLead.fetch("Lead_Source_Detail__c")).to eql "Inbound Call Page"
        @helper.addLogs("[Result ]   : Activity lead source detail checked successfully")
        @helper.addLogs("[Validate ] : Checking status on activity")
        @helper.addLogs("[Expected ] : Status on activity should be Open")
        @helper.addLogs("[Actual ]   : Status on activity is #{generatedActivityForLead.fetch("Status")}")
        expect(generatedActivityForLead.fetch("Status")).to eql "Open"
        @helper.addLogs("[Result ]   : Activity assigned to field checked successfully")
        @helper.addLogs("[Validate ] : Checking Company on activity")
        @helper.addLogs("[Expected ] : Company on activity should be #{leadInfo.fetch('Company')}")
        @helper.addLogs("[Actual ]   : Status on activity is #{generatedActivityForLead.fetch("Company__c")}")
        expect(generatedActivityForLead.fetch("Company__c")).to eql leadInfo.fetch('Company')
        @helper.addLogs("[Result ]   : Activity Status field checked successfully")
        @helper.addLogs('Success')
        @helper.postSuccessResult(2578)
      rescue Exception => e
        @helper.addLogs('Error')
        @helper.postFailResult(e, 2578)
        raise e
      end
    end
    it 'To Check Journey not Created While Importing Existing Lead Which is Owned By Susie Romero Where Activity is Not present on Existing Lead, when the Generate Journey on UI is UnChecked and Generate Journey in CSV is false and assign to the Campaign.', :'2622' => 'true' do
      begin
        @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Generate_Journey__c'] = true
        leadInfo = nil
        @helper.getExistingLead(nil,nil,"Susie Romero",true).each do |lead|
          if lead['Tasks'].nil?
            leadInfo = lead
            break;
          end
        end
        leadInfo.nil? ? email = "John.Smith_QAAuto#{rand(9999999999999999)}@example.com" : email = leadInfo.fetch('Email')
        if leadInfo.nil?
          @testDataJSON['Lead'][0]['Email'] = email
          leadInfo = {"lastName"=>@testDataJSON['Lead'][0]['FirstName'],"firstName"=>@testDataJSON['Lead'][0]['LastName'],"website"=>"http://www.Testgmail.com","email"=>email,"phone"=>"8146185355","company"=>@testDataJSON['Lead'][0]['Company'],"company_Size__c"=>@testDataJSON['Lead'][0]['Number_of_Full_Time_Employees__c'],"lead_Source_Detail__c"=>@testDataJSON['Lead'][0]['lead_Source_Detail__c'],"utm_campaign__c"=>"San Francisco - Modifier","utm_content__c"=>"utm contents","utm_medium__c"=>"cpc","utm_source__c"=>"ads-google","utm_term__c"=>"virtual +office +san +francisco","locale__c"=>@testDataJSON['Lead'][0]['Locale__c'],"country_Code__c"=>@testDataJSON['Lead'][0]['Country_Code__c'] ,"number_of_Desks__c"=>@testDataJSON['Lead'][0]['Interested_in_Number_of_Desks__c'],"leadSource"=>@testDataJSON['Lead'][0]['LeadSource'],"Generate_Journey__c"=>false,"OwnerId"=>"005F0000003Kmbw"}
          leadInfo['Id'] = @helper.instance_variable_get(:@restForce).createRecord("Lead",leadInfo)
          Helper.addRecordsToDelete("Lead",leadInfo['Id'])
        end
        @pageObject.upload_csv(email, "", @testDataJSON['Campaign'][0]['Name'],true,false,"Lead")[0]
        expect(leadInfo).to_not eql nil
        @helper.addLogs("[Validate ] : Checking Lead owner should be lead owner on campaign")
        @helper.addLogs("[Expected ] : Owner of lead should be Logged in user")
        @pageObject.checkJobStatus
        leadInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Owner.Name, Generate_Journey__c,Owner.id,LeadSource , Lead_Source_Detail__c , Building_Interested_In__c , Building_Interested_Name__c ,Journey_Created_On__c, Locations_Interested__c , Number_of_Full_Time_Employees__c , Interested_in_Number_of_Desks__c , Email , Phone , Company , Name , RecordType.Name , Status , Type__c FROM Lead WHERE id = '#{leadInfo.fetch("Id")}'")[0]
        @helper.addLogs("[Actual ]   : Owner of lead is #{leadInfo.fetch("Owner").fetch("Id")}")
        owner = @pageObject.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
        expect(leadInfo.fetch("Owner").fetch("Id")).to eql owner
        @helper.addLogs("[Result ]   : Owner checked successfully\n")
        @helper.addLogs("[Validate ] : Checking create Journey on lead")
        @helper.addLogs("[Expected ] : Create Journey should #{@testDataJSON['Lead'][0]['Generate_Journey__c']}")
        @helper.addLogs("[Actual ]   : Create Journey on lead is #{leadInfo.fetch("Generate_Journey__c").inspect}")
        expect(leadInfo.fetch("Generate_Journey__c")).to eql false
        insertedJourneyInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,CampaignId__c,Owner.id, Owner.Name,CreatedDate ,Status__c , NMD_Next_Contact_Date__c ,Primary_Email__c , Lead_Source__c , Lead_Source_Detail__c , Primary_Phone__c , Company_Name__c , Building_Interested_In__c , Locations_Interested__c , Interested_in_Number_of_Desks__c , Full_Time_Employees__c, Name   FROM Journey__c WHERE Primary_Email__c = '#{leadInfo.fetch("Email")}'")[0]
        @helper.addLogs("[Validate ] : Checking Journey is created on lead")
        @helper.addLogs("[Expected ] : Journey should not be created")
        @helper.addLogs("[Actual ]   : Journey is created - #{insertedJourneyInfo.nil? ? "No" : "Yes"}")
        expect(insertedJourneyInfo).to eql nil
        @helper.addLogs("[Result ]   : Journey created successfully\n")
        generatedActivityForLead = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Subject , CreatedDate,Status ,Lead_Source__c , Lead_Source_Detail__c,Owner.Name,Locations_Interested__c, Number_of_Full_Time_Employees__c,Interested_in_Number_of_Desks__c,Company__c,WhoId FROM Task WHERE WhoId = '#{leadInfo.fetch('Id')}'")[0]
        @helper.addLogs("[Validate ] : Checking Subject on acitivity")
        @helper.addLogs("[Expected ] : Subject on activity should be inboound lead submission")
        @helper.addLogs("[Actual ]   : Subject on activity  is #{generatedActivityForLead.fetch("Subject")}")
        expect(generatedActivityForLead.fetch("Subject")).to eql "Inbound Lead submission"
        @helper.addLogs("[Result ]   : Activity subject checked successfully")
        @helper.addLogs("[Validate ] : Checking lead source on activity")
        @helper.addLogs("[Expected ] : Lead source on activity should be lead source of created lead")
        @helper.addLogs("[Actual ]   : Lead source on activity is #{generatedActivityForLead.fetch("Lead_Source__c")}")
        expect(generatedActivityForLead.fetch("Lead_Source__c")).to eql "Inbound Call"
        @helper.addLogs("[Result ]   : Activity lead source checked successfully")
        @helper.addLogs("[Validate ] : Checking lead source detail on activity")
        @helper.addLogs("[Expected ] : Lead source detail on activity should be lead source of created lead")
        @helper.addLogs("[Actual ]   : Lead source detail on activity is #{generatedActivityForLead.fetch("Lead_Source__c")}")
        expect(generatedActivityForLead.fetch("Lead_Source_Detail__c")).to eql "Inbound Call Page"
        @helper.addLogs("[Result ]   : Activity lead source detail checked successfully")
        @helper.addLogs("[Validate ] : Checking status on activity")
        @helper.addLogs("[Expected ] : Status on activity should be Open")
        @helper.addLogs("[Actual ]   : Status on activity is #{generatedActivityForLead.fetch("Status")}")
        expect(generatedActivityForLead.fetch("Status")).to eql "Open"
        @helper.addLogs("[Result ]   : Activity assigned to field checked successfully")
        @helper.addLogs("[Validate ] : Checking Company on activity")
        @helper.addLogs("[Expected ] : Company on activity should be #{leadInfo.fetch('Company')}")
        @helper.addLogs("[Actual ]   : Status on activity is #{generatedActivityForLead.fetch("Company__c")}")
        expect(generatedActivityForLead.fetch("Company__c")).to eql leadInfo.fetch('Company')
        @helper.addLogs("[Result ]   : Activity Status field checked successfully")
        @helper.addLogs('Success')
        @helper.postSuccessResult(2622)
      rescue Exception => e
        @helper.addLogs('Error')
        @helper.postFailResult(e, 2622)
        raise e
      end
    end
  end
  context "Kickbox Importer While Insertion of Existing Lead Which is Owned By Susie Romero from Kickbox and assign to the Particular Campaign Based on Email Address Criterias",'325'=>'true' do
    before(:all) do
      @testDataJSON['Campaign'][0]['Lead Owner'] = ''
      @testDataJSON['Campaign'][0]['Email Address'] = 'vikhroliwest@wework.co.in'
      @testDataJSON['Campaign'][0]['City'] = ''
      @campaignId = @helper.instance_variable_get(:@restForce).getRecords("SELECT id FROM Campaign WHERE Name = '#{@testDataJSON['Campaign'][0]['Name']}'")[0]
      @helper.update_campaign(@campaignId.fetch('Id'),nil,@testDataJSON['Campaign'][0]['Email Address'])
    end
    it 'To Check Journey is Created While Importing Existing Lead  Which is Owned By Susie Romero Where Activity is Not present on Existing Lead, when the Generate Journey on UI is Checked and Generate Journey in CSV is Blank and assign to the Campaign.', :'2636' => 'true' do
      begin
        leadInfo = nil
        @helper.getExistingLead(nil,nil,"Susie Romero",true).each do |lead|
          if lead['Tasks'].nil?
            leadInfo = lead
            break;
          end
        end
        leadInfo.nil? ? email = "John.Smith_QAAuto#{rand(9999999999999999)}@example.com" : email = leadInfo.fetch('Email')
        if leadInfo.nil?
          @testDataJSON['Lead'][0]['Email'] = email
          @testDataJSON['Lead'][0]['Generate_Journey__c'] = false
          leadInfo = {"lastName"=>@testDataJSON['Lead'][0]['FirstName'],"firstName"=>@testDataJSON['Lead'][0]['LastName'],"website"=>"http://www.Testgmail.com","email"=>email,"phone"=>"8146185355","company"=>@testDataJSON['Lead'][0]['Company'],"company_Size__c"=>@testDataJSON['Lead'][0]['Number_of_Full_Time_Employees__c'],"lead_Source_Detail__c"=>@testDataJSON['Lead'][0]['lead_Source_Detail__c'],"utm_campaign__c"=>"San Francisco - Modifier","utm_content__c"=>"utm contents","utm_medium__c"=>"cpc","utm_source__c"=>"ads-google","utm_term__c"=>"virtual +office +san +francisco","locale__c"=>@testDataJSON['Lead'][0]['Locale__c'],"country_Code__c"=>@testDataJSON['Lead'][0]['Country_Code__c'] ,"number_of_Desks__c"=>@testDataJSON['Lead'][0]['Interested_in_Number_of_Desks__c'],"leadSource"=>@testDataJSON['Lead'][0]['LeadSource'],"Generate_Journey__c"=>false,"OwnerId"=>"005F0000003Kmbw"}
          leadInfo['Id'] = @helper.instance_variable_get(:@restForce).createRecord("Lead",leadInfo)
          Helper.addRecordsToDelete("Lead",leadInfo['Id'])
        end
        @pageObject.upload_csv(email, "", @testDataJSON['Campaign'][0]['Name'],false,false,"Lead")[0]
        expect(leadInfo).to_not eql nil
        @helper.addLogs("[Validate ] : Checking Lead owner should be lead owner on campaign")
        @helper.addLogs("[Expected ] : Owner of lead should be Logged in user")
        @pageObject.checkJobStatus
        leadInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Owner.Name, Generate_Journey__c,Owner.id,LeadSource , Lead_Source_Detail__c , Building_Interested_In__c , Building_Interested_Name__c ,Journey_Created_On__c, Locations_Interested__c , Number_of_Full_Time_Employees__c , Interested_in_Number_of_Desks__c , Email , Phone , Company , Name , RecordType.Name , Status , Type__c FROM Lead WHERE id = '#{leadInfo.fetch("Id")}'")[0]
        @helper.addLogs("[Actual ]   : Owner of lead is #{leadInfo.fetch("Owner").fetch("Id")}")
        owner = @pageObject.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
        expect(leadInfo.fetch("Owner").fetch("Id")).to eql owner
        @helper.addLogs("[Result ]   : Owner checked successfully\n")
        @helper.addLogs("[Validate ] : Checking create Journey on lead")
        @helper.addLogs("[Expected ] : Create Journey should #{@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Generate_Journey__c']}")
        @helper.addLogs("[Actual ]   : Create Journey on lead is #{leadInfo.fetch("Generate_Journey__c").inspect}")
        expect(leadInfo.fetch("Generate_Journey__c")).to eql @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Generate_Journey__c']
        insertedJourneyInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,CampaignId__c,Owner.id, Owner.Name,CreatedDate ,Status__c , NMD_Next_Contact_Date__c ,Primary_Email__c , Lead_Source__c , Lead_Source_Detail__c , Primary_Phone__c , Company_Name__c , Building_Interested_In__c , Locations_Interested__c , Interested_in_Number_of_Desks__c , Full_Time_Employees__c, Name   FROM Journey__c WHERE Primary_Email__c = '#{leadInfo.fetch("Email")}'")[0]
        Helper.addRecordsToDelete("Journey__c", insertedJourneyInfo.fetch('Id'))
        @helper.addLogs("[Validate ] : Checking Journey is created on lead")
        @helper.addLogs("[Expected ] : Journey should be created")
        @helper.addLogs("[Actual ]   : Journey is created with name #{insertedJourneyInfo.fetch("Name")}")
        expect(insertedJourneyInfo).to_not eql nil
        Helper.addRecordsToDelete("Journey__c", insertedJourneyInfo.fetch('Id'))
        @helper.addLogs("[Result ]   : Journey created successfully\n")
        @helper.addLogs("[Validate ] : Checking Journey owner should be lead owner")
        @helper.addLogs("[Expected ] : Owner of Journey should be owner of lead")
        @helper.addLogs("[Actual ]   : Owner of Journey is #{insertedJourneyInfo.fetch("Owner").fetch("Id")}")
        expect(insertedJourneyInfo.fetch("Owner").fetch("Id")).to match owner
        @helper.addLogs("[Result ]   : Owner checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Campaign on journey")
        @helper.addLogs("[Expected ] : Campaign on Journey should be campaign selected while importing lead")
        @helper.addLogs("[Actual ]   : Campaign on Journey is #{insertedJourneyInfo.fetch("CampaignId__c")}")
        expect(insertedJourneyInfo.fetch("CampaignId__c")).to eql @campaignId.fetch('Id')
        @helper.addLogs("[Result ]   : Campaign checked successfully\n")
        @pageObject.instance_variable_get(:@testDataJSON)['Journey'][0]
        generatedActivityForLead = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Subject , CreatedDate,Status ,Lead_Source__c , Lead_Source_Detail__c,Owner.Name,Locations_Interested__c, Number_of_Full_Time_Employees__c,Interested_in_Number_of_Desks__c,Company__c,WhoId FROM Task WHERE WhoId = '#{leadInfo.fetch('Id')}'")[0]
        @helper.addLogs("[Validate ] : Checking Subject on acitivity")
        @helper.addLogs("[Expected ] : Subject on activity should be inboound lead submission")
        @helper.addLogs("[Actual ]   : Subject on activity  is #{generatedActivityForLead.fetch("Subject")}")
        expect(generatedActivityForLead.fetch("Subject")).to eql "Inbound Lead submission"
        @helper.addLogs("[Result ]   : Activity subject checked successfully")
        @helper.addLogs("[Validate ] : Checking lead source on activity")
        @helper.addLogs("[Expected ] : Lead source on activity should be lead source of created lead")
        @helper.addLogs("[Actual ]   : Lead source on activity is #{generatedActivityForLead.fetch("Lead_Source__c")}")
        expect(generatedActivityForLead.fetch("Lead_Source__c")).to eql "Inbound Call"
        @helper.addLogs("[Result ]   : Activity lead source checked successfully")
        @helper.addLogs("[Validate ] : Checking lead source detail on activity")
        @helper.addLogs("[Expected ] : Lead source detail on activity should be lead source of created lead")
        @helper.addLogs("[Actual ]   : Lead source detail on activity is #{generatedActivityForLead.fetch("Lead_Source__c")}")
        expect(generatedActivityForLead.fetch("Lead_Source_Detail__c")).to eql "Inbound Call Page"
        @helper.addLogs("[Result ]   : Activity lead source detail checked successfully")
        @helper.addLogs("[Validate ] : Checking status on activity")
        @helper.addLogs("[Expected ] : Status on activity should be Open")
        @helper.addLogs("[Actual ]   : Status on activity is #{generatedActivityForLead.fetch("Status")}")
        expect(generatedActivityForLead.fetch("Status")).to eql "Open"
        @helper.addLogs("[Result ]   : Activity assigned to field checked successfully")
        @helper.addLogs("[Validate ] : Checking Company on activity")
        @helper.addLogs("[Expected ] : Company on activity should be #{leadInfo.fetch('Company')}")
        @helper.addLogs("[Actual ]   : Status on activity is #{generatedActivityForLead.fetch("Company__c")}")
        expect(generatedActivityForLead.fetch("Company__c")).to eql leadInfo.fetch('Company')
        @helper.addLogs("[Result ]   : Activity Status field checked successfully")
        @helper.addLogs('Success')
        @helper.postSuccessResult(2636)
      rescue Exception => e
        @helper.addLogs('Error')
        @helper.postFailResult(e, 2636)
        raise e
      end
    end
    it 'To Check Journey is Created While Importing Existing Lead Which is Owned By Susie Romero Where Activity is Not present on Existing Lead, when the Generate Journey on UI is UnChecked and Generate Journey in CSV is True and assign to the Campaign.', :'2637' => 'true' do
      begin
        @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Generate_Journey__c'] = true
        leadInfo = nil
        @helper.getExistingLead(nil,nil,"Susie Romero",true).each do |lead|
          if lead['Tasks'].nil?
            leadInfo = lead
            break;
          end
        end
        leadInfo.nil? ? email = "John.Smith_QAAuto#{rand(9999999999999999)}@example.com" : email = leadInfo.fetch('Email')
        if leadInfo.nil?
          @testDataJSON['Lead'][0]['Email'] = email
          leadInfo = {"lastName"=>@testDataJSON['Lead'][0]['FirstName'],"firstName"=>@testDataJSON['Lead'][0]['LastName'],"website"=>"http://www.Testgmail.com","email"=>email,"phone"=>"8146185355","company"=>@testDataJSON['Lead'][0]['Company'],"company_Size__c"=>@testDataJSON['Lead'][0]['Number_of_Full_Time_Employees__c'],"lead_Source_Detail__c"=>@testDataJSON['Lead'][0]['lead_Source_Detail__c'],"utm_campaign__c"=>"San Francisco - Modifier","utm_content__c"=>"utm contents","utm_medium__c"=>"cpc","utm_source__c"=>"ads-google","utm_term__c"=>"virtual +office +san +francisco","locale__c"=>@testDataJSON['Lead'][0]['Locale__c'],"country_Code__c"=>@testDataJSON['Lead'][0]['Country_Code__c'] ,"number_of_Desks__c"=>@testDataJSON['Lead'][0]['Interested_in_Number_of_Desks__c'],"leadSource"=>@testDataJSON['Lead'][0]['LeadSource'],"Generate_Journey__c"=>false,"OwnerId"=>"005F0000003Kmbw"}
          leadInfo['Id'] = @helper.instance_variable_get(:@restForce).createRecord("Lead",leadInfo)
          Helper.addRecordsToDelete("Lead",leadInfo['Id'])
        end
        @pageObject.upload_csv(email, "TRUE", @testDataJSON['Campaign'][0]['Name'],true,false,"Lead")[0]
        expect(leadInfo).to_not eql nil
        @helper.addLogs("[Validate ] : Checking Lead owner should be lead owner on campaign")
        @helper.addLogs("[Expected ] : Owner of lead should be Logged in user")
        @pageObject.checkJobStatus
        leadInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Owner.Name, Generate_Journey__c,Owner.id,LeadSource , Lead_Source_Detail__c , Building_Interested_In__c , Building_Interested_Name__c ,Journey_Created_On__c, Locations_Interested__c , Number_of_Full_Time_Employees__c , Interested_in_Number_of_Desks__c , Email , Phone , Company , Name , RecordType.Name , Status , Type__c FROM Lead WHERE id = '#{leadInfo.fetch("Id")}'")[0]
        @helper.addLogs("[Actual ]   : Owner of lead is #{leadInfo.fetch("Owner").fetch("Id")}")
        owner = @pageObject.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
        expect(leadInfo.fetch("Owner").fetch("Id")).to eql owner
        @helper.addLogs("[Result ]   : Owner checked successfully\n")
        @helper.addLogs("[Validate ] : Checking create Journey on lead")
        @helper.addLogs("[Expected ] : Create Journey should #{@testDataJSON['Lead'][0]['Generate_Journey__c']}")
        @helper.addLogs("[Actual ]   : Create Journey on lead is #{leadInfo.fetch("Generate_Journey__c").inspect}")
        expect(leadInfo.fetch("Generate_Journey__c")).to eql false
        insertedJourneyInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,CampaignId__c,Owner.id, Owner.Name,CreatedDate ,Status__c , NMD_Next_Contact_Date__c ,Primary_Email__c , Lead_Source__c , Lead_Source_Detail__c , Primary_Phone__c , Company_Name__c , Building_Interested_In__c , Locations_Interested__c , Interested_in_Number_of_Desks__c , Full_Time_Employees__c, Name   FROM Journey__c WHERE Primary_Email__c = '#{leadInfo.fetch("Email")}'")[0]
        Helper.addRecordsToDelete("Journey__c", insertedJourneyInfo.fetch('Id'))
        @helper.addLogs("[Validate ] : Checking Journey is created on lead")
        @helper.addLogs("[Expected ] : Journey should be created")
        @helper.addLogs("[Actual ]   : Journey is created with name #{insertedJourneyInfo.fetch("Name")}")
        expect(insertedJourneyInfo).to_not eql nil
        Helper.addRecordsToDelete("Journey__c", insertedJourneyInfo.fetch('Id'))
        @helper.addLogs("[Result ]   : Journey created successfully\n")
        @helper.addLogs("[Validate ] : Checking Journey owner should be lead owner")
        @helper.addLogs("[Expected ] : Owner of Journey should be owner of lead")
        @helper.addLogs("[Actual ]   : Owner of Journey is #{insertedJourneyInfo.fetch("Owner").fetch("Id")}")
        expect(insertedJourneyInfo.fetch("Owner").fetch("Id")).to match owner
        @helper.addLogs("[Result ]   : Owner checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Campaign on journey")
        @helper.addLogs("[Expected ] : Campaign on Journey should be campaign selected while importing lead")
        @helper.addLogs("[Actual ]   : Campaign on Journey is #{insertedJourneyInfo.fetch("CampaignId__c")}")
        expect(insertedJourneyInfo.fetch("CampaignId__c")).to eql @campaignId.fetch('Id')
        @helper.addLogs("[Result ]   : Campaign checked successfully\n")
        @pageObject.instance_variable_get(:@testDataJSON)['Journey'][0]
        generatedActivityForLead = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Subject , CreatedDate,Status ,Lead_Source__c , Lead_Source_Detail__c,Owner.Name,Locations_Interested__c, Number_of_Full_Time_Employees__c,Interested_in_Number_of_Desks__c,Company__c,WhoId FROM Task WHERE WhoId = '#{leadInfo.fetch('Id')}'")[0]
        @helper.addLogs("[Validate ] : Checking Subject on acitivity")
        @helper.addLogs("[Expected ] : Subject on activity should be inboound lead submission")
        @helper.addLogs("[Actual ]   : Subject on activity  is #{generatedActivityForLead.fetch("Subject")}")
        expect(generatedActivityForLead.fetch("Subject")).to eql "Inbound Lead submission"
        @helper.addLogs("[Result ]   : Activity subject checked successfully")
        @helper.addLogs("[Validate ] : Checking lead source on activity")
        @helper.addLogs("[Expected ] : Lead source on activity should be lead source of created lead")
        @helper.addLogs("[Actual ]   : Lead source on activity is #{generatedActivityForLead.fetch("Lead_Source__c")}")
        expect(generatedActivityForLead.fetch("Lead_Source__c")).to eql "Inbound Call"
        @helper.addLogs("[Result ]   : Activity lead source checked successfully")
        @helper.addLogs("[Validate ] : Checking lead source detail on activity")
        @helper.addLogs("[Expected ] : Lead source detail on activity should be lead source of created lead")
        @helper.addLogs("[Actual ]   : Lead source detail on activity is #{generatedActivityForLead.fetch("Lead_Source__c")}")
        expect(generatedActivityForLead.fetch("Lead_Source_Detail__c")).to eql "Inbound Call Page"
        @helper.addLogs("[Result ]   : Activity lead source detail checked successfully")
        @helper.addLogs("[Validate ] : Checking status on activity")
        @helper.addLogs("[Expected ] : Status on activity should be Open")
        @helper.addLogs("[Actual ]   : Status on activity is #{generatedActivityForLead.fetch("Status")}")
        expect(generatedActivityForLead.fetch("Status")).to eql "Open"
        @helper.addLogs("[Result ]   : Activity assigned to field checked successfully")
        @helper.addLogs("[Validate ] : Checking Company on activity")
        @helper.addLogs("[Expected ] : Company on activity should be #{leadInfo.fetch('Company')}")
        @helper.addLogs("[Actual ]   : Status on activity is #{generatedActivityForLead.fetch("Company__c")}")
        expect(generatedActivityForLead.fetch("Company__c")).to eql leadInfo.fetch('Company')
        @helper.addLogs("[Result ]   : Activity Status field checked successfully")
        @helper.addLogs('Success')
        @helper.postSuccessResult(2637)
      rescue Exception => e
        @helper.addLogs('Error')
        @helper.postFailResult(e, 2637)
        raise e
      end
    end
    it 'To Check Journey is Created While Importing Existing Lead Which is Owned By Susie Romero Where Activity is present on Existing Lead, when the Generate Journey on UI is Checked and Generate Journey in CSV is Blank and assign to the Campaign.', :'2639' => 'true' do
      begin
        @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Generate_Journey__c'] = true
        leadInfo = nil
        @helper.getExistingLead(nil,nil,"Susie Romero",true).each do |lead|
          if !lead['Tasks'].nil?
            leadInfo = lead
            break;
          end
        end
        leadInfo.nil? ? email = "John.Smith_QAAuto#{rand(9999999999999999)}@example.com" : email = leadInfo.fetch('Email')
        if leadInfo.nil?
          @testDataJSON['Lead'][0]['Email'] = email
          leadInfo = {"lastName"=>@testDataJSON['Lead'][0]['FirstName'],"firstName"=>@testDataJSON['Lead'][0]['LastName'],"website"=>"http://www.Testgmail.com","email"=>email,"phone"=>"8146185355","company"=>@testDataJSON['Lead'][0]['Company'],"company_Size__c"=>@testDataJSON['Lead'][0]['Number_of_Full_Time_Employees__c'],"lead_Source_Detail__c"=>@testDataJSON['Lead'][0]['lead_Source_Detail__c'],"utm_campaign__c"=>"San Francisco - Modifier","utm_content__c"=>"utm contents","utm_medium__c"=>"cpc","utm_source__c"=>"ads-google","utm_term__c"=>"virtual +office +san +francisco","locale__c"=>@testDataJSON['Lead'][0]['Locale__c'],"country_Code__c"=>@testDataJSON['Lead'][0]['Country_Code__c'] ,"number_of_Desks__c"=>@testDataJSON['Lead'][0]['Interested_in_Number_of_Desks__c'],"leadSource"=>@testDataJSON['Lead'][0]['LeadSource'],"Generate_Journey__c"=>false,"OwnerId"=>"005F0000003Kmbw"}
          leadInfo['Id'] = @helper.instance_variable_get(:@restForce).createRecord("Lead",leadInfo)
          Helper.addRecordsToDelete("Lead",leadInfo['Id'])
        end
        @pageObject.upload_csv(email, "FALSE", @testDataJSON['Campaign'][0]['Name'],false,false,"Lead")[0]
        expect(leadInfo).to_not eql nil
        @helper.addLogs("[Validate ] : Checking Lead owner should be lead owner on campaign")
        @helper.addLogs("[Expected ] : Owner of lead should be Logged in user")
        @pageObject.checkJobStatus
        leadInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Owner.Name, Generate_Journey__c,Owner.id,LeadSource , Lead_Source_Detail__c , Building_Interested_In__c , Building_Interested_Name__c ,Journey_Created_On__c, Locations_Interested__c , Number_of_Full_Time_Employees__c , Interested_in_Number_of_Desks__c , Email , Phone , Company , Name , RecordType.Name , Status , Type__c FROM Lead WHERE id = '#{leadInfo.fetch("Id")}'")[0]
        @helper.addLogs("[Actual ]   : Owner of lead is #{leadInfo.fetch("Owner").fetch("Id")}")
        owner = @pageObject.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
        expect(leadInfo.fetch("Owner").fetch("Id")).to eql owner
        @helper.addLogs("[Result ]   : Owner checked successfully\n")
        @helper.addLogs("[Validate ] : Checking create Journey on lead")
        @helper.addLogs("[Expected ] : Create Journey should #{@testDataJSON['Lead'][0]['Generate_Journey__c']}")
        @helper.addLogs("[Actual ]   : Create Journey on lead is #{leadInfo.fetch("Generate_Journey__c").inspect}")
        expect(leadInfo.fetch("Generate_Journey__c")).to eql false
        insertedJourneyInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,CampaignId__c,Owner.id, Owner.Name,CreatedDate ,Status__c , NMD_Next_Contact_Date__c ,Primary_Email__c , Lead_Source__c , Lead_Source_Detail__c , Primary_Phone__c , Company_Name__c , Building_Interested_In__c , Locations_Interested__c , Interested_in_Number_of_Desks__c , Full_Time_Employees__c, Name   FROM Journey__c WHERE Primary_Email__c = '#{leadInfo.fetch("Email")}'")[0]
        Helper.addRecordsToDelete("Journey__c", insertedJourneyInfo.fetch('Id'))
        @helper.addLogs("[Validate ] : Checking Journey is created on lead")
        @helper.addLogs("[Expected ] : Journey should be created")
        @helper.addLogs("[Actual ]   : Journey is created with name #{insertedJourneyInfo.fetch("Name")}")
        expect(insertedJourneyInfo).to_not eql nil
        Helper.addRecordsToDelete("Journey__c", insertedJourneyInfo.fetch('Id'))
        @helper.addLogs("[Result ]   : Journey created successfully\n")
        @helper.addLogs("[Validate ] : Checking Journey owner should be lead owner")
        @helper.addLogs("[Expected ] : Owner of Journey should be owner of lead")
        @helper.addLogs("[Actual ]   : Owner of Journey is #{insertedJourneyInfo.fetch("Owner").fetch("Id")}")
        expect(insertedJourneyInfo.fetch("Owner").fetch("Id")).to match owner
        @helper.addLogs("[Result ]   : Owner checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Campaign on journey")
        @helper.addLogs("[Expected ] : Campaign on Journey should be campaign selected while importing lead")
        @helper.addLogs("[Actual ]   : Campaign on Journey is #{insertedJourneyInfo.fetch("CampaignId__c")}")
        expect(insertedJourneyInfo.fetch("CampaignId__c")).to eql @campaignId.fetch('Id')
        @helper.addLogs("[Result ]   : Campaign checked successfully\n")
        @pageObject.instance_variable_get(:@testDataJSON)['Journey'][0]
        generatedActivityForLead = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Subject , CreatedDate,Status ,Lead_Source__c , Lead_Source_Detail__c,Owner.Name,Locations_Interested__c, Number_of_Full_Time_Employees__c,Interested_in_Number_of_Desks__c,Company__c,WhoId FROM Task WHERE WhoId = '#{leadInfo.fetch('Id')}'")[0]
        @helper.addLogs("[Validate ] : Checking Subject on acitivity")
        @helper.addLogs("[Expected ] : Subject on activity should be inboound lead submission")
        @helper.addLogs("[Actual ]   : Subject on activity  is #{generatedActivityForLead.fetch("Subject")}")
        expect(generatedActivityForLead.fetch("Subject")).to eql "Inbound Lead submission"
        @helper.addLogs("[Result ]   : Activity subject checked successfully")
        @helper.addLogs("[Validate ] : Checking lead source on activity")
        @helper.addLogs("[Expected ] : Lead source on activity should be lead source of created lead")
        @helper.addLogs("[Actual ]   : Lead source on activity is #{generatedActivityForLead.fetch("Lead_Source__c")}")
        expect(generatedActivityForLead.fetch("Lead_Source__c")).to eql "Inbound Call"
        @helper.addLogs("[Result ]   : Activity lead source checked successfully")
        @helper.addLogs("[Validate ] : Checking lead source detail on activity")
        @helper.addLogs("[Expected ] : Lead source detail on activity should be lead source of created lead")
        @helper.addLogs("[Actual ]   : Lead source detail on activity is #{generatedActivityForLead.fetch("Lead_Source__c")}")
        expect(generatedActivityForLead.fetch("Lead_Source_Detail__c")).to eql "Inbound Call Page"
        @helper.addLogs("[Result ]   : Activity lead source detail checked successfully")
        @helper.addLogs("[Validate ] : Checking status on activity")
        @helper.addLogs("[Expected ] : Status on activity should be Open")
        @helper.addLogs("[Actual ]   : Status on activity is #{generatedActivityForLead.fetch("Status")}")
        expect(generatedActivityForLead.fetch("Status")).to eql "Open"
        @helper.addLogs("[Result ]   : Activity assigned to field checked successfully")
        @helper.addLogs("[Validate ] : Checking Company on activity")
        @helper.addLogs("[Expected ] : Company on activity should be #{leadInfo.fetch('Company')}")
        @helper.addLogs("[Actual ]   : Status on activity is #{generatedActivityForLead.fetch("Company__c")}")
        expect(generatedActivityForLead.fetch("Company__c")).to eql leadInfo.fetch('Company')
        @helper.addLogs("[Result ]   : Activity Status field checked successfully")
        @helper.addLogs('Success')
        @helper.postSuccessResult(2639)
      rescue Exception => e
        @helper.addLogs('Error')
        @helper.postFailResult(e, 2639)
        raise e
      end
    end
    it 'To Check Journey Created for Existing Lead Owned By Susie Romero Where Activity is not present and which is assigned to the particular Campaign, When the generate Journey on UI is Checked & Generate Journey in CSV is Blank & inserted into diff Campgn.', :'2644' => 'true' do
      begin
        leadInfo = nil
        leadInfo = @helper.instance_variable_get(:@restForce).getRecords("select lead.email from campaignmember where campaignid != '7010G000001V6lGQAS' and lead.email like '%example.com' and lead.owner.name = 'Susie Romero'")[0]
        leadInfo.nil? ? email = "John.Smith_QAAuto#{rand(9999999999999999)}@example.com" : email = leadInfo.fetch('Email')
        if leadInfo.nil?
          @testDataJSON['Lead'][0]['Email'] = email
          leadInfo = {"lastName"=>@testDataJSON['Lead'][0]['FirstName'],"firstName"=>@testDataJSON['Lead'][0]['LastName'],"website"=>"http://www.Testgmail.com","email"=>email,"phone"=>"8146185355","company"=>@testDataJSON['Lead'][0]['Company'],"company_Size__c"=>@testDataJSON['Lead'][0]['Number_of_Full_Time_Employees__c'],"lead_Source_Detail__c"=>@testDataJSON['Lead'][0]['lead_Source_Detail__c'],"utm_campaign__c"=>"San Francisco - Modifier","utm_content__c"=>"utm contents","utm_medium__c"=>"cpc","utm_source__c"=>"ads-google","utm_term__c"=>"virtual +office +san +francisco","locale__c"=>@testDataJSON['Lead'][0]['Locale__c'],"country_Code__c"=>@testDataJSON['Lead'][0]['Country_Code__c'] ,"number_of_Desks__c"=>@testDataJSON['Lead'][0]['Interested_in_Number_of_Desks__c'],"leadSource"=>@testDataJSON['Lead'][0]['LeadSource'],"Generate_Journey__c"=>false,"OwnerId"=>"005F0000003Kmbw"}
          leadInfo['Id'] = @helper.instance_variable_get(:@restForce).createRecord("Lead",leadInfo)
          @helper.instance_variable_get(:@restForce).createRecord("CampaignMember",{"lead"=>leadInfo.fetch("Id"),"campaignId"=>"7010G000000Ccln"})
          Helper.addRecordsToDelete("Lead",leadInfo['Id'])
        end
        @pageObject.upload_csv(email, "", @testDataJSON['Campaign'][0]['Name'],false,false,"Lead")[0]
        expect(leadInfo).to_not eql nil
        @helper.addLogs("[Validate ] : Checking Lead owner should be lead owner on campaign")
        @helper.addLogs("[Expected ] : Owner of lead should be Logged in user")
        @pageObject.checkJobStatus
        leadInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Owner.Name, Generate_Journey__c,Owner.id,LeadSource , Lead_Source_Detail__c , Building_Interested_In__c , Building_Interested_Name__c ,Journey_Created_On__c, Locations_Interested__c , Number_of_Full_Time_Employees__c , Interested_in_Number_of_Desks__c , Email , Phone , Company , Name , RecordType.Name , Status , Type__c FROM Lead WHERE id = '#{leadInfo.fetch("Id")}'")[0]
        @helper.addLogs("[Actual ]   : Owner of lead is #{leadInfo.fetch("Owner").fetch("Id")}")
        owner = @pageObject.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
        expect(leadInfo.fetch("Owner").fetch("Id")).to eql owner
        @helper.addLogs("[Result ]   : Owner checked successfully\n")
        @helper.addLogs("[Validate ] : Checking create Journey on lead")
        @helper.addLogs("[Expected ] : Create Journey should #{@testDataJSON['Lead'][0]['Generate_Journey__c']}")
        @helper.addLogs("[Actual ]   : Create Journey on lead is #{leadInfo.fetch("Generate_Journey__c").inspect}")
        expect(leadInfo.fetch("Generate_Journey__c")).to eql false
        insertedJourneyInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,CampaignId__c,Owner.id, Owner.Name,CreatedDate ,Status__c , NMD_Next_Contact_Date__c ,Primary_Email__c , Lead_Source__c , Lead_Source_Detail__c , Primary_Phone__c , Company_Name__c , Building_Interested_In__c , Locations_Interested__c , Interested_in_Number_of_Desks__c , Full_Time_Employees__c, Name   FROM Journey__c WHERE Primary_Email__c = '#{leadInfo.fetch("Email")}'")[0]
        Helper.addRecordsToDelete("Journey__c", insertedJourneyInfo.fetch('Id'))
        @helper.addLogs("[Validate ] : Checking Journey is created on lead")
        @helper.addLogs("[Expected ] : Journey should be created")
        @helper.addLogs("[Actual ]   : Journey is created with name #{insertedJourneyInfo.fetch("Name")}")
        expect(insertedJourneyInfo).to_not eql nil
        Helper.addRecordsToDelete("Journey__c", insertedJourneyInfo.fetch('Id'))
        @helper.addLogs("[Result ]   : Journey created successfully\n")
        @helper.addLogs("[Validate ] : Checking Journey owner should be lead owner")
        @helper.addLogs("[Expected ] : Owner of Journey should be owner of lead")
        @helper.addLogs("[Actual ]   : Owner of Journey is #{insertedJourneyInfo.fetch("Owner").fetch("Id")}")
        expect(insertedJourneyInfo.fetch("Owner").fetch("Id")).to match owner
        @helper.addLogs("[Result ]   : Owner checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Campaign on journey")
        @helper.addLogs("[Expected ] : Campaign on Journey should be campaign selected while importing lead")
        @helper.addLogs("[Actual ]   : Campaign on Journey is #{insertedJourneyInfo.fetch("CampaignId__c")}")
        expect(insertedJourneyInfo.fetch("CampaignId__c")).to eql @campaignId.fetch('Id')
        @helper.addLogs("[Result ]   : Campaign checked successfully\n")
        @pageObject.instance_variable_get(:@testDataJSON)['Journey'][0]
        generatedActivityForLead = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Subject , CreatedDate,Status ,Lead_Source__c , Lead_Source_Detail__c,Owner.Name,Locations_Interested__c, Number_of_Full_Time_Employees__c,Interested_in_Number_of_Desks__c,Company__c,WhoId FROM Task WHERE WhoId = '#{leadInfo.fetch('Id')}'")[0]
        @helper.addLogs("[Validate ] : Checking Subject on acitivity")
        @helper.addLogs("[Expected ] : Subject on activity should be inboound lead submission")
        @helper.addLogs("[Actual ]   : Subject on activity  is #{generatedActivityForLead.fetch("Subject")}")
        expect(generatedActivityForLead.fetch("Subject")).to eql "Inbound Lead submission"
        @helper.addLogs("[Result ]   : Activity subject checked successfully")
        @helper.addLogs("[Validate ] : Checking lead source on activity")
        @helper.addLogs("[Expected ] : Lead source on activity should be lead source of created lead")
        @helper.addLogs("[Actual ]   : Lead source on activity is #{generatedActivityForLead.fetch("Lead_Source__c")}")
        expect(generatedActivityForLead.fetch("Lead_Source__c")).to eql "Inbound Call"
        @helper.addLogs("[Result ]   : Activity lead source checked successfully")
        @helper.addLogs("[Validate ] : Checking lead source detail on activity")
        @helper.addLogs("[Expected ] : Lead source detail on activity should be lead source of created lead")
        @helper.addLogs("[Actual ]   : Lead source detail on activity is #{generatedActivityForLead.fetch("Lead_Source__c")}")
        expect(generatedActivityForLead.fetch("Lead_Source_Detail__c")).to eql "Inbound Call Page"
        @helper.addLogs("[Result ]   : Activity lead source detail checked successfully")
        @helper.addLogs("[Validate ] : Checking status on activity")
        @helper.addLogs("[Expected ] : Status on activity should be Open")
        @helper.addLogs("[Actual ]   : Status on activity is #{generatedActivityForLead.fetch("Status")}")
        expect(generatedActivityForLead.fetch("Status")).to eql "Open"
        @helper.addLogs("[Result ]   : Activity assigned to field checked successfully")
        @helper.addLogs("[Validate ] : Checking Company on activity")
        @helper.addLogs("[Expected ] : Company on activity should be #{leadInfo.fetch('Company')}")
        @helper.addLogs("[Actual ]   : Status on activity is #{generatedActivityForLead.fetch("Company__c")}")
        expect(generatedActivityForLead.fetch("Company__c")).to eql leadInfo.fetch('Company')
        @helper.addLogs("[Result ]   : Activity Status field checked successfully")
        @helper.addLogs('Success')
        @helper.postSuccessResult(2578)
      rescue Exception => e
        @helper.addLogs('Error')
        @helper.postFailResult(e, 2578)
        raise e
      end
    end
    it 'To Check Journey not Created While Importing Existing Lead Which is Owned By Susie Romero Where Activity is Not present on Existing Lead, when the Generate Journey on UI is UnChecked and Generate Journey in CSV is false and assign to the Campaign.', :'2638' => 'true' do
      begin
        @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Generate_Journey__c'] = true
        leadInfo = nil
        @helper.getExistingLead(nil,nil,"Susie Romero",true).each do |lead|
          if lead['Tasks'].nil?
            leadInfo = lead
            break;
          end
        end
        leadInfo.nil? ? email = "John.Smith_QAAuto#{rand(9999999999999999)}@example.com" : email = leadInfo.fetch('Email')
        if leadInfo.nil?
          @testDataJSON['Lead'][0]['Email'] = email
          leadInfo = {"lastName"=>@testDataJSON['Lead'][0]['FirstName'],"firstName"=>@testDataJSON['Lead'][0]['LastName'],"website"=>"http://www.Testgmail.com","email"=>email,"phone"=>"8146185355","company"=>@testDataJSON['Lead'][0]['Company'],"company_Size__c"=>@testDataJSON['Lead'][0]['Number_of_Full_Time_Employees__c'],"lead_Source_Detail__c"=>@testDataJSON['Lead'][0]['lead_Source_Detail__c'],"utm_campaign__c"=>"San Francisco - Modifier","utm_content__c"=>"utm contents","utm_medium__c"=>"cpc","utm_source__c"=>"ads-google","utm_term__c"=>"virtual +office +san +francisco","locale__c"=>@testDataJSON['Lead'][0]['Locale__c'],"country_Code__c"=>@testDataJSON['Lead'][0]['Country_Code__c'] ,"number_of_Desks__c"=>@testDataJSON['Lead'][0]['Interested_in_Number_of_Desks__c'],"leadSource"=>@testDataJSON['Lead'][0]['LeadSource'],"Generate_Journey__c"=>false,"OwnerId"=>"005F0000003Kmbw"}
          leadInfo['Id'] = @helper.instance_variable_get(:@restForce).createRecord("Lead",leadInfo)
          Helper.addRecordsToDelete("Lead",leadInfo['Id'])
        end
        @pageObject.upload_csv(email, "", @testDataJSON['Campaign'][0]['Name'],true,false,"Lead")[0]
        expect(leadInfo).to_not eql nil
        @helper.addLogs("[Validate ] : Checking Lead owner should be lead owner on campaign")
        @helper.addLogs("[Expected ] : Owner of lead should be Logged in user")
        @pageObject.checkJobStatus
        leadInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Owner.Name, Generate_Journey__c,Owner.id,LeadSource , Lead_Source_Detail__c , Building_Interested_In__c , Building_Interested_Name__c ,Journey_Created_On__c, Locations_Interested__c , Number_of_Full_Time_Employees__c , Interested_in_Number_of_Desks__c , Email , Phone , Company , Name , RecordType.Name , Status , Type__c FROM Lead WHERE id = '#{leadInfo.fetch("Id")}'")[0]
        @helper.addLogs("[Actual ]   : Owner of lead is #{leadInfo.fetch("Owner").fetch("Id")}")
        owner = @pageObject.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
        expect(leadInfo.fetch("Owner").fetch("Id")).to eql owner
        @helper.addLogs("[Result ]   : Owner checked successfully\n")
        @helper.addLogs("[Validate ] : Checking create Journey on lead")
        @helper.addLogs("[Expected ] : Create Journey should #{@testDataJSON['Lead'][0]['Generate_Journey__c']}")
        @helper.addLogs("[Actual ]   : Create Journey on lead is #{leadInfo.fetch("Generate_Journey__c").inspect}")
        expect(leadInfo.fetch("Generate_Journey__c")).to eql false
        insertedJourneyInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,CampaignId__c,Owner.id, Owner.Name,CreatedDate ,Status__c , NMD_Next_Contact_Date__c ,Primary_Email__c , Lead_Source__c , Lead_Source_Detail__c , Primary_Phone__c , Company_Name__c , Building_Interested_In__c , Locations_Interested__c , Interested_in_Number_of_Desks__c , Full_Time_Employees__c, Name   FROM Journey__c WHERE Primary_Email__c = '#{leadInfo.fetch("Email")}'")[0]

        @helper.addLogs("[Validate ] : Checking Journey is created on lead")
        @helper.addLogs("[Expected ] : Journey should not be created")
        @helper.addLogs("[Actual ]   : Journey is created - #{insertedJourneyInfo.nil? ? "No" : "Yes"}")
        expect(insertedJourneyInfo).to eql nil
        @helper.addLogs("[Result ]   : Journey created successfully\n")
        generatedActivityForLead = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Subject , CreatedDate,Status ,Lead_Source__c , Lead_Source_Detail__c,Owner.Name,Locations_Interested__c, Number_of_Full_Time_Employees__c,Interested_in_Number_of_Desks__c,Company__c,WhoId FROM Task WHERE WhoId = '#{leadInfo.fetch('Id')}'")[0]
        @helper.addLogs("[Validate ] : Checking Subject on acitivity")
        @helper.addLogs("[Expected ] : Subject on activity should be inboound lead submission")
        @helper.addLogs("[Actual ]   : Subject on activity  is #{generatedActivityForLead.fetch("Subject")}")
        expect(generatedActivityForLead.fetch("Subject")).to eql "Inbound Lead submission"
        @helper.addLogs("[Result ]   : Activity subject checked successfully")
        @helper.addLogs("[Validate ] : Checking lead source on activity")
        @helper.addLogs("[Expected ] : Lead source on activity should be lead source of created lead")
        @helper.addLogs("[Actual ]   : Lead source on activity is #{generatedActivityForLead.fetch("Lead_Source__c")}")
        expect(generatedActivityForLead.fetch("Lead_Source__c")).to eql "Inbound Call"
        @helper.addLogs("[Result ]   : Activity lead source checked successfully")
        @helper.addLogs("[Validate ] : Checking lead source detail on activity")
        @helper.addLogs("[Expected ] : Lead source detail on activity should be lead source of created lead")
        @helper.addLogs("[Actual ]   : Lead source detail on activity is #{generatedActivityForLead.fetch("Lead_Source__c")}")
        expect(generatedActivityForLead.fetch("Lead_Source_Detail__c")).to eql "Inbound Call Page"
        @helper.addLogs("[Result ]   : Activity lead source detail checked successfully")
        @helper.addLogs("[Validate ] : Checking status on activity")
        @helper.addLogs("[Expected ] : Status on activity should be Open")
        @helper.addLogs("[Actual ]   : Status on activity is #{generatedActivityForLead.fetch("Status")}")
        expect(generatedActivityForLead.fetch("Status")).to eql "Open"
        @helper.addLogs("[Result ]   : Activity assigned to field checked successfully")
        @helper.addLogs("[Validate ] : Checking Company on activity")
        @helper.addLogs("[Expected ] : Company on activity should be #{leadInfo.fetch('Company')}")
        @helper.addLogs("[Actual ]   : Status on activity is #{generatedActivityForLead.fetch("Company__c")}")
        expect(generatedActivityForLead.fetch("Company__c")).to eql leadInfo.fetch('Company')
        @helper.addLogs("[Result ]   : Activity Status field checked successfully")
        @helper.addLogs('Success')
        @helper.postSuccessResult(2622)
      rescue Exception => e
        @helper.addLogs('Error')
        @helper.postFailResult(e, 2622)
        raise e
      end
    end
  end
  context "Kickbox Importer While Insertion of Existing Lead from Kickbox and assign to the Particular Campaign Based on City Criterias." do
    before(:all) do
      @testDataJSON['Campaign'][0]['Lead Owner'] = ''
      @testDataJSON['Campaign'][0]['Email Address'] = 'vikhroliwest@wework.co.in'
      @testDataJSON['Campaign'][0]['City'] = ''
      @campaignId = @helper.instance_variable_get(:@restForce).getRecords("SELECT id FROM Campaign WHERE Name = '#{@testDataJSON['Campaign'][0]['Name']}'")[0]
      @helper.update_campaign(@campaignId.fetch('Id'),nil,@testDataJSON['Campaign'][0]['Email Address'])
    end
    it 'To Check Journey is Created While Importing Existing Lead Where Activity is Not present on Existing Lead, when the Generate Journey on UI is Checked and Generate Journey in CSV is Blank and assign to the Campaign.', :'2645' => 'true' do
      begin
        @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Generate_Journey__c'] = true
        leadInfo = nil
        @helper.getExistingLead(nil,nil,"Susie Romero",true).each do |lead|
          if lead['Tasks'].nil?
            leadInfo = lead
            break;
          end
        end
        leadInfo.nil? ? email = "John.Smith_QAAuto#{rand(9999999999999999)}@example.com" : email = leadInfo.fetch('Email')
        if leadInfo.nil?
          @testDataJSON['Lead'][0]['Email'] = email
          leadInfo = {"lastName"=>@testDataJSON['Lead'][0]['FirstName'],"firstName"=>@testDataJSON['Lead'][0]['LastName'],"website"=>"http://www.Testgmail.com","email"=>email,"phone"=>"8146185355","company"=>@testDataJSON['Lead'][0]['Company'],"company_Size__c"=>@testDataJSON['Lead'][0]['Number_of_Full_Time_Employees__c'],"lead_Source_Detail__c"=>@testDataJSON['Lead'][0]['lead_Source_Detail__c'],"utm_campaign__c"=>"San Francisco - Modifier","utm_content__c"=>"utm contents","utm_medium__c"=>"cpc","utm_source__c"=>"ads-google","utm_term__c"=>"virtual +office +san +francisco","locale__c"=>@testDataJSON['Lead'][0]['Locale__c'],"country_Code__c"=>@testDataJSON['Lead'][0]['Country_Code__c'] ,"number_of_Desks__c"=>@testDataJSON['Lead'][0]['Interested_in_Number_of_Desks__c'],"leadSource"=>@testDataJSON['Lead'][0]['LeadSource'],"Generate_Journey__c"=>false,"OwnerId"=>"005F0000003Kmbw"}
          leadInfo['Id'] = @helper.instance_variable_get(:@restForce).createRecord("Lead",leadInfo)
          Helper.addRecordsToDelete("Lead",leadInfo['Id'])
        end
        @pageObject.upload_csv(email, "", @testDataJSON['Campaign'][0]['Name'],false,false,"Lead")[0]
        expect(leadInfo).to_not eql nil
        @helper.addLogs("[Validate ] : Checking Lead owner should be lead owner on campaign")
        @helper.addLogs("[Expected ] : Owner of lead should be Logged in user")
        @pageObject.checkJobStatus
        leadInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Owner.Name, Generate_Journey__c,Owner.id,LeadSource , Lead_Source_Detail__c , Building_Interested_In__c , Building_Interested_Name__c ,Journey_Created_On__c, Locations_Interested__c , Number_of_Full_Time_Employees__c , Interested_in_Number_of_Desks__c , Email , Phone , Company , Name , RecordType.Name , Status , Type__c FROM Lead WHERE id = '#{leadInfo.fetch("Id")}'")[0]
        @helper.addLogs("[Actual ]   : Owner of lead is #{leadInfo.fetch("Owner").fetch("Id")}")
        owner = @pageObject.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
        expect(leadInfo.fetch("Owner").fetch("Id")).to eql owner
        @helper.addLogs("[Result ]   : Owner checked successfully\n")
        @helper.addLogs("[Validate ] : Checking create Journey on lead")
        @helper.addLogs("[Expected ] : Create Journey should #{@testDataJSON['Lead'][0]['Generate_Journey__c']}")
        @helper.addLogs("[Actual ]   : Create Journey on lead is #{leadInfo.fetch("Generate_Journey__c").inspect}")
        expect(leadInfo.fetch("Generate_Journey__c")).to eql false
        insertedJourneyInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,CampaignId__c,Owner.id, Owner.Name,CreatedDate ,Status__c , NMD_Next_Contact_Date__c ,Primary_Email__c , Lead_Source__c , Lead_Source_Detail__c , Primary_Phone__c , Company_Name__c , Building_Interested_In__c , Locations_Interested__c , Interested_in_Number_of_Desks__c , Full_Time_Employees__c, Name   FROM Journey__c WHERE Primary_Email__c = '#{leadInfo.fetch("Email")}'")[0]
        Helper.addRecordsToDelete("Journey__c", insertedJourneyInfo.fetch('Id'))
        @helper.addLogs("[Validate ] : Checking Journey is created on lead")
        @helper.addLogs("[Expected ] : Journey should be created")
        @helper.addLogs("[Actual ]   : Journey is created with name #{insertedJourneyInfo.fetch("Name")}")
        expect(insertedJourneyInfo).to_not eql nil
        @helper.addLogs("[Result ]   : Journey created successfully\n")
        @helper.addLogs("[Validate ] : Checking Journey owner should be lead owner")
        @helper.addLogs("[Expected ] : Owner of Journey should be owner of lead")
        @helper.addLogs("[Actual ]   : Owner of Journey is #{insertedJourneyInfo.fetch("Owner").fetch("Id")}")
        expect(insertedJourneyInfo.fetch("Owner").fetch("Id")).to match owner
        @helper.addLogs("[Result ]   : Owner checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Campaign on journey")
        @helper.addLogs("[Expected ] : Campaign on Journey should be campaign selected while importing lead")
        @helper.addLogs("[Actual ]   : Campaign on Journey is #{insertedJourneyInfo.fetch("CampaignId__c")}")
        expect(insertedJourneyInfo.fetch("CampaignId__c")).to eql @campaignId.fetch('Id')
        @helper.addLogs("[Result ]   : Campaign checked successfully\n")
        @pageObject.instance_variable_get(:@testDataJSON)['Journey'][0]
        generatedActivityForLead = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Subject , CreatedDate,Status ,Lead_Source__c , Lead_Source_Detail__c,Owner.Name,Locations_Interested__c, Number_of_Full_Time_Employees__c,Interested_in_Number_of_Desks__c,Company__c,WhoId FROM Task WHERE WhoId = '#{leadInfo.fetch('Id')}'")[0]
        @helper.addLogs("[Validate ] : Checking Subject on acitivity")
        @helper.addLogs("[Expected ] : Subject on activity should be inboound lead submission")
        @helper.addLogs("[Actual ]   : Subject on activity  is #{generatedActivityForLead.fetch("Subject")}")
        expect(generatedActivityForLead.fetch("Subject")).to eql "Inbound Lead submission"
        @helper.addLogs("[Result ]   : Activity subject checked successfully")
        @helper.addLogs("[Validate ] : Checking lead source on activity")
        @helper.addLogs("[Expected ] : Lead source on activity should be lead source of created lead")
        @helper.addLogs("[Actual ]   : Lead source on activity is #{generatedActivityForLead.fetch("Lead_Source__c")}")
        expect(generatedActivityForLead.fetch("Lead_Source__c")).to eql "Inbound Call"
        @helper.addLogs("[Result ]   : Activity lead source checked successfully")
        @helper.addLogs("[Validate ] : Checking lead source detail on activity")
        @helper.addLogs("[Expected ] : Lead source detail on activity should be lead source of created lead")
        @helper.addLogs("[Actual ]   : Lead source detail on activity is #{generatedActivityForLead.fetch("Lead_Source__c")}")
        expect(generatedActivityForLead.fetch("Lead_Source_Detail__c")).to eql "Inbound Call Page"
        @helper.addLogs("[Result ]   : Activity lead source detail checked successfully")
        @helper.addLogs("[Validate ] : Checking status on activity")
        @helper.addLogs("[Expected ] : Status on activity should be Open")
        @helper.addLogs("[Actual ]   : Status on activity is #{generatedActivityForLead.fetch("Status")}")
        expect(generatedActivityForLead.fetch("Status")).to eql "Open"
        @helper.addLogs("[Result ]   : Activity assigned to field checked successfully")
        @helper.addLogs("[Validate ] : Checking Company on activity")
        @helper.addLogs("[Expected ] : Company on activity should be #{leadInfo.fetch('Company')}")
        @helper.addLogs("[Actual ]   : Status on activity is #{generatedActivityForLead.fetch("Company__c")}")
        expect(generatedActivityForLead.fetch("Company__c")).to eql leadInfo.fetch('Company')
        @helper.addLogs("[Result ]   : Activity Status field checked successfully")
        @helper.addLogs('Success')
        @helper.postSuccessResult(2636)
      rescue Exception => e
        @helper.addLogs('Error')
        @helper.postFailResult(e, 2636)
        raise e
      end
    end
    it 'To Check Journey is Created While Importing Existing Lead Where Activity is Not present on Existing Lead, when the Generate Journey on UI is UnChecked and Generate Journey in CSV is True and assign to the Campaign.', :'2649' => 'true' do
      begin
        @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Generate_Journey__c'] = true
        leadInfo = nil
        @helper.getExistingLead(nil,nil,"Susie Romero",true).each do |lead|
          if lead['Tasks'].nil?
            leadInfo = lead
            break;
          end
        end
        leadInfo.nil? ? email = "John.Smith_QAAuto#{rand(9999999999999999)}@example.com" : email = leadInfo.fetch('Email')
        if leadInfo.nil?
          @testDataJSON['Lead'][0]['Email'] = email
          @testDataJSON['Lead'][0]['Number_of_Full_Time_Employees__c'] = 10
          @testDataJSON['Lead'][0]['Interested_in_Number_of_Desks__c'] = 5
          @testDataJSON['Lead'][0]['Status'] = "Open"
          @testDataJSON['Lead'][0]['LeadSource'] = "Inbound Call"
          @testDataJSON['Lead'][0]['lead_Source_Detail__c'] = "Inbound Call Page"
          @testDataJSON['Lead'][0]['Locale__c'] = "en-US"
          @testDataJSON['Lead'][0]['Country_Code__c'] = "IN"
          leadInfo = {"lastName"=>@testDataJSON['Lead'][0]['FirstName'],"firstName"=>@testDataJSON['Lead'][0]['LastName'],"website"=>"http://www.Testgmail.com","email"=>email,"phone"=>"8146185355","company"=>@testDataJSON['Lead'][0]['Company'],"company_Size__c"=>@testDataJSON['Lead'][0]['Number_of_Full_Time_Employees__c'],"lead_Source_Detail__c"=>@testDataJSON['Lead'][0]['lead_Source_Detail__c'],"utm_campaign__c"=>"San Francisco - Modifier","utm_content__c"=>"utm contents","utm_medium__c"=>"cpc","utm_source__c"=>"ads-google","utm_term__c"=>"virtual +office +san +francisco","locale__c"=>@testDataJSON['Lead'][0]['Locale__c'],"country_Code__c"=>@testDataJSON['Lead'][0]['Country_Code__c'] ,"number_of_Desks__c"=>@testDataJSON['Lead'][0]['Interested_in_Number_of_Desks__c'],"leadSource"=>@testDataJSON['Lead'][0]['LeadSource'],"Generate_Journey__c"=>false,"OwnerId"=>"005F0000003Kmbw"}
          leadInfo['Id'] = @helper.instance_variable_get(:@restForce).createRecord("Lead",leadInfo)
          Helper.addRecordsToDelete("Lead",leadInfo['Id'])
        end
        @pageObject.upload_csv(email, "TRUE", @testDataJSON['Campaign'][0]['Name'],true,false,"Lead")[0]
        expect(leadInfo).to_not eql nil
        @helper.addLogs("[Validate ] : Checking Lead owner should be lead owner on campaign")
        @helper.addLogs("[Expected ] : Owner of lead should be Logged in user")
        @pageObject.checkJobStatus
        leadInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Owner.Name, Generate_Journey__c,Owner.id,LeadSource , Lead_Source_Detail__c , Building_Interested_In__c , Building_Interested_Name__c ,Journey_Created_On__c, Locations_Interested__c , Number_of_Full_Time_Employees__c , Interested_in_Number_of_Desks__c , Email , Phone , Company , Name , RecordType.Name , Status , Type__c FROM Lead WHERE id = '#{leadInfo.fetch("Id")}'")[0]
        @helper.addLogs("[Actual ]   : Owner of lead is #{leadInfo.fetch("Owner").fetch("Id")}")
        owner = @pageObject.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
        expect(leadInfo.fetch("Owner").fetch("Id")).to eql owner
        @helper.addLogs("[Result ]   : Owner checked successfully\n")
        @helper.addLogs("[Validate ] : Checking create Journey on lead")
        @helper.addLogs("[Expected ] : Create Journey should #{@testDataJSON['Lead'][0]['Generate_Journey__c']}")
        @helper.addLogs("[Actual ]   : Create Journey on lead is #{leadInfo.fetch("Generate_Journey__c").inspect}")
        expect(leadInfo.fetch("Generate_Journey__c")).to eql false
        insertedJourneyInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,CampaignId__c,Owner.id, Owner.Name,CreatedDate ,Status__c , NMD_Next_Contact_Date__c ,Primary_Email__c , Lead_Source__c , Lead_Source_Detail__c , Primary_Phone__c , Company_Name__c , Building_Interested_In__c , Locations_Interested__c , Interested_in_Number_of_Desks__c , Full_Time_Employees__c, Name   FROM Journey__c WHERE Primary_Email__c = '#{leadInfo.fetch("Email")}'")[0]
        Helper.addRecordsToDelete("Journey__c", insertedJourneyInfo.fetch('Id'))
        @helper.addLogs("[Validate ] : Checking Journey is created on lead")
        @helper.addLogs("[Expected ] : Journey should be created")
        @helper.addLogs("[Actual ]   : Journey is created with name #{insertedJourneyInfo.fetch("Name")}")
        expect(insertedJourneyInfo).to_not eql nil
        Helper.addRecordsToDelete("Journey__c", insertedJourneyInfo.fetch('Id'))
        @helper.addLogs("[Result ]   : Journey created successfully\n")
        @helper.addLogs("[Validate ] : Checking Journey owner should be lead owner")
        @helper.addLogs("[Expected ] : Owner of Journey should be owner of lead")
        @helper.addLogs("[Actual ]   : Owner of Journey is #{insertedJourneyInfo.fetch("Owner").fetch("Id")}")
        expect(insertedJourneyInfo.fetch("Owner").fetch("Id")).to match owner
        @helper.addLogs("[Result ]   : Owner checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Campaign on journey")
        @helper.addLogs("[Expected ] : Campaign on Journey should be campaign selected while importing lead")
        @helper.addLogs("[Actual ]   : Campaign on Journey is #{insertedJourneyInfo.fetch("CampaignId__c")}")
        expect(insertedJourneyInfo.fetch("CampaignId__c")).to eql @campaignId.fetch('Id')
        @helper.addLogs("[Result ]   : Campaign checked successfully\n")
        @pageObject.instance_variable_get(:@testDataJSON)['Journey'][0]
        generatedActivityForLead = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Subject , CreatedDate,Status ,Lead_Source__c , Lead_Source_Detail__c,Owner.Name,Locations_Interested__c, Number_of_Full_Time_Employees__c,Interested_in_Number_of_Desks__c,Company__c,WhoId FROM Task WHERE WhoId = '#{leadInfo.fetch('Id')}'")[0]
        @helper.addLogs("[Validate ] : Checking Subject on acitivity")
        @helper.addLogs("[Expected ] : Subject on activity should be inboound lead submission")
        @helper.addLogs("[Actual ]   : Subject on activity  is #{generatedActivityForLead.fetch("Subject")}")
        expect(generatedActivityForLead.fetch("Subject")).to eql "Inbound Lead submission"
        @helper.addLogs("[Result ]   : Activity subject checked successfully")
        @helper.addLogs("[Validate ] : Checking lead source on activity")
        @helper.addLogs("[Expected ] : Lead source on activity should be lead source of created lead")
        @helper.addLogs("[Actual ]   : Lead source on activity is #{generatedActivityForLead.fetch("Lead_Source__c")}")
        expect(generatedActivityForLead.fetch("Lead_Source__c")).to eql "Inbound Call"
        @helper.addLogs("[Result ]   : Activity lead source checked successfully")
        @helper.addLogs("[Validate ] : Checking lead source detail on activity")
        @helper.addLogs("[Expected ] : Lead source detail on activity should be lead source of created lead")
        @helper.addLogs("[Actual ]   : Lead source detail on activity is #{generatedActivityForLead.fetch("Lead_Source__c")}")
        expect(generatedActivityForLead.fetch("Lead_Source_Detail__c")).to eql "Inbound Call Page"
        @helper.addLogs("[Result ]   : Activity lead source detail checked successfully")
        @helper.addLogs("[Validate ] : Checking status on activity")
        @helper.addLogs("[Expected ] : Status on activity should be Open")
        @helper.addLogs("[Actual ]   : Status on activity is #{generatedActivityForLead.fetch("Status")}")
        expect(generatedActivityForLead.fetch("Status")).to eql "Open"
        @helper.addLogs("[Result ]   : Activity assigned to field checked successfully")
        @helper.addLogs("[Validate ] : Checking Company on activity")
        @helper.addLogs("[Expected ] : Company on activity should be #{leadInfo.fetch('Company')}")
        @helper.addLogs("[Actual ]   : Status on activity is #{generatedActivityForLead.fetch("Company__c")}")
        expect(generatedActivityForLead.fetch("Company__c")).to eql leadInfo.fetch('Company')
        @helper.addLogs("[Result ]   : Activity Status field checked successfully")
        @helper.addLogs('Success')
        @helper.postSuccessResult(2637)
      rescue Exception => e
        @helper.addLogs('Error')
        @helper.postFailResult(e, 2637)
        raise e
      end
    end
    it 'To Check Journey is Created While Importing Existing Lead Which is Owned By Susie Romero Where Activity is present on Existing Lead, when the Generate Journey on UI is Checked and Generate Journey in CSV is Blank and assign to the Campaign.', :'2653' => 'true' do
      begin
        @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Generate_Journey__c'] = true
        leadInfo = nil
        @helper.getExistingLead(nil,nil,"Susie Romero",true).each do |lead|
          if lead['Tasks'].nil?
            leadInfo = lead
            break;
          end
        end
        leadInfo.nil? ? email = "John.Smith_QAAuto#{rand(9999999999999999)}@example.com" : email = leadInfo.fetch('Email')
        if leadInfo.nil?
          @testDataJSON['Lead'][0]['Email'] = email
          @testDataJSON['Lead'][0]['Number_of_Full_Time_Employees__c'] = 10
          @testDataJSON['Lead'][0]['Interested_in_Number_of_Desks__c'] = 5
          @testDataJSON['Lead'][0]['Status'] = "Open"
          @testDataJSON['Lead'][0]['LeadSource'] = "Inbound Call"
          @testDataJSON['Lead'][0]['lead_Source_Detail__c'] = "Inbound Call Page"
          @testDataJSON['Lead'][0]['Locale__c'] = "en-US"
          @testDataJSON['Lead'][0]['Country_Code__c'] = "IN"
          leadInfo = {"lastName"=>@testDataJSON['Lead'][0]['FirstName'],"firstName"=>@testDataJSON['Lead'][0]['LastName'],"website"=>"http://www.Testgmail.com","email"=>email,"phone"=>"8146185355","company"=>@testDataJSON['Lead'][0]['Company'],"company_Size__c"=>@testDataJSON['Lead'][0]['Number_of_Full_Time_Employees__c'],"lead_Source_Detail__c"=>@testDataJSON['Lead'][0]['lead_Source_Detail__c'],"utm_campaign__c"=>"San Francisco - Modifier","utm_content__c"=>"utm contents","utm_medium__c"=>"cpc","utm_source__c"=>"ads-google","utm_term__c"=>"virtual +office +san +francisco","locale__c"=>@testDataJSON['Lead'][0]['Locale__c'],"country_Code__c"=>@testDataJSON['Lead'][0]['Country_Code__c'] ,"number_of_Desks__c"=>@testDataJSON['Lead'][0]['Interested_in_Number_of_Desks__c'],"leadSource"=>@testDataJSON['Lead'][0]['LeadSource'],"Generate_Journey__c"=>false,"OwnerId"=>"005F0000003Kmbw"}
          leadInfo['Id'] = @helper.instance_variable_get(:@restForce).createRecord("Lead",leadInfo)
          Helper.addRecordsToDelete("Lead",leadInfo['Id'])
        end
        @pageObject.upload_csv(email, "FALSE", @testDataJSON['Campaign'][0]['Name'],false,false,"Lead")[0]
        expect(leadInfo).to_not eql nil
        @helper.addLogs("[Validate ] : Checking Lead owner should be lead owner on campaign")
        @helper.addLogs("[Expected ] : Owner of lead should be Logged in user")
        @pageObject.checkJobStatus
        leadInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Owner.Name, Generate_Journey__c,Owner.id,LeadSource , Lead_Source_Detail__c , Building_Interested_In__c , Building_Interested_Name__c ,Journey_Created_On__c, Locations_Interested__c , Number_of_Full_Time_Employees__c , Interested_in_Number_of_Desks__c , Email , Phone , Company , Name , RecordType.Name , Status , Type__c FROM Lead WHERE id = '#{leadInfo.fetch("Id")}'")[0]
        @helper.addLogs("[Actual ]   : Owner of lead is #{leadInfo.fetch("Owner").fetch("Id")}")
        owner = @pageObject.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
        expect(leadInfo.fetch("Owner").fetch("Id")).to eql owner
        @helper.addLogs("[Result ]   : Owner checked successfully\n")
        @helper.addLogs("[Validate ] : Checking create Journey on lead")
        @helper.addLogs("[Expected ] : Create Journey should #{@testDataJSON['Lead'][0]['Generate_Journey__c']}")
        @helper.addLogs("[Actual ]   : Create Journey on lead is #{leadInfo.fetch("Generate_Journey__c").inspect}")
        expect(leadInfo.fetch("Generate_Journey__c")).to eql false
        insertedJourneyInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,CampaignId__c,Owner.id, Owner.Name,CreatedDate ,Status__c , NMD_Next_Contact_Date__c ,Primary_Email__c , Lead_Source__c , Lead_Source_Detail__c , Primary_Phone__c , Company_Name__c , Building_Interested_In__c , Locations_Interested__c , Interested_in_Number_of_Desks__c , Full_Time_Employees__c, Name   FROM Journey__c WHERE Primary_Email__c = '#{leadInfo.fetch("Email")}'")[0]
        Helper.addRecordsToDelete("Journey__c", insertedJourneyInfo.fetch('Id'))
        @helper.addLogs("[Validate ] : Checking Journey is created on lead")
        @helper.addLogs("[Expected ] : Journey should be created")
        @helper.addLogs("[Actual ]   : Journey is created with name #{insertedJourneyInfo.fetch("Name")}")
        expect(insertedJourneyInfo).to_not eql nil
        Helper.addRecordsToDelete("Journey__c", insertedJourneyInfo.fetch('Id'))
        @helper.addLogs("[Result ]   : Journey created successfully\n")
        @helper.addLogs("[Validate ] : Checking Journey owner should be lead owner")
        @helper.addLogs("[Expected ] : Owner of Journey should be owner of lead")
        @helper.addLogs("[Actual ]   : Owner of Journey is #{insertedJourneyInfo.fetch("Owner").fetch("Id")}")
        expect(insertedJourneyInfo.fetch("Owner").fetch("Id")).to match owner
        @helper.addLogs("[Result ]   : Owner checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Campaign on journey")
        @helper.addLogs("[Expected ] : Campaign on Journey should be campaign selected while importing lead")
        @helper.addLogs("[Actual ]   : Campaign on Journey is #{insertedJourneyInfo.fetch("CampaignId__c")}")
        expect(insertedJourneyInfo.fetch("CampaignId__c")).to eql @campaignId.fetch('Id')
        @helper.addLogs("[Result ]   : Campaign checked successfully\n")
        @pageObject.instance_variable_get(:@testDataJSON)['Journey'][0]
        generatedActivityForLead = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Subject , CreatedDate,Status ,Lead_Source__c , Lead_Source_Detail__c,Owner.Name,Locations_Interested__c, Number_of_Full_Time_Employees__c,Interested_in_Number_of_Desks__c,Company__c,WhoId FROM Task WHERE WhoId = '#{leadInfo.fetch('Id')}'")[0]
        @helper.addLogs("[Validate ] : Checking Subject on acitivity")
        @helper.addLogs("[Expected ] : Subject on activity should be inboound lead submission")
        @helper.addLogs("[Actual ]   : Subject on activity  is #{generatedActivityForLead.fetch("Subject")}")
        expect(generatedActivityForLead.fetch("Subject")).to eql "Inbound Lead submission"
        @helper.addLogs("[Result ]   : Activity subject checked successfully")
        @helper.addLogs("[Validate ] : Checking lead source on activity")
        @helper.addLogs("[Expected ] : Lead source on activity should be lead source of created lead")
        @helper.addLogs("[Actual ]   : Lead source on activity is #{generatedActivityForLead.fetch("Lead_Source__c")}")
        expect(generatedActivityForLead.fetch("Lead_Source__c")).to eql "Inbound Call"
        @helper.addLogs("[Result ]   : Activity lead source checked successfully")
        @helper.addLogs("[Validate ] : Checking lead source detail on activity")
        @helper.addLogs("[Expected ] : Lead source detail on activity should be lead source of created lead")
        @helper.addLogs("[Actual ]   : Lead source detail on activity is #{generatedActivityForLead.fetch("Lead_Source__c")}")
        expect(generatedActivityForLead.fetch("Lead_Source_Detail__c")).to eql "Inbound Call Page"
        @helper.addLogs("[Result ]   : Activity lead source detail checked successfully")
        @helper.addLogs("[Validate ] : Checking status on activity")
        @helper.addLogs("[Expected ] : Status on activity should be Open")
        @helper.addLogs("[Actual ]   : Status on activity is #{generatedActivityForLead.fetch("Status")}")
        expect(generatedActivityForLead.fetch("Status")).to eql "Open"
        @helper.addLogs("[Result ]   : Activity assigned to field checked successfully")
        @helper.addLogs("[Validate ] : Checking Company on activity")
        @helper.addLogs("[Expected ] : Company on activity should be #{leadInfo.fetch('Company')}")
        @helper.addLogs("[Actual ]   : Status on activity is #{generatedActivityForLead.fetch("Company__c")}")
        expect(generatedActivityForLead.fetch("Company__c")).to eql leadInfo.fetch('Company')
        @helper.addLogs("[Result ]   : Activity Status field checked successfully")
        @helper.addLogs('Success')
        @helper.postSuccessResult(2639)
      rescue Exception => e
        @helper.addLogs('Error')
        @helper.postFailResult(e, 2639)
        raise e
      end
    end
    it 'To Check Journey Created for Existing Lead Owned By Susie Romero Where Activity is not present and which is assigned to the particular Campaign, When the generate Journey on UI is Checked & Generate Journey in CSV is Blank & inserted into diff Campgn', :'2655' => 'true' do
      begin
        @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Generate_Journey__c'] = true
        leadInfo = nil
        @helper.getExistingLead(nil,nil,"Susie Romero",true).each do |lead|
          if lead['Tasks'].nil?
            leadInfo = lead
            break;
          end
        end
        leadInfo.nil? ? email = "John.Smith_QAAuto#{rand(9999999999999999)}@example.com" : email = leadInfo.fetch('Email')
        if leadInfo.nil?
          @testDataJSON['Lead'][0]['Email'] = email
          @testDataJSON['Lead'][0]['Number_of_Full_Time_Employees__c'] = 10
          @testDataJSON['Lead'][0]['Interested_in_Number_of_Desks__c'] = 5
          @testDataJSON['Lead'][0]['Status'] = "Open"
          @testDataJSON['Lead'][0]['LeadSource'] = "Inbound Call"
          @testDataJSON['Lead'][0]['lead_Source_Detail__c'] = "Inbound Call Page"
          @testDataJSON['Lead'][0]['Locale__c'] = "en-US"
          @testDataJSON['Lead'][0]['Country_Code__c'] = "IN"
          leadInfo = {"lastName"=>@testDataJSON['Lead'][0]['FirstName'],"firstName"=>@testDataJSON['Lead'][0]['LastName'],"website"=>"http://www.Testgmail.com","email"=>email,"phone"=>"8146185355","company"=>@testDataJSON['Lead'][0]['Company'],"company_Size__c"=>@testDataJSON['Lead'][0]['Number_of_Full_Time_Employees__c'],"lead_Source_Detail__c"=>@testDataJSON['Lead'][0]['lead_Source_Detail__c'],"utm_campaign__c"=>"San Francisco - Modifier","utm_content__c"=>"utm contents","utm_medium__c"=>"cpc","utm_source__c"=>"ads-google","utm_term__c"=>"virtual +office +san +francisco","locale__c"=>@testDataJSON['Lead'][0]['Locale__c'],"country_Code__c"=>@testDataJSON['Lead'][0]['Country_Code__c'] ,"number_of_Desks__c"=>@testDataJSON['Lead'][0]['Interested_in_Number_of_Desks__c'],"leadSource"=>@testDataJSON['Lead'][0]['LeadSource'],"Generate_Journey__c"=>false,"OwnerId"=>"005F0000003Kmbw"}
          leadInfo['Id'] = @helper.instance_variable_get(:@restForce).createRecord("Lead",leadInfo)
          Helper.addRecordsToDelete("Lead",leadInfo['Id'])
        end
        @pageObject.upload_csv(email, "", @testDataJSON['Campaign'][0]['Name'],true,false,"Lead")[0]
        expect(leadInfo).to_not eql nil
        @helper.addLogs("[Validate ] : Checking Lead owner should be lead owner on campaign")
        @helper.addLogs("[Expected ] : Owner of lead should be Logged in user")
        @pageObject.checkJobStatus
        leadInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Owner.Name, Generate_Journey__c,Owner.id,LeadSource , Lead_Source_Detail__c , Building_Interested_In__c , Building_Interested_Name__c ,Journey_Created_On__c, Locations_Interested__c , Number_of_Full_Time_Employees__c , Interested_in_Number_of_Desks__c , Email , Phone , Company , Name , RecordType.Name , Status , Type__c FROM Lead WHERE id = '#{leadInfo.fetch("Id")}'")[0]
        @helper.addLogs("[Actual ]   : Owner of lead is #{leadInfo.fetch("Owner").fetch("Id")}")
        owner = @pageObject.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
        expect(leadInfo.fetch("Owner").fetch("Id")).to eql owner
        @helper.addLogs("[Result ]   : Owner checked successfully\n")
        @helper.addLogs("[Validate ] : Checking create Journey on lead")
        @helper.addLogs("[Expected ] : Create Journey should #{@testDataJSON['Lead'][0]['Generate_Journey__c']}")
        @helper.addLogs("[Actual ]   : Create Journey on lead is #{leadInfo.fetch("Generate_Journey__c").inspect}")
        expect(leadInfo.fetch("Generate_Journey__c")).to eql false
        insertedJourneyInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,CampaignId__c,Owner.id, Owner.Name,CreatedDate ,Status__c , NMD_Next_Contact_Date__c ,Primary_Email__c , Lead_Source__c , Lead_Source_Detail__c , Primary_Phone__c , Company_Name__c , Building_Interested_In__c , Locations_Interested__c , Interested_in_Number_of_Desks__c , Full_Time_Employees__c, Name   FROM Journey__c WHERE Primary_Email__c = '#{leadInfo.fetch("Email")}'")[0]
        Helper.addRecordsToDelete("Journey__c", insertedJourneyInfo.fetch('Id'))
        @helper.addLogs("[Validate ] : Checking Journey is created on lead")
        @helper.addLogs("[Expected ] : Journey should be created")
        @helper.addLogs("[Actual ]   : Journey is created with name #{insertedJourneyInfo.fetch("Name")}")
        expect(insertedJourneyInfo).to_not eql nil
        Helper.addRecordsToDelete("Journey__c", insertedJourneyInfo.fetch('Id'))
        @helper.addLogs("[Result ]   : Journey created successfully\n")
        @helper.addLogs("[Validate ] : Checking Journey owner should be lead owner")
        @helper.addLogs("[Expected ] : Owner of Journey should be owner of lead")
        @helper.addLogs("[Actual ]   : Owner of Journey is #{insertedJourneyInfo.fetch("Owner").fetch("Id")}")
        expect(insertedJourneyInfo.fetch("Owner").fetch("Id")).to match owner
        @helper.addLogs("[Result ]   : Owner checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Campaign on journey")
        @helper.addLogs("[Expected ] : Campaign on Journey should be campaign selected while importing lead")
        @helper.addLogs("[Actual ]   : Campaign on Journey is #{insertedJourneyInfo.fetch("CampaignId__c")}")
        expect(insertedJourneyInfo.fetch("CampaignId__c")).to eql @campaignId.fetch('Id')
        @helper.addLogs("[Result ]   : Campaign checked successfully\n")
        @pageObject.instance_variable_get(:@testDataJSON)['Journey'][0]
        generatedActivityForLead = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Subject , CreatedDate,Status ,Lead_Source__c , Lead_Source_Detail__c,Owner.Name,Locations_Interested__c, Number_of_Full_Time_Employees__c,Interested_in_Number_of_Desks__c,Company__c,WhoId FROM Task WHERE WhoId = '#{leadInfo.fetch('Id')}'")[0]
        @helper.addLogs("[Validate ] : Checking Subject on acitivity")
        @helper.addLogs("[Expected ] : Subject on activity should be inboound lead submission")
        @helper.addLogs("[Actual ]   : Subject on activity  is #{generatedActivityForLead.fetch("Subject")}")
        expect(generatedActivityForLead.fetch("Subject")).to eql "Inbound Lead submission"
        @helper.addLogs("[Result ]   : Activity subject checked successfully")
        @helper.addLogs("[Validate ] : Checking lead source on activity")
        @helper.addLogs("[Expected ] : Lead source on activity should be lead source of created lead")
        @helper.addLogs("[Actual ]   : Lead source on activity is #{generatedActivityForLead.fetch("Lead_Source__c")}")
        expect(generatedActivityForLead.fetch("Lead_Source__c")).to eql "Inbound Call"
        @helper.addLogs("[Result ]   : Activity lead source checked successfully")
        @helper.addLogs("[Validate ] : Checking lead source detail on activity")
        @helper.addLogs("[Expected ] : Lead source detail on activity should be lead source of created lead")
        @helper.addLogs("[Actual ]   : Lead source detail on activity is #{generatedActivityForLead.fetch("Lead_Source__c")}")
        expect(generatedActivityForLead.fetch("Lead_Source_Detail__c")).to eql "Inbound Call Page"
        @helper.addLogs("[Result ]   : Activity lead source detail checked successfully")
        @helper.addLogs("[Validate ] : Checking status on activity")
        @helper.addLogs("[Expected ] : Status on activity should be Open")
        @helper.addLogs("[Actual ]   : Status on activity is #{generatedActivityForLead.fetch("Status")}")
        expect(generatedActivityForLead.fetch("Status")).to eql "Open"
        @helper.addLogs("[Result ]   : Activity assigned to field checked successfully")
        @helper.addLogs("[Validate ] : Checking Company on activity")
        @helper.addLogs("[Expected ] : Company on activity should be #{leadInfo.fetch('Company')}")
        @helper.addLogs("[Actual ]   : Status on activity is #{generatedActivityForLead.fetch("Company__c")}")
        expect(generatedActivityForLead.fetch("Company__c")).to eql leadInfo.fetch('Company')
        @helper.addLogs("[Result ]   : Activity Status field checked successfully")
        @helper.addLogs('Success')
        @helper.postSuccessResult(2578)
      rescue Exception => e
        @helper.addLogs('Error')
        @helper.postFailResult(e, 2578)
        raise e
      end
    end
    it 'To Check Journey not Created While Importing Existing Lead Which is Owned By Susie Romero Where Activity is Not present on Existing Lead, when the Generate Journey on UI is UnChecked and Generate Journey in CSV is false and assign to the Campaign.', :'2651' => 'true' do
      begin
        @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Generate_Journey__c'] = true
        leadInfo = nil
        @helper.getExistingLead(nil,nil,"Susie Romero",true).each do |lead|
          if lead['Tasks'].nil?
            leadInfo = lead
            break;
          end
        end
        leadInfo.nil? ? email = "John.Smith_QAAuto#{rand(9999999999999999)}@example.com" : email = leadInfo.fetch('Email')
        if leadInfo.nil?
          @testDataJSON['Lead'][0]['Email'] = email
          @testDataJSON['Lead'][0]['Number_of_Full_Time_Employees__c'] = 10
          @testDataJSON['Lead'][0]['Interested_in_Number_of_Desks__c'] = 5
          @testDataJSON['Lead'][0]['Status'] = "Open"
          @testDataJSON['Lead'][0]['LeadSource'] = "Inbound Call"
          @testDataJSON['Lead'][0]['lead_Source_Detail__c'] = "Inbound Call Page"
          @testDataJSON['Lead'][0]['Locale__c'] = "en-US"
          @testDataJSON['Lead'][0]['Country_Code__c'] = "IN"
          leadInfo = {"lastName"=>@testDataJSON['Lead'][0]['FirstName'],"firstName"=>@testDataJSON['Lead'][0]['LastName'],"website"=>"http://www.Testgmail.com","email"=>email,"phone"=>"8146185355","company"=>@testDataJSON['Lead'][0]['Company'],"company_Size__c"=>@testDataJSON['Lead'][0]['Number_of_Full_Time_Employees__c'],"lead_Source_Detail__c"=>@testDataJSON['Lead'][0]['lead_Source_Detail__c'],"utm_campaign__c"=>"San Francisco - Modifier","utm_content__c"=>"utm contents","utm_medium__c"=>"cpc","utm_source__c"=>"ads-google","utm_term__c"=>"virtual +office +san +francisco","locale__c"=>@testDataJSON['Lead'][0]['Locale__c'],"country_Code__c"=>@testDataJSON['Lead'][0]['Country_Code__c'] ,"number_of_Desks__c"=>@testDataJSON['Lead'][0]['Interested_in_Number_of_Desks__c'],"leadSource"=>@testDataJSON['Lead'][0]['LeadSource'],"Generate_Journey__c"=>false,"OwnerId"=>"005F0000003Kmbw"}
          leadInfo['Id'] = @helper.instance_variable_get(:@restForce).createRecord("Lead",leadInfo)
          Helper.addRecordsToDelete("Lead",leadInfo['Id'])
        end
        @pageObject.upload_csv(email, "", @testDataJSON['Campaign'][0]['Name'],true,false,"Lead")[0]
        expect(leadInfo).to_not eql nil
        @helper.addLogs("[Validate ] : Checking Lead owner should be lead owner on campaign")
        @helper.addLogs("[Expected ] : Owner of lead should be Logged in user")
        @pageObject.checkJobStatus
        leadInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Owner.Name, Generate_Journey__c,Owner.id,LeadSource , Lead_Source_Detail__c , Building_Interested_In__c , Building_Interested_Name__c ,Journey_Created_On__c, Locations_Interested__c , Number_of_Full_Time_Employees__c , Interested_in_Number_of_Desks__c , Email , Phone , Company , Name , RecordType.Name , Status , Type__c FROM Lead WHERE id = '#{leadInfo.fetch("Id")}'")[0]
        @helper.addLogs("[Actual ]   : Owner of lead is #{leadInfo.fetch("Owner").fetch("Id")}")
        owner = @pageObject.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
        expect(leadInfo.fetch("Owner").fetch("Id")).to eql owner
        @helper.addLogs("[Result ]   : Owner checked successfully\n")
        @helper.addLogs("[Validate ] : Checking create Journey on lead")
        @helper.addLogs("[Expected ] : Create Journey should #{@testDataJSON['Lead'][0]['Generate_Journey__c']}")
        @helper.addLogs("[Actual ]   : Create Journey on lead is #{leadInfo.fetch("Generate_Journey__c").inspect}")
        expect(leadInfo.fetch("Generate_Journey__c")).to eql false
        insertedJourneyInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,CampaignId__c,Owner.id, Owner.Name,CreatedDate ,Status__c , NMD_Next_Contact_Date__c ,Primary_Email__c , Lead_Source__c , Lead_Source_Detail__c , Primary_Phone__c , Company_Name__c , Building_Interested_In__c , Locations_Interested__c , Interested_in_Number_of_Desks__c , Full_Time_Employees__c, Name   FROM Journey__c WHERE Primary_Email__c = '#{leadInfo.fetch("Email")}'")[0]

        @helper.addLogs("[Validate ] : Checking Journey is created on lead")
        @helper.addLogs("[Expected ] : Journey should not be created")
        @helper.addLogs("[Actual ]   : Journey is created - #{insertedJourneyInfo.nil? ? "No" : "Yes"}")
        expect(insertedJourneyInfo).to eql nil
        @helper.addLogs("[Result ]   : Journey created successfully\n")
        generatedActivityForLead = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Subject , CreatedDate,Status ,Lead_Source__c , Lead_Source_Detail__c,Owner.Name,Locations_Interested__c, Number_of_Full_Time_Employees__c,Interested_in_Number_of_Desks__c,Company__c,WhoId FROM Task WHERE WhoId = '#{leadInfo.fetch('Id')}'")[0]
        @helper.addLogs("[Validate ] : Checking Subject on acitivity")
        @helper.addLogs("[Expected ] : Subject on activity should be inboound lead submission")
        @helper.addLogs("[Actual ]   : Subject on activity  is #{generatedActivityForLead.fetch("Subject")}")
        expect(generatedActivityForLead.fetch("Subject")).to eql "Inbound Lead submission"
        @helper.addLogs("[Result ]   : Activity subject checked successfully")
        @helper.addLogs("[Validate ] : Checking lead source on activity")
        @helper.addLogs("[Expected ] : Lead source on activity should be lead source of created lead")
        @helper.addLogs("[Actual ]   : Lead source on activity is #{generatedActivityForLead.fetch("Lead_Source__c")}")
        expect(generatedActivityForLead.fetch("Lead_Source__c")).to eql "Inbound Call"
        @helper.addLogs("[Result ]   : Activity lead source checked successfully")
        @helper.addLogs("[Validate ] : Checking lead source detail on activity")
        @helper.addLogs("[Expected ] : Lead source detail on activity should be lead source of created lead")
        @helper.addLogs("[Actual ]   : Lead source detail on activity is #{generatedActivityForLead.fetch("Lead_Source__c")}")
        expect(generatedActivityForLead.fetch("Lead_Source_Detail__c")).to eql "Inbound Call Page"
        @helper.addLogs("[Result ]   : Activity lead source detail checked successfully")
        @helper.addLogs("[Validate ] : Checking status on activity")
        @helper.addLogs("[Expected ] : Status on activity should be Open")
        @helper.addLogs("[Actual ]   : Status on activity is #{generatedActivityForLead.fetch("Status")}")
        expect(generatedActivityForLead.fetch("Status")).to eql "Open"
        @helper.addLogs("[Result ]   : Activity assigned to field checked successfully")
        @helper.addLogs("[Validate ] : Checking Company on activity")
        @helper.addLogs("[Expected ] : Company on activity should be #{leadInfo.fetch('Company')}")
        @helper.addLogs("[Actual ]   : Status on activity is #{generatedActivityForLead.fetch("Company__c")}")
        expect(generatedActivityForLead.fetch("Company__c")).to eql leadInfo.fetch('Company')
        @helper.addLogs("[Result ]   : Activity Status field checked successfully")
        @helper.addLogs('Success')
        @helper.postSuccessResult(2622)
      rescue Exception => e
        @helper.addLogs('Error')
        @helper.postFailResult(e, 2622)
        raise e
      end
    end
  end

  context "Kickbox Importer While Insertion of Existing Lead from Kickbox and assign to the Particular Campaign if No criteria is Matched" do
    before(:all) do
      @testDataJSON['Campaign'][0]['Lead Owner'] = ''
      @testDataJSON['Campaign'][0]['Email Address'] = ''
      @testDataJSON['Campaign'][0]['City'] = ''
      @campaignId = @helper.instance_variable_get(:@restForce).getRecords("SELECT id FROM Campaign WHERE Name = '#{@testDataJSON['Campaign'][0]['Name']}'")[0]
      @helper.update_campaign(@campaignId.fetch('Id'), @testDataJSON['Campaign'][0]['Lead Owner'])
    end
    it 'To Check Journey is Created While Importing Existing Lead  Which is Owned By Susie Romero Where Activity is Not present on Existing Lead, when the Generate Journey on UI is Checked and Generate Journey in CSV is Blank and assign to the Campaign.', :'2657' => 'true' do
      begin
        @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Generate_Journey__c'] = true
        leadInfo = nil
        @helper.getExistingLead(nil,nil,"Susie Romero",true).each do |lead|
          if lead['Tasks'].nil?
            leadInfo = lead
            break;
          end
        end
        leadInfo.nil? ? email = "John.Smith_QAAuto#{rand(9999999999999999)}@example.com" : email = leadInfo.fetch('Email')
        if leadInfo.nil?
          @testDataJSON['Lead'][0]['Email'] = email
          @testDataJSON['Lead'][0]['Number_of_Full_Time_Employees__c'] = 10
          @testDataJSON['Lead'][0]['Interested_in_Number_of_Desks__c'] = 5
          @testDataJSON['Lead'][0]['Status'] = "Open"
          @testDataJSON['Lead'][0]['LeadSource'] = "Inbound Call"
          @testDataJSON['Lead'][0]['lead_Source_Detail__c'] = "Inbound Call Page"
          @testDataJSON['Lead'][0]['Locale__c'] = "en-US"
          @testDataJSON['Lead'][0]['Country_Code__c'] = "IN"
          @testDataJSON['Lead'][0]['Generate_Journey__c'] = false
          leadInfo = {"lastName"=>@testDataJSON['Lead'][0]['FirstName'],"firstName"=>@testDataJSON['Lead'][0]['LastName'],"website"=>"http://www.Testgmail.com","email"=>email,"phone"=>"8146185355","company"=>@testDataJSON['Lead'][0]['Company'],"company_Size__c"=>@testDataJSON['Lead'][0]['Number_of_Full_Time_Employees__c'],"lead_Source_Detail__c"=>@testDataJSON['Lead'][0]['lead_Source_Detail__c'],"utm_campaign__c"=>"San Francisco - Modifier","utm_content__c"=>"utm contents","utm_medium__c"=>"cpc","utm_source__c"=>"ads-google","utm_term__c"=>"virtual +office +san +francisco","locale__c"=>@testDataJSON['Lead'][0]['Locale__c'],"country_Code__c"=>@testDataJSON['Lead'][0]['Country_Code__c'] ,"number_of_Desks__c"=>@testDataJSON['Lead'][0]['Interested_in_Number_of_Desks__c'],"leadSource"=>@testDataJSON['Lead'][0]['LeadSource'],"Generate_Journey__c"=>false,"OwnerId"=>"005F0000003Kmbw"}
          leadInfo['Id'] = @helper.instance_variable_get(:@restForce).createRecord("Lead",leadInfo)
          Helper.addRecordsToDelete("Lead",leadInfo['Id'])
        end
        @pageObject.upload_csv(email, "", @testDataJSON['Campaign'][0]['Name'],false,false,"Lead")[0]
        expect(leadInfo).to_not eql nil
        @helper.addLogs("[Validate ] : Checking Lead owner should be lead owner on campaign")
        @helper.addLogs("[Expected ] : Owner of lead should be according to campaign assignment")
        @pageObject.checkJobStatus
        leadInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Owner.Name, Generate_Journey__c,Owner.id,LeadSource , Lead_Source_Detail__c , Building_Interested_In__c , Building_Interested_Name__c ,Journey_Created_On__c, Locations_Interested__c , Number_of_Full_Time_Employees__c , Interested_in_Number_of_Desks__c , Email , Phone , Company , Name , RecordType.Name , Status , Type__c FROM Lead WHERE id = '#{leadInfo.fetch("Id")}'")[0]
        @helper.addLogs("[Actual ]   : Owner of lead is #{leadInfo.fetch("Owner").fetch("Id")}")
        owner = @pageObject.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
        expect(leadInfo.fetch("Owner").fetch("Id")).to eql owner
        @helper.addLogs("[Result ]   : Owner checked successfully\n")
        @helper.addLogs("[Validate ] : Checking create Journey on lead")
        @helper.addLogs("[Expected ] : Create Journey should #{@testDataJSON['Lead'][0]['Generate_Journey__c']}")
        @helper.addLogs("[Actual ]   : Create Journey on lead is #{leadInfo.fetch("Generate_Journey__c").inspect}")
        expect(leadInfo.fetch("Generate_Journey__c")).to eql false
        insertedJourneyInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,CampaignId__c,Owner.id, Owner.Name,CreatedDate ,Status__c , NMD_Next_Contact_Date__c ,Primary_Email__c , Lead_Source__c , Lead_Source_Detail__c , Primary_Phone__c , Company_Name__c , Building_Interested_In__c , Locations_Interested__c , Interested_in_Number_of_Desks__c , Full_Time_Employees__c, Name   FROM Journey__c WHERE Primary_Email__c = '#{leadInfo.fetch("Email")}'")[0]
        Helper.addRecordsToDelete("Journey__c", insertedJourneyInfo.fetch('Id'))
        @helper.addLogs("[Validate ] : Checking Journey is created on lead")
        @helper.addLogs("[Expected ] : Journey should be created")
        @helper.addLogs("[Actual ]   : Journey is created with name #{insertedJourneyInfo.fetch("Name")}")
        expect(insertedJourneyInfo).to_not eql nil
        Helper.addRecordsToDelete("Journey__c", insertedJourneyInfo.fetch('Id'))
        @helper.addLogs("[Result ]   : Journey created successfully\n")
        @helper.addLogs("[Validate ] : Checking Journey owner should be lead owner")
        @helper.addLogs("[Expected ] : Owner of Journey should be owner of lead")
        @helper.addLogs("[Actual ]   : Owner of Journey is #{insertedJourneyInfo.fetch("Owner").fetch("Id")}")
        expect(insertedJourneyInfo.fetch("Owner").fetch("Id")).to match owner
        @helper.addLogs("[Result ]   : Owner checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Campaign on journey")
        @helper.addLogs("[Expected ] : Campaign on Journey should be campaign selected while importing lead")
        @helper.addLogs("[Actual ]   : Campaign on Journey is #{insertedJourneyInfo.fetch("CampaignId__c")}")
        expect(insertedJourneyInfo.fetch("CampaignId__c")).to eql @campaignId.fetch('Id')
        @helper.addLogs("[Result ]   : Campaign checked successfully\n")
        @pageObject.instance_variable_get(:@testDataJSON)['Journey'][0]
        generatedActivityForLead = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Subject , CreatedDate,Status ,Lead_Source__c , Lead_Source_Detail__c,Owner.Name,Locations_Interested__c, Number_of_Full_Time_Employees__c,Interested_in_Number_of_Desks__c,Company__c,WhoId FROM Task WHERE WhoId = '#{leadInfo.fetch('Id')}'")[0]
        @helper.addLogs("[Validate ] : Checking Subject on acitivity")
        @helper.addLogs("[Expected ] : Subject on activity should be inboound lead submission")
        @helper.addLogs("[Actual ]   : Subject on activity  is #{generatedActivityForLead.fetch("Subject")}")
        expect(generatedActivityForLead.fetch("Subject")).to eql "Inbound Lead submission"
        @helper.addLogs("[Result ]   : Activity subject checked successfully")
        @helper.addLogs("[Validate ] : Checking lead source on activity")
        @helper.addLogs("[Expected ] : Lead source on activity should be lead source of created lead")
        @helper.addLogs("[Actual ]   : Lead source on activity is #{generatedActivityForLead.fetch("Lead_Source__c")}")
        expect(generatedActivityForLead.fetch("Lead_Source__c")).to eql "Inbound Call"
        @helper.addLogs("[Result ]   : Activity lead source checked successfully")
        @helper.addLogs("[Validate ] : Checking lead source detail on activity")
        @helper.addLogs("[Expected ] : Lead source detail on activity should be lead source of created lead")
        @helper.addLogs("[Actual ]   : Lead source detail on activity is #{generatedActivityForLead.fetch("Lead_Source__c")}")
        expect(generatedActivityForLead.fetch("Lead_Source_Detail__c")).to eql "Inbound Call Page"
        @helper.addLogs("[Result ]   : Activity lead source detail checked successfully")
        @helper.addLogs("[Validate ] : Checking status on activity")
        @helper.addLogs("[Expected ] : Status on activity should be Open")
        @helper.addLogs("[Actual ]   : Status on activity is #{generatedActivityForLead.fetch("Status")}")
        expect(generatedActivityForLead.fetch("Status")).to eql "Open"
        @helper.addLogs("[Result ]   : Activity assigned to field checked successfully")
        @helper.addLogs("[Validate ] : Checking Company on activity")
        @helper.addLogs("[Expected ] : Company on activity should be #{leadInfo.fetch('Company')}")
        @helper.addLogs("[Actual ]   : Status on activity is #{generatedActivityForLead.fetch("Company__c")}")
        expect(generatedActivityForLead.fetch("Company__c")).to eql leadInfo.fetch('Company')
        @helper.addLogs("[Result ]   : Activity Status field checked successfully")
        @helper.addLogs("[Validate ] : Checking Location interested on activity")
        @helper.addLogs("[Expected ] : Location interested on activity should be #{leadInfo.fetch('Locations_Interested__c')}")
        @helper.addLogs("[Actual ]   : Location interested on activity is #{generatedActivityForLead.fetch("Locations_Interested__c")}")
        expect(generatedActivityForLead.fetch("Locations_Interested__c")).to eql leadInfo.fetch('Locations_Interested__c')
        @helper.addLogs("[Result ]   : Activity Location interested field checked successfully")
        @helper.addLogs('Success')
        @helper.postSuccessResult(2575)
      rescue Exception => e
        @helper.addLogs('Error')
        @helper.postFailResult(e, 2575)
        raise e
      end
    end
    it 'To Check Journey is Created While Importing Existing Lead Which is Owned By Susie Romero Where Activity is Not present on Existing Lead, when the Generate Journey on UI is UnChecked and Generate Journey in CSV is True and assign to the Campaign.', :'2658' => 'true' do
      begin
        @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Generate_Journey__c'] = true
        leadInfo = nil
        @helper.getExistingLead(nil,nil,"Susie Romero",true).each do |lead|
          if lead['Tasks'].nil?
            leadInfo = lead
            break;
          end
        end
        leadInfo.nil? ? email = "John.Smith_QAAuto#{rand(9999999999999999)}@example.com" : email = leadInfo.fetch('Email')
        if leadInfo.nil?
          @testDataJSON['Lead'][0]['Email'] = email
          @testDataJSON['Lead'][0]['Number_of_Full_Time_Employees__c'] = 10
          @testDataJSON['Lead'][0]['Interested_in_Number_of_Desks__c'] = 5
          @testDataJSON['Lead'][0]['Status'] = "Open"
          @testDataJSON['Lead'][0]['LeadSource'] = "Inbound Call"
          @testDataJSON['Lead'][0]['lead_Source_Detail__c'] = "Inbound Call Page"
          @testDataJSON['Lead'][0]['Locale__c'] = "en-US"
          @testDataJSON['Lead'][0]['Country_Code__c'] = "IN"
          @testDataJSON['Lead'][0]['Generate_Journey__c'] = false
          leadInfo = {"lastName"=>@testDataJSON['Lead'][0]['FirstName'],"firstName"=>@testDataJSON['Lead'][0]['LastName'],"website"=>"http://www.Testgmail.com","email"=>email,"phone"=>"8146185355","company"=>@testDataJSON['Lead'][0]['Company'],"company_Size__c"=>@testDataJSON['Lead'][0]['Number_of_Full_Time_Employees__c'],"lead_Source_Detail__c"=>@testDataJSON['Lead'][0]['lead_Source_Detail__c'],"utm_campaign__c"=>"San Francisco - Modifier","utm_content__c"=>"utm contents","utm_medium__c"=>"cpc","utm_source__c"=>"ads-google","utm_term__c"=>"virtual +office +san +francisco","locale__c"=>@testDataJSON['Lead'][0]['Locale__c'],"country_Code__c"=>@testDataJSON['Lead'][0]['Country_Code__c'] ,"number_of_Desks__c"=>@testDataJSON['Lead'][0]['Interested_in_Number_of_Desks__c'],"leadSource"=>@testDataJSON['Lead'][0]['LeadSource'],"Generate_Journey__c"=>false,"OwnerId"=>"005F0000003Kmbw"}
          leadInfo['Id'] = @helper.instance_variable_get(:@restForce).createRecord("Lead",leadInfo)
          Helper.addRecordsToDelete("Lead",leadInfo['Id'])
        end
        @pageObject.upload_csv(email, "", @testDataJSON['Campaign'][0]['Name'],false,false,"Lead")[0]
        expect(leadInfo).to_not eql nil
        @helper.addLogs("[Validate ] : Checking Lead owner should be lead owner on campaign")
        @helper.addLogs("[Expected ] : Owner of lead should be according to campaign assignment")
        @pageObject.checkJobStatus
        leadInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Owner.Name, Generate_Journey__c,Owner.id,LeadSource , Lead_Source_Detail__c , Building_Interested_In__c , Building_Interested_Name__c ,Journey_Created_On__c, Locations_Interested__c , Number_of_Full_Time_Employees__c , Interested_in_Number_of_Desks__c , Email , Phone , Company , Name , RecordType.Name , Status , Type__c FROM Lead WHERE id = '#{leadInfo.fetch("Id")}'")[0]
        @helper.addLogs("[Actual ]   : Owner of lead is #{leadInfo.fetch("Owner").fetch("Id")}")
        owner = @pageObject.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
        expect(leadInfo.fetch("Owner").fetch("Id")).to eql owner
        @helper.addLogs("[Result ]   : Owner checked successfully\n")
        @helper.addLogs("[Validate ] : Checking create Journey on lead")
        @helper.addLogs("[Expected ] : Create Journey should #{@testDataJSON['Lead'][0]['Generate_Journey__c']}")
        @helper.addLogs("[Actual ]   : Create Journey on lead is #{leadInfo.fetch("Generate_Journey__c").inspect}")
        expect(leadInfo.fetch("Generate_Journey__c")).to eql false
        insertedJourneyInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,CampaignId__c,Owner.id, Owner.Name,CreatedDate ,Status__c , NMD_Next_Contact_Date__c ,Primary_Email__c , Lead_Source__c , Lead_Source_Detail__c , Primary_Phone__c , Company_Name__c , Building_Interested_In__c , Locations_Interested__c , Interested_in_Number_of_Desks__c , Full_Time_Employees__c, Name   FROM Journey__c WHERE Primary_Email__c = '#{leadInfo.fetch("Email")}'")[0]
        Helper.addRecordsToDelete("Journey__c", insertedJourneyInfo.fetch('Id'))
        @helper.addLogs("[Validate ] : Checking Journey is created on lead")
        @helper.addLogs("[Expected ] : Journey should be created")
        @helper.addLogs("[Actual ]   : Journey is created with name #{insertedJourneyInfo.fetch("Name")}")
        expect(insertedJourneyInfo).to_not eql nil
        Helper.addRecordsToDelete("Journey__c", insertedJourneyInfo.fetch('Id'))
        @helper.addLogs("[Result ]   : Journey created successfully\n")
        @helper.addLogs("[Validate ] : Checking Journey owner should be lead owner")
        @helper.addLogs("[Expected ] : Owner of Journey should be owner of lead")
        @helper.addLogs("[Actual ]   : Owner of Journey is #{insertedJourneyInfo.fetch("Owner").fetch("Id")}")
        expect(insertedJourneyInfo.fetch("Owner").fetch("Id")).to match owner
        @helper.addLogs("[Result ]   : Owner checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Campaign on journey")
        @helper.addLogs("[Expected ] : Campaign on Journey should be campaign selected while importing lead")
        @helper.addLogs("[Actual ]   : Campaign on Journey is #{insertedJourneyInfo.fetch("CampaignId__c")}")
        expect(insertedJourneyInfo.fetch("CampaignId__c")).to eql @campaignId.fetch('Id')
        @helper.addLogs("[Result ]   : Campaign checked successfully\n")
        @pageObject.instance_variable_get(:@testDataJSON)['Journey'][0]
        generatedActivityForLead = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Subject , CreatedDate,Status ,Lead_Source__c , Lead_Source_Detail__c,Owner.Name,Locations_Interested__c, Number_of_Full_Time_Employees__c,Interested_in_Number_of_Desks__c,Company__c,WhoId FROM Task WHERE WhoId = '#{leadInfo.fetch('Id')}'")[0]
        @helper.addLogs("[Validate ] : Checking Subject on acitivity")
        @helper.addLogs("[Expected ] : Subject on activity should be inboound lead submission")
        @helper.addLogs("[Actual ]   : Subject on activity  is #{generatedActivityForLead.fetch("Subject")}")
        expect(generatedActivityForLead.fetch("Subject")).to eql "Inbound Lead submission"
        @helper.addLogs("[Result ]   : Activity subject checked successfully")
        @helper.addLogs("[Validate ] : Checking lead source on activity")
        @helper.addLogs("[Expected ] : Lead source on activity should be lead source of created lead")
        @helper.addLogs("[Actual ]   : Lead source on activity is #{generatedActivityForLead.fetch("Lead_Source__c")}")
        expect(generatedActivityForLead.fetch("Lead_Source__c")).to eql "Inbound Call"
        @helper.addLogs("[Result ]   : Activity lead source checked successfully")
        @helper.addLogs("[Validate ] : Checking lead source detail on activity")
        @helper.addLogs("[Expected ] : Lead source detail on activity should be lead source of created lead")
        @helper.addLogs("[Actual ]   : Lead source detail on activity is #{generatedActivityForLead.fetch("Lead_Source__c")}")
        expect(generatedActivityForLead.fetch("Lead_Source_Detail__c")).to eql "Inbound Call Page"
        @helper.addLogs("[Result ]   : Activity lead source detail checked successfully")
        @helper.addLogs("[Validate ] : Checking status on activity")
        @helper.addLogs("[Expected ] : Status on activity should be Open")
        @helper.addLogs("[Actual ]   : Status on activity is #{generatedActivityForLead.fetch("Status")}")
        expect(generatedActivityForLead.fetch("Status")).to eql "Open"
        @helper.addLogs("[Result ]   : Activity assigned to field checked successfully")
        @helper.addLogs("[Validate ] : Checking Company on activity")
        @helper.addLogs("[Expected ] : Company on activity should be #{leadInfo.fetch('Company')}")
        @helper.addLogs("[Actual ]   : Status on activity is #{generatedActivityForLead.fetch("Company__c")}")
        expect(generatedActivityForLead.fetch("Company__c")).to eql leadInfo.fetch('Company')
        @helper.addLogs("[Result ]   : Activity Status field checked successfully")
        @helper.addLogs("[Validate ] : Checking Location interested on activity")
        @helper.addLogs("[Expected ] : Location interested on activity should be #{leadInfo.fetch('Locations_Interested__c')}")
        @helper.addLogs("[Actual ]   : Location interested on activity is #{generatedActivityForLead.fetch("Locations_Interested__c")}")
        expect(generatedActivityForLead.fetch("Locations_Interested__c")).to eql leadInfo.fetch('Locations_Interested__c')
        @helper.addLogs("[Result ]   : Activity Location interested field checked successfully")
        @helper.addLogs('Success')
        @helper.postSuccessResult(2578)
      rescue Exception => e
        @helper.addLogs('Error')
        @helper.postFailResult(e, 2578)
        raise e
      end
    end
    it 'To Check Journey is Created While Importing Existing Lead Which is Owned By Susie Romero Where Activity is present on Existing Lead, when the Generate Journey on UI is Checked and Generate Journey in CSV is Blank and assign to the Campaign.', :'2664' => 'true' do
      begin
        @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Generate_Journey__c'] = true
        leadInfo = nil
        @helper.getExistingLead(nil,nil,"Susie Romero",true).each do |lead|
          if lead['Tasks'].nil?
            leadInfo = lead
            break;
          end
        end
        leadInfo.nil? ? email = "John.Smith_QAAuto#{rand(9999999999999999)}@example.com" : email = leadInfo.fetch('Email')
        if leadInfo.nil?
          @testDataJSON['Lead'][0]['Email'] = email
          @testDataJSON['Lead'][0]['Number_of_Full_Time_Employees__c'] = 10
          @testDataJSON['Lead'][0]['Interested_in_Number_of_Desks__c'] = 5
          @testDataJSON['Lead'][0]['Status'] = "Open"
          @testDataJSON['Lead'][0]['LeadSource'] = "Inbound Call"
          @testDataJSON['Lead'][0]['lead_Source_Detail__c'] = "Inbound Call Page"
          @testDataJSON['Lead'][0]['Locale__c'] = "en-US"
          @testDataJSON['Lead'][0]['Country_Code__c'] = "IN"
          @testDataJSON['Lead'][0]['Generate_Journey__c'] = false
          leadInfo = {"lastName"=>@testDataJSON['Lead'][0]['FirstName'],"firstName"=>@testDataJSON['Lead'][0]['LastName'],"website"=>"http://www.Testgmail.com","email"=>email,"phone"=>"8146185355","company"=>@testDataJSON['Lead'][0]['Company'],"company_Size__c"=>@testDataJSON['Lead'][0]['Number_of_Full_Time_Employees__c'],"lead_Source_Detail__c"=>@testDataJSON['Lead'][0]['lead_Source_Detail__c'],"utm_campaign__c"=>"San Francisco - Modifier","utm_content__c"=>"utm contents","utm_medium__c"=>"cpc","utm_source__c"=>"ads-google","utm_term__c"=>"virtual +office +san +francisco","locale__c"=>@testDataJSON['Lead'][0]['Locale__c'],"country_Code__c"=>@testDataJSON['Lead'][0]['Country_Code__c'] ,"number_of_Desks__c"=>@testDataJSON['Lead'][0]['Interested_in_Number_of_Desks__c'],"leadSource"=>@testDataJSON['Lead'][0]['LeadSource'],"Generate_Journey__c"=>false,"OwnerId"=>"005F0000003Kmbw"}
          leadInfo['Id'] = @helper.instance_variable_get(:@restForce).createRecord("Lead",leadInfo)
          Helper.addRecordsToDelete("Lead",leadInfo['Id'])
        end
        @pageObject.upload_csv(email, "", @testDataJSON['Campaign'][0]['Name'],false,false,"Lead")[0]
        expect(leadInfo).to_not eql nil
        @helper.addLogs("[Validate ] : Checking Lead owner should be lead owner on campaign")
        @helper.addLogs("[Expected ] : Owner of lead should be according to campaign assignment")
        @pageObject.checkJobStatus
        leadInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Owner.Name, Generate_Journey__c,Owner.id,LeadSource , Lead_Source_Detail__c , Building_Interested_In__c , Building_Interested_Name__c ,Journey_Created_On__c, Locations_Interested__c , Number_of_Full_Time_Employees__c , Interested_in_Number_of_Desks__c , Email , Phone , Company , Name , RecordType.Name , Status , Type__c FROM Lead WHERE id = '#{leadInfo.fetch("Id")}'")[0]
        @helper.addLogs("[Actual ]   : Owner of lead is #{leadInfo.fetch("Owner").fetch("Id")}")
        owner = @pageObject.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
        expect(leadInfo.fetch("Owner").fetch("Id")).to eql owner
        @helper.addLogs("[Result ]   : Owner checked successfully\n")
        @helper.addLogs("[Validate ] : Checking create Journey on lead")
        @helper.addLogs("[Expected ] : Create Journey should #{@testDataJSON['Lead'][0]['Generate_Journey__c']}")
        @helper.addLogs("[Actual ]   : Create Journey on lead is #{leadInfo.fetch("Generate_Journey__c").inspect}")
        expect(leadInfo.fetch("Generate_Journey__c")).to eql false
        insertedJourneyInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,CampaignId__c,Owner.id, Owner.Name,CreatedDate ,Status__c , NMD_Next_Contact_Date__c ,Primary_Email__c , Lead_Source__c , Lead_Source_Detail__c , Primary_Phone__c , Company_Name__c , Building_Interested_In__c , Locations_Interested__c , Interested_in_Number_of_Desks__c , Full_Time_Employees__c, Name   FROM Journey__c WHERE Primary_Email__c = '#{leadInfo.fetch("Email")}'")[0]
        Helper.addRecordsToDelete("Journey__c", insertedJourneyInfo.fetch('Id'))
        @helper.addLogs("[Validate ] : Checking Journey is created on lead")
        @helper.addLogs("[Expected ] : Journey should be created")
        @helper.addLogs("[Actual ]   : Journey is created with name #{insertedJourneyInfo.fetch("Name")}")
        expect(insertedJourneyInfo).to_not eql nil
        Helper.addRecordsToDelete("Journey__c", insertedJourneyInfo.fetch('Id'))
        @helper.addLogs("[Result ]   : Journey created successfully\n")
        @helper.addLogs("[Validate ] : Checking Journey owner should be lead owner")
        @helper.addLogs("[Expected ] : Owner of Journey should be owner of lead")
        @helper.addLogs("[Actual ]   : Owner of Journey is #{insertedJourneyInfo.fetch("Owner").fetch("Id")}")
        expect(insertedJourneyInfo.fetch("Owner").fetch("Id")).to match owner
        @helper.addLogs("[Result ]   : Owner checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Campaign on journey")
        @helper.addLogs("[Expected ] : Campaign on Journey should be campaign selected while importing lead")
        @helper.addLogs("[Actual ]   : Campaign on Journey is #{insertedJourneyInfo.fetch("CampaignId__c")}")
        expect(insertedJourneyInfo.fetch("CampaignId__c")).to eql @campaignId.fetch('Id')
        @helper.addLogs("[Result ]   : Campaign checked successfully\n")
        @pageObject.instance_variable_get(:@testDataJSON)['Journey'][0]
        generatedActivityForLead = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Subject , CreatedDate,Status ,Lead_Source__c , Lead_Source_Detail__c,Owner.Name,Locations_Interested__c, Number_of_Full_Time_Employees__c,Interested_in_Number_of_Desks__c,Company__c,WhoId FROM Task WHERE WhoId = '#{leadInfo.fetch('Id')}'")[0]
        @helper.addLogs("[Validate ] : Checking Subject on acitivity")
        @helper.addLogs("[Expected ] : Subject on activity should be inboound lead submission")
        @helper.addLogs("[Actual ]   : Subject on activity  is #{generatedActivityForLead.fetch("Subject")}")
        expect(generatedActivityForLead.fetch("Subject")).to eql "Inbound Lead submission"
        @helper.addLogs("[Result ]   : Activity subject checked successfully")
        @helper.addLogs("[Validate ] : Checking lead source on activity")
        @helper.addLogs("[Expected ] : Lead source on activity should be lead source of created lead")
        @helper.addLogs("[Actual ]   : Lead source on activity is #{generatedActivityForLead.fetch("Lead_Source__c")}")
        expect(generatedActivityForLead.fetch("Lead_Source__c")).to eql "Inbound Call"
        @helper.addLogs("[Result ]   : Activity lead source checked successfully")
        @helper.addLogs("[Validate ] : Checking lead source detail on activity")
        @helper.addLogs("[Expected ] : Lead source detail on activity should be lead source of created lead")
        @helper.addLogs("[Actual ]   : Lead source detail on activity is #{generatedActivityForLead.fetch("Lead_Source__c")}")
        expect(generatedActivityForLead.fetch("Lead_Source_Detail__c")).to eql "Inbound Call Page"
        @helper.addLogs("[Result ]   : Activity lead source detail checked successfully")
        @helper.addLogs("[Validate ] : Checking status on activity")
        @helper.addLogs("[Expected ] : Status on activity should be Open")
        @helper.addLogs("[Actual ]   : Status on activity is #{generatedActivityForLead.fetch("Status")}")
        expect(generatedActivityForLead.fetch("Status")).to eql "Open"
        @helper.addLogs("[Result ]   : Activity assigned to field checked successfully")
        @helper.addLogs("[Validate ] : Checking Company on activity")
        @helper.addLogs("[Expected ] : Company on activity should be #{leadInfo.fetch('Company')}")
        @helper.addLogs("[Actual ]   : Status on activity is #{generatedActivityForLead.fetch("Company__c")}")
        expect(generatedActivityForLead.fetch("Company__c")).to eql leadInfo.fetch('Company')
        @helper.addLogs("[Result ]   : Activity Status field checked successfully")
        @helper.addLogs('Success')
        @helper.postSuccessResult(2578)
      rescue Exception => e
        @helper.addLogs('Error')
        @helper.postFailResult(e, 2578)
        raise e
      end
    end
    it 'To Check Journey Created for Existing Lead Owned By Susie Romero Where Activity is not present and which is assigned to the particular Campaign, When the generate Journey on UI is Checked & Generate Journey in CSV is Blank & inserted into diff Campgn', :'2666' => 'true' do
      begin
        @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Generate_Journey__c'] = true
        leadInfo = nil
        @helper.getExistingLead(nil,nil,"Susie Romero",true).each do |lead|
          if lead['Tasks'].nil?
            leadInfo = lead
            break;
          end
        end
        leadInfo.nil? ? email = "John.Smith_QAAuto#{rand(9999999999999999)}@example.com" : email = leadInfo.fetch('Email')
        if leadInfo.nil?
          @testDataJSON['Lead'][0]['Email'] = email
          @testDataJSON['Lead'][0]['Number_of_Full_Time_Employees__c'] = 10
          @testDataJSON['Lead'][0]['Interested_in_Number_of_Desks__c'] = 5
          @testDataJSON['Lead'][0]['Status'] = "Open"
          @testDataJSON['Lead'][0]['LeadSource'] = "Inbound Call"
          @testDataJSON['Lead'][0]['lead_Source_Detail__c'] = "Inbound Call Page"
          @testDataJSON['Lead'][0]['Locale__c'] = "en-US"
          @testDataJSON['Lead'][0]['Country_Code__c'] = "IN"
          @testDataJSON['Lead'][0]['Generate_Journey__c'] = false
          leadInfo = {"lastName"=>@testDataJSON['Lead'][0]['FirstName'],"firstName"=>@testDataJSON['Lead'][0]['LastName'],"website"=>"http://www.Testgmail.com","email"=>email,"phone"=>"8146185355","company"=>@testDataJSON['Lead'][0]['Company'],"company_Size__c"=>@testDataJSON['Lead'][0]['Number_of_Full_Time_Employees__c'],"lead_Source_Detail__c"=>@testDataJSON['Lead'][0]['lead_Source_Detail__c'],"utm_campaign__c"=>"San Francisco - Modifier","utm_content__c"=>"utm contents","utm_medium__c"=>"cpc","utm_source__c"=>"ads-google","utm_term__c"=>"virtual +office +san +francisco","locale__c"=>@testDataJSON['Lead'][0]['Locale__c'],"country_Code__c"=>@testDataJSON['Lead'][0]['Country_Code__c'] ,"number_of_Desks__c"=>@testDataJSON['Lead'][0]['Interested_in_Number_of_Desks__c'],"leadSource"=>@testDataJSON['Lead'][0]['LeadSource'],"Generate_Journey__c"=>false,"OwnerId"=>"005F0000003Kmbw"}
          leadInfo['Id'] = @helper.instance_variable_get(:@restForce).createRecord("Lead",leadInfo)
          Helper.addRecordsToDelete("Lead",leadInfo['Id'])
        end
        @pageObject.upload_csv(email, "", @testDataJSON['Campaign'][0]['Name'],false,false,"Lead")[0]
        expect(leadInfo).to_not eql nil
        @helper.addLogs("[Validate ] : Checking Lead owner should be lead owner on campaign")
        @helper.addLogs("[Expected ] : Owner of lead should be according to campaign assignment")
        @pageObject.checkJobStatus
        leadInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Owner.Name, Generate_Journey__c,Owner.id,LeadSource , Lead_Source_Detail__c , Building_Interested_In__c , Building_Interested_Name__c ,Journey_Created_On__c, Locations_Interested__c , Number_of_Full_Time_Employees__c , Interested_in_Number_of_Desks__c , Email , Phone , Company , Name , RecordType.Name , Status , Type__c FROM Lead WHERE id = '#{leadInfo.fetch("Id")}'")[0]
        @helper.addLogs("[Actual ]   : Owner of lead is #{leadInfo.fetch("Owner").fetch("Id")}")
        owner = @pageObject.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
        expect(leadInfo.fetch("Owner").fetch("Id")).to eql owner
        @helper.addLogs("[Result ]   : Owner checked successfully\n")
        @helper.addLogs("[Validate ] : Checking create Journey on lead")
        @helper.addLogs("[Expected ] : Create Journey should #{@testDataJSON['Lead'][0]['Generate_Journey__c']}")
        @helper.addLogs("[Actual ]   : Create Journey on lead is #{leadInfo.fetch("Generate_Journey__c").inspect}")
        expect(leadInfo.fetch("Generate_Journey__c")).to eql false
        insertedJourneyInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,CampaignId__c,Owner.id, Owner.Name,CreatedDate ,Status__c , NMD_Next_Contact_Date__c ,Primary_Email__c , Lead_Source__c , Lead_Source_Detail__c , Primary_Phone__c , Company_Name__c , Building_Interested_In__c , Locations_Interested__c , Interested_in_Number_of_Desks__c , Full_Time_Employees__c, Name   FROM Journey__c WHERE Primary_Email__c = '#{leadInfo.fetch("Email")}'")[0]
        Helper.addRecordsToDelete("Journey__c", insertedJourneyInfo.fetch('Id'))
        @helper.addLogs("[Validate ] : Checking Journey is created on lead")
        @helper.addLogs("[Expected ] : Journey should be created")
        @helper.addLogs("[Actual ]   : Journey is created with name #{insertedJourneyInfo.fetch("Name")}")
        expect(insertedJourneyInfo).to_not eql nil
        Helper.addRecordsToDelete("Journey__c", insertedJourneyInfo.fetch('Id'))
        @helper.addLogs("[Result ]   : Journey created successfully\n")
        @helper.addLogs("[Validate ] : Checking Journey owner should be lead owner")
        @helper.addLogs("[Expected ] : Owner of Journey should be owner of lead")
        @helper.addLogs("[Actual ]   : Owner of Journey is #{insertedJourneyInfo.fetch("Owner").fetch("Id")}")
        expect(insertedJourneyInfo.fetch("Owner").fetch("Id")).to match owner
        @helper.addLogs("[Result ]   : Owner checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Campaign on journey")
        @helper.addLogs("[Expected ] : Campaign on Journey should be campaign selected while importing lead")
        @helper.addLogs("[Actual ]   : Campaign on Journey is #{insertedJourneyInfo.fetch("CampaignId__c")}")
        expect(insertedJourneyInfo.fetch("CampaignId__c")).to eql @campaignId.fetch('Id')
        @helper.addLogs("[Result ]   : Campaign checked successfully\n")
        @pageObject.instance_variable_get(:@testDataJSON)['Journey'][0]
        generatedActivityForLead = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Subject , CreatedDate,Status ,Lead_Source__c , Lead_Source_Detail__c,Owner.Name,Locations_Interested__c, Number_of_Full_Time_Employees__c,Interested_in_Number_of_Desks__c,Company__c,WhoId FROM Task WHERE WhoId = '#{leadInfo.fetch('Id')}'")[0]
        @helper.addLogs("[Validate ] : Checking Subject on acitivity")
        @helper.addLogs("[Expected ] : Subject on activity should be inboound lead submission")
        @helper.addLogs("[Actual ]   : Subject on activity  is #{generatedActivityForLead.fetch("Subject")}")
        expect(generatedActivityForLead.fetch("Subject")).to eql "Inbound Lead submission"
        @helper.addLogs("[Result ]   : Activity subject checked successfully")
        @helper.addLogs("[Validate ] : Checking lead source on activity")
        @helper.addLogs("[Expected ] : Lead source on activity should be lead source of created lead")
        @helper.addLogs("[Actual ]   : Lead source on activity is #{generatedActivityForLead.fetch("Lead_Source__c")}")
        expect(generatedActivityForLead.fetch("Lead_Source__c")).to eql "Inbound Call"
        @helper.addLogs("[Result ]   : Activity lead source checked successfully")
        @helper.addLogs("[Validate ] : Checking lead source detail on activity")
        @helper.addLogs("[Expected ] : Lead source detail on activity should be lead source of created lead")
        @helper.addLogs("[Actual ]   : Lead source detail on activity is #{generatedActivityForLead.fetch("Lead_Source__c")}")
        expect(generatedActivityForLead.fetch("Lead_Source_Detail__c")).to eql "Inbound Call Page"
        @helper.addLogs("[Result ]   : Activity lead source detail checked successfully")
        @helper.addLogs("[Validate ] : Checking status on activity")
        @helper.addLogs("[Expected ] : Status on activity should be Open")
        @helper.addLogs("[Actual ]   : Status on activity is #{generatedActivityForLead.fetch("Status")}")
        expect(generatedActivityForLead.fetch("Status")).to eql "Open"
        @helper.addLogs("[Result ]   : Activity assigned to field checked successfully")
        @helper.addLogs("[Validate ] : Checking Company on activity")
        @helper.addLogs("[Expected ] : Company on activity should be #{leadInfo.fetch('Company')}")
        @helper.addLogs("[Actual ]   : Status on activity is #{generatedActivityForLead.fetch("Company__c")}")
        expect(generatedActivityForLead.fetch("Company__c")).to eql leadInfo.fetch('Company')
        @helper.addLogs("[Result ]   : Activity Status field checked successfully")
        @helper.addLogs('Success')
        @helper.postSuccessResult(2578)
      rescue Exception => e
        @helper.addLogs('Error')
        @helper.postFailResult(e, 2578)
        raise e
      end
    end
    it 'To Check Journey not Created While Importing Existing Lead Which is Owned By Susie Romero Where Activity is Not present on Existing Lead, when the Generate Journey on UI is UnChecked and Generate Journey in CSV is false and assign to the Campaign.', :'2663' => 'true' do
      begin
        @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Generate_Journey__c'] = true
        leadInfo = nil
        @helper.getExistingLead(nil,nil,"Susie Romero",true).each do |lead|
          if lead['Tasks'].nil?
            leadInfo = lead
            break;
          end
        end
        leadInfo.nil? ? email = "John.Smith_QAAuto#{rand(9999999999999999)}@example.com" : email = leadInfo.fetch('Email')
        if leadInfo.nil?
          @testDataJSON['Lead'][0]['Email'] = email
          @testDataJSON['Lead'][0]['Number_of_Full_Time_Employees__c'] = 10
          @testDataJSON['Lead'][0]['Interested_in_Number_of_Desks__c'] = 5
          @testDataJSON['Lead'][0]['Status'] = "Open"
          @testDataJSON['Lead'][0]['LeadSource'] = "Inbound Call"
          @testDataJSON['Lead'][0]['lead_Source_Detail__c'] = "Inbound Call Page"
          @testDataJSON['Lead'][0]['Locale__c'] = "en-US"
          @testDataJSON['Lead'][0]['Country_Code__c'] = "IN"
          leadInfo = {"lastName"=>@testDataJSON['Lead'][0]['FirstName'],"firstName"=>@testDataJSON['Lead'][0]['LastName'],"website"=>"http://www.Testgmail.com","email"=>email,"phone"=>"8146185355","company"=>@testDataJSON['Lead'][0]['Company'],"company_Size__c"=>@testDataJSON['Lead'][0]['Number_of_Full_Time_Employees__c'],"lead_Source_Detail__c"=>@testDataJSON['Lead'][0]['lead_Source_Detail__c'],"utm_campaign__c"=>"San Francisco - Modifier","utm_content__c"=>"utm contents","utm_medium__c"=>"cpc","utm_source__c"=>"ads-google","utm_term__c"=>"virtual +office +san +francisco","locale__c"=>@testDataJSON['Lead'][0]['Locale__c'],"country_Code__c"=>@testDataJSON['Lead'][0]['Country_Code__c'] ,"number_of_Desks__c"=>@testDataJSON['Lead'][0]['Interested_in_Number_of_Desks__c'],"leadSource"=>@testDataJSON['Lead'][0]['LeadSource'],"Generate_Journey__c"=>false,"OwnerId"=>"005F0000003Kmbw"}
          leadInfo['Id'] = @helper.instance_variable_get(:@restForce).createRecord("Lead",leadInfo)
          Helper.addRecordsToDelete("Lead",leadInfo['Id'])
        end
        @pageObject.upload_csv(email, "", @testDataJSON['Campaign'][0]['Name'],true,false,"Lead")[0]
        expect(leadInfo).to_not eql nil
        @helper.addLogs("[Validate ] : Checking Lead owner should be lead owner on campaign")
        @helper.addLogs("[Expected ] : Owner of lead should be Logged in user")
        @pageObject.checkJobStatus
        leadInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Owner.Name, Generate_Journey__c,Owner.id,LeadSource , Lead_Source_Detail__c , Building_Interested_In__c , Building_Interested_Name__c ,Journey_Created_On__c, Locations_Interested__c , Number_of_Full_Time_Employees__c , Interested_in_Number_of_Desks__c , Email , Phone , Company , Name , RecordType.Name , Status , Type__c FROM Lead WHERE id = '#{leadInfo.fetch("Id")}'")[0]
        @helper.addLogs("[Actual ]   : Owner of lead is #{leadInfo.fetch("Owner").fetch("Id")}")
        owner = @pageObject.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
        expect(leadInfo.fetch("Owner").fetch("Id")).to eql owner
        @helper.addLogs("[Result ]   : Owner checked successfully\n")
        @helper.addLogs("[Validate ] : Checking create Journey on lead")
        @helper.addLogs("[Expected ] : Create Journey should #{@testDataJSON['Lead'][0]['Generate_Journey__c']}")
        @helper.addLogs("[Actual ]   : Create Journey on lead is #{leadInfo.fetch("Generate_Journey__c").inspect}")
        expect(leadInfo.fetch("Generate_Journey__c")).to eql false
        insertedJourneyInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,CampaignId__c,Owner.id, Owner.Name,CreatedDate ,Status__c , NMD_Next_Contact_Date__c ,Primary_Email__c , Lead_Source__c , Lead_Source_Detail__c , Primary_Phone__c , Company_Name__c , Building_Interested_In__c , Locations_Interested__c , Interested_in_Number_of_Desks__c , Full_Time_Employees__c, Name   FROM Journey__c WHERE Primary_Email__c = '#{leadInfo.fetch("Email")}'")[0]

        @helper.addLogs("[Validate ] : Checking Journey is created on lead")
        @helper.addLogs("[Expected ] : Journey should not be created")
        @helper.addLogs("[Actual ]   : Journey is created - #{insertedJourneyInfo.nil? ? "No" : "Yes"}")
        expect(insertedJourneyInfo).to eql nil
        @helper.addLogs("[Result ]   : Journey created successfully\n")
        generatedActivityForLead = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Subject , CreatedDate,Status ,Lead_Source__c , Lead_Source_Detail__c,Owner.Name,Locations_Interested__c, Number_of_Full_Time_Employees__c,Interested_in_Number_of_Desks__c,Company__c,WhoId FROM Task WHERE WhoId = '#{leadInfo.fetch('Id')}'")[0]
        @helper.addLogs("[Validate ] : Checking Subject on acitivity")
        @helper.addLogs("[Expected ] : Subject on activity should be inboound lead submission")
        @helper.addLogs("[Actual ]   : Subject on activity  is #{generatedActivityForLead.fetch("Subject")}")
        expect(generatedActivityForLead.fetch("Subject")).to eql "Inbound Lead submission"
        @helper.addLogs("[Result ]   : Activity subject checked successfully")
        @helper.addLogs("[Validate ] : Checking lead source on activity")
        @helper.addLogs("[Expected ] : Lead source on activity should be lead source of created lead")
        @helper.addLogs("[Actual ]   : Lead source on activity is #{generatedActivityForLead.fetch("Lead_Source__c")}")
        expect(generatedActivityForLead.fetch("Lead_Source__c")).to eql "Inbound Call"
        @helper.addLogs("[Result ]   : Activity lead source checked successfully")
        @helper.addLogs("[Validate ] : Checking lead source detail on activity")
        @helper.addLogs("[Expected ] : Lead source detail on activity should be lead source of created lead")
        @helper.addLogs("[Actual ]   : Lead source detail on activity is #{generatedActivityForLead.fetch("Lead_Source__c")}")
        expect(generatedActivityForLead.fetch("Lead_Source_Detail__c")).to eql "Inbound Call Page"
        @helper.addLogs("[Result ]   : Activity lead source detail checked successfully")
        @helper.addLogs("[Validate ] : Checking status on activity")
        @helper.addLogs("[Expected ] : Status on activity should be Open")
        @helper.addLogs("[Actual ]   : Status on activity is #{generatedActivityForLead.fetch("Status")}")
        expect(generatedActivityForLead.fetch("Status")).to eql "Open"
        @helper.addLogs("[Result ]   : Activity assigned to field checked successfully")
        @helper.addLogs("[Validate ] : Checking Company on activity")
        @helper.addLogs("[Expected ] : Company on activity should be #{leadInfo.fetch('Company')}")
        @helper.addLogs("[Actual ]   : Status on activity is #{generatedActivityForLead.fetch("Company__c")}")
        expect(generatedActivityForLead.fetch("Company__c")).to eql leadInfo.fetch('Company')
        @helper.addLogs("[Result ]   : Activity Status field checked successfully")
        @helper.addLogs('Success')
        @helper.postSuccessResult(2622)
      rescue Exception => e
        @helper.addLogs('Error')
        @helper.postFailResult(e, 2622)
        raise e
      end
    end
  end
  def validate_case(object,actual,expected)
    #isValidate = false
    expected.keys.each do |key|
      if actual.key? key
        @helper.addLogs("[Validate ] : Checking #{object} : #{key}")
        @helper.addLogs("[Expected ] : #{actual[key]}")
        @helper.addLogs("[Actual ]   : #{expected[key]}")
        expect(expected[key]).to eql actual[key]
        #isValidate = true if expected[key].eql?
        @helper.addLogs("[Result ]   : #{key} checked successfully")
        puts "\n"
      end
    end
    #isValidate
  end
end
