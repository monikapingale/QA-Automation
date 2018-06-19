require 'json'
require 'selenium-webdriver'
require 'rspec'
require 'date'
require 'enziUIUtility'
require 'csv'
require_relative File.expand_path('../../../../', Dir.pwd) + '/specHelper.rb'
require_relative File.expand_path('..', Dir.pwd) + '/Page Objects/kickbox_importer.rb'
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
    @pageObject = Kickbox_Importer.new(@driver, @helper)
    EnziUIUtility.switchToClassic(@driver)
    @helper.go_to_app(@driver, "Sales Console")
    if @helper.alert_present? @driver
      @helper.close_alert_and_get_its_text(@driver, "id", "RPPWarning")
    end
    @building = @helper.instance_variable_get(:@restForce).getRecords("SELECT id FROM Building__c WHERE Name = '#{@testDataJSON['Lead'][0]["Building_Interested_In__c"]}'")[0].fetch("Id")
  end
  before(:each) do
    @pageObject.open_tab("KickBox Verification", "journey_importer")
  end
  after(:all) do
    @verification_errors.should == []
    @helper.deleteSalesforceRecordBySfbulk("Task", EnziRestforce.class_variable_get(:@@createdRecordsIds)["Task"])
    @helper.deleteSalesforceRecordBySfbulk("Journey__c", EnziRestforce.class_variable_get(:@@createdRecordsIds)["Journey__c"])
    @helper.deleteSalesforceRecordBySfbulk("Lead", EnziRestforce.class_variable_get(:@@createdRecordsIds)["Lead"])
  end
  context "Kickbox Importer While Insertion of Existing Lead Which is Owned By Susie Romero from Kickbox and assign to the Particular Campaign Based on Lead Owner Criterias", '317' => 'true' do
    before(:all) do
      @testDataJSON['Campaign'][0]['Lead Owner'] = '0051g000000tSCu'
      @testDataJSON['Campaign'][0]['Email Address'] = ''
      @testDataJSON['Campaign'][0]['City'] = ''
      @campaignId = @helper.instance_variable_get(:@restForce).getRecords("SELECT id FROM Campaign WHERE Name = '#{@testDataJSON['Campaign'][0]['Name']}'")[0]
      @helper.update_campaign(@campaignId.fetch('Id'), @testDataJSON['Campaign'][0]['Lead Owner'])
    end
    it 'To Check Journey Created While Importing Existing Contact Which is Owned By Susie Romero Where Activity is not present and existing journey is not present where Generate Journey on UI is Checked & in CSV is Blank and assign to the Campaign', :'2673' => 'true' do
      begin
        @helper.addLogs("[Step ]  : Getting existing contact")
        @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Generate_Journey__c'] = true
        contactInfo = nil
        contactInfo = @pageObject.getExistingContact("Susie Romero",false,false)
        if contactInfo.nil?
          @testDataJSON['Contact'][0]['Email'] = "john.smith_qaauto#{rand(999999999999999999)}@example.com"
          @testDataJSON['Contact'][0]['AccountId'] = @helper.instance_variable_get(:@restForce).getRecords("SELECT id FROM Account WHERE CreatedBy.Name IN ('Veena Hegane','Ashotosh Thakur','Monika Pingale','Kishor Shinde') and isDeleted = false")[0].fetch('Id')
          contactInfo = @helper.instance_variable_get(:@restForce).createRecord("Contact",@testDataJSON['Contact'][0])
          contactInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id, email,Account.Name, Owner.Name,Journey_Created_On__c FROM Contact WHERE id = '#{contactInfo}'")[0]
          Helper.addRecordsToDelete("Contact",contactInfo['Id'])
        end
        @helper.addLogs("[Step ]  : Using contact with email => #{contactInfo.fetch('Email')} and id => #{contactInfo.fetch('Id')}")
        @pageObject.upload_csv(contactInfo.fetch('Email'), "", @testDataJSON['Campaign'][0]['Name'], false,false,"Contact")
        expect(contactInfo).to_not eql nil
        @pageObject.checkJobStatus
        owner = @pageObject.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
        contactInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id, email,Account.Name, Owner.Name,Journey_Created_On__c FROM Contact WHERE id = '#{contactInfo.fetch("Id")}'")[0]
        sleep(5)
        insertedJourneyInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,CampaignId__c,Owner.id, Owner.Name,CreatedDate ,Status__c , NMD_Next_Contact_Date__c ,Primary_Email__c , Lead_Source__c , Lead_Source_Detail__c , Primary_Phone__c , Company_Name__c , Building_Interested_In__c , Locations_Interested__c , Interested_in_Number_of_Desks__c , Full_Time_Employees__c, Name   FROM Journey__c WHERE Primary_Email__c = '#{contactInfo.fetch("Email")}' AND CreatedDate = TODAY")[0]
        @helper.addLogs("[Validate ] : Checking Journey is created on lead")
        @helper.addLogs("[Expected ] : Journey should be created")
        @helper.addLogs("[Actual ]   : Journey is created with name #{insertedJourneyInfo.fetch("Name")}")
        expect(insertedJourneyInfo).to_not eql nil
        Helper.addRecordsToDelete("Journey__c", insertedJourneyInfo.fetch('Id'))
        @helper.addLogs("[Result ]   : Journey created successfully\n")
        puts "\n"
        validate_case("Journey",insertedJourneyInfo,{'Lead_Source__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['LeadSource'],'lead_Source_Detail__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]["lead_Source_Detail__c"],'Primary_Email__c'=>contactInfo.fetch("Email"),'Primary_Phone__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]["Phone"],'Company_Name__c'=>contactInfo.fetch('Account').fetch('Name'),'Status__c'=>'Started','CampaignId__c'=>@campaignId.fetch('Id')})
        @helper.addLogs("[Validate ] : Checking Journey owner should be according to lead owner criteria")
        @helper.addLogs("[Expected ] : Owner of Journey should be owner of lead")
        @helper.addLogs("[Actual ]   : Owner of Journey is #{insertedJourneyInfo.fetch("Owner").fetch("Id")}")
        expect(insertedJourneyInfo.fetch("Owner").fetch("Id")).to match owner
        @helper.addLogs("[Result ]   : Owner checked successfully\n")
        generatedActivityForContact = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Subject , CreatedDate,Status ,Lead_Source__c , Lead_Source_Detail__c,Owner.Name,Locations_Interested__c, Number_of_Full_Time_Employees__c,Interested_in_Number_of_Desks__c,Company__c,WhoId FROM Task WHERE WhoId = '#{contactInfo.fetch('Id')}' AND status != 'Completed' AND CreatedDate = TODAY")[0]

        Helper.addRecordsToDelete("Task", generatedActivityForContact.fetch('Id'))
        validate_case("Activity",generatedActivityForContact,{'Subject'=>'Inbound Lead submission','Locations_Interested__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Building_Interested_In__c'],'Company__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Company'],'Lead_Source_Detail__c'=>"Inbound Call Page",'Lead_Source__c'=>"Inbound Call",'Status'=>'Open'})
        @helper.addLogs("[Validate ] : Checking create Journey created on field on contact")
        @helper.addLogs("[Expected ] : Create Journey created on should today")
        @helper.addLogs("[Actual ]   : Create Journey created on on lead is #{contactInfo.fetch("Journey_Created_On__c").inspect}")
        expect(contactInfo .fetch("Journey_Created_On__c")).to match Date.today().to_s
        @helper.addLogs("[Result ]   : Journey created on field checked successfully\n")
        @helper.addLogs('Success')
        @helper.postSuccessResult(2575)
      rescue Exception => e
        @helper.addLogs('Error')
        @helper.postFailResult(e, 2575)
        raise e
      end
    end
    it 'To Check Journey  Created While Importing Existing Contact Which is Owned By Susie Romero Where Activity is not present and existing journey is not present where Generate Journey on UI is UnChecked & in CSV is True and assign to the Campaign.', :'2674' => 'true' do
      begin
        @helper.addLogs("[Step ]  : Getting existing contact")
        @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Generate_Journey__c'] = true
        contactInfo = @pageObject.getExistingContact("Susie Romero",false,false)
        @helper.addLogs("[Step ]  : Using contact with email => #{contactInfo.fetch('Email')} and id => #{contactInfo.fetch('Id')}")
        @pageObject.upload_csv(contactInfo.fetch('Email'), "TRUE", @testDataJSON['Campaign'][0]['Name'], true,false,"Contact")
        expect(contactInfo).to_not eql nil
        @pageObject.checkJobStatus
        owner = @pageObject.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
        contactInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id, email, Owner.Name,Journey_Created_On__c FROM Contact WHERE id = '#{contactInfo.fetch("Id")}'")[0]
        sleep(5)
        insertedJourneyInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,CampaignId__c,Owner.id, Owner.Name,CreatedDate ,Status__c , NMD_Next_Contact_Date__c ,Primary_Email__c , Lead_Source__c , Lead_Source_Detail__c , Primary_Phone__c , Company_Name__c , Building_Interested_In__c , Locations_Interested__c , Interested_in_Number_of_Desks__c , Full_Time_Employees__c, Name   FROM Journey__c WHERE Primary_Email__c = '#{contactInfo.fetch("Email")}'")[0]
        @helper.addLogs("[Validate ] : Checking Journey is created on lead")
        @helper.addLogs("[Expected ] : Journey should be created")
        @helper.addLogs("[Actual ]   : Journey is created with name #{insertedJourneyInfo.fetch("Name")}")
        expect(insertedJourneyInfo).to_not eql nil
        Helper.addRecordsToDelete("Journey__c", insertedJourneyInfo.fetch('Id'))
        @helper.addLogs("[Result ]   : Journey created successfully\n")
        puts "\n"
        validate_case("Journey",insertedJourneyInfo,{'Lead_Source__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['LeadSource'],'lead_Source_Detail__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]["lead_Source_Detail__c"],'NMD_Next_Contact_Date__c'=>contactInfo.fetch("Journey_Created_On__c"),'Primary_Email__c'=>contactInfo.fetch("Email"),'Primary_Phone__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]["Phone"],'Company_Name__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]["Company"],'Status__c'=>'Started','CampaignId__c'=>@campaignId.fetch('Id')})
        @helper.addLogs("[Validate ] : Checking Journey owner should be according to lead owner criteria")
        @helper.addLogs("[Expected ] : Owner of Journey should be owner of lead")
        @helper.addLogs("[Actual ]   : Owner of Journey is #{insertedJourneyInfo.fetch("Owner").fetch("Id")}")
        expect(insertedJourneyInfo.fetch("Owner").fetch("Id")).to match owner
        @helper.addLogs("[Result ]   : Owner checked successfully\n")
        @pageObject.instance_variable_get(:@testDataJSON)['Journey'][0]
        generatedActivityForContact = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Subject , CreatedDate,Status ,Lead_Source__c , Lead_Source_Detail__c,Owner.Name,Locations_Interested__c, Number_of_Full_Time_Employees__c,Interested_in_Number_of_Desks__c,Company__c,WhoId FROM Task WHERE WhoId = '#{contactInfo.fetch('Id')}'")[0]
        puts generatedActivityForContact
        validate_case("Activity",generatedActivityForContact,{'Subject'=>'Inbound Lead submission','Locations_Interested__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Locations_Interested__c'],'Company__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Company'],'Lead_Source_Detail__c'=>"Inbound Call Page",'Lead_Source__c'=>"Inbound Call",'Status'=>'Open'})
        @helper.addLogs("[Validate ] : Checking create Journey created on field on contact")
        @helper.addLogs("[Expected ] : Create Journey created on should today")
        @helper.addLogs("[Actual ]   : Create Journey created on on lead is #{contactInfo.fetch("Journey_Created_On__c").inspect}")
        expect(contactInfo .fetch("Journey_Created_On__c")).to match Date.today().to_s
        @helper.addLogs("[Result ]   : Journey created on field checked successfully\n")
        @helper.addLogs('Success')
        @helper.postSuccessResult(2578)
      rescue Exception => e
        @helper.addLogs('Error')
        @helper.postFailResult(e, 2578)
        raise e
      end
    end
    it 'To Check Journey  Created While Importing Existing Contact Which is Owned By Susie Romero Where Activity is not present and existing journey is present where Generate Journey on UI is Checked & in CSV is Blank and assign to the Campaign', :'2677' => 'true' do
      begin
        @helper.addLogs("[Step ]  : Getting existing contact")
        @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Generate_Journey__c'] = true
        contactInfo = @pageObject.getExistingContact("Susie Romero",true,false)
        @helper.addLogs("[Step ]  : Using contact with email => #{contactInfo.fetch('Email')} and id => #{contactInfo.fetch('Id')}")
        @pageObject.upload_csv(contactInfo.fetch('Email'), "", @testDataJSON['Campaign'][0]['Name'], false,false,"Contact")
        expect(contactInfo).to_not eql nil
        @pageObject.checkJobStatus
        owner = @pageObject.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
        contactInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id, email, Owner.Name,Journey_Created_On__c FROM Contact WHERE id = '#{contactInfo.fetch("Id")}'")[0]
        sleep(5)
        insertedJourneyInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,CampaignId__c,Owner.id, Owner.Name,CreatedDate ,Status__c , NMD_Next_Contact_Date__c ,Primary_Email__c , Lead_Source__c , Lead_Source_Detail__c , Primary_Phone__c , Company_Name__c , Building_Interested_In__c , Locations_Interested__c , Interested_in_Number_of_Desks__c , Full_Time_Employees__c, Name   FROM Journey__c WHERE Primary_Email__c = '#{contactInfo.fetch("Email")}'")[0]
        @helper.addLogs("[Validate ] : Checking Journey is created on lead")
        @helper.addLogs("[Expected ] : Journey should be created")
        @helper.addLogs("[Actual ]   : Journey is created with name #{insertedJourneyInfo.fetch("Name")}")
        expect(insertedJourneyInfo).to_not eql nil
        Helper.addRecordsToDelete("Journey__c", insertedJourneyInfo.fetch('Id'))
        @helper.addLogs("[Result ]   : Journey created successfully\n")
        puts "\n"
        validate_case("Journey",insertedJourneyInfo,{'Lead_Source__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['LeadSource'],'lead_Source_Detail__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]["lead_Source_Detail__c"],'NMD_Next_Contact_Date__c'=>contactInfo.fetch("Journey_Created_On__c"),'Primary_Email__c'=>contactInfo.fetch("Email"),'Primary_Phone__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]["Phone"],'Company_Name__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]["Company"],'Status__c'=>'Started','CampaignId__c'=>@campaignId.fetch('Id')})
        @helper.addLogs("[Validate ] : Checking Journey owner should be according to lead owner criteria")
        @helper.addLogs("[Expected ] : Owner of Journey should be owner of lead")
        @helper.addLogs("[Actual ]   : Owner of Journey is #{insertedJourneyInfo.fetch("Owner").fetch("Id")}")
        expect(insertedJourneyInfo.fetch("Owner").fetch("Id")).to match owner
        @helper.addLogs("[Result ]   : Owner checked successfully\n")
        @pageObject.instance_variable_get(:@testDataJSON)['Journey'][0]
        generatedActivityForContact = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Subject , CreatedDate,Status ,Lead_Source__c , Lead_Source_Detail__c,Owner.Name,Locations_Interested__c, Number_of_Full_Time_Employees__c,Interested_in_Number_of_Desks__c,Company__c,WhoId FROM Task WHERE WhoId = '#{contactInfo.fetch('Id')}'")[0]
        puts generatedActivityForContact
        validate_case("Activity",generatedActivityForContact,{'Subject'=>'Inbound Lead submission','Locations_Interested__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Locations_Interested__c'],'Company__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Company'],'Lead_Source_Detail__c'=>"Inbound Call Page",'Lead_Source__c'=>"Inbound Call",'Status'=>'Open'})
        @helper.addLogs("[Validate ] : Checking create Journey created on field on contact")
        @helper.addLogs("[Expected ] : Create Journey created on should today")
        @helper.addLogs("[Actual ]   : Create Journey created on on lead is #{contactInfo.fetch("Journey_Created_On__c").inspect}")
        expect(contactInfo .fetch("Journey_Created_On__c")).to match Date.today().to_s
        @helper.addLogs("[Result ]   : Journey created on field checked successfully\n")
        @helper.addLogs('Success')
        @helper.postSuccessResult(2578)
      rescue Exception => e
        @helper.addLogs('Error')
        @helper.postFailResult(e, 2578)
        raise e
      end
    end
    it 'To Check Journey Created While Importing Existing Contact Which is Owned By Susie Romero Where Activity & Existing Journey is Present, Generate Journey in UI is Checked and in CSv it is Blank and assign to the Campaign based on Lead Owner.', :'2679' => 'true' do
      begin
        @helper.addLogs("[Step ]  : Getting existing contact")
        @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Generate_Journey__c'] = true
        contactInfo = @pageObject.getExistingContact("Susie Romero",true,true)
        @helper.addLogs("[Step ]  : Using contact with email => #{contactInfo.fetch('Email')} and id => #{contactInfo.fetch('Id')}")
        @pageObject.upload_csv(contactInfo.fetch('Email'), "", @testDataJSON['Campaign'][0]['Name'], false,false,"Contact")
        expect(contactInfo).to_not eql nil
        @pageObject.checkJobStatus
        owner = @pageObject.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
        contactInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id, email, Owner.Name,Journey_Created_On__c FROM Contact WHERE id = '#{contactInfo.fetch("Id")}'")[0]
        sleep(5)
        insertedJourneyInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,CampaignId__c,Owner.id, Owner.Name,CreatedDate ,Status__c , NMD_Next_Contact_Date__c ,Primary_Email__c , Lead_Source__c , Lead_Source_Detail__c , Primary_Phone__c , Company_Name__c , Building_Interested_In__c , Locations_Interested__c , Interested_in_Number_of_Desks__c , Full_Time_Employees__c, Name   FROM Journey__c WHERE Primary_Email__c = '#{contactInfo.fetch("Email")}'")[0]
        @helper.addLogs("[Validate ] : Checking Journey is created on lead")
        @helper.addLogs("[Expected ] : Journey should be created")
        @helper.addLogs("[Actual ]   : Journey is created with name #{insertedJourneyInfo.fetch("Name")}")
        expect(insertedJourneyInfo).to_not eql nil
        Helper.addRecordsToDelete("Journey__c", insertedJourneyInfo.fetch('Id'))
        @helper.addLogs("[Result ]   : Journey created successfully\n")
        puts "\n"
        validate_case("Journey",insertedJourneyInfo,{'Lead_Source__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['LeadSource'],'lead_Source_Detail__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]["lead_Source_Detail__c"],'NMD_Next_Contact_Date__c'=>contactInfo.fetch("Journey_Created_On__c"),'Primary_Email__c'=>contactInfo.fetch("Email"),'Primary_Phone__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]["Phone"],'Company_Name__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]["Company"],'Status__c'=>'Started','CampaignId__c'=>@campaignId.fetch('Id')})
        @helper.addLogs("[Validate ] : Checking Journey owner should be according to lead owner criteria")
        @helper.addLogs("[Expected ] : Owner of Journey should be owner of lead")
        @helper.addLogs("[Actual ]   : Owner of Journey is #{insertedJourneyInfo.fetch("Owner").fetch("Id")}")
        expect(insertedJourneyInfo.fetch("Owner").fetch("Id")).to match owner
        @helper.addLogs("[Result ]   : Owner checked successfully\n")
        @pageObject.instance_variable_get(:@testDataJSON)['Journey'][0]
        generatedActivityForContact = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Subject , CreatedDate,Status ,Lead_Source__c , Lead_Source_Detail__c,Owner.Name,Locations_Interested__c, Number_of_Full_Time_Employees__c,Interested_in_Number_of_Desks__c,Company__c,WhoId FROM Task WHERE WhoId = '#{contactInfo.fetch('Id')}'")[0]
        puts generatedActivityForContact
        validate_case("Activity",generatedActivityForContact,{'Subject'=>'Inbound Lead submission','Locations_Interested__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Locations_Interested__c'],'Company__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Company'],'Lead_Source_Detail__c'=>"Inbound Call Page",'Lead_Source__c'=>"Inbound Call",'Status'=>'Open'})
        @helper.addLogs("[Validate ] : Checking create Journey created on field on contact")
        @helper.addLogs("[Expected ] : Create Journey created on should today")
        @helper.addLogs("[Actual ]   : Create Journey created on on lead is #{contactInfo.fetch("Journey_Created_On__c").inspect}")
        expect(contactInfo .fetch("Journey_Created_On__c")).to match Date.today().to_s
        @helper.addLogs("[Result ]   : Journey created on field checked successfully\n")
        @helper.addLogs('Success')
        @helper.postSuccessResult(2578)
      rescue Exception => e
        @helper.addLogs('Error')
        @helper.postFailResult(e, 2578)
        raise e
      end
    end
    it 'To Check Journey not Created While Importing Existing Contact Which is Owned By Susie Romero Where Activity is not present and existing journey is not present where Generate Journey on UI is Unchecked & in CSV is False and assign to the Campaign.', :'2676' => 'true' do
      begin
        @helper.addLogs("[Step ]  : Getting existing contact")
        @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Generate_Journey__c'] = true
        contactInfo = @pageObject.getExistingContact("Susie Romero",true,true)
        @helper.addLogs("[Step ]  : Using contact with email => #{contactInfo.fetch('Email')} and id => #{contactInfo.fetch('Id')}")
        @pageObject.upload_csv(contactInfo.fetch('Email'), "", @testDataJSON['Campaign'][0]['Name'], true,false,"Contact")
        expect(contactInfo).to_not eql nil
        @pageObject.checkJobStatus
        owner = @pageObject.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
        contactInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id, email, Owner.Name,Journey_Created_On__c FROM Contact WHERE id = '#{contactInfo.fetch("Id")}'")[0]
        sleep(5)
        insertedJourneyInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,CampaignId__c,Owner.id, Owner.Name,CreatedDate ,Status__c , NMD_Next_Contact_Date__c ,Primary_Email__c , Lead_Source__c , Lead_Source_Detail__c , Primary_Phone__c , Company_Name__c , Building_Interested_In__c , Locations_Interested__c , Interested_in_Number_of_Desks__c , Full_Time_Employees__c, Name   FROM Journey__c WHERE Primary_Email__c = '#{contactInfo.fetch("Email")}'")[0]
        @helper.addLogs("[Validate ] : Checking Journey is created on lead")
        @helper.addLogs("[Expected ] : Journey should not be created")
        @helper.addLogs("[Actual ]   : Journey is created - #{insertedJourneyInfo.nil? ? "No" : "Yes"}")
        expect(insertedJourneyInfo).to eql nil
        @helper.addLogs("[Result ]   : Journey creation checked successfully\n")
        puts "\n"
        generatedActivityForContact = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Subject , CreatedDate,Status ,Lead_Source__c , Lead_Source_Detail__c,Owner.Name,Locations_Interested__c, Number_of_Full_Time_Employees__c,Interested_in_Number_of_Desks__c,Company__c,WhoId FROM Task WHERE WhoId = '#{contactInfo.fetch('Id')}'")[0]
        puts generatedActivityForContact
        validate_case("Activity",generatedActivityForContact,{'Subject'=>'Inbound Lead submission','Locations_Interested__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Locations_Interested__c'],'Company__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Company'],'Lead_Source_Detail__c'=>"Inbound Call Page",'Lead_Source__c'=>"Inbound Call",'Status'=>'Open'})
        @helper.addLogs("[Validate ] : Checking create Journey created on field on contact")
        @helper.addLogs("[Expected ] : Create Journey created on should today")
        @helper.addLogs("[Actual ]   : Create Journey created on on lead is #{contactInfo.fetch("Journey_Created_On__c").inspect}")
        expect(contactInfo .fetch("Journey_Created_On__c")).to match Date.today().to_s
        @helper.addLogs("[Result ]   : Journey created on field checked successfully\n")
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
    it 'To Check Journey Created While Importing Existing Contact Which is Owned By Susie Romero Where Activity is not present and existing journey is not present where Generate Journey on UI is Checked & in CSV is Blank and assign to the Campaign.', :'2732' => 'true' do
      begin
        @helper.addLogs("[Step ]  : Getting existing contact")
        @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Generate_Journey__c'] = true
        contactInfo = nil
        contactInfo = @pageObject.getExistingContact("",false,false)
        if contactInfo.nil?
          @testDataJSON['Contact'][0]['Email'] = "john.smith_qaauto#{rand(999999999999999999)}@example.com"
          @testDataJSON['Contact'][0]['AccountId'] = @helper.instance_variable_get(:@restForce).getRecords("SELECT id FROM Account WHERE CreatedBy.Name IN ('Veena Hegane','Ashotosh Thakur','Monika Pingale','Kishor Shinde') and isDeleted = false")[0]
          contactInfo = @helper.instance_variable_get(:@restForce).createRecord("Contact",@testDataJSON['Contact'][0])
          Helper.addRecordsToDelete("Contact",contactInfo['Id'])
        end
        @helper.addLogs("[Step ]  : Using contact with email => #{contactInfo.fetch('Email')} and id => #{contactInfo.fetch('Id')}")
        @pageObject.upload_csv(contactInfo.fetch('Email'), "", @testDataJSON['Campaign'][0]['Name'], false,false,"Contact")
        expect(contactInfo).to_not eql nil
        @pageObject.checkJobStatus
        owner = @pageObject.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
        contactInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id, email,Account.Name, Owner.Name,Journey_Created_On__c FROM Contact WHERE id = '#{contactInfo.fetch("Id")}'")[0]
        sleep(5)
        insertedJourneyInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,CampaignId__c,Owner.id, Owner.Name,CreatedDate ,Status__c , NMD_Next_Contact_Date__c ,Primary_Email__c , Lead_Source__c , Lead_Source_Detail__c , Primary_Phone__c , Company_Name__c , Building_Interested_In__c , Locations_Interested__c , Interested_in_Number_of_Desks__c , Full_Time_Employees__c, Name   FROM Journey__c WHERE Primary_Email__c = '#{contactInfo.fetch("Email")}' AND CreatedDate = TODAY")[0]
        @helper.addLogs("[Validate ] : Checking Journey is created on lead")
        @helper.addLogs("[Expected ] : Journey should be created")
        @helper.addLogs("[Actual ]   : Journey is created with name #{insertedJourneyInfo.fetch("Name")}")
        expect(insertedJourneyInfo).to_not eql nil
        Helper.addRecordsToDelete("Journey__c", insertedJourneyInfo.fetch('Id'))
        @helper.addLogs("[Result ]   : Journey created successfully\n")
        puts "\n"
        validate_case("Journey",insertedJourneyInfo,{'Lead_Source__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['LeadSource'],'lead_Source_Detail__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]["lead_Source_Detail__c"],'Primary_Email__c'=>contactInfo.fetch("Email"),'Primary_Phone__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]["Phone"],'Company_Name__c'=>contactInfo.fetch('Account').fetch('Name'),'Status__c'=>'Started','CampaignId__c'=>@campaignId.fetch('Id')})
        @helper.addLogs("[Validate ] : Checking Journey owner should be according to lead owner criteria")
        @helper.addLogs("[Expected ] : Owner of Journey should be owner of lead")
        @helper.addLogs("[Actual ]   : Owner of Journey is #{insertedJourneyInfo.fetch("Owner").fetch("Id")}")
        expect(insertedJourneyInfo.fetch("Owner").fetch("Id")).to match owner
        @helper.addLogs("[Result ]   : Owner checked successfully\n")
        generatedActivityForContact = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Subject , CreatedDate,Status ,Lead_Source__c , Lead_Source_Detail__c,Owner.Name,Locations_Interested__c, Number_of_Full_Time_Employees__c,Interested_in_Number_of_Desks__c,Company__c,WhoId FROM Task WHERE WhoId = '#{contactInfo.fetch('Id')}' AND status != 'Completed' AND CreatedDate = TODAY")[0]

        Helper.addRecordsToDelete("Task", generatedActivityForContact.fetch('Id'))
        validate_case("Activity",generatedActivityForContact,{'Subject'=>'Inbound Lead submission','Locations_Interested__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Building_Interested_In__c'],'Company__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Company'],'Lead_Source_Detail__c'=>"Inbound Call Page",'Lead_Source__c'=>"Inbound Call",'Status'=>'Open'})
        @helper.addLogs("[Validate ] : Checking create Journey created on field on contact")
        @helper.addLogs("[Expected ] : Create Journey created on should today")
        @helper.addLogs("[Actual ]   : Create Journey created on on lead is #{contactInfo.fetch("Journey_Created_On__c").inspect}")
        expect(contactInfo .fetch("Journey_Created_On__c")).to match Date.today().to_s
        @helper.addLogs("[Result ]   : Journey created on field checked successfully\n")
        @helper.addLogs('Success')
        @helper.postSuccessResult(2636)
      rescue Exception => e
        @helper.addLogs('Error')
        @helper.postFailResult(e, 2636)
        raise e
      end
    end
    it 'To Check Journey Created While Importing Existing Contact Which is Owned By Susie Romero Where Activity is not present and existing journey is not present where Generate Journey on UI is UnChecked & in CSV is True and assign to the Campaign.', :'2733' => 'true' do
      begin
        @helper.addLogs("[Step ]  : Getting existing contact")
        @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Generate_Journey__c'] = true
        contactInfo = @pageObject.getExistingContact("",false,false)
        @helper.addLogs("[Step ]  : Using contact with email => #{contactInfo.fetch('Email')} and id => #{contactInfo.fetch('Id')}")
        @pageObject.upload_csv(contactInfo.fetch('Email'), "TRUE", @testDataJSON['Campaign'][0]['Name'], true,false,"Contact")
        expect(contactInfo).to_not eql nil
        @pageObject.checkJobStatus
        owner = @pageObject.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
        contactInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id, email, Owner.Name,Journey_Created_On__c FROM Contact WHERE id = '#{contactInfo.fetch("Id")}'")[0]
        sleep(5)
        insertedJourneyInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,CampaignId__c,Owner.id, Owner.Name,CreatedDate ,Status__c , NMD_Next_Contact_Date__c ,Primary_Email__c , Lead_Source__c , Lead_Source_Detail__c , Primary_Phone__c , Company_Name__c , Building_Interested_In__c , Locations_Interested__c , Interested_in_Number_of_Desks__c , Full_Time_Employees__c, Name   FROM Journey__c WHERE Primary_Email__c = '#{contactInfo.fetch("Email")}'")[0]
        @helper.addLogs("[Validate ] : Checking Journey is created on lead")
        @helper.addLogs("[Expected ] : Journey should be created")
        @helper.addLogs("[Actual ]   : Journey is created with name #{insertedJourneyInfo.fetch("Name")}")
        expect(insertedJourneyInfo).to_not eql nil
        Helper.addRecordsToDelete("Journey__c", insertedJourneyInfo.fetch('Id'))
        @helper.addLogs("[Result ]   : Journey created successfully\n")
        puts "\n"
        validate_case("Journey",insertedJourneyInfo,{'Lead_Source__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['LeadSource'],'lead_Source_Detail__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]["lead_Source_Detail__c"],'NMD_Next_Contact_Date__c'=>contactInfo.fetch("Journey_Created_On__c"),'Primary_Email__c'=>contactInfo.fetch("Email"),'Primary_Phone__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]["Phone"],'Company_Name__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]["Company"],'Status__c'=>'Started','CampaignId__c'=>@campaignId.fetch('Id')})
        @helper.addLogs("[Validate ] : Checking Journey owner should be according to lead owner criteria")
        @helper.addLogs("[Expected ] : Owner of Journey should be owner of lead")
        @helper.addLogs("[Actual ]   : Owner of Journey is #{insertedJourneyInfo.fetch("Owner").fetch("Id")}")
        expect(insertedJourneyInfo.fetch("Owner").fetch("Id")).to match owner
        @helper.addLogs("[Result ]   : Owner checked successfully\n")
        @pageObject.instance_variable_get(:@testDataJSON)['Journey'][0]
        generatedActivityForContact = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Subject , CreatedDate,Status ,Lead_Source__c , Lead_Source_Detail__c,Owner.Name,Locations_Interested__c, Number_of_Full_Time_Employees__c,Interested_in_Number_of_Desks__c,Company__c,WhoId FROM Task WHERE WhoId = '#{contactInfo.fetch('Id')}'")[0]
        puts generatedActivityForContact
        validate_case("Activity",generatedActivityForContact,{'Subject'=>'Inbound Lead submission','Locations_Interested__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Locations_Interested__c'],'Company__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Company'],'Lead_Source_Detail__c'=>"Inbound Call Page",'Lead_Source__c'=>"Inbound Call",'Status'=>'Open'})
        @helper.addLogs("[Validate ] : Checking create Journey created on field on contact")
        @helper.addLogs("[Expected ] : Create Journey created on should today")
        @helper.addLogs("[Actual ]   : Create Journey created on on lead is #{contactInfo.fetch("Journey_Created_On__c").inspect}")
        expect(contactInfo .fetch("Journey_Created_On__c")).to match Date.today().to_s
        @helper.addLogs("[Result ]   : Journey created on field checked successfully\n")
        @helper.addLogs('Success')
        @helper.postSuccessResult(2637)
      rescue Exception => e
        @helper.addLogs('Error')
        @helper.postFailResult(e, 2637)
        raise e
      end
    end
    it 'To Check Journey Created While Importing Existing Contact Which is Owned By Susie Romero Where Activity is not present and existing journey is present where Generate Journey on UI is Checked & in CSV is Blank and assign to the Campaign.', :'2735' => 'true' do
      begin
        @helper.addLogs("[Step ]  : Getting existing contact")
        @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Generate_Journey__c'] = true
        contactInfo = @pageObject.getExistingContact("",true,false)
        @helper.addLogs("[Step ]  : Using contact with email => #{contactInfo.fetch('Email')} and id => #{contactInfo.fetch('Id')}")
        @pageObject.upload_csv(contactInfo.fetch('Email'), "", @testDataJSON['Campaign'][0]['Name'], false,false,"Contact")
        expect(contactInfo).to_not eql nil
        @pageObject.checkJobStatus
        owner = @pageObject.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
        contactInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id, email, Owner.Name,Journey_Created_On__c FROM Contact WHERE id = '#{contactInfo.fetch("Id")}'")[0]
        sleep(5)
        insertedJourneyInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,CampaignId__c,Owner.id, Owner.Name,CreatedDate ,Status__c , NMD_Next_Contact_Date__c ,Primary_Email__c , Lead_Source__c , Lead_Source_Detail__c , Primary_Phone__c , Company_Name__c , Building_Interested_In__c , Locations_Interested__c , Interested_in_Number_of_Desks__c , Full_Time_Employees__c, Name   FROM Journey__c WHERE Primary_Email__c = '#{contactInfo.fetch("Email")}'")[0]
        @helper.addLogs("[Validate ] : Checking Journey is created on lead")
        @helper.addLogs("[Expected ] : Journey should be created")
        @helper.addLogs("[Actual ]   : Journey is created with name #{insertedJourneyInfo.fetch("Name")}")
        expect(insertedJourneyInfo).to_not eql nil
        Helper.addRecordsToDelete("Journey__c", insertedJourneyInfo.fetch('Id'))
        @helper.addLogs("[Result ]   : Journey created successfully\n")
        puts "\n"
        validate_case("Journey",insertedJourneyInfo,{'Lead_Source__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['LeadSource'],'lead_Source_Detail__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]["lead_Source_Detail__c"],'NMD_Next_Contact_Date__c'=>contactInfo.fetch("Journey_Created_On__c"),'Primary_Email__c'=>contactInfo.fetch("Email"),'Primary_Phone__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]["Phone"],'Company_Name__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]["Company"],'Status__c'=>'Started','CampaignId__c'=>@campaignId.fetch('Id')})
        @helper.addLogs("[Validate ] : Checking Journey owner should be according to lead owner criteria")
        @helper.addLogs("[Expected ] : Owner of Journey should be owner of lead")
        @helper.addLogs("[Actual ]   : Owner of Journey is #{insertedJourneyInfo.fetch("Owner").fetch("Id")}")
        expect(insertedJourneyInfo.fetch("Owner").fetch("Id")).to match owner
        @helper.addLogs("[Result ]   : Owner checked successfully\n")
        @pageObject.instance_variable_get(:@testDataJSON)['Journey'][0]
        generatedActivityForContact = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Subject , CreatedDate,Status ,Lead_Source__c , Lead_Source_Detail__c,Owner.Name,Locations_Interested__c, Number_of_Full_Time_Employees__c,Interested_in_Number_of_Desks__c,Company__c,WhoId FROM Task WHERE WhoId = '#{contactInfo.fetch('Id')}'")[0]
        puts generatedActivityForContact
        validate_case("Activity",generatedActivityForContact,{'Subject'=>'Inbound Lead submission','Locations_Interested__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Locations_Interested__c'],'Company__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Company'],'Lead_Source_Detail__c'=>"Inbound Call Page",'Lead_Source__c'=>"Inbound Call",'Status'=>'Open'})
        @helper.addLogs("[Validate ] : Checking create Journey created on field on contact")
        @helper.addLogs("[Expected ] : Create Journey created on should today")
        @helper.addLogs("[Actual ]   : Create Journey created on on lead is #{contactInfo.fetch("Journey_Created_On__c").inspect}")
        expect(contactInfo .fetch("Journey_Created_On__c")).to match Date.today().to_s
        @helper.addLogs("[Result ]   : Journey created on field checked successfully\n")
        @helper.addLogs('Success')
        @helper.postSuccessResult(2639)
      rescue Exception => e
        @helper.addLogs('Error')
        @helper.postFailResult(e, 2639)
        raise e
      end
    end
    it 'To Check Journey Created While Importing Existing Contact Which is Owned By Susie Romero Where Activity is  present and existing journey is present where Generate Journey on UI is Checked & in CSV is Blank and assign to the Campaign.', :'2737' => 'true' do
      begin
        @helper.addLogs("[Step ]  : Getting existing contact")
        @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Generate_Journey__c'] = true
        contactInfo = @pageObject.getExistingContact("",true,true)
        @helper.addLogs("[Step ]  : Using contact with email => #{contactInfo.fetch('Email')} and id => #{contactInfo.fetch('Id')}")
        @pageObject.upload_csv(contactInfo.fetch('Email'), "", @testDataJSON['Campaign'][0]['Name'], false,false,"Contact")
        expect(contactInfo).to_not eql nil
        @pageObject.checkJobStatus
        owner = @pageObject.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
        contactInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id, email, Owner.Name,Journey_Created_On__c FROM Contact WHERE id = '#{contactInfo.fetch("Id")}'")[0]
        sleep(5)
        insertedJourneyInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,CampaignId__c,Owner.id, Owner.Name,CreatedDate ,Status__c , NMD_Next_Contact_Date__c ,Primary_Email__c , Lead_Source__c , Lead_Source_Detail__c , Primary_Phone__c , Company_Name__c , Building_Interested_In__c , Locations_Interested__c , Interested_in_Number_of_Desks__c , Full_Time_Employees__c, Name   FROM Journey__c WHERE Primary_Email__c = '#{contactInfo.fetch("Email")}'")[0]
        @helper.addLogs("[Validate ] : Checking Journey is created on lead")
        @helper.addLogs("[Expected ] : Journey should be created")
        @helper.addLogs("[Actual ]   : Journey is created with name #{insertedJourneyInfo.fetch("Name")}")
        expect(insertedJourneyInfo).to_not eql nil
        Helper.addRecordsToDelete("Journey__c", insertedJourneyInfo.fetch('Id'))
        @helper.addLogs("[Result ]   : Journey created successfully\n")
        puts "\n"
        validate_case("Journey",insertedJourneyInfo,{'Lead_Source__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['LeadSource'],'lead_Source_Detail__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]["lead_Source_Detail__c"],'NMD_Next_Contact_Date__c'=>contactInfo.fetch("Journey_Created_On__c"),'Primary_Email__c'=>contactInfo.fetch("Email"),'Primary_Phone__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]["Phone"],'Company_Name__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]["Company"],'Status__c'=>'Started','CampaignId__c'=>@campaignId.fetch('Id')})
        @helper.addLogs("[Validate ] : Checking Journey owner should be according to lead owner criteria")
        @helper.addLogs("[Expected ] : Owner of Journey should be owner of lead")
        @helper.addLogs("[Actual ]   : Owner of Journey is #{insertedJourneyInfo.fetch("Owner").fetch("Id")}")
        expect(insertedJourneyInfo.fetch("Owner").fetch("Id")).to match owner
        @helper.addLogs("[Result ]   : Owner checked successfully\n")
        @pageObject.instance_variable_get(:@testDataJSON)['Journey'][0]
        generatedActivityForContact = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Subject , CreatedDate,Status ,Lead_Source__c , Lead_Source_Detail__c,Owner.Name,Locations_Interested__c, Number_of_Full_Time_Employees__c,Interested_in_Number_of_Desks__c,Company__c,WhoId FROM Task WHERE WhoId = '#{contactInfo.fetch('Id')}'")[0]
        puts generatedActivityForContact
        validate_case("Activity",generatedActivityForContact,{'Subject'=>'Inbound Lead submission','Locations_Interested__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Locations_Interested__c'],'Company__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Company'],'Lead_Source_Detail__c'=>"Inbound Call Page",'Lead_Source__c'=>"Inbound Call",'Status'=>'Open'})
        @helper.addLogs("[Validate ] : Checking create Journey created on field on contact")
        @helper.addLogs("[Expected ] : Create Journey created on should today")
        @helper.addLogs("[Actual ]   : Create Journey created on on lead is #{contactInfo.fetch("Journey_Created_On__c").inspect}")
        expect(contactInfo .fetch("Journey_Created_On__c")).to match Date.today().to_s
        @helper.addLogs("[Result ]   : Journey created on field checked successfully\n")
        @helper.addLogs('Success')
        @helper.postSuccessResult(2578)
      rescue Exception => e
        @helper.addLogs('Error')
        @helper.postFailResult(e, 2578)
        raise e
      end
    end
    it 'To Check Journey not Created While Importing Existing Contact Which is Owned By Susie Romero Where Activity is not present and existing journey is not present where Generate Journey on UI is UnChecked & in CSV is false and assign to the Campaign.', :'2734' => 'true' do
      begin
        @helper.addLogs("[Step ]  : Getting existing contact")
        @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Generate_Journey__c'] = true
        contactInfo = @pageObject.getExistingContact("",true,true)
        @helper.addLogs("[Step ]  : Using contact with email => #{contactInfo.fetch('Email')} and id => #{contactInfo.fetch('Id')}")
        @pageObject.upload_csv(contactInfo.fetch('Email'), "", @testDataJSON['Campaign'][0]['Name'], true,false,"Contact")
        expect(contactInfo).to_not eql nil
        @pageObject.checkJobStatus
        owner = @pageObject.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
        contactInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id, email, Owner.Name,Journey_Created_On__c FROM Contact WHERE id = '#{contactInfo.fetch("Id")}'")[0]
        sleep(5)
        insertedJourneyInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,CampaignId__c,Owner.id, Owner.Name,CreatedDate ,Status__c , NMD_Next_Contact_Date__c ,Primary_Email__c , Lead_Source__c , Lead_Source_Detail__c , Primary_Phone__c , Company_Name__c , Building_Interested_In__c , Locations_Interested__c , Interested_in_Number_of_Desks__c , Full_Time_Employees__c, Name   FROM Journey__c WHERE Primary_Email__c = '#{contactInfo.fetch("Email")}'")[0]
        @helper.addLogs("[Validate ] : Checking Journey is created on lead")
        @helper.addLogs("[Expected ] : Journey should not be created")
        @helper.addLogs("[Actual ]   : Journey is created - #{insertedJourneyInfo.nil? ? "No" : "Yes"}")
        expect(insertedJourneyInfo).to eql nil
        @helper.addLogs("[Result ]   : Journey creation checked successfully\n")
        puts "\n"
        generatedActivityForContact = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Subject , CreatedDate,Status ,Lead_Source__c , Lead_Source_Detail__c,Owner.Name,Locations_Interested__c, Number_of_Full_Time_Employees__c,Interested_in_Number_of_Desks__c,Company__c,WhoId FROM Task WHERE WhoId = '#{contactInfo.fetch('Id')}'")[0]
        puts generatedActivityForContact
        validate_case("Activity",generatedActivityForContact,{'Subject'=>'Inbound Lead submission','Locations_Interested__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Locations_Interested__c'],'Company__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Company'],'Lead_Source_Detail__c'=>"Inbound Call Page",'Lead_Source__c'=>"Inbound Call",'Status'=>'Open'})
        @helper.addLogs("[Validate ] : Checking create Journey created on field on contact")
        @helper.addLogs("[Expected ] : Create Journey created on should today")
        @helper.addLogs("[Actual ]   : Create Journey created on on lead is #{contactInfo.fetch("Journey_Created_On__c").inspect}")
        expect(contactInfo .fetch("Journey_Created_On__c")).to match Date.today().to_s
        @helper.addLogs("[Result ]   : Journey created on field checked successfully\n")
        @helper.addLogs('Success')
        @helper.postSuccessResult(2622)
      rescue Exception => e
        @helper.addLogs('Error')
        @helper.postFailResult(e, 2622)
        raise e
      end
    end
  end
  context "Kickbox Importer While Insertion of Existing Contact which is Owned by Susie Romero from Kickbox and assign to the Particular Campaign Based on City Criterias",'325'=>'true' do
    before(:all) do
      @testDataJSON['Campaign'][0]['Lead Owner'] = ''
      @testDataJSON['Campaign'][0]['Email Address'] = 'vikhroliwest@wework.co.in'
      @testDataJSON['Campaign'][0]['City'] = ''
      @campaignId = @helper.instance_variable_get(:@restForce).getRecords("SELECT id FROM Campaign WHERE Name = '#{@testDataJSON['Campaign'][0]['Name']}'")[0]
      @helper.update_campaign(@campaignId.fetch('Id'),nil,@testDataJSON['Campaign'][0]['Email Address'])
    end
    it 'To Check Journey Created While Importing Existing Contact Which is Owned By Susie Romero Where Activity is not present and existing journey is not present where Generate Journey on UI is Checked & in CSV is Blank and assign to the Campaign.', :'2738' => 'true' do
      begin
        @helper.addLogs("[Step ]  : Getting existing contact")
        @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Generate_Journey__c'] = true
        contactInfo = nil
        contactInfo = @pageObject.getExistingContact("",false,false)
        if contactInfo.nil?
          @testDataJSON['Contact'][0]['Email'] = "john.smith_qaauto#{rand(999999999999999999)}@example.com"
          @testDataJSON['Contact'][0]['AccountId'] = @helper.instance_variable_get(:@restForce).getRecords("SELECT id FROM Account WHERE CreatedBy.Name IN ('Veena Hegane','Ashotosh Thakur','Monika Pingale','Kishor Shinde') and isDeleted = false")[0]
          contactInfo = @helper.instance_variable_get(:@restForce).createRecord("Contact",@testDataJSON['Contact'][0])
          Helper.addRecordsToDelete("Contact",contactInfo['Id'])
        end
        @helper.addLogs("[Step ]  : Using contact with email => #{contactInfo.fetch('Email')} and id => #{contactInfo.fetch('Id')}")
        @pageObject.upload_csv(contactInfo.fetch('Email'), "", @testDataJSON['Campaign'][0]['Name'], false,false,"Contact")
        expect(contactInfo).to_not eql nil
        @pageObject.checkJobStatus
        owner = @pageObject.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
        contactInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id, email,Account.Name, Owner.Name,Journey_Created_On__c FROM Contact WHERE id = '#{contactInfo.fetch("Id")}'")[0]
        sleep(5)
        insertedJourneyInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,CampaignId__c,Owner.id, Owner.Name,CreatedDate ,Status__c , NMD_Next_Contact_Date__c ,Primary_Email__c , Lead_Source__c , Lead_Source_Detail__c , Primary_Phone__c , Company_Name__c , Building_Interested_In__c , Locations_Interested__c , Interested_in_Number_of_Desks__c , Full_Time_Employees__c, Name   FROM Journey__c WHERE Primary_Email__c = '#{contactInfo.fetch("Email")}' AND CreatedDate = TODAY")[0]
        @helper.addLogs("[Validate ] : Checking Journey is created on lead")
        @helper.addLogs("[Expected ] : Journey should be created")
        @helper.addLogs("[Actual ]   : Journey is created with name #{insertedJourneyInfo.fetch("Name")}")
        expect(insertedJourneyInfo).to_not eql nil
        Helper.addRecordsToDelete("Journey__c", insertedJourneyInfo.fetch('Id'))
        @helper.addLogs("[Result ]   : Journey created successfully\n")
        puts "\n"
        validate_case("Journey",insertedJourneyInfo,{'Lead_Source__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['LeadSource'],'lead_Source_Detail__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]["lead_Source_Detail__c"],'Primary_Email__c'=>contactInfo.fetch("Email"),'Primary_Phone__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]["Phone"],'Company_Name__c'=>contactInfo.fetch('Account').fetch('Name'),'Status__c'=>'Started','CampaignId__c'=>@campaignId.fetch('Id')})
        @helper.addLogs("[Validate ] : Checking Journey owner should be according to lead owner criteria")
        @helper.addLogs("[Expected ] : Owner of Journey should be owner of lead")
        @helper.addLogs("[Actual ]   : Owner of Journey is #{insertedJourneyInfo.fetch("Owner").fetch("Id")}")
        expect(insertedJourneyInfo.fetch("Owner").fetch("Id")).to match owner
        @helper.addLogs("[Result ]   : Owner checked successfully\n")
        generatedActivityForContact = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Subject , CreatedDate,Status ,Lead_Source__c , Lead_Source_Detail__c,Owner.Name,Locations_Interested__c, Number_of_Full_Time_Employees__c,Interested_in_Number_of_Desks__c,Company__c,WhoId FROM Task WHERE WhoId = '#{contactInfo.fetch('Id')}' AND status != 'Completed' AND CreatedDate = TODAY")[0]

        Helper.addRecordsToDelete("Task", generatedActivityForContact.fetch('Id'))
        validate_case("Activity",generatedActivityForContact,{'Subject'=>'Inbound Lead submission','Locations_Interested__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Building_Interested_In__c'],'Company__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Company'],'Lead_Source_Detail__c'=>"Inbound Call Page",'Lead_Source__c'=>"Inbound Call",'Status'=>'Open'})
        @helper.addLogs("[Validate ] : Checking create Journey created on field on contact")
        @helper.addLogs("[Expected ] : Create Journey created on should today")
        @helper.addLogs("[Actual ]   : Create Journey created on on lead is #{contactInfo.fetch("Journey_Created_On__c").inspect}")
        expect(contactInfo .fetch("Journey_Created_On__c")).to match Date.today().to_s
        @helper.addLogs("[Result ]   : Journey created on field checked successfully\n")
        @helper.addLogs('Success')
        @helper.postSuccessResult(2636)
      rescue Exception => e
        @helper.addLogs('Error')
        @helper.postFailResult(e, 2636)
        raise e
      end
    end
    it 'To Check Journey Created While Importing Existing Contact Which is Owned By Susie Romero Where Activity is not present and existing journey is not present where Generate Journey on UI is UnChecked & in CSV is True and assign to the Campaign.', :'2741' => 'true' do
      begin
        @helper.addLogs("[Step ]  : Getting existing contact")
        @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Generate_Journey__c'] = true
        contactInfo = @pageObject.getExistingContact("",false,false)
        @helper.addLogs("[Step ]  : Using contact with email => #{contactInfo.fetch('Email')} and id => #{contactInfo.fetch('Id')}")
        @pageObject.upload_csv(contactInfo.fetch('Email'), "TRUE", @testDataJSON['Campaign'][0]['Name'], true,false,"Contact")
        expect(contactInfo).to_not eql nil
        @pageObject.checkJobStatus
        owner = @pageObject.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
        contactInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id, email, Owner.Name,Journey_Created_On__c FROM Contact WHERE id = '#{contactInfo.fetch("Id")}'")[0]
        sleep(5)
        insertedJourneyInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,CampaignId__c,Owner.id, Owner.Name,CreatedDate ,Status__c , NMD_Next_Contact_Date__c ,Primary_Email__c , Lead_Source__c , Lead_Source_Detail__c , Primary_Phone__c , Company_Name__c , Building_Interested_In__c , Locations_Interested__c , Interested_in_Number_of_Desks__c , Full_Time_Employees__c, Name   FROM Journey__c WHERE Primary_Email__c = '#{contactInfo.fetch("Email")}'")[0]
        @helper.addLogs("[Validate ] : Checking Journey is created on lead")
        @helper.addLogs("[Expected ] : Journey should be created")
        @helper.addLogs("[Actual ]   : Journey is created with name #{insertedJourneyInfo.fetch("Name")}")
        expect(insertedJourneyInfo).to_not eql nil
        Helper.addRecordsToDelete("Journey__c", insertedJourneyInfo.fetch('Id'))
        @helper.addLogs("[Result ]   : Journey created successfully\n")
        puts "\n"
        validate_case("Journey",insertedJourneyInfo,{'Lead_Source__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['LeadSource'],'lead_Source_Detail__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]["lead_Source_Detail__c"],'NMD_Next_Contact_Date__c'=>contactInfo.fetch("Journey_Created_On__c"),'Primary_Email__c'=>contactInfo.fetch("Email"),'Primary_Phone__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]["Phone"],'Company_Name__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]["Company"],'Status__c'=>'Started','CampaignId__c'=>@campaignId.fetch('Id')})
        @helper.addLogs("[Validate ] : Checking Journey owner should be according to lead owner criteria")
        @helper.addLogs("[Expected ] : Owner of Journey should be owner of lead")
        @helper.addLogs("[Actual ]   : Owner of Journey is #{insertedJourneyInfo.fetch("Owner").fetch("Id")}")
        expect(insertedJourneyInfo.fetch("Owner").fetch("Id")).to match owner
        @helper.addLogs("[Result ]   : Owner checked successfully\n")
        @pageObject.instance_variable_get(:@testDataJSON)['Journey'][0]
        generatedActivityForContact = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Subject , CreatedDate,Status ,Lead_Source__c , Lead_Source_Detail__c,Owner.Name,Locations_Interested__c, Number_of_Full_Time_Employees__c,Interested_in_Number_of_Desks__c,Company__c,WhoId FROM Task WHERE WhoId = '#{contactInfo.fetch('Id')}'")[0]
        puts generatedActivityForContact
        validate_case("Activity",generatedActivityForContact,{'Subject'=>'Inbound Lead submission','Locations_Interested__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Locations_Interested__c'],'Company__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Company'],'Lead_Source_Detail__c'=>"Inbound Call Page",'Lead_Source__c'=>"Inbound Call",'Status'=>'Open'})
        @helper.addLogs("[Validate ] : Checking create Journey created on field on contact")
        @helper.addLogs("[Expected ] : Create Journey created on should today")
        @helper.addLogs("[Actual ]   : Create Journey created on on lead is #{contactInfo.fetch("Journey_Created_On__c").inspect}")
        expect(contactInfo .fetch("Journey_Created_On__c")).to match Date.today().to_s
        @helper.addLogs("[Result ]   : Journey created on field checked successfully\n")
        @helper.addLogs('Success')
        @helper.postSuccessResult(2637)
      rescue Exception => e
        @helper.addLogs('Error')
        @helper.postFailResult(e, 2637)
        raise e
      end
    end
    it 'To Check Journey Created While Importing Existing Contact Which is Owned By Susie Romero Where Activity is not present and existing journey is present where Generate Journey on UI is Checked & in CSV is Blank and assign to the Campaign.', :'2743' => 'true' do
      begin
        @helper.addLogs("[Step ]  : Getting existing contact")
        @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Generate_Journey__c'] = true
        contactInfo = @pageObject.getExistingContact("",true,false)
        @helper.addLogs("[Step ]  : Using contact with email => #{contactInfo.fetch('Email')} and id => #{contactInfo.fetch('Id')}")
        @pageObject.upload_csv(contactInfo.fetch('Email'), "", @testDataJSON['Campaign'][0]['Name'], false,false,"Contact")
        expect(contactInfo).to_not eql nil
        @pageObject.checkJobStatus
        owner = @pageObject.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
        contactInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id, email, Owner.Name,Journey_Created_On__c FROM Contact WHERE id = '#{contactInfo.fetch("Id")}'")[0]
        sleep(5)
        insertedJourneyInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,CampaignId__c,Owner.id, Owner.Name,CreatedDate ,Status__c , NMD_Next_Contact_Date__c ,Primary_Email__c , Lead_Source__c , Lead_Source_Detail__c , Primary_Phone__c , Company_Name__c , Building_Interested_In__c , Locations_Interested__c , Interested_in_Number_of_Desks__c , Full_Time_Employees__c, Name   FROM Journey__c WHERE Primary_Email__c = '#{contactInfo.fetch("Email")}'")[0]
        @helper.addLogs("[Validate ] : Checking Journey is created on lead")
        @helper.addLogs("[Expected ] : Journey should be created")
        @helper.addLogs("[Actual ]   : Journey is created with name #{insertedJourneyInfo.fetch("Name")}")
        expect(insertedJourneyInfo).to_not eql nil
        Helper.addRecordsToDelete("Journey__c", insertedJourneyInfo.fetch('Id'))
        @helper.addLogs("[Result ]   : Journey created successfully\n")
        puts "\n"
        validate_case("Journey",insertedJourneyInfo,{'Lead_Source__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['LeadSource'],'lead_Source_Detail__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]["lead_Source_Detail__c"],'NMD_Next_Contact_Date__c'=>contactInfo.fetch("Journey_Created_On__c"),'Primary_Email__c'=>contactInfo.fetch("Email"),'Primary_Phone__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]["Phone"],'Company_Name__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]["Company"],'Status__c'=>'Started','CampaignId__c'=>@campaignId.fetch('Id')})
        @helper.addLogs("[Validate ] : Checking Journey owner should be according to lead owner criteria")
        @helper.addLogs("[Expected ] : Owner of Journey should be owner of lead")
        @helper.addLogs("[Actual ]   : Owner of Journey is #{insertedJourneyInfo.fetch("Owner").fetch("Id")}")
        expect(insertedJourneyInfo.fetch("Owner").fetch("Id")).to match owner
        @helper.addLogs("[Result ]   : Owner checked successfully\n")
        @pageObject.instance_variable_get(:@testDataJSON)['Journey'][0]
        generatedActivityForContact = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Subject , CreatedDate,Status ,Lead_Source__c , Lead_Source_Detail__c,Owner.Name,Locations_Interested__c, Number_of_Full_Time_Employees__c,Interested_in_Number_of_Desks__c,Company__c,WhoId FROM Task WHERE WhoId = '#{contactInfo.fetch('Id')}'")[0]
        puts generatedActivityForContact
        validate_case("Activity",generatedActivityForContact,{'Subject'=>'Inbound Lead submission','Locations_Interested__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Locations_Interested__c'],'Company__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Company'],'Lead_Source_Detail__c'=>"Inbound Call Page",'Lead_Source__c'=>"Inbound Call",'Status'=>'Open'})
        @helper.addLogs("[Validate ] : Checking create Journey created on field on contact")
        @helper.addLogs("[Expected ] : Create Journey created on should today")
        @helper.addLogs("[Actual ]   : Create Journey created on on lead is #{contactInfo.fetch("Journey_Created_On__c").inspect}")
        expect(contactInfo .fetch("Journey_Created_On__c")).to match Date.today().to_s
        @helper.addLogs("[Result ]   : Journey created on field checked successfully\n")
        @helper.addLogs('Success')
        @helper.postSuccessResult(2639)
      rescue Exception => e
        @helper.addLogs('Error')
        @helper.postFailResult(e, 2639)
        raise e
      end
    end
    it 'To Check Journey Created While Importing Existing Contact Which is Owned By Susie Romero Where Activity is  present and existing journey is present where Generate Journey on UI is Checked & in CSV is Blank and assign to the Campaign.', :'2744' => 'true' do
      begin
        @helper.addLogs("[Step ]  : Getting existing contact")
        @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Generate_Journey__c'] = true
        contactInfo = @pageObject.getExistingContact("",true,true)
        @helper.addLogs("[Step ]  : Using contact with email => #{contactInfo.fetch('Email')} and id => #{contactInfo.fetch('Id')}")
        @pageObject.upload_csv(contactInfo.fetch('Email'), "", @testDataJSON['Campaign'][0]['Name'], false,false,"Contact")
        expect(contactInfo).to_not eql nil
        @pageObject.checkJobStatus
        owner = @pageObject.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
        contactInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id, email, Owner.Name,Journey_Created_On__c FROM Contact WHERE id = '#{contactInfo.fetch("Id")}'")[0]
        sleep(5)
        insertedJourneyInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,CampaignId__c,Owner.id, Owner.Name,CreatedDate ,Status__c , NMD_Next_Contact_Date__c ,Primary_Email__c , Lead_Source__c , Lead_Source_Detail__c , Primary_Phone__c , Company_Name__c , Building_Interested_In__c , Locations_Interested__c , Interested_in_Number_of_Desks__c , Full_Time_Employees__c, Name   FROM Journey__c WHERE Primary_Email__c = '#{contactInfo.fetch("Email")}'")[0]
        @helper.addLogs("[Validate ] : Checking Journey is created on lead")
        @helper.addLogs("[Expected ] : Journey should be created")
        @helper.addLogs("[Actual ]   : Journey is created with name #{insertedJourneyInfo.fetch("Name")}")
        expect(insertedJourneyInfo).to_not eql nil
        Helper.addRecordsToDelete("Journey__c", insertedJourneyInfo.fetch('Id'))
        @helper.addLogs("[Result ]   : Journey created successfully\n")
        puts "\n"
        validate_case("Journey",insertedJourneyInfo,{'Lead_Source__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['LeadSource'],'lead_Source_Detail__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]["lead_Source_Detail__c"],'NMD_Next_Contact_Date__c'=>contactInfo.fetch("Journey_Created_On__c"),'Primary_Email__c'=>contactInfo.fetch("Email"),'Primary_Phone__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]["Phone"],'Company_Name__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]["Company"],'Status__c'=>'Started','CampaignId__c'=>@campaignId.fetch('Id')})
        @helper.addLogs("[Validate ] : Checking Journey owner should be according to lead owner criteria")
        @helper.addLogs("[Expected ] : Owner of Journey should be owner of lead")
        @helper.addLogs("[Actual ]   : Owner of Journey is #{insertedJourneyInfo.fetch("Owner").fetch("Id")}")
        expect(insertedJourneyInfo.fetch("Owner").fetch("Id")).to match owner
        @helper.addLogs("[Result ]   : Owner checked successfully\n")
        @pageObject.instance_variable_get(:@testDataJSON)['Journey'][0]
        generatedActivityForContact = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Subject , CreatedDate,Status ,Lead_Source__c , Lead_Source_Detail__c,Owner.Name,Locations_Interested__c, Number_of_Full_Time_Employees__c,Interested_in_Number_of_Desks__c,Company__c,WhoId FROM Task WHERE WhoId = '#{contactInfo.fetch('Id')}'")[0]
        puts generatedActivityForContact
        validate_case("Activity",generatedActivityForContact,{'Subject'=>'Inbound Lead submission','Locations_Interested__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Locations_Interested__c'],'Company__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Company'],'Lead_Source_Detail__c'=>"Inbound Call Page",'Lead_Source__c'=>"Inbound Call",'Status'=>'Open'})
        @helper.addLogs("[Validate ] : Checking create Journey created on field on contact")
        @helper.addLogs("[Expected ] : Create Journey created on should today")
        @helper.addLogs("[Actual ]   : Create Journey created on on lead is #{contactInfo.fetch("Journey_Created_On__c").inspect}")
        expect(contactInfo .fetch("Journey_Created_On__c")).to match Date.today().to_s
        @helper.addLogs("[Result ]   : Journey created on field checked successfully\n")
        @helper.addLogs('Success')
        @helper.postSuccessResult(2578)
      rescue Exception => e
        @helper.addLogs('Error')
        @helper.postFailResult(e, 2578)
        raise e
      end
    end
    it 'To Check Journey not Created While Importing Existing Contact Which is Owned By Susie Romero Where Activity is not present and existing journey is not present where Generate Journey on UI is UnChecked & in CSV is false and assign to the Campaign.', :'2742' => 'true' do
      begin
        @helper.addLogs("[Step ]  : Getting existing contact")
        @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Generate_Journey__c'] = true
        contactInfo = @pageObject.getExistingContact("",true,true)
        @helper.addLogs("[Step ]  : Using contact with email => #{contactInfo.fetch('Email')} and id => #{contactInfo.fetch('Id')}")
        @pageObject.upload_csv(contactInfo.fetch('Email'), "", @testDataJSON['Campaign'][0]['Name'], true,false,"Contact")
        expect(contactInfo).to_not eql nil
        @pageObject.checkJobStatus
        owner = @pageObject.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
        contactInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id, email, Owner.Name,Journey_Created_On__c FROM Contact WHERE id = '#{contactInfo.fetch("Id")}'")[0]
        sleep(5)
        insertedJourneyInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,CampaignId__c,Owner.id, Owner.Name,CreatedDate ,Status__c , NMD_Next_Contact_Date__c ,Primary_Email__c , Lead_Source__c , Lead_Source_Detail__c , Primary_Phone__c , Company_Name__c , Building_Interested_In__c , Locations_Interested__c , Interested_in_Number_of_Desks__c , Full_Time_Employees__c, Name   FROM Journey__c WHERE Primary_Email__c = '#{contactInfo.fetch("Email")}'")[0]
        @helper.addLogs("[Validate ] : Checking Journey is created on lead")
        @helper.addLogs("[Expected ] : Journey should not be created")
        @helper.addLogs("[Actual ]   : Journey is created - #{insertedJourneyInfo.nil? ? "No" : "Yes"}")
        expect(insertedJourneyInfo).to eql nil
        @helper.addLogs("[Result ]   : Journey creation checked successfully\n")
        puts "\n"
        generatedActivityForContact = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Subject , CreatedDate,Status ,Lead_Source__c , Lead_Source_Detail__c,Owner.Name,Locations_Interested__c, Number_of_Full_Time_Employees__c,Interested_in_Number_of_Desks__c,Company__c,WhoId FROM Task WHERE WhoId = '#{contactInfo.fetch('Id')}'")[0]
        puts generatedActivityForContact
        validate_case("Activity",generatedActivityForContact,{'Subject'=>'Inbound Lead submission','Locations_Interested__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Locations_Interested__c'],'Company__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Company'],'Lead_Source_Detail__c'=>"Inbound Call Page",'Lead_Source__c'=>"Inbound Call",'Status'=>'Open'})
        @helper.addLogs("[Validate ] : Checking create Journey created on field on contact")
        @helper.addLogs("[Expected ] : Create Journey created on should today")
        @helper.addLogs("[Actual ]   : Create Journey created on on lead is #{contactInfo.fetch("Journey_Created_On__c").inspect}")
        expect(contactInfo .fetch("Journey_Created_On__c")).to match Date.today().to_s
        @helper.addLogs("[Result ]   : Journey created on field checked successfully\n")
        @helper.addLogs('Success')
        @helper.postSuccessResult(2622)
      rescue Exception => e
        @helper.addLogs('Error')
        @helper.postFailResult(e, 2622)
        raise e
      end
    end
  end
  context "Kickbox Importer While Insertion of Existing Contact which is Owned by Susie Romero from Kickbox and assign to the Particular Campaign Based if No criteria is Matched",'325'=>'true' do
    before(:all) do
      @testDataJSON['Campaign'][0]['Lead Owner'] = ''
      @testDataJSON['Campaign'][0]['Email Address'] = 'vikhroliwest@wework.co.in'
      @testDataJSON['Campaign'][0]['City'] = ''
      @campaignId = @helper.instance_variable_get(:@restForce).getRecords("SELECT id FROM Campaign WHERE Name = '#{@testDataJSON['Campaign'][0]['Name']}'")[0]
      @helper.update_campaign(@campaignId.fetch('Id'),nil,@testDataJSON['Campaign'][0]['Email Address'])
    end
    it 'To Check Journey Created While Importing Existing Contact Which is Owned By Susie Romero Where Activity is not present and existing journey is not present where Generate Journey on UI is Checked & in CSV is Blank and assign to the Campaign.', :'2746' => 'true' do
      begin
        @helper.addLogs("[Step ]  : Getting existing contact")
        @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Generate_Journey__c'] = true
        contactInfo = nil
        contactInfo = @pageObject.getExistingContact("",false,false)
        if contactInfo.nil?
          @testDataJSON['Contact'][0]['Email'] = "john.smith_qaauto#{rand(999999999999999999)}@example.com"
          @testDataJSON['Contact'][0]['AccountId'] = @helper.instance_variable_get(:@restForce).getRecords("SELECT id FROM Account WHERE CreatedBy.Name IN ('Veena Hegane','Ashotosh Thakur','Monika Pingale','Kishor Shinde') and isDeleted = false")[0]
          contactInfo = @helper.instance_variable_get(:@restForce).createRecord("Contact",@testDataJSON['Contact'][0])
          Helper.addRecordsToDelete("Contact",contactInfo['Id'])
        end
        @helper.addLogs("[Step ]  : Using contact with email => #{contactInfo.fetch('Email')} and id => #{contactInfo.fetch('Id')}")
        @pageObject.upload_csv(contactInfo.fetch('Email'), "", @testDataJSON['Campaign'][0]['Name'], false,false,"Contact")
        expect(contactInfo).to_not eql nil
        @pageObject.checkJobStatus
        owner = @pageObject.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
        contactInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id, email,Account.Name, Owner.Name,Journey_Created_On__c FROM Contact WHERE id = '#{contactInfo.fetch("Id")}'")[0]
        sleep(5)
        insertedJourneyInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,CampaignId__c,Owner.id, Owner.Name,CreatedDate ,Status__c , NMD_Next_Contact_Date__c ,Primary_Email__c , Lead_Source__c , Lead_Source_Detail__c , Primary_Phone__c , Company_Name__c , Building_Interested_In__c , Locations_Interested__c , Interested_in_Number_of_Desks__c , Full_Time_Employees__c, Name   FROM Journey__c WHERE Primary_Email__c = '#{contactInfo.fetch("Email")}' AND CreatedDate = TODAY")[0]
        @helper.addLogs("[Validate ] : Checking Journey is created on lead")
        @helper.addLogs("[Expected ] : Journey should be created")
        @helper.addLogs("[Actual ]   : Journey is created with name #{insertedJourneyInfo.fetch("Name")}")
        expect(insertedJourneyInfo).to_not eql nil
        Helper.addRecordsToDelete("Journey__c", insertedJourneyInfo.fetch('Id'))
        @helper.addLogs("[Result ]   : Journey created successfully\n")
        puts "\n"
        validate_case("Journey",insertedJourneyInfo,{'Lead_Source__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['LeadSource'],'lead_Source_Detail__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]["lead_Source_Detail__c"],'Primary_Email__c'=>contactInfo.fetch("Email"),'Primary_Phone__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]["Phone"],'Company_Name__c'=>contactInfo.fetch('Account').fetch('Name'),'Status__c'=>'Started','CampaignId__c'=>@campaignId.fetch('Id')})
        @helper.addLogs("[Validate ] : Checking Journey owner should be according to lead owner criteria")
        @helper.addLogs("[Expected ] : Owner of Journey should be owner of lead")
        @helper.addLogs("[Actual ]   : Owner of Journey is #{insertedJourneyInfo.fetch("Owner").fetch("Id")}")
        expect(insertedJourneyInfo.fetch("Owner").fetch("Id")).to match owner
        @helper.addLogs("[Result ]   : Owner checked successfully\n")
        generatedActivityForContact = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Subject , CreatedDate,Status ,Lead_Source__c , Lead_Source_Detail__c,Owner.Name,Locations_Interested__c, Number_of_Full_Time_Employees__c,Interested_in_Number_of_Desks__c,Company__c,WhoId FROM Task WHERE WhoId = '#{contactInfo.fetch('Id')}' AND status != 'Completed' AND CreatedDate = TODAY")[0]

        Helper.addRecordsToDelete("Task", generatedActivityForContact.fetch('Id'))
        validate_case("Activity",generatedActivityForContact,{'Subject'=>'Inbound Lead submission','Locations_Interested__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Building_Interested_In__c'],'Company__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Company'],'Lead_Source_Detail__c'=>"Inbound Call Page",'Lead_Source__c'=>"Inbound Call",'Status'=>'Open'})
        @helper.addLogs("[Validate ] : Checking create Journey created on field on contact")
        @helper.addLogs("[Expected ] : Create Journey created on should today")
        @helper.addLogs("[Actual ]   : Create Journey created on on lead is #{contactInfo.fetch("Journey_Created_On__c").inspect}")
        expect(contactInfo .fetch("Journey_Created_On__c")).to match Date.today().to_s
        @helper.addLogs("[Result ]   : Journey created on field checked successfully\n")
        @helper.addLogs('Success')
        @helper.postSuccessResult(2636)
      rescue Exception => e
        @helper.addLogs('Error')
        @helper.postFailResult(e, 2636)
        raise e
      end
    end
    it 'To Check Journey Created While Importing Existing Contact Which is Owned By Susie Romero Where Activity is not present and existing journey is not present where Generate Journey on UI is UnChecked & in CSV is True and assign to the Campaign.', :'2748' => 'true' do
      begin
        @helper.addLogs("[Step ]  : Getting existing contact")
        @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Generate_Journey__c'] = true
        contactInfo = @pageObject.getExistingContact("",false,false)
        @helper.addLogs("[Step ]  : Using contact with email => #{contactInfo.fetch('Email')} and id => #{contactInfo.fetch('Id')}")
        @pageObject.upload_csv(contactInfo.fetch('Email'), "TRUE", @testDataJSON['Campaign'][0]['Name'], true,false,"Contact")
        expect(contactInfo).to_not eql nil
        @pageObject.checkJobStatus
        owner = @pageObject.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
        contactInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id, email, Owner.Name,Journey_Created_On__c FROM Contact WHERE id = '#{contactInfo.fetch("Id")}'")[0]
        sleep(5)
        insertedJourneyInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,CampaignId__c,Owner.id, Owner.Name,CreatedDate ,Status__c , NMD_Next_Contact_Date__c ,Primary_Email__c , Lead_Source__c , Lead_Source_Detail__c , Primary_Phone__c , Company_Name__c , Building_Interested_In__c , Locations_Interested__c , Interested_in_Number_of_Desks__c , Full_Time_Employees__c, Name   FROM Journey__c WHERE Primary_Email__c = '#{contactInfo.fetch("Email")}'")[0]
        @helper.addLogs("[Validate ] : Checking Journey is created on lead")
        @helper.addLogs("[Expected ] : Journey should be created")
        @helper.addLogs("[Actual ]   : Journey is created with name #{insertedJourneyInfo.fetch("Name")}")
        expect(insertedJourneyInfo).to_not eql nil
        Helper.addRecordsToDelete("Journey__c", insertedJourneyInfo.fetch('Id'))
        @helper.addLogs("[Result ]   : Journey created successfully\n")
        puts "\n"
        validate_case("Journey",insertedJourneyInfo,{'Lead_Source__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['LeadSource'],'lead_Source_Detail__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]["lead_Source_Detail__c"],'NMD_Next_Contact_Date__c'=>contactInfo.fetch("Journey_Created_On__c"),'Primary_Email__c'=>contactInfo.fetch("Email"),'Primary_Phone__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]["Phone"],'Company_Name__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]["Company"],'Status__c'=>'Started','CampaignId__c'=>@campaignId.fetch('Id')})
        @helper.addLogs("[Validate ] : Checking Journey owner should be according to lead owner criteria")
        @helper.addLogs("[Expected ] : Owner of Journey should be owner of lead")
        @helper.addLogs("[Actual ]   : Owner of Journey is #{insertedJourneyInfo.fetch("Owner").fetch("Id")}")
        expect(insertedJourneyInfo.fetch("Owner").fetch("Id")).to match owner
        @helper.addLogs("[Result ]   : Owner checked successfully\n")
        @pageObject.instance_variable_get(:@testDataJSON)['Journey'][0]
        generatedActivityForContact = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Subject , CreatedDate,Status ,Lead_Source__c , Lead_Source_Detail__c,Owner.Name,Locations_Interested__c, Number_of_Full_Time_Employees__c,Interested_in_Number_of_Desks__c,Company__c,WhoId FROM Task WHERE WhoId = '#{contactInfo.fetch('Id')}'")[0]
        puts generatedActivityForContact
        validate_case("Activity",generatedActivityForContact,{'Subject'=>'Inbound Lead submission','Locations_Interested__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Locations_Interested__c'],'Company__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Company'],'Lead_Source_Detail__c'=>"Inbound Call Page",'Lead_Source__c'=>"Inbound Call",'Status'=>'Open'})
        @helper.addLogs("[Validate ] : Checking create Journey created on field on contact")
        @helper.addLogs("[Expected ] : Create Journey created on should today")
        @helper.addLogs("[Actual ]   : Create Journey created on on lead is #{contactInfo.fetch("Journey_Created_On__c").inspect}")
        expect(contactInfo .fetch("Journey_Created_On__c")).to match Date.today().to_s
        @helper.addLogs("[Result ]   : Journey created on field checked successfully\n")
        @helper.addLogs('Success')
        @helper.postSuccessResult(2637)
      rescue Exception => e
        @helper.addLogs('Error')
        @helper.postFailResult(e, 2637)
        raise e
      end
    end
    it 'To Check Journey Created While Importing Existing Contact Which is Owned By Susie Romero Where Activity is not present and existing journey is present where Generate Journey on UI is Checked & in CSV is Blank and assign to the Campaign.', :'2752' => 'true' do
      begin
        @helper.addLogs("[Step ]  : Getting existing contact")
        @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Generate_Journey__c'] = true
        contactInfo = @pageObject.getExistingContact("",true,false)
        @helper.addLogs("[Step ]  : Using contact with email => #{contactInfo.fetch('Email')} and id => #{contactInfo.fetch('Id')}")
        @pageObject.upload_csv(contactInfo.fetch('Email'), "", @testDataJSON['Campaign'][0]['Name'], false,false,"Contact")
        expect(contactInfo).to_not eql nil
        @pageObject.checkJobStatus
        owner = @pageObject.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
        contactInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id, email, Owner.Name,Journey_Created_On__c FROM Contact WHERE id = '#{contactInfo.fetch("Id")}'")[0]
        sleep(5)
        insertedJourneyInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,CampaignId__c,Owner.id, Owner.Name,CreatedDate ,Status__c , NMD_Next_Contact_Date__c ,Primary_Email__c , Lead_Source__c , Lead_Source_Detail__c , Primary_Phone__c , Company_Name__c , Building_Interested_In__c , Locations_Interested__c , Interested_in_Number_of_Desks__c , Full_Time_Employees__c, Name   FROM Journey__c WHERE Primary_Email__c = '#{contactInfo.fetch("Email")}'")[0]
        @helper.addLogs("[Validate ] : Checking Journey is created on lead")
        @helper.addLogs("[Expected ] : Journey should be created")
        @helper.addLogs("[Actual ]   : Journey is created with name #{insertedJourneyInfo.fetch("Name")}")
        expect(insertedJourneyInfo).to_not eql nil
        Helper.addRecordsToDelete("Journey__c", insertedJourneyInfo.fetch('Id'))
        @helper.addLogs("[Result ]   : Journey created successfully\n")
        puts "\n"
        validate_case("Journey",insertedJourneyInfo,{'Lead_Source__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['LeadSource'],'lead_Source_Detail__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]["lead_Source_Detail__c"],'NMD_Next_Contact_Date__c'=>contactInfo.fetch("Journey_Created_On__c"),'Primary_Email__c'=>contactInfo.fetch("Email"),'Primary_Phone__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]["Phone"],'Company_Name__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]["Company"],'Status__c'=>'Started','CampaignId__c'=>@campaignId.fetch('Id')})
        @helper.addLogs("[Validate ] : Checking Journey owner should be according to lead owner criteria")
        @helper.addLogs("[Expected ] : Owner of Journey should be owner of lead")
        @helper.addLogs("[Actual ]   : Owner of Journey is #{insertedJourneyInfo.fetch("Owner").fetch("Id")}")
        expect(insertedJourneyInfo.fetch("Owner").fetch("Id")).to match owner
        @helper.addLogs("[Result ]   : Owner checked successfully\n")
        @pageObject.instance_variable_get(:@testDataJSON)['Journey'][0]
        generatedActivityForContact = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Subject , CreatedDate,Status ,Lead_Source__c , Lead_Source_Detail__c,Owner.Name,Locations_Interested__c, Number_of_Full_Time_Employees__c,Interested_in_Number_of_Desks__c,Company__c,WhoId FROM Task WHERE WhoId = '#{contactInfo.fetch('Id')}'")[0]
        puts generatedActivityForContact
        validate_case("Activity",generatedActivityForContact,{'Subject'=>'Inbound Lead submission','Locations_Interested__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Locations_Interested__c'],'Company__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Company'],'Lead_Source_Detail__c'=>"Inbound Call Page",'Lead_Source__c'=>"Inbound Call",'Status'=>'Open'})
        @helper.addLogs("[Validate ] : Checking create Journey created on field on contact")
        @helper.addLogs("[Expected ] : Create Journey created on should today")
        @helper.addLogs("[Actual ]   : Create Journey created on on lead is #{contactInfo.fetch("Journey_Created_On__c").inspect}")
        expect(contactInfo .fetch("Journey_Created_On__c")).to match Date.today().to_s
        @helper.addLogs("[Result ]   : Journey created on field checked successfully\n")
        @helper.addLogs('Success')
        @helper.postSuccessResult(2639)
      rescue Exception => e
        @helper.addLogs('Error')
        @helper.postFailResult(e, 2639)
        raise e
      end
    end
    it 'To Check Journey Created While Importing Existing Contact Which is Owned By Susie Romero Where Activity is  present and existing journey is present where Generate Journey on UI is Checked & in CSV is Blank and assign to the Campaign.', :'2764' => 'true' do
      begin
        @helper.addLogs("[Step ]  : Getting existing contact")
        @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Generate_Journey__c'] = true
        contactInfo = @pageObject.getExistingContact("",true,true)
        @helper.addLogs("[Step ]  : Using contact with email => #{contactInfo.fetch('Email')} and id => #{contactInfo.fetch('Id')}")
        @pageObject.upload_csv(contactInfo.fetch('Email'), "", @testDataJSON['Campaign'][0]['Name'], false,false,"Contact")
        expect(contactInfo).to_not eql nil
        @pageObject.checkJobStatus
        owner = @pageObject.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
        contactInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id, email, Owner.Name,Journey_Created_On__c FROM Contact WHERE id = '#{contactInfo.fetch("Id")}'")[0]
        sleep(5)
        insertedJourneyInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,CampaignId__c,Owner.id, Owner.Name,CreatedDate ,Status__c , NMD_Next_Contact_Date__c ,Primary_Email__c , Lead_Source__c , Lead_Source_Detail__c , Primary_Phone__c , Company_Name__c , Building_Interested_In__c , Locations_Interested__c , Interested_in_Number_of_Desks__c , Full_Time_Employees__c, Name   FROM Journey__c WHERE Primary_Email__c = '#{contactInfo.fetch("Email")}'")[0]
        @helper.addLogs("[Validate ] : Checking Journey is created on lead")
        @helper.addLogs("[Expected ] : Journey should be created")
        @helper.addLogs("[Actual ]   : Journey is created with name #{insertedJourneyInfo.fetch("Name")}")
        expect(insertedJourneyInfo).to_not eql nil
        Helper.addRecordsToDelete("Journey__c", insertedJourneyInfo.fetch('Id'))
        @helper.addLogs("[Result ]   : Journey created successfully\n")
        puts "\n"
        validate_case("Journey",insertedJourneyInfo,{'Lead_Source__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['LeadSource'],'lead_Source_Detail__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]["lead_Source_Detail__c"],'NMD_Next_Contact_Date__c'=>contactInfo.fetch("Journey_Created_On__c"),'Primary_Email__c'=>contactInfo.fetch("Email"),'Primary_Phone__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]["Phone"],'Company_Name__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]["Company"],'Status__c'=>'Started','CampaignId__c'=>@campaignId.fetch('Id')})
        @helper.addLogs("[Validate ] : Checking Journey owner should be according to lead owner criteria")
        @helper.addLogs("[Expected ] : Owner of Journey should be owner of lead")
        @helper.addLogs("[Actual ]   : Owner of Journey is #{insertedJourneyInfo.fetch("Owner").fetch("Id")}")
        expect(insertedJourneyInfo.fetch("Owner").fetch("Id")).to match owner
        @helper.addLogs("[Result ]   : Owner checked successfully\n")
        @pageObject.instance_variable_get(:@testDataJSON)['Journey'][0]
        generatedActivityForContact = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Subject , CreatedDate,Status ,Lead_Source__c , Lead_Source_Detail__c,Owner.Name,Locations_Interested__c, Number_of_Full_Time_Employees__c,Interested_in_Number_of_Desks__c,Company__c,WhoId FROM Task WHERE WhoId = '#{contactInfo.fetch('Id')}'")[0]
        puts generatedActivityForContact
        validate_case("Activity",generatedActivityForContact,{'Subject'=>'Inbound Lead submission','Locations_Interested__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Locations_Interested__c'],'Company__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Company'],'Lead_Source_Detail__c'=>"Inbound Call Page",'Lead_Source__c'=>"Inbound Call",'Status'=>'Open'})
        @helper.addLogs("[Validate ] : Checking create Journey created on field on contact")
        @helper.addLogs("[Expected ] : Create Journey created on should today")
        @helper.addLogs("[Actual ]   : Create Journey created on on lead is #{contactInfo.fetch("Journey_Created_On__c").inspect}")
        expect(contactInfo .fetch("Journey_Created_On__c")).to match Date.today().to_s
        @helper.addLogs("[Result ]   : Journey created on field checked successfully\n")
        @helper.addLogs('Success')
        @helper.postSuccessResult(2578)
      rescue Exception => e
        @helper.addLogs('Error')
        @helper.postFailResult(e, 2578)
        raise e
      end
    end
    it 'To Check Journey not Created While Importing Existing Contact Which is Owned By Susie Romero Where Activity is not present and existing journey is not present where Generate Journey on UI is UnChecked & in CSV is false and assign to the Campaign.', :'2750' => 'true' do
      begin
        @helper.addLogs("[Step ]  : Getting existing contact")
        @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Generate_Journey__c'] = true
        contactInfo = @pageObject.getExistingContact("",true,true)
        @helper.addLogs("[Step ]  : Using contact with email => #{contactInfo.fetch('Email')} and id => #{contactInfo.fetch('Id')}")
        @pageObject.upload_csv(contactInfo.fetch('Email'), "", @testDataJSON['Campaign'][0]['Name'], true,false,"Contact")
        expect(contactInfo).to_not eql nil
        @pageObject.checkJobStatus
        owner = @pageObject.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
        contactInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id, email, Owner.Name,Journey_Created_On__c FROM Contact WHERE id = '#{contactInfo.fetch("Id")}'")[0]
        sleep(5)
        insertedJourneyInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,CampaignId__c,Owner.id, Owner.Name,CreatedDate ,Status__c , NMD_Next_Contact_Date__c ,Primary_Email__c , Lead_Source__c , Lead_Source_Detail__c , Primary_Phone__c , Company_Name__c , Building_Interested_In__c , Locations_Interested__c , Interested_in_Number_of_Desks__c , Full_Time_Employees__c, Name   FROM Journey__c WHERE Primary_Email__c = '#{contactInfo.fetch("Email")}'")[0]
        @helper.addLogs("[Validate ] : Checking Journey is created on lead")
        @helper.addLogs("[Expected ] : Journey should not be created")
        @helper.addLogs("[Actual ]   : Journey is created - #{insertedJourneyInfo.nil? ? "No" : "Yes"}")
        expect(insertedJourneyInfo).to eql nil
        @helper.addLogs("[Result ]   : Journey creation checked successfully\n")
        puts "\n"
        generatedActivityForContact = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Subject , CreatedDate,Status ,Lead_Source__c , Lead_Source_Detail__c,Owner.Name,Locations_Interested__c, Number_of_Full_Time_Employees__c,Interested_in_Number_of_Desks__c,Company__c,WhoId FROM Task WHERE WhoId = '#{contactInfo.fetch('Id')}'")[0]
        puts generatedActivityForContact
        validate_case("Activity",generatedActivityForContact,{'Subject'=>'Inbound Lead submission','Locations_Interested__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Locations_Interested__c'],'Company__c'=>@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Company'],'Lead_Source_Detail__c'=>"Inbound Call Page",'Lead_Source__c'=>"Inbound Call",'Status'=>'Open'})
        @helper.addLogs("[Validate ] : Checking create Journey created on field on contact")
        @helper.addLogs("[Expected ] : Create Journey created on should today")
        @helper.addLogs("[Actual ]   : Create Journey created on on lead is #{contactInfo.fetch("Journey_Created_On__c").inspect}")
        expect(contactInfo .fetch("Journey_Created_On__c")).to match Date.today().to_s
        @helper.addLogs("[Result ]   : Journey created on field checked successfully\n")
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
    expected.keys.each do |key|
      if !key.nil?
      if actual.key? key
        @helper.addLogs("[Validate ] : Checking #{object} : #{key}")
        @helper.addLogs("[Expected ] : #{actual[key]}")
        @helper.addLogs("[Actual ]   : #{expected[key]}")
        expect(expected[key]).to eql actual[key]
        @helper.addLogs("[Result ]   : #{key} checked successfully")
        puts "\n"
      end
      end
    end
  end
end