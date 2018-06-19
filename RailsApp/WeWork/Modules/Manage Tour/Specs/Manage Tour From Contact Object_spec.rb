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
	it 'To check proper contact information is displayed on manage tour page.', :'345'=> 'true' do
  begin
    #
    #Add steps for test case execution
    #
    @helper.addLogs('Success')
    @helper.postSuccessResult(345)
  rescue Exception => e
    @helper.addLogs('Error')
    @helper.postFailResult(e,345)
    raise e
  end
	end
	it 'To check manage tour page is displayed.', :'346'=> 'true' do
  begin
    #
    #Add steps for test case execution
    #
    @helper.addLogs('Success')
    @helper.postSuccessResult(346)
  rescue Exception => e
    @helper.addLogs('Error')
    @helper.postFailResult(e,346)
    raise e
  end
	end
	it 'To check user can select start time', :'347'=> 'true' do
  begin
    #
    #Add steps for test case execution
    #
    @helper.addLogs('Success')
    @helper.postSuccessResult(347)
  rescue Exception => e
    @helper.addLogs('Error')
    @helper.postFailResult(e,347)
    raise e
  end
	end
	it 'To check user can get end time automatically after entering start time.', :'348'=> 'true' do
  begin
    #
    #Add steps for test case execution
    #
    @helper.addLogs('Success')
    @helper.postSuccessResult(348)
  rescue Exception => e
    @helper.addLogs('Error')
    @helper.postFailResult(e,348)
    raise e
  end
	end
	it 'To check proper error message is displayed when user enter single character in building field.', :'349'=> 'true' do
  begin
    #
    #Add steps for test case execution
    #
    @helper.addLogs('Success')
    @helper.postSuccessResult(349)
  rescue Exception => e
    @helper.addLogs('Error')
    @helper.postFailResult(e,349)
    raise e
  end
	end
	it 'To check book tour button get enable', :'350'=> 'true' do
  begin
    #
    #Add steps for test case execution
    #
    @helper.addLogs('Success')
    @helper.postSuccessResult(350)
  rescue Exception => e
    @helper.addLogs('Error')
    @helper.postFailResult(e,350)
    raise e
  end
	end
	it 'To check user can view booked tours information.', :'356'=> 'true' do
  begin
    #
    #Add steps for test case execution
    #
    @helper.addLogs('Success')
    @helper.postSuccessResult(356)
  rescue Exception => e
    @helper.addLogs('Error')
    @helper.postFailResult(e,356)
    raise e
  end
	end
	it 'To check user can book multiple tour', :'357'=> 'true' do
  begin
    #
    #Add steps for test case execution
    #
    @helper.addLogs('Success')
    @helper.postSuccessResult(357)
  rescue Exception => e
    @helper.addLogs('Error')
    @helper.postFailResult(e,357)
    raise e
  end
	end
	it 'To check user can reschedule a tour', :'358'=> 'true' do
  begin
    #
    #Add steps for test case execution
    #
    @helper.addLogs('Success')
    @helper.postSuccessResult(358)
  rescue Exception => e
    @helper.addLogs('Error')
    @helper.postFailResult(e,358)
    raise e
  end
	end
	it 'To check user can cancel a tour', :'359'=> 'true' do
  begin
    #
    #Add steps for test case execution
    #
    @helper.addLogs('Success')
    @helper.postSuccessResult(359)
  rescue Exception => e
    @helper.addLogs('Error')
    @helper.postFailResult(e,359)
    raise e
  end
	end
	it 'To check booked tour location is added into location interested field of existing opportunity', :'360'=> 'true' do
  begin
    #
    #Add steps for test case execution
    #
    @helper.addLogs('Success')
    @helper.postSuccessResult(360)
  rescue Exception => e
    @helper.addLogs('Error')
    @helper.postFailResult(e,360)
    raise e
  end
	end
	it 'To check new opportunity is added through manage tour', :'361'=> 'true' do
  begin
    #
    #Add steps for test case execution
    #
    @helper.addLogs('Success')
    @helper.postSuccessResult(361)
  rescue Exception => e
    @helper.addLogs('Error')
    @helper.postFailResult(e,361)
    raise e
  end
	end
end