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
    it "C:2175 To check lead is assigned to proper 'User' from lead assignment rule for 'Consumer' record type and journey,activity should be created for that lead.", :'2175' => 'true' do
        begin
            @helper.addLogs("C:2016 To check lead is assigned to proper 'User' from lead assignment rule for 'Consumer' record type and journey,activity should be created for that lead.",'2175')
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

            @helper.addLogs("[Step ]     : Fetch building deatails")            
            building = @objLeadGeneration.fetchBuildingDetails(@testDataJSON['Lead'][0]['Building Interested In'])
            expect(building).to_not eq nil
            expect(building.size).to eq 1
            expect(building[0]).to_not eq nil      
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Login to salesforce")
            @objLeadGeneration.loginToSalesforce
            
            @helper.addLogs("[Step ]     : Create Lead record with consumer record type")
            @objLeadGeneration.createLeadStdsalesforce
            @helper.addLogs("[Validate ] : Checking Lead is created after form submission")
            @helper.addLogs("[Expected ] : Lead should create with name #{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
            
            @helper.addLogs("[Step ]     : Fetch lead deatails")            
            insertedLeadInfo = @objLeadGeneration.fetchLeadDetails(@testDataJSON['Lead'][0]['Email'])
            expect(insertedLeadInfo).to_not eq nil
            expect(insertedLeadInfo.size).to eq 1
            expect(insertedLeadInfo[0]).to_not eq nil  
            insertedLeadInfo =  insertedLeadInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            recordType = @objLeadGeneration.getRecordType(@testDataJSON['Lead'][0]['Number of Full Time Employees'].to_i)

            @helper.addLogs("[Validate ] : Checking Lead name")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Name")}")            
            expect(insertedLeadInfo.fetch("Name")).to match("#{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead owner should be According to Lead Assignment Rule")
            @helper.addLogs("[Expected ] : 0050G000008KcLF")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Owner").fetch("Id")}")            
            expect(insertedLeadInfo.fetch("Owner").fetch("Id")).to match("0050G000008KcLF")
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Organization")
            @helper.addLogs("[Expected ] : 0011g00000CIkegAAD")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Account__c")}")
            expect(insertedLeadInfo.fetch("Account__c")).to match("0011g00000CIkegAAD")
            @helper.addLogs("[Result ]   : Success\n")
            
            @helper.addLogs("[Validate ] : Checking Lead Market")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Market']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Market__c")}")
            expect(insertedLeadInfo.fetch("Market__c")).to eql @testDataJSON['Lead'][0]['Market']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Generate_Journey__c")
            @helper.addLogs("[Expected ] : #{!@testDataJSON['Lead'][0]['Generate Journey']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Generate_Journey__c")}")
            expect(insertedLeadInfo.fetch("Generate_Journey__c")).to eql true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Has_Active_Journey__c")
            @helper.addLogs("[Expected ] : true")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Has_Active_Journey__c")}")
            expect(insertedLeadInfo.fetch("Has_Active_Journey__c")).to eql true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Markets_Interested__c")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Markets Interested']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Markets_Interested__c")}")
            expect(insertedLeadInfo.fetch("Markets_Interested__c")).to eql @testDataJSON['Lead'][0]['Markets Interested']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Referrer__c")
            @helper.addLogs("[Expected ] : 0031g000008ROtsAAG")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Referrer__c")}")
            expect(insertedLeadInfo.fetch("Referrer__c")).to eql "0031g000008ROtsAAG"
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Referral_Company_Name__c")
            @helper.addLogs("[Expected ] : john.snow_Org_qaauto12121212")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Referral_Company_Name__c")}")
            expect(insertedLeadInfo.fetch("Referral_Company_Name__c")).to eql "john.snow_Org_qaauto12121212"
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Referrer_Name__c")
            @helper.addLogs("[Expected ] : John")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Referrer_Name__c")}")
            expect(insertedLeadInfo.fetch("Referrer_Name__c")).to eql "John"
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Referrer_Email__c")
            @helper.addLogs("[Expected ] : abc@example.com")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Referrer_Email__c")}")
            expect(insertedLeadInfo.fetch("Referrer_Email__c")).to eql "abc@example.com"
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

            @helper.addLogs("[Validate ] : Checking building interested name on Lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Building Interested In']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Building_Interested_Name__c")}")
            expect(insertedLeadInfo.fetch("Building_Interested_Name__c")).to eql @testDataJSON['Lead'][0]['Building Interested In']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking building interested In")
            @helper.addLogs("[Expected ] : #{building[0].fetch("Id")}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Building_Interested_In__c")}")
            expect(insertedLeadInfo.fetch("Building_Interested_In__c")).to eql building[0].fetch("Id")
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Journey created date on lead")
            @helper.addLogs("[Expected ] : #{Date.today}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Journey_Created_On__c")}")
            expect(insertedLeadInfo.fetch("Journey_Created_On__c")).to eql Date.today.to_s
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Interested in Number of Desks on lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Interested in Number of Desk(s)']}.0")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch('Interested_in_Number_of_Desks__c')}")
            expect(insertedLeadInfo.fetch("Interested_in_Number_of_Desks__c").to_i).to eql "#{@testDataJSON['Lead'][0]['Interested in Number of Desk(s)']}.0".to_i
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Locations Interested on lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Locations Interested']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Locations_Interested__c")}")
            expect(insertedLeadInfo.fetch("Locations_Interested__c")).to eql @testDataJSON['Lead'][0]['Locations Interested']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Number of Full Time Employees on lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Number of Full Time Employees']}.0")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Number_of_Full_Time_Employees__c")}")
            expect(insertedLeadInfo.fetch("Number_of_Full_Time_Employees__c").to_i).to eql "#{@testDataJSON['Lead'][0]['Number of Full Time Employees']}.0".to_i
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Email on lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Email']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Email")}")
            expect(insertedLeadInfo.fetch("Email")).to eql @testDataJSON['Lead'][0]['Email']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Phone on lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Phone']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Phone")}")
            expect(insertedLeadInfo.fetch("Phone")).to eql "(888) 888-8888"
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Company on lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Company']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Company")}")
            expect(insertedLeadInfo.fetch("Company")).to eql @testDataJSON['Lead'][0]['Company']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking RecordType on lead")
            @helper.addLogs("[Expected ] : #{recordType}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("RecordType").fetch("Name")}")
            expect(insertedLeadInfo.fetch("RecordType").fetch("Name")).to eql recordType
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

            @helper.addLogs("[Validate ] : Checking Email_Opt_out on lead")
            @helper.addLogs("[Expected ] : true")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("HasOptedOutOfEmail")}")
            expect(insertedLeadInfo.fetch("HasOptedOutOfEmail")).to eql true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Promo code on lead")
            @helper.addLogs("[Expected ] : @testDataJSON['Lead'][0]['Promo Code']")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Promo_Code__c")}")
            expect(insertedLeadInfo.fetch("Promo_Code__c")).to eql @testDataJSON['Lead'][0]['Promo Code']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Move in Time frame on lead")
            @helper.addLogs("[Expected ] : @testDataJSON['Lead'][0]['Move In Time Frame']")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Move_In_Time_Frame__c")}")
            expect(insertedLeadInfo.fetch("Move_In_Time_Frame__c")).to eql @testDataJSON['Lead'][0]['Move In Time Frame']
            @helper.addLogs("[Result ]   : Success\n")            

            @helper.addLogs("[Step ]     : Checking for journey should created or Not")
            generateJourneyPermissin = @objLeadGeneration.isGenerateJourney(insertedLeadInfo.fetch("Owner").fetch("Id"),insertedLeadInfo.fetch("LeadSource"),insertedLeadInfo.fetch("Lead_Source_Detail__c"),insertedLeadInfo.fetch("Generate_Journey__c"))
           

            if generateJourneyPermissin then
                puts "********************************************************"

                @helper.addLogs("[Step ]     : Fetch journey deatails")            
                insertedJourneyInfo = @objLeadGeneration.fetchJourneyDetails(insertedLeadInfo.fetch("Email"))
                expect(insertedJourneyInfo).to_not eq nil
                expect(insertedJourneyInfo.size).to eq 1
                expect(insertedJourneyInfo[0]).to_not eq nil  
                insertedJourneyInfo =  insertedJourneyInfo[0]      
                @helper.addLogs("[Result ]   : Success\n")

                @helper.addLogs("[Validate ] : Checking Journey Name")
                @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
                @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Name")}")
                expect(insertedJourneyInfo).to_not eql nil
                expect(insertedJourneyInfo.fetch("Name")).to match("#{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
                @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking Journey owner")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Owner").fetch("Name")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Owner").fetch("Name")}")
                 expect(insertedJourneyInfo.fetch("Owner").fetch("Id")).to eql insertedLeadInfo.fetch("Owner").fetch("Id")
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

                 @helper.addLogs("[Validate ] : Checking building interested In on Journey")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Building_Interested_In__c")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Building_Interested_In__c")}")
                 expect(insertedJourneyInfo.fetch("Building_Interested_In__c")).to eql insertedLeadInfo.fetch("Building_Interested_In__c")
                 @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking NMD Next Contact Date on Journey")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Journey_Created_On__c")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")}")
                 expect(insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")).to eql insertedLeadInfo.fetch("Journey_Created_On__c")
                 @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking Interested in Number of Desks on Journey")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Interested_in_Number_of_Desks__c")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Interested_in_Number_of_Desks__c")}")
                 expect(insertedJourneyInfo.fetch("Interested_in_Number_of_Desks__c")).to eql insertedLeadInfo.fetch("Interested_in_Number_of_Desks__c")
                 @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking Locations Interested on Journey")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Locations_Interested__c")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Locations_Interested__c")}")
                 expect(insertedJourneyInfo.fetch("Locations_Interested__c")).to eql insertedLeadInfo.fetch("Locations_Interested__c")
                 @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking Number of Full Time Employees on Journey")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Number_of_Full_Time_Employees__c")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Full_Time_Employees__c")}")
                 expect(insertedJourneyInfo.fetch("Full_Time_Employees__c")).to eql insertedLeadInfo.fetch("Number_of_Full_Time_Employees__c")
                 @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking Email on Journey")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Email")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Primary_Email__c")}")
                 expect(insertedJourneyInfo.fetch("Primary_Email__c")).to eql insertedLeadInfo.fetch("Email")
                 @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking Phone on Journey")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Phone")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Primary_Phone__c")}")
                 expect(insertedJourneyInfo.fetch("Primary_Phone__c")).to eql "(888) 888-8888"
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

                 @helper.addLogs("[Validate ] : Checking Journey Market")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Market__c")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Market__c")}")
                 expect(insertedJourneyInfo.fetch("Market__c")).to eql insertedLeadInfo.fetch("Market__c")
                 @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking Journey Next Contact Date")
                 @helper.addLogs("[Expected ] : #{Date.today().to_s}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")}")
                 #expect(insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")).to eql "Started"
                 @helper.addLogs("[Result ]   : Success\n")

                @helper.addLogs("[Validate ] : Checking Journey Markets_Interested__c")
                @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Markets_Interested__c")}")
                @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Markets_Interested__c")}")
                expect(insertedLeadInfo.fetch("Markets_Interested__c")).to eql insertedLeadInfo.fetch("Markets_Interested__c")
                @helper.addLogs("[Result ]   : Success\n")

            else
                expect(insertedJourneyInfo).to eql nil
            end
            puts "********************************************************"

            @helper.addLogs("[Step ]     : Fetch Activity deatails")            
            generatedActivityForLead = @objLeadGeneration.fetchActivityDetails(insertedLeadInfo.fetch("Id"))
            expect(generatedActivityForLead).to_not eq nil
            expect(generatedActivityForLead.size).to eq 1
            expect(generatedActivityForLead[0]).to_not eq nil  
            generatedActivityForLead =  generatedActivityForLead[0]      
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Subject on acitivity")
            @helper.addLogs("[Expected ] : Inbound Lead submission")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Subject")}")
            expect(generatedActivityForLead.fetch("Subject")).to eql "Inbound Lead submission"
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking lead source on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("LeadSource")}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Lead_Source__c")}")
            expect(generatedActivityForLead.fetch("Lead_Source__c")).to eql insertedLeadInfo.fetch("LeadSource")
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking lead source detail on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Lead_Source_Detail__c")}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Lead_Source_Detail__c")}")
            expect(generatedActivityForLead.fetch("Lead_Source_Detail__c")).to eql insertedLeadInfo.fetch("Lead_Source_Detail__c")
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking assigned to on activity")
            @helper.addLogs("[Expected ] : Logged In User")#{@userInfo.fetch("display_name")}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Owner").fetch("Name")}")
            #expect(generatedActivityForLead.fetch("Owner").fetch("Name")).to eql @userInfo.fetch("display_name")
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking status on activity")
            @helper.addLogs("[Expected ] : Open")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Status")}")
            expect(generatedActivityForLead.fetch("Status")).to eql "Open"
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Company__c on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Company')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Company__c")}")
            expect(generatedActivityForLead.fetch("Company__c")).to eql insertedLeadInfo.fetch('Company')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Location interested on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Locations_Interested__c')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Locations_Interested__c")}")
            expect(generatedActivityForLead.fetch("Locations_Interested__c")).to eql insertedLeadInfo.fetch('Locations_Interested__c')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Location interested on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Number_of_Full_Time_Employees__c')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Number_of_Full_Time_Employees__c")}")
            expect(generatedActivityForLead.fetch("Number_of_Full_Time_Employees__c")).to eql insertedLeadInfo.fetch('Number_of_Full_Time_Employees__c')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Number of desks on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Interested_in_Number_of_Desks__c')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Interested_in_Number_of_Desks__c")}")
            expect(generatedActivityForLead.fetch("Interested_in_Number_of_Desks__c")).to eql insertedLeadInfo.fetch('Interested_in_Number_of_Desks__c')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Priority on activity")
            @helper.addLogs("[Expected ] : Normal")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Priority")}")
            expect(generatedActivityForLead.fetch("Priority")).to eql "Normal"
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Name on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Name')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Who").fetch('Name')}")
            expect(generatedActivityForLead.fetch("Who").fetch('Name')).to eql insertedLeadInfo.fetch('Name')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Email on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Email')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Email__c")}")
            expect(generatedActivityForLead.fetch("Email__c")).to eql insertedLeadInfo.fetch('Email')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Country_Code__c on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Country_Code__c')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Country_Code__c")}")
            expect(generatedActivityForLead.fetch("Country_Code__c")).to eql insertedLeadInfo.fetch('Country_Code__c')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Locale__c on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Locale__c')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Locale__c")}")
            expect(generatedActivityForLead.fetch("Locale__c")).to eql insertedLeadInfo.fetch('Locale__c')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Markets_Interested__c on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Markets_Interested__c')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Markets_Interested__c")}")
            expect(generatedActivityForLead.fetch("Markets_Interested__c")).to eql insertedLeadInfo.fetch('Markets_Interested__c')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Market__c on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Market__c')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Market__c")}")
            expect(generatedActivityForLead.fetch("Market__c")).to eql insertedLeadInfo.fetch('Market__c')
            @helper.addLogs("[Result ]   : Success\n")




            #owner --
            #Record Type --
            #Name --
            #email --
            #phone -- expect remaining 
            #Company  --
            #Lead Source --
            #Lead source Details  --
            #Organization Account__c ORg acc Id  --
            #No of FTE --
            #Intrsted No of Desk  --
            #Market
            #Journey Created On   --
            #Generate Journey
            #has active Journey
            #Building interested in  --
            #building Interested Name  --
            #Markets interested
            #Locations Interested --
            #Reffer
            #Refferal Company Name
            #REFFER NAME
            #REffer email
            #status --
            #Type --
            #Email_Opt_out --
            #promo code --
            #move in time frame --


            #*****Journey Fields********
            #no of journey == 1  --
            #owner  --
            #name --
            #journey Status  --
            #Primary Lead  --
            #Primary_Phone__c --
            #Primary_Email__c  --
            #Company Name  --
            #FTE  --
            #Lead source  --
            #Lead source Details --
            #record Type  --
            #building interested In  --
            #Locations Interested  --
            #Markets Interested --
            #Market  --
            #Next Contact Date --
            #Name --
            #Looking_For_Number_Of_Desk__c --
            #Interested_in_Number_of_Desks__c  --
            

            #******Activity fields********
            #no of activity == 1  --
            #Assigned To  --
            #subject --
            #priority --
            #Name --
            #company  --
            #Email  --
            #FTE  --
            #Interested In no of Desk --
            #Lead source  --
            #Lead Source Details  --
            #Country Code  --
            #locale --
            #Market --
            #Market Interested --
            #Locations Interested  --
            #status --




            @helper.postSuccessResult('2175')
        rescue Exception => e
            puts e
            @helper.postFailResult(e,'2175')
        end
    end

    it "C:2554 To check lead is assigned to proper 'User' from lead assignment rule for 'Mid-Market' record type and journey,activity should be created for that lead.", :'2554' => 'true' do
        begin
            @helper.addLogs("C:2016 To check lead is assigned to proper 'User' from lead assignment rule for 'Mid-Market' record type and journey,activity should be created for that lead.",'2554')
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
            @testDataJSON['Lead'][0]['Number of Full Time Employees'] = '55'
            @testDataJSON['Lead'][0]['Locations Interested'] = "AMS-Labs;AMS-Strawinskylaan"
            @testDataJSON['Lead'][0]['Referrer'] = 'john snow_QaAuto_121'
            @testDataJSON['Lead'][0]['Referrer Name'] = 'John'
            @testDataJSON['Lead'][0]['Referrer Email'] = 'abc@example.com'
            @testDataJSON['Lead'][0]['Assign using active assignment rule'] = true
            @testDataJSON['Lead'][0]['Promo Code'] = "123123"

            @helper.addLogs("[Step ]     : Fetch building deatails")            
            building = @objLeadGeneration.fetchBuildingDetails(@testDataJSON['Lead'][0]['Building Interested In'])
            expect(building).to_not eq nil
            expect(building.size).to eq 1
            expect(building[0]).to_not eq nil      
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Login to salesforce")
            @objLeadGeneration.loginToSalesforce
            
            @helper.addLogs("[Step ]     : Create Lead record with consumer record type")
            @objLeadGeneration.createLeadStdsalesforce
            @helper.addLogs("[Validate ] : Checking Lead is created after form submission")
            @helper.addLogs("[Expected ] : Lead should create with name #{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
            
            @helper.addLogs("[Step ]     : Fetch lead deatails")            
            insertedLeadInfo = @objLeadGeneration.fetchLeadDetails(@testDataJSON['Lead'][0]['Email'])
            expect(insertedLeadInfo).to_not eq nil
            expect(insertedLeadInfo.size).to eq 1
            expect(insertedLeadInfo[0]).to_not eq nil  
            insertedLeadInfo =  insertedLeadInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            recordType = @objLeadGeneration.getRecordType(@testDataJSON['Lead'][0]['Number of Full Time Employees'].to_i)

            @helper.addLogs("[Validate ] : Checking Lead name")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Name")}")            
            expect(insertedLeadInfo.fetch("Name")).to match("#{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead owner should be According to Lead Assignment Rule")
            @helper.addLogs("[Expected ] : 0050G000008KcLF")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Owner").fetch("Id")}")            
            expect(insertedLeadInfo.fetch("Owner").fetch("Id")).to match("0050G000008KcLF")
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Organization")
            @helper.addLogs("[Expected ] : 0011g00000CIkegAAD")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Account__c")}")
            expect(insertedLeadInfo.fetch("Account__c")).to match("0011g00000CIkegAAD")
            @helper.addLogs("[Result ]   : Success\n")
            
            @helper.addLogs("[Validate ] : Checking Lead Market")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Market']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Market__c")}")
            expect(insertedLeadInfo.fetch("Market__c")).to eql @testDataJSON['Lead'][0]['Market']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Generate_Journey__c")
            @helper.addLogs("[Expected ] : #{!@testDataJSON['Lead'][0]['Generate Journey']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Generate_Journey__c")}")
            expect(insertedLeadInfo.fetch("Generate_Journey__c")).to eql true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Has_Active_Journey__c")
            @helper.addLogs("[Expected ] : true")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Has_Active_Journey__c")}")
            expect(insertedLeadInfo.fetch("Has_Active_Journey__c")).to eql true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Markets_Interested__c")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Markets Interested']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Markets_Interested__c")}")
            expect(insertedLeadInfo.fetch("Markets_Interested__c")).to eql @testDataJSON['Lead'][0]['Markets Interested']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Referrer__c")
            @helper.addLogs("[Expected ] : 0031g000008ROtsAAG")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Referrer__c")}")
            expect(insertedLeadInfo.fetch("Referrer__c")).to eql "0031g000008ROtsAAG"
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Referral_Company_Name__c")
            @helper.addLogs("[Expected ] : john.snow_Org_qaauto12121212")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Referral_Company_Name__c")}")
            expect(insertedLeadInfo.fetch("Referral_Company_Name__c")).to eql "john.snow_Org_qaauto12121212"
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Referrer_Name__c")
            @helper.addLogs("[Expected ] : John")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Referrer_Name__c")}")
            expect(insertedLeadInfo.fetch("Referrer_Name__c")).to eql "John"
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Referrer_Email__c")
            @helper.addLogs("[Expected ] : abc@example.com")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Referrer_Email__c")}")
            expect(insertedLeadInfo.fetch("Referrer_Email__c")).to eql "abc@example.com"
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

            @helper.addLogs("[Validate ] : Checking building interested name on Lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Building Interested In']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Building_Interested_Name__c")}")
            expect(insertedLeadInfo.fetch("Building_Interested_Name__c")).to eql @testDataJSON['Lead'][0]['Building Interested In']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking building interested In")
            @helper.addLogs("[Expected ] : #{building[0].fetch("Id")}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Building_Interested_In__c")}")
            expect(insertedLeadInfo.fetch("Building_Interested_In__c")).to eql building[0].fetch("Id")
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Journey created date on lead")
            @helper.addLogs("[Expected ] : #{Date.today}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Journey_Created_On__c")}")
            expect(insertedLeadInfo.fetch("Journey_Created_On__c")).to eql Date.today.to_s
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Interested in Number of Desks on lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Interested in Number of Desk(s)']}.0")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch('Interested_in_Number_of_Desks__c')}")
            expect(insertedLeadInfo.fetch("Interested_in_Number_of_Desks__c").to_i).to eql "#{@testDataJSON['Lead'][0]['Interested in Number of Desk(s)']}.0".to_i
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Locations Interested on lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Locations Interested']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Locations_Interested__c")}")
            expect(insertedLeadInfo.fetch("Locations_Interested__c")).to eql @testDataJSON['Lead'][0]['Locations Interested']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Number of Full Time Employees on lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Number of Full Time Employees']}.0")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Number_of_Full_Time_Employees__c")}")
            expect(insertedLeadInfo.fetch("Number_of_Full_Time_Employees__c").to_i).to eql "#{@testDataJSON['Lead'][0]['Number of Full Time Employees']}.0".to_i
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Email on lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Email']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Email")}")
            expect(insertedLeadInfo.fetch("Email")).to eql @testDataJSON['Lead'][0]['Email']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Phone on lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Phone']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Phone")}")
            expect(insertedLeadInfo.fetch("Phone")).to eql "(888) 888-8888"
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Company on lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Company']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Company")}")
            expect(insertedLeadInfo.fetch("Company")).to eql @testDataJSON['Lead'][0]['Company']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking RecordType on lead")
            @helper.addLogs("[Expected ] : #{recordType}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("RecordType").fetch("Name")}")
            expect(insertedLeadInfo.fetch("RecordType").fetch("Name")).to eql recordType
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

            @helper.addLogs("[Validate ] : Checking Email_Opt_out on lead")
            @helper.addLogs("[Expected ] : true")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("HasOptedOutOfEmail")}")
            expect(insertedLeadInfo.fetch("HasOptedOutOfEmail")).to eql true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Promo code on lead")
            @helper.addLogs("[Expected ] : @testDataJSON['Lead'][0]['Promo Code']")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Promo_Code__c")}")
            expect(insertedLeadInfo.fetch("Promo_Code__c")).to eql @testDataJSON['Lead'][0]['Promo Code']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Move in Time frame on lead")
            @helper.addLogs("[Expected ] : @testDataJSON['Lead'][0]['Move In Time Frame']")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Move_In_Time_Frame__c")}")
            expect(insertedLeadInfo.fetch("Move_In_Time_Frame__c")).to eql @testDataJSON['Lead'][0]['Move In Time Frame']
            @helper.addLogs("[Result ]   : Success\n")            

            @helper.addLogs("[Step ]     : Checking for journey should created or Not")
            generateJourneyPermissin = @objLeadGeneration.isGenerateJourney(insertedLeadInfo.fetch("Owner").fetch("Id"),insertedLeadInfo.fetch("LeadSource"),insertedLeadInfo.fetch("Lead_Source_Detail__c"),insertedLeadInfo.fetch("Generate_Journey__c"))
           

            if generateJourneyPermissin then
                puts "********************************************************"

                @helper.addLogs("[Step ]     : Fetch journey deatails")            
                insertedJourneyInfo = @objLeadGeneration.fetchJourneyDetails(insertedLeadInfo.fetch("Email"))
                expect(insertedJourneyInfo).to_not eq nil
                expect(insertedJourneyInfo.size).to eq 1
                expect(insertedJourneyInfo[0]).to_not eq nil  
                insertedJourneyInfo =  insertedJourneyInfo[0]      
                @helper.addLogs("[Result ]   : Success\n")

                @helper.addLogs("[Validate ] : Checking Journey Name")
                @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
                @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Name")}")
                expect(insertedJourneyInfo).to_not eql nil
                expect(insertedJourneyInfo.fetch("Name")).to match("#{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
                @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking Journey owner")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Owner").fetch("Name")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Owner").fetch("Name")}")
                 expect(insertedJourneyInfo.fetch("Owner").fetch("Id")).to eql insertedLeadInfo.fetch("Owner").fetch("Id")
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

                 @helper.addLogs("[Validate ] : Checking building interested In on Journey")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Building_Interested_In__c")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Building_Interested_In__c")}")
                 expect(insertedJourneyInfo.fetch("Building_Interested_In__c")).to eql insertedLeadInfo.fetch("Building_Interested_In__c")
                 @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking NMD Next Contact Date on Journey")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Journey_Created_On__c")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")}")
                 expect(insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")).to eql insertedLeadInfo.fetch("Journey_Created_On__c")
                 @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking Interested in Number of Desks on Journey")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Interested_in_Number_of_Desks__c")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Interested_in_Number_of_Desks__c")}")
                 expect(insertedJourneyInfo.fetch("Interested_in_Number_of_Desks__c")).to eql insertedLeadInfo.fetch("Interested_in_Number_of_Desks__c")
                 @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking Locations Interested on Journey")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Locations_Interested__c")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Locations_Interested__c")}")
                 expect(insertedJourneyInfo.fetch("Locations_Interested__c")).to eql insertedLeadInfo.fetch("Locations_Interested__c")
                 @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking Number of Full Time Employees on Journey")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Number_of_Full_Time_Employees__c")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Full_Time_Employees__c")}")
                 expect(insertedJourneyInfo.fetch("Full_Time_Employees__c")).to eql insertedLeadInfo.fetch("Number_of_Full_Time_Employees__c")
                 @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking Email on Journey")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Email")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Primary_Email__c")}")
                 expect(insertedJourneyInfo.fetch("Primary_Email__c")).to eql insertedLeadInfo.fetch("Email")
                 @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking Phone on Journey")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Phone")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Primary_Phone__c")}")
                 expect(insertedJourneyInfo.fetch("Primary_Phone__c")).to eql "(888) 888-8888"
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

                 @helper.addLogs("[Validate ] : Checking Journey Market")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Market__c")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Market__c")}")
                 expect(insertedJourneyInfo.fetch("Market__c")).to eql insertedLeadInfo.fetch("Market__c")
                 @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking Journey Next Contact Date")
                 @helper.addLogs("[Expected ] : Started")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")}")
                 #expect(insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")).to eql "Started"
                 @helper.addLogs("[Result ]   : Success\n")

                @helper.addLogs("[Validate ] : Checking Journey Markets_Interested__c")
                @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Markets_Interested__c")}")
                @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Markets_Interested__c")}")
                expect(insertedLeadInfo.fetch("Markets_Interested__c")).to eql insertedLeadInfo.fetch("Markets_Interested__c")
                @helper.addLogs("[Result ]   : Success\n")

            else
                expect(insertedJourneyInfo).to eql nil
            end
            puts "********************************************************"

            @helper.addLogs("[Step ]     : Fetch Activity deatails")            
            generatedActivityForLead = @objLeadGeneration.fetchActivityDetails(insertedLeadInfo.fetch("Id"))
            expect(generatedActivityForLead).to_not eq nil
            expect(generatedActivityForLead.size).to eq 1
            expect(generatedActivityForLead[0]).to_not eq nil  
            generatedActivityForLead =  generatedActivityForLead[0]      
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Subject on acitivity")
            @helper.addLogs("[Expected ] : Inbound Lead submission")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Subject")}")
            expect(generatedActivityForLead.fetch("Subject")).to eql "Inbound Lead submission"
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking lead source on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("LeadSource")}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Lead_Source__c")}")
            expect(generatedActivityForLead.fetch("Lead_Source__c")).to eql insertedLeadInfo.fetch("LeadSource")
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking lead source detail on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Lead_Source_Detail__c")}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Lead_Source_Detail__c")}")
            expect(generatedActivityForLead.fetch("Lead_Source_Detail__c")).to eql insertedLeadInfo.fetch("Lead_Source_Detail__c")
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking assigned to on activity")
            @helper.addLogs("[Expected ] : Logged In User")#{@userInfo.fetch("display_name")}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Owner").fetch("Name")}")
            #expect(generatedActivityForLead.fetch("Owner").fetch("Name")).to eql @userInfo.fetch("display_name")
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking status on activity")
            @helper.addLogs("[Expected ] : Open")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Status")}")
            expect(generatedActivityForLead.fetch("Status")).to eql "Open"
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Company__c on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Company')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Company__c")}")
            expect(generatedActivityForLead.fetch("Company__c")).to eql insertedLeadInfo.fetch('Company')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Location interested on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Locations_Interested__c')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Locations_Interested__c")}")
            expect(generatedActivityForLead.fetch("Locations_Interested__c")).to eql insertedLeadInfo.fetch('Locations_Interested__c')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Location interested on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Number_of_Full_Time_Employees__c')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Number_of_Full_Time_Employees__c")}")
            expect(generatedActivityForLead.fetch("Number_of_Full_Time_Employees__c")).to eql insertedLeadInfo.fetch('Number_of_Full_Time_Employees__c')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Number of desks on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Interested_in_Number_of_Desks__c')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Interested_in_Number_of_Desks__c")}")
            expect(generatedActivityForLead.fetch("Interested_in_Number_of_Desks__c")).to eql insertedLeadInfo.fetch('Interested_in_Number_of_Desks__c')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Priority on activity")
            @helper.addLogs("[Expected ] : Normal")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Priority")}")
            expect(generatedActivityForLead.fetch("Priority")).to eql "Normal"
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Name on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Name')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Who").fetch('Name')}")
            expect(generatedActivityForLead.fetch("Who").fetch('Name')).to eql insertedLeadInfo.fetch('Name')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Email on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Email')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Email__c")}")
            expect(generatedActivityForLead.fetch("Email__c")).to eql insertedLeadInfo.fetch('Email')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Country_Code__c on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Country_Code__c')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Country_Code__c")}")
            expect(generatedActivityForLead.fetch("Country_Code__c")).to eql insertedLeadInfo.fetch('Country_Code__c')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Locale__c on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Locale__c')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Locale__c")}")
            expect(generatedActivityForLead.fetch("Locale__c")).to eql insertedLeadInfo.fetch('Locale__c')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Markets_Interested__c on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Markets_Interested__c')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Markets_Interested__c")}")
            expect(generatedActivityForLead.fetch("Markets_Interested__c")).to eql insertedLeadInfo.fetch('Markets_Interested__c')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Market__c on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Market__c')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Market__c")}")
            expect(generatedActivityForLead.fetch("Market__c")).to eql insertedLeadInfo.fetch('Market__c')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.postSuccessResult('2554')
        rescue Exception => e
            puts e
            @helper.postFailResult(e,'2554')
        end
    end

    it "C:2555 To check lead is assigned to proper 'User' from lead assignment rule for 'Enterprise Solution' record type and journey,activity should be created for that lead.", :'2555' => 'true' do
        begin
            @helper.addLogs("C:2016 To check lead is assigned to proper 'User' from lead assignment rule for 'Enterprise Solution' record type and journey,activity should be created for that lead.",'2555')
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
            @testDataJSON['Lead'][0]['Number of Full Time Employees'] = '1500'
            @testDataJSON['Lead'][0]['Locations Interested'] = "AMS-Labs;AMS-Strawinskylaan"
            @testDataJSON['Lead'][0]['Referrer'] = 'john snow_QaAuto_121'
            @testDataJSON['Lead'][0]['Referrer Name'] = 'John'
            @testDataJSON['Lead'][0]['Referrer Email'] = 'abc@example.com'
            @testDataJSON['Lead'][0]['Assign using active assignment rule'] = true
            @testDataJSON['Lead'][0]['Promo Code'] = "123123"

            @helper.addLogs("[Step ]     : Fetch building deatails")            
            building = @objLeadGeneration.fetchBuildingDetails(@testDataJSON['Lead'][0]['Building Interested In'])
            expect(building).to_not eq nil
            expect(building.size).to eq 1
            expect(building[0]).to_not eq nil      
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Login to salesforce")
            @objLeadGeneration.loginToSalesforce
            
            @helper.addLogs("[Step ]     : Create Lead record with consumer record type")
            @objLeadGeneration.createLeadStdsalesforce
            @helper.addLogs("[Validate ] : Checking Lead is created after form submission")
            @helper.addLogs("[Expected ] : Lead should create with name #{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
            
            @helper.addLogs("[Step ]     : Fetch lead deatails")            
            insertedLeadInfo = @objLeadGeneration.fetchLeadDetails(@testDataJSON['Lead'][0]['Email'])
            expect(insertedLeadInfo).to_not eq nil
            expect(insertedLeadInfo.size).to eq 1
            expect(insertedLeadInfo[0]).to_not eq nil  
            insertedLeadInfo =  insertedLeadInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead name")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Name")}")            
            expect(insertedLeadInfo.fetch("Name")).to match("#{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
            @helper.addLogs("[Result ]   : Success\n")

            recordType = @objLeadGeneration.getRecordType(@testDataJSON['Lead'][0]['Number of Full Time Employees'].to_i)

            @helper.addLogs("[Validate ] : Checking Lead owner should be According to Lead Assignment Rule")
            @helper.addLogs("[Expected ] : 0050G000008KcLF")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Owner").fetch("Id")}")            
            expect(insertedLeadInfo.fetch("Owner").fetch("Id")).to match("0050G000008KcLF")
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Organization")
            @helper.addLogs("[Expected ] : 0011g00000CIkegAAD")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Account__c")}")
            expect(insertedLeadInfo.fetch("Account__c")).to match("0011g00000CIkegAAD")
            @helper.addLogs("[Result ]   : Success\n")
            
            @helper.addLogs("[Validate ] : Checking Lead Market")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Market']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Market__c")}")
            expect(insertedLeadInfo.fetch("Market__c")).to eql @testDataJSON['Lead'][0]['Market']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Generate_Journey__c")
            @helper.addLogs("[Expected ] : #{!@testDataJSON['Lead'][0]['Generate Journey']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Generate_Journey__c")}")
            expect(insertedLeadInfo.fetch("Generate_Journey__c")).to eql true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Has_Active_Journey__c")
            @helper.addLogs("[Expected ] : true")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Has_Active_Journey__c")}")
            expect(insertedLeadInfo.fetch("Has_Active_Journey__c")).to eql true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Markets_Interested__c")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Markets Interested']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Markets_Interested__c")}")
            expect(insertedLeadInfo.fetch("Markets_Interested__c")).to eql @testDataJSON['Lead'][0]['Markets Interested']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Referrer__c")
            @helper.addLogs("[Expected ] : 0031g000008ROtsAAG")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Referrer__c")}")
            expect(insertedLeadInfo.fetch("Referrer__c")).to eql "0031g000008ROtsAAG"
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Referral_Company_Name__c")
            @helper.addLogs("[Expected ] : john.snow_Org_qaauto12121212")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Referral_Company_Name__c")}")
            expect(insertedLeadInfo.fetch("Referral_Company_Name__c")).to eql "john.snow_Org_qaauto12121212"
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Referrer_Name__c")
            @helper.addLogs("[Expected ] : John")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Referrer_Name__c")}")
            expect(insertedLeadInfo.fetch("Referrer_Name__c")).to eql "John"
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Referrer_Email__c")
            @helper.addLogs("[Expected ] : abc@example.com")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Referrer_Email__c")}")
            expect(insertedLeadInfo.fetch("Referrer_Email__c")).to eql "abc@example.com"
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

            @helper.addLogs("[Validate ] : Checking building interested name on Lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Building Interested In']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Building_Interested_Name__c")}")
            expect(insertedLeadInfo.fetch("Building_Interested_Name__c")).to eql @testDataJSON['Lead'][0]['Building Interested In']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking building interested In")
            @helper.addLogs("[Expected ] : #{building[0].fetch("Id")}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Building_Interested_In__c")}")
            expect(insertedLeadInfo.fetch("Building_Interested_In__c")).to eql building[0].fetch("Id")
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Journey created date on lead")
            @helper.addLogs("[Expected ] : #{Date.today}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Journey_Created_On__c")}")
            expect(insertedLeadInfo.fetch("Journey_Created_On__c")).to eql Date.today.to_s
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Interested in Number of Desks on lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Interested in Number of Desk(s)']}.0")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch('Interested_in_Number_of_Desks__c')}")
            expect(insertedLeadInfo.fetch("Interested_in_Number_of_Desks__c").to_i).to eql "#{@testDataJSON['Lead'][0]['Interested in Number of Desk(s)']}.0".to_i
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Locations Interested on lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Locations Interested']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Locations_Interested__c")}")
            expect(insertedLeadInfo.fetch("Locations_Interested__c")).to eql @testDataJSON['Lead'][0]['Locations Interested']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Number of Full Time Employees on lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Number of Full Time Employees']}.0")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Number_of_Full_Time_Employees__c")}")
            expect(insertedLeadInfo.fetch("Number_of_Full_Time_Employees__c").to_i).to eql "#{@testDataJSON['Lead'][0]['Number of Full Time Employees']}.0".to_i
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Email on lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Email']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Email")}")
            expect(insertedLeadInfo.fetch("Email")).to eql @testDataJSON['Lead'][0]['Email']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Phone on lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Phone']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Phone")}")
            expect(insertedLeadInfo.fetch("Phone")).to eql "(888) 888-8888"
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Company on lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Company']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Company")}")
            expect(insertedLeadInfo.fetch("Company")).to eql @testDataJSON['Lead'][0]['Company']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking RecordType on lead")
            @helper.addLogs("[Expected ] : #{recordType}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("RecordType").fetch("Name")}")
            expect(insertedLeadInfo.fetch("RecordType").fetch("Name")).to eql recordType
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

            @helper.addLogs("[Validate ] : Checking Email_Opt_out on lead")
            @helper.addLogs("[Expected ] : true")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("HasOptedOutOfEmail")}")
            expect(insertedLeadInfo.fetch("HasOptedOutOfEmail")).to eql true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Promo code on lead")
            @helper.addLogs("[Expected ] : @testDataJSON['Lead'][0]['Promo Code']")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Promo_Code__c")}")
            expect(insertedLeadInfo.fetch("Promo_Code__c")).to eql @testDataJSON['Lead'][0]['Promo Code']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Move in Time frame on lead")
            @helper.addLogs("[Expected ] : @testDataJSON['Lead'][0]['Move In Time Frame']")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Move_In_Time_Frame__c")}")
            expect(insertedLeadInfo.fetch("Move_In_Time_Frame__c")).to eql @testDataJSON['Lead'][0]['Move In Time Frame']
            @helper.addLogs("[Result ]   : Success\n")            

            @helper.addLogs("[Step ]     : Checking for journey should created or Not")
            generateJourneyPermissin = @objLeadGeneration.isGenerateJourney(insertedLeadInfo.fetch("Owner").fetch("Id"),insertedLeadInfo.fetch("LeadSource"),insertedLeadInfo.fetch("Lead_Source_Detail__c"),insertedLeadInfo.fetch("Generate_Journey__c"))
           

            if generateJourneyPermissin then
                puts "********************************************************"

                @helper.addLogs("[Step ]     : Fetch journey deatails")            
                insertedJourneyInfo = @objLeadGeneration.fetchJourneyDetails(insertedLeadInfo.fetch("Email"))
                expect(insertedJourneyInfo).to_not eq nil
                expect(insertedJourneyInfo.size).to eq 1
                expect(insertedJourneyInfo[0]).to_not eq nil  
                insertedJourneyInfo =  insertedJourneyInfo[0]      
                @helper.addLogs("[Result ]   : Success\n")

                @helper.addLogs("[Validate ] : Checking Journey Name")
                @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
                @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Name")}")
                expect(insertedJourneyInfo).to_not eql nil
                expect(insertedJourneyInfo.fetch("Name")).to match("#{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
                @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking Journey owner")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Owner").fetch("Name")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Owner").fetch("Name")}")
                 expect(insertedJourneyInfo.fetch("Owner").fetch("Id")).to eql insertedLeadInfo.fetch("Owner").fetch("Id")
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

                 @helper.addLogs("[Validate ] : Checking building interested In on Journey")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Building_Interested_In__c")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Building_Interested_In__c")}")
                 expect(insertedJourneyInfo.fetch("Building_Interested_In__c")).to eql insertedLeadInfo.fetch("Building_Interested_In__c")
                 @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking NMD Next Contact Date on Journey")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Journey_Created_On__c")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")}")
                 expect(insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")).to eql insertedLeadInfo.fetch("Journey_Created_On__c")
                 @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking Interested in Number of Desks on Journey")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Interested_in_Number_of_Desks__c")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Interested_in_Number_of_Desks__c")}")
                 expect(insertedJourneyInfo.fetch("Interested_in_Number_of_Desks__c")).to eql insertedLeadInfo.fetch("Interested_in_Number_of_Desks__c")
                 @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking Locations Interested on Journey")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Locations_Interested__c")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Locations_Interested__c")}")
                 expect(insertedJourneyInfo.fetch("Locations_Interested__c")).to eql insertedLeadInfo.fetch("Locations_Interested__c")
                 @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking Number of Full Time Employees on Journey")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Number_of_Full_Time_Employees__c")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Full_Time_Employees__c")}")
                 expect(insertedJourneyInfo.fetch("Full_Time_Employees__c")).to eql insertedLeadInfo.fetch("Number_of_Full_Time_Employees__c")
                 @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking Email on Journey")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Email")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Primary_Email__c")}")
                 expect(insertedJourneyInfo.fetch("Primary_Email__c")).to eql insertedLeadInfo.fetch("Email")
                 @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking Phone on Journey")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Phone")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Primary_Phone__c")}")
                 expect(insertedJourneyInfo.fetch("Primary_Phone__c")).to eql "(888) 888-8888"
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

                 @helper.addLogs("[Validate ] : Checking Journey Market")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Market__c")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Market__c")}")
                 expect(insertedJourneyInfo.fetch("Market__c")).to eql insertedLeadInfo.fetch("Market__c")
                 @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking Journey Next Contact Date")
                 @helper.addLogs("[Expected ] : Started")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")}")
                 #expect(insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")).to eql "Started"
                 @helper.addLogs("[Result ]   : Success\n")

                @helper.addLogs("[Validate ] : Checking Journey Markets_Interested__c")
                @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Markets_Interested__c")}")
                @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Markets_Interested__c")}")
                expect(insertedLeadInfo.fetch("Markets_Interested__c")).to eql insertedLeadInfo.fetch("Markets_Interested__c")
                @helper.addLogs("[Result ]   : Success\n")

            else
                expect(insertedJourneyInfo).to eql nil
            end
            puts "********************************************************"

            @helper.addLogs("[Step ]     : Fetch Activity deatails")            
            generatedActivityForLead = @objLeadGeneration.fetchActivityDetails(insertedLeadInfo.fetch("Id"))
            expect(generatedActivityForLead).to_not eq nil
            expect(generatedActivityForLead.size).to eq 1
            expect(generatedActivityForLead[0]).to_not eq nil  
            generatedActivityForLead =  generatedActivityForLead[0]      
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Subject on acitivity")
            @helper.addLogs("[Expected ] : Inbound Lead submission")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Subject")}")
            expect(generatedActivityForLead.fetch("Subject")).to eql "Inbound Lead submission"
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking lead source on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("LeadSource")}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Lead_Source__c")}")
            expect(generatedActivityForLead.fetch("Lead_Source__c")).to eql insertedLeadInfo.fetch("LeadSource")
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking lead source detail on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Lead_Source_Detail__c")}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Lead_Source_Detail__c")}")
            expect(generatedActivityForLead.fetch("Lead_Source_Detail__c")).to eql insertedLeadInfo.fetch("Lead_Source_Detail__c")
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking assigned to on activity")
            @helper.addLogs("[Expected ] : Logged In User")#{@userInfo.fetch("display_name")}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Owner").fetch("Name")}")
            #expect(generatedActivityForLead.fetch("Owner").fetch("Name")).to eql @userInfo.fetch("display_name")
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking status on activity")
            @helper.addLogs("[Expected ] : Open")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Status")}")
            expect(generatedActivityForLead.fetch("Status")).to eql "Open"
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Company__c on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Company')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Company__c")}")
            expect(generatedActivityForLead.fetch("Company__c")).to eql insertedLeadInfo.fetch('Company')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Location interested on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Locations_Interested__c')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Locations_Interested__c")}")
            expect(generatedActivityForLead.fetch("Locations_Interested__c")).to eql insertedLeadInfo.fetch('Locations_Interested__c')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Location interested on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Number_of_Full_Time_Employees__c')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Number_of_Full_Time_Employees__c")}")
            expect(generatedActivityForLead.fetch("Number_of_Full_Time_Employees__c")).to eql insertedLeadInfo.fetch('Number_of_Full_Time_Employees__c')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Number of desks on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Interested_in_Number_of_Desks__c')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Interested_in_Number_of_Desks__c")}")
            expect(generatedActivityForLead.fetch("Interested_in_Number_of_Desks__c")).to eql insertedLeadInfo.fetch('Interested_in_Number_of_Desks__c')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Priority on activity")
            @helper.addLogs("[Expected ] : Normal")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Priority")}")
            expect(generatedActivityForLead.fetch("Priority")).to eql "Normal"
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Name on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Name')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Who").fetch('Name')}")
            expect(generatedActivityForLead.fetch("Who").fetch('Name')).to eql insertedLeadInfo.fetch('Name')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Email on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Email')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Email__c")}")
            expect(generatedActivityForLead.fetch("Email__c")).to eql insertedLeadInfo.fetch('Email')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Country_Code__c on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Country_Code__c')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Country_Code__c")}")
            expect(generatedActivityForLead.fetch("Country_Code__c")).to eql insertedLeadInfo.fetch('Country_Code__c')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Locale__c on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Locale__c')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Locale__c")}")
            expect(generatedActivityForLead.fetch("Locale__c")).to eql insertedLeadInfo.fetch('Locale__c')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Markets_Interested__c on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Markets_Interested__c')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Markets_Interested__c")}")
            expect(generatedActivityForLead.fetch("Markets_Interested__c")).to eql insertedLeadInfo.fetch('Markets_Interested__c')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Market__c on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Market__c')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Market__c")}")
            expect(generatedActivityForLead.fetch("Market__c")).to eql insertedLeadInfo.fetch('Market__c')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.postSuccessResult('2555')
        rescue Exception => e
            puts e
            @helper.postFailResult(e,'2555')
        end
    end

    it "C:2527 To check lead is assigned to proper 'Queue' from lead assignment rule for 'Consumer' record type and journey,activity should be created for that lead.", :'2527' => 'true' do
        begin
            @helper.addLogs("C:2527 To check lead is assigned to proper 'Queue' from lead assignment rule for 'Consumer' record type and journey,activity should be created for that lead.",'2527')
            @testDataJSON['Lead'][0]['RecordType'] = 'Consumer'
            @testDataJSON['Lead'][0]['Email'] = @testDataJSON['Lead'][0]['LastName'] + SecureRandom.random_number(10000000000).to_s + "@test.com"
            @testDataJSON['Lead'][0]['leadSource'] = 'Event'
            @testDataJSON['Lead'][0]['lead_Source_Detail__c'] = 'Global Contact CTA'
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

            expectedOwner  = '00GF0000007vuoIMAQ'

            @helper.addLogs("[Step ]     : Fetch building deatails")            
            building = @objLeadGeneration.fetchBuildingDetails(@testDataJSON['Lead'][0]['Building Interested In'])
            expect(building).to_not eq nil
            expect(building.size).to eq 1
            expect(building[0]).to_not eq nil      
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Login to salesforce")
            @objLeadGeneration.loginToSalesforce
            
            @helper.addLogs("[Step ]     : Create Lead record with consumer record type")
            @objLeadGeneration.createLeadStdsalesforce
            @helper.addLogs("[Validate ] : Checking Lead is created after form submission")
            @helper.addLogs("[Expected ] : Lead should create with name #{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
            
            @helper.addLogs("[Step ]     : Fetch lead deatails")            
            insertedLeadInfo = @objLeadGeneration.fetchLeadDetails(@testDataJSON['Lead'][0]['Email'])
            expect(insertedLeadInfo).to_not eq nil
            expect(insertedLeadInfo.size).to eq 1
            expect(insertedLeadInfo[0]).to_not eq nil  
            insertedLeadInfo =  insertedLeadInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead name")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Name")}")            
            expect(insertedLeadInfo.fetch("Name")).to match("#{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
            @helper.addLogs("[Result ]   : Success\n")

            recordType = @objLeadGeneration.getRecordType(@testDataJSON['Lead'][0]['Number of Full Time Employees'].to_i)

            @helper.addLogs("[Validate ] : Checking Lead owner should be According to Lead Assignment Rule")
            @helper.addLogs("[Expected ] : #{expectedOwner}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Owner").fetch("Id")}")            
            expect(insertedLeadInfo.fetch("Owner").fetch("Id")).to match("#{expectedOwner}")
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Organization")
            @helper.addLogs("[Expected ] : 0011g00000CIkegAAD")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Account__c")}")
            expect(insertedLeadInfo.fetch("Account__c")).to match("0011g00000CIkegAAD")
            @helper.addLogs("[Result ]   : Success\n")
            
            @helper.addLogs("[Validate ] : Checking Lead Market")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Market']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Market__c")}")
            expect(insertedLeadInfo.fetch("Market__c")).to eql @testDataJSON['Lead'][0]['Market']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Generate_Journey__c")
            @helper.addLogs("[Expected ] : #{!@testDataJSON['Lead'][0]['Generate Journey']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Generate_Journey__c")}")
            expect(insertedLeadInfo.fetch("Generate_Journey__c")).to eql true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Has_Active_Journey__c")
            @helper.addLogs("[Expected ] : true")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Has_Active_Journey__c")}")
            expect(insertedLeadInfo.fetch("Has_Active_Journey__c")).to eql true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Markets_Interested__c")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Markets Interested']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Markets_Interested__c")}")
            expect(insertedLeadInfo.fetch("Markets_Interested__c")).to eql @testDataJSON['Lead'][0]['Markets Interested']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Referrer__c")
            @helper.addLogs("[Expected ] : 0031g000008ROtsAAG")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Referrer__c")}")
            expect(insertedLeadInfo.fetch("Referrer__c")).to eql "0031g000008ROtsAAG"
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Referral_Company_Name__c")
            @helper.addLogs("[Expected ] : john.snow_Org_qaauto12121212")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Referral_Company_Name__c")}")
            expect(insertedLeadInfo.fetch("Referral_Company_Name__c")).to eql "john.snow_Org_qaauto12121212"
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Referrer_Name__c")
            @helper.addLogs("[Expected ] : John")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Referrer_Name__c")}")
            expect(insertedLeadInfo.fetch("Referrer_Name__c")).to eql "John"
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Referrer_Email__c")
            @helper.addLogs("[Expected ] : abc@example.com")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Referrer_Email__c")}")
            expect(insertedLeadInfo.fetch("Referrer_Email__c")).to eql "abc@example.com"
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

            @helper.addLogs("[Validate ] : Checking building interested name on Lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Building Interested In']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Building_Interested_Name__c")}")
            expect(insertedLeadInfo.fetch("Building_Interested_Name__c")).to eql @testDataJSON['Lead'][0]['Building Interested In']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking building interested In")
            @helper.addLogs("[Expected ] : #{building[0].fetch("Id")}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Building_Interested_In__c")}")
            expect(insertedLeadInfo.fetch("Building_Interested_In__c")).to eql building[0].fetch("Id")
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Journey created date on lead")
            @helper.addLogs("[Expected ] : #{Date.today}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Journey_Created_On__c")}")
            expect(insertedLeadInfo.fetch("Journey_Created_On__c")).to eql Date.today.to_s
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Interested in Number of Desks on lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Interested in Number of Desk(s)']}.0")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch('Interested_in_Number_of_Desks__c')}")
            expect(insertedLeadInfo.fetch("Interested_in_Number_of_Desks__c").to_i).to eql "#{@testDataJSON['Lead'][0]['Interested in Number of Desk(s)']}.0".to_i
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Locations Interested on lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Locations Interested']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Locations_Interested__c")}")
            expect(insertedLeadInfo.fetch("Locations_Interested__c")).to eql @testDataJSON['Lead'][0]['Locations Interested']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Number of Full Time Employees on lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Number of Full Time Employees']}.0")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Number_of_Full_Time_Employees__c")}")
            expect(insertedLeadInfo.fetch("Number_of_Full_Time_Employees__c").to_i).to eql "#{@testDataJSON['Lead'][0]['Number of Full Time Employees']}.0".to_i
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Email on lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Email']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Email")}")
            expect(insertedLeadInfo.fetch("Email")).to eql @testDataJSON['Lead'][0]['Email']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Phone on lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Phone']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Phone")}")
            expect(insertedLeadInfo.fetch("Phone")).to eql "(888) 888-8888"
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Company on lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Company']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Company")}")
            expect(insertedLeadInfo.fetch("Company")).to eql @testDataJSON['Lead'][0]['Company']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking RecordType on lead")
            @helper.addLogs("[Expected ] : #{recordType}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("RecordType").fetch("Name")}")
            expect(insertedLeadInfo.fetch("RecordType").fetch("Name")).to eql recordType
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

            @helper.addLogs("[Validate ] : Checking Email_Opt_out on lead")
            @helper.addLogs("[Expected ] : true")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("HasOptedOutOfEmail")}")
            expect(insertedLeadInfo.fetch("HasOptedOutOfEmail")).to eql true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Promo code on lead")
            @helper.addLogs("[Expected ] : @testDataJSON['Lead'][0]['Promo Code']")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Promo_Code__c")}")
            expect(insertedLeadInfo.fetch("Promo_Code__c")).to eql @testDataJSON['Lead'][0]['Promo Code']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Move in Time frame on lead")
            @helper.addLogs("[Expected ] : @testDataJSON['Lead'][0]['Move In Time Frame']")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Move_In_Time_Frame__c")}")
            expect(insertedLeadInfo.fetch("Move_In_Time_Frame__c")).to eql @testDataJSON['Lead'][0]['Move In Time Frame']
            @helper.addLogs("[Result ]   : Success\n")            

            @helper.addLogs("[Step ]     : Checking for journey should created or Not")
            generateJourneyPermissin = @objLeadGeneration.isGenerateJourney(insertedLeadInfo.fetch("Owner").fetch("Id"),insertedLeadInfo.fetch("LeadSource"),insertedLeadInfo.fetch("Lead_Source_Detail__c"),insertedLeadInfo.fetch("Generate_Journey__c"))
           

            if generateJourneyPermissin then
                puts "********************************************************"

                @helper.addLogs("[Step ]     : Fetch journey deatails")            
                insertedJourneyInfo = @objLeadGeneration.fetchJourneyDetails(insertedLeadInfo.fetch("Email"))
                expect(insertedJourneyInfo).to_not eq nil
                expect(insertedJourneyInfo.size).to eq 1
                expect(insertedJourneyInfo[0]).to_not eq nil  
                insertedJourneyInfo =  insertedJourneyInfo[0]      
                @helper.addLogs("[Result ]   : Success\n")

                @helper.addLogs("[Validate ] : Checking Journey Name")
                @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
                @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Name")}")
                expect(insertedJourneyInfo).to_not eql nil
                expect(insertedJourneyInfo.fetch("Name")).to match("#{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
                @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking Journey owner")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Owner").fetch("Name")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Owner").fetch("Name")}")
                 expect(insertedJourneyInfo.fetch("Owner").fetch("Id")).to eql insertedLeadInfo.fetch("Owner").fetch("Id")
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

                 @helper.addLogs("[Validate ] : Checking building interested In on Journey")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Building_Interested_In__c")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Building_Interested_In__c")}")
                 expect(insertedJourneyInfo.fetch("Building_Interested_In__c")).to eql insertedLeadInfo.fetch("Building_Interested_In__c")
                 @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking NMD Next Contact Date on Journey")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Journey_Created_On__c")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")}")
                 expect(insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")).to eql insertedLeadInfo.fetch("Journey_Created_On__c")
                 @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking Interested in Number of Desks on Journey")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Interested_in_Number_of_Desks__c")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Interested_in_Number_of_Desks__c")}")
                 expect(insertedJourneyInfo.fetch("Interested_in_Number_of_Desks__c")).to eql insertedLeadInfo.fetch("Interested_in_Number_of_Desks__c")
                 @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking Locations Interested on Journey")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Locations_Interested__c")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Locations_Interested__c")}")
                 expect(insertedJourneyInfo.fetch("Locations_Interested__c")).to eql insertedLeadInfo.fetch("Locations_Interested__c")
                 @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking Number of Full Time Employees on Journey")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Number_of_Full_Time_Employees__c")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Full_Time_Employees__c")}")
                 expect(insertedJourneyInfo.fetch("Full_Time_Employees__c")).to eql insertedLeadInfo.fetch("Number_of_Full_Time_Employees__c")
                 @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking Email on Journey")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Email")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Primary_Email__c")}")
                 expect(insertedJourneyInfo.fetch("Primary_Email__c")).to eql insertedLeadInfo.fetch("Email")
                 @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking Phone on Journey")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Phone")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Primary_Phone__c")}")
                 expect(insertedJourneyInfo.fetch("Primary_Phone__c")).to eql "(888) 888-8888"
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

                 @helper.addLogs("[Validate ] : Checking Journey Market")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Market__c")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Market__c")}")
                 expect(insertedJourneyInfo.fetch("Market__c")).to eql insertedLeadInfo.fetch("Market__c")
                 @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking Journey Next Contact Date")
                 @helper.addLogs("[Expected ] : Started")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")}")
                 #expect(insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")).to eql "Started"
                 @helper.addLogs("[Result ]   : Success\n")

                @helper.addLogs("[Validate ] : Checking Journey Markets_Interested__c")
                @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Markets_Interested__c")}")
                @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Markets_Interested__c")}")
                expect(insertedLeadInfo.fetch("Markets_Interested__c")).to eql insertedLeadInfo.fetch("Markets_Interested__c")
                @helper.addLogs("[Result ]   : Success\n")

            else
                expect(insertedJourneyInfo).to eql nil
            end
            puts "********************************************************"

            @helper.addLogs("[Step ]     : Fetch Activity deatails")            
            generatedActivityForLead = @objLeadGeneration.fetchActivityDetails(insertedLeadInfo.fetch("Id"))
            expect(generatedActivityForLead).to_not eq nil
            expect(generatedActivityForLead.size).to eq 1
            expect(generatedActivityForLead[0]).to_not eq nil  
            generatedActivityForLead =  generatedActivityForLead[0]      
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Subject on acitivity")
            @helper.addLogs("[Expected ] : Inbound Lead submission")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Subject")}")
            expect(generatedActivityForLead.fetch("Subject")).to eql "Inbound Lead submission"
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking lead source on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("LeadSource")}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Lead_Source__c")}")
            expect(generatedActivityForLead.fetch("Lead_Source__c")).to eql insertedLeadInfo.fetch("LeadSource")
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking lead source detail on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Lead_Source_Detail__c")}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Lead_Source_Detail__c")}")
            expect(generatedActivityForLead.fetch("Lead_Source_Detail__c")).to eql insertedLeadInfo.fetch("Lead_Source_Detail__c")
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking assigned to on activity")
            @helper.addLogs("[Expected ] : Logged In User")#{@userInfo.fetch("display_name")}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Owner").fetch("Name")}")
            #expect(generatedActivityForLead.fetch("Owner").fetch("Name")).to eql @userInfo.fetch("display_name")
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking status on activity")
            @helper.addLogs("[Expected ] : Open")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Status")}")
            expect(generatedActivityForLead.fetch("Status")).to eql "Open"
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Company__c on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Company')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Company__c")}")
            expect(generatedActivityForLead.fetch("Company__c")).to eql insertedLeadInfo.fetch('Company')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Location interested on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Locations_Interested__c')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Locations_Interested__c")}")
            expect(generatedActivityForLead.fetch("Locations_Interested__c")).to eql insertedLeadInfo.fetch('Locations_Interested__c')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Location interested on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Number_of_Full_Time_Employees__c')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Number_of_Full_Time_Employees__c")}")
            expect(generatedActivityForLead.fetch("Number_of_Full_Time_Employees__c")).to eql insertedLeadInfo.fetch('Number_of_Full_Time_Employees__c')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Number of desks on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Interested_in_Number_of_Desks__c')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Interested_in_Number_of_Desks__c")}")
            expect(generatedActivityForLead.fetch("Interested_in_Number_of_Desks__c")).to eql insertedLeadInfo.fetch('Interested_in_Number_of_Desks__c')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Priority on activity")
            @helper.addLogs("[Expected ] : Normal")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Priority")}")
            expect(generatedActivityForLead.fetch("Priority")).to eql "Normal"
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Name on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Name')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Who").fetch('Name')}")
            expect(generatedActivityForLead.fetch("Who").fetch('Name')).to eql insertedLeadInfo.fetch('Name')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Email on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Email')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Email__c")}")
            expect(generatedActivityForLead.fetch("Email__c")).to eql insertedLeadInfo.fetch('Email')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Country_Code__c on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Country_Code__c')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Country_Code__c")}")
            expect(generatedActivityForLead.fetch("Country_Code__c")).to eql insertedLeadInfo.fetch('Country_Code__c')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Locale__c on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Locale__c')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Locale__c")}")
            expect(generatedActivityForLead.fetch("Locale__c")).to eql insertedLeadInfo.fetch('Locale__c')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Markets_Interested__c on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Markets_Interested__c')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Markets_Interested__c")}")
            expect(generatedActivityForLead.fetch("Markets_Interested__c")).to eql insertedLeadInfo.fetch('Markets_Interested__c')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Market__c on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Market__c')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Market__c")}")
            expect(generatedActivityForLead.fetch("Market__c")).to eql insertedLeadInfo.fetch('Market__c')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.postSuccessResult('2527')
        rescue Exception => e
            puts e
            @helper.postFailResult(e,'2527')
        end
    end

    it "C:2541 To check lead is assigned to proper 'Queue' from lead assignment rule for 'Consumer' record type and journey,activity should be created for that lead.", :'2541' => 'true' do
        begin
            @helper.addLogs("C:2527 To check lead is assigned to proper 'Queue' from lead assignment rule for 'Consumer' record type and journey,activity should be created for that lead.",'2541')
            @testDataJSON['Lead'][0]['RecordType'] = 'Consumer'
            @testDataJSON['Lead'][0]['Email'] = @testDataJSON['Lead'][0]['LastName'] + SecureRandom.random_number(10000000000).to_s + "@test.com"
            @testDataJSON['Lead'][0]['leadSource'] = 'Event'
            @testDataJSON['Lead'][0]['lead_Source_Detail__c'] = 'Global Contact CTA'
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
            @testDataJSON['Lead'][0]['Number of Full Time Employees'] = '55'
            @testDataJSON['Lead'][0]['Locations Interested'] = "AMS-Labs;AMS-Strawinskylaan"
            @testDataJSON['Lead'][0]['Referrer'] = 'john snow_QaAuto_121'
            @testDataJSON['Lead'][0]['Referrer Name'] = 'John'
            @testDataJSON['Lead'][0]['Referrer Email'] = 'abc@example.com'
            @testDataJSON['Lead'][0]['Assign using active assignment rule'] = true
            @testDataJSON['Lead'][0]['Promo Code'] = "123123"

            expectedOwner  = '00GF0000007vuoIMAQ'

            @helper.addLogs("[Step ]     : Fetch building deatails")            
            building = @objLeadGeneration.fetchBuildingDetails(@testDataJSON['Lead'][0]['Building Interested In'])
            expect(building).to_not eq nil
            expect(building.size).to eq 1
            expect(building[0]).to_not eq nil      
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Login to salesforce")
            @objLeadGeneration.loginToSalesforce
            
            @helper.addLogs("[Step ]     : Create Lead record with consumer record type")
            @objLeadGeneration.createLeadStdsalesforce
            @helper.addLogs("[Validate ] : Checking Lead is created after form submission")
            @helper.addLogs("[Expected ] : Lead should create with name #{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
            
            @helper.addLogs("[Step ]     : Fetch lead deatails")            
            insertedLeadInfo = @objLeadGeneration.fetchLeadDetails(@testDataJSON['Lead'][0]['Email'])
            expect(insertedLeadInfo).to_not eq nil
            expect(insertedLeadInfo.size).to eq 1
            expect(insertedLeadInfo[0]).to_not eq nil  
            insertedLeadInfo =  insertedLeadInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead name")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Name")}")            
            expect(insertedLeadInfo.fetch("Name")).to match("#{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
            @helper.addLogs("[Result ]   : Success\n")

            recordType = @objLeadGeneration.getRecordType(@testDataJSON['Lead'][0]['Number of Full Time Employees'].to_i)

            @helper.addLogs("[Validate ] : Checking Lead owner should be According to Lead Assignment Rule")
            @helper.addLogs("[Expected ] : #{expectedOwner}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Owner").fetch("Id")}")            
            expect(insertedLeadInfo.fetch("Owner").fetch("Id")).to match("#{expectedOwner}")
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Organization")
            @helper.addLogs("[Expected ] : 0011g00000CIkegAAD")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Account__c")}")
            expect(insertedLeadInfo.fetch("Account__c")).to match("0011g00000CIkegAAD")
            @helper.addLogs("[Result ]   : Success\n")
            
            @helper.addLogs("[Validate ] : Checking Lead Market")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Market']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Market__c")}")
            expect(insertedLeadInfo.fetch("Market__c")).to eql @testDataJSON['Lead'][0]['Market']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Generate_Journey__c")
            @helper.addLogs("[Expected ] : #{!@testDataJSON['Lead'][0]['Generate Journey']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Generate_Journey__c")}")
            expect(insertedLeadInfo.fetch("Generate_Journey__c")).to eql true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Has_Active_Journey__c")
            @helper.addLogs("[Expected ] : true")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Has_Active_Journey__c")}")
            expect(insertedLeadInfo.fetch("Has_Active_Journey__c")).to eql true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Markets_Interested__c")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Markets Interested']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Markets_Interested__c")}")
            expect(insertedLeadInfo.fetch("Markets_Interested__c")).to eql @testDataJSON['Lead'][0]['Markets Interested']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Referrer__c")
            @helper.addLogs("[Expected ] : 0031g000008ROtsAAG")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Referrer__c")}")
            expect(insertedLeadInfo.fetch("Referrer__c")).to eql "0031g000008ROtsAAG"
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Referral_Company_Name__c")
            @helper.addLogs("[Expected ] : john.snow_Org_qaauto12121212")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Referral_Company_Name__c")}")
            expect(insertedLeadInfo.fetch("Referral_Company_Name__c")).to eql "john.snow_Org_qaauto12121212"
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Referrer_Name__c")
            @helper.addLogs("[Expected ] : John")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Referrer_Name__c")}")
            expect(insertedLeadInfo.fetch("Referrer_Name__c")).to eql "John"
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Referrer_Email__c")
            @helper.addLogs("[Expected ] : abc@example.com")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Referrer_Email__c")}")
            expect(insertedLeadInfo.fetch("Referrer_Email__c")).to eql "abc@example.com"
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

            @helper.addLogs("[Validate ] : Checking building interested name on Lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Building Interested In']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Building_Interested_Name__c")}")
            expect(insertedLeadInfo.fetch("Building_Interested_Name__c")).to eql @testDataJSON['Lead'][0]['Building Interested In']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking building interested In")
            @helper.addLogs("[Expected ] : #{building[0].fetch("Id")}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Building_Interested_In__c")}")
            expect(insertedLeadInfo.fetch("Building_Interested_In__c")).to eql building[0].fetch("Id")
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Journey created date on lead")
            @helper.addLogs("[Expected ] : #{Date.today}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Journey_Created_On__c")}")
            expect(insertedLeadInfo.fetch("Journey_Created_On__c")).to eql Date.today.to_s
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Interested in Number of Desks on lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Interested in Number of Desk(s)']}.0")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch('Interested_in_Number_of_Desks__c')}")
            expect(insertedLeadInfo.fetch("Interested_in_Number_of_Desks__c").to_i).to eql "#{@testDataJSON['Lead'][0]['Interested in Number of Desk(s)']}.0".to_i
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Locations Interested on lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Locations Interested']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Locations_Interested__c")}")
            expect(insertedLeadInfo.fetch("Locations_Interested__c")).to eql @testDataJSON['Lead'][0]['Locations Interested']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Number of Full Time Employees on lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Number of Full Time Employees']}.0")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Number_of_Full_Time_Employees__c")}")
            expect(insertedLeadInfo.fetch("Number_of_Full_Time_Employees__c").to_i).to eql "#{@testDataJSON['Lead'][0]['Number of Full Time Employees']}.0".to_i
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Email on lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Email']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Email")}")
            expect(insertedLeadInfo.fetch("Email")).to eql @testDataJSON['Lead'][0]['Email']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Phone on lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Phone']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Phone")}")
            expect(insertedLeadInfo.fetch("Phone")).to eql "(888) 888-8888"
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Company on lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Company']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Company")}")
            expect(insertedLeadInfo.fetch("Company")).to eql @testDataJSON['Lead'][0]['Company']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking RecordType on lead")
            @helper.addLogs("[Expected ] : #{recordType}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("RecordType").fetch("Name")}")
            expect(insertedLeadInfo.fetch("RecordType").fetch("Name")).to eql recordType
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

            @helper.addLogs("[Validate ] : Checking Email_Opt_out on lead")
            @helper.addLogs("[Expected ] : true")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("HasOptedOutOfEmail")}")
            expect(insertedLeadInfo.fetch("HasOptedOutOfEmail")).to eql true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Promo code on lead")
            @helper.addLogs("[Expected ] : @testDataJSON['Lead'][0]['Promo Code']")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Promo_Code__c")}")
            expect(insertedLeadInfo.fetch("Promo_Code__c")).to eql @testDataJSON['Lead'][0]['Promo Code']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Move in Time frame on lead")
            @helper.addLogs("[Expected ] : @testDataJSON['Lead'][0]['Move In Time Frame']")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Move_In_Time_Frame__c")}")
            expect(insertedLeadInfo.fetch("Move_In_Time_Frame__c")).to eql @testDataJSON['Lead'][0]['Move In Time Frame']
            @helper.addLogs("[Result ]   : Success\n")            

            @helper.addLogs("[Step ]     : Checking for journey should created or Not")
            generateJourneyPermissin = @objLeadGeneration.isGenerateJourney(insertedLeadInfo.fetch("Owner").fetch("Id"),insertedLeadInfo.fetch("LeadSource"),insertedLeadInfo.fetch("Lead_Source_Detail__c"),insertedLeadInfo.fetch("Generate_Journey__c"))
           

            if generateJourneyPermissin then
                puts "********************************************************"

                @helper.addLogs("[Step ]     : Fetch journey deatails")            
                insertedJourneyInfo = @objLeadGeneration.fetchJourneyDetails(insertedLeadInfo.fetch("Email"))
                expect(insertedJourneyInfo).to_not eq nil
                expect(insertedJourneyInfo.size).to eq 1
                expect(insertedJourneyInfo[0]).to_not eq nil  
                insertedJourneyInfo =  insertedJourneyInfo[0]      
                @helper.addLogs("[Result ]   : Success\n")

                @helper.addLogs("[Validate ] : Checking Journey Name")
                @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
                @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Name")}")
                expect(insertedJourneyInfo).to_not eql nil
                expect(insertedJourneyInfo.fetch("Name")).to match("#{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
                @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking Journey owner")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Owner").fetch("Name")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Owner").fetch("Name")}")
                 expect(insertedJourneyInfo.fetch("Owner").fetch("Id")).to eql insertedLeadInfo.fetch("Owner").fetch("Id")
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

                 @helper.addLogs("[Validate ] : Checking building interested In on Journey")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Building_Interested_In__c")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Building_Interested_In__c")}")
                 expect(insertedJourneyInfo.fetch("Building_Interested_In__c")).to eql insertedLeadInfo.fetch("Building_Interested_In__c")
                 @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking NMD Next Contact Date on Journey")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Journey_Created_On__c")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")}")
                 expect(insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")).to eql insertedLeadInfo.fetch("Journey_Created_On__c")
                 @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking Interested in Number of Desks on Journey")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Interested_in_Number_of_Desks__c")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Interested_in_Number_of_Desks__c")}")
                 expect(insertedJourneyInfo.fetch("Interested_in_Number_of_Desks__c")).to eql insertedLeadInfo.fetch("Interested_in_Number_of_Desks__c")
                 @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking Locations Interested on Journey")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Locations_Interested__c")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Locations_Interested__c")}")
                 expect(insertedJourneyInfo.fetch("Locations_Interested__c")).to eql insertedLeadInfo.fetch("Locations_Interested__c")
                 @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking Number of Full Time Employees on Journey")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Number_of_Full_Time_Employees__c")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Full_Time_Employees__c")}")
                 expect(insertedJourneyInfo.fetch("Full_Time_Employees__c")).to eql insertedLeadInfo.fetch("Number_of_Full_Time_Employees__c")
                 @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking Email on Journey")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Email")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Primary_Email__c")}")
                 expect(insertedJourneyInfo.fetch("Primary_Email__c")).to eql insertedLeadInfo.fetch("Email")
                 @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking Phone on Journey")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Phone")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Primary_Phone__c")}")
                 expect(insertedJourneyInfo.fetch("Primary_Phone__c")).to eql "(888) 888-8888"
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

                 @helper.addLogs("[Validate ] : Checking Journey Market")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Market__c")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Market__c")}")
                 expect(insertedJourneyInfo.fetch("Market__c")).to eql insertedLeadInfo.fetch("Market__c")
                 @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking Journey Next Contact Date")
                 @helper.addLogs("[Expected ] : Started")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")}")
                 #expect(insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")).to eql "Started"
                 @helper.addLogs("[Result ]   : Success\n")

                @helper.addLogs("[Validate ] : Checking Journey Markets_Interested__c")
                @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Markets_Interested__c")}")
                @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Markets_Interested__c")}")
                expect(insertedLeadInfo.fetch("Markets_Interested__c")).to eql insertedLeadInfo.fetch("Markets_Interested__c")
                @helper.addLogs("[Result ]   : Success\n")

            else
                expect(insertedJourneyInfo).to eql nil
            end
            puts "********************************************************"

            @helper.addLogs("[Step ]     : Fetch Activity deatails")            
            generatedActivityForLead = @objLeadGeneration.fetchActivityDetails(insertedLeadInfo.fetch("Id"))
            expect(generatedActivityForLead).to_not eq nil
            expect(generatedActivityForLead.size).to eq 1
            expect(generatedActivityForLead[0]).to_not eq nil  
            generatedActivityForLead =  generatedActivityForLead[0]      
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Subject on acitivity")
            @helper.addLogs("[Expected ] : Inbound Lead submission")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Subject")}")
            expect(generatedActivityForLead.fetch("Subject")).to eql "Inbound Lead submission"
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking lead source on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("LeadSource")}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Lead_Source__c")}")
            expect(generatedActivityForLead.fetch("Lead_Source__c")).to eql insertedLeadInfo.fetch("LeadSource")
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking lead source detail on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Lead_Source_Detail__c")}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Lead_Source_Detail__c")}")
            expect(generatedActivityForLead.fetch("Lead_Source_Detail__c")).to eql insertedLeadInfo.fetch("Lead_Source_Detail__c")
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking assigned to on activity")
            @helper.addLogs("[Expected ] : Logged In User")#{@userInfo.fetch("display_name")}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Owner").fetch("Name")}")
            #expect(generatedActivityForLead.fetch("Owner").fetch("Name")).to eql @userInfo.fetch("display_name")
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking status on activity")
            @helper.addLogs("[Expected ] : Open")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Status")}")
            expect(generatedActivityForLead.fetch("Status")).to eql "Open"
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Company__c on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Company')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Company__c")}")
            expect(generatedActivityForLead.fetch("Company__c")).to eql insertedLeadInfo.fetch('Company')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Location interested on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Locations_Interested__c')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Locations_Interested__c")}")
            expect(generatedActivityForLead.fetch("Locations_Interested__c")).to eql insertedLeadInfo.fetch('Locations_Interested__c')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Location interested on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Number_of_Full_Time_Employees__c')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Number_of_Full_Time_Employees__c")}")
            expect(generatedActivityForLead.fetch("Number_of_Full_Time_Employees__c")).to eql insertedLeadInfo.fetch('Number_of_Full_Time_Employees__c')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Number of desks on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Interested_in_Number_of_Desks__c')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Interested_in_Number_of_Desks__c")}")
            expect(generatedActivityForLead.fetch("Interested_in_Number_of_Desks__c")).to eql insertedLeadInfo.fetch('Interested_in_Number_of_Desks__c')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Priority on activity")
            @helper.addLogs("[Expected ] : Normal")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Priority")}")
            expect(generatedActivityForLead.fetch("Priority")).to eql "Normal"
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Name on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Name')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Who").fetch('Name')}")
            expect(generatedActivityForLead.fetch("Who").fetch('Name')).to eql insertedLeadInfo.fetch('Name')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Email on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Email')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Email__c")}")
            expect(generatedActivityForLead.fetch("Email__c")).to eql insertedLeadInfo.fetch('Email')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Country_Code__c on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Country_Code__c')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Country_Code__c")}")
            expect(generatedActivityForLead.fetch("Country_Code__c")).to eql insertedLeadInfo.fetch('Country_Code__c')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Locale__c on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Locale__c')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Locale__c")}")
            expect(generatedActivityForLead.fetch("Locale__c")).to eql insertedLeadInfo.fetch('Locale__c')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Markets_Interested__c on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Markets_Interested__c')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Markets_Interested__c")}")
            expect(generatedActivityForLead.fetch("Markets_Interested__c")).to eql insertedLeadInfo.fetch('Markets_Interested__c')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Market__c on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Market__c')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Market__c")}")
            expect(generatedActivityForLead.fetch("Market__c")).to eql insertedLeadInfo.fetch('Market__c')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.postSuccessResult('2541')
        rescue Exception => e
            puts e
            @helper.postFailResult(e,'2541')
        end
    end

    it "C:2542 To check lead is assigned to proper 'Queue' from lead assignment rule for 'Enterprise Solution' record type and journey,activity should be created for that lead.", :'2542' => 'true' do
        begin
            @helper.addLogs("C:2542 To check lead is assigned to proper 'Queue' from lead assignment rule for 'Enterprise Solution' record type and journey,activity should be created for that lead.",'2542')
            @testDataJSON['Lead'][0]['RecordType'] = 'Consumer'
            @testDataJSON['Lead'][0]['Email'] = @testDataJSON['Lead'][0]['LastName'] + SecureRandom.random_number(10000000000).to_s + "@test.com"
            @testDataJSON['Lead'][0]['leadSource'] = 'Event'
            @testDataJSON['Lead'][0]['lead_Source_Detail__c'] = 'Global Contact CTA'
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
            @testDataJSON['Lead'][0]['Number of Full Time Employees'] = '1550'
            @testDataJSON['Lead'][0]['Locations Interested'] = "AMS-Labs;AMS-Strawinskylaan"
            @testDataJSON['Lead'][0]['Referrer'] = 'john snow_QaAuto_121'
            @testDataJSON['Lead'][0]['Referrer Name'] = 'John'
            @testDataJSON['Lead'][0]['Referrer Email'] = 'abc@example.com'
            @testDataJSON['Lead'][0]['Assign using active assignment rule'] = true
            @testDataJSON['Lead'][0]['Promo Code'] = "123123"

            expectedOwner  = '00GF0000007vuoIMAQ'

            @helper.addLogs("[Step ]     : Fetch building deatails")            
            building = @objLeadGeneration.fetchBuildingDetails(@testDataJSON['Lead'][0]['Building Interested In'])
            expect(building).to_not eq nil
            expect(building.size).to eq 1
            expect(building[0]).to_not eq nil      
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Login to salesforce")
            @objLeadGeneration.loginToSalesforce
            
            @helper.addLogs("[Step ]     : Create Lead record with consumer record type")
            @objLeadGeneration.createLeadStdsalesforce
            @helper.addLogs("[Validate ] : Checking Lead is created after form submission")
            @helper.addLogs("[Expected ] : Lead should create with name #{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
            
            @helper.addLogs("[Step ]     : Fetch lead deatails")            
            insertedLeadInfo = @objLeadGeneration.fetchLeadDetails(@testDataJSON['Lead'][0]['Email'])
            expect(insertedLeadInfo).to_not eq nil
            expect(insertedLeadInfo.size).to eq 1
            expect(insertedLeadInfo[0]).to_not eq nil  
            insertedLeadInfo =  insertedLeadInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead name")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Name")}")            
            expect(insertedLeadInfo.fetch("Name")).to match("#{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
            @helper.addLogs("[Result ]   : Success\n")

            recordType = @objLeadGeneration.getRecordType(@testDataJSON['Lead'][0]['Number of Full Time Employees'].to_i)

            @helper.addLogs("[Validate ] : Checking Lead owner should be According to Lead Assignment Rule")
            @helper.addLogs("[Expected ] : #{expectedOwner}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Owner").fetch("Id")}")            
            expect(insertedLeadInfo.fetch("Owner").fetch("Id")).to match("#{expectedOwner}")
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Organization")
            @helper.addLogs("[Expected ] : 0011g00000CIkegAAD")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Account__c")}")
            expect(insertedLeadInfo.fetch("Account__c")).to match("0011g00000CIkegAAD")
            @helper.addLogs("[Result ]   : Success\n")
            
            @helper.addLogs("[Validate ] : Checking Lead Market")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Market']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Market__c")}")
            expect(insertedLeadInfo.fetch("Market__c")).to eql @testDataJSON['Lead'][0]['Market']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Generate_Journey__c")
            @helper.addLogs("[Expected ] : #{!@testDataJSON['Lead'][0]['Generate Journey']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Generate_Journey__c")}")
            expect(insertedLeadInfo.fetch("Generate_Journey__c")).to eql true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Has_Active_Journey__c")
            @helper.addLogs("[Expected ] : true")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Has_Active_Journey__c")}")
            expect(insertedLeadInfo.fetch("Has_Active_Journey__c")).to eql true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Markets_Interested__c")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Markets Interested']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Markets_Interested__c")}")
            expect(insertedLeadInfo.fetch("Markets_Interested__c")).to eql @testDataJSON['Lead'][0]['Markets Interested']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Referrer__c")
            @helper.addLogs("[Expected ] : 0031g000008ROtsAAG")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Referrer__c")}")
            expect(insertedLeadInfo.fetch("Referrer__c")).to eql "0031g000008ROtsAAG"
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Referral_Company_Name__c")
            @helper.addLogs("[Expected ] : john.snow_Org_qaauto12121212")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Referral_Company_Name__c")}")
            expect(insertedLeadInfo.fetch("Referral_Company_Name__c")).to eql "john.snow_Org_qaauto12121212"
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Referrer_Name__c")
            @helper.addLogs("[Expected ] : John")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Referrer_Name__c")}")
            expect(insertedLeadInfo.fetch("Referrer_Name__c")).to eql "John"
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Referrer_Email__c")
            @helper.addLogs("[Expected ] : abc@example.com")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Referrer_Email__c")}")
            expect(insertedLeadInfo.fetch("Referrer_Email__c")).to eql "abc@example.com"
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

            @helper.addLogs("[Validate ] : Checking building interested name on Lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Building Interested In']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Building_Interested_Name__c")}")
            expect(insertedLeadInfo.fetch("Building_Interested_Name__c")).to eql @testDataJSON['Lead'][0]['Building Interested In']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking building interested In")
            @helper.addLogs("[Expected ] : #{building[0].fetch("Id")}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Building_Interested_In__c")}")
            expect(insertedLeadInfo.fetch("Building_Interested_In__c")).to eql building[0].fetch("Id")
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Journey created date on lead")
            @helper.addLogs("[Expected ] : #{Date.today}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Journey_Created_On__c")}")
            expect(insertedLeadInfo.fetch("Journey_Created_On__c")).to eql Date.today.to_s
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Interested in Number of Desks on lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Interested in Number of Desk(s)']}.0")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch('Interested_in_Number_of_Desks__c')}")
            expect(insertedLeadInfo.fetch("Interested_in_Number_of_Desks__c").to_i).to eql "#{@testDataJSON['Lead'][0]['Interested in Number of Desk(s)']}.0".to_i
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Locations Interested on lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Locations Interested']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Locations_Interested__c")}")
            expect(insertedLeadInfo.fetch("Locations_Interested__c")).to eql @testDataJSON['Lead'][0]['Locations Interested']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Number of Full Time Employees on lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Number of Full Time Employees']}.0")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Number_of_Full_Time_Employees__c")}")
            expect(insertedLeadInfo.fetch("Number_of_Full_Time_Employees__c").to_i).to eql "#{@testDataJSON['Lead'][0]['Number of Full Time Employees']}.0".to_i
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Email on lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Email']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Email")}")
            expect(insertedLeadInfo.fetch("Email")).to eql @testDataJSON['Lead'][0]['Email']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Phone on lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Phone']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Phone")}")
            expect(insertedLeadInfo.fetch("Phone")).to eql "(888) 888-8888"
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Company on lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Company']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Company")}")
            expect(insertedLeadInfo.fetch("Company")).to eql @testDataJSON['Lead'][0]['Company']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking RecordType on lead")
            @helper.addLogs("[Expected ] : #{recordType}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("RecordType").fetch("Name")}")
            expect(insertedLeadInfo.fetch("RecordType").fetch("Name")).to eql recordType
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

            @helper.addLogs("[Validate ] : Checking Email_Opt_out on lead")
            @helper.addLogs("[Expected ] : true")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("HasOptedOutOfEmail")}")
            expect(insertedLeadInfo.fetch("HasOptedOutOfEmail")).to eql true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Promo code on lead")
            @helper.addLogs("[Expected ] : @testDataJSON['Lead'][0]['Promo Code']")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Promo_Code__c")}")
            expect(insertedLeadInfo.fetch("Promo_Code__c")).to eql @testDataJSON['Lead'][0]['Promo Code']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Move in Time frame on lead")
            @helper.addLogs("[Expected ] : @testDataJSON['Lead'][0]['Move In Time Frame']")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Move_In_Time_Frame__c")}")
            expect(insertedLeadInfo.fetch("Move_In_Time_Frame__c")).to eql @testDataJSON['Lead'][0]['Move In Time Frame']
            @helper.addLogs("[Result ]   : Success\n")            

            @helper.addLogs("[Step ]     : Checking for journey should created or Not")
            generateJourneyPermissin = @objLeadGeneration.isGenerateJourney(insertedLeadInfo.fetch("Owner").fetch("Id"),insertedLeadInfo.fetch("LeadSource"),insertedLeadInfo.fetch("Lead_Source_Detail__c"),insertedLeadInfo.fetch("Generate_Journey__c"))
           

            if generateJourneyPermissin then
                puts "********************************************************"

                @helper.addLogs("[Step ]     : Fetch journey deatails")            
                insertedJourneyInfo = @objLeadGeneration.fetchJourneyDetails(insertedLeadInfo.fetch("Email"))
                expect(insertedJourneyInfo).to_not eq nil
                expect(insertedJourneyInfo.size).to eq 1
                expect(insertedJourneyInfo[0]).to_not eq nil  
                insertedJourneyInfo =  insertedJourneyInfo[0]      
                @helper.addLogs("[Result ]   : Success\n")

                @helper.addLogs("[Validate ] : Checking Journey Name")
                @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
                @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Name")}")
                expect(insertedJourneyInfo).to_not eql nil
                expect(insertedJourneyInfo.fetch("Name")).to match("#{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
                @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking Journey owner")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Owner").fetch("Name")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Owner").fetch("Name")}")
                 expect(insertedJourneyInfo.fetch("Owner").fetch("Id")).to eql insertedLeadInfo.fetch("Owner").fetch("Id")
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

                 @helper.addLogs("[Validate ] : Checking building interested In on Journey")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Building_Interested_In__c")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Building_Interested_In__c")}")
                 expect(insertedJourneyInfo.fetch("Building_Interested_In__c")).to eql insertedLeadInfo.fetch("Building_Interested_In__c")
                 @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking NMD Next Contact Date on Journey")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Journey_Created_On__c")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")}")
                 expect(insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")).to eql insertedLeadInfo.fetch("Journey_Created_On__c")
                 @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking Interested in Number of Desks on Journey")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Interested_in_Number_of_Desks__c")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Interested_in_Number_of_Desks__c")}")
                 expect(insertedJourneyInfo.fetch("Interested_in_Number_of_Desks__c")).to eql insertedLeadInfo.fetch("Interested_in_Number_of_Desks__c")
                 @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking Locations Interested on Journey")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Locations_Interested__c")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Locations_Interested__c")}")
                 expect(insertedJourneyInfo.fetch("Locations_Interested__c")).to eql insertedLeadInfo.fetch("Locations_Interested__c")
                 @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking Number of Full Time Employees on Journey")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Number_of_Full_Time_Employees__c")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Full_Time_Employees__c")}")
                 expect(insertedJourneyInfo.fetch("Full_Time_Employees__c")).to eql insertedLeadInfo.fetch("Number_of_Full_Time_Employees__c")
                 @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking Email on Journey")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Email")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Primary_Email__c")}")
                 expect(insertedJourneyInfo.fetch("Primary_Email__c")).to eql insertedLeadInfo.fetch("Email")
                 @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking Phone on Journey")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Phone")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Primary_Phone__c")}")
                 expect(insertedJourneyInfo.fetch("Primary_Phone__c")).to eql "(888) 888-8888"
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

                 @helper.addLogs("[Validate ] : Checking Journey Market")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Market__c")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Market__c")}")
                 expect(insertedJourneyInfo.fetch("Market__c")).to eql insertedLeadInfo.fetch("Market__c")
                 @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking Journey Next Contact Date")
                 @helper.addLogs("[Expected ] : Started")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")}")
                 #expect(insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")).to eql "Started"
                 @helper.addLogs("[Result ]   : Success\n")

                @helper.addLogs("[Validate ] : Checking Journey Markets_Interested__c")
                @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Markets_Interested__c")}")
                @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Markets_Interested__c")}")
                expect(insertedLeadInfo.fetch("Markets_Interested__c")).to eql insertedLeadInfo.fetch("Markets_Interested__c")
                @helper.addLogs("[Result ]   : Success\n")

            else
                expect(insertedJourneyInfo).to eql nil
            end
            puts "********************************************************"

            @helper.addLogs("[Step ]     : Fetch Activity deatails")            
            generatedActivityForLead = @objLeadGeneration.fetchActivityDetails(insertedLeadInfo.fetch("Id"))
            expect(generatedActivityForLead).to_not eq nil
            expect(generatedActivityForLead.size).to eq 1
            expect(generatedActivityForLead[0]).to_not eq nil  
            generatedActivityForLead =  generatedActivityForLead[0]      
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Subject on acitivity")
            @helper.addLogs("[Expected ] : Inbound Lead submission")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Subject")}")
            expect(generatedActivityForLead.fetch("Subject")).to eql "Inbound Lead submission"
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking lead source on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("LeadSource")}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Lead_Source__c")}")
            expect(generatedActivityForLead.fetch("Lead_Source__c")).to eql insertedLeadInfo.fetch("LeadSource")
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking lead source detail on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Lead_Source_Detail__c")}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Lead_Source_Detail__c")}")
            expect(generatedActivityForLead.fetch("Lead_Source_Detail__c")).to eql insertedLeadInfo.fetch("Lead_Source_Detail__c")
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking assigned to on activity")
            @helper.addLogs("[Expected ] : Logged In User")#{@userInfo.fetch("display_name")}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Owner").fetch("Name")}")
            #expect(generatedActivityForLead.fetch("Owner").fetch("Name")).to eql @userInfo.fetch("display_name")
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking status on activity")
            @helper.addLogs("[Expected ] : Open")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Status")}")
            expect(generatedActivityForLead.fetch("Status")).to eql "Open"
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Company__c on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Company')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Company__c")}")
            expect(generatedActivityForLead.fetch("Company__c")).to eql insertedLeadInfo.fetch('Company')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Location interested on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Locations_Interested__c')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Locations_Interested__c")}")
            expect(generatedActivityForLead.fetch("Locations_Interested__c")).to eql insertedLeadInfo.fetch('Locations_Interested__c')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Location interested on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Number_of_Full_Time_Employees__c')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Number_of_Full_Time_Employees__c")}")
            expect(generatedActivityForLead.fetch("Number_of_Full_Time_Employees__c")).to eql insertedLeadInfo.fetch('Number_of_Full_Time_Employees__c')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Number of desks on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Interested_in_Number_of_Desks__c')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Interested_in_Number_of_Desks__c")}")
            expect(generatedActivityForLead.fetch("Interested_in_Number_of_Desks__c")).to eql insertedLeadInfo.fetch('Interested_in_Number_of_Desks__c')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Priority on activity")
            @helper.addLogs("[Expected ] : Normal")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Priority")}")
            expect(generatedActivityForLead.fetch("Priority")).to eql "Normal"
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Name on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Name')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Who").fetch('Name')}")
            expect(generatedActivityForLead.fetch("Who").fetch('Name')).to eql insertedLeadInfo.fetch('Name')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Email on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Email')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Email__c")}")
            expect(generatedActivityForLead.fetch("Email__c")).to eql insertedLeadInfo.fetch('Email')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Country_Code__c on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Country_Code__c')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Country_Code__c")}")
            expect(generatedActivityForLead.fetch("Country_Code__c")).to eql insertedLeadInfo.fetch('Country_Code__c')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Locale__c on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Locale__c')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Locale__c")}")
            expect(generatedActivityForLead.fetch("Locale__c")).to eql insertedLeadInfo.fetch('Locale__c')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Markets_Interested__c on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Markets_Interested__c')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Markets_Interested__c")}")
            expect(generatedActivityForLead.fetch("Markets_Interested__c")).to eql insertedLeadInfo.fetch('Markets_Interested__c')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Market__c on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Market__c')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Market__c")}")
            expect(generatedActivityForLead.fetch("Market__c")).to eql insertedLeadInfo.fetch('Market__c')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.postSuccessResult('2542')
        rescue Exception => e
            puts e
            @helper.postFailResult(e,'2542')
        end
    end

    it "C:2538 To check lead is assigned to 'Logged In user' for record type 'Consumer' and journey,activity should be created for that lead.", :'2538' => 'true' do
        begin
            @helper.addLogs("C:2538 To check lead is assigned to 'Logged In user' for record type 'Consumer' and journey,activity should be created for that lead.",'2538')
            @testDataJSON['Lead'][0]['RecordType'] = 'Consumer'
            @testDataJSON['Lead'][0]['Email'] = @testDataJSON['Lead'][0]['LastName'] + SecureRandom.random_number(10000000000).to_s + "@test.com"
            @testDataJSON['Lead'][0]['leadSource'] = 'Outbound Email/Cold Call'
            @testDataJSON['Lead'][0]['lead_Source_Detail__c'] = ''
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

            expectedOwner  = '0051g000000tWpP'

            @helper.addLogs("[Step ]     : Fetch building deatails")            
            building = @objLeadGeneration.fetchBuildingDetails(@testDataJSON['Lead'][0]['Building Interested In'])
            expect(building).to_not eq nil
            expect(building.size).to eq 1
            expect(building[0]).to_not eq nil      
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Login to salesforce")
            @objLeadGeneration.loginToSalesforce
            
            @helper.addLogs("[Step ]     : Create Lead record with consumer record type")
            @objLeadGeneration.createLeadStdsalesforce
            @helper.addLogs("[Validate ] : Checking Lead is created after form submission")
            @helper.addLogs("[Expected ] : Lead should create with name #{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
            
            @helper.addLogs("[Step ]     : Fetch lead deatails")            
            insertedLeadInfo = @objLeadGeneration.fetchLeadDetails(@testDataJSON['Lead'][0]['Email'])
            expect(insertedLeadInfo).to_not eq nil
            expect(insertedLeadInfo.size).to eq 1
            expect(insertedLeadInfo[0]).to_not eq nil  
            insertedLeadInfo =  insertedLeadInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead name")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Name")}")            
            expect(insertedLeadInfo.fetch("Name")).to match("#{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
            @helper.addLogs("[Result ]   : Success\n")

            recordType = @objLeadGeneration.getRecordType(@testDataJSON['Lead'][0]['Number of Full Time Employees'].to_i)

            @helper.addLogs("[Validate ] : Checking Lead owner should be According to Lead Assignment Rule")
            @helper.addLogs("[Expected ] : #{expectedOwner}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Owner").fetch("Id")}")            
            expect(insertedLeadInfo.fetch("Owner").fetch("Id")).to match("#{expectedOwner}")
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Organization")
            @helper.addLogs("[Expected ] : 0011g00000CIkegAAD")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Account__c")}")
            expect(insertedLeadInfo.fetch("Account__c")).to match("0011g00000CIkegAAD")
            @helper.addLogs("[Result ]   : Success\n")
            
            @helper.addLogs("[Validate ] : Checking Lead Market")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Market']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Market__c")}")
            expect(insertedLeadInfo.fetch("Market__c")).to eql @testDataJSON['Lead'][0]['Market']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Generate_Journey__c")
            @helper.addLogs("[Expected ] : #{!@testDataJSON['Lead'][0]['Generate Journey']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Generate_Journey__c")}")
            expect(insertedLeadInfo.fetch("Generate_Journey__c")).to eql true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Has_Active_Journey__c")
            @helper.addLogs("[Expected ] : true")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Has_Active_Journey__c")}")
            expect(insertedLeadInfo.fetch("Has_Active_Journey__c")).to eql true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Markets_Interested__c")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Markets Interested']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Markets_Interested__c")}")
            expect(insertedLeadInfo.fetch("Markets_Interested__c")).to eql @testDataJSON['Lead'][0]['Markets Interested']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Referrer__c")
            @helper.addLogs("[Expected ] : 0031g000008ROtsAAG")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Referrer__c")}")
            expect(insertedLeadInfo.fetch("Referrer__c")).to eql "0031g000008ROtsAAG"
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Referral_Company_Name__c")
            @helper.addLogs("[Expected ] : john.snow_Org_qaauto12121212")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Referral_Company_Name__c")}")
            expect(insertedLeadInfo.fetch("Referral_Company_Name__c")).to eql "john.snow_Org_qaauto12121212"
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Referrer_Name__c")
            @helper.addLogs("[Expected ] : John")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Referrer_Name__c")}")
            expect(insertedLeadInfo.fetch("Referrer_Name__c")).to eql "John"
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Referrer_Email__c")
            @helper.addLogs("[Expected ] : abc@example.com")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Referrer_Email__c")}")
            expect(insertedLeadInfo.fetch("Referrer_Email__c")).to eql "abc@example.com"
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead source")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['leadSource']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("LeadSource")}")
            expect(insertedLeadInfo.fetch("LeadSource")).to eql @testDataJSON['Lead'][0]['leadSource']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead source details")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['lead_Source_Detail__c']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Lead_Source_Detail__c")}")
            expect(insertedLeadInfo.fetch("Lead_Source_Detail__c")).to eql nil
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking building interested name on Lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Building Interested In']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Building_Interested_Name__c")}")
            expect(insertedLeadInfo.fetch("Building_Interested_Name__c")).to eql @testDataJSON['Lead'][0]['Building Interested In']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking building interested In")
            @helper.addLogs("[Expected ] : #{building[0].fetch("Id")}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Building_Interested_In__c")}")
            expect(insertedLeadInfo.fetch("Building_Interested_In__c")).to eql building[0].fetch("Id")
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Journey created date on lead")
            @helper.addLogs("[Expected ] : #{Date.today}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Journey_Created_On__c")}")
            expect(insertedLeadInfo.fetch("Journey_Created_On__c")).to eql Date.today.to_s
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Interested in Number of Desks on lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Interested in Number of Desk(s)']}.0")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch('Interested_in_Number_of_Desks__c')}")
            expect(insertedLeadInfo.fetch("Interested_in_Number_of_Desks__c").to_i).to eql "#{@testDataJSON['Lead'][0]['Interested in Number of Desk(s)']}.0".to_i
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Locations Interested on lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Locations Interested']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Locations_Interested__c")}")
            expect(insertedLeadInfo.fetch("Locations_Interested__c")).to eql @testDataJSON['Lead'][0]['Locations Interested']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Number of Full Time Employees on lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Number of Full Time Employees']}.0")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Number_of_Full_Time_Employees__c")}")
            expect(insertedLeadInfo.fetch("Number_of_Full_Time_Employees__c").to_i).to eql "#{@testDataJSON['Lead'][0]['Number of Full Time Employees']}.0".to_i
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Email on lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Email']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Email")}")
            expect(insertedLeadInfo.fetch("Email")).to eql @testDataJSON['Lead'][0]['Email']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Phone on lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Phone']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Phone")}")
            expect(insertedLeadInfo.fetch("Phone")).to eql "(888) 888-8888"
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Company on lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Company']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Company")}")
            expect(insertedLeadInfo.fetch("Company")).to eql @testDataJSON['Lead'][0]['Company']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking RecordType on lead")
            @helper.addLogs("[Expected ] : #{recordType}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("RecordType").fetch("Name")}")
            expect(insertedLeadInfo.fetch("RecordType").fetch("Name")).to eql recordType
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

            @helper.addLogs("[Validate ] : Checking Email_Opt_out on lead")
            @helper.addLogs("[Expected ] : true")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("HasOptedOutOfEmail")}")
            expect(insertedLeadInfo.fetch("HasOptedOutOfEmail")).to eql true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Promo code on lead")
            @helper.addLogs("[Expected ] : @testDataJSON['Lead'][0]['Promo Code']")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Promo_Code__c")}")
            expect(insertedLeadInfo.fetch("Promo_Code__c")).to eql @testDataJSON['Lead'][0]['Promo Code']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Move in Time frame on lead")
            @helper.addLogs("[Expected ] : @testDataJSON['Lead'][0]['Move In Time Frame']")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Move_In_Time_Frame__c")}")
            expect(insertedLeadInfo.fetch("Move_In_Time_Frame__c")).to eql @testDataJSON['Lead'][0]['Move In Time Frame']
            @helper.addLogs("[Result ]   : Success\n")            

            @helper.addLogs("[Step ]     : Checking for journey should created or Not")
            generateJourneyPermissin = @objLeadGeneration.isGenerateJourney(insertedLeadInfo.fetch("Owner").fetch("Id"),insertedLeadInfo.fetch("LeadSource"),insertedLeadInfo.fetch("Lead_Source_Detail__c"),insertedLeadInfo.fetch("Generate_Journey__c"))
           

            if generateJourneyPermissin then
                puts "********************************************************"

                @helper.addLogs("[Step ]     : Fetch journey deatails")            
                insertedJourneyInfo = @objLeadGeneration.fetchJourneyDetails(insertedLeadInfo.fetch("Email"))
                expect(insertedJourneyInfo).to_not eq nil
                expect(insertedJourneyInfo.size).to eq 1
                expect(insertedJourneyInfo[0]).to_not eq nil  
                insertedJourneyInfo =  insertedJourneyInfo[0]      
                @helper.addLogs("[Result ]   : Success\n")

                @helper.addLogs("[Validate ] : Checking Journey Name")
                @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
                @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Name")}")
                expect(insertedJourneyInfo).to_not eql nil
                expect(insertedJourneyInfo.fetch("Name")).to match("#{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
                @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking Journey owner")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Owner").fetch("Name")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Owner").fetch("Name")}")
                 expect(insertedJourneyInfo.fetch("Owner").fetch("Id")).to eql insertedLeadInfo.fetch("Owner").fetch("Id")
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

                 @helper.addLogs("[Validate ] : Checking building interested In on Journey")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Building_Interested_In__c")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Building_Interested_In__c")}")
                 expect(insertedJourneyInfo.fetch("Building_Interested_In__c")).to eql insertedLeadInfo.fetch("Building_Interested_In__c")
                 @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking NMD Next Contact Date on Journey")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Journey_Created_On__c")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")}")
                 expect(insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")).to eql insertedLeadInfo.fetch("Journey_Created_On__c")
                 @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking Interested in Number of Desks on Journey")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Interested_in_Number_of_Desks__c")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Interested_in_Number_of_Desks__c")}")
                 expect(insertedJourneyInfo.fetch("Interested_in_Number_of_Desks__c")).to eql insertedLeadInfo.fetch("Interested_in_Number_of_Desks__c")
                 @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking Locations Interested on Journey")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Locations_Interested__c")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Locations_Interested__c")}")
                 expect(insertedJourneyInfo.fetch("Locations_Interested__c")).to eql insertedLeadInfo.fetch("Locations_Interested__c")
                 @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking Number of Full Time Employees on Journey")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Number_of_Full_Time_Employees__c")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Full_Time_Employees__c")}")
                 expect(insertedJourneyInfo.fetch("Full_Time_Employees__c")).to eql insertedLeadInfo.fetch("Number_of_Full_Time_Employees__c")
                 @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking Email on Journey")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Email")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Primary_Email__c")}")
                 expect(insertedJourneyInfo.fetch("Primary_Email__c")).to eql insertedLeadInfo.fetch("Email")
                 @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking Phone on Journey")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Phone")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Primary_Phone__c")}")
                 expect(insertedJourneyInfo.fetch("Primary_Phone__c")).to eql "(888) 888-8888"
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

                 @helper.addLogs("[Validate ] : Checking Journey Market")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Market__c")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Market__c")}")
                 expect(insertedJourneyInfo.fetch("Market__c")).to eql insertedLeadInfo.fetch("Market__c")
                 @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking Journey Next Contact Date")
                 @helper.addLogs("[Expected ] : Started")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")}")
                 #expect(insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")).to eql "Started"
                 @helper.addLogs("[Result ]   : Success\n")

                @helper.addLogs("[Validate ] : Checking Journey Markets_Interested__c")
                @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Markets_Interested__c")}")
                @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Markets_Interested__c")}")
                expect(insertedLeadInfo.fetch("Markets_Interested__c")).to eql insertedLeadInfo.fetch("Markets_Interested__c")
                @helper.addLogs("[Result ]   : Success\n")

            else
                expect(insertedJourneyInfo).to eql nil
            end
            puts "********************************************************"

            @helper.addLogs("[Step ]     : Fetch Activity deatails")            
            generatedActivityForLead = @objLeadGeneration.fetchActivityDetails(insertedLeadInfo.fetch("Id"))
            expect(generatedActivityForLead).to_not eq nil
            expect(generatedActivityForLead.size).to eq 1
            expect(generatedActivityForLead[0]).to_not eq nil  
            generatedActivityForLead =  generatedActivityForLead[0]      
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Subject on acitivity")
            @helper.addLogs("[Expected ] : Inbound Lead submission")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Subject")}")
            expect(generatedActivityForLead.fetch("Subject")).to eql "Inbound Lead submission"
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking lead source on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("LeadSource")}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Lead_Source__c")}")
            expect(generatedActivityForLead.fetch("Lead_Source__c")).to eql insertedLeadInfo.fetch("LeadSource")
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking lead source detail on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Lead_Source_Detail__c")}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Lead_Source_Detail__c")}")
            expect(generatedActivityForLead.fetch("Lead_Source_Detail__c")).to eql insertedLeadInfo.fetch("Lead_Source_Detail__c")
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking assigned to on activity")
            @helper.addLogs("[Expected ] : Logged In User")#{@userInfo.fetch("display_name")}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Owner").fetch("Name")}")
            #expect(generatedActivityForLead.fetch("Owner").fetch("Name")).to eql @userInfo.fetch("display_name")
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking status on activity")
            @helper.addLogs("[Expected ] : Open")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Status")}")
            expect(generatedActivityForLead.fetch("Status")).to eql "Open"
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Company__c on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Company')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Company__c")}")
            expect(generatedActivityForLead.fetch("Company__c")).to eql insertedLeadInfo.fetch('Company')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Location interested on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Locations_Interested__c')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Locations_Interested__c")}")
            expect(generatedActivityForLead.fetch("Locations_Interested__c")).to eql insertedLeadInfo.fetch('Locations_Interested__c')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Location interested on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Number_of_Full_Time_Employees__c')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Number_of_Full_Time_Employees__c")}")
            expect(generatedActivityForLead.fetch("Number_of_Full_Time_Employees__c")).to eql insertedLeadInfo.fetch('Number_of_Full_Time_Employees__c')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Number of desks on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Interested_in_Number_of_Desks__c')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Interested_in_Number_of_Desks__c")}")
            expect(generatedActivityForLead.fetch("Interested_in_Number_of_Desks__c")).to eql insertedLeadInfo.fetch('Interested_in_Number_of_Desks__c')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Priority on activity")
            @helper.addLogs("[Expected ] : Normal")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Priority")}")
            expect(generatedActivityForLead.fetch("Priority")).to eql "Normal"
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Name on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Name')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Who").fetch('Name')}")
            expect(generatedActivityForLead.fetch("Who").fetch('Name')).to eql insertedLeadInfo.fetch('Name')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Email on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Email')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Email__c")}")
            expect(generatedActivityForLead.fetch("Email__c")).to eql insertedLeadInfo.fetch('Email')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Country_Code__c on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Country_Code__c')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Country_Code__c")}")
            expect(generatedActivityForLead.fetch("Country_Code__c")).to eql insertedLeadInfo.fetch('Country_Code__c')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Locale__c on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Locale__c')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Locale__c")}")
            expect(generatedActivityForLead.fetch("Locale__c")).to eql insertedLeadInfo.fetch('Locale__c')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Markets_Interested__c on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Markets_Interested__c')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Markets_Interested__c")}")
            expect(generatedActivityForLead.fetch("Markets_Interested__c")).to eql insertedLeadInfo.fetch('Markets_Interested__c')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Market__c on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Market__c')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Market__c")}")
            expect(generatedActivityForLead.fetch("Market__c")).to eql insertedLeadInfo.fetch('Market__c')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.postSuccessResult('2538')
        rescue Exception => e
            puts e
            @helper.postFailResult(e,'2538')
        end
    end

    it "C:2544 To check lead is assigned to 'Logged In user' for record type 'Mid Market' and journey,activity should be created for that lead.", :'2544' => 'true' do
        begin
            @helper.addLogs("C:2544 To check lead is assigned to 'Logged In user' for record type 'Mid Market' and journey,activity should be created for that lead.",'2544')
            @testDataJSON['Lead'][0]['RecordType'] = 'Consumer'
            @testDataJSON['Lead'][0]['Email'] = @testDataJSON['Lead'][0]['LastName'] + SecureRandom.random_number(10000000000).to_s + "@test.com"
            @testDataJSON['Lead'][0]['leadSource'] = 'Outbound Email/Cold Call'
            @testDataJSON['Lead'][0]['lead_Source_Detail__c'] = ''
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
            @testDataJSON['Lead'][0]['Number of Full Time Employees'] = '55'
            @testDataJSON['Lead'][0]['Locations Interested'] = "AMS-Labs;AMS-Strawinskylaan"
            @testDataJSON['Lead'][0]['Referrer'] = 'john snow_QaAuto_121'
            @testDataJSON['Lead'][0]['Referrer Name'] = 'John'
            @testDataJSON['Lead'][0]['Referrer Email'] = 'abc@example.com'
            @testDataJSON['Lead'][0]['Assign using active assignment rule'] = true
            @testDataJSON['Lead'][0]['Promo Code'] = "123123"

            expectedOwner  = '0051g000000tWpP'

            @helper.addLogs("[Step ]     : Fetch building deatails")            
            building = @objLeadGeneration.fetchBuildingDetails(@testDataJSON['Lead'][0]['Building Interested In'])
            expect(building).to_not eq nil
            expect(building.size).to eq 1
            expect(building[0]).to_not eq nil      
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Login to salesforce")
            @objLeadGeneration.loginToSalesforce
            
            @helper.addLogs("[Step ]     : Create Lead record with consumer record type")
            @objLeadGeneration.createLeadStdsalesforce
            @helper.addLogs("[Validate ] : Checking Lead is created after form submission")
            @helper.addLogs("[Expected ] : Lead should create with name #{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
            
            @helper.addLogs("[Step ]     : Fetch lead deatails")            
            insertedLeadInfo = @objLeadGeneration.fetchLeadDetails(@testDataJSON['Lead'][0]['Email'])
            expect(insertedLeadInfo).to_not eq nil
            expect(insertedLeadInfo.size).to eq 1
            expect(insertedLeadInfo[0]).to_not eq nil  
            insertedLeadInfo =  insertedLeadInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead name")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Name")}")            
            expect(insertedLeadInfo.fetch("Name")).to match("#{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
            @helper.addLogs("[Result ]   : Success\n")

            recordType = @objLeadGeneration.getRecordType(@testDataJSON['Lead'][0]['Number of Full Time Employees'].to_i)

            @helper.addLogs("[Validate ] : Checking Lead owner should be According to Lead Assignment Rule")
            @helper.addLogs("[Expected ] : #{expectedOwner}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Owner").fetch("Id")}")            
            expect(insertedLeadInfo.fetch("Owner").fetch("Id")).to match("#{expectedOwner}")
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Organization")
            @helper.addLogs("[Expected ] : 0011g00000CIkegAAD")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Account__c")}")
            expect(insertedLeadInfo.fetch("Account__c")).to match("0011g00000CIkegAAD")
            @helper.addLogs("[Result ]   : Success\n")
            
            @helper.addLogs("[Validate ] : Checking Lead Market")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Market']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Market__c")}")
            expect(insertedLeadInfo.fetch("Market__c")).to eql @testDataJSON['Lead'][0]['Market']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Generate_Journey__c")
            @helper.addLogs("[Expected ] : #{!@testDataJSON['Lead'][0]['Generate Journey']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Generate_Journey__c")}")
            expect(insertedLeadInfo.fetch("Generate_Journey__c")).to eql true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Has_Active_Journey__c")
            @helper.addLogs("[Expected ] : true")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Has_Active_Journey__c")}")
            expect(insertedLeadInfo.fetch("Has_Active_Journey__c")).to eql true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Markets_Interested__c")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Markets Interested']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Markets_Interested__c")}")
            expect(insertedLeadInfo.fetch("Markets_Interested__c")).to eql @testDataJSON['Lead'][0]['Markets Interested']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Referrer__c")
            @helper.addLogs("[Expected ] : 0031g000008ROtsAAG")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Referrer__c")}")
            expect(insertedLeadInfo.fetch("Referrer__c")).to eql "0031g000008ROtsAAG"
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Referral_Company_Name__c")
            @helper.addLogs("[Expected ] : john.snow_Org_qaauto12121212")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Referral_Company_Name__c")}")
            expect(insertedLeadInfo.fetch("Referral_Company_Name__c")).to eql "john.snow_Org_qaauto12121212"
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Referrer_Name__c")
            @helper.addLogs("[Expected ] : John")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Referrer_Name__c")}")
            expect(insertedLeadInfo.fetch("Referrer_Name__c")).to eql "John"
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Referrer_Email__c")
            @helper.addLogs("[Expected ] : abc@example.com")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Referrer_Email__c")}")
            expect(insertedLeadInfo.fetch("Referrer_Email__c")).to eql "abc@example.com"
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead source")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['leadSource']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("LeadSource")}")
            expect(insertedLeadInfo.fetch("LeadSource")).to eql @testDataJSON['Lead'][0]['leadSource']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead source details")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['lead_Source_Detail__c']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Lead_Source_Detail__c")}")
            expect(insertedLeadInfo.fetch("Lead_Source_Detail__c")).to eql nil
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking building interested name on Lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Building Interested In']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Building_Interested_Name__c")}")
            expect(insertedLeadInfo.fetch("Building_Interested_Name__c")).to eql @testDataJSON['Lead'][0]['Building Interested In']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking building interested In")
            @helper.addLogs("[Expected ] : #{building[0].fetch("Id")}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Building_Interested_In__c")}")
            expect(insertedLeadInfo.fetch("Building_Interested_In__c")).to eql building[0].fetch("Id")
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Journey created date on lead")
            @helper.addLogs("[Expected ] : #{Date.today}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Journey_Created_On__c")}")
            expect(insertedLeadInfo.fetch("Journey_Created_On__c")).to eql Date.today.to_s
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Interested in Number of Desks on lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Interested in Number of Desk(s)']}.0")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch('Interested_in_Number_of_Desks__c')}")
            expect(insertedLeadInfo.fetch("Interested_in_Number_of_Desks__c").to_i).to eql "#{@testDataJSON['Lead'][0]['Interested in Number of Desk(s)']}.0".to_i
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Locations Interested on lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Locations Interested']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Locations_Interested__c")}")
            expect(insertedLeadInfo.fetch("Locations_Interested__c")).to eql @testDataJSON['Lead'][0]['Locations Interested']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Number of Full Time Employees on lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Number of Full Time Employees']}.0")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Number_of_Full_Time_Employees__c")}")
            expect(insertedLeadInfo.fetch("Number_of_Full_Time_Employees__c").to_i).to eql "#{@testDataJSON['Lead'][0]['Number of Full Time Employees']}.0".to_i
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Email on lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Email']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Email")}")
            expect(insertedLeadInfo.fetch("Email")).to eql @testDataJSON['Lead'][0]['Email']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Phone on lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Phone']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Phone")}")
            expect(insertedLeadInfo.fetch("Phone")).to eql "(888) 888-8888"
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Company on lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Company']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Company")}")
            expect(insertedLeadInfo.fetch("Company")).to eql @testDataJSON['Lead'][0]['Company']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking RecordType on lead")
            @helper.addLogs("[Expected ] : #{recordType}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("RecordType").fetch("Name")}")
            expect(insertedLeadInfo.fetch("RecordType").fetch("Name")).to eql recordType
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

            @helper.addLogs("[Validate ] : Checking Email_Opt_out on lead")
            @helper.addLogs("[Expected ] : true")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("HasOptedOutOfEmail")}")
            expect(insertedLeadInfo.fetch("HasOptedOutOfEmail")).to eql true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Promo code on lead")
            @helper.addLogs("[Expected ] : @testDataJSON['Lead'][0]['Promo Code']")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Promo_Code__c")}")
            expect(insertedLeadInfo.fetch("Promo_Code__c")).to eql @testDataJSON['Lead'][0]['Promo Code']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Move in Time frame on lead")
            @helper.addLogs("[Expected ] : @testDataJSON['Lead'][0]['Move In Time Frame']")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Move_In_Time_Frame__c")}")
            expect(insertedLeadInfo.fetch("Move_In_Time_Frame__c")).to eql @testDataJSON['Lead'][0]['Move In Time Frame']
            @helper.addLogs("[Result ]   : Success\n")            

            @helper.addLogs("[Step ]     : Checking for journey should created or Not")
            generateJourneyPermissin = @objLeadGeneration.isGenerateJourney(insertedLeadInfo.fetch("Owner").fetch("Id"),insertedLeadInfo.fetch("LeadSource"),insertedLeadInfo.fetch("Lead_Source_Detail__c"),insertedLeadInfo.fetch("Generate_Journey__c"))
           

            if generateJourneyPermissin then
                puts "********************************************************"

                @helper.addLogs("[Step ]     : Fetch journey deatails")            
                insertedJourneyInfo = @objLeadGeneration.fetchJourneyDetails(insertedLeadInfo.fetch("Email"))
                expect(insertedJourneyInfo).to_not eq nil
                expect(insertedJourneyInfo.size).to eq 1
                expect(insertedJourneyInfo[0]).to_not eq nil  
                insertedJourneyInfo =  insertedJourneyInfo[0]      
                @helper.addLogs("[Result ]   : Success\n")

                @helper.addLogs("[Validate ] : Checking Journey Name")
                @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
                @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Name")}")
                expect(insertedJourneyInfo).to_not eql nil
                expect(insertedJourneyInfo.fetch("Name")).to match("#{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
                @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking Journey owner")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Owner").fetch("Name")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Owner").fetch("Name")}")
                 expect(insertedJourneyInfo.fetch("Owner").fetch("Id")).to eql insertedLeadInfo.fetch("Owner").fetch("Id")
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

                 @helper.addLogs("[Validate ] : Checking building interested In on Journey")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Building_Interested_In__c")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Building_Interested_In__c")}")
                 expect(insertedJourneyInfo.fetch("Building_Interested_In__c")).to eql insertedLeadInfo.fetch("Building_Interested_In__c")
                 @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking NMD Next Contact Date on Journey")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Journey_Created_On__c")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")}")
                 expect(insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")).to eql insertedLeadInfo.fetch("Journey_Created_On__c")
                 @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking Interested in Number of Desks on Journey")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Interested_in_Number_of_Desks__c")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Interested_in_Number_of_Desks__c")}")
                 expect(insertedJourneyInfo.fetch("Interested_in_Number_of_Desks__c")).to eql insertedLeadInfo.fetch("Interested_in_Number_of_Desks__c")
                 @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking Locations Interested on Journey")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Locations_Interested__c")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Locations_Interested__c")}")
                 expect(insertedJourneyInfo.fetch("Locations_Interested__c")).to eql insertedLeadInfo.fetch("Locations_Interested__c")
                 @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking Number of Full Time Employees on Journey")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Number_of_Full_Time_Employees__c")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Full_Time_Employees__c")}")
                 expect(insertedJourneyInfo.fetch("Full_Time_Employees__c")).to eql insertedLeadInfo.fetch("Number_of_Full_Time_Employees__c")
                 @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking Email on Journey")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Email")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Primary_Email__c")}")
                 expect(insertedJourneyInfo.fetch("Primary_Email__c")).to eql insertedLeadInfo.fetch("Email")
                 @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking Phone on Journey")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Phone")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Primary_Phone__c")}")
                 expect(insertedJourneyInfo.fetch("Primary_Phone__c")).to eql "(888) 888-8888"
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

                 @helper.addLogs("[Validate ] : Checking Journey Market")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Market__c")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Market__c")}")
                 expect(insertedJourneyInfo.fetch("Market__c")).to eql insertedLeadInfo.fetch("Market__c")
                 @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking Journey Next Contact Date")
                 @helper.addLogs("[Expected ] : Started")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")}")
                 #expect(insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")).to eql "Started"
                 @helper.addLogs("[Result ]   : Success\n")

                @helper.addLogs("[Validate ] : Checking Journey Markets_Interested__c")
                @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Markets_Interested__c")}")
                @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Markets_Interested__c")}")
                expect(insertedLeadInfo.fetch("Markets_Interested__c")).to eql insertedLeadInfo.fetch("Markets_Interested__c")
                @helper.addLogs("[Result ]   : Success\n")

            else
                expect(insertedJourneyInfo).to eql nil
            end
            puts "********************************************************"

            @helper.addLogs("[Step ]     : Fetch Activity deatails")            
            generatedActivityForLead = @objLeadGeneration.fetchActivityDetails(insertedLeadInfo.fetch("Id"))
            expect(generatedActivityForLead).to_not eq nil
            expect(generatedActivityForLead.size).to eq 1
            expect(generatedActivityForLead[0]).to_not eq nil  
            generatedActivityForLead =  generatedActivityForLead[0]      
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Subject on acitivity")
            @helper.addLogs("[Expected ] : Inbound Lead submission")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Subject")}")
            expect(generatedActivityForLead.fetch("Subject")).to eql "Inbound Lead submission"
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking lead source on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("LeadSource")}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Lead_Source__c")}")
            expect(generatedActivityForLead.fetch("Lead_Source__c")).to eql insertedLeadInfo.fetch("LeadSource")
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking lead source detail on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Lead_Source_Detail__c")}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Lead_Source_Detail__c")}")
            expect(generatedActivityForLead.fetch("Lead_Source_Detail__c")).to eql insertedLeadInfo.fetch("Lead_Source_Detail__c")
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking assigned to on activity")
            @helper.addLogs("[Expected ] : Logged In User")#{@userInfo.fetch("display_name")}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Owner").fetch("Name")}")
            #expect(generatedActivityForLead.fetch("Owner").fetch("Name")).to eql @userInfo.fetch("display_name")
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking status on activity")
            @helper.addLogs("[Expected ] : Open")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Status")}")
            expect(generatedActivityForLead.fetch("Status")).to eql "Open"
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Company__c on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Company')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Company__c")}")
            expect(generatedActivityForLead.fetch("Company__c")).to eql insertedLeadInfo.fetch('Company')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Location interested on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Locations_Interested__c')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Locations_Interested__c")}")
            expect(generatedActivityForLead.fetch("Locations_Interested__c")).to eql insertedLeadInfo.fetch('Locations_Interested__c')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Location interested on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Number_of_Full_Time_Employees__c')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Number_of_Full_Time_Employees__c")}")
            expect(generatedActivityForLead.fetch("Number_of_Full_Time_Employees__c")).to eql insertedLeadInfo.fetch('Number_of_Full_Time_Employees__c')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Number of desks on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Interested_in_Number_of_Desks__c')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Interested_in_Number_of_Desks__c")}")
            expect(generatedActivityForLead.fetch("Interested_in_Number_of_Desks__c")).to eql insertedLeadInfo.fetch('Interested_in_Number_of_Desks__c')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Priority on activity")
            @helper.addLogs("[Expected ] : Normal")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Priority")}")
            expect(generatedActivityForLead.fetch("Priority")).to eql "Normal"
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Name on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Name')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Who").fetch('Name')}")
            expect(generatedActivityForLead.fetch("Who").fetch('Name')).to eql insertedLeadInfo.fetch('Name')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Email on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Email')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Email__c")}")
            expect(generatedActivityForLead.fetch("Email__c")).to eql insertedLeadInfo.fetch('Email')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Country_Code__c on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Country_Code__c')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Country_Code__c")}")
            expect(generatedActivityForLead.fetch("Country_Code__c")).to eql insertedLeadInfo.fetch('Country_Code__c')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Locale__c on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Locale__c')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Locale__c")}")
            expect(generatedActivityForLead.fetch("Locale__c")).to eql insertedLeadInfo.fetch('Locale__c')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Markets_Interested__c on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Markets_Interested__c')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Markets_Interested__c")}")
            expect(generatedActivityForLead.fetch("Markets_Interested__c")).to eql insertedLeadInfo.fetch('Markets_Interested__c')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Market__c on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Market__c')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Market__c")}")
            expect(generatedActivityForLead.fetch("Market__c")).to eql insertedLeadInfo.fetch('Market__c')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.postSuccessResult('2544')
        rescue Exception => e
            puts e
            @helper.postFailResult(e,'2544')
        end
    end

    it "C:2545 To check lead is assigned to 'Logged In user' for record type 'Enterprise Solution' and journey,activity should be created for that lead.", :'2545' => 'true' do
        begin
            @helper.addLogs("C:2545 To check lead is assigned to 'Logged In user' for record type 'Enterprise Solution' and journey,activity should be created for that lead.",'2545')
            @testDataJSON['Lead'][0]['RecordType'] = 'Consumer'
            @testDataJSON['Lead'][0]['Email'] = @testDataJSON['Lead'][0]['LastName'] + SecureRandom.random_number(10000000000).to_s + "@test.com"
            @testDataJSON['Lead'][0]['leadSource'] = 'Outbound Email/Cold Call'
            @testDataJSON['Lead'][0]['lead_Source_Detail__c'] = ''
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
            @testDataJSON['Lead'][0]['Number of Full Time Employees'] = '1500'
            @testDataJSON['Lead'][0]['Locations Interested'] = "AMS-Labs;AMS-Strawinskylaan"
            @testDataJSON['Lead'][0]['Referrer'] = 'john snow_QaAuto_121'
            @testDataJSON['Lead'][0]['Referrer Name'] = 'John'
            @testDataJSON['Lead'][0]['Referrer Email'] = 'abc@example.com'
            @testDataJSON['Lead'][0]['Assign using active assignment rule'] = true
            @testDataJSON['Lead'][0]['Promo Code'] = "123123"

            expectedOwner  = '0051g000000tWpP'

            @helper.addLogs("[Step ]     : Fetch building deatails")            
            building = @objLeadGeneration.fetchBuildingDetails(@testDataJSON['Lead'][0]['Building Interested In'])
            expect(building).to_not eq nil
            expect(building.size).to eq 1
            expect(building[0]).to_not eq nil      
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Login to salesforce")
            @objLeadGeneration.loginToSalesforce
            
            @helper.addLogs("[Step ]     : Create Lead record with consumer record type")
            @objLeadGeneration.createLeadStdsalesforce
            @helper.addLogs("[Validate ] : Checking Lead is created after form submission")
            @helper.addLogs("[Expected ] : Lead should create with name #{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
            
            @helper.addLogs("[Step ]     : Fetch lead deatails")            
            insertedLeadInfo = @objLeadGeneration.fetchLeadDetails(@testDataJSON['Lead'][0]['Email'])
            expect(insertedLeadInfo).to_not eq nil
            expect(insertedLeadInfo.size).to eq 1
            expect(insertedLeadInfo[0]).to_not eq nil  
            insertedLeadInfo =  insertedLeadInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead name")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Name")}")            
            expect(insertedLeadInfo.fetch("Name")).to match("#{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
            @helper.addLogs("[Result ]   : Success\n")

            recordType = @objLeadGeneration.getRecordType(@testDataJSON['Lead'][0]['Number of Full Time Employees'].to_i)

            @helper.addLogs("[Validate ] : Checking Lead owner should be According to Lead Assignment Rule")
            @helper.addLogs("[Expected ] : #{expectedOwner}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Owner").fetch("Id")}")            
            expect(insertedLeadInfo.fetch("Owner").fetch("Id")).to match("#{expectedOwner}")
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Organization")
            @helper.addLogs("[Expected ] : 0011g00000CIkegAAD")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Account__c")}")
            expect(insertedLeadInfo.fetch("Account__c")).to match("0011g00000CIkegAAD")
            @helper.addLogs("[Result ]   : Success\n")
            
            @helper.addLogs("[Validate ] : Checking Lead Market")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Market']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Market__c")}")
            expect(insertedLeadInfo.fetch("Market__c")).to eql @testDataJSON['Lead'][0]['Market']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Generate_Journey__c")
            @helper.addLogs("[Expected ] : #{!@testDataJSON['Lead'][0]['Generate Journey']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Generate_Journey__c")}")
            expect(insertedLeadInfo.fetch("Generate_Journey__c")).to eql true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Has_Active_Journey__c")
            @helper.addLogs("[Expected ] : true")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Has_Active_Journey__c")}")
            expect(insertedLeadInfo.fetch("Has_Active_Journey__c")).to eql true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Markets_Interested__c")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Markets Interested']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Markets_Interested__c")}")
            expect(insertedLeadInfo.fetch("Markets_Interested__c")).to eql @testDataJSON['Lead'][0]['Markets Interested']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Referrer__c")
            @helper.addLogs("[Expected ] : 0031g000008ROtsAAG")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Referrer__c")}")
            expect(insertedLeadInfo.fetch("Referrer__c")).to eql "0031g000008ROtsAAG"
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Referral_Company_Name__c")
            @helper.addLogs("[Expected ] : john.snow_Org_qaauto12121212")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Referral_Company_Name__c")}")
            expect(insertedLeadInfo.fetch("Referral_Company_Name__c")).to eql "john.snow_Org_qaauto12121212"
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Referrer_Name__c")
            @helper.addLogs("[Expected ] : John")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Referrer_Name__c")}")
            expect(insertedLeadInfo.fetch("Referrer_Name__c")).to eql "John"
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Referrer_Email__c")
            @helper.addLogs("[Expected ] : abc@example.com")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Referrer_Email__c")}")
            expect(insertedLeadInfo.fetch("Referrer_Email__c")).to eql "abc@example.com"
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead source")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['leadSource']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("LeadSource")}")
            expect(insertedLeadInfo.fetch("LeadSource")).to eql @testDataJSON['Lead'][0]['leadSource']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead source details")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['lead_Source_Detail__c']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Lead_Source_Detail__c")}")
            expect(insertedLeadInfo.fetch("Lead_Source_Detail__c")).to eql nil
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking building interested name on Lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Building Interested In']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Building_Interested_Name__c")}")
            expect(insertedLeadInfo.fetch("Building_Interested_Name__c")).to eql @testDataJSON['Lead'][0]['Building Interested In']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking building interested In")
            @helper.addLogs("[Expected ] : #{building[0].fetch("Id")}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Building_Interested_In__c")}")
            expect(insertedLeadInfo.fetch("Building_Interested_In__c")).to eql building[0].fetch("Id")
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Journey created date on lead")
            @helper.addLogs("[Expected ] : #{Date.today}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Journey_Created_On__c")}")
            expect(insertedLeadInfo.fetch("Journey_Created_On__c")).to eql Date.today.to_s
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Interested in Number of Desks on lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Interested in Number of Desk(s)']}.0")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch('Interested_in_Number_of_Desks__c')}")
            expect(insertedLeadInfo.fetch("Interested_in_Number_of_Desks__c").to_i).to eql "#{@testDataJSON['Lead'][0]['Interested in Number of Desk(s)']}.0".to_i
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Locations Interested on lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Locations Interested']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Locations_Interested__c")}")
            expect(insertedLeadInfo.fetch("Locations_Interested__c")).to eql @testDataJSON['Lead'][0]['Locations Interested']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Number of Full Time Employees on lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Number of Full Time Employees']}.0")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Number_of_Full_Time_Employees__c")}")
            expect(insertedLeadInfo.fetch("Number_of_Full_Time_Employees__c").to_i).to eql "#{@testDataJSON['Lead'][0]['Number of Full Time Employees']}.0".to_i
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Email on lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Email']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Email")}")
            expect(insertedLeadInfo.fetch("Email")).to eql @testDataJSON['Lead'][0]['Email']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Phone on lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Phone']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Phone")}")
            expect(insertedLeadInfo.fetch("Phone")).to eql "(888) 888-8888"
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Company on lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Company']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Company")}")
            expect(insertedLeadInfo.fetch("Company")).to eql @testDataJSON['Lead'][0]['Company']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking RecordType on lead")
            @helper.addLogs("[Expected ] : #{recordType}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("RecordType").fetch("Name")}")
            expect(insertedLeadInfo.fetch("RecordType").fetch("Name")).to eql recordType
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

            @helper.addLogs("[Validate ] : Checking Email_Opt_out on lead")
            @helper.addLogs("[Expected ] : true")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("HasOptedOutOfEmail")}")
            expect(insertedLeadInfo.fetch("HasOptedOutOfEmail")).to eql true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Promo code on lead")
            @helper.addLogs("[Expected ] : @testDataJSON['Lead'][0]['Promo Code']")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Promo_Code__c")}")
            expect(insertedLeadInfo.fetch("Promo_Code__c")).to eql @testDataJSON['Lead'][0]['Promo Code']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Move in Time frame on lead")
            @helper.addLogs("[Expected ] : @testDataJSON['Lead'][0]['Move In Time Frame']")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Move_In_Time_Frame__c")}")
            expect(insertedLeadInfo.fetch("Move_In_Time_Frame__c")).to eql @testDataJSON['Lead'][0]['Move In Time Frame']
            @helper.addLogs("[Result ]   : Success\n")            

            @helper.addLogs("[Step ]     : Checking for journey should created or Not")
            generateJourneyPermissin = @objLeadGeneration.isGenerateJourney(insertedLeadInfo.fetch("Owner").fetch("Id"),insertedLeadInfo.fetch("LeadSource"),insertedLeadInfo.fetch("Lead_Source_Detail__c"),insertedLeadInfo.fetch("Generate_Journey__c"))
           

            if generateJourneyPermissin then
                puts "********************************************************"

                @helper.addLogs("[Step ]     : Fetch journey deatails")            
                insertedJourneyInfo = @objLeadGeneration.fetchJourneyDetails(insertedLeadInfo.fetch("Email"))
                expect(insertedJourneyInfo).to_not eq nil
                expect(insertedJourneyInfo.size).to eq 1
                expect(insertedJourneyInfo[0]).to_not eq nil  
                insertedJourneyInfo =  insertedJourneyInfo[0]      
                @helper.addLogs("[Result ]   : Success\n")

                @helper.addLogs("[Validate ] : Checking Journey Name")
                @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
                @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Name")}")
                expect(insertedJourneyInfo).to_not eql nil
                expect(insertedJourneyInfo.fetch("Name")).to match("#{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
                @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking Journey owner")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Owner").fetch("Name")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Owner").fetch("Name")}")
                 expect(insertedJourneyInfo.fetch("Owner").fetch("Id")).to eql insertedLeadInfo.fetch("Owner").fetch("Id")
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

                 @helper.addLogs("[Validate ] : Checking building interested In on Journey")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Building_Interested_In__c")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Building_Interested_In__c")}")
                 expect(insertedJourneyInfo.fetch("Building_Interested_In__c")).to eql insertedLeadInfo.fetch("Building_Interested_In__c")
                 @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking NMD Next Contact Date on Journey")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Journey_Created_On__c")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")}")
                 expect(insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")).to eql insertedLeadInfo.fetch("Journey_Created_On__c")
                 @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking Interested in Number of Desks on Journey")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Interested_in_Number_of_Desks__c")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Interested_in_Number_of_Desks__c")}")
                 expect(insertedJourneyInfo.fetch("Interested_in_Number_of_Desks__c")).to eql insertedLeadInfo.fetch("Interested_in_Number_of_Desks__c")
                 @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking Locations Interested on Journey")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Locations_Interested__c")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Locations_Interested__c")}")
                 expect(insertedJourneyInfo.fetch("Locations_Interested__c")).to eql insertedLeadInfo.fetch("Locations_Interested__c")
                 @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking Number of Full Time Employees on Journey")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Number_of_Full_Time_Employees__c")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Full_Time_Employees__c")}")
                 expect(insertedJourneyInfo.fetch("Full_Time_Employees__c")).to eql insertedLeadInfo.fetch("Number_of_Full_Time_Employees__c")
                 @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking Email on Journey")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Email")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Primary_Email__c")}")
                 expect(insertedJourneyInfo.fetch("Primary_Email__c")).to eql insertedLeadInfo.fetch("Email")
                 @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking Phone on Journey")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Phone")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Primary_Phone__c")}")
                 expect(insertedJourneyInfo.fetch("Primary_Phone__c")).to eql "(888) 888-8888"
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

                 @helper.addLogs("[Validate ] : Checking Journey Market")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Market__c")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Market__c")}")
                 expect(insertedJourneyInfo.fetch("Market__c")).to eql insertedLeadInfo.fetch("Market__c")
                 @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking Journey Next Contact Date")
                 @helper.addLogs("[Expected ] : Started")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")}")
                 #expect(insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")).to eql "Started"
                 @helper.addLogs("[Result ]   : Success\n")

                @helper.addLogs("[Validate ] : Checking Journey Markets_Interested__c")
                @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Markets_Interested__c")}")
                @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Markets_Interested__c")}")
                expect(insertedLeadInfo.fetch("Markets_Interested__c")).to eql insertedLeadInfo.fetch("Markets_Interested__c")
                @helper.addLogs("[Result ]   : Success\n")

            else
                expect(insertedJourneyInfo).to eql nil
            end
            puts "********************************************************"

            @helper.addLogs("[Step ]     : Fetch Activity deatails")            
            generatedActivityForLead = @objLeadGeneration.fetchActivityDetails(insertedLeadInfo.fetch("Id"))
            expect(generatedActivityForLead).to_not eq nil
            expect(generatedActivityForLead.size).to eq 1
            expect(generatedActivityForLead[0]).to_not eq nil  
            generatedActivityForLead =  generatedActivityForLead[0]      
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Subject on acitivity")
            @helper.addLogs("[Expected ] : Inbound Lead submission")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Subject")}")
            expect(generatedActivityForLead.fetch("Subject")).to eql "Inbound Lead submission"
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking lead source on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("LeadSource")}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Lead_Source__c")}")
            expect(generatedActivityForLead.fetch("Lead_Source__c")).to eql insertedLeadInfo.fetch("LeadSource")
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking lead source detail on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Lead_Source_Detail__c")}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Lead_Source_Detail__c")}")
            expect(generatedActivityForLead.fetch("Lead_Source_Detail__c")).to eql insertedLeadInfo.fetch("Lead_Source_Detail__c")
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking assigned to on activity")
            @helper.addLogs("[Expected ] : Logged In User")#{@userInfo.fetch("display_name")}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Owner").fetch("Name")}")
            #expect(generatedActivityForLead.fetch("Owner").fetch("Name")).to eql @userInfo.fetch("display_name")
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking status on activity")
            @helper.addLogs("[Expected ] : Open")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Status")}")
            expect(generatedActivityForLead.fetch("Status")).to eql "Open"
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Company__c on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Company')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Company__c")}")
            expect(generatedActivityForLead.fetch("Company__c")).to eql insertedLeadInfo.fetch('Company')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Location interested on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Locations_Interested__c')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Locations_Interested__c")}")
            expect(generatedActivityForLead.fetch("Locations_Interested__c")).to eql insertedLeadInfo.fetch('Locations_Interested__c')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Location interested on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Number_of_Full_Time_Employees__c')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Number_of_Full_Time_Employees__c")}")
            expect(generatedActivityForLead.fetch("Number_of_Full_Time_Employees__c")).to eql insertedLeadInfo.fetch('Number_of_Full_Time_Employees__c')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Number of desks on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Interested_in_Number_of_Desks__c')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Interested_in_Number_of_Desks__c")}")
            expect(generatedActivityForLead.fetch("Interested_in_Number_of_Desks__c")).to eql insertedLeadInfo.fetch('Interested_in_Number_of_Desks__c')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Priority on activity")
            @helper.addLogs("[Expected ] : Normal")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Priority")}")
            expect(generatedActivityForLead.fetch("Priority")).to eql "Normal"
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Name on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Name')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Who").fetch('Name')}")
            expect(generatedActivityForLead.fetch("Who").fetch('Name')).to eql insertedLeadInfo.fetch('Name')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Email on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Email')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Email__c")}")
            expect(generatedActivityForLead.fetch("Email__c")).to eql insertedLeadInfo.fetch('Email')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Country_Code__c on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Country_Code__c')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Country_Code__c")}")
            expect(generatedActivityForLead.fetch("Country_Code__c")).to eql insertedLeadInfo.fetch('Country_Code__c')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Locale__c on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Locale__c')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Locale__c")}")
            expect(generatedActivityForLead.fetch("Locale__c")).to eql insertedLeadInfo.fetch('Locale__c')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Markets_Interested__c on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Markets_Interested__c')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Markets_Interested__c")}")
            expect(generatedActivityForLead.fetch("Markets_Interested__c")).to eql insertedLeadInfo.fetch('Markets_Interested__c')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Market__c on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Market__c')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Market__c")}")
            expect(generatedActivityForLead.fetch("Market__c")).to eql insertedLeadInfo.fetch('Market__c')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.postSuccessResult('2545')
        rescue Exception => e
            puts e
            @helper.postFailResult(e,'2545')
        end
    end

    it "C:2553 To check lead is assigned to proper 'User/Queue' from lead assignment rule and activity should be created but journey should not be created.", :'2553' => 'true' do
        begin
            @helper.addLogs("C:2553 To check lead is assigned to proper 'User/Queue' from lead assignment rule and activity should be created but journey should not be created.",'2553')
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

            @helper.addLogs("[Step ]     : Fetch building deatails")            
            building = @objLeadGeneration.fetchBuildingDetails(@testDataJSON['Lead'][0]['Building Interested In'])
            expect(building).to_not eq nil
            expect(building.size).to eq 1
            expect(building[0]).to_not eq nil      
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Login to salesforce")
            @objLeadGeneration.loginToSalesforce
            
            @helper.addLogs("[Step ]     : Create Lead record with consumer record type")
            @objLeadGeneration.createLeadStdsalesforce
            @helper.addLogs("[Validate ] : Checking Lead is created after form submission")
            @helper.addLogs("[Expected ] : Lead should create with name #{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
            
            @helper.addLogs("[Step ]     : Fetch lead deatails")            
            insertedLeadInfo = @objLeadGeneration.fetchLeadDetails(@testDataJSON['Lead'][0]['Email'])
            expect(insertedLeadInfo).to_not eq nil
            expect(insertedLeadInfo.size).to eq 1
            expect(insertedLeadInfo[0]).to_not eq nil  
            insertedLeadInfo =  insertedLeadInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            recordType = @objLeadGeneration.getRecordType(@testDataJSON['Lead'][0]['Number of Full Time Employees'].to_i)
            @helper.addLogs("[Step ]     : Checking for journey should created or Not")
            generateJourneyPermissin = @objLeadGeneration.isGenerateJourney(insertedLeadInfo.fetch("Owner").fetch("Id"),insertedLeadInfo.fetch("LeadSource"),insertedLeadInfo.fetch("Lead_Source_Detail__c"),insertedLeadInfo.fetch("Generate_Journey__c"))
           
            @helper.addLogs("[Validate ] : Checking Lead name")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Name")}")            
            expect(insertedLeadInfo.fetch("Name")).to match("#{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead owner should be According to Lead Assignment Rule")
            @helper.addLogs("[Expected ] : 0050G000008KcLF")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Owner").fetch("Id")}")            
            expect(insertedLeadInfo.fetch("Owner").fetch("Id")).to match("0050G000008KcLF")
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Organization")
            @helper.addLogs("[Expected ] : 0011g00000CIkegAAD")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Account__c")}")
            expect(insertedLeadInfo.fetch("Account__c")).to match("0011g00000CIkegAAD")
            @helper.addLogs("[Result ]   : Success\n")
            
            @helper.addLogs("[Validate ] : Checking Lead Market")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Market']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Market__c")}")
            expect(insertedLeadInfo.fetch("Market__c")).to eql @testDataJSON['Lead'][0]['Market']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Generate_Journey__c")
            @helper.addLogs("[Expected ] : #{!@testDataJSON['Lead'][0]['Generate Journey']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Generate_Journey__c")}")
            expect(insertedLeadInfo.fetch("Generate_Journey__c")).to eql !@testDataJSON['Lead'][0]['Generate Journey']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Has_Active_Journey__c")
            @helper.addLogs("[Expected ] : true")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Has_Active_Journey__c")}")
            expect(insertedLeadInfo.fetch("Has_Active_Journey__c")).to eql !@testDataJSON['Lead'][0]['Generate Journey']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Markets_Interested__c")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Markets Interested']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Markets_Interested__c")}")
            expect(insertedLeadInfo.fetch("Markets_Interested__c")).to eql @testDataJSON['Lead'][0]['Markets Interested']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Referrer__c")
            @helper.addLogs("[Expected ] : 0031g000008ROtsAAG")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Referrer__c")}")
            expect(insertedLeadInfo.fetch("Referrer__c")).to eql "0031g000008ROtsAAG"
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Referral_Company_Name__c")
            @helper.addLogs("[Expected ] : john.snow_Org_qaauto12121212")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Referral_Company_Name__c")}")
            expect(insertedLeadInfo.fetch("Referral_Company_Name__c")).to eql "john.snow_Org_qaauto12121212"
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Referrer_Name__c")
            @helper.addLogs("[Expected ] : John")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Referrer_Name__c")}")
            expect(insertedLeadInfo.fetch("Referrer_Name__c")).to eql "John"
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Referrer_Email__c")
            @helper.addLogs("[Expected ] : abc@example.com")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Referrer_Email__c")}")
            expect(insertedLeadInfo.fetch("Referrer_Email__c")).to eql "abc@example.com"
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

            @helper.addLogs("[Validate ] : Checking building interested name on Lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Building Interested In']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Building_Interested_Name__c")}")
            expect(insertedLeadInfo.fetch("Building_Interested_Name__c")).to eql @testDataJSON['Lead'][0]['Building Interested In']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking building interested In")
            @helper.addLogs("[Expected ] : #{building[0].fetch("Id")}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Building_Interested_In__c")}")
            expect(insertedLeadInfo.fetch("Building_Interested_In__c")).to eql building[0].fetch("Id")
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Journey created date on lead")
            @helper.addLogs("[Expected ] : #{Date.today}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Journey_Created_On__c")}")
            generateJourneyPermissin ? (expect(insertedLeadInfo.fetch("Journey_Created_On__c")).to eql Date.today.to_s) : (expect(insertedLeadInfo.fetch("Journey_Created_On__c")).to eql nil)
            
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Interested in Number of Desks on lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Interested in Number of Desk(s)']}.0")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch('Interested_in_Number_of_Desks__c')}")
            expect(insertedLeadInfo.fetch("Interested_in_Number_of_Desks__c").to_i).to eql "#{@testDataJSON['Lead'][0]['Interested in Number of Desk(s)']}.0".to_i
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Locations Interested on lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Locations Interested']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Locations_Interested__c")}")
            expect(insertedLeadInfo.fetch("Locations_Interested__c")).to eql @testDataJSON['Lead'][0]['Locations Interested']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Number of Full Time Employees on lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Number of Full Time Employees']}.0")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Number_of_Full_Time_Employees__c")}")
            expect(insertedLeadInfo.fetch("Number_of_Full_Time_Employees__c").to_i).to eql "#{@testDataJSON['Lead'][0]['Number of Full Time Employees']}.0".to_i
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Email on lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Email']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Email")}")
            expect(insertedLeadInfo.fetch("Email")).to eql @testDataJSON['Lead'][0]['Email']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Phone on lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Phone']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Phone")}")
            expect(insertedLeadInfo.fetch("Phone")).to eql "(888) 888-8888"
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Company on lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Company']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Company")}")
            expect(insertedLeadInfo.fetch("Company")).to eql @testDataJSON['Lead'][0]['Company']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking RecordType on lead")
            @helper.addLogs("[Expected ] : #{recordType}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("RecordType").fetch("Name")}")
            expect(insertedLeadInfo.fetch("RecordType").fetch("Name")).to eql recordType
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

            @helper.addLogs("[Validate ] : Checking Email_Opt_out on lead")
            @helper.addLogs("[Expected ] : true")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("HasOptedOutOfEmail")}")
            expect(insertedLeadInfo.fetch("HasOptedOutOfEmail")).to eql true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Promo code on lead")
            @helper.addLogs("[Expected ] : @testDataJSON['Lead'][0]['Promo Code']")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Promo_Code__c")}")
            expect(insertedLeadInfo.fetch("Promo_Code__c")).to eql @testDataJSON['Lead'][0]['Promo Code']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Move in Time frame on lead")
            @helper.addLogs("[Expected ] : @testDataJSON['Lead'][0]['Move In Time Frame']")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Move_In_Time_Frame__c")}")
            expect(insertedLeadInfo.fetch("Move_In_Time_Frame__c")).to eql @testDataJSON['Lead'][0]['Move In Time Frame']
            @helper.addLogs("[Result ]   : Success\n")            

            

            if generateJourneyPermissin then
                puts "********************************************************"

                @helper.addLogs("[Step ]     : Fetch journey deatails")            
                insertedJourneyInfo = @objLeadGeneration.fetchJourneyDetails(insertedLeadInfo.fetch("Email"))
                expect(insertedJourneyInfo).to_not eq nil
                expect(insertedJourneyInfo.size).to eq 1
                expect(insertedJourneyInfo[0]).to_not eq nil  
                insertedJourneyInfo =  insertedJourneyInfo[0]      
                @helper.addLogs("[Result ]   : Success\n")

                @helper.addLogs("[Validate ] : Checking Journey Name")
                @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
                @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Name")}")
                expect(insertedJourneyInfo).to_not eql nil
                expect(insertedJourneyInfo.fetch("Name")).to match("#{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
                @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking Journey owner")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Owner").fetch("Name")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Owner").fetch("Name")}")
                 expect(insertedJourneyInfo.fetch("Owner").fetch("Id")).to eql insertedLeadInfo.fetch("Owner").fetch("Id")
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

                 @helper.addLogs("[Validate ] : Checking building interested In on Journey")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Building_Interested_In__c")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Building_Interested_In__c")}")
                 expect(insertedJourneyInfo.fetch("Building_Interested_In__c")).to eql insertedLeadInfo.fetch("Building_Interested_In__c")
                 @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking NMD Next Contact Date on Journey")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Journey_Created_On__c")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")}")
                 expect(insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")).to eql insertedLeadInfo.fetch("Journey_Created_On__c")
                 @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking Interested in Number of Desks on Journey")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Interested_in_Number_of_Desks__c")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Interested_in_Number_of_Desks__c")}")
                 expect(insertedJourneyInfo.fetch("Interested_in_Number_of_Desks__c")).to eql insertedLeadInfo.fetch("Interested_in_Number_of_Desks__c")
                 @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking Locations Interested on Journey")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Locations_Interested__c")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Locations_Interested__c")}")
                 expect(insertedJourneyInfo.fetch("Locations_Interested__c")).to eql insertedLeadInfo.fetch("Locations_Interested__c")
                 @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking Number of Full Time Employees on Journey")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Number_of_Full_Time_Employees__c")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Full_Time_Employees__c")}")
                 expect(insertedJourneyInfo.fetch("Full_Time_Employees__c")).to eql insertedLeadInfo.fetch("Number_of_Full_Time_Employees__c")
                 @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking Email on Journey")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Email")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Primary_Email__c")}")
                 expect(insertedJourneyInfo.fetch("Primary_Email__c")).to eql insertedLeadInfo.fetch("Email")
                 @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking Phone on Journey")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Phone")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Primary_Phone__c")}")
                 expect(insertedJourneyInfo.fetch("Primary_Phone__c")).to eql "(888) 888-8888"
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

                 @helper.addLogs("[Validate ] : Checking Journey Market")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Market__c")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Market__c")}")
                 expect(insertedJourneyInfo.fetch("Market__c")).to eql insertedLeadInfo.fetch("Market__c")
                 @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking Journey Next Contact Date")
                 @helper.addLogs("[Expected ] : Started")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")}")
                 #expect(insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")).to eql "Started"
                 @helper.addLogs("[Result ]   : Success\n")

                @helper.addLogs("[Validate ] : Checking Journey Markets_Interested__c")
                @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Markets_Interested__c")}")
                @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Markets_Interested__c")}")
                expect(insertedLeadInfo.fetch("Markets_Interested__c")).to eql insertedLeadInfo.fetch("Markets_Interested__c")
                @helper.addLogs("[Result ]   : Success\n")


                @helper.addLogs("[Step ]     : Fetch Activity deatails")            
            generatedActivityForLead = @objLeadGeneration.fetchActivityDetails(insertedLeadInfo.fetch("Id"))
            expect(generatedActivityForLead).to_not eq nil
            expect(generatedActivityForLead.size).to eq 1
            expect(generatedActivityForLead[0]).to_not eq nil  
            generatedActivityForLead =  generatedActivityForLead[0]      
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Subject on acitivity")
            @helper.addLogs("[Expected ] : Inbound Lead submission")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Subject")}")
            expect(generatedActivityForLead.fetch("Subject")).to eql "Inbound Lead submission"
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking lead source on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("LeadSource")}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Lead_Source__c")}")
            expect(generatedActivityForLead.fetch("Lead_Source__c")).to eql insertedLeadInfo.fetch("LeadSource")
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking lead source detail on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Lead_Source_Detail__c")}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Lead_Source_Detail__c")}")
            expect(generatedActivityForLead.fetch("Lead_Source_Detail__c")).to eql insertedLeadInfo.fetch("Lead_Source_Detail__c")
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking assigned to on activity")
            @helper.addLogs("[Expected ] : Logged In User")#{@userInfo.fetch("display_name")}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Owner").fetch("Name")}")
            #expect(generatedActivityForLead.fetch("Owner").fetch("Name")).to eql @userInfo.fetch("display_name")
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking status on activity")
            @helper.addLogs("[Expected ] : Open")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Status")}")
            expect(generatedActivityForLead.fetch("Status")).to eql "Open"
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Company__c on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Company')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Company__c")}")
            expect(generatedActivityForLead.fetch("Company__c")).to eql insertedLeadInfo.fetch('Company')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Location interested on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Locations_Interested__c')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Locations_Interested__c")}")
            expect(generatedActivityForLead.fetch("Locations_Interested__c")).to eql insertedLeadInfo.fetch('Locations_Interested__c')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Location interested on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Number_of_Full_Time_Employees__c')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Number_of_Full_Time_Employees__c")}")
            expect(generatedActivityForLead.fetch("Number_of_Full_Time_Employees__c")).to eql insertedLeadInfo.fetch('Number_of_Full_Time_Employees__c')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Number of desks on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Interested_in_Number_of_Desks__c')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Interested_in_Number_of_Desks__c")}")
            expect(generatedActivityForLead.fetch("Interested_in_Number_of_Desks__c")).to eql insertedLeadInfo.fetch('Interested_in_Number_of_Desks__c')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Priority on activity")
            @helper.addLogs("[Expected ] : Normal")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Priority")}")
            expect(generatedActivityForLead.fetch("Priority")).to eql "Normal"
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Name on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Name')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Who").fetch('Name')}")
            expect(generatedActivityForLead.fetch("Who").fetch('Name')).to eql insertedLeadInfo.fetch('Name')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Email on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Email')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Email__c")}")
            expect(generatedActivityForLead.fetch("Email__c")).to eql insertedLeadInfo.fetch('Email')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Country_Code__c on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Country_Code__c')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Country_Code__c")}")
            expect(generatedActivityForLead.fetch("Country_Code__c")).to eql insertedLeadInfo.fetch('Country_Code__c')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Locale__c on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Locale__c')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Locale__c")}")
            expect(generatedActivityForLead.fetch("Locale__c")).to eql insertedLeadInfo.fetch('Locale__c')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Markets_Interested__c on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Markets_Interested__c')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Markets_Interested__c")}")
            expect(generatedActivityForLead.fetch("Markets_Interested__c")).to eql insertedLeadInfo.fetch('Markets_Interested__c')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Market__c on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Market__c')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Market__c")}")
            expect(generatedActivityForLead.fetch("Market__c")).to eql insertedLeadInfo.fetch('Market__c')
            @helper.addLogs("[Result ]   : Success\n")

            else
                @helper.addLogs("[Validate ] : Checking Journey Creation")
                @helper.addLogs("[Expected ] : journey should not created")
                expect(insertedJourneyInfo).to eql nil
                @helper.addLogs("[Result ]   : Success\n")

                @helper.addLogs("[Validate ] : Checking Activity creation")
                @helper.addLogs("[Expected ] : Activity should not created}")
                expect(generatedActivityForLead).to eql nil
                @helper.addLogs("[Result ]   : Success\n")

                
            end
            
            @helper.postSuccessResult('2553')
        rescue Exception => e
            puts e
            @helper.postFailResult(e,'2553')
        end
    end

    it "C:2557 To check lead is assigned to proper 'User/Queue' from lead assignment rule and activity should be created but journey should not be created.", :'2557' => 'true' do
        begin
            @helper.addLogs("C:2557 To check lead is assigned to proper 'User/Queue' from lead assignment rule and activity should be created but journey should not be created.",'2557')
            @testDataJSON['Lead'][0]['RecordType'] = 'Consumer'
            @testDataJSON['Lead'][0]['Email'] = @testDataJSON['Lead'][0]['LastName'] + SecureRandom.random_number(10000000000).to_s + "@example.com"
            @testDataJSON['Lead'][0]['leadSource'] = 'Facebook'
            @testDataJSON['Lead'][0]['lead_Source_Detail__c'] = ''
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

            @helper.addLogs("[Step ]     : Fetch building deatails")            
            building = @objLeadGeneration.fetchBuildingDetails(@testDataJSON['Lead'][0]['Building Interested In'])
            expect(building).to_not eq nil
            expect(building.size).to eq 1
            expect(building[0]).to_not eq nil      
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Step ]     : Login to salesforce")
            @objLeadGeneration.loginToSalesforce
            
            @helper.addLogs("[Step ]     : Create Lead record with consumer record type")
            @objLeadGeneration.createLeadStdsalesforce
            @helper.addLogs("[Validate ] : Checking Lead is created after form submission")
            @helper.addLogs("[Expected ] : Lead should create with name #{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
            
            @helper.addLogs("[Step ]     : Fetch lead deatails")            
            insertedLeadInfo = @objLeadGeneration.fetchLeadDetails(@testDataJSON['Lead'][0]['Email'])
            expect(insertedLeadInfo).to_not eq nil
            expect(insertedLeadInfo.size).to eq 1
            expect(insertedLeadInfo[0]).to_not eq nil  
            insertedLeadInfo =  insertedLeadInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            recordType = @objLeadGeneration.getRecordType(@testDataJSON['Lead'][0]['Number of Full Time Employees'].to_i)
            @helper.addLogs("[Step ]     : Checking for journey should created or Not")
            generateJourneyPermissin = @objLeadGeneration.isGenerateJourney(insertedLeadInfo.fetch("Owner").fetch("Id"),insertedLeadInfo.fetch("LeadSource"),insertedLeadInfo.fetch("Lead_Source_Detail__c"),insertedLeadInfo.fetch("Generate_Journey__c"))
           
            @helper.addLogs("[Validate ] : Checking Lead name")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Name")}")            
            expect(insertedLeadInfo.fetch("Name")).to match("#{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead owner should be According to Lead Assignment Rule")
            @helper.addLogs("[Expected ] : 0050G000008KcLF")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Owner").fetch("Id")}")            
            expect(insertedLeadInfo.fetch("Owner").fetch("Id")).to match("0050G000008KcLF")
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Organization")
            @helper.addLogs("[Expected ] : 0011g00000CIkegAAD")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Account__c")}")
            expect(insertedLeadInfo.fetch("Account__c")).to match("0011g00000CIkegAAD")
            @helper.addLogs("[Result ]   : Success\n")
            
            @helper.addLogs("[Validate ] : Checking Lead Market")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Market']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Market__c")}")
            expect(insertedLeadInfo.fetch("Market__c")).to eql @testDataJSON['Lead'][0]['Market']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Generate_Journey__c")
            @helper.addLogs("[Expected ] : #{!@testDataJSON['Lead'][0]['Generate Journey']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Generate_Journey__c")}")
            expect(insertedLeadInfo.fetch("Generate_Journey__c")).to eql !@testDataJSON['Lead'][0]['Generate Journey']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Has_Active_Journey__c")
            @helper.addLogs("[Expected ] : true")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Has_Active_Journey__c")}")
            expect(insertedLeadInfo.fetch("Has_Active_Journey__c")).to eql false
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Markets_Interested__c")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Markets Interested']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Markets_Interested__c")}")
            expect(insertedLeadInfo.fetch("Markets_Interested__c")).to eql @testDataJSON['Lead'][0]['Markets Interested']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Referrer__c")
            @helper.addLogs("[Expected ] : 0031g000008ROtsAAG")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Referrer__c")}")
            expect(insertedLeadInfo.fetch("Referrer__c")).to eql "0031g000008ROtsAAG"
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Referral_Company_Name__c")
            @helper.addLogs("[Expected ] : john.snow_Org_qaauto12121212")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Referral_Company_Name__c")}")
            expect(insertedLeadInfo.fetch("Referral_Company_Name__c")).to eql "john.snow_Org_qaauto12121212"
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Referrer_Name__c")
            @helper.addLogs("[Expected ] : John")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Referrer_Name__c")}")
            expect(insertedLeadInfo.fetch("Referrer_Name__c")).to eql "John"
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead Referrer_Email__c")
            @helper.addLogs("[Expected ] : abc@example.com")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Referrer_Email__c")}")
            expect(insertedLeadInfo.fetch("Referrer_Email__c")).to eql "abc@example.com"
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead source")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['leadSource']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("LeadSource")}")
            expect(insertedLeadInfo.fetch("LeadSource")).to eql @testDataJSON['Lead'][0]['leadSource']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead source details")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['lead_Source_Detail__c']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Lead_Source_Detail__c")}")
            (@testDataJSON['Lead'][0]['lead_Source_Detail__c'] != "") ? (expect(insertedLeadInfo.fetch("Lead_Source_Detail__c")).to eql @testDataJSON['Lead'][0]['lead_Source_Detail__c']) : (expect(insertedLeadInfo.fetch("Lead_Source_Detail__c")).to eql nil)
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking building interested name on Lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Building Interested In']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Building_Interested_Name__c")}")
            expect(insertedLeadInfo.fetch("Building_Interested_Name__c")).to eql @testDataJSON['Lead'][0]['Building Interested In']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking building interested In")
            @helper.addLogs("[Expected ] : #{building[0].fetch("Id")}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Building_Interested_In__c")}")
            expect(insertedLeadInfo.fetch("Building_Interested_In__c")).to eql building[0].fetch("Id")
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Journey created date on lead")
            @helper.addLogs("[Expected ] : #{Date.today}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Journey_Created_On__c")}")
            generateJourneyPermissin ? (expect(insertedLeadInfo.fetch("Journey_Created_On__c")).to eql Date.today.to_s) : (expect(insertedLeadInfo.fetch("Journey_Created_On__c")).to eql nil)
            
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Interested in Number of Desks on lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Interested in Number of Desk(s)']}.0")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch('Interested_in_Number_of_Desks__c')}")
            expect(insertedLeadInfo.fetch("Interested_in_Number_of_Desks__c").to_i).to eql "#{@testDataJSON['Lead'][0]['Interested in Number of Desk(s)']}.0".to_i
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Locations Interested on lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Locations Interested']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Locations_Interested__c")}")
            expect(insertedLeadInfo.fetch("Locations_Interested__c")).to eql @testDataJSON['Lead'][0]['Locations Interested']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Number of Full Time Employees on lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Number of Full Time Employees']}.0")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Number_of_Full_Time_Employees__c")}")
            expect(insertedLeadInfo.fetch("Number_of_Full_Time_Employees__c").to_i).to eql "#{@testDataJSON['Lead'][0]['Number of Full Time Employees']}.0".to_i
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Email on lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Email']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Email")}")
            expect(insertedLeadInfo.fetch("Email")).to eql @testDataJSON['Lead'][0]['Email']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Phone on lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Phone']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Phone")}")
            expect(insertedLeadInfo.fetch("Phone")).to eql "(888) 888-8888"
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Company on lead")
            @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['Company']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Company")}")
            expect(insertedLeadInfo.fetch("Company")).to eql @testDataJSON['Lead'][0]['Company']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking RecordType on lead")
            @helper.addLogs("[Expected ] : #{recordType}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("RecordType").fetch("Name")}")
            expect(insertedLeadInfo.fetch("RecordType").fetch("Name")).to eql recordType
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

            @helper.addLogs("[Validate ] : Checking Email_Opt_out on lead")
            @helper.addLogs("[Expected ] : true")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("HasOptedOutOfEmail")}")
            expect(insertedLeadInfo.fetch("HasOptedOutOfEmail")).to eql true
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Promo code on lead")
            @helper.addLogs("[Expected ] : @testDataJSON['Lead'][0]['Promo Code']")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Promo_Code__c")}")
            expect(insertedLeadInfo.fetch("Promo_Code__c")).to eql @testDataJSON['Lead'][0]['Promo Code']
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Move in Time frame on lead")
            @helper.addLogs("[Expected ] : @testDataJSON['Lead'][0]['Move In Time Frame']")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Move_In_Time_Frame__c")}")
            expect(insertedLeadInfo.fetch("Move_In_Time_Frame__c")).to eql @testDataJSON['Lead'][0]['Move In Time Frame']
            @helper.addLogs("[Result ]   : Success\n")            

            

            if generateJourneyPermissin then
                puts "********************************************************"

                @helper.addLogs("[Step ]     : Fetch journey deatails")            
                insertedJourneyInfo = @objLeadGeneration.fetchJourneyDetails(insertedLeadInfo.fetch("Email"))
                expect(insertedJourneyInfo).to_not eq nil
                expect(insertedJourneyInfo.size).to eq 1
                expect(insertedJourneyInfo[0]).to_not eq nil  
                insertedJourneyInfo =  insertedJourneyInfo[0]      
                @helper.addLogs("[Result ]   : Success\n")

                @helper.addLogs("[Validate ] : Checking Journey Name")
                @helper.addLogs("[Expected ] : #{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
                @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Name")}")
                expect(insertedJourneyInfo).to_not eql nil
                expect(insertedJourneyInfo.fetch("Name")).to match("#{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
                @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking Journey owner")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Owner").fetch("Name")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Owner").fetch("Name")}")
                 expect(insertedJourneyInfo.fetch("Owner").fetch("Id")).to eql insertedLeadInfo.fetch("Owner").fetch("Id")
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

                 @helper.addLogs("[Validate ] : Checking building interested In on Journey")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Building_Interested_In__c")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Building_Interested_In__c")}")
                 expect(insertedJourneyInfo.fetch("Building_Interested_In__c")).to eql insertedLeadInfo.fetch("Building_Interested_In__c")
                 @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking NMD Next Contact Date on Journey")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Journey_Created_On__c")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")}")
                 expect(insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")).to eql insertedLeadInfo.fetch("Journey_Created_On__c")
                 @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking Interested in Number of Desks on Journey")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Interested_in_Number_of_Desks__c")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Interested_in_Number_of_Desks__c")}")
                 expect(insertedJourneyInfo.fetch("Interested_in_Number_of_Desks__c")).to eql insertedLeadInfo.fetch("Interested_in_Number_of_Desks__c")
                 @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking Locations Interested on Journey")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Locations_Interested__c")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Locations_Interested__c")}")
                 expect(insertedJourneyInfo.fetch("Locations_Interested__c")).to eql insertedLeadInfo.fetch("Locations_Interested__c")
                 @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking Number of Full Time Employees on Journey")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Number_of_Full_Time_Employees__c")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Full_Time_Employees__c")}")
                 expect(insertedJourneyInfo.fetch("Full_Time_Employees__c")).to eql insertedLeadInfo.fetch("Number_of_Full_Time_Employees__c")
                 @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking Email on Journey")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Email")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Primary_Email__c")}")
                 expect(insertedJourneyInfo.fetch("Primary_Email__c")).to eql insertedLeadInfo.fetch("Email")
                 @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking Phone on Journey")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Phone")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Primary_Phone__c")}")
                 expect(insertedJourneyInfo.fetch("Primary_Phone__c")).to eql "(888) 888-8888"
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

                 @helper.addLogs("[Validate ] : Checking Journey Market")
                 @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Market__c")}")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Market__c")}")
                 expect(insertedJourneyInfo.fetch("Market__c")).to eql insertedLeadInfo.fetch("Market__c")
                 @helper.addLogs("[Result ]   : Success\n")

                 @helper.addLogs("[Validate ] : Checking Journey Next Contact Date")
                 @helper.addLogs("[Expected ] : Started")
                 @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")}")
                 #expect(insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")).to eql "Started"
                 @helper.addLogs("[Result ]   : Success\n")

                @helper.addLogs("[Validate ] : Checking Journey Markets_Interested__c")
                @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Markets_Interested__c")}")
                @helper.addLogs("[Actual ]   : #{insertedJourneyInfo.fetch("Markets_Interested__c")}")
                expect(insertedLeadInfo.fetch("Markets_Interested__c")).to eql insertedLeadInfo.fetch("Markets_Interested__c")
                @helper.addLogs("[Result ]   : Success\n")


                @helper.addLogs("[Step ]     : Fetch Activity deatails")            
            generatedActivityForLead = @objLeadGeneration.fetchActivityDetails(insertedLeadInfo.fetch("Id"))
            expect(generatedActivityForLead).to_not eq nil
            expect(generatedActivityForLead.size).to eq 1
            expect(generatedActivityForLead[0]).to_not eq nil  
            generatedActivityForLead =  generatedActivityForLead[0]      
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Subject on acitivity")
            @helper.addLogs("[Expected ] : Inbound Lead submission")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Subject")}")
            expect(generatedActivityForLead.fetch("Subject")).to eql "Inbound Lead submission"
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking lead source on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("LeadSource")}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Lead_Source__c")}")
            expect(generatedActivityForLead.fetch("Lead_Source__c")).to eql insertedLeadInfo.fetch("LeadSource")
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking lead source detail on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch("Lead_Source_Detail__c")}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Lead_Source_Detail__c")}")
            expect(generatedActivityForLead.fetch("Lead_Source_Detail__c")).to eql insertedLeadInfo.fetch("Lead_Source_Detail__c")
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking assigned to on activity")
            @helper.addLogs("[Expected ] : Logged In User")#{@userInfo.fetch("display_name")}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Owner").fetch("Name")}")
            #expect(generatedActivityForLead.fetch("Owner").fetch("Name")).to eql @userInfo.fetch("display_name")
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking status on activity")
            @helper.addLogs("[Expected ] : Open")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Status")}")
            expect(generatedActivityForLead.fetch("Status")).to eql "Open"
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Company__c on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Company')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Company__c")}")
            expect(generatedActivityForLead.fetch("Company__c")).to eql insertedLeadInfo.fetch('Company')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Location interested on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Locations_Interested__c')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Locations_Interested__c")}")
            expect(generatedActivityForLead.fetch("Locations_Interested__c")).to eql insertedLeadInfo.fetch('Locations_Interested__c')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Location interested on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Number_of_Full_Time_Employees__c')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Number_of_Full_Time_Employees__c")}")
            expect(generatedActivityForLead.fetch("Number_of_Full_Time_Employees__c")).to eql insertedLeadInfo.fetch('Number_of_Full_Time_Employees__c')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Number of desks on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Interested_in_Number_of_Desks__c')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Interested_in_Number_of_Desks__c")}")
            expect(generatedActivityForLead.fetch("Interested_in_Number_of_Desks__c")).to eql insertedLeadInfo.fetch('Interested_in_Number_of_Desks__c')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Priority on activity")
            @helper.addLogs("[Expected ] : Normal")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Priority")}")
            expect(generatedActivityForLead.fetch("Priority")).to eql "Normal"
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Name on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Name')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Who").fetch('Name')}")
            expect(generatedActivityForLead.fetch("Who").fetch('Name')).to eql insertedLeadInfo.fetch('Name')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Email on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Email')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Email__c")}")
            expect(generatedActivityForLead.fetch("Email__c")).to eql insertedLeadInfo.fetch('Email')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Country_Code__c on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Country_Code__c')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Country_Code__c")}")
            expect(generatedActivityForLead.fetch("Country_Code__c")).to eql insertedLeadInfo.fetch('Country_Code__c')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Locale__c on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Locale__c')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Locale__c")}")
            expect(generatedActivityForLead.fetch("Locale__c")).to eql insertedLeadInfo.fetch('Locale__c')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Markets_Interested__c on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Markets_Interested__c')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Markets_Interested__c")}")
            expect(generatedActivityForLead.fetch("Markets_Interested__c")).to eql insertedLeadInfo.fetch('Markets_Interested__c')
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Market__c on activity")
            @helper.addLogs("[Expected ] : #{insertedLeadInfo.fetch('Market__c')}")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Market__c")}")
            expect(generatedActivityForLead.fetch("Market__c")).to eql insertedLeadInfo.fetch('Market__c')
            @helper.addLogs("[Result ]   : Success\n")

            else
                @helper.addLogs("[Validate ] : Checking Journey Creation")
                @helper.addLogs("[Expected ] : journey should not created")
                expect(insertedJourneyInfo).to eql nil
                @helper.addLogs("[Result ]   : Success\n")

                @helper.addLogs("[Validate ] : Checking Activity creation")
                @helper.addLogs("[Expected ] : Activity should not created}")
                expect(generatedActivityForLead).to eql nil
                @helper.addLogs("[Result ]   : Success\n")

                
            end
            
            @helper.postSuccessResult('2557')
        rescue Exception => e
            puts e
            @helper.postFailResult(e,'2557')
        end
    end

    
