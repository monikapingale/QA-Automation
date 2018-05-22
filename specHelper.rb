#require 'yaml'
#require 'rspec'
#require 'json'
#require 'selenium-webdriver'
require 'enziUIUtility'
require 'enziSalesforce'
require 'enziRestforce'
require_relative File.expand_path('',Dir.pwd )+"/GemUtilities/RollbarUtility/rollbarUtility.rb"
require_relative File.expand_path('',Dir.pwd )+"/GemUtilities/EnziTestRailUtility/lib/EnziTestRailUtility.rb"

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
  
  @sObjectRecords = JSON.parse(File.read(File.expand_path('',Dir.pwd ) + "/testRecords.json"))
  @timeSettingMap = YAML.load_file(Dir.pwd + '/timeSettings.yaml')
  @mapCredentials = YAML.load_file(Dir.pwd + '/credentials.yaml')

  #@sObjectRecords = JSON.parse(File.read(File.expand_path('..',Dir.pwd ) + "/testRecords.json"))
  #@timeSettingMap = YAML.load_file(File.expand_path('..',Dir.pwd ) + '/timeSettings.yaml')
  #@mapCredentials = YAML.load_file(File.expand_path('..',Dir.pwd ) + '/credentials.yaml')
  

  @testRailUtility = EnziTestRailUtility::TestRailUtility.new(@mapCredentials['TestRail']['username'],@mapCredentials['TestRail']['password'])
  #puts @mapCredentials['Staging']['WeWork System Administrator']['username']
  #puts @mapCredentials['Staging']['WeWork System Administrator']['password']
  @salesforceBulk = Salesforce.login(@mapCredentials['Staging']['WeWork System Administrator']['username'], @mapCredentials['Staging']['WeWork System Administrator']['password'], true)
  @restForce = EnziRestforce.new(@mapCredentials['Staging']['WeWork System Administrator']['username'],@mapCredentials['Staging']['WeWork System Administrator']['password'],@mapCredentials['Staging']['WeWork System Administrator']['client_id'],@mapCredentials['Staging']['WeWork System Administrator']['client_secret'],true)
end



def postSuccessResult(caseId)
  puts "----------------------------------------------------------------------------------"
  puts ""
  @testRailUtility.postResult(caseId,"Pass",1,@runId)
  @passedLogs = @objRollbar.addLog("[Result  ]  Success")
end

def postFailResult(exception,caseId)
  puts "----------------------------------------------------------------------------------"
  puts ""
  puts exception
  caseInfo = @testRailUtility.getCase(caseId)
  @passedLogs = @objRollbar.addLog("[Result  ]  Failed")
  @objRollbar.postRollbarData(caseInfo['id'], caseInfo['title'], @passedLogs[caseInfo['id']])
  Rollbar.error(exception)
  @testRailUtility.postResult(caseId,"Result for case #{caseId} is #{exception}",5,@runId)
  raise exception
end

def addLogs(logs,caseId = nil)
  if caseId != nil then
    @passedLogs= @objRollbar.addLog(logs,caseId)
  else
    @passedLogs = @objRollbar.addLog(logs)
  end
end

def getRecordJSON()
  return @sObjectRecords
end

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

end

