
require "selenium-webdriver"
require "rspec"
require_relative File.expand_path('',Dir.pwd )+"/specHelper.rb"
#require_relative File.expand_path('..',Dir.pwd )+"/specHelper.rb"
require_relative '../PageObjects/leadFromWeb.rb'
include RSpec::Expectations

describe "LeadGenerete" do

    before(:all) do
        @helper = Helper.new
        #@driver = Selenium::WebDriver.for :chrome
        @driver = ARGV[0]
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

    it "C:2016 To check whether generation of lead from Website.", :'2016' => 'true' do
        begin
            @helper.addLogs('C:2016 To check whether generation of lead from Website.','2016')

            @testDataJSON['CreateLeadFromWeb'][0]["BuildingName"]  = 'marol'
            @testDataJSON['CreateLeadFromWeb'][0]["City"]  = 'mumbai'
            @testDataJSON['CreateLeadFromWeb'][0]["Building"]  = 'MUM-Marol'


            @helper.addLogs('Go to Staging website and create lead')

            @testDataJSON['CreateLeadFromWeb'][0]['Email'] = @testDataJSON['CreateLeadFromWeb'][0]['Name'] + SecureRandom.random_number(10000000000).to_s + "@example.com"
            emailLead = @testDataJSON['CreateLeadFromWeb'][0]['Email']

            expect(@objLeadGeneration.createLead(emailLead)).to eq true
            @helper.addLogs('Success')

            sleep(10)

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
            expect(journey[0]).to_not eq nil
            @helper.addLogs("[Result  ]  Success")


            @helper.addLogs("[Step    ] get Activity details")
            #activity  = @helper.getSalesforceRecordByRestforce(journey[0].fetch('Id'))
            leadId = lead[0].fetch('Id')
            #activity = @helper.getSalesforceRecordByRestforce("Select Id,Status,Owner.Name,Owner.Id, Subject, WhoId, Lead_Source__c, Lead_Source_Detail__c, Locations_Interested__c,Type FROM Task WHERE WhatId = '#{leadId}'")
            activity  = @helper.getSalesforceRecord('Task',"Select Id,Owner.Name,Owner.Id, Subject, WhoId, Lead_Source__c, Lead_Source_Detail__c, Locations_Interested__c,Type,CreatedDate,Status FROM Task WHERE WhoId = '#{leadId}' order by CreatedDate")
            puts activity
            expect(activity[0]).to_not eq nil
            expect(activity.size == 1).to eq true
            expect(activity[0].fetch('Id')).to_not eq nil
            @helper.addLogs("[Result  ]  Success")

            puts "****************************"

            passedLogs = @helper.addLogs("[Validate] lead:.Name")
            #puts lead[0].fetch('Name')
            expect(lead[0].fetch('Name')).to match("#{@testDataJSON['CreateLeadFromWeb'][0]['Name']}")
            passedLogs = @helper.addLogs("[Result  ]  Success")

            passedLogs = @helper.addLogs("[Validate] lead:Email")
            expect(lead[0].fetch('Email')).to eq @testDataJSON['CreateLeadFromWeb'][0]['Email']
            passedLogs = @helper.addLogs("[Result  ]  Success")

            passedLogs = @helper.addLogs("[Validate] lead:Company")
            expect(lead[0].fetch('Company')).to eq @testDataJSON['CreateLeadFromWeb'][0]['Name']
            passedLogs = @helper.addLogs("[Result  ]  Success")

            passedLogs = @helper.addLogs("[Validate] lead:Phone")
            expect(lead[0].fetch('Phone')).to match("#{@testDataJSON['CreateLeadFromWeb'][0]['Phone']}")
            passedLogs = @helper.addLogs("[Result  ]  Success")

            passedLogs = @helper.addLogs("[Validate] lead:LeadSource")
            expect(lead[0].fetch('LeadSource')).to eq "WeWork.com"
            passedLogs = @helper.addLogs("[Result  ]  Success")

            passedLogs = @helper.addLogs("[Validate] lead:Company_Size__c")
            expect(lead[0].fetch('Company_Size__c').to_i).to eq @testDataJSON['CreateLeadFromWeb'][0]["NumberOfPeople"].split(' ')[0].to_i
            passedLogs = @helper.addLogs("[Result  ]  Success")

            passedLogs = @helper.addLogs("[Validate] lead:Lead_Source_Detail__c")
            expect(lead[0].fetch('Lead_Source_Detail__c')).to eq "Book A Tour Availability"
            passedLogs = @helper.addLogs("[Result  ]  Success")

            passedLogs = @helper.addLogs("[Validate] lead:Status")
            expect(lead[0].fetch('Status')).to eq "Open"
            passedLogs = @helper.addLogs("[Result  ]  Success")


            passedLogs = @helper.addLogs("[Validate] lead:Building_Interested_In__c")
            puts lead[0].fetch('Building_Interested_In__c')
            #expect(lead[0].fetch('Building_Interested_In__c')).to eq "#{building.fetch('Id')}"
            passedLogs = @helper.addLogs("[Result  ]  Success")

            passedLogs = @helper.addLogs("[Validate] lead:Building_Interested_Name__c")
            #puts lead[0].fetch('Building_Interested_Name__c')
            expect(lead[0].fetch('Building_Interested_Name__c')).to eq @testDataJSON['CreateLeadFromWeb'][0]["Building"]
            passedLogs = @helper.addLogs("[Result  ]  Success")

            passedLogs = @helper.addLogs("[Validate] lead:Locations_Interested__c")
            expect(lead[0].fetch('Locations_Interested__c')).to eq @testDataJSON['CreateLeadFromWeb'][0]["Building"]
            passedLogs = @helper.addLogs("[Result  ]  Success")

            puts "*******************************"

            passedLogs = @helper.addLogs("[Validate] journey:.Name")
            expect(journey[0].fetch('Name')).to match("#{@testDataJSON['CreateLeadFromWeb'][0]['Name']}")
            passedLogs = @helper.addLogs("[Result  ]  Success")

            passedLogs = @helper.addLogs("[Validate] journey:NMD_Next_Contact_Date__c")
            #puts journey[0].fetch('NMD_Next_Contact_Date__c')
            #puts Date.today
            expect(journey[0].fetch('NMD_Next_Contact_Date__c')).to eq Date.today.to_s
            passedLogs = @helper.addLogs("[Result  ]  Success")

            passedLogs = @helper.addLogs("[Validate] journey:Status__c")
            expect(journey[0].fetch('Status__c')).to eq "Started"
            passedLogs = @helper.addLogs("[Result  ]  Success")


            puts "******************************"
            passedLogs = @helper.addLogs("[Validate] Activity:Subject")
            expect(activity[0].fetch('Subject')).to eq "Inbound Lead submission"
            passedLogs = @helper.addLogs("[Result  ]  Success")

            passedLogs = @helper.addLogs("[Validate] Activity:Lead_Source__c")
            expect(activity[0].fetch('Lead_Source__c')).to eq "WeWork.com"
            passedLogs = @helper.addLogs("[Result  ]  Success")

            passedLogs = @helper.addLogs("[Validate] Activity:Type")
            expect(activity[0].fetch('Type')).to eq "Website"
            passedLogs = @helper.addLogs("[Result  ]  Success")

            passedLogs = @helper.addLogs("[Validate] Activity:Lead_Source_Detail__c")
            expect(activity[0].fetch('Lead_Source_Detail__c')).to eq "Book A Tour Availability"
            passedLogs = @helper.addLogs("[Result  ]  Success")

            passedLogs = @helper.addLogs("[Validate] Activity:Status")
            expect(activity[0].fetch('Status')).to eq "Not Started"
            passedLogs = @helper.addLogs("[Result  ]  Success")


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
            @helper.postSuccessResult('2016')
        rescue Exception => e
            puts e
            @helper.postFailResult(e,'2016')
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
