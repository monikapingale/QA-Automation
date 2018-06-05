=begin
************************************************************************************************************************************
    Author      :   QaAutomationTeam
    Description :   This class provides methods for Business logic related to lead.

    History     :
  ----------------------------------------------------------------------------------------------------------------------------------
  VERSION            DATE             AUTHOR                  DETAIL
  1                 24 May 2018     QaAutomationTeam        sprint-1.0
**************************************************************************************************************************************
=end

require 'enziUIUtility'
require 'enziSalesforce'
require 'json'
require 'yaml'
require 'selenium-webdriver'
require 'date'
#require_relative File.expand_path("",Dir.pwd)+"/sfRESTService.rb"


class CreateOppManageProduct
  @mapRecordType = nil
  @salesforceBulk = nil
  @testDataJSON = nil
  @timeSettingMap = nil
  @mapCredentials = nil
  @salesConsoleSetting = nil

=begin
  ************************************************************************************************************************************
        Author          :   QaAutomationTeam
        Description     :   This method authenticate user  and return @client object.
        Created Date    :   21 April 2018
        Issue No.       :
  **************************************************************************************************************************************
=end
  def initialize(helper,driver)
    puts "in CreateOppManageProduct::initialize"
    @driver=driver
    @helper=helper
    @testDataJSON = @helper.getRecordJSON()
    @timeSettingMap = @helper.instance_variable_get(:@timeSettingMap)
    @mapCredentials = @helper.instance_variable_get(:@mapCredentials)
    @verification_errors = []

    #puts @helper.instance_variable_get(:@testDataJSON)

    #@leadsTestData=@helper.instance_variable_get(:@testDataJSON)['CreateOpportunity'][0]['lead']
    #@leadsTestData[0]['email'] = "test_johnsmith#{rand(99999999999999)}@example.com"
    #@leadEmailId=@leadsTestData[0]['email']
    #@leadsTestData[0]['company'] = "Test_johnsmith1#{rand(99999999999999)}"
    #@testDataJSON['Opportunity']=@helper.instance_variable_get(:@testDataJSON)['CreateOpportunity'][1]['createOpp']
    #@testDataJSON['Opportunity'][0]['accountName']="test_Enterprise1#{rand(99999999999999)}"
    #@oppAccName=@testDataJSON['Opportunity'][0]['accountName']

    @wait = Selenium::WebDriver::Wait.new(:timeout => @timeSettingMap['Wait']['Environment']['Lightening']['Min'])
  end

=begin
  ************************************************************************************************************************************
        Author          :   QaAutomationTeam
        Description     :   This method authenticate user  and return @client object.
        Created Date    :   21 April 2018
        Issue No.       :
  **************************************************************************************************************************************
=end
  def salesforcelogin
    @driver.get "https://wework--staging.cs96.my.salesforce.com/"
    @driver.find_element(:id, "username").clear
    @driver.find_element(:id, "username").send_keys @mapCredentials['Staging']['WeWork System Administrator']['username']
    @driver.find_element(:id, "password").clear
    @driver.find_element(:id, "password").send_keys @mapCredentials['Staging']['WeWork System Administrator']['password']
    @driver.find_element(:id, "Login").click
    puts "Login sucessfully \n"

    @wait.until{@driver.find_element(:id ,"tsidLabel").displayed? }
    portfolio= @helper.getSalesforceRecord('Building__c',"select Market__r.Name, Market__c, Id, Name, Address__c from Building__c where Name= '#{@testDataJSON['Opportunity'][0]['building']}'")
    port =  portfolio[0].fetch("Market__r.Name")
    puts port
    result1= @helper.getSalesforceRecord('Account_Queue__c',"SELECT Member__c from Account_Queue__c where Account_Record_Type__c= 'Enterprise Solutions' AND Market__c='#{port}'")
    puts result1.class
  end

=begin
  ************************************************************************************************************************************
        Author          :   QaAutomationTeam
        Description     :   This method authenticate user  and return @client object.
        Created Date    :   21 April 2018
        Issue No.       :
  **************************************************************************************************************************************