end




    it "C:2145 To Check of journey updation on duplicate lead submission, if an open journey already exist in system with created date within 4 days from today.", :'2145'=> 'true' do
        begin
            @helper.addLogs('C:2145 To check whether generation of lead from Website.','2145')

            @testDataJSON['CreateLeadFromWeb'][0]["BuildingName"]  = 'marol'
            @testDataJSON['CreateLeadFromWeb'][0]["City"]  = 'mumbai'
            @testDataJSON['CreateLeadFromWeb'][0]["Building"]  = 'MUM-Marol'
 
            @helper.addLogs('Go to Staging website and create lead')
            @testDataJSON['CreateLeadFromWeb'][0]['Email'] = @testDataJSON['CreateLeadFromWeb'][0]['Name'] + SecureRandom.random_number(10000000000).to_s + "@example.com"
            emailLead = @testDataJSON['CreateLeadFromWeb'][0]['Email']
            expect(@objLeadGeneration.createLead(emailLead)).to eq true
            @helper.addLogs('Success')

            @helper.addLogs('Go to Staging website and Again create lead with same email Id')
            expect(@objLeadGeneration.createLead(emailLead)).to eq true
            @helper.addLogs('Success')

            @helper.addLogs("[Step    ] get building details of #{@testDataJSON['CreateLeadFromWeb'][0]["Building"]}")
            building = @objLeadGeneration.fetchBuildingDetails(@testDataJSON['CreateLeadFromWeb'][0]["Building"])
            expect(building[0]).to_not eq nil
            @helper.addLogs("[Result  ]  Success")

            @helper.addLogs("[Step    ] get Lead details")
            lead  = @objLeadGeneration.fetchLeadDetails(emailLead)
            expect(lead.size == 1).to eq true
            expect(lead[0].fetch('Id')).to_not eq nil
            @helper.addLogs("[Result  ]  Success")

            @helper.addLogs("[Step    ] get Journey details")
            journey  = @objLeadGeneration.fetchJourneyDetails(emailLead)
            #puts journey.size
            #puts journey[journey.size - 1]
            expect(journey.size == 1).to eq true
            expect(journey[journey.size - 1]).to_not eq nil
            expect(journey[journey.size - 1].fetch('Id')).to_not eq nil
            passedLogs = @helper.addLogs("[Result  ]  Success")

            passedLogs = @helper.addLogs("[Step    ] get Activity details")
            leadId  =lead[0].fetch('Id')
            activity  = @helper.getSalesforceRecord('Task',"Select Id,Owner.Name,Owner.Id, Subject, WhoId, Lead_Source__c, Lead_Source_Detail__c, Locations_Interested__c,Type,CreatedDate,Status FROM Task WHERE WhoId = '#{leadId}' order by CreatedDate")
            expect(activity[0]).to_not eq nil
            expect(activity[0].fetch('Id')).to_not eq nil
            passedLogs = @helper.addLogs("[Result  ]  Success")

            puts "*******************************"

            passedLogs = @helper.addLogs("[Validate] journey:.Name")
            expect(journey[journey.size - 1].fetch('Name')).to match("#{@testDataJSON['CreateLeadFromWeb'][0]['Name']}")
            passedLogs = @helper.addLogs("[Result  ]  Success")

            passedLogs = @helper.addLogs("[Validate] journey:NMD_Next_Contact_Date__c")
            #puts journey[journey.size - 1].fetch('NMD_Next_Contact_Date__c')
            #puts Date.today
            expect(journey[journey.size - 1].fetch('NMD_Next_Contact_Date__c')).to eq Date.today.to_s
            passedLogs = @helper.addLogs("[Result  ]  Success")

            passedLogs = @helper.addLogs("[Validate] journey:Status__c")
            expect(journey[journey.size - 1].fetch('Status__c')).to eq "Started"
            passedLogs = @helper.addLogs("[Result  ]  Success")

            puts "******************************"
            passedLogs = @helper.addLogs("[Validate] Activity:Subject")
            expect(activity[activity.size - 1].fetch('Subject')).to eq "Inbound Lead submission"
            passedLogs = @helper.addLogs("[Result  ]  Success")

            passedLogs = @helper.addLogs("[Validate] Activity:Lead_Source__c")
            expect(activity[activity.size - 1].fetch('Lead_Source__c')).to eq "WeWork.com"
            passedLogs = @helper.addLogs("[Result  ]  Success")

            passedLogs = @helper.addLogs("[Validate] Activity:Type")
            expect(activity[activity.size - 1].fetch('Type')).to eq "Website"
            passedLogs = @helper.addLogs("[Result  ]  Success")

            passedLogs = @helper.addLogs("[Validate] Activity:Lead_Source_Detail__c")
            expect(activity[activity.size - 1].fetch('Lead_Source_Detail__c')).to eq "Book A Tour Availability"
            passedLogs = @helper.addLogs("[Result  ]  Success")

            passedLogs = @helper.addLogs("[Validate] Activity:Status")
            expect(activity[activity.size - 1].fetch('Status')).to eq "Not Started"
            passedLogs = @helper.addLogs("[Result  ]  Success")

            @helper.postSuccessResult('2145')
        rescue Exception => e
            @helper.postFailResult(e,'2145')
        end
    end



    it "C:2146 To check new journey creation if duplicate lead submission happens for existing lead which is created before 4 days and within 30 days from today.", :'2146'=> 'true' do
        begin
            @helper.addLogs('C:2146 To check new journey creation if duplicate lead submission happens for existing lead which is created after 4 days and within 30 days from today.','2146')

            @testDataJSON['CreateLeadFromWeb'][0]["BuildingName"]  = 'marol'
            @testDataJSON['CreateLeadFromWeb'][0]["City"]  = 'mumbai'
            @testDataJSON['CreateLeadFromWeb'][0]["Building"]  = 'MUM-Marol'

            passedLogs = @helper.addLogs("[Step    ] get details of 4 days ago lead")
            lead = @helper.getSalesforceRecordByRestforce("SELECT Id,Name,Email,Owner.Name,CreatedDate FROM Lead WHERE Email LIKE '%@example.com' AND CreatedDate = LAST_N_DAYS: 4 AND IsConverted = False LIMIT 1")
            
            if (lead[0].fetch('Id') == nil ) then
                @helper.addLogs("Lead not present")
            end
            expect(lead.size == 1).to eq true
            expect(lead[0]).to_not eq nil
            expect(lead[0].fetch('Id')).to_not eq nil
            passedLogs = @helper.addLogs("[Result  ]  Success")

            emailLead = lead[0].fetch('Email')

            @helper.addLogs('Go to Staging website and create lead with email id of existing lead created before 4 to 30 days.')
            expect(@objLeadGeneration.createLead(emailLead)).to eq true
            @helper.addLogs('Success')

            @helper.addLogs("[Step    ] get building details of #{@testDataJSON['CreateLeadFromWeb'][0]["Building"]}")
            building = @objLeadGeneration.fetchBuildingDetails(@testDataJSON['CreateLeadFromWeb'][0]["Building"])
            expect(building[0]).to_not eq nil
            @helper.addLogs("[Result  ]  Success")

            @helper.addLogs("[Step    ] get Lead details")
            lead  = @objLeadGeneration.fetchLeadDetails(emailLead)
