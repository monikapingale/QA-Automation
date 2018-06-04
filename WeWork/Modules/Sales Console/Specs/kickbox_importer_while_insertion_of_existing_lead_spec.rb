require 'json'
require 'selenium-webdriver'
require 'rspec'
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
	it 'To Check Journey Not being Created while importing Existing lead Which is created within X days(Here X=4) where Generate Journey on UI is Checked and Generate Journey in CSV is Blank.', :'2572'=> 'true' do
  begin
    leadInfo = @helper.getExistingLead(0,4)
    existingJourneyInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id FROM Journey__c WHERE Primary_Email__c = '#{leadInfo.fetch("Email")}'")
    @pageObject.upload_csv(leadInfo.fetch('Email'),"TRUE",false,false,"Lead")[0]
    insertedJourneyInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,Owner.Name, CreatedDate ,Status__c , NMD_Next_Contact_Date__c ,Primary_Email__c , Lead_Source__c , Lead_Source_Detail__c , Primary_Phone__c , Company_Name__c , Building_Interested_In__c , Locations_Interested__c , Interested_in_Number_of_Desks__c , Full_Time_Employees__c, Name   FROM Journey__c WHERE Primary_Email__c = '#{leadInfo.fetch("Email")}'")
    puts existingJourneyInfo.size
    puts insertedJourneyInfo.size
    @helper.addLogs("[Validate ] : Checking Journey is created on lead")
    @helper.addLogs("[Expected ] : Journey should not create")
    @helper.addLogs("[Actual ]   : Journey is created #{(insertedJourneyInfo.size.eql? existingJourneyInfo.size) ? 'No' : 'Yes'}")
    expect(insertedJourneyInfo.size).to eql existingJourneyInfo.size
    @helper.addLogs("[Result ]   : Journey created successfully\n")
    generatedActivityForLead = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Subject , CreatedDate,Status ,Lead_Source__c , Lead_Source_Detail__c,Owner.Name,Locations_Interested__c, Number_of_Full_Time_Employees__c,Interested_in_Number_of_Desks__c,Company__c,WhoId FROM Task WHERE WhoId = '#{leadInfo.fetch('Id')}'")[0]
    @helper.addLogs("[Validate ] : Checking Next Contact Date on existing Journey")
    @helper.addLogs("[Expected ] : Next Contact Date on existing Journey should update with duplicate lead submission date")
    @helper.addLogs("[Actual ]   : Next Contact Date on existing Journey is #{insertedJourneyInfo[0].fetch("NMD_Next_Contact_Date__c")}")
    #expect(existingJourneyInfo.fetch("NMD_Next_Contact_Date__c")).to match generatedActivityForLead.fetch("CreatedDate")
    @helper.addLogs("[Validate ] : Checking Subject on acitivity")
    @helper.addLogs("[Expected ] : Subject on activity should be inboound lead submission")
    @helper.addLogs("[Actual ]   : Subject on activity  is #{generatedActivityForLead.fetch("Subject")}")
    expect(generatedActivityForLead.fetch("Subject")).to eql "Inbound Lead submission"
    @helper.addLogs("[Result ]   : Activity subject checked successfully")
    @helper.addLogs("[Validate ] : Checking lead source on activity")
    @helper.addLogs("[Expected ] : Lead source on activity should be #{@testDataJSON['Lead'][0]['leadSource']}")
    @helper.addLogs("[Actual ]   : Lead source on activity is #{generatedActivityForLead.fetch("Lead_Source__c")}")
    expect(generatedActivityForLead.fetch("Lead_Source__c")).to eql @testDataJSON['Lead'][0]['leadSource']
    @helper.addLogs("[Result ]   : Activity lead source checked successfully")
    @helper.addLogs("[Validate ] : Checking lead source detail on activity")
    @helper.addLogs("[Expected ] : Lead source detail on activity should be #{@testDataJSON['Lead'][0]['lead_Source_Detail__c']}")
    @helper.addLogs("[Actual ]   : Lead source detail on activity is #{generatedActivityForLead.fetch("Lead_Source__c")}")
    expect(generatedActivityForLead.fetch("Lead_Source_Detail__c")).to eql @testDataJSON['Lead'][0]['lead_Source_Detail__c']
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
    @helper.addLogs("[Validate ] : Checking Company on activity")
    @helper.addLogs("[Expected ] : Company on activity should be #{@testDataJSON['Lead'][0]['Company']}")
    @helper.addLogs("[Actual ]   : Company on activity is #{generatedActivityForLead.fetch("Company__c")}")
    expect(generatedActivityForLead.fetch("Company__c")).to eql @testDataJSON['Lead'][0]['Company']
    @helper.addLogs("[Result ]   : Activity Company field checked successfully")
    @helper.addLogs('Success')
    @helper.postSuccessResult(2567)
  rescue Exception => e
    @helper.addLogs('Error')
    @helper.postFailResult(e,2567)
    raise e
  end
  end
