require "json"
require "selenium-webdriver"
require "rspec"
#require_relative File.expand_path('',Dir.pwd )+"/specHelper.rb"
require_relative File.expand_path('..',Dir.pwd )+"/specHelper.rb"
include RSpec::Expectations
puts "1212"

describe "LeadGenerete" do

puts "2222"
  before(:all) do    
    #puts "helllooooo"
    @helper = Helper.new
    @driver = Selenium::WebDriver.for :chrome
    #@driver = ARGV[0]
    @testDataJSON = @helper.getRecordJSON()
    #@base_url = "https://www.katalon.com/"
    @accept_next_alert = true
    @driver.manage.timeouts.implicit_wait = 30
    @verification_errors = []
  end

  after(:each) do
    @driver.quit
    @verification_errors.should == []
  end

  it "C:2016 To check whether generation of lead from Website.", :'2016'=> 'true' do
    begin
        @helper.addLogs('To check whether generation of lead from Website.','2016')


        @helper.addLogs('Go to Staging website and create lead')

        
        @driver.get "https://www-staging.wework.com/buildings/bkc--mumbai"
        @driver.find_element(:id, "tourFormContactNameField").clear
        @driver.find_element(:id, "tourFormContactNameField").send_keys @testDataJSON['CreateLeadFromWeb'][0]['Name']
        @driver.find_element(:id, "tourFormEmailField").clear
        @testDataJSON['CreateLeadFromWeb'][0]['Email'] = @testDataJSON['CreateLeadFromWeb'][0]['Name'] + SecureRandom.random_number(10000000000).to_s + "@example.com" 
        emailLead = @testDataJSON['CreateLeadFromWeb'][0]['Email']
        @driver.find_element(:id, "tourFormEmailField").send_keys @testDataJSON['CreateLeadFromWeb'][0]['Email']
        @driver.find_element(:id, "tourFormPhoneField").clear
        @driver.find_element(:id, "tourFormPhoneField").send_keys @testDataJSON['CreateLeadFromWeb'][0]['Phone']
        @driver.find_element(:id, "tourFormStepOneSubmitButton").click
        
        @helper.addLogs('Success')
  
        sleep(10)
        
        passedLogs = @helper.addLogs("[Step    ] get building details of #{@testDataJSON['CreateLeadFromWeb'][0]["Building"]}")
        buildingName = @testDataJSON['CreateLeadFromWeb'][0]["Building"]
        building = @helper.getSalesforceRecord('Building__c',"SELECT id,Cluster_Sales_Lead_Name__c,name,Community_Lead__c,Market__c,UUID__C FROM Building__c WHERE Name = '#{buildingName}'")
        expect(building).to_not eq nil
        passedLogs = @helper.addLogs("[Result  ]  Success")


        passedLogs = @helper.addLogs("[Step    ] get Lead details")
        lead  = @helper.getSalesforceRecord('Lead',"SELECT Id,Name,Email,Owner.Name,CreatedDate,Company,Phone,LeadSource,Company_Size__c,Lead_Source_Detail__c,Status,Building_Interested_In__c,Building_Interested_Name__c,Locations_Interested__c,Journey_Created_On__c FROM Lead WHERE Email='#{emailLead}'")
        puts lead
        expect(lead.size == 1).to eq true
        expect(lead[0]).to_not eq nil
        expect(lead[0].fetch('Id')).to_not eq nil

        passedLogs = @helper.addLogs("[Step    ] get Journey details")
        journey  = @helper.getSalesforceRecord('Journey__c',"SELECT Id,Status__c,NMD_Next_Contact_Date__c FROM Journey__c WHERE Primary_Email__c = '#{emailLead}'")
        puts journey
        #expect(journey.size == 1).to eq true
        expect(journey[0]).to_not eq nil
        expect(journey[0].fetch('Id')).to_not eq nil


        passedLogs = @helper.addLogs("[Step    ] get Activity details")
        leadId  =lead[0].fetch('Id')
        activity  = @helper.getSalesforceRecord('Task',"Select Id,Owner.Name,Owner.Id, Subject, WhoId, Lead_Source__c, Lead_Source_Detail__c, Locations_Interested__c,Type FROM Task WHERE WhoId = '#{leadId}'")
        puts activity
        #expect(activity.size == 1).to eq true
        expect(activity[0]).to_not eq nil
        expect(activity[0].fetch('Id')).to_not eq nil


        passedLogs = @helper.addLogs("[Validate] lead:.Name")
        puts lead[0].fetch('Name')
        #expect(lead[0].fetch('Name')).to eq @testDataJSON['CreateLeadFromWeb'][0]['Name']
        passedLogs = @helper.addLogs("[Result  ]  Success")

        passedLogs = @helper.addLogs("[Validate] lead:Email")
        expect(lead[0].fetch('Email')).to eq @testDataJSON['CreateLeadFromWeb'][0]['Email']
        passedLogs = @helper.addLogs("[Result  ]  Success")

        passedLogs = @helper.addLogs("[Validate] lead:Company")
        expect(lead[0].fetch('Company')).to eq @testDataJSON['CreateLeadFromWeb'][0]['Name']
        passedLogs = @helper.addLogs("[Result  ]  Success")

        passedLogs = @helper.addLogs("[Validate] lead:Phone")
        expect(lead[0].fetch('Phone')).to eq @testDataJSON['CreateLeadFromWeb'][0]['Phone']
        passedLogs = @helper.addLogs("[Result  ]  Success")

        passedLogs = @helper.addLogs("[Validate] lead:LeadSource")
        expect(lead[0].fetch('LeadSource')).to eq "WeWork.com"
        passedLogs = @helper.addLogs("[Result  ]  Success")

        passedLogs = @helper.addLogs("[Validate] lead:Company_Size__c")
        puts lead[0].fetch('Company_Size__c').to_i
        #expect(lead[0].fetch('Company_Size__c').to_i).to eq @testDataJSON['CreateLeadFromWeb'][0]["NumberOfPeople"]}".split(' ')[0].to_i
        passedLogs = @helper.addLogs("[Result  ]  Success")

        passedLogs = @helper.addLogs("[Validate] lead:Lead_Source_Detail__c")
        expect(lead[0].fetch('Lead_Source_Detail__c').to_i).to eq "Book A Tour Availability"
        passedLogs = @helper.addLogs("[Result  ]  Success")

        passedLogs = @helper.addLogs("[Validate] lead:Status")
        expect(lead[0].fetch('Status').to_i).to eq "Open"
        passedLogs = @helper.addLogs("[Result  ]  Success")

        
        passedLogs = @helper.addLogs("[Validate] lead:Building_Interested_In__c")
        expect(lead[0].fetch('Building_Interested_In__c')).to eq "#{building.fetch('Id')}"
        passedLogs = @helper.addLogs("[Result  ]  Success")

        passedLogs = @helper.addLogs("[Validate] lead:Building_Interested_Name__c")
        puts lead[0].fetch('Building_Interested_Name__c')
        #expect(lead[0].fetch('Building_Interested_Name__c')).to eq @testDataJSON['CreateLeadFromWeb'][0]["Building"]
        passedLogs = @helper.addLogs("[Result  ]  Success")

        passedLogs = @helper.addLogs("[Validate] lead:Locations_Interested__c")
        expect(lead[0].fetch('Locations_Interested__c')).to eq @testDataJSON['CreateLeadFromWeb'][0]["Building"]
        passedLogs = @helper.addLogs("[Result  ]  Success")



