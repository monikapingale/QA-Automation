=begin
************************************************************************************************************************************
   Author      :   Monika Pingale
   Description :   This spec will automate follow up functionality of sales console.

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
    @helper.go_to_app(@driver, "Sales Console")
    @pageObject = Kickbox_Importer.new(@driver, @helper)
    @settings = @helper.instance_variable_get(:@restForce).getRecords("SELECT name,Data__c FROM Setting__c WHERE name IN ('User/Queue Journey Creation','Lead:Lead and Lead Source Details')")
  end
  after(:all) do
    @verification_errors.should == []
    @helper.deleteSalesforceRecordBySfbulk("Journey__c", EnziRestforce.class_variable_get(:@@createdRecordsIds)["Journey__c"])
    @helper.deleteSalesforceRecordBySfbulk("Lead", EnziRestforce.class_variable_get(:@@createdRecordsIds)["Lead"])
  end
  it 'To Check Outreach stage not updation when the journey creation date and follow up after date difference is not greater than 48 hours.', :'3057' => 'true' do
    begin
      @helper.addLogs("[Step ]     : Create Lead record with consumer record type")
      if !@driver.find_elements(:id, "scc_widget_Inbound_Call").empty?
        EnziUIUtility.switchToFrame @driver, "scc_widget_Inbound_Call"
      end
      @pageObject.createLead(false)
      @helper.instance_variable_get(:@wait).until {!@driver.find_element(:id, "spinnerContainer").displayed?}
      @helper.instance_variable_get(:@wait).until {@driver.find_element(:id, "enzTable").displayed?}
      insertedLeadInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Owner.Name, LeadSource , Lead_Source_Detail__c , Building_Interested_In__c , Building_Interested_Name__c ,Journey_Created_On__c, Locations_Interested__c , Number_of_Full_Time_Employees__c , Interested_in_Number_of_Desks__c , Email , Phone , Company , Name , RecordType.Name , Status , Type__c FROM Lead WHERE Email = '#{@testDataJSON['Lead'][0]['Email']}'")[0]
      insertedJourneyInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,Owner.Name,Outreach_Stage__c, CreatedDate ,Status__c , NMD_Next_Contact_Date__c ,Primary_Email__c , Lead_Source__c , Lead_Source_Detail__c , Primary_Phone__c , Company_Name__c , Building_Interested_In__c , Locations_Interested__c , Interested_in_Number_of_Desks__c , Full_Time_Employees__c, Name   FROM Journey__c WHERE Primary_Email__c = '#{@testDataJSON['Lead'][0]['Email']}'")[0]
      @helper.addLogs("[Validate ] : Checking Lead is created after form submission")
      @helper.addLogs("[Expected ] : Lead should create with name #{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
      @helper.addLogs("[Actual ]   : Lead is created with name #{insertedLeadInfo.fetch("Name")}")
      @driver.find_element(:id, "Journey").find_element(:link, "Open").click
      @helper.instance_variable_get(:@wait).until {!@driver.find_element(:id, "spinnerContainer").displayed?}
      Helper.addRecordsToDelete("Lead", insertedLeadInfo.fetch('Id'))
      Helper.addRecordsToDelete("Journey__c", insertedJourneyInfo.fetch('Id'))
      expect(insertedLeadInfo).to_not eql nil
      @pageObject.journeyAction(1)
      @helper.addLogs("[Result ]   : Lead insertion checked successfully\n")
      @helper.addLogs("[Validate ] : Checking Lead owner should be logged in user")
      @helper.addLogs("[Expected ] : Owner of lead should be Logged in user")
      @helper.addLogs("[Actual ]   : Owner of lead is #{insertedLeadInfo.fetch("Owner").fetch("Name")}")
      expect(insertedLeadInfo.fetch("Owner").fetch("Name")).to eql @userInfo.fetch("display_name")
      @helper.addLogs("[Result ]   : Owner checked successfully\n")
      validate_case("Journey", insertedJourneyInfo, {'NMD_Next_Contact_Date__c' => Date.today().next.to_s, 'Lead_Source__c' => @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['LeadSource'], 'lead_Source_Detail__c' => @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]["lead_Source_Detail__c"], 'Primary_Email__c' => @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]["Email"], 'Primary_Phone__c' => @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]["Phone"], 'Company_Name__c' => @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]["Company"], 'Status__c' => 'Not Started'})
      generatedActivityForContact = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,Type__c,whatid, Subject , CreatedDate,Status ,Lead_Source__c , Lead_Source_Detail__c,Owner.Name,Locations_Interested__c, Number_of_Full_Time_Employees__c,Interested_in_Number_of_Desks__c,Company__c,WhoId FROM Task WHERE WhoId = '#{insertedJourneyInfo.fetch('Id')}' AND status != 'Completed' AND CreatedDate = TODAY")[0]
      Helper.addRecordsToDelete("Task", generatedActivityForContact.fetch('Id'))
      validate_case("Activity", generatedActivityForContact, {'WhatId' => insertedJourneyInfo.fetch('Id'), 'Type__c' => 'call', 'Subject' => 'follow-up', 'Locations_Interested__c' => @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Building_Interested_In__c'], 'Company__c' => @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Company'], 'Lead_Source_Detail__c' => "Inbound Call Page", 'Lead_Source__c' => "Inbound Call", 'Status' => 'Open'})
      @helper.addLogs('Success')
      @helper.postSuccessResult(3057)
    rescue Exception => e
      @helper.addLogs('Error')
      @helper.postFailResult(e, 3057)
      raise e
    end
  end
  it 'To Check Outreach Stage updation when the journey creation date and follow up after date difference is greater than 48 hours.', :'3058' => 'true' do
    begin
      @helper.addLogs("[Step ]     : Create Lead record with consumer record type")
      if !@driver.find_elements(:id, "scc_widget_Inbound_Call").empty?
        EnziUIUtility.switchToFrame @driver, "scc_widget_Inbound_Call"
      end
      @pageObject.createLead(false)
      @helper.instance_variable_get(:@wait).until {!@driver.find_element(:id, "spinnerContainer").displayed?}
      @helper.instance_variable_get(:@wait).until {@driver.find_element(:id, "enzTable").displayed?}
      insertedLeadInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Owner.Name, LeadSource , Lead_Source_Detail__c , Building_Interested_In__c , Building_Interested_Name__c ,Journey_Created_On__c, Locations_Interested__c , Number_of_Full_Time_Employees__c , Interested_in_Number_of_Desks__c , Email , Phone , Company , Name , RecordType.Name , Status , Type__c FROM Lead WHERE Email = '#{@testDataJSON['Lead'][0]['Email']}'")[0]
      insertedJourneyInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,Owner.Name,Outreach_Stage__c, CreatedDate ,Status__c , NMD_Next_Contact_Date__c ,Primary_Email__c , Lead_Source__c , Lead_Source_Detail__c , Primary_Phone__c , Company_Name__c , Building_Interested_In__c , Locations_Interested__c , Interested_in_Number_of_Desks__c , Full_Time_Employees__c, Name   FROM Journey__c WHERE Primary_Email__c = '#{@testDataJSON['Lead'][0]['Email']}'")[0]
      @helper.addLogs("[Validate ] : Checking Lead is created after form submission")
      @helper.addLogs("[Expected ] : Lead should create with name #{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
      @helper.addLogs("[Actual ]   : Lead is created with name #{insertedLeadInfo.fetch("Name")}")
      @driver.find_element(:id, "Journey").find_element(:link, "Open").click
      @helper.instance_variable_get(:@wait).until {!@driver.find_element(:id, "spinnerContainer").displayed?}
      Helper.addRecordsToDelete("Lead", insertedLeadInfo.fetch('Id'))
      Helper.addRecordsToDelete("Journey__c", insertedJourneyInfo.fetch('Id'))
      expect(insertedLeadInfo).to_not eql nil
      @pageObject.journeyAction(2)
      @helper.addLogs("[Result ]   : Lead insertion checked successfully\n")
      @helper.addLogs("[Validate ] : Checking Lead owner should be logged in user")
      @helper.addLogs("[Expected ] : Owner of lead should be Logged in user")
      @helper.addLogs("[Actual ]   : Owner of lead is #{insertedLeadInfo.fetch("Owner").fetch("Name")}")
      expect(insertedLeadInfo.fetch("Owner").fetch("Name")).to eql @userInfo.fetch("display_name")
      @helper.addLogs("[Result ]   : Owner checked successfully\n")
      validate_case("Journey", insertedJourneyInfo, {'NMD_Next_Contact_Date__c' => Date.today().next.to_s, 'Lead_Source__c' => @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['LeadSource'], 'lead_Source_Detail__c' => @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]["lead_Source_Detail__c"], 'Primary_Email__c' => @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]["Email"], 'Primary_Phone__c' => @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]["Phone"], 'Company_Name__c' => @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]["Company"], 'Status__c' => 'Not Started'})
      generatedActivityForContact = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,Type__c,whatid, Subject , CreatedDate,Status ,Lead_Source__c , Lead_Source_Detail__c,Owner.Name,Locations_Interested__c, Number_of_Full_Time_Employees__c,Interested_in_Number_of_Desks__c,Company__c,WhoId FROM Task WHERE WhoId = '#{insertedJourneyInfo.fetch('Id')}' AND status != 'Completed' AND CreatedDate = TODAY")[0]
      Helper.addRecordsToDelete("Task", generatedActivityForContact.fetch('Id'))
      validate_case("Activity", generatedActivityForContact, {'WhatId' => insertedJourneyInfo.fetch('Id'), 'Type__c' => 'call', 'Subject' => 'follow-up', 'Locations_Interested__c' => @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Building_Interested_In__c'], 'Company__c' => @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Company'], 'Lead_Source_Detail__c' => "Inbound Call Page", 'Lead_Source__c' => "Inbound Call", 'Status' => 'Open'})

      @helper.addLogs('Success')
      @helper.postSuccessResult(3060)
    rescue Exception => e
      @helper.addLogs('Error')
      @helper.postFailResult(e, 3060)
      raise e
    end
  end
  it 'To Check Outreach Stage updation when the journey creation date and follow up after date difference is greater than 48 hours from sales console', :'3060' => 'true' do
    begin
      @helper.addLogs("[Step ]     : Create Lead record with consumer record type")
      if !@driver.find_elements(:id, "scc_widget_Inbound_Call").empty?
        EnziUIUtility.switchToFrame @driver, "scc_widget_Inbound_Call"
      end
      @pageObject.createLead(false)
      @helper.instance_variable_get(:@wait).until {!@driver.find_element(:id, "spinnerContainer").displayed?}
      @helper.instance_variable_get(:@wait).until {@driver.find_element(:id, "enzTable").displayed?}
      insertedLeadInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , Owner.Name, LeadSource , Lead_Source_Detail__c , Building_Interested_In__c , Building_Interested_Name__c ,Journey_Created_On__c, Locations_Interested__c , Number_of_Full_Time_Employees__c , Interested_in_Number_of_Desks__c , Email , Phone , Company , Name , RecordType.Name , Status , Type__c FROM Lead WHERE Email = '#{@testDataJSON['Lead'][0]['Email']}'")[0]
      insertedJourneyInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,Owner.Name,Outreach_Stage__c, CreatedDate ,Status__c , NMD_Next_Contact_Date__c ,Primary_Email__c , Lead_Source__c , Lead_Source_Detail__c , Primary_Phone__c , Company_Name__c , Building_Interested_In__c , Locations_Interested__c , Interested_in_Number_of_Desks__c , Full_Time_Employees__c, Name   FROM Journey__c WHERE Primary_Email__c = '#{@testDataJSON['Lead'][0]['Email']}'")[0]
      @helper.addLogs("[Validate ] : Checking Lead is created after form submission")
      @helper.addLogs("[Expected ] : Lead should create with name #{@testDataJSON['Lead'][0]['FirstName']} #{@testDataJSON['Lead'][0]['LastName']}")
      @helper.addLogs("[Actual ]   : Lead is created with name #{insertedLeadInfo.fetch("Name")}")
      @driver.find_element(:id, "Journey").find_element(:link, "Follow-Up Task").click
      @helper.instance_variable_get(:@wait).until {!@driver.find_element(:id, "spinnerContainer").displayed?}
      Helper.addRecordsToDelete("Lead", insertedLeadInfo.fetch('Id'))
      Helper.addRecordsToDelete("Journey__c", insertedJourneyInfo.fetch('Id'))
      expect(insertedLeadInfo).to_not eql nil
      @pageObject.journeyAction(2)
      @helper.addLogs("[Result ]   : Lead insertion checked successfully\n")
      @helper.addLogs("[Validate ] : Checking Lead owner should be logged in user")
      @helper.addLogs("[Expected ] : Owner of lead should be Logged in user")
      @helper.addLogs("[Actual ]   : Owner of lead is #{insertedLeadInfo.fetch("Owner").fetch("Name")}")
      expect(insertedLeadInfo.fetch("Owner").fetch("Name")).to eql @userInfo.fetch("display_name")
      @helper.addLogs("[Result ]   : Owner checked successfully\n")
      validate_case("Journey", insertedJourneyInfo, {'NMD_Next_Contact_Date__c' => Date.today().next.to_s, 'Lead_Source__c' => @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['LeadSource'], 'lead_Source_Detail__c' => @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]["lead_Source_Detail__c"], 'Primary_Email__c' => @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]["Email"], 'Primary_Phone__c' => @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]["Phone"], 'Company_Name__c' => @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]["Company"], 'Status__c' => 'Not Started'})
      generatedActivityForContact = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,Type__c,whatid, Subject , CreatedDate,Status ,Lead_Source__c , Lead_Source_Detail__c,Owner.Name,Locations_Interested__c, Number_of_Full_Time_Employees__c,Interested_in_Number_of_Desks__c,Company__c,WhoId FROM Task WHERE WhoId = '#{insertedJourneyInfo.fetch('Id')}' AND status != 'Completed' AND CreatedDate = TODAY")[0]
      Helper.addRecordsToDelete("Task", generatedActivityForContact.fetch('Id'))
      validate_case("Activity", generatedActivityForContact, {'WhatId' => insertedJourneyInfo.fetch('Id'), 'Type__c' => 'call', 'Subject' => 'follow-up', 'Locations_Interested__c' => @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Building_Interested_In__c'], 'Company__c' => @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Company'], 'Lead_Source_Detail__c' => "Inbound Call Page", 'Lead_Source__c' => "Inbound Call", 'Status' => 'Open'})

      @helper.addLogs('Success')
      @helper.postSuccessResult(3060)
    rescue Exception => e
      @helper.addLogs('Error')
      @helper.postFailResult(e, 3060)
      raise e
    end
  end
  it 'To Check Outreach Stage updation when the follow up is taken on multiple journey where journey creation date and follow up after date is greater than 48 hours.', :'3061' => 'true' do
    begin
      @helper.addLogs("[Step ]     : Create Lead records")
      if !@driver.find_elements(:id, "scc_widget_Inbound_Call").empty?
        EnziUIUtility.switchToFrame @driver, "scc_widget_Inbound_Call"
      end
      leadId = []
      @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Email'] = "John.Smith_QAAuto#{rand(9999999999999999)}@example.com"
      leadInfo = {"lastName" => @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['FirstName'], "firstName" => @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['LastName'], "website" => "http://www.Testgmail.com", "email" => @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Email'], "phone" => "8146185355", "company" => @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Company'], "company_Size__c" => @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Number_of_Full_Time_Employees__c'], "lead_Source_Detail__c" => @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Lead_Source_Detail__c'], "utm_campaign__c" => "San Francisco - Modifier", "utm_content__c" => "utm contents", "utm_medium__c" => "cpc", "utm_source__c" => "ads-google", "utm_term__c" => "virtual +office +san +francisco", "locale__c" => @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Locale__c'], "country_Code__c" => @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Country_Code__c'], "number_of_Desks__c" => @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Interested_in_Number_of_Desks__c'], "leadSource" => @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['LeadSource']}
      leadId[0] = @helper.instance_variable_get(:@restForce).createRecord("Lead", leadInfo)
      Helper.addRecordsToDelete("Lead", leadId[0])
      leadInfo['email'] = "John.Smith_QAAuto#{rand(9999999999999999)}@example.com"
      leadId[1] = @helper.instance_variable_get(:@restForce).createRecord("Lead", leadInfo)
      Helper.addRecordsToDelete("Lead", leadId[1])
      @helper.addLogs("[Result ]   : Getting created journeys info\n")
      insertedJourneyInfo = []
      insertedLeadInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,(SELECT id FROM Journeys__r WHERE Primary_Lead__c IN ('#{leadId[0]}','#{leadId[1]}')) FROM Lead WHERE id IN ('#{leadId[0]}','#{leadId[1]}')")
      insertedJourneyInfo.push(insertedLeadInfo[0].fetch("Journeys__r").to_a[0])
      insertedJourneyInfo.push(insertedLeadInfo[1].fetch("Journeys__r").to_a[0])
      Helper.addRecordsToDelete("Journey__c", insertedJourneyInfo[0]['Id'])
      Helper.addRecordsToDelete("Journey__c", insertedJourneyInfo[1]['Id'])
      sleep(5)
      @driver.switch_to.default_content
      if @driver.find_elements(:id, "ext-gen47").empty? && !@driver.find_elements(:id,"navigatortab__scc-pt-newtab-0").empty?
        @driver.find_element(:id,"ext-gen115").click
      end
      sleep(20)
      @helper.instance_variable_get(:@wait).until {@driver.find_element(:id, "ext-gen47").displayed?}
      @driver.find_element(:id, "ext-gen47").click
      EnziUIUtility.switchToFrame(@driver, "ext-comp-1005")
      @driver.find_element(:name, "fcf").click
      @driver.find_element(:name, "fcf").find_element(:xpath, "//option[@value='00B0G000008Tf2U']").click
      @helper.instance_variable_get(:@wait).until {!@driver.find_element(:id, "00B0G000008Tf2U_loading").displayed?} if @driver.find_element(:id, "00B0G000008Tf2U_loading").displayed?
      @driver.find_element(:id, "00B0G000008Tf2U_refresh").click
      sleep(5)
      @driver.find_element(:id, "#{insertedJourneyInfo[0]['Id'][0,insertedJourneyInfo[0]['Id'].length-3]}").click
      @driver.find_element(:id, "#{insertedJourneyInfo[1]['Id'][0,insertedJourneyInfo[1]['Id'].length-3]}").click
      @driver.find_element(:class, "piped").find_element(:xpath, "//input[@value='Follow Up']").click
      EnziUIUtility.switchToWindow(@driver, "Followup Calls")
      @helper.instance_variable_get(:@wait).until {@driver.find_element(:id, "main-container").displayed?}
      @driver.find_element(:id, "main-container").find_element(:tag_name, "select").click
      @driver.find_element(:id, "main-container").find_element(:tag_name, "select").find_elements(:tag_name,"option")[1].click
      @driver.find_element(:id, "main-container").find_element(:tag_name, "select").find_elements(:tag_name,"option")[1].click
      @driver.find_element(:id, "next-folowup-date").send_keys(Date.today().next.to_s)
      @driver.find_element(:id, "field-comment").click
      @helper.instance_variable_get(:@wait).until {@driver.find_element(:id, "view-save").displayed?}
      @driver.find_element(:id, "view-save").click
      sleep(5)
      insertedJourneyInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,Owner.Name,Outreach_Stage__c, NMD_Next_Contact_Date__c FROM Journey__c WHERE Primary_Lead__c IN ('#{leadId[0]}','#{leadId[1]}')")
      today = Date.today.next.to_s
      puts today
      validate_case("Journey", insertedJourneyInfo[0], {'NMD_Next_Contact_Date__c' => today})
      validate_case("Journey", insertedJourneyInfo[1], {'NMD_Next_Contact_Date__c' => today})
      generatedActivityForJourney = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,Type__c,whatid, Subject , CreatedDate,Status ,Lead_Source__c , Lead_Source_Detail__c,Owner.Name,Locations_Interested__c, Number_of_Full_Time_Employees__c,Interested_in_Number_of_Desks__c,Company__c,WhoId FROM Task WHERE WhoId = '#{insertedJourneyInfo[0].fetch('Id')}' AND status != 'Completed' AND CreatedDate = TODAY")[0]
      Helper.addRecordsToDelete("Task", generatedActivityForJourney.fetch('Id'))
      validate_case("Activity", generatedActivityForJourney, {'WhatId' => insertedJourneyInfo.fetch('Id'), 'Type__c' => 'call', 'Subject' => 'follow-up', 'Locations_Interested__c' => @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Building_Interested_In__c'], 'Company__c' => @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Company'], 'Lead_Source_Detail__c' => "Inbound Call Page", 'Lead_Source__c' => "Inbound Call", 'Status' => 'Open'})
      generatedActivityForJourney = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,Type__c,whatid, Subject , CreatedDate,Status ,Lead_Source__c , Lead_Source_Detail__c,Owner.Name,Locations_Interested__c, Number_of_Full_Time_Employees__c,Interested_in_Number_of_Desks__c,Company__c,WhoId FROM Task WHERE WhoId = '#{insertedJourneyInfo[1].fetch('Id')}' AND status != 'Completed' AND CreatedDate = TODAY")[0]
      Helper.addRecordsToDelete("Task", generatedActivityForJourney.fetch('Id'))
      validate_case("Activity", generatedActivityForJourney, {'WhatId' => insertedJourneyInfo.fetch('Id'), 'Type__c' => 'call', 'Subject' => 'follow-up', 'Locations_Interested__c' => @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Building_Interested_In__c'], 'Company__c' => @pageObject.instance_variable_get(:@testDataJSON)['Lead'][0]['Company'], 'Lead_Source_Detail__c' => "Inbound Call Page", 'Lead_Source__c' => "Inbound Call", 'Status' => 'Open'})
      @helper.addLogs('Success')
      @helper.postSuccessResult(3060)
    rescue Exception => e
      @helper.addLogs('Error')
      @helper.postFailResult(e, 3060)
      raise e

    end
  end
  def validate_case(object,actual,expected)
    expected.keys.each do |key|
      if actual.key? key
        @helper.addLogs("[Validate ] : Checking #{object} : #{key}")
        @helper.addLogs("[Expected ] : #{actual[key]}")
        @helper.addLogs("[Actual ]   : #{expected[key]}")
        expect(expected[key]).to eql actual[key]
        @helper.addLogs("[Result ]   : #{key} checked successfully")
        puts "\n"
      end
    end
  end
end