=begin
            index = 1
            until (lead.size == 1)do
                sleep(10)
                puts index
                index = index + 1
                lead  = @objLeadGeneration.fetchLeadDetails(emailLead)
                puts lead
            end
=end            
            puts lead[lead.size - 1]
            expect(lead[lead.size - 1].fetch('Id')).to_not eq nil
            @helper.addLogs("[Result  ]  Success")

            passedLogs = @helper.addLogs("[Step    ] get Journey details")
            journey  = @objLeadGeneration.fetchJourneyDetails(emailLead)
            #puts journey.size
            #puts journey[journey.size - 1]
            puts journey.size
            #expect(journey.size == 1).to eq true
            #journey  = @helper.getSalesforceRecord('Journey__c',"SELECT Id,Name,Status__c,NMD_Next_Contact_Date__c FROM Journey__c WHERE Primary_Email__c = '#{emailLead}' order by CreatedDate")
            #puts journey
            #puts journey.size
            #expect(journey.size == 1).to eq true
            expect(journey[journey.size - 1]).to_not eq nil
            expect(journey[journey.size - 1].fetch('Id')).to_not eq nil
            puts journey[journey.size - 1].attrs
            passedLogs = @helper.addLogs("[Result  ]  Success")

            passedLogs = @helper.addLogs("[Step    ] get Activity details")
            leadId  =lead[lead.size - 1].fetch('Id')
            activity  = @helper.getSalesforceRecord('Task',"Select Id,Owner.Name,Owner.Id, Subject, WhoId, Lead_Source__c, Lead_Source_Detail__c, Locations_Interested__c,Type,Status FROM Task WHERE WhoId = '#{leadId}' order by CreatedDate")
            #puts activity
            #puts activity.size
            #expect(activity.size == 1).to eq true
            expect(activity[activity.size - 1]).to_not eq nil
            expect(activity[activity.size - 1].fetch('Id')).to_not eq nil
            passedLogs = @helper.addLogs("[Result  ]  Success")


            puts "deleting created journey"
            deleted_journeys = Hash["id" => "#{journey[journey.size - 1].fetch('Id')}"]
            records_to_delete = Array.new
            records_to_delete.push(deleted_journeys)
            @helper.deleteSalesforceRecordBySfbulk('Journey__c',records_to_delete)

            puts "*******************************"
            passedLogs = @helper.addLogs("[Validate] journey:.Name")
            expect(journey[journey.size - 1].fetch('Name')).to match("#{@testDataJSON['CreateLeadFromWeb'][0]['Name']}")
            passedLogs = @helper.addLogs("[Result  ]  Success")

            passedLogs = @helper.addLogs("[Validate] journey:NMD_Next_Contact_Date__c")
            #puts journey[journey.size - 1].fetch('NMD_Next_Contact_Date__c')
            #puts Date.today
            expect(journey[journey.size - 1].fetch('NMD_Next_Contact_Date__c')).to eq Date.today.to_s
            passedLogs = @helper.addLogs("[Result  ]  Success")

            passedLogs = @helper.addLogs("[Validate] journey:Status__c")
            #puts journey[journey.size - 1].fetch('Status__c')
            expect(journey[journey.size - 1].fetch('Status__c')).to eq "Started"
            passedLogs = @helper.addLogs("[Result  ]  Success")

            puts "******************************"
            passedLogs = @helper.addLogs("[Validate] Activity:Subject")
            expect(activity[activity.size - 1].fetch('Subject')).to eq "Inbound Lead submission"
            passedLogs = @helper.addLogs("[Result  ]  Success")

            passedLogs = @helper.addLogs("[Validate] Activity:Lead_Source__c")
            expect(activity[activity.size - 1].fetch('Lead_Source__c')).to eq "WeWork.com"
            passedLogs = @helper.addLogs("[Result  ]  Success")

            passedLogs = @helper.addLogs("[Validate] Activity:Type")
            expect(activity[activity.size - 1].fetch('Type')).to eq "Website"
            passedLogs = @helper.addLogs("[Result  ]  Success")

            passedLogs = @helper.addLogs("[Validate] Activity:Lead_Source_Detail__c")
            expect(activity[activity.size - 1].fetch('Lead_Source_Detail__c')).to eq "Book A Tour Availability"
            passedLogs = @helper.addLogs("[Result  ]  Success")

            passedLogs = @helper.addLogs("[Validate] Activity:Status")
            expect(activity[activity.size - 1].fetch('Status')).to eq "Not Started"
            passedLogs = @helper.addLogs("[Result  ]  Success")

            @helper.postSuccessResult('2146')
        rescue Exception => e
            @helper.postFailResult(e,'2146')
        end
    end



    it "C:2147 To check new journey creation if duplicate lead submission happens for existing lead which is created after 4 days and within 30 days from today.", :'2147'=> 'true' do
        begin
            @helper.addLogs('C:2147 To check new journey creation if duplicate lead submission happens for existing lead which is created after 30 days from today.','2147')

            @testDataJSON['CreateLeadFromWeb'][0]["BuildingName"]  = 'marol'
            @testDataJSON['CreateLeadFromWeb'][0]["City"]  = 'mumbai'
            @testDataJSON['CreateLeadFromWeb'][0]["Building"]  = 'MUM-Marol'

            passedLogs = @helper.addLogs("[Step    ] get details of 30 days ago lead")
            #d = Date.today().next_day(-30)
            #puts d
            lead = @helper.getSalesforceRecordByRestforce("select id,Name,createdDate,IsConverted,Email from Lead where Email like  '%@example.com%' AND createdDate = LAST_N_DAYS:30 And IsConverted= false order by CreatedDate LIMIT 1")
            puts lead

            if (lead[0] == nil ) then
                @helper.addLogs("Lead not present")
            end
            expect(lead.size == 1).to eq true
            expect(lead[0]).to_not eq nil
            expect(lead[0].fetch('Id')).to_not eq nil
            passedLogs = @helper.addLogs("[Result  ]  Success")
            emailLead = lead[0].fetch('Email')

            @helper.addLogs('Go to Staging website and create lead with email id of existing lead created before 4 to 30 days.')
            expect(@objLeadGeneration.createLead(emailLead)).to eq true
            @helper.addLogs('Success')
            
            sleep(20)

            @helper.addLogs("[Step    ] get building details of #{@testDataJSON['CreateLeadFromWeb'][0]["Building"]}")
            building = @objLeadGeneration.fetchBuildingDetails(@testDataJSON['CreateLeadFromWeb'][0]["Building"])
            expect(building[0]).to_not eq nil
            @helper.addLogs("[Result  ]  Success")