=begin
        passedLogs = @helper.addLogs("[Validate] lead:.Name")
        expect(journey[0].fetch('Name')).to eq "Consumer"
        passedLogs = @helper.addLogs("[Result  ]  Success")

        passedLogs = @helper.addLogs("[Validate] lead:Email")
        expect(lead[0].fetch('Email')).to eq "#{building.fetch('Community_Lead__c')}"
        passedLogs = @helper.addLogs("[Result  ]  Success")

        passedLogs = @helper.addLogs("[Validate] lead:Company")
        expect(lead[0].fetch('Company').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
        passedLogs = @helper.addLogs("[Result  ]  Success")

        passedLogs = @helper.addLogs("[Validate] lead:Phone")
        expect(lead[0].fetch('Phone').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
        passedLogs = @helper.addLogs("[Result  ]  Success")

        passedLogs = @helper.addLogs("[Validate] lead:LeadSource")
        expect(lead[0].fetch('LeadSource')).to eq "Consumer"
        passedLogs = @helper.addLogs("[Result  ]  Success")

        passedLogs = @helper.addLogs("[Validate] lead:Company_Size__c")
        expect(lead[0].fetch('Company_Size__c')).to eq "#{building.fetch('Community_Lead__c')}"
        passedLogs = @helper.addLogs("[Result  ]  Success")

        passedLogs = @helper.addLogs("[Validate] lead:Lead_Source_Detail__c")
        expect(lead[0].fetch('Lead_Source_Detail__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
        passedLogs = @helper.addLogs("[Result  ]  Success")

        passedLogs = @helper.addLogs("[Validate] lead:Status")
        expect(lead[0].fetch('Status').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
        passedLogs = @helper.addLogs("[Result  ]  Success")

        
        passedLogs = @helper.addLogs("[Validate] lead:Building_Interested_In__c")
        expect(lead[0].fetch('Building_Interested_In__c')).to eq "#{building.fetch('Community_Lead__c')}"
        passedLogs = @helper.addLogs("[Result  ]  Success")

        passedLogs = @helper.addLogs("[Validate] lead:Building_Interested_Name__c")
        expect(lead[0].fetch('Building_Interested_Name__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
        passedLogs = @helper.addLogs("[Result  ]  Success")

        passedLogs = @helper.addLogs("[Validate] lead:Locations_Interested__c")
        expect(lead[0].fetch('Locations_Interested__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
        passedLogs = @helper.addLogs("[Result  ]  Success")


        puts 'Task details: '
        taskDetails = @objLeadGeneration.fetchTaskDetails(lead.fetch("Id"))
        puts "Task Details: #{taskDetails}"
        expect(taskDetails.fetch("Lead_Source__c")).to eq "WeWork.com"
        #[Select Id, Subject, WhoId FROM Task WHERE WhoId=:lead.id AND SUBJECT ="unreach"];
        expect(taskDetails.fetch("Lead_Source_Detail__c")).to eq "Book A Tour Availability"
        expect(taskDetails.fetch("Locations_Interested__c")).to eq lead.fetch("Locations_Interested__c")
=end

        #@helper.getSalesforceRecord('Lead',"SELECT Id,Name,Email,Owner.Name,CreatedDate FROM #{sObject} WHERE Email LIKE '%@example.com' AND CreatedDate = N_DAYS_AGO: 4 AND IsConverted = False LIMIT 1")
=begin       
        @helper.addLogs('Login To Salesforce')
        @driver.get "https://wework--staging.cs96.my.salesforce.com/?un=kishor.shinde@wework.com.staging&pw=Anujgagare@525255"
        @helper.addLogs('Success')
        
        @helper.addLogs('Search for created Lead')
        @driver.find_element(:id, "phSearchInput").clear
        @driver.find_element(:id, "phSearchInput").send_keys @testDataJSON['CreateLeadFromWeb'][0]['Email']
        @driver.find_element(:id, "phSearchButton").click

        @helper.addLogs('Go to detail page of created lead')
        @driver.find_element(:link, "john.sparrow [not provided]").click

        @helper.addLogs('Checking Fields of lead')
        (@driver.find_element(:id, "lea2_ileinner").text).should == "john.sparrow [not provided]"
        @driver.find_element(:id, "lea11_ileinner").click
        (@driver.find_element(:id, "lea11_ileinner").text).should == @testDataJSON['CreateLeadFromWeb'][0]['Email'] + " [Gmail]"
        @driver.find_element(:id, "RecordType_ileinner").click
        (@driver.find_element(:id, "RecordType_ileinner").text).should == "Consumer [Change]"
        @driver.find_element(:id, "lea13_ileinner").click
        (@driver.find_element(:id, "lea13_ileinner").text).should == "Open"
        (@driver.find_element(:id, "lea3_ileinner").text).should == @testDataJSON['CreateLeadFromWeb'][0]['Name']
        (@driver.find_element(:id, "lea8_ileinner").text).should == "+91-"+ @testDataJSON['CreateLeadFromWeb'][0]['Phone']
        (@driver.find_element(:id, "lea5_ileinner").text).should == "WeWork.com"
        (@driver.find_element(:id, "00NF0000008jx4n_ileinner").text).should == "Book A Tour Availability"
        #(@driver.find_element(:id, "00N0G00000BjVWH_ileinner").text).should == Date.today().to_s
        (@driver.find_element(:id, "CF00NF000000DW8Sn_ileinner").text).should == "MUM-BKC"
        (@driver.find_element(:id, "00NF0000008jx61_ileinner").text).should == "MUM-BKC"
        (@driver.find_element(:id, "00N0G00000DKsrf_ileinner").text).should == "1"
        (@driver.find_element(:id, "lookup0050G000008KcLFlea1").text).should == "Vidu Mangrulkar"
        (@driver.find_element(:id, "lea3_ileinner").text).should == @testDataJSON['CreateLeadFromWeb'][0]['Name']
        (@driver.find_element(:link, "Vidu Mangrulkar").text).should == "Vidu Mangrulkar"
        @helper.addLogs('Go to details apage journey')
        @driver.find_element(:link, "john.sparrow [not provided]-Mumbai-WeWork.com").click
        @helper.addLogs('Checking fields of journey')
        !60.times{ break if (@driver.find_element(:id, "Primary_Email__c").text == @testDataJSON['CreateLeadFromWeb'][0]['Email'] rescue false); sleep 1 }
        (@driver.find_element(:id, "Primary_Email__c").text).should == @testDataJSON['CreateLeadFromWeb'][0]['Email']
        (@driver.find_element(:id, "Primary_Phone__c").text).should == "+91-"+@testDataJSON['CreateLeadFromWeb'][0]['Phone']
        (@driver.find_element(:link, "MUM-BKC").text).should == "MUM-BKC"
        @driver.find_element(:id, "NMD_Next_Contact_Date__c").click
=end
        #@helper.postSuccessResult('2016')
    rescue Exception => e
      raise e
        #@helper.postFailResult(e,'2016')
    end
  end




  it "C:2145 To Check of journey updation on duplicate lead submission, if an open journey already exist in system with created date within 4 days from today.", :'2145'=> 'true' do
    begin
        @helper.addLogs('To check whether generation of lead from Website.','2145')


        @helper.addLogs('Go to Staging website and create lead')

        
        @driver.get "https://www-staging.wework.com/buildings/bkc--mumbai"
        @driver.find_element(:id, "tourFormContactNameField").clear
        @driver.find_element(:id, "tourFormContactNameField").send_keys @testDataJSON['CreateLeadFromWeb'][0]['Name']
        @driver.find_element(:id, "tourFormEmailField").clear
        @testDataJSON['CreateLeadFromWeb'][0]['Email'] = @testDataJSON['CreateLeadFromWeb'][0]['Name'] + SecureRandom.random_number(10000000000).to_s + "@example.com" 
        emailLead = @testDataJSON['CreateLeadFromWeb'][0]['Email']
        @driver.find_element(:id, "tourFormEmailField").send_keys @testDataJSON['CreateLeadFromWeb'][0]['Email']
        @driver.find_element(:id, "tourFormPhoneField").clear
        @driver.find_element(:id, "tourFormPhoneField").send_keys @testDataJSON['CreateLeadFromWeb'][0]['Phone']
        @driver.find_element(:id, "tourFormStepOneSubmitButton").click
        
        @helper.addLogs('Success')


        @helper.addLogs('Go to Staging website and Again create lead with same email Id')
        sleep(10)
        @driver.get "https://www-staging.wework.com/buildings/bkc--mumbai"
        @driver.find_element(:id, "tourFormContactNameField").clear
        @driver.find_element(:id, "tourFormContactNameField").send_keys @testDataJSON['CreateLeadFromWeb'][0]['Name']
        @driver.find_element(:id, "tourFormEmailField").clear
        @testDataJSON['CreateLeadFromWeb'][0]['Email'] = @testDataJSON['CreateLeadFromWeb'][0]['Name'] + SecureRandom.random_number(10000000000).to_s + "@example.com" 
        @driver.find_element(:id, "tourFormEmailField").send_keys emailLead
        @driver.find_element(:id, "tourFormPhoneField").clear
        @driver.find_element(:id, "tourFormPhoneField").send_keys @testDataJSON['CreateLeadFromWeb'][0]['Phone']
        @driver.find_element(:id, "tourFormStepOneSubmitButton").click
        sleep(5)
        @helper.addLogs('Success')
  
        sleep(20)
        
        passedLogs = @helper.addLogs("[Step    ] get building details of #{@testDataJSON['CreateLeadFromWeb'][0]["Building"]}")
        buildingName = @testDataJSON['CreateLeadFromWeb'][0]["Building"]
        building = @helper.getSalesforceRecord('Building__c',"SELECT id,Cluster_Sales_Lead_Name__c,name,Community_Lead__c,Market__c,UUID__C FROM Building__c WHERE Name = '#{buildingName}'")
        expect(building).to_not eq nil
        passedLogs = @helper.addLogs("[Result  ]  Success")


        passedLogs = @helper.addLogs("[Step    ] get Lead details")
        lead  = @helper.getSalesforceRecord('Lead',"SELECT Id,Name,Email,Owner.Name,CreatedDate,Company,Phone,LeadSource,Company_Size__c,Lead_Source_Detail__c,Status,Building_Interested_In__c,Building_Interested_Name__c,Locations_Interested__c,Journey_Created_On__c FROM Lead WHERE Email='#{emailLead}'")
        puts lead
        expect(lead.size == 1).to eq true
        expect(lead[0]).to_not eq nil
        expect(lead[0].fetch('Id')).to_not eq nil
        passedLogs = @helper.addLogs("[Result  ]  Success")


        passedLogs = @helper.addLogs("[Step    ] get Journey details")
        journey  = @helper.getSalesforceRecord('Journey__c',"SELECT Id,Status__c,NMD_Next_Contact_Date__c FROM Journey__c WHERE Primary_Email__c = '#{emailLead}'")
        puts journey
        puts journey.size
        #expect(journey.size == 1).to eq true
        expect(journey[0]).to_not eq nil
        expect(journey[0].fetch('Id')).to_not eq nil
        passedLogs = @helper.addLogs("[Result  ]  Success")

        passedLogs = @helper.addLogs("[Step    ] get Activity details")
        leadId  =lead[0].fetch('Id')
        activity  = @helper.getSalesforceRecord('Task',"Select Id,Owner.Name,Owner.Id, Subject, WhoId, Lead_Source__c, Lead_Source_Detail__c, Locations_Interested__c,Type FROM Task WHERE WhoId = '#{leadId}'")
        puts activity
        puts activity.size
        #expect(activity.size == 1).to eq true
        expect(activity[0]).to_not eq nil
        expect(activity[0].fetch('Id')).to_not eq nil
        passedLogs = @helper.addLogs("[Result  ]  Success")

=begin
        
        passedLogs = @helper.addLogs("[Validate] lead:.Name")
        puts lead[0].fetch('Name')
        #expect(lead[0].fetch('Name')).to eq @testDataJSON['CreateLeadFromWeb'][0]['Name']
        passedLogs = @helper.addLogs("[Result  ]  Success")

        passedLogs = @helper.addLogs("[Validate] lead:Email")
        expect(lead[0].fetch('Email')).to eq @testDataJSON['CreateLeadFromWeb'][0]['Email']
        passedLogs = @helper.addLogs("[Result  ]  Success")

        passedLogs = @helper.addLogs("[Validate] lead:Company")
        expect(lead[0].fetch('Company')).to eq @testDataJSON['CreateLeadFromWeb'][0]['Name']
        passedLogs = @helper.addLogs("[Result  ]  Success")

        passedLogs = @helper.addLogs("[Validate] lead:Phone")
        expect(lead[0].fetch('Phone')).to eq @testDataJSON['CreateLeadFromWeb'][0]['Phone']
        passedLogs = @helper.addLogs("[Result  ]  Success")

        passedLogs = @helper.addLogs("[Validate] lead:LeadSource")
        expect(lead[0].fetch('LeadSource')).to eq "WeWork.com"
        passedLogs = @helper.addLogs("[Result  ]  Success")

        passedLogs = @helper.addLogs("[Validate] lead:Company_Size__c")
        puts lead[0].fetch('Company_Size__c').to_i
        #expect(lead[0].fetch('Company_Size__c').to_i).to eq @testDataJSON['CreateLeadFromWeb'][0]["NumberOfPeople"]}".split(' ')[0].to_i
        passedLogs = @helper.addLogs("[Result  ]  Success")

        passedLogs = @helper.addLogs("[Validate] lead:Lead_Source_Detail__c")
        expect(lead[0].fetch('Lead_Source_Detail__c').to_i).to eq "Book A Tour Availability"
        passedLogs = @helper.addLogs("[Result  ]  Success")

        passedLogs = @helper.addLogs("[Validate] lead:Status")
        expect(lead[0].fetch('Status').to_i).to eq "Open"
        passedLogs = @helper.addLogs("[Result  ]  Success")

        
        passedLogs = @helper.addLogs("[Validate] lead:Building_Interested_In__c")
        expect(lead[0].fetch('Building_Interested_In__c')).to eq "#{building.fetch('Id')}"
        passedLogs = @helper.addLogs("[Result  ]  Success")

        passedLogs = @helper.addLogs("[Validate] lead:Building_Interested_Name__c")
        puts lead[0].fetch('Building_Interested_Name__c')
        #expect(lead[0].fetch('Building_Interested_Name__c')).to eq @testDataJSON['CreateLeadFromWeb'][0]["Building"]
        passedLogs = @helper.addLogs("[Result  ]  Success")

        passedLogs = @helper.addLogs("[Validate] lead:Locations_Interested__c")
        expect(lead[0].fetch('Locations_Interested__c')).to eq @testDataJSON['CreateLeadFromWeb'][0]["Building"]
        passedLogs = @helper.addLogs("[Result  ]  Success")


=end


        #@helper.getSalesforceRecord('Lead',"SELECT Id,Name,Email,Owner.Name,CreatedDate FROM #{sObject} WHERE Email LIKE '%@example.com' AND CreatedDate = N_DAYS_AGO: 4 AND IsConverted = False LIMIT 1")

    rescue Exception => e
      raise e
        #@helper.postFailResult(e,'2016')
    end
  end



  it "C:2146 To check new journey creation if duplicate lead submission happens for existing lead which is created after 4 days and within 30 days from today.", :'2146'=> 'true' do
    begin
        @helper.addLogs('To check new journey creation if duplicate lead submission happens for existing lead which is created after 4 days and within 30 days from today.','2146')


        passedLogs = @helper.addLogs("[Step    ] get details of 4 days ago lead")
        lead = @helper.getSalesforceRecord('Lead',"SELECT Id,Name,Email,Owner.Name,CreatedDate FROM Lead WHERE Email LIKE '%@example.com' AND CreatedDate = N_DAYS_AGO: 4 AND IsConverted = False LIMIT 1")
        puts lead
        
        if (lead[0].fetch('Id') == nil ) then
          @helper.addLogs("Lead not present")
        end
        expect(lead.size == 1).to eq true
        expect(lead[0]).to_not eq nil
        expect(lead[0].fetch('Id')).to_not eq nil
        passedLogs = @helper.addLogs("[Result  ]  Success")


        @helper.addLogs('Go to Staging website and create lead with email id of existing lead created before 4 to 30 days.')

        
        @driver.get "https://www-staging.wework.com/buildings/bkc--mumbai"
        @driver.find_element(:id, "tourFormContactNameField").clear
        @driver.find_element(:id, "tourFormContactNameField").send_keys @testDataJSON['CreateLeadFromWeb'][0]['Name']
        @driver.find_element(:id, "tourFormEmailField").clear
        @testDataJSON['CreateLeadFromWeb'][0]['Email'] = @testDataJSON['CreateLeadFromWeb'][0]['Name'] + SecureRandom.random_number(10000000000).to_s + "@example.com" 
        emailLead = lead[0].fetch('Email')
        @driver.find_element(:id, "tourFormEmailField").send_keys emailLead
        @driver.find_element(:id, "tourFormPhoneField").clear
        @driver.find_element(:id, "tourFormPhoneField").send_keys @testDataJSON['CreateLeadFromWeb'][0]['Phone']
        @driver.find_element(:id, "tourFormStepOneSubmitButton").click
        @helper.addLogs('Success')
  
        sleep(20)
        
        passedLogs = @helper.addLogs("[Step    ] get building details of #{@testDataJSON['CreateLeadFromWeb'][0]["Building"]}")
        buildingName = @testDataJSON['CreateLeadFromWeb'][0]["Building"]
        building = @helper.getSalesforceRecord('Building__c',"SELECT id,Cluster_Sales_Lead_Name__c,name,Community_Lead__c,Market__c,UUID__C FROM Building__c WHERE Name = '#{buildingName}'")
        expect(building).to_not eq nil
        passedLogs = @helper.addLogs("[Result  ]  Success")


        passedLogs = @helper.addLogs("[Step    ] get Lead details")
        lead  = @helper.getSalesforceRecord('Lead',"SELECT Id,Name,Email,Owner.Name,CreatedDate,Company,Phone,LeadSource,Company_Size__c,Lead_Source_Detail__c,Status,Building_Interested_In__c,Building_Interested_Name__c,Locations_Interested__c,Journey_Created_On__c FROM Lead WHERE Email='#{emailLead}'")
        puts lead
        expect(lead.size == 1).to eq true
        expect(lead[0]).to_not eq nil
        expect(lead[0].fetch('Id')).to_not eq nil
        passedLogs = @helper.addLogs("[Result  ]  Success")


        passedLogs = @helper.addLogs("[Step    ] get Journey details")
        journey  = @helper.getSalesforceRecord('Journey__c',"SELECT Id,Status__c,NMD_Next_Contact_Date__c FROM Journey__c WHERE Primary_Email__c = '#{emailLead}'")
        puts journey
        puts journey.size 
        #expect(journey.size == 1).to eq true
        expect(journey[0]).to_not eq nil
        expect(journey[0].fetch('Id')).to_not eq nil
        passedLogs = @helper.addLogs("[Result  ]  Success")


        passedLogs = @helper.addLogs("[Step    ] get Activity details")
        leadId  =lead[0].fetch('Id')
        activity  = @helper.getSalesforceRecord('Task',"Select Id,Owner.Name,Owner.Id, Subject, WhoId, Lead_Source__c, Lead_Source_Detail__c, Locations_Interested__c,Type FROM Task WHERE WhoId = '#{leadId}'")
        puts activity
        puts activity.size
        #expect(activity.size == 1).to eq true
        expect(activity[0]).to_not eq nil
        expect(activity[0].fetch('Id')).to_not eq nil
        passedLogs = @helper.addLogs("[Result  ]  Success")

=begin
        
        passedLogs = @helper.addLogs("[Validate] lead:.Name")
        puts lead[0].fetch('Name')
        #expect(lead[0].fetch('Name')).to eq @testDataJSON['CreateLeadFromWeb'][0]['Name']
        passedLogs = @helper.addLogs("[Result  ]  Success")

        passedLogs = @helper.addLogs("[Validate] lead:Email")
        expect(lead[0].fetch('Email')).to eq @testDataJSON['CreateLeadFromWeb'][0]['Email']
        passedLogs = @helper.addLogs("[Result  ]  Success")

        passedLogs = @helper.addLogs("[Validate] lead:Company")
        expect(lead[0].fetch('Company')).to eq @testDataJSON['CreateLeadFromWeb'][0]['Name']
        passedLogs = @helper.addLogs("[Result  ]  Success")

        passedLogs = @helper.addLogs("[Validate] lead:Phone")
        expect(lead[0].fetch('Phone')).to eq @testDataJSON['CreateLeadFromWeb'][0]['Phone']
        passedLogs = @helper.addLogs("[Result  ]  Success")

        passedLogs = @helper.addLogs("[Validate] lead:LeadSource")
        expect(lead[0].fetch('LeadSource')).to eq "WeWork.com"
        passedLogs = @helper.addLogs("[Result  ]  Success")

        passedLogs = @helper.addLogs("[Validate] lead:Company_Size__c")
        puts lead[0].fetch('Company_Size__c').to_i
        #expect(lead[0].fetch('Company_Size__c').to_i).to eq @testDataJSON['CreateLeadFromWeb'][0]["NumberOfPeople"]}".split(' ')[0].to_i
        passedLogs = @helper.addLogs("[Result  ]  Success")

        passedLogs = @helper.addLogs("[Validate] lead:Lead_Source_Detail__c")
        expect(lead[0].fetch('Lead_Source_Detail__c').to_i).to eq "Book A Tour Availability"
        passedLogs = @helper.addLogs("[Result  ]  Success")

        passedLogs = @helper.addLogs("[Validate] lead:Status")
        expect(lead[0].fetch('Status').to_i).to eq "Open"
        passedLogs = @helper.addLogs("[Result  ]  Success")

        
        passedLogs = @helper.addLogs("[Validate] lead:Building_Interested_In__c")
        expect(lead[0].fetch('Building_Interested_In__c')).to eq "#{building.fetch('Id')}"
        passedLogs = @helper.addLogs("[Result  ]  Success")

        passedLogs = @helper.addLogs("[Validate] lead:Building_Interested_Name__c")
        puts lead[0].fetch('Building_Interested_Name__c')
        #expect(lead[0].fetch('Building_Interested_Name__c')).to eq @testDataJSON['CreateLeadFromWeb'][0]["Building"]
        passedLogs = @helper.addLogs("[Result  ]  Success")

        passedLogs = @helper.addLogs("[Validate] lead:Locations_Interested__c")
        expect(lead[0].fetch('Locations_Interested__c')).to eq @testDataJSON['CreateLeadFromWeb'][0]["Building"]
        passedLogs = @helper.addLogs("[Result  ]  Success")


=end


        #@helper.getSalesforceRecord('Lead',"SELECT Id,Name,Email,Owner.Name,CreatedDate FROM #{sObject} WHERE Email LIKE '%@example.com' AND CreatedDate = N_DAYS_AGO: 4 AND IsConverted = False LIMIT 1")

    rescue Exception => e
      raise e
        #@helper.postFailResult(e,'2016')
    end
  end



  it "C:2147 To check new journey creation if duplicate lead submission happens for existing lead which is created after 4 days and within 30 days from today.", :'2147'=> 'true' do
    begin
        @helper.addLogs('To check new journey creation if duplicate lead submission happens for existing lead which is created after 30 days from today.','2147')


        passedLogs = @helper.addLogs("[Step    ] get details of 30 days ago lead")
        lead = @helper.getSalesforceRecord('Lead',"select id,Name,createdDate,IsConverted from Lead where Email like  '%@example.com%' AND createdDate = LAST_N_DAYS:30 And IsConverted= false LIMIT 1")
        puts lead
        
        if (lead[0] == nil ) then
          @helper.addLogs("Lead not present")
        end
        expect(lead.size == 1).to eq true
        expect(lead[0]).to_not eq nil
        expect(lead[0].fetch('Id')).to_not eq nil
        passedLogs = @helper.addLogs("[Result  ]  Success")


        @helper.addLogs('Go to Staging website and create lead with email id of existing lead created before 4 to 30 days.')

        
        @driver.get "https://www-staging.wework.com/buildings/bkc--mumbai"
        @driver.find_element(:id, "tourFormContactNameField").clear
        @driver.find_element(:id, "tourFormContactNameField").send_keys @testDataJSON['CreateLeadFromWeb'][0]['Name']
        @driver.find_element(:id, "tourFormEmailField").clear
        @testDataJSON['CreateLeadFromWeb'][0]['Email'] = @testDataJSON['CreateLeadFromWeb'][0]['Name'] + SecureRandom.random_number(10000000000).to_s + "@example.com" 
        emailLead = lead[0].fetch('Email')
        @driver.find_element(:id, "tourFormEmailField").send_keys emailLead
        @driver.find_element(:id, "tourFormPhoneField").clear
        @driver.find_element(:id, "tourFormPhoneField").send_keys @testDataJSON['CreateLeadFromWeb'][0]['Phone']
        @driver.find_element(:id, "tourFormStepOneSubmitButton").click
        @helper.addLogs('Success')
  
        sleep(20)
        
        passedLogs = @helper.addLogs("[Step    ] get building details of #{@testDataJSON['CreateLeadFromWeb'][0]["Building"]}")
        buildingName = @testDataJSON['CreateLeadFromWeb'][0]["Building"]
        building = @helper.getSalesforceRecord('Building__c',"SELECT id,Cluster_Sales_Lead_Name__c,name,Community_Lead__c,Market__c,UUID__C FROM Building__c WHERE Name = '#{buildingName}'")
        expect(building).to_not eq nil
        passedLogs = @helper.addLogs("[Result  ]  Success")


        passedLogs = @helper.addLogs("[Step    ] get Lead details")
        lead  = @helper.getSalesforceRecord('Lead',"SELECT Id,Name,Email,Owner.Name,CreatedDate,Company,Phone,LeadSource,Company_Size__c,Lead_Source_Detail__c,Status,Building_Interested_In__c,Building_Interested_Name__c,Locations_Interested__c,Journey_Created_On__c FROM Lead WHERE Email='#{emailLead}'")
        puts lead
        expect(lead.size == 1).to eq true
        expect(lead[0]).to_not eq nil
        expect(lead[0].fetch('Id')).to_not eq nil
        passedLogs = @helper.addLogs("[Result  ]  Success")


        passedLogs = @helper.addLogs("[Step    ] get Journey details")
        journey  = @helper.getSalesforceRecord('Journey__c',"SELECT Id,Status__c,NMD_Next_Contact_Date__c FROM Journey__c WHERE Primary_Email__c = '#{emailLead}'")
        puts journey
        puts journey.size 
        #expect(journey.size == 1).to eq true
        expect(journey[0]).to_not eq nil
        expect(journey[0].fetch('Id')).to_not eq nil
        passedLogs = @helper.addLogs("[Result  ]  Success")


        passedLogs = @helper.addLogs("[Step    ] get Activity details")
        leadId  =lead[0].fetch('Id')
        activity  = @helper.getSalesforceRecord('Task',"Select Id,Owner.Name,Owner.Id, Subject, WhoId, Lead_Source__c, Lead_Source_Detail__c, Locations_Interested__c,Type FROM Task WHERE WhoId = '#{leadId}'")
        puts activity
        puts activity.size
        #expect(activity.size == 1).to eq true
        expect(activity[0]).to_not eq nil
        expect(activity[0].fetch('Id')).to_not eq nil
        passedLogs = @helper.addLogs("[Result  ]  Success")

=begin
        
        passedLogs = @helper.addLogs("[Validate] lead:.Name")
        puts lead[0].fetch('Name')
        #expect(lead[0].fetch('Name')).to eq @testDataJSON['CreateLeadFromWeb'][0]['Name']
        passedLogs = @helper.addLogs("[Result  ]  Success")

        passedLogs = @helper.addLogs("[Validate] lead:Email")
        expect(lead[0].fetch('Email')).to eq @testDataJSON['CreateLeadFromWeb'][0]['Email']
        passedLogs = @helper.addLogs("[Result  ]  Success")

        passedLogs = @helper.addLogs("[Validate] lead:Company")
        expect(lead[0].fetch('Company')).to eq @testDataJSON['CreateLeadFromWeb'][0]['Name']
        passedLogs = @helper.addLogs("[Result  ]  Success")

        passedLogs = @helper.addLogs("[Validate] lead:Phone")
        expect(lead[0].fetch('Phone')).to eq @testDataJSON['CreateLeadFromWeb'][0]['Phone']
        passedLogs = @helper.addLogs("[Result  ]  Success")

        passedLogs = @helper.addLogs("[Validate] lead:LeadSource")
        expect(lead[0].fetch('LeadSource')).to eq "WeWork.com"
        passedLogs = @helper.addLogs("[Result  ]  Success")

        passedLogs = @helper.addLogs("[Validate] lead:Company_Size__c")
        puts lead[0].fetch('Company_Size__c').to_i
        #expect(lead[0].fetch('Company_Size__c').to_i).to eq @testDataJSON['CreateLeadFromWeb'][0]["NumberOfPeople"]}".split(' ')[0].to_i
        passedLogs = @helper.addLogs("[Result  ]  Success")

        passedLogs = @helper.addLogs("[Validate] lead:Lead_Source_Detail__c")
        expect(lead[0].fetch('Lead_Source_Detail__c').to_i).to eq "Book A Tour Availability"
        passedLogs = @helper.addLogs("[Result  ]  Success")

        passedLogs = @helper.addLogs("[Validate] lead:Status")
        expect(lead[0].fetch('Status').to_i).to eq "Open"
        passedLogs = @helper.addLogs("[Result  ]  Success")

        
        passedLogs = @helper.addLogs("[Validate] lead:Building_Interested_In__c")
        expect(lead[0].fetch('Building_Interested_In__c')).to eq "#{building.fetch('Id')}"
        passedLogs = @helper.addLogs("[Result  ]  Success")

        passedLogs = @helper.addLogs("[Validate] lead:Building_Interested_Name__c")
        puts lead[0].fetch('Building_Interested_Name__c')
        #expect(lead[0].fetch('Building_Interested_Name__c')).to eq @testDataJSON['CreateLeadFromWeb'][0]["Building"]
        passedLogs = @helper.addLogs("[Result  ]  Success")

        passedLogs = @helper.addLogs("[Validate] lead:Locations_Interested__c")
        expect(lead[0].fetch('Locations_Interested__c')).to eq @testDataJSON['CreateLeadFromWeb'][0]["Building"]
        passedLogs = @helper.addLogs("[Result  ]  Success")


=end


        #@helper.getSalesforceRecord('Lead',"SELECT Id,Name,Email,Owner.Name,CreatedDate FROM #{sObject} WHERE Email LIKE '%@example.com' AND CreatedDate = N_DAYS_AGO: 4 AND IsConverted = False LIMIT 1")

    rescue Exception => e
      raise e
        #@helper.postFailResult(e,'2016')
    end
  end



  it "C:2149 To Check New Journey creation if duplicate lead submission happens for existing contact which is created within 30 days from today when the existing contact has permission to create a journey.", :'2149'=> 'true' do
    begin
        @helper.addLogs('To Check New Journey creation if duplicate lead submission happens for existing contact which is created within 30 days from today when the existing contact has permission to create a journey.','2149')


        users = @helper.getSalesforceRecord('Setting__c',"select Data__c from Setting__c Where Name = 'User/Queue Journey Creation'")

        puts users
        puts users[0].fetch('Data__c')
        userIds = JSON.parse(users[0].fetch('Data__c'))
        puts userIds['allowedUsers']

        arrayOfUsers = []
        userIds['allowedUsers'].each do |user|
            puts user
            arrayOfUsers.push(user['Id'])
        end


        puts arrayOfUsers

=begin
        if users[0].fetch('Data__c') != nil then
            puts 'accQueue present'
            members = []
            i = 0


            users[0].fetch('Data__c').each do |item|
              
            end
          until users[0]ecords[i] == nil do
            members.push(accQueue.result.records[i].fetch('Member__c'))
            i = i + 1
          end
      return members

=end        

        passedLogs = @helper.addLogs("[Step    ] get details of 30 days ago Contact")
        contacts = @helper.getSalesforceRecord('Contact',"select id,Name,createdDate,Account.Id,Looking_For_Number_Of_Desk__c,Owner.Id,Owner.Name,RecordType.Name,Number_of_Full_Time_Employees__c,Email,Interested_in_Number_of_Desks__c from Contact where Email like  '%@example.com%' AND createdDate = LAST_N_DAYS:30")
        puts contacts

        contactToTest = nil
        contacts.each do |contact|
            if arrayOfUsers.include? contact.fetch('Owner.Id') then
                puts "User has permission #{contact}"
                puts contact
                contactToTest = contact
                break;
            else
                puts "No users having permission to create journey"
                raise e "No Users found"
            end
        end

        
        if (contactToTest.fetch('Id') == nil ) then
          @helper.addLogs("Contact not present")
        end
        expect(contactToTest).to_not eq nil
        expect(contactToTest.fetch('Id')).to_not eq nil
        passedLogs = @helper.addLogs("[Result  ]  Success")

=begin
        @helper.addLogs('Go to Staging website and create lead with email id of existing contact created within 30 days.')

        
        @driver.get "https://www-staging.wework.com/buildings/bkc--mumbai"
        @driver.find_element(:id, "tourFormContactNameField").clear
        @driver.find_element(:id, "tourFormContactNameField").send_keys @testDataJSON['CreateLeadFromWeb'][0]['Name']
        @driver.find_element(:id, "tourFormEmailField").clear
        @testDataJSON['CreateLeadFromWeb'][0]['Email'] = @testDataJSON['CreateLeadFromWeb'][0]['Name'] + SecureRandom.random_number(10000000000).to_s + "@example.com" 
        emailId = contact[0].fetch('Email')
        @driver.find_element(:id, "tourFormEmailField").send_keys emailId
        @driver.find_element(:id, "tourFormPhoneField").clear
        @driver.find_element(:id, "tourFormPhoneField").send_keys @testDataJSON['CreateLeadFromWeb'][0]['Phone']
        @driver.find_element(:id, "tourFormStepOneSubmitButton").click
        @helper.addLogs('Success')
  
        sleep(20)
        
        passedLogs = @helper.addLogs("[Step    ] get building details of #{@testDataJSON['CreateLeadFromWeb'][0]["Building"]}")
        buildingName = @testDataJSON['CreateLeadFromWeb'][0]["Building"]
        building = @helper.getSalesforceRecord('Building__c',"SELECT id,Cluster_Sales_Lead_Name__c,name,Community_Lead__c,Market__c,UUID__C FROM Building__c WHERE Name = '#{buildingName}'")
        expect(building).to_not eq nil
        passedLogs = @helper.addLogs("[Result  ]  Success")


        
        passedLogs = @helper.addLogs("[Step    ] get Journey details")
        journey  = @helper.getSalesforceRecord('Journey__c',"SELECT Id,Status__c,NMD_Next_Contact_Date__c FROM Journey__c WHERE Primary_Email__c = '#{emailId}'")
        puts journey
        puts journey.size 
        #expect(journey.size == 1).to eq true
        expect(journey[0]).to_not eq nil
        expect(journey[0].fetch('Id')).to_not eq nil
        passedLogs = @helper.addLogs("[Result  ]  Success")


        passedLogs = @helper.addLogs("[Step    ] get Activity details")
        leadId  =contact[0].fetch('Id')
        activity  = @helper.getSalesforceRecord('Task',"Select Id,Owner.Name,Owner.Id, Subject, WhoId, Lead_Source__c, Lead_Source_Detail__c, Locations_Interested__c,Type FROM Task WHERE WhoId = '#{leadId}'")
        puts activity
        puts activity.size
        #expect(activity.size == 1).to eq true
        expect(activity[0]).to_not eq nil
        expect(activity[0].fetch('Id')).to_not eq nil
        passedLogs = @helper.addLogs("[Result  ]  Success")
=end

=begin
        
        passedLogs = @helper.addLogs("[Validate] lead:.Name")
        puts lead[0].fetch('Name')
        #expect(lead[0].fetch('Name')).to eq @testDataJSON['CreateLeadFromWeb'][0]['Name']
        passedLogs = @helper.addLogs("[Result  ]  Success")

        passedLogs = @helper.addLogs("[Validate] lead:Email")
        expect(lead[0].fetch('Email')).to eq @testDataJSON['CreateLeadFromWeb'][0]['Email']
        passedLogs = @helper.addLogs("[Result  ]  Success")

        passedLogs = @helper.addLogs("[Validate] lead:Company")
        expect(lead[0].fetch('Company')).to eq @testDataJSON['CreateLeadFromWeb'][0]['Name']
        passedLogs = @helper.addLogs("[Result  ]  Success")

        passedLogs = @helper.addLogs("[Validate] lead:Phone")
        expect(lead[0].fetch('Phone')).to eq @testDataJSON['CreateLeadFromWeb'][0]['Phone']
        passedLogs = @helper.addLogs("[Result  ]  Success")

        passedLogs = @helper.addLogs("[Validate] lead:LeadSource")
        expect(lead[0].fetch('LeadSource')).to eq "WeWork.com"
        passedLogs = @helper.addLogs("[Result  ]  Success")

        passedLogs = @helper.addLogs("[Validate] lead:Company_Size__c")
        puts lead[0].fetch('Company_Size__c').to_i
        #expect(lead[0].fetch('Company_Size__c').to_i).to eq @testDataJSON['CreateLeadFromWeb'][0]["NumberOfPeople"]}".split(' ')[0].to_i
        passedLogs = @helper.addLogs("[Result  ]  Success")

        passedLogs = @helper.addLogs("[Validate] lead:Lead_Source_Detail__c")
        expect(lead[0].fetch('Lead_Source_Detail__c').to_i).to eq "Book A Tour Availability"
        passedLogs = @helper.addLogs("[Result  ]  Success")

        passedLogs = @helper.addLogs("[Validate] lead:Status")
        expect(lead[0].fetch('Status').to_i).to eq "Open"
        passedLogs = @helper.addLogs("[Result  ]  Success")

        
        passedLogs = @helper.addLogs("[Validate] lead:Building_Interested_In__c")
        expect(lead[0].fetch('Building_Interested_In__c')).to eq "#{building.fetch('Id')}"
        passedLogs = @helper.addLogs("[Result  ]  Success")

        passedLogs = @helper.addLogs("[Validate] lead:Building_Interested_Name__c")
        puts lead[0].fetch('Building_Interested_Name__c')
        #expect(lead[0].fetch('Building_Interested_Name__c')).to eq @testDataJSON['CreateLeadFromWeb'][0]["Building"]
        passedLogs = @helper.addLogs("[Result  ]  Success")

        passedLogs = @helper.addLogs("[Validate] lead:Locations_Interested__c")
        expect(lead[0].fetch('Locations_Interested__c')).to eq @testDataJSON['CreateLeadFromWeb'][0]["Building"]
        passedLogs = @helper.addLogs("[Result  ]  Success")


=end


        #@helper.getSalesforceRecord('Lead',"SELECT Id,Name,Email,Owner.Name,CreatedDate FROM #{sObject} WHERE Email LIKE '%@example.com' AND CreatedDate = N_DAYS_AGO: 4 AND IsConverted = False LIMIT 1")

    rescue Exception => e
      raise e
        #@helper.postFailResult(e,'2016')
    end
  end

  it "test_c2146", :'214'=> 'true' do
    begin
        @helper.addLogs('To check whether generation of lead from Website.','2016')
        @helper.addLogs('Go to Staging website and create lead')

        
        @driver.get "https://www-staging.wework.com/buildings/bkc--mumbai"
        @driver.find_element(:id, "tourFormContactNameField").clear
        @driver.find_element(:id, "tourFormContactNameField").send_keys @testDataJSON['CreateLeadFromWeb'][0]['Name']
        @driver.find_element(:id, "tourFormEmailField").clear
        @testDataJSON['CreateLeadFromWeb'][0]['Email'] = @testDataJSON['CreateLeadFromWeb'][0]['Name'] + SecureRandom.random_number(10000000000).to_s + "@example.com" 
        puts @testDataJSON['CreateLeadFromWeb'][0]['Email']
        @driver.find_element(:id, "tourFormEmailField").send_keys @testDataJSON['CreateLeadFromWeb'][0]['Email']
        @driver.find_element(:id, "tourFormPhoneField").clear
        @driver.find_element(:id, "tourFormPhoneField").send_keys @testDataJSON['CreateLeadFromWeb'][0]['Phone']
        @driver.find_element(:id, "tourFormStepOneSubmitButton").click
        sleep(10)
        @helper.addLogs('Success')


        emailLead = @testDataJSON['CreateLeadFromWeb'][0]['Email']
        lead = @helper.getSalesforceRecord('Lead',"SELECT Id,Email,LeadSource,Lead_Source_Detail__c,isConverted,Name,Owner.Id FROM Lead WHERE email = '#{emailLead}'")
        
        puts "Checking lead details"
        puts lead

        journey = @helper.getSalesforceRecord('Journey__c',"SELECT id FROM Journey__c WHERE Primary_Email__c = '#{emailLead}'")
        

        puts "checking journey fields"
        puts journey
        
        @helper.postSuccessResult('2016')
      rescue Exception => e
        #@helper.postFailResult(e,'2016')
      end
    end

  it "test_to_check_new_journey_creation_if_duplicate_lead_submission_happens_for_existing_lead_which_is_created_within 4 to 30 days_from_today", :'21471212'=> 'true' do
   
   begin

      #SELECT Id,Name,Email,Owner.Name,CreatedDate FROM #{sObject} WHERE Email LIKE '%@example.com' AND CreatedDate = N_DAYS_AGO: #{daysAgo} AND IsConverted = False LIMIT 1

       #lead = @helper.getSalesforceRecord('Lead',"SELECT Id,Name,Email,Owner.Name,CreatedDate FROM Lead WHERE Email LIKE '%@example.com' AND CreatedDate = N_DAYS_AGO: 4 AND IsConverted = False LIMIT 1")
       #if lead[0].fetch('Id') != nil then

       #else
       # puts "No leads found creted within 4 to 30"
       #end
       @driver.get "https://www-staging.wework.com/"
       @driver.find_element(:name, "market").click
       @driver.find_element(:xpath, "//div[@id='wework']/div/div[2]/main/section/div/div").click
       @driver.find_element(:xpath, "//div[@id='wework']/div/div[2]/main/section/div/div/div/div/div[3]/form/div[2]/div/div/label/span").click
       @driver.find_element(:xpath, "//div[@id='wework']/div/div[2]/main/section/div/div/div/div/div[3]/form/button/span").click
       @driver.find_element(:xpath, "//div[@id='wework']/div/div[2]/main/div[2]/div/div/section/div/div[2]/div/div/div/div[2]/div/div/div[2]/button").click
       @driver.find_element(:id, "tourFormContactNameField").click
       @driver.find_element(:id, "tourFormContactNameField").clear
       @driver.find_element(:id, "tourFormContactNameField").send_keys @testDataJSON['CreateLeadFromWeb'][0]['Name']
       @driver.find_element(:id, "tourFormEmailField").clear
       @testDataJSON['CreateLeadFromWeb'][0]['Email'] = @testDataJSON['CreateLeadFromWeb'][0]['Name'] + SecureRandom.random_number(10000000000).to_s + "@example.com" 
       @driver.find_element(:id, "tourFormEmailField").send_keys @testDataJSON['CreateLeadFromWeb'][0]['Email']

       @driver.find_element(:id, "tourFormPhoneField").clear
       @driver.find_element(:id, "tourFormPhoneField").send_keys @testDataJSON['CreateLeadFromWeb'][0]['Phone']
       @driver.find_element(:name, "move_in_time_frame").click
       @driver.find_element(:name, "move_in_time_frame").click
       @driver.find_element(:name, "desired_capacity").click
       @driver.find_element(:name, "desired_capacity").click
       @driver.find_element(:id, "tourFormStepOneSubmitButton").click
       sleep(20)
       @driver.get "https://wework--staging.cs96.my.salesforce.com/?un=ashutosh.thakur@wework.com.staging&pw=Ashu@12345"
       @driver.find_element(:id, "phSearchInput").click
       @driver.find_element(:id, "phSearchInput").clear
       @driver.find_element(:id, "phSearchInput").send_keys @testDataJSON['CreateLeadFromWeb'][0]['Email']
       @driver.find_element(:id, "phSearchButton").click
       puts "go to activity"
       @driver.find_element(:link, "Inbound Lead submission").click
       (@driver.find_element(:id, "tsk10_ileinner").text).should == "Website"
       (@driver.find_element(:id, "tsk5_ileinner").text).should == "Inbound Lead submission"
       (@driver.find_element(:id, "tsk12_ileinner").text).should == "Not Started"
       (@driver.find_element(:id, "00NF000000CsL9a_ileinner").text).should == "WeWork.com"
       (@driver.find_element(:id, "00NF000000CsL9f_ilecell").text).should == "Book A Tour Availability"
       (@driver.find_element(:id, "00NF000000DSUHp_ileinner").text).should == "MUM-BKC"
       @driver.find_element(:id, "lookup00Q1g000002Cfcftsk2").click
       @driver.find_element(:link, "hortensebeer201805020821210000 [not provided]-Mumbai-WeWork.com").click
       @driver.find_element(:xpath, "//div[@id='127:2;a']/div/div[4]/div/div/div[2]/div[3]/div[2]/button/lightning-primitive-icon").click
       (@driver.find_element(:id, "Status__c").text).should == "Select Journey StatusCompletedIn ContactNo ContactNurtureStartedTransferredTrying to ReachUnqualifiedUnresponsive"
       @driver.find_element(:xpath, "//div[@id='127:2;a']/div/div[4]/div[4]/div/div/div[3]/div[2]/button/lightning-primitive-icon").click
       (@driver.find_element(:id, "NMD_Next_Contact_Date__c").attribute("value")).should == "05/09/2018"
       (@driver.find_element(:link, "Vidu Mangrulkar").text).should == "Vidu Mangrulkar"
       @helper.postSuccessResult(2146)
     rescue Exception => e
       @helper.postFailResult(e,'2146')
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

  puts "33333"
end
