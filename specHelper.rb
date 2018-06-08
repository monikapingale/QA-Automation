=begin
************************************************************************************************************************************
    Author      :   QaAutomationTeam
    Description :   This class provides methods for Business logic related to lead.

    History     :
  ----------------------------------------------------------------------------------------------------------------------------------
  VERSION            DATE             AUTHOR                  DETAIL
  1                 24 May 2018     QaAutomationTeam        sprint-1.0
**************************************************************************************************************************************
=end

#require 'yaml'
#require 'rspec'
#require 'json'
#require 'selenium-webdriver'
require 'enziUIUtility'
require 'enziSalesforce'
require 'enziRestforce'
require_relative File.expand_path('',Dir.pwd )+"/GemUtilities/RollbarUtility/rollbarUtility.rb"
require_relative File.expand_path('',Dir.pwd )+"/GemUtilities/EnziTestRailUtility/lib/EnziTestRailUtility.rb"
require_relative File.expand_path('',Dir.pwd)+"/GemUtilities/sfRESTService.rb"

#require_relative File.expand_path('../',Dir.pwd )+"/GemUtilities/RollbarUtility/rollbarUtility.rb"
#require_relative File.expand_path('../',Dir.pwd )+"/GemUtilities/EnziTestRailUtility/lib/EnziTestRailUtility.rb"
#require_relative File.expand_path('../',Dir.pwd)+"/GemUtilities/sfRESTService.rb"

#require_relative File.expand_path('',Dir.pwd )+ "/credentials.yaml"
#require_relative File.expand_path(Dir.pwd+"/GemUtilities/testRecords.json")
class Helper

=begin
  ************************************************************************************************************************************
        Author          :   QaAutomationTeam
        Description     :   This method authenticate user  and return @client object.
        Created Date    :   21 April 2018
        Issue No.       :
  **************************************************************************************************************************************
=end
def initialize()
  #@testRailUtility = EnziTestRailUtility::TestRailUtility.new('team-qa@enzigma.com','7O^dv0mi$IZHf4Cn')
  @runId = ENV['RUN_ID']
  #@runId = '1698'
  @objRollbar = RollbarUtility.new()
  
  @sObjectRecords = JSON.parse(File.read(File.expand_path('',Dir.pwd ) + "/testRecords.json"))
  @timeSettingMap = YAML.load_file(Dir.pwd + '/timeSettings.yaml')
  @mapCredentials = YAML.load_file(Dir.pwd + '/credentials.yaml')

  #@sObjectRecords = JSON.parse(File.read(File.expand_path('..',Dir.pwd ) + "/testRecords.json"))
  #@timeSettingMap = YAML.load_file(File.expand_path('..',Dir.pwd ) + '/timeSettings.yaml')
  #@mapCredentials = YAML.load_file(File.expand_path('..',Dir.pwd ) + '/credentials.yaml')
  @wait = Selenium::WebDriver::Wait.new(:timeout => @timeSettingMap['Wait']['Environment']['Lightening']['Max'])
    
  @testRailUtility = EnziTestRailUtility::TestRailUtility.new(@mapCredentials['TestRail']['username'],@mapCredentials['TestRail']['password'])
  #puts @mapCredentials['Staging']['WeWork System Administrator']['username']
  #puts @mapCredentials['Staging']['WeWork System Administrator']['password']
  #@salesforceBulk = Salesforce.login(@mapCredentials['Staging']['WeWork System Administrator']['username'], @mapCredentials['Staging']['WeWork System Administrator']['password'], true)
  #SfRESTService.new(@mapCredentials['Staging']['WeWork System Administrator']['grant_type'],@mapCredentials['Staging']['WeWork System Administrator']['client_id'],@mapCredentials['Staging']['WeWork System Administrator']['client_secret'],@mapCredentials['Staging']['WeWork System Administrator']['username'],@mapCredentials['Staging']['WeWork System Administrator']['password'])
  @sfRESTService = SfRESTService.new(@mapCredentials['Staging']['WeWork System Administrator']['grant_type'],@mapCredentials['Staging']['WeWork System Administrator']['client_id'],@mapCredentials['Staging']['WeWork System Administrator']['client_secret'],@mapCredentials['Staging']['WeWork System Administrator']['username'],@mapCredentials['Staging']['WeWork System Administrator']['password'])
  @restForce = EnziRestforce.new(@mapCredentials['Staging']['WeWork System Administrator']['username'],@mapCredentials['Staging']['WeWork System Administrator']['password'],@mapCredentials['Staging']['WeWork System Administrator']['client_id'],@mapCredentials['Staging']['WeWork System Administrator']['client_secret'],true)