=end
  def createLead
    #@testDataJSON['CreateOpportunity'][0]['lead'][0]['email'] = "test_johnsmith#{rand(99999999999999)}@example.com"

    #puts @driver.current_url()
    #puts @leadsTestData
    #@result= @helper.createSalesforceRecord('Lead',@leadsTestData)
    #puts @result
    #url = @driver.current_url();
    #newUrl = url.split('/')
    #@driver.get "#{newUrl[0]}//#{newUrl[2]}/#{@result[0]['Id']}"
    #puts "Lead created suceessfully\n "
  end

  def createNewOrg()
    #@testDataJSON['CreateOpportunity']['Opportunity'][0]['Number_of_Full_Time_Employees__c']
    @wait.until {!@driver.find_element(:id,"spinner").displayed?}
    @driver.find_element(:id, "OrgButton").click
    @testDataJSON['CreateOpportunity']['Opportunity'][0]['accountName'] = @testDataJSON['CreateOpportunity']['Opportunity'][0]['accountName'] + "#{rand(99999999999999)}"
    puts @testDataJSON['CreateOpportunity']['Opportunity'][0]['accountName']
    @driver.find_element(:id, "Account").clear
    @driver.find_element(:id, "Account").send_keys @testDataJSON['CreateOpportunity']['Opportunity'][0]['accountName']
    @driver.find_element(:id, "Number_of_Full_Time_Employees__c").clear
    @driver.find_element(:id, "Number_of_Full_Time_Employees__c").send_keys @testDataJSON['CreateOpportunity']['Opportunity'][0]['Number_of_Full_Time_Employees__c']
    @driver.find_element(:xpath, "//div[@id='lightning']/div[3]/div/div[3]/div/div/div[3]/button").click
  end

  def selectBuilding
    @driver.find_element(:id, "input-1-radio-0").click

    @driver.find_element(:id, "primaryBuilding").clear
    @driver.find_element(:id, "primaryBuilding").send_keys @testDataJSON['CreateOpportunity']['Opportunity'][0]['building']

    #building selected on opportunity
    building1 = @driver.find_element(:id,"primaryBuildinglist")
    @wait.until {building1.displayed?}
    @wait.until {!@driver.find_element(:id,"spinner").displayed?}
    @wait.until {!@driver.find_element(:id,"primaryBuildinglist").find_element(:id,"spinner").displayed?}
    @wait.until {building1.find_elements(:tag_name,"ul")[0].displayed?}
    ulist= building1.find_elements(:tag_name,"ul")[0]
    list=ulist.find_elements(:tag_name,"li")[1]
    @wait.until {!@driver.find_element(:id,"spinner").displayed?}
    list.click
    @wait.until {!@driver.find_element(:id,"spinner").displayed?}
  end

  def selectGeography
    @driver.find_element(:id, "input-1-radio-1").click

    @driver.find_element(:id, "googleLocation").clear
    @driver.find_element(:id, "googleLocation").send_keys @testDataJSON['CreateOpportunity']['Opportunity'][0]['building']

    #building selected on opportunity
    geography = @driver.find_element(:id,"googleLocationlist")
    @wait.until {geography.displayed?}
    @wait.until {!@driver.find_element(:id,"spinner").displayed?}
    @wait.until {!@driver.find_element(:id,"primaryBuildinglist").find_element(:id,"spinner").displayed?}
    @wait.until {geography.find_elements(:tag_name,"ul")[0].displayed?}
    ulist= geography.find_elements(:tag_name,"ul")[0]
    list=ulist.find_elements(:tag_name,"li")[2]
    @wait.until {!@driver.find_element(:id,"spinner").displayed?}
    list.click
    @wait.until {!@driver.find_element(:id,"spinner").displayed?}

   # //*[@id="googleLocationlist"]/ul/li[2]/span/div/div
    

  end

=begin
  ************************************************************************************************************************************
        Author          :   QaAutomationTeam
        Description     :   This method authenticate user  and return @client object.
        Created Date    :   21 April 2018
        Issue No.       :
  **************************************************************************************************************************************
