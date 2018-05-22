require "json"
require "selenium-webdriver"
require "rspec"
require_relative File.expand_path('',Dir.pwd )+"/specHelper.rb"
#require_relative File.expand_path('..',Dir.pwd )+"/specHelper.rb"

include RSpec::Expectations

describe "ToCheckTourBookedFromWebsiteWhetherRecordTypeIsConsumerAndDealTypeIsTransactional" do

  before(:all) do
    @helper = Helper.new
    @driver = ARGV[0]
    #@driver = Selenium::WebDriver.for :chrome
    @objRollbar = RollbarUtility.new()

    #@base_url = "https://www.katalon.com/"
    @testDataJSON = @helper.getRecordJSON()
    @accept_next_alert = true
    @driver.manage.timeouts.implicit_wait = 30
    @verification_errors = []
  end
  
  after(:each) do
    @driver.quit
    @verification_errors.should == []
  end
  it "C:2151 To check Tour Booked from website whether record type is consumer and deal type is transactional.", :'2151'=> 'true' do 
    begin
    @helper.addLogs('To check Tour Booked from website whether record type is consumer and deal type is transactional.','2151')
    @driver.get "https://www-staging.wework.com/buildings/marol--mumbai"
    @driver.find_element(:id, "tourFormContactNameField").click
    @driver.find_element(:id, "tourFormContactNameField").clear
    @driver.find_element(:id, "tourFormContactNameField").send_keys @testDataJSON['CreateLeadFromWeb'][0]['Name']
    @driver.find_element(:id, "tourFormEmailField").click
    @driver.find_element(:id, "tourFormEmailField").clear
    @testDataJSON['CreateLeadFromWeb'][0]['Email'] = @testDataJSON['CreateLeadFromWeb'][0]['Name'] + SecureRandom.random_number(10000000000).to_s + "@example.com" 
    emailLead = @testDataJSON['CreateLeadFromWeb'][0]['Email']
    puts "\n"
    puts emailLead
    @driver.find_element(:id, "tourFormEmailField").send_keys @testDataJSON['CreateLeadFromWeb'][0]['Email']
    @driver.find_element(:id, "tourFormPhoneField").click
    @driver.find_element(:id, "tourFormPhoneField").clear
    @driver.find_element(:id, "tourFormPhoneField").send_keys @testDataJSON['CreateLeadFromWeb'][0]['Phone']
    @driver.find_element(:name, "move_in_time_frame").click
    @driver.find_element(:name, "move_in_time_frame").click
    @driver.find_element(:name, "desired_capacity").click
    @driver.find_element(:name, "desired_capacity").click
    @driver.find_element(:id, "tourFormStepOneSubmitButton").click
    @driver.find_element(:id, "tourFormCompanyNameField").click
    @driver.find_element(:id, "tourFormCompanyNameField").clear
    @driver.find_element(:id, "tourFormCompanyNameField").send_keys @testDataJSON['CreateLeadFromWeb'][0]['Name']
    @driver.find_element(:id, "tourFormNotesField").click
    @driver.find_element(:id, "tourFormNotesField").clear
    @driver.find_element(:id, "tourFormNotesField").send_keys "Test Data"
    @driver.find_element(:id, "tourFormStepTwoSubmitButton").click

    @helper.addLogs('Success')

    sleep(10)

    @helper.addLogs("[Step    ] Get Contact Details")
    contact=@helper.getSalesforceRecordByRestforce("SELECT Id,Name,Account.Name,Email,Interested_in_Number_of_Desks__c,Looking_For_Number_Of_Desk__c,Location_Interested__c,Owner.Name,RecordType.Name from Contact WHERE Email='#{emailLead}'")
    puts contact
    expect(contact[0].size != 0).to eq true
    expect(contact[0]).to_not eq nil
    #expect(contact.size == 1).to eq true
    #expect(contact[0]).to_not eq nil
    #expect(contact[0].fetch('Id')).to_not eq nil
    @helper.addLogs("[Result  ]  Success")
    puts "\n"

    @helper.addLogs("[Step    ] Get building details of #{@testDataJSON['CreateLeadFromWeb'][0]["Building"]}")
    buildingName = @testDataJSON['CreateLeadFromWeb'][0]["Building"]
    building = @helper.getSalesforceRecordByRestforce("SELECT id,Cluster_Sales_Lead_Name__c,name,Community_Lead__c,Market__c,UUID__C FROM Building__c WHERE Name = '#{buildingName}'")
    expect(building).to_not eq nil
    @helper.addLogs("[Result  ]  Success")
    puts "\n"

