#require "json"
require "selenium-webdriver"
require "rspec"
#require_relative File.expand_path('',Dir.pwd )+"/specHelper.rb"
require_relative File.expand_path('..',Dir.pwd )+"/specHelper.rb"
require_relative '../PageObjects/leadGeneration.rb'
include RSpec::Expectations

describe "LeadGenerete" do

    before(:all) do
        @helper = Helper.new
        @driver = Selenium::WebDriver.for :chrome
        #@driver = ARGV[0]
        @testDataJSON = @helper.getRecordJSON()
        @objLeadGeneration = LeadGeneration.new(@driver,@helper)
        
        @accept_next_alert = true
        @driver.manage.timeouts.implicit_wait = 30
        @verification_errors = []
    end

    before(:each) do
        puts ""
        puts "----------------------------------------------------------------------------------"
    end

    after(:each) do
        puts "----------------------------------------------------------------------------------"
    end

    after(:all) do
        @driver.quit
        @verification_errors.should == []
        #@helper.deleteSalesforceRecordBySfbulk("Journey__c", EnziRestforce.class_variable_get(:@@createdRecordsIds)["Journey__c"])
        #@helper.deleteSalesforceRecordBySfbulk("Lead", EnziRestforce.class_variable_get(:@@createdRecordsIds)["Lead"])

    end

context "LeadFromStanderdSalesforce" do

#MLP
    it "C:2570 To check lead is assigned to proper 'User' from lead assignment rule for 'Consumer' record type and journey,activity should be created for that lead.", :'2570' => 'true' do
        begin
            @helper.addLogs("C:2570 To check lead is assigned to proper 'User' from lead assignment rule for 'Consumer' record type and journey,activity should be created for that lead.",'2570')
            
            @testDataJSON['MarketingLandingPage'][0]['Email'] = @testDataJSON['MarketingLandingPage'][0]['Name'] + SecureRandom.random_number(10000000000).to_s + "@example.com"
            @testDataJSON['Campaign'][0]['Name'] = '2018-03-RM-DC-Multi-Touch-Direct-Mail-Apollo'
            @testDataJSON['Campaign'][0]['Lead Owner'] = '0051g000000tSCu'
            @testDataJSON['Campaign'][0]['Email Address'] = ''
            @testDataJSON['Campaign'][0]['City'] = ''

            @testDataJSON['Lead'][0]['leadSource'] = 'WeWork.com'
            @testDataJSON['Lead'][0]['lead_Source_Detail__c'] = 'Marketing Landing Page'
            @testDataJSON['Lead'][0]['RecordType'] = 'Consumer'
            @testDataJSON['Lead'][0]['Lead Status'] = 'Open'
            @testDataJSON['Lead'][0]['Type'] = 'Office Space'
            @testDataJSON['Lead'][0]['Email Quality'] = 'Pending'
            @testDataJSON['Lead'][0]['Locale'] = 'en-US' 
            @testDataJSON['Lead'][0]['Country Code'] = 'IN' 
            @testDataJSON['Lead'][0]['Product Line'] = 'WeWork' 
            @testDataJSON['Lead'][0]['Marketing Consent'] = true 
            @testDataJSON['Lead'][0]['Ts and Cs Consent'] = false

            @helper.addLogs("[Step ]     : Fetch camapign deatails")            
            campaignInfo = @objLeadGeneration.fetchCampaignDetails('Name',@testDataJSON['Campaign'][0]['Name'])
            expect(campaignInfo).to_not eq nil
            expect(campaignInfo.size).to eq 1
            expect(campaignInfo[0]).to_not eq nil  
            campaignInfo =  campaignInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Update campaign")
            expect(@objLeadGeneration.update_campaign(campaignInfo.fetch('Id'),@testDataJSON['Campaign'][0]['Lead Owner'],@testDataJSON['Campaign'][0]['Email Address'],@testDataJSON['Campaign'][0]['City'])).to eq true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Create lead from Marketing Landing Page")
            expect(@objLeadGeneration.createLeadFromMarketingPage).to eq true
            @helper.addLogs("[Validate ] : Checking Lead is created after form submission")
            @helper.addLogs("[Expected ] : Lead should create with email #{@testDataJSON['MarketingLandingPage'][0]['Email']}")

            @helper.addLogs("[Step ]     : Check lead inserted into camapign")
            expect(@objLeadGeneration.checkCamapignMember(@testDataJSON['MarketingLandingPage'][0]['Email'],campaignInfo.fetch('Id'))).to eq true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Fetch lead deatails")            
            insertedLeadInfo = @objLeadGeneration.fetchLeadDetails(@testDataJSON['MarketingLandingPage'][0]['Email'])
            expect(insertedLeadInfo).to_not eq nil
            expect(insertedLeadInfo.size).to eq 1
            expect(insertedLeadInfo[0]).to_not eq nil  
            insertedLeadInfo =  insertedLeadInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Fetch camapign deatails")
            owner = @objLeadGeneration.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
            expect(owner).to_not eq nil
            @helper.addLogs("[Result ]   : Success\n")

            expectedOwner = owner 

            #lead fields
            #Name --
            #Owner --
            #Email --
            #Comapny --
            #Phone  --
            #LeadSource --
            #LeadSourceDetails --
            #recordType --
            #Org identification status
            #Status --
            #Has active journey --
            #email quality --
            #Journey Created on --
            #Marketing Consent --
            #Ts and Cs Consent  --
            #Interested in Number of Desk(s) --
            #Interested in Number of Desks Range --
            #Interested in Number of Desks Min  --
            #Interested in Number of Desks Max --
            #Product Line  --
            #type  --
            #Local --
            #country code  --
            #generate journey --


            #journey fields
            #name --
            #Owner --
            #status --
            #Email --
            #Customer
            #Primary Lead  --
            #Phone --
            #Comapny Name  --
            #Looking for no of desk  --
            #lead source --
            #lead source details  --
            #Record type --
            #campaign --
            #Next contact date --
            #Marketing Consent  --
            #Ts and Cs consent --

            #activity fields
            #Type
            #assigned to field
            #subject
            #priority
            #Name
            #status
            #Lead source
            #Lead source detail
            #phone
            
            @helper.addLogs("[Validate ] : Checking Lead name")
            @helper.addLogs("[Expected ] : #{@testDataJSON['MarketingLandingPage'][0]['Name']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Name")}")            
            expect(insertedLeadInfo.fetch("Name")).to match("#{@testDataJSON['MarketingLandingPage'][0]['Name']}")
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead owner should be According to Lead Assignment Rule")
            @helper.addLogs("[Expected ] : #{expectedOwner}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Owner").fetch("Id")}")            
            expect(insertedLeadInfo.fetch("Owner").fetch("Id")).to match("#{expectedOwner}")
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Generate_Journey__c")
            @helper.addLogs("[Expected ] : false")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Generate_Journey__c")}")
            expect(insertedLeadInfo.fetch("Generate_Journey__c")).to eql false
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Has_Active_Journey__c")
            @helper.addLogs("[Expected ] : true")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Has_Active_Journey__c")}")
            expect(insertedLeadInfo.fetch("Has_Active_Journey__c")).to eql true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead source")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['leadSource']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("LeadSource")}")
            expect(insertedLeadInfo.fetch("LeadSource")).to eql @testDataJSON['Lead'][0]['leadSource']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead source details")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['lead_Source_Detail__c']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Lead_Source_Detail__c")}")
            expect(insertedLeadInfo.fetch("Lead_Source_Detail__c")).to eql @testDataJSON['Lead'][0]['lead_Source_Detail__c']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Journey created date on lead")
            @helper.addLogs("[Expected ] : #{Date.today}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Journey_Created_On__c")}")
            expect(insertedLeadInfo.fetch("Journey_Created_On__c")).to eql Date.today.to_s
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Interested in Number of Desks on lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['MarketingLandingPage'][0]['I need space for'].split('-')[0]}.0")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch('Interested_in_Number_of_Desks__c')}")
            expect(insertedLeadInfo.fetch("Interested_in_Number_of_Desks__c").to_i).to eql "#{@testDataJSON['MarketingLandingPage'][0]['I need space for'].split('-')[0]}".to_i
            @helper.addLogs("[Result ]   : Success\n")
            
            @helper.addLogs("[Validate ] : Checking Email on lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['MarketingLandingPage'][0]['Email']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Email")}")
            expect(insertedLeadInfo.fetch("Email")).to eql @testDataJSON['MarketingLandingPage'][0]['Email']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Phone on lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['MarketingLandingPage'][0]['Phone']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Phone")}")
            expect(insertedLeadInfo.fetch("Phone")).to match('8888888888')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Company on lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['MarketingLandingPage'][0]['Company']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Company")}")
            expect(insertedLeadInfo.fetch("Company")).to eql @testDataJSON['MarketingLandingPage'][0]['Company']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking RecordType on lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['RecordType']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("RecordType").fetch("Name")}")
            expect(insertedLeadInfo.fetch("RecordType").fetch("Name")).to eql @testDataJSON['Lead'][0]['RecordType']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Status on lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Lead Status']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Status")}")
            expect(insertedLeadInfo.fetch("Status")).to eql @testDataJSON['Lead'][0]['Lead Status']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Type on lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Type']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Type__c")}")
            expect(insertedLeadInfo.fetch("Type__c")).to eql @testDataJSON['Lead'][0]['Type']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Type on lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Email Quality']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Email_Quality__c")}")
            expect(insertedLeadInfo.fetch("Email_Quality__c")).to eql @testDataJSON['Lead'][0]['Email Quality']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Marketing_Consent__c on lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Marketing Consent']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Marketing_Consent__c")}")
            expect(insertedLeadInfo.fetch("Marketing_Consent__c")).to eql @testDataJSON['Lead'][0]['Marketing Consent']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Ts_and_Cs_Consent__c on lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Ts and Cs Consent']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Ts_and_Cs_Consent__c")}")
            expect(insertedLeadInfo.fetch("Ts_and_Cs_Consent__c")).to eql @testDataJSON['Lead'][0]['Ts and Cs Consent']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Interested_in_Number_of_Desks_Range__c on lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['MarketingLandingPage'][0]['I need space for'].split(' ')[0]}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Interested_in_Number_of_Desks_Range__c")}")
            expect(insertedLeadInfo.fetch("Interested_in_Number_of_Desks_Range__c")).to eql @testDataJSON['MarketingLandingPage'][0]['I need space for'].split('-')[0] + ' - '+ @testDataJSON['MarketingLandingPage'][0]['I need space for'].split('-')[1].split(' ')[0]
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Interested_in_Number_of_Desks_Min__c on lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['MarketingLandingPage'][0]['I need space for'].split('-')[0]}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Interested_in_Number_of_Desks_Min__c")}")
            expect(insertedLeadInfo.fetch("Interested_in_Number_of_Desks_Min__c").to_i).to eql @testDataJSON['MarketingLandingPage'][0]['I need space for'].split('-')[0].to_i
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Interested_in_Number_of_Desks_Max__c on lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['MarketingLandingPage'][0]['I need space for'].split('-')[1].split(' ')[0]}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Interested_in_Number_of_Desks_Max__c")}")
            expect(insertedLeadInfo.fetch("Interested_in_Number_of_Desks_Max__c").to_i).to eql @testDataJSON['MarketingLandingPage'][0]['I need space for'].split('-')[1].split(' ')[0].to_i
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Product_Line__c on lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Product Line']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Product_Line__c")}")
            expect(insertedLeadInfo.fetch("Product_Line__c")).to eql @testDataJSON['Lead'][0]['Product Line']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Locale__c on lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Locale']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Locale__c")}")
            expect(insertedLeadInfo.fetch("Locale__c")).to eql @testDataJSON['Lead'][0]['Locale']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Country_Code__c on lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Country Code']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Country_Code__c")}")
            expect(insertedLeadInfo.fetch("Country_Code__c")).to eql @testDataJSON['Lead'][0]['Country Code']
            @helper.addLogs("[Result ]   : Success\n")

            puts "********************************************************"

            @helper.addLogs("[Step ]     : Fetch journey deatails")            
            insertedJourneyInfo = @objLeadGeneration.fetchJourneyDetails(insertedLeadInfo.fetch("Email"))
            expect(insertedJourneyInfo).to_not eq nil
            expect(insertedJourneyInfo.size).to eq 1
            expect(insertedJourneyInfo[0]).to_not eq nil  
            insertedJourneyInfo =  insertedJourneyInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Journey Name")
            @helper.addLogs("[Expected ] : #{@testDataJSON['MarketingLandingPage'][0]['Name']}")
            @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Name")}")
            expect(insertedJourneyInfo.fetch("Name")).to match("#{@testDataJSON['MarketingLandingPage'][0]['Name']}")
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Journey owner")
            @helper.addLogs("[Expected ] : #{expectedOwner}")
            @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Owner").fetch("Id")}")
            expect(insertedJourneyInfo.fetch("Owner").fetch("Id")).to eql expectedOwner
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead source on Journey")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("LeadSource")}")
            @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Lead_Source__c")}")
            expect(insertedJourneyInfo.fetch("Lead_Source__c")).to eql insertedLeadInfo.fetch("LeadSource")
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead source details on Journey")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Lead_Source_Detail__c")}")
            @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Lead_Source_Detail__c")}")
            expect(insertedJourneyInfo.fetch("Lead_Source_Detail__c")).to eql insertedLeadInfo.fetch("Lead_Source_Detail__c")
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking NMD Next Contact Date on Journey")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Journey_Created_On__c")}")
            @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")}")
            expect(insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")).to eql insertedLeadInfo.fetch("Journey_Created_On__c")
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Email on Journey")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Email")}")
            @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Primary_Email__c")}")
            expect(insertedJourneyInfo.fetch("Primary_Email__c")).to eql insertedLeadInfo.fetch("Email")
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Phone on Journey")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Phone")}")
            @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Primary_Phone__c")}")
            expect(insertedJourneyInfo.fetch("Primary_Phone__c")).to eql insertedLeadInfo.fetch("Phone")
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Company on Journey")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Company")}")
            @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Company_Name__c")}")
            expect(insertedJourneyInfo.fetch("Company_Name__c")).to eql insertedLeadInfo.fetch("Company")
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Status on Journey")
            @helper.addLogs("[Expected ] : Started")
            @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Status__c")}")
            expect(insertedJourneyInfo.fetch("Status__c")).to eql "Started"
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Journey Primary Lead")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Id")}")
            @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Primary_Lead__c")}")
            expect(insertedJourneyInfo.fetch("Primary_Lead__c")).to eql insertedLeadInfo.fetch("Id")
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Journey Lookong for No of Desk")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Interested_in_Number_of_Desks__c")}")
            @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Looking_For_Number_Of_Desk__c")}")
            expect(insertedJourneyInfo.fetch("Looking_For_Number_Of_Desk__c")).to eql insertedLeadInfo.fetch("Interested_in_Number_of_Desks__c")
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Journey Record Type")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("RecordType").fetch("Name")}")
            @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Record_Type__c")}")
            expect(insertedJourneyInfo.fetch("Record_Type__c")).to eql insertedLeadInfo.fetch("RecordType").fetch("Name")
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Journey Next Contact Date")
            @helper.addLogs("[Expected ] : #{Date.today().to_s}")
            @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")}")
            expect(insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")).to eql Date.today().to_s
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Journey Next Contact Date")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Marketing Consent']}")
            @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Marketing_Consent__c")}")
            expect(insertedJourneyInfo.fetch("Marketing_Consent__c")).to eql @testDataJSON['Lead'][0]['Marketing Consent']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Journey Next Contact Date")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Ts and Cs Consent']}")
            @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Ts_and_Cs_Consent__c")}")
            expect(insertedJourneyInfo.fetch("Ts_and_Cs_Consent__c")).to eql @testDataJSON['Lead'][0]['Ts and Cs Consent']
            @helper.addLogs("[Result ]   : Success\n")


            @helper.addLogs("[Validate ] : Checking Journey Next Contact Date")
            @helper.addLogs("[Expected ] : #{campaignInfo.fetch('Id')}")
            @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("CampaignId__c")}")
            expect(insertedJourneyInfo.fetch("CampaignId__c")).to eql campaignInfo.fetch('Id')
            @helper.addLogs("[Result ]   : Success\n")

            puts "*************************************************************************"

            @helper.addLogs("[Step ]     : Fetch Activity deatails")            
            generatedActivityForLead = @objLeadGeneration.fetchActivityDetails(insertedLeadInfo.fetch("Id"))
            expect(generatedActivityForLead).to_not eq nil
            expect(generatedActivityForLead.size).to eq 1
            expect(generatedActivityForLead[0]).to_not eq nil  
            generatedActivityForLead =  generatedActivityForLead[0] 
            puts generatedActivityForLead
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Activity owner")
            @helper.addLogs("[Expected ] : Susie Romero")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Owner").fetch("Name")}")
            expect(generatedActivityForLead.fetch("Owner").fetch("Name")).to eql 'Susie Romero'
            @helper.addLogs("[Result ]   : Success\n")

            activityExpectHash = {'Subject'=>'Inbound Lead submission','Type'=>'','Priority'=>'Normal','Lead_Source_Detail__c'=>insertedLeadInfo.fetch("Lead_Source_Detail__c"),'Lead_Source__c'=>insertedLeadInfo.fetch("LeadSource"),'Status'=>'Not Started'}
            validate_case_eql('Activity',generatedActivityForLead,activityExpectHash) 

            @helper.postSuccessResult('2170')
        rescue Exception => e
            puts e
            @helper.postFailResult(e,'2170')
        end
    end

    it "C:2576 To check lead and journey assignment for new lead owned by 'Susie Romero' when lead is coming from website marketing landing page and lead is not existing in salesforce, where campaign assignment should be as per 'Email Address' field.", :'2576' => 'true' do
        begin
            @helper.addLogs("C:2576 To check lead and journey assignment for new lead owned by 'Susie Romero' when lead is coming from website marketing landing page and lead is not existing in salesforce, where campaign assignment should be as per 'Email Address' field.",'2576')
            
            @testDataJSON['MarketingLandingPage'][0]['Email'] = @testDataJSON['MarketingLandingPage'][0]['Name'] + SecureRandom.random_number(10000000000).to_s + "@example.com"
            @testDataJSON['Campaign'][0]['Name'] = '2018-03-RM-DC-Multi-Touch-Direct-Mail-Apollo'
            @testDataJSON['Campaign'][0]['Lead Owner'] = ''
            @testDataJSON['Campaign'][0]['Email Address'] = 'vikhroliwest@wework.co.in'
            @testDataJSON['Campaign'][0]['City'] = ''

            @testDataJSON['Lead'][0]['leadSource'] = 'WeWork.com'
            @testDataJSON['Lead'][0]['lead_Source_Detail__c'] = 'Marketing Landing Page'
            @testDataJSON['Lead'][0]['RecordType'] = 'Consumer'
            @testDataJSON['Lead'][0]['Lead Status'] = 'Open'
            @testDataJSON['Lead'][0]['Type'] = 'Office Space'
            @testDataJSON['Lead'][0]['Email Quality'] = 'Pending'
            @testDataJSON['Lead'][0]['Locale'] = 'en-US' 
            @testDataJSON['Lead'][0]['Country Code'] = 'IN' 
            @testDataJSON['Lead'][0]['Product Line'] = 'WeWork' 
            @testDataJSON['Lead'][0]['Marketing Consent'] = true 
            @testDataJSON['Lead'][0]['Ts and Cs Consent'] = false 

            @helper.addLogs("[Step ]     : Fetch camapign deatails")            
            campaignInfo = @objLeadGeneration.fetchCampaignDetails('Name',@testDataJSON['Campaign'][0]['Name'])
            expect(campaignInfo).to_not eq nil
            expect(campaignInfo.size).to eq 1
            expect(campaignInfo[0]).to_not eq nil  
            campaignInfo =  campaignInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Update campaign")
            expect(@objLeadGeneration.update_campaign(campaignInfo.fetch('Id'),@testDataJSON['Campaign'][0]['Lead Owner'],@testDataJSON['Campaign'][0]['Email Address'],@testDataJSON['Campaign'][0]['City'])).to eq true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Create lead from Marketing Landing Page")
            expect(@objLeadGeneration.createLeadFromMarketingPage).to eq true
            @helper.addLogs("[Validate ] : Checking Lead is created after form submission")
            @helper.addLogs("[Expected ] : Lead should create with email #{@testDataJSON['MarketingLandingPage'][0]['Email']}")

            @helper.addLogs("[Step ]     : Check lead inserted into camapign")
            expect(@objLeadGeneration.checkCamapignMember(@testDataJSON['MarketingLandingPage'][0]['Email'],campaignInfo.fetch('Id'))).to eq true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Fetch camapign deatails")
            owner = @objLeadGeneration.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
            expect(owner).to_not eq nil
            @helper.addLogs("[Result ]   : Success\n")

            puts "**************************** Checking Lead Fields ****************************"

            @helper.addLogs("[Step ]     : Fetch lead deatails")            
            insertedLeadInfo = @objLeadGeneration.fetchLeadDetails(@testDataJSON['MarketingLandingPage'][0]['Email'])
            expect(insertedLeadInfo).to_not eq nil
            expect(insertedLeadInfo.size).to eq 1
            expect(insertedLeadInfo[0]).to_not eq nil  
            insertedLeadInfo =  insertedLeadInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")
            
            leadExpectedEqlHash = {'Generate_Journey__c' => false,'Has_Active_Journey__c' => true ,'LeadSource' => 'WeWork.com','Country_Code__c' => 'IN','Locale__c'=>'en-US','Product_Line__c'=>'WeWork','Interested_in_Number_of_Desks_Max__c'=>"#{@testDataJSON['MarketingLandingPage'][0]['I need space for'].split('-')[1].split(' ')[0].to_i}".to_f,'Interested_in_Number_of_Desks_Min__c'=>@testDataJSON['MarketingLandingPage'][0]['I need space for'].split('-')[0].to_f,'Interested_in_Number_of_Desks_Range__c'=> @testDataJSON['MarketingLandingPage'][0]['I need space for'].split('-')[0] + ' - '+ @testDataJSON['MarketingLandingPage'][0]['I need space for'].split('-')[1].split(' ')[0],'Ts_and_Cs_Consent__c'=>false ,'Marketing_Consent__c'=> true,'Email_Quality__c'=>'Pending','Type__c'=>'Office Space','Status'=>'Open','Company'=>@testDataJSON['MarketingLandingPage'][0]['Company'],'Email'=>@testDataJSON['MarketingLandingPage'][0]['Email'],'Lead_Source_Detail__c'=>'Marketing Landing Page','Journey_Created_On__c'=> Date.today.to_s,'Interested_in_Number_of_Desks__c'=>@testDataJSON['MarketingLandingPage'][0]['I need space for'].split('-')[0].to_f}
            validate_case_eql('Lead',insertedLeadInfo,leadExpectedEqlHash)

            leadExpectedMatchHash = {'Name' => @testDataJSON['MarketingLandingPage'][0]['Name']}
            validate_case_match('Lead',insertedLeadInfo,leadExpectedMatchHash)            

            puts "**************************** Checking Journey Fields ****************************"

            @helper.addLogs("[Step ]     : Fetch journey deatails")            
            insertedJourneyInfo = @objLeadGeneration.fetchJourneyDetails(insertedLeadInfo.fetch("Email"))
            expect(insertedJourneyInfo).to_not eq nil
            expect(insertedJourneyInfo.size).to eq 1
            expect(insertedJourneyInfo[0]).to_not eq nil  
            insertedJourneyInfo =  insertedJourneyInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            journeyExpectHash = {'Lead_Source__c'=>insertedLeadInfo.fetch("LeadSource"),'Lead_Source_Detail__c'=>insertedLeadInfo.fetch("Lead_Source_Detail__c"),'NMD_Next_Contact_Date__c'=>insertedLeadInfo.fetch("Journey_Created_On__c"),'Primary_Email__c'=>insertedLeadInfo.fetch("Email"),'Primary_Phone__c'=>insertedLeadInfo.fetch("Phone"),'Company_Name__c'=>insertedLeadInfo.fetch("Company"),'Status__c'=>'Started','Primary_Lead__c'=>insertedLeadInfo.fetch("Id"),'Looking_For_Number_Of_Desk__c'=>insertedLeadInfo.fetch("Interested_in_Number_of_Desks__c"),'Record_Type__c'=>insertedLeadInfo.fetch("RecordType").fetch("Name"),'Marketing_Consent__c'=>true,'Ts_and_Cs_Consent__c'=>false,'CampaignId__c'=>campaignInfo.fetch('Id')}
            validate_case_eql('Journey',insertedJourneyInfo,journeyExpectHash)
            
            puts "**************************** Checking Activity Fields ****************************"

            @helper.addLogs("[Step ]     : Fetch Activity deatails")            
            generatedActivityForLead = @objLeadGeneration.fetchActivityDetails(insertedLeadInfo.fetch("Id"))
            expect(generatedActivityForLead).to_not eq nil
            expect(generatedActivityForLead.size).to eq 1
            expect(generatedActivityForLead[0]).to_not eq nil  
            generatedActivityForLead =  generatedActivityForLead[0] 
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Activity owner")
            @helper.addLogs("[Expected ] : Susie Romero")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Owner").fetch("Name")}")
            expect(generatedActivityForLead.fetch("Owner").fetch("Name")).to eql 'Susie Romero'
            @helper.addLogs("[Result ]   : Success\n")

            activityExpectHash = {'Subject'=>'Inbound Lead submission','Type'=>'','Priority'=>'Normal','Lead_Source_Detail__c'=>insertedLeadInfo.fetch("Lead_Source_Detail__c"),'Lead_Source__c'=>insertedLeadInfo.fetch("LeadSource"),'Status'=>'Not Started'}
            validate_case_eql('Activity',generatedActivityForLead,activityExpectHash) 

            @helper.postSuccessResult('2576')
        rescue Exception => e
            puts e
            @helper.postFailResult(e,'2576')
        end
    end

    it "C:2577 To check lead and journey assignment for new lead owned by 'Susie Romero' when lead is coming from website marketing landing page and lead is not existing in salesforce, where campaign assignment should be as per 'City' field.", :'2577' => 'true' do
        begin
            @helper.addLogs("C:2577 To check lead and journey assignment for new lead owned by 'Susie Romero' when lead is coming from website marketing landing page and lead is not existing in salesforce, where campaign assignment should be as per 'City' field.",'2577')
            
            @testDataJSON['MarketingLandingPage'][0]['Email'] = @testDataJSON['MarketingLandingPage'][0]['Name'] + SecureRandom.random_number(10000000000).to_s + "@example.com"
            @testDataJSON['Campaign'][0]['Name'] = '2018-03-RM-DC-Multi-Touch-Direct-Mail-Apollo'
            @testDataJSON['Campaign'][0]['Lead Owner'] = ''
            @testDataJSON['Campaign'][0]['Email Address'] = ''
            @testDataJSON['Campaign'][0]['City'] = 'Mumbai'

            @testDataJSON['Lead'][0]['leadSource'] = 'WeWork.com'
            @testDataJSON['Lead'][0]['lead_Source_Detail__c'] = 'Marketing Landing Page'
            @testDataJSON['Lead'][0]['RecordType'] = 'Consumer'
            @testDataJSON['Lead'][0]['Lead Status'] = 'Open'
            @testDataJSON['Lead'][0]['Type'] = 'Office Space'
            @testDataJSON['Lead'][0]['Email Quality'] = 'Pending'
            @testDataJSON['Lead'][0]['Locale'] = 'en-US' 
            @testDataJSON['Lead'][0]['Country Code'] = 'IN' 
            @testDataJSON['Lead'][0]['Product Line'] = 'WeWork' 
            @testDataJSON['Lead'][0]['Marketing Consent'] = true 
            @testDataJSON['Lead'][0]['Ts and Cs Consent'] = false 

            @helper.addLogs("[Step ]     : Fetch camapign deatails")            
            campaignInfo = @objLeadGeneration.fetchCampaignDetails('Name',@testDataJSON['Campaign'][0]['Name'])
            expect(campaignInfo).to_not eq nil
            expect(campaignInfo.size).to eq 1
            expect(campaignInfo[0]).to_not eq nil  
            campaignInfo =  campaignInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Update campaign")
            expect(@objLeadGeneration.update_campaign(campaignInfo.fetch('Id'),@testDataJSON['Campaign'][0]['Lead Owner'],@testDataJSON['Campaign'][0]['Email Address'],@testDataJSON['Campaign'][0]['City'])).to eq true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Create lead from Marketing Landing Page")
            expect(@objLeadGeneration.createLeadFromMarketingPage).to eq true
            @helper.addLogs("[Validate ] : Checking Lead is created after form submission")
            @helper.addLogs("[Expected ] : Lead should create with email #{@testDataJSON['MarketingLandingPage'][0]['Email']}")

            @helper.addLogs("[Step ]     : Check lead inserted into camapign")
            expect(@objLeadGeneration.checkCamapignMember(@testDataJSON['MarketingLandingPage'][0]['Email'],campaignInfo.fetch('Id'))).to eq true
            @helper.addLogs("[Result ]   : Success\n")
            
            @helper.addLogs("[Step ]     : Fetch camapign deatails to get Owner")
            owner = @objLeadGeneration.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
            expect(owner).to_not eq nil
            @helper.addLogs("[Result ]   : Success\n")

            puts "**************************** Checking Lead Fields ****************************"

            @helper.addLogs("[Step ]     : Fetch lead deatails")            
            insertedLeadInfo = @objLeadGeneration.fetchLeadDetails(@testDataJSON['MarketingLandingPage'][0]['Email'])
            expect(insertedLeadInfo).to_not eq nil
            expect(insertedLeadInfo.size).to eq 1
            expect(insertedLeadInfo[0]).to_not eq nil  
            insertedLeadInfo =  insertedLeadInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")            

            leadExpectedEqlHash = {'Generate_Journey__c' => false,'Has_Active_Journey__c' => true ,'LeadSource' => 'WeWork.com','Country_Code__c' => 'IN','Locale__c'=>'en-US','Product_Line__c'=>'WeWork','Interested_in_Number_of_Desks_Max__c'=>"#{@testDataJSON['MarketingLandingPage'][0]['I need space for'].split('-')[1].split(' ')[0].to_i}".to_f,'Interested_in_Number_of_Desks_Min__c'=>@testDataJSON['MarketingLandingPage'][0]['I need space for'].split('-')[0].to_f,'Interested_in_Number_of_Desks_Range__c'=> @testDataJSON['MarketingLandingPage'][0]['I need space for'].split('-')[0] + ' - '+ @testDataJSON['MarketingLandingPage'][0]['I need space for'].split('-')[1].split(' ')[0],'Ts_and_Cs_Consent__c'=>false ,'Marketing_Consent__c'=> true,'Email_Quality__c'=>'Pending','Type__c'=>'Office Space','Status'=>'Open','Company'=>@testDataJSON['MarketingLandingPage'][0]['Company'],'Email'=>@testDataJSON['MarketingLandingPage'][0]['Email'],'Lead_Source_Detail__c'=>'Marketing Landing Page','Journey_Created_On__c'=> Date.today.to_s,'Interested_in_Number_of_Desks__c'=>@testDataJSON['MarketingLandingPage'][0]['I need space for'].split('-')[0].to_f}
            validate_case_eql('Lead',insertedLeadInfo,leadExpectedEqlHash)

            leadExpectedMatchHash = {'Name' => @testDataJSON['MarketingLandingPage'][0]['Name']}
            validate_case_match('Lead',insertedLeadInfo,leadExpectedMatchHash)            

            puts "**************************** Checking Journey Fields ****************************"

            @helper.addLogs("[Step ]     : Fetch journey deatails")            
            insertedJourneyInfo = @objLeadGeneration.fetchJourneyDetails(insertedLeadInfo.fetch("Email"))
            expect(insertedJourneyInfo).to_not eq nil
            expect(insertedJourneyInfo.size).to eq 1
            expect(insertedJourneyInfo[0]).to_not eq nil  
            insertedJourneyInfo =  insertedJourneyInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            journeyExpectHash = {'Lead_Source__c'=>insertedLeadInfo.fetch("LeadSource"),'Lead_Source_Detail__c'=>insertedLeadInfo.fetch("Lead_Source_Detail__c"),'NMD_Next_Contact_Date__c'=>insertedLeadInfo.fetch("Journey_Created_On__c"),'Primary_Email__c'=>insertedLeadInfo.fetch("Email"),'Primary_Phone__c'=>insertedLeadInfo.fetch("Phone"),'Company_Name__c'=>insertedLeadInfo.fetch("Company"),'Status__c'=>'Started','Primary_Lead__c'=>insertedLeadInfo.fetch("Id"),'Looking_For_Number_Of_Desk__c'=>insertedLeadInfo.fetch("Interested_in_Number_of_Desks__c"),'Record_Type__c'=>insertedLeadInfo.fetch("RecordType").fetch("Name"),'NMD_Next_Contact_Date__c'=>Date.today().to_s,'Marketing_Consent__c'=>true,'Ts_and_Cs_Consent__c'=>false,'CampaignId__c'=>campaignInfo.fetch('Id')}
            validate_case_eql('Journey',insertedJourneyInfo,journeyExpectHash)

            puts "**************************** Checking Activity Fields ****************************"

            @helper.addLogs("[Step ]     : Fetch Activity deatails")            
            generatedActivityForLead = @objLeadGeneration.fetchActivityDetails(insertedLeadInfo.fetch("Id"))
            expect(generatedActivityForLead).to_not eq nil
            expect(generatedActivityForLead.size).to eq 1
            expect(generatedActivityForLead[0]).to_not eq nil  
            generatedActivityForLead =  generatedActivityForLead[0] 
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Activity owner")
            @helper.addLogs("[Expected ] : Susie Romero")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Owner").fetch("Name")}")
            expect(generatedActivityForLead.fetch("Owner").fetch("Name")).to eql 'Susie Romero'
            @helper.addLogs("[Result ]   : Success\n")

            activityExpectHash = {'Subject'=>'Inbound Lead submission','Type'=>'','Priority'=>'Normal','Lead_Source_Detail__c'=>insertedLeadInfo.fetch("Lead_Source_Detail__c"),'Lead_Source__c'=>insertedLeadInfo.fetch("LeadSource"),'Status'=>'Not Started'}
            validate_case_eql('Activity',generatedActivityForLead,activityExpectHash) 

            @helper.postSuccessResult('2577')
        rescue Exception => e
            puts e
            @helper.postFailResult(e,'2577')
        end
    end

    it "C:2579 To check lead and journey assignment for new lead owned by 'Susie Romero' when lead is coming from website marketing landing page and lead is not existing in salesforce, where campaign assignment should be 'Unassigned NMD Queue' field.", :'2579' => 'true' do
        begin
            @helper.addLogs("C:2579 To check lead and journey assignment for new lead owned by 'Susie Romero' when lead is coming from website marketing landing page and lead is not existing in salesforce, where campaign assignment should be 'Unassigned NMD Queue' field.",'2579')
            
            @testDataJSON['MarketingLandingPage'][0]['Email'] = @testDataJSON['MarketingLandingPage'][0]['Name'] + SecureRandom.random_number(10000000000).to_s + "@example.com"
            @testDataJSON['Campaign'][0]['Name'] = '2018-03-RM-DC-Multi-Touch-Direct-Mail-Apollo'
            @testDataJSON['Campaign'][0]['Lead Owner'] = ''
            @testDataJSON['Campaign'][0]['Email Address'] = ''
            @testDataJSON['Campaign'][0]['City'] = ''

            @testDataJSON['Lead'][0]['leadSource'] = 'WeWork.com'
            @testDataJSON['Lead'][0]['lead_Source_Detail__c'] = 'Marketing Landing Page'
            @testDataJSON['Lead'][0]['RecordType'] = 'Consumer'
            @testDataJSON['Lead'][0]['Lead Status'] = 'Open'
            @testDataJSON['Lead'][0]['Type'] = 'Office Space'
            @testDataJSON['Lead'][0]['Email Quality'] = 'Pending'
            @testDataJSON['Lead'][0]['Locale'] = 'en-US' 
            @testDataJSON['Lead'][0]['Country Code'] = 'IN' 
            @testDataJSON['Lead'][0]['Product Line'] = 'WeWork' 
            @testDataJSON['Lead'][0]['Marketing Consent'] = true 
            @testDataJSON['Lead'][0]['Ts and Cs Consent'] = false 

            @helper.addLogs("[Step ]     : Fetch camapign deatails")            
            campaignInfo = @objLeadGeneration.fetchCampaignDetails('Name',@testDataJSON['Campaign'][0]['Name'])
            expect(campaignInfo).to_not eq nil
            expect(campaignInfo.size).to eq 1
            expect(campaignInfo[0]).to_not eq nil  
            campaignInfo =  campaignInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Update campaign")
            expect(@objLeadGeneration.update_campaign(campaignInfo.fetch('Id'),@testDataJSON['Campaign'][0]['Lead Owner'],@testDataJSON['Campaign'][0]['Email Address'],@testDataJSON['Campaign'][0]['City'])).to eq true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Create lead from Marketing Landing Page")
            expect(@objLeadGeneration.createLeadFromMarketingPage).to eq true
            @helper.addLogs("[Validate ] : Checking Lead is created after form submission")
            @helper.addLogs("[Expected ] : Lead should create with email #{@testDataJSON['MarketingLandingPage'][0]['Email']}")

            @helper.addLogs("[Step ]     : Check lead inserted into camapign")
            expect(@objLeadGeneration.checkCamapignMember(@testDataJSON['MarketingLandingPage'][0]['Email'],campaignInfo.fetch('Id'))).to eq true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Fetch camapign deatails")
            owner = @objLeadGeneration.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
            expect(owner).to_not eq nil
            @helper.addLogs("[Result ]   : Success\n")
            
            puts "**************************** Checking Lead Fields ****************************"

            @helper.addLogs("[Step ]     : Fetch lead deatails")            
            insertedLeadInfo = @objLeadGeneration.fetchLeadDetails(@testDataJSON['MarketingLandingPage'][0]['Email'])
            expect(insertedLeadInfo).to_not eq nil
            expect(insertedLeadInfo.size).to eq 1
            expect(insertedLeadInfo[0]).to_not eq nil  
            insertedLeadInfo =  insertedLeadInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            leadExpectedEqlHash = {'Generate_Journey__c' => false,'Has_Active_Journey__c' => true ,'LeadSource' => 'WeWork.com','Country_Code__c' => 'IN','Locale__c'=>'en-US','Product_Line__c'=>'WeWork','Interested_in_Number_of_Desks_Max__c'=>"#{@testDataJSON['MarketingLandingPage'][0]['I need space for'].split('-')[1].split(' ')[0].to_i}".to_f,'Interested_in_Number_of_Desks_Min__c'=>@testDataJSON['MarketingLandingPage'][0]['I need space for'].split('-')[0].to_f,'Interested_in_Number_of_Desks_Range__c'=> @testDataJSON['MarketingLandingPage'][0]['I need space for'].split('-')[0] + ' - '+ @testDataJSON['MarketingLandingPage'][0]['I need space for'].split('-')[1].split(' ')[0],'Ts_and_Cs_Consent__c'=>false ,'Marketing_Consent__c'=> true,'Email_Quality__c'=>'Pending','Type__c'=>'Office Space','Status'=>'Open','Company'=>@testDataJSON['MarketingLandingPage'][0]['Company'],'Email'=>@testDataJSON['MarketingLandingPage'][0]['Email'],'Lead_Source_Detail__c'=>'Marketing Landing Page','Journey_Created_On__c'=> Date.today.to_s,'Interested_in_Number_of_Desks__c'=>@testDataJSON['MarketingLandingPage'][0]['I need space for'].split('-')[0].to_f}
            validate_case_eql('Lead',insertedLeadInfo,leadExpectedEqlHash)

            leadExpectedMatchHash = {'Name' => @testDataJSON['MarketingLandingPage'][0]['Name']}
            validate_case_match('Lead',insertedLeadInfo,leadExpectedMatchHash)
            

            puts "**************************** Checking Journey Fields ****************************"

            @helper.addLogs("[Step ]     : Fetch journey deatails")            
            insertedJourneyInfo = @objLeadGeneration.fetchJourneyDetails(insertedLeadInfo.fetch("Email"))
            expect(insertedJourneyInfo).to_not eq nil
            expect(insertedJourneyInfo.size).to eq 1
            expect(insertedJourneyInfo[0]).to_not eq nil  
            insertedJourneyInfo =  insertedJourneyInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Activity owner")
            @helper.addLogs("[Expected ] : Susie Romero")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Owner").fetch("Name")}")
            expect(generatedActivityForLead.fetch("Owner").fetch("Name")).to eql 'Susie Romero'
            @helper.addLogs("[Result ]   : Success\n")

            journeyExpectHash = {'Lead_Source__c'=>insertedLeadInfo.fetch("LeadSource"),'Lead_Source_Detail__c'=>insertedLeadInfo.fetch("Lead_Source_Detail__c"),'NMD_Next_Contact_Date__c'=>insertedLeadInfo.fetch("Journey_Created_On__c"),'Primary_Email__c'=>insertedLeadInfo.fetch("Email"),'Primary_Phone__c'=>insertedLeadInfo.fetch("Phone"),'Company_Name__c'=>insertedLeadInfo.fetch("Company"),'Status__c'=>'Started','Primary_Lead__c'=>insertedLeadInfo.fetch("Id"),'Looking_For_Number_Of_Desk__c'=>insertedLeadInfo.fetch("Interested_in_Number_of_Desks__c"),'Record_Type__c'=>insertedLeadInfo.fetch("RecordType").fetch("Name"),'NMD_Next_Contact_Date__c'=>Date.today().to_s,'Marketing_Consent__c'=>true,'Ts_and_Cs_Consent__c'=>false,'CampaignId__c'=>campaignInfo.fetch('Id')}
            validate_case_eql('Journey',insertedJourneyInfo,journeyExpectHash)
            
            puts "**************************** Checking Activity Fields ****************************"

            @helper.addLogs("[Step ]     : Fetch Activity deatails")            
            generatedActivityForLead = @objLeadGeneration.fetchActivityDetails(insertedLeadInfo.fetch("Id"))
            expect(generatedActivityForLead).to_not eq nil
            expect(generatedActivityForLead.size).to eq 1
            expect(generatedActivityForLead[0]).to_not eq nil  
            generatedActivityForLead =  generatedActivityForLead[0] 
            puts generatedActivityForLead
            @helper.addLogs("[Result ]   : Success\n")

            activityExpectHash = {'Subject'=>'Inbound Lead submission','Type'=>'','Priority'=>'Normal','Lead_Source_Detail__c'=>insertedLeadInfo.fetch("Lead_Source_Detail__c"),'Lead_Source__c'=>insertedLeadInfo.fetch("LeadSource"),'Status'=>'Not Started'}
            validate_case_eql('Activity',generatedActivityForLead,activityExpectHash) 

            @helper.postSuccessResult('2579')
        rescue Exception => e
            puts e
            @helper.postFailResult(e,'2579')
        end
    end

    

