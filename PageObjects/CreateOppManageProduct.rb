require 'enziUIUtility'
require 'enziSalesforce'
require 'json'
require 'yaml'
require 'selenium-webdriver'
require 'date'
#require_relative File.expand_path("",Dir.pwd)+"/sfRESTService.rb"


class CreateOppManageProduct

  def initialize(helper1,driver1)
    @driver=driver1
    @helper=helper1
  @timeSettingMap = @helper.instance_variable_get(:@timeSettingMap)
  #@verification_errors = []
  #puts @helper.instance_variable_get(:@sObjectRecords)
  @leadsTestData=@helper.instance_variable_get(:@sObjectRecords)['CreateOpportunity'][0]['lead']
  @leadsTestData[0]['email'] = "test_johnsmith#{rand(99999999999999)}@example.com"
  @leadEmailId=@leadsTestData[0]['email']
  @leadsTestData[0]['company'] = "Test_johnsmith1#{rand(99999999999999)}"
  @oppTestData=@helper.instance_variable_get(:@sObjectRecords)['CreateOpportunity'][1]['createOpp']
  @oppTestData[0]['accountName']="test_Enterprise1#{rand(99999999999999)}"
  @oppAccName=@oppTestData[0]['accountName']
    @wait = Selenium::WebDriver::Wait.new(:timeout => @timeSettingMap['Wait']['Environment']['Lightening']['Min'])
  end

  def Salesforcelogin
    @driver.get "https://wework--staging.cs96.my.salesforce.com/"
    @driver.find_element(:id, "username").clear
    @driver.find_element(:id, "username").send_keys @helper.instance_variable_get(:@mapCredentials)['Staging']['WeWork System Administrator']['username']
    @driver.find_element(:id, "password").clear
    @driver.find_element(:id, "password").send_keys @helper.instance_variable_get(:@mapCredentials)['Staging']['WeWork System Administrator']['password']
    @driver.find_element(:id, "Login").click
    puts "Login sucessfully \n"

    @wait.until{@driver.find_element(:id ,"tsidLabel").displayed? }
    portfolio= @helper.getSalesforceRecord('Building__c',"select Market__r.Name, Market__c, Id, Name, Address__c from Building__c where Name= '#{@oppTestData[0]['building']}'")
    port =  portfolio[0].fetch("Market__r.Name")
    puts port
    result1= @helper.getSalesforceRecord('Account_Queue__c',"SELECT Member__c from Account_Queue__c where Account_Record_Type__c= 'Enterprise Solutions' AND Market__c='#{port}'")
    puts result1.class
  end

  def createRecord
    puts @driver.current_url()
    puts @leadsTestData
    @result= @helper.createSalesforceRecord('Lead',@leadsTestData)
    puts @result
    url = @driver.current_url();
    newUrl = url.split('/')
    @driver.get "#{newUrl[0]}//#{newUrl[2]}/#{@result[0]['Id']}"
    puts "Lead created suceessfully\n "
  end




  def createOppEnt
    @driver.find_element(:name, "create_opportunity").click
    @wait.until {!@driver.find_element(:id,"spinner").displayed?}
    @driver.find_element(:id, "OrgButton").click
    @driver.find_element(:id, "Account").click
    @driver.find_element(:id, "Account").clear
    @driver.find_element(:id, "Account").send_keys @oppAccName
    @driver.find_element(:id, "Number_of_Full_Time_Employees__c").clear
    @driver.find_element(:id, "Number_of_Full_Time_Employees__c").send_keys "#{@oppTestData[0]['Number_of_Full_Time_Employees__c']}"
    @driver.find_element(:xpath, "//div[@id='lightning']/div[3]/div/div[3]/div/div/div[3]/button").click
  #@driver.find_element(:id, "primaryBuilding").click
    @driver.find_element(:id, "primaryBuilding").clear
    @driver.find_element(:id, "primaryBuilding").send_keys @oppTestData[0]['building']

  #building selected on opportunity
  building1 = @driver.find_element(:id,"primaryBuildinglist")
  puts building1
  @wait.until {building1.displayed?}
  @wait.until {!@driver.find_element(:id,"spinner").displayed?}
  @wait.until {!@driver.find_element(:id,"primaryBuildinglist").find_element(:id,"spinner").displayed?}
  @wait.until {building1.find_elements(:tag_name,"ul")[0].displayed?}
  ulist= building1.find_elements(:tag_name,"ul")[0]
  list=ulist.find_elements(:tag_name,"li")[1]
  @wait.until {!@driver.find_element(:id,"spinner").displayed?}
  list.click
  @wait.until {!@driver.find_element(:id,"spinner").displayed?}

  #@helper.getElementByAttribute(@driver,:tag_name ,"button","title",@oppTestData[0]['building'])[0].click

    @driver.find_element(:id, "closeDate").click
    @driver.find_element(:css, "lightning-icon.slds-icon-utility-right.slds-icon_container > lightning-primitive-icon > svg.slds-icon.slds-icon-text-default.slds-icon_xx-small > use").click
    @driver.find_element(:id, "2018-06-21").click

  #@driver.find_element(:id, "Date.today.next_day(3)").click

    @driver.find_element(:id, "description").click
    @driver.find_element(:id, "description").clear
    @driver.find_element(:id, "description").send_keys "test data"

    @driver.find_element(:xpath, "//div[@id='lightning']/div[3]/div/div[2]/div[9]/div/button[2]").click

    @driver.find_element(:id, "Family:0").click
  resultData=@driver.find_element(:xpath,"//*[@id='Family:0']/option[2]").click
  puts resultData

    @driver.find_element(:id, "Family:0").click
    @driver.find_element(:id, "Product2Id:0").click
    @driver.find_element(:xpath,"//*[@id='Product2Id:0']/option[2]").click
    @driver.find_element(:id, "Product2Id:0").click
    @driver.find_element(:id, "Quantity:0").click
    @driver.find_element(:id, "Quantity:0").clear
    @driver.find_element(:id, "Quantity:0").send_keys "150"
    @driver.find_element(:id, "Geography__c:0").click
  sleep(4)
    @driver.find_element(:id, "Geography__c:0").send_keys  @oppTestData[0]['geography']

  #geography on manage product is selected

  outerContainer = @driver.find_element(:id, "Geography__c:0list")
  outerContainer = @driver.find_element(:id, "Geography__c:0list")
  @wait.until {!outerContainer.find_element(:id,"spinner").displayed?}
  geolist=outerContainer.find_elements(:tag_name,"ul")[0]
  @wait.until {geolist.displayed?}
  @wait.until {!outerContainer.find_element(:id,"spinner").displayed?}
  geo= geolist.find_elements(:tag_name,"li")[1]
  @wait.until {geo.displayed?}
  geo.click
  @wait.until {!@driver.find_element(:id,"spinner").displayed?}
 end

end
