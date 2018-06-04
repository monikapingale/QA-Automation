#require 'yaml'
#require 'rspec'
#require 'json'
#require 'selenium-webdriver'
require 'enziUIUtility'
require 'salesforce'
require 'faye'
require_relative File.expand_path('../../../../', Dir.pwd) + "/GemUtilities/enziRestforce/lib/enziRestforce.rb"
require_relative File.expand_path('../../../../', Dir.pwd) + "/GemUtilities/RollbarUtility/rollbarUtility.rb"
require_relative File.expand_path('../../../../', Dir.pwd) + "/GemUtilities/EnziTestRailUtility/lib/EnziTestRailUtility.rb"

#require_relative File.expand_path('../',Dir.pwd )+"/GemUtilities/RollbarUtility/rollbarUtility.rb"
#require_relative File.expand_path('../',Dir.pwd )+"/GemUtilities/EnziTestRailUtility/lib/EnziTestRailUtility.rb"

#require_relative File.expand_path('',Dir.pwd )+ "/credentials.yaml"
#require_relative File.expand_path(Dir.pwd+"/GemUtilities/testRecords.json")
class Helper
  def initialize()
    #@testRailUtility = EnziTestRailUtility::TestRailUtility.new('team-qa@enzigma.com','7O^dv0mi$IZHf4Cn')
    @runId = ENV['RUN_ID']
    #@runId = '1698'
    @objRollbar = RollbarUtility.new()

    @sObjectRecords = JSON.parse(File.read(File.expand_path('../../../../', Dir.pwd) + "/testRecords.json"))
    @timeSettingMap = YAML.load_file(File.expand_path('../../../../', Dir.pwd) + '/timeSettings.yaml')
    @mapCredentials = YAML.load_file(File.expand_path('../../../../', Dir.pwd) + '/credentials.yaml')
    @wait = Selenium::WebDriver::Wait.new(:timeout => @timeSettingMap['Wait']['Environment']['Lightening']['Min'])
    @testRailUtility = EnziTestRailUtility::TestRailUtility.new(@mapCredentials['TestRail']['username'], @mapCredentials['TestRail']['password'])
    @salesforceBulk = Salesforce.login(@mapCredentials['Staging']['WeWork System Administrator']['username'], @mapCredentials['Staging']['WeWork System Administrator']['password'], true)
    @restForce = EnziRestforce.new(@mapCredentials['Staging']['WeWork System Administrator']['username'], @mapCredentials['Staging']['WeWork System Administrator']['password'], @mapCredentials['Staging']['WeWork System Administrator']['client_id'], @mapCredentials['Staging']['WeWork System Administrator']['client_secret'], true)
    @settings = @restForce.getRecords("SELECT name,Data__c FROM Setting__c WHERE name IN ('User/Queue Journey Creation','Lead:Lead and Lead Source Details','Unassigned NMD US Queue','SplashEventJourney')")
  end

  def alert_present?(driver)
    driver.switch_to.alert
    true
  rescue Selenium::WebDriver::Error::NoAlertPresentError
    false
  end

  def close_alert_and_get_its_text(driver, how, what)
    alert = driver.switch_to().alert()
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

  def self.addRecordsToDelete(key, value)
    if EnziRestforce.class_variable_get(:@@createdRecordsIds).key?("#{key}") then
      EnziRestforce.class_variable_get(:@@createdRecordsIds)["#{key}"] << Hash["Id" => value]
    else
      EnziRestforce.class_variable_get(:@@createdRecordsIds)["#{key}"] = [Hash["Id" => value]]
    end
  end

  def postSuccessResult(caseId)
    puts "----------------------------------------------------------------------------------"
    puts ""
    @testRailUtility.postResult(caseId, "Pass", 1, @runId)
    @passedLogs = @objRollbar.addLogs("[Result  ]  Success")
  end

  def postFailResult(exception, caseId)
    puts "----------------------------------------------------------------------------------"
    puts ""
    puts exception
    caseInfo = @testRailUtility.getCase(caseId)
    @passedLogs = @objRollbar.addLogs("[Result  ]  Failed")
    @objRollbar.postRollbarData(caseInfo['id'], caseInfo['title'], @passedLogs[caseInfo['id']])
    Rollbar.error(exception)
    @testRailUtility.postResult(caseId, "Result for case #{caseId} is #{exception}", 5, @runId)
    raise exception
  end

  def addLogs(logs, caseId = nil)
    if caseId != nil then
      @passedLogs = @objRollbar.addLogs(logs, caseId)
    else
      @passedLogs = @objRollbar.addLogs(logs)
    end
  end

  def getRecordJSON()
    return @sObjectRecords
  end

  def getSalesforceRecord(sObject, query)
    puts query
    result = Salesforce.getRecords(@salesforceBulk, "#{sObject}", "#{query}", nil)
    #puts "#{sObject} created => #{result.result.records}"
    return result.result.records
  rescue Exception => e
    puts e
    puts "No record found111111"
    return nil
  end

  def createSalesforceRecord(objectType, records_to_insert)

    result = Salesforce.createRecords(@salesforceBulk, objectType, records_to_insert)

  end

  def getRestforceObj()
    return @restForce
  end

  def getSalesforceRecordByRestforce(query)
    #puts query
    record = @restForce.getRecords("#{query}")
    if record.size > 1 then
      puts "Multiple records handle carefully....!!!"
    elsif record.size == 0 then
      puts "No record found....!!!"
      return nil
    end
    #puts record[0].attrs['Id']
    return record
  rescue Exception => e
    puts e
    return nil
  end

  def deleteSalesforceRecordBySfbulk(sObject, recordsToDelete)
    #puts recordsToDelete
    result = Salesforce.deleteRecords(@salesforceBulk, sObject, recordsToDelete)
    puts "record deleted===> #{result}"
    puts result
    return true
  rescue Exception => e
    puts e
    return nil
  end

  def getElementByAttribute(driver, elementFindBy, elementIdentity, attributeName, attributeValue)
    puts "in accountAssignment::getElementByAttribute"
    driver.execute_script("arguments[0].scrollIntoView();", driver.find_element(elementFindBy, elementIdentity))
    puts "in getElementByAttribute #{attributeValue}"
    @driver = driver
    elements = @driver.find_elements(elementFindBy, elementIdentity)
    elements.each do |element|
      if element.attribute(attributeName) != nil then
        if element.attribute(attributeName).include? attributeValue then
          puts "element found"
          return element
          break
        end
      end
    end
  end