#MLP same camp + MLP susie 2B

    it "C:2591 To check lead and journey assignment for new lead owned by non 'Susie Romero' when lead is coming from standard salesforce page and lead is not existing in salesforce, where campaign assignment should be as per 'Lead Owner'", :'25917121212121'=> 'true' do
        begin
            @helper.addLogs("C:2591 To check lead and journey assignment for new lead owned by non 'Susie Romero' when lead is coming from standard salesforce page and lead is not existing in salesforce, where campaign assignment should be as per 'Lead Owner'.",'2591')
            
            @testDataJSON['MarketingLandingPage'][0]['Email'] = @testDataJSON['MarketingLandingPage'][0]['Name'] + SecureRandom.random_number(10000000000).to_s + "@example.com"
            @testDataJSON['Campaign'][0]['Name'] = '2018-03-RM-DC-Multi-Touch-Direct-Mail-Apollo'
            @testDataJSON['Campaign'][0]['Lead Owner'] = '0051g000000tSCu'
            @testDataJSON['Campaign'][0]['Email Address'] = ''
            @testDataJSON['Campaign'][0]['City'] = ''

            @testDataJSON['Lead'][0]['leadSource'] = 'WeWork.com'
            @testDataJSON['Lead'][0]['lead_Source_Detail__c'] = 'Marketing Landing Page'
            @testDataJSON['Lead'][0]['RecordType'] = 'Consumer'
            @testDataJSON['Lead'][0]['Lead Status'] = 'Open'
            @testDataJSON['Lead'][0]['Type'] = 'Office Space'
            @testDataJSON['Lead'][0]['Email Quality'] = 'Pending'
            @testDataJSON['Lead'][0]['Locale'] = 'en-US' 
            @testDataJSON['Lead'][0]['Country Code'] = 'IN' 
            @testDataJSON['Lead'][0]['Product Line'] = 'WeWork' 
            @testDataJSON['Lead'][0]['Marketing Consent'] = true 
            @testDataJSON['Lead'][0]['Ts and Cs Consent'] = false

            @helper.addLogs("[Step ]     : Fetch camapign deatails")            
            campaignInfo = @objLeadGeneration.fetchCampaignDetails('Name',@testDataJSON['Campaign'][0]['Name'])
            expect(campaignInfo).to_not eq nil
            expect(campaignInfo.size).to eq 1
            expect(campaignInfo[0]).to_not eq nil  
            campaignInfo =  campaignInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step   ]   : Update campaign")
            expect(@objLeadGeneration.update_campaign(campaignInfo.fetch('Id'),@testDataJSON['Campaign'][0]['Lead Owner'],@testDataJSON['Campaign'][0]['Email Address'],@testDataJSON['Campaign'][0]['City'])).to eq true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Create lead from Marketing Landing Page")
            expect(@objLeadGeneration.createLeadFromMarketingPage).to eq true
            @helper.addLogs("[Validate ] : Checking Lead is created after form submission")
            @helper.addLogs("[Expected ] : Lead should create with email #{@testDataJSON['MarketingLandingPage'][0]['Email']}")
            sleep(5)
            @helper.addLogs("[Step ]     : Create lead from Marketing Landing Page")
            expect(@objLeadGeneration.createLeadFromMarketingPage).to eq true
            @helper.addLogs("[Validate ] : Checking Lead is created after form submission")
            @helper.addLogs("[Expected ] : Lead should create with email #{@testDataJSON['MarketingLandingPage'][0]['Email']}")

            @helper.addLogs("[Step ]     : Check lead inserted into camapign")
            expect(@objLeadGeneration.checkCamapignMember(@testDataJSON['MarketingLandingPage'][0]['Email'],campaignInfo.fetch('Id'))).to eq true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Fetch camapign deatails")
            expectedOwner = @objLeadGeneration.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
            expect(expectedOwner).to_not eq nil
            @helper.addLogs("[Result ]   : Success\n")

            puts "**************************** Checking Lead Fields ****************************"
            #owner--campaign assignment
            @helper.addLogs("[Step ]     : Fetch lead deatails")            
            insertedLeadInfo = @objLeadGeneration.fetchLeadDetails(@testDataJSON['MarketingLandingPage'][0]['Email'])
            expect(insertedLeadInfo).to_not eq nil
            expect(insertedLeadInfo.size).to eq 1
            expect(insertedLeadInfo[0]).to_not eq nil  
            insertedLeadInfo =  insertedLeadInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead owner should be According to Lead Assignment Rule")
            @helper.addLogs("[Expected ] : #{expectedOwner}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Owner").fetch("Id")}")            
            expect(insertedLeadInfo.fetch("Owner").fetch("Id")).to match("#{expectedOwner}")
            @helper.addLogs("[Result ]   : Success\n")

            leadExpectedEqlHash = {'Generate_Journey__c' => false,'Has_Active_Journey__c' => true ,'LeadSource' => 'WeWork.com','Country_Code__c' => 'IN','Locale__c'=>'en-US','Product_Line__c'=>'WeWork','Interested_in_Number_of_Desks_Max__c'=>"#{@testDataJSON['MarketingLandingPage'][0]['I need space for'].split('-')[1].split(' ')[0].to_i}".to_f,'Interested_in_Number_of_Desks_Min__c'=>@testDataJSON['MarketingLandingPage'][0]['I need space for'].split('-')[0].to_f,'Interested_in_Number_of_Desks_Range__c'=> @testDataJSON['MarketingLandingPage'][0]['I need space for'].split('-')[0] + ' - '+ @testDataJSON['MarketingLandingPage'][0]['I need space for'].split('-')[1].split(' ')[0],'Ts_and_Cs_Consent__c'=>false ,'Marketing_Consent__c'=> true,'Email_Quality__c'=>'Pending','Type__c'=>'Office Space','Status'=>'Open','Company'=>@testDataJSON['MarketingLandingPage'][0]['Company'],'Email'=>@testDataJSON['MarketingLandingPage'][0]['Email'],'Lead_Source_Detail__c'=>'Marketing Landing Page','Journey_Created_On__c'=> Date.today.to_s,'Interested_in_Number_of_Desks__c'=>@testDataJSON['MarketingLandingPage'][0]['I need space for'].split('-')[0].to_f}
            validate_case_eql('Lead',insertedLeadInfo,leadExpectedEqlHash)

            leadExpectedMatchHash = {'Name' => @testDataJSON['MarketingLandingPage'][0]['Name']}
            validate_case_match('Lead',insertedLeadInfo,leadExpectedMatchHash)

            puts "**************************** Checking Journey Fields ****************************"
            #owner campaign assignment
            @helper.addLogs("[Step ]     : Fetch journey deatails")            
            insertedJourneyInfo = @objLeadGeneration.fetchJourneyDetails(insertedLeadInfo.fetch("Email"))
            expect(insertedJourneyInfo).to_not eq nil
            expect(insertedJourneyInfo.size).to eq 1
            expect(insertedJourneyInfo[0]).to_not eq nil  
            insertedJourneyInfo =  insertedJourneyInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Journey owner")
            @helper.addLogs("[Expected ] : #{expectedOwner}")
            @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Owner").fetch("Id")}")
            expect(insertedJourneyInfo.fetch("Owner").fetch("Id")).to eql expectedOwner
            @helper.addLogs("[Result ]   : Success\n")

            journeyExpectHash = {'Lead_Source__c'=>insertedLeadInfo.fetch("LeadSource"),'Lead_Source_Detail__c'=>insertedLeadInfo.fetch("Lead_Source_Detail__c"),'NMD_Next_Contact_Date__c'=>insertedLeadInfo.fetch("Journey_Created_On__c"),'Primary_Email__c'=>insertedLeadInfo.fetch("Email"),'Primary_Phone__c'=>insertedLeadInfo.fetch("Phone"),'Company_Name__c'=>insertedLeadInfo.fetch("Company"),'Status__c'=>'Started','Primary_Lead__c'=>insertedLeadInfo.fetch("Id"),'Looking_For_Number_Of_Desk__c'=>insertedLeadInfo.fetch("Interested_in_Number_of_Desks__c"),'Record_Type__c'=>insertedLeadInfo.fetch("RecordType").fetch("Name"),'Marketing_Consent__c'=>true,'Ts_and_Cs_Consent__c'=>false,'CampaignId__c'=>campaignInfo.fetch('Id')}
            validate_case_eql('Journey',insertedJourneyInfo,journeyExpectHash)
            
            puts "**************************** Checking Activity Fields ****************************"
            #activity owner---logged in user
            @helper.addLogs("[Step ]     : Fetch Activity deatails")            
            generatedActivityForLead = @objLeadGeneration.fetchActivityDetails(insertedLeadInfo.fetch("Id"))
            expect(generatedActivityForLead).to_not eq nil
            expect(generatedActivityForLead.size).to eq 2
            expect(generatedActivityForLead[0]).to_not eq nil  
            generatedActivityForLead =  generatedActivityForLead[generatedActivityForLead.size - 1] 
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Activity owner")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Owner").fetch("Name")}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Owner").fetch("Name")}")
            expect(generatedActivityForLead.fetch("Owner").fetch("Name")).to eql insertedLeadInfo.fetch("Owner").fetch("Name")
            @helper.addLogs("[Result ]   : Success\n")            

            activityExpectHash = {'Subject'=>'Inbound Lead submission','Type'=>'Website','Priority'=>'Normal','Lead_Source_Detail__c'=>insertedLeadInfo.fetch("Lead_Source_Detail__c"),'Lead_Source__c'=>insertedLeadInfo.fetch("LeadSource"),'Status'=>'Not Started'}
            validate_case_eql('Activity',generatedActivityForLead,activityExpectHash)

            @helper.postSuccessResult(2591)
        rescue Exception => e
            @helper.postFailResult(e,2591)
            raise e
        end
    end

    
#MLP diff camp + mlp 3A susie --------- remaining no second campaign MLP ********************

    it "C:2591 To check lead and journey assignment for new lead owned by non 'Susie Romero' when lead is coming from standard salesforce page and lead is not existing in salesforce, where campaign assignment should be as per 'Lead Owner'", :'25917'=> 'true' do
        begin
            @helper.addLogs("C:2591 To check lead and journey assignment for new lead owned by non 'Susie Romero' when lead is coming from standard salesforce page and lead is not existing in salesforce, where campaign assignment should be as per 'Lead Owner'.",'2591')
            
            @testDataJSON['MarketingLandingPage'][0]['Email'] = @testDataJSON['MarketingLandingPage'][0]['Name'] + SecureRandom.random_number(10000000000).to_s + "@example.com"
            @testDataJSON['Campaign'][0]['Name'] = '2018-03-RM-DC-Multi-Touch-Direct-Mail-Apollo'
            @testDataJSON['Campaign'][0]['Lead Owner'] = '0051g000000tSCu'
            @testDataJSON['Campaign'][0]['Email Address'] = ''
            @testDataJSON['Campaign'][0]['City'] = ''

            @testDataJSON['Lead'][0]['leadSource'] = 'WeWork.com'
            @testDataJSON['Lead'][0]['lead_Source_Detail__c'] = 'Marketing Landing Page'
            @testDataJSON['Lead'][0]['RecordType'] = 'Consumer'
            @testDataJSON['Lead'][0]['Lead Status'] = 'Open'
            @testDataJSON['Lead'][0]['Type'] = 'Office Space'
            @testDataJSON['Lead'][0]['Email Quality'] = 'Pending'
            @testDataJSON['Lead'][0]['Locale'] = 'en-US' 
            @testDataJSON['Lead'][0]['Country Code'] = 'IN' 
            @testDataJSON['Lead'][0]['Product Line'] = 'WeWork' 
            @testDataJSON['Lead'][0]['Marketing Consent'] = true 
            @testDataJSON['Lead'][0]['Ts and Cs Consent'] = false

            @helper.addLogs("[Step ]     : Fetch camapign deatails")            
            campaignInfo = @objLeadGeneration.fetchCampaignDetails('Name',@testDataJSON['Campaign'][0]['Name'])
            expect(campaignInfo).to_not eq nil
            expect(campaignInfo.size).to eq 1
            expect(campaignInfo[0]).to_not eq nil  
            campaignInfo =  campaignInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Update campaign")
            expect(@objLeadGeneration.update_campaign(campaignInfo.fetch('Id'),@testDataJSON['Campaign'][0]['Lead Owner'],@testDataJSON['Campaign'][0]['Email Address'],@testDataJSON['Campaign'][0]['City'])).to eq true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Create lead from Marketing Landing Page")
            expect(@objLeadGeneration.createLeadFromMarketingPage).to eq true
            @helper.addLogs("[Validate ] : Checking Lead is created after form submission")
            @helper.addLogs("[Expected ] : Lead should create with email #{@testDataJSON['MarketingLandingPage'][0]['Email']}")
            sleep(5)
            @helper.addLogs("[Step ]     : Create lead from Marketing Landing Page")
            expect(@objLeadGeneration.createLeadFromMarketingPage).to eq true
            @helper.addLogs("[Validate ] : Checking Lead is created after form submission")
            @helper.addLogs("[Expected ] : Lead should create with email #{@testDataJSON['MarketingLandingPage'][0]['Email']}")

            @helper.addLogs("[Step ]     : Check lead inserted into camapign")
            expect(@objLeadGeneration.checkCamapignMember(@testDataJSON['MarketingLandingPage'][0]['Email'],campaignInfo.fetch('Id'))).to eq true
            @helper.addLogs("[Result ]   : Success\n")

            puts "*******************************************************"


            @helper.addLogs("[Step ]     : Fetch camapign deatails")
            owner = @objLeadGeneration.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
            expect(owner).to_not eq nil
            @helper.addLogs("[Result ]   : Success\n")

            expectedOwner = owner 
            puts expectedOwner

            #owner--campaign assignment
            @helper.addLogs("[Step ]     : Fetch lead deatails")            
            insertedLeadInfo = @objLeadGeneration.fetchLeadDetails(@testDataJSON['MarketingLandingPage'][0]['Email'])
            expect(insertedLeadInfo).to_not eq nil
            expect(insertedLeadInfo.size).to eq 1
            expect(insertedLeadInfo[0]).to_not eq nil  
            insertedLeadInfo =  insertedLeadInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

                       

            puts "********************************************************"
            #owner campaign assignment
            @helper.addLogs("[Step ]     : Fetch journey deatails")            
            insertedJourneyInfo = @objLeadGeneration.fetchJourneyDetails(insertedLeadInfo.fetch("Email"))
            expect(insertedJourneyInfo).to_not eq nil
            expect(insertedJourneyInfo.size).to eq 1
            expect(insertedJourneyInfo[0]).to_not eq nil  
            insertedJourneyInfo =  insertedJourneyInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            

            puts "*************************************************************************"
            #activity owner---logged in user
            @helper.addLogs("[Step ]     : Fetch Activity deatails")            
            generatedActivityForLead = @objLeadGeneration.fetchActivityDetails(insertedLeadInfo.fetch("Id"))
            expect(generatedActivityForLead).to_not eq nil
            expect(generatedActivityForLead.size).to eq 2
            expect(generatedActivityForLead[0]).to_not eq nil  
            generatedActivityForLead =  generatedActivityForLead[0] 
            puts generatedActivityForLead
            @helper.addLogs("[Result ]   : Success\n")


            @helper.postSuccessResult(2591)
        rescue Exception => e
            @helper.addLogs('Error')
            @helper.postFailResult(e,2591)
            raise e
        end
    end


