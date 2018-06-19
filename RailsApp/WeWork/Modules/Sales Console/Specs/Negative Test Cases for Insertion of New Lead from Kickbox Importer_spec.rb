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
	it 'To Check Journey Not being Created While Importing lead from Kickbox when the Generate Journey on UI is Unchecked and Generate Journey in CSV is false.', :'2567'=> 'true' do
  begin
    #
    #Add steps for test case execution
    #
    @helper.addLogs('Success')
    @helper.postSuccessResult(2567)
  rescue Exception => e
    @helper.addLogs('Error')
    @helper.postFailResult(e,2567)
    raise e
  end
	end
end