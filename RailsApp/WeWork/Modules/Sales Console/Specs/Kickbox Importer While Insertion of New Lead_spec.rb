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
	it 'To Check New Journey is created While importing lead from Kickbox when the Generate Journey on UI is Unchecked and Generate Journey in CSV file is True.', :'2566'=> 'true' do
  begin
    #
    #Add steps for test case execution
    #
    @helper.addLogs('Success')
    @helper.postSuccessResult(2566)
  rescue Exception => e
    @helper.addLogs('Error')
    @helper.postFailResult(e,2566)
    raise e
  end
	end
	it 'To Check New Journey is created while importing lead from Kickbox when the Generate Journey on UI is Checked and Generate journey on CSV is Blank.', :'2568'=> 'true' do
  begin
    #
    #Add steps for test case execution
    #
    @helper.addLogs('Success')
    @helper.postSuccessResult(2568)
  rescue Exception => e
    @helper.addLogs('Error')
    @helper.postFailResult(e,2568)
    raise e
  end
	end
	it 'To Check New Journey is Created while importing lead from Kickbox when the Generate Journey on UI is Checked and Generate Journey in CSV is false.', :'2569'=> 'true' do
  begin
    #
    #Add steps for test case execution
    #
    @helper.addLogs('Success')
    @helper.postSuccessResult(2569)
  rescue Exception => e
    @helper.addLogs('Error')
    @helper.postFailResult(e,2569)
    raise e
  end
	end
	it 'To Check New Journey is Created while importing Lead from Kickbox when the Generate Journey on UI is Checked and Generate Journey in CSV is True.', :'2571'=> 'true' do
  begin
    #
    #Add steps for test case execution
    #
    @helper.addLogs('Success')
    @helper.postSuccessResult(2571)
  rescue Exception => e
    @helper.addLogs('Error')
    @helper.postFailResult(e,2571)
    raise e
  end
	end
end