#std diff camp + mlp 3B non susie
    it "C:2591 To check lead and journey assignment for new lead owned by non 'Susie Romero' when lead is coming from standard salesforce page and lead is not existing in salesforce, where campaign assignment should be as per 'Lead Owner'", :'2591112'=> 'true' do
        begin
            @helper.addLogs("C:2591 To check lead and journey assignment for new lead owned by non 'Susie Romero' when lead is coming from standard salesforce page and lead is not existing in salesforce, where campaign assignment should be as per 'Lead Owner'.",'2591')
            
            #@testDataJSON['MarketingLandingPage'][0]['Email'] = @testDataJSON['MarketingLandingPage'][0]['Name'] + SecureRandom.random_number(10000000000).to_s + "@example.com"
            @testDataJSON['Campaign'][0]['Name'] = '2018-03-RM-DC-Multi-Touch-Direct-Mail-Apollo'
            @testDataJSON['Campaign'][0]['Lead Owner'] = '0051g000000tSCu'
            @testDataJSON['Campaign'][0]['Email Address'] = ''
            @testDataJSON['Campaign'][0]['City'] = ''

            @testDataJSON['Lead'][0]['RecordType'] = 'Consumer'
            @testDataJSON['Lead'][0]['Email'] = @testDataJSON['Lead'][0]['LastName'] + SecureRandom.random_number(10000000000).to_s + "@example.com"
            @testDataJSON['Lead'][0]['leadSource'] = 'Event'
            @testDataJSON['Lead'][0]['lead_Source_Detail__c'] = 'Book A Tour Form'
            @testDataJSON['Lead'][0]['Interested in Number of Desk(s)'] = '2'
            @testDataJSON['Lead'][0]['Lead Status'] = 'Open'
            @testDataJSON['Lead'][0]['Generate Journey'] = false
            @testDataJSON['Lead'][0]['Restart Journey'] = false
            @testDataJSON['Lead'][0]['Type'] = 'Office Space'
            @testDataJSON['Lead'][0]['Market'] = 'Amsterdam'
            @testDataJSON['Lead'][0]['Locale'] = 'af'
            @testDataJSON['Lead'][0]['Building Interested In'] = 'BKN-Montague St.'
            @testDataJSON['Lead'][0]['Markets Interested'] = 'Amsterdam;Atlanta'
            @testDataJSON['Lead'][0]['Country Code'] = 'AF'
            @testDataJSON['Lead'][0]['Number of Full Time Employees'] = '15'
            @testDataJSON['Lead'][0]['Locations Interested'] = "AMS-Labs;AMS-Strawinskylaan"
            @testDataJSON['Lead'][0]['Referrer'] = 'john snow_QaAuto_121'
            @testDataJSON['Lead'][0]['Referrer Name'] = 'John'
            @testDataJSON['Lead'][0]['Referrer Email'] = 'abc@example.com'
            @testDataJSON['Lead'][0]['Assign using active assignment rule'] = true
            @testDataJSON['Lead'][0]['Promo Code'] = "123123"
            @testDataJSON['Lead'][0]['Campaign'] = 'Community Impact Offer'

            @testDataJSON['MarketingLandingPage'][0]['Email'] = @testDataJSON['Lead'][0]['Email']

            @helper.addLogs("[Step ]     : Fetch camapign deatails")            
            campaignInfo = @objLeadGeneration.fetchCampaignDetails('Name',@testDataJSON['Campaign'][0]['Name'])
            expect(campaignInfo).to_not eq nil
            expect(campaignInfo.size).to eq 1
            expect(campaignInfo[0]).to_not eq nil  
            campaignInfo =  campaignInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Update campaign")
            expect(@objLeadGeneration.update_campaign(campaignInfo.fetch('Id'),@testDataJSON['Campaign'][0]['Lead Owner'],@testDataJSON['Campaign'][0]['Email Address'],@testDataJSON['Campaign'][0]['City'])).to eq true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Create lead from Standerd salesforce page")
            expect(@objLeadGeneration.createLeadStdsalesforce).to eq true
            @helper.addLogs("[Validate ] : Checking Lead is created after form submission")
            @helper.addLogs("[Expected ] : Lead should create with email #{@testDataJSON['Lead'][0]['Email']}")

            @helper.addLogs("[Step ]     : Create lead from Marketing Landing Page")
            expect(@objLeadGeneration.createLeadFromMarketingPage).to eq true
            @helper.addLogs("[Validate ] : Checking Lead is created after form submission")
            @helper.addLogs("[Expected ] : Lead should create with email #{@testDataJSON['MarketingLandingPage'][0]['Email']}")


            @helper.addLogs("[Step ]     : Check lead inserted into camapign")
            expect(@objLeadGeneration.checkCamapignMember(@testDataJSON['Lead'][0]['Email'],campaignInfo.fetch('Id'))).to eq true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Fetch camapign deatails")
            owner = @objLeadGeneration.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
            expect(owner).to_not eq nil
            @helper.addLogs("[Result ]   : Success\n")

            expectedOwner = owner 
            puts expectedOwner

            #owner--campaign assignment
            @helper.addLogs("[Step ]     : Fetch lead deatails")            
            insertedLeadInfo = @objLeadGeneration.fetchLeadDetails(@testDataJSON['Lead'][0]['Email'])
            expect(insertedLeadInfo).to_not eq nil
            expect(insertedLeadInfo.size).to eq 1
            expect(insertedLeadInfo[0]).to_not eq nil  
            insertedLeadInfo =  insertedLeadInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")                       

            puts "********************************************************"
            #owner campaign assignment
            @helper.addLogs("[Step ]     : Fetch journey deatails")            
            insertedJourneyInfo = @objLeadGeneration.fetchJourneyDetails(insertedLeadInfo.fetch("Email"))
            expect(insertedJourneyInfo).to_not eq nil
            expect(insertedJourneyInfo.size).to eq 2
            expect(insertedJourneyInfo[0]).to_not eq nil  
            puts insertedJourneyInfo
            insertedJourneyInfo =  insertedJourneyInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")            

            puts "*************************************************************************"
            #activity owner---logged in user
            @helper.addLogs("[Step ]     : Fetch Activity deatails")            
            generatedActivityForLead = @objLeadGeneration.fetchActivityDetails(insertedLeadInfo.fetch("Id"))
            expect(generatedActivityForLead).to_not eq nil
            expect(generatedActivityForLead.size).to eq 2
            expect(generatedActivityForLead[0]).to_not eq nil  
             puts generatedActivityForLead
            generatedActivityForLead =  generatedActivityForLead[0] 
           
            @helper.addLogs("[Result ]   : Success\n")


            @helper.postSuccessResult(2591)
        rescue Exception => e
            @helper.postFailResult(e,2591)
            raise e
        end
    end

    it "C:2592 To check lead and journey assignment for new lead owned by non 'Susie Romero' when lead is coming from standard salesforce page and lead is not existing in salesforce, where campaign assignment should be as per 'Email Address'", :'2592212'=> 'true' do
        begin
            @helper.addLogs("C:2592 To check lead and journey assignment for new lead owned by non 'Susie Romero' when lead is coming from standard salesforce page and lead is not existing in salesforce, where campaign assignment should be as per 'Email Address'.",'2592')
            
            #@testDataJSON['MarketingLandingPage'][0]['Email'] = @testDataJSON['MarketingLandingPage'][0]['Name'] + SecureRandom.random_number(10000000000).to_s + "@example.com"
            @testDataJSON['Campaign'][0]['Name'] = '2018-03-RM-DC-Multi-Touch-Direct-Mail-Apollo'
            @testDataJSON['Campaign'][0]['Lead Owner'] = ''
            @testDataJSON['Campaign'][0]['Email Address'] = 'vikhroliwest@wework.co.in'
            @testDataJSON['Campaign'][0]['City'] = ''

            @testDataJSON['Lead'][0]['RecordType'] = 'Consumer'
            @testDataJSON['Lead'][0]['Email'] = @testDataJSON['Lead'][0]['LastName'] + SecureRandom.random_number(10000000000).to_s + "@example.com"
            @testDataJSON['Lead'][0]['leadSource'] = 'Event'
            @testDataJSON['Lead'][0]['lead_Source_Detail__c'] = 'Book A Tour Form'
            @testDataJSON['Lead'][0]['Interested in Number of Desk(s)'] = '2'
            @testDataJSON['Lead'][0]['Lead Status'] = 'Open'
            @testDataJSON['Lead'][0]['Generate Journey'] = false
            @testDataJSON['Lead'][0]['Restart Journey'] = false
            @testDataJSON['Lead'][0]['Type'] = 'Office Space'
            @testDataJSON['Lead'][0]['Market'] = 'Amsterdam'
            @testDataJSON['Lead'][0]['Locale'] = 'af'
            @testDataJSON['Lead'][0]['Building Interested In'] = 'BKN-Montague St.'
            @testDataJSON['Lead'][0]['Markets Interested'] = 'Amsterdam;Atlanta'
            @testDataJSON['Lead'][0]['Country Code'] = 'AF'
            @testDataJSON['Lead'][0]['Number of Full Time Employees'] = '15'
            @testDataJSON['Lead'][0]['Locations Interested'] = "AMS-Labs;AMS-Strawinskylaan"
            @testDataJSON['Lead'][0]['Referrer'] = 'john snow_QaAuto_121'
            @testDataJSON['Lead'][0]['Referrer Name'] = 'John'
            @testDataJSON['Lead'][0]['Referrer Email'] = 'abc@example.com'
            @testDataJSON['Lead'][0]['Assign using active assignment rule'] = true
            @testDataJSON['Lead'][0]['Promo Code'] = "123123"
            @testDataJSON['Lead'][0]['Campaign'] = 'Community Impact Offer'

            @testDataJSON['MarketingLandingPage'][0]['Email'] = @testDataJSON['Lead'][0]['Email']


            @helper.addLogs("[Step ]     : Fetch camapign deatails")            
            campaignInfo = @objLeadGeneration.fetchCampaignDetails('Name',@testDataJSON['Campaign'][0]['Name'])
            expect(campaignInfo).to_not eq nil
            expect(campaignInfo.size).to eq 1
            expect(campaignInfo[0]).to_not eq nil  
            campaignInfo =  campaignInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Update campaign")
            expect(@objLeadGeneration.update_campaign(campaignInfo.fetch('Id'),@testDataJSON['Campaign'][0]['Lead Owner'],@testDataJSON['Campaign'][0]['Email Address'],@testDataJSON['Campaign'][0]['City'])).to eq true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Create lead from Standerd salesforce page")
            expect(@objLeadGeneration.createLeadStdsalesforce).to eq true
            @helper.addLogs("[Validate ] : Checking Lead is created after form submission")
            @helper.addLogs("[Expected ] : Lead should create with email #{@testDataJSON['Lead'][0]['Email']}")

            @helper.addLogs("[Step ]     : Create lead from Marketing Landing Page")
            expect(@objLeadGeneration.createLeadFromMarketingPage).to eq true
            @helper.addLogs("[Validate ] : Checking Lead is created after form submission")
            @helper.addLogs("[Expected ] : Lead should create with email #{@testDataJSON['MarketingLandingPage'][0]['Email']}")

            @helper.addLogs("[Step ]     : Check lead inserted into camapign")
            expect(@objLeadGeneration.checkCamapignMember(@testDataJSON['Lead'][0]['Email'],campaignInfo.fetch('Id'))).to eq true
            @helper.addLogs("[Result ]   : Success\n")

            puts "*******************************************************"


            @helper.addLogs("[Step ]     : Fetch camapign deatails")
            owner = @objLeadGeneration.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
            expect(owner).to_not eq nil
            @helper.addLogs("[Result ]   : Success\n")

            expectedOwner = owner 
            puts expectedOwner

            #owner--campaign assignment
            @helper.addLogs("[Step ]     : Fetch lead deatails")            
            insertedLeadInfo = @objLeadGeneration.fetchLeadDetails(@testDataJSON['Lead'][0]['Email'])
            expect(insertedLeadInfo).to_not eq nil
            expect(insertedLeadInfo.size).to eq 1
            expect(insertedLeadInfo[0]).to_not eq nil  
            insertedLeadInfo =  insertedLeadInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")                       

            puts "********************************************************"
            #owner campaign assignment
            @helper.addLogs("[Step ]     : Fetch journey deatails")            
            insertedJourneyInfo = @objLeadGeneration.fetchJourneyDetails(insertedLeadInfo.fetch("Email"))
            expect(insertedJourneyInfo).to_not eq nil
            expect(insertedJourneyInfo.size).to eq 2
            expect(insertedJourneyInfo[0]).to_not eq nil  
            insertedJourneyInfo =  insertedJourneyInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")            

            puts "*************************************************************************"
            #activity owner---logged in user
            @helper.addLogs("[Step ]     : Fetch Activity deatails")            
            generatedActivityForLead = @objLeadGeneration.fetchActivityDetails(insertedLeadInfo.fetch("Id"))
            expect(generatedActivityForLead).to_not eq nil
            expect(generatedActivityForLead.size).to eq 2
            expect(generatedActivityForLead[0]).to_not eq nil  
            generatedActivityForLead =  generatedActivityForLead[0] 
            puts generatedActivityForLead
            @helper.addLogs("[Result ]   : Success\n")

            @helper.postSuccessResult(2592)
        rescue Exception => e
            @helper.addLogs('Error')
            @helper.postFailResult(e,2592)
            raise e
        end
    end

    it "C:2593 To check lead and journey assignment for new lead owned by non 'Susie Romero' when lead is coming from standard salesforce page and lead is not existing in salesforce, where campaign assignment should be as per 'City'", :'2593312'=> 'true' do
        begin
            @helper.addLogs("C:2593 To check lead and journey assignment for new lead owned by non 'Susie Romero' when lead is coming from standard salesforce page and lead is not existing in salesforce, where campaign assignment should be as per 'City'.",'2592')
            
            #@testDataJSON['MarketingLandingPage'][0]['Email'] = @testDataJSON['MarketingLandingPage'][0]['Name'] + SecureRandom.random_number(10000000000).to_s + "@example.com"
            @testDataJSON['Campaign'][0]['Name'] = '2018-03-RM-DC-Multi-Touch-Direct-Mail-Apollo'
            @testDataJSON['Campaign'][0]['Lead Owner'] = ''
            @testDataJSON['Campaign'][0]['Email Address'] = ''
            @testDataJSON['Campaign'][0]['City'] = 'Mumbai'

            @testDataJSON['Lead'][0]['RecordType'] = 'Consumer'
            @testDataJSON['Lead'][0]['Email'] = @testDataJSON['Lead'][0]['LastName'] + SecureRandom.random_number(10000000000).to_s + "@example.com"
            @testDataJSON['Lead'][0]['leadSource'] = 'Event'
            @testDataJSON['Lead'][0]['lead_Source_Detail__c'] = 'Book A Tour Form'
            @testDataJSON['Lead'][0]['Interested in Number of Desk(s)'] = '2'
            @testDataJSON['Lead'][0]['Lead Status'] = 'Open'
            @testDataJSON['Lead'][0]['Generate Journey'] = false
            @testDataJSON['Lead'][0]['Restart Journey'] = false
            @testDataJSON['Lead'][0]['Type'] = 'Office Space'
            @testDataJSON['Lead'][0]['Market'] = 'Amsterdam'
            @testDataJSON['Lead'][0]['Locale'] = 'af'
            @testDataJSON['Lead'][0]['Building Interested In'] = 'BKN-Montague St.'
            @testDataJSON['Lead'][0]['Markets Interested'] = 'Amsterdam;Atlanta'
            @testDataJSON['Lead'][0]['Country Code'] = 'AF'
            @testDataJSON['Lead'][0]['Number of Full Time Employees'] = '15'
            @testDataJSON['Lead'][0]['Locations Interested'] = "AMS-Labs;AMS-Strawinskylaan"
            @testDataJSON['Lead'][0]['Referrer'] = 'john snow_QaAuto_121'
            @testDataJSON['Lead'][0]['Referrer Name'] = 'John'
            @testDataJSON['Lead'][0]['Referrer Email'] = 'abc@example.com'
            @testDataJSON['Lead'][0]['Assign using active assignment rule'] = true
            @testDataJSON['Lead'][0]['Promo Code'] = "123123"
            @testDataJSON['Lead'][0]['Campaign'] = 'Community Impact Offer'

            @testDataJSON['MarketingLandingPage'][0]['Email'] = @testDataJSON['Lead'][0]['Email']


            @helper.addLogs("[Step ]     : Fetch camapign deatails")            
            campaignInfo = @objLeadGeneration.fetchCampaignDetails('Name',@testDataJSON['Campaign'][0]['Name'])
            expect(campaignInfo).to_not eq nil
            expect(campaignInfo.size).to eq 1
            expect(campaignInfo[0]).to_not eq nil  
            campaignInfo =  campaignInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Update campaign")
            expect(@objLeadGeneration.update_campaign(campaignInfo.fetch('Id'),@testDataJSON['Campaign'][0]['Lead Owner'],@testDataJSON['Campaign'][0]['Email Address'],@testDataJSON['Campaign'][0]['City'])).to eq true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Create lead from Standerd salesforce page")
            expect(@objLeadGeneration.createLeadStdsalesforce).to eq true
            @helper.addLogs("[Validate ] : Checking Lead is created after form submission")
            @helper.addLogs("[Expected ] : Lead should create with email #{@testDataJSON['Lead'][0]['Email']}")

            @helper.addLogs("[Step ]     : Create lead from Marketing Landing Page")
            expect(@objLeadGeneration.createLeadFromMarketingPage).to eq true
            @helper.addLogs("[Validate ] : Checking Lead is created after form submission")
            @helper.addLogs("[Expected ] : Lead should create with email #{@testDataJSON['MarketingLandingPage'][0]['Email']}")

            @helper.addLogs("[Step ]     : Check lead inserted into camapign")
            expect(@objLeadGeneration.checkCamapignMember(@testDataJSON['Lead'][0]['Email'],campaignInfo.fetch('Id'))).to eq true
            @helper.addLogs("[Result ]   : Success\n")

            puts "*******************************************************"


            @helper.addLogs("[Step ]     : Fetch camapign deatails")
            owner = @objLeadGeneration.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
            expect(owner).to_not eq nil
            @helper.addLogs("[Result ]   : Success\n")

            expectedOwner = owner 
            puts expectedOwner

            #owner--campaign assignment
            @helper.addLogs("[Step ]     : Fetch lead deatails")            
            insertedLeadInfo = @objLeadGeneration.fetchLeadDetails(@testDataJSON['Lead'][0]['Email'])
            expect(insertedLeadInfo).to_not eq nil
            expect(insertedLeadInfo.size).to eq 1
            expect(insertedLeadInfo[0]).to_not eq nil  
            insertedLeadInfo =  insertedLeadInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")                       

            puts "********************************************************"
            #owner campaign assignment
            @helper.addLogs("[Step ]     : Fetch journey deatails")            
            insertedJourneyInfo = @objLeadGeneration.fetchJourneyDetails(insertedLeadInfo.fetch("Email"))
            expect(insertedJourneyInfo).to_not eq nil
            expect(insertedJourneyInfo.size).to eq 2
            expect(insertedJourneyInfo[0]).to_not eq nil 
            puts insertedJourneyInfo 
            insertedJourneyInfo =  insertedJourneyInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")            

            puts "*************************************************************************"
            #activity owner---logged in user
            @helper.addLogs("[Step ]     : Fetch Activity deatails")            
            generatedActivityForLead = @objLeadGeneration.fetchActivityDetails(insertedLeadInfo.fetch("Id"))
            expect(generatedActivityForLead).to_not eq nil
            expect(generatedActivityForLead.size).to eq 2
            expect(generatedActivityForLead[0]).to_not eq nil
            puts generatedActivityForLead  
            generatedActivityForLead =  generatedActivityForLead[0]             
            @helper.addLogs("[Result ]   : Success\n")



            @helper.addLogs('Success')
            @helper.postSuccessResult(2593)
        rescue Exception => e
            @helper.addLogs('Error')
            @helper.postFailResult(e,2593)
            raise e
        end
    end

    it "C:2594 To check lead and journey assignment for new lead owned by non 'Susie Romero' when lead is coming from standard salesforce page and lead is not existing in salesforce, where campaign assignment should be 'Unassigned NMD US Queue'", :'2594412'=> 'true' do
        begin
            @helper.addLogs("C:2593 To check lead and journey assignment for new lead owned by non 'Susie Romero' when lead is coming from standard salesforce page and lead is not existing in salesforce, where campaign assignment should be 'Unassigned NMD US Queue'.",'2592')
            
            #@testDataJSON['MarketingLandingPage'][0]['Email'] = @testDataJSON['MarketingLandingPage'][0]['Name'] + SecureRandom.random_number(10000000000).to_s + "@example.com"
            @testDataJSON['Campaign'][0]['Name'] = '2018-03-RM-DC-Multi-Touch-Direct-Mail-Apollo'
            @testDataJSON['Campaign'][0]['Lead Owner'] = ''
            @testDataJSON['Campaign'][0]['Email Address'] = ''
            @testDataJSON['Campaign'][0]['City'] = ''

            @testDataJSON['Lead'][0]['RecordType'] = 'Consumer'
            @testDataJSON['Lead'][0]['Email'] = @testDataJSON['Lead'][0]['LastName'] + SecureRandom.random_number(10000000000).to_s + "@example.com"
            @testDataJSON['Lead'][0]['leadSource'] = 'Event'
            @testDataJSON['Lead'][0]['lead_Source_Detail__c'] = 'Book A Tour Form'
            @testDataJSON['Lead'][0]['Interested in Number of Desk(s)'] = '2'
            @testDataJSON['Lead'][0]['Lead Status'] = 'Open'
            @testDataJSON['Lead'][0]['Generate Journey'] = false
            @testDataJSON['Lead'][0]['Restart Journey'] = false
            @testDataJSON['Lead'][0]['Type'] = 'Office Space'
            @testDataJSON['Lead'][0]['Market'] = 'Amsterdam'
            @testDataJSON['Lead'][0]['Locale'] = 'af'
            @testDataJSON['Lead'][0]['Building Interested In'] = 'BKN-Montague St.'
            @testDataJSON['Lead'][0]['Markets Interested'] = 'Amsterdam;Atlanta'
            @testDataJSON['Lead'][0]['Country Code'] = 'AF'
            @testDataJSON['Lead'][0]['Number of Full Time Employees'] = '15'
            @testDataJSON['Lead'][0]['Locations Interested'] = "AMS-Labs;AMS-Strawinskylaan"
            @testDataJSON['Lead'][0]['Referrer'] = 'john snow_QaAuto_121'
            @testDataJSON['Lead'][0]['Referrer Name'] = 'John'
            @testDataJSON['Lead'][0]['Referrer Email'] = 'abc@example.com'
            @testDataJSON['Lead'][0]['Assign using active assignment rule'] = true
            @testDataJSON['Lead'][0]['Promo Code'] = "123123"
            @testDataJSON['Lead'][0]['Campaign'] = 'Community Impact Offer'

            @testDataJSON['MarketingLandingPage'][0]['Email'] = @testDataJSON['Lead'][0]['Email']


            @helper.addLogs("[Step ]     : Fetch camapign deatails")            
            campaignInfo = @objLeadGeneration.fetchCampaignDetails('Name',@testDataJSON['Campaign'][0]['Name'])
            expect(campaignInfo).to_not eq nil
            expect(campaignInfo.size).to eq 1
            expect(campaignInfo[0]).to_not eq nil  
            campaignInfo =  campaignInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Update campaign")
            expect(@objLeadGeneration.update_campaign(campaignInfo.fetch('Id'),@testDataJSON['Campaign'][0]['Lead Owner'],@testDataJSON['Campaign'][0]['Email Address'],@testDataJSON['Campaign'][0]['City'])).to eq true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Create lead from Standerd salesforce page")
            expect(@objLeadGeneration.createLeadStdsalesforce).to eq true
            @helper.addLogs("[Validate ] : Checking Lead is created after form submission")
            @helper.addLogs("[Expected ] : Lead should create with email #{@testDataJSON['Lead'][0]['Email']}")

            @helper.addLogs("[Step ]     : Create lead from Marketing Landing Page")
            expect(@objLeadGeneration.createLeadFromMarketingPage).to eq true
            @helper.addLogs("[Validate ] : Checking Lead is created after form submission")
            @helper.addLogs("[Expected ] : Lead should create with email #{@testDataJSON['MarketingLandingPage'][0]['Email']}")

            @helper.addLogs("[Step ]     : Check lead inserted into camapign")
            expect(@objLeadGeneration.checkCamapignMember(@testDataJSON['Lead'][0]['Email'],campaignInfo.fetch('Id'))).to eq true
            @helper.addLogs("[Result ]   : Success\n")

            puts "*******************************************************"


            @helper.addLogs("[Step ]     : Fetch camapign deatails")
            owner = @objLeadGeneration.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
            expect(owner).to_not eq nil
            @helper.addLogs("[Result ]   : Success\n")

            expectedOwner = owner 
            puts expectedOwner

            #owner--campaign assignment
            @helper.addLogs("[Step ]     : Fetch lead deatails")            
            insertedLeadInfo = @objLeadGeneration.fetchLeadDetails(@testDataJSON['Lead'][0]['Email'])
            expect(insertedLeadInfo).to_not eq nil
            expect(insertedLeadInfo.size).to eq 1
            expect(insertedLeadInfo[0]).to_not eq nil  
            insertedLeadInfo =  insertedLeadInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")                       

            puts "********************************************************"
            #owner campaign assignment
            @helper.addLogs("[Step ]     : Fetch journey deatails")            
            insertedJourneyInfo = @objLeadGeneration.fetchJourneyDetails(insertedLeadInfo.fetch("Email"))
            expect(insertedJourneyInfo).to_not eq nil
            expect(insertedJourneyInfo.size).to eq 2
            expect(insertedJourneyInfo[0]).to_not eq nil
            puts insertedJourneyInfo
            insertedJourneyInfo =  insertedJourneyInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")            

            puts "*************************************************************************"
            #activity owner---logged in user
            @helper.addLogs("[Step ]     : Fetch Activity deatails")            
            generatedActivityForLead = @objLeadGeneration.fetchActivityDetails(insertedLeadInfo.fetch("Id"))
            expect(generatedActivityForLead).to_not eq nil
            expect(generatedActivityForLead.size).to eq 2
            expect(generatedActivityForLead[0]).to_not eq nil  
            generatedActivityForLead =  generatedActivityForLead[0] 
            puts generatedActivityForLead
            @helper.addLogs("[Result ]   : Success\n")



            @helper.addLogs('Success')


            @helper.addLogs('Success')
            @helper.postSuccessResult(2594)
        rescue Exception => e
            @helper.addLogs('Error')
            @helper.postFailResult(e,2594)
            raise e
        end
    end



#Std with same camp + MLP---non susie 2A

    it "C:2591 To check lead and journey assignment for new lead owned by non 'Susie Romero' when lead is coming from standard salesforce page and lead is not existing in salesforce, where campaign assignment should be as per 'Lead Owner'", :'2591145'=> 'true' do
        begin
            @helper.addLogs("C:2591 To check lead and journey assignment for new lead owned by non 'Susie Romero' when lead is coming from standard salesforce page and lead is not existing in salesforce, where campaign assignment should be as per 'Lead Owner'.",'2591')
            
            #@testDataJSON['MarketingLandingPage'][0]['Email'] = @testDataJSON['MarketingLandingPage'][0]['Name'] + SecureRandom.random_number(10000000000).to_s + "@example.com"
            @testDataJSON['Campaign'][0]['Name'] = '2018-03-RM-DC-Multi-Touch-Direct-Mail-Apollo'
            @testDataJSON['Campaign'][0]['Lead Owner'] = '0051g000000tSCu'
            @testDataJSON['Campaign'][0]['Email Address'] = ''
            @testDataJSON['Campaign'][0]['City'] = ''

            @testDataJSON['Lead'][0]['RecordType'] = 'Consumer'
            @testDataJSON['Lead'][0]['Email'] = @testDataJSON['Lead'][0]['LastName'] + SecureRandom.random_number(10000000000).to_s + "@example.com"
            @testDataJSON['Lead'][0]['leadSource'] = 'Event'
            @testDataJSON['Lead'][0]['lead_Source_Detail__c'] = 'Book A Tour Form'
            @testDataJSON['Lead'][0]['Interested in Number of Desk(s)'] = '2'
            @testDataJSON['Lead'][0]['Lead Status'] = 'Open'
            @testDataJSON['Lead'][0]['Generate Journey'] = false
            @testDataJSON['Lead'][0]['Restart Journey'] = false
            @testDataJSON['Lead'][0]['Type'] = 'Office Space'
            @testDataJSON['Lead'][0]['Market'] = 'Amsterdam'
            @testDataJSON['Lead'][0]['Locale'] = 'af'
            @testDataJSON['Lead'][0]['Building Interested In'] = 'BKN-Montague St.'
            @testDataJSON['Lead'][0]['Markets Interested'] = 'Amsterdam;Atlanta'
            @testDataJSON['Lead'][0]['Country Code'] = 'AF'
            @testDataJSON['Lead'][0]['Number of Full Time Employees'] = '15'
            @testDataJSON['Lead'][0]['Locations Interested'] = "AMS-Labs;AMS-Strawinskylaan"
            @testDataJSON['Lead'][0]['Referrer'] = 'john snow_QaAuto_121'
            @testDataJSON['Lead'][0]['Referrer Name'] = 'John'
            @testDataJSON['Lead'][0]['Referrer Email'] = 'abc@example.com'
            @testDataJSON['Lead'][0]['Assign using active assignment rule'] = true
            @testDataJSON['Lead'][0]['Promo Code'] = "123123"
            @testDataJSON['Lead'][0]['Campaign'] = @testDataJSON['Campaign'][0]['Name']

            @testDataJSON['MarketingLandingPage'][0]['Email'] = @testDataJSON['Lead'][0]['Email']

            @helper.addLogs("[Step ]     : Fetch camapign deatails")            
            campaignInfo = @objLeadGeneration.fetchCampaignDetails('Name',@testDataJSON['Campaign'][0]['Name'])
            expect(campaignInfo).to_not eq nil
            expect(campaignInfo.size).to eq 1
            expect(campaignInfo[0]).to_not eq nil  
            campaignInfo =  campaignInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Update campaign")
            expect(@objLeadGeneration.update_campaign(campaignInfo.fetch('Id'),@testDataJSON['Campaign'][0]['Lead Owner'],@testDataJSON['Campaign'][0]['Email Address'],@testDataJSON['Campaign'][0]['City'])).to eq true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Create lead from Standerd salesforce page")
            expect(@objLeadGeneration.createLeadStdsalesforce).to eq true
            @helper.addLogs("[Validate ] : Checking Lead is created after form submission")
            @helper.addLogs("[Expected ] : Lead should create with email #{@testDataJSON['Lead'][0]['Email']}")

            @helper.addLogs("[Step ]     : Create lead from Marketing Landing Page")
            expect(@objLeadGeneration.createLeadFromMarketingPage).to eq true
            @helper.addLogs("[Validate ] : Checking Lead is created after form submission")
            @helper.addLogs("[Expected ] : Lead should create with email #{@testDataJSON['MarketingLandingPage'][0]['Email']}")


            @helper.addLogs("[Step ]     : Check lead inserted into camapign")
            expect(@objLeadGeneration.checkCamapignMember(@testDataJSON['Lead'][0]['Email'],campaignInfo.fetch('Id'))).to eq true
            @helper.addLogs("[Result ]   : Success\n")

            puts "*******************************************************"


            @helper.addLogs("[Step ]     : Fetch camapign deatails")
            owner = @objLeadGeneration.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
            expect(owner).to_not eq nil
            @helper.addLogs("[Result ]   : Success\n")

            expectedOwner = owner 
            puts expectedOwner

            #owner--campaign assignment
            @helper.addLogs("[Step ]     : Fetch lead deatails")            
            insertedLeadInfo = @objLeadGeneration.fetchLeadDetails(@testDataJSON['Lead'][0]['Email'])
            expect(insertedLeadInfo).to_not eq nil
            expect(insertedLeadInfo.size).to eq 1
            expect(insertedLeadInfo[0]).to_not eq nil  
            insertedLeadInfo =  insertedLeadInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

                       

            puts "********************************************************"
            #owner campaign assignment
            @helper.addLogs("[Step ]     : Fetch journey deatails")            
            insertedJourneyInfo = @objLeadGeneration.fetchJourneyDetails(insertedLeadInfo.fetch("Email"))
            expect(insertedJourneyInfo).to_not eq nil
            expect(insertedJourneyInfo.size).to eq 1
            expect(insertedJourneyInfo[0]).to_not eq nil  
            insertedJourneyInfo =  insertedJourneyInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            

            puts "*************************************************************************"
            #activity owner---logged in user
            @helper.addLogs("[Step ]     : Fetch Activity deatails")            
            generatedActivityForLead = @objLeadGeneration.fetchActivityDetails(insertedLeadInfo.fetch("Id"))
            expect(generatedActivityForLead).to_not eq nil
            expect(generatedActivityForLead.size).to eq 2
            expect(generatedActivityForLead[0]).to_not eq nil  
            generatedActivityForLead =  generatedActivityForLead[0] 
            puts generatedActivityForLead
            @helper.addLogs("[Result ]   : Success\n")


            @helper.postSuccessResult(2591)
        rescue Exception => e
            @helper.addLogs('Error')
            @helper.postFailResult(e,2591)
            raise e
        end
    end


