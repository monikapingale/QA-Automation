
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
    end

    it "C:2016 To check whether generation of lead from RestAPI.", :'20161' => 'true' do
        begin
            @helper.addLogs('C:2016 To check whether generation of lead from RestAPI.','2016')

            @testDataJSON['LeadJSON'][0]['body']['email'] = @testDataJSON['CreateLeadFromWeb'][0]['Name'] + SecureRandom.random_number(10000000000).to_s + "@example.com"
            @testDataJSON['LeadJSON'][0]['body']['company_name'] = @testDataJSON['LeadJSON'][0]['body']['company_name'] + SecureRandom.random_number(10000000000).to_s
            @testDataJSON['LeadJSON'][0]['body']['buildings_interested_uuids'][0] = @testDataJSON['ExistingRecord']['Staging']['Building'][0]['UUID']
            #@testDataJSON['LeadJSON'][0]['body']['referrer_sfid'] = @testDataJSON['ExistingRecord']['Staging']['Contact'][0]['SFID']
            #@testDataJSON['LeadJSON'][0]['body']['campaign_sfid'] = @testDataJSON['ExistingRecord']['Staging']['Campaign'][0]['SFID']

            @objLeadGeneration.createLeadFromRestApi()
            puts "**************************** Checking Lead Fields ****************************"

            @helper.addLogs("[Step ]     : Fetch lead deatails")            
            insertedLeadInfo = @objLeadGeneration.fetchLeadDetails(@testDataJSON['LeadJSON'][0]['body']['email'])
            expect(insertedLeadInfo).to_not eq nil
            expect(insertedLeadInfo.size).to eq 1
            expect(insertedLeadInfo[0]).to_not eq nil  
            insertedLeadInfo =  insertedLeadInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            puts "&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&"

            puts insertedLeadInfo
            puts "&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&"

            @helper.addLogs("[Validate ] : Checking Lead owner")
            @helper.addLogs("[Expected ] : Vidu Mangrulkar")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Owner").fetch("Name")}")
            expect(insertedLeadInfo.fetch("Owner").fetch("Name")).to eql 'Vidu Mangrulkar'
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead referrer_sfid")
            @helper.addLogs("[Expected ] : ")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Referrer__r")}")
            expect(insertedLeadInfo.fetch("Referrer__r")).to eql nil #@testDataJSON['LeadJSON'][0]['body']['referrer_sfid']
            @helper.addLogs("[Result ]   : Success\n")
            
            leadExpectedEqlHash = {'Phone'=> @testDataJSON['LeadJSON'][0]['body']['phone'],'Name'=>@testDataJSON['LeadJSON'][0]['body']['first_name'] + ' ' +@testDataJSON['LeadJSON'][0]['body']['last_name'],'Company_Size__c'=>@testDataJSON['LeadJSON'][0]['body']['company_size'],'Building_Interested_Name__c'=>@testDataJSON['ExistingRecord']['Staging']['Building'][0]['Name'],'Building_Interested_In__c' => @testDataJSON['ExistingRecord']['Staging']['Building'][0]['SFID'],'Generate_Journey__c' => false,'Has_Active_Journey__c' => true ,'LeadSource' => 'WeWork.com','Country_Code__c' =>@testDataJSON['LeadJSON'][0]['body']['country_code'],'Locale__c'=>@testDataJSON['LeadJSON'][0]['body']['locale'],'Product_Line__c'=>@testDataJSON['LeadJSON'][0]['body']['product_line'],'Interested_in_Number_of_Desks_Max__c'=>@testDataJSON['LeadJSON'][0]['body']['desks_interested_max'].to_f,'Interested_in_Number_of_Desks_Min__c'=>@testDataJSON['LeadJSON'][0]['body']['desks_interested_min'].to_f,'Interested_in_Number_of_Desks_Range__c'=> @testDataJSON['LeadJSON'][0]['body']['desks_interested_range'],'Ts_and_Cs_Consent__c'=>false,'Marketing_Consent__c'=> false,'Email_Quality__c'=>'Pending','Type__c'=>@testDataJSON['LeadJSON'][0]['body']['product_interests'][0],'Status'=>'Open','Company'=>@testDataJSON['LeadJSON'][0]['body']['company_name'],'Email'=>@testDataJSON['LeadJSON'][0]['body']['email'],'Lead_Source_Detail__c'=>'Book A Tour Form','Journey_Created_On__c'=> Date.today.to_s,'Industry'=>@testDataJSON['LeadJSON'][0]['body']['company_industry'],'Quick_Quote_Location__c'=>@testDataJSON['LeadJSON'][0]['body']['quick_quote_location'],'Promo_Code__c'=>@testDataJSON['LeadJSON'][0]['body']['promo_code'],'Referral_Fail_Reason__c'=>@testDataJSON['LeadJSON'][0]['body']['referral_fail_reason'],'Affiliate_Consent__c'=>false,'Interested_in_Number_of_Desks__c'=>@testDataJSON['LeadJSON'][0]['body']['desks_interested_min'].to_f}
            validate_case_eql('Lead',insertedLeadInfo,leadExpectedEqlHash)          

            puts "**************************** Checking Journey Fields ****************************"

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
            expect(insertedJourneyInfo.fetch("Owner").fetch("Name")).to eql "#{insertedLeadInfo.fetch("Owner").fetch("Name")}"
            @helper.addLogs("[Result ]   : Success\n")

            journeyExpectHash = {'Lead_Source__c'=>insertedLeadInfo.fetch("LeadSource"),'Lead_Source_Detail__c'=>insertedLeadInfo.fetch("Lead_Source_Detail__c"),'NMD_Next_Contact_Date__c'=>insertedLeadInfo.fetch("Journey_Created_On__c"),'Primary_Email__c'=>insertedLeadInfo.fetch("Email"),'Primary_Phone__c'=>insertedLeadInfo.fetch("Phone"),'Company_Name__c'=>insertedLeadInfo.fetch("Company"),'Status__c'=>'Started','Primary_Lead__c'=>insertedLeadInfo.fetch("Id"),'Looking_For_Number_Of_Desk__c'=>insertedLeadInfo.fetch("Interested_in_Number_of_Desks__c"),'Record_Type__c'=>insertedLeadInfo.fetch("RecordType").fetch("Name"),'Marketing_Consent__c'=>false,'Ts_and_Cs_Consent__c'=>false,'CampaignId__c'=>nil}
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
            @helper.addLogs("[Expected ] : Veena Hegane")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Owner").fetch("Name")}")
            expect(generatedActivityForLead.fetch("Owner").fetch("Name")).to eql 'Veena Hegane'
            @helper.addLogs("[Result ]   : Success\n")

            activityExpectHash = {'Subject'=>'Inbound Lead submission','Type'=>'Website','Priority'=>'Normal','Lead_Source_Detail__c'=>insertedLeadInfo.fetch("Lead_Source_Detail__c"),'Lead_Source__c'=>insertedLeadInfo.fetch("LeadSource"),'Status'=>'Not Started'}
            validate_case_eql('Activity',generatedActivityForLead,activityExpectHash)

            
            @helper.postSuccessResult('2016')
        rescue Exception => e
            puts e
            @helper.postFailResult(e,'2016')
        end
    end

    it "C:2016 To check whether generation of lead from RestAPI.", :'20162' => 'true' do
        begin
            @helper.addLogs('C:2016 To check whether generation of lead from RestAPI.','2016')

            @testDataJSON['LeadJSON'][0]['body']['email'] = @testDataJSON['CreateLeadFromWeb'][0]['Name'] + SecureRandom.random_number(10000000000).to_s + "@example.com"
            @testDataJSON['LeadJSON'][0]['body']['company_name'] = @testDataJSON['LeadJSON'][0]['body']['company_name'] + SecureRandom.random_number(10000000000).to_s
            @testDataJSON['LeadJSON'][0]['body']['buildings_interested_uuids'][0] = @testDataJSON['ExistingRecord']['Staging']['Building'][0]['UUID']
            
            @testDataJSON['LeadJSON'][0]['body']['referrer_sfid'] = @testDataJSON['ExistingRecord']['Staging']['Contact'][0]['SFID']
            @testDataJSON['LeadJSON'][0]['body']['campaign_sfid'] = @testDataJSON['ExistingRecord']['Staging']['Campaign'][0]['SFID']

            @objLeadGeneration.createLeadFromRestApi()

            puts "**************************** Checking Lead Fields ****************************"

            @helper.addLogs("[Step ]     : Fetch lead deatails")            
            insertedLeadInfo = @objLeadGeneration.fetchLeadDetails(@testDataJSON['LeadJSON'][0]['body']['email'])
            expect(insertedLeadInfo).to_not eq nil
            expect(insertedLeadInfo.size).to eq 1
            expect(insertedLeadInfo[0]).to_not eq nil  
            insertedLeadInfo =  insertedLeadInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            puts "&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&"

            puts insertedLeadInfo

            puts "&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&"

            expectedOwner = @objLeadGeneration.getOwnerByCampaignAssignment(@testDataJSON['ExistingRecord']['Staging']['Campaign'][0]['Name'])

            puts expectedOwner

            @helper.addLogs("[Validate ] : Checking Lead owner")
            @helper.addLogs("[Expected ] : Vidu Mangrulkar")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Owner").fetch("Name")}")
            expect(insertedLeadInfo.fetch("Owner").fetch("Id")).to eql expectedOwner
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead referrer_sfid")
            @helper.addLogs("[Expected ] : #{@testDataJSON['ExistingRecord']['Staging']['Contact'][0]['SFID']}")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Referrer__r").fetch('Id')}")
            expect(insertedLeadInfo.fetch("Referrer__r").fetch('Id')).to match(@testDataJSON['LeadJSON'][0]['body']['referrer_sfid'])
            @helper.addLogs("[Result ]   : Success\n")
            
            leadExpectedEqlHash = {'Phone'=> @testDataJSON['LeadJSON'][0]['body']['phone'],'Name'=>@testDataJSON['LeadJSON'][0]['body']['first_name'] + ' ' +@testDataJSON['LeadJSON'][0]['body']['last_name'],'Company_Size__c'=>@testDataJSON['LeadJSON'][0]['body']['company_size'],'Building_Interested_Name__c'=>@testDataJSON['ExistingRecord']['Staging']['Building'][0]['Name'],'Building_Interested_In__c' => @testDataJSON['ExistingRecord']['Staging']['Building'][0]['SFID'],'Generate_Journey__c' => false,'Has_Active_Journey__c' => true ,'LeadSource' => 'WeWork.com','Country_Code__c' =>@testDataJSON['LeadJSON'][0]['body']['country_code'],'Locale__c'=>@testDataJSON['LeadJSON'][0]['body']['locale'],'Product_Line__c'=>@testDataJSON['LeadJSON'][0]['body']['product_line'],'Interested_in_Number_of_Desks_Max__c'=>@testDataJSON['LeadJSON'][0]['body']['desks_interested_max'].to_f,'Interested_in_Number_of_Desks_Min__c'=>@testDataJSON['LeadJSON'][0]['body']['desks_interested_min'].to_f,'Interested_in_Number_of_Desks_Range__c'=> @testDataJSON['LeadJSON'][0]['body']['desks_interested_range'],'Ts_and_Cs_Consent__c'=>false,'Marketing_Consent__c'=> false,'Email_Quality__c'=>'Pending','Type__c'=>@testDataJSON['LeadJSON'][0]['body']['product_interests'][0],'Status'=>'Open','Company'=>@testDataJSON['LeadJSON'][0]['body']['company_name'],'Email'=>@testDataJSON['LeadJSON'][0]['body']['email'],'Lead_Source_Detail__c'=>'Book A Tour Form','Journey_Created_On__c'=> Date.today.to_s,'Industry'=>@testDataJSON['LeadJSON'][0]['body']['company_industry'],'Quick_Quote_Location__c'=>@testDataJSON['LeadJSON'][0]['body']['quick_quote_location'],'Promo_Code__c'=>@testDataJSON['LeadJSON'][0]['body']['promo_code'],'Referral_Fail_Reason__c'=>@testDataJSON['LeadJSON'][0]['body']['referral_fail_reason'],'Affiliate_Consent__c'=>false,'Interested_in_Number_of_Desks__c'=>@testDataJSON['LeadJSON'][0]['body']['desks_interested_min'].to_f}
            validate_case_eql('Lead',insertedLeadInfo,leadExpectedEqlHash)          

            puts "**************************** Checking Journey Fields ****************************"

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
            expect(insertedJourneyInfo.fetch("Owner").fetch("Name")).to eql "#{insertedLeadInfo.fetch("Owner").fetch("Name")}"
            @helper.addLogs("[Result ]   : Success\n")

            journeyExpectHash = {'Lead_Source__c'=>insertedLeadInfo.fetch("LeadSource"),'Lead_Source_Detail__c'=>insertedLeadInfo.fetch("Lead_Source_Detail__c"),'NMD_Next_Contact_Date__c'=>insertedLeadInfo.fetch("Journey_Created_On__c"),'Primary_Email__c'=>insertedLeadInfo.fetch("Email"),'Primary_Phone__c'=>insertedLeadInfo.fetch("Phone"),'Company_Name__c'=>insertedLeadInfo.fetch("Company"),'Status__c'=>'Started','Primary_Lead__c'=>insertedLeadInfo.fetch("Id"),'Looking_For_Number_Of_Desk__c'=>insertedLeadInfo.fetch("Interested_in_Number_of_Desks__c"),'Record_Type__c'=>insertedLeadInfo.fetch("RecordType").fetch("Name"),'Marketing_Consent__c'=>false,'Ts_and_Cs_Consent__c'=>false,'CampaignId__c'=>@testDataJSON['LeadJSON'][0]['body']['campaign_sfid']}
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
            @helper.addLogs("[Expected ] : Veena Hegane")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Owner").fetch("Name")}")
            expect(generatedActivityForLead.fetch("Owner").fetch("Name")).to eql 'Veena Hegane'
            @helper.addLogs("[Result ]   : Success\n")

            activityExpectHash = {'Subject'=>'Inbound Lead submission','Type'=>'Website','Priority'=>'Normal','Lead_Source_Detail__c'=>insertedLeadInfo.fetch("Lead_Source_Detail__c"),'Lead_Source__c'=>insertedLeadInfo.fetch("LeadSource"),'Status'=>'Not Started'}
            validate_case_eql('Activity',generatedActivityForLead,activityExpectHash)

            @helper.postSuccessResult('2016')
        rescue Exception => e
            puts e
            @helper.postFailResult(e,'2016')
        end
    end

    it "C:2016 To check whether generation of lead from RestAPI.", :'20163' => 'true' do
        begin
            @helper.addLogs('C:2016 To check whether generation of lead from RestAPI.','2016')

            @testDataJSON['LeadJSON'][0]['body']['email'] = @testDataJSON['ExistingRecord']['Staging']['Lead'][0]['Email']
            @testDataJSON['LeadJSON'][0]['body']['company_name'] = @testDataJSON['LeadJSON'][0]['body']['company_name'] + SecureRandom.random_number(10000000000).to_s
            @testDataJSON['LeadJSON'][0]['body']['buildings_interested_uuids'][0] = @testDataJSON['ExistingRecord']['Staging']['Building'][0]['UUID']
            
            @testDataJSON['LeadJSON'][0]['body']['referrer_sfid'] = @testDataJSON['ExistingRecord']['Staging']['Contact'][0]['SFID']
            @testDataJSON['LeadJSON'][0]['body']['campaign_sfid'] = @testDataJSON['ExistingRecord']['Staging']['Campaign'][0]['SFID']

            responce = @objLeadGeneration.createLeadFromRestApi()

            puts "**************************** Checking Lead Fields ****************************"

            @helper.addLogs("[Step ]     : Fetch lead deatails")            
            insertedLeadInfo = @objLeadGeneration.fetchLeadDetails(@testDataJSON['LeadJSON'][0]['body']['email'])
            expect(insertedLeadInfo).to_not eq nil
            expect(insertedLeadInfo.size).to eq 1
            expect(insertedLeadInfo[0]).to_not eq nil  
            insertedLeadInfo =  insertedLeadInfo[0]      
            @helper.addLogs("[Result ]   : Success\n")

            puts "&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&"

            puts insertedLeadInfo
            puts "&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&"

            @helper.addLogs("[Validate ] : Checking Lead owner")
            @helper.addLogs("[Expected ] : Vidu Mangrulkar")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Owner").fetch("Name")}")
            expect(insertedLeadInfo.fetch("Owner").fetch("Name")).to eql 'Vidu Mangrulkar'
            @helper.addLogs("[Result ]   : Success\n")

            @helper.addLogs("[Validate ] : Checking Lead referrer_sfid")
            @helper.addLogs("[Expected ] : ")
            @helper.addLogs("[Actual ]   : #{insertedLeadInfo.fetch("Referrer__r")}")
            expect(insertedLeadInfo.fetch("Referrer__r")).to eql nil #@testDataJSON['LeadJSON'][0]['body']['referrer_sfid']
            @helper.addLogs("[Result ]   : Success\n")
            
            leadExpectedEqlHash = {'Phone'=> @testDataJSON['LeadJSON'][0]['body']['phone'],'Name'=>@testDataJSON['LeadJSON'][0]['body']['first_name'] + ' ' +@testDataJSON['LeadJSON'][0]['body']['last_name'],'Company_Size__c'=>@testDataJSON['LeadJSON'][0]['body']['company_size'],'Building_Interested_Name__c'=>@testDataJSON['ExistingRecord']['Staging']['Building'][0]['Name'],'Building_Interested_In__c' => @testDataJSON['ExistingRecord']['Staging']['Building'][0]['SFID'],'Generate_Journey__c' => false,'Has_Active_Journey__c' => true ,'LeadSource' => 'WeWork.com','Country_Code__c' =>@testDataJSON['LeadJSON'][0]['body']['country_code'],'Locale__c'=>@testDataJSON['LeadJSON'][0]['body']['locale'],'Product_Line__c'=>@testDataJSON['LeadJSON'][0]['body']['product_line'],'Interested_in_Number_of_Desks_Max__c'=>@testDataJSON['LeadJSON'][0]['body']['desks_interested_max'].to_f,'Interested_in_Number_of_Desks_Min__c'=>@testDataJSON['LeadJSON'][0]['body']['desks_interested_min'].to_f,'Interested_in_Number_of_Desks_Range__c'=> @testDataJSON['LeadJSON'][0]['body']['desks_interested_range'],'Ts_and_Cs_Consent__c'=>false,'Marketing_Consent__c'=> false,'Email_Quality__c'=>'Pending','Type__c'=>@testDataJSON['LeadJSON'][0]['body']['product_interests'][0],'Status'=>'Open','Company'=>@testDataJSON['LeadJSON'][0]['body']['company_name'],'Email'=>@testDataJSON['LeadJSON'][0]['body']['email'],'Lead_Source_Detail__c'=>'Book A Tour Form','Journey_Created_On__c'=> Date.today.to_s,'Industry'=>@testDataJSON['LeadJSON'][0]['body']['company_industry'],'Quick_Quote_Location__c'=>@testDataJSON['LeadJSON'][0]['body']['quick_quote_location'],'Promo_Code__c'=>@testDataJSON['LeadJSON'][0]['body']['promo_code'],'Referral_Fail_Reason__c'=>@testDataJSON['LeadJSON'][0]['body']['referral_fail_reason'],'Affiliate_Consent__c'=>false,'Interested_in_Number_of_Desks__c'=>@testDataJSON['LeadJSON'][0]['body']['desks_interested_min'].to_f}
            validate_case_eql('Lead',insertedLeadInfo,leadExpectedEqlHash)          

            puts "**************************** Checking Journey Fields ****************************"

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
            expect(insertedJourneyInfo.fetch("Owner").fetch("Name")).to eql "#{insertedLeadInfo.fetch("Owner").fetch("Name")}"
            @helper.addLogs("[Result ]   : Success\n")

            journeyExpectHash = {'Lead_Source__c'=>insertedLeadInfo.fetch("LeadSource"),'Lead_Source_Detail__c'=>insertedLeadInfo.fetch("Lead_Source_Detail__c"),'NMD_Next_Contact_Date__c'=>insertedLeadInfo.fetch("Journey_Created_On__c"),'Primary_Email__c'=>insertedLeadInfo.fetch("Email"),'Primary_Phone__c'=>insertedLeadInfo.fetch("Phone"),'Company_Name__c'=>insertedLeadInfo.fetch("Company"),'Status__c'=>'Started','Primary_Lead__c'=>insertedLeadInfo.fetch("Id"),'Looking_For_Number_Of_Desk__c'=>insertedLeadInfo.fetch("Interested_in_Number_of_Desks__c"),'Record_Type__c'=>insertedLeadInfo.fetch("RecordType").fetch("Name"),'Marketing_Consent__c'=>false,'Ts_and_Cs_Consent__c'=>false,'CampaignId__c'=>nil}
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
            @helper.addLogs("[Expected ] : Veena Hegane")
            @helper.addLogs("[Actual ]   : #{generatedActivityForLead.fetch("Owner").fetch("Name")}")
            expect(generatedActivityForLead.fetch("Owner").fetch("Name")).to eql 'Veena Hegane'
            @helper.addLogs("[Result ]   : Success\n")

            activityExpectHash = {'Subject'=>'Inbound Lead submission','Type'=>'Website','Priority'=>'Normal','Lead_Source_Detail__c'=>insertedLeadInfo.fetch("Lead_Source_Detail__c"),'Lead_Source__c'=>insertedLeadInfo.fetch("LeadSource"),'Status'=>'Not Started'}
            validate_case_eql('Activity',generatedActivityForLead,activityExpectHash)

            @helper.postSuccessResult('2016')
        rescue Exception => e
            puts e
            @helper.postFailResult(e,'2016')
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
