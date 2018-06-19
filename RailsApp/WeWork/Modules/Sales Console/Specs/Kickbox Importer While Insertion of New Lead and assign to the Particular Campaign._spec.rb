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
	it 'To Check Journey is created While Importing lead from Kickbox When the Generate Journey on UI is Checked and Generate journey in CSV is Blank and assign to the particular Campaign.', :'2575'=> 'true' do
  begin
    #
    #Add steps for test case execution
    #
    @helper.addLogs('Success')
    @helper.postSuccessResult(2575)
  rescue Exception => e
    @helper.addLogs('Error')
    @helper.postFailResult(e,2575)
    raise e
  end
	end
	it 'To Check Journey is Created While Importing Lead from Kickbox When the Generate Journey on UI is Unchecked and Generate Journey in CSV is True and assign to the particular Campaign.', :'2578'=> 'true' do
  begin
    #
    #Add steps for test case execution
    #
    @helper.addLogs('Success')
    @helper.postSuccessResult(2578)
  rescue Exception => e
    @helper.addLogs('Error')
    @helper.postFailResult(e,2578)
    raise e
  end
	end
end