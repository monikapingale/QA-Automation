require "json"
require "selenium-webdriver"
require "rspec"
require_relative File.expand_path('',Dir.pwd )+"/specHelper.rb"
include RSpec::Expectations
describe "LeadGenerete" do

  before(:all) do    
    puts "helllooooo"
    @helper = Helper.new
    #@driver = Selenium::WebDriver.for :chrome
    @driver = ARGV[0]
    @testDataJSON = @helper.getRecordJSON()
    #@base_url = "https://www.katalon.com/"
    @accept_next_alert = true
    @driver.manage.timeouts.implicit_wait = 30
    @verification_errors = []
  end

  after(:each) do
    @driver.quit
    @verification_errors.should == []
  end

  it "C:2016 To check whether generation of lead from Website.", :'2016'=> 'true' do
    begin
        @helper.addLogs('To check whether generation of lead from Website.','2016')
        @helper.addLogs('Go to Staging website and create lead')

        recordJson = 

        @driver.get "https://www-staging.wework.com/buildings/bkc--mumbai"
        @driver.find_element(:id, "tourFormContactNameField").clear
        @driver.find_element(:id, "tourFormContactNameField").send_keys @testDataJSON['CreateLeadFromWeb'][0]['Name']
        @driver.find_element(:id, "tourFormEmailField").clear
        @testDataJSON['CreateLeadFromWeb'][0]['Email'] = @testDataJSON['CreateLeadFromWeb'][0]['Name'] + SecureRandom.random_number(10000000000).to_s + "@example.com" 
        puts @testDataJSON['CreateLeadFromWeb'][0]['Email']
        @driver.find_element(:id, "tourFormEmailField").send_keys @testDataJSON['CreateLeadFromWeb'][0]['Email']
        @driver.find_element(:id, "tourFormPhoneField").clear
        @driver.find_element(:id, "tourFormPhoneField").send_keys @testDataJSON['CreateLeadFromWeb'][0]['Phone']
        @driver.find_element(:id, "tourFormStepOneSubmitButton").click
        @helper.addLogs('Success')
        
        @helper.addLogs('Login To Salesforce')
        @driver.get "https://wework--staging.cs96.my.salesforce.com/?un=kishor.shinde@wework.com.staging&pw=Anujgagare@525255"
        @helper.addLogs('Success')
        
        @driver.find_element(:id, "phSearchInput").clear
        @driver.find_element(:id, "phSearchInput").send_keys @testDataJSON['CreateLeadFromWeb'][0]['Email']
        @driver.find_element(:id, "phSearchButton").click
        @driver.find_element(:link, "john.sparrow [not provided]").click
        (@driver.find_element(:id, "lea2_ileinner").text).should == "john.sparrow [not provided]"
        @driver.find_element(:id, "lea11_ileinner").click
        (@driver.find_element(:id, "lea11_ileinner").text).should == "john.sparrow123451@example.com [Gmail]"
        @driver.find_element(:id, "RecordType_ileinner").click
        (@driver.find_element(:id, "RecordType_ileinner").text).should == "Consumer [Change]"
        @driver.find_element(:id, "lea13_ileinner").click
        (@driver.find_element(:id, "lea13_ileinner").text).should == "Open"
        (@driver.find_element(:id, "lea3_ileinner").text).should == "john.sparrow"
        (@driver.find_element(:id, "lea8_ileinner").text).should == "+91-123456789"
        (@driver.find_element(:id, "lea5_ileinner").text).should == "WeWork.com"
        (@driver.find_element(:id, "00NF0000008jx4n_ileinner").text).should == "Book A Tour Availability"
        (@driver.find_element(:id, "00N0G00000BjVWH_ileinner").text).should == "5/7/2018"
        (@driver.find_element(:id, "CF00NF000000DW8Sn_ileinner").text).should == "MUM-BKC"
        (@driver.find_element(:id, "00NF0000008jx61_ileinner").text).should == "MUM-BKC"
        (@driver.find_element(:id, "00N0G00000DKsrf_ileinner").text).should == "1"
        (@driver.find_element(:id, "lookup0050G000008KcLFlea1").text).should == "Vidu Mangrulkar"
        (@driver.find_element(:id, "lea3_ileinner").text).should == "john.sparrow"
        (@driver.find_element(:link, "Vidu Mangrulkar").text).should == "Vidu Mangrulkar"
        @driver.find_element(:xpath, "//a[@id='00Q1g000002DK90_00NF000000DSUDp_link']/span").click
        @driver.find_element(:link, "john.sparrow [not provided]-Mumbai-WeWork.com").click
        !60.times{ break if (@driver.find_element(:id, "Primary_Email__c").text == "john.sparrow123451@example.com" rescue false); sleep 1 }
        (@driver.find_element(:id, "Primary_Email__c").text).should == "john.sparrow123451@example.com"
        (@driver.find_element(:id, "Primary_Phone__c").text).should == "+91-123456789"
        (@driver.find_element(:link, "MUM-BKC").text).should == "MUM-BKC"
        @driver.find_element(:id, "NMD_Next_Contact_Date__c").click
      @helper.postSuccessResult(2016)
    rescue Exception => e
      @helper.postFailResult(e,'2016')
    end
  end

  it "test_c2146", :'2146'=> 'true' do
    @driver.get "https://www-staging.wework.com/buildings/bkc--mumbai"
    !60.times{ break if (@driver.find_element(:id, "tourFormContactNameField").displayed? rescue false); sleep 1 }
    @driver.find_element(:id, "tourFormContactNameField").clear
    @driver.find_element(:id, "tourFormContactNameField").send_keys "john.sparrow"
    @driver.find_element(:id, "tourFormEmailField").clear
    @driver.find_element(:id, "tourFormEmailField").send_keys "john.sparrow123451@example.com"
    @driver.find_element(:id, "tourFormPhoneField").clear
    @driver.find_element(:id, "tourFormPhoneField").send_keys "123456789"
    @driver.find_element(:id, "tourFormStepOneSubmitButton").click
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