require "json"
require "selenium-webdriver"
require "rspec"
include RSpec::Expectations

describe "LeadInbound" do

  before(:each) do
    @driver = Selenium::WebDriver.for :chrome
    @base_url = "https://www.katalon.com/"
    @accept_next_alert = true
  end
  
  after(:each) do
    @driver.quit
    @verification_errors.should == []
  end
  
  it "test_lead_inbound" do
    @driver.get "https://wework--staging.cs96.my.salesforce.com/home/home.jsp"
    puts @testDataJSON
    @driver.find_element(:link, "Leads").click
    @driver.find_element(:link, "test, testkickbox28devA").click
    @driver.find_element(:id, "tsidLabel").click
    @driver.find_element(:link, "Sales Console").click
    @driver.find_element(:id, "ext-gen106").click
    # ERROR: Caught exception [ERROR: Unsupported command [selectFrame | index=3 | ]]
    @driver.find_element(:xpath, "//input[@type='text']").click
    @driver.find_element(:xpath, "//input[@type='text']").click
    @driver.find_element(:xpath, "//input[@type='text']").clear
    @driver.find_element(:xpath, "//input[@type='text']").send_keys "test"
    @driver.find_element(:id, "btnSearch").click
    @driver.find_element(:xpath, "//div[@id='page-content-wrapper']/div/div[2]/div/div/button").click
    @driver.find_element(:id, "inputFirstName").click
    @driver.find_element(:id, "inputFirstName").clear
    @driver.find_element(:id, "inputFirstName").send_keys "monika"
    @driver.find_element(:id, "inputLastName").click
    @driver.find_element(:id, "inputLastName").clear
    @driver.find_element(:id, "inputLastName").send_keys "Pingale"
    @driver.find_element(:id, "inputEmail").click
    @driver.find_element(:id, "inputEmail").clear
    @driver.find_element(:id, "inputEmail").send_keys "lead_demo@example.com"
    @driver.find_element(:name, "myForm").click
    @driver.find_element(:id, "inputPhone").click
    @driver.find_element(:id, "inputPhone").clear
    @driver.find_element(:id, "inputPhone").send_keys "1234567890"
    @driver.find_element(:id, "inputCompany").click
    @driver.find_element(:id, "inputCompany").clear
    @driver.find_element(:id, "inputCompany").send_keys "EnziAuto"
    @driver.find_element(:id, "sel1").click
    Selenium::WebDriver::Support::Select.new(@driver.find_element(:id, "sel1")).select_by(:text, "Inbound Call")
    @driver.find_element(:id, "sel1").click
    @driver.find_element(:name, "autocomplete").click
    @driver.find_element(:name, "autocomplete").clear
    @driver.find_element(:name, "autocomplete").send_keys "la-"
    @driver.find_element(:link, "LA-One Culver").click
    @driver.find_element(:xpath, "(//button[@type='button'])[3]").click
  end
end
