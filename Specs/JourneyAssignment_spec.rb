require "json"
require "selenium-webdriver"
require "rspec"
require 'yaml'
require 'rails'
require 'httparty'
#require_relative File.expand_path('..',Dir.pwd )+"/specHelper.rb"
require_relative File.expand_path('',Dir.pwd )+"/specHelper.rb"
require_relative '../PageObjects/JourneyAssignment.rb'




include RSpec::Expectations

describe "VerificationOfJourneyAssignmentWhenJourneyIsAssociatedWithLead" do

  before(:all) do
  	@helper = Helper.new
    @driver = Selenium::WebDriver.for :chrome
    #@driver = ARGV[0]
    
    #@base_url = "https://www.katalon.com/"
    @testDataJSON = @helper.getRecordJSON()
    @journeyAssignmentFromLead = JourneyAssignment.new(@driver,@helper)
    @accept_next_alert = true
    @driver.manage.timeouts.implicit_wait = 60
    @verification_errors = []
    @wait = @journeyAssignmentFromLead.instance_variable_get(:@wait)

  end
  
  after(:all) do
    @driver.quit
    @verification_errors.should == []
  end
  
  it "C:975 Verification of journey assignment when journey is associated with lead.", :'975'=> 'true' do 
  	begin
  	@helper.addLogs("[Step    ] Creating lead",'975')
    emailLead = @journeyAssignmentFromLead.createLead()
    puts emailLead
    puts "\n"
    puts "lead created from Sales Console with emailId = #{emailLead}"
    puts "\n"
    @helper.addLogs("[Step    ] Get Journey details")
    
    #puts "SELECT Id,Status__c,NMD_Next_Contact_Date__c,Name,Owner.Name FROM Journey__c WHERE Primary_Email__c='#{emailLead}'"

    journey  =@helper.getSalesforceRecordByRestforce("SELECT Id,Status__c,NMD_Next_Contact_Date__c,Name,Owner.Name FROM Journey__c WHERE Primary_Email__c='#{emailLead}'")
    puts journey
    expect(journey[0].size != 0).to eq true
    expect(journey[0]).to_not eq nil
    @helper.addLogs("[Result  ]  Success")

    puts "\n"


    @helper.addLogs("[Step    ] Get Lead details")
    lead  = @helper.getSalesforceRecordByRestforce("SELECT Id,Name,Email,Owner.Name,CreatedDate,Company,Phone,LeadSource,Company_Size__c,Lead_Source_Detail__c,Status,Building_Interested_In__c,Building_Interested_Name__c,Locations_Interested__c,Journey_Created_On__c FROM Lead WHERE Email='#{emailLead}'")
    puts lead
    expect(lead[0].size != 0).to eq true
    expect(lead[0]).to_not eq nil
    @helper.addLogs("[Result  ]  Success")
    puts "\n"

    @helper.addLogs("[Validate] Get Journey Owner")
    expect(journey[0].fetch('Owner')['Name'].to_s).to eq "Ashutosh Thakur"
    @helper.addLogs("[Result  ] Success")
    puts "\n"

    @helper.addLogs("[Validate] Get Lead Owner")
    expect(lead[0].fetch('Owner')['Name'].to_s).to eq "Ashutosh Thakur"
    @helper.addLogs("[Result  ] Success")
	
	@helper.postSuccessResult('975')
     rescue Exception => e
      raise e
      @helper.postFailResult(e,'975')
  end
 end

 	it "C:994 Verification of Outreach Stage not updation for follow up when journey creation date an follow up date difference is not greater than 48 hours.", :'994'=> 'true' do 
 	begin
 	@helper.addLogs("[Step    ] Creating lead",'994')
 	emailLead = @journeyAssignmentFromLead.createLead()
    puts "\n"
    puts "lead created from Sales Console with emailId = #{emailLead}"
    puts "\n"

	puts "click on More action"
	frameid = @journeyAssignmentFromLead.moreAction()
	
	puts "Click on Follow Up"
	@driver.find_element(:link_text, 'Follow Up').click
	sleep(2)
	@driver.switch_to.frame('frame')
    @wait.until {!@driver.find_element(:id, "spinner").displayed?}
   	!60.times{ break if (@driver.find_element(:id, "FollowUpAfter").displayed? rescue false); sleep 1 }
    @driver.find_element(:id, "FollowUpAfter").click
    Selenium::WebDriver::Support::Select.new(@driver.find_element(:id, "FollowUpAfter")).select_by(:text, "1 Day")
    #Selenium::WebDriver::Support::Select.new(@driver.find_element(:id, "FollowUpAfter")).select_by(:index, "0")
    @driver.find_element(:id, "FollowUpAfter").click
    @driver.find_element(:xpath, "//div[@id='lightning']/div[4]/div[3]/div[3]/div[2]/div/textarea").click
    @driver.find_element(:xpath, "//div[@id='lightning']/div[4]/div[3]/div[3]/div[2]/div/textarea").clear
    @driver.find_element(:xpath, "//div[@id='lightning']/div[4]/div[3]/div[3]/div[2]/div/textarea").send_keys "Test Data"
    @driver.find_element(:xpath, "//div[@id='lightning']/div[4]/div[4]/button").click
    puts "Follow up is done"

    frameid = @journeyAssignmentFromLead.moreAction()
	puts "Click on  Log A Call"
   	@driver.find_element(:xpath, "//li[@id='action:5']/a/span").click
   	sleep(5)
   	@driver.switch_to.frame('frame')
   	#@wait.until {!@driver.find_element(:id, "spinner").displayed?}
   	#@driver.find_element(:id, "left-a-voicemail").click
    @driver.find_element(:id, "field-comment").click
    @driver.find_element(:id, "field-comment").clear
    @driver.find_element(:id, "field-comment").send_keys "Test Data"
    @driver.find_element(:id, "view-save").click
    puts "Log A Call is Done"



    @helper.addLogs("[Step    ] Get Journey details")
    journey  =@helper.getSalesforceRecordByRestforce("SELECT Id,Status__c,NMD_Next_Contact_Date__c,Name,Owner.Name,Outreach_Stage__c FROM Journey__c WHERE Primary_Email__c='#{emailLead}'")
    puts journey
    expect(journey[0].size != 0).to eq true
    expect(journey[0]).to_not eq nil
    #expect(journey[0].fetch('Id')).to_not eq nil
    @helper.addLogs("[Result  ]  Success")
    puts "\n"

    @helper.addLogs("[Validate] Get Journey Owner")
    expect(journey[0].fetch('Owner')['Name'].to_s).to eq "Ashutosh Thakur"
    @helper.addLogs("[Result  ] Success")
    puts "\n"

    @helper.addLogs("[Validate] Get Journey Status")
    expect(journey[0].fetch('Status__c')).to eq "Started"
    @helper.addLogs("[Result  ] Success")
    puts "\n"

    @helper.addLogs("[Validate] Get Outreach Stage")
    expect(journey[0].fetch('Outreach_Stage__c')).to eq "Call"
    @helper.addLogs("[Result  ] Success")
    puts "\n"

    @helper.addLogs("[Step    ] Get Journey Follow up Activity Details")
    journeyId  =journey[0].fetch('Id')
    activity=@helper.getSalesforceRecordByRestforce("Select Id,Owner.Name,Owner.Id, Subject,Lead_Source__c, Lead_Source_Detail__c, Locations_Interested__c,Type,Status,WhatId FROM Task WHERE WhatId = '#{journeyId}'")
    puts activity
    expect(activity[0].size != 0).to eq true
    expect(activity[0]).to_not eq nil
    passedLogs = @helper.addLogs("[Result  ]  Success")
    puts "\n"


    @helper.addLogs("[Validate] Get Type on Followup Activity")
    expect(activity[0].fetch('Type')).to eq "Call"
    @helper.addLogs("[Result  ] Success")
    puts "\n"

    @helper.addLogs("[Validate] Get Type on Followup Activity")
    expect(activity[0].fetch('Subject')).to eq "Follow-Up"
    @helper.addLogs("[Result  ] Success")
    puts "\n"

    @helper.addLogs("[Validate] Get Subject on Followup Activity")
    expect(activity[0].fetch('Subject')).to eq "Follow-Up"
    @helper.addLogs("[Result  ] Success")
    puts "\n"

    @helper.addLogs("[Validate] Get Status on Followup Activity")
    expect(activity[0].fetch('Status')).to eq "Not Started"
    @helper.addLogs("[Result  ] Success")
    puts "\n"

	@helper.addLogs("[Validate] Get WhatId on Followup Activity")
    expect(activity[0].fetch('WhatId')).to eq "#{journeyId}"
    @helper.addLogs("[Result  ] Success")
    puts "\n"
	
	@helper.addLogs("[Validate] Get Lead Source on Followup Activity")
    expect(activity[0].fetch('Lead_Source__c')).to eq "Outbound Email/Cold Call"
	@helper.addLogs("[Result  ] Success")
    puts "\n"

    @helper.addLogs("[Validate] Get Lead Source Detail on Followup Activity")
    expect(activity[0].fetch('Lead_Source_Detail__c')).to eq "Inbound Call Page"
	@helper.addLogs("[Result  ] Success")
    puts "\n"

    @helper.addLogs("[Step    ] Get Lead Details")
    lead  =@helper.getSalesforceRecordByRestforce("SELECT Id,Name,Email,Owner.Name,CreatedDate,Company,Phone,LeadSource,Company_Size__c,Lead_Source_Detail__c,Status,Building_Interested_In__c,Building_Interested_Name__c,Locations_Interested__c,Journey_Created_On__c FROM Lead WHERE Email='#{emailLead}'")
    puts lead
    expect(lead[0].size != 0).to eq true
    expect(lead[0]).to_not eq nil
    @helper.addLogs("[Result  ]  Success")
    puts "\n"

    @helper.addLogs("[Step    ] Get Lead Activity details")
    leadId  =lead[0].fetch('Id')
    activity=@helper.getSalesforceRecordByRestforce("Select Id,Type,Status,Owner.Name,Owner.Id, Subject, WhoId,CallDisposition FROM Task WHERE WhoId ='#{leadId}'and Status='Completed'")
    puts activity
    expect(activity[0].size != 0).to eq true
    expect(activity[0]).to_not eq nil
    @helper.addLogs("[Result  ]  Success")
    puts "\n"

    @helper.addLogs("[Validate] Get Type on Lead Activity")
    expect(activity[0].fetch('Type')).to eq "Call"
    @helper.addLogs("[Result  ] Success")
    puts "\n"

    @helper.addLogs("[Validate] Get Subject on Lead Activity")
    expect(activity[0].fetch('Subject')).to eq "Log A Call : Call 1"
    @helper.addLogs("[Result  ] Success")
    puts "\n"

    @helper.addLogs("[Validate] Get Status on Lead Activity")
    expect(activity[0].fetch('Status')).to eq "Completed"
    @helper.addLogs("[Result  ] Success")
    puts "\n"

    @helper.addLogs("[Validate] Get Whoid on Lead Activity")
    expect(activity[0].fetch('WhoId')).to eq "#{leadId}"
    @helper.addLogs("[Result  ] Success")
    puts "\n"

    @helper.addLogs("[Validate] Get Call Result on Lead Activity")
    expect(activity[0].fetch('CallDisposition')).to eq "Test Data"
    @helper.addLogs("[Result  ] Success")
    puts "\n"

	@helper.postSuccessResult('994')
     rescue Exception => e
      raise e
      @helper.postFailResult(e,'994')
  end