=begin
        passedLogs = @helper.addLogs("[Step    ] get Lead details")
        lead  = @helper.getSalesforceRecord('Lead',"SELECT Id,Name,Email,Owner.Name,CreatedDate,Company,Phone,LeadSource,Company_Size__c,Lead_Source_Detail__c,Status,Building_Interested_In__c,Building_Interested_Name__c,Locations_Interested__c,Journey_Created_On__c FROM Lead WHERE Email='#{emailLead}'")
        #puts lead
        expect(lead.size == 1).to eq true
        expect(lead[0]).to_not eq nil
        expect(lead[0].fetch('Id')).to_not eq nil
        passedLogs = @helper.addLogs("[Result  ]  Success")
=end
            passedLogs = @helper.addLogs("[Step    ] get Journey details")
            #journey  = @helper.getSalesforceRecord('Journey__c',"SELECT Id,Status__c,NMD_Next_Contact_Date__c,Name FROM Journey__c WHERE Primary_Email__c = '#{emailLead}' order by CreatedDate")
            journey  = @objLeadGeneration.fetchJourneyDetails(emailLead)
            puts journey

            #puts journey

            puts journey.size
            #expect(journey.size == 1).to eq true
            expect(journey[journey.size - 1]).to_not eq nil
            expect(journey[journey.size - 1].fetch('Id')).to_not eq nil
            passedLogs = @helper.addLogs("[Result  ]  Success")



            passedLogs = @helper.addLogs("[Step    ] get Activity details")
            leadId  =lead[0].fetch('Id')
            activity  = @helper.getSalesforceRecord('Task',"Select Id,Owner.Name,Owner.Id, Subject, WhoId, Lead_Source__c, Lead_Source_Detail__c, Locations_Interested__c,Type,Status FROM Task WHERE WhoId = '#{leadId}' order by CreatedDate")
            #puts activity
            #puts activity.size
            #expect(activity.size == 1).to eq true
            expect(activity[activity.size - 1]).to_not eq nil
            expect(activity[activity.size - 1].fetch('Id')).to_not eq nil
            passedLogs = @helper.addLogs("[Result  ]  Success")


            deleted_journeys = Hash["id" => "#{journey[journey.size - 1].fetch('Id')}"]
            records_to_delete = Array.new
            records_to_delete.push(deleted_journeys)
            puts records_to_delete
            @helper.deleteSalesforceRecordBySfbulk('Journey__c',records_to_delete)

            puts "*******************************"
            passedLogs = @helper.addLogs("[Validate] journey:.Name")
            expect(journey[journey.size - 1].fetch('Name')).to match("#{@testDataJSON['CreateLeadFromWeb'][0]['Name']}")
            passedLogs = @helper.addLogs("[Result  ]  Success")

            passedLogs = @helper.addLogs("[Validate] journey:NMD_Next_Contact_Date__c")
            #puts journey[journey.size - 1].fetch('NMD_Next_Contact_Date__c')
            #puts Date.today
            expect(journey[journey.size - 1].fetch('NMD_Next_Contact_Date__c')).to eq Date.today.to_s
            passedLogs = @helper.addLogs("[Result  ]  Success")

            passedLogs = @helper.addLogs("[Validate] journey:Status__c")
            #puts journey[journey.size - 1].fetch('Status__c')
            expect(journey[journey.size - 1].fetch('Status__c')).to eq "Started"
            passedLogs = @helper.addLogs("[Result  ]  Success")

            puts "******************************"
            passedLogs = @helper.addLogs("[Validate] Activity:Subject")
            expect(activity[activity.size - 1].fetch('Subject')).to eq "Inbound Lead submission"
            passedLogs = @helper.addLogs("[Result  ]  Success")

            passedLogs = @helper.addLogs("[Validate] Activity:Lead_Source__c")
            expect(activity[activity.size - 1].fetch('Lead_Source__c')).to eq "WeWork.com"
            passedLogs = @helper.addLogs("[Result  ]  Success")

            passedLogs = @helper.addLogs("[Validate] Activity:Type")
            expect(activity[activity.size - 1].fetch('Type')).to eq "Website"
            passedLogs = @helper.addLogs("[Result  ]  Success")

            passedLogs = @helper.addLogs("[Validate] Activity:Lead_Source_Detail__c")
            expect(activity[activity.size - 1].fetch('Lead_Source_Detail__c')).to eq "Book A Tour Availability"
            passedLogs = @helper.addLogs("[Result  ]  Success")

            passedLogs = @helper.addLogs("[Validate] Activity:Status")
            expect(activity[activity.size - 1].fetch('Status')).to eq "Not Started"
            passedLogs = @helper.addLogs("[Result  ]  Success")
            #@helper.deleteSalesforceRecords('Journey__c',["#{journey[journey.size - 1].fetch('Id')}"])
            @helper.postSuccessResult('2147')
        rescue Exception => e
            #@helper.deleteSalesforceRecords('Journey__c',["#{journey[journey.size - 1].fetch('Id')}"])
            @helper.postFailResult(e,'2147')
        end
    end



    it "C:2149 To Check New Journey creation if duplicate lead submission happens for existing contact which is created within 30 days from today when the existing contact has permission to create a journey.", :'2149'=> 'true' do
        begin
            @helper.addLogs('C:2149 To Check New Journey creation if duplicate lead submission happens for existing contact which is created within 30 days from today when the existing contact has permission to create a journey.','2149')
            @testDataJSON['CreateLeadFromWeb'][0]["BuildingName"]  = 'marol'
            @testDataJSON['CreateLeadFromWeb'][0]["City"]  = 'mumbai'
            @testDataJSON['CreateLeadFromWeb'][0]["Building"]  = 'MUM-Marol'

            #users = @helper.getSalesforceRecord('Setting__c',"select Data__c from Setting__c Where Name = 'User/Queue Journey Creation'")


            #userIds = JSON.parse(users[0].fetch('Data__c'))

            #arrOfUsersHavingPermissionToCreateJourney = []
            #userIds['allowedUsers'].each do |user|
            #    arrOfUsersHavingPermissionToCreateJourney.push(user['Id'])
            #end

            #puts arrOfUsersHavingPermissionToCreateJourney

            #passedLogs = @helper.addLogs("[Step    ] get details of 30 days ago Contact")
            #contacts = @helper.getSalesforceRecord('Contact',"select id,Name,createdDate,Account.Id,Looking_For_Number_Of_Desk__c,Owner.Id,Owner.Name,RecordType.Name,Number_of_Full_Time_Employees__c,Email,Interested_in_Number_of_Desks__c from Contact where Email like  '%@example.com%' AND createdDate = LAST_N_DAYS:30")


            #passedLogs = @helper.addLogs("[Step    ] Create Contact such that contact owner has permissions to generate journey")


