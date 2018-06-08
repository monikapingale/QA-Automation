#Created By : Monika Pingale
#Created Date : 31/01/2018
#Modified date :
require 'yaml'
require 'rspec'
require 'json'
require "selenium-webdriver"
require 'enziUIUtility'
require 'enziSalesforce'
#require_relative File.expand_path(Dir.pwd+"/specHelper.rb")
require_relative File.expand_path(Dir.pwd+"/GemUtilities/EnziTestRailUtility/lib/EnziTestRailUtility.rb")
specMap = Hash.new
mapSuitRunId = Hash.new
config = YAML.load_file('credentials.yaml')
testRailUtility = EnziTestRailUtility::TestRailUtility.new(config['TestRail']['username'],config['TestRail']['password'])
if ARGV.size == 1 &&  !ENV['PROJECT_ID'].nil? then
  ARGV = ["project:#{ENV['PROJECT_ID']}", "suit:#{ENV['SUIT_ID']}" , "section:#{ENV['SECTION_ID']}" , "browser:#{ENV['BROWSERS']}" , "case:#{ENV['CASE_ID']}" , "profile:#{ENV['PROFILE']}"]
end
if !ARGV.empty? then
  ARGV.each do |input|
    containerInfo = input.split(":")
    if specMap.key?(containerInfo[0]) && containerInfo.size > 1 then
      specMap[containerInfo[0]] << containerInfo[1].split(",").uniq
    else
      if containerInfo.size > 1 then
        specMap[containerInfo[0]] = containerInfo[1].split(",").uniq
      end
    end
  end
  specs = Array.new
  if !specMap.empty? && !specMap.values.empty? then
    if specMap.key?('case') && specMap.fetch('case').size > 0 then
      RSpec.configuration.filter_runs_including(specMap.fetch('case'))
      if specMap.key?('case') && specMap.key?('section') && specMap.key?('suit') && specMap.key?('project') then

        specMap.fetch('case').each do |caseId|
          if ENV['RUN_ID'].nil? && specMap.key?('profile') && specMap.fetch('profile').size > 0
            specs.concat(testRailUtility.getSpecLocations(caseId,specMap.fetch('case'),specMap.fetch('suit'),nil,specMap.fetch('project'),specMap.fetch('profile')))
          else
           specs.concat(testRailUtility.getSpecLocations(caseId,specMap.fetch('case'),specMap.fetch('suit'),nil,specMap.fetch('project'),nil))
          end

        end
      else
        if ENV['RUN_ID'].nil? && specMap.key?('profile') && specMap.fetch('profile').size > 0
          specs.concat(testRailUtility.getSpecLocations(caseId,specMap.fetch('case'),nil,nil,nil,specMap.fetch('profile')))
        else
          specs.concat(testRailUtility.getSpecLocations(caseId,specMap.fetch('case'),nil,nil,nil,nil))
        end
      end
    end
    if !specMap.key?('case') && specMap.key?('section') then
      if specMap.key?('suit') && specMap.key?('project') then
        specMap.fetch('section').each do |sectionId|
          if ENV['RUN_ID'].nil? && specMap.key?('profile') && specMap.fetch('profile').size > 0
            specs.concat(testRailUtility.getSpecLocations(nil,sectionId,specMap.fetch('suit')[0],nil,specMap.fetch('project')[0],specMap.fetch('profile')))
          else
            specs.concat(testRailUtility.getSpecLocations(nil,sectionId,specMap.fetch('suit')[0],nil,specMap.fetch('project')[0],nil))
          end
        end
      else
        specMap.fetch('section').each do |sectionId|
          suitId  = testRailUtility.getSection(sectionId)['suite_id']
          if ENV['RUN_ID'].nil? && specMap.key?('profile') && specMap.fetch('profile').size > 0
          specs.concat(testRailUtility.getSpecLocations(nil,sectionId,suitId,nil,testRailUtility.getSuite(suitId)['project_id'],specMap.fetch('profile')))
          else
            specs.concat(testRailUtility.getSpecLocations(nil,sectionId,suitId,nil,testRailUtility.getSuite(suitId)['project_id'],nil))
          end
        end
      end
    end
    if !specMap.key?('case') &&!(specMap.key?('section')) && specMap.key?('suit') then
      if specMap.key?('project') then
        specMap.fetch('suit').each do |suitId|
          if ENV['RUN_ID'].nil? && specMap.key?('profile') && specMap.fetch('profile').size > 0
            specs.concat(testRailUtility.getSpecLocations(nil,nil,suitId,nil,specMap.fetch('project')[0],specMap.fetch('profile')))
          else
            specs.concat(testRailUtility.getSpecLocations(nil,nil,suitId,nil,specMap.fetch('project')[0],nil))
          end
        end
      else
        specMap.fetch('suit').each do |suitId|
          if ENV['RUN_ID'].nil? && specMap.key?('profile') && specMap.fetch('profile').size > 0
            specs.concat(testRailUtility.getSpecLocations(nil,nil,suitId,nil,suitInfo['project_id'],specMap.fetch('profile')))
          else
            specs.concat(testRailUtility.getSpecLocations(nil,nil,suitId,nil,suitInfo['project_id'],nil))
          end
        end
      end
    end
    if specMap.key?('plan') then
      specMap.fetch('plan').each do |planId|
        specs.concat(testRailUtility.getSpecLocations(nil,nil,nil,planId,nil))
      end
    end
    if  !(specMap.key?('suit') || specMap.key?('section')) && specMap.key?('project') then
      specMap.fetch('project').each do |projectId|
        if ENV['RUN_ID'].nil? && specMap.key?('profile') && specMap.fetch('profile').size > 0
          specs.concat(testRailUtility.getSpecLocations(nil,nil,nil,nil,projectId,specMap.fetch('profile')))
        else
          specs.concat(testRailUtility.getSpecLocations(nil,nil,nil,nil,projectId,nil))
        end
      end
    end
  end

  if !ENV['PROJECT_ID'].nil? && ENV['SUIT_ID'].nil? && ENV['SECTION_ID'].nil? && !ENV['RUN_ID'].nil? then
    ENV['RUN_ID'].split(",").each do |runId|
      mapSuitRunId[testRailUtility.getSpecLocations(nil,nil,testRailUtility.getRun(runId)['suite_id'],nil,ENV['PROJECT_ID'],nil)[0]['path']] = runId
    end
  end
  if !specs.empty? then
    ARGV[1] = Salesforce.login(config['Staging']["WeWork System Administrator"]['username'],config['Staging']["WeWork System Administrator"]['password'],true)
    ARGV[2] = EnziTestRailUtility::TestRailUtility.new(config['TestRail']['username'],config['TestRail']['password'])
    specs.uniq.each do |spec|
      #Run spec in multiple browsers
      if !spec.nil? then
        if !ENV['PROJECT_ID'].nil? && ENV['SUIT_ID'].nil? && ENV['SECTION_ID'].nil? then
          ENV['RUN_ID'] = mapSuitRunId[spec['path']]
        end
        if spec['isBrowserDependent'] then
          specMap.fetch('browser')[0].split(" ").each do |browser|
            ARGV[0] = Selenium::WebDriver.for browser.to_sym
            ARGV[0].get "https://test.salesforce.com/login.jsp?pw=#{config['Staging']["WeWork System Administrator"]['password']}&un=#{config['Staging']["WeWork System Administrator"]['username']}"
            EnziUIUtility.switchToClassic(ARGV[0])
            EnziUIUtility.wait(ARGV[0], :id, 'phSearchInput', YAML.load_file('timeSettings.yaml')['Wait']['Environment']['Classic']['Max'])
            #config['Staging'].keys.each do |profile|
            #ENV['BROWSER'] = browser
            ARGV[0].get "#{ARGV[0].current_url().split('/home')[0]}/005"
            EnziUIUtility.wait(ARGV[0], :id, 'fcf', YAML.load_file('timeSettings.yaml')['Wait']['Environment']['Classic']['Min'])
            if !ARGV[0].find_element(:id,"fcf").attribute('value').eql?('00BF0000006mfEJ') then
              ARGV[0].find_element(:id,"fcf").click
              EnziUIUtility.selectElement(ARGV[0].find_element(:id,"fcf"),"Active Users","option").click
            end
            profiles = []
            if specMap.key?('profile') && specMap.fetch('profile').size > 0
              profiles = specMap.fetch('profile')
            else
              profiles = YAML.load_file('UserSettings.yaml')['profile']
            end
            profiles.each_index do |index,profile|
              if ENV['RUN_ID'].nil? && specMap.key?('profile') && specMap.fetch('profile').size > 0
                ENV['RUN_ID'] = spec['runId'][index]
              end
              EnziUIUtility.wait(ARGV[0], :name, 'new', YAML.load_file('timeSettings.yaml')['Wait']['Environment']['Classic']['Min'])
              EnziUIUtility.loginForUser(ARGV[0],profile)
              EnziUIUtility.switchToWindow(ARGV[0],ARGV[0].current_url())
              puts "Successfully Logged In with #{profile} profile"
              ::RSpec::Core::Runner.run([spec['path']], $stderr, $stdout)
              EnziUIUtility.logout(ARGV[0])
              EnziUIUtility.wait(ARGV[0], :name, 'new', YAML.load_file('timeSettings.yaml')['Wait']['Environment']['Classic']['Max'])
              RSpec.clear_examples
              testRailUtility.closeRun(ENV['RUN_ID'])
            end
            ARGV[0].quit
          end
        else
          ARGV[0] = "Staging,WeWork System Administrator"
          ::RSpec::Core::Runner.run([spec['path']], $stderr, $stdout)
          RSpec.clear_examples
        end
      end
    end
  end
end