=begin
    @helper.addLog("[Validate] Contact Name")
    expect(contact[0].fetch('Name')).to match @testDataJSON['CreateLeadFromWeb'][0]['Name']
    @helper.addLog("[Result  ] Success")
    puts "\n"
=end
    @helper.addLogs("[Validate] Contact Email")
    expect(contact[0].fetch('Email')).to eq @testDataJSON['CreateLeadFromWeb'][0]['Email']
    @helper.addLogs("[Result  ] Success")
    puts "\n"

    @helper.addLogs("[Validate] Account Name")
    expect(contact[0].fetch('Account')['Name']).to match @testDataJSON['CreateLeadFromWeb'][0]['Name']
    @helper.addLogs("[Result  ] Success")
    puts "\n"

    @helper.addLogs("[Validate] contact Record Type")
    expect(contact[0].fetch('RecordType')['Name']).to eq "Consumer"
    @helper.addLogs("[Result  ] Success")
    puts "\n"

=begin
    passedLogs = @objRollbar.addLog("[Validate] Contact:Owner.Name")
    #puts "#{building.fetch('Community_Lead__c')}".class
    expect(contact[0].fetch('Owner.Name').to_s).to eq "#{building.fetch('Community_Lead__c')}"
    passedLogs = @objRollbar.addLog("[Result  ]  Success")
=end

=begin  
    passedLogs = @objRollbar.addLog("[Validate] Get Looking for Number of Desks")
    expect(contact[0].fetch('Looking_For_Number_Of_Desk__c').to_i).to eq @testDataJSON['CreateLeadFromWeb'][0]['NumberOfPeople']
    passedLogs = @objRollbar.addLog("[Result  ]  Success")
=end
    
    @helper.addLogs("[Validate] Get Locations Interested")
    expect(contact[0].fetch('Location_Interested__c')).to eq @testDataJSON['CreateLeadFromWeb'][0]['Building']
    @helper.addLogs("[Result  ] Success")
    puts "\n"

    @helper.addLogs("[Step    ] Get Account Details")
    account=@helper.getSalesforceRecordByRestforce("SELECT Id,Name,Lead_Source__c,Company_Size__c,Interested_in_Number_of_Desks__c,Primary_Member__r.Name,RecordType.Name,Allow_Merge__c,Owner.Id from Account WHERE Primary_Member__r.Email='#{emailLead}'")
    puts account
    expect(account[0].size != 0).to eq true
    expect(account[0]).to_not eq nil
    #expect(account.size == 1).to eq true
    #expect(account[0]).to_not eq nil
    #expect(account[0].fetch('Id')).to_not eq nil
    @helper.addLogs("[Result  ]  Success")
    puts "\n"

    @helper.addLogs("[Validate] Account Name")
    expect(account[0].fetch('Name')).to eq @testDataJSON['CreateLeadFromWeb'][0]['Name']
    @helper.addLogs("[Result  ] Success")
    puts "\n"

    @helper.addLogs("[Validate] Get Lead Source")
    expect(account[0].fetch('Lead_Source__c')).to eq @testDataJSON['Lead'][0]['LeadSource']
    @helper.addLogs("[Result  ] Success")
    puts "\n"

=begin
    passedLogs = @objRollbar.addLog("[Validate] Get Company Size")
    expect(account[0].fetch('Company_Size__c')).to eq @testDataJSON['CreateLeadFromWeb'][0]['NumberOfPeople']
    passedLogs = @objRollbar.addLog("[Result  ]  Success")

    passedLogs = @objRollbar.addLog("[Validate] Get Interested in Number of Desk")
    expect(account[0].fetch('Interested_in_Number_of_Desks__c').to_i).to eq @testDataJSON['CreateLeadFromWeb'][0]['NumberOfPeople']
    passedLogs = @objRollbar.addLog("[Result  ]  Success")
=end
    @helper.addLogs("[Validate] Get Primary Member")
    expect(account[0].fetch('Primary_Member__r')['Name']).to match @testDataJSON['CreateLeadFromWeb'][0]['Name']
    @helper.addLogs("[Result  ] Success")
    puts "\n"


    @helper.addLogs("[Validate] Account  Record Type")
    expect(account[0].fetch('RecordType')['Name']).to eq "Consumer"
    @helper.addLogs("[Result  ] Success")
    puts "\n"