=end
  def createOppEnt(org,buildingOrGeography,action)
    puts "in createOppEnt"
    #@driver.find_element(:name, "create_opportunity").click
    @wait.until {!@driver.find_element(:id,"spinner").displayed?}
    
    #select org
    if org == 'newOrg' then
      createNewOrg()
    elsif org == 'searchOrg' then
      #searh and select
    elsif org == 'checkOrg' then 
      #check for correct org
    end
    
    #select opp role
    Selenium::WebDriver::Support::Select.new(@driver.find_element(:id, "OppRole")).select_by(:text, @testDataJSON['CreateOpportunity']['Opportunity'][0]['opportunityRole'])

    #select building or geography
    if buildingOrGeography == 'building' then
      selectBuilding()      
    elsif buildingOrGeography == 'geography' then
      selectGeography()
    end
      

    #@driver.find_element(:id, "primaryBuilding").click
    
    #@helper.getElementByAttribute(@driver,:tag_name ,"button","title",@testDataJSON['Opportunity'][0]['building'])[0].click

    #select close date
    @driver.find_element(:id, "closeDate").click
    #@driver.find_element(:css, "lightning-icon.slds-icon-utility-right.slds-icon_container > lightning-primitive-icon > svg.slds-icon.slds-icon-text-default.slds-icon_xx-small > use").click
    @driver.find_element(:id, "2018-06-21").click

    #@driver.find_element(:id, "Date.today.next_day(3)").click

    #write description
    @driver.find_element(:id, "description").clear
    @driver.find_element(:id, "description").send_keys "test data"

    #click button save - add product - close
    if action == 'save&close' then
      @helper.getElementByAttribute(@driver, :tag_name, 'button', 'title', 'Save & Close').click
    elsif action == 'addProducts' then

      @helper.getElementByAttribute(@driver, :tag_name, 'button', 'title', 'Add Products').click

    elsif action == 'close' then
        @helper.getElementByAttribute(@driver, :tag_name, 'button', 'title', 'Close').click
      
    end
        


    #click on add product
    

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
    @driver.find_element(:id, "Geography__c:0").send_keys  @testDataJSON['Opportunity'][0]['geography']

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


 def  goToCreateOppPageFromJourney(email)
  puts "in goToCreateOppPageFromJourney"
  puts "search email"
    #@wait.until {!@driver.find_element(:id,"spinner").displayed?}
    @wait.until {@driver.find_element(:id,"phSearchInput").displayed?}
    @driver.find_element(:id, "phSearchInput").clear
    @driver.find_element(:id, "phSearchInput").send_keys @testDataJSON['CreateLeadFromWeb'][0]['Email']
    sleep(2)
    puts "select search output"
    #sleep(5)
    #@wait.until {!@driver.find_element(:id,"spinner").displayed?}
    @wait.until {@driver.find_element(:id,"phSearchInput_autoCompleteRowId_0").displayed?}
    @driver.find_element(:xpath, "//div[@id='phSearchInput_autoCompleteRowId_0']/span/span").click
    #@wait.until {!@driver.find_element(:id,"spinner").displayed?}
    #sw to frame
    #sleep(10)
    puts "sw to frame"
    EnziUIUtility.switchToWindow(@driver, @driver.current_url())
    #puts @driver.find_elements(:xpath, "//iframe[contains(@id, 'ext-comp-')]").size

    #puts @driver.find_elements(:xpath, "//iframe[contains(@id, 'ext-comp-')]")[0].attribute('id')
    @size  = @driver.find_elements(:xpath, "//iframe[contains(@id, 'ext-comp-')]").size

    frameid = @driver.find_elements(:xpath, "//iframe[contains(@id, 'ext-comp-')]")[@size - 2].attribute('id')
    puts frameid
    
    @driver.switch_to.frame(frameid)
    puts "click on journey link"
    @wait.until {@driver.find_element(:id,"Journey__c_body").displayed?}
    #@wait.until {!@driver.find_element(:id,"spinner").displayed?}
    @driver.find_element(:xpath, " //*[@id='Journey__c_body']/table/tbody/tr[2]/th/a").click
    #sleep(30)

    puts 'sw to frame'
    EnziUIUtility.switchToWindow(@driver, @driver.current_url())
    #sleep(5)
    #puts @driver.find_elements(:xpath, "//iframe[contains(@id, 'ext-comp-')]").size
    #puts "121211212"
    @size = @driver.find_elements(:xpath, "//iframe[contains(@id, 'ext-comp-')]").size
    #puts @driver.find_elements(:xpath, "//iframe[contains(@id, 'ext-comp-')]")[@size - 1].attribute('id')
    #puts @driver.find_elements(:xpath, "//iframe[contains(@id, 'ext-comp-')]")[@size - 1 - 1].attribute('id')
    
    frameid2 = @driver.find_elements(:xpath, "//iframe[contains(@id, 'ext-comp-')]")[@size - 1 - 1].attribute('id')
    puts frameid2
    puts "switching to frame"
    sleep(0)
    @driver.switch_to.frame(frameid2)
    puts "click on actionDropdown"
    #sleep(10)
    #@wait.until {!@driver.find_element(:id,"spinner").displayed?}    
    @wait.until {@driver.find_element(:id,"Primary_Email__c").displayed?}
    @wait.until {@driver.find_element(:id,"actionDropdown").displayed?}
    @driver.find_element(:id,'actionDropdown').click
    #@wait.until {!@driver.find_element(:id,"spinner").displayed?}
    #sleep(5)
    puts 'click on send to Enterprise'
    @wait.until {@driver.find_element(:id,"action:7").displayed?}
    @driver.find_element(:xpath, "//li[@id='action:7']/a/span").click
    #@wait.until {!@driver.find_element(:id,"spinner").displayed?}

    puts "sw to frame1111"
    EnziUIUtility.switchToWindow(@driver, @driver.current_url())
    sleep(10)
    @size = @driver.find_elements(:xpath, "//iframe[contains(@id, 'ext-comp-')]").size
    puts @size
    frameid3 = @driver.find_elements(:xpath, "//iframe[contains(@id, 'ext-comp-')]")[@size - 2].attribute('id')
    puts frameid3
    puts "switching to frame"
    sleep(0)
    @driver.switch_to.frame(frameid3)
    puts "fill the form----"
  end
end