#std with camp
    it "C:2591 To check lead and journey assignment for new lead owned by non 'Susie Romero' when lead is coming from standard salesforce page and lead is not existing in salesforce, where campaign assignment should be as per 'Lead Owner'", :'2591'=> 'true' do
        begin
            @helper.addLogs("C:2591 To check lead and journey assignment for new lead owned by non 'Susie Romero' when lead is coming from standard salesforce page and lead is not existing in salesforce, where campaign assignment should be as per 'Lead Owner'.",'2591')
            
            #@testDataJSON['MarketingLandingPage'][0]['Email'] = @testDataJSON['MarketingLandingPage'][0]['Name'] + SecureRandom.random_number(10000000000).to_s + "@example.com"
            @testDataJSON['Campaign'][0]['Name'] = '2018-03-RM-DC-Multi-Touch-Direct-Mail-Apollo'
            @testDataJSON['Campaign'][0]['Lead Owner'] = '0051g000000tSCu'
            @testDataJSON['Campaign'][0]['Email Address'] = ''
            @testDataJSON['Campaign'][0]['City'] = ''

            @testDataJSON['Lead'][0]['RecordType'] = 'Consumer'
            @testDataJSON['Lead'][0]['Email'] = @testDataJSON['Lead'][0]['LastName'] + SecureRandom.random_number(10000000000).to_s + "@example.com"
            @testDataJSON['Lead'][0]['leadSource'] = 'Event'
            @testDataJSON['Lead'][0]['lead_Source_Detail__c'] = 'Book A Tour Form'
            @testDataJSON['Lead'][0]['Interested in Number of Desk(s)'] = '2'
            @testDataJSON['Lead'][0]['Lead Status'] = 'Open'
            @testDataJSON['Lead'][0]['Generate Journey'] = false
            @testDataJSON['Lead'][0]['Restart Journey'] = false
            @testDataJSON['Lead'][0]['Type'] = 'Office Space'
            @testDataJSON['Lead'][0]['Market'] = 'Amsterdam'
            @testDataJSON['Lead'][0]['Locale'] = 'af'
            @testDataJSON['Lead'][0]['Building Interested In'] = 'BKN-Montague St.'
            @testDataJSON['Lead'][0]['Markets Interested'] = 'Amsterdam;Atlanta'
            @testDataJSON['Lead'][0]['Country Code'] = 'AF'
            @testDataJSON['Lead'][0]['Number of Full Time Employees'] = '15'
            @testDataJSON['Lead'][0]['Locations Interested'] = "AMS-Labs;AMS-Strawinskylaan"
            @testDataJSON['Lead'][0]['Referrer'] = 'john snow_QaAuto_121'
            @testDataJSON['Lead'][0]['Referrer Name'] = 'John'
            @testDataJSON['Lead'][0]['Referrer Email'] = 'abc@example.com'
            @testDataJSON['Lead'][0]['Assign using active assignment rule'] = true
            @testDataJSON['Lead'][0]['Promo Code'] = "123123"
            @testDataJSON['Lead'][0]['Campaign'] = @testDataJSON['Campaign'][0]['Name']


            @helper.addLogs("[Step ]     : Fetch camapign deatails")            
            campaignInfo = @objLeadGeneration.fetchCampaignDetails('Name',@testDataJSON['Campaign'][0]['Name'])
            expect(campaignInfo).to_not eq nil
            expect(campaignInfo.size).to eq 1
            expect(campaignInfo[0]).to_not eq nil  
            campaignInfo =  campaignInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Fetch building deatails")            
            building = @objLeadGeneration.fetchBuildingDetails(@testDataJSON['Lead'][0]['Building Interested In'])
            expect(building).to_not eq nil
            expect(building.size).to eq 1
            expect(building[0]).to_not eq nil      
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Update campaign")
            expect(@objLeadGeneration.update_campaign(campaignInfo.fetch('Id'),@testDataJSON['Campaign'][0]['Lead Owner'],@testDataJSON['Campaign'][0]['Email Address'],@testDataJSON['Campaign'][0]['City'])).to eq true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Create lead from Standerd salesforce page")
            expect(@objLeadGeneration.createLeadStdsalesforce).to eq true
            @helper.addLogs("[Validate ] : Checking Lead is created after form submission")
            @helper.addLogs("[Expected ] : Lead should create with email #{@testDataJSON['Lead'][0]['Email']}")

            @helper.addLogs("[Step ]     : Check lead inserted into camapign")
            expect(@objLeadGeneration.checkCamapignMember(@testDataJSON['Lead'][0]['Email'],campaignInfo.fetch('Id'))).to eq true
            @helper.addLogs("[Result ]   : Success\n")

            recordType = @objLeadGeneration.getRecordType(@testDataJSON['Lead'][0]['Number of Full Time Employees'].to_i)

            @helper.addLogs("[Step ]     : Fetch camapign deatails")
            expectedOwner = @objLeadGeneration.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
            expect(expectedOwner).to_not eq nil
            @helper.addLogs("[Result ]   : Success\n") 
            puts expectedOwner

            puts "**************************** Checking Lead Fields ****************************"
            #owner--campaign assignment
            @helper.addLogs("[Step ]     : Fetch lead deatails")            
            insertedLeadInfo = @objLeadGeneration.fetchLeadDetails(@testDataJSON['Lead'][0]['Email'])
            expect(insertedLeadInfo).to_not eq nil
            expect(insertedLeadInfo.size).to eq 1
            expect(insertedLeadInfo[0]).to_not eq nil  
            insertedLeadInfo =  insertedLeadInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead owner should be According to Lead Assignment Rule")
            @helper.addLogs("[Expected ] : #{expectedOwner}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Owner").fetch("Id")}")            
            expect(insertedLeadInfo.fetch("Owner").fetch("Id")).to match("#{expectedOwner}")
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking RecordType on lead")
            @helper.addLogs("[Expected ] : #{recordType}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("RecordType").fetch("Name")}")
            expect(insertedLeadInfo.fetch("RecordType").fetch("Name")).to eql recordType
            @helper.addLogs("[Result ]   : Success\n")

            leadExpectedEqlHash = {'Building_Interested_In__c'=>building[0].fetch("Id"),'Generate_Journey__c' => !@testDataJSON['Lead'][0]['Generate Journey'],'Has_Active_Journey__c' => true ,'Market__c'=>@testDataJSON['Lead'][0]['Market'],'LeadSource' => @testDataJSON['Lead'][0]['leadSource'],'Locations_Interested__c'=>@testDataJSON['Lead'][0]['Locations Interested'],'HasOptedOutOfEmail'=>true,'Number_of_Full_Time_Employees__c'=>@testDataJSON['Lead'][0]['Number of Full Time Employees'].to_f,'Country_Code__c' => @testDataJSON['Lead'][0]['Country Code'],'Locale__c'=>@testDataJSON['Lead'][0]['Locale'],'Product_Line__c'=>nil,'Interested_in_Number_of_Desks_Max__c'=>nil,'Interested_in_Number_of_Desks_Min__c'=>nil,'Interested_in_Number_of_Desks_Range__c'=>nil,'Ts_and_Cs_Consent__c'=>false ,'Marketing_Consent__c'=> false,'Email_Quality__c'=>'Pending','Type__c'=>@testDataJSON['Lead'][0]['Type'],'Status'=>@testDataJSON['Lead'][0]['Lead Status'],'Company'=>@testDataJSON['Lead'][0]['Company'],'Email'=>@testDataJSON['Lead'][0]['Email'],'Promo_Code__c'=>@testDataJSON['Lead'][0]['Promo Code'],'Move_In_Time_Frame__c'=>@testDataJSON['Lead'][0]['Move In Time Frame'],'Lead_Source_Detail__c'=>@testDataJSON['Lead'][0]['lead_Source_Detail__c'],'Referrer__c'=>"0031g000008ROtsAAG",'Journey_Created_On__c'=> Date.today.to_s,'Markets_Interested__c'=>@testDataJSON['Lead'][0]['Markets Interested'],'Interested_in_Number_of_Desks__c'=>@testDataJSON['Lead'][0]['Interested in Number of Desk(s)'].to_f,'Referral_Company_Name__c'=>"john.snow_Org_qaauto12121212",'Referrer_Name__c'=>@testDataJSON['Lead'][0]['Referrer Name'],'Referrer_Email__c'=>@testDataJSON['Lead'][0]['Referrer Email'],'Building_Interested_Name__c'=>@testDataJSON['Lead'][0]['Building Interested In']}
            validate_case_eql('Lead',insertedLeadInfo,leadExpectedEqlHash)

            leadExpectedMatchHash = {'Name' => @testDataJSON['Lead'][0]['FirstName'],'Account__c'=>'0011g00000CIkegAAD'}
            validate_case_match('Lead',insertedLeadInfo,leadExpectedMatchHash)                       

            puts "**************************** Checking Journey Fields ****************************"
            
            #owner campaign assignment
            @helper.addLogs("[Step ]     : Fetch journey deatails")            
            insertedJourneyInfo = @objLeadGeneration.fetchJourneyDetails(insertedLeadInfo.fetch("Email"))
            expect(insertedJourneyInfo).to_not eq nil
            expect(insertedJourneyInfo.size).to eq 1
            expect(insertedJourneyInfo[0]).to_not eq nil  
            insertedJourneyInfo =  insertedJourneyInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Journey owner")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Owner").fetch("Name")}")
            @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Owner").fetch("Name")}")
            expect(insertedJourneyInfo.fetch("Owner").fetch("Id")).to eql insertedLeadInfo.fetch("Owner").fetch("Id")
            @helper.addLogs("[Result ]   : Success\n")

            journeyExpectHash = {'Lead_Source__c'=>insertedLeadInfo.fetch("LeadSource"),'Markets_Interested__c'=>insertedLeadInfo.fetch("Markets_Interested__c"),'Lead_Source_Detail__c'=>insertedLeadInfo.fetch("Lead_Source_Detail__c"),'NMD_Next_Contact_Date__c'=>insertedLeadInfo.fetch("Journey_Created_On__c"),'Primary_Email__c'=>insertedLeadInfo.fetch("Email"),'Primary_Phone__c'=>insertedLeadInfo.fetch("Phone"),'Company_Name__c'=>insertedLeadInfo.fetch("Company"),'Status__c'=>'Started','Primary_Lead__c'=>insertedLeadInfo.fetch("Id"),'Looking_For_Number_Of_Desk__c'=>insertedLeadInfo.fetch("Interested_in_Number_of_Desks__c"),'Record_Type__c'=>insertedLeadInfo.fetch("RecordType").fetch("Name"),'Building_Interested_In__c'=>insertedLeadInfo.fetch("Building_Interested_In__c"),'Locations_Interested__c'=>insertedLeadInfo.fetch("Locations_Interested__c"),'Full_Time_Employees__c'=>insertedLeadInfo.fetch("Number_of_Full_Time_Employees__c"),'Marketing_Consent__c'=>false,'Ts_and_Cs_Consent__c'=>false,'CampaignId__c'=>campaignInfo.fetch('Id')}
            validate_case_eql('Journey',insertedJourneyInfo,journeyExpectHash)

            
            journeyExpectedMatchHash = {'Name' => "#{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}"}
            validate_case_match('Lead',insertedJourneyInfo,journeyExpectedMatchHash)            

            puts "**************************** Checking Activity Fields ****************************"
            
            #activity owner---logged in user
            @helper.addLogs("[Step ]     : Fetch Activity deatails")            
            generatedActivityForLead = @objLeadGeneration.fetchActivityDetails(insertedLeadInfo.fetch("Id"))
            expect(generatedActivityForLead).to_not eq nil
            expect(generatedActivityForLead.size).to eq 1
            expect(generatedActivityForLead[0]).to_not eq nil  
            generatedActivityForLead =  generatedActivityForLead[0] 
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking assigned to on activity")
            @helper.addLogs("[Expected ] : Logged In User")#{@userInfo.fetch("display_name")}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Owner").fetch("Name")}")
            #expect(generatedActivityForLead.fetch("Owner").fetch("Name")).to eql @userInfo.fetch("display_name")
            @helper.addLogs("[Result ]   : Success\n")

            activityExpectHash = {'Subject'=>'Inbound Lead submission','Type'=>nil,'Priority'=>'Normal','Lead_Source_Detail__c'=>insertedLeadInfo.fetch("Lead_Source_Detail__c"),'Lead_Source__c'=>insertedLeadInfo.fetch("LeadSource"),'Status'=>'Open','Company__c'=>insertedLeadInfo.fetch('Company'),'Locations_Interested__c'=>insertedLeadInfo.fetch('Locations_Interested__c'),'Number_of_Full_Time_Employees__c'=>insertedLeadInfo.fetch('Number_of_Full_Time_Employees__c'),'Interested_in_Number_of_Desks__c'=>insertedLeadInfo.fetch('Interested_in_Number_of_Desks__c'),'Email__c'=>insertedLeadInfo.fetch('Email'),'Country_Code__c'=>insertedLeadInfo.fetch('Country_Code__c'),'Locale__c'=>insertedLeadInfo.fetch('Locale__c'),'Markets_Interested__c'=>insertedLeadInfo.fetch('Markets_Interested__c'),'Market__c'=>insertedLeadInfo.fetch('Market__c')}
            validate_case_eql('Activity',generatedActivityForLead,activityExpectHash) 

            @helper.postSuccessResult(2591)
        rescue Exception => e
            @helper.addLogs('Error')
            @helper.postFailResult(e,2591)
            raise e
        end
    end

    it "C:2592 To check lead and journey assignment for new lead owned by non 'Susie Romero' when lead is coming from standard salesforce page and lead is not existing in salesforce, where campaign assignment should be as per 'Email Address'", :'2592'=> 'true' do
        begin
            @helper.addLogs("C:2592 To check lead and journey assignment for new lead owned by non 'Susie Romero' when lead is coming from standard salesforce page and lead is not existing in salesforce, where campaign assignment should be as per 'Email Address'.",'2592')
            
            #@testDataJSON['MarketingLandingPage'][0]['Email'] = @testDataJSON['MarketingLandingPage'][0]['Name'] + SecureRandom.random_number(10000000000).to_s + "@example.com"
            @testDataJSON['Campaign'][0]['Name'] = '2018-03-RM-DC-Multi-Touch-Direct-Mail-Apollo'
            @testDataJSON['Campaign'][0]['Lead Owner'] = ''
            @testDataJSON['Campaign'][0]['Email Address'] = 'vikhroliwest@wework.co.in'
            @testDataJSON['Campaign'][0]['City'] = ''

            @testDataJSON['Lead'][0]['RecordType'] = 'Consumer'
            @testDataJSON['Lead'][0]['Email'] = @testDataJSON['Lead'][0]['LastName'] + SecureRandom.random_number(10000000000).to_s + "@example.com"
            @testDataJSON['Lead'][0]['leadSource'] = 'Event'
            @testDataJSON['Lead'][0]['lead_Source_Detail__c'] = 'Book A Tour Form'
            @testDataJSON['Lead'][0]['Interested in Number of Desk(s)'] = '2'
            @testDataJSON['Lead'][0]['Lead Status'] = 'Open'
            @testDataJSON['Lead'][0]['Generate Journey'] = false
            @testDataJSON['Lead'][0]['Restart Journey'] = false
            @testDataJSON['Lead'][0]['Type'] = 'Office Space'
            @testDataJSON['Lead'][0]['Market'] = 'Amsterdam'
            @testDataJSON['Lead'][0]['Locale'] = 'af'
            @testDataJSON['Lead'][0]['Building Interested In'] = 'BKN-Montague St.'
            @testDataJSON['Lead'][0]['Markets Interested'] = 'Amsterdam;Atlanta'
            @testDataJSON['Lead'][0]['Country Code'] = 'AF'
            @testDataJSON['Lead'][0]['Number of Full Time Employees'] = '15'
            @testDataJSON['Lead'][0]['Locations Interested'] = "AMS-Labs;AMS-Strawinskylaan"
            @testDataJSON['Lead'][0]['Referrer'] = 'john snow_QaAuto_121'
            @testDataJSON['Lead'][0]['Referrer Name'] = 'John'
            @testDataJSON['Lead'][0]['Referrer Email'] = 'abc@example.com'
            @testDataJSON['Lead'][0]['Assign using active assignment rule'] = true
            @testDataJSON['Lead'][0]['Promo Code'] = "123123"
            @testDataJSON['Lead'][0]['Campaign'] = @testDataJSON['Campaign'][0]['Name']

            @helper.addLogs("[Step ]     : Fetch camapign deatails")            
            campaignInfo = @objLeadGeneration.fetchCampaignDetails('Name',@testDataJSON['Campaign'][0]['Name'])
            expect(campaignInfo).to_not eq nil
            expect(campaignInfo.size).to eq 1
            expect(campaignInfo[0]).to_not eq nil  
            campaignInfo =  campaignInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Update campaign")
            expect(@objLeadGeneration.update_campaign(campaignInfo.fetch('Id'),@testDataJSON['Campaign'][0]['Lead Owner'],@testDataJSON['Campaign'][0]['Email Address'],@testDataJSON['Campaign'][0]['City'])).to eq true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Create lead from Standerd salesforce page")
            expect(@objLeadGeneration.createLeadStdsalesforce).to eq true
            @helper.addLogs("[Validate ] : Checking Lead is created after form submission")
            @helper.addLogs("[Expected ] : Lead should create with email #{@testDataJSON['Lead'][0]['Email']}")

            @helper.addLogs("[Step ]     : Check lead inserted into camapign")
            expect(@objLeadGeneration.checkCamapignMember(@testDataJSON['Lead'][0]['Email'],campaignInfo.fetch('Id'))).to eq true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Fetch building deatails")            
            building = @objLeadGeneration.fetchBuildingDetails(@testDataJSON['Lead'][0]['Building Interested In'])
            expect(building).to_not eq nil
            expect(building.size).to eq 1
            expect(building[0]).to_not eq nil      
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Fetch camapign deatails")
            expectedOwner = @objLeadGeneration.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
            expect(expectedOwner).to_not eq nil
            @helper.addLogs("[Result ]   : Success\n")

            recordType = @objLeadGeneration.getRecordType(@testDataJSON['Lead'][0]['Number of Full Time Employees'].to_i)

            puts "**************************** Checking Lead Fields ****************************"
            #owner--campaign assignment
            @helper.addLogs("[Step ]     : Fetch lead deatails")            
            insertedLeadInfo = @objLeadGeneration.fetchLeadDetails(@testDataJSON['Lead'][0]['Email'])
            expect(insertedLeadInfo).to_not eq nil
            expect(insertedLeadInfo.size).to eq 1
            expect(insertedLeadInfo[0]).to_not eq nil  
            insertedLeadInfo =  insertedLeadInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead owner should be According to Lead Assignment Rule")
            @helper.addLogs("[Expected ] : #{expectedOwner}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Owner").fetch("Id")}")            
            expect(insertedLeadInfo.fetch("Owner").fetch("Id")).to match("#{expectedOwner}")
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking RecordType on lead")
            @helper.addLogs("[Expected ] : #{recordType}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("RecordType").fetch("Name")}")
            expect(insertedLeadInfo.fetch("RecordType").fetch("Name")).to eql recordType
            @helper.addLogs("[Result ]   : Success\n")

            leadExpectedEqlHash = {'Building_Interested_In__c'=>building[0].fetch("Id"),'Generate_Journey__c' => !@testDataJSON['Lead'][0]['Generate Journey'],'Has_Active_Journey__c' => true ,'Market__c'=>@testDataJSON['Lead'][0]['Market'],'LeadSource' => @testDataJSON['Lead'][0]['leadSource'],'Locations_Interested__c'=>@testDataJSON['Lead'][0]['Locations Interested'],'HasOptedOutOfEmail'=>true,'Number_of_Full_Time_Employees__c'=>@testDataJSON['Lead'][0]['Number of Full Time Employees'].to_f,'Country_Code__c' => @testDataJSON['Lead'][0]['Country Code'],'Locale__c'=>@testDataJSON['Lead'][0]['Locale'],'Product_Line__c'=>nil,'Interested_in_Number_of_Desks_Max__c'=>nil,'Interested_in_Number_of_Desks_Min__c'=>nil,'Interested_in_Number_of_Desks_Range__c'=>nil,'Ts_and_Cs_Consent__c'=>false ,'Marketing_Consent__c'=> false,'Email_Quality__c'=>'Pending','Type__c'=>@testDataJSON['Lead'][0]['Type'],'Status'=>@testDataJSON['Lead'][0]['Lead Status'],'Company'=>@testDataJSON['Lead'][0]['Company'],'Email'=>@testDataJSON['Lead'][0]['Email'],'Promo_Code__c'=>@testDataJSON['Lead'][0]['Promo Code'],'Move_In_Time_Frame__c'=>@testDataJSON['Lead'][0]['Move In Time Frame'],'Lead_Source_Detail__c'=>@testDataJSON['Lead'][0]['lead_Source_Detail__c'],'Referrer__c'=>"0031g000008ROtsAAG",'Journey_Created_On__c'=> Date.today.to_s,'Markets_Interested__c'=>@testDataJSON['Lead'][0]['Markets Interested'],'Interested_in_Number_of_Desks__c'=>@testDataJSON['Lead'][0]['Interested in Number of Desk(s)'].to_f,'Referral_Company_Name__c'=>"john.snow_Org_qaauto12121212",'Referrer_Name__c'=>@testDataJSON['Lead'][0]['Referrer Name'],'Referrer_Email__c'=>@testDataJSON['Lead'][0]['Referrer Email'],'Building_Interested_Name__c'=>@testDataJSON['Lead'][0]['Building Interested In']}
            validate_case_eql('Lead',insertedLeadInfo,leadExpectedEqlHash)

            leadExpectedMatchHash = {'Name' => @testDataJSON['Lead'][0]['FirstName'],'Account__c'=>'0011g00000CIkegAAD'}
            validate_case_match('Lead',insertedLeadInfo,leadExpectedMatchHash)                       

            puts "**************************** Checking Journey Fields ****************************"
            #owner campaign assignment
            @helper.addLogs("[Step ]     : Fetch journey deatails")            
            insertedJourneyInfo = @objLeadGeneration.fetchJourneyDetails(insertedLeadInfo.fetch("Email"))
            expect(insertedJourneyInfo).to_not eq nil
            expect(insertedJourneyInfo.size).to eq 1
            expect(insertedJourneyInfo[0]).to_not eq nil  
            insertedJourneyInfo =  insertedJourneyInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")            

            @helper.addLogs("[Validate ] : Checking Journey owner")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Owner").fetch("Name")}")
            @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Owner").fetch("Name")}")
            expect(insertedJourneyInfo.fetch("Owner").fetch("Id")).to eql insertedLeadInfo.fetch("Owner").fetch("Id")
            @helper.addLogs("[Result ]   : Success\n")

            journeyExpectHash = {'Lead_Source__c'=>insertedLeadInfo.fetch("LeadSource"),'Markets_Interested__c'=>insertedLeadInfo.fetch("Markets_Interested__c"),'Lead_Source_Detail__c'=>insertedLeadInfo.fetch("Lead_Source_Detail__c"),'NMD_Next_Contact_Date__c'=>insertedLeadInfo.fetch("Journey_Created_On__c"),'Primary_Email__c'=>insertedLeadInfo.fetch("Email"),'Primary_Phone__c'=>insertedLeadInfo.fetch("Phone"),'Company_Name__c'=>insertedLeadInfo.fetch("Company"),'Status__c'=>'Started','Primary_Lead__c'=>insertedLeadInfo.fetch("Id"),'Looking_For_Number_Of_Desk__c'=>insertedLeadInfo.fetch("Interested_in_Number_of_Desks__c"),'Record_Type__c'=>insertedLeadInfo.fetch("RecordType").fetch("Name"),'NMD_Next_Contact_Date__c'=>Date.today().to_s,'Building_Interested_In__c'=>insertedLeadInfo.fetch("Building_Interested_In__c"),'Locations_Interested__c'=>insertedLeadInfo.fetch("Locations_Interested__c"),'Full_Time_Employees__c'=>insertedLeadInfo.fetch("Number_of_Full_Time_Employees__c"),'Marketing_Consent__c'=>false,'Ts_and_Cs_Consent__c'=>false,'CampaignId__c'=>campaignInfo.fetch('Id')}
            validate_case_eql('Journey',insertedJourneyInfo,journeyExpectHash)
            
            journeyExpectedMatchHash = {'Name' => "#{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}"}
            validate_case_match('Lead',insertedJourneyInfo,journeyExpectedMatchHash)            

            puts "**************************** Checking Activity Fields ****************************"
            #activity owner---logged in user
            @helper.addLogs("[Step ]     : Fetch Activity deatails")            
            generatedActivityForLead = @objLeadGeneration.fetchActivityDetails(insertedLeadInfo.fetch("Id"))
            expect(generatedActivityForLead).to_not eq nil
            expect(generatedActivityForLead.size).to eq 1
            expect(generatedActivityForLead[0]).to_not eq nil  
            generatedActivityForLead =  generatedActivityForLead[0] 
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking assigned to on activity")
            @helper.addLogs("[Expected ] : Logged In User")#{@userInfo.fetch("display_name")}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Owner").fetch("Name")}")
            #expect(generatedActivityForLead.fetch("Owner").fetch("Name")).to eql @userInfo.fetch("display_name")
            @helper.addLogs("[Result ]   : Success\n")

            activityExpectHash = {'Subject'=>'Inbound Lead submission','Type'=>nil,'Priority'=>'Normal','Lead_Source_Detail__c'=>insertedLeadInfo.fetch("Lead_Source_Detail__c"),'Lead_Source__c'=>insertedLeadInfo.fetch("LeadSource"),'Status'=>'Open','Company__c'=>insertedLeadInfo.fetch('Company'),'Locations_Interested__c'=>insertedLeadInfo.fetch('Locations_Interested__c'),'Number_of_Full_Time_Employees__c'=>insertedLeadInfo.fetch('Number_of_Full_Time_Employees__c'),'Interested_in_Number_of_Desks__c'=>insertedLeadInfo.fetch('Interested_in_Number_of_Desks__c'),'Email__c'=>insertedLeadInfo.fetch('Email'),'Country_Code__c'=>insertedLeadInfo.fetch('Country_Code__c'),'Locale__c'=>insertedLeadInfo.fetch('Locale__c'),'Markets_Interested__c'=>insertedLeadInfo.fetch('Markets_Interested__c'),'Market__c'=>insertedLeadInfo.fetch('Market__c')}
            validate_case_eql('Activity',generatedActivityForLead,activityExpectHash)

            @helper.postSuccessResult(2592)
        rescue Exception => e
            @helper.postFailResult(e,2592)
            raise e
        end
    end

    it "C:2593 To check lead and journey assignment for new lead owned by non 'Susie Romero' when lead is coming from standard salesforce page and lead is not existing in salesforce, where campaign assignment should be as per 'City'", :'2593'=> 'true' do
        begin
            @helper.addLogs("C:2593 To check lead and journey assignment for new lead owned by non 'Susie Romero' when lead is coming from standard salesforce page and lead is not existing in salesforce, where campaign assignment should be as per 'City'.",'2593')
            
            #@testDataJSON['MarketingLandingPage'][0]['Email'] = @testDataJSON['MarketingLandingPage'][0]['Name'] + SecureRandom.random_number(10000000000).to_s + "@example.com"
            @testDataJSON['Campaign'][0]['Name'] = '2018-03-RM-DC-Multi-Touch-Direct-Mail-Apollo'
            @testDataJSON['Campaign'][0]['Lead Owner'] = ''
            @testDataJSON['Campaign'][0]['Email Address'] = ''
            @testDataJSON['Campaign'][0]['City'] = 'Mumbai'

            @testDataJSON['Lead'][0]['RecordType'] = 'Consumer'
            @testDataJSON['Lead'][0]['Email'] = @testDataJSON['Lead'][0]['LastName'] + SecureRandom.random_number(10000000000).to_s + "@example.com"
            @testDataJSON['Lead'][0]['leadSource'] = 'Event'
            @testDataJSON['Lead'][0]['lead_Source_Detail__c'] = 'Book A Tour Form'
            @testDataJSON['Lead'][0]['Interested in Number of Desk(s)'] = '2'
            @testDataJSON['Lead'][0]['Lead Status'] = 'Open'
            @testDataJSON['Lead'][0]['Generate Journey'] = false
            @testDataJSON['Lead'][0]['Restart Journey'] = false
            @testDataJSON['Lead'][0]['Type'] = 'Office Space'
            @testDataJSON['Lead'][0]['Market'] = 'Amsterdam'
            @testDataJSON['Lead'][0]['Locale'] = 'af'
            @testDataJSON['Lead'][0]['Building Interested In'] = 'BKN-Montague St.'
            @testDataJSON['Lead'][0]['Markets Interested'] = 'Amsterdam;Atlanta'
            @testDataJSON['Lead'][0]['Country Code'] = 'AF'
            @testDataJSON['Lead'][0]['Number of Full Time Employees'] = '15'
            @testDataJSON['Lead'][0]['Locations Interested'] = "AMS-Labs;AMS-Strawinskylaan"
            @testDataJSON['Lead'][0]['Referrer'] = 'john snow_QaAuto_121'
            @testDataJSON['Lead'][0]['Referrer Name'] = 'John'
            @testDataJSON['Lead'][0]['Referrer Email'] = 'abc@example.com'
            @testDataJSON['Lead'][0]['Assign using active assignment rule'] = true
            @testDataJSON['Lead'][0]['Promo Code'] = "123123"
            @testDataJSON['Lead'][0]['Campaign'] = @testDataJSON['Campaign'][0]['Name']

            @helper.addLogs("[Step ]     : Fetch camapign deatails")            
            campaignInfo = @objLeadGeneration.fetchCampaignDetails('Name',@testDataJSON['Campaign'][0]['Name'])
            expect(campaignInfo).to_not eq nil
            expect(campaignInfo.size).to eq 1
            expect(campaignInfo[0]).to_not eq nil  
            campaignInfo =  campaignInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Update campaign")
            expect(@objLeadGeneration.update_campaign(campaignInfo.fetch('Id'),@testDataJSON['Campaign'][0]['Lead Owner'],@testDataJSON['Campaign'][0]['Email Address'],@testDataJSON['Campaign'][0]['City'])).to eq true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Create lead from Standerd salesforce page")
            expect(@objLeadGeneration.createLeadStdsalesforce).to eq true
            @helper.addLogs("[Validate ] : Checking Lead is created after form submission")
            @helper.addLogs("[Expected ] : Lead should create with email #{@testDataJSON['Lead'][0]['Email']}")

            @helper.addLogs("[Step ]     : Check lead inserted into camapign")
            expect(@objLeadGeneration.checkCamapignMember(@testDataJSON['Lead'][0]['Email'],campaignInfo.fetch('Id'))).to eq true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Fetch building deatails")            
            building = @objLeadGeneration.fetchBuildingDetails(@testDataJSON['Lead'][0]['Building Interested In'])
            expect(building).to_not eq nil
            expect(building.size).to eq 1
            expect(building[0]).to_not eq nil      
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Fetch camapign deatails")
            expectedOwner = @objLeadGeneration.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
            expect(expectedOwner).to_not eq nil
            @helper.addLogs("[Result ]   : Success\n")

            recordType = @objLeadGeneration.getRecordType(@testDataJSON['Lead'][0]['Number of Full Time Employees'].to_i)

            puts "**************************** Checking Lead Fields ****************************"
            #owner--campaign assignment
            @helper.addLogs("[Step ]     : Fetch lead deatails")            
            insertedLeadInfo = @objLeadGeneration.fetchLeadDetails(@testDataJSON['Lead'][0]['Email'])
            expect(insertedLeadInfo).to_not eq nil
            expect(insertedLeadInfo.size).to eq 1
            expect(insertedLeadInfo[0]).to_not eq nil  
            insertedLeadInfo =  insertedLeadInfo[0]      
            @helper.addLogs("[Result ]   : Success\n") 

            @helper.addLogs("[Validate ] : Checking Lead owner should be According to Lead Assignment Rule")
            @helper.addLogs("[Expected ] : #{expectedOwner}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Owner").fetch("Id")}")            
            expect(insertedLeadInfo.fetch("Owner").fetch("Id")).to match("#{expectedOwner}")
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking RecordType on lead")
            @helper.addLogs("[Expected ] : #{recordType}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("RecordType").fetch("Name")}")
            expect(insertedLeadInfo.fetch("RecordType").fetch("Name")).to eql recordType
            @helper.addLogs("[Result ]   : Success\n")

            leadExpectedEqlHash = {'Building_Interested_In__c'=>building[0].fetch("Id"),'Generate_Journey__c' => !@testDataJSON['Lead'][0]['Generate Journey'],'Has_Active_Journey__c' => true ,'Market__c'=>@testDataJSON['Lead'][0]['Market'],'LeadSource' => @testDataJSON['Lead'][0]['leadSource'],'Locations_Interested__c'=>@testDataJSON['Lead'][0]['Locations Interested'],'HasOptedOutOfEmail'=>true,'Number_of_Full_Time_Employees__c'=>@testDataJSON['Lead'][0]['Number of Full Time Employees'].to_f,'Country_Code__c' => @testDataJSON['Lead'][0]['Country Code'],'Locale__c'=>@testDataJSON['Lead'][0]['Locale'],'Product_Line__c'=>nil,'Interested_in_Number_of_Desks_Max__c'=>nil,'Interested_in_Number_of_Desks_Min__c'=>nil,'Interested_in_Number_of_Desks_Range__c'=>nil,'Ts_and_Cs_Consent__c'=>false ,'Marketing_Consent__c'=> false,'Email_Quality__c'=>'Pending','Type__c'=>@testDataJSON['Lead'][0]['Type'],'Status'=>@testDataJSON['Lead'][0]['Lead Status'],'Company'=>@testDataJSON['Lead'][0]['Company'],'Email'=>@testDataJSON['Lead'][0]['Email'],'Promo_Code__c'=>@testDataJSON['Lead'][0]['Promo Code'],'Move_In_Time_Frame__c'=>@testDataJSON['Lead'][0]['Move In Time Frame'],'Lead_Source_Detail__c'=>@testDataJSON['Lead'][0]['lead_Source_Detail__c'],'Referrer__c'=>"0031g000008ROtsAAG",'Journey_Created_On__c'=> Date.today.to_s,'Markets_Interested__c'=>@testDataJSON['Lead'][0]['Markets Interested'],'Interested_in_Number_of_Desks__c'=>@testDataJSON['Lead'][0]['Interested in Number of Desk(s)'].to_f,'Referral_Company_Name__c'=>"john.snow_Org_qaauto12121212",'Referrer_Name__c'=>@testDataJSON['Lead'][0]['Referrer Name'],'Referrer_Email__c'=>@testDataJSON['Lead'][0]['Referrer Email'],'Building_Interested_Name__c'=>@testDataJSON['Lead'][0]['Building Interested In']}
            validate_case_eql('Lead',insertedLeadInfo,leadExpectedEqlHash)

            leadExpectedMatchHash = {'Name' => @testDataJSON['Lead'][0]['FirstName'],'Account__c'=>'0011g00000CIkegAAD'}
            validate_case_match('Lead',insertedLeadInfo,leadExpectedMatchHash)                       

            puts "**************************** Checking Journey Fields ****************************"
            #owner campaign assignment
            @helper.addLogs("[Step ]     : Fetch journey deatails")            
            insertedJourneyInfo = @objLeadGeneration.fetchJourneyDetails(insertedLeadInfo.fetch("Email"))
            expect(insertedJourneyInfo).to_not eq nil
            expect(insertedJourneyInfo.size).to eq 1
            expect(insertedJourneyInfo[0]).to_not eq nil  
            insertedJourneyInfo =  insertedJourneyInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")            

            @helper.addLogs("[Validate ] : Checking Journey owner")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Owner").fetch("Name")}")
            @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Owner").fetch("Name")}")
            expect(insertedJourneyInfo.fetch("Owner").fetch("Id")).to eql insertedLeadInfo.fetch("Owner").fetch("Id")
            @helper.addLogs("[Result ]   : Success\n")

            journeyExpectHash = {'Lead_Source__c'=>insertedLeadInfo.fetch("LeadSource"),'Markets_Interested__c'=>insertedLeadInfo.fetch("Markets_Interested__c"),'Lead_Source_Detail__c'=>insertedLeadInfo.fetch("Lead_Source_Detail__c"),'NMD_Next_Contact_Date__c'=>insertedLeadInfo.fetch("Journey_Created_On__c"),'Primary_Email__c'=>insertedLeadInfo.fetch("Email"),'Primary_Phone__c'=>insertedLeadInfo.fetch("Phone"),'Company_Name__c'=>insertedLeadInfo.fetch("Company"),'Status__c'=>'Started','Primary_Lead__c'=>insertedLeadInfo.fetch("Id"),'Looking_For_Number_Of_Desk__c'=>insertedLeadInfo.fetch("Interested_in_Number_of_Desks__c"),'Record_Type__c'=>insertedLeadInfo.fetch("RecordType").fetch("Name"),'NMD_Next_Contact_Date__c'=>Date.today().to_s,'Building_Interested_In__c'=>insertedLeadInfo.fetch("Building_Interested_In__c"),'Locations_Interested__c'=>insertedLeadInfo.fetch("Locations_Interested__c"),'Full_Time_Employees__c'=>insertedLeadInfo.fetch("Number_of_Full_Time_Employees__c"),'Marketing_Consent__c'=>false,'Ts_and_Cs_Consent__c'=>false,'CampaignId__c'=>campaignInfo.fetch('Id')}
            validate_case_eql('Journey',insertedJourneyInfo,journeyExpectHash)

            journeyExpectedMatchHash = {'Name' => "#{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}"}
            validate_case_match('Lead',insertedJourneyInfo,journeyExpectedMatchHash)            

            puts "**************************** Checking Activity Fields ****************************"
            #activity owner---logged in user
            @helper.addLogs("[Step ]     : Fetch Activity deatails")            
            generatedActivityForLead = @objLeadGeneration.fetchActivityDetails(insertedLeadInfo.fetch("Id"))
            expect(generatedActivityForLead).to_not eq nil
            expect(generatedActivityForLead.size).to eq 1
            expect(generatedActivityForLead[0]).to_not eq nil  
            generatedActivityForLead =  generatedActivityForLead[0] 
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking assigned to on activity")
            @helper.addLogs("[Expected ] : Logged In User")#{@userInfo.fetch("display_name")}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Owner").fetch("Name")}")
            #expect(generatedActivityForLead.fetch("Owner").fetch("Name")).to eql @userInfo.fetch("display_name")
            @helper.addLogs("[Result ]   : Success\n")

            activityExpectHash = {'Subject'=>'Inbound Lead submission','Type'=>nil,'Priority'=>'Normal','Lead_Source_Detail__c'=>insertedLeadInfo.fetch("Lead_Source_Detail__c"),'Lead_Source__c'=>insertedLeadInfo.fetch("LeadSource"),'Status'=>'Open','Company__c'=>insertedLeadInfo.fetch('Company'),'Locations_Interested__c'=>insertedLeadInfo.fetch('Locations_Interested__c'),'Number_of_Full_Time_Employees__c'=>insertedLeadInfo.fetch('Number_of_Full_Time_Employees__c'),'Interested_in_Number_of_Desks__c'=>insertedLeadInfo.fetch('Interested_in_Number_of_Desks__c'),'Email__c'=>insertedLeadInfo.fetch('Email'),'Country_Code__c'=>insertedLeadInfo.fetch('Country_Code__c'),'Locale__c'=>insertedLeadInfo.fetch('Locale__c'),'Markets_Interested__c'=>insertedLeadInfo.fetch('Markets_Interested__c'),'Market__c'=>insertedLeadInfo.fetch('Market__c')}
            validate_case_eql('Activity',generatedActivityForLead,activityExpectHash)
            
            @helper.postSuccessResult(2593)
        rescue Exception => e
            @helper.postFailResult(e,2593)
            raise e
        end
    end

    it "C:2594 To check lead and journey assignment for new lead owned by non 'Susie Romero' when lead is coming from standard salesforce page and lead is not existing in salesforce, where campaign assignment should be 'Unassigned NMD US Queue'", :'2594'=> 'true' do
        begin
            @helper.addLogs("C:2593 To check lead and journey assignment for new lead owned by non 'Susie Romero' when lead is coming from standard salesforce page and lead is not existing in salesforce, where campaign assignment should be 'Unassigned NMD US Queue'.",'2594')
            
            #@testDataJSON['MarketingLandingPage'][0]['Email'] = @testDataJSON['MarketingLandingPage'][0]['Name'] + SecureRandom.random_number(10000000000).to_s + "@example.com"
            @testDataJSON['Campaign'][0]['Name'] = '2018-03-RM-DC-Multi-Touch-Direct-Mail-Apollo'
            @testDataJSON['Campaign'][0]['Lead Owner'] = ''
            @testDataJSON['Campaign'][0]['Email Address'] = ''
            @testDataJSON['Campaign'][0]['City'] = ''

            @testDataJSON['Lead'][0]['RecordType'] = 'Consumer'
            @testDataJSON['Lead'][0]['Email'] = @testDataJSON['Lead'][0]['LastName'] + SecureRandom.random_number(10000000000).to_s + "@example.com"
            @testDataJSON['Lead'][0]['leadSource'] = 'Event'
            @testDataJSON['Lead'][0]['lead_Source_Detail__c'] = 'Book A Tour Form'
            @testDataJSON['Lead'][0]['Interested in Number of Desk(s)'] = '2'
            @testDataJSON['Lead'][0]['Lead Status'] = 'Open'
            @testDataJSON['Lead'][0]['Generate Journey'] = false
            @testDataJSON['Lead'][0]['Restart Journey'] = false
            @testDataJSON['Lead'][0]['Type'] = 'Office Space'
            @testDataJSON['Lead'][0]['Market'] = 'Amsterdam'
            @testDataJSON['Lead'][0]['Locale'] = 'af'
            @testDataJSON['Lead'][0]['Building Interested In'] = 'BKN-Montague St.'
            @testDataJSON['Lead'][0]['Markets Interested'] = 'Amsterdam;Atlanta'
            @testDataJSON['Lead'][0]['Country Code'] = 'AF'
            @testDataJSON['Lead'][0]['Number of Full Time Employees'] = '15'
            @testDataJSON['Lead'][0]['Locations Interested'] = "AMS-Labs;AMS-Strawinskylaan"
            @testDataJSON['Lead'][0]['Referrer'] = 'john snow_QaAuto_121'
            @testDataJSON['Lead'][0]['Referrer Name'] = 'John'
            @testDataJSON['Lead'][0]['Referrer Email'] = 'abc@example.com'
            @testDataJSON['Lead'][0]['Assign using active assignment rule'] = true
            @testDataJSON['Lead'][0]['Promo Code'] = "123123"
            @testDataJSON['Lead'][0]['Campaign'] = @testDataJSON['Campaign'][0]['Name']

            @helper.addLogs("[Step ]     : Fetch camapign deatails")            
            campaignInfo = @objLeadGeneration.fetchCampaignDetails('Name',@testDataJSON['Campaign'][0]['Name'])
            expect(campaignInfo).to_not eq nil
            expect(campaignInfo.size).to eq 1
            expect(campaignInfo[0]).to_not eq nil  
            campaignInfo =  campaignInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Update campaign")
            expect(@objLeadGeneration.update_campaign(campaignInfo.fetch('Id'),@testDataJSON['Campaign'][0]['Lead Owner'],@testDataJSON['Campaign'][0]['Email Address'],@testDataJSON['Campaign'][0]['City'])).to eq true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Create lead from Standerd salesforce page")
            expect(@objLeadGeneration.createLeadStdsalesforce).to eq true
            @helper.addLogs("[Validate ] : Checking Lead is created after form submission")
            @helper.addLogs("[Expected ] : Lead should create with email #{@testDataJSON['Lead'][0]['Email']}")

            @helper.addLogs("[Step ]     : Check lead inserted into camapign")
            expect(@objLeadGeneration.checkCamapignMember(@testDataJSON['Lead'][0]['Email'],campaignInfo.fetch('Id'))).to eq true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Fetch building deatails")            
            building = @objLeadGeneration.fetchBuildingDetails(@testDataJSON['Lead'][0]['Building Interested In'])
            expect(building).to_not eq nil
            expect(building.size).to eq 1
            expect(building[0]).to_not eq nil      
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Fetch camapign deatails")
            expectedOwner = @objLeadGeneration.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
            expect(expectedOwner).to_not eq nil
            @helper.addLogs("[Result ]   : Success\n")

            recordType = @objLeadGeneration.getRecordType(@testDataJSON['Lead'][0]['Number of Full Time Employees'].to_i)
            puts "**************************** Checking Lead Fields ****************************"
            #owner--campaign assignment
            @helper.addLogs("[Step ]     : Fetch lead deatails")            
            insertedLeadInfo = @objLeadGeneration.fetchLeadDetails(@testDataJSON['Lead'][0]['Email'])
            expect(insertedLeadInfo).to_not eq nil
            expect(insertedLeadInfo.size).to eq 1
            expect(insertedLeadInfo[0]).to_not eq nil  
            insertedLeadInfo =  insertedLeadInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")                       

            @helper.addLogs("[Validate ] : Checking Lead owner should be According to Lead Assignment Rule")
            @helper.addLogs("[Expected ] : #{expectedOwner}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Owner").fetch("Id")}")            
            expect(insertedLeadInfo.fetch("Owner").fetch("Id")).to match("#{expectedOwner}")
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking RecordType on lead")
            @helper.addLogs("[Expected ] : #{recordType}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("RecordType").fetch("Name")}")
            expect(insertedLeadInfo.fetch("RecordType").fetch("Name")).to eql recordType
            @helper.addLogs("[Result ]   : Success\n")

            leadExpectedEqlHash = {'Building_Interested_In__c'=>building[0].fetch("Id"),'Generate_Journey__c' => !@testDataJSON['Lead'][0]['Generate Journey'],'Has_Active_Journey__c' => true ,'Market__c'=>@testDataJSON['Lead'][0]['Market'],'LeadSource' => @testDataJSON['Lead'][0]['leadSource'],'Locations_Interested__c'=>@testDataJSON['Lead'][0]['Locations Interested'],'HasOptedOutOfEmail'=>true,'Number_of_Full_Time_Employees__c'=>@testDataJSON['Lead'][0]['Number of Full Time Employees'].to_f,'Country_Code__c' => @testDataJSON['Lead'][0]['Country Code'],'Locale__c'=>@testDataJSON['Lead'][0]['Locale'],'Product_Line__c'=>nil,'Interested_in_Number_of_Desks_Max__c'=>nil,'Interested_in_Number_of_Desks_Min__c'=>nil,'Interested_in_Number_of_Desks_Range__c'=>nil,'Ts_and_Cs_Consent__c'=>false ,'Marketing_Consent__c'=> false,'Email_Quality__c'=>'Pending','Type__c'=>@testDataJSON['Lead'][0]['Type'],'Status'=>@testDataJSON['Lead'][0]['Lead Status'],'Company'=>@testDataJSON['Lead'][0]['Company'],'Email'=>@testDataJSON['Lead'][0]['Email'],'Promo_Code__c'=>@testDataJSON['Lead'][0]['Promo Code'],'Move_In_Time_Frame__c'=>@testDataJSON['Lead'][0]['Move In Time Frame'],'Lead_Source_Detail__c'=>@testDataJSON['Lead'][0]['lead_Source_Detail__c'],'Referrer__c'=>"0031g000008ROtsAAG",'Journey_Created_On__c'=> Date.today.to_s,'Markets_Interested__c'=>@testDataJSON['Lead'][0]['Markets Interested'],'Interested_in_Number_of_Desks__c'=>@testDataJSON['Lead'][0]['Interested in Number of Desk(s)'].to_f,'Referral_Company_Name__c'=>"john.snow_Org_qaauto12121212",'Referrer_Name__c'=>@testDataJSON['Lead'][0]['Referrer Name'],'Referrer_Email__c'=>@testDataJSON['Lead'][0]['Referrer Email'],'Building_Interested_Name__c'=>@testDataJSON['Lead'][0]['Building Interested In']}
            validate_case_eql('Lead',insertedLeadInfo,leadExpectedEqlHash)

            leadExpectedMatchHash = {'Name' => @testDataJSON['Lead'][0]['FirstName'],'Account__c'=>'0011g00000CIkegAAD'}
            validate_case_match('Lead',insertedLeadInfo,leadExpectedMatchHash)                       

            puts "**************************** Checking Journey Fields ****************************"
            #owner campaign assignment
            @helper.addLogs("[Step ]     : Fetch journey deatails")            
            insertedJourneyInfo = @objLeadGeneration.fetchJourneyDetails(insertedLeadInfo.fetch("Email"))
            expect(insertedJourneyInfo).to_not eq nil
            expect(insertedJourneyInfo.size).to eq 1
            expect(insertedJourneyInfo[0]).to_not eq nil  
            insertedJourneyInfo =  insertedJourneyInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")            

            @helper.addLogs("[Validate ] : Checking Journey owner")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Owner").fetch("Name")}")
            @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Owner").fetch("Name")}")
            expect(insertedJourneyInfo.fetch("Owner").fetch("Id")).to eql insertedLeadInfo.fetch("Owner").fetch("Id")
            @helper.addLogs("[Result ]   : Success\n")

            journeyExpectHash = {'Lead_Source__c'=>insertedLeadInfo.fetch("LeadSource"),'Markets_Interested__c'=>insertedLeadInfo.fetch("Markets_Interested__c"),'Lead_Source_Detail__c'=>insertedLeadInfo.fetch("Lead_Source_Detail__c"),'NMD_Next_Contact_Date__c'=>insertedLeadInfo.fetch("Journey_Created_On__c"),'Primary_Email__c'=>insertedLeadInfo.fetch("Email"),'Primary_Phone__c'=>insertedLeadInfo.fetch("Phone"),'Company_Name__c'=>insertedLeadInfo.fetch("Company"),'Status__c'=>'Started','Primary_Lead__c'=>insertedLeadInfo.fetch("Id"),'Looking_For_Number_Of_Desk__c'=>insertedLeadInfo.fetch("Interested_in_Number_of_Desks__c"),'Record_Type__c'=>insertedLeadInfo.fetch("RecordType").fetch("Name"),'NMD_Next_Contact_Date__c'=>Date.today().to_s,'Building_Interested_In__c'=>insertedLeadInfo.fetch("Building_Interested_In__c"),'Locations_Interested__c'=>insertedLeadInfo.fetch("Locations_Interested__c"),'Full_Time_Employees__c'=>insertedLeadInfo.fetch("Number_of_Full_Time_Employees__c"),'Marketing_Consent__c'=>false,'Ts_and_Cs_Consent__c'=>false,'CampaignId__c'=>campaignInfo.fetch('Id')}
            validate_case_eql('Journey',insertedJourneyInfo,journeyExpectHash)

            
            journeyExpectedMatchHash = {'Name' => "#{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}"}
            validate_case_match('Lead',insertedJourneyInfo,journeyExpectedMatchHash)            

            puts "**************************** Checking Activity Fields ****************************"
            #activity owner---logged in user
            @helper.addLogs("[Step ]     : Fetch Activity deatails")            
            generatedActivityForLead = @objLeadGeneration.fetchActivityDetails(insertedLeadInfo.fetch("Id"))
            expect(generatedActivityForLead).to_not eq nil
            expect(generatedActivityForLead.size).to eq 1
            expect(generatedActivityForLead[0]).to_not eq nil  
            generatedActivityForLead =  generatedActivityForLead[0] 
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking assigned to on activity")
            @helper.addLogs("[Expected ] : Logged In User")#{@userInfo.fetch("display_name")}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Owner").fetch("Name")}")
            #expect(generatedActivityForLead.fetch("Owner").fetch("Name")).to eql @userInfo.fetch("display_name")
            @helper.addLogs("[Result ]   : Success\n")

            activityExpectHash = {'Subject'=>'Inbound Lead submission','Type'=>nil,'Priority'=>'Normal','Lead_Source_Detail__c'=>insertedLeadInfo.fetch("Lead_Source_Detail__c"),'Lead_Source__c'=>insertedLeadInfo.fetch("LeadSource"),'Status'=>'Open','Company__c'=>insertedLeadInfo.fetch('Company'),'Locations_Interested__c'=>insertedLeadInfo.fetch('Locations_Interested__c'),'Number_of_Full_Time_Employees__c'=>insertedLeadInfo.fetch('Number_of_Full_Time_Employees__c'),'Interested_in_Number_of_Desks__c'=>insertedLeadInfo.fetch('Interested_in_Number_of_Desks__c'),'Email__c'=>insertedLeadInfo.fetch('Email'),'Country_Code__c'=>insertedLeadInfo.fetch('Country_Code__c'),'Locale__c'=>insertedLeadInfo.fetch('Locale__c'),'Markets_Interested__c'=>insertedLeadInfo.fetch('Markets_Interested__c'),'Market__c'=>insertedLeadInfo.fetch('Market__c')}
            validate_case_eql('Activity',generatedActivityForLead,activityExpectHash)

            @helper.postSuccessResult(2594)
        rescue Exception => e
            @helper.postFailResult(e,2594)
            raise e
        end
    end