=begin
    @helper.addLogs("[Validate] Allow Merge field on Account")
    expect(account[0].fetch('Allow_Merge__c')).to eq "true"
    @helper.addLogs("[Result  ] Success")
    puts "\n"
=end
=begin
    passedLogs = @objRollbar.addLog("[Validate] Get Account Owner")
    expect(account[0].fetch('Owner.Id').to_s).to eq "#{building.fetch('Community_Lead__c')}"
    passedLogs = @objRollbar.addLog("[Result  ]  Success")
=end

    @helper.addLogs("[Step    ] Get Opportunity details")
    opportunity=@helper.getSalesforceRecordByRestforce("SELECT Id,StageName,Interested_in_Number_of_Desks__c,Owner.Id,Locations_Interested__c,Primary_Member__r.Name,RecordType.Name,Deal_Type__c,Owner_Auto_Assign__c,Primary_Member_Email_New__c,CloseDate,Building__r.Name,Account.Name from Opportunity where Primary_Member_Email_New__c='#{emailLead}'")
    puts opportunity
    expect(opportunity.size == 1).to eq true
    expect(opportunity[0]).to_not eq nil
    expect(opportunity[0].fetch('Id')).to_not eq nil
    puts "\n"

    @helper.addLogs("[Validate] Opportunity Stage")
    expect(opportunity[0].fetch('StageName')).to eq "Selling"
    @helper.addLogs("[Result  ] Success")
    puts "\n"

    @helper.addLogs("[Validate] Get Account Name on Opportunity")
    expect(opportunity[0].fetch('Account')['Name']).to eq @testDataJSON['CreateLeadFromWeb'][0]['Name']
    @helper.addLogs("[Result  ] Success")
    puts "\n"

=begin 
    passedLogs = @objRollbar.addLog("[Validate] Get Interested in Number of Desks on Opportunity")
    expect(opportunity[0].fetch('Interested_in_Number_of_Desks__c')).to eq @testDataJSON['CreateLeadFromWeb'][0]['NumberOfPeople']
    passedLogs = @objRollbar.addLog("[Result  ]  Success")
=end
    
    @helper.addLogs("[Validate] Get Locations Interest on Opportunity")
    puts opportunity[0].fetch('Locations_Interested__c')
    expect(opportunity[0].fetch('Locations_Interested__c')).to eq @testDataJSON['CreateLeadFromWeb'][0]['Building']

    @helper.addLogs("[Result  ] Success")
    puts "\n"

    @helper.addLogs("[Validate] Get Main Contact on Opportunity")
    expect(opportunity[0].fetch('Primary_Member__r')['Name']).to match @testDataJSON['CreateLeadFromWeb'][0]['Name']
    @helper.addLogs("[Result  ] Success")
    puts "\n"

    @helper.addLogs("[Validate] Get Record Type on Opportunity")
    expect(opportunity[0].fetch('RecordType')['Name']).to eq "Consumer"
    @helper.addLogs("[Result  ] Success")
    puts "\n"

    @helper.addLogs("[Validate] Get Deal Type on Opportunity")
    expect(opportunity[0].fetch('Deal_Type__c')).to eq "Transactional"
    @helper.addLogs("[Result  ] Success")
    puts "\n"

=begin
    @helper.addLogs("[Validate] Get Owner Auto Assign on Opportunity")
    expect(opportunity[0].fetch('Owner_Auto_Assign__c')).to eq "true"
    @helper.addLogs("[Result  ] Success")
    puts "\n"
=end
    @helper.addLogs("[Validate] Get Primary Member Email Address on Opportunity")
    expect(opportunity[0].fetch('Primary_Member_Email_New__c')).to eq "#{emailLead}"
    @helper.addLogs("[Result  ] Success")
    puts "\n"

=begin
    passedLogs = @objRollbar.addLog("[Validate] Get Close Date on Opportunity")
    expect(opportunity[0].fetch('CloseDate')).to eq Date.today + 30.day
    passedLogs = @objRollbar.addLog("[Result  ] Success")
    puts "\n"
=end

=begin
    passedLogs = @objRollbar.addLog("[Validate] Get Opportunity Owner")
    expect(opportunity[0].fetch('Owner.Id').to_s).to eq "#{building.fetch('Community_Lead__c')}"
    passedLogs = @objRollbar.addLog("[Result  ]  Success")
