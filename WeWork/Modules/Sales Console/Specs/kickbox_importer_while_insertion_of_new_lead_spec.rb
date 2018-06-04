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
  it 'To Check New Journey is created While importing lead from Kickbox when the Generate Journey on UI is Unchecked and Generate Journey in CSV file is True.', :'2566' => 'true' do
    begin
      leadInfo = @pageObject.upload_csv("john.snow#{rand(9999999999)}_qaauto@example.com","TRUE",false,true,"Lead")[0]
      Helper.addRecordsToDelete("Lead", leadInfo.fetch('Id'))
      @helper.addLogs("[Expected ] : Lead should create with name #{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
      @helper.addLogs("[Actual ]   : Lead is created with name #{leadInfo.fetch("Name")}")
      expect(leadInfo).to_not eql nil
      expect(@helper.validate_case("Lead",@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0],leadInfo)).to be true
      @helper.addLogs("[Result ]   : Lead insertion checked successfully\n")
      @helper.addLogs("[Validate ] : Checking Lead owner should be logged in user")
      @helper.addLogs("[Expected ] : Owner of lead should be Logged in user")
      @helper.addLogs("[Actual ]   : Owner of lead is #{leadInfo.fetch("Owner").fetch("Name")}")
      expect(leadInfo.fetch("Owner").fetch("Name")).to eql @userInfo.fetch("display_name")
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
      @helper.postSuccessResult(2566)
    rescue Exception => e
      @helper.addLogs('Error')
      @helper.postFailResult(e, 2566)
      raise e
    end
  end
  it 'To Check New Journey is created while importing lead from Kickbox when the Generate Journey on UI is Checked and Generate journey on CSV is Blank.', :'2568' => 'true' do
    begin
      @testDataJSON['Lead'][0]['leadSource'] = "Inbound Call"
      @testDataJSON['Lead'][0]['Email'] = "john.snow#{rand(9999999999)}_qaauto@example.com"
      @testDataJSON['Lead'][0]['lead_Source_Detail__c'] = "Inbound Call Page"
      CSV.open("E:/QA-Automation/leadImporter.csv", "wb") do |csv|
        csv << "First Name,Last Name,Email,Phone,Company,Locale,Lead source,Lead source detail,Country code,Locations interested,Status,Generate Journey".split(',')
        csv << ["#{@testDataJSON['Lead'][0]['FirstName']}","#{@testDataJSON['Lead'][0]['LastName']}","#{@testDataJSON['Lead'][0]['Email']}","#{@testDataJSON['Lead'][0]['Phone']}","#{@testDataJSON['Lead'][0]['Company']}","en-US","#{@testDataJSON['Lead'][0]['leadSource']}","#{@testDataJSON['Lead'][0]['lead_Source_Detail__c']}","IN","#{@testDataJSON['Lead'][0]['Building_Interested_In__c']}","open"]
      end
      arr_of_arrs = CSV.read("E:/QA-Automation/leadImporter.csv")
      puts arr_of_arrs.inspect
      @helper.addLogs("[Step ]     : Browse csv")
      @driver.switch_to.default_content
      @helper.instance_variable_get(:@wait).until {@driver.find_element(:id, "servicedesk").find_elements(:tag_name,"iframe").size > 1}
      EnziUIUtility.switchToFrame(@driver,@driver.find_element(:id, "servicedesk").find_elements(:tag_name,"iframe")[1].attribute("name"))
      @helper.instance_variable_get(:@wait).until {@driver.find_element(:class, "file-browse").displayed?}
      @helper.instance_variable_get(:@wait).until {@driver.find_element(:id, "csvUpload")}
      @driver.find_element(:id, "csvUpload").send_keys "E:/QA-Automation/leadImporter.csv"
      @helper.addLogs("[Result ]   : Csv browsed successfully")
      @helper.instance_variable_get(:@wait).until {!@driver.find_element(:id, "spinnerContainer").displayed?}
      EnziUIUtility.selectElement(@driver,"Upload","button").click
      @helper.addLogs("[Validate ] : Checking Lead creation")
      leadInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , CreatedDate,Owner.Name,	Generate_Journey__c, 	Locale__c, LeadSource,Journey_Created_On__c ,Country_Code__c, Lead_Source_Detail__c , Building_Interested_In__c , Building_Interested_Name__c ,Locations_Interested__c , Number_of_Full_Time_Employees__c , Interested_in_Number_of_Desks__c , Email , Phone , Company , Name , RecordType.Name , Status , Type__c FROM Lead WHERE Email = '#{@testDataJSON['Lead'][0]['Email']}'")
      index = 1
      until !leadInfo[0].nil?
        if index.eql? 5
          break;
        end
        sleep(20)
        leadInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,CreatedDate, Owner.Name,	Generate_Journey__c, 	Locale__c, LeadSource,Journey_Created_On__c ,Country_Code__c, Lead_Source_Detail__c , Building_Interested_In__c , Building_Interested_Name__c ,Locations_Interested__c , Number_of_Full_Time_Employees__c , Interested_in_Number_of_Desks__c , Email , Phone , Company , Name , RecordType.Name , Status , Type__c FROM Lead WHERE Email = '#{@testDataJSON['Lead'][0]['Email']}'")
        puts leadInfo.inspect
        index += 1
      end
      leadInfo = leadInfo[0]
      @helper.addLogs("[Expected ] : Lead should create with name #{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
      @helper.addLogs("[Actual ]   : Lead is created with name #{leadInfo.fetch("Name")}")
      expect(leadInfo).to_not eql nil
      Helper.addRecordsToDelete("Lead", leadInfo.fetch('Id'))
      @helper.addLogs("[Result ]   : Lead insertion checked successfully\n")
      @helper.addLogs("[Validate ] : Checking Lead owner should be logged in user")
      @helper.addLogs("[Expected ] : Owner of lead should be Logged in user")
      @helper.addLogs("[Actual ]   : Owner of lead is #{leadInfo.fetch("Owner").fetch("Name")}")
      expect(leadInfo.fetch("Owner").fetch("Name")).to eql @userInfo.fetch("display_name")
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
      expect(leadInfo.fetch("Building_Interested_In__c")).to eql @helper.instance_variable_get(:@restForce).getRecords("SELECT id FROM Building__c WHERE Name = '#{@testDataJSON['Lead'][0]["Building_Interested_In__c"]}'")[0].fetch("Id")
      @helper.addLogs("[Result ]   : Building interested on Lead checked successfully\n")
      @helper.addLogs("[Validate ] : Checking Journey created date on lead")
      @helper.addLogs("[Expected ] : Journey created date should be #{leadInfo.fetch("CreatedDate")}")
      @helper.addLogs("[Actual ]   : Lead is created with Journey created date #{leadInfo.fetch("Journey_Created_On__c")}")
      #expect(insertedLeadInfo.fetch("Journey_Created_On__c")).to eql insertedJourneyInfo[0].fetch("CreatedDate")
      @helper.addLogs("[Result ]   : Journey created date on Lead checked successfully\n")
      @helper.addLogs("[Validate ] : Checking Interested in Number of Desks on lead")
      @helper.addLogs("[Expected ] : Interested in Number of Desks should be #{@testDataJSON['Lead'][0]['NumberofDesks']}.0")
      @helper.addLogs("[Actual ]   : Lead is created with Interested in Number of Desks #{leadInfo.fetch("Interested_in_Number_of_Desks__c")}")
      expect("#{leadInfo.fetch('Interested_in_Number_of_Desks__c')}").to eql "#{@testDataJSON['Lead'][0]['NumberofDesks']}.0"
      @helper.addLogs("[Result ]   : Interested in Number of Desks on Lead checked successfully\n")
      @helper.addLogs("[Validate ] : Checking Locations Interested on lead")
      @helper.addLogs("[Expected ] : Locations Interested should be #{@testDataJSON['Lead'][0]["Building_Interested_In__c"]}")
      @helper.addLogs("[Actual ]   : Lead is created with Locations Interested #{leadInfo.fetch("Locations_Interested__c")}")
      expect(leadInfo.fetch("Locations_Interested__c")).to eql @testDataJSON['Lead'][0]["Building_Interested_In__c"]
      @helper.addLogs("[Result ]   : Locations Interested on Lead checked successfully\n")
      @helper.addLogs("[Validate ] : Checking Number of Full Time Employees on lead")
      @helper.addLogs("[Expected ] : Number of Full Time Employees should be #{@testDataJSON['Lead'][0]['CompanySize']}.0")
      @helper.addLogs("[Actual ]   : Lead is created with Number of Full Time Employees #{leadInfo.fetch("Number_of_Full_Time_Employees__c")}")
      expect("#{leadInfo.fetch('Number_of_Full_Time_Employees__c')}").to eql "#{@testDataJSON['Lead'][0]['CompanySize']}.0"
      @helper.addLogs("[Result ]   : Number of Full Time Employees on Lead checked successfully\n")
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
      @helper.addLogs("[Validate ] : Checking RecordType on lead")
      @helper.addLogs("[Expected ] : RecordType should be Consumer")
      @helper.addLogs("[Actual ]   : Lead is created with RecordType #{leadInfo.fetch("RecordType").fetch("Name")}")
      expect(leadInfo.fetch("RecordType").fetch("Name")).to eql "Consumer"
      @helper.addLogs("[Result ]   : RecordType on Lead checked successfully\n")
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
      expect(insertedJourneyInfo.fetch("Name")).to eql "#{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}"
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
      expect(insertedJourneyInfo.fetch("Building_Interested_In__c")).to eql @helper.instance_variable_get(:@restForce).getRecords("SELECT id FROM Building__c WHERE Name = '#{@testDataJSON['Lead'][0]["Building_Interested_In__c"]}'")[0].fetch("id")
      @helper.addLogs("[Result ]   : Building interested on Journey checked successfully\n")
      @helper.addLogs("[Validate ] : Checking NMD Next Contact Date on Journey")
      @helper.addLogs("[Expected ] : NMD Next Contact Date should be journey creation date")
      @helper.addLogs("[Actual ]   : Journey is created with NMD Next Contact Date #{insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")}")
      #expect(insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")).to eql insertedJourneyInfo[0].fetch("CreatedDate")
      @helper.addLogs("[Result ]   : NMD Next Contact Date on Journey checked successfully\n")
      @helper.addLogs("[Validate ] : Checking Interested in Number of Desks on Journey")
      @helper.addLogs("[Expected ] : Interested in Number of Desks should be #{@testDataJSON['Lead'][0]['NumberofDesks']}.0")
      @helper.addLogs("[Actual ]   : Journey is created with Interested in Number of Desks #{insertedJourneyInfo.fetch("Interested_in_Number_of_Desks__c")}")
      expect("#{insertedJourneyInfo.fetch('Interested_in_Number_of_Desks__c')}").to eql "#{@testDataJSON['Lead'][0]['NumberofDesks']}.0"
      @helper.addLogs("[Result ]   : Interested in Number of Desks on Journey checked successfully\n")
      @helper.addLogs("[Validate ] : Checking Locations Interested on Journey")
      @helper.addLogs("[Expected ] : Locations Interested should be #{@testDataJSON['Lead'][0]['NumberofDesks']}.0")
      @helper.addLogs("[Actual ]   : Journey is created with Locations Interested #{insertedJourneyInfo.fetch("Locations_Interested__c")}")
      expect(insertedJourneyInfo.fetch('Locations_Interested__c')).to eql @testDataJSON['Lead'][0]["Building_Interested_In__c"]
      @helper.addLogs("[Result ]   : Locations Interested on Journey checked successfully\n")
      @helper.addLogs("[Validate ] : Checking Number of Full Time Employees on Journey")
      @helper.addLogs("[Expected ] : Number of Full Time Employees should be #{@testDataJSON['Lead'][0]['CompanySize']}.0")
      @helper.addLogs("[Actual ]   : Journey is created with Number of Full Time Employees #{insertedJourneyInfo.fetch("Full_Time_Employees__c")}")
      expect("#{insertedJourneyInfo.fetch('Full_Time_Employees__c')}").to eql "#{@testDataJSON['Lead'][0]['CompanySize']}.0"
      @helper.addLogs("[Result ]   : Number of Full Time Employees on Journey checked successfully\n")
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
      @helper.postSuccessResult(2568)
    rescue Exception => e
      @helper.addLogs('Error')
      @helper.postFailResult(e, 2568)
      raise e
    end
  end
  it 'To Check New Journey is Created while importing lead from Kickbox when the Generate Journey on UI is Checked and Generate Journey in CSV is false.', :'2569' => 'true' do
    begin
      @testDataJSON['Lead'][0]['leadSource'] = "Inbound Call"
      @testDataJSON['Lead'][0]['Email'] = "john.snow#{rand(9999999999)}_qaauto@example.com"
      @testDataJSON['Lead'][0]['lead_Source_Detail__c'] = "Inbound Call Page"
      CSV.open("E:/QA-Automation/leadImporter.csv", "wb") do |csv|
        csv << "First Name,Last Name,Email,Phone,Company,Locale,Lead source,Lead source detail,Country code,Locations interested,Status,Generate Journey".split(',')
        csv << ["#{@testDataJSON['Lead'][0]['FirstName']}","#{@testDataJSON['Lead'][0]['LastName']}","#{@testDataJSON['Lead'][0]['Email']}","#{@testDataJSON['Lead'][0]['Phone']}","#{@testDataJSON['Lead'][0]['Company']}","en-US","#{@testDataJSON['Lead'][0]['leadSource']}","#{@testDataJSON['Lead'][0]['lead_Source_Detail__c']}","IN","#{@testDataJSON['Lead'][0]['Building_Interested_In__c']}","open","FALSE"]
      end
      arr_of_arrs = CSV.read("E:/QA-Automation/leadImporter.csv")
      puts arr_of_arrs.inspect
      @helper.addLogs("[Step ]     : Browse csv")
      @driver.switch_to.default_content
      @helper.instance_variable_get(:@wait).until {@driver.find_element(:id, "servicedesk").find_elements(:tag_name,"iframe").size > 1}
      EnziUIUtility.switchToFrame(@driver,@driver.find_element(:id, "servicedesk").find_elements(:tag_name,"iframe")[1].attribute("name"))
      @helper.instance_variable_get(:@wait).until {@driver.find_element(:class, "file-browse").displayed?}
      @helper.instance_variable_get(:@wait).until {@driver.find_element(:id, "csvUpload")}
      @driver.find_element(:id, "csvUpload").send_keys "E:/QA-Automation/leadImporter.csv"
      @helper.addLogs("[Result ]   : Csv browsed successfully")
      @helper.instance_variable_get(:@wait).until {!@driver.find_element(:id, "spinnerContainer").displayed?}
      EnziUIUtility.selectElement(@driver,"Upload","button").click
      @helper.addLogs("[Validate ] : Checking Lead creation")
      leadInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,CreatedDate, Owner.Name,	Generate_Journey__c, 	Locale__c, LeadSource,Journey_Created_On__c ,Country_Code__c, Lead_Source_Detail__c , Building_Interested_In__c , Building_Interested_Name__c ,Locations_Interested__c , Number_of_Full_Time_Employees__c , Interested_in_Number_of_Desks__c , Email , Phone , Company , Name , RecordType.Name , Status , Type__c FROM Lead WHERE Email = '#{@testDataJSON['Lead'][0]['Email']}'")
      index = 1
      until !leadInfo[0].nil?
        if index.eql? 5
          break;
        end
        sleep(20)
        leadInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,CreatedDate, Owner.Name,	Generate_Journey__c, 	Locale__c, LeadSource,Journey_Created_On__c ,Country_Code__c, Lead_Source_Detail__c , Building_Interested_In__c , Building_Interested_Name__c ,Locations_Interested__c , Number_of_Full_Time_Employees__c , Interested_in_Number_of_Desks__c , Email , Phone , Company , Name , RecordType.Name , Status , Type__c FROM Lead WHERE Email = '#{@testDataJSON['Lead'][0]['Email']}'")
        puts leadInfo.inspect
        index += 1
      end
      leadInfo = leadInfo[0]
      @helper.addLogs("[Expected ] : Lead should create with name #{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
      @helper.addLogs("[Actual ]   : Lead is created with name #{leadInfo.fetch("Name")}")
      expect(leadInfo).to_not eql nil
      Helper.addRecordsToDelete("Lead", leadInfo.fetch('Id'))
      @helper.addLogs("[Result ]   : Lead insertion checked successfully\n")
      @helper.addLogs("[Validate ] : Checking Lead owner should be logged in user")
      @helper.addLogs("[Expected ] : Owner of lead should be Logged in user")
      @helper.addLogs("[Actual ]   : Owner of lead is #{leadInfo.fetch("Owner").fetch("Name")}")
      expect(leadInfo.fetch("Owner").fetch("Name")).to eql @userInfo.fetch("display_name")
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
      expect(leadInfo.fetch("Building_Interested_In__c")).to eql @helper.instance_variable_get(:@restForce).getRecords("SELECT id FROM Building__c WHERE Name = '#{@testDataJSON['Lead'][0]["Building_Interested_In__c"]}'")[0].fetch("Id")
      @helper.addLogs("[Result ]   : Building interested on Lead checked successfully\n")
      @helper.addLogs("[Validate ] : Checking Journey created date on lead")
      @helper.addLogs("[Expected ] : Journey created date should be #{leadInfo.fetch("CreatedDate")}")
      @helper.addLogs("[Actual ]   : Lead is created with Journey created date #{leadInfo.fetch("Journey_Created_On__c")}")
      #expect(insertedLeadInfo.fetch("Journey_Created_On__c")).to eql insertedJourneyInfo[0].fetch("CreatedDate")
      @helper.addLogs("[Result ]   : Journey created date on Lead checked successfully\n")
      @helper.addLogs("[Validate ] : Checking Interested in Number of Desks on lead")
      @helper.addLogs("[Expected ] : Interested in Number of Desks should be #{@testDataJSON['Lead'][0]['NumberofDesks']}.0")
      @helper.addLogs("[Actual ]   : Lead is created with Interested in Number of Desks #{leadInfo.fetch("Interested_in_Number_of_Desks__c")}")
      expect("#{leadInfo.fetch('Interested_in_Number_of_Desks__c')}").to eql "#{@testDataJSON['Lead'][0]['NumberofDesks']}.0"
      @helper.addLogs("[Result ]   : Interested in Number of Desks on Lead checked successfully\n")
      @helper.addLogs("[Validate ] : Checking Locations Interested on lead")
      @helper.addLogs("[Expected ] : Locations Interested should be #{@testDataJSON['Lead'][0]["Building_Interested_In__c"]}")
      @helper.addLogs("[Actual ]   : Lead is created with Locations Interested #{leadInfo.fetch("Locations_Interested__c")}")
      expect(leadInfo.fetch("Locations_Interested__c")).to eql @testDataJSON['Lead'][0]["Building_Interested_In__c"]
      @helper.addLogs("[Result ]   : Locations Interested on Lead checked successfully\n")
      @helper.addLogs("[Validate ] : Checking Number of Full Time Employees on lead")
      @helper.addLogs("[Expected ] : Number of Full Time Employees should be #{@testDataJSON['Lead'][0]['CompanySize']}.0")
      @helper.addLogs("[Actual ]   : Lead is created with Number of Full Time Employees #{leadInfo.fetch("Number_of_Full_Time_Employees__c")}")
      expect("#{leadInfo.fetch('Number_of_Full_Time_Employees__c')}").to eql "#{@testDataJSON['Lead'][0]['CompanySize']}.0"
      @helper.addLogs("[Result ]   : Number of Full Time Employees on Lead checked successfully\n")
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
      @helper.addLogs("[Validate ] : Checking RecordType on lead")
      @helper.addLogs("[Expected ] : RecordType should be Consumer")
      @helper.addLogs("[Actual ]   : Lead is created with RecordType #{leadInfo.fetch("RecordType").fetch("Name")}")
      expect(leadInfo.fetch("RecordType").fetch("Name")).to eql "Consumer"
      @helper.addLogs("[Result ]   : RecordType on Lead checked successfully\n")
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
      expect(insertedJourneyInfo.fetch("Name")).to eql "#{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}"
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
      expect(insertedJourneyInfo.fetch("Building_Interested_In__c")).to eql @helper.instance_variable_get(:@restForce).getRecords("SELECT id FROM Building__c WHERE Name = '#{@testDataJSON['Lead'][0]["Building_Interested_In__c"]}'")[0].fetch("id")
      @helper.addLogs("[Result ]   : Building interested on Journey checked successfully\n")
      @helper.addLogs("[Validate ] : Checking NMD Next Contact Date on Journey")
      @helper.addLogs("[Expected ] : NMD Next Contact Date should be journey creation date")
      @helper.addLogs("[Actual ]   : Journey is created with NMD Next Contact Date #{insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")}")
      #expect(insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")).to eql insertedJourneyInfo[0].fetch("CreatedDate")
      @helper.addLogs("[Result ]   : NMD Next Contact Date on Journey checked successfully\n")
      @helper.addLogs("[Validate ] : Checking Interested in Number of Desks on Journey")
      @helper.addLogs("[Expected ] : Interested in Number of Desks should be #{@testDataJSON['Lead'][0]['NumberofDesks']}.0")
      @helper.addLogs("[Actual ]   : Journey is created with Interested in Number of Desks #{insertedJourneyInfo.fetch("Interested_in_Number_of_Desks__c")}")
      expect("#{insertedJourneyInfo.fetch('Interested_in_Number_of_Desks__c')}").to eql "#{@testDataJSON['Lead'][0]['NumberofDesks']}.0"
      @helper.addLogs("[Result ]   : Interested in Number of Desks on Journey checked successfully\n")
      @helper.addLogs("[Validate ] : Checking Locations Interested on Journey")
      @helper.addLogs("[Expected ] : Locations Interested should be #{@testDataJSON['Lead'][0]['NumberofDesks']}.0")
      @helper.addLogs("[Actual ]   : Journey is created with Locations Interested #{insertedJourneyInfo.fetch("Locations_Interested__c")}")
      expect(insertedJourneyInfo.fetch('Locations_Interested__c')).to eql @testDataJSON['Lead'][0]["Building_Interested_In__c"]
      @helper.addLogs("[Result ]   : Locations Interested on Journey checked successfully\n")
      @helper.addLogs("[Validate ] : Checking Number of Full Time Employees on Journey")
      @helper.addLogs("[Expected ] : Number of Full Time Employees should be #{@testDataJSON['Lead'][0]['CompanySize']}.0")
      @helper.addLogs("[Actual ]   : Journey is created with Number of Full Time Employees #{insertedJourneyInfo.fetch("Full_Time_Employees__c")}")
      expect("#{insertedJourneyInfo.fetch('Full_Time_Employees__c')}").to eql "#{@testDataJSON['Lead'][0]['CompanySize']}.0"
      @helper.addLogs("[Result ]   : Number of Full Time Employees on Journey checked successfully\n")
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
      @helper.postSuccessResult(2569)
    rescue Exception => e
      @helper.addLogs('Error')
      @helper.postFailResult(e, 2569)
      raise e
    end
  end
  it 'To Check New Journey is Created while importing Lead from Kickbox when the Generate Journey on UI is Checked and Generate Journey in CSV is True.', :'2571' => 'true' do
    begin
      @testDataJSON['Lead'][0]['leadSource'] = "Inbound Call"
      @testDataJSON['Lead'][0]['Email'] = "john.snow#{rand(9999999999)}_qaauto@example.com"
      @testDataJSON['Lead'][0]['lead_Source_Detail__c'] = "Inbound Call Page"
      CSV.open("E:/QA-Automation/leadImporter.csv", "wb") do |csv|
        csv << "First Name,Last Name,Email,Phone,Company,Locale,Lead source,Lead source detail,Country code,Locations interested,Status,Generate Journey".split(',')
        csv << ["#{@testDataJSON['Lead'][0]['FirstName']}","#{@testDataJSON['Lead'][0]['LastName']}","#{@testDataJSON['Lead'][0]['Email']}","#{@testDataJSON['Lead'][0]['Phone']}","#{@testDataJSON['Lead'][0]['Company']}","en-US","#{@testDataJSON['Lead'][0]['leadSource']}","#{@testDataJSON['Lead'][0]['lead_Source_Detail__c']}","IN","#{@testDataJSON['Lead'][0]['Building_Interested_In__c']}","open",'TRUE']
      end
      arr_of_arrs = CSV.read("E:/QA-Automation/leadImporter.csv")
      puts arr_of_arrs.inspect
      @helper.addLogs("[Step ]     : Browse csv")
      @driver.switch_to.default_content
      @helper.instance_variable_get(:@wait).until {@driver.find_element(:id, "servicedesk").find_elements(:tag_name,"iframe").size > 1}
      EnziUIUtility.switchToFrame(@driver,@driver.find_element(:id, "servicedesk").find_elements(:tag_name,"iframe")[1].attribute("name"))
      @helper.instance_variable_get(:@wait).until {@driver.find_element(:class, "file-browse").displayed?}
      @helper.instance_variable_get(:@wait).until {@driver.find_element(:id, "csvUpload")}
      @driver.find_element(:id, "csvUpload").send_keys "E:/QA-Automation/leadImporter.csv"
      @helper.addLogs("[Result ]   : Csv browsed successfully")
      @helper.instance_variable_get(:@wait).until {!@driver.find_element(:id, "spinnerContainer").displayed?}
      @driver.find_element(:id, "checkbox-308").find_element(:xpath,"..").click
      EnziUIUtility.selectElement(@driver,"Upload","button").click
      @helper.addLogs("[Validate ] : Checking Lead creation")
      leadInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,CreatedDate, Owner.Name,	Generate_Journey__c, 	Locale__c, LeadSource,Journey_Created_On__c ,Country_Code__c, Lead_Source_Detail__c , Building_Interested_In__c , Building_Interested_Name__c ,Locations_Interested__c , Number_of_Full_Time_Employees__c , Interested_in_Number_of_Desks__c , Email , Phone , Company , Name , RecordType.Name , Status , Type__c FROM Lead WHERE Email = '#{@testDataJSON['Lead'][0]['Email']}'")
      index = 1
      until !leadInfo[0].nil?
        if index.eql? 5
          break;
        end
        sleep(20)
        leadInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,CreatedDate, Owner.Name,	Generate_Journey__c, 	Locale__c, LeadSource,Journey_Created_On__c ,Country_Code__c, Lead_Source_Detail__c , Building_Interested_In__c , Building_Interested_Name__c ,Locations_Interested__c , Number_of_Full_Time_Employees__c , Interested_in_Number_of_Desks__c , Email , Phone , Company , Name , RecordType.Name , Status , Type__c FROM Lead WHERE Email = '#{@testDataJSON['Lead'][0]['Email']}'")
        puts leadInfo.inspect
        index += 1
      end
      leadInfo = leadInfo[0]
      @helper.addLogs("[Expected ] : Lead should create with name #{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
      @helper.addLogs("[Actual ]   : Lead is created with name #{leadInfo.fetch("Name")}")
      expect(leadInfo).to_not eql nil
      Helper.addRecordsToDelete("Lead", leadInfo.fetch('Id'))
      @helper.addLogs("[Result ]   : Lead insertion checked successfully\n")
      @helper.addLogs("[Validate ] : Checking Lead owner should be logged in user")
      @helper.addLogs("[Expected ] : Owner of lead should be Logged in user")
      @helper.addLogs("[Actual ]   : Owner of lead is #{leadInfo.fetch("Owner").fetch("Name")}")
      expect(leadInfo.fetch("Owner").fetch("Name")).to eql @userInfo.fetch("display_name")
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
      expect(leadInfo.fetch("Building_Interested_In__c")).to eql @helper.instance_variable_get(:@restForce).getRecords("SELECT id FROM Building__c WHERE Name = '#{@testDataJSON['Lead'][0]["Building_Interested_In__c"]}'")[0].fetch("Id")
      @helper.addLogs("[Result ]   : Building interested on Lead checked successfully\n")
      @helper.addLogs("[Validate ] : Checking Journey created date on lead")
      @helper.addLogs("[Expected ] : Journey created date should be #{leadInfo.fetch("CreatedDate")}")
      @helper.addLogs("[Actual ]   : Lead is created with Journey created date #{leadInfo.fetch("Journey_Created_On__c")}")
      #expect(insertedLeadInfo.fetch("Journey_Created_On__c")).to eql insertedJourneyInfo[0].fetch("CreatedDate")
      @helper.addLogs("[Result ]   : Journey created date on Lead checked successfully\n")
      @helper.addLogs("[Validate ] : Checking Interested in Number of Desks on lead")
      @helper.addLogs("[Expected ] : Interested in Number of Desks should be #{@testDataJSON['Lead'][0]['NumberofDesks']}.0")
      @helper.addLogs("[Actual ]   : Lead is created with Interested in Number of Desks #{leadInfo.fetch("Interested_in_Number_of_Desks__c")}")
      expect("#{leadInfo.fetch('Interested_in_Number_of_Desks__c')}").to eql "#{@testDataJSON['Lead'][0]['NumberofDesks']}.0"
      @helper.addLogs("[Result ]   : Interested in Number of Desks on Lead checked successfully\n")
      @helper.addLogs("[Validate ] : Checking Locations Interested on lead")
      @helper.addLogs("[Expected ] : Locations Interested should be #{@testDataJSON['Lead'][0]["Building_Interested_In__c"]}")
      @helper.addLogs("[Actual ]   : Lead is created with Locations Interested #{leadInfo.fetch("Locations_Interested__c")}")
      expect(leadInfo.fetch("Locations_Interested__c")).to eql @testDataJSON['Lead'][0]["Building_Interested_In__c"]
      @helper.addLogs("[Result ]   : Locations Interested on Lead checked successfully\n")
      @helper.addLogs("[Validate ] : Checking Number of Full Time Employees on lead")
      @helper.addLogs("[Expected ] : Number of Full Time Employees should be #{@testDataJSON['Lead'][0]['CompanySize']}.0")
      @helper.addLogs("[Actual ]   : Lead is created with Number of Full Time Employees #{leadInfo.fetch("Number_of_Full_Time_Employees__c")}")
      expect("#{leadInfo.fetch('Number_of_Full_Time_Employees__c')}").to eql "#{@testDataJSON['Lead'][0]['CompanySize']}.0"
      @helper.addLogs("[Result ]   : Number of Full Time Employees on Lead checked successfully\n")
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
      @helper.addLogs("[Validate ] : Checking RecordType on lead")
      @helper.addLogs("[Expected ] : RecordType should be Consumer")
      @helper.addLogs("[Actual ]   : Lead is created with RecordType #{leadInfo.fetch("RecordType").fetch("Name")}")
      expect(leadInfo.fetch("RecordType").fetch("Name")).to eql "Consumer"
      @helper.addLogs("[Result ]   : RecordType on Lead checked successfully\n")
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
      expect(insertedJourneyInfo.fetch("Name")).to eql "#{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}"
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
      expect(insertedJourneyInfo.fetch("Building_Interested_In__c")).to eql @helper.instance_variable_get(:@restForce).getRecords("SELECT id FROM Building__c WHERE Name = '#{@testDataJSON['Lead'][0]["Building_Interested_In__c"]}'")[0].fetch("id")
      @helper.addLogs("[Result ]   : Building interested on Journey checked successfully\n")
      @helper.addLogs("[Validate ] : Checking NMD Next Contact Date on Journey")
      @helper.addLogs("[Expected ] : NMD Next Contact Date should be journey creation date")
      @helper.addLogs("[Actual ]   : Journey is created with NMD Next Contact Date #{insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")}")
      #expect(insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")).to eql insertedJourneyInfo[0].fetch("CreatedDate")
      @helper.addLogs("[Result ]   : NMD Next Contact Date on Journey checked successfully\n")
      @helper.addLogs("[Validate ] : Checking Interested in Number of Desks on Journey")
      @helper.addLogs("[Expected ] : Interested in Number of Desks should be #{@testDataJSON['Lead'][0]['NumberofDesks']}.0")
      @helper.addLogs("[Actual ]   : Journey is created with Interested in Number of Desks #{insertedJourneyInfo.fetch("Interested_in_Number_of_Desks__c")}")
      expect("#{insertedJourneyInfo.fetch('Interested_in_Number_of_Desks__c')}").to eql "#{@testDataJSON['Lead'][0]['NumberofDesks']}.0"
      @helper.addLogs("[Result ]   : Interested in Number of Desks on Journey checked successfully\n")
      @helper.addLogs("[Validate ] : Checking Locations Interested on Journey")
      @helper.addLogs("[Expected ] : Locations Interested should be #{@testDataJSON['Lead'][0]['NumberofDesks']}.0")
      @helper.addLogs("[Actual ]   : Journey is created with Locations Interested #{insertedJourneyInfo.fetch("Locations_Interested__c")}")
      expect(insertedJourneyInfo.fetch('Locations_Interested__c')).to eql @testDataJSON['Lead'][0]["Building_Interested_In__c"]
      @helper.addLogs("[Result ]   : Locations Interested on Journey checked successfully\n")
      @helper.addLogs("[Validate ] : Checking Number of Full Time Employees on Journey")
      @helper.addLogs("[Expected ] : Number of Full Time Employees should be #{@testDataJSON['Lead'][0]['CompanySize']}.0")
      @helper.addLogs("[Actual ]   : Journey is created with Number of Full Time Employees #{insertedJourneyInfo.fetch("Full_Time_Employees__c")}")
      expect("#{insertedJourneyInfo.fetch('Full_Time_Employees__c')}").to eql "#{@testDataJSON['Lead'][0]['CompanySize']}.0"
      @helper.addLogs("[Result ]   : Number of Full Time Employees on Journey checked successfully\n")
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
      @helper.postSuccessResult(2571)
    rescue Exception => e
      @helper.addLogs('Error')
      @helper.postFailResult(e, 2571)
      raise e
    end
  end
  it "To Check Journey Not being Created While Importing lead from Kickbox when the Generate Journey on UI is Unchecked and Generate Journey in CSV is false.",:'2567'=>'true' do
    begin
      @testDataJSON['Lead'][0]['leadSource'] = "Inbound Call"
      @testDataJSON['Lead'][0]['Email'] = "john.snow#{rand(9999999999)}_qaauto@example.com"
      @testDataJSON['Lead'][0]['lead_Source_Detail__c'] = "Inbound Call Page"
      CSV.open("E:/QA-Automation/leadImporter.csv", "wb") do |csv|
        csv << "First Name,Last Name,Email,Phone,Company,Locale,Lead source,Lead source detail,Country code,Locations interested,Status,Generate Journey".split(',')
        csv << ["#{@testDataJSON['Lead'][0]['FirstName']}","#{@testDataJSON['Lead'][0]['LastName']}","#{@testDataJSON['Lead'][0]['Email']}","#{@testDataJSON['Lead'][0]['Phone']}","#{@testDataJSON['Lead'][0]['Company']}","en-US","#{@testDataJSON['Lead'][0]['leadSource']}","#{@testDataJSON['Lead'][0]['lead_Source_Detail__c']}","IN","#{@testDataJSON['Lead'][0]['Building_Interested_In__c']}","open",'TRUE']
      end
      arr_of_arrs = CSV.read("E:/QA-Automation/leadImporter.csv")
      puts arr_of_arrs.inspect
      @helper.addLogs("[Step ]     : Browse csv")
      @driver.switch_to.default_content
      @helper.instance_variable_get(:@wait).until {@driver.find_element(:id, "servicedesk").find_elements(:tag_name,"iframe").size > 1}
      EnziUIUtility.switchToFrame(@driver,@driver.find_element(:id, "servicedesk").find_elements(:tag_name,"iframe")[1].attribute("name"))
      @helper.instance_variable_get(:@wait).until {@driver.find_element(:class, "file-browse").displayed?}
      @helper.instance_variable_get(:@wait).until {@driver.find_element(:id, "csvUpload")}
      @driver.find_element(:id, "csvUpload").send_keys "E:/QA-Automation/leadImporter.csv"
      @helper.addLogs("[Result ]   : Csv browsed successfully")
      @helper.instance_variable_get(:@wait).until {!@driver.find_element(:id, "spinnerContainer").displayed?}
      @driver.find_element(:id, "checkbox-308").find_element(:xpath,"..").click
      EnziUIUtility.selectElement(@driver,"Upload","button").click
      @helper.addLogs("[Validate ] : Checking Lead creation")
      leadInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,CreatedDate, Owner.Name,	Generate_Journey__c, 	Locale__c, LeadSource,Journey_Created_On__c ,Country_Code__c, Lead_Source_Detail__c , Building_Interested_In__c , Building_Interested_Name__c ,Locations_Interested__c , Number_of_Full_Time_Employees__c , Interested_in_Number_of_Desks__c , Email , Phone , Company , Name , RecordType.Name , Status , Type__c FROM Lead WHERE Email = '#{@testDataJSON['Lead'][0]['Email']}'")
      index = 1
      until !leadInfo[0].nil?
        if index.eql? 5
          break;
        end
        sleep(20)
        leadInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,CreatedDate, Owner.Name,	Generate_Journey__c, 	Locale__c, LeadSource,Journey_Created_On__c ,Country_Code__c, Lead_Source_Detail__c , Building_Interested_In__c , Building_Interested_Name__c ,Locations_Interested__c , Number_of_Full_Time_Employees__c , Interested_in_Number_of_Desks__c , Email , Phone , Company , Name , RecordType.Name , Status , Type__c FROM Lead WHERE Email = '#{@testDataJSON['Lead'][0]['Email']}'")
        puts leadInfo.inspect
        index += 1
      end
      leadInfo = leadInfo[0]
      @helper.addLogs("[Expected ] : Lead should create with name #{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
      @helper.addLogs("[Actual ]   : Lead is created with name #{leadInfo.fetch("Name")}")
      expect(leadInfo).to_not eql nil
      Helper.addRecordsToDelete("Lead", leadInfo.fetch('Id'))
      @helper.addLogs("[Result ]   : Lead insertion checked successfully\n")
      @helper.addLogs("[Validate ] : Checking Lead owner should be logged in user")
      @helper.addLogs("[Expected ] : Owner of lead should be Logged in user")
      @helper.addLogs("[Actual ]   : Owner of lead is #{leadInfo.fetch("Owner").fetch("Name")}")
      expect(leadInfo.fetch("Owner").fetch("Name")).to eql @userInfo.fetch("display_name")
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
      expect(leadInfo.fetch("Building_Interested_In__c")).to eql @helper.instance_variable_get(:@restForce).getRecords("SELECT id FROM Building__c WHERE Name = '#{@testDataJSON['Lead'][0]["Building_Interested_In__c"]}'")[0].fetch("Id")
      @helper.addLogs("[Result ]   : Building interested on Lead checked successfully\n")
      @helper.addLogs("[Validate ] : Checking Journey created date on lead")
      @helper.addLogs("[Expected ] : Journey created date should be #{leadInfo.fetch("CreatedDate")}")
      @helper.addLogs("[Actual ]   : Lead is created with Journey created date #{leadInfo.fetch("Journey_Created_On__c")}")
      #expect(insertedLeadInfo.fetch("Journey_Created_On__c")).to eql insertedJourneyInfo[0].fetch("CreatedDate")
      @helper.addLogs("[Result ]   : Journey created date on Lead checked successfully\n")
      @helper.addLogs("[Validate ] : Checking Interested in Number of Desks on lead")
      @helper.addLogs("[Expected ] : Interested in Number of Desks should be #{@testDataJSON['Lead'][0]['NumberofDesks']}.0")
      @helper.addLogs("[Actual ]   : Lead is created with Interested in Number of Desks #{leadInfo.fetch("Interested_in_Number_of_Desks__c")}")
      expect("#{leadInfo.fetch('Interested_in_Number_of_Desks__c')}").to eql "#{@testDataJSON['Lead'][0]['NumberofDesks']}.0"
      @helper.addLogs("[Result ]   : Interested in Number of Desks on Lead checked successfully\n")
      @helper.addLogs("[Validate ] : Checking Locations Interested on lead")
      @helper.addLogs("[Expected ] : Locations Interested should be #{@testDataJSON['Lead'][0]["Building_Interested_In__c"]}")
      @helper.addLogs("[Actual ]   : Lead is created with Locations Interested #{leadInfo.fetch("Locations_Interested__c")}")
      expect(leadInfo.fetch("Locations_Interested__c")).to eql @testDataJSON['Lead'][0]["Building_Interested_In__c"]
      @helper.addLogs("[Result ]   : Locations Interested on Lead checked successfully\n")
      @helper.addLogs("[Validate ] : Checking Number of Full Time Employees on lead")
      @helper.addLogs("[Expected ] : Number of Full Time Employees should be #{@testDataJSON['Lead'][0]['CompanySize']}.0")
      @helper.addLogs("[Actual ]   : Lead is created with Number of Full Time Employees #{leadInfo.fetch("Number_of_Full_Time_Employees__c")}")
      expect("#{leadInfo.fetch('Number_of_Full_Time_Employees__c')}").to eql "#{@testDataJSON['Lead'][0]['CompanySize']}.0"
      @helper.addLogs("[Result ]   : Number of Full Time Employees on Lead checked successfully\n")
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
      @helper.addLogs("[Validate ] : Checking RecordType on lead")
      @helper.addLogs("[Expected ] : RecordType should be Consumer")
      @helper.addLogs("[Actual ]   : Lead is created with RecordType #{leadInfo.fetch("RecordType").fetch("Name")}")
      expect(leadInfo.fetch("RecordType").fetch("Name")).to eql "Consumer"
      @helper.addLogs("[Result ]   : RecordType on Lead checked successfully\n")
      @helper.addLogs("[Validate ] : Checking Status on lead")
      @helper.addLogs("[Expected ] : Status should be Open")
      @helper.addLogs("[Actual ]   : Lead is created with Status #{leadInfo.fetch("Status")}")
      expect(leadInfo.fetch("Status")).to eql "Open"
      @helper.addLogs("[Result ]   : Status on Lead checked successfully\n")

      insertedJourneyInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,Owner.Name, CreatedDate ,Status__c , NMD_Next_Contact_Date__c ,Primary_Email__c , Lead_Source__c , Lead_Source_Detail__c , Primary_Phone__c , Company_Name__c , Building_Interested_In__c , Locations_Interested__c , Interested_in_Number_of_Desks__c , Full_Time_Employees__c, Name   FROM Journey__c WHERE Primary_Email__c = '#{leadInfo.fetch("Email")}'")[0]
      @helper.addLogs("[Validate ] : Checking Journey is created on lead")
      @helper.addLogs("[Expected ] : Journey should not create")
      @helper.addLogs("[Actual ]   : Journey is created #{insertedJourneyInfo.nil? ? 'No' : 'Yes'}")
      expect(insertedJourneyInfo).to eql nil
      @helper.addLogs("[Result ]   : Journey created successfully\n")
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
      @helper.postSuccessResult(2571)
    rescue Exception => e
      @helper.addLogs('Error')
      @helper.postFailResult(e, 2571)
      raise e
    end
  end
end
