require 'json'
require 'selenium-webdriver'
require 'rspec'
require 'date'
require 'enziUIUtility'
require 'active_support/core_ext/hash'
require_relative File.expand_path('../../../../', Dir.pwd) + "/GemUtilities/EnziTestRailUtility/lib/EnziTestRailUtility.rb"
require_relative File.expand_path('../../../../', Dir.pwd) + "/GemUtilities/EnziUIUtility/lib/enziUIUtility.rb"
require_relative File.expand_path('../../../../', Dir.pwd) + '/specHelper.rb'
include RSpec::Expectations
describe 'Project' do
  before(:all) do
    @accept_next_alert = true
    @verification_errors = []
    @helper = Helper.new
    @wait = @helper.instance_variable_get(:@wait)
  end
  after(:each) do
    @verification_errors.should == []
  end
  context 'InboundLead', :'68' => 'true' do
    @testRailUtility = EnziTestRailUtility::TestRailUtility.new('team-qa@enzigma.com', '7O^dv0mi$IZHf4Cn')
    @testRailUtility.getCases(4, 26, 68).each do |caseid|
      it caseid['title'], :caseid['id'] => 'true' do
        begin
          caseHash = Hash.from_xml(File.read(%Q(scripts/333.xml)))
          caseHash['TestCase']['selenese'].each_with_index do |command,index|
            puts command
            if command['target'].eql?('id=tsidButton')
              @helper.go_to_app(@helper.instance_variable_get(:@driver),caseHash['TestCase']['selenese'][index+1]['target'].split('=')[1]);next;next
            else
              @helper.send(%Q(#{command['command']}).to_sym,%Q(#{command['target']}),%Q(#{command['value']}))
            end
          end
          @helper.addLogs('Success')
          @helper.postSuccessResult(%Q(#{caseid['id']}))
        rescue Exception => e
          @helper.addLogs('Error')
          @helper.postFailResult(e, %Q(#{caseid['id']}))
          raise e
        end
      end
    end
  end
end