=begin
  it "To Check Journey Not being Created While Importing Lead from Kickbox Which is Created after X days(X=4) and Within y days(Here Y=30) where Generate Journey on UI is Checked and Generate Journey in CSV is Blank.",:'2573'=>'true' do
    begin
      @testDataJSON['Lead'][0]['leadSource'] = "Inbound Call"
      @testDataJSON['Lead'][0]['lead_Source_Detail__c'] = "Inbound Call Page"
      leadInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Owner.Name, Email,(select id from tasks where createdDate  = LAST_N_DAYS:60) FROM Lead WHERE CreatedBy.Name IN ('Veena Hegane','Ashotosh Thakur','Monika Pingale','Kishor Shinde') AND Email like '%@example.com' AND CreatedDate > LAST_N_DAYS:5 ")[0]
      index = 5
      until !leadInfo.nil? && index < 30
        leadInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Owner.Name, Email,(select id from tasks where createdDate  = LAST_N_DAYS:60) FROM Lead WHERE CreatedBy.Name IN ('Veena Hegane','Ashotosh Thakur','Monika Pingale','Kishor Shinde') AND Email like '%@example.com' AND CreatedDate = LAST_N_DAYS:#{index}")[0]
        index += 1
      end
      puts leadInfo.inspect
      CSV.open("E:/QA-Automation/leadImporter.csv", "wb") do |csv|
        csv << "First Name,Last Name,Email,Phone,Company,Locale,Lead source,Lead source detail,Country code,Locations interested,Status,Generate Journey".split(',')
        csv << ["#{@testDataJSON['Lead'][0]['FirstName']}","#{@testDataJSON['Lead'][0]['LastName']}","#{leadInfo.fetch('Email')}","#{@testDataJSON['Lead'][0]['Phone']}","#{@testDataJSON['Lead'][0]['Company']}","en-US","#{@testDataJSON['Lead'][0]['leadSource']}","#{@testDataJSON['Lead'][0]['lead_Source_Detail__c']}","IN","#{@testDataJSON['Lead'][0]['Building_Interested_In__c']}","open"]
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
      @helper.addLogs("[Step ]     : Uploading csv")
      EnziUIUtility.selectElement(@driver,"Upload","button").click
      @helper.addLogs("[Result ]   : Csv uploaded successfully")
      @helper.addLogs("[Validate ] : Checking Lead creation")
      insertedJourneyInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,Owner.Name, CreatedDate ,Status__c , NMD_Next_Contact_Date__c ,Primary_Email__c , Lead_Source__c , Lead_Source_Detail__c , Primary_Phone__c , Company_Name__c , Building_Interested_In__c , Locations_Interested__c , Interested_in_Number_of_Desks__c , Full_Time_Employees__c, Name   FROM Journey__c WHERE Primary_Email__c = '#{leadInfo.fetch("Email")}' AND CreatedDate = TODAY")[0]
      @helper.addLogs("[Validate ] : Checking Journey is created on lead")
      @helper.addLogs("[Expected ] : Journey should not create")
      @helper.addLogs("[Actual ]   : Journey is created #{insertedJourneyInfo.nil? ? 'No' : 'Yes'}")
      expect(insertedJourneyInfo).to eql nil
      @helper.addLogs("[Result ]   : Journey created successfully\n")
      generatedActivityForLead = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Subject,Name , CreatedDate,Status ,Lead_Source__c , Lead_Source_Detail__c,Owner.Name,Locations_Interested__c, Number_of_Full_Time_Employees__c,Interested_in_Number_of_Desks__c,Company__c,WhoId FROM Task WHERE WhoId = '#{leadInfo.fetch('Id')}'")[0]
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
      @helper.addLogs("[Expected ] : Lead source on activity should be #{@testDataJSON['Lead'][0]['leadSource']}")
      @helper.addLogs("[Actual ]   : Lead source on activity is #{generatedActivityForLead.fetch("Lead_Source__c")}")
      expect(generatedActivityForLead.fetch("Lead_Source__c")).to eql @testDataJSON['Lead'][0]['leadSource']
      @helper.addLogs("[Result ]   : Activity lead source checked successfully")
      @helper.addLogs("[Validate ] : Checking lead source detail on activity")
      @helper.addLogs("[Expected ] : Lead source detail on activity should be #{@testDataJSON['Lead'][0]['lead_Source_Detail__c']}")
      @helper.addLogs("[Actual ]   : Lead source detail on activity is #{generatedActivityForLead.fetch("Lead_Source__c")}")
      expect(generatedActivityForLead.fetch("Lead_Source_Detail__c")).to eql @testDataJSON['Lead'][0]['lead_Source_Detail__c']
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
      @helper.addLogs("[Validate ] : Checking Company on activity")
      @helper.addLogs("[Expected ] : Company on activity should be #{@testDataJSON['Lead'][0]['Company']}")
      @helper.addLogs("[Actual ]   : Company on activity is #{generatedActivityForLead.fetch("Company__c")}")
      expect(generatedActivityForLead.fetch("Company__c")).to eql @testDataJSON['Lead'][0]['Company']
      @helper.addLogs("[Result ]   : Activity Company field checked successfully")
      @helper.addLogs("[Validate ] : Checking Name on activity")
      @helper.addLogs("[Expected ] : Name on activity should be #{leadInfo.fetch('Id')}")
      @helper.addLogs("[Actual ]   : Name on activity is #{generatedActivityForLead.fetch("Name")}")
      expect(generatedActivityForLead.fetch("Name")).to eql leadInfo.fetch('Id')
      @helper.addLogs("[Result ]   : Activity Number of full time employees field checked successfully")
      @helper.addLogs('Success')
      @helper.postSuccessResult(2567)
    rescue Exception => e
      @helper.addLogs('Error')
      @helper.postFailResult(e,2567)
      raise e
    end
  end
  it "To Check Journey Not being Created While Importing Lead From Kickbox Which is Created Before Y days(Here Y days=30) where Generate Journey on UI is Checked and Generate Journey on CSV is Blank.",:'2574'=>'true' do
    begin
      @testDataJSON['Lead'][0]['leadSource'] = "Inbound Call"
      @testDataJSON['Lead'][0]['lead_Source_Detail__c'] = "Inbound Call Page"
      leadInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Owner.Name, Email,(select id from tasks where createdDate  = LAST_N_DAYS:60) FROM Lead WHERE CreatedBy.Name IN ('Veena Hegane','Ashotosh Thakur','Monika Pingale','Kishor Shinde') AND Email like '%@example.com' AND CreatedDate > LAST_N_DAYS:30")[0]
      index = 30
      until !leadInfo.nil? && index < 35
        leadInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Owner.Name, Email,(select id from tasks where createdDate  = LAST_N_DAYS:60) FROM Lead WHERE CreatedBy.Name IN ('Veena Hegane','Ashotosh Thakur','Monika Pingale','Kishor Shinde') AND Email like '%@example.com' AND CreatedDate = LAST_N_DAYS:#{index}")[0]
        index += 1
      end
      puts leadInfo.inspect
      CSV.open("E:/QA-Automation/leadImporter.csv", "wb") do |csv|
        csv << "First Name,Last Name,Email,Phone,Company,Locale,Lead source,Lead source detail,Country code,Locations interested,Status,Generate Journey".split(',')
        csv << ["#{@testDataJSON['Lead'][0]['FirstName']}","#{@testDataJSON['Lead'][0]['LastName']}","#{leadInfo.fetch('Email')}","#{@testDataJSON['Lead'][0]['Phone']}","#{@testDataJSON['Lead'][0]['Company']}","en-US","#{@testDataJSON['Lead'][0]['leadSource']}","#{@testDataJSON['Lead'][0]['lead_Source_Detail__c']}","IN","#{@testDataJSON['Lead'][0]['Building_Interested_In__c']}","open"]
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
      @helper.addLogs("[Step ]     : Uploading csv")
      EnziUIUtility.selectElement(@driver,"Upload","button").click
      @helper.addLogs("[Result ]   : Csv uploaded successfully")
      @helper.addLogs("[Validate ] : Checking Lead creation")
      insertedJourneyInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,Owner.Name, CreatedDate ,Status__c , NMD_Next_Contact_Date__c ,Primary_Email__c , Lead_Source__c , Lead_Source_Detail__c , Primary_Phone__c , Company_Name__c , Building_Interested_In__c , Locations_Interested__c , Interested_in_Number_of_Desks__c , Full_Time_Employees__c, Name   FROM Journey__c WHERE Primary_Email__c = '#{leadInfo.fetch("Email")}' AND CreatedDate = TODAY")[0]
      @helper.addLogs("[Validate ] : Checking Journey is created on lead")
      @helper.addLogs("[Expected ] : Journey should not create")
      @helper.addLogs("[Actual ]   : Journey is created #{insertedJourneyInfo.nil? ? 'No' : 'Yes'}")
      expect(insertedJourneyInfo).to eql nil
      @helper.addLogs("[Result ]   : Journey created successfully\n")
      generatedActivityForLead = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Subject,Name , CreatedDate,Status ,Lead_Source__c , Lead_Source_Detail__c,Owner.Name,Locations_Interested__c, Number_of_Full_Time_Employees__c,Interested_in_Number_of_Desks__c,Company__c,WhoId FROM Task WHERE WhoId = '#{leadInfo.fetch('Id')}'")[0]
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
      @helper.addLogs("[Expected ] : Lead source on activity should be #{@testDataJSON['Lead'][0]['leadSource']}")
      @helper.addLogs("[Actual ]   : Lead source on activity is #{generatedActivityForLead.fetch("Lead_Source__c")}")
      expect(generatedActivityForLead.fetch("Lead_Source__c")).to eql @testDataJSON['Lead'][0]['leadSource']
      @helper.addLogs("[Result ]   : Activity lead source checked successfully")
      @helper.addLogs("[Validate ] : Checking lead source detail on activity")
      @helper.addLogs("[Expected ] : Lead source detail on activity should be #{@testDataJSON['Lead'][0]['lead_Source_Detail__c']}")
      @helper.addLogs("[Actual ]   : Lead source detail on activity is #{generatedActivityForLead.fetch("Lead_Source__c")}")
      expect(generatedActivityForLead.fetch("Lead_Source_Detail__c")).to eql @testDataJSON['Lead'][0]['lead_Source_Detail__c']
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
      @helper.addLogs("[Validate ] : Checking Company on activity")
      @helper.addLogs("[Expected ] : Company on activity should be #{@testDataJSON['Lead'][0]['Company']}")
      @helper.addLogs("[Actual ]   : Company on activity is #{generatedActivityForLead.fetch("Company__c")}")
      expect(generatedActivityForLead.fetch("Company__c")).to eql @testDataJSON['Lead'][0]['Company']
      @helper.addLogs("[Result ]   : Activity Company field checked successfully")
      @helper.addLogs("[Validate ] : Checking Name on activity")
      @helper.addLogs("[Expected ] : Name on activity should be #{leadInfo.fetch('Id')}")
      @helper.addLogs("[Actual ]   : Name on activity is #{generatedActivityForLead.fetch("Name")}")
      expect(generatedActivityForLead.fetch("Name")).to eql leadInfo.fetch('Id')
      @helper.addLogs("[Result ]   : Activity Number of full time employees field checked successfully")
      @helper.addLogs('Success')
      @helper.postSuccessResult(2574)
    rescue Exception => e
      @helper.addLogs('Error')
      @helper.postFailResult(e, 2574)
      raise e
    end
  end
end
=end
end