=begin

        contactToTest = nil
        contacts.each do |contact|
            if arrOfUsersHavingPermissionToCreateJourney.include? contact.fetch('Owner.Id') then
                puts "User has permission #{contact}"
                contactToTest = contact
                break;
            end
        end

        puts contactToTest
        
        if (contactToTest.fetch('Id') == nil ) then
          @helper.addLogs("Contact not present")
        end
        expect(contactToTest).to_not eq nil
        expect(contactToTest.fetch('Id')).to_not eq nil
        passedLogs = @helper.addLogs("[Result  ]  Success")


=end
            @testDataJSON['CreateLeadFromWeb'][0]['Email'] = @testDataJSON['CreateLeadFromWeb'][0]['Name'] + SecureRandom.random_number(10000000000).to_s + "@example.com"
            emailId =  @testDataJSON['CreateLeadFromWeb'][0]['Email']
            @helper.addLogs('Go to Staging website and book a tour')
            expect(@objLeadGeneration.createLead(emailId)).to eq true
=begin
            @driver.get "https://www-staging.wework.com/buildings/bkc--mumbai"
            sleep(5)
            @driver.find_element(:id, "tourFormContactNameField").clear
            @driver.find_element(:id, "tourFormContactNameField").send_keys @testDataJSON['CreateLeadFromWeb'][0]['Name']
            @driver.find_element(:id, "tourFormEmailField").clear
            @testDataJSON['CreateLeadFromWeb'][0]['Email'] = @testDataJSON['CreateLeadFromWeb'][0]['Name'] + SecureRandom.random_number(10000000000).to_s + "@example.com"
            emailId =  @testDataJSON['CreateLeadFromWeb'][0]['Email']
            @driver.find_element(:id, "tourFormEmailField").send_keys emailId
            @driver.find_element(:id, "tourFormPhoneField").clear
            @driver.find_element(:id, "tourFormPhoneField").send_keys @testDataJSON['CreateLeadFromWeb'][0]['Phone']
            sleep(2)
            @driver.find_element(:id, "tourFormStepOneSubmitButton").click