#Std with No--------- camp + MLP  1B non susie
    it "C:2591 To check lead and journey assignment for new lead owned by non 'Susie Romero' when lead is coming from standard salesforce page and lead is not existing in salesforce, where campaign assignment should be as per 'Lead Owner'", :'25911'=> 'true' do
        begin
            @helper.addLogs("C:2591 To check lead and journey assignment for new lead owned by non 'Susie Romero' when lead is coming from standard salesforce page and lead is not existing in salesforce, where campaign assignment should be as per 'Lead Owner'.",'2591')
            
            #@testDataJSON['MarketingLandingPage'][0]['Email'] = @testDataJSON['MarketingLandingPage'][0]['Name'] + SecureRandom.random_number(10000000000).to_s + "@example.com"
            @testDataJSON['Campaign'][0]['Name'] = '2018-03-RM-DC-Multi-Touch-Direct-Mail-Apollo'
            @testDataJSON['Campaign'][0]['Lead Owner'] = '0051g000000tSCu'
            @testDataJSON['Campaign'][0]['Email Address'] = ''
            @testDataJSON['Campaign'][0]['City'] = ''

            @testDataJSON['Lead'][0]['RecordType'] = 'Consumer'
            @testDataJSON['Lead'][0]['Email'] = @testDataJSON['Lead'][0]['LastName'] + SecureRandom.random_number(10000000000).to_s + "@example.com"
            @testDataJSON['Lead'][0]['leadSource'] = 'Event'
            @testDataJSON['Lead'][0]['lead_Source_Detail__c'] = 'Book A Tour Form'
            @testDataJSON['Lead'][0]['Interested in Number of Desk(s)'] = '2'
            @testDataJSON['Lead'][0]['Lead Status'] = 'Open'
            @testDataJSON['Lead'][0]['Generate Journey'] = false
            @testDataJSON['Lead'][0]['Restart Journey'] = false
            @testDataJSON['Lead'][0]['Type'] = 'Office Space'
            @testDataJSON['Lead'][0]['Market'] = 'Amsterdam'
            @testDataJSON['Lead'][0]['Locale'] = 'af'
            @testDataJSON['Lead'][0]['Building Interested In'] = 'BKN-Montague St.'
            @testDataJSON['Lead'][0]['Markets Interested'] = 'Amsterdam;Atlanta'
            @testDataJSON['Lead'][0]['Country Code'] = 'AF'
            @testDataJSON['Lead'][0]['Number of Full Time Employees'] = '15'
            @testDataJSON['Lead'][0]['Locations Interested'] = "AMS-Labs;AMS-Strawinskylaan"
            @testDataJSON['Lead'][0]['Referrer'] = 'john snow_QaAuto_121'
            @testDataJSON['Lead'][0]['Referrer Name'] = 'John'
            @testDataJSON['Lead'][0]['Referrer Email'] = 'abc@example.com'
            @testDataJSON['Lead'][0]['Assign using active assignment rule'] = true
            @testDataJSON['Lead'][0]['Promo Code'] = "123123"
            #@testDataJSON['Lead'][0]['Campaign'] = @testDataJSON['Campaign'][0]['Name']

            @testDataJSON['MarketingLandingPage'][0]['Email'] = @testDataJSON['Lead'][0]['Email']


            @helper.addLogs("[Step ]     : Fetch camapign deatails")            
            campaignInfo = @objLeadGeneration.fetchCampaignDetails('Name',@testDataJSON['Campaign'][0]['Name'])
            expect(campaignInfo).to_not eq nil
            expect(campaignInfo.size).to eq 1
            expect(campaignInfo[0]).to_not eq nil  
            campaignInfo =  campaignInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Update campaign")
            expect(@objLeadGeneration.update_campaign(campaignInfo.fetch('Id'),@testDataJSON['Campaign'][0]['Lead Owner'],@testDataJSON['Campaign'][0]['Email Address'],@testDataJSON['Campaign'][0]['City'])).to eq true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Create lead from Standerd salesforce page")
            expect(@objLeadGeneration.createLeadStdsalesforce).to eq true
            @helper.addLogs("[Validate ] : Checking Lead is created after form submission")
            @helper.addLogs("[Expected ] : Lead should create with email #{@testDataJSON['Lead'][0]['Email']}")

            @helper.addLogs("[Step ]     : Create lead from Marketing Landing Page")
            expect(@objLeadGeneration.createLeadFromMarketingPage).to eq true
            @helper.addLogs("[Validate ] : Checking Lead is created after form submission")
            @helper.addLogs("[Expected ] : Lead should create with email #{@testDataJSON['MarketingLandingPage'][0]['Email']}")


            @helper.addLogs("[Step ]     : Check lead inserted into camapign")
            expect(@objLeadGeneration.checkCamapignMember(@testDataJSON['Lead'][0]['Email'],campaignInfo.fetch('Id'))).to eq true
            @helper.addLogs("[Result ]   : Success\n")

            puts "*******************************************************"


            @helper.addLogs("[Step ]     : Fetch camapign deatails")
            owner = @objLeadGeneration.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
            expect(owner).to_not eq nil
            @helper.addLogs("[Result ]   : Success\n")

            expectedOwner = owner 
            puts expectedOwner

            #owner--campaign assignment
            @helper.addLogs("[Step ]     : Fetch lead deatails")            
            insertedLeadInfo = @objLeadGeneration.fetchLeadDetails(@testDataJSON['Lead'][0]['Email'])
            expect(insertedLeadInfo).to_not eq nil
            expect(insertedLeadInfo.size).to eq 1
            expect(insertedLeadInfo[0]).to_not eq nil  
            insertedLeadInfo =  insertedLeadInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

                       

            puts "********************************************************"
            #owner campaign assignment
            @helper.addLogs("[Step ]     : Fetch journey deatails")            
            insertedJourneyInfo = @objLeadGeneration.fetchJourneyDetails(insertedLeadInfo.fetch("Email"))
            expect(insertedJourneyInfo).to_not eq nil
            expect(insertedJourneyInfo.size).to eq 1
            expect(insertedJourneyInfo[0]).to_not eq nil  
            insertedJourneyInfo =  insertedJourneyInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            

            puts "*************************************************************************"
            #activity owner---logged in user
            @helper.addLogs("[Step ]     : Fetch Activity deatails")            
            generatedActivityForLead = @objLeadGeneration.fetchActivityDetails(insertedLeadInfo.fetch("Id"))
            expect(generatedActivityForLead).to_not eq nil
            expect(generatedActivityForLead.size).to eq 2
            expect(generatedActivityForLead[0]).to_not eq nil  
            generatedActivityForLead =  generatedActivityForLead[0] 
            puts generatedActivityForLead
            @helper.addLogs("[Result ]   : Success\n")


            @helper.postSuccessResult(2591)
        rescue Exception => e
            @helper.addLogs('Error')
            @helper.postFailResult(e,2591)
            raise e
        end
    end

    it "C:2592 To check lead and journey assignment for new lead owned by non 'Susie Romero' when lead is coming from standard salesforce page and lead is not existing in salesforce, where campaign assignment should be as per 'Email Address'", :'25922'=> 'true' do
        begin
            @helper.addLogs("C:2592 To check lead and journey assignment for new lead owned by non 'Susie Romero' when lead is coming from standard salesforce page and lead is not existing in salesforce, where campaign assignment should be as per 'Email Address'.",'2592')
            
            #@testDataJSON['MarketingLandingPage'][0]['Email'] = @testDataJSON['MarketingLandingPage'][0]['Name'] + SecureRandom.random_number(10000000000).to_s + "@example.com"
            @testDataJSON['Campaign'][0]['Name'] = '2018-03-RM-DC-Multi-Touch-Direct-Mail-Apollo'
            @testDataJSON['Campaign'][0]['Lead Owner'] = ''
            @testDataJSON['Campaign'][0]['Email Address'] = 'vikhroliwest@wework.co.in'
            @testDataJSON['Campaign'][0]['City'] = ''

            @testDataJSON['Lead'][0]['RecordType'] = 'Consumer'
            @testDataJSON['Lead'][0]['Email'] = @testDataJSON['Lead'][0]['LastName'] + SecureRandom.random_number(10000000000).to_s + "@example.com"
            @testDataJSON['Lead'][0]['leadSource'] = 'Event'
            @testDataJSON['Lead'][0]['lead_Source_Detail__c'] = 'Book A Tour Form'
            @testDataJSON['Lead'][0]['Interested in Number of Desk(s)'] = '2'
            @testDataJSON['Lead'][0]['Lead Status'] = 'Open'
            @testDataJSON['Lead'][0]['Generate Journey'] = false
            @testDataJSON['Lead'][0]['Restart Journey'] = false
            @testDataJSON['Lead'][0]['Type'] = 'Office Space'
            @testDataJSON['Lead'][0]['Market'] = 'Amsterdam'
            @testDataJSON['Lead'][0]['Locale'] = 'af'
            @testDataJSON['Lead'][0]['Building Interested In'] = 'BKN-Montague St.'
            @testDataJSON['Lead'][0]['Markets Interested'] = 'Amsterdam;Atlanta'
            @testDataJSON['Lead'][0]['Country Code'] = 'AF'
            @testDataJSON['Lead'][0]['Number of Full Time Employees'] = '15'
            @testDataJSON['Lead'][0]['Locations Interested'] = "AMS-Labs;AMS-Strawinskylaan"
            @testDataJSON['Lead'][0]['Referrer'] = 'john snow_QaAuto_121'
            @testDataJSON['Lead'][0]['Referrer Name'] = 'John'
            @testDataJSON['Lead'][0]['Referrer Email'] = 'abc@example.com'
            @testDataJSON['Lead'][0]['Assign using active assignment rule'] = true
            @testDataJSON['Lead'][0]['Promo Code'] = "123123"
            #@testDataJSON['Lead'][0]['Campaign'] = @testDataJSON['Campaign'][0]['Name']

            @testDataJSON['MarketingLandingPage'][0]['Email'] = @testDataJSON['Lead'][0]['Email']


            @helper.addLogs("[Step ]     : Fetch camapign deatails")            
            campaignInfo = @objLeadGeneration.fetchCampaignDetails('Name',@testDataJSON['Campaign'][0]['Name'])
            expect(campaignInfo).to_not eq nil
            expect(campaignInfo.size).to eq 1
            expect(campaignInfo[0]).to_not eq nil  
            campaignInfo =  campaignInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Update campaign")
            expect(@objLeadGeneration.update_campaign(campaignInfo.fetch('Id'),@testDataJSON['Campaign'][0]['Lead Owner'],@testDataJSON['Campaign'][0]['Email Address'],@testDataJSON['Campaign'][0]['City'])).to eq true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Create lead from Standerd salesforce page")
            expect(@objLeadGeneration.createLeadStdsalesforce).to eq true
            @helper.addLogs("[Validate ] : Checking Lead is created after form submission")
            @helper.addLogs("[Expected ] : Lead should create with email #{@testDataJSON['Lead'][0]['Email']}")

            @helper.addLogs("[Step ]     : Create lead from Marketing Landing Page")
            expect(@objLeadGeneration.createLeadFromMarketingPage).to eq true
            @helper.addLogs("[Validate ] : Checking Lead is created after form submission")
            @helper.addLogs("[Expected ] : Lead should create with email #{@testDataJSON['MarketingLandingPage'][0]['Email']}")

            @helper.addLogs("[Step ]     : Check lead inserted into camapign")
            expect(@objLeadGeneration.checkCamapignMember(@testDataJSON['Lead'][0]['Email'],campaignInfo.fetch('Id'))).to eq true
            @helper.addLogs("[Result ]   : Success\n")

            puts "*******************************************************"


            @helper.addLogs("[Step ]     : Fetch camapign deatails")
            owner = @objLeadGeneration.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
            expect(owner).to_not eq nil
            @helper.addLogs("[Result ]   : Success\n")

            expectedOwner = owner 
            puts expectedOwner

            #owner--campaign assignment
            @helper.addLogs("[Step ]     : Fetch lead deatails")            
            insertedLeadInfo = @objLeadGeneration.fetchLeadDetails(@testDataJSON['Lead'][0]['Email'])
            expect(insertedLeadInfo).to_not eq nil
            expect(insertedLeadInfo.size).to eq 1
            expect(insertedLeadInfo[0]).to_not eq nil  
            insertedLeadInfo =  insertedLeadInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")                       

            puts "********************************************************"
            #owner campaign assignment
            @helper.addLogs("[Step ]     : Fetch journey deatails")            
            insertedJourneyInfo = @objLeadGeneration.fetchJourneyDetails(insertedLeadInfo.fetch("Email"))
            expect(insertedJourneyInfo).to_not eq nil
            expect(insertedJourneyInfo.size).to eq 1
            expect(insertedJourneyInfo[0]).to_not eq nil  
            insertedJourneyInfo =  insertedJourneyInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")            

            puts "*************************************************************************"
            #activity owner---logged in user
            @helper.addLogs("[Step ]     : Fetch Activity deatails")            
            generatedActivityForLead = @objLeadGeneration.fetchActivityDetails(insertedLeadInfo.fetch("Id"))
            expect(generatedActivityForLead).to_not eq nil
            expect(generatedActivityForLead.size).to eq 2
            expect(generatedActivityForLead[0]).to_not eq nil  
            generatedActivityForLead =  generatedActivityForLead[0] 
            puts generatedActivityForLead
            @helper.addLogs("[Result ]   : Success\n")

            @helper.postSuccessResult(2592)
        rescue Exception => e
            @helper.addLogs('Error')
            @helper.postFailResult(e,2592)
            raise e
        end
    end

    it "C:2593 To check lead and journey assignment for new lead owned by non 'Susie Romero' when lead is coming from standard salesforce page and lead is not existing in salesforce, where campaign assignment should be as per 'City'", :'25933'=> 'true' do
        begin
            @helper.addLogs("C:2593 To check lead and journey assignment for new lead owned by non 'Susie Romero' when lead is coming from standard salesforce page and lead is not existing in salesforce, where campaign assignment should be as per 'City'.",'2592')
            
            #@testDataJSON['MarketingLandingPage'][0]['Email'] = @testDataJSON['MarketingLandingPage'][0]['Name'] + SecureRandom.random_number(10000000000).to_s + "@example.com"
            @testDataJSON['Campaign'][0]['Name'] = '2018-03-RM-DC-Multi-Touch-Direct-Mail-Apollo'
            @testDataJSON['Campaign'][0]['Lead Owner'] = ''
            @testDataJSON['Campaign'][0]['Email Address'] = ''
            @testDataJSON['Campaign'][0]['City'] = 'Mumbai'

            @testDataJSON['Lead'][0]['RecordType'] = 'Consumer'
            @testDataJSON['Lead'][0]['Email'] = @testDataJSON['Lead'][0]['LastName'] + SecureRandom.random_number(10000000000).to_s + "@example.com"
            @testDataJSON['Lead'][0]['leadSource'] = 'Event'
            @testDataJSON['Lead'][0]['lead_Source_Detail__c'] = 'Book A Tour Form'
            @testDataJSON['Lead'][0]['Interested in Number of Desk(s)'] = '2'
            @testDataJSON['Lead'][0]['Lead Status'] = 'Open'
            @testDataJSON['Lead'][0]['Generate Journey'] = false
            @testDataJSON['Lead'][0]['Restart Journey'] = false
            @testDataJSON['Lead'][0]['Type'] = 'Office Space'
            @testDataJSON['Lead'][0]['Market'] = 'Amsterdam'
            @testDataJSON['Lead'][0]['Locale'] = 'af'
            @testDataJSON['Lead'][0]['Building Interested In'] = 'BKN-Montague St.'
            @testDataJSON['Lead'][0]['Markets Interested'] = 'Amsterdam;Atlanta'
            @testDataJSON['Lead'][0]['Country Code'] = 'AF'
            @testDataJSON['Lead'][0]['Number of Full Time Employees'] = '15'
            @testDataJSON['Lead'][0]['Locations Interested'] = "AMS-Labs;AMS-Strawinskylaan"
            @testDataJSON['Lead'][0]['Referrer'] = 'john snow_QaAuto_121'
            @testDataJSON['Lead'][0]['Referrer Name'] = 'John'
            @testDataJSON['Lead'][0]['Referrer Email'] = 'abc@example.com'
            @testDataJSON['Lead'][0]['Assign using active assignment rule'] = true
            @testDataJSON['Lead'][0]['Promo Code'] = "123123"
            #@testDataJSON['Lead'][0]['Campaign'] = @testDataJSON['Campaign'][0]['Name']

            @testDataJSON['MarketingLandingPage'][0]['Email'] = @testDataJSON['Lead'][0]['Email']


            @helper.addLogs("[Step ]     : Fetch camapign deatails")            
            campaignInfo = @objLeadGeneration.fetchCampaignDetails('Name',@testDataJSON['Campaign'][0]['Name'])
            expect(campaignInfo).to_not eq nil
            expect(campaignInfo.size).to eq 1
            expect(campaignInfo[0]).to_not eq nil  
            campaignInfo =  campaignInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Update campaign")
            expect(@objLeadGeneration.update_campaign(campaignInfo.fetch('Id'),@testDataJSON['Campaign'][0]['Lead Owner'],@testDataJSON['Campaign'][0]['Email Address'],@testDataJSON['Campaign'][0]['City'])).to eq true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Create lead from Standerd salesforce page")
            expect(@objLeadGeneration.createLeadStdsalesforce).to eq true
            @helper.addLogs("[Validate ] : Checking Lead is created after form submission")
            @helper.addLogs("[Expected ] : Lead should create with email #{@testDataJSON['Lead'][0]['Email']}")

            @helper.addLogs("[Step ]     : Create lead from Marketing Landing Page")
            expect(@objLeadGeneration.createLeadFromMarketingPage).to eq true
            @helper.addLogs("[Validate ] : Checking Lead is created after form submission")
            @helper.addLogs("[Expected ] : Lead should create with email #{@testDataJSON['MarketingLandingPage'][0]['Email']}")

            @helper.addLogs("[Step ]     : Check lead inserted into camapign")
            expect(@objLeadGeneration.checkCamapignMember(@testDataJSON['Lead'][0]['Email'],campaignInfo.fetch('Id'))).to eq true
            @helper.addLogs("[Result ]   : Success\n")

            puts "*******************************************************"


            @helper.addLogs("[Step ]     : Fetch camapign deatails")
            owner = @objLeadGeneration.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
            expect(owner).to_not eq nil
            @helper.addLogs("[Result ]   : Success\n")

            expectedOwner = owner 
            puts expectedOwner

            #owner--campaign assignment
            @helper.addLogs("[Step ]     : Fetch lead deatails")            
            insertedLeadInfo = @objLeadGeneration.fetchLeadDetails(@testDataJSON['Lead'][0]['Email'])
            expect(insertedLeadInfo).to_not eq nil
            expect(insertedLeadInfo.size).to eq 1
            expect(insertedLeadInfo[0]).to_not eq nil  
            insertedLeadInfo =  insertedLeadInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")                       

            puts "********************************************************"
            #owner campaign assignment
            @helper.addLogs("[Step ]     : Fetch journey deatails")            
            insertedJourneyInfo = @objLeadGeneration.fetchJourneyDetails(insertedLeadInfo.fetch("Email"))
            expect(insertedJourneyInfo).to_not eq nil
            expect(insertedJourneyInfo.size).to eq 1
            expect(insertedJourneyInfo[0]).to_not eq nil  
            insertedJourneyInfo =  insertedJourneyInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")            

            puts "*************************************************************************"
            #activity owner---logged in user
            @helper.addLogs("[Step ]     : Fetch Activity deatails")            
            generatedActivityForLead = @objLeadGeneration.fetchActivityDetails(insertedLeadInfo.fetch("Id"))
            expect(generatedActivityForLead).to_not eq nil
            expect(generatedActivityForLead.size).to eq 2
            expect(generatedActivityForLead[0]).to_not eq nil  
            generatedActivityForLead =  generatedActivityForLead[0] 
            puts generatedActivityForLead
            @helper.addLogs("[Result ]   : Success\n")



            @helper.addLogs('Success')
            @helper.postSuccessResult(2593)
        rescue Exception => e
            @helper.addLogs('Error')
            @helper.postFailResult(e,2593)
            raise e
        end
    end

    it "C:2594 To check lead and journey assignment for new lead owned by non 'Susie Romero' when lead is coming from standard salesforce page and lead is not existing in salesforce, where campaign assignment should be 'Unassigned NMD US Queue'", :'25944'=> 'true' do
        begin
            @helper.addLogs("C:2593 To check lead and journey assignment for new lead owned by non 'Susie Romero' when lead is coming from standard salesforce page and lead is not existing in salesforce, where campaign assignment should be 'Unassigned NMD US Queue'.",'2592')
            
            #@testDataJSON['MarketingLandingPage'][0]['Email'] = @testDataJSON['MarketingLandingPage'][0]['Name'] + SecureRandom.random_number(10000000000).to_s + "@example.com"
            @testDataJSON['Campaign'][0]['Name'] = '2018-03-RM-DC-Multi-Touch-Direct-Mail-Apollo'
            @testDataJSON['Campaign'][0]['Lead Owner'] = ''
            @testDataJSON['Campaign'][0]['Email Address'] = ''
            @testDataJSON['Campaign'][0]['City'] = ''

            @testDataJSON['Lead'][0]['RecordType'] = 'Consumer'
            @testDataJSON['Lead'][0]['Email'] = @testDataJSON['Lead'][0]['LastName'] + SecureRandom.random_number(10000000000).to_s + "@example.com"
            @testDataJSON['Lead'][0]['leadSource'] = 'Event'
            @testDataJSON['Lead'][0]['lead_Source_Detail__c'] = 'Book A Tour Form'
            @testDataJSON['Lead'][0]['Interested in Number of Desk(s)'] = '2'
            @testDataJSON['Lead'][0]['Lead Status'] = 'Open'
            @testDataJSON['Lead'][0]['Generate Journey'] = false
            @testDataJSON['Lead'][0]['Restart Journey'] = false
            @testDataJSON['Lead'][0]['Type'] = 'Office Space'
            @testDataJSON['Lead'][0]['Market'] = 'Amsterdam'
            @testDataJSON['Lead'][0]['Locale'] = 'af'
            @testDataJSON['Lead'][0]['Building Interested In'] = 'BKN-Montague St.'
            @testDataJSON['Lead'][0]['Markets Interested'] = 'Amsterdam;Atlanta'
            @testDataJSON['Lead'][0]['Country Code'] = 'AF'
            @testDataJSON['Lead'][0]['Number of Full Time Employees'] = '15'
            @testDataJSON['Lead'][0]['Locations Interested'] = "AMS-Labs;AMS-Strawinskylaan"
            @testDataJSON['Lead'][0]['Referrer'] = 'john snow_QaAuto_121'
            @testDataJSON['Lead'][0]['Referrer Name'] = 'John'
            @testDataJSON['Lead'][0]['Referrer Email'] = 'abc@example.com'
            @testDataJSON['Lead'][0]['Assign using active assignment rule'] = true
            @testDataJSON['Lead'][0]['Promo Code'] = "123123"
            #@testDataJSON['Lead'][0]['Campaign'] = @testDataJSON['Campaign'][0]['Name']

            @testDataJSON['MarketingLandingPage'][0]['Email'] = @testDataJSON['Lead'][0]['Email']


            @helper.addLogs("[Step ]     : Fetch camapign deatails")            
            campaignInfo = @objLeadGeneration.fetchCampaignDetails('Name',@testDataJSON['Campaign'][0]['Name'])
            expect(campaignInfo).to_not eq nil
            expect(campaignInfo.size).to eq 1
            expect(campaignInfo[0]).to_not eq nil  
            campaignInfo =  campaignInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Update campaign")
            expect(@objLeadGeneration.update_campaign(campaignInfo.fetch('Id'),@testDataJSON['Campaign'][0]['Lead Owner'],@testDataJSON['Campaign'][0]['Email Address'],@testDataJSON['Campaign'][0]['City'])).to eq true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Create lead from Standerd salesforce page")
            expect(@objLeadGeneration.createLeadStdsalesforce).to eq true
            @helper.addLogs("[Validate ] : Checking Lead is created after form submission")
            @helper.addLogs("[Expected ] : Lead should create with email #{@testDataJSON['Lead'][0]['Email']}")

            @helper.addLogs("[Step ]     : Create lead from Marketing Landing Page")
            expect(@objLeadGeneration.createLeadFromMarketingPage).to eq true
            @helper.addLogs("[Validate ] : Checking Lead is created after form submission")
            @helper.addLogs("[Expected ] : Lead should create with email #{@testDataJSON['MarketingLandingPage'][0]['Email']}")

            @helper.addLogs("[Step ]     : Check lead inserted into camapign")
            expect(@objLeadGeneration.checkCamapignMember(@testDataJSON['Lead'][0]['Email'],campaignInfo.fetch('Id'))).to eq true
            @helper.addLogs("[Result ]   : Success\n")

            puts "*******************************************************"


            @helper.addLogs("[Step ]     : Fetch camapign deatails")
            owner = @objLeadGeneration.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
            expect(owner).to_not eq nil
            @helper.addLogs("[Result ]   : Success\n")

            expectedOwner = owner 
            puts expectedOwner

            #owner--campaign assignment
            @helper.addLogs("[Step ]     : Fetch lead deatails")            
            insertedLeadInfo = @objLeadGeneration.fetchLeadDetails(@testDataJSON['Lead'][0]['Email'])
            expect(insertedLeadInfo).to_not eq nil
            expect(insertedLeadInfo.size).to eq 1
            expect(insertedLeadInfo[0]).to_not eq nil  
            insertedLeadInfo =  insertedLeadInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")                       

            puts "********************************************************"
            #owner campaign assignment
            @helper.addLogs("[Step ]     : Fetch journey deatails")            
            insertedJourneyInfo = @objLeadGeneration.fetchJourneyDetails(insertedLeadInfo.fetch("Email"))
            expect(insertedJourneyInfo).to_not eq nil
            expect(insertedJourneyInfo.size).to eq 1
            expect(insertedJourneyInfo[0]).to_not eq nil  
            insertedJourneyInfo =  insertedJourneyInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")            

            puts "*************************************************************************"
            #activity owner---logged in user
            @helper.addLogs("[Step ]     : Fetch Activity deatails")            
            generatedActivityForLead = @objLeadGeneration.fetchActivityDetails(insertedLeadInfo.fetch("Id"))
            expect(generatedActivityForLead).to_not eq nil
            expect(generatedActivityForLead.size).to eq 2
            expect(generatedActivityForLead[0]).to_not eq nil  
            generatedActivityForLead =  generatedActivityForLead[0] 
            puts generatedActivityForLead
            @helper.addLogs("[Result ]   : Success\n")



            @helper.addLogs('Success')


            @helper.addLogs('Success')
            @helper.postSuccessResult(2594)
        rescue Exception => e
            @helper.addLogs('Error')
            @helper.postFailResult(e,2594)
            raise e
        end
    end

