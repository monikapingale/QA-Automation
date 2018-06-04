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
  context "Kickbox Importer While Insertion of New Lead assign to the Particular Campaign Based on Lead Owner Criterias" do
    before(:all) do
      @testDataJSON['Campaign'][0]['Lead Owner'] = '0051g000000tSCu'
      @testDataJSON['Campaign'][0]['Email Address'] = ''
      @testDataJSON['Campaign'][0]['City'] = ''
      @campaignId = @helper.instance_variable_get(:@restForce).getRecords("SELECT id FROM Campaign WHERE Name = '#{@testDataJSON['Campaign'][0]['Name']}'")[0]
      @helper.update_campaign(@campaignId.fetch('Id'), @testDataJSON['Campaign'][0]['Lead Owner'])
    end
    it 'To Check Journey is created While Importing lead from Kickbox When the Generate Journey on UI is Checked and Generate journey in CSV is Blank and assign to the particular Campaign.', :'2575' => 'true' do
      begin
        @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Generate_Journey__c'] = true
        leadInfo = @pageObject.upload_csv("john.snow#{rand(9999999999)}_qaauto@example.com", "TRUE", @testDataJSON['Campaign'][0]['Name'],true,true,"Lead")[0]
        Helper.addRecordsToDelete("Lead", leadInfo.fetch('Id'))
        @helper.addLogs("[Expected ] : Lead should create with name #{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
        @helper.addLogs("[Actual ]   : Lead is created with name #{leadInfo.fetch("Name")}")
        expect(leadInfo).to_not eql nil
        expect(validate_case("Lead", @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0], leadInfo)).to be true
        @helper.addLogs("[Result ]   : Lead insertion checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Lead owner should be lead owner on campaign")
        @helper.addLogs("[Expected ] : Owner of lead should be Logged in user")
        @helper.addLogs("[Actual ]   : Owner of lead is #{leadInfo.fetch("Owner").fetch("Id")}")
        expect(leadInfo.fetch("Owner").fetch("Id")).to eql @pageObject.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
        @helper.addLogs("[Result ]   : Owner checked successfully\n")
=begin
        @helper.addLogs("[Validate ] : Checking Lead source")
        @helper.addLogs("[Expected ] : Lead source should be Inbound Call")
        @helper.addLogs("[Actual ]   : Lead is created with lead source #{leadInfo.fetch("LeadSource")}")
        expect(leadInfo.fetch("LeadSource")).to eql "Inbound Call"
        @helper.addLogs("[Result ]   : Lead source checked successfully\n")
        @helper.addLogs("[Validate ] : Checking building interested name on Lead")
        @helper.addLogs("[Expected ] : Building interested name should be #{@testDataJSON['Lead'][0]['Building_Interested_In__c']}")
        @helper.addLogs("[Actual ]   : Lead is created with building interested name #{leadInfo.fetch("Building_Interested_Name__c")}")
        expect(leadInfo.fetch("Building_Interested_Name__c")).to eql @testDataJSON['Lead'][0]["Building_Interested_In__c"]
        @helper.addLogs("[Result ]   : Building interested name on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Generate Journey on Lead")
        @helper.addLogs("[Expected ] : Generate Journey should be TRUE")
        @helper.addLogs("[Actual ]   : Lead is created with Generate Journey =  #{leadInfo.fetch("Generate_Journey__c")}")
        expect(leadInfo.fetch("Generate_Journey__c")).to be true
        @helper.addLogs("[Result ]   : Generate Journey on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Locale on Lead")
        @helper.addLogs("[Expected ] : Locale should be en-US")
        @helper.addLogs("[Actual ]   : Lead is created with Locale =  #{leadInfo.fetch("Locale__c")}")
        expect(leadInfo.fetch("Locale__c")).to eql "en-US"
        @helper.addLogs("[Result ]   : Locale on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Country code on Lead")
        @helper.addLogs("[Expected ] : Country code should be IN")
        @helper.addLogs("[Actual ]   : Lead is created with Country code =  #{leadInfo.fetch("Country_Code__c")}")
        expect(leadInfo.fetch("Country_Code__c")).to eql "IN"
        @helper.addLogs("[Result ]   : Country code on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking building interested")
        @helper.addLogs("[Expected ] : Building interested should be #{@testDataJSON['Lead'][0]["Building_Interested_In__c"]}")
        @helper.addLogs("[Actual ]   : Lead is created with building interested #{leadInfo.fetch("Building_Interested_In__c")}")
        expect(leadInfo.fetch("Building_Interested_In__c")).to eql @building
        @helper.addLogs("[Result ]   : Building interested on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Journey created date on lead")
        @helper.addLogs("[Expected ] : Journey created date should be #{leadInfo.fetch("CreatedDate")}")
        @helper.addLogs("[Actual ]   : Lead is created with Journey created date #{leadInfo.fetch("Journey_Created_On__c")}")
        #expect(insertedLeadInfo.fetch("Journey_Created_On__c")).to eql insertedJourneyInfo[0].fetch("CreatedDate")
        @helper.addLogs("[Result ]   : Journey created date on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Locations Interested on lead")
        @helper.addLogs("[Expected ] : Locations Interested should be #{@testDataJSON['Lead'][0]["Building_Interested_In__c"]}")
        @helper.addLogs("[Actual ]   : Lead is created with Locations Interested #{leadInfo.fetch("Locations_Interested__c")}")
        expect(leadInfo.fetch("Locations_Interested__c")).to eql @testDataJSON['Lead'][0]["Building_Interested_In__c"]
        @helper.addLogs("[Result ]   : Locations Interested on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Email on lead")
        @helper.addLogs("[Expected ] : Email should be #{@testDataJSON['Lead'][0]['Email']}")
        @helper.addLogs("[Actual ]   : Lead is created with Email #{leadInfo.fetch("Email")}")
        expect(leadInfo.fetch("Email")).to eql @testDataJSON['Lead'][0]['Email']
        @helper.addLogs("[Result ]   : Email on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Phone on lead")
        @helper.addLogs("[Expected ] : Number of Phone should be #{@testDataJSON['Lead'][0]['Phone']}")
        @helper.addLogs("[Actual ]   : Lead is created with Phone #{leadInfo.fetch("Phone")}")
        expect(leadInfo.fetch("Phone")).to eql @testDataJSON['Lead'][0]['Phone']
        @helper.addLogs("[Result ]   : Phone on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Company on lead")
        @helper.addLogs("[Expected ] : Company should be #{@testDataJSON['Lead'][0]['Company']}")
        @helper.addLogs("[Actual ]   : Lead is created with Company #{leadInfo.fetch("Company")}")
        expect(leadInfo.fetch("Company")).to eql @testDataJSON['Lead'][0]['Company']
        @helper.addLogs("[Result ]   : Company on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Status on lead")
        @helper.addLogs("[Expected ] : Status should be Open")
        @helper.addLogs("[Actual ]   : Lead is created with Status #{leadInfo.fetch("Status")}")
        expect(leadInfo.fetch("Status")).to eql "Open"
        @helper.addLogs("[Result ]   : Status on Lead checked successfully\n")
=end
        insertedJourneyInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,Owner.Name, CreatedDate ,Status__c , NMD_Next_Contact_Date__c ,Primary_Email__c , Lead_Source__c , Lead_Source_Detail__c , Primary_Phone__c , Company_Name__c , Building_Interested_In__c , Locations_Interested__c , Interested_in_Number_of_Desks__c , Full_Time_Employees__c, Name   FROM Journey__c WHERE Primary_Email__c = '#{leadInfo.fetch("Email")}'")[0]
        @helper.addLogs("[Validate ] : Checking Journey is created on lead")
        @helper.addLogs("[Expected ] : Journey should create with name #{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
        @helper.addLogs("[Actual ]   : Journey is created with name #{insertedJourneyInfo.fetch("Name")}")
        expect(insertedJourneyInfo).to_not eql nil
        Helper.addRecordsToDelete("Journey__c", insertedJourneyInfo.fetch('Id'))
        @helper.addLogs("[Result ]   : Journey created successfully\n")
        @helper.addLogs("[Validate ] : Checking Journey owner should be logged in user")
        @helper.addLogs("[Expected ] : Owner of Journey should be owner of lead")
        @helper.addLogs("[Actual ]   : Owner of Journey is #{insertedJourneyInfo.fetch("Owner").fetch("Name")}")
        expect(insertedJourneyInfo.fetch("Owner").fetch("Name")).to eql @userInfo.fetch("display_name")
        @helper.addLogs("[Result ]   : Owner checked successfully\n")
        expect(validate_case("Journey", @pageObject.instance_variable_get(:@testDataJSON)['Journey'][0], insertedJourneyInfo)).to be true
=begin
        @helper.addLogs("[Validate ] : Checking Lead source on Journey")
        @helper.addLogs("[Expected ] : Lead source should be Inbound Call")
        @helper.addLogs("[Actual ]   : Journey is created with lead source #{insertedJourneyInfo.fetch("Lead_Source__c")}")
        expect(insertedJourneyInfo.fetch("Lead_Source__c")).to eql "Inbound Call"
        @helper.addLogs("[Result ]   : Lead source checked successfully\n")
        @helper.addLogs("[Validate ] : Checking building interested name on Journey")
        @helper.addLogs("[Expected ] : Building interested should be #{@testDataJSON['Lead'][0]['Building_Interested_In__c']}")
        @helper.addLogs("[Actual ]   : Journey is created with building interested name #{insertedJourneyInfo.fetch("Building_Interested_In__c")}")
        expect(insertedJourneyInfo.fetch("Building_Interested_In__c")).to eql @building
        @helper.addLogs("[Result ]   : Building interested on Journey checked successfully\n")
        @helper.addLogs("[Validate ] : Checking NMD Next Contact Date on Journey")
        @helper.addLogs("[Expected ] : NMD Next Contact Date should be journey creation date")
        @helper.addLogs("[Actual ]   : Journey is created with NMD Next Contact Date #{insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")}")
        #expect(insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")).to eql insertedJourneyInfo[0].fetch("CreatedDate")
        @helper.addLogs("[Result ]   : NMD Next Contact Date on Journey checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Locations Interested on Journey")
        @helper.addLogs("[Expected ] : Locations Interested should be #{@testDataJSON['Lead'][0]['Building_Interested_In__c']}")
        @helper.addLogs("[Actual ]   : Journey is created with Locations Interested #{insertedJourneyInfo.fetch("Locations_Interested__c")}")
        expect(insertedJourneyInfo.fetch('Locations_Interested__c')).to eql @testDataJSON['Lead'][0]["Building_Interested_In__c"]
        @helper.addLogs("[Result ]   : Locations Interested on Journey checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Email on Journey")
        @helper.addLogs("[Expected ] : Email should be #{@testDataJSON['Lead'][0]['Email']}")
        @helper.addLogs("[Actual ]   : Journey is created with Email #{insertedJourneyInfo.fetch("Primary_Email__c")}")
        expect(insertedJourneyInfo.fetch("Primary_Email__c")).to eql @testDataJSON['Lead'][0]['Email']
        @helper.addLogs("[Result ]   : Email on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Phone on Journey")
        @helper.addLogs("[Expected ] : Number of Phone should be #{@testDataJSON['Lead'][0]['Phone']}")
        @helper.addLogs("[Actual ]   : Journey is created with Phone #{insertedJourneyInfo.fetch("Primary_Phone__c")}")
        expect(insertedJourneyInfo.fetch("Primary_Phone__c")).to eql @testDataJSON['Lead'][0]['Phone']
        @helper.addLogs("[Result ]   : Phone on Journey checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Company on Journey")
        @helper.addLogs("[Expected ] : Company should be #{@testDataJSON['Lead'][0]['Company']}")
        @helper.addLogs("[Actual ]   : Journey is created with Company #{insertedJourneyInfo.fetch("Company_Name__c")}")
        expect(insertedJourneyInfo.fetch("Company_Name__c")).to eql @testDataJSON['Lead'][0]['Company']
        @helper.addLogs("[Result ]   : Company on Journey checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Status on Journey")
        @helper.addLogs("[Expected ] : Status should be Started")
        @helper.addLogs("[Actual ]   : Journey is created with Status #{insertedJourneyInfo.fetch("Status__c")}")
        expect(insertedJourneyInfo.fetch("Status__c")).to eql "Started"
        @helper.addLogs("[Result ]   : Status on Journey checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Campaign on Journey")
        @helper.addLogs("[Expected ] : Campaign should be #{@campaignId}")
        @helper.addLogs("[Actual ]   : Journey is created with Campaign #{insertedJourneyInfo.fetch("CampaignId__c")} on it")
        expect(insertedJourneyInfo.fetch("CampaignId__c")).to eql @campaignId
        @helper.addLogs("[Result ]   : Status on Journey checked successfully\n")