=end
            sleep(5)
            @driver.find_element(:id, "tourFormCompanyNameField").click
            @driver.find_element(:id, "tourFormCompanyNameField").clear
            @driver.find_element(:id, "tourFormCompanyNameField").send_keys @testDataJSON['CreateLeadFromWeb'][0]['Name']
            @driver.find_element(:id, "tourFormNotesField").click
            @driver.find_element(:id, "tourFormNotesField").clear
            @driver.find_element(:id, "tourFormNotesField").send_keys @testDataJSON['CreateLeadFromWeb'][0]['Notes']
            sleep(2)
            @driver.find_element(:id, "tourFormStepTwoSubmitButton").click
            @helper.addLogs('Success')
            sleep(20)

            @helper.addLogs("[Step    ] get building details of #{@testDataJSON['CreateLeadFromWeb'][0]["Building"]}")
            building = @objLeadGeneration.fetchBuildingDetails(@testDataJSON['CreateLeadFromWeb'][0]["Building"])
            expect(building[0]).to_not eq nil
            @helper.addLogs("[Result  ]  Success")

sleep(20)
            passedLogs = @helper.addLogs("[Step    ] get details of Contact")
            contact= @objLeadGeneration.fetchContactDetails(emailId)
            #contact= @objLeadGeneration.fetchContactDetails('Contact',"select id,Name,createdDate,Account.Id,Looking_For_Number_Of_Desk__c,Owner.Id,Owner.Name,RecordType.Name,Number_of_Full_Time_Employees__c,Email,Interested_in_Number_of_Desks__c from Contact where Email = '#{emailId}'")
            expect(contact[0]).to_not eq nil
            expect(contact[0].fetch('Id')).to_not eq nil
            passedLogs = @helper.addLogs("[Result  ]  Success")

            @helper.addLogs('Go to Staging website again and genetate lead')
            expect(@objLeadGeneration.createLead(emailId)).to eq true