#Please provide exact app name displayed on app list
  def go_to_app(driver, app_name)
    @wait.until {driver.find_element(:id, "tsidButton")}
    appButton = driver.find_elements(:id, "tsidButton")
    addLogs("[Step ]   : Opening #{app_name} app")
    if !appButton.empty?
      driver.find_element(:id, "tsidButton").click
      @wait.until {driver.find_element(:id, "tsid-menuItems")}
      appsDrpDwn = driver.find_element(:id, "tsid-menuItems").find_elements(:link, app_name)
      if !appsDrpDwn.empty?
        appsDrpDwn[0].click
        addLogs("[Result ] : #{app_name} app opened successfully")
      else
        driver.find_element(:id, "tsidButton").click
        addLogs("[Result ] : Already on #{app_name}")
      end
    end
  end

  def update_campaign(id, lead_owner = nil, email = nil, city = nil)
    @restForce.updateRecord("Campaign", {"Id" => id, "Lead_Owner__c" => lead_owner, "Email_Address__c" => email, "City__c" => city})
  end

  def getExistingLead(from, to, owner = nil, checkForActivity = nil)
    index = from
    userHasPermission = false
    owner = " AND CreatedBy.Name = '#{owner}'" if !owner.nil?
    checkForActivity = "(SELECT id FROM tasks)," if !checkForActivity.nil?
    if !from.nil? || !to.nil?
      leadInfo = @restForce.getRecords("SELECT id , #{checkForActivity} Owner.Name,Owner.id,LeadSource , Lead_Source_Detail__c , Building_Interested_In__c , Building_Interested_Name__c ,Journey_Created_On__c, Locations_Interested__c , Number_of_Full_Time_Employees__c , Interested_in_Number_of_Desks__c , Email , Phone , Company , Name , RecordType.Name , Status , Type__c FROM Lead WHERE CreatedBy.Name IN ('Veena Hegane','Ashotosh Thakur','Monika Pingale','Kishor Shinde') AND Email like '%@example.com' AND CreatedDate < #{from} AND CreatedDate  = LAST_N_DAYS:#{to} AND  isDeleted = false #{owner}")
      allowedUsers = JSON.parse(@settings[3]['Data__c'])['allowedUsers']
      leadInfo.each do |lead|
        if allowedUsers.include?({"Id" => lead.fetch("Owner").fetch("Id")})
          userHasPermission = true
          leadInfo = lead
          break;
        end
      end
      if leadInfo.nil?
        until !(index < to) || userHasPermission
          if leadInfo[0].nil?
            leadInfo = @restForce.getRecords("SELECT id , Owner.Name, Owner.id,LeadSource , Lead_Source_Detail__c , Building_Interested_In__c , Building_Interested_Name__c ,Journey_Created_On__c, Locations_Interested__c , Number_of_Full_Time_Employees__c , Interested_in_Number_of_Desks__c , Email , Phone , Company , Name , RecordType.Name , Status , Type__c FROM Lead WHERE CreatedBy.Name IN ('Veena Hegane','Ashotosh Thakur','Monika Pingale','Kishor Shinde') AND Email like '%@example.com' AND CreatedDate = LAST_N_DAYS:#{index} AND isDeleted = false #{owner}")
            leadInfo.each do |lead|
              if allowedUsers.include?({"Id" => lead.fetch("Owner").fetch("Id")})
                userHasPermission = true
                leadInfo = lead
                break;
              end
            end
          end
        end
      else
        leadInfo.each do |lead|
          if allowedUsers.include?({"Id" => lead.fetch("Owner").fetch("Id")})
            userHasPermission = true
            leadInfo = lead
            break;
          end
        end
      end
      index += 1
    else
      puts "Getting Records....."
      leadInfo = @restForce.getRecords("SELECT id , #{checkForActivity} Owner.Name,Owner.id,LeadSource , Lead_Source_Detail__c , Building_Interested_In__c , Building_Interested_Name__c ,Journey_Created_On__c, Locations_Interested__c , Number_of_Full_Time_Employees__c , Interested_in_Number_of_Desks__c , Email , Phone , Company , Name , RecordType.Name , Status , Type__c FROM Lead WHERE Email like '%@example.com' AND isConverted = false AND isDeleted = false #{owner} LIMIT 10")
    end

    leadInfo if !leadInfo.nil?
  end
  def createPushTopic(name,query)
# Create a PushTopic for subscribing to record changes.
    client.upsert! 'PushTopic', {
        ApiVersion: '23.0',
        Name: name,
        Description: 'Monitoring ',
        NotifyForOperations: 'All',
        NotifyForFields: 'All',
        Query: query
    }
  end
end