end
  
  it "C:987 Verification of Log a call when journey status is started.", :'987'=> 'true' do 
  	begin
  	@helper.addLogs("[Step    ] Creating lead",'987')
  	emailLead = @journeyAssignmentFromLead.createLead()
    #puts demo
    puts "\n"
    puts "lead created from Sales Console with emailId = #{emailLead}"
    puts "\n"
    puts "click on More action"
    frameid = @journeyAssignmentFromLead.moreAction()
   	puts "Click on  Log A Call"
   	@driver.find_element(:xpath, "//li[@id='action:5']/a/span").click
   	sleep(5)
   	@driver.switch_to.frame('frame')
   	#@wait.until {!@driver.find_element(:id, "spinner").displayed?}
   	#@driver.find_element(:id, "left-a-voicemail").click
    @driver.find_element(:id, "field-comment").click
    @driver.find_element(:id, "field-comment").clear
    @driver.find_element(:id, "field-comment").send_keys "Test Data"
    @driver.find_element(:id, "view-save").click
    puts "Log A Call is Done"
    puts "\n"

    @helper.addLogs("[Step    ] Get Journey details")
    journey  =@helper.getSalesforceRecordByRestforce("SELECT Id,Status__c,NMD_Next_Contact_Date__c,Name,Owner.Name,Outreach_Stage__c FROM Journey__c WHERE Primary_Email__c='#{emailLead}'")
    puts journey
    expect(journey[0].size != 0).to eq true
    expect(journey[0]).to_not eq nil
    #expect(journey[0].fetch('Id')).to_not eq nil
    @helper.addLogs("[Result  ]  Success")
    puts "\n"

    @helper.addLogs("[Validate] Get Journey Status")
    expect(journey[0].fetch('Status__c')).to eq "Started"
    @helper.addLogs("[Result  ] Success")
    puts "\n"

    @helper.addLogs("[Validate] Get Next Contact Date on Journey")
    expect(journey[0].fetch('NMD_Next_Contact_Date__c')).to eq Date.today.to_s
    @helper.addLogs("[Result  ] Success")
    puts "\n"

    @helper.addLogs("[Validate] Get Journey Owner")
    expect(journey[0].fetch('Owner')['Name'].to_s).to eq "Ashutosh Thakur"
    @helper.addLogs("[Result  ] Success")
    puts "\n"

    @helper.addLogs("[Validate] Get Outreach Stage")
    expect(journey[0].fetch('Outreach_Stage__c')).to eq "Call 1"
    @helper.addLogs("[Result  ] Success")
    puts "\n"

    @helper.addLogs("[Step    ] Get Lead Details")
    lead  =@helper.getSalesforceRecordByRestforce("SELECT Id,Name,Email,Owner.Name,CreatedDate,Company,Phone,LeadSource,Company_Size__c,Lead_Source_Detail__c,Status,Building_Interested_In__c,Building_Interested_Name__c,Locations_Interested__c,Journey_Created_On__c FROM Lead WHERE Email='#{emailLead}'")
    puts lead
    expect(lead[0].size != 0).to eq true
    expect(lead[0]).to_not eq nil
    @helper.addLogs("[Result  ]  Success")
    puts "\n"

    @helper.addLogs("[Step    ] Get Lead Activity details")
    leadId  =lead[0].fetch('Id')
    activity=@helper.getSalesforceRecordByRestforce("Select Id,Type,Status,Owner.Name,Owner.Id, Subject, WhoId,CallDisposition FROM Task WHERE WhoId ='#{leadId}'and Status='Completed'")
    puts activity
    expect(activity[0].size != 0).to eq true
    expect(activity[0]).to_not eq nil
    @helper.addLogs("[Result  ]  Success")
    puts "\n"

    @helper.addLogs("[Validate] Get Type on Lead ACtivity")
    expect(activity[0].fetch('Type')).to eq "Call"
    @helper.addLogs("[Result  ] Success")
    puts "\n"

    @helper.addLogs("[Validate] Get Subject on Lead Activity")
    expect(activity[0].fetch('Subject')).to eq "Log A Call : Call 1"
    @helper.addLogs("[Result  ] Success")
    puts "\n"

    @helper.addLogs("[Validate] Get Status on Lead Activity")
    expect(activity[0].fetch('Status')).to eq "Completed"
    @helper.addLogs("[Result  ] Success")
    puts "\n"

    @helper.addLogs("[Validate] Get Whoid on Lead Activity")
    expect(activity[0].fetch('WhoId')).to eq "#{leadId}"
    @helper.addLogs("[Result  ] Success")
    puts "\n"

    @helper.addLogs("[Validate] Get Call Result on Lead Activity")
    expect(activity[0].fetch('CallDisposition')).to eq "Test Data"
    @helper.addLogs("[Result  ] Success")
    puts "\n"

    @helper.postSuccessResult('987')
     rescue Exception => e
      raise e
      @helper.postFailResult(e,'987')
  end