=begin            
            @driver.get "https://www-staging.wework.com/buildings/bkc--mumbai"
            sleep(5)
            @driver.find_element(:id, "tourFormContactNameField").send_keys @testDataJSON['CreateLeadFromWeb'][0]['Name']
            @driver.find_element(:id, "tourFormEmailField").send_keys emailId
            @driver.find_element(:id, "tourFormPhoneField").send_keys @testDataJSON['CreateLeadFromWeb'][0]['Phone']
            sleep(2)
            @driver.find_element(:id, "tourFormStepOneSubmitButton").click
=end
            passedLogs = @helper.addLogs("[Result  ]  Success")

            passedLogs = @helper.addLogs("[Step    ] get Journey details")
            journey  = @objLeadGeneration.fetchJourneyDetails(emailId)
            #journey  = @helper.getSalesforceRecord('Journey__c',"SELECT Id,Status__c,NMD_Next_Contact_Date__c,Name FROM Journey__c WHERE Primary_Email__c = '#{emailId}' order by CreatedDate")
            puts journey
            puts journey.size
            #expect(journey.size == 1).to eq true
            expect(journey[journey.size - 1]).to_not eq nil
            expect(journey[journey.size - 1].fetch('Id')).to_not eq nil
            passedLogs = @helper.addLogs("[Result  ]  Success")

            passedLogs = @helper.addLogs("[Step    ] get Activity details")
            whoId  = contact[0].fetch('Id')
            activity  = @helper.getSalesforceRecord('Task',"Select Id,Status,Owner.Name,Owner.Id, Subject, WhoId, Lead_Source__c, Lead_Source_Detail__c, Locations_Interested__c,Type FROM Task WHERE WhoId = '#{whoId}' order by CreatedDate")
            puts activity
            puts activity.size
            #expect(activity.size == 1).to eq true
            expect(activity[activity.size - 1]).to_not eq nil
            expect(activity[activity.size - 1].fetch('Id')).to_not eq nil
            passedLogs = @helper.addLogs("[Result  ]  Success")

            puts "*******************************"

            passedLogs = @helper.addLogs("[Validate] journey:.Name")
            expect(journey[journey.size - 1].fetch('Name')).to match("#{@testDataJSON['CreateLeadFromWeb'][0]['Name']}")
            passedLogs = @helper.addLogs("[Result  ]  Success")

            passedLogs = @helper.addLogs("[Validate] journey:NMD_Next_Contact_Date__c")
            puts journey[journey.size - 1].fetch('NMD_Next_Contact_Date__c')
            puts Date.today
            #expect(journey[0].fetch('NMD_Next_Contact_Date__c')).to eq Date.today.to_s
            passedLogs = @helper.addLogs("[Result  ]  Success")

            passedLogs = @helper.addLogs("[Validate] journey:Status__c")
            puts journey[journey.size - 1].fetch('Status__c')
            expect(journey[journey.size - 1].fetch('Status__c')).to eq "Started"
            passedLogs = @helper.addLogs("[Result  ]  Success")

            puts "******************************"
            passedLogs = @helper.addLogs("[Validate] Activity:Subject")
            expect(activity[activity.size - 1].fetch('Subject')).to eq "Inbound Lead submission"
            passedLogs = @helper.addLogs("[Result  ]  Success")

            passedLogs = @helper.addLogs("[Validate] Activity:Lead_Source__c")
            expect(activity[activity.size - 1].fetch('Lead_Source__c')).to eq "WeWork.com"
            passedLogs = @helper.addLogs("[Result  ]  Success")

            passedLogs = @helper.addLogs("[Validate] Activity:Type")
            expect(activity[activity.size - 1].fetch('Type')).to eq "Website"
            passedLogs = @helper.addLogs("[Result  ]  Success")

            passedLogs = @helper.addLogs("[Validate] Activity:Lead_Source_Detail__c")
            expect(activity[activity.size - 1].fetch('Lead_Source_Detail__c')).to eq "Book A Tour Availability"
            passedLogs = @helper.addLogs("[Result  ]  Success")

            passedLogs = @helper.addLogs("[Validate] Activity:Status")
            expect(activity[activity.size - 1].fetch('Status')).to eq "Not Started"
            passedLogs = @helper.addLogs("[Result  ]  Success")

            @helper.postSuccessResult('2149')
        rescue Exception => e
            puts e
            @helper.postFailResult(e,'2149')
        end
    end



    it "C:2150 To Check New Journey Creation if dupicate lead submisison happens for existing contact which is created within 30 days from today when the existing contact does not have permission to create journey.", :'2150'=> 'true' do
        begin
            @helper.addLogs('C:2150 To Check New Journey Creation if dupicate lead submisison happens for existing contact which is created within 30 days from today when the existing contact does not have permission to create journey.','2150')

            allUsers = @helper.getSalesforceRecord('User',"SELECT id,IsActive FROM User")
            activeUserArray = []
            allUsers.each do |user|
                if user.fetch('IsActive') == 'true' then
                    activeUserArray.push(user.fetch('Id'))
                end
            end
            puts activeUserArray.size


            users = @helper.getSalesforceRecord('Setting__c',"select Data__c from Setting__c Where Name = 'User/Queue Journey Creation'")


            userIds = JSON.parse(users[0].fetch('Data__c'))

            arrOfUsersHavingPermissionToCreateJourney = []
            userIds['allowedUsers'].each do |user|
                arrOfUsersHavingPermissionToCreateJourney.push(user['Id'])
            end


            passedLogs = @helper.addLogs("[Step    ] get all building details")
            buildings = @helper.getSalesforceRecord('Building__c',"SELECT id,Cluster_Sales_Lead_Name__c,name,Community_Lead__c,Market__c,UUID__C FROM Building__c")
            expect(buildings).to_not eq nil
            passedLogs = @helper.addLogs("[Result  ]  Success")




            puts '$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$'
            puts activeUserArray.size
            buildingToSet = nil
            buildings.each do |building|
                puts building
                if (building.fetch('Community_Lead__c') != "") && !(arrOfUsersHavingPermissionToCreateJourney.include? building.fetch('Community_Lead__c')) && (activeUserArray.include? building.fetch('Community_Lead__c')) then
                    puts "CM does not have permission #{building}"
                    buildingToSet = building
                    break;
                end
            end
            puts "+++++++++++++++++++++++++++"
            puts buildingToSet