#web site + MLP  1A susie
    it "C:2603 To check lead and journey owner as per 'Lead Owner' campaign assignment for existing lead owned by 'Susie Romero', where existing journey is not associated with campaign and same lead is coming to campaign on same day(TODAY)", :'26031'=> 'true' do
        begin
            @helper.addLogs("C:2603 To check lead and journey owner as per 'Lead Owner' campaign assignment for existing lead owned by 'Susie Romero', where existing journey is not associated with campaign and same lead is coming to campaign on same day(TODAY).",'2603')
            
            @testDataJSON['CreateLeadFromWeb'][0]["BuildingName"]  = 'marol'
            @testDataJSON['CreateLeadFromWeb'][0]["City"]  = 'mumbai'
            @testDataJSON['CreateLeadFromWeb'][0]["Building"]  = 'MUM-Marol'
            @testDataJSON['CreateLeadFromWeb'][0]['Email'] = @testDataJSON['CreateLeadFromWeb'][0]['Name'] + SecureRandom.random_number(10000000000).to_s + "@example.com"
 
            @testDataJSON['MarketingLandingPage'][0]['Email'] = @testDataJSON['CreateLeadFromWeb'][0]['Email']
            @testDataJSON['Campaign'][0]['Name'] = '2018-03-RM-DC-Multi-Touch-Direct-Mail-Apollo'
            @testDataJSON['Campaign'][0]['Lead Owner'] = '0051g000000tSCu'
            @testDataJSON['Campaign'][0]['Email Address'] = ''
            @testDataJSON['Campaign'][0]['City'] = ''

            @testDataJSON['Lead'][0]['leadSource'] = 'WeWork.com'
            @testDataJSON['Lead'][0]['lead_Source_Detail__c'] = 'Marketing Landing Page'
            @testDataJSON['Lead'][0]['RecordType'] = 'Consumer'
            @testDataJSON['Lead'][0]['Lead Status'] = 'Open'
            @testDataJSON['Lead'][0]['Type'] = 'Office Space'
            @testDataJSON['Lead'][0]['Email Quality'] = 'Pending'
            @testDataJSON['Lead'][0]['Locale'] = 'en-US' 
            @testDataJSON['Lead'][0]['Country Code'] = 'IN' 
            @testDataJSON['Lead'][0]['Product Line'] = 'WeWork' 
            @testDataJSON['Lead'][0]['Marketing Consent'] = true 
            @testDataJSON['Lead'][0]['Ts and Cs Consent'] = false

            @helper.addLogs('Go to Staging website and create lead')            
            expect(@objLeadGeneration.createLeadFromWeb(@testDataJSON['CreateLeadFromWeb'][0]['Email'])).to eq true
            @helper.addLogs('Success')             

            @helper.addLogs("[Step ]     : Fetch camapign deatails")            
            campaignInfo = @objLeadGeneration.fetchCampaignDetails('Name',@testDataJSON['Campaign'][0]['Name'])
            expect(campaignInfo).to_not eq nil
            expect(campaignInfo.size).to eq 1
            expect(campaignInfo[0]).to_not eq nil  
            campaignInfo =  campaignInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Update campaign")
            expect(@objLeadGeneration.update_campaign(campaignInfo.fetch('Id'),@testDataJSON['Campaign'][0]['Lead Owner'],@testDataJSON['Campaign'][0]['Email Address'],@testDataJSON['Campaign'][0]['City'])).to eq true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Create lead from Marketing Landing Page")
            expect(@objLeadGeneration.createLeadFromMarketingPage).to eq true
            @helper.addLogs("[Validate ] : Checking Lead is created after form submission")
            @helper.addLogs("[Expected ] : Lead should create with email #{@testDataJSON['MarketingLandingPage'][0]['Email']}")

            @helper.addLogs("[Step ]     : Check lead inserted into camapign")
            expect(@objLeadGeneration.checkCamapignMember(@testDataJSON['MarketingLandingPage'][0]['Email'],campaignInfo.fetch('Id'))).to eq true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Fetch camapign deatails")
            owner = @objLeadGeneration.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
            expect(owner).to_not eq nil
            @helper.addLogs("[Result ]   : Success\n")

            expectedOwner = owner 
                        
            puts "******************************************************"

            @helper.addLogs("[Step ]     : Fetch lead deatails")            
            insertedLeadInfo = @objLeadGeneration.fetchLeadDetails(@testDataJSON['MarketingLandingPage'][0]['Email'])
            expect(insertedLeadInfo).to_not eq nil
            expect(insertedLeadInfo.size).to eq 1
            expect(insertedLeadInfo[0]).to_not eq nil  
            insertedLeadInfo =  insertedLeadInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            
            puts "********************************************************"

            @helper.addLogs("[Step ]     : Fetch journey deatails")            
            insertedJourneyInfo = @objLeadGeneration.fetchJourneyDetails(insertedLeadInfo.fetch("Email"))
            expect(insertedJourneyInfo).to_not eq nil
            expect(insertedJourneyInfo.size).to eq 1
            expect(insertedJourneyInfo[0]).to_not eq nil  
            insertedJourneyInfo =  insertedJourneyInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            puts "*************************************************************************"

            @helper.addLogs("[Step ]     : Fetch Activity deatails")            
            generatedActivityForLead = @objLeadGeneration.fetchActivityDetails(insertedLeadInfo.fetch("Id"))
            expect(generatedActivityForLead).to_not eq nil
            expect(generatedActivityForLead.size).to eq 2
            expect(generatedActivityForLead[0]).to_not eq nil 
            puts generatedActivityForLead[0] 
            generatedActivityForLead =  generatedActivityForLead[0] 
            puts generatedActivityForLead
            @helper.addLogs("[Result ]   : Success\n")


            
            @helper.addLogs('Success')
            @helper.postSuccessResult(2603)
        rescue Exception => e
            @helper.addLogs('Error')
            @helper.postFailResult(e,2603)
            raise e
        end
    end

    it "C:2603 To check lead and journey owner as per 'Lead Owner' campaign assignment for existing lead owned by 'Susie Romero', where existing journey is not associated with campaign and same lead is coming to campaign on same day(TODAY)", :'26032'=> 'true' do
        begin
            @helper.addLogs("C:2603 To check lead and journey owner as per 'Lead Owner' campaign assignment for existing lead owned by 'Susie Romero', where existing journey is not associated with campaign and same lead is coming to campaign on same day(TODAY).",'2603')
            
            @testDataJSON['CreateLeadFromWeb'][0]["BuildingName"]  = 'marol'
            @testDataJSON['CreateLeadFromWeb'][0]["City"]  = 'mumbai'
            @testDataJSON['CreateLeadFromWeb'][0]["Building"]  = 'MUM-Marol'
            @testDataJSON['CreateLeadFromWeb'][0]['Email'] = @testDataJSON['CreateLeadFromWeb'][0]['Name'] + SecureRandom.random_number(10000000000).to_s + "@example.com"
 
            @testDataJSON['MarketingLandingPage'][0]['Email'] = @testDataJSON['CreateLeadFromWeb'][0]['Email']
            @testDataJSON['Campaign'][0]['Name'] = '2018-03-RM-DC-Multi-Touch-Direct-Mail-Apollo'
            @testDataJSON['Campaign'][0]['Lead Owner'] = ''
            @testDataJSON['Campaign'][0]['Email Address'] = 'vikhroliwest@wework.co.in'
            @testDataJSON['Campaign'][0]['City'] = ''

            @testDataJSON['Lead'][0]['leadSource'] = 'WeWork.com'
            @testDataJSON['Lead'][0]['lead_Source_Detail__c'] = 'Marketing Landing Page'
            @testDataJSON['Lead'][0]['RecordType'] = 'Consumer'
            @testDataJSON['Lead'][0]['Lead Status'] = 'Open'
            @testDataJSON['Lead'][0]['Type'] = 'Office Space'
            @testDataJSON['Lead'][0]['Email Quality'] = 'Pending'
            @testDataJSON['Lead'][0]['Locale'] = 'en-US' 
            @testDataJSON['Lead'][0]['Country Code'] = 'IN' 
            @testDataJSON['Lead'][0]['Product Line'] = 'WeWork' 
            @testDataJSON['Lead'][0]['Marketing Consent'] = true 
            @testDataJSON['Lead'][0]['Ts and Cs Consent'] = false

            @helper.addLogs('Go to Staging website and create lead')            
            expect(@objLeadGeneration.createLeadFromWeb(@testDataJSON['CreateLeadFromWeb'][0]['Email'])).to eq true
            @helper.addLogs('Success')             

            @helper.addLogs("[Step ]     : Fetch camapign deatails")            
            campaignInfo = @objLeadGeneration.fetchCampaignDetails('Name',@testDataJSON['Campaign'][0]['Name'])
            expect(campaignInfo).to_not eq nil
            expect(campaignInfo.size).to eq 1
            expect(campaignInfo[0]).to_not eq nil  
            campaignInfo =  campaignInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Update campaign")
            expect(@objLeadGeneration.update_campaign(campaignInfo.fetch('Id'),@testDataJSON['Campaign'][0]['Lead Owner'],@testDataJSON['Campaign'][0]['Email Address'],@testDataJSON['Campaign'][0]['City'])).to eq true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Create lead from Marketing Landing Page")
            expect(@objLeadGeneration.createLeadFromMarketingPage).to eq true
            @helper.addLogs("[Validate ] : Checking Lead is created after form submission")
            @helper.addLogs("[Expected ] : Lead should create with email #{@testDataJSON['MarketingLandingPage'][0]['Email']}")

            @helper.addLogs("[Step ]     : Check lead inserted into camapign")
            expect(@objLeadGeneration.checkCamapignMember(@testDataJSON['MarketingLandingPage'][0]['Email'],campaignInfo.fetch('Id'))).to eq true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Fetch camapign deatails")
            owner = @objLeadGeneration.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
            expect(owner).to_not eq nil
            @helper.addLogs("[Result ]   : Success\n")

            expectedOwner = owner 
            puts expectedOwner
                        
            puts "******************************************************"

            @helper.addLogs("[Step ]     : Fetch lead deatails")            
            insertedLeadInfo = @objLeadGeneration.fetchLeadDetails(@testDataJSON['MarketingLandingPage'][0]['Email'])
            expect(insertedLeadInfo).to_not eq nil
            expect(insertedLeadInfo.size).to eq 1
            expect(insertedLeadInfo[0]).to_not eq nil  
            insertedLeadInfo =  insertedLeadInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            
            puts "********************************************************"

            @helper.addLogs("[Step ]     : Fetch journey deatails")            
            insertedJourneyInfo = @objLeadGeneration.fetchJourneyDetails(insertedLeadInfo.fetch("Email"))
            expect(insertedJourneyInfo).to_not eq nil
            expect(insertedJourneyInfo.size).to eq 1
            expect(insertedJourneyInfo[0]).to_not eq nil  
            insertedJourneyInfo =  insertedJourneyInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            puts "*************************************************************************"

            @helper.addLogs("[Step ]     : Fetch Activity deatails")            
            generatedActivityForLead = @objLeadGeneration.fetchActivityDetails(insertedLeadInfo.fetch("Id"))
            puts "&&&&&&&&&&&&&&&&&&&&&"
            expect(generatedActivityForLead).to_not eq nil
            puts "&&&&&&&&&&&&&&&&&&&&&"
            expect(generatedActivityForLead.size).to eq 2
            puts "&&&&&&&&&&&&&&&&&&&&&"
            expect(generatedActivityForLead[0]).to_not eq nil 
            puts "&&&&&&&&&&&&&&&&&&&&&"
            puts "Activity------>"
            puts generatedActivityForLead
            generatedActivityForLead =  generatedActivityForLead[0] 
            @helper.addLogs("[Result ]   : Success\n")


            
            @helper.addLogs('Success')
            @helper.postSuccessResult(2603)
        rescue Exception => e
            @helper.addLogs('Error')
            @helper.postFailResult(e,2603)
            raise e
        end
    end

    it "C:2603 To check lead and journey owner as per 'Lead Owner' campaign assignment for existing lead owned by 'Susie Romero', where existing journey is not associated with campaign and same lead is coming to campaign on same day(TODAY)", :'26033'=> 'true' do
        begin
            @helper.addLogs("C:2603 To check lead and journey owner as per 'Lead Owner' campaign assignment for existing lead owned by 'Susie Romero', where existing journey is not associated with campaign and same lead is coming to campaign on same day(TODAY).",'2603')
            
            @testDataJSON['CreateLeadFromWeb'][0]["BuildingName"]  = 'marol'
            @testDataJSON['CreateLeadFromWeb'][0]["City"]  = 'mumbai'
            @testDataJSON['CreateLeadFromWeb'][0]["Building"]  = 'MUM-Marol'
            @testDataJSON['CreateLeadFromWeb'][0]['Email'] = @testDataJSON['CreateLeadFromWeb'][0]['Name'] + SecureRandom.random_number(10000000000).to_s + "@example.com"
 
            @testDataJSON['MarketingLandingPage'][0]['Email'] = @testDataJSON['CreateLeadFromWeb'][0]['Email']
            @testDataJSON['Campaign'][0]['Name'] = '2018-03-RM-DC-Multi-Touch-Direct-Mail-Apollo'
            @testDataJSON['Campaign'][0]['Lead Owner'] = ''
            @testDataJSON['Campaign'][0]['Email Address'] = ''
            @testDataJSON['Campaign'][0]['City'] = 'Mumbai'

            @testDataJSON['Lead'][0]['leadSource'] = 'WeWork.com'
            @testDataJSON['Lead'][0]['lead_Source_Detail__c'] = 'Marketing Landing Page'
            @testDataJSON['Lead'][0]['RecordType'] = 'Consumer'
            @testDataJSON['Lead'][0]['Lead Status'] = 'Open'
            @testDataJSON['Lead'][0]['Type'] = 'Office Space'
            @testDataJSON['Lead'][0]['Email Quality'] = 'Pending'
            @testDataJSON['Lead'][0]['Locale'] = 'en-US' 
            @testDataJSON['Lead'][0]['Country Code'] = 'IN' 
            @testDataJSON['Lead'][0]['Product Line'] = 'WeWork' 
            @testDataJSON['Lead'][0]['Marketing Consent'] = true 
            @testDataJSON['Lead'][0]['Ts and Cs Consent'] = false

            @helper.addLogs('Go to Staging website and create lead')            
            expect(@objLeadGeneration.createLeadFromWeb(@testDataJSON['CreateLeadFromWeb'][0]['Email'])).to eq true
            @helper.addLogs('Success')             

            @helper.addLogs("[Step ]     : Fetch camapign deatails")            
            campaignInfo = @objLeadGeneration.fetchCampaignDetails('Name',@testDataJSON['Campaign'][0]['Name'])
            expect(campaignInfo).to_not eq nil
            expect(campaignInfo.size).to eq 1
            expect(campaignInfo[0]).to_not eq nil  
            campaignInfo =  campaignInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Update campaign")
            expect(@objLeadGeneration.update_campaign(campaignInfo.fetch('Id'),@testDataJSON['Campaign'][0]['Lead Owner'],@testDataJSON['Campaign'][0]['Email Address'],@testDataJSON['Campaign'][0]['City'])).to eq true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Create lead from Marketing Landing Page")
            expect(@objLeadGeneration.createLeadFromMarketingPage).to eq true
            @helper.addLogs("[Validate ] : Checking Lead is created after form submission")
            @helper.addLogs("[Expected ] : Lead should create with email #{@testDataJSON['MarketingLandingPage'][0]['Email']}")

            @helper.addLogs("[Step ]     : Check lead inserted into camapign")
            expect(@objLeadGeneration.checkCamapignMember(@testDataJSON['MarketingLandingPage'][0]['Email'],campaignInfo.fetch('Id'))).to eq true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Fetch camapign deatails")
            owner = @objLeadGeneration.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
            expect(owner).to_not eq nil
            @helper.addLogs("[Result ]   : Success\n")

            expectedOwner = owner 
            puts expectedOwner
                        
            puts "******************************************************"

            @helper.addLogs("[Step ]     : Fetch lead deatails")            
            insertedLeadInfo = @objLeadGeneration.fetchLeadDetails(@testDataJSON['MarketingLandingPage'][0]['Email'])
            expect(insertedLeadInfo).to_not eq nil
            expect(insertedLeadInfo.size).to eq 1
            expect(insertedLeadInfo[0]).to_not eq nil  
            insertedLeadInfo =  insertedLeadInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            
            puts "********************************************************"

            @helper.addLogs("[Step ]     : Fetch journey deatails")            
            insertedJourneyInfo = @objLeadGeneration.fetchJourneyDetails(insertedLeadInfo.fetch("Email"))
            expect(insertedJourneyInfo).to_not eq nil
            expect(insertedJourneyInfo.size).to eq 1
            expect(insertedJourneyInfo[0]).to_not eq nil  
            insertedJourneyInfo =  insertedJourneyInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            puts "*************************************************************************"

            @helper.addLogs("[Step ]     : Fetch Activity deatails")            
            generatedActivityForLead = @objLeadGeneration.fetchActivityDetails(insertedLeadInfo.fetch("Id"))
            expect(generatedActivityForLead).to_not eq nil
            expect(generatedActivityForLead.size).to eq 2
            expect(generatedActivityForLead[0]).to_not eq nil 
            puts generatedActivityForLead 
            generatedActivityForLead =  generatedActivityForLead[0] 
            @helper.addLogs("[Result ]   : Success\n")


            
            @helper.addLogs('Success')
            @helper.postSuccessResult(2603)
        rescue Exception => e
            @helper.addLogs('Error')
            @helper.postFailResult(e,2603)
            raise e
        end
    end

    it "C:2603 To check lead and journey owner as per 'Lead Owner' campaign assignment for existing lead owned by 'Susie Romero', where existing journey is not associated with campaign and same lead is coming to campaign on same day(TODAY)", :'26034'=> 'true' do
        begin
            @helper.addLogs("C:2603 To check lead and journey owner as per 'Lead Owner' campaign assignment for existing lead owned by 'Susie Romero', where existing journey is not associated with campaign and same lead is coming to campaign on same day(TODAY).",'2603')
            
            @testDataJSON['CreateLeadFromWeb'][0]["BuildingName"]  = 'marol'
            @testDataJSON['CreateLeadFromWeb'][0]["City"]  = 'mumbai'
            @testDataJSON['CreateLeadFromWeb'][0]["Building"]  = 'MUM-Marol'
            @testDataJSON['CreateLeadFromWeb'][0]['Email'] = @testDataJSON['CreateLeadFromWeb'][0]['Name'] + SecureRandom.random_number(10000000000).to_s + "@example.com"
 
            @testDataJSON['MarketingLandingPage'][0]['Email'] = @testDataJSON['CreateLeadFromWeb'][0]['Email']
            @testDataJSON['Campaign'][0]['Name'] = '2018-03-RM-DC-Multi-Touch-Direct-Mail-Apollo'
            @testDataJSON['Campaign'][0]['Lead Owner'] = ''
            @testDataJSON['Campaign'][0]['Email Address'] = ''
            @testDataJSON['Campaign'][0]['City'] = ''

            @testDataJSON['Lead'][0]['leadSource'] = 'WeWork.com'
            @testDataJSON['Lead'][0]['lead_Source_Detail__c'] = 'Marketing Landing Page'
            @testDataJSON['Lead'][0]['RecordType'] = 'Consumer'
            @testDataJSON['Lead'][0]['Lead Status'] = 'Open'
            @testDataJSON['Lead'][0]['Type'] = 'Office Space'
            @testDataJSON['Lead'][0]['Email Quality'] = 'Pending'
            @testDataJSON['Lead'][0]['Locale'] = 'en-US' 
            @testDataJSON['Lead'][0]['Country Code'] = 'IN' 
            @testDataJSON['Lead'][0]['Product Line'] = 'WeWork' 
            @testDataJSON['Lead'][0]['Marketing Consent'] = true 
            @testDataJSON['Lead'][0]['Ts and Cs Consent'] = false

            @helper.addLogs('Go to Staging website and create lead')            
            expect(@objLeadGeneration.createLeadFromWeb(@testDataJSON['CreateLeadFromWeb'][0]['Email'])).to eq true
            @helper.addLogs('Success')             

            @helper.addLogs("[Step ]     : Fetch camapign deatails")            
            campaignInfo = @objLeadGeneration.fetchCampaignDetails('Name',@testDataJSON['Campaign'][0]['Name'])
            expect(campaignInfo).to_not eq nil
            expect(campaignInfo.size).to eq 1
            expect(campaignInfo[0]).to_not eq nil  
            campaignInfo =  campaignInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Update campaign")
            expect(@objLeadGeneration.update_campaign(campaignInfo.fetch('Id'),@testDataJSON['Campaign'][0]['Lead Owner'],@testDataJSON['Campaign'][0]['Email Address'],@testDataJSON['Campaign'][0]['City'])).to eq true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Create lead from Marketing Landing Page")
            expect(@objLeadGeneration.createLeadFromMarketingPage).to eq true
            @helper.addLogs("[Validate ] : Checking Lead is created after form submission")
            @helper.addLogs("[Expected ] : Lead should create with email #{@testDataJSON['MarketingLandingPage'][0]['Email']}")

            @helper.addLogs("[Step ]     : Check lead inserted into camapign")
            expect(@objLeadGeneration.checkCamapignMember(@testDataJSON['MarketingLandingPage'][0]['Email'],campaignInfo.fetch('Id'))).to eq true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Fetch camapign deatails")
            owner = @objLeadGeneration.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
            expect(owner).to_not eq nil
            @helper.addLogs("[Result ]   : Success\n")

            expectedOwner = owner 
                        
            puts "******************************************************"

            @helper.addLogs("[Step ]     : Fetch lead deatails")            
            insertedLeadInfo = @objLeadGeneration.fetchLeadDetails(@testDataJSON['MarketingLandingPage'][0]['Email'])
            expect(insertedLeadInfo).to_not eq nil
            expect(insertedLeadInfo.size).to eq 1
            expect(insertedLeadInfo[0]).to_not eq nil  
            insertedLeadInfo =  insertedLeadInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            
            puts "********************************************************"

            @helper.addLogs("[Step ]     : Fetch journey deatails")            
            insertedJourneyInfo = @objLeadGeneration.fetchJourneyDetails(insertedLeadInfo.fetch("Email"))
            expect(insertedJourneyInfo).to_not eq nil
            expect(insertedJourneyInfo.size).to eq 1
            expect(insertedJourneyInfo[0]).to_not eq nil  
            insertedJourneyInfo =  insertedJourneyInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            puts "*************************************************************************"

            @helper.addLogs("[Step ]     : Fetch Activity deatails")            
            generatedActivityForLead = @objLeadGeneration.fetchActivityDetails(insertedLeadInfo.fetch("Id"))
            expect(generatedActivityForLead).to_not eq nil
            expect(generatedActivityForLead.size).to eq 2
            expect(generatedActivityForLead[0]).to_not eq nil 
            puts generatedActivityForLead
            generatedActivityForLead =  generatedActivityForLead[0] 
            @helper.addLogs("[Result ]   : Success\n")


            
            @helper.addLogs('Success')
            @helper.postSuccessResult(2603)
        rescue Exception => e
            @helper.addLogs('Error')
            @helper.postFailResult(e,2603)
            raise e
        end
    end


    it "(VIEW LATER)To check lead and journey assignment for duplicate lead submission for two different campaign", :'2582'=> 'true' do
        begin
            #
            #Add steps for test case execution
            #
            @helper.addLogs('Success')
            @helper.postSuccessResult(2582)
        rescue Exception => e
            @helper.addLogs('Error')
            @helper.postFailResult(e,2582)
            raise e
        end
    end

    it "To check campaign assignment for existing lead and journey where existing journey is not associated with any campaign and then same lead with email address come for campaign then campaign assignment should be as per 'Lead owner' field of campaign", :'2596'=> 'true' do
        begin
            #
            #Add steps for test case execution
            #
            @helper.addLogs('Success')
            @helper.postSuccessResult(2596)
        rescue Exception => e
            @helper.addLogs('Error')
            @helper.postFailResult(e,2596)
            raise e
        end
    end


 #existing lead -> today -> 0 journey  ------> MLP -> 1J created 1 A created
    it "C:2591 To check lead and journey assignment for new lead owned by non 'Susie Romero' when lead is coming from standard salesforce page and lead is not existing in salesforce, where campaign assignment should be as per 'Lead Owner'", :'454545'=> 'true' do
        begin
            @helper.addLogs("C:2591 To check lead and journey assignment for new lead owned by non 'Susie Romero' when lead is coming from standard salesforce page and lead is not existing in salesforce, where campaign assignment should be as per 'Lead Owner'.",'2591')
            
            #@testDataJSON['MarketingLandingPage'][0]['Email'] = @testDataJSON['MarketingLandingPage'][0]['Name'] + SecureRandom.random_number(10000000000).to_s + "@example.com"
            @testDataJSON['Campaign'][0]['Name'] = '2018-03-RM-DC-Multi-Touch-Direct-Mail-Apollo'
            @testDataJSON['Campaign'][0]['Lead Owner'] = '0051g000000tSCu'
            @testDataJSON['Campaign'][0]['Email Address'] = ''
            @testDataJSON['Campaign'][0]['City'] = ''

            @testDataJSON['Lead'][0]['RecordType'] = 'Consumer'
            @testDataJSON['Lead'][0]['Email'] = @testDataJSON['Lead'][0]['LastName'] + SecureRandom.random_number(10000000000).to_s + "@example.com"
            @testDataJSON['Lead'][0]['leadSource'] = 'Event'
            @testDataJSON['Lead'][0]['lead_Source_Detail__c'] = 'Book A Tour Form'
            @testDataJSON['Lead'][0]['Interested in Number of Desk(s)'] = '2'
            @testDataJSON['Lead'][0]['Lead Status'] = 'Open'
            @testDataJSON['Lead'][0]['Generate Journey'] = true
            @testDataJSON['Lead'][0]['Restart Journey'] = false
            @testDataJSON['Lead'][0]['Type'] = 'Office Space'
            @testDataJSON['Lead'][0]['Market'] = 'Amsterdam'
            @testDataJSON['Lead'][0]['Locale'] = 'af'
            @testDataJSON['Lead'][0]['Building Interested In'] = 'BKN-Montague St.'
            @testDataJSON['Lead'][0]['Markets Interested'] = 'Amsterdam;Atlanta'
            @testDataJSON['Lead'][0]['Country Code'] = 'AF'
            @testDataJSON['Lead'][0]['Number of Full Time Employees'] = '15'
            @testDataJSON['Lead'][0]['Locations Interested'] = "AMS-Labs;AMS-Strawinskylaan"
            @testDataJSON['Lead'][0]['Referrer'] = 'john snow_QaAuto_121'
            @testDataJSON['Lead'][0]['Referrer Name'] = 'John'
            @testDataJSON['Lead'][0]['Referrer Email'] = 'abc@example.com'
            @testDataJSON['Lead'][0]['Assign using active assignment rule'] = true
            @testDataJSON['Lead'][0]['Promo Code'] = "123123"
            #@testDataJSON['Lead'][0]['Campaign'] = @testDataJSON['Campaign'][0]['Name']

            @testDataJSON['MarketingLandingPage'][0]['Email'] = @testDataJSON['Lead'][0]['Email']


            @helper.addLogs("[Step ]     : Fetch camapign deatails")            
            campaignInfo = @objLeadGeneration.fetchCampaignDetails('Name',@testDataJSON['Campaign'][0]['Name'])
            expect(campaignInfo).to_not eq nil
            expect(campaignInfo.size).to eq 1
            expect(campaignInfo[0]).to_not eq nil  
            campaignInfo =  campaignInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Update campaign")
            expect(@objLeadGeneration.update_campaign(campaignInfo.fetch('Id'),@testDataJSON['Campaign'][0]['Lead Owner'],@testDataJSON['Campaign'][0]['Email Address'],@testDataJSON['Campaign'][0]['City'])).to eq true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Create lead from Standerd salesforce page")
            expect(@objLeadGeneration.createLeadStdsalesforce).to eq true
            @helper.addLogs("[Validate ] : Checking Lead is created after form submission")
            @helper.addLogs("[Expected ] : Lead should create with email #{@testDataJSON['Lead'][0]['Email']}")

            @helper.addLogs("[Step ]     : Create lead from Marketing Landing Page")
            expect(@objLeadGeneration.createLeadFromMarketingPage).to eq true
            @helper.addLogs("[Validate ] : Checking Lead is created after form submission")
            @helper.addLogs("[Expected ] : Lead should create with email #{@testDataJSON['MarketingLandingPage'][0]['Email']}")


            @helper.addLogs("[Step ]     : Check lead inserted into camapign")
            expect(@objLeadGeneration.checkCamapignMember(@testDataJSON['Lead'][0]['Email'],campaignInfo.fetch('Id'))).to eq true
            @helper.addLogs("[Result ]   : Success\n")

            puts "*******************************************************"


            @helper.addLogs("[Step ]     : Fetch camapign deatails")
            owner = @objLeadGeneration.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
            expect(owner).to_not eq nil
            @helper.addLogs("[Result ]   : Success\n")

            expectedOwner = owner 
            puts expectedOwner

            #owner--campaign assignment
            @helper.addLogs("[Step ]     : Fetch lead deatails")            
            insertedLeadInfo = @objLeadGeneration.fetchLeadDetails(@testDataJSON['Lead'][0]['Email'])
            expect(insertedLeadInfo).to_not eq nil
            expect(insertedLeadInfo.size).to eq 1
            expect(insertedLeadInfo[0]).to_not eq nil  
            insertedLeadInfo =  insertedLeadInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

                       

            puts "********************************************************"
            #owner campaign assignment
            @helper.addLogs("[Step ]     : Fetch journey deatails")            
            insertedJourneyInfo = @objLeadGeneration.fetchJourneyDetails(insertedLeadInfo.fetch("Email"))
            expect(insertedJourneyInfo).to_not eq nil
            expect(insertedJourneyInfo.size).to eq 1
            expect(insertedJourneyInfo[0]).to_not eq nil  
            insertedJourneyInfo =  insertedJourneyInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            

            puts "*************************************************************************"
            #activity owner---logged in user
            @helper.addLogs("[Step ]     : Fetch Activity deatails")            
            generatedActivityForLead = @objLeadGeneration.fetchActivityDetails(insertedLeadInfo.fetch("Id"))
            expect(generatedActivityForLead).to_not eq nil
            expect(generatedActivityForLead.size).to eq 1
            expect(generatedActivityForLead[0]).to_not eq nil  
            generatedActivityForLead =  generatedActivityForLead[0] 
            puts generatedActivityForLead
            @helper.addLogs("[Result ]   : Success\n")

            @helper.postSuccessResult(2591)
        rescue Exception => e
            @helper.addLogs('Error')
            @helper.postFailResult(e,2591)
            raise e
        end
    end

