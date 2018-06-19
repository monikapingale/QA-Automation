=begin
************************************************************************************************************************************
   Author      :   Monika Pingale
   Description :   This spec will automate inboun call functionality of sales console.

   History     :
 ----------------------------------------------------------------------------------------------------------------------------------
 VERSION            DATE             AUTHOR                  DETAIL
 1                 24 May 2018       Monika Pingale          Initial Developement
**************************************************************************************************************************************
=end
require 'json'
require 'selenium-webdriver'
require 'rspec'
require 'date'
require 'enziUIUtility'
require_relative File.expand_path('../../../../', Dir.pwd) + '/specHelper.rb'
require_relative File.expand_path('..', Dir.pwd) + '/Page Objects/inbound_call.rb'
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
    @helper.go_to_app(@driver,"Sales Console")
    @pageObject = Kickbox_Importer.new(@driver, @helper)
    button = EnziUIUtility.selectElement(@driver, "Lead/Contact Search", "button")
    @helper.instance_variable_get(:@wait).until {button.displayed?}
    button.click
    @settings = @helper.instance_variable_get(:@restForce).getRecords("SELECT name,Data__c FROM Setting__c WHERE name IN ('User/Queue Journey Creation','Lead:Lead and Lead Source Details')")
  end
  after(:all) do
    @verification_errors.should == []
    @helper.deleteSalesforceRecordBySfbulk("Journey__c", EnziRestforce.class_variable_get(:@@createdRecordsIds)["Journey__c"])
    @helper.deleteSalesforceRecordBySfbulk("Lead", EnziRestforce.class_variable_get(:@@createdRecordsIds)["Lead"])
  end
  it "To Check Journey Creation if user and queue permission is checked and lead source is checked and Override lead source detail checkbox is unchecked and lead source detail is checked.", :'2546' => 'true' do
    @helper.addLogs("[Step ]     : Create Lead record with consumer record type")
    if !@driver.find_elements(:id, "scc_widget_Inbound_Call").empty?
      EnziUIUtility.switchToFrame @driver, "scc_widget_Inbound_Call"
    end
    @pageObject.createLead(false)
    @helper.instance_variable_get(:@wait).until {!@driver.find_element(:id, "spinnerContainer").displayed?}
    @helper.instance_variable_get(:@wait).until {@driver.find_element(:id, "enzTable").displayed?}
    insertedLeadInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Owner.Name, LeadSource , Lead_Source_Detail__c , Building_Interested_In__c , Building_Interested_Name__c ,Journey_Created_On__c, Locations_Interested__c , Number_of_Full_Time_Employees__c , Interested_in_Number_of_Desks__c , Email , Phone , Company , Name , RecordType.Name , Status , Type__c FROM Lead WHERE Email = '#{@testDataJSON['Lead'][0]['Email']}'")
    insertedJourneyInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,Owner.Name, CreatedDate ,Status__c , NMD_Next_Contact_Date__c ,Primary_Email__c , Lead_Source__c , Lead_Source_Detail__c , Primary_Phone__c , Company_Name__c , Building_Interested_In__c , Locations_Interested__c , Interested_in_Number_of_Desks__c , Full_Time_Employees__c, Name   FROM Journey__c WHERE Primary_Email__c = '#{@testDataJSON['Lead'][0]['Email']}'")
    @helper.addLogs("[Validate ] : Checking Lead is created after form submission")
    @helper.addLogs("[Expected ] : Lead should create with name #{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
    @helper.addLogs("[Actual ]   : Lead is created with name #{insertedLeadInfo[0].fetch("Name")}")
    expect(insertedLeadInfo).to_not eql nil
    Helper.addRecordsToDelete("Lead", insertedLeadInfo[0].fetch('Id'))
    insertedLeadInfo = insertedLeadInfo[0]
    @helper.addLogs("[Result ]   : Lead insertion checked successfully\n")
    @helper.addLogs("[Validate ] : Checking Lead owner should be logged in user")
    @helper.addLogs("[Expected ] : Owner of lead should be Logged in user")
    @helper.addLogs("[Actual ]   : Owner of lead is #{insertedLeadInfo.fetch("Owner").fetch("Name")}")
    expect(insertedLeadInfo.fetch("Owner").fetch("Name")).to eql @userInfo.fetch("display_name")
    @helper.addLogs("[Result ]   : Owner checked successfully\n")
    @helper.addLogs("[Validate ] : Checking Lead source")
    @helper.addLogs("[Expected ] : Lead source should be Inbound Call")
    @helper.addLogs("[Actual ]   : Lead is created with lead source #{insertedLeadInfo.fetch("LeadSource")}")
    expect(insertedLeadInfo.fetch("LeadSource")).to eql "Inbound Call"
    @helper.addLogs("[Result ]   : Lead source checked successfully\n")
    @helper.addLogs("[Validate ] : Checking Lead source details")
    @helper.addLogs("[Expected ] : Lead source detail should be Inbound Call Page")
    @helper.addLogs("[Actual ]   : Lead is created with lead source detail #{insertedLeadInfo.fetch("Lead_Source_Detail__c")}")
    expect(insertedLeadInfo.fetch("Lead_Source_Detail__c")).to eql "Inbound Call Page"
    @helper.addLogs("[Result ]   : Lead source detail checked successfully\n")
    @helper.addLogs("[Validate ] : Checking building interested name on Lead")
    @helper.addLogs("[Expected ] : Building interested name should be #{@testDataJSON['Lead'][0]['Building_Interested_In__c']}")
    @helper.addLogs("[Actual ]   : Lead is created with building interested name #{insertedLeadInfo.fetch("Building_Interested_Name__c")}")
    expect(insertedLeadInfo.fetch("Building_Interested_Name__c")).to eql @testDataJSON['Lead'][0]["Building_Interested_In__c"]
    @helper.addLogs("[Result ]   : Building interested name on Lead checked successfully\n")
    @helper.addLogs("[Validate ] : Checking building interested")
    @helper.addLogs("[Expected ] : Building interested should be #{@testDataJSON['Lead'][0]["Building_Interested_In__c"]}")
    @helper.addLogs("[Actual ]   : Lead is created with building interested #{insertedLeadInfo.fetch("Building_Interested_In__c")}")
    expect(insertedLeadInfo.fetch("Building_Interested_In__c")).to eql @helper.instance_variable_get(:@restForce).getRecords("SELECT id FROM Building__c WHERE Name = '#{@testDataJSON['Lead'][0]["Building_Interested_In__c"]}'")[0].fetch("Id")
    @helper.addLogs("[Result ]   : Building interested on Lead checked successfully\n")
    @helper.addLogs("[Validate ] : Checking Journey created date on lead")
    @helper.addLogs("[Expected ] : Journey created date should be #{insertedJourneyInfo[0].fetch("CreatedDate")}")
    @helper.addLogs("[Actual ]   : Lead is created with Journey created date #{insertedLeadInfo.fetch("Journey_Created_On__c")}")
    #expect(insertedLeadInfo.fetch("Journey_Created_On__c")).to eql DateTime.parse(insertedJourneyInfo[0].fetch("CreatedDate")).to_date
    @helper.addLogs("[Result ]   : Journey created date on Lead checked successfully\n")
    @helper.addLogs("[Validate ] : Checking Interested in Number of Desks on lead")
    @helper.addLogs("[Expected ] : Interested in Number of Desks should be #{@testDataJSON['Lead'][0]['Interested_in_Number_of_Desks__c']}.0")
    @helper.addLogs("[Actual ]   : Lead is created with Interested in Number of Desks #{insertedLeadInfo.fetch("Interested_in_Number_of_Desks__c")}")
    expect("#{insertedLeadInfo.fetch('Interested_in_Number_of_Desks__c')}").to eql "#{@testDataJSON['Lead'][0]['Interested_in_Number_of_Desks__c']}.0"
    @helper.addLogs("[Result ]   : Interested in Number of Desks on Lead checked successfully\n")
    @helper.addLogs("[Validate ] : Checking Locations Interested on lead")
    @helper.addLogs("[Expected ] : Locations Interested should be #{@testDataJSON['Lead'][0]["Building_Interested_In__c"]}")
    @helper.addLogs("[Actual ]   : Lead is created with Locations Interested #{insertedLeadInfo.fetch("Locations_Interested__c")}")
    expect(insertedLeadInfo.fetch("Locations_Interested__c")).to eql @testDataJSON['Lead'][0]["Building_Interested_In__c"]
    @helper.addLogs("[Result ]   : Locations Interested on Lead checked successfully\n")
    @helper.addLogs("[Validate ] : Checking Number of Full Time Employees on lead")
    @helper.addLogs("[Expected ] : Number of Full Time Employees should be #{@testDataJSON['Lead'][0]['Number_of_Full_Time_Employees__c']}.0")
    @helper.addLogs("[Actual ]   : Lead is created with Number of Full Time Employees #{insertedLeadInfo.fetch("Number_of_Full_Time_Employees__c")}")
    expect("#{insertedLeadInfo.fetch('Number_of_Full_Time_Employees__c')}").to eql "#{@testDataJSON['Lead'][0]['Number_of_Full_Time_Employees__c']}.0"
    @helper.addLogs("[Result ]   : Number of Full Time Employees on Lead checked successfully\n")
    @helper.addLogs("[Validate ] : Checking Email on lead")
    @helper.addLogs("[Expected ] : Email should be #{@testDataJSON['Lead'][0]['Email']}")
    @helper.addLogs("[Actual ]   : Lead is created with Email #{insertedLeadInfo.fetch("Email")}")
    expect(insertedLeadInfo.fetch("Email")).to eql @testDataJSON['Lead'][0]['Email']
    @helper.addLogs("[Result ]   : Email on Lead checked successfully\n")
    @helper.addLogs("[Validate ] : Checking Phone on lead")
    @helper.addLogs("[Expected ] : Number of Phone should be #{@testDataJSON['Lead'][0]['Phone']}")
    @helper.addLogs("[Actual ]   : Lead is created with Phone #{insertedLeadInfo.fetch("Phone")}")
    expect(insertedLeadInfo.fetch("Phone")).to eql @testDataJSON['Lead'][0]['Phone']
    @helper.addLogs("[Result ]   : Phone on Lead checked successfully\n")
    @helper.addLogs("[Validate ] : Checking Company on lead")
    @helper.addLogs("[Expected ] : Company should be #{@testDataJSON['Lead'][0]['Company']}")
    @helper.addLogs("[Actual ]   : Lead is created with Company #{insertedLeadInfo.fetch("Company")}")
    expect(insertedLeadInfo.fetch("Company")).to eql @testDataJSON['Lead'][0]['Company']
    @helper.addLogs("[Result ]   : Company on Lead checked successfully\n")
    @helper.addLogs("[Validate ] : Checking RecordType on lead")
    @helper.addLogs("[Expected ] : RecordType should be Consumer")
    @helper.addLogs("[Actual ]   : Lead is created with RecordType #{insertedLeadInfo.fetch('RecordType').fetch('Name')}")
    expect(insertedLeadInfo.fetch("RecordType").fetch("Name")).to eql "Consumer"
    @helper.addLogs("[Result ]   : RecordType on Lead checked successfully\n")
    @helper.addLogs("[Validate ] : Checking Status on lead")
    @helper.addLogs("[Expected ] : Status should be open")
    @helper.addLogs("[Actual ]   : Lead is created with Status #{insertedLeadInfo.fetch("Status")}")
    expect(insertedLeadInfo.fetch("Status")).to eql "Open"
    @helper.addLogs("[Result ]   : Status on Lead checked successfully\n")
    @helper.addLogs("[Validate ] : Checking Type on lead")
    @helper.addLogs("[Expected ] : Type should be office space")
    @helper.addLogs("[Actual ]   : Lead is created with Type #{insertedLeadInfo.fetch("Type__c")}")
    expect(insertedLeadInfo.fetch("Type__c")).to eql "Office Space"
    @helper.addLogs("[Result ]   : Type on Lead checked successfully\n")
    @helper.addLogs("[Step ]     : Checking logged in user has journey creation permission")
    JSON.parse(@settings[1]["Data__c"])["allowedUsers"].each do |user|
      if user["Id"].eql? @userInfo.fetch("user_id")
        @userHasPermission = true
      end
    end
    @helper.addLogs("[Result ]   : LoggedIn User is in setting - #{@userHasPermission ? "Yes" : "No"}\n")
    @helper.addLogs("[Step ]     : Checking Inbound call has permission for journey creation")
    JSON.parse(@settings[0]["Data__c"])["LeadSource"].each do |source|
      if source['name'].eql? "Inbound Call"
        @isSourceHasPermission = true
        @overrideLeadSource = source["OverrideLeadSoruce"]
      end
    end
    puts @isSourceHasPermission
    puts @overrideLeadSource
    @helper.addLogs("[Result ]   : Inbound lead has journey creation permission - #{@isSourceHasPermission ? "Yes" : "No"}\n")
    @helper.addLogs("[Step ]     : Checking override lead source for Inbound call ")
    @helper.addLogs("[Result ]   : Override lead source for Inbound call is - #{@overrideLeadSource ? "Checked" : "Unchecked"}\n")
    insertedJourneyInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,Owner.Name, CreatedDate ,Status__c , NMD_Next_Contact_Date__c ,Primary_Email__c , Lead_Source__c , Lead_Source_Detail__c , Primary_Phone__c , Company_Name__c , Building_Interested_In__c , Locations_Interested__c , Interested_in_Number_of_Desks__c , Full_Time_Employees__c, Name   FROM Journey__c WHERE Primary_Email__c = '#{@testDataJSON['Lead'][0]['Email']}'")
    Helper.addRecordsToDelete("Journey__c", insertedJourneyInfo[0].fetch('Id'))
    if @userHasPermission && @isSourceHasPermission
      if !@overrideLeadSource
        @helper.addLogs("[Step ]  : Checking LeadSourceDetails has permission for journey creation")
        isLeadSourceDetailHasPermission = false
        JSON.parse(@settings[0]["Data__c"])["LeadSourceDetails"].each do |source|
          if source.eql? "Inbound Call Page"
            isLeadSourceDetailHasPermission = true
          end
        end
        puts isLeadSourceDetailHasPermission
        @helper.addLogs("[Result ]     : LeadSourceDetails has journey creation permission - #{isLeadSourceDetailHasPermission ? "Yes" : "No"}\n")
        if isLeadSourceDetailHasPermission
          @helper.addLogs("[Validate ] : Checking Journey is created on lead")
          @helper.addLogs("[Expected ] : Journey should create with name #{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
          @helper.addLogs("[Actual ]   : Journey is created with name #{insertedJourneyInfo[0].fetch("Name")}")
          expect(insertedJourneyInfo).to_not eql nil
          expect(insertedJourneyInfo[0].fetch("Name")).to match "#{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}"
          @helper.addLogs("[Result ]   : Journey created successfully\n")
          insertedJourneyInfo = insertedJourneyInfo[0]
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
          @helper.addLogs("[Validate ] : Checking Lead source details on Journey")
          @helper.addLogs("[Expected ] : Lead source detail should be Inbound Call Page")
          @helper.addLogs("[Actual ]   : Lead is created with lead source detail #{insertedJourneyInfo.fetch("Lead_Source_Detail__c")}")
          expect(insertedJourneyInfo.fetch("Lead_Source_Detail__c")).to eql "Inbound Call Page"
          @helper.addLogs("[Result ]   : Lead source detail checked successfully\n")
          @helper.addLogs("[Validate ] : Checking building interested name on Journey")
          @helper.addLogs("[Expected ] : Building interested should be #{@testDataJSON['Lead'][0]['Building_Interested_In__c']}")
          @helper.addLogs("[Actual ]   : Journey is created with building interested name #{insertedJourneyInfo.fetch("Building_Interested_In__c")}")
          expect(insertedJourneyInfo.fetch("Building_Interested_In__c")).to eql @helper.instance_variable_get(:@restForce).getRecords("SELECT id FROM Building__c WHERE Name = '#{@testDataJSON['Lead'][0]["Building_Interested_In__c"]}'")[0].fetch("Id")
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
          expect(insertedJourneyInfo.fetch("Locations_Interested__c")).to eql @testDataJSON['Lead'][0]["Building_Interested_In__c"]
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
        else
          expect(insertedJourneyInfo).to eql nil
        end
      end
    else
      expect(insertedJourneyInfo).to eql nil
    end
  end
  it "To Check Journey Creation if User and Queue permission is checked and lead source is checked and override lead source detail is checked and lead source detail checkbox is checked.", '2548' => 'true' do
    @helper.addLogs("[Step ] : Create Lead record with consumer record type")
    @testDataJSON['Lead'][0]['Email'] = "john.snow_qaauto-#{rand(99999999)}@example.com"
    @testDataJSON['Lead'][0]['CompanySize'] = 10
    @testDataJSON['Lead'][0]['NumberofDesks'] = 5
    if !@driver.find_elements(:id, "scc_widget_Inbound_Call").empty?
      EnziUIUtility.switchToFrame @driver, "scc_widget_Inbound_Call"
    end
    @pageObject.createLead(true)
    @helper.instance_variable_get(:@wait).until {!@driver.find_element(:id, "spinnerContainer").displayed?}
    @helper.instance_variable_get(:@wait).until {@driver.find_element(:id, "enzTable").displayed?}
    insertedLeadInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Owner.Name,CreatedDate, LeadSource , Lead_Source_Detail__c , Building_Interested_In__c , Building_Interested_Name__c ,Journey_Created_On__c, Locations_Interested__c , Number_of_Full_Time_Employees__c , Interested_in_Number_of_Desks__c , Email , Phone , Company , Name , RecordType.Name , Status , Type__c FROM Lead WHERE Email = '#{@testDataJSON['Lead'][0]['Email']}'")
    @helper.addLogs("[Validate ] : Checking Lead is created after form submission")
    @helper.addLogs("[Expected ] : Lead should create with name #{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
    @helper.addLogs("[Actual ]   : Lead is created with name #{insertedLeadInfo[0].fetch("Name")}")
    expect(insertedLeadInfo).to_not eql nil
    Helper.addRecordsToDelete("Lead", insertedLeadInfo[0].fetch('Id'))
    insertedLeadInfo = insertedLeadInfo[0]
    @helper.addLogs("[Result ]   : Lead insertion checked successfully\n")
    @helper.addLogs("[Validate ] : Checking Lead owner should be logged in user")
    @helper.addLogs("[Expected ] : Owner of lead should be Logged in user")
    @helper.addLogs("[Actual ]   : Owner of lead is #{insertedLeadInfo.fetch("Owner").fetch("Name")}")
    expect(insertedLeadInfo.fetch("Owner").fetch("Name")).to eql @userInfo.fetch("display_name")
    @helper.addLogs("[Result ]   : Owner checked successfully\n")
    @helper.addLogs("[Validate ] : Checking Lead source")
    @helper.addLogs("[Expected ] : Lead source should be Inbound Call")
    @helper.addLogs("[Actual ]   : Lead is created with lead source #{insertedLeadInfo.fetch("LeadSource")}")
    expect(insertedLeadInfo.fetch("LeadSource")).to eql "Inbound Call"
    @helper.addLogs("[Result ]   : Lead source checked successfully\n")
    @helper.addLogs("[Validate ] : Checking building interested name on Lead")
    @helper.addLogs("[Expected ] : Building interested name should be #{@testDataJSON['Lead'][0]['Building_Interested_In__c']}")
    @helper.addLogs("[Actual ]   : Lead is created with building interested name #{insertedLeadInfo.fetch("Building_Interested_Name__c")}")
    expect(insertedLeadInfo.fetch("Building_Interested_Name__c")).to eql @testDataJSON['Lead'][0]["Building_Interested_In__c"]
    @helper.addLogs("[Result ]   : Building interested name on Lead checked successfully\n")
    @helper.addLogs("[Validate ] : Checking building interested")
    @helper.addLogs("[Expected ] : Building interested should be #{@testDataJSON['Lead'][0]["Building_Interested_In__c"]}")
    @helper.addLogs("[Actual ]   : Lead is created with building interested #{insertedLeadInfo.fetch("Building_Interested_In__c")}")
    expect(insertedLeadInfo.fetch("Building_Interested_In__c")).to eql @helper.instance_variable_get(:@restForce).getRecords("SELECT id FROM Building__c WHERE Name = '#{@testDataJSON['Lead'][0]["Building_Interested_In__c"]}'")[0].fetch("Id")
    @helper.addLogs("[Result ]   : Building interested on Lead checked successfully\n")
    @helper.addLogs("[Validate ] : Checking Journey created date on lead")
    @helper.addLogs("[Expected ] : Journey created date should be #{insertedLeadInfo.fetch("CreatedDate")}")
    @helper.addLogs("[Actual ]   : Lead is created with Journey created date #{insertedLeadInfo.fetch("Journey_Created_On__c")}")
    #expect(insertedLeadInfo.fetch("Journey_Created_On__c")).to eql insertedJourneyInfo[0].fetch("CreatedDate")
    @helper.addLogs("[Result ]   : Journey created date on Lead checked successfully\n")
    @helper.addLogs("[Validate ] : Checking Interested in Number of Desks on lead")
    @helper.addLogs("[Expected ] : Interested in Number of Desks should be #{@testDataJSON['Lead'][0]['NumberofDesks']}.0")
    @helper.addLogs("[Actual ]   : Lead is created with Interested in Number of Desks #{insertedLeadInfo.fetch("Interested_in_Number_of_Desks__c")}")
    expect("#{insertedLeadInfo.fetch('Interested_in_Number_of_Desks__c')}").to eql "#{@testDataJSON['Lead'][0]['NumberofDesks']}.0"
    @helper.addLogs("[Result ]   : Interested in Number of Desks on Lead checked successfully\n")
    @helper.addLogs("[Validate ] : Checking Locations Interested on lead")
    @helper.addLogs("[Expected ] : Locations Interested should be #{@testDataJSON['Lead'][0]["Building_Interested_In__c"]}")
    @helper.addLogs("[Actual ]   : Lead is created with Locations Interested #{insertedLeadInfo.fetch("Locations_Interested__c")}")
    expect(insertedLeadInfo.fetch("Locations_Interested__c")).to eql @testDataJSON['Lead'][0]["Building_Interested_In__c"]
    @helper.addLogs("[Result ]   : Locations Interested on Lead checked successfully\n")
    @helper.addLogs("[Validate ] : Checking Number of Full Time Employees on lead")
    @helper.addLogs("[Expected ] : Number of Full Time Employees should be #{@testDataJSON['Lead'][0]['CompanySize']}.0")
    @helper.addLogs("[Actual ]   : Lead is created with Number of Full Time Employees #{insertedLeadInfo.fetch("Number_of_Full_Time_Employees__c")}")
    expect("#{insertedLeadInfo.fetch('Number_of_Full_Time_Employees__c')}").to eql "#{@testDataJSON['Lead'][0]['CompanySize']}.0"
    @helper.addLogs("[Result ]   : Number of Full Time Employees on Lead checked successfully\n")
    @helper.addLogs("[Validate ] : Checking Email on lead")
    @helper.addLogs("[Expected ] : Email should be #{@testDataJSON['Lead'][0]['Email']}")
    @helper.addLogs("[Actual ]   : Lead is created with Email #{insertedLeadInfo.fetch("Email")}")
    expect(insertedLeadInfo.fetch("Email")).to eql @testDataJSON['Lead'][0]['Email']
    @helper.addLogs("[Result ]   : Email on Lead checked successfully\n")
    @helper.addLogs("[Validate ] : Checking Phone on lead")
    @helper.addLogs("[Expected ] : Number of Phone should be #{@testDataJSON['Lead'][0]['Phone']}")
    @helper.addLogs("[Actual ]   : Lead is created with Phone #{insertedLeadInfo.fetch("Phone")}")
    expect(insertedLeadInfo.fetch("Phone")).to eql @testDataJSON['Lead'][0]['Phone']
    @helper.addLogs("[Result ]   : Phone on Lead checked successfully\n")
    @helper.addLogs("[Validate ] : Checking Company on lead")
    @helper.addLogs("[Expected ] : Company should be #{@testDataJSON['Lead'][0]['Company']}")
    @helper.addLogs("[Actual ]   : Lead is created with Company #{insertedLeadInfo.fetch("Company")}")
    expect(insertedLeadInfo.fetch("Company")).to eql @testDataJSON['Lead'][0]['Company']
    @helper.addLogs("[Result ]   : Company on Lead checked successfully\n")
    @helper.addLogs("[Validate ] : Checking RecordType on lead")
    @helper.addLogs("[Expected ] : RecordType should be Consumer")
    @helper.addLogs("[Actual ]   : Lead is created with RecordType #{insertedLeadInfo.fetch("RecordType").fetch("Name")}")
    expect(insertedLeadInfo.fetch("RecordType").fetch("Name")).to eql "Consumer"
    @helper.addLogs("[Result ]   : RecordType on Lead checked successfully\n")
    @helper.addLogs("[Validate ] : Checking Status on lead")
    @helper.addLogs("[Expected ] : Status should be Open")
    @helper.addLogs("[Actual ]   : Lead is created with Status #{insertedLeadInfo.fetch("Status")}")
    expect(insertedLeadInfo.fetch("Status")).to eql "Open"
    @helper.addLogs("[Result ]   : Status on Lead checked successfully\n")
    @helper.addLogs("[Validate ] : Checking Type on lead")
    @helper.addLogs("[Expected ] : Type should be Office Space")
    @helper.addLogs("[Actual ]   : Lead is created with Type #{insertedLeadInfo.fetch("Type__c")}")
    expect(insertedLeadInfo.fetch("Type__c")).to eql "Office Space"
    @helper.addLogs("[Result ]   : Type on Lead checked successfully\n")
    @helper.addLogs("[Step ]     : Checking logged in user has journey creation permission")
    JSON.parse(@settings[1]["Data__c"])["allowedUsers"].each do |user|
      if user["Id"].eql? @userInfo.fetch("user_id")
        @userHasPermission = true
      end
    end

    @helper.addLogs("[Result ]   : LoggedIn User is in setting - #{@userHasPermission ? "Yes" : "No"}\n")
    @helper.addLogs("[Step ]     : Checking Inbound call has permission for journey creation")
    JSON.parse(@settings[0]["Data__c"])["LeadSource"].each do |source|
      if source['name'].eql? "Inbound Call"
        @isSourceHasPermission = true
        @overrideLeadSource = source["OverrideLeadSoruce"]
      end
    end
    @helper.addLogs("[Result ]   : Inbound lead has journey creation permission - #{@isSourceHasPermission ? "Yes" : "No"}\n")
    @helper.addLogs("[Step ]     : Checking override lead source for Inbound call ")
    @helper.addLogs("[Result ]   : Override lead source for Inbound call is - #{@overrideLeadSource ? "Checked" : "Unchecked"}\n")
    insertedJourneyInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,Owner.Name, CreatedDate ,Status__c , NMD_Next_Contact_Date__c ,Primary_Email__c , Lead_Source__c , Lead_Source_Detail__c , Primary_Phone__c , Company_Name__c , Building_Interested_In__c , Locations_Interested__c , Interested_in_Number_of_Desks__c , Full_Time_Employees__c, Name   FROM Journey__c WHERE Primary_Email__c = '#{@testDataJSON['Lead'][0]['Email']}'")

    Helper.addRecordsToDelete("Journey__c", insertedJourneyInfo[0].fetch('Id'))
    if @userHasPermission && @isSourceHasPermission
      if !@overrideLeadSource
        @helper.addLogs("[Step ]  : Checking LeadSourceDetails has permission for journey creation")
        isLeadSourceDetailHasPermission = false
        JSON.parse(@settings[0]["Data__c"])["LeadSourceDetails"].each do |source|
          if source.eql? "Inbound Call Page"
            isLeadSourceDetailHasPermission = true
          end
        end
        @helper.addLogs("[Result ]   : LeadSourceDetails has journey creation permission - #{isLeadSourceDetailHasPermission ? "Yes" : "No"}\n")
        if isLeadSourceDetailHasPermission
          @helper.addLogs("[Validate ] : Checking Journey is created on lead")
          @helper.addLogs("[Expected ] : Journey should create with name #{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
          @helper.addLogs("[Actual ]   : Journey is created with name #{insertedJourneyInfo.fetch("Name")}")
          expect(insertedJourneyInfo).to_not eql nil
          expect(insertedJourneyInfo.fetch("Name")).to eql "#{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}"
          @helper.addLogs("[Result ]   : Journey created successfully\n")
          insertedJourneyInfo = insertedJourneyInfo[0]
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
        else
          expect(insertedJourneyInfo).to eql nil
        end
      end
    else
      expect(insertedJourneyInfo).to eql nil
    end
  end
  it "To Check Journey Creation If User and Queue permission is checked and Lead Source is checked and override lead source detail is unchecked and lead source detail is unchecked.", '2549' => 'true' do
    @helper.addLogs("[Step ] : Create Lead record with consumer record type")
    @testDataJSON['Lead'][0]['Email'] = "john.snow_qaauto-#{rand(99999999)}@example.com"
    @testDataJSON['Lead'][0]['CompanySize'] = 10
    @testDataJSON['Lead'][0]['NumberofDesks'] = 5
    if !@driver.find_elements(:id, "scc_widget_Inbound_Call").empty?
      EnziUIUtility.switchToFrame @driver, "scc_widget_Inbound_Call"
    end
    @pageObject.createLead(true)
    @helper.instance_variable_get(:@wait).until {!@driver.find_element(:id, "spinnerContainer").displayed?}
    @helper.instance_variable_get(:@wait).until {@driver.find_element(:id, "enzTable").displayed?}
    insertedLeadInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Owner.Name, LeadSource , Lead_Source_Detail__c , Building_Interested_In__c , Building_Interested_Name__c ,Journey_Created_On__c, Locations_Interested__c , Number_of_Full_Time_Employees__c , Interested_in_Number_of_Desks__c , Email , Phone , Company , Name , RecordType.Name , Status , Type__c FROM Lead WHERE Email = '#{@testDataJSON['Lead'][0]['Email']}'")
    @helper.addLogs("[Validate ] : Checking Lead is created after form submission")
    @helper.addLogs("[Expected ] : Lead should create with name #{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
    @helper.addLogs("[Actual ]   : Lead is created with name #{insertedLeadInfo[0].fetch("Name")}")
    expect(insertedLeadInfo).to_not eql nil
    EnziRestforce.class_variable_get(:@@createdRecordsIds)["Lead"] = [Hash["Id" => insertedLeadInfo[0].fetch('Id')]]
    insertedLeadInfo = insertedLeadInfo[0]
    @helper.addLogs("[Result ]   : Lead insertion checked successfully\n")
    @helper.addLogs("[Step ]     : Checking logged in user has journey creation permission")
    JSON.parse(@settings[1]["Data__c"])["allowedUsers"].each do |user|
      if user["Id"].eql? @userInfo.fetch("user_id")
        @userHasPermission = true
      end
    end
    @helper.addLogs("[Result ]   : LoggedIn User is in setting - #{@userHasPermission ? "Yes" : "No"}\n")
    @helper.addLogs("[Step ]     : Checking Inbound call has permission for journey creation")
    JSON.parse(@settings[0]["Data__c"])["LeadSource"].each do |source|
      if source['name'].eql? "Inbound Call"
        @isSourceHasPermission = true
        @overrideLeadSource = source["OverrideLeadSoruce"]
      end
    end
    @helper.addLogs("[Result ]   : Inbound lead has journey creation permission - #{@isSourceHasPermission ? "Yes" : "No"}\n")
    @helper.addLogs("[Step ]     : Checking override lead source for Inbound call ")
    @helper.addLogs("[Result ]   : Override lead source for Inbound call is - #{@overrideLeadSource ? "Checked" : "Unchecked"}\n")
    insertedJourneyInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,Owner.Name, CreatedDate ,Status__c , NMD_Next_Contact_Date__c ,Primary_Email__c , Lead_Source__c , Lead_Source_Detail__c , Primary_Phone__c , Company_Name__c , Building_Interested_In__c , Locations_Interested__c , Interested_in_Number_of_Desks__c , Full_Time_Employees__c, Name   FROM Journey__c WHERE Primary_Email__c = '#{@testDataJSON['Lead'][0]['Email']}'")
    EnziRestforce.class_variable_get(:@@createdRecordsIds)["Journey__c"] = [Hash["Id" => insertedJourneyInfo[0].fetch('Id')]]
    if @userHasPermission && @isSourceHasPermission
      if !@overrideLeadSource
        @helper.addLogs("[Step ]  : Checking LeadSourceDetails has permission for journey creation")
        isLeadSourceDetailHasPermission = false
        JSON.parse(@settings[0]["Data__c"])["LeadSourceDetails"].each do |source|
          if source.eql? "Inbound Call Page"
            isLeadSourceDetailHasPermission = true
          end
        end
        @helper.addLogs("[Result ]   : LeadSourceDetails has journey creation permission - #{isLeadSourceDetailHasPermission ? "Yes" : "No"}\n")
        @helper.addLogs("[Validate ] : Checking Journey is created")
        @helper.addLogs("[Expected ] : Journey should not created as lead source detail is mandatory")
        @helper.addLogs("[Actual ]   : Journey created - #{insertedJourneyInfo ? "Yes" : "No"}")
        expect(insertedJourneyInfo).to eql nil
        @helper.addLogs("[Result ]   : Journey creation checked successfully\n")
      end
    end
  end
  it "To Check Journey Creation If User and Queue permission is checked and lead source is checked and override lead source detail is Unchecked and lead source detail is checked.", :'2550' => 'true' do
    @helper.addLogs("[Step ] : Create Lead record with consumer record type")
    @testDataJSON['Lead'][0]['Email'] = "john.snow_qaauto-#{rand(99999999)}@example.com"
    @testDataJSON['Lead'][0]['CompanySize'] = 10
    @testDataJSON['Lead'][0]['NumberofDesks'] = 5
    if !@driver.find_elements(:id, "scc_widget_Inbound_Call").empty?
      EnziUIUtility.switchToFrame @driver, "scc_widget_Inbound_Call"
    end
    @pageObject.createLead(true)
    @helper.instance_variable_get(:@wait).until {!@driver.find_element(:id, "spinnerContainer").displayed?}
    @helper.instance_variable_get(:@wait).until {@driver.find_element(:id, "enzTable").displayed?}
    insertedLeadInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Owner.Name, LeadSource , Lead_Source_Detail__c , Building_Interested_In__c , Building_Interested_Name__c ,Journey_Created_On__c, Locations_Interested__c , Number_of_Full_Time_Employees__c , Interested_in_Number_of_Desks__c , Email , Phone , Company , Name , RecordType.Name , Status , Type__c FROM Lead WHERE Email = '#{@testDataJSON['Lead'][0]['Email']}'")
    @helper.addLogs("[Validate ] : Checking Lead is created after form submission")
    @helper.addLogs("[Expected ] : Lead should create with name #{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
    @helper.addLogs("[Actual ]   : Lead is created with name #{insertedLeadInfo[0].fetch("Name")}")
    expect(insertedLeadInfo).to_not eql nil
    Helper.addRecordsToDelete("Lead", insertedLeadInfo[0].fetch('Id'))
    insertedLeadInfo = insertedLeadInfo[0]
    @helper.addLogs("[Result ]   : Lead insertion checked successfully\n")
    @helper.addLogs("[Step ]     : Checking logged in user has journey creation permission")
    JSON.parse(@settings[1]["Data__c"])["allowedUsers"].each do |user|
      if user["Id"].eql? @userInfo.fetch("user_id")
        @userHasPermission = true
      end
    end
    @helper.addLogs("[Result ]   : LoggedIn User is in setting - #{@userHasPermission ? "Yes" : "No"}\n")
    @helper.addLogs("[Step ]     : Checking Inbound call has permission for journey creation")
    JSON.parse(@settings[0]["Data__c"])["LeadSource"].each do |source|
      if source['name'].eql? "Inbound Call"
        @isSourceHasPermission = true
        @overrideLeadSource = source["OverrideLeadSoruce"]
      end
    end
    @helper.addLogs("[Result ]   : Inbound lead has journey creation permission - #{@isSourceHasPermission ? "Yes" : "No"}\n")
    @helper.addLogs("[Step ]     : Checking override lead source for Inbound call ")
    @helper.addLogs("[Result ]   : Override lead source for Inbound call is - #{@overrideLeadSource ? "Checked" : "Unchecked"}\n")
    insertedJourneyInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,Owner.Name, CreatedDate ,Status__c , NMD_Next_Contact_Date__c ,Primary_Email__c , Lead_Source__c , Lead_Source_Detail__c , Primary_Phone__c , Company_Name__c , Building_Interested_In__c , Locations_Interested__c , Interested_in_Number_of_Desks__c , Full_Time_Employees__c, Name   FROM Journey__c WHERE Primary_Email__c = '#{@testDataJSON['Lead'][0]['Email']}'")
    Helper.addRecordsToDelete("Journey__c", insertedJourneyInfo[0].fetch('Id'))
    if @userHasPermission && @isSourceHasPermission
      if !@overrideLeadSource
        @helper.addLogs("[Step ]  : Checking LeadSourceDetails has permission for journey creation")
        isLeadSourceDetailHasPermission = false
        JSON.parse(@settings[0]["Data__c"])["LeadSourceDetails"].each do |source|
          if source.eql? "Inbound Call Page"
            isLeadSourceDetailHasPermission = true
          end
        end
        @helper.addLogs("[Result ]   : LeadSourceDetails has journey creation permission - #{isLeadSourceDetailHasPermission ? "Yes" : "No"}\n")
        @helper.addLogs("[Validate ] : Checking Journey is created")
        @helper.addLogs("[Expected ] : Journey should not create")
        @helper.addLogs("[Actual ]   : Journey created - #{insertedJourneyInfo ? "Yes" : "No"}")
        expect(insertedJourneyInfo).to eql nil
        @helper.addLogs("[Result ]   : Journey creation checked successfully\n")
      end
    end
  end
  it "To Check Journey Creation If User and Queue permission is unchecked and lead source is checked and Override lead source detail is checked and lead source detail is checked.", :'2551' => 'true' do
    @helper.addLogs("[Step ] : Create Lead record with consumer record type")
    @testDataJSON['Lead'][0]['Email'] = "john.snow_qaauto-#{rand(99999999)}@example.com"
    @testDataJSON['Lead'][0]['CompanySize'] = 10
    @testDataJSON['Lead'][0]['NumberofDesks'] = 5
    if !@driver.find_elements(:id, "scc_widget_Inbound_Call").empty?
      EnziUIUtility.switchToFrame @driver, "scc_widget_Inbound_Call"
    end
    @pageObject.createLead(true)
    @helper.instance_variable_get(:@wait).until {!@driver.find_element(:id, "spinnerContainer").displayed?}
    @helper.instance_variable_get(:@wait).until {@driver.find_element(:id, "enzTable").displayed?}
    insertedLeadInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Owner.Name, LeadSource , Lead_Source_Detail__c , Building_Interested_In__c , Building_Interested_Name__c ,Journey_Created_On__c, Locations_Interested__c , Number_of_Full_Time_Employees__c , Interested_in_Number_of_Desks__c , Email , Phone , Company , Name , RecordType.Name , Status , Type__c FROM Lead WHERE Email = '#{@testDataJSON['Lead'][0]['Email']}'")
    @helper.addLogs("[Validate ] : Checking Lead is created after form submission")
    @helper.addLogs("[Expected ] : Lead should create with name #{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
    @helper.addLogs("[Actual ]   : Lead is created with name #{insertedLeadInfo[0].fetch("Name")}")
    expect(insertedLeadInfo).to_not eql nil
    Helper.addRecordsToDelete("Lead", insertedLeadInfo[0].fetch('Id'))
    insertedLeadInfo = insertedLeadInfo[0]
    @helper.addLogs("[Result ]   : Lead insertion checked successfully\n")
    @helper.addLogs("[Step ]     : Checking logged in user has journey creation permission")
    JSON.parse(@settings[1]["Data__c"])["allowedUsers"].each do |user|
      if user["Id"].eql? @userInfo.fetch("user_id")
        @userHasPermission = true
      end
    end
    @helper.addLogs("[Result ]   : LoggedIn User is in setting - #{@userHasPermission ? "Yes" : "No"}\n")
    insertedJourneyInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,Owner.Name, CreatedDate ,Status__c , NMD_Next_Contact_Date__c ,Primary_Email__c , Lead_Source__c , Lead_Source_Detail__c , Primary_Phone__c , Company_Name__c , Building_Interested_In__c , Locations_Interested__c , Interested_in_Number_of_Desks__c , Full_Time_Employees__c, Name   FROM Journey__c WHERE Primary_Email__c = '#{@testDataJSON['Lead'][0]['Email']}'")
    @helper.addLogs("[Validate ] : Checking Journey is created")
    if !@userHasPermission
      @helper.addLogs("[Expected ] : Journey should not create")
      @helper.addLogs("[Actual ]   : Journey created - #{insertedJourneyInfo[0] ? "Yes" : "No"}")
      expect(insertedJourneyInfo[0]).to eql nil
      Helper.addRecordsToDelete("Journey__c", insertedJourneyInfo[0].fetch('Id'))
      @helper.addLogs("[Result ]   : Journey creation checked successfully\n")
    else
      @helper.addLogs("[Expected ] : Journey should create")
      @helper.addLogs("[Actual ]   : Journey created - #{insertedJourneyInfo[0] ? "Yes" : "No"}")
      expect(insertedJourneyInfo[0]).to_not eql nil
      @helper.addLogs("[Result ]   : Journey creation checked successfully\n")
    end
  end
  it "To Check of journey updation on duplicate lead submission, if an open journey already exist in system with created date within 4 days from today.", :'2537' => 'true' do
    @helper.addLogs("[Step ] : Create duplicate lead with existing lead email which is created within 4 days")
    existingLead = @helper.getExistingLead((Date.today).to_datetime,4)
    puts existingLead
    @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Email'] = existingLead.fetch("Email")
    @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Number_of_Full_Time_Employees__c'] = 10
    @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Interested_in_Number_of_Desks__c'] = 5
    @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Locations_Interested__c'] = "LA-Santa Monica"
    if !@driver.find_elements(:id, "scc_widget_Inbound_Call").empty?
      EnziUIUtility.switchToFrame @driver, "scc_widget_Inbound_Call"
    end
    @pageObject.createLead(false)
    existingJourneyInfo = @pageObject.getRecord("SELECT id ,Status__c ,Lead_Source__c , Lead_Source_Detail__c, NMD_Next_Contact_Date__c FROM Journey__c WHERE Primary_Email__c = '#{existingLead.fetch("Email")}'")[0]
    sleep(10)
    generatedActivityForLead = @pageObject.getRecord("SELECT id , Subject , CreatedDate,Status ,Lead_Source__c , Lead_Source_Detail__c,Owner.Name,Locations_Interested__c, Number_of_Full_Time_Employees__c,Interested_in_Number_of_Desks__c,Company__c,WhoId FROM Task WHERE WhoId = '#{existingLead.fetch('Id')}' AND CreatedDate=TODAY")[0]
    puts generatedActivityForLead.inspect
    @helper.addLogs("[Validate ] : Checking Next Contact Date on existing Journey")
    @helper.addLogs("[Expected ] : Next Contact Date on existing Journey should update with duplicate lead submission date")
    @helper.addLogs("[Actual ]   : Next Contact Date on existing Journey is #{existingJourneyInfo.fetch("NMD_Next_Contact_Date__c")}")
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
    expect(generatedActivityForLead.fetch("Company__c")).to eql existingLead.fetch('Company')
    @helper.addLogs("[Result ]   : Activity Status field checked successfully")
    @helper.addLogs("[Validate ] : Checking Location interested on activity")
    @helper.addLogs("[Expected ] : Location interested on activity should be #{@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Locations_Interested__c']}")
    @helper.addLogs("[Actual ]   : Location interested on activity is #{generatedActivityForLead.fetch("Locations_Interested__c")}")
    expect(generatedActivityForLead.fetch("Locations_Interested__c")).to eql @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Locations_Interested__c']
    @helper.addLogs("[Result ]   : Activity Location interested field checked successfully")
    @helper.addLogs("[Validate ] : Checking Location interested on activity")

  end
  it "To check New journey creation if duplicate lead submission happens for existing lead which is created after 4 days and within 30 days from today when the Existing Lead Owner has permission to generate a Journey.", :'2543' => 'true' do
    @helper.addLogs("[Step ] : Create duplicate lead with existing lead email which is created within 4 and 30 days")
    existingLead = @helper.getExistingLead((Date.today - 4).to_datetime,4)
    @testDataJSON['Lead'][0]['Email'] = existingLead.fetch("Email")
    @testDataJSON['Lead'][0]['CompanySize'] = 10
    @testDataJSON['Lead'][0]['NumberofDesks'] = 5
    if !@driver.find_elements(:id, "scc_widget_Inbound_Call").empty?
      EnziUIUtility.switchToFrame @driver, "scc_widget_Inbound_Call"
    end
    @pageObject.createLead(true)
    @helper.addLogs("[Step ] : Getting created activity info")
    existingJourneyInfo = @pageObject.getRecord("SELECT id ,Status__c ,Lead_Source__c , Lead_Source_Detail__c, NMD_Next_Contact_Date__c FROM Journey__c WHERE Primary_Email__c = '#{existingLeadInfo.fetch("Email")}'")[0]
    generatedActivityForLead = @pageObject.getRecord("SELECT id , Subject , CreatedDate,Status ,Lead_Source__c , Lead_Source_Detail__c,Owner.Name,Locations_Interested__c, Number_of_Full_Time_Employees__c,Interested_in_Number_of_Desks__c,Company__c,WhoId FROM Task WHERE WhoId = '#{existingLeadInfo['id']}'")[0]

    @helper.addLogs("[Validate ] : Checking Next Contact Date on existing Journey")
    @helper.addLogs("[Expected ] : Next Contact Date on existing Journey should update with duplicate lead submission date")
    @helper.addLogs("[Actual ]   : Next Contact Date on existing Journey is #{existingJourneyInfo.fetch("NMD_Next_Contact_Date__c")}")
    Helper.addRecordsToDelete("Journey__c", existingJourneyInfo.fetch('Id'))
    expect(existingJourneyInfo.fetch("NMD_Next_Contact_Date__c")).to eql generatedActivityForLead.fetch("CreatedDate")
    @helper.addLogs("[Validate ] : Checking Next Contact Date on existing Journey")
    @helper.addLogs("[Expected ] : Next Contact Date on existing Journey should update with duplicate lead submission date")
    @helper.addLogs("[Actual ]   : Next Contact Date on existing Journey is #{existingJourneyInfo.fetch("NMD_Next_Contact_Date__c")}")
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
    expect(generatedActivityForLead.fetch("Company__c")).to eql existingLeadInfo.fetch('Company')
    @helper.addLogs("[Result ]   : Activity Status field checked successfully")
    @helper.addLogs("[Validate ] : Checking Location interested on activity")
    @helper.addLogs("[Expected ] : Location interested on activity should be #{existingLeadInfo.fetch('Locations_Interested__c')}")
    @helper.addLogs("[Actual ]   : Location interested on activity is #{generatedActivityForLead.fetch("Status")}")
    expect(generatedActivityForLead.fetch("Locations_Interested__c")).to eql existingLeadInfo.fetch('Locations_Interested__c')
    @helper.addLogs("[Result ]   : Activity Location interested field checked successfully")
    @helper.addLogs("[Validate ] : Checking Location interested on activity")
    @helper.addLogs("[Expected ] : Number of full time employees on activity should be #{existingLeadInfo.fetch('Number_of_Full_Time_Employees__c')}")
    @helper.addLogs("[Actual ]   : Number of full time employees on activity is #{generatedActivityForLead.fetch("Number_of_Full_Time_Employees__c")}")
    expect(generatedActivityForLead.fetch("Number_of_Full_Time_Employees__c")).to eql existingLeadInfo.fetch('Number_of_Full_Time_Employees__c')
    @helper.addLogs("[Result ]   : Activity Number of full time employees field checked successfully")
    @helper.addLogs("[Validate ] : Checking Number of desks on activity")
    @helper.addLogs("[Expected ] : Checking Number of desks on activity should be #{existingLeadInfo.fetch('Number_of_Full_Time_Employees__c')}")
    @helper.addLogs("[Actual ]   : Checking Number of desks on activity is #{generatedActivityForLead.fetch("Number_of_Full_Time_Employees__c")}")
    expect(generatedActivityForLead.fetch("Interested_in_Number_of_Desks__c")).to eql existingLeadInfo.fetch('Interested_in_Number_of_Desks__c')
    @helper.addLogs("[Result ]   : Activity Number of desks field checked successfully")
  end
  it "To Check New Journey Creation if duplicate lead submission happens for existing contact which is created after 4 days and within 30 days from today when the existing contact has permission to Generate journey.", :'2552' => 'true' do
    @helper.addLogs("[Step ] : Create duplicate contact with existing contact email which is created within 4 and 30 days")
    until @userHasPermission
      existContactInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,Email, Owner.Name,Owner.id FROM Contact WHERE CreatedBy.Name IN ('Veena Hegane','Ashotosh Thakur','Monika Pingale','Kishor Shinde') AND Email like '%@example.com' AND CreatedDate = LAST_N_DAYS:5")
      if existContactInfo.nil?
        existContactInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Owner.Name,Email FROM Contact WHERE CreatedBy.Name IN ('Veena Hegane','Ashotosh Thakur','Monika Pingale','Kishor Shinde') AND Email like '%@example.com' AND CreatedDate = LAST_N_DAYS:30")
        @settings.each do |user|
          existContactInfo.each do |contact|
            if user["Id"].eql? contact.fetch("Owner").fetch("Id")
              @userHasPermission = true
              existContactInfo = contact
              break;
            end
          end
        end
      else
        JSON.parse(@settings[1]["Data__c"])["allowedUsers"].each do |user|
          if user["Id"].eql?(existContactInfo[0].fetch("Owner").fetch("Id"))
            puts user.inspect
            @userHasPermission = true
            existContactInfo = existContactInfo[0]
            break;
          end
        end
      end
    end
    @testDataJSON['Lead'][0]['Email'] = existContactInfo.fetch("Email")
    @testDataJSON['Lead'][0]['CompanySize'] = 10
    @testDataJSON['Lead'][0]['NumberofDesks'] = 5
    if !@driver.find_elements(:id, "scc_widget_Inbound_Call").empty?
      EnziUIUtility.switchToFrame @driver, "scc_widget_Inbound_Call"
    end
    @pageObject.createLead(false)
    createdJourneyInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,Status__c,Number_of_Full_Time_Employees__c,Interested_in_Number_of_Desks__c, Locations_Interested__c,Name,Lead_Source__c ,Owner.Name, Lead_Source_Detail__c, NMD_Next_Contact_Date__c,Primary_Email__c FROM Journey__c WHERE Primary_Email__c = '#{existContactInfo.fetch("Email")}'")[0]
    generatedActivityForLead = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Subject , CreatedDate,Status , Owner.Name,Lead_Source__c , Lead_Source_Detail__c,Locations_Interested__c, Number_of_Full_Time_Employees__c,Interested_in_Number_of_Desks__c,Company__c,WhoId FROM Task WHERE WhoId = '#{existContactInfo.fetch('Id')}'")[0]
    Helper.addRecordsToDelete("Journey__c", createdJourneyInfo.fetch('Id'))
    @helper.addLogs("[Validate ] : Checking Journey creation for duplicate contact creation")
    @helper.addLogs("[Expected ] : Journey should be created for existing contact")
    @helper.addLogs("[Actual ]   : Journey is created with email #{createdJourneyInfo.fetch("Primary_Email__c")}")
    expect(createdJourneyInfo.fetch("Primary_Email__c")).to eql existContactInfo.fetch("Email")
    @helper.addLogs("[Validate ] : Checking Journey owner should be logged in user")
    @helper.addLogs("[Expected ] : Owner of Journey should be #{existContactInfo.fetch("Owner").fetch("Name")}")
    @helper.addLogs("[Actual ]   : Owner of Journey is #{createdJourneyInfo.fetch("Owner").fetch("Name")}")
    expect(createdJourneyInfo.fetch("Owner").fetch("Name")).to eql existContactInfo.fetch("Owner").fetch("Name")
    @helper.addLogs("[Result ]   : Owner checked successfully\n")
    @helper.addLogs("[Validate ] : Checking Lead source on Journey")
    @helper.addLogs("[Expected ] : Lead source should be Inbound Call")
    @helper.addLogs("[Actual ]   : Journey is created with lead source #{createdJourneyInfo.fetch("Lead_Source__c")}")
    expect(createdJourneyInfo.fetch("Lead_Source__c")).to eql "Inbound Call"
    @helper.addLogs("[Result ]   : Lead source checked successfully\n")
    @helper.addLogs("[Validate ] : Checking Next Contact Date on existing Journey")
    @helper.addLogs("[Expected ] : Next Contact Date on existing Journey should update with duplicate lead submission date")
    @helper.addLogs("[Actual ]   : Next Contact Date on existing Journey is #{createdJourneyInfo.fetch("NMD_Next_Contact_Date__c")}")
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
    @helper.addLogs("[Expected ] : Assigned to on activity should be #{existContactInfo.fetch("Owner").fetch("Name")}")
    @helper.addLogs("[Actual ]   : Assigned to on activity is #{generatedActivityForLead.fetch("Owner").fetch("Name")}")
    expect(generatedActivityForLead.fetch("Owner").fetch("Name")).to eql existContactInfo.fetch("Owner").fetch("Name")
    @helper.addLogs("[Result ]   : Activity assigned to field checked successfully")
    @helper.addLogs("[Validate ] : Checking status on activity")
    @helper.addLogs("[Expected ] : Status on activity should be Open")
    @helper.addLogs("[Actual ]   : Status on activity is #{generatedActivityForLead.fetch("Status")}")
    expect(generatedActivityForLead.fetch("Status")).to eql "Open"
    @helper.addLogs("[Result ]   : Activity Status field checked successfully")
    @helper.addLogs("[Validate ] : Checking Location interested on activity")
    @helper.addLogs("[Expected ] : Location interested on activity should be #{createdJourneyInfo.fetch('Locations_Interested__c')}")
    @helper.addLogs("[Actual ]   : Location interested on activity is #{generatedActivityForLead.fetch("Locations_Interested__c")}")
    expect(generatedActivityForLead.fetch("Locations_Interested__c")).to eql createdJourneyInfo.fetch('Locations_Interested__c')
    @helper.addLogs("[Result ]   : Activity Location interested field checked successfully")
    @helper.addLogs("[Validate ] : Checking Location interested on activity")
    @helper.addLogs("[Expected ] : Number of full time employees on activity should be #{createdJourneyInfo.fetch('Number_of_Full_Time_Employees__c')}")
    @helper.addLogs("[Actual ]   : Number of full time employees on activity is #{generatedActivityForLead.fetch("Number_of_Full_Time_Employees__c")}")
    expect(generatedActivityForLead.fetch("Number_of_Full_Time_Employees__c")).to eql createdJourneyInfo.fetch('Number_of_Full_Time_Employees__c')
    @helper.addLogs("[Result ]   : Activity Number of full time employees field checked successfully")
    @helper.addLogs("[Validate ] : Checking Number of desks on activity")
    @helper.addLogs("[Expected ] : Checking Number of desks on activity should be #{createdJourneyInfo.fetch('Interested_in_Number_of_Desks__c')}")
    @helper.addLogs("[Actual ]   : Checking Number of desks on activity is #{generatedActivityForLead.fetch("Interested_in_Number_of_Desks__c")}")
    expect(generatedActivityForLead.fetch("Interested_in_Number_of_Desks__c")).to eql createdJourneyInfo.fetch('Interested_in_Number_of_Desks__c')
    @helper.addLogs("[Result ]   : Activity Number of desks field checked successfully")

  end
  it "To Check New Journey Creation if duplicate lead submission happens for Existing Lead which is created before 30 days.", :'2562' => 'true' do
    @helper.addLogs("[Step ] : Create duplicate lead with existing lead email which is created before 30 days")
    existingLead = @helper.getExistingLead((Date.today - 30).to_datetime,2)
    puts existingLead
    @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Email'] = existingLead.fetch("Email")
    @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Number_of_Full_Time_Employees__c'] = 10
    @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Interested_in_Number_of_Desks__c'] = 5
    @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Locations_Interested__c'] = "LA-Santa Monica"
    if !@driver.find_elements(:id, "scc_widget_Inbound_Call").empty?
      EnziUIUtility.switchToFrame @driver, "scc_widget_Inbound_Call"
    end
    @pageObject.createLead(false)
    createdJourneyInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,Status__c, Name,Lead_Source__c , Lead_Source_Detail__c, NMD_Next_Contact_Date__c FROM Journey__c WHERE Primary_Email__c = '#{existingLeadInfo.fetch("Email")}'")[0]
    generatedActivityForLead = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Subject , CreatedDate,Status , Owner.Name,Lead_Source__c , Lead_Source_Detail__c,Owner.Name,Locations_Interested__c, Number_of_Full_Time_Employees__c,Interested_in_Number_of_Desks__c,Company__c,WhoId FROM Task WHERE WhoId = '#{existContactInfo['id']}'")[0]
    puts generatedActivityForLead.inspect
    @helper.addLogs("[Validate ] : Checking Next Contact Date on existing Journey")
    @helper.addLogs("[Expected ] : Next Contact Date on existing Journey should update with duplicate lead submission date")
    @helper.addLogs("[Actual ]   : Next Contact Date on existing Journey is #{createdJourneyInfo.fetch("NMD_Next_Contact_Date__c")}")
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
    expect(generatedActivityForLead.fetch("Company__c")).to eql @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Company']
    @helper.addLogs("[Result ]   : Activity Status field checked successfully")
    @helper.addLogs("[Validate ] : Checking Location interested on activity")
    @helper.addLogs("[Expected ] : Location interested on activity should be #{@pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Locations_Interested__c']}")
    @helper.addLogs("[Actual ]   : Location interested on activity is #{generatedActivityForLead.fetch("Status")}")
    expect(generatedActivityForLead.fetch("Locations_Interested__c")).to eql @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Locations_Interested__c']
    @helper.addLogs("[Result ]   : Activity Location interested field checked successfully")
    Helper.addRecordsToDelete("Journey__c", createdJourneyInfo.fetch('Id'))
    @helper.addLogs("[Validate ] : Checking Journey creation for duplicate lead creation")
    @helper.addLogs("[Expected ] : Journey should be created for existing lead")
    @helper.addLogs("[Actual ]   : Journey is created with email #{createdJourneyInfo.fetch("Primary_Email__c")}")
    expect(createdJourneyInfo.fetch("Primary_Email__c")).to eql @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Email']
    @helper.addLogs("[Validate ] : Checking Journey owner should be logged in user")
    @helper.addLogs("[Expected ] : Owner of Journey should be owner of lead")
    @helper.addLogs("[Actual ]   : Owner of Journey is #{createdJourneyInfo.fetch("Owner").fetch("Name")}")
    expect(createdJourneyInfo.fetch("Owner").fetch("Name")).to eql @userInfo.fetch("display_name")
    @helper.addLogs("[Result ]   : Owner checked successfully\n")
    @helper.addLogs("[Validate ] : Checking Lead source on Journey")
    @helper.addLogs("[Expected ] : Lead source should be Inbound Call")
    @helper.addLogs("[Actual ]   : Journey is created with lead source #{createdJourneyInfo.fetch("Lead_Source__c")}")
    expect(createdJourneyInfo.fetch("Lead_Source__c")).to eql "Inbound Call"
    @helper.addLogs("[Result ]   : Lead source checked successfully\n")
    @helper.addLogs("[Validate ] : Checking building interested name on Journey")
    @helper.addLogs("[Expected ] : Building interested should be #{@testDataJSON['Lead'][0]['Building_Interested_In__c']}")
    @helper.addLogs("[Actual ]   : Journey is created with building interested name #{createdJourneyInfo.fetch("Building_Interested_In__c")}")
    expect(createdJourneyInfo.fetch("Building_Interested_In__c")).to eql @helper.instance_variable_get(:@restForce).getRecords("SELECT id FROM Building__c WHERE Name = '#{@testDataJSON['Lead'][0]["Building_Interested_In__c"]}'")[0].fetch("id")
    @helper.addLogs("[Result ]   : Building interested on Journey checked successfully\n")
    @helper.addLogs("[Validate ] : Checking NMD Next Contact Date on Journey")
    @helper.addLogs("[Expected ] : NMD Next Contact Date should be journey creation date")
    @helper.addLogs("[Actual ]   : Journey is created with NMD Next Contact Date #{createdJourneyInfo.fetch("NMD_Next_Contact_Date__c")}")
    #expect(createdJourneyInfo.fetch("NMD_Next_Contact_Date__c")).to eql insertedJourneyInfo[0].fetch("CreatedDate")
    @helper.addLogs("[Result ]   : NMD Next Contact Date on Journey checked successfully\n")
  end
  it "To Check New Journey Creation if duplicate Lead Submission happens for existing contact which is created after 4 days and within 30 days when the existing contact Owner has not permission to create a journey.", :'2556' => 'true' do
    @helper.addLogs("[Step ] : Create duplicate contact with existing contact email which is created within 4 and 30 days when the existing contact Owner has not permission to create a journey")
    until !@userHasPermission
      existContactInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,Email, Owner.Name,Owner.id FROM Contact WHERE CreatedBy.Name IN ('Veena Hegane','Ashotosh Thakur','Monika Pingale','Kishor Shinde') AND Email like '%@example.com' AND CreatedDate = LAST_N_DAYS:5")
      if existContactInfo.nil?
        existContactInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Owner.Name,Email FROM Contact WHERE CreatedBy.Name IN ('Veena Hegane','Ashotosh Thakur','Monika Pingale','Kishor Shinde') AND Email like '%@example.com' AND CreatedDate = LAST_N_DAYS:30")
        @settings.each do |user|
          existContactInfo.each do |contact|
            if user["Id"].eql? contact.fetch("Owner").fetch("Id")
              @userHasPermission = true
              existContactInfo = contact
              break;
            end
          end
        end
      else
        JSON.parse(@settings[1]["Data__c"])["allowedUsers"].each do |user|
          if user["Id"].eql?(existContactInfo[0].fetch("Owner").fetch("Id"))
            puts user.inspect
            @userHasPermission = true
            existContactInfo = existContactInfo[0]
            break;
          end
        end
      end
    end
    @testDataJSON['Lead'][0]['Email'] = existContactInfo.fetch("Email")
    @testDataJSON['Lead'][0]['CompanySize'] = 10
    @testDataJSON['Lead'][0]['NumberofDesks'] = 5
    if !@driver.find_elements(:id, "scc_widget_Inbound_Call").empty?
      EnziUIUtility.switchToFrame @driver, "scc_widget_Inbound_Call"
    end
    @pageObject.createLead(true)
    createdJourneyInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,Status__c, Name,Lead_Source__c , Lead_Source_Detail__c, NMD_Next_Contact_Date__c FROM Journey__c WHERE Primary_Email__c = '#{existContactInfo.fetch("Email")}'")[0]
    generatedActivityForLead = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Subject , CreatedDate,Status , Owner.Name,Lead_Source__c , Lead_Source_Detail__c,Owner.Name,Locations_Interested__c, Number_of_Full_Time_Employees__c,Interested_in_Number_of_Desks__c,Company__c,WhoId FROM Task WHERE WhoId = '#{existContactInfo['id']}'")[0]
    puts generatedActivityForLead.inspect
    @helper.addLogs("[Validate ] : Checking Next Contact Date on existing Journey")
    @helper.addLogs("[Expected ] : Next Contact Date on existing Journey should update with duplicate lead submission date")
    @helper.addLogs("[Actual ]   : Next Contact Date on existing Journey is #{existingJourneyInfo.fetch("NMD_Next_Contact_Date__c")}")
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
    expect(generatedActivityForLead.fetch("Company__c")).to eql insertedLeadInfo.fetch('Company')
    @helper.addLogs("[Result ]   : Activity Status field checked successfully")
    @helper.addLogs("[Validate ] : Checking Location interested on activity")
    @helper.addLogs("[Expected ] : Location interested on activity should be #{insertedLeadInfo.fetch('Locations_Interested__c')}")
    @helper.addLogs("[Actual ]   : Location interested on activity is #{generatedActivityForLead.fetch("Status")}")
    expect(generatedActivityForLead.fetch("Locations_Interested__c")).to eql insertedLeadInfo.fetch('Locations_Interested__c')
    @helper.addLogs("[Result ]   : Activity Location interested field checked successfully")
    @helper.addLogs("[Validate ] : Checking Location interested on activity")
    @helper.addLogs("[Expected ] : Number of full time employees on activity should be #{insertedLeadInfo.fetch('Number_of_Full_Time_Employees__c')}")
    @helper.addLogs("[Actual ]   : Number of full time employees on activity is #{generatedActivityForLead.fetch("Number_of_Full_Time_Employees__c")}")
    expect(generatedActivityForLead.fetch("Number_of_Full_Time_Employees__c")).to eql insertedLeadInfo.fetch('Number_of_Full_Time_Employees__c')
    @helper.addLogs("[Result ]   : Activity Number of full time employees field checked successfully")
    @helper.addLogs("[Validate ] : Checking Number of desks on activity")
    @helper.addLogs("[Expected ] : Checking Number of desks on activity should be #{insertedLeadInfo.fetch('Number_of_Full_Time_Employees__c')}")
    @helper.addLogs("[Actual ]   : Checking Number of desks on activity is #{generatedActivityForLead.fetch("Number_of_Full_Time_Employees__c")}")
    expect(generatedActivityForLead.fetch("Interested_in_Number_of_Desks__c")).to eql insertedLeadInfo.fetch('Interested_in_Number_of_Desks__c')
    @helper.addLogs("[Result ]   : Activity Number of desks field checked successfully")
    Helper.addRecordsToDelete("Journey__c", createdJourneyInfo.fetch('Id'))
    @helper.addLogs("[Validate ] : Checking Journey creation for duplicate contact creation")
    @helper.addLogs("[Expected ] : Journey should be created for existing contact")
    @helper.addLogs("[Actual ]   : Journey is created with email #{createdJourneyInfo.fetch("Primary_Email__c")}")
    expect(createdJourneyInfo.fetch("Primary_Email__c")).to eql existContactInfo.fetch("Email")
    @helper.addLogs("[Validate ] : Checking Journey owner should be #{@userInfo.fetch("display_name")}")
    @helper.addLogs("[Expected ] : Owner of Journey should be logged in user")
    @helper.addLogs("[Actual ]   : Owner of Journey is #{createdJourneyInfo.fetch("Owner").fetch("Name")}")
    expect(createdJourneyInfo.fetch("Owner").fetch("Name")).to eql @userInfo.fetch("display_name")
    @helper.addLogs("[Result ]   : Owner checked successfully\n")
    @helper.addLogs("[Validate ] : Checking Lead source on Journey")
    @helper.addLogs("[Expected ] : Lead source should be Inbound Call")
    @helper.addLogs("[Actual ]   : Journey is created with lead source #{createdJourneyInfo.fetch("Lead_Source__c")}")
    expect(createdJourneyInfo.fetch("Lead_Source__c")).to eql "Inbound Call"
    @helper.addLogs("[Result ]   : Lead source checked successfully\n")
    @helper.addLogs("[Validate ] : Checking building interested name on Journey")
    @helper.addLogs("[Expected ] : Building interested should be #{@testDataJSON['Lead'][0]['Building_Interested_In__c']}")
    @helper.addLogs("[Actual ]   : Journey is created with building interested name #{createdJourneyInfo.fetch("Building_Interested_In__c")}")
    expect(createdJourneyInfo.fetch("Building_Interested_In__c")).to eql @helper.instance_variable_get(:@restForce).getRecords("SELECT id FROM Building__c WHERE Name = '#{@testDataJSON['Lead'][0]["Building_Interested_In__c"]}'")[0].fetch("id")
    @helper.addLogs("[Result ]   : Building interested on Journey checked successfully\n")
    @helper.addLogs("[Validate ] : Checking NMD Next Contact Date on Journey")
    @helper.addLogs("[Expected ] : NMD Next Contact Date should be journey creation date")
    @helper.addLogs("[Actual ]   : Journey is created with NMD Next Contact Date #{createdJourneyInfo.fetch("NMD_Next_Contact_Date__c")}")
    #expect(createdJourneyInfo.fetch("NMD_Next_Contact_Date__c")).to eql insertedJourneyInfo[0].fetch("CreatedDate")
    @helper.addLogs("[Result ]   : NMD Next Contact Date on Journey checked successfully\n")

  end
  it "To Check Journey not being Created if duplicate lead submission happens for existing contact which is created after 4 days & within 30 days when the existing lead and lead assignment(Logged in user) logged in user has not journey create permission", :'2558' => 'true' do
    @helper.addLogs("[Step ] : Create duplicate lead with existing lead email which is created within 4 and 30 days when the existing lead Owner has not permission to create a journey")
    until !@userHasPermission
      existLeadInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,Email, Owner.Name,Owner.id FROM Lead WHERE CreatedBy.Name IN ('Veena Hegane','Ashotosh Thakur','Monika Pingale','Kishor Shinde') AND Email like '%@example.com' AND CreatedDate = LAST_N_DAYS:5")
      if existLeadInfo.nil?
        existLeadInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Owner.Name,Email FROM Lead WHERE CreatedBy.Name IN ('Veena Hegane','Ashotosh Thakur','Monika Pingale','Kishor Shinde') AND Email like '%@example.com' AND CreatedDate = LAST_N_DAYS:30")
        @settings.each do |user|
          existLeadInfo.each do |contact|
            if user["Id"].eql? contact.fetch("Owner").fetch("Id")
              @userHasPermission = true
              existContactInfo = contact
              break;
            end
          end
        end
      else
        JSON.parse(@settings[1]["Data__c"])["allowedUsers"].each do |user|
          if user["Id"].eql?(existLeadInfo[0].fetch("Owner").fetch("Id"))
            @userHasPermission = true
            existLeadInfo = existLeadInfo[0]
            break;
          end
        end
      end
    end
    @driver.get "#{@driver.current_url().split('/home')[0]}/#{existLeadInfo.fetch("Owner").fetch("Id")}?noredirect=1&isUserEntityOverride=1"
    @driver.find_element(:name, "login").click
    @testDataJSON['Lead'][0]['Email'] = existLeadInfo.fetch("Email")
    @testDataJSON['Lead'][0]['CompanySize'] = 10
    @testDataJSON['Lead'][0]['NumberofDesks'] = 5
    if !@driver.find_elements(:id, "scc_widget_Inbound_Call").empty?
      EnziUIUtility.switchToFrame @driver, "scc_widget_Inbound_Call"
    end
    @pageObject.createLead(true)
    createdJourneyInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id  FROM Journey__c WHERE Primary_Email__c = '#{existLeadInfo.fetch("Email")}'")[0]
    @helper.addLogs("[Validate ] : Checking Journey Creation")
    @helper.addLogs("[Expected ] : Journey should not created")
    @helper.addLogs("[Actual ]   : Journey is created  #{createdJourneyInfo}")
    expect(createdJourneyInfo).be eql nil
    generatedActivityForLead = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Subject , CreatedDate,Status , Owner.Name,Lead_Source__c , Lead_Source_Detail__c,Owner.Name,Locations_Interested__c, Number_of_Full_Time_Employees__c,Interested_in_Number_of_Desks__c,Company__c,WhoId FROM Task WHERE WhoId = '#{existLeadInfo.fetch('Id')}'")[0]
    puts generatedActivityForLead.inspect
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
    expect(generatedActivityForLead.fetch("Company__c")).to eql existLeadInfo.fetch('Company')
    @helper.addLogs("[Result ]   : Activity Status field checked successfully")
    @helper.addLogs("[Validate ] : Checking Location interested on activity")
    @helper.addLogs("[Expected ] : Location interested on activity should be #{existLeadInfo.fetch('Locations_Interested__c')}")
    @helper.addLogs("[Actual ]   : Location interested on activity is #{generatedActivityForLead.fetch("Status")}")
    expect(generatedActivityForLead.fetch("Locations_Interested__c")).to eql existLeadInfo.fetch('Locations_Interested__c')
    @helper.addLogs("[Result ]   : Activity Location interested field checked successfully")
    @helper.addLogs("[Validate ] : Checking Location interested on activity")
    @helper.addLogs("[Expected ] : Number of full time employees on activity should be #{existLeadInfo.fetch('Number_of_Full_Time_Employees__c')}")
    @helper.addLogs("[Actual ]   : Number of full time employees on activity is #{generatedActivityForLead.fetch("Number_of_Full_Time_Employees__c")}")
    expect(generatedActivityForLead.fetch("Number_of_Full_Time_Employees__c")).to eql existLeadInfo.fetch('Number_of_Full_Time_Employees__c')
    @helper.addLogs("[Result ]   : Activity Number of full time employees field checked successfully")
    @helper.addLogs("[Validate ] : Checking Number of desks on activity")
    @helper.addLogs("[Expected ] : Checking Number of desks on activity should be #{existLeadInfo.fetch('Number_of_Full_Time_Employees__c')}")
    @helper.addLogs("[Actual ]   : Checking Number of desks on activity is #{generatedActivityForLead.fetch("Number_of_Full_Time_Employees__c")}")
    expect(generatedActivityForLead.fetch("Interested_in_Number_of_Desks__c")).to eql existLeadInfo.fetch('Interested_in_Number_of_Desks__c')
    @helper.addLogs("[Result ]   : Activity Number of desks field checked successfully")
    Helper.addRecordsToDelete("Journey__c", createdJourneyInfo.fetch('Id'))
    @helper.addLogs("[Validate ] : Checking Journey creation for duplicate contact creation")
    @helper.addLogs("[Expected ] : Journey should be created for existing contact")
    @helper.addLogs("[Actual ]   : Journey is created with email #{createdJourneyInfo.fetch("Primary_Email__c")}")
    expect(createdJourneyInfo.fetch("Primary_Email__c")).to eql existLeadInfo.fetch("Email")
    @helper.addLogs("[Validate ] : Checking Journey owner should be #{@userInfo.fetch("display_name")}")
    @helper.addLogs("[Expected ] : Owner of Journey should be logged in user")
    @helper.addLogs("[Actual ]   : Owner of Journey is #{createdJourneyInfo.fetch("Owner").fetch("Name")}")
    expect(createdJourneyInfo.fetch("Owner").fetch("Name")).to eql @userInfo.fetch("display_name")
    @helper.addLogs("[Result ]   : Owner checked successfully\n")
    @helper.addLogs("[Validate ] : Checking Lead source on Journey")
    @helper.addLogs("[Expected ] : Lead source should be Inbound Call")
    @helper.addLogs("[Actual ]   : Journey is created with lead source #{createdJourneyInfo.fetch("Lead_Source__c")}")
    expect(createdJourneyInfo.fetch("Lead_Source__c")).to eql "Inbound Call"
    @helper.addLogs("[Result ]   : Lead source checked successfully\n")
    @helper.addLogs("[Validate ] : Checking building interested name on Journey")
    @helper.addLogs("[Expected ] : Building interested should be #{@testDataJSON['Lead'][0]['Building_Interested_In__c']}")
    @helper.addLogs("[Actual ]   : Journey is created with building interested name #{createdJourneyInfo.fetch("Building_Interested_In__c")}")
    expect(createdJourneyInfo.fetch("Building_Interested_In__c")).to eql @helper.instance_variable_get(:@restForce).getRecords("SELECT id FROM Building__c WHERE Name = '#{@testDataJSON['Lead'][0]["Building_Interested_In__c"]}'")[0].fetch("id")
    @helper.addLogs("[Result ]   : Building interested on Journey checked successfully\n")
    @helper.addLogs("[Validate ] : Checking NMD Next Contact Date on Journey")
    @helper.addLogs("[Expected ] : NMD Next Contact Date should be journey creation date")
    @helper.addLogs("[Actual ]   : Journey is created with NMD Next Contact Date #{createdJourneyInfo.fetch("NMD_Next_Contact_Date__c")}")
    #expect(createdJourneyInfo.fetch("NMD_Next_Contact_Date__c")).to eql insertedJourneyInfo[0].fetch("CreatedDate")
    @helper.addLogs("[Result ]   : NMD Next Contact Date on Journey checked successfully\n")
  end
  it "To Check Journey not being Created if Duplicate lead submission happens for existing lead which is created after 4 days and within 30 days when the existing lead owner and lead assignment(Logged in user) has not permission to generate journey.", :'2561' => 'true' do
    @helper.addLogs("[Step ] : Create duplicate contact with existing contact email which is created within 4 and 30 days when the existing contact Owner has not permission to create a journey")
    until !@userHasPermission
      existContactInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,Email, Owner.Name,Owner.id FROM Contact WHERE CreatedBy.Name IN ('Veena Hegane','Ashotosh Thakur','Monika Pingale','Kishor Shinde') AND Email like '%@example.com' AND CreatedDate = LAST_N_DAYS:5")
      if existContactInfo.nil?
        existContactInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Owner.Name,Email FROM Contact WHERE CreatedBy.Name IN ('Veena Hegane','Ashotosh Thakur','Monika Pingale','Kishor Shinde') AND Email like '%@example.com' AND CreatedDate = LAST_N_DAYS:30")
        @settings.each do |user|
          existContactInfo.each do |contact|
            if user["Id"].eql? contact.fetch("Owner").fetch("Id")
              @userHasPermission = true
              existContactInfo = contact
              break;
            end
          end
        end
      else
        JSON.parse(@settings[1]["Data__c"])["allowedUsers"].each do |user|
          if user["Id"].eql?(existContactInfo[0].fetch("Owner").fetch("Id"))
            @userHasPermission = true
            existContactInfo = existContactInfo[0]
            break;
          end
        end
      end
    end
    @driver.get "#{@driver.current_url().split('/home')[0]}/#{existContactInfo.fetch("Owner").fetch("Id")}?noredirect=1&isUserEntityOverride=1"
    @driver.find_element(:name, "login").click
    if !appButton.empty?
      @driver.find_element(:id, "tsidButton").click
      @helper.instance_variable_get(:@wait).until {@driver.find_element(:id, "tsid-menuItems")}
      appsDrpDwn = @driver.find_element(:id, "tsid-menuItems").find_elements(:link, "Sales Console")
      if !appsDrpDwn.empty?
        appsDrpDwn[0].click
        @helper.addLogs("[Result ] : Sales Console app opened successfully")
      end
    end
    @testDataJSON['Lead'][0]['Email'] = existContactInfo.fetch("Email")
    @testDataJSON['Lead'][0]['CompanySize'] = 10
    @testDataJSON['Lead'][0]['NumberofDesks'] = 5
    if !@driver.find_elements(:id, "scc_widget_Inbound_Call").empty?
      EnziUIUtility.switchToFrame @driver, "scc_widget_Inbound_Call"
    end
    @pageObject.createLead(true)
    createdJourneyInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id  FROM Journey__c WHERE Primary_Email__c = '#{existContactInfo.fetch("Email")}'")[0]
    @helper.addLogs("[Validate ] : Checking Journey Creation")
    @helper.addLogs("[Expected ] : Journey should not created")
    @helper.addLogs("[Actual ]   : Journey is created  #{createdJourneyInfo}")
    expect(createdJourneyInfo).be eql nil
  end
  it "To Check Journey Not being Created if duplicate lead submission happens for Existing lead which is created before 30 days when the new user as per the lead assignment rule has not generate journey permission.", :'2563' => 'true' do

    @helper.addLogs("[Step ] : Create duplicate lead with Existing lead which is created before 30 days when the new user as per the lead assignment rule has not generate journey permission")
    until !@userHasPermission
      existingLeadInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Owner.Name, LeadSource , Lead_Source_Detail__c , Building_Interested_In__c , Building_Interested_Name__c ,Journey_Created_On__c, Locations_Interested__c , Number_of_Full_Time_Employees__c , Interested_in_Number_of_Desks__c , Email , Phone , Company  , RecordType.Name , Status , Type__c FROM Lead WHERE CreatedBy.Name IN ('Veena Hegane','Ashotosh Thakur','Monika Pingale','Kishor Shinde') AND Email like '%@example.com' AND CreatedDate = LAST_N_MONTHS:1")
      if existContactInfo.nil?
        existingLeadInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Owner.Name, LeadSource , Lead_Source_Detail__c , Building_Interested_In__c , Building_Interested_Name__c ,Journey_Created_On__c, Locations_Interested__c , Number_of_Full_Time_Employees__c , Interested_in_Number_of_Desks__c , Email , Phone , Company  , RecordType.Name , Status , Type__c FROM Lead WHERE CreatedBy.Name IN ('Veena Hegane','Ashotosh Thakur','Monika Pingale','Kishor Shinde') AND Email like '%@example.com' AND CreatedDate = LAST_N_MONTHS:2")
        @settings.each do |user|
          existContactInfo.each do |contact|
            if user["Id"].eql? contact.fetch("Owner").fetch("Id")
              @userHasPermission = true
              existContactInfo = contact
              break;
            end
          end
        end
      else
        JSON.parse(@settings[1]["Data__c"])["allowedUsers"].each do |user|
          if user["Id"].eql?(existContactInfo[0].fetch("Owner").fetch("Id"))
            @userHasPermission = true
            existContactInfo = existContactInfo[0]
            break;
          end
        end
      end
    end
  end
=begin
  it "To Check Journey Creation Based on the User and Queue Permission." ,:'2530'=>'true' do
    if @userHasPermission.nil?
      permittedUsers = @helper.instance_variable_get(:@restForce).getRecords("SELECT name,Data__c FROM Setting__c WHERE name = 'User/Queue Journey Creation'")
      JSON.parse(permittedUsers[0]["Data__c"])["allowedUsers"].each do |user|
        if user["Id"].eql?
          @userHasPermission = true
        end
      end
    end
    createLead(@overrideLeadSource,10,5)
    insertedJourneyInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,Owner.Name, CreatedDate ,Status__c , NMD_Next_Contact_Date__c ,Primary_Email__c , Lead_Source__c , Lead_Source_Detail__c , Primary_Phone__c , Company_Name__c , Building_Interested_In__c , Locations_Interested__c , Interested_in_Number_of_Desks__c , Full_Time_Employees__c, Name   FROM Journey__c WHERE Primary_Email__c = '#{@testDataJSON['Lead'][0]['Email']}'")
    if @userHasPermission
      isLeadSourceDetailHasPermission = false
      JSON.parse(leadSource[0]["Data__c"])["LeadSourceDetails"].each do |source|
        if source.eql? "Inbound Call Page"
          isLeadSourceDetailHasPermission = true
        end
      end
      if isLeadSourceDetailHasPermission
        expect(insertedJourneyInfo).to_not eql nil
        insertedJourneyInfo= insertedJourneyInfo[0]
        expect(insertedJourneyInfo.fetch("Owner").fetch("Name")).to eql @userInfo.fetch("display_name")
        expect(insertedJourneyInfo.fetch("Lead_Source__c")).to eql "Inbound Call"
        expect(insertedJourneyInfo.fetch("Lead_Source_Detail__c")).to eql "Inbound Call Page"
        expect(insertedJourneyInfo.fetch("Building_Interested_In__c")).to eql @helper.instance_variable_get(:@restForce).getRecords("SELECT id FROM Building__c WHERE Name = '#{@testDataJSON['Lead'][0]["Building_Interested_In__c"]}'")[0].fetch("id")
        expect(insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")).to eql insertedJourneyInfo[0].fetch("CreatedDate")
        expect(insertedJourneyInfo.fetch("Interested_in_Number_of_Desks__c")).to eql "#{@testDataJSON['Lead'][0]['NumberofDesks']}.0"
        expect(insertedJourneyInfo.fetch("Locations_Interested__c")).to eql @testDataJSON['Lead'][0]["Building_Interested_In__c"]
        expect(insertedJourneyInfo.fetch("Full_Time_Employees__c")).to eql "#{@testDataJSON['Lead'][0]['CompanySize']}.0"
        expect(insertedJourneyInfo.fetch("Primary_Email__c")).to eql @testDataJSON['Lead'][0]['Email']
        expect(insertedJourneyInfo.fetch("Primary_Phone__c")).to eql @testDataJSON['Lead'][0]['Phone']
        expect(insertedJourneyInfo.fetch("Company_Name__c")).to eql @testDataJSON['Lead'][0]['Company']
        expect(insertedJourneyInfo.fetch("Status__c")).to eql "Started"
        expect(insertedJourneyInfo.fetch("Name")).to eql "#{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}"
      else
        expect(insertedJourneyInfo).to eql nil
      end
    else
      expect(insertedJourneyInfo).to eql nil
    end
  end
  it "To Check Journey Creation Where Lead Source has permission to create journey and Override lead source detail checkbox is checked & Lead Source detail has not permission to generate journey" ,:'2523'=> 'true' do
    leadSource = @helper.instance_variable_get(:@restForce).getRecords("SELECT name,Data__c FROM Setting__c WHERE name = 'Lead:Lead and Lead Source Details'")
    isLeadSourceDetailHasPermission = false
    JSON.parse(leadSource[0]["Data__c"])["LeadSourceDetails"].each do |source|
      if source.eql? "Inbound Call Page"
        isLeadSourceDetailHasPermission = true
      end
    end
    if @isSourceHasPermission.nil?
      JSON.parse(leadSource[0]["Data__c"])["LeadSource"].each do |source|
        if source['name'].eql? "Inbound Call"
          @isSourceHasPermission= true
          @overrideLeadSource = source["OverrideLeadSoruce"]
        end
      end
    end
    createLead(@overrideLeadSource,10,5)
    insertedJourneyInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,Owner.Name, CreatedDate ,Status__c , NMD_Next_Contact_Date__c ,Primary_Email__c , Lead_Source__c , Lead_Source_Detail__c , Primary_Phone__c , Company_Name__c , Building_Interested_In__c , Locations_Interested__c , Interested_in_Number_of_Desks__c , Full_Time_Employees__c, Name   FROM Journey__c WHERE Primary_Email__c = '#{@testDataJSON['Lead'][0]['Email']}'")
    if @isSourceHasPermission
      expect(insertedJourneyInfo).to_not eql nil
      expect(insertedJourneyInfo.fetch("Owner").fetch("Name")).to eql @userInfo.fetch("display_name")
      expect(insertedJourneyInfo.fetch("Lead_Source__c")).to eql "Inbound Call"
      expect(insertedJourneyInfo.fetch("Lead_Source_Detail__c")).to eql "Inbound Call Page"
      expect(insertedJourneyInfo.fetch("Building_Interested_In__c")).to eql @helper.instance_variable_get(:@restForce).getRecords("SELECT id FROM Building__c WHERE Name = '#{@testDataJSON['Lead'][0]["Building_Interested_In__c"]}'")[0].fetch("id")
      expect(insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")).to eql insertedJourneyInfo[0].fetch("CreatedDate")
      expect(insertedJourneyInfo.fetch("Interested_in_Number_of_Desks__c")).to eql "#{@testDataJSON['Lead'][0]['NumberofDesks']}.0"
      expect(insertedJourneyInfo.fetch("Locations_Interested__c")).to eql @testDataJSON['Lead'][0]["Building_Interested_In__c"]
      expect(insertedJourneyInfo.fetch("Full_Time_Employees__c")).to eql "#{@testDataJSON['Lead'][0]['CompanySize']}.0"
      expect(insertedJourneyInfo.fetch("Primary_Email__c")).to eql @testDataJSON['Lead'][0]['Email']
      expect(insertedJourneyInfo.fetch("Primary_Phone__c")).to eql @testDataJSON['Lead'][0]['Phone']
      expect(insertedJourneyInfo.fetch("Company_Name__c")).to eql @testDataJSON['Lead'][0]['Company']
      expect(insertedJourneyInfo.fetch("Status__c")).to eql "Started"
      expect(insertedJourneyInfo.fetch("Name")).to eql "#{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}"
    else
      expect(insertedJourneyInfo).to eql nil
    end
  end
  it 'To Check Lead Insertion for Consumer from Inbound Call Page', :'2174'=> 'true' do
    begin
      #@helper.addLogs("[Step] Create new lead")
      createLead(false,10,5)
      @helper.instance_variable_get(:@wait).until {!@driver.find_element(:id ,"spinnerContainer").displayed?}
      @helper.instance_variable_get(:@wait).until {@driver.find_element(:id ,"enzTable").displayed?}
      expect(@driver.find_element(:id,"enzTable").find_elements(:tag_name,"tr").size > 1).to be true
      @driver.find_element(:id,"Journey").find_element(:link,"Open").click
      @helper.instance_variable_get(:@wait).until {!@driver.find_element(:id ,"spinnerContainer").displayed?}
      puts "Checking Lead Fields"
      insertedLeadInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Owner.Name, LeadSource , Lead_Source_Detail__c , Building_Interested_In__c , Building_Interested_Name__c ,Journey_Created_On__c, Locations_Interested__c , Number_of_Full_Time_Employees__c , Interested_in_Number_of_Desks__c , Email , Phone , Company , Name , RecordType.Name , Status , Type__c FROM Lead WHERE Email = '#{@testDataJSON['Lead'][0]['Email']}'")[0]
      puts insertedLeadInfo.inspect
      insertedJourneyInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,Owner.Name, CreatedDate ,Status__c , NMD_Next_Contact_Date__c ,Primary_Email__c , Lead_Source__c , Lead_Source_Detail__c , Primary_Phone__c , Company_Name__c , Building_Interested_In__c , Locations_Interested__c , Interested_in_Number_of_Desks__c , Full_Time_Employees__c, Name   FROM Journey__c WHERE Primary_Email__c = '#{@testDataJSON['Lead'][0]['Email']}'")[0]
      expect(insertedLeadInfo.fetch("Owner").fetch("Name")).to eql @userInfo.fetch("display_name")
      expect(insertedLeadInfo.fetch("LeadSource")).to eql "Inbound Call"
      expect(insertedLeadInfo.fetch("Lead_Source_Detail__c")).to eql "Inbound Call Page"
      expect(insertedLeadInfo.fetch("Building_Interested_Name__c")).to eql @testDataJSON['Lead'][0]["Building_Interested_In__c"]
      expect(insertedLeadInfo.fetch("Building_Interested_In__c")).to eql @helper.instance_variable_get(:@restForce).getRecords("SELECT id FROM Building__c WHERE Name = '#{@testDataJSON['Lead'][0]["Building_Interested_In__c"]}'")[0].fetch("id")
      expect(insertedLeadInfo.fetch("Journey_Created_On__c")).to eql insertedJourneyInfo[0].fetch("CreatedDate")
      expect(insertedLeadInfo.fetch("Interested_in_Number_of_Desks__c")).to eql "#{@testDataJSON['Lead'][0]['NumberofDesks']}.0"
      expect(insertedLeadInfo.fetch("Locations_Interested__c")).to eql @testDataJSON['Lead'][0]["Building_Interested_In__c"]
      expect(insertedLeadInfo.fetch("Number_of_Full_Time_Employees__c")).to eql "#{@testDataJSON['Lead'][0]['CompanySize']}.0"
      expect(insertedLeadInfo.fetch("Email")).to eql @testDataJSON['Lead'][0]['Email']
      expect(insertedLeadInfo.fetch("Phone")).to eql @testDataJSON['Lead'][0]['Phone']
      expect(insertedLeadInfo.fetch("Company")).to eql @testDataJSON['Lead'][0]['Company']
      expect(insertedLeadInfo.fetch("RecordType.Name")).to eql "Consumer"
      expect(insertedLeadInfo.fetch("Status")).to eql "Open"
      expect(insertedLeadInfo.fetch("Type__c")).to eql "Office Space"
      expect(insertedLeadInfo.fetch("Name")).to eql "#{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}"
      puts "Checking Journey Fields"
      puts insertedJourneyInfo.inspect
      expect(insertedJourneyInfo.fetch("Owner").fetch("Name")).to eql @userInfo.fetch("display_name")
      expect(insertedJourneyInfo.fetch("Lead_Source__c")).to eql "Inbound Call"
      expect(insertedJourneyInfo.fetch("Lead_Source_Detail__c")).to eql "Inbound Call Page"
      expect(insertedJourneyInfo.fetch("Building_Interested_In__c")).to eql @helper.instance_variable_get(:@restForce).getRecords("SELECT id FROM Building__c WHERE Name = '#{@testDataJSON['Lead'][0]["Building_Interested_In__c"]}'")[0].fetch("id")
      expect(insertedJourneyInfo.fetch("NMD_Next_Contact_Date__c")).to eql insertedJourneyInfo[0].fetch("CreatedDate")
      expect(insertedJourneyInfo.fetch("Interested_in_Number_of_Desks__c")).to eql "#{@testDataJSON['Lead'][0]['NumberofDesks']}.0"
      expect(insertedJourneyInfo.fetch("Locations_Interested__c")).to eql @testDataJSON['Lead'][0]["Building_Interested_In__c"]
      expect(insertedJourneyInfo.fetch("Full_Time_Employees__c")).to eql "#{@testDataJSON['Lead'][0]['CompanySize']}.0"
      expect(insertedJourneyInfo.fetch("Primary_Email__c")).to eql @testDataJSON['Lead'][0]['Email']
      expect(insertedJourneyInfo.fetch("Primary_Phone__c")).to eql @testDataJSON['Lead'][0]['Phone']
      expect(insertedJourneyInfo.fetch("Company_Name__c")).to eql @testDataJSON['Lead'][0]['Company']
      expect(insertedJourneyInfo.fetch("Status__c")).to eql "Started"
      expect(insertedJourneyInfo.fetch("Name")).to eql "#{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}"
      puts "Checking Activity Fields"
      puts generatedActivityForLead.inspect
      generatedActivityForLead = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Subject , Status , Lead_Source__c , Lead_Source_Detail__c,Owner.Name,Locations_Interested__c, Number_of_Full_Time_Employees__c,Interested_in_Number_of_Desks__c,Company__c,WhoId FROM Task WHERE WhoId = '#{insertedLeadInfo[0]['id']}'")
      expect(generatedActivityForLead.fetch("Subject")).to eql "Inbound Lead Submission"
      expect(generatedActivityForLead.fetch("Lead_Source__c")).to eql "Inbound Call"
      expect(generatedActivityForLead.fetch("Lead_Source_Detail__c")).to eql "Inbound Call Page"
      expect(generatedActivityForLead.fetch("Owner").fetch("Name")).to eql @userInfo.fetch("display_name")
      expect(generatedActivityForLead.fetch("Company__c")).to eql @testDataJSON['Lead'][0]['Phone']
      expect(insertedJourneyInfo.fetch("Company_Name__c")).to eql @testDataJSON['Lead'][0]['Company']
      expect(insertedJourneyInfo.fetch("Locations_Interested__c")).to eql @testDataJSON['Lead'][0]["Building_Interested_In__c"]
      expect(insertedLeadInfo.fetch("Number_of_Full_Time_Employees__c")).to eql "#{@testDataJSON['Lead'][0]['CompanySize']}.0"
      expect(insertedJourneyInfo.fetch("Interested_in_Number_of_Desks__c")).to eql "#{@testDataJSON['Lead'][0]['NumberofDesks']}.0"
      @helper.postSuccessResult(2174)
    rescue Exception => e
      @helper.postFailResult(e,2174)
      raise e
    end
  end
=end

end










