=begin

        contactToTest = nil
        contacts.each do |contact|
            if arrOfUsersHavingPermissionToCreateJourney.include? contact.fetch('Owner.Id') then
                puts "User has permission #{contact}"
                contactToTest = contact
                break;
            end
        end

        puts contactToTest
        
        if (contactToTest.fetch('Id') == nil ) then
          @helper.addLogs("Contact not present")
        end
        expect(contactToTest).to_not eq nil
        expect(contactToTest.fetch('Id')).to_not eq nil
        passedLogs = @helper.addLogs("[Result  ]  Success")


=end

            @helper.addLogs('Go to Staging website and book a tour')

            @driver.get "https://www-staging.wework.com/buildings/bkc--mumbai"
            sleep(5)
            @driver.find_element(:id, "tourFormContactNameField").clear
            @driver.find_element(:id, "tourFormContactNameField").send_keys @testDataJSON['CreateLeadFromWeb'][0]['Name']
            @driver.find_element(:id, "tourFormEmailField").clear
            @testDataJSON['CreateLeadFromWeb'][0]['Email'] = @testDataJSON['CreateLeadFromWeb'][0]['Name'] + SecureRandom.random_number(10000000000).to_s + "@example.com"
            emailId =  @testDataJSON['CreateLeadFromWeb'][0]['Email']
            @driver.find_element(:id, "tourFormEmailField").send_keys emailId
            @driver.find_element(:id, "tourFormPhoneField").clear
            @driver.find_element(:id, "tourFormPhoneField").send_keys @testDataJSON['CreateLeadFromWeb'][0]['Phone']
            sleep(2)
            @driver.find_element(:id, "tourFormStepOneSubmitButton").click
            sleep(5)
            @driver.find_element(:id, "tourFormCompanyNameField").click
            @driver.find_element(:id, "tourFormCompanyNameField").clear
            @driver.find_element(:id, "tourFormCompanyNameField").send_keys @testDataJSON['CreateLeadFromWeb'][0]['Name']
            @driver.find_element(:id, "tourFormNotesField").click
            @driver.find_element(:id, "tourFormNotesField").clear
            @driver.find_element(:id, "tourFormNotesField").send_keys @testDataJSON['CreateLeadFromWeb'][0]['Notes']
            sleep(2)
            @driver.find_element(:id, "tourFormStepTwoSubmitButton").click
            sleep(5)
            @helper.addLogs('Success')
            sleep(20)

            passedLogs = @helper.addLogs("[Step    ] get building details of #{@testDataJSON['CreateLeadFromWeb'][0]["Building"]}")
            buildingName = @testDataJSON['CreateLeadFromWeb'][0]["Building"]
            building = @helper.getSalesforceRecord('Building__c',"SELECT id,Cluster_Sales_Lead_Name__c,name,Community_Lead__c,Market__c,UUID__C FROM Building__c WHERE Name = '#{buildingName}'")
            expect(building).to_not eq nil
            passedLogs = @helper.addLogs("[Result  ]  Success")

            passedLogs = @helper.addLogs("[Step    ] get details of Contact")
            contact= @helper.getSalesforceRecord('Contact',"select id,Name,createdDate,Account.Id,Looking_For_Number_Of_Desk__c,Owner.Id,Owner.Name,RecordType.Name,Number_of_Full_Time_Employees__c,Email,Interested_in_Number_of_Desks__c from Contact where Email = '#{emailId}'")
            expect(contact[0]).to_not eq nil
            expect(contact[0].fetch('Id')).to_not eq nil
            passedLogs = @helper.addLogs("[Result  ]  Success")

            passedLogs = @helper.addLogs("[Step    ] get Journey details")
            oldJourney  = @helper.getSalesforceRecord('Journey__c',"SELECT Id,Status__c,NMD_Next_Contact_Date__c FROM Journey__c WHERE Primary_Email__c = '#{emailId}'")
            puts oldJourney
            puts oldJourney.size
            #expect(journey.size == 1).to eq true
            expect(oldJourney[0]).to_not eq nil
            expect(oldJourney[0].fetch('Id')).to_not eq nil
            passedLogs = @helper.addLogs("[Result  ]  Success")

            passedLogs = @helper.addLogs("[Step    ] get Activity details")
            contactId  =contact[0].fetch('Id')
            oldActivity  = @helper.getSalesforceRecord('Task',"Select Id,Owner.Name,Owner.Id, Subject, WhoId, Lead_Source__c, Lead_Source_Detail__c, Locations_Interested__c,Type FROM Task WHERE WhoId = '#{contactId}'")
            puts oldActivity
            puts oldActivity.size
            #expect(activity.size == 1).to eq true
            expect(oldActivity[0]).to_not eq nil
            expect(oldActivity[0].fetch('Id')).to_not eq nil
            passedLogs = @helper.addLogs("[Result  ]  Success")

            @helper.addLogs('Go to Staging website again and book a tour')
            @driver.get "https://www-staging.wework.com/buildings/bkc--mumbai"
            sleep(10)
            @driver.find_element(:id, "tourFormContactNameField").send_keys @testDataJSON['CreateLeadFromWeb'][0]['Name']
            @driver.find_element(:id, "tourFormEmailField").send_keys emailId
            @driver.find_element(:id, "tourFormPhoneField").send_keys @testDataJSON['CreateLeadFromWeb'][0]['Phone']
            sleep(10)
            @driver.find_element(:id, "tourFormStepOneSubmitButton").click
            passedLogs = @helper.addLogs("[Result  ]  Success")

            passedLogs = @helper.addLogs("[Step    ] get Journey details")
            newJourney  = @helper.getSalesforceRecord('Journey__c',"SELECT Id,Status__c,NMD_Next_Contact_Date__c FROM Journey__c WHERE Primary_Email__c = '#{emailId}'")
            puts newJourney
            puts newJourney.size
            #expect(journey.size == 1).to eq true
            expect(newJourney[0]).to_not eq nil
            expect(newJourney[0].fetch('Id')).to_not eq nil
            passedLogs = @helper.addLogs("[Result  ]  Success")

            passedLogs = @helper.addLogs("[Step    ] get Activity details")
            leadId  =contact[0].fetch('Id')
            activity  = @helper.getSalesforceRecord('Task',"Select Id,Owner.Name,Owner.Id, Subject, WhoId, Lead_Source__c, Lead_Source_Detail__c, Locations_Interested__c,Type FROM Task WHERE WhoId = '#{emailId}'")
            puts activity
            puts activity.size
            #expect(activity.size == 1).to eq true
            expect(activity[0]).to_not eq nil
            expect(activity[0].fetch('Id')).to_not eq nil
            passedLogs = @helper.addLogs("[Result  ]  Success")

            @helper.postSuccessResult('2150')
        rescue Exception => e
            raise e
            @helper.postFailResult(e,'2150')
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
