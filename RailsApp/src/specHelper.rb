=begin
require 'rspec'
  # Retrieve a list of formatters
  formatters = RSpec.configuration.formatters
  config = RSpec.configuration
  config.add_formatter(:json)
  config.add_formatter(:documentation)
  #formater = RSpec::Core::Formatters::JsonFormatter.new(config.instance_variable_get(:@output_stream))
  formatter = RSpec::Core::Formatters::JsonFormatter.new(config.instance_variable_get(:@output_stream))
  reporter  = RSpec::Core::Reporter.new(config)
  # create reporter with json formatter
  #reporter =  RSpec::Core::Reporter.new(config)
  # set reporter for rspec configuration
  config.instance_variable_set(:@reporter, reporter)
  loader = config.send(:formatter_loader)
  notifications = loader.send(:notifications_for, RSpec::Core::Formatters::JsonFormatter)
  reporter.register_listener(formatter, *notifications)
=end
require 'yaml'
require 'json'
require 'selenium-webdriver'
require 'enziUIUtility'
require 'enziSalesforce'
require_relative File.expand_path('../',Dir.pwd )+"/GemUtilities/RollbarUtility/rollbarUtility.rb"
require_relative File.expand_path('../',Dir.pwd )+"/GemUtilities/EnziTestRailUtility/lib/EnziTestRailUtility.rb"
class Helper
  def initialize()
    @runId = ENV['RUN_ID']
    @objRollbar = RollbarUtility.new()
    @timeSettingMap = YAML.load_file(File.expand_path('..',Dir.pwd ) + '/timeSettings.yaml')
    @wait = Selenium::WebDriver::Wait.new(:timeout => @timeSettingMap['Wait']['Environment']['Lightening']['Min'])
    #@salesforceBulk = ARGV[1]
    @sObjectRecords = JSON.parse(File.read(File.expand_path('..',Dir.pwd ) + "/testRecords.json"))
    @mapCredentials = YAML.load_file(File.expand_path('..',Dir.pwd ) + '/credentials.yaml')
    @testRailUtility = EnziTestRailUtility::TestRailUtility.new(@mapCredentials['TestRail']['username'],@mapCredentials['TestRail']['password'])
    @salesforceBulk = Salesforce.login(@mapCredentials['Staging']['WeWork System Administrator']['username'], @mapCredentials['Staging']['WeWork System Administrator']['password'], true)
  end

  def getTime(which,environment,strength)
    @timeSettingMap[which]['Environment'][environment][strength]
  end

  def postSuccessResult(caseId)
    @testRailUtility.postResult(caseId,"Pass",1,@runId)
    @passedLogs = @objRollbar.addLog("[Result  ]  Success")
  end

  def postFailResult(exception,caseId)
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
    result = Salesforce.getRecords(@salesforceBulk, "#{sObject}", "#{query}", nil)
    return result.result.records
  rescue Exception => e
    return nil
  end

end


