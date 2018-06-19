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
	it 'To check proper lead information is displayed on manage tour page.', :'91'=> 'true' do
  begin
    #
    #Add steps for test case execution
    #
    @helper.addLogs('Success')
    @helper.postSuccessResult(91)
  rescue Exception => e
    @helper.addLogs('Error')
    @helper.postFailResult(e,91)
    raise e
  end
	end
	it 'To check manage tour page is displayed.', :'149'=> 'true' do
  begin
    #
    #Add steps for test case execution
    #
    @helper.addLogs('Success')
    @helper.postSuccessResult(149)
  rescue Exception => e
    @helper.addLogs('Error')
    @helper.postFailResult(e,149)
    raise e
  end
	end
	it 'To check that user can select start time', :'81'=> 'true' do
  begin
    #
    #Add steps for test case execution
    #
    @helper.addLogs('Success')
    @helper.postSuccessResult(81)
  rescue Exception => e
    @helper.addLogs('Error')
    @helper.postFailResult(e,81)
    raise e
  end
	end
	it 'To check proper error message is displayed when user enter single character in building field.', :'92'=> 'true' do
  begin
    #
    #Add steps for test case execution
    #
    @helper.addLogs('Success')
    @helper.postSuccessResult(92)
  rescue Exception => e
    @helper.addLogs('Error')
    @helper.postFailResult(e,92)
    raise e
  end
	end
	it 'To check book tour button get enable', :'7'=> 'true' do
  begin
    #
    #Add steps for test case execution
    #
    @helper.addLogs('Success')
    @helper.postSuccessResult(7)
  rescue Exception => e
    @helper.addLogs('Error')
    @helper.postFailResult(e,7)
    raise e
  end
	end
	it 'To check user can view duplicate account selector page while booking a tour.', :'85'=> 'true' do
  begin
    #
    #Add steps for test case execution
    #
    @helper.addLogs('Success')
    @helper.postSuccessResult(85)
  rescue Exception => e
    @helper.addLogs('Error')
    @helper.postFailResult(e,85)
    raise e
  end
	end
	it 'To check account records are fetched from Account object on duplicate account selector pop-up.', :'171'=> 'true' do
  begin
    #
    #Add steps for test case execution
    #
    @helper.addLogs('Success')
    @helper.postSuccessResult(171)
  rescue Exception => e
    @helper.addLogs('Error')
    @helper.postFailResult(e,171)
    raise e
  end
	end
	it 'To check tour is booked, when user clicks on "create account and don't merge" button.', :'86'=> 'true' do
  begin
    #
    #Add steps for test case execution
    #
    @helper.addLogs('Success')
    @helper.postSuccessResult(86)
  rescue Exception => e
    @helper.addLogs('Error')
    @helper.postFailResult(e,86)
    raise e
  end
	end
	it 'To check tour is booked, when user clicks on "create account and merge" button.', :'94'=> 'true' do
  begin
    #
    #Add steps for test case execution
    #
    @helper.addLogs('Success')
    @helper.postSuccessResult(94)
  rescue Exception => e
    @helper.addLogs('Error')
    @helper.postFailResult(e,94)
    raise e
  end
	end
	it 'To check tour is booked, when user clicks on "Use Selector Account" button.', :'102'=> 'true' do
  begin
    #
    #Add steps for test case execution
    #
    @helper.addLogs('Success')
    @helper.postSuccessResult(102)
  rescue Exception => e
    @helper.addLogs('Error')
    @helper.postFailResult(e,102)
    raise e
  end
	end
	it 'To check user can view booked tours information.', :'89'=> 'true' do
  begin
    #
    #Add steps for test case execution
    #
    @helper.addLogs('Success')
    @helper.postSuccessResult(89)
  rescue Exception => e
    @helper.addLogs('Error')
    @helper.postFailResult(e,89)
    raise e
  end
	end
	it 'To check user can book multiple tour', :'96'=> 'true' do
  begin
    #
    #Add steps for test case execution
    #
    @helper.addLogs('Success')
    @helper.postSuccessResult(96)
  rescue Exception => e
    @helper.addLogs('Error')
    @helper.postFailResult(e,96)
    raise e
  end
	end
	it 'To check user can reschedule a tour', :'115'=> 'true' do
  begin
    #
    #Add steps for test case execution
    #
    @helper.addLogs('Success')
    @helper.postSuccessResult(115)
  rescue Exception => e
    @helper.addLogs('Error')
    @helper.postFailResult(e,115)
    raise e
  end
	end
	it 'To check user can cancel a tour', :'129'=> 'true' do
  begin
    #
    #Add steps for test case execution
    #
    @helper.addLogs('Success')
    @helper.postSuccessResult(129)
  rescue Exception => e
    @helper.addLogs('Error')
    @helper.postFailResult(e,129)
    raise e
  end
	end
	it 'To check book tour button is disabled', :'883'=> 'true' do
  begin
    #
    #Add steps for test case execution
    #
    @helper.addLogs('Success')
    @helper.postSuccessResult(883)
  rescue Exception => e
    @helper.addLogs('Error')
    @helper.postFailResult(e,883)
    raise e
  end
	end
	it 'To check user can select tour date without building name', :'885'=> 'true' do
  begin
    #
    #Add steps for test case execution
    #
    @helper.addLogs('Success')
    @helper.postSuccessResult(885)
  rescue Exception => e
    @helper.addLogs('Error')
    @helper.postFailResult(e,885)
    raise e
  end
	end
	it 'To check user can get end time automatically after entering start time.', :'887'=> 'true' do
  begin
    #
    #Add steps for test case execution
    #
    @helper.addLogs('Success')
    @helper.postSuccessResult(887)
  rescue Exception => e
    @helper.addLogs('Error')
    @helper.postFailResult(e,887)
    raise e
  end
	end
	it 'to check user can select previous date', :'1016'=> 'true' do
  begin
    #
    #Add steps for test case execution
    #
    @helper.addLogs('Success')
    @helper.postSuccessResult(1016)
  rescue Exception => e
    @helper.addLogs('Error')
    @helper.postFailResult(e,1016)
    raise e
  end
	end
end