end
	it "C:988 Verification of Log a call for more than two times when journey status is started.", :'988'=> 'true' do 
	 begin
	@helper.addLogs("[Step    ] Creating lead",'988')
  	emailLead = @journeyAssignmentFromLead.createLead()
    #puts demo
    puts "\n"
    puts "lead created from Sales Console with emailId = #{emailLead}"
    puts "\n"
    puts "click on More action"
    frameid = @journeyAssignmentFromLead.moreAction()
   	puts "Click on  Log A Call"
   	@driver.find_element(:xpath, "//li[@id='action:5']/a/span").click
   	sleep(5)
   	@driver.switch_to.frame('frame')
   	#@wait.until {!@driver.find_element(:id, "spinner").displayed?}
   	#@driver.find_element(:id, "left-a-voicemail").click
    @driver.find_element(:id, "field-comment").click
    @driver.find_element(:id, "field-comment").clear
    @driver.find_element(:id, "field-comment").send_keys "Test Data"
    @driver.find_element(:id, "view-save").click
    puts "Log A Call is Done"
    puts "\n"

    frameid = @journeyAssignmentFromLead.moreAction()
    puts "Click on  Log A Call"
   	@driver.find_element(:xpath, "//li[@id='action:5']/a/span").click
   	sleep(5)
   	@driver.switch_to.frame('frame')
   	#@wait.until {!@driver.find_element(:id, "spinner").displayed?}
   	#@driver.find_element(:id, "left-a-voicemail").click
    @driver.find_element(:id, "field-comment").click
    @driver.find_element(:id, "field-comment").clear
    @driver.find_element(:id, "field-comment").send_keys "Test Data"
    @driver.find_element(:id, "view-save").click
    puts "Log A Call is Done"
    puts "\n"

    frameid = @journeyAssignmentFromLead.moreAction()
    puts "Click on  Log A Call"
   	@driver.find_element(:xpath, "//li[@id='action:5']/a/span").click
   	sleep(5)
   	@driver.switch_to.frame('frame')
   	#@wait.until {!@driver.find_element(:id, "spinner").displayed?}
   	#@driver.find_element(:id, "left-a-voicemail").click
    #@driver.find_element(:id, "field-comment").click
    #@driver.find_element(:id, "field-comment").clear
    #@driver.find_element(:id, "field-comment").send_keys "Test Data"
    #@driver.find_element(:id, "view-save").click
    puts "Save Button is disabled"
    puts "\n"

    @helper.addLogs("[Step    ] Get Journey details")
    journey  =@helper.getSalesforceRecordByRestforce("SELECT Id,Status__c,NMD_Next_Contact_Date__c,Name,Owner.Name,Outreach_Stage__c FROM Journey__c WHERE Primary_Email__c='#{emailLead}'")
    puts journey
    expect(journey[0].size != 0).to eq true
    expect(journey[0]).to_not eq nil
    #expect(journey[0].fetch('Id')).to_not eq nil
    @helper.addLogs("[Result  ]  Success")
    puts "\n"

    @helper.addLogs("[Validate] Get Journey Status")
    expect(journey[0].fetch('Status__c')).to eq "Started"
    @helper.addLogs("[Result  ] Success")
    puts "\n"

    @helper.addLogs("[Validate] Get Next Contact Date on Journey")
    expect(journey[0].fetch('NMD_Next_Contact_Date__c')).to eq Date.today.to_s
    @helper.addLogs("[Result  ] Success")
    puts "\n"

    @helper.addLogs("[Validate] Get Journey Owner")
    expect(journey[0].fetch('Owner')['Name'].to_s).to eq "Ashutosh Thakur"
    @helper.addLogs("[Result  ] Success")
    puts "\n"

    @helper.addLogs("[Validate] Get Outreach Stage")
    expect(journey[0].fetch('Outreach_Stage__c')).to eq "Call 2"
    @helper.addLogs("[Result  ] Success")
    puts "\n"

    @helper.addLogs("[Step    ] Get Lead Details")
    lead  =@helper.getSalesforceRecordByRestforce("SELECT Id,Name,Email,Owner.Name,CreatedDate,Company,Phone,LeadSource,Company_Size__c,Lead_Source_Detail__c,Status,Building_Interested_In__c,Building_Interested_Name__c,Locations_Interested__c,Journey_Created_On__c FROM Lead WHERE Email='#{emailLead}'")
    puts lead
    expect(lead[0].size != 0).to eq true
    expect(lead[0]).to_not eq nil
    @helper.addLogs("[Result  ]  Success")
    puts "\n"

    @helper.addLogs("[Step    ] Get Lead Activity details")
    leadId  =lead[0].fetch('Id')
    activity=@helper.getSalesforceRecordByRestforce("Select Id,Type,Status,Owner.Name,Owner.Id, Subject, WhoId,CallDisposition FROM Task WHERE WhoId ='#{leadId}'and Status='Completed' order by createdDate DESC limit 1")
    puts activity
    expect(activity[0].size != 0).to eq true
    expect(activity[0]).to_not eq nil
    @helper.addLogs("[Result  ]  Success")
    puts "\n"

    @helper.addLogs("[Validate] Get Type on Lead ACtivity")
    expect(activity[0].fetch('Type')).to eq "Call"
    @helper.addLogs("[Result  ] Success")
    puts "\n"

    @helper.addLogs("[Validate] Get Subject on Lead Activity")
    expect(activity[0].fetch('Subject')).to eq "Log A Call : Call 2"
    @helper.addLogs("[Result  ] Success")
    puts "\n"

    @helper.addLogs("[Validate] Get Status on Lead Activity")
    expect(activity[0].fetch('Status')).to eq "Completed"
    @helper.addLogs("[Result  ] Success")
    puts "\n"

    @helper.addLogs("[Validate] Get Whoid on Lead Activity")
    expect(activity[0].fetch('WhoId')).to eq "#{leadId}"
    @helper.addLogs("[Result  ] Success")
    puts "\n"

    @helper.addLogs("[Validate] Get Call Result on Lead Activity")
    expect(activity[0].fetch('CallDisposition')).to eq "Test Data"
    @helper.addLogs("[Result  ] Success")
    puts "\n"

     @helper.postSuccessResult('988')
     rescue Exception => e
      raise e
      @helper.postFailResult(e,'988')
  end
end
  def element_present?(how, what)
  	@driver.find_element(how, what)
    true
  rescue Selenium::WebDriver::Error::NoSuchElementError
    false
  end
  
  def alert_present?()
  	@driver.switch_to.alert
    true
  rescue Selenium::WebDriver::Error::NoAlertPresentError
    false
  end
  
  def verify(&blk)
    yield
  rescue ExpectationNotMetError => ex
    @verification_errors << ex
  end
  
  def close_alert_and_get_its_text(how, what)
    alert = @driver.switch_to().alert()
    alert_text = alert.text
    if (@accept_next_alert) then
      alert.accept()
    else
      alert.dismiss()
    end
    alert_text
  ensure
    @accept_next_alert = true
  end
end
