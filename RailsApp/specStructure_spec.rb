require "json"
require "selenium-webdriver"
require "rspec"
#require_relative File.expand_path('',Dir.pwd )+"/specHelper.rb"
require_relative File.expand_path('..',Dir.pwd )+"/specHelper.rb"
include RSpec::Expectations
describe "Project" do
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

  it "Example", :'tag'=> 'true' do
    begin
      #
      #Add steps for test case execution
      #

      @helper.addLogs('Success')
      @helper.postSuccessResult('caseId')

    rescue Exception => e
      @helper.addLogs('Error')
      @helper.postFailResult(e,'caseId')
      raise e
    end
  end

  def element_present?(how, what)
    @driver.find_element(how, what)
    true
  rescue Selenium::WebDriver::Error::NoSuchElementError
    false
  end

  def alert_present?()
    @driver.switch_to.alert
    true
  rescue Selenium::WebDriver::Error::NoAlertPresentError
    false
  end

  def verify(&blk)
    yield
  rescue ExpectationNotMetError => ex
    @verification_errors << ex
  end

  def close_alert_and_get_its_text(how, what)
    alert = @driver.switch_to().alert()
    alert_text = alert.text
    if (@accept_next_alert) then
      alert.accept()
    else
      alert.dismiss()
    end
    alert_text
  ensure
    @accept_next_alert = true
  end
end