end

=begin
  ************************************************************************************************************************************
        Author          :   QaAutomationTeam
        Description     :   This method authenticate user  and return @client object.
        Created Date    :   21 April 2018
        Issue No.       :
  **************************************************************************************************************************************
=end
#Please provide exact app name displayed on app list
  def go_to_app(driver, app_name)
      @wait.until {driver.find_element(:id, "tsidButton")}
      appButton = driver.find_elements(:id, "tsidButton")
      addLogs("[Step ] : Opening #{app_name} app")
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
      return true
    rescue Exception => e
      puts e
      return false
  end


=begin
  ************************************************************************************************************************************
        Author          :   QaAutomationTeam
        Description     :   This method authenticate user  and return @client object.
        Created Date    :   21 April 2018
        Issue No.       :
  **************************************************************************************************************************************
=end
  def getElementByAttribute(driver, elementFindBy, elementIdentity, attributeName, attributeValue,attributeName2 = nil,attributeValue2=nil)
    puts "in accountAssignment::getElementByAttribute"
    driver.execute_script("arguments[0].scrollIntoView();", driver.find_element(elementFindBy, elementIdentity))
    #puts "in getElementByAttribute #{attributeValue}"
    elements = driver.find_elements(elementFindBy, elementIdentity)
    elements.each do |element|
      if element.attribute(attributeName) != nil then
        if attributeName2.nil? then
          if element.attribute(attributeName).include? attributeValue then
            #puts "element found"
            return element
          end
        elsif !attributeName2.nil? then
          puts "2nd attribute check"
          if attributeValue2.nil? then
            puts "2nd value in nil"
            puts "121--1"
            puts element.attribute(attributeName)
            puts "121--2"
            puts element.attribute(attributeName2)
            puts "121--2"
            if (element.attribute(attributeName).include? attributeValue)  && (element[0].attribute(attributeName2).nil?) then
              puts "2nd attributeValue -- nil"
              #puts "element found"
              return element
            end
          else
            if (element.attribute(attributeName).include? attributeValue)  && (element.attribute(attributeName2).include? attributeValue2) then
              #puts "element found"
              puts '2nd attributeValue -- not nil'
              return element
            end
          end
        end
      end
    end
  end




=begin
  ************************************************************************************************************************************
        Author          :   QaAutomationTeam
        Description     :   This method authenticate user  and return @client object.
        Created Date    :   21 April 2018
        Issue No.       :
  **************************************************************************************************************************************
=end
def postSuccessResult(caseId)
  puts "----------------------------------------------------------------------------------"
  puts ""
  @testRailUtility.postResult(caseId,"Pass",1,@runId)
  @passedLogs = @objRollbar.addLog("[Result  ]  Success")
end


=begin
  ************************************************************************************************************************************
        Author          :   QaAutomationTeam
        Description     :   This method authenticate user  and return @client object.
        Created Date    :   21 April 2018
        Issue No.       :
  **************************************************************************************************************************************
=end
def postFailResult(exception,caseId)
  puts "----------------------------------------------------------------------------------"
  puts ""
  puts exception
  caseInfo = @testRailUtility.getCase(caseId)
  #puts "$$$$$$$$$$$$$$$$$$$$$"
  #puts caseInfo['id']
  @passedLogs = @objRollbar.addLog("[Result  ]  Failed")
  #puts "postResult---->#{@passedLogs[caseInfo['id'].to_s]}"
  #puts @passedLogs[caseInfo['id']]
  @objRollbar.postRollbarData(caseInfo['id'], caseInfo['title'], @passedLogs[caseInfo['id'].to_s])
  #puts "&&&&&&&&&&&&&&&&&&&"
  Rollbar.error(exception)
  @testRailUtility.postResult(caseId,"Result for case #{caseId} is #{exception}",5,@runId)
  raise exception
