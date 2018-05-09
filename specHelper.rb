require 'yaml'
require 'rspec'
require 'json'
require 'selenium-webdriver'
require 'enziUIUtility'
require 'enziSalesforce'
require_relative File.expand_path('',Dir.pwd )+"/GemUtilities/RollbarUtility/rollbarUtility.rb"
require_relative File.expand_path('',Dir.pwd )+"/GemUtilities/EnziTestRailUtility/lib/EnziTestRailUtility.rb"
#require_relative File.expand_path('',Dir.pwd )+ "/credentials.yaml"
#require_relative File.expand_path(Dir.pwd+"/GemUtilities/testRecords.json")

class Helper
def initialize()
  #@testRailUtility = EnziTestRailUtility::TestRailUtility.new('team-qa@enzigma.com','7O^dv0mi$IZHf4Cn')
  #@runId = ENV['RUN_ID']
  @runId = '1698'
  @objRollbar = RollbarUtility.new()
  @sObjectRecords = JSON.parse(File.read("/Users/sachin.chavan/RubymineProjects/QaAuto/testRecords.json"))
  @timeSettingMap = YAML.load_file(Dir.pwd + '/timeSettings.yaml')
  @mapCredentials = YAML.load_file(Dir.pwd + '/credentials.yaml')
  puts @mapCredentials
  @testRailUtility = EnziTestRailUtility::TestRailUtility.new(@mapCredentials['TestRail']['username'],@mapCredentials['TestRail']['password'])
  puts "hello"
end



def postSuccessResult(caseId)
  @testRailUtility.postResult(caseId,"Pass",1,@runId)
  @passedLogs = @objRollbar.addLog("[Result  ]  Success")
end

def postFailResult(exception,caseId)
  caseInfo = @testRailUtility.getCase(caseId)
  puts "caseInfo"
  puts caseInfo
  @passedLogs = @objRollbar.addLog("[Result  ]  Failed")
  @objRollbar.postRollbarData(caseInfo['id'], caseInfo['title'], @passedLogs[caseInfo['id']])
  Rollbar.error(exception)
  @testRailUtility.postResult(149,"Result for case 149 is #{exception}",5,@runId)
  raise exception
end

def addLogs(logs,caseId = nil)
  if caseId != nil then
    @passedLogs= @objRollbar.addLog(logs,caseId)
  else
    @passedLogs = @objRollbar.addLog(logs)
  end
end

def getRecordJSON(sObjectName)
  return @sObjectRecords[sObjectName][0]
end

end

