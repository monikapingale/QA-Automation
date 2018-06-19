require 'json'
require 'selenium-webdriver'
require 'rspec'
require_relative File.expand_path('..',Dir.pwd )+'/specHelper.rb'
include RSpec::Expectations
describe 'Project' do
  before(:all) do
    @helper = Helper.new
    @driver = ARGV[0]
    @testDataJSON = @helper.getRecordJSON()
    @accept_next_alert = true
    @wait = @helper.instance_variable_get(:@wait)
    @verification_errors = []
  end
  after(:each) do
    @verification_errors.should == []
  end
	it '(VIEW LATER)To check lead and journey assignment for duplicate lead submission for two different campaign', :'2582'=> 'true' do
  begin
    #
    #Add steps for test case execution
    #
    @helper.addLogs('Success')
    @helper.postSuccessResult(2582)
  rescue Exception => e
    @helper.addLogs('Error')
    @helper.postFailResult(e,2582)
    raise e
  end
	end
	it 'To check campaign assignment for existing lead and journey where existing journey is not associated with any campaign and then same lead with email address come for campaign then campaign assignment should be as per 'Lead owner' field of campaign', :'2596'=> 'true' do
  begin
    #
    #Add steps for test case execution
    #
    @helper.addLogs('Success')
    @helper.postSuccessResult(2596)
  rescue Exception => e
    @helper.addLogs('Error')
    @helper.postFailResult(e,2596)
    raise e
  end
	end
end