#existing lead -> Not today -> 1 journey   ass with no camp ------> MLP -> 1J created 1 A created

    it "C:2603 To check lead and journey owner as per 'Lead Owner' campaign assignment for existing lead owned by 'Susie Romero', where existing journey is not associated with campaign and same lead is coming to campaign on same day(TODAY)", :'45451'=> 'true' do
        begin
            @helper.addLogs("C:2603 To check lead and journey owner as per 'Lead Owner' campaign assignment for existing lead owned by 'Susie Romero', where existing journey is not associated with campaign and same lead is coming to campaign on same day(TODAY).",'2603')
            
            @testDataJSON['Campaign'][0]['Name'] = '2018-03-RM-DC-Multi-Touch-Direct-Mail-Apollo'
            @testDataJSON['Campaign'][0]['Lead Owner'] = '0051g000000tSCu'
            @testDataJSON['Campaign'][0]['Email Address'] = ''
            @testDataJSON['Campaign'][0]['City'] = ''


            @helper.addLogs("[Step ]     : Fetch camapign deatails")            
            campaignInfo = @objLeadGeneration.fetchCampaignDetails('Name',@testDataJSON['Campaign'][0]['Name'])
            expect(campaignInfo).to_not eq nil
            expect(campaignInfo.size).to eq 1
            expect(campaignInfo[0]).to_not eq nil  
            campaignInfo =  campaignInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")


            leadEmailId = @objLeadGeneration.getExistingLead((Date.today - 4).to_datetime,30,"","no",campaignInfo.fetch('Id'))
            puts "******************"
            puts leadEmailId.inspect
            puts "***************" 
            
            
            @testDataJSON['MarketingLandingPage'][0]['Email'] = leadEmailId
            

            @testDataJSON['Lead'][0]['leadSource'] = 'WeWork.com'
            @testDataJSON['Lead'][0]['lead_Source_Detail__c'] = 'Marketing Landing Page'
            @testDataJSON['Lead'][0]['RecordType'] = 'Consumer'
            @testDataJSON['Lead'][0]['Lead Status'] = 'Open'
            @testDataJSON['Lead'][0]['Type'] = 'Office Space'
            @testDataJSON['Lead'][0]['Email Quality'] = 'Pending'
            @testDataJSON['Lead'][0]['Locale'] = 'en-US' 
            @testDataJSON['Lead'][0]['Country Code'] = 'IN' 
            @testDataJSON['Lead'][0]['Product Line'] = 'WeWork' 
            @testDataJSON['Lead'][0]['Marketing Consent'] = true 
            @testDataJSON['Lead'][0]['Ts and Cs Consent'] = false
            

            @helper.addLogs("[Step ]     : Update campaign")
            expect(@objLeadGeneration.update_campaign(campaignInfo.fetch('Id'),@testDataJSON['Campaign'][0]['Lead Owner'],@testDataJSON['Campaign'][0]['Email Address'],@testDataJSON['Campaign'][0]['City'])).to eq true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Create lead from Marketing Landing Page")
            expect(@objLeadGeneration.createLeadFromMarketingPage).to eq true
            @helper.addLogs("[Validate ] : Checking Lead is created after form submission")
            @helper.addLogs("[Expected ] : Lead should create with email #{@testDataJSON['MarketingLandingPage'][0]['Email']}")

            @helper.addLogs("[Step ]     : Check lead inserted into camapign")
            expect(@objLeadGeneration.checkCamapignMember(@testDataJSON['MarketingLandingPage'][0]['Email'],campaignInfo.fetch('Id'))).to eq true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Fetch camapign deatails")
            owner = @objLeadGeneration.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
            expect(owner).to_not eq nil
            @helper.addLogs("[Result ]   : Success\n")

            expectedOwner = owner 
            puts expectedOwner                        
            puts "******************************************************"

            @helper.addLogs("[Step ]     : Fetch lead deatails")            
            insertedLeadInfo = @objLeadGeneration.fetchLeadDetails(@testDataJSON['MarketingLandingPage'][0]['Email'])
            expect(insertedLeadInfo).to_not eq nil
            expect(insertedLeadInfo.size).to eq 1
            expect(insertedLeadInfo[0]).to_not eq nil  
            insertedLeadInfo =  insertedLeadInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            
            puts "********************************************************"

            @helper.addLogs("[Step ]     : Fetch journey deatails")            
            insertedJourneyInfo = @objLeadGeneration.fetchJourneyDetails(insertedLeadInfo.fetch("Email"))
            expect(insertedJourneyInfo).to_not eq nil
            expect(insertedJourneyInfo.size).to eq 2
            expect(insertedJourneyInfo[0]).to_not eq nil  
            insertedJourneyInfo =  insertedJourneyInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            puts "*************************************************************************"

            @helper.addLogs("[Step ]     : Fetch Activity deatails")            
            generatedActivityForLead = @objLeadGeneration.fetchActivityDetails(insertedLeadInfo.fetch("Id"))
            expect(generatedActivityForLead).to_not eq nil
            expect(generatedActivityForLead.size).to eq 2
            expect(generatedActivityForLead[0]).to_not eq nil 
            puts generatedActivityForLead[0] 
            generatedActivityForLead =  generatedActivityForLead[0] 
            puts generatedActivityForLead
            @helper.addLogs("[Result ]   : Success\n")


            
            @helper.addLogs('Success')
            @helper.postSuccessResult(2603)
        rescue Exception => e
            @helper.addLogs('Error')
            @helper.postFailResult(e,2603)
            raise e
        end
    end

    it "C:2603 To check lead and journey owner as per 'Lead Owner' campaign assignment for existing lead owned by 'Susie Romero', where existing journey is not associated with campaign and same lead is coming to campaign on same day(TODAY)", :'45452'=> 'true' do
        begin
            @helper.addLogs("C:2603 To check lead and journey owner as per 'Lead Owner' campaign assignment for existing lead owned by 'Susie Romero', where existing journey is not associated with campaign and same lead is coming to campaign on same day(TODAY).",'2603')
            
            @testDataJSON['Campaign'][0]['Name'] = '2018-03-RM-DC-Multi-Touch-Direct-Mail-Apollo'
            @testDataJSON['Campaign'][0]['Lead Owner'] = ''
            @testDataJSON['Campaign'][0]['Email Address'] = 'vikhroliwest@wework.co.in'
            @testDataJSON['Campaign'][0]['City'] = ''


            @helper.addLogs("[Step ]     : Fetch camapign deatails")            
            campaignInfo = @objLeadGeneration.fetchCampaignDetails('Name',@testDataJSON['Campaign'][0]['Name'])
            expect(campaignInfo).to_not eq nil
            expect(campaignInfo.size).to eq 1
            expect(campaignInfo[0]).to_not eq nil  
            campaignInfo =  campaignInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")


            leadEmailId = @objLeadGeneration.getExistingLead((Date.today - 4).to_datetime,30,"","no",campaignInfo.fetch('Id'))
            puts "******************"
            puts leadEmailId.inspect
            puts "***************" 
            
            
            @testDataJSON['MarketingLandingPage'][0]['Email'] = leadEmailId
            

            @testDataJSON['Lead'][0]['leadSource'] = 'WeWork.com'
            @testDataJSON['Lead'][0]['lead_Source_Detail__c'] = 'Marketing Landing Page'
            @testDataJSON['Lead'][0]['RecordType'] = 'Consumer'
            @testDataJSON['Lead'][0]['Lead Status'] = 'Open'
            @testDataJSON['Lead'][0]['Type'] = 'Office Space'
            @testDataJSON['Lead'][0]['Email Quality'] = 'Pending'
            @testDataJSON['Lead'][0]['Locale'] = 'en-US' 
            @testDataJSON['Lead'][0]['Country Code'] = 'IN' 
            @testDataJSON['Lead'][0]['Product Line'] = 'WeWork' 
            @testDataJSON['Lead'][0]['Marketing Consent'] = true 
            @testDataJSON['Lead'][0]['Ts and Cs Consent'] = false
            

            @helper.addLogs("[Step ]     : Update campaign")
            expect(@objLeadGeneration.update_campaign(campaignInfo.fetch('Id'),@testDataJSON['Campaign'][0]['Lead Owner'],@testDataJSON['Campaign'][0]['Email Address'],@testDataJSON['Campaign'][0]['City'])).to eq true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Create lead from Marketing Landing Page")
            expect(@objLeadGeneration.createLeadFromMarketingPage).to eq true
            @helper.addLogs("[Validate ] : Checking Lead is created after form submission")
            @helper.addLogs("[Expected ] : Lead should create with email #{@testDataJSON['MarketingLandingPage'][0]['Email']}")

            @helper.addLogs("[Step ]     : Check lead inserted into camapign")
            expect(@objLeadGeneration.checkCamapignMember(@testDataJSON['MarketingLandingPage'][0]['Email'],campaignInfo.fetch('Id'))).to eq true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Fetch camapign deatails")
            owner = @objLeadGeneration.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
            expect(owner).to_not eq nil
            @helper.addLogs("[Result ]   : Success\n")

            expectedOwner = owner 
            puts expectedOwner                        
            puts "******************************************************"

            @helper.addLogs("[Step ]     : Fetch lead deatails")            
            insertedLeadInfo = @objLeadGeneration.fetchLeadDetails(@testDataJSON['MarketingLandingPage'][0]['Email'])
            expect(insertedLeadInfo).to_not eq nil
            expect(insertedLeadInfo.size).to eq 1
            expect(insertedLeadInfo[0]).to_not eq nil  
            insertedLeadInfo =  insertedLeadInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            
            puts "********************************************************"

            @helper.addLogs("[Step ]     : Fetch journey deatails")            
            insertedJourneyInfo = @objLeadGeneration.fetchJourneyDetails(insertedLeadInfo.fetch("Email"))
            expect(insertedJourneyInfo).to_not eq nil
            expect(insertedJourneyInfo.size).to eq 2
            expect(insertedJourneyInfo[0]).to_not eq nil  
            insertedJourneyInfo =  insertedJourneyInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            puts "*************************************************************************"

            @helper.addLogs("[Step ]     : Fetch Activity deatails")            
            generatedActivityForLead = @objLeadGeneration.fetchActivityDetails(insertedLeadInfo.fetch("Id"))
            expect(generatedActivityForLead).to_not eq nil
            expect(generatedActivityForLead.size).to eq 2
            expect(generatedActivityForLead[0]).to_not eq nil 
            puts generatedActivityForLead[0] 
            generatedActivityForLead =  generatedActivityForLead[0] 
            puts generatedActivityForLead
            @helper.addLogs("[Result ]   : Success\n")


            
            @helper.addLogs('Success')
            @helper.postSuccessResult(2603)
        rescue Exception => e
            @helper.addLogs('Error')
            @helper.postFailResult(e,2603)
            raise e
        end
    end

    it "C:2603 To check lead and journey owner as per 'Lead Owner' campaign assignment for existing lead owned by 'Susie Romero', where existing journey is not associated with campaign and same lead is coming to campaign on same day(TODAY)", :'45453'=> 'true' do
        begin
            @helper.addLogs("C:2603 To check lead and journey owner as per 'Lead Owner' campaign assignment for existing lead owned by 'Susie Romero', where existing journey is not associated with campaign and same lead is coming to campaign on same day(TODAY).",'2603')
            
            @testDataJSON['Campaign'][0]['Name'] = '2018-03-RM-DC-Multi-Touch-Direct-Mail-Apollo'
            @testDataJSON['Campaign'][0]['Lead Owner'] = ''
            @testDataJSON['Campaign'][0]['Email Address'] = ''
            @testDataJSON['Campaign'][0]['City'] = 'Mumbai'


            @helper.addLogs("[Step ]     : Fetch camapign deatails")            
            campaignInfo = @objLeadGeneration.fetchCampaignDetails('Name',@testDataJSON['Campaign'][0]['Name'])
            expect(campaignInfo).to_not eq nil
            expect(campaignInfo.size).to eq 1
            expect(campaignInfo[0]).to_not eq nil  
            campaignInfo =  campaignInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")


            leadEmailId = @objLeadGeneration.getExistingLead((Date.today - 4).to_datetime,30,"","no",campaignInfo.fetch('Id'))
            puts "******************"
            puts leadEmailId.inspect
            puts "***************" 
            
            
            @testDataJSON['MarketingLandingPage'][0]['Email'] = leadEmailId
            

            @testDataJSON['Lead'][0]['leadSource'] = 'WeWork.com'
            @testDataJSON['Lead'][0]['lead_Source_Detail__c'] = 'Marketing Landing Page'
            @testDataJSON['Lead'][0]['RecordType'] = 'Consumer'
            @testDataJSON['Lead'][0]['Lead Status'] = 'Open'
            @testDataJSON['Lead'][0]['Type'] = 'Office Space'
            @testDataJSON['Lead'][0]['Email Quality'] = 'Pending'
            @testDataJSON['Lead'][0]['Locale'] = 'en-US' 
            @testDataJSON['Lead'][0]['Country Code'] = 'IN' 
            @testDataJSON['Lead'][0]['Product Line'] = 'WeWork' 
            @testDataJSON['Lead'][0]['Marketing Consent'] = true 
            @testDataJSON['Lead'][0]['Ts and Cs Consent'] = false
            

            @helper.addLogs("[Step ]     : Update campaign")
            expect(@objLeadGeneration.update_campaign(campaignInfo.fetch('Id'),@testDataJSON['Campaign'][0]['Lead Owner'],@testDataJSON['Campaign'][0]['Email Address'],@testDataJSON['Campaign'][0]['City'])).to eq true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Create lead from Marketing Landing Page")
            expect(@objLeadGeneration.createLeadFromMarketingPage).to eq true
            @helper.addLogs("[Validate ] : Checking Lead is created after form submission")
            @helper.addLogs("[Expected ] : Lead should create with email #{@testDataJSON['MarketingLandingPage'][0]['Email']}")

            @helper.addLogs("[Step ]     : Check lead inserted into camapign")
            expect(@objLeadGeneration.checkCamapignMember(@testDataJSON['MarketingLandingPage'][0]['Email'],campaignInfo.fetch('Id'))).to eq true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Fetch camapign deatails")
            owner = @objLeadGeneration.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
            expect(owner).to_not eq nil
            @helper.addLogs("[Result ]   : Success\n")

            expectedOwner = owner 
            puts expectedOwner                        
            puts "******************************************************"

            @helper.addLogs("[Step ]     : Fetch lead deatails")            
            insertedLeadInfo = @objLeadGeneration.fetchLeadDetails(@testDataJSON['MarketingLandingPage'][0]['Email'])
            expect(insertedLeadInfo).to_not eq nil
            expect(insertedLeadInfo.size).to eq 1
            expect(insertedLeadInfo[0]).to_not eq nil  
            insertedLeadInfo =  insertedLeadInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            
            puts "********************************************************"

            @helper.addLogs("[Step ]     : Fetch journey deatails")            
            insertedJourneyInfo = @objLeadGeneration.fetchJourneyDetails(insertedLeadInfo.fetch("Email"))
            expect(insertedJourneyInfo).to_not eq nil
            expect(insertedJourneyInfo.size).to eq 2
            expect(insertedJourneyInfo[0]).to_not eq nil  
            insertedJourneyInfo =  insertedJourneyInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            puts "*************************************************************************"

            @helper.addLogs("[Step ]     : Fetch Activity deatails")            
            generatedActivityForLead = @objLeadGeneration.fetchActivityDetails(insertedLeadInfo.fetch("Id"))
            expect(generatedActivityForLead).to_not eq nil
            expect(generatedActivityForLead.size).to eq 2
            expect(generatedActivityForLead[0]).to_not eq nil 
            puts generatedActivityForLead[0] 
            generatedActivityForLead =  generatedActivityForLead[0] 
            puts generatedActivityForLead
            @helper.addLogs("[Result ]   : Success\n")
            
            @helper.addLogs('Success')
            @helper.postSuccessResult(2603)
        rescue Exception => e
            @helper.addLogs('Error')
            @helper.postFailResult(e,2603)
            raise e
        end
    end

    it "C:2603 To check lead and journey owner as per 'Lead Owner' campaign assignment for existing lead owned by 'Susie Romero', where existing journey is not associated with campaign and same lead is coming to campaign on same day(TODAY)", :'45454'=> 'true' do
        begin
            @helper.addLogs("C:2603 To check lead and journey owner as per 'Lead Owner' campaign assignment for existing lead owned by 'Susie Romero', where existing journey is not associated with campaign and same lead is coming to campaign on same day(TODAY).",'2603')
            
            @testDataJSON['Campaign'][0]['Name'] = '2018-03-RM-DC-Multi-Touch-Direct-Mail-Apollo'
            @testDataJSON['Campaign'][0]['Lead Owner'] = ''
            @testDataJSON['Campaign'][0]['Email Address'] = ''
            @testDataJSON['Campaign'][0]['City'] = ''


            @helper.addLogs("[Step ]     : Fetch camapign deatails")            
            campaignInfo = @objLeadGeneration.fetchCampaignDetails('Name',@testDataJSON['Campaign'][0]['Name'])
            expect(campaignInfo).to_not eq nil
            expect(campaignInfo.size).to eq 1
            expect(campaignInfo[0]).to_not eq nil  
            campaignInfo =  campaignInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")


            leadEmailId = @objLeadGeneration.getExistingLead((Date.today - 4).to_datetime,30,"","no",campaignInfo.fetch('Id'))
            puts "******************"
            puts leadEmailId.inspect
            puts "***************" 
            
            
            @testDataJSON['MarketingLandingPage'][0]['Email'] = leadEmailId
            

            @testDataJSON['Lead'][0]['leadSource'] = 'WeWork.com'
            @testDataJSON['Lead'][0]['lead_Source_Detail__c'] = 'Marketing Landing Page'
            @testDataJSON['Lead'][0]['RecordType'] = 'Consumer'
            @testDataJSON['Lead'][0]['Lead Status'] = 'Open'
            @testDataJSON['Lead'][0]['Type'] = 'Office Space'
            @testDataJSON['Lead'][0]['Email Quality'] = 'Pending'
            @testDataJSON['Lead'][0]['Locale'] = 'en-US' 
            @testDataJSON['Lead'][0]['Country Code'] = 'IN' 
            @testDataJSON['Lead'][0]['Product Line'] = 'WeWork' 
            @testDataJSON['Lead'][0]['Marketing Consent'] = true 
            @testDataJSON['Lead'][0]['Ts and Cs Consent'] = false
            

            @helper.addLogs("[Step ]     : Update campaign")
            expect(@objLeadGeneration.update_campaign(campaignInfo.fetch('Id'),@testDataJSON['Campaign'][0]['Lead Owner'],@testDataJSON['Campaign'][0]['Email Address'],@testDataJSON['Campaign'][0]['City'])).to eq true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Create lead from Marketing Landing Page")
            expect(@objLeadGeneration.createLeadFromMarketingPage).to eq true
            @helper.addLogs("[Validate ] : Checking Lead is created after form submission")
            @helper.addLogs("[Expected ] : Lead should create with email #{@testDataJSON['MarketingLandingPage'][0]['Email']}")

            @helper.addLogs("[Step ]     : Check lead inserted into camapign")
            expect(@objLeadGeneration.checkCamapignMember(@testDataJSON['MarketingLandingPage'][0]['Email'],campaignInfo.fetch('Id'))).to eq true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Fetch camapign deatails")
            owner = @objLeadGeneration.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
            expect(owner).to_not eq nil
            @helper.addLogs("[Result ]   : Success\n")

            expectedOwner = owner 
            puts expectedOwner                        
            puts "******************************************************"

            @helper.addLogs("[Step ]     : Fetch lead deatails")            
            insertedLeadInfo = @objLeadGeneration.fetchLeadDetails(@testDataJSON['MarketingLandingPage'][0]['Email'])
            expect(insertedLeadInfo).to_not eq nil
            expect(insertedLeadInfo.size).to eq 1
            expect(insertedLeadInfo[0]).to_not eq nil  
            insertedLeadInfo =  insertedLeadInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            
            puts "********************************************************"

            @helper.addLogs("[Step ]     : Fetch journey deatails")            
            insertedJourneyInfo = @objLeadGeneration.fetchJourneyDetails(insertedLeadInfo.fetch("Email"))
            expect(insertedJourneyInfo).to_not eq nil
            expect(insertedJourneyInfo.size).to eq 2
            expect(insertedJourneyInfo[0]).to_not eq nil  
            insertedJourneyInfo =  insertedJourneyInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            puts "*************************************************************************"

            @helper.addLogs("[Step ]     : Fetch Activity deatails")            
            generatedActivityForLead = @objLeadGeneration.fetchActivityDetails(insertedLeadInfo.fetch("Id"))
            expect(generatedActivityForLead).to_not eq nil
            expect(generatedActivityForLead.size).to eq 2
            expect(generatedActivityForLead[0]).to_not eq nil 
            puts generatedActivityForLead[0] 
            generatedActivityForLead =  generatedActivityForLead[0] 
            puts generatedActivityForLead
            @helper.addLogs("[Result ]   : Success\n")


            
            @helper.addLogs('Success')
            @helper.postSuccessResult(2603)
        rescue Exception => e
            @helper.addLogs('Error')
            @helper.postFailResult(e,2603)
            raise e
        end
    end