=end
        generatedActivityForLead = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Subject , CreatedDate,Status ,Lead_Source__c , Lead_Source_Detail__c,Owner.Name,Locations_Interested__c, Number_of_Full_Time_Employees__c,Interested_in_Number_of_Desks__c,Company__c,WhoId FROM Task WHERE WhoId = '#{leadInfo.fetch('Id')}'")[0]
        @helper.addLogs("[Validate ] : Checking Next Contact Date on existing Journey")
        @helper.addLogs("[Expected ] : Next Contact Date on existing Journey should update with duplicate lead submission date")
        @helper.addLogs("[Actual ]   : Next Contact Date on existing Journey is #{insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")}")
        #expect(existingJourneyInfo.fetch("NMD_Next_Contact_Date__c")).to match generatedActivityForLead.fetch("CreatedDate")
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
        @helper.addLogs("[Validate ] : Checking assigned to on activity")
        @helper.addLogs("[Expected ] : Assigned to on activity should be lead owner")
        @helper.addLogs("[Actual ]   : Assigned to on activity is #{generatedActivityForLead.fetch("Owner").fetch("Name")}")
        expect(generatedActivityForLead.fetch("Owner").fetch("Name")).to eql @userInfo.fetch("display_name")
        @helper.addLogs("[Result ]   : Activity assigned to field checked successfully")
        @helper.addLogs("[Validate ] : Checking status on activity")
        @helper.addLogs("[Expected ] : Status on activity should be Open")
        @helper.addLogs("[Actual ]   : Status on activity is #{generatedActivityForLead.fetch("Status")}")
        expect(generatedActivityForLead.fetch("Status")).to eql "Open"
        @helper.addLogs("[Result ]   : Activity assigned to field checked successfully")
        @helper.addLogs("[Validate ] : Checking status on activity")
        @helper.addLogs("[Expected ] : Status on activity should be Open")
        @helper.addLogs("[Actual ]   : Status on activity is #{generatedActivityForLead.fetch("Status")}")
        expect(generatedActivityForLead.fetch("Company__c")).to eql leadInfo.fetch('Company')
        @helper.addLogs("[Result ]   : Activity Status field checked successfully")
        @helper.addLogs("[Validate ] : Checking Location interested on activity")
        @helper.addLogs("[Expected ] : Location interested on activity should be #{leadInfo.fetch('Locations_Interested__c')}")
        @helper.addLogs("[Actual ]   : Location interested on activity is #{generatedActivityForLead.fetch("Status")}")
        expect(generatedActivityForLead.fetch("Locations_Interested__c")).to eql leadInfo.fetch('Locations_Interested__c')
        @helper.addLogs("[Result ]   : Activity Location interested field checked successfully")
        @helper.addLogs("[Validate ] : Checking Location interested on activity")
        @helper.addLogs("[Expected ] : Number of full time employees on activity should be #{leadInfo.fetch('Number_of_Full_Time_Employees__c')}")
        @helper.addLogs("[Actual ]   : Number of full time employees on activity is #{generatedActivityForLead.fetch("Number_of_Full_Time_Employees__c")}")
        expect(generatedActivityForLead.fetch("Number_of_Full_Time_Employees__c")).to eql leadInfo.fetch('Number_of_Full_Time_Employees__c')
        @helper.addLogs("[Result ]   : Activity Number of full time employees field checked successfully")
        @helper.addLogs("[Validate ] : Checking Number of desks on activity")
        @helper.addLogs("[Expected ] : Checking Number of desks on activity should be #{leadInfo.fetch('Number_of_Full_Time_Employees__c')}")
        @helper.addLogs("[Actual ]   : Checking Number of desks on activity is #{generatedActivityForLead.fetch("Number_of_Full_Time_Employees__c")}")
        expect(generatedActivityForLead.fetch("Interested_in_Number_of_Desks__c")).to eql leadInfo.fetch('Interested_in_Number_of_Desks__c')
        @helper.addLogs("[Result ]   : Activity Number of desks field checked successfully")
        @helper.addLogs('Success')
        @helper.postSuccessResult(2575)
      rescue Exception => e
        @helper.addLogs('Error')
        @helper.postFailResult(e, 2575)
        raise e
      end
    end
    it 'To Check Journey is Created While Importing Lead from Kickbox When the Generate Journey on UI is Unchecked and Generate Journey in CSV is True and assign to the particular Campaign.', :'2578' => 'true' do
      begin
        leadInfo = @pageObject.upload_csv("john.snow#{rand(9999999999)}_qaauto@example.com", 'TRUE', @testDataJSON['Campaign'][0]['Name'],false,true,"Lead")[0]
        Helper.addRecordsToDelete("Lead", leadInfo.fetch('Id'))
        @helper.addLogs("[Expected ] : Lead should create with name #{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
        @helper.addLogs("[Actual ]   : Lead is created with name #{leadInfo.fetch("Name")}")
        expect(leadInfo).to_not eql nil
        expect(validate_case("Lead", @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0], leadInfo)).to be true
        @helper.addLogs("[Result ]   : Lead insertion checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Lead owner should be lead owner on campaign")
        @helper.addLogs("[Expected ] : Owner of lead should be Logged in user")
        @helper.addLogs("[Actual ]   : Owner of lead is #{leadInfo.fetch("Owner").fetch("Name")}")
        expect(leadInfo.fetch("Owner").fetch("Name")).to eql @pageObject.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
        @helper.addLogs("[Result ]   : Owner checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Lead source")
        @helper.addLogs("[Expected ] : Lead source should be Inbound Call")
        @helper.addLogs("[Actual ]   : Lead is created with lead source #{leadInfo.fetch("LeadSource")}")
        expect(leadInfo.fetch("LeadSource")).to eql "Inbound Call"
        @helper.addLogs("[Result ]   : Lead source checked successfully\n")
        @helper.addLogs("[Validate ] : Checking building interested name on Lead")
        @helper.addLogs("[Expected ] : Building interested name should be #{@testDataJSON['Lead'][0]['Building_Interested_In__c']}")
        @helper.addLogs("[Actual ]   : Lead is created with building interested name #{leadInfo.fetch("Building_Interested_Name__c")}")
        expect(leadInfo.fetch("Building_Interested_Name__c")).to eql @testDataJSON['Lead'][0]["Building_Interested_In__c"]
        @helper.addLogs("[Result ]   : Building interested name on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Generate Journey on Lead")
        @helper.addLogs("[Expected ] : Generate Journey should be TRUE")
        @helper.addLogs("[Actual ]   : Lead is created with Generate Journey =  #{leadInfo.fetch("Generate_Journey__c")}")
        expect(leadInfo.fetch("Generate_Journey__c")).to be true
        @helper.addLogs("[Result ]   : Generate Journey on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Locale on Lead")
        @helper.addLogs("[Expected ] : Locale should be en-US")
        @helper.addLogs("[Actual ]   : Lead is created with Locale =  #{leadInfo.fetch("Locale__c")}")
        expect(leadInfo.fetch("Locale__c")).to eql "en-US"
        @helper.addLogs("[Result ]   : Locale on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Country code on Lead")
        @helper.addLogs("[Expected ] : Country code should be IN")
        @helper.addLogs("[Actual ]   : Lead is created with Country code =  #{leadInfo.fetch("Country_Code__c")}")
        expect(leadInfo.fetch("Country_Code__c")).to eql "IN"
        @helper.addLogs("[Result ]   : Country code on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking building interested")
        @helper.addLogs("[Expected ] : Building interested should be #{@testDataJSON['Lead'][0]["Building_Interested_In__c"]}")
        @helper.addLogs("[Actual ]   : Lead is created with building interested #{leadInfo.fetch("Building_Interested_In__c")}")
        expect(leadInfo.fetch("Building_Interested_In__c")).to eql @building
        @helper.addLogs("[Result ]   : Building interested on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Journey created date on lead")
        @helper.addLogs("[Expected ] : Journey created date should be #{leadInfo.fetch("CreatedDate")}")
        @helper.addLogs("[Actual ]   : Lead is created with Journey created date #{leadInfo.fetch("Journey_Created_On__c")}")
        #expect(insertedLeadInfo.fetch("Journey_Created_On__c")).to eql insertedJourneyInfo[0].fetch("CreatedDate")
        @helper.addLogs("[Result ]   : Journey created date on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Locations Interested on lead")
        @helper.addLogs("[Expected ] : Locations Interested should be #{@testDataJSON['Lead'][0]["Building_Interested_In__c"]}")
        @helper.addLogs("[Actual ]   : Lead is created with Locations Interested #{leadInfo.fetch("Locations_Interested__c")}")
        expect(leadInfo.fetch("Locations_Interested__c")).to eql @testDataJSON['Lead'][0]["Building_Interested_In__c"]
        @helper.addLogs("[Result ]   : Locations Interested on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Email on lead")
        @helper.addLogs("[Expected ] : Email should be #{@testDataJSON['Lead'][0]['Email']}")
        @helper.addLogs("[Actual ]   : Lead is created with Email #{leadInfo.fetch("Email")}")
        expect(leadInfo.fetch("Email")).to eql @testDataJSON['Lead'][0]['Email']
        @helper.addLogs("[Result ]   : Email on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Phone on lead")
        @helper.addLogs("[Expected ] : Number of Phone should be #{@testDataJSON['Lead'][0]['Phone']}")
        @helper.addLogs("[Actual ]   : Lead is created with Phone #{leadInfo.fetch("Phone")}")
        expect(leadInfo.fetch("Phone")).to eql @testDataJSON['Lead'][0]['Phone']
        @helper.addLogs("[Result ]   : Phone on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Company on lead")
        @helper.addLogs("[Expected ] : Company should be #{@testDataJSON['Lead'][0]['Company']}")
        @helper.addLogs("[Actual ]   : Lead is created with Company #{leadInfo.fetch("Company")}")
        expect(leadInfo.fetch("Company")).to eql @testDataJSON['Lead'][0]['Company']
        @helper.addLogs("[Result ]   : Company on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Status on lead")
        @helper.addLogs("[Expected ] : Status should be Open")
        @helper.addLogs("[Actual ]   : Lead is created with Status #{leadInfo.fetch("Status")}")
        expect(leadInfo.fetch("Status")).to eql "Open"
        @helper.addLogs("[Result ]   : Status on Lead checked successfully\n")
        insertedJourneyInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,Owner.Name, CreatedDate ,Status__c , NMD_Next_Contact_Date__c ,Primary_Email__c , Lead_Source__c , Lead_Source_Detail__c , Primary_Phone__c , Company_Name__c , Building_Interested_In__c , Locations_Interested__c , Interested_in_Number_of_Desks__c , Full_Time_Employees__c, Name   FROM Journey__c WHERE Primary_Email__c = '#{leadInfo.fetch("Email")}'")[0]
        @helper.addLogs("[Validate ] : Checking Journey is created on lead")
        @helper.addLogs("[Expected ] : Journey should create with name #{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
        @helper.addLogs("[Actual ]   : Journey is created with name #{insertedJourneyInfo.fetch("Name")}")
        expect(insertedJourneyInfo).to_not eql nil
        Helper.addRecordsToDelete("Journey__c", insertedJourneyInfo.fetch('Id'))
        @helper.addLogs("[Result ]   : Journey created successfully\n")
        @helper.addLogs("[Validate ] : Checking Journey owner should be logged in user")
        @helper.addLogs("[Expected ] : Owner of Journey should be owner of lead")
        @helper.addLogs("[Actual ]   : Owner of Journey is #{insertedJourneyInfo.fetch("Owner").fetch("Name")}")
        expect(insertedJourneyInfo.fetch("Owner").fetch("Name")).to eql @userInfo.fetch("display_name")
        @helper.addLogs("[Result ]   : Owner checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Lead source on Journey")
        @helper.addLogs("[Expected ] : Lead source should be Inbound Call")
        @helper.addLogs("[Actual ]   : Journey is created with lead source #{insertedJourneyInfo.fetch("Lead_Source__c")}")
        expect(insertedJourneyInfo.fetch("Lead_Source__c")).to eql "Inbound Call"
        @helper.addLogs("[Result ]   : Lead source checked successfully\n")
        @helper.addLogs("[Validate ] : Checking building interested name on Journey")
        @helper.addLogs("[Expected ] : Building interested should be #{@testDataJSON['Lead'][0]['Building_Interested_In__c']}")
        @helper.addLogs("[Actual ]   : Journey is created with building interested name #{insertedJourneyInfo.fetch("Building_Interested_In__c")}")
        expect(insertedJourneyInfo.fetch("Building_Interested_In__c")).to eql @building
        @helper.addLogs("[Result ]   : Building interested on Journey checked successfully\n")
        @helper.addLogs("[Validate ] : Checking NMD Next Contact Date on Journey")
        @helper.addLogs("[Expected ] : NMD Next Contact Date should be journey creation date")
        @helper.addLogs("[Actual ]   : Journey is created with NMD Next Contact Date #{insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")}")
        #expect(insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")).to eql insertedJourneyInfo[0].fetch("CreatedDate")
        @helper.addLogs("[Result ]   : NMD Next Contact Date on Journey checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Locations Interested on Journey")
        @helper.addLogs("[Expected ] : Locations Interested should be #{@testDataJSON['Lead'][0]['Building_Interested_In__c']}")
        @helper.addLogs("[Actual ]   : Journey is created with Locations Interested #{insertedJourneyInfo.fetch("Locations_Interested__c")}")
        expect(insertedJourneyInfo.fetch('Locations_Interested__c')).to eql @testDataJSON['Lead'][0]["Building_Interested_In__c"]
        @helper.addLogs("[Result ]   : Locations Interested on Journey checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Email on Journey")
        @helper.addLogs("[Expected ] : Email should be #{@testDataJSON['Lead'][0]['Email']}")
        @helper.addLogs("[Actual ]   : Journey is created with Email #{insertedJourneyInfo.fetch("Primary_Email__c")}")
        expect(insertedJourneyInfo.fetch("Primary_Email__c")).to eql @testDataJSON['Lead'][0]['Email']
        @helper.addLogs("[Result ]   : Email on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Phone on Journey")
        @helper.addLogs("[Expected ] : Number of Phone should be #{@testDataJSON['Lead'][0]['Phone']}")
        @helper.addLogs("[Actual ]   : Journey is created with Phone #{insertedJourneyInfo.fetch("Primary_Phone__c")}")
        expect(insertedJourneyInfo.fetch("Primary_Phone__c")).to eql @testDataJSON['Lead'][0]['Phone']
        @helper.addLogs("[Result ]   : Phone on Journey checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Company on Journey")
        @helper.addLogs("[Expected ] : Company should be #{@testDataJSON['Lead'][0]['Company']}")
        @helper.addLogs("[Actual ]   : Journey is created with Company #{insertedJourneyInfo.fetch("Company_Name__c")}")
        expect(insertedJourneyInfo.fetch("Company_Name__c")).to eql @testDataJSON['Lead'][0]['Company']
        @helper.addLogs("[Result ]   : Company on Journey checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Status on Journey")
        @helper.addLogs("[Expected ] : Status should be Started")
        @helper.addLogs("[Actual ]   : Journey is created with Status #{insertedJourneyInfo.fetch("Status__c")}")
        expect(insertedJourneyInfo.fetch("Status__c")).to eql "Started"
        @helper.addLogs("[Result ]   : Status on Journey checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Campaign on Journey")
        @helper.addLogs("[Expected ] : Campaign should be #{@campaignId}")
        @helper.addLogs("[Actual ]   : Journey is created with Campaign #{insertedJourneyInfo.fetch("CampaignId__c")} on it")
        expect(insertedJourneyInfo.fetch("CampaignId__c")).to eql @campaignId
        @helper.addLogs("[Result ]   : Status on Journey checked successfully\n")
        generatedActivityForLead = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Subject , CreatedDate,Status ,Lead_Source__c , Lead_Source_Detail__c,Owner.Name,Locations_Interested__c, Number_of_Full_Time_Employees__c,Interested_in_Number_of_Desks__c,Company__c,WhoId FROM Task WHERE WhoId = '#{leadInfo.fetch('Id')}'")[0]
        @helper.addLogs("[Validate ] : Checking Next Contact Date on existing Journey")
        @helper.addLogs("[Expected ] : Next Contact Date on existing Journey should update with duplicate lead submission date")
        @helper.addLogs("[Actual ]   : Next Contact Date on existing Journey is #{insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")}")
        #expect(existingJourneyInfo.fetch("NMD_Next_Contact_Date__c")).to match generatedActivityForLead.fetch("CreatedDate")
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
        @helper.addLogs("[Validate ] : Checking assigned to on activity")
        @helper.addLogs("[Expected ] : Assigned to on activity should be lead owner")
        @helper.addLogs("[Actual ]   : Assigned to on activity is #{generatedActivityForLead.fetch("Owner").fetch("Name")}")
        expect(generatedActivityForLead.fetch("Owner").fetch("Name")).to eql @userInfo.fetch("display_name")
        @helper.addLogs("[Result ]   : Activity assigned to field checked successfully")
        @helper.addLogs("[Validate ] : Checking status on activity")
        @helper.addLogs("[Expected ] : Status on activity should be Open")
        @helper.addLogs("[Actual ]   : Status on activity is #{generatedActivityForLead.fetch("Status")}")
        expect(generatedActivityForLead.fetch("Status")).to eql "Open"
        @helper.addLogs("[Result ]   : Activity assigned to field checked successfully")
        @helper.addLogs("[Validate ] : Checking status on activity")
        @helper.addLogs("[Expected ] : Status on activity should be Open")
        @helper.addLogs("[Actual ]   : Status on activity is #{generatedActivityForLead.fetch("Status")}")
        expect(generatedActivityForLead.fetch("Company__c")).to eql leadInfo.fetch('Company')
        @helper.addLogs("[Result ]   : Activity Status field checked successfully")
        @helper.addLogs("[Validate ] : Checking Location interested on activity")
        @helper.addLogs("[Expected ] : Location interested on activity should be #{leadInfo.fetch('Locations_Interested__c')}")
        @helper.addLogs("[Actual ]   : Location interested on activity is #{generatedActivityForLead.fetch("Status")}")
        expect(generatedActivityForLead.fetch("Locations_Interested__c")).to eql leadInfo.fetch('Locations_Interested__c')
        @helper.addLogs("[Result ]   : Activity Location interested field checked successfully")
        @helper.addLogs("[Validate ] : Checking Location interested on activity")
        @helper.addLogs("[Expected ] : Number of full time employees on activity should be #{leadInfo.fetch('Number_of_Full_Time_Employees__c')}")
        @helper.addLogs("[Actual ]   : Number of full time employees on activity is #{generatedActivityForLead.fetch("Number_of_Full_Time_Employees__c")}")
        expect(generatedActivityForLead.fetch("Number_of_Full_Time_Employees__c")).to eql leadInfo.fetch('Number_of_Full_Time_Employees__c')
        @helper.addLogs("[Result ]   : Activity Number of full time employees field checked successfully")
        @helper.addLogs("[Validate ] : Checking Number of desks on activity")
        @helper.addLogs("[Expected ] : Checking Number of desks on activity should be #{leadInfo.fetch('Number_of_Full_Time_Employees__c')}")
        @helper.addLogs("[Actual ]   : Checking Number of desks on activity is #{generatedActivityForLead.fetch("Number_of_Full_Time_Employees__c")}")
        expect(generatedActivityForLead.fetch("Interested_in_Number_of_Desks__c")).to eql leadInfo.fetch('Interested_in_Number_of_Desks__c')
        @helper.addLogs("[Result ]   : Activity Number of desks field checked successfully")
        @helper.addLogs('Success')
        @helper.postSuccessResult(2578)
      rescue Exception => e
        @helper.addLogs('Error')
        @helper.postFailResult(e, 2578)
        raise e
      end
    end
    it 'To Check Journey is Created While Importing New Lead from Kickbox When the Generate Journey on UI is Checked and Generate Journey in CSV is False and assign to the particular Campaign.', :'2583' => 'true' do
      begin
        leadInfo = @pageObject.upload_csv("john.snow#{rand(9999999999)}_qaauto@example.com", 'TRUE', @testDataJSON['Campaign'][0]['Name'],false,true,"Lead")[0]
        Helper.addRecordsToDelete("Lead", leadInfo.fetch('Id'))
        @helper.addLogs("[Expected ] : Lead should create with name #{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
        @helper.addLogs("[Actual ]   : Lead is created with name #{leadInfo.fetch("Name")}")
        expect(leadInfo).to_not eql nil
        expect(validate_case("Lead", @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0], leadInfo)).to be true
        @helper.addLogs("[Result ]   : Lead insertion checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Lead owner should be lead owner on campaign")
        @helper.addLogs("[Expected ] : Owner of lead should be Logged in user")
        @helper.addLogs("[Actual ]   : Owner of lead is #{leadInfo.fetch("Owner").fetch("Name")}")
        expect(leadInfo.fetch("Owner").fetch("Name")).to eql @pageObject.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
        @helper.addLogs("[Result ]   : Owner checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Lead source")
        @helper.addLogs("[Expected ] : Lead source should be Inbound Call")
        @helper.addLogs("[Actual ]   : Lead is created with lead source #{leadInfo.fetch("LeadSource")}")
        expect(leadInfo.fetch("LeadSource")).to eql "Inbound Call"
        @helper.addLogs("[Result ]   : Lead source checked successfully\n")
        @helper.addLogs("[Validate ] : Checking building interested name on Lead")
        @helper.addLogs("[Expected ] : Building interested name should be #{@testDataJSON['Lead'][0]['Building_Interested_In__c']}")
        @helper.addLogs("[Actual ]   : Lead is created with building interested name #{leadInfo.fetch("Building_Interested_Name__c")}")
        expect(leadInfo.fetch("Building_Interested_Name__c")).to eql @testDataJSON['Lead'][0]["Building_Interested_In__c"]
        @helper.addLogs("[Result ]   : Building interested name on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Generate Journey on Lead")
        @helper.addLogs("[Expected ] : Generate Journey should be TRUE")
        @helper.addLogs("[Actual ]   : Lead is created with Generate Journey =  #{leadInfo.fetch("Generate_Journey__c")}")
        expect(leadInfo.fetch("Generate_Journey__c")).to be true
        @helper.addLogs("[Result ]   : Generate Journey on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Locale on Lead")
        @helper.addLogs("[Expected ] : Locale should be en-US")
        @helper.addLogs("[Actual ]   : Lead is created with Locale =  #{leadInfo.fetch("Locale__c")}")
        expect(leadInfo.fetch("Locale__c")).to eql "en-US"
        @helper.addLogs("[Result ]   : Locale on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Country code on Lead")
        @helper.addLogs("[Expected ] : Country code should be IN")
        @helper.addLogs("[Actual ]   : Lead is created with Country code =  #{leadInfo.fetch("Country_Code__c")}")
        expect(leadInfo.fetch("Country_Code__c")).to eql "IN"
        @helper.addLogs("[Result ]   : Country code on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking building interested")
        @helper.addLogs("[Expected ] : Building interested should be #{@testDataJSON['Lead'][0]["Building_Interested_In__c"]}")
        @helper.addLogs("[Actual ]   : Lead is created with building interested #{leadInfo.fetch("Building_Interested_In__c")}")
        expect(leadInfo.fetch("Building_Interested_In__c")).to eql @building
        @helper.addLogs("[Result ]   : Building interested on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Journey created date on lead")
        @helper.addLogs("[Expected ] : Journey created date should be #{leadInfo.fetch("CreatedDate")}")
        @helper.addLogs("[Actual ]   : Lead is created with Journey created date #{leadInfo.fetch("Journey_Created_On__c")}")
        #expect(insertedLeadInfo.fetch("Journey_Created_On__c")).to eql insertedJourneyInfo[0].fetch("CreatedDate")
        @helper.addLogs("[Result ]   : Journey created date on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Locations Interested on lead")
        @helper.addLogs("[Expected ] : Locations Interested should be #{@testDataJSON['Lead'][0]["Building_Interested_In__c"]}")
        @helper.addLogs("[Actual ]   : Lead is created with Locations Interested #{leadInfo.fetch("Locations_Interested__c")}")
        expect(leadInfo.fetch("Locations_Interested__c")).to eql @testDataJSON['Lead'][0]["Building_Interested_In__c"]
        @helper.addLogs("[Result ]   : Locations Interested on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Email on lead")
        @helper.addLogs("[Expected ] : Email should be #{@testDataJSON['Lead'][0]['Email']}")
        @helper.addLogs("[Actual ]   : Lead is created with Email #{leadInfo.fetch("Email")}")
        expect(leadInfo.fetch("Email")).to eql @testDataJSON['Lead'][0]['Email']
        @helper.addLogs("[Result ]   : Email on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Phone on lead")
        @helper.addLogs("[Expected ] : Number of Phone should be #{@testDataJSON['Lead'][0]['Phone']}")
        @helper.addLogs("[Actual ]   : Lead is created with Phone #{leadInfo.fetch("Phone")}")
        expect(leadInfo.fetch("Phone")).to eql @testDataJSON['Lead'][0]['Phone']
        @helper.addLogs("[Result ]   : Phone on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Company on lead")
        @helper.addLogs("[Expected ] : Company should be #{@testDataJSON['Lead'][0]['Company']}")
        @helper.addLogs("[Actual ]   : Lead is created with Company #{leadInfo.fetch("Company")}")
        expect(leadInfo.fetch("Company")).to eql @testDataJSON['Lead'][0]['Company']
        @helper.addLogs("[Result ]   : Company on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Status on lead")
        @helper.addLogs("[Expected ] : Status should be Open")
        @helper.addLogs("[Actual ]   : Lead is created with Status #{leadInfo.fetch("Status")}")
        expect(leadInfo.fetch("Status")).to eql "Open"
        @helper.addLogs("[Result ]   : Status on Lead checked successfully\n")
        insertedJourneyInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,Owner.Name, CreatedDate ,Status__c , NMD_Next_Contact_Date__c ,Primary_Email__c , Lead_Source__c , Lead_Source_Detail__c , Primary_Phone__c , Company_Name__c , Building_Interested_In__c , Locations_Interested__c , Interested_in_Number_of_Desks__c , Full_Time_Employees__c, Name   FROM Journey__c WHERE Primary_Email__c = '#{leadInfo.fetch("Email")}'")[0]
        @helper.addLogs("[Validate ] : Checking Journey is created on lead")
        @helper.addLogs("[Expected ] : Journey should create with name #{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
        @helper.addLogs("[Actual ]   : Journey is created with name #{insertedJourneyInfo.fetch("Name")}")
        expect(insertedJourneyInfo).to_not eql nil
        Helper.addRecordsToDelete("Journey__c", insertedJourneyInfo.fetch('Id'))
        @helper.addLogs("[Result ]   : Journey created successfully\n")
        @helper.addLogs("[Validate ] : Checking Journey owner should be logged in user")
        @helper.addLogs("[Expected ] : Owner of Journey should be owner of lead")
        @helper.addLogs("[Actual ]   : Owner of Journey is #{insertedJourneyInfo.fetch("Owner").fetch("Name")}")
        expect(insertedJourneyInfo.fetch("Owner").fetch("Name")).to eql @userInfo.fetch("display_name")
        @helper.addLogs("[Result ]   : Owner checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Lead source on Journey")
        @helper.addLogs("[Expected ] : Lead source should be Inbound Call")
        @helper.addLogs("[Actual ]   : Journey is created with lead source #{insertedJourneyInfo.fetch("Lead_Source__c")}")
        expect(insertedJourneyInfo.fetch("Lead_Source__c")).to eql "Inbound Call"
        @helper.addLogs("[Result ]   : Lead source checked successfully\n")
        @helper.addLogs("[Validate ] : Checking building interested name on Journey")
        @helper.addLogs("[Expected ] : Building interested should be #{@testDataJSON['Lead'][0]['Building_Interested_In__c']}")
        @helper.addLogs("[Actual ]   : Journey is created with building interested name #{insertedJourneyInfo.fetch("Building_Interested_In__c")}")
        expect(insertedJourneyInfo.fetch("Building_Interested_In__c")).to eql @building
        @helper.addLogs("[Result ]   : Building interested on Journey checked successfully\n")
        @helper.addLogs("[Validate ] : Checking NMD Next Contact Date on Journey")
        @helper.addLogs("[Expected ] : NMD Next Contact Date should be journey creation date")
        @helper.addLogs("[Actual ]   : Journey is created with NMD Next Contact Date #{insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")}")
        #expect(insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")).to eql insertedJourneyInfo[0].fetch("CreatedDate")
        @helper.addLogs("[Result ]   : NMD Next Contact Date on Journey checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Locations Interested on Journey")
        @helper.addLogs("[Expected ] : Locations Interested should be #{@testDataJSON['Lead'][0]['Building_Interested_In__c']}")
        @helper.addLogs("[Actual ]   : Journey is created with Locations Interested #{insertedJourneyInfo.fetch("Locations_Interested__c")}")
        expect(insertedJourneyInfo.fetch('Locations_Interested__c')).to eql @testDataJSON['Lead'][0]["Building_Interested_In__c"]
        @helper.addLogs("[Result ]   : Locations Interested on Journey checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Email on Journey")
        @helper.addLogs("[Expected ] : Email should be #{@testDataJSON['Lead'][0]['Email']}")
        @helper.addLogs("[Actual ]   : Journey is created with Email #{insertedJourneyInfo.fetch("Primary_Email__c")}")
        expect(insertedJourneyInfo.fetch("Primary_Email__c")).to eql @testDataJSON['Lead'][0]['Email']
        @helper.addLogs("[Result ]   : Email on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Phone on Journey")
        @helper.addLogs("[Expected ] : Number of Phone should be #{@testDataJSON['Lead'][0]['Phone']}")
        @helper.addLogs("[Actual ]   : Journey is created with Phone #{insertedJourneyInfo.fetch("Primary_Phone__c")}")
        expect(insertedJourneyInfo.fetch("Primary_Phone__c")).to eql @testDataJSON['Lead'][0]['Phone']
        @helper.addLogs("[Result ]   : Phone on Journey checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Company on Journey")
        @helper.addLogs("[Expected ] : Company should be #{@testDataJSON['Lead'][0]['Company']}")
        @helper.addLogs("[Actual ]   : Journey is created with Company #{insertedJourneyInfo.fetch("Company_Name__c")}")
        expect(insertedJourneyInfo.fetch("Company_Name__c")).to eql @testDataJSON['Lead'][0]['Company']
        @helper.addLogs("[Result ]   : Company on Journey checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Status on Journey")
        @helper.addLogs("[Expected ] : Status should be Started")
        @helper.addLogs("[Actual ]   : Journey is created with Status #{insertedJourneyInfo.fetch("Status__c")}")
        expect(insertedJourneyInfo.fetch("Status__c")).to eql "Started"
        @helper.addLogs("[Result ]   : Status on Journey checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Campaign on Journey")
        @helper.addLogs("[Expected ] : Campaign should be #{@campaignId}")
        @helper.addLogs("[Actual ]   : Journey is created with Campaign #{insertedJourneyInfo.fetch("CampaignId__c")} on it")
        expect(insertedJourneyInfo.fetch("CampaignId__c")).to eql @campaignId
        @helper.addLogs("[Result ]   : Status on Journey checked successfully\n")
        generatedActivityForLead = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Subject , CreatedDate,Status ,Lead_Source__c , Lead_Source_Detail__c,Owner.Name,Locations_Interested__c, Number_of_Full_Time_Employees__c,Interested_in_Number_of_Desks__c,Company__c,WhoId FROM Task WHERE WhoId = '#{leadInfo.fetch('Id')}'")[0]
        @helper.addLogs("[Validate ] : Checking Next Contact Date on existing Journey")
        @helper.addLogs("[Expected ] : Next Contact Date on existing Journey should update with duplicate lead submission date")
        @helper.addLogs("[Actual ]   : Next Contact Date on existing Journey is #{insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")}")
        #expect(existingJourneyInfo.fetch("NMD_Next_Contact_Date__c")).to match generatedActivityForLead.fetch("CreatedDate")
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
        @helper.addLogs("[Validate ] : Checking assigned to on activity")
        @helper.addLogs("[Expected ] : Assigned to on activity should be lead owner")
        @helper.addLogs("[Actual ]   : Assigned to on activity is #{generatedActivityForLead.fetch("Owner").fetch("Name")}")
        expect(generatedActivityForLead.fetch("Owner").fetch("Name")).to eql @userInfo.fetch("display_name")
        @helper.addLogs("[Result ]   : Activity assigned to field checked successfully")
        @helper.addLogs("[Validate ] : Checking status on activity")
        @helper.addLogs("[Expected ] : Status on activity should be Open")
        @helper.addLogs("[Actual ]   : Status on activity is #{generatedActivityForLead.fetch("Status")}")
        expect(generatedActivityForLead.fetch("Status")).to eql "Open"
        @helper.addLogs("[Result ]   : Activity assigned to field checked successfully")
        @helper.addLogs("[Validate ] : Checking status on activity")
        @helper.addLogs("[Expected ] : Status on activity should be Open")
        @helper.addLogs("[Actual ]   : Status on activity is #{generatedActivityForLead.fetch("Status")}")
        expect(generatedActivityForLead.fetch("Company__c")).to eql leadInfo.fetch('Company')
        @helper.addLogs("[Result ]   : Activity Status field checked successfully")
        @helper.addLogs("[Validate ] : Checking Location interested on activity")
        @helper.addLogs("[Expected ] : Location interested on activity should be #{leadInfo.fetch('Locations_Interested__c')}")
        @helper.addLogs("[Actual ]   : Location interested on activity is #{generatedActivityForLead.fetch("Status")}")
        expect(generatedActivityForLead.fetch("Locations_Interested__c")).to eql leadInfo.fetch('Locations_Interested__c')
        @helper.addLogs("[Result ]   : Activity Location interested field checked successfully")
        @helper.addLogs("[Validate ] : Checking Location interested on activity")
        @helper.addLogs("[Expected ] : Number of full time employees on activity should be #{leadInfo.fetch('Number_of_Full_Time_Employees__c')}")
        @helper.addLogs("[Actual ]   : Number of full time employees on activity is #{generatedActivityForLead.fetch("Number_of_Full_Time_Employees__c")}")
        expect(generatedActivityForLead.fetch("Number_of_Full_Time_Employees__c")).to eql leadInfo.fetch('Number_of_Full_Time_Employees__c')
        @helper.addLogs("[Result ]   : Activity Number of full time employees field checked successfully")
        @helper.addLogs("[Validate ] : Checking Number of desks on activity")
        @helper.addLogs("[Expected ] : Checking Number of desks on activity should be #{leadInfo.fetch('Number_of_Full_Time_Employees__c')}")
        @helper.addLogs("[Actual ]   : Checking Number of desks on activity is #{generatedActivityForLead.fetch("Number_of_Full_Time_Employees__c")}")
        expect(generatedActivityForLead.fetch("Interested_in_Number_of_Desks__c")).to eql leadInfo.fetch('Interested_in_Number_of_Desks__c')
        @helper.addLogs("[Result ]   : Activity Number of desks field checked successfully")
        @helper.addLogs('Success')
        @helper.postSuccessResult(2578)
      rescue Exception => e
        @helper.addLogs('Error')
        @helper.postFailResult(e, 2578)
        raise e
      end
    end
    it 'To Check Journey is Not being Created While Importing New Lead From Kickbox When the Generate Journey on UI is Unchecked and Generate Journey in CSV is False and assign to the particular Campaign.', :'2580' => 'true' do
      begin
        leadInfo = @pageObject.upload_csv("john.snow#{rand(9999999999)}_qaauto@example.com", 'FALSE', @testDataJSON['Campaign'][0]['Name'],false,true,"Lead")[0]
        Helper.addRecordsToDelete("Lead", leadInfo.fetch('Id'))
        @helper.addLogs("[Expected ] : Lead should create with name #{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
        @helper.addLogs("[Actual ]   : Lead is created with name #{leadInfo.fetch("Name")}")
        expect(leadInfo).to_not eql nil
        expect(validate_case("Lead", @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0], leadInfo)).to be true
        @helper.addLogs("[Result ]   : Lead insertion checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Lead owner should be lead owner on campaign")
        @helper.addLogs("[Expected ] : Owner of lead should be Logged in user")
        @helper.addLogs("[Actual ]   : Owner of lead is #{leadInfo.fetch("Owner").fetch("Name")}")
        expect(leadInfo.fetch("Owner").fetch("Name")).to eql @pageObject.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
        @helper.addLogs("[Result ]   : Owner checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Lead source")
        @helper.addLogs("[Expected ] : Lead source should be Inbound Call")
        @helper.addLogs("[Actual ]   : Lead is created with lead source #{leadInfo.fetch("LeadSource")}")
        expect(leadInfo.fetch("LeadSource")).to eql "Inbound Call"
        @helper.addLogs("[Result ]   : Lead source checked successfully\n")
        @helper.addLogs("[Validate ] : Checking building interested name on Lead")
        @helper.addLogs("[Expected ] : Building interested name should be #{@testDataJSON['Lead'][0]['Building_Interested_In__c']}")
        @helper.addLogs("[Actual ]   : Lead is created with building interested name #{leadInfo.fetch("Building_Interested_Name__c")}")
        expect(leadInfo.fetch("Building_Interested_Name__c")).to eql @testDataJSON['Lead'][0]["Building_Interested_In__c"]
        @helper.addLogs("[Result ]   : Building interested name on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Generate Journey on Lead")
        @helper.addLogs("[Expected ] : Generate Journey should be TRUE")
        @helper.addLogs("[Actual ]   : Lead is created with Generate Journey =  #{leadInfo.fetch("Generate_Journey__c")}")
        expect(leadInfo.fetch("Generate_Journey__c")).to be true
        @helper.addLogs("[Result ]   : Generate Journey on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Locale on Lead")
        @helper.addLogs("[Expected ] : Locale should be en-US")
        @helper.addLogs("[Actual ]   : Lead is created with Locale =  #{leadInfo.fetch("Locale__c")}")
        expect(leadInfo.fetch("Locale__c")).to eql "en-US"
        @helper.addLogs("[Result ]   : Locale on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Country code on Lead")
        @helper.addLogs("[Expected ] : Country code should be IN")
        @helper.addLogs("[Actual ]   : Lead is created with Country code =  #{leadInfo.fetch("Country_Code__c")}")
        expect(leadInfo.fetch("Country_Code__c")).to eql "IN"
        @helper.addLogs("[Result ]   : Country code on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking building interested")
        @helper.addLogs("[Expected ] : Building interested should be #{@testDataJSON['Lead'][0]["Building_Interested_In__c"]}")
        @helper.addLogs("[Actual ]   : Lead is created with building interested #{leadInfo.fetch("Building_Interested_In__c")}")
        expect(leadInfo.fetch("Building_Interested_In__c")).to eql @building
        @helper.addLogs("[Result ]   : Building interested on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Journey created date on lead")
        @helper.addLogs("[Expected ] : Journey created date should be #{leadInfo.fetch("CreatedDate")}")
        @helper.addLogs("[Actual ]   : Lead is created with Journey created date #{leadInfo.fetch("Journey_Created_On__c")}")
        #expect(insertedLeadInfo.fetch("Journey_Created_On__c")).to eql insertedJourneyInfo[0].fetch("CreatedDate")
        @helper.addLogs("[Result ]   : Journey created date on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Locations Interested on lead")
        @helper.addLogs("[Expected ] : Locations Interested should be #{@testDataJSON['Lead'][0]["Building_Interested_In__c"]}")
        @helper.addLogs("[Actual ]   : Lead is created with Locations Interested #{leadInfo.fetch("Locations_Interested__c")}")
        expect(leadInfo.fetch("Locations_Interested__c")).to eql @testDataJSON['Lead'][0]["Building_Interested_In__c"]
        @helper.addLogs("[Result ]   : Locations Interested on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Email on lead")
        @helper.addLogs("[Expected ] : Email should be #{@testDataJSON['Lead'][0]['Email']}")
        @helper.addLogs("[Actual ]   : Lead is created with Email #{leadInfo.fetch("Email")}")
        expect(leadInfo.fetch("Email")).to eql @testDataJSON['Lead'][0]['Email']
        @helper.addLogs("[Result ]   : Email on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Phone on lead")
        @helper.addLogs("[Expected ] : Number of Phone should be #{@testDataJSON['Lead'][0]['Phone']}")
        @helper.addLogs("[Actual ]   : Lead is created with Phone #{leadInfo.fetch("Phone")}")
        expect(leadInfo.fetch("Phone")).to eql @testDataJSON['Lead'][0]['Phone']
        @helper.addLogs("[Result ]   : Phone on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Company on lead")
        @helper.addLogs("[Expected ] : Company should be #{@testDataJSON['Lead'][0]['Company']}")
        @helper.addLogs("[Actual ]   : Lead is created with Company #{leadInfo.fetch("Company")}")
        expect(leadInfo.fetch("Company")).to eql @testDataJSON['Lead'][0]['Company']
        @helper.addLogs("[Result ]   : Company on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Status on lead")
        @helper.addLogs("[Expected ] : Status should be Open")
        @helper.addLogs("[Actual ]   : Lead is created with Status #{leadInfo.fetch("Status")}")
        expect(leadInfo.fetch("Status")).to eql "Open"
        @helper.addLogs("[Result ]   : Status on Lead checked successfully\n")
        insertedJourneyInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,Owner.Name,CampaignId__c, CreatedDate ,Status__c , NMD_Next_Contact_Date__c ,Primary_Email__c , Lead_Source__c , Lead_Source_Detail__c , Primary_Phone__c , Company_Name__c , Building_Interested_In__c , Locations_Interested__c , Interested_in_Number_of_Desks__c , Full_Time_Employees__c, Name   FROM Journey__c WHERE Primary_Email__c = '#{leadInfo.fetch("Email")}'")[0]
        @helper.addLogs("[Validate ] : Checking Journey is created on lead")
        @helper.addLogs("[Expected ] : Journey should not be created")
        @helper.addLogs("[Actual ]   : Journey is created #{insertedJourneyInfo.nil? ? 'No' : 'Yes'}")
        expect(insertedJourneyInfo).to eql nil
        @helper.addLogs("[Result ]   : Journey creation checked successfully\n")
        generatedActivityForLead = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Subject , CreatedDate,Status ,Lead_Source__c , Lead_Source_Detail__c,Owner.Name,Locations_Interested__c, Number_of_Full_Time_Employees__c,Interested_in_Number_of_Desks__c,Company__c,WhoId FROM Task WHERE WhoId = '#{leadInfo.fetch('Id')}'")[0]
        @helper.addLogs("[Validate ] : Checking Next Contact Date on existing Journey")
        @helper.addLogs("[Expected ] : Next Contact Date on existing Journey should update with duplicate lead submission date")
        @helper.addLogs("[Actual ]   : Next Contact Date on existing Journey is #{insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")}")
        #expect(existingJourneyInfo.fetch("NMD_Next_Contact_Date__c")).to match generatedActivityForLead.fetch("CreatedDate")
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
        @helper.addLogs("[Validate ] : Checking assigned to on activity")
        @helper.addLogs("[Expected ] : Assigned to on activity should be lead owner")
        @helper.addLogs("[Actual ]   : Assigned to on activity is #{generatedActivityForLead.fetch("Owner").fetch("Name")}")
        expect(generatedActivityForLead.fetch("Owner").fetch("Name")).to eql @userInfo.fetch("display_name")
        @helper.addLogs("[Result ]   : Activity assigned to field checked successfully")
        @helper.addLogs("[Validate ] : Checking status on activity")
        @helper.addLogs("[Expected ] : Status on activity should be Open")
        @helper.addLogs("[Actual ]   : Status on activity is #{generatedActivityForLead.fetch("Status")}")
        expect(generatedActivityForLead.fetch("Status")).to eql "Open"
        @helper.addLogs("[Result ]   : Activity assigned to field checked successfully")
        @helper.addLogs("[Validate ] : Checking status on activity")
        @helper.addLogs("[Expected ] : Status on activity should be Open")
        @helper.addLogs("[Actual ]   : Status on activity is #{generatedActivityForLead.fetch("Status")}")
        expect(generatedActivityForLead.fetch("Company__c")).to eql leadInfo.fetch('Company')
        @helper.addLogs("[Result ]   : Activity Status field checked successfully")
        @helper.addLogs("[Validate ] : Checking Location interested on activity")
        @helper.addLogs("[Expected ] : Location interested on activity should be #{leadInfo.fetch('Locations_Interested__c')}")
        @helper.addLogs("[Actual ]   : Location interested on activity is #{generatedActivityForLead.fetch("Status")}")
        expect(generatedActivityForLead.fetch("Locations_Interested__c")).to eql leadInfo.fetch('Locations_Interested__c')
        @helper.addLogs("[Result ]   : Activity Location interested field checked successfully")
        @helper.addLogs("[Validate ] : Checking Location interested on activity")
        @helper.addLogs("[Expected ] : Number of full time employees on activity should be #{leadInfo.fetch('Number_of_Full_Time_Employees__c')}")
        @helper.addLogs("[Actual ]   : Number of full time employees on activity is #{generatedActivityForLead.fetch("Number_of_Full_Time_Employees__c")}")
        expect(generatedActivityForLead.fetch("Number_of_Full_Time_Employees__c")).to eql leadInfo.fetch('Number_of_Full_Time_Employees__c')
        @helper.addLogs("[Result ]   : Activity Number of full time employees field checked successfully")
        @helper.addLogs("[Validate ] : Checking Number of desks on activity")
        @helper.addLogs("[Expected ] : Checking Number of desks on activity should be #{leadInfo.fetch('Number_of_Full_Time_Employees__c')}")
        @helper.addLogs("[Actual ]   : Checking Number of desks on activity is #{generatedActivityForLead.fetch("Number_of_Full_Time_Employees__c")}")
        expect(generatedActivityForLead.fetch("Interested_in_Number_of_Desks__c")).to eql leadInfo.fetch('Interested_in_Number_of_Desks__c')
        @helper.addLogs("[Result ]   : Activity Number of desks field checked successfully")
        @helper.addLogs('Success')
        @helper.postSuccessResult(2578)
      rescue Exception => e
        @helper.addLogs('Error')
        @helper.postFailResult(e, 2578)
        raise e
      end
    end
  end
  context "Kickbox Importer While Insertion of New Lead assign to the Particular Campaign Based on Email Address Criterias" do
    before(:all) do
      @testDataJSON['Campaign'][0]['Lead Owner'] = ''
      @testDataJSON['Campaign'][0]['Email Address'] = 'vikhroliwest@wework.co.in'
      @testDataJSON['Campaign'][0]['City'] = ''
      @campaignId = @helper.instance_variable_get(:@restForce).getRecords("SELECT id FROM Campaign WHERE Name = '#{@testDataJSON['Campaign'][0]['Name']}'")[0]
      @helper.update_campaign(@campaignId.fetch('Id'),nil,@testDataJSON['Campaign'][0]['Email Address'])
    end
    it 'To Check Journey is created While Importing New lead from Kickbox When the Generate Journey on UI is Checked and Generate journey in CSV is Blank and assign to the particular Campaign Based on Email Address Scenario.', :'2585' => 'true' do
      begin
        leadInfo = @pageObject.upload_csv("john.snow#{rand(9999999999)}_qaauto@example.com", @testDataJSON['Campaign'][0]['Name'],true,true,"Lead")[0]
        Helper.addRecordsToDelete("Lead", leadInfo.fetch('Id'))
        @helper.addLogs("[Expected ] : Lead should create with name #{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
        @helper.addLogs("[Actual ]   : Lead is created with name #{leadInfo.fetch("Name")}")
        expect(leadInfo).to_not eql nil
        expect(validate_case("Lead", @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0], leadInfo)).to be true
        @helper.addLogs("[Result ]   : Lead insertion checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Lead owner should be according to Campaign assignment as here Campaign assignment is done on the basis of Email address scenario")
        @helper.addLogs("[Expected ] : Owner of lead should be user/queue assigned to building of provided email address")
        @helper.addLogs("[Actual ]   : Owner of lead is #{leadInfo.fetch("Owner").fetch("Name")}")
        expect(leadInfo.fetch("Owner").fetch("Name")).to eql @pageObject.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
        @helper.addLogs("[Result ]   : Owner checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Lead source")
        @helper.addLogs("[Expected ] : Lead source should be Inbound Call")
        @helper.addLogs("[Actual ]   : Lead is created with lead source #{leadInfo.fetch("LeadSource")}")
        expect(leadInfo.fetch("LeadSource")).to eql "Inbound Call"
        @helper.addLogs("[Result ]   : Lead source checked successfully\n")
        @helper.addLogs("[Validate ] : Checking building interested name on Lead")
        @helper.addLogs("[Expected ] : Building interested name should be #{@testDataJSON['Lead'][0]['Building_Interested_In__c']}")
        @helper.addLogs("[Actual ]   : Lead is created with building interested name #{leadInfo.fetch("Building_Interested_Name__c")}")
        expect(leadInfo.fetch("Building_Interested_Name__c")).to eql @testDataJSON['Lead'][0]["Building_Interested_In__c"]
        @helper.addLogs("[Result ]   : Building interested name on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Generate Journey on Lead")
        @helper.addLogs("[Expected ] : Generate Journey should be TRUE")
        @helper.addLogs("[Actual ]   : Lead is created with Generate Journey =  #{leadInfo.fetch("Generate_Journey__c")}")
        expect(leadInfo.fetch("Generate_Journey__c")).to be true
        @helper.addLogs("[Result ]   : Generate Journey on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Locale on Lead")
        @helper.addLogs("[Expected ] : Locale should be en-US")
        @helper.addLogs("[Actual ]   : Lead is created with Locale =  #{leadInfo.fetch("Locale__c")}")
        expect(leadInfo.fetch("Locale__c")).to eql "en-US"
        @helper.addLogs("[Result ]   : Locale on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Country code on Lead")
        @helper.addLogs("[Expected ] : Country code should be IN")
        @helper.addLogs("[Actual ]   : Lead is created with Country code =  #{leadInfo.fetch("Country_Code__c")}")
        expect(leadInfo.fetch("Country_Code__c")).to eql "IN"
        @helper.addLogs("[Result ]   : Country code on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking building interested")
        @helper.addLogs("[Expected ] : Building interested should be #{@testDataJSON['Lead'][0]["Building_Interested_In__c"]}")
        @helper.addLogs("[Actual ]   : Lead is created with building interested #{leadInfo.fetch("Building_Interested_In__c")}")
        expect(leadInfo.fetch("Building_Interested_In__c")).to eql @building
        @helper.addLogs("[Result ]   : Building interested on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Journey created date on lead")
        @helper.addLogs("[Expected ] : Journey created date should be #{leadInfo.fetch("CreatedDate")}")
        @helper.addLogs("[Actual ]   : Lead is created with Journey created date #{leadInfo.fetch("Journey_Created_On__c")}")
        #expect(insertedLeadInfo.fetch("Journey_Created_On__c")).to eql insertedJourneyInfo[0].fetch("CreatedDate")
        @helper.addLogs("[Result ]   : Journey created date on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Locations Interested on lead")
        @helper.addLogs("[Expected ] : Locations Interested should be #{@testDataJSON['Lead'][0]["Building_Interested_In__c"]}")
        @helper.addLogs("[Actual ]   : Lead is created with Locations Interested #{leadInfo.fetch("Locations_Interested__c")}")
        expect(leadInfo.fetch("Locations_Interested__c")).to eql @testDataJSON['Lead'][0]["Building_Interested_In__c"]
        @helper.addLogs("[Result ]   : Locations Interested on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Email on lead")
        @helper.addLogs("[Expected ] : Email should be #{@testDataJSON['Lead'][0]['Email']}")
        @helper.addLogs("[Actual ]   : Lead is created with Email #{leadInfo.fetch("Email")}")
        expect(leadInfo.fetch("Email")).to eql @testDataJSON['Lead'][0]['Email']
        @helper.addLogs("[Result ]   : Email on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Phone on lead")
        @helper.addLogs("[Expected ] : Number of Phone should be #{@testDataJSON['Lead'][0]['Phone']}")
        @helper.addLogs("[Actual ]   : Lead is created with Phone #{leadInfo.fetch("Phone")}")
        expect(leadInfo.fetch("Phone")).to eql @testDataJSON['Lead'][0]['Phone']
        @helper.addLogs("[Result ]   : Phone on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Company on lead")
        @helper.addLogs("[Expected ] : Company should be #{@testDataJSON['Lead'][0]['Company']}")
        @helper.addLogs("[Actual ]   : Lead is created with Company #{leadInfo.fetch("Company")}")
        expect(leadInfo.fetch("Company")).to eql @testDataJSON['Lead'][0]['Company']
        @helper.addLogs("[Result ]   : Company on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Status on lead")
        @helper.addLogs("[Expected ] : Status should be Open")
        @helper.addLogs("[Actual ]   : Lead is created with Status #{leadInfo.fetch("Status")}")
        expect(leadInfo.fetch("Status")).to eql "Open"
        @helper.addLogs("[Result ]   : Status on Lead checked successfully\n")
        insertedJourneyInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,Owner.Name, CreatedDate ,Status__c , NMD_Next_Contact_Date__c ,Primary_Email__c , Lead_Source__c , Lead_Source_Detail__c , Primary_Phone__c , Company_Name__c , Building_Interested_In__c , Locations_Interested__c , Interested_in_Number_of_Desks__c , Full_Time_Employees__c, Name   FROM Journey__c WHERE Primary_Email__c = '#{leadInfo.fetch("Email")}'")[0]
        @helper.addLogs("[Validate ] : Checking Journey is created on lead")
        @helper.addLogs("[Expected ] : Journey should create with name #{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
        @helper.addLogs("[Actual ]   : Journey is created with name #{insertedJourneyInfo.fetch("Name")}")
        expect(insertedJourneyInfo).to_not eql nil
        Helper.addRecordsToDelete("Journey__c", insertedJourneyInfo.fetch('Id'))
        @helper.addLogs("[Result ]   : Journey created successfully\n")
        @helper.addLogs("[Validate ] : Checking Journey owner should be logged in user")
        @helper.addLogs("[Expected ] : Owner of Journey should be owner of lead")
        @helper.addLogs("[Actual ]   : Owner of Journey is #{insertedJourneyInfo.fetch("Owner").fetch("Name")}")
        expect(insertedJourneyInfo.fetch("Owner").fetch("Name")).to eql @userInfo.fetch("display_name")
        @helper.addLogs("[Result ]   : Owner checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Lead source on Journey")
        @helper.addLogs("[Expected ] : Lead source should be Inbound Call")
        @helper.addLogs("[Actual ]   : Journey is created with lead source #{insertedJourneyInfo.fetch("Lead_Source__c")}")
        expect(insertedJourneyInfo.fetch("Lead_Source__c")).to eql "Inbound Call"
        @helper.addLogs("[Result ]   : Lead source checked successfully\n")
        @helper.addLogs("[Validate ] : Checking building interested name on Journey")
        @helper.addLogs("[Expected ] : Building interested should be #{@testDataJSON['Lead'][0]['Building_Interested_In__c']}")
        @helper.addLogs("[Actual ]   : Journey is created with building interested name #{insertedJourneyInfo.fetch("Building_Interested_In__c")}")
        expect(insertedJourneyInfo.fetch("Building_Interested_In__c")).to eql @building
        @helper.addLogs("[Result ]   : Building interested on Journey checked successfully\n")
        @helper.addLogs("[Validate ] : Checking NMD Next Contact Date on Journey")
        @helper.addLogs("[Expected ] : NMD Next Contact Date should be journey creation date")
        @helper.addLogs("[Actual ]   : Journey is created with NMD Next Contact Date #{insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")}")
        #expect(insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")).to eql insertedJourneyInfo[0].fetch("CreatedDate")
        @helper.addLogs("[Result ]   : NMD Next Contact Date on Journey checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Locations Interested on Journey")
        @helper.addLogs("[Expected ] : Locations Interested should be #{@testDataJSON['Lead'][0]['Building_Interested_In__c']}")
        @helper.addLogs("[Actual ]   : Journey is created with Locations Interested #{insertedJourneyInfo.fetch("Locations_Interested__c")}")
        expect(insertedJourneyInfo.fetch('Locations_Interested__c')).to eql @testDataJSON['Lead'][0]["Building_Interested_In__c"]
        @helper.addLogs("[Result ]   : Locations Interested on Journey checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Email on Journey")
        @helper.addLogs("[Expected ] : Email should be #{@testDataJSON['Lead'][0]['Email']}")
        @helper.addLogs("[Actual ]   : Journey is created with Email #{insertedJourneyInfo.fetch("Primary_Email__c")}")
        expect(insertedJourneyInfo.fetch("Primary_Email__c")).to eql @testDataJSON['Lead'][0]['Email']
        @helper.addLogs("[Result ]   : Email on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Phone on Journey")
        @helper.addLogs("[Expected ] : Number of Phone should be #{@testDataJSON['Lead'][0]['Phone']}")
        @helper.addLogs("[Actual ]   : Journey is created with Phone #{insertedJourneyInfo.fetch("Primary_Phone__c")}")
        expect(insertedJourneyInfo.fetch("Primary_Phone__c")).to eql @testDataJSON['Lead'][0]['Phone']
        @helper.addLogs("[Result ]   : Phone on Journey checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Company on Journey")
        @helper.addLogs("[Expected ] : Company should be #{@testDataJSON['Lead'][0]['Company']}")
        @helper.addLogs("[Actual ]   : Journey is created with Company #{insertedJourneyInfo.fetch("Company_Name__c")}")
        expect(insertedJourneyInfo.fetch("Company_Name__c")).to eql @testDataJSON['Lead'][0]['Company']
        @helper.addLogs("[Result ]   : Company on Journey checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Status on Journey")
        @helper.addLogs("[Expected ] : Status should be Started")
        @helper.addLogs("[Actual ]   : Journey is created with Status #{insertedJourneyInfo.fetch("Status__c")}")
        expect(insertedJourneyInfo.fetch("Status__c")).to eql "Started"
        @helper.addLogs("[Result ]   : Status on Journey checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Campaign on Journey")
        @helper.addLogs("[Expected ] : Campaign should be #{@campaignId}")
        @helper.addLogs("[Actual ]   : Journey is created with Campaign #{insertedJourneyInfo.fetch("CampaignId__c")} on it")
        expect(insertedJourneyInfo.fetch("CampaignId__c")).to eql @campaignId
        @helper.addLogs("[Result ]   : Status on Journey checked successfully\n")
        generatedActivityForLead = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Subject , CreatedDate,Status ,Lead_Source__c , Lead_Source_Detail__c,Owner.Name,Locations_Interested__c, Number_of_Full_Time_Employees__c,Interested_in_Number_of_Desks__c,Company__c,WhoId FROM Task WHERE WhoId = '#{leadInfo.fetch('Id')}'")[0]
        @helper.addLogs("[Validate ] : Checking Next Contact Date on existing Journey")
        @helper.addLogs("[Expected ] : Next Contact Date on existing Journey should update with duplicate lead submission date")
        @helper.addLogs("[Actual ]   : Next Contact Date on existing Journey is #{insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")}")
        #expect(existingJourneyInfo.fetch("NMD_Next_Contact_Date__c")).to match generatedActivityForLead.fetch("CreatedDate")
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
        @helper.addLogs("[Validate ] : Checking assigned to on activity")
        @helper.addLogs("[Expected ] : Assigned to on activity should be lead owner")
        @helper.addLogs("[Actual ]   : Assigned to on activity is #{generatedActivityForLead.fetch("Owner").fetch("Name")}")
        expect(generatedActivityForLead.fetch("Owner").fetch("Name")).to eql @userInfo.fetch("display_name")
        @helper.addLogs("[Result ]   : Activity assigned to field checked successfully")
        @helper.addLogs("[Validate ] : Checking status on activity")
        @helper.addLogs("[Expected ] : Status on activity should be Open")
        @helper.addLogs("[Actual ]   : Status on activity is #{generatedActivityForLead.fetch("Status")}")
        expect(generatedActivityForLead.fetch("Status")).to eql "Open"
        @helper.addLogs("[Result ]   : Activity assigned to field checked successfully")
        @helper.addLogs("[Validate ] : Checking status on activity")
        @helper.addLogs("[Expected ] : Status on activity should be Open")
        @helper.addLogs("[Actual ]   : Status on activity is #{generatedActivityForLead.fetch("Status")}")
        expect(generatedActivityForLead.fetch("Company__c")).to eql leadInfo.fetch('Company')
        @helper.addLogs("[Result ]   : Activity Status field checked successfully")
        @helper.addLogs("[Validate ] : Checking Location interested on activity")
        @helper.addLogs("[Expected ] : Location interested on activity should be #{leadInfo.fetch('Locations_Interested__c')}")
        @helper.addLogs("[Actual ]   : Location interested on activity is #{generatedActivityForLead.fetch("Status")}")
        expect(generatedActivityForLead.fetch("Locations_Interested__c")).to eql leadInfo.fetch('Locations_Interested__c')
        @helper.addLogs("[Result ]   : Activity Location interested field checked successfully")
        @helper.addLogs("[Validate ] : Checking Location interested on activity")
        @helper.addLogs("[Expected ] : Number of full time employees on activity should be #{leadInfo.fetch('Number_of_Full_Time_Employees__c')}")
        @helper.addLogs("[Actual ]   : Number of full time employees on activity is #{generatedActivityForLead.fetch("Number_of_Full_Time_Employees__c")}")
        expect(generatedActivityForLead.fetch("Number_of_Full_Time_Employees__c")).to eql leadInfo.fetch('Number_of_Full_Time_Employees__c')
        @helper.addLogs("[Result ]   : Activity Number of full time employees field checked successfully")
        @helper.addLogs("[Validate ] : Checking Number of desks on activity")
        @helper.addLogs("[Expected ] : Checking Number of desks on activity should be #{leadInfo.fetch('Number_of_Full_Time_Employees__c')}")
        @helper.addLogs("[Actual ]   : Checking Number of desks on activity is #{generatedActivityForLead.fetch("Number_of_Full_Time_Employees__c")}")
        expect(generatedActivityForLead.fetch("Interested_in_Number_of_Desks__c")).to eql leadInfo.fetch('Interested_in_Number_of_Desks__c')
        @helper.addLogs("[Result ]   : Activity Number of desks field checked successfully")
        @helper.addLogs('Success')
        @helper.postSuccessResult(2575)
      rescue Exception => e
        @helper.addLogs('Error')
        @helper.postFailResult(e, 2575)
        raise e
      end
    end
    it 'To Check Journey is Created While Importing New Lead from Kickbox When the Generate Journey on UI is Unchecked and Generate Journey in CSV is True and assign to the particular Campaign Based on Email Address Scenario.', :'2587' => 'true' do
      begin
        leadInfo = @pageObject.upload_csv("john.snow#{rand(9999999999)}_qaauto@example.com", 'TRUE', @testDataJSON['Campaign'][0]['Name'],false,true,"Lead")[0]
        Helper.addRecordsToDelete("Lead", leadInfo.fetch('Id'))
        @helper.addLogs("[Expected ] : Lead should create with name #{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
        @helper.addLogs("[Actual ]   : Lead is created with name #{leadInfo.fetch("Name")}")
        expect(leadInfo).to_not eql nil
        expect(validate_case("Lead", @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0], leadInfo)).to be true
        @helper.addLogs("[Result ]   : Lead insertion checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Lead owner should be according to Campaign assignment as here Campaign assignment is done on the basis of Email address scenario")
        @helper.addLogs("[Expected ] : Owner of lead should be user/queue assigned to building of provided email address")
        @helper.addLogs("[Actual ]   : Owner of lead is #{leadInfo.fetch("Owner").fetch("Name")}")
        expect(leadInfo.fetch("Owner").fetch("Name")).to eql @pageObject.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
        @helper.addLogs("[Result ]   : Owner checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Lead source")
        @helper.addLogs("[Expected ] : Lead source should be Inbound Call")
        @helper.addLogs("[Actual ]   : Lead is created with lead source #{leadInfo.fetch("LeadSource")}")
        expect(leadInfo.fetch("LeadSource")).to eql "Inbound Call"
        @helper.addLogs("[Result ]   : Lead source checked successfully\n")
        @helper.addLogs("[Validate ] : Checking building interested name on Lead")
        @helper.addLogs("[Expected ] : Building interested name should be #{@testDataJSON['Lead'][0]['Building_Interested_In__c']}")
        @helper.addLogs("[Actual ]   : Lead is created with building interested name #{leadInfo.fetch("Building_Interested_Name__c")}")
        expect(leadInfo.fetch("Building_Interested_Name__c")).to eql @testDataJSON['Lead'][0]["Building_Interested_In__c"]
        @helper.addLogs("[Result ]   : Building interested name on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Generate Journey on Lead")
        @helper.addLogs("[Expected ] : Generate Journey should be TRUE")
        @helper.addLogs("[Actual ]   : Lead is created with Generate Journey =  #{leadInfo.fetch("Generate_Journey__c")}")
        expect(leadInfo.fetch("Generate_Journey__c")).to be true
        @helper.addLogs("[Result ]   : Generate Journey on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Locale on Lead")
        @helper.addLogs("[Expected ] : Locale should be en-US")
        @helper.addLogs("[Actual ]   : Lead is created with Locale =  #{leadInfo.fetch("Locale__c")}")
        expect(leadInfo.fetch("Locale__c")).to eql "en-US"
        @helper.addLogs("[Result ]   : Locale on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Country code on Lead")
        @helper.addLogs("[Expected ] : Country code should be IN")
        @helper.addLogs("[Actual ]   : Lead is created with Country code =  #{leadInfo.fetch("Country_Code__c")}")
        expect(leadInfo.fetch("Country_Code__c")).to eql "IN"
        @helper.addLogs("[Result ]   : Country code on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking building interested")
        @helper.addLogs("[Expected ] : Building interested should be #{@testDataJSON['Lead'][0]["Building_Interested_In__c"]}")
        @helper.addLogs("[Actual ]   : Lead is created with building interested #{leadInfo.fetch("Building_Interested_In__c")}")
        expect(leadInfo.fetch("Building_Interested_In__c")).to eql @building
        @helper.addLogs("[Result ]   : Building interested on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Journey created date on lead")
        @helper.addLogs("[Expected ] : Journey created date should be #{leadInfo.fetch("CreatedDate")}")
        @helper.addLogs("[Actual ]   : Lead is created with Journey created date #{leadInfo.fetch("Journey_Created_On__c")}")
        #expect(insertedLeadInfo.fetch("Journey_Created_On__c")).to eql insertedJourneyInfo[0].fetch("CreatedDate")
        @helper.addLogs("[Result ]   : Journey created date on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Locations Interested on lead")
        @helper.addLogs("[Expected ] : Locations Interested should be #{@testDataJSON['Lead'][0]["Building_Interested_In__c"]}")
        @helper.addLogs("[Actual ]   : Lead is created with Locations Interested #{leadInfo.fetch("Locations_Interested__c")}")
        expect(leadInfo.fetch("Locations_Interested__c")).to eql @testDataJSON['Lead'][0]["Building_Interested_In__c"]
        @helper.addLogs("[Result ]   : Locations Interested on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Email on lead")
        @helper.addLogs("[Expected ] : Email should be #{@testDataJSON['Lead'][0]['Email']}")
        @helper.addLogs("[Actual ]   : Lead is created with Email #{leadInfo.fetch("Email")}")
        expect(leadInfo.fetch("Email")).to eql @testDataJSON['Lead'][0]['Email']
        @helper.addLogs("[Result ]   : Email on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Phone on lead")
        @helper.addLogs("[Expected ] : Number of Phone should be #{@testDataJSON['Lead'][0]['Phone']}")
        @helper.addLogs("[Actual ]   : Lead is created with Phone #{leadInfo.fetch("Phone")}")
        expect(leadInfo.fetch("Phone")).to eql @testDataJSON['Lead'][0]['Phone']
        @helper.addLogs("[Result ]   : Phone on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Company on lead")
        @helper.addLogs("[Expected ] : Company should be #{@testDataJSON['Lead'][0]['Company']}")
        @helper.addLogs("[Actual ]   : Lead is created with Company #{leadInfo.fetch("Company")}")
        expect(leadInfo.fetch("Company")).to eql @testDataJSON['Lead'][0]['Company']
        @helper.addLogs("[Result ]   : Company on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Status on lead")
        @helper.addLogs("[Expected ] : Status should be Open")
        @helper.addLogs("[Actual ]   : Lead is created with Status #{leadInfo.fetch("Status")}")
        expect(leadInfo.fetch("Status")).to eql "Open"
        @helper.addLogs("[Result ]   : Status on Lead checked successfully\n")
        insertedJourneyInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,Owner.Name, CreatedDate ,Status__c , NMD_Next_Contact_Date__c ,Primary_Email__c , Lead_Source__c , Lead_Source_Detail__c , Primary_Phone__c , Company_Name__c , Building_Interested_In__c , Locations_Interested__c , Interested_in_Number_of_Desks__c , Full_Time_Employees__c, Name   FROM Journey__c WHERE Primary_Email__c = '#{leadInfo.fetch("Email")}'")[0]
        @helper.addLogs("[Validate ] : Checking Journey is created on lead")
        @helper.addLogs("[Expected ] : Journey should create with name #{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
        @helper.addLogs("[Actual ]   : Journey is created with name #{insertedJourneyInfo.fetch("Name")}")
        expect(insertedJourneyInfo).to_not eql nil
        Helper.addRecordsToDelete("Journey__c", insertedJourneyInfo.fetch('Id'))
        @helper.addLogs("[Result ]   : Journey created successfully\n")
        @helper.addLogs("[Validate ] : Checking Journey owner should be logged in user")
        @helper.addLogs("[Expected ] : Owner of Journey should be owner of lead")
        @helper.addLogs("[Actual ]   : Owner of Journey is #{insertedJourneyInfo.fetch("Owner").fetch("Name")}")
        expect(insertedJourneyInfo.fetch("Owner").fetch("Name")).to eql @userInfo.fetch("display_name")
        @helper.addLogs("[Result ]   : Owner checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Lead source on Journey")
        @helper.addLogs("[Expected ] : Lead source should be Inbound Call")
        @helper.addLogs("[Actual ]   : Journey is created with lead source #{insertedJourneyInfo.fetch("Lead_Source__c")}")
        expect(insertedJourneyInfo.fetch("Lead_Source__c")).to eql "Inbound Call"
        @helper.addLogs("[Result ]   : Lead source checked successfully\n")
        @helper.addLogs("[Validate ] : Checking building interested name on Journey")
        @helper.addLogs("[Expected ] : Building interested should be #{@testDataJSON['Lead'][0]['Building_Interested_In__c']}")
        @helper.addLogs("[Actual ]   : Journey is created with building interested name #{insertedJourneyInfo.fetch("Building_Interested_In__c")}")
        expect(insertedJourneyInfo.fetch("Building_Interested_In__c")).to eql @building
        @helper.addLogs("[Result ]   : Building interested on Journey checked successfully\n")
        @helper.addLogs("[Validate ] : Checking NMD Next Contact Date on Journey")
        @helper.addLogs("[Expected ] : NMD Next Contact Date should be journey creation date")
        @helper.addLogs("[Actual ]   : Journey is created with NMD Next Contact Date #{insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")}")
        #expect(insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")).to eql insertedJourneyInfo[0].fetch("CreatedDate")
        @helper.addLogs("[Result ]   : NMD Next Contact Date on Journey checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Locations Interested on Journey")
        @helper.addLogs("[Expected ] : Locations Interested should be #{@testDataJSON['Lead'][0]['Building_Interested_In__c']}")
        @helper.addLogs("[Actual ]   : Journey is created with Locations Interested #{insertedJourneyInfo.fetch("Locations_Interested__c")}")
        expect(insertedJourneyInfo.fetch('Locations_Interested__c')).to eql @testDataJSON['Lead'][0]["Building_Interested_In__c"]
        @helper.addLogs("[Result ]   : Locations Interested on Journey checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Email on Journey")
        @helper.addLogs("[Expected ] : Email should be #{@testDataJSON['Lead'][0]['Email']}")
        @helper.addLogs("[Actual ]   : Journey is created with Email #{insertedJourneyInfo.fetch("Primary_Email__c")}")
        expect(insertedJourneyInfo.fetch("Primary_Email__c")).to eql @testDataJSON['Lead'][0]['Email']
        @helper.addLogs("[Result ]   : Email on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Phone on Journey")
        @helper.addLogs("[Expected ] : Number of Phone should be #{@testDataJSON['Lead'][0]['Phone']}")
        @helper.addLogs("[Actual ]   : Journey is created with Phone #{insertedJourneyInfo.fetch("Primary_Phone__c")}")
        expect(insertedJourneyInfo.fetch("Primary_Phone__c")).to eql @testDataJSON['Lead'][0]['Phone']
        @helper.addLogs("[Result ]   : Phone on Journey checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Company on Journey")
        @helper.addLogs("[Expected ] : Company should be #{@testDataJSON['Lead'][0]['Company']}")
        @helper.addLogs("[Actual ]   : Journey is created with Company #{insertedJourneyInfo.fetch("Company_Name__c")}")
        expect(insertedJourneyInfo.fetch("Company_Name__c")).to eql @testDataJSON['Lead'][0]['Company']
        @helper.addLogs("[Result ]   : Company on Journey checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Status on Journey")
        @helper.addLogs("[Expected ] : Status should be Started")
        @helper.addLogs("[Actual ]   : Journey is created with Status #{insertedJourneyInfo.fetch("Status__c")}")
        expect(insertedJourneyInfo.fetch("Status__c")).to eql "Started"
        @helper.addLogs("[Result ]   : Status on Journey checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Campaign on Journey")
        @helper.addLogs("[Expected ] : Campaign should be #{@campaignId}")
        @helper.addLogs("[Actual ]   : Journey is created with Campaign #{insertedJourneyInfo.fetch("CampaignId__c")} on it")
        expect(insertedJourneyInfo.fetch("CampaignId__c")).to eql @campaignId
        @helper.addLogs("[Result ]   : Status on Journey checked successfully\n")
        generatedActivityForLead = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Subject , CreatedDate,Status ,Lead_Source__c , Lead_Source_Detail__c,Owner.Name,Locations_Interested__c, Number_of_Full_Time_Employees__c,Interested_in_Number_of_Desks__c,Company__c,WhoId FROM Task WHERE WhoId = '#{leadInfo.fetch('Id')}'")[0]
        @helper.addLogs("[Validate ] : Checking Next Contact Date on existing Journey")
        @helper.addLogs("[Expected ] : Next Contact Date on existing Journey should update with duplicate lead submission date")
        @helper.addLogs("[Actual ]   : Next Contact Date on existing Journey is #{insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")}")
        #expect(existingJourneyInfo.fetch("NMD_Next_Contact_Date__c")).to match generatedActivityForLead.fetch("CreatedDate")
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
        @helper.addLogs("[Validate ] : Checking assigned to on activity")
        @helper.addLogs("[Expected ] : Assigned to on activity should be lead owner")
        @helper.addLogs("[Actual ]   : Assigned to on activity is #{generatedActivityForLead.fetch("Owner").fetch("Name")}")
        expect(generatedActivityForLead.fetch("Owner").fetch("Name")).to eql @userInfo.fetch("display_name")
        @helper.addLogs("[Result ]   : Activity assigned to field checked successfully")
        @helper.addLogs("[Validate ] : Checking status on activity")
        @helper.addLogs("[Expected ] : Status on activity should be Open")
        @helper.addLogs("[Actual ]   : Status on activity is #{generatedActivityForLead.fetch("Status")}")
        expect(generatedActivityForLead.fetch("Status")).to eql "Open"
        @helper.addLogs("[Result ]   : Activity assigned to field checked successfully")
        @helper.addLogs("[Validate ] : Checking status on activity")
        @helper.addLogs("[Expected ] : Status on activity should be Open")
        @helper.addLogs("[Actual ]   : Status on activity is #{generatedActivityForLead.fetch("Status")}")
        expect(generatedActivityForLead.fetch("Company__c")).to eql leadInfo.fetch('Company')
        @helper.addLogs("[Result ]   : Activity Status field checked successfully")
        @helper.addLogs("[Validate ] : Checking Location interested on activity")
        @helper.addLogs("[Expected ] : Location interested on activity should be #{leadInfo.fetch('Locations_Interested__c')}")
        @helper.addLogs("[Actual ]   : Location interested on activity is #{generatedActivityForLead.fetch("Status")}")
        expect(generatedActivityForLead.fetch("Locations_Interested__c")).to eql leadInfo.fetch('Locations_Interested__c')
        @helper.addLogs("[Result ]   : Activity Location interested field checked successfully")
        @helper.addLogs("[Validate ] : Checking Location interested on activity")
        @helper.addLogs("[Expected ] : Number of full time employees on activity should be #{leadInfo.fetch('Number_of_Full_Time_Employees__c')}")
        @helper.addLogs("[Actual ]   : Number of full time employees on activity is #{generatedActivityForLead.fetch("Number_of_Full_Time_Employees__c")}")
        expect(generatedActivityForLead.fetch("Number_of_Full_Time_Employees__c")).to eql leadInfo.fetch('Number_of_Full_Time_Employees__c')
        @helper.addLogs("[Result ]   : Activity Number of full time employees field checked successfully")
        @helper.addLogs("[Validate ] : Checking Number of desks on activity")
        @helper.addLogs("[Expected ] : Checking Number of desks on activity should be #{leadInfo.fetch('Number_of_Full_Time_Employees__c')}")
        @helper.addLogs("[Actual ]   : Checking Number of desks on activity is #{generatedActivityForLead.fetch("Number_of_Full_Time_Employees__c")}")
        expect(generatedActivityForLead.fetch("Interested_in_Number_of_Desks__c")).to eql leadInfo.fetch('Interested_in_Number_of_Desks__c')
        @helper.addLogs("[Result ]   : Activity Number of desks field checked successfully")
        @helper.addLogs('Success')
        @helper.postSuccessResult(2578)
      rescue Exception => e
        @helper.addLogs('Error')
        @helper.postFailResult(e, 2578)
        raise e
      end
    end
    it 'To Check Journey is Created While Importing New Lead From Kickbox When the Generate Journey on UI is Checked and Generate Journey in CSV is False and assign to the particular Campaign based on the Email Address Scenario.', :'2595' => 'true' do
      begin
        leadInfo = @pageObject.upload_csv("john.snow#{rand(9999999999)}_qaauto@example.com", 'TRUE', @testDataJSON['Campaign'][0]['Name'],false,true,"Lead")[0]
        Helper.addRecordsToDelete("Lead", leadInfo.fetch('Id'))
        @helper.addLogs("[Expected ] : Lead should create with name #{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
        @helper.addLogs("[Actual ]   : Lead is created with name #{leadInfo.fetch("Name")}")
        expect(leadInfo).to_not eql nil
        expect(validate_case("Lead", @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0], leadInfo)).to be true
        @helper.addLogs("[Result ]   : Lead insertion checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Lead owner should be according to Campaign assignment as here Campaign assignment is done on the basis of Email address scenario")
        @helper.addLogs("[Expected ] : Owner of lead should be user/queue assigned to building of provided email address")
        @helper.addLogs("[Actual ]   : Owner of lead is #{leadInfo.fetch("Owner").fetch("Name")}")
        expect(leadInfo.fetch("Owner").fetch("Name")).to eql @pageObject.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
        @helper.addLogs("[Result ]   : Owner checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Lead source")
        @helper.addLogs("[Expected ] : Lead source should be Inbound Call")
        @helper.addLogs("[Actual ]   : Lead is created with lead source #{leadInfo.fetch("LeadSource")}")
        expect(leadInfo.fetch("LeadSource")).to eql "Inbound Call"
        @helper.addLogs("[Result ]   : Lead source checked successfully\n")
        @helper.addLogs("[Validate ] : Checking building interested name on Lead")
        @helper.addLogs("[Expected ] : Building interested name should be #{@testDataJSON['Lead'][0]['Building_Interested_In__c']}")
        @helper.addLogs("[Actual ]   : Lead is created with building interested name #{leadInfo.fetch("Building_Interested_Name__c")}")
        expect(leadInfo.fetch("Building_Interested_Name__c")).to eql @testDataJSON['Lead'][0]["Building_Interested_In__c"]
        @helper.addLogs("[Result ]   : Building interested name on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Generate Journey on Lead")
        @helper.addLogs("[Expected ] : Generate Journey should be TRUE")
        @helper.addLogs("[Actual ]   : Lead is created with Generate Journey =  #{leadInfo.fetch("Generate_Journey__c")}")
        expect(leadInfo.fetch("Generate_Journey__c")).to be true
        @helper.addLogs("[Result ]   : Generate Journey on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Locale on Lead")
        @helper.addLogs("[Expected ] : Locale should be en-US")
        @helper.addLogs("[Actual ]   : Lead is created with Locale =  #{leadInfo.fetch("Locale__c")}")
        expect(leadInfo.fetch("Locale__c")).to eql "en-US"
        @helper.addLogs("[Result ]   : Locale on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Country code on Lead")
        @helper.addLogs("[Expected ] : Country code should be IN")
        @helper.addLogs("[Actual ]   : Lead is created with Country code =  #{leadInfo.fetch("Country_Code__c")}")
        expect(leadInfo.fetch("Country_Code__c")).to eql "IN"
        @helper.addLogs("[Result ]   : Country code on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking building interested")
        @helper.addLogs("[Expected ] : Building interested should be #{@testDataJSON['Lead'][0]["Building_Interested_In__c"]}")
        @helper.addLogs("[Actual ]   : Lead is created with building interested #{leadInfo.fetch("Building_Interested_In__c")}")
        expect(leadInfo.fetch("Building_Interested_In__c")).to eql @building
        @helper.addLogs("[Result ]   : Building interested on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Journey created date on lead")
        @helper.addLogs("[Expected ] : Journey created date should be #{leadInfo.fetch("CreatedDate")}")
        @helper.addLogs("[Actual ]   : Lead is created with Journey created date #{leadInfo.fetch("Journey_Created_On__c")}")
        #expect(insertedLeadInfo.fetch("Journey_Created_On__c")).to eql insertedJourneyInfo[0].fetch("CreatedDate")
        @helper.addLogs("[Result ]   : Journey created date on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Locations Interested on lead")
        @helper.addLogs("[Expected ] : Locations Interested should be #{@testDataJSON['Lead'][0]["Building_Interested_In__c"]}")
        @helper.addLogs("[Actual ]   : Lead is created with Locations Interested #{leadInfo.fetch("Locations_Interested__c")}")
        expect(leadInfo.fetch("Locations_Interested__c")).to eql @testDataJSON['Lead'][0]["Building_Interested_In__c"]
        @helper.addLogs("[Result ]   : Locations Interested on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Email on lead")
        @helper.addLogs("[Expected ] : Email should be #{@testDataJSON['Lead'][0]['Email']}")
        @helper.addLogs("[Actual ]   : Lead is created with Email #{leadInfo.fetch("Email")}")
        expect(leadInfo.fetch("Email")).to eql @testDataJSON['Lead'][0]['Email']
        @helper.addLogs("[Result ]   : Email on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Phone on lead")
        @helper.addLogs("[Expected ] : Number of Phone should be #{@testDataJSON['Lead'][0]['Phone']}")
        @helper.addLogs("[Actual ]   : Lead is created with Phone #{leadInfo.fetch("Phone")}")
        expect(leadInfo.fetch("Phone")).to eql @testDataJSON['Lead'][0]['Phone']
        @helper.addLogs("[Result ]   : Phone on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Company on lead")
        @helper.addLogs("[Expected ] : Company should be #{@testDataJSON['Lead'][0]['Company']}")
        @helper.addLogs("[Actual ]   : Lead is created with Company #{leadInfo.fetch("Company")}")
        expect(leadInfo.fetch("Company")).to eql @testDataJSON['Lead'][0]['Company']
        @helper.addLogs("[Result ]   : Company on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Status on lead")
        @helper.addLogs("[Expected ] : Status should be Open")
        @helper.addLogs("[Actual ]   : Lead is created with Status #{leadInfo.fetch("Status")}")
        expect(leadInfo.fetch("Status")).to eql "Open"
        @helper.addLogs("[Result ]   : Status on Lead checked successfully\n")
        insertedJourneyInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,Owner.Name, CreatedDate ,Status__c , NMD_Next_Contact_Date__c ,Primary_Email__c , Lead_Source__c , Lead_Source_Detail__c , Primary_Phone__c , Company_Name__c , Building_Interested_In__c , Locations_Interested__c , Interested_in_Number_of_Desks__c , Full_Time_Employees__c, Name   FROM Journey__c WHERE Primary_Email__c = '#{leadInfo.fetch("Email")}'")[0]
        @helper.addLogs("[Validate ] : Checking Journey is created on lead")
        @helper.addLogs("[Expected ] : Journey should create with name #{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
        @helper.addLogs("[Actual ]   : Journey is created with name #{insertedJourneyInfo.fetch("Name")}")
        expect(insertedJourneyInfo).to_not eql nil
        Helper.addRecordsToDelete("Journey__c", insertedJourneyInfo.fetch('Id'))
        @helper.addLogs("[Result ]   : Journey created successfully\n")
        @helper.addLogs("[Validate ] : Checking Journey owner should be logged in user")
        @helper.addLogs("[Expected ] : Owner of Journey should be owner of lead")
        @helper.addLogs("[Actual ]   : Owner of Journey is #{insertedJourneyInfo.fetch("Owner").fetch("Name")}")
        expect(insertedJourneyInfo.fetch("Owner").fetch("Name")).to eql @userInfo.fetch("display_name")
        @helper.addLogs("[Result ]   : Owner checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Lead source on Journey")
        @helper.addLogs("[Expected ] : Lead source should be Inbound Call")
        @helper.addLogs("[Actual ]   : Journey is created with lead source #{insertedJourneyInfo.fetch("Lead_Source__c")}")
        expect(insertedJourneyInfo.fetch("Lead_Source__c")).to eql "Inbound Call"
        @helper.addLogs("[Result ]   : Lead source checked successfully\n")
        @helper.addLogs("[Validate ] : Checking building interested name on Journey")
        @helper.addLogs("[Expected ] : Building interested should be #{@testDataJSON['Lead'][0]['Building_Interested_In__c']}")
        @helper.addLogs("[Actual ]   : Journey is created with building interested name #{insertedJourneyInfo.fetch("Building_Interested_In__c")}")
        expect(insertedJourneyInfo.fetch("Building_Interested_In__c")).to eql @building
        @helper.addLogs("[Result ]   : Building interested on Journey checked successfully\n")
        @helper.addLogs("[Validate ] : Checking NMD Next Contact Date on Journey")
        @helper.addLogs("[Expected ] : NMD Next Contact Date should be journey creation date")
        @helper.addLogs("[Actual ]   : Journey is created with NMD Next Contact Date #{insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")}")
        #expect(insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")).to eql insertedJourneyInfo[0].fetch("CreatedDate")
        @helper.addLogs("[Result ]   : NMD Next Contact Date on Journey checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Locations Interested on Journey")
        @helper.addLogs("[Expected ] : Locations Interested should be #{@testDataJSON['Lead'][0]['Building_Interested_In__c']}")
        @helper.addLogs("[Actual ]   : Journey is created with Locations Interested #{insertedJourneyInfo.fetch("Locations_Interested__c")}")
        expect(insertedJourneyInfo.fetch('Locations_Interested__c')).to eql @testDataJSON['Lead'][0]["Building_Interested_In__c"]
        @helper.addLogs("[Result ]   : Locations Interested on Journey checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Email on Journey")
        @helper.addLogs("[Expected ] : Email should be #{@testDataJSON['Lead'][0]['Email']}")
        @helper.addLogs("[Actual ]   : Journey is created with Email #{insertedJourneyInfo.fetch("Primary_Email__c")}")
        expect(insertedJourneyInfo.fetch("Primary_Email__c")).to eql @testDataJSON['Lead'][0]['Email']
        @helper.addLogs("[Result ]   : Email on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Phone on Journey")
        @helper.addLogs("[Expected ] : Number of Phone should be #{@testDataJSON['Lead'][0]['Phone']}")
        @helper.addLogs("[Actual ]   : Journey is created with Phone #{insertedJourneyInfo.fetch("Primary_Phone__c")}")
        expect(insertedJourneyInfo.fetch("Primary_Phone__c")).to eql @testDataJSON['Lead'][0]['Phone']
        @helper.addLogs("[Result ]   : Phone on Journey checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Company on Journey")
        @helper.addLogs("[Expected ] : Company should be #{@testDataJSON['Lead'][0]['Company']}")
        @helper.addLogs("[Actual ]   : Journey is created with Company #{insertedJourneyInfo.fetch("Company_Name__c")}")
        expect(insertedJourneyInfo.fetch("Company_Name__c")).to eql @testDataJSON['Lead'][0]['Company']
        @helper.addLogs("[Result ]   : Company on Journey checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Status on Journey")
        @helper.addLogs("[Expected ] : Status should be Started")
        @helper.addLogs("[Actual ]   : Journey is created with Status #{insertedJourneyInfo.fetch("Status__c")}")
        expect(insertedJourneyInfo.fetch("Status__c")).to eql "Started"
        @helper.addLogs("[Result ]   : Status on Journey checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Campaign on Journey")
        @helper.addLogs("[Expected ] : Campaign should be #{@campaignId}")
        @helper.addLogs("[Actual ]   : Journey is created with Campaign #{insertedJourneyInfo.fetch("CampaignId__c")} on it")
        expect(insertedJourneyInfo.fetch("CampaignId__c")).to eql @campaignId
        @helper.addLogs("[Result ]   : Status on Journey checked successfully\n")
        generatedActivityForLead = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Subject , CreatedDate,Status ,Lead_Source__c , Lead_Source_Detail__c,Owner.Name,Locations_Interested__c, Number_of_Full_Time_Employees__c,Interested_in_Number_of_Desks__c,Company__c,WhoId FROM Task WHERE WhoId = '#{leadInfo.fetch('Id')}'")[0]
        @helper.addLogs("[Validate ] : Checking Next Contact Date on existing Journey")
        @helper.addLogs("[Expected ] : Next Contact Date on existing Journey should update with duplicate lead submission date")
        @helper.addLogs("[Actual ]   : Next Contact Date on existing Journey is #{insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")}")
        #expect(existingJourneyInfo.fetch("NMD_Next_Contact_Date__c")).to match generatedActivityForLead.fetch("CreatedDate")
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
        @helper.addLogs("[Validate ] : Checking assigned to on activity")
        @helper.addLogs("[Expected ] : Assigned to on activity should be lead owner")
        @helper.addLogs("[Actual ]   : Assigned to on activity is #{generatedActivityForLead.fetch("Owner").fetch("Name")}")
        expect(generatedActivityForLead.fetch("Owner").fetch("Name")).to eql @userInfo.fetch("display_name")
        @helper.addLogs("[Result ]   : Activity assigned to field checked successfully")
        @helper.addLogs("[Validate ] : Checking status on activity")
        @helper.addLogs("[Expected ] : Status on activity should be Open")
        @helper.addLogs("[Actual ]   : Status on activity is #{generatedActivityForLead.fetch("Status")}")
        expect(generatedActivityForLead.fetch("Status")).to eql "Open"
        @helper.addLogs("[Result ]   : Activity assigned to field checked successfully")
        @helper.addLogs("[Validate ] : Checking status on activity")
        @helper.addLogs("[Expected ] : Status on activity should be Open")
        @helper.addLogs("[Actual ]   : Status on activity is #{generatedActivityForLead.fetch("Status")}")
        expect(generatedActivityForLead.fetch("Company__c")).to eql leadInfo.fetch('Company')
        @helper.addLogs("[Result ]   : Activity Status field checked successfully")
        @helper.addLogs("[Validate ] : Checking Location interested on activity")
        @helper.addLogs("[Expected ] : Location interested on activity should be #{leadInfo.fetch('Locations_Interested__c')}")
        @helper.addLogs("[Actual ]   : Location interested on activity is #{generatedActivityForLead.fetch("Status")}")
        expect(generatedActivityForLead.fetch("Locations_Interested__c")).to eql leadInfo.fetch('Locations_Interested__c')
        @helper.addLogs("[Result ]   : Activity Location interested field checked successfully")
        @helper.addLogs("[Validate ] : Checking Location interested on activity")
        @helper.addLogs("[Expected ] : Number of full time employees on activity should be #{leadInfo.fetch('Number_of_Full_Time_Employees__c')}")
        @helper.addLogs("[Actual ]   : Number of full time employees on activity is #{generatedActivityForLead.fetch("Number_of_Full_Time_Employees__c")}")
        expect(generatedActivityForLead.fetch("Number_of_Full_Time_Employees__c")).to eql leadInfo.fetch('Number_of_Full_Time_Employees__c')
        @helper.addLogs("[Result ]   : Activity Number of full time employees field checked successfully")
        @helper.addLogs("[Validate ] : Checking Number of desks on activity")
        @helper.addLogs("[Expected ] : Checking Number of desks on activity should be #{leadInfo.fetch('Number_of_Full_Time_Employees__c')}")
        @helper.addLogs("[Actual ]   : Checking Number of desks on activity is #{generatedActivityForLead.fetch("Number_of_Full_Time_Employees__c")}")
        expect(generatedActivityForLead.fetch("Interested_in_Number_of_Desks__c")).to eql leadInfo.fetch('Interested_in_Number_of_Desks__c')
        @helper.addLogs("[Result ]   : Activity Number of desks field checked successfully")
        @helper.addLogs('Success')
        @helper.postSuccessResult(2578)
      rescue Exception => e
        @helper.addLogs('Error')
        @helper.postFailResult(e, 2578)
        raise e
      end
    end
    it 'To Check Journey is Not being Created While Importing New Lead from Kickbox when the Generate Journey on UI is Unchecked and Generate Journey in CSV is Blank and assign to the particular Campaign Based on Email Address Scenario.', :'2590' => 'true' do
      begin
        leadInfo = @pageObject.upload_csv("john.snow#{rand(9999999999)}_qaauto@example.com", 'FALSE', @testDataJSON['Campaign'][0]['Name'],false,true,"Lead")[0]
        Helper.addRecordsToDelete("Lead", leadInfo.fetch('Id'))
        @helper.addLogs("[Expected ] : Lead should create with name #{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
        @helper.addLogs("[Actual ]   : Lead is created with name #{leadInfo.fetch("Name")}")
        expect(leadInfo).to_not eql nil
        expect(validate_case("Lead", @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0], leadInfo)).to be true
        @helper.addLogs("[Result ]   : Lead insertion checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Lead owner should be according to Campaign assignment as here Campaign assignment is done on the basis of Email address scenario")
        @helper.addLogs("[Expected ] : Owner of lead should be user/queue assigned to building of provided email address")
        @helper.addLogs("[Actual ]   : Owner of lead is #{leadInfo.fetch("Owner").fetch("Name")}")
        expect(leadInfo.fetch("Owner").fetch("Name")).to eql @pageObject.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
        @helper.addLogs("[Result ]   : Owner checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Lead source")
        @helper.addLogs("[Expected ] : Lead source should be Inbound Call")
        @helper.addLogs("[Actual ]   : Lead is created with lead source #{leadInfo.fetch("LeadSource")}")
        expect(leadInfo.fetch("LeadSource")).to eql "Inbound Call"
        @helper.addLogs("[Result ]   : Lead source checked successfully\n")
        @helper.addLogs("[Validate ] : Checking building interested name on Lead")
        @helper.addLogs("[Expected ] : Building interested name should be #{@testDataJSON['Lead'][0]['Building_Interested_In__c']}")
        @helper.addLogs("[Actual ]   : Lead is created with building interested name #{leadInfo.fetch("Building_Interested_Name__c")}")
        expect(leadInfo.fetch("Building_Interested_Name__c")).to eql @testDataJSON['Lead'][0]["Building_Interested_In__c"]
        @helper.addLogs("[Result ]   : Building interested name on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Generate Journey on Lead")
        @helper.addLogs("[Expected ] : Generate Journey should be TRUE")
        @helper.addLogs("[Actual ]   : Lead is created with Generate Journey =  #{leadInfo.fetch("Generate_Journey__c")}")
        expect(leadInfo.fetch("Generate_Journey__c")).to be true
        @helper.addLogs("[Result ]   : Generate Journey on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Locale on Lead")
        @helper.addLogs("[Expected ] : Locale should be en-US")
        @helper.addLogs("[Actual ]   : Lead is created with Locale =  #{leadInfo.fetch("Locale__c")}")
        expect(leadInfo.fetch("Locale__c")).to eql "en-US"
        @helper.addLogs("[Result ]   : Locale on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Country code on Lead")
        @helper.addLogs("[Expected ] : Country code should be IN")
        @helper.addLogs("[Actual ]   : Lead is created with Country code =  #{leadInfo.fetch("Country_Code__c")}")
        expect(leadInfo.fetch("Country_Code__c")).to eql "IN"
        @helper.addLogs("[Result ]   : Country code on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking building interested")
        @helper.addLogs("[Expected ] : Building interested should be #{@testDataJSON['Lead'][0]["Building_Interested_In__c"]}")
        @helper.addLogs("[Actual ]   : Lead is created with building interested #{leadInfo.fetch("Building_Interested_In__c")}")
        expect(leadInfo.fetch("Building_Interested_In__c")).to eql @building
        @helper.addLogs("[Result ]   : Building interested on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Journey created date on lead")
        @helper.addLogs("[Expected ] : Journey created date should be #{leadInfo.fetch("CreatedDate")}")
        @helper.addLogs("[Actual ]   : Lead is created with Journey created date #{leadInfo.fetch("Journey_Created_On__c")}")
        #expect(insertedLeadInfo.fetch("Journey_Created_On__c")).to eql insertedJourneyInfo[0].fetch("CreatedDate")
        @helper.addLogs("[Result ]   : Journey created date on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Locations Interested on lead")
        @helper.addLogs("[Expected ] : Locations Interested should be #{@testDataJSON['Lead'][0]["Building_Interested_In__c"]}")
        @helper.addLogs("[Actual ]   : Lead is created with Locations Interested #{leadInfo.fetch("Locations_Interested__c")}")
        expect(leadInfo.fetch("Locations_Interested__c")).to eql @testDataJSON['Lead'][0]["Building_Interested_In__c"]
        @helper.addLogs("[Result ]   : Locations Interested on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Email on lead")
        @helper.addLogs("[Expected ] : Email should be #{@testDataJSON['Lead'][0]['Email']}")
        @helper.addLogs("[Actual ]   : Lead is created with Email #{leadInfo.fetch("Email")}")
        expect(leadInfo.fetch("Email")).to eql @testDataJSON['Lead'][0]['Email']
        @helper.addLogs("[Result ]   : Email on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Phone on lead")
        @helper.addLogs("[Expected ] : Number of Phone should be #{@testDataJSON['Lead'][0]['Phone']}")
        @helper.addLogs("[Actual ]   : Lead is created with Phone #{leadInfo.fetch("Phone")}")
        expect(leadInfo.fetch("Phone")).to eql @testDataJSON['Lead'][0]['Phone']
        @helper.addLogs("[Result ]   : Phone on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Company on lead")
        @helper.addLogs("[Expected ] : Company should be #{@testDataJSON['Lead'][0]['Company']}")
        @helper.addLogs("[Actual ]   : Lead is created with Company #{leadInfo.fetch("Company")}")
        expect(leadInfo.fetch("Company")).to eql @testDataJSON['Lead'][0]['Company']
        @helper.addLogs("[Result ]   : Company on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Status on lead")
        @helper.addLogs("[Expected ] : Status should be Open")
        @helper.addLogs("[Actual ]   : Lead is created with Status #{leadInfo.fetch("Status")}")
        expect(leadInfo.fetch("Status")).to eql "Open"
        @helper.addLogs("[Result ]   : Status on Lead checked successfully\n")
        insertedJourneyInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id FROM Journey__c WHERE Primary_Email__c = '#{leadInfo.fetch("Email")}'")[0]
        @helper.addLogs("[Validate ] : Checking Journey is created on lead")
        @helper.addLogs("[Expected ] : Journey should not be created")
        @helper.addLogs("[Result ]   : Journey is created #{insertedJourneyInfo.nil? ? 'NO' : 'Yes'}")
        expect(insertedJourneyInfo).to eql nil
        @helper.addLogs("[Result ] : Journey creation checked successfully")
        @helper.addLogs("[Actual ]   : Next Contact Date on existing Journey is #{insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")}")
        generatedActivityForLead = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Subject , CreatedDate,Status ,Lead_Source__c , Lead_Source_Detail__c,Owner.Name,Locations_Interested__c, Number_of_Full_Time_Employees__c,Interested_in_Number_of_Desks__c,Company__c,WhoId FROM Task WHERE WhoId = '#{leadInfo.fetch('Id')}'")[0]
        @helper.addLogs("[Validate ] : Checking Next Contact Date on existing Journey")
        @helper.addLogs("[Expected ] : Next Contact Date on existing Journey should update with duplicate lead submission date")
        @helper.addLogs("[Actual ]   : Next Contact Date on existing Journey is #{insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")}")
        #expect(existingJourneyInfo.fetch("NMD_Next_Contact_Date__c")).to match generatedActivityForLead.fetch("CreatedDate")
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
        @helper.addLogs("[Validate ] : Checking assigned to on activity")
        @helper.addLogs("[Expected ] : Assigned to on activity should be lead owner")
        @helper.addLogs("[Actual ]   : Assigned to on activity is #{generatedActivityForLead.fetch("Owner").fetch("Name")}")
        expect(generatedActivityForLead.fetch("Owner").fetch("Name")).to eql @userInfo.fetch("display_name")
        @helper.addLogs("[Result ]   : Activity assigned to field checked successfully")
        @helper.addLogs("[Validate ] : Checking status on activity")
        @helper.addLogs("[Expected ] : Status on activity should be Open")
        @helper.addLogs("[Actual ]   : Status on activity is #{generatedActivityForLead.fetch("Status")}")
        expect(generatedActivityForLead.fetch("Status")).to eql "Open"
        @helper.addLogs("[Result ]   : Activity assigned to field checked successfully")
        @helper.addLogs("[Validate ] : Checking status on activity")
        @helper.addLogs("[Expected ] : Status on activity should be Open")
        @helper.addLogs("[Actual ]   : Status on activity is #{generatedActivityForLead.fetch("Status")}")
        expect(generatedActivityForLead.fetch("Company__c")).to eql leadInfo.fetch('Company')
        @helper.addLogs("[Result ]   : Activity Status field checked successfully")
        @helper.addLogs("[Validate ] : Checking Location interested on activity")
        @helper.addLogs("[Expected ] : Location interested on activity should be #{leadInfo.fetch('Locations_Interested__c')}")
        @helper.addLogs("[Actual ]   : Location interested on activity is #{generatedActivityForLead.fetch("Status")}")
        expect(generatedActivityForLead.fetch("Locations_Interested__c")).to eql leadInfo.fetch('Locations_Interested__c')
        @helper.addLogs("[Result ]   : Activity Location interested field checked successfully")
        @helper.addLogs("[Validate ] : Checking Location interested on activity")
        @helper.addLogs("[Expected ] : Number of full time employees on activity should be #{leadInfo.fetch('Number_of_Full_Time_Employees__c')}")
        @helper.addLogs("[Actual ]   : Number of full time employees on activity is #{generatedActivityForLead.fetch("Number_of_Full_Time_Employees__c")}")
        expect(generatedActivityForLead.fetch("Number_of_Full_Time_Employees__c")).to eql leadInfo.fetch('Number_of_Full_Time_Employees__c')
        @helper.addLogs("[Result ]   : Activity Number of full time employees field checked successfully")
        @helper.addLogs("[Validate ] : Checking Number of desks on activity")
        @helper.addLogs("[Expected ] : Checking Number of desks on activity should be #{leadInfo.fetch('Number_of_Full_Time_Employees__c')}")
        @helper.addLogs("[Actual ]   : Checking Number of desks on activity is #{generatedActivityForLead.fetch("Number_of_Full_Time_Employees__c")}")
        expect(generatedActivityForLead.fetch("Interested_in_Number_of_Desks__c")).to eql leadInfo.fetch('Interested_in_Number_of_Desks__c')
        @helper.addLogs("[Result ]   : Activity Number of desks field checked successfully")
        @helper.addLogs('Success')
        @helper.postSuccessResult(2578)
      rescue Exception => e
        @helper.addLogs('Error')
        @helper.postFailResult(e, 2578)
        raise e
      end
    end
  end
  context "Kickbox Importer While Insertion of New Lead assign to the Particular Campaign Based on City Scenario" do
    before(:all) do
      @testDataJSON['Campaign'][0]['Lead Owner'] = ''
      @testDataJSON['Campaign'][0]['Email Address'] = ''
      @testDataJSON['Campaign'][0]['City'] = 'Mumbai'
      @campaignId = @helper.instance_variable_get(:@restForce).getRecords("SELECT id FROM Campaign WHERE Name = '#{@testDataJSON['Campaign'][0]['Name']}'")[0]
      @helper.update_campaign(@campaignId.fetch('Id'),nil,nil, @testDataJSON['Campaign'][0]['City'])
    end
    it 'To Check Journey is created While Importing New lead from Kickbox When the Generate Journey on UI is Checked and Generate journey in CSV is Blank and assign to the particular Campaign Based on City Scenario.', :'2597' => 'true' do
      begin
        leadInfo = @pageObject.upload_csv("john.snow#{rand(9999999999)}_qaauto@example.com", @testDataJSON['Campaign'][0]['Name'],true,true,"Lead")[0]
        Helper.addRecordsToDelete("Lead", leadInfo.fetch('Id'))
        @helper.addLogs("[Expected ] : Lead should create with name #{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
        @helper.addLogs("[Actual ]   : Lead is created with name #{leadInfo.fetch("Name")}")
        expect(leadInfo).to_not eql nil
        expect(validate_case("Lead", @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0], leadInfo)).to be true
        @helper.addLogs("[Result ]   : Lead insertion checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Lead owner should be according to Campaign Assignment as here Campaign assignment is done on the basis of City Scenario")
        @helper.addLogs("[Expected ] : Owner of lead should be user/queue assigned to city")
        @helper.addLogs("[Actual ]   : Owner of lead is #{leadInfo.fetch("Owner").fetch("Name")}")
        expect(leadInfo.fetch("Owner").fetch("Name")).to eql @pageObject.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
        @helper.addLogs("[Result ]   : Owner checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Lead source")
        @helper.addLogs("[Expected ] : Lead source should be Inbound Call")
        @helper.addLogs("[Actual ]   : Lead is created with lead source #{leadInfo.fetch("LeadSource")}")
        expect(leadInfo.fetch("LeadSource")).to eql "Inbound Call"
        @helper.addLogs("[Result ]   : Lead source checked successfully\n")
        @helper.addLogs("[Validate ] : Checking building interested name on Lead")
        @helper.addLogs("[Expected ] : Building interested name should be #{@testDataJSON['Lead'][0]['Building_Interested_In__c']}")
        @helper.addLogs("[Actual ]   : Lead is created with building interested name #{leadInfo.fetch("Building_Interested_Name__c")}")
        expect(leadInfo.fetch("Building_Interested_Name__c")).to eql @testDataJSON['Lead'][0]["Building_Interested_In__c"]
        @helper.addLogs("[Result ]   : Building interested name on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Generate Journey on Lead")
        @helper.addLogs("[Expected ] : Generate Journey should be TRUE")
        @helper.addLogs("[Actual ]   : Lead is created with Generate Journey =  #{leadInfo.fetch("Generate_Journey__c")}")
        expect(leadInfo.fetch("Generate_Journey__c")).to be true
        @helper.addLogs("[Result ]   : Generate Journey on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Locale on Lead")
        @helper.addLogs("[Expected ] : Locale should be en-US")
        @helper.addLogs("[Actual ]   : Lead is created with Locale =  #{leadInfo.fetch("Locale__c")}")
        expect(leadInfo.fetch("Locale__c")).to eql "en-US"
        @helper.addLogs("[Result ]   : Locale on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Country code on Lead")
        @helper.addLogs("[Expected ] : Country code should be IN")
        @helper.addLogs("[Actual ]   : Lead is created with Country code =  #{leadInfo.fetch("Country_Code__c")}")
        expect(leadInfo.fetch("Country_Code__c")).to eql "IN"
        @helper.addLogs("[Result ]   : Country code on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking building interested")
        @helper.addLogs("[Expected ] : Building interested should be #{@testDataJSON['Lead'][0]["Building_Interested_In__c"]}")
        @helper.addLogs("[Actual ]   : Lead is created with building interested #{leadInfo.fetch("Building_Interested_In__c")}")
        expect(leadInfo.fetch("Building_Interested_In__c")).to eql @building
        @helper.addLogs("[Result ]   : Building interested on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Journey created date on lead")
        @helper.addLogs("[Expected ] : Journey created date should be #{leadInfo.fetch("CreatedDate")}")
        @helper.addLogs("[Actual ]   : Lead is created with Journey created date #{leadInfo.fetch("Journey_Created_On__c")}")
        #expect(insertedLeadInfo.fetch("Journey_Created_On__c")).to eql insertedJourneyInfo[0].fetch("CreatedDate")
        @helper.addLogs("[Result ]   : Journey created date on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Locations Interested on lead")
        @helper.addLogs("[Expected ] : Locations Interested should be #{@testDataJSON['Lead'][0]["Building_Interested_In__c"]}")
        @helper.addLogs("[Actual ]   : Lead is created with Locations Interested #{leadInfo.fetch("Locations_Interested__c")}")
        expect(leadInfo.fetch("Locations_Interested__c")).to eql @testDataJSON['Lead'][0]["Building_Interested_In__c"]
        @helper.addLogs("[Result ]   : Locations Interested on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Email on lead")
        @helper.addLogs("[Expected ] : Email should be #{@testDataJSON['Lead'][0]['Email']}")
        @helper.addLogs("[Actual ]   : Lead is created with Email #{leadInfo.fetch("Email")}")
        expect(leadInfo.fetch("Email")).to eql @testDataJSON['Lead'][0]['Email']
        @helper.addLogs("[Result ]   : Email on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Phone on lead")
        @helper.addLogs("[Expected ] : Number of Phone should be #{@testDataJSON['Lead'][0]['Phone']}")
        @helper.addLogs("[Actual ]   : Lead is created with Phone #{leadInfo.fetch("Phone")}")
        expect(leadInfo.fetch("Phone")).to eql @testDataJSON['Lead'][0]['Phone']
        @helper.addLogs("[Result ]   : Phone on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Company on lead")
        @helper.addLogs("[Expected ] : Company should be #{@testDataJSON['Lead'][0]['Company']}")
        @helper.addLogs("[Actual ]   : Lead is created with Company #{leadInfo.fetch("Company")}")
        expect(leadInfo.fetch("Company")).to eql @testDataJSON['Lead'][0]['Company']
        @helper.addLogs("[Result ]   : Company on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Status on lead")
        @helper.addLogs("[Expected ] : Status should be Open")
        @helper.addLogs("[Actual ]   : Lead is created with Status #{leadInfo.fetch("Status")}")
        expect(leadInfo.fetch("Status")).to eql "Open"
        @helper.addLogs("[Result ]   : Status on Lead checked successfully\n")
        insertedJourneyInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,Owner.Name, CreatedDate ,Status__c , NMD_Next_Contact_Date__c ,Primary_Email__c , Lead_Source__c , Lead_Source_Detail__c , Primary_Phone__c , Company_Name__c , Building_Interested_In__c , Locations_Interested__c , Interested_in_Number_of_Desks__c , Full_Time_Employees__c, Name   FROM Journey__c WHERE Primary_Email__c = '#{leadInfo.fetch("Email")}'")[0]
        @helper.addLogs("[Validate ] : Checking Journey is created on lead")
        @helper.addLogs("[Expected ] : Journey should create with name #{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
        @helper.addLogs("[Actual ]   : Journey is created with name #{insertedJourneyInfo.fetch("Name")}")
        expect(insertedJourneyInfo).to_not eql nil
        Helper.addRecordsToDelete("Journey__c", insertedJourneyInfo.fetch('Id'))
        @helper.addLogs("[Result ]   : Journey created successfully\n")
        @helper.addLogs("[Validate ] : Checking Journey owner should be logged in user")
        @helper.addLogs("[Expected ] : Owner of Journey should be owner of lead")
        @helper.addLogs("[Actual ]   : Owner of Journey is #{insertedJourneyInfo.fetch("Owner").fetch("Name")}")
        expect(insertedJourneyInfo.fetch("Owner").fetch("Name")).to eql @userInfo.fetch("display_name")
        @helper.addLogs("[Result ]   : Owner checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Lead source on Journey")
        @helper.addLogs("[Expected ] : Lead source should be Inbound Call")
        @helper.addLogs("[Actual ]   : Journey is created with lead source #{insertedJourneyInfo.fetch("Lead_Source__c")}")
        expect(insertedJourneyInfo.fetch("Lead_Source__c")).to eql "Inbound Call"
        @helper.addLogs("[Result ]   : Lead source checked successfully\n")
        @helper.addLogs("[Validate ] : Checking building interested name on Journey")
        @helper.addLogs("[Expected ] : Building interested should be #{@testDataJSON['Lead'][0]['Building_Interested_In__c']}")
        @helper.addLogs("[Actual ]   : Journey is created with building interested name #{insertedJourneyInfo.fetch("Building_Interested_In__c")}")
        expect(insertedJourneyInfo.fetch("Building_Interested_In__c")).to eql @building
        @helper.addLogs("[Result ]   : Building interested on Journey checked successfully\n")
        @helper.addLogs("[Validate ] : Checking NMD Next Contact Date on Journey")
        @helper.addLogs("[Expected ] : NMD Next Contact Date should be journey creation date")
        @helper.addLogs("[Actual ]   : Journey is created with NMD Next Contact Date #{insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")}")
        #expect(insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")).to eql insertedJourneyInfo[0].fetch("CreatedDate")
        @helper.addLogs("[Result ]   : NMD Next Contact Date on Journey checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Locations Interested on Journey")
        @helper.addLogs("[Expected ] : Locations Interested should be #{@testDataJSON['Lead'][0]['Building_Interested_In__c']}")
        @helper.addLogs("[Actual ]   : Journey is created with Locations Interested #{insertedJourneyInfo.fetch("Locations_Interested__c")}")
        expect(insertedJourneyInfo.fetch('Locations_Interested__c')).to eql @testDataJSON['Lead'][0]["Building_Interested_In__c"]
        @helper.addLogs("[Result ]   : Locations Interested on Journey checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Email on Journey")
        @helper.addLogs("[Expected ] : Email should be #{@testDataJSON['Lead'][0]['Email']}")
        @helper.addLogs("[Actual ]   : Journey is created with Email #{insertedJourneyInfo.fetch("Primary_Email__c")}")
        expect(insertedJourneyInfo.fetch("Primary_Email__c")).to eql @testDataJSON['Lead'][0]['Email']
        @helper.addLogs("[Result ]   : Email on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Phone on Journey")
        @helper.addLogs("[Expected ] : Number of Phone should be #{@testDataJSON['Lead'][0]['Phone']}")
        @helper.addLogs("[Actual ]   : Journey is created with Phone #{insertedJourneyInfo.fetch("Primary_Phone__c")}")
        expect(insertedJourneyInfo.fetch("Primary_Phone__c")).to eql @testDataJSON['Lead'][0]['Phone']
        @helper.addLogs("[Result ]   : Phone on Journey checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Company on Journey")
        @helper.addLogs("[Expected ] : Company should be #{@testDataJSON['Lead'][0]['Company']}")
        @helper.addLogs("[Actual ]   : Journey is created with Company #{insertedJourneyInfo.fetch("Company_Name__c")}")
        expect(insertedJourneyInfo.fetch("Company_Name__c")).to eql @testDataJSON['Lead'][0]['Company']
        @helper.addLogs("[Result ]   : Company on Journey checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Status on Journey")
        @helper.addLogs("[Expected ] : Status should be Started")
        @helper.addLogs("[Actual ]   : Journey is created with Status #{insertedJourneyInfo.fetch("Status__c")}")
        expect(insertedJourneyInfo.fetch("Status__c")).to eql "Started"
        @helper.addLogs("[Result ]   : Status on Journey checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Campaign on Journey")
        @helper.addLogs("[Expected ] : Campaign should be #{@campaignId}")
        @helper.addLogs("[Actual ]   : Journey is created with Campaign #{insertedJourneyInfo.fetch("CampaignId__c")} on it")
        expect(insertedJourneyInfo.fetch("CampaignId__c")).to eql @campaignId
        @helper.addLogs("[Result ]   : Status on Journey checked successfully\n")
        generatedActivityForLead = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Subject , CreatedDate,Status ,Lead_Source__c , Lead_Source_Detail__c,Owner.Name,Locations_Interested__c, Number_of_Full_Time_Employees__c,Interested_in_Number_of_Desks__c,Company__c,WhoId FROM Task WHERE WhoId = '#{leadInfo.fetch('Id')}'")[0]
        @helper.addLogs("[Validate ] : Checking Next Contact Date on existing Journey")
        @helper.addLogs("[Expected ] : Next Contact Date on existing Journey should update with duplicate lead submission date")
        @helper.addLogs("[Actual ]   : Next Contact Date on existing Journey is #{insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")}")
        #expect(existingJourneyInfo.fetch("NMD_Next_Contact_Date__c")).to match generatedActivityForLead.fetch("CreatedDate")
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
        @helper.addLogs("[Validate ] : Checking assigned to on activity")
        @helper.addLogs("[Expected ] : Assigned to on activity should be lead owner")
        @helper.addLogs("[Actual ]   : Assigned to on activity is #{generatedActivityForLead.fetch("Owner").fetch("Name")}")
        expect(generatedActivityForLead.fetch("Owner").fetch("Name")).to eql @userInfo.fetch("display_name")
        @helper.addLogs("[Result ]   : Activity assigned to field checked successfully")
        @helper.addLogs("[Validate ] : Checking status on activity")
        @helper.addLogs("[Expected ] : Status on activity should be Open")
        @helper.addLogs("[Actual ]   : Status on activity is #{generatedActivityForLead.fetch("Status")}")
        expect(generatedActivityForLead.fetch("Status")).to eql "Open"
        @helper.addLogs("[Result ]   : Activity assigned to field checked successfully")
        @helper.addLogs("[Validate ] : Checking status on activity")
        @helper.addLogs("[Expected ] : Status on activity should be Open")
        @helper.addLogs("[Actual ]   : Status on activity is #{generatedActivityForLead.fetch("Status")}")
        expect(generatedActivityForLead.fetch("Company__c")).to eql leadInfo.fetch('Company')
        @helper.addLogs("[Result ]   : Activity Status field checked successfully")
        @helper.addLogs("[Validate ] : Checking Location interested on activity")
        @helper.addLogs("[Expected ] : Location interested on activity should be #{leadInfo.fetch('Locations_Interested__c')}")
        @helper.addLogs("[Actual ]   : Location interested on activity is #{generatedActivityForLead.fetch("Status")}")
        expect(generatedActivityForLead.fetch("Locations_Interested__c")).to eql leadInfo.fetch('Locations_Interested__c')
        @helper.addLogs("[Result ]   : Activity Location interested field checked successfully")
        @helper.addLogs("[Validate ] : Checking Location interested on activity")
        @helper.addLogs("[Expected ] : Number of full time employees on activity should be #{leadInfo.fetch('Number_of_Full_Time_Employees__c')}")
        @helper.addLogs("[Actual ]   : Number of full time employees on activity is #{generatedActivityForLead.fetch("Number_of_Full_Time_Employees__c")}")
        expect(generatedActivityForLead.fetch("Number_of_Full_Time_Employees__c")).to eql leadInfo.fetch('Number_of_Full_Time_Employees__c')
        @helper.addLogs("[Result ]   : Activity Number of full time employees field checked successfully")
        @helper.addLogs("[Validate ] : Checking Number of desks on activity")
        @helper.addLogs("[Expected ] : Checking Number of desks on activity should be #{leadInfo.fetch('Number_of_Full_Time_Employees__c')}")
        @helper.addLogs("[Actual ]   : Checking Number of desks on activity is #{generatedActivityForLead.fetch("Number_of_Full_Time_Employees__c")}")
        expect(generatedActivityForLead.fetch("Interested_in_Number_of_Desks__c")).to eql leadInfo.fetch('Interested_in_Number_of_Desks__c')
        @helper.addLogs("[Result ]   : Activity Number of desks field checked successfully")
        @helper.addLogs('Success')
        @helper.postSuccessResult(2575)
      rescue Exception => e
        @helper.addLogs('Error')
        @helper.postFailResult(e, 2575)
        raise e
      end
    end
    it 'To Check Journey is Created While Importing New Lead from Kickbox When the Generate Journey on UI is Unchecked and Generate Journey in CSV is True and assign to the particular Campaign Based on City Scenario.', :'2599' => 'true' do
      begin
        leadInfo = @pageObject.upload_csv("john.snow#{rand(9999999999)}_qaauto@example.com", 'TRUE',@testDataJSON['Campaign'][0]['Name'],false,true,"Lead")[0]
        Helper.addRecordsToDelete("Lead", leadInfo.fetch('Id'))
        @helper.addLogs("[Expected ] : Lead should create with name #{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
        @helper.addLogs("[Actual ]   : Lead is created with name #{leadInfo.fetch("Name")}")
        expect(leadInfo).to_not eql nil
        expect(validate_case("Lead", @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0], leadInfo)).to be true
        @helper.addLogs("[Result ]   : Lead insertion checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Lead owner should be according to Campaign Assignment as here Campaign assignment is done on the basis of City Scenario")
        @helper.addLogs("[Expected ] : Owner of lead should be user/queue assigned to building of provided email address")
        @helper.addLogs("[Actual ]   : Owner of lead is #{leadInfo.fetch("Owner").fetch("Name")}")
        expect(leadInfo.fetch("Owner").fetch("Name")).to eql @pageObject.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
        @helper.addLogs("[Result ]   : Owner checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Lead source")
        @helper.addLogs("[Expected ] : Lead source should be Inbound Call")
        @helper.addLogs("[Actual ]   : Lead is created with lead source #{leadInfo.fetch("LeadSource")}")
        expect(leadInfo.fetch("LeadSource")).to eql "Inbound Call"
        @helper.addLogs("[Result ]   : Lead source checked successfully\n")
        @helper.addLogs("[Validate ] : Checking building interested name on Lead")
        @helper.addLogs("[Expected ] : Building interested name should be #{@testDataJSON['Lead'][0]['Building_Interested_In__c']}")
        @helper.addLogs("[Actual ]   : Lead is created with building interested name #{leadInfo.fetch("Building_Interested_Name__c")}")
        expect(leadInfo.fetch("Building_Interested_Name__c")).to eql @testDataJSON['Lead'][0]["Building_Interested_In__c"]
        @helper.addLogs("[Result ]   : Building interested name on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Generate Journey on Lead")
        @helper.addLogs("[Expected ] : Generate Journey should be TRUE")
        @helper.addLogs("[Actual ]   : Lead is created with Generate Journey =  #{leadInfo.fetch("Generate_Journey__c")}")
        expect(leadInfo.fetch("Generate_Journey__c")).to be true
        @helper.addLogs("[Result ]   : Generate Journey on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Locale on Lead")
        @helper.addLogs("[Expected ] : Locale should be en-US")
        @helper.addLogs("[Actual ]   : Lead is created with Locale =  #{leadInfo.fetch("Locale__c")}")
        expect(leadInfo.fetch("Locale__c")).to eql "en-US"
        @helper.addLogs("[Result ]   : Locale on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Country code on Lead")
        @helper.addLogs("[Expected ] : Country code should be IN")
        @helper.addLogs("[Actual ]   : Lead is created with Country code =  #{leadInfo.fetch("Country_Code__c")}")
        expect(leadInfo.fetch("Country_Code__c")).to eql "IN"
        @helper.addLogs("[Result ]   : Country code on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking building interested")
        @helper.addLogs("[Expected ] : Building interested should be #{@testDataJSON['Lead'][0]["Building_Interested_In__c"]}")
        @helper.addLogs("[Actual ]   : Lead is created with building interested #{leadInfo.fetch("Building_Interested_In__c")}")
        expect(leadInfo.fetch("Building_Interested_In__c")).to eql @building
        @helper.addLogs("[Result ]   : Building interested on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Journey created date on lead")
        @helper.addLogs("[Expected ] : Journey created date should be #{leadInfo.fetch("CreatedDate")}")
        @helper.addLogs("[Actual ]   : Lead is created with Journey created date #{leadInfo.fetch("Journey_Created_On__c")}")
        #expect(insertedLeadInfo.fetch("Journey_Created_On__c")).to eql insertedJourneyInfo[0].fetch("CreatedDate")
        @helper.addLogs("[Result ]   : Journey created date on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Locations Interested on lead")
        @helper.addLogs("[Expected ] : Locations Interested should be #{@testDataJSON['Lead'][0]["Building_Interested_In__c"]}")
        @helper.addLogs("[Actual ]   : Lead is created with Locations Interested #{leadInfo.fetch("Locations_Interested__c")}")
        expect(leadInfo.fetch("Locations_Interested__c")).to eql @testDataJSON['Lead'][0]["Building_Interested_In__c"]
        @helper.addLogs("[Result ]   : Locations Interested on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Email on lead")
        @helper.addLogs("[Expected ] : Email should be #{@testDataJSON['Lead'][0]['Email']}")
        @helper.addLogs("[Actual ]   : Lead is created with Email #{leadInfo.fetch("Email")}")
        expect(leadInfo.fetch("Email")).to eql @testDataJSON['Lead'][0]['Email']
        @helper.addLogs("[Result ]   : Email on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Phone on lead")
        @helper.addLogs("[Expected ] : Number of Phone should be #{@testDataJSON['Lead'][0]['Phone']}")
        @helper.addLogs("[Actual ]   : Lead is created with Phone #{leadInfo.fetch("Phone")}")
        expect(leadInfo.fetch("Phone")).to eql @testDataJSON['Lead'][0]['Phone']
        @helper.addLogs("[Result ]   : Phone on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Company on lead")
        @helper.addLogs("[Expected ] : Company should be #{@testDataJSON['Lead'][0]['Company']}")
        @helper.addLogs("[Actual ]   : Lead is created with Company #{leadInfo.fetch("Company")}")
        expect(leadInfo.fetch("Company")).to eql @testDataJSON['Lead'][0]['Company']
        @helper.addLogs("[Result ]   : Company on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Status on lead")
        @helper.addLogs("[Expected ] : Status should be Open")
        @helper.addLogs("[Actual ]   : Lead is created with Status #{leadInfo.fetch("Status")}")
        expect(leadInfo.fetch("Status")).to eql "Open"
        @helper.addLogs("[Result ]   : Status on Lead checked successfully\n")
        insertedJourneyInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,Owner.Name, CreatedDate ,Status__c , NMD_Next_Contact_Date__c ,Primary_Email__c , Lead_Source__c , Lead_Source_Detail__c , Primary_Phone__c , Company_Name__c , Building_Interested_In__c , Locations_Interested__c , Interested_in_Number_of_Desks__c , Full_Time_Employees__c, Name   FROM Journey__c WHERE Primary_Email__c = '#{leadInfo.fetch("Email")}'")[0]
        @helper.addLogs("[Validate ] : Checking Journey is created on lead")
        @helper.addLogs("[Expected ] : Journey should create with name #{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
        @helper.addLogs("[Actual ]   : Journey is created with name #{insertedJourneyInfo.fetch("Name")}")
        expect(insertedJourneyInfo).to_not eql nil
        Helper.addRecordsToDelete("Journey__c", insertedJourneyInfo.fetch('Id'))
        @helper.addLogs("[Result ]   : Journey created successfully\n")
        @helper.addLogs("[Validate ] : Checking Journey owner should be logged in user")
        @helper.addLogs("[Expected ] : Owner of Journey should be owner of lead")
        @helper.addLogs("[Actual ]   : Owner of Journey is #{insertedJourneyInfo.fetch("Owner").fetch("Name")}")
        expect(insertedJourneyInfo.fetch("Owner").fetch("Name")).to eql @userInfo.fetch("display_name")
        @helper.addLogs("[Result ]   : Owner checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Lead source on Journey")
        @helper.addLogs("[Expected ] : Lead source should be Inbound Call")
        @helper.addLogs("[Actual ]   : Journey is created with lead source #{insertedJourneyInfo.fetch("Lead_Source__c")}")
        expect(insertedJourneyInfo.fetch("Lead_Source__c")).to eql "Inbound Call"
        @helper.addLogs("[Result ]   : Lead source checked successfully\n")
        @helper.addLogs("[Validate ] : Checking building interested name on Journey")
        @helper.addLogs("[Expected ] : Building interested should be #{@testDataJSON['Lead'][0]['Building_Interested_In__c']}")
        @helper.addLogs("[Actual ]   : Journey is created with building interested name #{insertedJourneyInfo.fetch("Building_Interested_In__c")}")
        expect(insertedJourneyInfo.fetch("Building_Interested_In__c")).to eql @building
        @helper.addLogs("[Result ]   : Building interested on Journey checked successfully\n")
        @helper.addLogs("[Validate ] : Checking NMD Next Contact Date on Journey")
        @helper.addLogs("[Expected ] : NMD Next Contact Date should be journey creation date")
        @helper.addLogs("[Actual ]   : Journey is created with NMD Next Contact Date #{insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")}")
        #expect(insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")).to eql insertedJourneyInfo[0].fetch("CreatedDate")
        @helper.addLogs("[Result ]   : NMD Next Contact Date on Journey checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Locations Interested on Journey")
        @helper.addLogs("[Expected ] : Locations Interested should be #{@testDataJSON['Lead'][0]['Building_Interested_In__c']}")
        @helper.addLogs("[Actual ]   : Journey is created with Locations Interested #{insertedJourneyInfo.fetch("Locations_Interested__c")}")
        expect(insertedJourneyInfo.fetch('Locations_Interested__c')).to eql @testDataJSON['Lead'][0]["Building_Interested_In__c"]
        @helper.addLogs("[Result ]   : Locations Interested on Journey checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Email on Journey")
        @helper.addLogs("[Expected ] : Email should be #{@testDataJSON['Lead'][0]['Email']}")
        @helper.addLogs("[Actual ]   : Journey is created with Email #{insertedJourneyInfo.fetch("Primary_Email__c")}")
        expect(insertedJourneyInfo.fetch("Primary_Email__c")).to eql @testDataJSON['Lead'][0]['Email']
        @helper.addLogs("[Result ]   : Email on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Phone on Journey")
        @helper.addLogs("[Expected ] : Number of Phone should be #{@testDataJSON['Lead'][0]['Phone']}")
        @helper.addLogs("[Actual ]   : Journey is created with Phone #{insertedJourneyInfo.fetch("Primary_Phone__c")}")
        expect(insertedJourneyInfo.fetch("Primary_Phone__c")).to eql @testDataJSON['Lead'][0]['Phone']
        @helper.addLogs("[Result ]   : Phone on Journey checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Company on Journey")
        @helper.addLogs("[Expected ] : Company should be #{@testDataJSON['Lead'][0]['Company']}")
        @helper.addLogs("[Actual ]   : Journey is created with Company #{insertedJourneyInfo.fetch("Company_Name__c")}")
        expect(insertedJourneyInfo.fetch("Company_Name__c")).to eql @testDataJSON['Lead'][0]['Company']
        @helper.addLogs("[Result ]   : Company on Journey checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Status on Journey")
        @helper.addLogs("[Expected ] : Status should be Started")
        @helper.addLogs("[Actual ]   : Journey is created with Status #{insertedJourneyInfo.fetch("Status__c")}")
        expect(insertedJourneyInfo.fetch("Status__c")).to eql "Started"
        @helper.addLogs("[Result ]   : Status on Journey checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Campaign on Journey")
        @helper.addLogs("[Expected ] : Campaign should be #{@campaignId}")
        @helper.addLogs("[Actual ]   : Journey is created with Campaign #{insertedJourneyInfo.fetch("CampaignId__c")} on it")
        expect(insertedJourneyInfo.fetch("CampaignId__c")).to eql @campaignId
        @helper.addLogs("[Result ]   : Status on Journey checked successfully\n")
        generatedActivityForLead = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Subject , CreatedDate,Status ,Lead_Source__c , Lead_Source_Detail__c,Owner.Name,Locations_Interested__c, Number_of_Full_Time_Employees__c,Interested_in_Number_of_Desks__c,Company__c,WhoId FROM Task WHERE WhoId = '#{leadInfo.fetch('Id')}'")[0]
        @helper.addLogs("[Validate ] : Checking Next Contact Date on existing Journey")
        @helper.addLogs("[Expected ] : Next Contact Date on existing Journey should update with duplicate lead submission date")
        @helper.addLogs("[Actual ]   : Next Contact Date on existing Journey is #{insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")}")
        #expect(existingJourneyInfo.fetch("NMD_Next_Contact_Date__c")).to match generatedActivityForLead.fetch("CreatedDate")
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
        @helper.addLogs("[Validate ] : Checking assigned to on activity")
        @helper.addLogs("[Expected ] : Assigned to on activity should be lead owner")
        @helper.addLogs("[Actual ]   : Assigned to on activity is #{generatedActivityForLead.fetch("Owner").fetch("Name")}")
        expect(generatedActivityForLead.fetch("Owner").fetch("Name")).to eql @userInfo.fetch("display_name")
        @helper.addLogs("[Result ]   : Activity assigned to field checked successfully")
        @helper.addLogs("[Validate ] : Checking status on activity")
        @helper.addLogs("[Expected ] : Status on activity should be Open")
        @helper.addLogs("[Actual ]   : Status on activity is #{generatedActivityForLead.fetch("Status")}")
        expect(generatedActivityForLead.fetch("Status")).to eql "Open"
        @helper.addLogs("[Result ]   : Activity assigned to field checked successfully")
        @helper.addLogs("[Validate ] : Checking status on activity")
        @helper.addLogs("[Expected ] : Status on activity should be Open")
        @helper.addLogs("[Actual ]   : Status on activity is #{generatedActivityForLead.fetch("Status")}")
        expect(generatedActivityForLead.fetch("Company__c")).to eql leadInfo.fetch('Company')
        @helper.addLogs("[Result ]   : Activity Status field checked successfully")
        @helper.addLogs("[Validate ] : Checking Location interested on activity")
        @helper.addLogs("[Expected ] : Location interested on activity should be #{leadInfo.fetch('Locations_Interested__c')}")
        @helper.addLogs("[Actual ]   : Location interested on activity is #{generatedActivityForLead.fetch("Status")}")
        expect(generatedActivityForLead.fetch("Locations_Interested__c")).to eql leadInfo.fetch('Locations_Interested__c')
        @helper.addLogs("[Result ]   : Activity Location interested field checked successfully")
        @helper.addLogs("[Validate ] : Checking Location interested on activity")
        @helper.addLogs("[Expected ] : Number of full time employees on activity should be #{leadInfo.fetch('Number_of_Full_Time_Employees__c')}")
        @helper.addLogs("[Actual ]   : Number of full time employees on activity is #{generatedActivityForLead.fetch("Number_of_Full_Time_Employees__c")}")
        expect(generatedActivityForLead.fetch("Number_of_Full_Time_Employees__c")).to eql leadInfo.fetch('Number_of_Full_Time_Employees__c')
        @helper.addLogs("[Result ]   : Activity Number of full time employees field checked successfully")
        @helper.addLogs("[Validate ] : Checking Number of desks on activity")
        @helper.addLogs("[Expected ] : Checking Number of desks on activity should be #{leadInfo.fetch('Number_of_Full_Time_Employees__c')}")
        @helper.addLogs("[Actual ]   : Checking Number of desks on activity is #{generatedActivityForLead.fetch("Number_of_Full_Time_Employees__c")}")
        expect(generatedActivityForLead.fetch("Interested_in_Number_of_Desks__c")).to eql leadInfo.fetch('Interested_in_Number_of_Desks__c')
        @helper.addLogs("[Result ]   : Activity Number of desks field checked successfully")
        @helper.addLogs('Success')
        @helper.postSuccessResult(2578)
      rescue Exception => e
        @helper.addLogs('Error')
        @helper.postFailResult(e, 2578)
        raise e
      end
    end
    it 'To Check Journey is Created While Importing New Lead From Kickbox When the Generate Journey on UI is Checked and Generate Journey in CSV is False and assign to the particular Campaign based on the City Scenario.', :'2602' => 'true' do
      begin
        leadInfo = @pageObject.upload_csv("john.snow#{rand(9999999999)}_qaauto@example.com", 'TRUE', @testDataJSON['Campaign'][0]['Name'],false,true,"Lead")[0]
        Helper.addRecordsToDelete("Lead", leadInfo.fetch('Id'))
        @helper.addLogs("[Expected ] : Lead should create with name #{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
        @helper.addLogs("[Actual ]   : Lead is created with name #{leadInfo.fetch("Name")}")
        expect(leadInfo).to_not eql nil
        expect(validate_case("Lead", @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0], leadInfo)).to be true
        @helper.addLogs("[Result ]   : Lead insertion checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Lead owner should be according to Campaign assignment as here Campaign assignment is done on the basis of City Scenario")
        @helper.addLogs("[Expected ] : Owner of lead should be user/queue assigned to building of provided email address")
        @helper.addLogs("[Actual ]   : Owner of lead is #{leadInfo.fetch("Owner").fetch("Name")}")
        expect(leadInfo.fetch("Owner").fetch("Name")).to eql @pageObject.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
        @helper.addLogs("[Result ]   : Owner checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Lead source")
        @helper.addLogs("[Expected ] : Lead source should be Inbound Call")
        @helper.addLogs("[Actual ]   : Lead is created with lead source #{leadInfo.fetch("LeadSource")}")
        expect(leadInfo.fetch("LeadSource")).to eql "Inbound Call"
        @helper.addLogs("[Result ]   : Lead source checked successfully\n")
        @helper.addLogs("[Validate ] : Checking building interested name on Lead")
        @helper.addLogs("[Expected ] : Building interested name should be #{@testDataJSON['Lead'][0]['Building_Interested_In__c']}")
        @helper.addLogs("[Actual ]   : Lead is created with building interested name #{leadInfo.fetch("Building_Interested_Name__c")}")
        expect(leadInfo.fetch("Building_Interested_Name__c")).to eql @testDataJSON['Lead'][0]["Building_Interested_In__c"]
        @helper.addLogs("[Result ]   : Building interested name on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Generate Journey on Lead")
        @helper.addLogs("[Expected ] : Generate Journey should be TRUE")
        @helper.addLogs("[Actual ]   : Lead is created with Generate Journey =  #{leadInfo.fetch("Generate_Journey__c")}")
        expect(leadInfo.fetch("Generate_Journey__c")).to be true
        @helper.addLogs("[Result ]   : Generate Journey on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Locale on Lead")
        @helper.addLogs("[Expected ] : Locale should be en-US")
        @helper.addLogs("[Actual ]   : Lead is created with Locale =  #{leadInfo.fetch("Locale__c")}")
        expect(leadInfo.fetch("Locale__c")).to eql "en-US"
        @helper.addLogs("[Result ]   : Locale on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Country code on Lead")
        @helper.addLogs("[Expected ] : Country code should be IN")
        @helper.addLogs("[Actual ]   : Lead is created with Country code =  #{leadInfo.fetch("Country_Code__c")}")
        expect(leadInfo.fetch("Country_Code__c")).to eql "IN"
        @helper.addLogs("[Result ]   : Country code on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking building interested")
        @helper.addLogs("[Expected ] : Building interested should be #{@testDataJSON['Lead'][0]["Building_Interested_In__c"]}")
        @helper.addLogs("[Actual ]   : Lead is created with building interested #{leadInfo.fetch("Building_Interested_In__c")}")
        expect(leadInfo.fetch("Building_Interested_In__c")).to eql @building
        @helper.addLogs("[Result ]   : Building interested on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Journey created date on lead")
        @helper.addLogs("[Expected ] : Journey created date should be #{leadInfo.fetch("CreatedDate")}")
        @helper.addLogs("[Actual ]   : Lead is created with Journey created date #{leadInfo.fetch("Journey_Created_On__c")}")
        #expect(insertedLeadInfo.fetch("Journey_Created_On__c")).to eql insertedJourneyInfo[0].fetch("CreatedDate")
        @helper.addLogs("[Result ]   : Journey created date on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Locations Interested on lead")
        @helper.addLogs("[Expected ] : Locations Interested should be #{@testDataJSON['Lead'][0]["Building_Interested_In__c"]}")
        @helper.addLogs("[Actual ]   : Lead is created with Locations Interested #{leadInfo.fetch("Locations_Interested__c")}")
        expect(leadInfo.fetch("Locations_Interested__c")).to eql @testDataJSON['Lead'][0]["Building_Interested_In__c"]
        @helper.addLogs("[Result ]   : Locations Interested on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Email on lead")
        @helper.addLogs("[Expected ] : Email should be #{@testDataJSON['Lead'][0]['Email']}")
        @helper.addLogs("[Actual ]   : Lead is created with Email #{leadInfo.fetch("Email")}")
        expect(leadInfo.fetch("Email")).to eql @testDataJSON['Lead'][0]['Email']
        @helper.addLogs("[Result ]   : Email on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Phone on lead")
        @helper.addLogs("[Expected ] : Number of Phone should be #{@testDataJSON['Lead'][0]['Phone']}")
        @helper.addLogs("[Actual ]   : Lead is created with Phone #{leadInfo.fetch("Phone")}")
        expect(leadInfo.fetch("Phone")).to eql @testDataJSON['Lead'][0]['Phone']
        @helper.addLogs("[Result ]   : Phone on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Company on lead")
        @helper.addLogs("[Expected ] : Company should be #{@testDataJSON['Lead'][0]['Company']}")
        @helper.addLogs("[Actual ]   : Lead is created with Company #{leadInfo.fetch("Company")}")
        expect(leadInfo.fetch("Company")).to eql @testDataJSON['Lead'][0]['Company']
        @helper.addLogs("[Result ]   : Company on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Status on lead")
        @helper.addLogs("[Expected ] : Status should be Open")
        @helper.addLogs("[Actual ]   : Lead is created with Status #{leadInfo.fetch("Status")}")
        expect(leadInfo.fetch("Status")).to eql "Open"
        @helper.addLogs("[Result ]   : Status on Lead checked successfully\n")
        insertedJourneyInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,Owner.Name, CreatedDate ,Status__c , NMD_Next_Contact_Date__c ,Primary_Email__c , Lead_Source__c , Lead_Source_Detail__c , Primary_Phone__c , Company_Name__c , Building_Interested_In__c , Locations_Interested__c , Interested_in_Number_of_Desks__c , Full_Time_Employees__c, Name   FROM Journey__c WHERE Primary_Email__c = '#{leadInfo.fetch("Email")}'")[0]
        @helper.addLogs("[Validate ] : Checking Journey is created on lead")
        @helper.addLogs("[Expected ] : Journey should create with name #{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
        @helper.addLogs("[Actual ]   : Journey is created with name #{insertedJourneyInfo.fetch("Name")}")
        expect(insertedJourneyInfo).to_not eql nil
        Helper.addRecordsToDelete("Journey__c", insertedJourneyInfo.fetch('Id'))
        @helper.addLogs("[Result ]   : Journey created successfully\n")
        @helper.addLogs("[Validate ] : Checking Journey owner should be logged in user")
        @helper.addLogs("[Expected ] : Owner of Journey should be owner of lead")
        @helper.addLogs("[Actual ]   : Owner of Journey is #{insertedJourneyInfo.fetch("Owner").fetch("Name")}")
        expect(insertedJourneyInfo.fetch("Owner").fetch("Name")).to eql @userInfo.fetch("display_name")
        @helper.addLogs("[Result ]   : Owner checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Lead source on Journey")
        @helper.addLogs("[Expected ] : Lead source should be Inbound Call")
        @helper.addLogs("[Actual ]   : Journey is created with lead source #{insertedJourneyInfo.fetch("Lead_Source__c")}")
        expect(insertedJourneyInfo.fetch("Lead_Source__c")).to eql "Inbound Call"
        @helper.addLogs("[Result ]   : Lead source checked successfully\n")
        @helper.addLogs("[Validate ] : Checking building interested name on Journey")
        @helper.addLogs("[Expected ] : Building interested should be #{@testDataJSON['Lead'][0]['Building_Interested_In__c']}")
        @helper.addLogs("[Actual ]   : Journey is created with building interested name #{insertedJourneyInfo.fetch("Building_Interested_In__c")}")
        expect(insertedJourneyInfo.fetch("Building_Interested_In__c")).to eql @building
        @helper.addLogs("[Result ]   : Building interested on Journey checked successfully\n")
        @helper.addLogs("[Validate ] : Checking NMD Next Contact Date on Journey")
        @helper.addLogs("[Expected ] : NMD Next Contact Date should be journey creation date")
        @helper.addLogs("[Actual ]   : Journey is created with NMD Next Contact Date #{insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")}")
        #expect(insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")).to eql insertedJourneyInfo[0].fetch("CreatedDate")
        @helper.addLogs("[Result ]   : NMD Next Contact Date on Journey checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Locations Interested on Journey")
        @helper.addLogs("[Expected ] : Locations Interested should be #{@testDataJSON['Lead'][0]['Building_Interested_In__c']}")
        @helper.addLogs("[Actual ]   : Journey is created with Locations Interested #{insertedJourneyInfo.fetch("Locations_Interested__c")}")
        expect(insertedJourneyInfo.fetch('Locations_Interested__c')).to eql @testDataJSON['Lead'][0]["Building_Interested_In__c"]
        @helper.addLogs("[Result ]   : Locations Interested on Journey checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Email on Journey")
        @helper.addLogs("[Expected ] : Email should be #{@testDataJSON['Lead'][0]['Email']}")
        @helper.addLogs("[Actual ]   : Journey is created with Email #{insertedJourneyInfo.fetch("Primary_Email__c")}")
        expect(insertedJourneyInfo.fetch("Primary_Email__c")).to eql @testDataJSON['Lead'][0]['Email']
        @helper.addLogs("[Result ]   : Email on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Phone on Journey")
        @helper.addLogs("[Expected ] : Number of Phone should be #{@testDataJSON['Lead'][0]['Phone']}")
        @helper.addLogs("[Actual ]   : Journey is created with Phone #{insertedJourneyInfo.fetch("Primary_Phone__c")}")
        expect(insertedJourneyInfo.fetch("Primary_Phone__c")).to eql @testDataJSON['Lead'][0]['Phone']
        @helper.addLogs("[Result ]   : Phone on Journey checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Company on Journey")
        @helper.addLogs("[Expected ] : Company should be #{@testDataJSON['Lead'][0]['Company']}")
        @helper.addLogs("[Actual ]   : Journey is created with Company #{insertedJourneyInfo.fetch("Company_Name__c")}")
        expect(insertedJourneyInfo.fetch("Company_Name__c")).to eql @testDataJSON['Lead'][0]['Company']
        @helper.addLogs("[Result ]   : Company on Journey checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Status on Journey")
        @helper.addLogs("[Expected ] : Status should be Started")
        @helper.addLogs("[Actual ]   : Journey is created with Status #{insertedJourneyInfo.fetch("Status__c")}")
        expect(insertedJourneyInfo.fetch("Status__c")).to eql "Started"
        @helper.addLogs("[Result ]   : Status on Journey checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Campaign on Journey")
        @helper.addLogs("[Expected ] : Campaign should be #{@campaignId}")
        @helper.addLogs("[Actual ]   : Journey is created with Campaign #{insertedJourneyInfo.fetch("CampaignId__c")} on it")
        expect(insertedJourneyInfo.fetch("CampaignId__c")).to eql @campaignId
        @helper.addLogs("[Result ]   : Status on Journey checked successfully\n")
        generatedActivityForLead = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Subject , CreatedDate,Status ,Lead_Source__c , Lead_Source_Detail__c,Owner.Name,Locations_Interested__c, Number_of_Full_Time_Employees__c,Interested_in_Number_of_Desks__c,Company__c,WhoId FROM Task WHERE WhoId = '#{leadInfo.fetch('Id')}'")[0]
        @helper.addLogs("[Validate ] : Checking Next Contact Date on existing Journey")
        @helper.addLogs("[Expected ] : Next Contact Date on existing Journey should update with duplicate lead submission date")
        @helper.addLogs("[Actual ]   : Next Contact Date on existing Journey is #{insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")}")
        #expect(existingJourneyInfo.fetch("NMD_Next_Contact_Date__c")).to match generatedActivityForLead.fetch("CreatedDate")
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
        @helper.addLogs("[Validate ] : Checking assigned to on activity")
        @helper.addLogs("[Expected ] : Assigned to on activity should be lead owner")
        @helper.addLogs("[Actual ]   : Assigned to on activity is #{generatedActivityForLead.fetch("Owner").fetch("Name")}")
        expect(generatedActivityForLead.fetch("Owner").fetch("Name")).to eql @userInfo.fetch("display_name")
        @helper.addLogs("[Result ]   : Activity assigned to field checked successfully")
        @helper.addLogs("[Validate ] : Checking status on activity")
        @helper.addLogs("[Expected ] : Status on activity should be Open")
        @helper.addLogs("[Actual ]   : Status on activity is #{generatedActivityForLead.fetch("Status")}")
        expect(generatedActivityForLead.fetch("Status")).to eql "Open"
        @helper.addLogs("[Result ]   : Activity assigned to field checked successfully")
        @helper.addLogs("[Validate ] : Checking status on activity")
        @helper.addLogs("[Expected ] : Status on activity should be Open")
        @helper.addLogs("[Actual ]   : Status on activity is #{generatedActivityForLead.fetch("Status")}")
        expect(generatedActivityForLead.fetch("Company__c")).to eql leadInfo.fetch('Company')
        @helper.addLogs("[Result ]   : Activity Status field checked successfully")
        @helper.addLogs("[Validate ] : Checking Location interested on activity")
        @helper.addLogs("[Expected ] : Location interested on activity should be #{leadInfo.fetch('Locations_Interested__c')}")
        @helper.addLogs("[Actual ]   : Location interested on activity is #{generatedActivityForLead.fetch("Status")}")
        expect(generatedActivityForLead.fetch("Locations_Interested__c")).to eql leadInfo.fetch('Locations_Interested__c')
        @helper.addLogs("[Result ]   : Activity Location interested field checked successfully")
        @helper.addLogs("[Validate ] : Checking Location interested on activity")
        @helper.addLogs("[Expected ] : Number of full time employees on activity should be #{leadInfo.fetch('Number_of_Full_Time_Employees__c')}")
        @helper.addLogs("[Actual ]   : Number of full time employees on activity is #{generatedActivityForLead.fetch("Number_of_Full_Time_Employees__c")}")
        expect(generatedActivityForLead.fetch("Number_of_Full_Time_Employees__c")).to eql leadInfo.fetch('Number_of_Full_Time_Employees__c')
        @helper.addLogs("[Result ]   : Activity Number of full time employees field checked successfully")
        @helper.addLogs("[Validate ] : Checking Number of desks on activity")
        @helper.addLogs("[Expected ] : Checking Number of desks on activity should be #{leadInfo.fetch('Number_of_Full_Time_Employees__c')}")
        @helper.addLogs("[Actual ]   : Checking Number of desks on activity is #{generatedActivityForLead.fetch("Number_of_Full_Time_Employees__c")}")
        expect(generatedActivityForLead.fetch("Interested_in_Number_of_Desks__c")).to eql leadInfo.fetch('Interested_in_Number_of_Desks__c')
        @helper.addLogs("[Result ]   : Activity Number of desks field checked successfully")
        @helper.addLogs('Success')
        @helper.postSuccessResult(2578)
      rescue Exception => e
        @helper.addLogs('Error')
        @helper.postFailResult(e, 2578)
        raise e
      end
    end
    it 'To Check Journey is Not being Created While Importing New Lead from Kickbox when the Generate Journey on UI is Unchecked and Generate Journey in CSV is Blank and assign to the particular Campaign Based on City Scenario.', :'2601' => 'true' do
      begin
        leadInfo = @pageObject.upload_csv("john.snow#{rand(9999999999)}_qaauto@example.com", 'FALSE', @testDataJSON['Campaign'][0]['Name'], false,true,"Lead")[0]
        Helper.addRecordsToDelete("Lead", leadInfo.fetch('Id'))
        @helper.addLogs("[Expected ] : Lead should create with name #{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
        @helper.addLogs("[Actual ]   : Lead is created with name #{leadInfo.fetch("Name")}")
        expect(leadInfo).to_not eql nil
        expect(validate_case("Lead", @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0], leadInfo)).to be true
        @helper.addLogs("[Result ]   : Lead insertion checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Lead owner should be according to Campaign assignment as here Campaign assignment is done on the basis of City Scenario")
        @helper.addLogs("[Expected ] : Owner of lead should be user/queue assigned to building of provided email address")
        @helper.addLogs("[Actual ]   : Owner of lead is #{leadInfo.fetch("Owner").fetch("Name")}")
        expect(leadInfo.fetch("Owner").fetch("Name")).to eql @pageObject.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
        @helper.addLogs("[Result ]   : Owner checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Lead source")
        @helper.addLogs("[Expected ] : Lead source should be Inbound Call")
        @helper.addLogs("[Actual ]   : Lead is created with lead source #{leadInfo.fetch("LeadSource")}")
        expect(leadInfo.fetch("LeadSource")).to eql "Inbound Call"
        @helper.addLogs("[Result ]   : Lead source checked successfully\n")
        @helper.addLogs("[Validate ] : Checking building interested name on Lead")
        @helper.addLogs("[Expected ] : Building interested name should be #{@testDataJSON['Lead'][0]['Building_Interested_In__c']}")
        @helper.addLogs("[Actual ]   : Lead is created with building interested name #{leadInfo.fetch("Building_Interested_Name__c")}")
        expect(leadInfo.fetch("Building_Interested_Name__c")).to eql @testDataJSON['Lead'][0]["Building_Interested_In__c"]
        @helper.addLogs("[Result ]   : Building interested name on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Generate Journey on Lead")
        @helper.addLogs("[Expected ] : Generate Journey should be TRUE")
        @helper.addLogs("[Actual ]   : Lead is created with Generate Journey =  #{leadInfo.fetch("Generate_Journey__c")}")
        expect(leadInfo.fetch("Generate_Journey__c")).to be true
        @helper.addLogs("[Result ]   : Generate Journey on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Locale on Lead")
        @helper.addLogs("[Expected ] : Locale should be en-US")
        @helper.addLogs("[Actual ]   : Lead is created with Locale =  #{leadInfo.fetch("Locale__c")}")
        expect(leadInfo.fetch("Locale__c")).to eql "en-US"
        @helper.addLogs("[Result ]   : Locale on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Country code on Lead")
        @helper.addLogs("[Expected ] : Country code should be IN")
        @helper.addLogs("[Actual ]   : Lead is created with Country code =  #{leadInfo.fetch("Country_Code__c")}")
        expect(leadInfo.fetch("Country_Code__c")).to eql "IN"
        @helper.addLogs("[Result ]   : Country code on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking building interested")
        @helper.addLogs("[Expected ] : Building interested should be #{@testDataJSON['Lead'][0]["Building_Interested_In__c"]}")
        @helper.addLogs("[Actual ]   : Lead is created with building interested #{leadInfo.fetch("Building_Interested_In__c")}")
        expect(leadInfo.fetch("Building_Interested_In__c")).to eql @building
        @helper.addLogs("[Result ]   : Building interested on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Journey created date on lead")
        @helper.addLogs("[Expected ] : Journey created date should be #{leadInfo.fetch("CreatedDate")}")
        @helper.addLogs("[Actual ]   : Lead is created with Journey created date #{leadInfo.fetch("Journey_Created_On__c")}")
        #expect(insertedLeadInfo.fetch("Journey_Created_On__c")).to eql insertedJourneyInfo[0].fetch("CreatedDate")
        @helper.addLogs("[Result ]   : Journey created date on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Locations Interested on lead")
        @helper.addLogs("[Expected ] : Locations Interested should be #{@testDataJSON['Lead'][0]["Building_Interested_In__c"]}")
        @helper.addLogs("[Actual ]   : Lead is created with Locations Interested #{leadInfo.fetch("Locations_Interested__c")}")
        expect(leadInfo.fetch("Locations_Interested__c")).to eql @testDataJSON['Lead'][0]["Building_Interested_In__c"]
        @helper.addLogs("[Result ]   : Locations Interested on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Email on lead")
        @helper.addLogs("[Expected ] : Email should be #{@testDataJSON['Lead'][0]['Email']}")
        @helper.addLogs("[Actual ]   : Lead is created with Email #{leadInfo.fetch("Email")}")
        expect(leadInfo.fetch("Email")).to eql @testDataJSON['Lead'][0]['Email']
        @helper.addLogs("[Result ]   : Email on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Phone on lead")
        @helper.addLogs("[Expected ] : Number of Phone should be #{@testDataJSON['Lead'][0]['Phone']}")
        @helper.addLogs("[Actual ]   : Lead is created with Phone #{leadInfo.fetch("Phone")}")
        expect(leadInfo.fetch("Phone")).to eql @testDataJSON['Lead'][0]['Phone']
        @helper.addLogs("[Result ]   : Phone on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Company on lead")
        @helper.addLogs("[Expected ] : Company should be #{@testDataJSON['Lead'][0]['Company']}")
        @helper.addLogs("[Actual ]   : Lead is created with Company #{leadInfo.fetch("Company")}")
        expect(leadInfo.fetch("Company")).to eql @testDataJSON['Lead'][0]['Company']
        @helper.addLogs("[Result ]   : Company on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Status on lead")
        @helper.addLogs("[Expected ] : Status should be Open")
        @helper.addLogs("[Actual ]   : Lead is created with Status #{leadInfo.fetch("Status")}")
        expect(leadInfo.fetch("Status")).to eql "Open"
        @helper.addLogs("[Result ]   : Status on Lead checked successfully\n")
        insertedJourneyInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id FROM Journey__c WHERE Primary_Email__c = '#{leadInfo.fetch("Email")}'")[0]
        @helper.addLogs("[Validate ] : Checking Journey is created on lead")
        @helper.addLogs("[Expected ] : Journey should not be created")
        @helper.addLogs("[Result ]   : Journey is created #{insertedJourneyInfo.nil? ? 'NO' : 'Yes'}")
        expect(insertedJourneyInfo).to eql nil
        @helper.addLogs("[Result ] : Journey creation checked successfully")
        @helper.addLogs("[Actual ]   : Next Contact Date on existing Journey is #{insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")}")
        generatedActivityForLead = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Subject , CreatedDate,Status ,Lead_Source__c , Lead_Source_Detail__c,Owner.Name,Locations_Interested__c, Number_of_Full_Time_Employees__c,Interested_in_Number_of_Desks__c,Company__c,WhoId FROM Task WHERE WhoId = '#{leadInfo.fetch('Id')}'")[0]
        @helper.addLogs("[Validate ] : Checking Next Contact Date on existing Journey")
        @helper.addLogs("[Expected ] : Next Contact Date on existing Journey should update with duplicate lead submission date")
        @helper.addLogs("[Actual ]   : Next Contact Date on existing Journey is #{insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")}")
        #expect(existingJourneyInfo.fetch("NMD_Next_Contact_Date__c")).to match generatedActivityForLead.fetch("CreatedDate")
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
        @helper.addLogs("[Validate ] : Checking assigned to on activity")
        @helper.addLogs("[Expected ] : Assigned to on activity should be lead owner")
        @helper.addLogs("[Actual ]   : Assigned to on activity is #{generatedActivityForLead.fetch("Owner").fetch("Name")}")
        expect(generatedActivityForLead.fetch("Owner").fetch("Name")).to eql @userInfo.fetch("display_name")
        @helper.addLogs("[Result ]   : Activity assigned to field checked successfully")
        @helper.addLogs("[Validate ] : Checking status on activity")
        @helper.addLogs("[Expected ] : Status on activity should be Open")
        @helper.addLogs("[Actual ]   : Status on activity is #{generatedActivityForLead.fetch("Status")}")
        expect(generatedActivityForLead.fetch("Status")).to eql "Open"
        @helper.addLogs("[Result ]   : Activity assigned to field checked successfully")
        @helper.addLogs("[Validate ] : Checking status on activity")
        @helper.addLogs("[Expected ] : Status on activity should be Open")
        @helper.addLogs("[Actual ]   : Status on activity is #{generatedActivityForLead.fetch("Status")}")
        expect(generatedActivityForLead.fetch("Company__c")).to eql leadInfo.fetch('Company')
        @helper.addLogs("[Result ]   : Activity Status field checked successfully")
        @helper.addLogs("[Validate ] : Checking Location interested on activity")
        @helper.addLogs("[Expected ] : Location interested on activity should be #{leadInfo.fetch('Locations_Interested__c')}")
        @helper.addLogs("[Actual ]   : Location interested on activity is #{generatedActivityForLead.fetch("Status")}")
        expect(generatedActivityForLead.fetch("Locations_Interested__c")).to eql leadInfo.fetch('Locations_Interested__c')
        @helper.addLogs("[Result ]   : Activity Location interested field checked successfully")
        @helper.addLogs("[Validate ] : Checking Location interested on activity")
        @helper.addLogs("[Expected ] : Number of full time employees on activity should be #{leadInfo.fetch('Number_of_Full_Time_Employees__c')}")
        @helper.addLogs("[Actual ]   : Number of full time employees on activity is #{generatedActivityForLead.fetch("Number_of_Full_Time_Employees__c")}")
        expect(generatedActivityForLead.fetch("Number_of_Full_Time_Employees__c")).to eql leadInfo.fetch('Number_of_Full_Time_Employees__c')
        @helper.addLogs("[Result ]   : Activity Number of full time employees field checked successfully")
        @helper.addLogs("[Validate ] : Checking Number of desks on activity")
        @helper.addLogs("[Expected ] : Checking Number of desks on activity should be #{leadInfo.fetch('Number_of_Full_Time_Employees__c')}")
        @helper.addLogs("[Actual ]   : Checking Number of desks on activity is #{generatedActivityForLead.fetch("Number_of_Full_Time_Employees__c")}")
        expect(generatedActivityForLead.fetch("Interested_in_Number_of_Desks__c")).to eql leadInfo.fetch('Interested_in_Number_of_Desks__c')
        @helper.addLogs("[Result ]   : Activity Number of desks field checked successfully")
        @helper.addLogs('Success')
        @helper.postSuccessResult(2578)
      rescue Exception => e
        @helper.addLogs('Error')
        @helper.postFailResult(e, 2578)
        raise e
      end
    end
  end
  context "Kickbox Importer While Insertion of New Lead assign to the Particular Campaign if No Criteria is Matched" do
    before(:all) do
      @testDataJSON['Campaign'][0]['Lead Owner'] = ''
      @testDataJSON['Campaign'][0]['Email Address'] = ''
      @testDataJSON['Campaign'][0]['City'] = ''
      @campaignId = @helper.instance_variable_get(:@restForce).getRecords("SELECT id FROM Campaign WHERE Name = '#{@testDataJSON['Campaign'][0]['Name']}'")[0]
      @helper.update_campaign(@campaignId.fetch('Id'), @testDataJSON['Campaign'][0]['Lead Owner'])
    end
    it 'To Check Journey is created While Importing New lead from Kickbox When the Generate Journey on UI is Checked and Generate journey in CSV is Blank and assign to the particular Campaign if No Criteria is Matched.', :'2604' => 'true' do
      begin
        leadInfo = @pageObject.upload_csv("john.snow#{rand(9999999999)}_qaauto@example.com", @testDataJSON['Campaign'][0]['Name'], true, true,"Lead")[0]
        Helper.addRecordsToDelete("Lead", leadInfo.fetch('Id'))
        @helper.addLogs("[Expected ] : Lead should create with name #{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
        @helper.addLogs("[Actual ]   : Lead is created with name #{leadInfo.fetch("Name")}")
        expect(leadInfo).to_not eql nil
        expect(validate_case("Lead", @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0], leadInfo)).to be true
        @helper.addLogs("[Result ]   : Lead insertion checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Lead owner should be Unassigned NMD Us Queue based on Unassigned NMD Us Queue Sales Console Setting")
        @helper.addLogs("[Expected ] : Owner of lead should be nassigned NMD Us Queue")
        @helper.addLogs("[Actual ]   : Owner of lead is #{leadInfo.fetch("Owner").fetch("Name")}")
        expect(leadInfo.fetch("Owner").fetch("Name")).to eql @pageObject.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
        @helper.addLogs("[Result ]   : Owner checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Lead source")
        @helper.addLogs("[Expected ] : Lead source should be Inbound Call")
        @helper.addLogs("[Actual ]   : Lead is created with lead source #{leadInfo.fetch("LeadSource")}")
        expect(leadInfo.fetch("LeadSource")).to eql "Inbound Call"
        @helper.addLogs("[Result ]   : Lead source checked successfully\n")
        @helper.addLogs("[Validate ] : Checking building interested name on Lead")
        @helper.addLogs("[Expected ] : Building interested name should be #{@testDataJSON['Lead'][0]['Building_Interested_In__c']}")
        @helper.addLogs("[Actual ]   : Lead is created with building interested name #{leadInfo.fetch("Building_Interested_Name__c")}")
        expect(leadInfo.fetch("Building_Interested_Name__c")).to eql @testDataJSON['Lead'][0]["Building_Interested_In__c"]
        @helper.addLogs("[Result ]   : Building interested name on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Generate Journey on Lead")
        @helper.addLogs("[Expected ] : Generate Journey should be TRUE")
        @helper.addLogs("[Actual ]   : Lead is created with Generate Journey =  #{leadInfo.fetch("Generate_Journey__c")}")
        expect(leadInfo.fetch("Generate_Journey__c")).to be true
        @helper.addLogs("[Result ]   : Generate Journey on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Locale on Lead")
        @helper.addLogs("[Expected ] : Locale should be en-US")
        @helper.addLogs("[Actual ]   : Lead is created with Locale =  #{leadInfo.fetch("Locale__c")}")
        expect(leadInfo.fetch("Locale__c")).to eql "en-US"
        @helper.addLogs("[Result ]   : Locale on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Country code on Lead")
        @helper.addLogs("[Expected ] : Country code should be IN")
        @helper.addLogs("[Actual ]   : Lead is created with Country code =  #{leadInfo.fetch("Country_Code__c")}")
        expect(leadInfo.fetch("Country_Code__c")).to eql "IN"
        @helper.addLogs("[Result ]   : Country code on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking building interested")
        @helper.addLogs("[Expected ] : Building interested should be #{@testDataJSON['Lead'][0]["Building_Interested_In__c"]}")
        @helper.addLogs("[Actual ]   : Lead is created with building interested #{leadInfo.fetch("Building_Interested_In__c")}")
        expect(leadInfo.fetch("Building_Interested_In__c")).to eql @building
        @helper.addLogs("[Result ]   : Building interested on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Journey created date on lead")
        @helper.addLogs("[Expected ] : Journey created date should be #{leadInfo.fetch("CreatedDate")}")
        @helper.addLogs("[Actual ]   : Lead is created with Journey created date #{leadInfo.fetch("Journey_Created_On__c")}")
        #expect(insertedLeadInfo.fetch("Journey_Created_On__c")).to eql insertedJourneyInfo[0].fetch("CreatedDate")
        @helper.addLogs("[Result ]   : Journey created date on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Locations Interested on lead")
        @helper.addLogs("[Expected ] : Locations Interested should be #{@testDataJSON['Lead'][0]["Building_Interested_In__c"]}")
        @helper.addLogs("[Actual ]   : Lead is created with Locations Interested #{leadInfo.fetch("Locations_Interested__c")}")
        expect(leadInfo.fetch("Locations_Interested__c")).to eql @testDataJSON['Lead'][0]["Building_Interested_In__c"]
        @helper.addLogs("[Result ]   : Locations Interested on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Email on lead")
        @helper.addLogs("[Expected ] : Email should be #{@testDataJSON['Lead'][0]['Email']}")
        @helper.addLogs("[Actual ]   : Lead is created with Email #{leadInfo.fetch("Email")}")
        expect(leadInfo.fetch("Email")).to eql @testDataJSON['Lead'][0]['Email']
        @helper.addLogs("[Result ]   : Email on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Phone on lead")
        @helper.addLogs("[Expected ] : Number of Phone should be #{@testDataJSON['Lead'][0]['Phone']}")
        @helper.addLogs("[Actual ]   : Lead is created with Phone #{leadInfo.fetch("Phone")}")
        expect(leadInfo.fetch("Phone")).to eql @testDataJSON['Lead'][0]['Phone']
        @helper.addLogs("[Result ]   : Phone on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Company on lead")
        @helper.addLogs("[Expected ] : Company should be #{@testDataJSON['Lead'][0]['Company']}")
        @helper.addLogs("[Actual ]   : Lead is created with Company #{leadInfo.fetch("Company")}")
        expect(leadInfo.fetch("Company")).to eql @testDataJSON['Lead'][0]['Company']
        @helper.addLogs("[Result ]   : Company on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Status on lead")
        @helper.addLogs("[Expected ] : Status should be Open")
        @helper.addLogs("[Actual ]   : Lead is created with Status #{leadInfo.fetch("Status")}")
        expect(leadInfo.fetch("Status")).to eql "Open"
        @helper.addLogs("[Result ]   : Status on Lead checked successfully\n")
        insertedJourneyInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,Owner.Name, CreatedDate ,Status__c , NMD_Next_Contact_Date__c ,Primary_Email__c , Lead_Source__c , Lead_Source_Detail__c , Primary_Phone__c , Company_Name__c , Building_Interested_In__c , Locations_Interested__c , Interested_in_Number_of_Desks__c , Full_Time_Employees__c, Name   FROM Journey__c WHERE Primary_Email__c = '#{leadInfo.fetch("Email")}'")[0]
        @helper.addLogs("[Validate ] : Checking Journey is created on lead")
        @helper.addLogs("[Expected ] : Journey should create with name #{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
        @helper.addLogs("[Actual ]   : Journey is created with name #{insertedJourneyInfo.fetch("Name")}")
        expect(insertedJourneyInfo).to_not eql nil
        Helper.addRecordsToDelete("Journey__c", insertedJourneyInfo.fetch('Id'))
        @helper.addLogs("[Result ]   : Journey created successfully\n")
        @helper.addLogs("[Validate ] : Checking Journey owner should be logged in user")
        @helper.addLogs("[Expected ] : Owner of Journey should be owner of lead")
        @helper.addLogs("[Actual ]   : Owner of Journey is #{insertedJourneyInfo.fetch("Owner").fetch("Name")}")
        expect(insertedJourneyInfo.fetch("Owner").fetch("Name")).to eql @userInfo.fetch("display_name")
        @helper.addLogs("[Result ]   : Owner checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Lead source on Journey")
        @helper.addLogs("[Expected ] : Lead source should be Inbound Call")
        @helper.addLogs("[Actual ]   : Journey is created with lead source #{insertedJourneyInfo.fetch("Lead_Source__c")}")
        expect(insertedJourneyInfo.fetch("Lead_Source__c")).to eql "Inbound Call"
        @helper.addLogs("[Result ]   : Lead source checked successfully\n")
        @helper.addLogs("[Validate ] : Checking building interested name on Journey")
        @helper.addLogs("[Expected ] : Building interested should be #{@testDataJSON['Lead'][0]['Building_Interested_In__c']}")
        @helper.addLogs("[Actual ]   : Journey is created with building interested name #{insertedJourneyInfo.fetch("Building_Interested_In__c")}")
        expect(insertedJourneyInfo.fetch("Building_Interested_In__c")).to eql @building
        @helper.addLogs("[Result ]   : Building interested on Journey checked successfully\n")
        @helper.addLogs("[Validate ] : Checking NMD Next Contact Date on Journey")
        @helper.addLogs("[Expected ] : NMD Next Contact Date should be journey creation date")
        @helper.addLogs("[Actual ]   : Journey is created with NMD Next Contact Date #{insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")}")
        #expect(insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")).to eql insertedJourneyInfo[0].fetch("CreatedDate")
        @helper.addLogs("[Result ]   : NMD Next Contact Date on Journey checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Locations Interested on Journey")
        @helper.addLogs("[Expected ] : Locations Interested should be #{@testDataJSON['Lead'][0]['Building_Interested_In__c']}")
        @helper.addLogs("[Actual ]   : Journey is created with Locations Interested #{insertedJourneyInfo.fetch("Locations_Interested__c")}")
        expect(insertedJourneyInfo.fetch('Locations_Interested__c')).to eql @testDataJSON['Lead'][0]["Building_Interested_In__c"]
        @helper.addLogs("[Result ]   : Locations Interested on Journey checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Email on Journey")
        @helper.addLogs("[Expected ] : Email should be #{@testDataJSON['Lead'][0]['Email']}")
        @helper.addLogs("[Actual ]   : Journey is created with Email #{insertedJourneyInfo.fetch("Primary_Email__c")}")
        expect(insertedJourneyInfo.fetch("Primary_Email__c")).to eql @testDataJSON['Lead'][0]['Email']
        @helper.addLogs("[Result ]   : Email on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Phone on Journey")
        @helper.addLogs("[Expected ] : Number of Phone should be #{@testDataJSON['Lead'][0]['Phone']}")
        @helper.addLogs("[Actual ]   : Journey is created with Phone #{insertedJourneyInfo.fetch("Primary_Phone__c")}")
        expect(insertedJourneyInfo.fetch("Primary_Phone__c")).to eql @testDataJSON['Lead'][0]['Phone']
        @helper.addLogs("[Result ]   : Phone on Journey checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Company on Journey")
        @helper.addLogs("[Expected ] : Company should be #{@testDataJSON['Lead'][0]['Company']}")
        @helper.addLogs("[Actual ]   : Journey is created with Company #{insertedJourneyInfo.fetch("Company_Name__c")}")
        expect(insertedJourneyInfo.fetch("Company_Name__c")).to eql @testDataJSON['Lead'][0]['Company']
        @helper.addLogs("[Result ]   : Company on Journey checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Status on Journey")
        @helper.addLogs("[Expected ] : Status should be Started")
        @helper.addLogs("[Actual ]   : Journey is created with Status #{insertedJourneyInfo.fetch("Status__c")}")
        expect(insertedJourneyInfo.fetch("Status__c")).to eql "Started"
        @helper.addLogs("[Result ]   : Status on Journey checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Campaign on Journey")
        @helper.addLogs("[Expected ] : Campaign should be #{@campaignId}")
        @helper.addLogs("[Actual ]   : Journey is created with Campaign #{insertedJourneyInfo.fetch("CampaignId__c")} on it")
        expect(insertedJourneyInfo.fetch("CampaignId__c")).to eql @campaignId
        @helper.addLogs("[Result ]   : Status on Journey checked successfully\n")
        generatedActivityForLead = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Subject , CreatedDate,Status ,Lead_Source__c , Lead_Source_Detail__c,Owner.Name,Locations_Interested__c, Number_of_Full_Time_Employees__c,Interested_in_Number_of_Desks__c,Company__c,WhoId FROM Task WHERE WhoId = '#{leadInfo.fetch('Id')}'")[0]
        @helper.addLogs("[Validate ] : Checking Next Contact Date on existing Journey")
        @helper.addLogs("[Expected ] : Next Contact Date on existing Journey should update with duplicate lead submission date")
        @helper.addLogs("[Actual ]   : Next Contact Date on existing Journey is #{insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")}")
        #expect(existingJourneyInfo.fetch("NMD_Next_Contact_Date__c")).to match generatedActivityForLead.fetch("CreatedDate")
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
        @helper.addLogs("[Validate ] : Checking assigned to on activity")
        @helper.addLogs("[Expected ] : Assigned to on activity should be lead owner")
        @helper.addLogs("[Actual ]   : Assigned to on activity is #{generatedActivityForLead.fetch("Owner").fetch("Name")}")
        expect(generatedActivityForLead.fetch("Owner").fetch("Name")).to eql @userInfo.fetch("display_name")
        @helper.addLogs("[Result ]   : Activity assigned to field checked successfully")
        @helper.addLogs("[Validate ] : Checking status on activity")
        @helper.addLogs("[Expected ] : Status on activity should be Open")
        @helper.addLogs("[Actual ]   : Status on activity is #{generatedActivityForLead.fetch("Status")}")
        expect(generatedActivityForLead.fetch("Status")).to eql "Open"
        @helper.addLogs("[Result ]   : Activity assigned to field checked successfully")
        @helper.addLogs("[Validate ] : Checking status on activity")
        @helper.addLogs("[Expected ] : Status on activity should be Open")
        @helper.addLogs("[Actual ]   : Status on activity is #{generatedActivityForLead.fetch("Status")}")
        expect(generatedActivityForLead.fetch("Company__c")).to eql leadInfo.fetch('Company')
        @helper.addLogs("[Result ]   : Activity Status field checked successfully")
        @helper.addLogs("[Validate ] : Checking Location interested on activity")
        @helper.addLogs("[Expected ] : Location interested on activity should be #{leadInfo.fetch('Locations_Interested__c')}")
        @helper.addLogs("[Actual ]   : Location interested on activity is #{generatedActivityForLead.fetch("Status")}")
        expect(generatedActivityForLead.fetch("Locations_Interested__c")).to eql leadInfo.fetch('Locations_Interested__c')
        @helper.addLogs("[Result ]   : Activity Location interested field checked successfully")
        @helper.addLogs("[Validate ] : Checking Location interested on activity")
        @helper.addLogs("[Expected ] : Number of full time employees on activity should be #{leadInfo.fetch('Number_of_Full_Time_Employees__c')}")
        @helper.addLogs("[Actual ]   : Number of full time employees on activity is #{generatedActivityForLead.fetch("Number_of_Full_Time_Employees__c")}")
        expect(generatedActivityForLead.fetch("Number_of_Full_Time_Employees__c")).to eql leadInfo.fetch('Number_of_Full_Time_Employees__c')
        @helper.addLogs("[Result ]   : Activity Number of full time employees field checked successfully")
        @helper.addLogs("[Validate ] : Checking Number of desks on activity")
        @helper.addLogs("[Expected ] : Checking Number of desks on activity should be #{leadInfo.fetch('Number_of_Full_Time_Employees__c')}")
        @helper.addLogs("[Actual ]   : Checking Number of desks on activity is #{generatedActivityForLead.fetch("Number_of_Full_Time_Employees__c")}")
        expect(generatedActivityForLead.fetch("Interested_in_Number_of_Desks__c")).to eql leadInfo.fetch('Interested_in_Number_of_Desks__c')
        @helper.addLogs("[Result ]   : Activity Number of desks field checked successfully")
        @helper.addLogs('Success')
        @helper.postSuccessResult(2575)
      rescue Exception => e
        @helper.addLogs('Error')
        @helper.postFailResult(e, 2575)
        raise e
      end
    end
    it 'To Check Journey is Created While Importing New Lead from Kickbox When the Generate Journey on UI is Unchecked and Generate Journey in CSV is True and assign to the particular Campaign if No Criteria is Matched.', :'2605' => 'true' do
      begin
        leadInfo = @pageObject.upload_csv("john.snow#{rand(9999999999)}_qaauto@example.com", 'TRUE', @testDataJSON['Campaign'][0]['Name'], false, true,"Lead")[0]
        Helper.addRecordsToDelete("Lead", leadInfo.fetch('Id'))
        @helper.addLogs("[Expected ] : Lead should create with name #{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
        @helper.addLogs("[Actual ]   : Lead is created with name #{leadInfo.fetch("Name")}")
        expect(leadInfo).to_not eql nil
        expect(validate_case("Lead", @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0], leadInfo)).to be true
        @helper.addLogs("[Result ]   : Lead insertion checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Lead owner should be Unassigned NMD Us Queue based on Unassigned NMD Us Queue Sales Console Setting")
        @helper.addLogs("[Expected ] : Owner of lead should be nassigned NMD Us Queue")
        @helper.addLogs("[Actual ]   : Owner of lead is #{leadInfo.fetch("Owner").fetch("Name")}")
        expect(leadInfo.fetch("Owner").fetch("Name")).to eql @pageObject.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
        @helper.addLogs("[Result ]   : Owner checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Lead source")
        @helper.addLogs("[Expected ] : Lead source should be Inbound Call")
        @helper.addLogs("[Actual ]   : Lead is created with lead source #{leadInfo.fetch("LeadSource")}")
        expect(leadInfo.fetch("LeadSource")).to eql "Inbound Call"
        @helper.addLogs("[Result ]   : Lead source checked successfully\n")
        @helper.addLogs("[Validate ] : Checking building interested name on Lead")
        @helper.addLogs("[Expected ] : Building interested name should be #{@testDataJSON['Lead'][0]['Building_Interested_In__c']}")
        @helper.addLogs("[Actual ]   : Lead is created with building interested name #{leadInfo.fetch("Building_Interested_Name__c")}")
        expect(leadInfo.fetch("Building_Interested_Name__c")).to eql @testDataJSON['Lead'][0]["Building_Interested_In__c"]
        @helper.addLogs("[Result ]   : Building interested name on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Generate Journey on Lead")
        @helper.addLogs("[Expected ] : Generate Journey should be TRUE")
        @helper.addLogs("[Actual ]   : Lead is created with Generate Journey =  #{leadInfo.fetch("Generate_Journey__c")}")
        expect(leadInfo.fetch("Generate_Journey__c")).to be true
        @helper.addLogs("[Result ]   : Generate Journey on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Locale on Lead")
        @helper.addLogs("[Expected ] : Locale should be en-US")
        @helper.addLogs("[Actual ]   : Lead is created with Locale =  #{leadInfo.fetch("Locale__c")}")
        expect(leadInfo.fetch("Locale__c")).to eql "en-US"
        @helper.addLogs("[Result ]   : Locale on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Country code on Lead")
        @helper.addLogs("[Expected ] : Country code should be IN")
        @helper.addLogs("[Actual ]   : Lead is created with Country code =  #{leadInfo.fetch("Country_Code__c")}")
        expect(leadInfo.fetch("Country_Code__c")).to eql "IN"
        @helper.addLogs("[Result ]   : Country code on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking building interested")
        @helper.addLogs("[Expected ] : Building interested should be #{@testDataJSON['Lead'][0]["Building_Interested_In__c"]}")
        @helper.addLogs("[Actual ]   : Lead is created with building interested #{leadInfo.fetch("Building_Interested_In__c")}")
        expect(leadInfo.fetch("Building_Interested_In__c")).to eql @building
        @helper.addLogs("[Result ]   : Building interested on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Journey created date on lead")
        @helper.addLogs("[Expected ] : Journey created date should be #{leadInfo.fetch("CreatedDate")}")
        @helper.addLogs("[Actual ]   : Lead is created with Journey created date #{leadInfo.fetch("Journey_Created_On__c")}")
        #expect(insertedLeadInfo.fetch("Journey_Created_On__c")).to eql insertedJourneyInfo[0].fetch("CreatedDate")
        @helper.addLogs("[Result ]   : Journey created date on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Locations Interested on lead")
        @helper.addLogs("[Expected ] : Locations Interested should be #{@testDataJSON['Lead'][0]["Building_Interested_In__c"]}")
        @helper.addLogs("[Actual ]   : Lead is created with Locations Interested #{leadInfo.fetch("Locations_Interested__c")}")
        expect(leadInfo.fetch("Locations_Interested__c")).to eql @testDataJSON['Lead'][0]["Building_Interested_In__c"]
        @helper.addLogs("[Result ]   : Locations Interested on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Email on lead")
        @helper.addLogs("[Expected ] : Email should be #{@testDataJSON['Lead'][0]['Email']}")
        @helper.addLogs("[Actual ]   : Lead is created with Email #{leadInfo.fetch("Email")}")
        expect(leadInfo.fetch("Email")).to eql @testDataJSON['Lead'][0]['Email']
        @helper.addLogs("[Result ]   : Email on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Phone on lead")
        @helper.addLogs("[Expected ] : Number of Phone should be #{@testDataJSON['Lead'][0]['Phone']}")
        @helper.addLogs("[Actual ]   : Lead is created with Phone #{leadInfo.fetch("Phone")}")
        expect(leadInfo.fetch("Phone")).to eql @testDataJSON['Lead'][0]['Phone']
        @helper.addLogs("[Result ]   : Phone on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Company on lead")
        @helper.addLogs("[Expected ] : Company should be #{@testDataJSON['Lead'][0]['Company']}")
        @helper.addLogs("[Actual ]   : Lead is created with Company #{leadInfo.fetch("Company")}")
        expect(leadInfo.fetch("Company")).to eql @testDataJSON['Lead'][0]['Company']
        @helper.addLogs("[Result ]   : Company on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Status on lead")
        @helper.addLogs("[Expected ] : Status should be Open")
        @helper.addLogs("[Actual ]   : Lead is created with Status #{leadInfo.fetch("Status")}")
        expect(leadInfo.fetch("Status")).to eql "Open"
        @helper.addLogs("[Result ]   : Status on Lead checked successfully\n")
        insertedJourneyInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,Owner.Name, CreatedDate ,Status__c , NMD_Next_Contact_Date__c ,Primary_Email__c , Lead_Source__c , Lead_Source_Detail__c , Primary_Phone__c , Company_Name__c , Building_Interested_In__c , Locations_Interested__c , Interested_in_Number_of_Desks__c , Full_Time_Employees__c, Name   FROM Journey__c WHERE Primary_Email__c = '#{leadInfo.fetch("Email")}'")[0]
        @helper.addLogs("[Validate ] : Checking Journey is created on lead")
        @helper.addLogs("[Expected ] : Journey should create with name #{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
        @helper.addLogs("[Actual ]   : Journey is created with name #{insertedJourneyInfo.fetch("Name")}")
        expect(insertedJourneyInfo).to_not eql nil
        Helper.addRecordsToDelete("Journey__c", insertedJourneyInfo.fetch('Id'))
        @helper.addLogs("[Result ]   : Journey created successfully\n")
        @helper.addLogs("[Validate ] : Checking Journey owner should be logged in user")
        @helper.addLogs("[Expected ] : Owner of Journey should be owner of lead")
        @helper.addLogs("[Actual ]   : Owner of Journey is #{insertedJourneyInfo.fetch("Owner").fetch("Name")}")
        expect(insertedJourneyInfo.fetch("Owner").fetch("Name")).to eql @userInfo.fetch("display_name")
        @helper.addLogs("[Result ]   : Owner checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Lead source on Journey")
        @helper.addLogs("[Expected ] : Lead source should be Inbound Call")
        @helper.addLogs("[Actual ]   : Journey is created with lead source #{insertedJourneyInfo.fetch("Lead_Source__c")}")
        expect(insertedJourneyInfo.fetch("Lead_Source__c")).to eql "Inbound Call"
        @helper.addLogs("[Result ]   : Lead source checked successfully\n")
        @helper.addLogs("[Validate ] : Checking building interested name on Journey")
        @helper.addLogs("[Expected ] : Building interested should be #{@testDataJSON['Lead'][0]['Building_Interested_In__c']}")
        @helper.addLogs("[Actual ]   : Journey is created with building interested name #{insertedJourneyInfo.fetch("Building_Interested_In__c")}")
        expect(insertedJourneyInfo.fetch("Building_Interested_In__c")).to eql @building
        @helper.addLogs("[Result ]   : Building interested on Journey checked successfully\n")
        @helper.addLogs("[Validate ] : Checking NMD Next Contact Date on Journey")
        @helper.addLogs("[Expected ] : NMD Next Contact Date should be journey creation date")
        @helper.addLogs("[Actual ]   : Journey is created with NMD Next Contact Date #{insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")}")
        #expect(insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")).to eql insertedJourneyInfo[0].fetch("CreatedDate")
        @helper.addLogs("[Result ]   : NMD Next Contact Date on Journey checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Locations Interested on Journey")
        @helper.addLogs("[Expected ] : Locations Interested should be #{@testDataJSON['Lead'][0]['Building_Interested_In__c']}")
        @helper.addLogs("[Actual ]   : Journey is created with Locations Interested #{insertedJourneyInfo.fetch("Locations_Interested__c")}")
        expect(insertedJourneyInfo.fetch('Locations_Interested__c')).to eql @testDataJSON['Lead'][0]["Building_Interested_In__c"]
        @helper.addLogs("[Result ]   : Locations Interested on Journey checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Email on Journey")
        @helper.addLogs("[Expected ] : Email should be #{@testDataJSON['Lead'][0]['Email']}")
        @helper.addLogs("[Actual ]   : Journey is created with Email #{insertedJourneyInfo.fetch("Primary_Email__c")}")
        expect(insertedJourneyInfo.fetch("Primary_Email__c")).to eql @testDataJSON['Lead'][0]['Email']
        @helper.addLogs("[Result ]   : Email on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Phone on Journey")
        @helper.addLogs("[Expected ] : Number of Phone should be #{@testDataJSON['Lead'][0]['Phone']}")
        @helper.addLogs("[Actual ]   : Journey is created with Phone #{insertedJourneyInfo.fetch("Primary_Phone__c")}")
        expect(insertedJourneyInfo.fetch("Primary_Phone__c")).to eql @testDataJSON['Lead'][0]['Phone']
        @helper.addLogs("[Result ]   : Phone on Journey checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Company on Journey")
        @helper.addLogs("[Expected ] : Company should be #{@testDataJSON['Lead'][0]['Company']}")
        @helper.addLogs("[Actual ]   : Journey is created with Company #{insertedJourneyInfo.fetch("Company_Name__c")}")
        expect(insertedJourneyInfo.fetch("Company_Name__c")).to eql @testDataJSON['Lead'][0]['Company']
        @helper.addLogs("[Result ]   : Company on Journey checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Status on Journey")
        @helper.addLogs("[Expected ] : Status should be Started")
        @helper.addLogs("[Actual ]   : Journey is created with Status #{insertedJourneyInfo.fetch("Status__c")}")
        expect(insertedJourneyInfo.fetch("Status__c")).to eql "Started"
        @helper.addLogs("[Result ]   : Status on Journey checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Campaign on Journey")
        @helper.addLogs("[Expected ] : Campaign should be #{@campaignId}")
        @helper.addLogs("[Actual ]   : Journey is created with Campaign #{insertedJourneyInfo.fetch("CampaignId__c")} on it")
        expect(insertedJourneyInfo.fetch("CampaignId__c")).to eql @campaignId
        @helper.addLogs("[Result ]   : Status on Journey checked successfully\n")
        generatedActivityForLead = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Subject , CreatedDate,Status ,Lead_Source__c , Lead_Source_Detail__c,Owner.Name,Locations_Interested__c, Number_of_Full_Time_Employees__c,Interested_in_Number_of_Desks__c,Company__c,WhoId FROM Task WHERE WhoId = '#{leadInfo.fetch('Id')}'")[0]
        @helper.addLogs("[Validate ] : Checking Next Contact Date on existing Journey")
        @helper.addLogs("[Expected ] : Next Contact Date on existing Journey should update with duplicate lead submission date")
        @helper.addLogs("[Actual ]   : Next Contact Date on existing Journey is #{insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")}")
        #expect(existingJourneyInfo.fetch("NMD_Next_Contact_Date__c")).to match generatedActivityForLead.fetch("CreatedDate")
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
        @helper.addLogs("[Validate ] : Checking assigned to on activity")
        @helper.addLogs("[Expected ] : Assigned to on activity should be lead owner")
        @helper.addLogs("[Actual ]   : Assigned to on activity is #{generatedActivityForLead.fetch("Owner").fetch("Name")}")
        expect(generatedActivityForLead.fetch("Owner").fetch("Name")).to eql @userInfo.fetch("display_name")
        @helper.addLogs("[Result ]   : Activity assigned to field checked successfully")
        @helper.addLogs("[Validate ] : Checking status on activity")
        @helper.addLogs("[Expected ] : Status on activity should be Open")
        @helper.addLogs("[Actual ]   : Status on activity is #{generatedActivityForLead.fetch("Status")}")
        expect(generatedActivityForLead.fetch("Status")).to eql "Open"
        @helper.addLogs("[Result ]   : Activity assigned to field checked successfully")
        @helper.addLogs("[Validate ] : Checking status on activity")
        @helper.addLogs("[Expected ] : Status on activity should be Open")
        @helper.addLogs("[Actual ]   : Status on activity is #{generatedActivityForLead.fetch("Status")}")
        expect(generatedActivityForLead.fetch("Company__c")).to eql leadInfo.fetch('Company')
        @helper.addLogs("[Result ]   : Activity Status field checked successfully")
        @helper.addLogs("[Validate ] : Checking Location interested on activity")
        @helper.addLogs("[Expected ] : Location interested on activity should be #{leadInfo.fetch('Locations_Interested__c')}")
        @helper.addLogs("[Actual ]   : Location interested on activity is #{generatedActivityForLead.fetch("Status")}")
        expect(generatedActivityForLead.fetch("Locations_Interested__c")).to eql leadInfo.fetch('Locations_Interested__c')
        @helper.addLogs("[Result ]   : Activity Location interested field checked successfully")
        @helper.addLogs("[Validate ] : Checking Location interested on activity")
        @helper.addLogs("[Expected ] : Number of full time employees on activity should be #{leadInfo.fetch('Number_of_Full_Time_Employees__c')}")
        @helper.addLogs("[Actual ]   : Number of full time employees on activity is #{generatedActivityForLead.fetch("Number_of_Full_Time_Employees__c")}")
        expect(generatedActivityForLead.fetch("Number_of_Full_Time_Employees__c")).to eql leadInfo.fetch('Number_of_Full_Time_Employees__c')
        @helper.addLogs("[Result ]   : Activity Number of full time employees field checked successfully")
        @helper.addLogs("[Validate ] : Checking Number of desks on activity")
        @helper.addLogs("[Expected ] : Checking Number of desks on activity should be #{leadInfo.fetch('Number_of_Full_Time_Employees__c')}")
        @helper.addLogs("[Actual ]   : Checking Number of desks on activity is #{generatedActivityForLead.fetch("Number_of_Full_Time_Employees__c")}")
        expect(generatedActivityForLead.fetch("Interested_in_Number_of_Desks__c")).to eql leadInfo.fetch('Interested_in_Number_of_Desks__c')
        @helper.addLogs("[Result ]   : Activity Number of desks field checked successfully")
        @helper.addLogs('Success')
        @helper.postSuccessResult(2578)
      rescue Exception => e
        @helper.addLogs('Error')
        @helper.postFailResult(e, 2578)
        raise e
      end
    end
    it 'To Check Journey is Created While Importing New Lead From Kickbox When the Generate Journey on UI is Checked and Generate Journey in CSV is False and assign to the particular Campaign based if No Criteria is Matched.', :'2607' => 'true' do
      begin
        leadInfo = @pageObject.upload_csv("john.snow#{rand(9999999999)}_qaauto@example.com", 'TRUE', @testDataJSON['Campaign'][0]['Name'], false, true,"Lead")[0]
        Helper.addRecordsToDelete("Lead", leadInfo.fetch('Id'))
        @helper.addLogs("[Expected ] : Lead should create with name #{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
        @helper.addLogs("[Actual ]   : Lead is created with name #{leadInfo.fetch("Name")}")
        expect(leadInfo).to_not eql nil
        expect(validate_case("Lead", @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0], leadInfo)).to be true
        @helper.addLogs("[Result ]   : Lead insertion checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Lead owner should be Unassigned NMD Us Queue based on Unassigned NMD Us Queue Sales Console Setting")
        @helper.addLogs("[Expected ] : Owner of lead should be nassigned NMD Us Queue")
        @helper.addLogs("[Actual ]   : Owner of lead is #{leadInfo.fetch("Owner").fetch("Name")}")
        expect(leadInfo.fetch("Owner").fetch("Name")).to eql @pageObject.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
        @helper.addLogs("[Result ]   : Owner checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Lead source")
        @helper.addLogs("[Expected ] : Lead source should be Inbound Call")
        @helper.addLogs("[Actual ]   : Lead is created with lead source #{leadInfo.fetch("LeadSource")}")
        expect(leadInfo.fetch("LeadSource")).to eql "Inbound Call"
        @helper.addLogs("[Result ]   : Lead source checked successfully\n")
        @helper.addLogs("[Validate ] : Checking building interested name on Lead")
        @helper.addLogs("[Expected ] : Building interested name should be #{@testDataJSON['Lead'][0]['Building_Interested_In__c']}")
        @helper.addLogs("[Actual ]   : Lead is created with building interested name #{leadInfo.fetch("Building_Interested_Name__c")}")
        expect(leadInfo.fetch("Building_Interested_Name__c")).to eql @testDataJSON['Lead'][0]["Building_Interested_In__c"]
        @helper.addLogs("[Result ]   : Building interested name on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Generate Journey on Lead")
        @helper.addLogs("[Expected ] : Generate Journey should be TRUE")
        @helper.addLogs("[Actual ]   : Lead is created with Generate Journey =  #{leadInfo.fetch("Generate_Journey__c")}")
        expect(leadInfo.fetch("Generate_Journey__c")).to be true
        @helper.addLogs("[Result ]   : Generate Journey on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Locale on Lead")
        @helper.addLogs("[Expected ] : Locale should be en-US")
        @helper.addLogs("[Actual ]   : Lead is created with Locale =  #{leadInfo.fetch("Locale__c")}")
        expect(leadInfo.fetch("Locale__c")).to eql "en-US"
        @helper.addLogs("[Result ]   : Locale on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Country code on Lead")
        @helper.addLogs("[Expected ] : Country code should be IN")
        @helper.addLogs("[Actual ]   : Lead is created with Country code =  #{leadInfo.fetch("Country_Code__c")}")
        expect(leadInfo.fetch("Country_Code__c")).to eql "IN"
        @helper.addLogs("[Result ]   : Country code on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking building interested")
        @helper.addLogs("[Expected ] : Building interested should be #{@testDataJSON['Lead'][0]["Building_Interested_In__c"]}")
        @helper.addLogs("[Actual ]   : Lead is created with building interested #{leadInfo.fetch("Building_Interested_In__c")}")
        expect(leadInfo.fetch("Building_Interested_In__c")).to eql @building
        @helper.addLogs("[Result ]   : Building interested on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Journey created date on lead")
        @helper.addLogs("[Expected ] : Journey created date should be #{leadInfo.fetch("CreatedDate")}")
        @helper.addLogs("[Actual ]   : Lead is created with Journey created date #{leadInfo.fetch("Journey_Created_On__c")}")
        #expect(insertedLeadInfo.fetch("Journey_Created_On__c")).to eql insertedJourneyInfo[0].fetch("CreatedDate")
        @helper.addLogs("[Result ]   : Journey created date on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Locations Interested on lead")
        @helper.addLogs("[Expected ] : Locations Interested should be #{@testDataJSON['Lead'][0]["Building_Interested_In__c"]}")
        @helper.addLogs("[Actual ]   : Lead is created with Locations Interested #{leadInfo.fetch("Locations_Interested__c")}")
        expect(leadInfo.fetch("Locations_Interested__c")).to eql @testDataJSON['Lead'][0]["Building_Interested_In__c"]
        @helper.addLogs("[Result ]   : Locations Interested on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Email on lead")
        @helper.addLogs("[Expected ] : Email should be #{@testDataJSON['Lead'][0]['Email']}")
        @helper.addLogs("[Actual ]   : Lead is created with Email #{leadInfo.fetch("Email")}")
        expect(leadInfo.fetch("Email")).to eql @testDataJSON['Lead'][0]['Email']
        @helper.addLogs("[Result ]   : Email on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Phone on lead")
        @helper.addLogs("[Expected ] : Number of Phone should be #{@testDataJSON['Lead'][0]['Phone']}")
        @helper.addLogs("[Actual ]   : Lead is created with Phone #{leadInfo.fetch("Phone")}")
        expect(leadInfo.fetch("Phone")).to eql @testDataJSON['Lead'][0]['Phone']
        @helper.addLogs("[Result ]   : Phone on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Company on lead")
        @helper.addLogs("[Expected ] : Company should be #{@testDataJSON['Lead'][0]['Company']}")
        @helper.addLogs("[Actual ]   : Lead is created with Company #{leadInfo.fetch("Company")}")
        expect(leadInfo.fetch("Company")).to eql @testDataJSON['Lead'][0]['Company']
        @helper.addLogs("[Result ]   : Company on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Status on lead")
        @helper.addLogs("[Expected ] : Status should be Open")
        @helper.addLogs("[Actual ]   : Lead is created with Status #{leadInfo.fetch("Status")}")
        expect(leadInfo.fetch("Status")).to eql "Open"
        @helper.addLogs("[Result ]   : Status on Lead checked successfully\n")
        insertedJourneyInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,Owner.Name, CreatedDate ,Status__c , NMD_Next_Contact_Date__c ,Primary_Email__c , Lead_Source__c , Lead_Source_Detail__c , Primary_Phone__c , Company_Name__c , Building_Interested_In__c , Locations_Interested__c , Interested_in_Number_of_Desks__c , Full_Time_Employees__c, Name   FROM Journey__c WHERE Primary_Email__c = '#{leadInfo.fetch("Email")}'")[0]
        @helper.addLogs("[Validate ] : Checking Journey is created on lead")
        @helper.addLogs("[Expected ] : Journey should create with name #{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
        @helper.addLogs("[Actual ]   : Journey is created with name #{insertedJourneyInfo.fetch("Name")}")
        expect(insertedJourneyInfo).to_not eql nil
        Helper.addRecordsToDelete("Journey__c", insertedJourneyInfo.fetch('Id'))
        @helper.addLogs("[Result ]   : Journey created successfully\n")
        @helper.addLogs("[Validate ] : Checking Journey owner should be logged in user")
        @helper.addLogs("[Expected ] : Owner of Journey should be owner of lead")
        @helper.addLogs("[Actual ]   : Owner of Journey is #{insertedJourneyInfo.fetch("Owner").fetch("Name")}")
        expect(insertedJourneyInfo.fetch("Owner").fetch("Name")).to eql @userInfo.fetch("display_name")
        @helper.addLogs("[Result ]   : Owner checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Lead source on Journey")
        @helper.addLogs("[Expected ] : Lead source should be Inbound Call")
        @helper.addLogs("[Actual ]   : Journey is created with lead source #{insertedJourneyInfo.fetch("Lead_Source__c")}")
        expect(insertedJourneyInfo.fetch("Lead_Source__c")).to eql "Inbound Call"
        @helper.addLogs("[Result ]   : Lead source checked successfully\n")
        @helper.addLogs("[Validate ] : Checking building interested name on Journey")
        @helper.addLogs("[Expected ] : Building interested should be #{@testDataJSON['Lead'][0]['Building_Interested_In__c']}")
        @helper.addLogs("[Actual ]   : Journey is created with building interested name #{insertedJourneyInfo.fetch("Building_Interested_In__c")}")
        expect(insertedJourneyInfo.fetch("Building_Interested_In__c")).to eql @building
        @helper.addLogs("[Result ]   : Building interested on Journey checked successfully\n")
        @helper.addLogs("[Validate ] : Checking NMD Next Contact Date on Journey")
        @helper.addLogs("[Expected ] : NMD Next Contact Date should be journey creation date")
        @helper.addLogs("[Actual ]   : Journey is created with NMD Next Contact Date #{insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")}")
        #expect(insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")).to eql insertedJourneyInfo[0].fetch("CreatedDate")
        @helper.addLogs("[Result ]   : NMD Next Contact Date on Journey checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Locations Interested on Journey")
        @helper.addLogs("[Expected ] : Locations Interested should be #{@testDataJSON['Lead'][0]['Building_Interested_In__c']}")
        @helper.addLogs("[Actual ]   : Journey is created with Locations Interested #{insertedJourneyInfo.fetch("Locations_Interested__c")}")
        expect(insertedJourneyInfo.fetch('Locations_Interested__c')).to eql @testDataJSON['Lead'][0]["Building_Interested_In__c"]
        @helper.addLogs("[Result ]   : Locations Interested on Journey checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Email on Journey")
        @helper.addLogs("[Expected ] : Email should be #{@testDataJSON['Lead'][0]['Email']}")
        @helper.addLogs("[Actual ]   : Journey is created with Email #{insertedJourneyInfo.fetch("Primary_Email__c")}")
        expect(insertedJourneyInfo.fetch("Primary_Email__c")).to eql @testDataJSON['Lead'][0]['Email']
        @helper.addLogs("[Result ]   : Email on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Phone on Journey")
        @helper.addLogs("[Expected ] : Number of Phone should be #{@testDataJSON['Lead'][0]['Phone']}")
        @helper.addLogs("[Actual ]   : Journey is created with Phone #{insertedJourneyInfo.fetch("Primary_Phone__c")}")
        expect(insertedJourneyInfo.fetch("Primary_Phone__c")).to eql @testDataJSON['Lead'][0]['Phone']
        @helper.addLogs("[Result ]   : Phone on Journey checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Company on Journey")
        @helper.addLogs("[Expected ] : Company should be #{@testDataJSON['Lead'][0]['Company']}")
        @helper.addLogs("[Actual ]   : Journey is created with Company #{insertedJourneyInfo.fetch("Company_Name__c")}")
        expect(insertedJourneyInfo.fetch("Company_Name__c")).to eql @testDataJSON['Lead'][0]['Company']
        @helper.addLogs("[Result ]   : Company on Journey checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Status on Journey")
        @helper.addLogs("[Expected ] : Status should be Started")
        @helper.addLogs("[Actual ]   : Journey is created with Status #{insertedJourneyInfo.fetch("Status__c")}")
        expect(insertedJourneyInfo.fetch("Status__c")).to eql "Started"
        @helper.addLogs("[Result ]   : Status on Journey checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Campaign on Journey")
        @helper.addLogs("[Expected ] : Campaign should be #{@campaignId}")
        @helper.addLogs("[Actual ]   : Journey is created with Campaign #{insertedJourneyInfo.fetch("CampaignId__c")} on it")
        expect(insertedJourneyInfo.fetch("CampaignId__c")).to eql @campaignId
        @helper.addLogs("[Result ]   : Status on Journey checked successfully\n")
        generatedActivityForLead = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Subject , CreatedDate,Status ,Lead_Source__c , Lead_Source_Detail__c,Owner.Name,Locations_Interested__c, Number_of_Full_Time_Employees__c,Interested_in_Number_of_Desks__c,Company__c,WhoId FROM Task WHERE WhoId = '#{leadInfo.fetch('Id')}'")[0]
        @helper.addLogs("[Validate ] : Checking Next Contact Date on existing Journey")
        @helper.addLogs("[Expected ] : Next Contact Date on existing Journey should update with duplicate lead submission date")
        @helper.addLogs("[Actual ]   : Next Contact Date on existing Journey is #{insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")}")
        #expect(existingJourneyInfo.fetch("NMD_Next_Contact_Date__c")).to match generatedActivityForLead.fetch("CreatedDate")
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
        @helper.addLogs("[Validate ] : Checking assigned to on activity")
        @helper.addLogs("[Expected ] : Assigned to on activity should be lead owner")
        @helper.addLogs("[Actual ]   : Assigned to on activity is #{generatedActivityForLead.fetch("Owner").fetch("Name")}")
        expect(generatedActivityForLead.fetch("Owner").fetch("Name")).to eql @userInfo.fetch("display_name")
        @helper.addLogs("[Result ]   : Activity assigned to field checked successfully")
        @helper.addLogs("[Validate ] : Checking status on activity")
        @helper.addLogs("[Expected ] : Status on activity should be Open")
        @helper.addLogs("[Actual ]   : Status on activity is #{generatedActivityForLead.fetch("Status")}")
        expect(generatedActivityForLead.fetch("Status")).to eql "Open"
        @helper.addLogs("[Result ]   : Activity assigned to field checked successfully")
        @helper.addLogs("[Validate ] : Checking status on activity")
        @helper.addLogs("[Expected ] : Status on activity should be Open")
        @helper.addLogs("[Actual ]   : Status on activity is #{generatedActivityForLead.fetch("Status")}")
        expect(generatedActivityForLead.fetch("Company__c")).to eql leadInfo.fetch('Company')
        @helper.addLogs("[Result ]   : Activity Status field checked successfully")
        @helper.addLogs("[Validate ] : Checking Location interested on activity")
        @helper.addLogs("[Expected ] : Location interested on activity should be #{leadInfo.fetch('Locations_Interested__c')}")
        @helper.addLogs("[Actual ]   : Location interested on activity is #{generatedActivityForLead.fetch("Status")}")
        expect(generatedActivityForLead.fetch("Locations_Interested__c")).to eql leadInfo.fetch('Locations_Interested__c')
        @helper.addLogs("[Result ]   : Activity Location interested field checked successfully")
        @helper.addLogs("[Validate ] : Checking Location interested on activity")
        @helper.addLogs("[Expected ] : Number of full time employees on activity should be #{leadInfo.fetch('Number_of_Full_Time_Employees__c')}")
        @helper.addLogs("[Actual ]   : Number of full time employees on activity is #{generatedActivityForLead.fetch("Number_of_Full_Time_Employees__c")}")
        expect(generatedActivityForLead.fetch("Number_of_Full_Time_Employees__c")).to eql leadInfo.fetch('Number_of_Full_Time_Employees__c')
        @helper.addLogs("[Result ]   : Activity Number of full time employees field checked successfully")
        @helper.addLogs("[Validate ] : Checking Number of desks on activity")
        @helper.addLogs("[Expected ] : Checking Number of desks on activity should be #{leadInfo.fetch('Number_of_Full_Time_Employees__c')}")
        @helper.addLogs("[Actual ]   : Checking Number of desks on activity is #{generatedActivityForLead.fetch("Number_of_Full_Time_Employees__c")}")
        expect(generatedActivityForLead.fetch("Interested_in_Number_of_Desks__c")).to eql leadInfo.fetch('Interested_in_Number_of_Desks__c')
        @helper.addLogs("[Result ]   : Activity Number of desks field checked successfully")
        @helper.addLogs('Success')
        @helper.postSuccessResult(2578)
      rescue Exception => e
        @helper.addLogs('Error')
        @helper.postFailResult(e, 2578)
        raise e
      end
    end
    it 'To Check Journey is Not being Created While Importing New Lead from Kickbox when the Generate Journey on UI is Unchecked and Generate Journey in CSV is Blank and assign to the particular Campaign if No criteria is Matched.', :'2606' => 'true' do
      begin
        leadInfo = @pageObject.upload_csv("john.snow#{rand(9999999999)}_qaauto@example.com", 'FALSE', @testDataJSON['Campaign'][0]['Name'], false, true,"Lead")[0]
        Helper.addRecordsToDelete("Lead", leadInfo.fetch('Id'))
        @helper.addLogs("[Expected ] : Lead should create with name #{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
        @helper.addLogs("[Actual ]   : Lead is created with name #{leadInfo.fetch("Name")}")
        expect(leadInfo).to_not eql nil
        expect(validate_case("Lead", @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0], leadInfo)).to be true
        @helper.addLogs("[Result ]   : Lead insertion checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Lead owner should be Unassigned NMD Us Queue based on Unassigned NMD Us Queue Sales Console Setting")
        @helper.addLogs("[Expected ] : Owner of lead should be nassigned NMD Us Queue")
        @helper.addLogs("[Actual ]   : Owner of lead is #{leadInfo.fetch("Owner").fetch("Name")}")
        expect(leadInfo.fetch("Owner").fetch("Name")).to eql @pageObject.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
        @helper.addLogs("[Result ]   : Owner checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Lead source")
        @helper.addLogs("[Expected ] : Lead source should be Inbound Call")
        @helper.addLogs("[Actual ]   : Lead is created with lead source #{leadInfo.fetch("LeadSource")}")
        expect(leadInfo.fetch("LeadSource")).to eql "Inbound Call"
        @helper.addLogs("[Result ]   : Lead source checked successfully\n")
        @helper.addLogs("[Validate ] : Checking building interested name on Lead")
        @helper.addLogs("[Expected ] : Building interested name should be #{@testDataJSON['Lead'][0]['Building_Interested_In__c']}")
        @helper.addLogs("[Actual ]   : Lead is created with building interested name #{leadInfo.fetch("Building_Interested_Name__c")}")
        expect(leadInfo.fetch("Building_Interested_Name__c")).to eql @testDataJSON['Lead'][0]["Building_Interested_In__c"]
        @helper.addLogs("[Result ]   : Building interested name on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Generate Journey on Lead")
        @helper.addLogs("[Expected ] : Generate Journey should be TRUE")
        @helper.addLogs("[Actual ]   : Lead is created with Generate Journey =  #{leadInfo.fetch("Generate_Journey__c")}")
        expect(leadInfo.fetch("Generate_Journey__c")).to be true
        @helper.addLogs("[Result ]   : Generate Journey on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Locale on Lead")
        @helper.addLogs("[Expected ] : Locale should be en-US")
        @helper.addLogs("[Actual ]   : Lead is created with Locale =  #{leadInfo.fetch("Locale__c")}")
        expect(leadInfo.fetch("Locale__c")).to eql "en-US"
        @helper.addLogs("[Result ]   : Locale on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Country code on Lead")
        @helper.addLogs("[Expected ] : Country code should be IN")
        @helper.addLogs("[Actual ]   : Lead is created with Country code =  #{leadInfo.fetch("Country_Code__c")}")
        expect(leadInfo.fetch("Country_Code__c")).to eql "IN"
        @helper.addLogs("[Result ]   : Country code on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking building interested")
        @helper.addLogs("[Expected ] : Building interested should be #{@testDataJSON['Lead'][0]["Building_Interested_In__c"]}")
        @helper.addLogs("[Actual ]   : Lead is created with building interested #{leadInfo.fetch("Building_Interested_In__c")}")
        expect(leadInfo.fetch("Building_Interested_In__c")).to eql @building
        @helper.addLogs("[Result ]   : Building interested on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Journey created date on lead")
        @helper.addLogs("[Expected ] : Journey created date should be #{leadInfo.fetch("CreatedDate")}")
        @helper.addLogs("[Actual ]   : Lead is created with Journey created date #{leadInfo.fetch("Journey_Created_On__c")}")
        #expect(insertedLeadInfo.fetch("Journey_Created_On__c")).to eql insertedJourneyInfo[0].fetch("CreatedDate")
        @helper.addLogs("[Result ]   : Journey created date on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Locations Interested on lead")
        @helper.addLogs("[Expected ] : Locations Interested should be #{@testDataJSON['Lead'][0]["Building_Interested_In__c"]}")
        @helper.addLogs("[Actual ]   : Lead is created with Locations Interested #{leadInfo.fetch("Locations_Interested__c")}")
        expect(leadInfo.fetch("Locations_Interested__c")).to eql @testDataJSON['Lead'][0]["Building_Interested_In__c"]
        @helper.addLogs("[Result ]   : Locations Interested on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Email on lead")
        @helper.addLogs("[Expected ] : Email should be #{@testDataJSON['Lead'][0]['Email']}")
        @helper.addLogs("[Actual ]   : Lead is created with Email #{leadInfo.fetch("Email")}")
        expect(leadInfo.fetch("Email")).to eql @testDataJSON['Lead'][0]['Email']
        @helper.addLogs("[Result ]   : Email on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Phone on lead")
        @helper.addLogs("[Expected ] : Number of Phone should be #{@testDataJSON['Lead'][0]['Phone']}")
        @helper.addLogs("[Actual ]   : Lead is created with Phone #{leadInfo.fetch("Phone")}")
        expect(leadInfo.fetch("Phone")).to eql @testDataJSON['Lead'][0]['Phone']
        @helper.addLogs("[Result ]   : Phone on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Company on lead")
        @helper.addLogs("[Expected ] : Company should be #{@testDataJSON['Lead'][0]['Company']}")
        @helper.addLogs("[Actual ]   : Lead is created with Company #{leadInfo.fetch("Company")}")
        expect(leadInfo.fetch("Company")).to eql @testDataJSON['Lead'][0]['Company']
        @helper.addLogs("[Result ]   : Company on Lead checked successfully\n")
        @helper.addLogs("[Validate ] : Checking Status on lead")
        @helper.addLogs("[Expected ] : Status should be Open")
        @helper.addLogs("[Actual ]   : Lead is created with Status #{leadInfo.fetch("Status")}")
        expect(leadInfo.fetch("Status")).to eql "Open"
        @helper.addLogs("[Result ]   : Status on Lead checked successfully\n")
        insertedJourneyInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id FROM Journey__c WHERE Primary_Email__c = '#{leadInfo.fetch("Email")}'")[0]
        @helper.addLogs("[Validate ] : Checking Journey is created on lead")
        @helper.addLogs("[Expected ] : Journey should not be created")
        @helper.addLogs("[Result ]   : Journey is created #{insertedJourneyInfo.nil? ? 'NO' : 'Yes'}")
        expect(insertedJourneyInfo).to eql nil
        @helper.addLogs("[Result ] : Journey creation checked successfully")
        @helper.addLogs("[Actual ]   : Next Contact Date on existing Journey is #{insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")}")
        generatedActivityForLead = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Subject , CreatedDate,Status ,Lead_Source__c , Lead_Source_Detail__c,Owner.Name,Locations_Interested__c, Number_of_Full_Time_Employees__c,Interested_in_Number_of_Desks__c,Company__c,WhoId FROM Task WHERE WhoId = '#{leadInfo.fetch('Id')}'")[0]
        @helper.addLogs("[Validate ] : Checking Next Contact Date on existing Journey")
        @helper.addLogs("[Expected ] : Next Contact Date on existing Journey should update with duplicate lead submission date")
        @helper.addLogs("[Actual ]   : Next Contact Date on existing Journey is #{insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")}")
        #expect(existingJourneyInfo.fetch("NMD_Next_Contact_Date__c")).to match generatedActivityForLead.fetch("CreatedDate")
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
        @helper.addLogs("[Validate ] : Checking assigned to on activity")
        @helper.addLogs("[Expected ] : Assigned to on activity should be lead owner")
        @helper.addLogs("[Actual ]   : Assigned to on activity is #{generatedActivityForLead.fetch("Owner").fetch("Name")}")
        expect(generatedActivityForLead.fetch("Owner").fetch("Name")).to eql @userInfo.fetch("display_name")
        @helper.addLogs("[Result ]   : Activity assigned to field checked successfully")
        @helper.addLogs("[Validate ] : Checking status on activity")
        @helper.addLogs("[Expected ] : Status on activity should be Open")
        @helper.addLogs("[Actual ]   : Status on activity is #{generatedActivityForLead.fetch("Status")}")
        expect(generatedActivityForLead.fetch("Status")).to eql "Open"
        @helper.addLogs("[Result ]   : Activity assigned to field checked successfully")
        @helper.addLogs("[Validate ] : Checking status on activity")
        @helper.addLogs("[Expected ] : Status on activity should be Open")
        @helper.addLogs("[Actual ]   : Status on activity is #{generatedActivityForLead.fetch("Status")}")
        expect(generatedActivityForLead.fetch("Company__c")).to eql leadInfo.fetch('Company')
        @helper.addLogs("[Result ]   : Activity Status field checked successfully")
        @helper.addLogs("[Validate ] : Checking Location interested on activity")
        @helper.addLogs("[Expected ] : Location interested on activity should be #{leadInfo.fetch('Locations_Interested__c')}")
        @helper.addLogs("[Actual ]   : Location interested on activity is #{generatedActivityForLead.fetch("Status")}")
        expect(generatedActivityForLead.fetch("Locations_Interested__c")).to eql leadInfo.fetch('Locations_Interested__c')
        @helper.addLogs("[Result ]   : Activity Location interested field checked successfully")
        @helper.addLogs("[Validate ] : Checking Location interested on activity")
        @helper.addLogs("[Expected ] : Number of full time employees on activity should be #{leadInfo.fetch('Number_of_Full_Time_Employees__c')}")
        @helper.addLogs("[Actual ]   : Number of full time employees on activity is #{generatedActivityForLead.fetch("Number_of_Full_Time_Employees__c")}")
        expect(generatedActivityForLead.fetch("Number_of_Full_Time_Employees__c")).to eql leadInfo.fetch('Number_of_Full_Time_Employees__c')
        @helper.addLogs("[Result ]   : Activity Number of full time employees field checked successfully")
        @helper.addLogs("[Validate ] : Checking Number of desks on activity")
        @helper.addLogs("[Expected ] : Checking Number of desks on activity should be #{leadInfo.fetch('Number_of_Full_Time_Employees__c')}")
        @helper.addLogs("[Actual ]   : Checking Number of desks on activity is #{generatedActivityForLead.fetch("Number_of_Full_Time_Employees__c")}")
        expect(generatedActivityForLead.fetch("Interested_in_Number_of_Desks__c")).to eql leadInfo.fetch('Interested_in_Number_of_Desks__c')
        @helper.addLogs("[Result ]   : Activity Number of desks field checked successfully")
        @helper.addLogs('Success')
        @helper.postSuccessResult(2578)
      rescue Exception => e
        @helper.addLogs('Error')
        @helper.postFailResult(e, 2578)
        raise e
      end
    end
  end
  def validate_case(object,actual,expected)
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
  end
end