=end
    @helper.addLogs("[Validate] Get Building/Nearest Building on Opportunity")
    expect(opportunity[0].fetch('Building__r')['Name']).to eq @testDataJSON['CreateLeadFromWeb'][0]['Building']
    @helper.addLogs("[Result  ] Success")
    puts "\n"


    @helper.addLogs("[Step    ] Get Tour Details")
    tour=@helper.getSalesforceRecordByRestforce("SELECT Name,Owner.Name,Status__c,Tour_Date__c,Start_Time__c,Primary_Member__r.Name,Company_Name__c,Location__r.Name,Opportunity__r.Name,Journey__r.Name,Tour_Scheduled_With_Email__c,Booked_By_Sales_Lead__c,booked_by_contact_id__r.Name,Booked_By_User_Role__c,Assigned_Host__r.Name from Tour_Outcome__c where Tour_Scheduled_With_Email__c='#{emailLead}'")
    puts tour
    expect(tour.size == 1).to eq true
    expect(tour[0]).to_not eq nil
    expect(tour[0].fetch('Name')).to_not eq nil
    puts "\n"

    @helper.addLogs("[Validate] Get Tour Status from Tour")
    expect(tour[0].fetch('Status__c')).to eq "Scheduled"
    @helper.addLogs("[Result  ] Success")
    puts "\n"

=begin
    passedLogs = @objRollbar.addLog("[Validate] Get Tour Date from Tour")
    expect(tour[0].fetch('Tour_Date__c')).to eq Date.today().to_s
    passedLogs = @objRollbar.addLog("[Result  ] Success")
    puts "\n"
=end
=begin 
    passedLogs = @objRollbar.addLog("[Validate] Get Start Time from Tour")
    expect(tour[0].fetch('Start_Time__c')).to eq "Scheduled"
    passedLogs = @objRollbar.addLog("[Result  ]  Success")

    passedLogs = @objRollbar.addLog("[Validate] Get Opportunity Name from Tour")
    expect(tour[0].fetch('Opportunity__r.Name')).to eq "Scheduled"
    passedLogs = @objRollbar.addLog("[Result  ]  Success")

    passedLogs = @objRollbar.addLog("[Validate] Get Journey Name from Tour")
    expect(tour[0].fetch('Journey__r.Name')).to eq "Scheduled"
    passedLogs = @objRollbar.addLog("[Result  ]  Success")
=end

    @helper.addLogs("[Validate] Get Primary member from Tour")
    expect(tour[0].fetch('Primary_Member__r')['Name']).to eq contact[0].fetch('Name')
    @helper.addLogs("[Result  ] Success")
    puts "\n"

    @helper.addLogs("[Validate] Get Company Name from Tour")
    expect(tour[0].fetch('Company_Name__c')).to eq @testDataJSON['CreateLeadFromWeb'][0]['Name']
    @helper.addLogs("[Result  ] Success")
    puts "\n"

    @helper.addLogs("[Validate] Get Location from Tour")
    expect(tour[0].fetch('Location__r')['Name']).to eq @testDataJSON['CreateLeadFromWeb'][0]['Building']
    @helper.addLogs("[Result  ] Success")
    puts "\n"

    @helper.addLogs("[Validate] Get Tour Scheduled with email from Tour")
    expect(tour[0].fetch('Tour_Scheduled_With_Email__c')).to eq "#{emailLead}"
    @helper.addLogs("[Result  ] Success")
    puts "\n"

    @helper.addLogs("[Validate] Get Tour Owner from Tour")
    expect(tour[0].fetch('Owner')['Name']).to eq "Susie Romero"
    @helper.addLogs("[Result  ] Success")
    puts "\n"

    @helper.addLogs("[Validate] Get Booked By Sales lead from Tour")
    expect(tour[0].fetch('Booked_By_Sales_Lead__c')).to eq false
    @helper.addLogs("[Result  ] Success")
    puts "\n"

    @helper.addLogs("[Validate] Get Booked By from Tour")
    expect(tour[0].fetch('booked_by_contact_id__r')['Name']).to eq "NMD WeWork"
    @helper.addLogs("[Result  ] Success")
    puts "\n"

    @helper.addLogs("[Validate] Get Booked By User Role from Tour")
    expect(tour[0].fetch('Booked_By_User_Role__c')).to eq "API User"
    @helper.addLogs("[Result  ] Success")
    puts "\n"

    @helper.addLogs("[Validate] Get Assigned Host from Tour")
    expect(tour[0].fetch('Assigned_Host__r')['Name']).to eq "NMD WeWork"
    @helper.addLogs("[Result  ] Success")

@helper.postSuccessResult(2151)
     rescue Exception => e
      raise e
      @helper.postFailResult(e,'2151')
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