#existing lead -> Not today -> 1 journey   ass with same camp ------> MLP -> 1J update 1 A created
    it "C:2603 To check lead and journey owner as per 'Lead Owner' campaign assignment for existing lead owned by 'Susie Romero', where existing journey is not associated with campaign and same lead is coming to campaign on same day(TODAY)", :'2603112453'=> 'true' do
        begin
            @helper.addLogs("C:2603 To check lead and journey owner as per 'Lead Owner' campaign assignment for existing lead owned by 'Susie Romero', where existing journey is not associated with campaign and same lead is coming to campaign on same day(TODAY).",'2603')
            
            @testDataJSON['Campaign'][0]['Name'] = '2018-03-RM-DC-Multi-Touch-Direct-Mail-Apollo'
            @testDataJSON['Campaign'][0]['Lead Owner'] = '0051g000000tSCu'
            @testDataJSON['Campaign'][0]['Email Address'] = ''
            @testDataJSON['Campaign'][0]['City'] = ''


            @helper.addLogs("[Step ]     : Fetch camapign deatails")            
            campaignInfo = @objLeadGeneration.fetchCampaignDetails('Name',@testDataJSON['Campaign'][0]['Name'])
            expect(campaignInfo).to_not eq nil
            expect(campaignInfo.size).to eq 1
            expect(campaignInfo[0]).to_not eq nil  
            campaignInfo =  campaignInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")


            leadEmailId = @objLeadGeneration.getExistingLead((Date.today - 4).to_datetime,30,"","same",campaignInfo.fetch('Id'))
            puts "******************"
            puts leadEmailId.inspect
            puts "***************" 
            
            
            @testDataJSON['MarketingLandingPage'][0]['Email'] = leadEmailId
            

            @testDataJSON['Lead'][0]['leadSource'] = 'WeWork.com'
            @testDataJSON['Lead'][0]['lead_Source_Detail__c'] = 'Marketing Landing Page'
            @testDataJSON['Lead'][0]['RecordType'] = 'Consumer'
            @testDataJSON['Lead'][0]['Lead Status'] = 'Open'
            @testDataJSON['Lead'][0]['Type'] = 'Office Space'
            @testDataJSON['Lead'][0]['Email Quality'] = 'Pending'
            @testDataJSON['Lead'][0]['Locale'] = 'en-US' 
            @testDataJSON['Lead'][0]['Country Code'] = 'IN' 
            @testDataJSON['Lead'][0]['Product Line'] = 'WeWork' 
            @testDataJSON['Lead'][0]['Marketing Consent'] = true 
            @testDataJSON['Lead'][0]['Ts and Cs Consent'] = false
            

            @helper.addLogs("[Step ]     : Update campaign")
            expect(@objLeadGeneration.update_campaign(campaignInfo.fetch('Id'),@testDataJSON['Campaign'][0]['Lead Owner'],@testDataJSON['Campaign'][0]['Email Address'],@testDataJSON['Campaign'][0]['City'])).to eq true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Create lead from Marketing Landing Page")
            expect(@objLeadGeneration.createLeadFromMarketingPage).to eq true
            @helper.addLogs("[Validate ] : Checking Lead is created after form submission")
            @helper.addLogs("[Expected ] : Lead should create with email #{@testDataJSON['MarketingLandingPage'][0]['Email']}")

            @helper.addLogs("[Step ]     : Check lead inserted into camapign")
            expect(@objLeadGeneration.checkCamapignMember(@testDataJSON['MarketingLandingPage'][0]['Email'],campaignInfo.fetch('Id'))).to eq true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Fetch camapign deatails")
            owner = @objLeadGeneration.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
            expect(owner).to_not eq nil
            @helper.addLogs("[Result ]   : Success\n")

            expectedOwner = owner 
            puts expectedOwner                        
            puts "******************************************************"

            @helper.addLogs("[Step ]     : Fetch lead deatails")            
            insertedLeadInfo = @objLeadGeneration.fetchLeadDetails(@testDataJSON['MarketingLandingPage'][0]['Email'])
            expect(insertedLeadInfo).to_not eq nil
            expect(insertedLeadInfo.size).to eq 1
            expect(insertedLeadInfo[0]).to_not eq nil  
            insertedLeadInfo =  insertedLeadInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            
            puts "********************************************************"

            @helper.addLogs("[Step ]     : Fetch journey deatails")            
            insertedJourneyInfo = @objLeadGeneration.fetchJourneyDetails(insertedLeadInfo.fetch("Email"))
            expect(insertedJourneyInfo).to_not eq nil
            expect(insertedJourneyInfo.size).to eq 2
            expect(insertedJourneyInfo[0]).to_not eq nil  
            insertedJourneyInfo =  insertedJourneyInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            puts "*************************************************************************"

            @helper.addLogs("[Step ]     : Fetch Activity deatails")            
            generatedActivityForLead = @objLeadGeneration.fetchActivityDetails(insertedLeadInfo.fetch("Id"))
            expect(generatedActivityForLead).to_not eq nil
            expect(generatedActivityForLead.size).to eq 2
            expect(generatedActivityForLead[0]).to_not eq nil 
            puts generatedActivityForLead[0] 
            generatedActivityForLead =  generatedActivityForLead[0] 
            puts generatedActivityForLead
            @helper.addLogs("[Result ]   : Success\n")


            
            @helper.addLogs('Success')
            @helper.postSuccessResult(2603)
        rescue Exception => e
            @helper.addLogs('Error')
            @helper.postFailResult(e,2603)
            raise e
        end
    end

    it "C:2603 To check lead and journey owner as per 'Lead Owner' campaign assignment for existing lead owned by 'Susie Romero', where existing journey is not associated with campaign and same lead is coming to campaign on same day(TODAY)", :'26031124531'=> 'true' do
        begin
            @helper.addLogs("C:2603 To check lead and journey owner as per 'Lead Owner' campaign assignment for existing lead owned by 'Susie Romero', where existing journey is not associated with campaign and same lead is coming to campaign on same day(TODAY).",'2603')
            
            @testDataJSON['Campaign'][0]['Name'] = '2018-03-RM-DC-Multi-Touch-Direct-Mail-Apollo'
            @testDataJSON['Campaign'][0]['Lead Owner'] = ''
            @testDataJSON['Campaign'][0]['Email Address'] = 'vikhroliwest@wework.co.in'
            @testDataJSON['Campaign'][0]['City'] = ''


            @helper.addLogs("[Step ]     : Fetch camapign deatails")            
            campaignInfo = @objLeadGeneration.fetchCampaignDetails('Name',@testDataJSON['Campaign'][0]['Name'])
            expect(campaignInfo).to_not eq nil
            expect(campaignInfo.size).to eq 1
            expect(campaignInfo[0]).to_not eq nil  
            campaignInfo =  campaignInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")


            leadEmailId = @objLeadGeneration.getExistingLead((Date.today - 4).to_datetime,30,"","same",campaignInfo.fetch('Id'))
            puts "******************"
            puts leadEmailId.inspect
            puts "***************" 
            
            
            @testDataJSON['MarketingLandingPage'][0]['Email'] = leadEmailId
            

            @testDataJSON['Lead'][0]['leadSource'] = 'WeWork.com'
            @testDataJSON['Lead'][0]['lead_Source_Detail__c'] = 'Marketing Landing Page'
            @testDataJSON['Lead'][0]['RecordType'] = 'Consumer'
            @testDataJSON['Lead'][0]['Lead Status'] = 'Open'
            @testDataJSON['Lead'][0]['Type'] = 'Office Space'
            @testDataJSON['Lead'][0]['Email Quality'] = 'Pending'
            @testDataJSON['Lead'][0]['Locale'] = 'en-US' 
            @testDataJSON['Lead'][0]['Country Code'] = 'IN' 
            @testDataJSON['Lead'][0]['Product Line'] = 'WeWork' 
            @testDataJSON['Lead'][0]['Marketing Consent'] = true 
            @testDataJSON['Lead'][0]['Ts and Cs Consent'] = false
            

            @helper.addLogs("[Step ]     : Update campaign")
            expect(@objLeadGeneration.update_campaign(campaignInfo.fetch('Id'),@testDataJSON['Campaign'][0]['Lead Owner'],@testDataJSON['Campaign'][0]['Email Address'],@testDataJSON['Campaign'][0]['City'])).to eq true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Create lead from Marketing Landing Page")
            expect(@objLeadGeneration.createLeadFromMarketingPage).to eq true
            @helper.addLogs("[Validate ] : Checking Lead is created after form submission")
            @helper.addLogs("[Expected ] : Lead should create with email #{@testDataJSON['MarketingLandingPage'][0]['Email']}")

            @helper.addLogs("[Step ]     : Check lead inserted into camapign")
            expect(@objLeadGeneration.checkCamapignMember(@testDataJSON['MarketingLandingPage'][0]['Email'],campaignInfo.fetch('Id'))).to eq true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Fetch camapign deatails")
            owner = @objLeadGeneration.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
            expect(owner).to_not eq nil
            @helper.addLogs("[Result ]   : Success\n")

            expectedOwner = owner 
            puts expectedOwner                        
            puts "******************************************************"

            @helper.addLogs("[Step ]     : Fetch lead deatails")            
            insertedLeadInfo = @objLeadGeneration.fetchLeadDetails(@testDataJSON['MarketingLandingPage'][0]['Email'])
            expect(insertedLeadInfo).to_not eq nil
            expect(insertedLeadInfo.size).to eq 1
            expect(insertedLeadInfo[0]).to_not eq nil  
            insertedLeadInfo =  insertedLeadInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            
            puts "********************************************************"

            @helper.addLogs("[Step ]     : Fetch journey deatails")            
            insertedJourneyInfo = @objLeadGeneration.fetchJourneyDetails(insertedLeadInfo.fetch("Email"))
            expect(insertedJourneyInfo).to_not eq nil
            expect(insertedJourneyInfo.size).to eq 2
            expect(insertedJourneyInfo[0]).to_not eq nil  
            insertedJourneyInfo =  insertedJourneyInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            puts "*************************************************************************"

            @helper.addLogs("[Step ]     : Fetch Activity deatails")            
            generatedActivityForLead = @objLeadGeneration.fetchActivityDetails(insertedLeadInfo.fetch("Id"))
            expect(generatedActivityForLead).to_not eq nil
            expect(generatedActivityForLead.size).to eq 2
            expect(generatedActivityForLead[0]).to_not eq nil 
            puts generatedActivityForLead[0] 
            generatedActivityForLead =  generatedActivityForLead[0] 
            puts generatedActivityForLead
            @helper.addLogs("[Result ]   : Success\n")


            
            @helper.addLogs('Success')
            @helper.postSuccessResult(2603)
        rescue Exception => e
            @helper.addLogs('Error')
            @helper.postFailResult(e,2603)
            raise e
        end
    end

    it "C:2603 To check lead and journey owner as per 'Lead Owner' campaign assignment for existing lead owned by 'Susie Romero', where existing journey is not associated with campaign and same lead is coming to campaign on same day(TODAY)", :'26031124532'=> 'true' do
        begin
            @helper.addLogs("C:2603 To check lead and journey owner as per 'Lead Owner' campaign assignment for existing lead owned by 'Susie Romero', where existing journey is not associated with campaign and same lead is coming to campaign on same day(TODAY).",'2603')
            
            @testDataJSON['Campaign'][0]['Name'] = '2018-03-RM-DC-Multi-Touch-Direct-Mail-Apollo'
            @testDataJSON['Campaign'][0]['Lead Owner'] = ''
            @testDataJSON['Campaign'][0]['Email Address'] = ''
            @testDataJSON['Campaign'][0]['City'] = 'Mumbai'


            @helper.addLogs("[Step ]     : Fetch camapign deatails")            
            campaignInfo = @objLeadGeneration.fetchCampaignDetails('Name',@testDataJSON['Campaign'][0]['Name'])
            expect(campaignInfo).to_not eq nil
            expect(campaignInfo.size).to eq 1
            expect(campaignInfo[0]).to_not eq nil  
            campaignInfo =  campaignInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")


            leadEmailId = @objLeadGeneration.getExistingLead((Date.today - 4).to_datetime,30,"","same",campaignInfo.fetch('Id'))
            puts "******************"
            puts leadEmailId.inspect
            puts "***************" 
            
            
            @testDataJSON['MarketingLandingPage'][0]['Email'] = leadEmailId
            

            @testDataJSON['Lead'][0]['leadSource'] = 'WeWork.com'
            @testDataJSON['Lead'][0]['lead_Source_Detail__c'] = 'Marketing Landing Page'
            @testDataJSON['Lead'][0]['RecordType'] = 'Consumer'
            @testDataJSON['Lead'][0]['Lead Status'] = 'Open'
            @testDataJSON['Lead'][0]['Type'] = 'Office Space'
            @testDataJSON['Lead'][0]['Email Quality'] = 'Pending'
            @testDataJSON['Lead'][0]['Locale'] = 'en-US' 
            @testDataJSON['Lead'][0]['Country Code'] = 'IN' 
            @testDataJSON['Lead'][0]['Product Line'] = 'WeWork' 
            @testDataJSON['Lead'][0]['Marketing Consent'] = true 
            @testDataJSON['Lead'][0]['Ts and Cs Consent'] = false
            

            @helper.addLogs("[Step ]     : Update campaign")
            expect(@objLeadGeneration.update_campaign(campaignInfo.fetch('Id'),@testDataJSON['Campaign'][0]['Lead Owner'],@testDataJSON['Campaign'][0]['Email Address'],@testDataJSON['Campaign'][0]['City'])).to eq true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Create lead from Marketing Landing Page")
            expect(@objLeadGeneration.createLeadFromMarketingPage).to eq true
            @helper.addLogs("[Validate ] : Checking Lead is created after form submission")
            @helper.addLogs("[Expected ] : Lead should create with email #{@testDataJSON['MarketingLandingPage'][0]['Email']}")

            @helper.addLogs("[Step ]     : Check lead inserted into camapign")
            expect(@objLeadGeneration.checkCamapignMember(@testDataJSON['MarketingLandingPage'][0]['Email'],campaignInfo.fetch('Id'))).to eq true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Fetch camapign deatails")
            owner = @objLeadGeneration.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
            expect(owner).to_not eq nil
            @helper.addLogs("[Result ]   : Success\n")

            expectedOwner = owner 
            puts expectedOwner                        
            puts "******************************************************"

            @helper.addLogs("[Step ]     : Fetch lead deatails")            
            insertedLeadInfo = @objLeadGeneration.fetchLeadDetails(@testDataJSON['MarketingLandingPage'][0]['Email'])
            expect(insertedLeadInfo).to_not eq nil
            expect(insertedLeadInfo.size).to eq 1
            expect(insertedLeadInfo[0]).to_not eq nil  
            insertedLeadInfo =  insertedLeadInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            
            puts "********************************************************"

            @helper.addLogs("[Step ]     : Fetch journey deatails")            
            insertedJourneyInfo = @objLeadGeneration.fetchJourneyDetails(insertedLeadInfo.fetch("Email"))
            expect(insertedJourneyInfo).to_not eq nil
            expect(insertedJourneyInfo.size).to eq 2
            expect(insertedJourneyInfo[0]).to_not eq nil  
            insertedJourneyInfo =  insertedJourneyInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            puts "*************************************************************************"

            @helper.addLogs("[Step ]     : Fetch Activity deatails")            
            generatedActivityForLead = @objLeadGeneration.fetchActivityDetails(insertedLeadInfo.fetch("Id"))
            expect(generatedActivityForLead).to_not eq nil
            expect(generatedActivityForLead.size).to eq 2
            expect(generatedActivityForLead[0]).to_not eq nil 
            puts generatedActivityForLead[0] 
            generatedActivityForLead =  generatedActivityForLead[0] 
            puts generatedActivityForLead
            @helper.addLogs("[Result ]   : Success\n")
            
            @helper.addLogs('Success')
            @helper.postSuccessResult(2603)
        rescue Exception => e
            @helper.addLogs('Error')
            @helper.postFailResult(e,2603)
            raise e
        end
    end

    it "C:2603 To check lead and journey owner as per 'Lead Owner' campaign assignment for existing lead owned by 'Susie Romero', where existing journey is not associated with campaign and same lead is coming to campaign on same day(TODAY)", :'26031124533'=> 'true' do
        begin
            @helper.addLogs("C:2603 To check lead and journey owner as per 'Lead Owner' campaign assignment for existing lead owned by 'Susie Romero', where existing journey is not associated with campaign and same lead is coming to campaign on same day(TODAY).",'2603')
            
            @testDataJSON['Campaign'][0]['Name'] = '2018-03-RM-DC-Multi-Touch-Direct-Mail-Apollo'
            @testDataJSON['Campaign'][0]['Lead Owner'] = ''
            @testDataJSON['Campaign'][0]['Email Address'] = ''
            @testDataJSON['Campaign'][0]['City'] = ''


            @helper.addLogs("[Step ]     : Fetch camapign deatails")            
            campaignInfo = @objLeadGeneration.fetchCampaignDetails('Name',@testDataJSON['Campaign'][0]['Name'])
            expect(campaignInfo).to_not eq nil
            expect(campaignInfo.size).to eq 1
            expect(campaignInfo[0]).to_not eq nil  
            campaignInfo =  campaignInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")


            leadEmailId = @objLeadGeneration.getExistingLead((Date.today - 4).to_datetime,30,"","same",campaignInfo.fetch('Id'))
            puts "******************"
            puts leadEmailId.inspect
            puts "***************" 
            
            
            @testDataJSON['MarketingLandingPage'][0]['Email'] = leadEmailId
            

            @testDataJSON['Lead'][0]['leadSource'] = 'WeWork.com'
            @testDataJSON['Lead'][0]['lead_Source_Detail__c'] = 'Marketing Landing Page'
            @testDataJSON['Lead'][0]['RecordType'] = 'Consumer'
            @testDataJSON['Lead'][0]['Lead Status'] = 'Open'
            @testDataJSON['Lead'][0]['Type'] = 'Office Space'
            @testDataJSON['Lead'][0]['Email Quality'] = 'Pending'
            @testDataJSON['Lead'][0]['Locale'] = 'en-US' 
            @testDataJSON['Lead'][0]['Country Code'] = 'IN' 
            @testDataJSON['Lead'][0]['Product Line'] = 'WeWork' 
            @testDataJSON['Lead'][0]['Marketing Consent'] = true 
            @testDataJSON['Lead'][0]['Ts and Cs Consent'] = false
            

            @helper.addLogs("[Step ]     : Update campaign")
            expect(@objLeadGeneration.update_campaign(campaignInfo.fetch('Id'),@testDataJSON['Campaign'][0]['Lead Owner'],@testDataJSON['Campaign'][0]['Email Address'],@testDataJSON['Campaign'][0]['City'])).to eq true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Create lead from Marketing Landing Page")
            expect(@objLeadGeneration.createLeadFromMarketingPage).to eq true
            @helper.addLogs("[Validate ] : Checking Lead is created after form submission")
            @helper.addLogs("[Expected ] : Lead should create with email #{@testDataJSON['MarketingLandingPage'][0]['Email']}")

            @helper.addLogs("[Step ]     : Check lead inserted into camapign")
            expect(@objLeadGeneration.checkCamapignMember(@testDataJSON['MarketingLandingPage'][0]['Email'],campaignInfo.fetch('Id'))).to eq true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Fetch camapign deatails")
            owner = @objLeadGeneration.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
            expect(owner).to_not eq nil
            @helper.addLogs("[Result ]   : Success\n")

            expectedOwner = owner 
            puts expectedOwner                        
            puts "******************************************************"

            @helper.addLogs("[Step ]     : Fetch lead deatails")            
            insertedLeadInfo = @objLeadGeneration.fetchLeadDetails(@testDataJSON['MarketingLandingPage'][0]['Email'])
            expect(insertedLeadInfo).to_not eq nil
            expect(insertedLeadInfo.size).to eq 1
            expect(insertedLeadInfo[0]).to_not eq nil  
            insertedLeadInfo =  insertedLeadInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            
            puts "********************************************************"

            @helper.addLogs("[Step ]     : Fetch journey deatails")            
            insertedJourneyInfo = @objLeadGeneration.fetchJourneyDetails(insertedLeadInfo.fetch("Email"))
            expect(insertedJourneyInfo).to_not eq nil
            expect(insertedJourneyInfo.size).to eq 2
            expect(insertedJourneyInfo[0]).to_not eq nil  
            insertedJourneyInfo =  insertedJourneyInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            puts "*************************************************************************"

            @helper.addLogs("[Step ]     : Fetch Activity deatails")            
            generatedActivityForLead = @objLeadGeneration.fetchActivityDetails(insertedLeadInfo.fetch("Id"))
            expect(generatedActivityForLead).to_not eq nil
            expect(generatedActivityForLead.size).to eq 2
            expect(generatedActivityForLead[0]).to_not eq nil 
            puts generatedActivityForLead[0] 
            generatedActivityForLead =  generatedActivityForLead[0] 
            puts generatedActivityForLead
            @helper.addLogs("[Result ]   : Success\n")


            
            @helper.addLogs('Success')
            @helper.postSuccessResult(2603)
        rescue Exception => e
            @helper.addLogs('Error')
            @helper.postFailResult(e,2603)
            raise e
        end
    end


#existing lead -> Not today -> 1 journey   ass with diff camp ------> MLP -> 1J created 1 A created

    it "C:2603 To check lead and journey owner as per 'Lead Owner' campaign assignment for existing lead owned by 'Susie Romero', where existing journey is not associated with campaign and same lead is coming to campaign on same day(TODAY)", :'7891'=> 'true' do
        begin
            @helper.addLogs("C:2603 To check lead and journey owner as per 'Lead Owner' campaign assignment for existing lead owned by 'Susie Romero', where existing journey is not associated with campaign and same lead is coming to campaign on same day(TODAY).",'2603')
            
            @testDataJSON['Campaign'][0]['Name'] = '2018-03-RM-DC-Multi-Touch-Direct-Mail-Apollo'
            @testDataJSON['Campaign'][0]['Lead Owner'] = '0051g000000tSCu'
            @testDataJSON['Campaign'][0]['Email Address'] = ''
            @testDataJSON['Campaign'][0]['City'] = ''


            @helper.addLogs("[Step ]     : Fetch camapign deatails")            
            campaignInfo = @objLeadGeneration.fetchCampaignDetails('Name',@testDataJSON['Campaign'][0]['Name'])
            expect(campaignInfo).to_not eq nil
            expect(campaignInfo.size).to eq 1
            expect(campaignInfo[0]).to_not eq nil  
            campaignInfo =  campaignInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")


            leadEmailId = @objLeadGeneration.getExistingLead((Date.today - 4).to_datetime,30,"","diff",campaignInfo.fetch('Id'))
            puts "******************"
            puts leadEmailId.inspect
            puts "***************" 
            
            
            @testDataJSON['MarketingLandingPage'][0]['Email'] = leadEmailId
            

            @testDataJSON['Lead'][0]['leadSource'] = 'WeWork.com'
            @testDataJSON['Lead'][0]['lead_Source_Detail__c'] = 'Marketing Landing Page'
            @testDataJSON['Lead'][0]['RecordType'] = 'Consumer'
            @testDataJSON['Lead'][0]['Lead Status'] = 'Open'
            @testDataJSON['Lead'][0]['Type'] = 'Office Space'
            @testDataJSON['Lead'][0]['Email Quality'] = 'Pending'
            @testDataJSON['Lead'][0]['Locale'] = 'en-US' 
            @testDataJSON['Lead'][0]['Country Code'] = 'IN' 
            @testDataJSON['Lead'][0]['Product Line'] = 'WeWork' 
            @testDataJSON['Lead'][0]['Marketing Consent'] = true 
            @testDataJSON['Lead'][0]['Ts and Cs Consent'] = false
            

            @helper.addLogs("[Step ]     : Update campaign")
            expect(@objLeadGeneration.update_campaign(campaignInfo.fetch('Id'),@testDataJSON['Campaign'][0]['Lead Owner'],@testDataJSON['Campaign'][0]['Email Address'],@testDataJSON['Campaign'][0]['City'])).to eq true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Create lead from Marketing Landing Page")
            expect(@objLeadGeneration.createLeadFromMarketingPage).to eq true
            @helper.addLogs("[Validate ] : Checking Lead is created after form submission")
            @helper.addLogs("[Expected ] : Lead should create with email #{@testDataJSON['MarketingLandingPage'][0]['Email']}")

            @helper.addLogs("[Step ]     : Check lead inserted into camapign")
            expect(@objLeadGeneration.checkCamapignMember(@testDataJSON['MarketingLandingPage'][0]['Email'],campaignInfo.fetch('Id'))).to eq true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Fetch camapign deatails")
            owner = @objLeadGeneration.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
            expect(owner).to_not eq nil
            @helper.addLogs("[Result ]   : Success\n")

            expectedOwner = owner 
            puts expectedOwner                        
            puts "******************************************************"

            @helper.addLogs("[Step ]     : Fetch lead deatails")            
            insertedLeadInfo = @objLeadGeneration.fetchLeadDetails(@testDataJSON['MarketingLandingPage'][0]['Email'])
            expect(insertedLeadInfo).to_not eq nil
            expect(insertedLeadInfo.size).to eq 1
            expect(insertedLeadInfo[0]).to_not eq nil  
            insertedLeadInfo =  insertedLeadInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            
            puts "********************************************************"

            @helper.addLogs("[Step ]     : Fetch journey deatails")            
            insertedJourneyInfo = @objLeadGeneration.fetchJourneyDetails(insertedLeadInfo.fetch("Email"))
            expect(insertedJourneyInfo).to_not eq nil
            expect(insertedJourneyInfo.size).to eq 2
            expect(insertedJourneyInfo[0]).to_not eq nil  
            insertedJourneyInfo =  insertedJourneyInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            puts "*************************************************************************"

            @helper.addLogs("[Step ]     : Fetch Activity deatails")            
            generatedActivityForLead = @objLeadGeneration.fetchActivityDetails(insertedLeadInfo.fetch("Id"))
            expect(generatedActivityForLead).to_not eq nil
            expect(generatedActivityForLead.size).to eq 2
            expect(generatedActivityForLead[0]).to_not eq nil 
            puts generatedActivityForLead[0] 
            generatedActivityForLead =  generatedActivityForLead[0] 
            puts generatedActivityForLead
            @helper.addLogs("[Result ]   : Success\n")


            
            @helper.addLogs('Success')
            @helper.postSuccessResult(2603)
        rescue Exception => e
            @helper.addLogs('Error')
            @helper.postFailResult(e,2603)
            raise e
        end
    end

    it "C:2603 To check lead and journey owner as per 'Lead Owner' campaign assignment for existing lead owned by 'Susie Romero', where existing journey is not associated with campaign and same lead is coming to campaign on same day(TODAY)", :'7892'=> 'true' do
        begin
            @helper.addLogs("C:2603 To check lead and journey owner as per 'Lead Owner' campaign assignment for existing lead owned by 'Susie Romero', where existing journey is not associated with campaign and same lead is coming to campaign on same day(TODAY).",'2603')
            
            @testDataJSON['Campaign'][0]['Name'] = '2018-03-RM-DC-Multi-Touch-Direct-Mail-Apollo'
            @testDataJSON['Campaign'][0]['Lead Owner'] = ''
            @testDataJSON['Campaign'][0]['Email Address'] = 'vikhroliwest@wework.co.in'
            @testDataJSON['Campaign'][0]['City'] = ''


            @helper.addLogs("[Step ]     : Fetch camapign deatails")            
            campaignInfo = @objLeadGeneration.fetchCampaignDetails('Name',@testDataJSON['Campaign'][0]['Name'])
            expect(campaignInfo).to_not eq nil
            expect(campaignInfo.size).to eq 1
            expect(campaignInfo[0]).to_not eq nil  
            campaignInfo =  campaignInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")


            leadEmailId = @objLeadGeneration.getExistingLead((Date.today - 4).to_datetime,30,"","diff",campaignInfo.fetch('Id'))
            puts "******************"
            puts leadEmailId.inspect
            puts "***************"             
            
            @testDataJSON['MarketingLandingPage'][0]['Email'] = leadEmailId
            

            @testDataJSON['Lead'][0]['leadSource'] = 'WeWork.com'
            @testDataJSON['Lead'][0]['lead_Source_Detail__c'] = 'Marketing Landing Page'
            @testDataJSON['Lead'][0]['RecordType'] = 'Consumer'
            @testDataJSON['Lead'][0]['Lead Status'] = 'Open'
            @testDataJSON['Lead'][0]['Type'] = 'Office Space'
            @testDataJSON['Lead'][0]['Email Quality'] = 'Pending'
            @testDataJSON['Lead'][0]['Locale'] = 'en-US' 
            @testDataJSON['Lead'][0]['Country Code'] = 'IN' 
            @testDataJSON['Lead'][0]['Product Line'] = 'WeWork' 
            @testDataJSON['Lead'][0]['Marketing Consent'] = true 
            @testDataJSON['Lead'][0]['Ts and Cs Consent'] = false
            

            @helper.addLogs("[Step ]     : Update campaign")
            expect(@objLeadGeneration.update_campaign(campaignInfo.fetch('Id'),@testDataJSON['Campaign'][0]['Lead Owner'],@testDataJSON['Campaign'][0]['Email Address'],@testDataJSON['Campaign'][0]['City'])).to eq true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Create lead from Marketing Landing Page")
            expect(@objLeadGeneration.createLeadFromMarketingPage).to eq true
            @helper.addLogs("[Validate ] : Checking Lead is created after form submission")
            @helper.addLogs("[Expected ] : Lead should create with email #{@testDataJSON['MarketingLandingPage'][0]['Email']}")

            @helper.addLogs("[Step ]     : Check lead inserted into camapign")
            expect(@objLeadGeneration.checkCamapignMember(@testDataJSON['MarketingLandingPage'][0]['Email'],campaignInfo.fetch('Id'))).to eq true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Fetch camapign deatails")
            owner = @objLeadGeneration.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
            expect(owner).to_not eq nil
            @helper.addLogs("[Result ]   : Success\n")

            expectedOwner = owner 
            puts expectedOwner                        
            puts "******************************************************"

            @helper.addLogs("[Step ]     : Fetch lead deatails")            
            insertedLeadInfo = @objLeadGeneration.fetchLeadDetails(@testDataJSON['MarketingLandingPage'][0]['Email'])
            expect(insertedLeadInfo).to_not eq nil
            expect(insertedLeadInfo.size).to eq 1
            expect(insertedLeadInfo[0]).to_not eq nil  
            insertedLeadInfo =  insertedLeadInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")
            
            puts "********************************************************"

            @helper.addLogs("[Step ]     : Fetch journey deatails")            
            insertedJourneyInfo = @objLeadGeneration.fetchJourneyDetails(insertedLeadInfo.fetch("Email"))
            expect(insertedJourneyInfo).to_not eq nil
            expect(insertedJourneyInfo.size).to eq 2
            expect(insertedJourneyInfo[0]).to_not eq nil  
            insertedJourneyInfo =  insertedJourneyInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            puts "*************************************************************************"

            @helper.addLogs("[Step ]     : Fetch Activity deatails")            
            generatedActivityForLead = @objLeadGeneration.fetchActivityDetails(insertedLeadInfo.fetch("Id"))
            expect(generatedActivityForLead).to_not eq nil
            expect(generatedActivityForLead.size).to eq 2
            expect(generatedActivityForLead[0]).to_not eq nil 
            puts generatedActivityForLead[0] 
            generatedActivityForLead =  generatedActivityForLead[0] 
            puts generatedActivityForLead
            @helper.addLogs("[Result ]   : Success\n")


            
            @helper.addLogs('Success')
            @helper.postSuccessResult(2603)
        rescue Exception => e
            @helper.addLogs('Error')
            @helper.postFailResult(e,2603)
            raise e
        end
    end

    it "C:2603 To check lead and journey owner as per 'Lead Owner' campaign assignment for existing lead owned by 'Susie Romero', where existing journey is not associated with campaign and same lead is coming to campaign on same day(TODAY)", :'7893'=> 'true' do
        begin
            @helper.addLogs("C:2603 To check lead and journey owner as per 'Lead Owner' campaign assignment for existing lead owned by 'Susie Romero', where existing journey is not associated with campaign and same lead is coming to campaign on same day(TODAY).",'2603')
            
            @testDataJSON['Campaign'][0]['Name'] = '2018-03-RM-DC-Multi-Touch-Direct-Mail-Apollo'
            @testDataJSON['Campaign'][0]['Lead Owner'] = ''
            @testDataJSON['Campaign'][0]['Email Address'] = ''
            @testDataJSON['Campaign'][0]['City'] = 'Mumbai'


            @helper.addLogs("[Step ]     : Fetch camapign deatails")            
            campaignInfo = @objLeadGeneration.fetchCampaignDetails('Name',@testDataJSON['Campaign'][0]['Name'])
            expect(campaignInfo).to_not eq nil
            expect(campaignInfo.size).to eq 1
            expect(campaignInfo[0]).to_not eq nil  
            campaignInfo =  campaignInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")


            leadEmailId = @objLeadGeneration.getExistingLead((Date.today - 4).to_datetime,30,"","diff",campaignInfo.fetch('Id'))
            puts "******************"
            puts leadEmailId.inspect
            puts "***************" 
            
            
            @testDataJSON['MarketingLandingPage'][0]['Email'] = leadEmailId
            

            @testDataJSON['Lead'][0]['leadSource'] = 'WeWork.com'
            @testDataJSON['Lead'][0]['lead_Source_Detail__c'] = 'Marketing Landing Page'
            @testDataJSON['Lead'][0]['RecordType'] = 'Consumer'
            @testDataJSON['Lead'][0]['Lead Status'] = 'Open'
            @testDataJSON['Lead'][0]['Type'] = 'Office Space'
            @testDataJSON['Lead'][0]['Email Quality'] = 'Pending'
            @testDataJSON['Lead'][0]['Locale'] = 'en-US' 
            @testDataJSON['Lead'][0]['Country Code'] = 'IN' 
            @testDataJSON['Lead'][0]['Product Line'] = 'WeWork' 
            @testDataJSON['Lead'][0]['Marketing Consent'] = true 
            @testDataJSON['Lead'][0]['Ts and Cs Consent'] = false
            

            @helper.addLogs("[Step ]     : Update campaign")
            expect(@objLeadGeneration.update_campaign(campaignInfo.fetch('Id'),@testDataJSON['Campaign'][0]['Lead Owner'],@testDataJSON['Campaign'][0]['Email Address'],@testDataJSON['Campaign'][0]['City'])).to eq true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Create lead from Marketing Landing Page")
            expect(@objLeadGeneration.createLeadFromMarketingPage).to eq true
            @helper.addLogs("[Validate ] : Checking Lead is created after form submission")
            @helper.addLogs("[Expected ] : Lead should create with email #{@testDataJSON['MarketingLandingPage'][0]['Email']}")

            @helper.addLogs("[Step ]     : Check lead inserted into camapign")
            expect(@objLeadGeneration.checkCamapignMember(@testDataJSON['MarketingLandingPage'][0]['Email'],campaignInfo.fetch('Id'))).to eq true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Fetch camapign deatails")
            owner = @objLeadGeneration.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
            expect(owner).to_not eq nil
            @helper.addLogs("[Result ]   : Success\n")

            expectedOwner = owner 
            puts expectedOwner                        
            puts "******************************************************"

            @helper.addLogs("[Step ]     : Fetch lead deatails")            
            insertedLeadInfo = @objLeadGeneration.fetchLeadDetails(@testDataJSON['MarketingLandingPage'][0]['Email'])
            expect(insertedLeadInfo).to_not eq nil
            expect(insertedLeadInfo.size).to eq 1
            expect(insertedLeadInfo[0]).to_not eq nil  
            insertedLeadInfo =  insertedLeadInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            
            puts "********************************************************"

            @helper.addLogs("[Step ]     : Fetch journey deatails")            
            insertedJourneyInfo = @objLeadGeneration.fetchJourneyDetails(insertedLeadInfo.fetch("Email"))
            expect(insertedJourneyInfo).to_not eq nil
            expect(insertedJourneyInfo.size).to eq 2
            expect(insertedJourneyInfo[0]).to_not eq nil  
            insertedJourneyInfo =  insertedJourneyInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            puts "*************************************************************************"

            @helper.addLogs("[Step ]     : Fetch Activity deatails")            
            generatedActivityForLead = @objLeadGeneration.fetchActivityDetails(insertedLeadInfo.fetch("Id"))
            expect(generatedActivityForLead).to_not eq nil
            expect(generatedActivityForLead.size).to eq 2
            expect(generatedActivityForLead[0]).to_not eq nil 
            puts generatedActivityForLead[0] 
            generatedActivityForLead =  generatedActivityForLead[0] 
            puts generatedActivityForLead
            @helper.addLogs("[Result ]   : Success\n")
            
            @helper.addLogs('Success')
            @helper.postSuccessResult(2603)
        rescue Exception => e
            @helper.addLogs('Error')
            @helper.postFailResult(e,2603)
            raise e
        end
    end

    it "C:2603 To check lead and journey owner as per 'Lead Owner' campaign assignment for existing lead owned by 'Susie Romero', where existing journey is not associated with campaign and same lead is coming to campaign on same day(TODAY)", :'7894'=> 'true' do
        begin
            @helper.addLogs("C:2603 To check lead and journey owner as per 'Lead Owner' campaign assignment for existing lead owned by 'Susie Romero', where existing journey is not associated with campaign and same lead is coming to campaign on same day(TODAY).",'2603')
            
            @testDataJSON['Campaign'][0]['Name'] = '2018-03-RM-DC-Multi-Touch-Direct-Mail-Apollo'
            @testDataJSON['Campaign'][0]['Lead Owner'] = ''
            @testDataJSON['Campaign'][0]['Email Address'] = ''
            @testDataJSON['Campaign'][0]['City'] = ''


            @helper.addLogs("[Step ]     : Fetch camapign deatails")            
            campaignInfo = @objLeadGeneration.fetchCampaignDetails('Name',@testDataJSON['Campaign'][0]['Name'])
            expect(campaignInfo).to_not eq nil
            expect(campaignInfo.size).to eq 1
            expect(campaignInfo[0]).to_not eq nil  
            campaignInfo =  campaignInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")


            leadEmailId = @objLeadGeneration.getExistingLead((Date.today - 4).to_datetime,30,"","diff",campaignInfo.fetch('Id'))
            puts "******************"
            puts leadEmailId.inspect
            puts "***************" 
            
            
            @testDataJSON['MarketingLandingPage'][0]['Email'] = leadEmailId
            

            @testDataJSON['Lead'][0]['leadSource'] = 'WeWork.com'
            @testDataJSON['Lead'][0]['lead_Source_Detail__c'] = 'Marketing Landing Page'
            @testDataJSON['Lead'][0]['RecordType'] = 'Consumer'
            @testDataJSON['Lead'][0]['Lead Status'] = 'Open'
            @testDataJSON['Lead'][0]['Type'] = 'Office Space'
            @testDataJSON['Lead'][0]['Email Quality'] = 'Pending'
            @testDataJSON['Lead'][0]['Locale'] = 'en-US' 
            @testDataJSON['Lead'][0]['Country Code'] = 'IN' 
            @testDataJSON['Lead'][0]['Product Line'] = 'WeWork' 
            @testDataJSON['Lead'][0]['Marketing Consent'] = true 
            @testDataJSON['Lead'][0]['Ts and Cs Consent'] = false
            

            @helper.addLogs("[Step ]     : Update campaign")
            expect(@objLeadGeneration.update_campaign(campaignInfo.fetch('Id'),@testDataJSON['Campaign'][0]['Lead Owner'],@testDataJSON['Campaign'][0]['Email Address'],@testDataJSON['Campaign'][0]['City'])).to eq true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Create lead from Marketing Landing Page")
            expect(@objLeadGeneration.createLeadFromMarketingPage).to eq true
            @helper.addLogs("[Validate ] : Checking Lead is created after form submission")
            @helper.addLogs("[Expected ] : Lead should create with email #{@testDataJSON['MarketingLandingPage'][0]['Email']}")

            @helper.addLogs("[Step ]     : Check lead inserted into camapign")
            expect(@objLeadGeneration.checkCamapignMember(@testDataJSON['MarketingLandingPage'][0]['Email'],campaignInfo.fetch('Id'))).to eq true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Fetch camapign deatails")
            owner = @objLeadGeneration.getOwnerByCampaignAssignment(@testDataJSON['Campaign'][0]['Name'])
            expect(owner).to_not eq nil
            @helper.addLogs("[Result ]   : Success\n")

            expectedOwner = owner 
            puts expectedOwner                        
            puts "******************************************************"

            @helper.addLogs("[Step ]     : Fetch lead deatails")            
            insertedLeadInfo = @objLeadGeneration.fetchLeadDetails(@testDataJSON['MarketingLandingPage'][0]['Email'])
            expect(insertedLeadInfo).to_not eq nil
            expect(insertedLeadInfo.size).to eq 1
            expect(insertedLeadInfo[0]).to_not eq nil  
            insertedLeadInfo =  insertedLeadInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            
            puts "********************************************************"

            @helper.addLogs("[Step ]     : Fetch journey deatails")            
            insertedJourneyInfo = @objLeadGeneration.fetchJourneyDetails(insertedLeadInfo.fetch("Email"))
            expect(insertedJourneyInfo).to_not eq nil
            expect(insertedJourneyInfo.size).to eq 2
            expect(insertedJourneyInfo[0]).to_not eq nil  
            insertedJourneyInfo =  insertedJourneyInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            puts "*************************************************************************"

            @helper.addLogs("[Step ]     : Fetch Activity deatails")            
            generatedActivityForLead = @objLeadGeneration.fetchActivityDetails(insertedLeadInfo.fetch("Id"))
            expect(generatedActivityForLead).to_not eq nil
            expect(generatedActivityForLead.size).to eq 2
            expect(generatedActivityForLead[0]).to_not eq nil 
            puts generatedActivityForLead[0] 
            generatedActivityForLead =  generatedActivityForLead[0] 
            puts generatedActivityForLead
            @helper.addLogs("[Result ]   : Success\n")


            
            @helper.addLogs('Success')
            @helper.postSuccessResult(2603)
        rescue Exception => e
            @helper.addLogs('Error')
            @helper.postFailResult(e,2603)
            raise e
        end
    end

def validate_case_eql(object,actual,expected)
    expected.keys.each do |key|
        if actual.key? key
            @helper.addLogs("[Validate ] : Checking #{object} : #{key}")
            @helper.addLogs("[Expected ] : #{expected[key]}")
            @helper.addLogs("[Actual   ] : #{actual[key]}")
            expect(actual[key]).to eql expected[key]
            @helper.addLogs("[Result   ] : Success")
            puts "\n"
        end
    end
end

def validate_case_match(object,actual,expected)
    expected.keys.each do |key|
        if actual.key? key
            @helper.addLogs("[Validate ] : Checking #{object} : #{key}")
            @helper.addLogs("[Expected ] : #{expected[key]}")
            @helper.addLogs("[Actual   ] : #{actual[key]}")
            expect(actual[key]).to match expected[key]
            @helper.addLogs("[Result   ] : Success")
            puts "\n"
        end
    end
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
end
