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
	it 'To check lead and journey assignment for new lead owned by non 'Susie Romero' when lead is coming from standard salesforce page and lead is not existing in salesforce, where campaign assignment should be as per 'Lead Owner'', :'2591'=> 'true' do
  begin
    #
    #Add steps for test case execution
    #
    @helper.addLogs('Success')
    @helper.postSuccessResult(2591)
  rescue Exception => e
    @helper.addLogs('Error')
    @helper.postFailResult(e,2591)
    raise e
  end
	end
	it 'To check lead and journey assignment for new lead owned by non 'Susie Romero' when lead is coming from standard salesforce page and lead is not existing in salesforce, where campaign assignment should be as per 'Email Address'', :'2592'=> 'true' do
  begin
    #
    #Add steps for test case execution
    #
    @helper.addLogs('Success')
    @helper.postSuccessResult(2592)
  rescue Exception => e
    @helper.addLogs('Error')
    @helper.postFailResult(e,2592)
    raise e
  end
	end
	it 'To check lead and journey assignment for new lead owned by non 'Susie Romero' when lead is coming from standard salesforce page and lead is not existing in salesforce, where campaign assignment should be as per 'City'', :'2593'=> 'true' do
  begin
    #
    #Add steps for test case execution
    #
    @helper.addLogs('Success')
    @helper.postSuccessResult(2593)
  rescue Exception => e
    @helper.addLogs('Error')
    @helper.postFailResult(e,2593)
    raise e
  end
	end
	it 'To check lead and journey assignment for new lead owned by non 'Susie Romero' when lead is coming from standard salesforce page and lead is not existing in salesforce, where campaign assignment should be 'Unassigned NMD US Queue'', :'2594'=> 'true' do
  begin
    #
    #Add steps for test case execution
    #
    @helper.addLogs('Success')
    @helper.postSuccessResult(2594)
  rescue Exception => e
    @helper.addLogs('Error')
    @helper.postFailResult(e,2594)
    raise e
  end
	end
end