end

=begin
  ************************************************************************************************************************************
        Author          :   QaAutomationTeam
        Description     :   This method authenticate user  and return @client object.
        Created Date    :   21 April 2018
        Issue No.       :
  **************************************************************************************************************************************
=end
def addLogs(logs,caseId = nil)
  if caseId != nil then
    @passedLogs= @objRollbar.addLog(logs,caseId)
  else
    @passedLogs = @objRollbar.addLog(logs)
  end
end

=begin
  ************************************************************************************************************************************
        Author          :   QaAutomationTeam
        Description     :   This method authenticate user  and return @client object.
        Created Date    :   21 April 2018
        Issue No.       :
  **************************************************************************************************************************************
=end
def getRecordJSON()
  return @sObjectRecords
end


=begin
  ************************************************************************************************************************************
        Author          :   QaAutomationTeam
        Description     :   This method authenticate user  and return @client object.
        Created Date    :   21 April 2018
        Issue No.       :
  **************************************************************************************************************************************
=end
def getSalesforceRecord(sObject,query)
   puts query
    result = Salesforce.getRecords(@salesforceBulk, "#{sObject}", "#{query}", nil)
    #puts "#{sObject} created => #{result.result.records}"
    return result.result.records
  rescue Exception => e 
    puts e
    puts "No record found111111"
    return nil
end

=begin
  ************************************************************************************************************************************
        Author          :   QaAutomationTeam
        Description     :   This method authenticate user  and return @client object.
        Created Date    :   21 April 2018
        Issue No.       :
  **************************************************************************************************************************************
=end
def createSalesforceRecords(objectType,records_to_insert)
    result= Salesforce.createRecords(@salesforceBulk,objectType ,records_to_insert)
    return result
end


=begin
  ************************************************************************************************************************************
        Author          :   QaAutomationTeam
        Description     :   This method authenticate user  and return @client object.
        Created Date    :   21 April 2018
        Issue No.       :
  **************************************************************************************************************************************
=end
def createRecord(sObject,records_to_insert)
  puts "in @helper::createRecord"
  puts records_to_insert
    record = @restForce.createRecord(sObject,records_to_insert)
    puts record
    return record
end

=begin
  ************************************************************************************************************************************
        Author          :   QaAutomationTeam
        Description     :   This method authenticate user  and return @client object.
        Created Date    :   21 April 2018
        Issue No.       :
  **************************************************************************************************************************************
=end
def getRestforceObj()
  return @restForce
end

=begin
  ************************************************************************************************************************************
        Author          :   QaAutomationTeam
        Description     :   This method authenticate user  and return @client object.
        Created Date    :   21 April 2018
        Issue No.       :
  **************************************************************************************************************************************
=end
def getSalesforceRecordByRestforce(query)
    puts query
    record = @restForce.getRecords("#{query}")
    puts "record fetched....in helper"
    if record.size > 1 then
      puts "Multiple records handle carefully....!!!"
    elsif record.size == 0 then
      puts "No record found....!!!"
      return nil      
    end
    puts record[0].attrs
    return record
  rescue Exception => e 
    puts e
    return nil
end

=begin
  ************************************************************************************************************************************
        Author          :   QaAutomationTeam
        Description     :   This method authenticate user  and return @client object.
        Created Date    :   21 April 2018
        Issue No.       :
  **************************************************************************************************************************************
=end
def deleteSalesforceRecordBySfbulk(sObject,recordsToDelete)
  #puts recordsToDelete
  result = Salesforce.deleteRecords(@salesforceBulk,sObject,recordsToDelete)
  puts "record deleted===> #{result}"
  puts result
  return true
  rescue Exception => e
  puts e
  return nil
end

=begin
  ************************************************************************************************************************************
        Author          :   QaAutomationTeam
        Description     :   This method authenticate user  and return @client object.
        Created Date    :   21 April 2018
        Issue No.       :
  **************************************************************************************************************************************

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


=end
end

