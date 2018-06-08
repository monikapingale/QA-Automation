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
  def initialize(driver,helper)
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

    @wait = Selenium::WebDriver::Wait.new(:timeout => @timeSettingMap['Wait']['Environment']['Lightening']['Max'])
  end


=begin
  ************************************************************************************************************************************
        Author          :   QaAutomationTeam
        Description     :   This method authenticate user  and return @client object.
        Created Date    :   21 April 2018
        Issue No.       :
  **************************************************************************************************************************************
=end
  def loginToSalesforce()
    #puts "in AccountAssignmentFromLead:loginToSalesforce"
    @driver.get "https://test.salesforce.com/login.jsp?pw=#{@mapCredentials['Staging']['WeWork NMD User']['password']}&un=#{@mapCredentials['Staging']['WeWork NMD User']['username']}"
    #switchToClassic(@driver)
    #EnziUIUtility.wait(@driver,:id, "phHeaderLogoImage",@timeSettingMap['Wait']['Environment']['Lightening']['Max'])
    return true
      #EnziUIUtility.wait(@driver,:id, "phHeaderLogoImage",60)
  rescue Exception => e
    puts e
    return false
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
    puts "in createNewOrg"
    #@testDataJSON['CreateOpportunity']['Opportunity'][0]['Number_of_Full_Time_Employees__c']
    @wait.until {!@driver.find_element(:id,"spinner").displayed?}
    @driver.find_element(:id, "OrgButton").click
    @testDataJSON['CreateOpportunity']['Opportunity'][0]['accountName'] = @testDataJSON['CreateOpportunity']['Opportunity'][0]['accountName'] + "#{rand(99999999999999)}"
    
    @driver.find_element(:id, "Account").clear
    @driver.find_element(:id, "Account").send_keys @testDataJSON['CreateOpportunity']['Opportunity'][0]['accountName']
    @driver.find_element(:id, "Number_of_Full_Time_Employees__c").clear
    @driver.find_element(:id, "Number_of_Full_Time_Employees__c").send_keys @testDataJSON['CreateOpportunity']['Opportunity'][0]['Number_of_Full_Time_Employees__c']
    #//*[@id="lightning"]/div[3]/div/div[3]/div[1]/div/div[3]/button[1]
    @driver.find_element(:xpath, "//div[@id='lightning']/div[3]/div/div[3]/div[1]/div/div[3]/button[1]").click
    puts "Org account created with name-----> #{@testDataJSON['CreateOpportunity']['Opportunity'][0]['accountName']}"
  end

  def selectBuilding
    puts "selecting building"
    #sleep(10)
    @wait.until {!@driver.find_element(:id,"spinner").displayed?}
    #@wait.until {@driver.find_element(:id,"input-1-radio-0").displayed?}
    #//*[@id="lightning"]/div[3]/div/div[2]/div[5]/fieldset/div/div/div[1]/lightning-radio-group/fieldset/div/span[1]/label
    @driver.find_element(:xpath, "//div[@id='lightning']/div[3]/div/div[2]/div[5]/fieldset/div/div/div[1]/lightning-radio-group/fieldset/div/span[1]/label/span[2]").click
    #@helper.getElementByAttribute(@driver, :tag_name, 'label', 'for', 'input-1-radio-0').click
    #@driver.find_element(:id, "input-1-radio-0").click
    @wait.until {!@driver.find_element(:id,"spinner").displayed?}

    @driver.find_element(:id, "primaryBuilding").clear
    @driver.find_element(:id, "primaryBuilding").send_keys @testDataJSON['CreateOpportunity']['Opportunity'][0]['BuildingOrGeographyName']

    #building selected on opportunity
    building1 = @driver.find_element(:id,"primaryBuildinglist")
    @wait.until {building1.displayed?}
    @wait.until {!@driver.find_element(:id,"spinner").displayed?}
    @wait.until {!@driver.find_element(:id,"primaryBuildinglist").find_element(:id,"spinner").displayed?}
    @wait.until {building1.find_elements(:tag_name,"ul")[0].displayed?}
    ulist= building1.find_elements(:tag_name,"ul")[0]
    list=ulist.find_elements(:tag_name,"li")[1]
    @wait.until {!@driver.find_element(:id,"spinner").displayed?}
    sleep(3)
    list.click
    @wait.until {!@driver.find_element(:id,"spinner").displayed?}
    puts "building selected---->"
  rescue Exception => e
    puts e
    raise e
  end

  def selectGeography
    puts 'select geography'
    @wait.until {!@driver.find_element(:id,"spinner").displayed?}
    #//*[@id="lightning"]/div[3]/div/div[2]/div[5]/fieldset/div/div/div[1]/lightning-radio-group/fieldset/div/span[2]/label
    @driver.find_element(:xpath, "//div[@id='lightning']/div[3]/div/div[2]/div[5]/fieldset/div/div/div[1]/lightning-radio-group/fieldset/div/span[2]/label/span[2]").click

    
    #@driver.find_element(:id, "input-1-radio-1").click
    @wait.until {!@driver.find_element(:id,"spinner").displayed?}

    @driver.find_element(:id, "googleLocation").clear
    @driver.find_element(:id, "googleLocation").send_keys @testDataJSON['CreateOpportunity']['Opportunity'][0]['BuildingOrGeographyName']
    @wait.until {!@driver.find_element(:id,"spinner").displayed?}

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
    puts 'geography selected--->' 
  end


=begin
  ************************************************************************************************************************************
        Author          :   QaAutomationTeam
        Description     :   This method authenticate user  and return @client object.
        Created Date    :   21 April 2018
        Issue No.       :
  **************************************************************************************************************************************
=end
  def addProducts()
    puts 'in add products'
    @wait.until {!@driver.find_element(:id,"spinner").displayed?}
    @wait.until {@driver.find_element(:id,"Family:0").displayed?}

    #select product family 
    puts "select product family"
    @driver.find_element(:id, "Family:0").click
    Selenium::WebDriver::Support::Select.new(@driver.find_element(:id, "Family:0")).select_by(:text, @testDataJSON['CreateOpportunity']['Product'][0]['ProductFamily'])


    #@driver.find_element(:id, "Family:0").click
    #resultData=@driver.find_element(:xpath,"//*[@id='Family:0']/option[2]").click
    #puts resultData

    #@driver.find_element(:id, "Family:0").click
    #@driver.find_element(:id, "Product2Id:0").click
    #@driver.find_element(:xpath,"//*[@id='Product2Id:0']/option[2]").click
    #@driver.find_element(:id, "Product2Id:0").click

    #select product
    puts 'select product'
    @driver.find_element(:id, "Product2Id:0").click
    Selenium::WebDriver::Support::Select.new(@driver.find_element(:id, "Product2Id:0")).select_by(:text, @testDataJSON['CreateOpportunity']['Product'][0]['Product'])


    #if desk
    if @testDataJSON['CreateOpportunity']['Product'][0]['Product'] == 'Desk' then
      puts 'select product cateogory as Product is Desk'
      @driver.find_element(:id, "Product_Category__c:0").click
      Selenium::WebDriver::Support::Select.new(@driver.find_element(:id, "Product_Category__c:0")).select_by(:text, @testDataJSON['CreateOpportunity']['Product'][0]['ProductCategory'])
    end

    puts 'select quantity'
    @driver.find_element(:id, "Quantity:0").click
    @driver.find_element(:id, "Quantity:0").clear
    @driver.find_element(:id, "Quantity:0").send_keys @testDataJSON['CreateOpportunity']['Product'][0]['Quantity']


    if @testDataJSON['CreateOpportunity']['Product'][0]['BuildingOrGeography'] == 'Building' then
      puts 'set building'
      @driver.find_element(:xpath, "//div[@id='lightning']/div[3]/div[4]/div/div/div[7]/div/div[2]/div[3]/div[2]/div/div/span/label/span[2]").click
      @driver.find_element(:id, "Building__c:0").click
      @driver.find_element(:id, "Building__c:0").clear
      puts "building---> #{@testDataJSON['CreateOpportunity']['Product'][0]['BuildingOrGeographyName']}"
      @driver.find_element(:id, "Building__c:0").send_keys @testDataJSON['CreateOpportunity']['Product'][0]['BuildingOrGeographyName']
      puts @testDataJSON['CreateOpportunity']['Product'][0]['BuildingOrGeographyName']
      sleep(1)
      @wait.until {!@driver.find_element(:id,"spinner").displayed?}
      sleep(1)
      @wait.until {!@driver.find_element(:id,"spinner").displayed?}
      sleep(1)
      @wait.until {!@driver.find_element(:id,"spinner").displayed?}
      @driver.find_element(:xpath, "//div[@id='Building__c:0list']/ul/li[2]/span/div/div/mark").click

    elsif @testDataJSON['CreateOpportunity']['Product'][0]['BuildingOrGeography'] == 'Geography' then

        puts "set geography"

        @driver.find_element(:xpath, "//div[@id='lightning']/div[3]/div[4]/div[1]/div/div[7]/div/div[2]/div[3]/div[2]/div[1]/div/span[2]/label/span").click
        sleep(2)
        #//*[@id="lightning"]/div[3]/div[4]/div[1]/div/div[7]/div/div[2]/div[3]/div[2]/div[1]/div/span[2]/label
        @driver.find_element(:id, "Geography__c:0").click
        @driver.find_element(:id, "Geography__c:0").clear
        @driver.find_element(:id, "Geography__c:0").send_keys  @testDataJSON['CreateOpportunity']['Product'][0]['BuildingOrGeographyName']
        puts "search"
        #geography on manage product is selected
        puts "78787877"
        sleep(1)
        @wait.until {!@driver.find_element(:id,"spinner").displayed?}
        sleep(1)
        @wait.until {!@driver.find_element(:id,"spinner").displayed?}
        sleep(1)
        @wait.until {!@driver.find_element(:id,"spinner").displayed?}
        @driver.find_element(:xpath, "//div[@id='Geography__c:0list']/ul/li[2]/span/div/div/mark").click
        #//*[@id="Building__c:0list"]/ul/li[2]
        
        #geo = @helper.getElementByAttribute(@driver,:tag_name,'div','title',@testDataJSON['CreateOpportunity']['Product'][0]['BuildingOrGeographyName'])
        
        #puts geo[0].attribute('title')
        #puts geo[1].attribute('title')
        #geo[0].click

#puts "121215454545124"
        #sleep(10)
=begin
        #geo = @helper.getElementByAttribute(@driver,:tag_name,'div','title',@testDataJSON['CreateOpportunity']['Product'][0]['BuildingOrGeographyName'])
        #puts geo[0].attribute('title')
        #puts geo[1].attribute('title')
        #geo[0].click
        #geo[1].click
        #outerContainer = @driver.find_element(:id, "Geography__c:0list")
        puts 'outerContainer found'
        #outerContainer = @driver.find_element(:id, "Geography__c:0list")
        @wait.until {!outerContainer.find_element(:id,"spinner").displayed?}
        puts "3"
        geolist = outerContainer.find_elements(:tag_name,"ul")[0]
        puts 'geolist found'
        @wait.until {geolist.displayed?}
        @wait.until {!outerContainer.find_element(:id,"spinner").displayed?}
        geo= geolist.find_elements(:tag_name,"li")[1]
        puts 'geo found'
        @wait.until {geo.displayed?}
        puts "78"
        #geo.click
        puts "89"
=end
        @wait.until {!@driver.find_element(:id,"spinner").displayed?}
        puts "completed"
    end
        
    #select primary
    if @testDataJSON['CreateOpportunity']['Product'][0]['isPrimaryProductToSet'] == 'true' then
      @driver.find_element(:xpath, "//div[@id='lightning']/div[3]/div[4]/div[2]/div[1]/div[3]/div[2]/div[1]/div/div/span/label/span").click
    end
    #CLICK ON SAVE PRODUCT
    if @testDataJSON['CreateOpportunity']['Product'][0]['Action'] == 'Save Product' then
      puts 'click on save product'
      sleep(5)
      @wait.until {!@driver.find_element(:id,"spinner").displayed?}
      @wait.until {!@driver.find_element(:id,"spinner").displayed?}
      @wait.until {!@driver.find_element(:id,"spinner").displayed?}
      #//*[@id="lightning"]/div[3]/div[5]/button[1]
      @driver.find_element(:xpath, "//div[@id='lightning']/div[3]/div[5]/button[1]").click
    elsif @testDataJSON['CreateOpportunity']['Product'][0]['Action'] == 'Close' then
      puts 'click on close'
      @wait.until {!@driver.find_element(:id,"spinner").displayed?}
      #//*[@id="lightning"]/div[3]/div[5]/button[2]
      @driver.find_element(:xpath, "//div[@id='lightning']/div[3]/div[5]/button[2]").click
    end
    puts "sleep for 200"
    sleep(200)
  rescue Exception => e
    raise e
  end

=begin
  ************************************************************************************************************************************
        Author          :   QaAutomationTeam
        Description     :   This method authenticate user  and return @client object.
        Created Date    :   21 April 2018
        Issue No.       :
  **************************************************************************************************************************************
=end
  def createOppEnt()
    puts "in createOppEnt"
    #@driver.find_element(:name, "create_opportunity").click
    @wait.until {!@driver.find_element(:id,"spinner").displayed?}
    
    #select org
    if @testDataJSON['CreateOpportunity']['Opportunity'][0]['account'] == 'newOrg' then
      createNewOrg()
    elsif @testDataJSON['CreateOpportunity']['Opportunity'][0]['account'] == 'searchOrg' then
      puts 'search for org'
      #searh and select
      @driver.find_element(:id, "searchOrg").click
      @driver.find_element(:id, "searchOrg").clear
      @driver.find_element(:id, "searchOrg").send_keys @testDataJSON['CreateOpportunity']['Opportunity'][0]['accountName']
      @wait.until {!@driver.find_element(:id,"spinner").displayed?}
      sleep(5)
      puts 'select from list'
      #@driver.find_element(:id, "searchOrg").click
      @wait.until {!@driver.find_element(:id,"spinner").displayed?}
      @driver.find_element(:xpath, "//div[@id='searchOrglist']/ul/li[2]/span/div/div").click
    elsif @testDataJSON['CreateOpportunity']['Opportunity'][0]['account'] == 'checkOrg' then 
      #check for correct org
    end
    
    #select opp role
    puts "select opp role"
    Selenium::WebDriver::Support::Select.new(@driver.find_element(:id, "OppRole")).select_by(:text, @testDataJSON['CreateOpportunity']['Opportunity'][0]['opportunityRole'])

    #select building or geography
    if @testDataJSON['CreateOpportunity']['Opportunity'][0]['BuildingOrGeographyName'] == 'building' then
      selectBuilding()      
    elsif @testDataJSON['CreateOpportunity']['Opportunity'][0]['BuildingOrGeographyName'] == 'geography' then
      selectGeography()
    end
      

    #@driver.find_element(:id, "primaryBuilding").click
    
    #@helper.getElementByAttribute(@driver,:tag_name ,"button","title",@testDataJSON['Opportunity'][0]['building'])[0].click

    #select close date
    puts "set close date"
    @wait.until {!@driver.find_element(:id,"spinner").displayed?}
    @driver.find_element(:id, "closeDate").click
    @wait.until {!@driver.find_element(:id,"spinner").displayed?}
    puts "#{Date.today.to_s}"
    @wait.until {@driver.find_element(:id,"2018-06-21").displayed?}
    #@driver.find_element(:css, "lightning-icon.slds-icon-utility-right.slds-icon_container > lightning-primitive-icon > svg.slds-icon.slds-icon-text-default.slds-icon_xx-small > use").click
    @driver.find_element(:id, "2018-06-21").click


    #lead source
    if !@testDataJSON['CreateOpportunity']['Opportunity'][0]['LeadSource'] == '' ||  !@testDataJSON['CreateOpportunity']['Opportunity'][0]['LeadSource'] == nil then
      puts "select lead source"
      @driver.find_element(:id, "leadSource").click
      Selenium::WebDriver::Support::Select.new(@driver.find_element(:id, "leadSource")).select_by(:text, @testDataJSON['CreateOpportunity']['Opportunity'][0]['LeadSource'])
    end
    

    #lead source details
    if !@testDataJSON['CreateOpportunity']['Opportunity'][0]['lead_Source_Detail'] == '' ||  !@testDataJSON['CreateOpportunity']['Opportunity'][0]['lead_Source_Detail'] == nil then
      puts "set lead source details "
      @driver.find_element(:id, "leadSourceDetail").click
      @driver.find_element(:id, "leadSourceDetail").clear
      @driver.find_element(:id, "leadSourceDetail").send_keys @testDataJSON['CreateOpportunity']['Opportunity'][0]['lead_Source_Detail']
    end
    
    #@driver.find_element(:id, "Date.today.next_day(3)").click

    #write description
    puts "write description"
    @driver.find_element(:id, "description").clear
    @driver.find_element(:id, "description").send_keys @testDataJSON['CreateOpportunity']['Opportunity'][0]['Description']
    puts "action--->"
    #click button save - add product - close
    if @testDataJSON['CreateOpportunity']['Opportunity'][0]['Action'] == 'save&close' then
      puts 'save&close'
      @wait.until {!@driver.find_element(:id,"spinner").displayed?}

       @driver.find_element(:xpath, "//div[@id='lightning']/div[3]/div/div[2]/div[10]/div/button[1]").click
       #//*[@id="lightning"]/div[3]/div/div[2]/div[11]/div/button[1]
       #//*[@id="lightning"]/div[3]/div/div[2]/div[11]/div/button[1]
       #//*[@id="lightning"]/div[3]/div/div[2]/div[10]/div/button[1]
      #@helper.getElementByAttribute(@driver, :tag_name, 'button', 'title', 'Save & Close').click
    elsif @testDataJSON['CreateOpportunity']['Opportunity'][0]['Action'] == 'addProducts' then
      puts 'addProducts'

      #//*[@id="lightning"]/div[3]/div/div[2]/div[10]/div/button[2]
      @wait.until {!@driver.find_element(:id,"spinner").displayed?}
      #//*[@id="lightning"]/div[3]/div/div[2]/div[9]/div/button[2]
      #//*[@id="lightning"]/div[3]/div/div[2]/div[11]/div/button[2]
      @driver.find_element(:xpath, "//div[@id='lightning']/div[3]/div/div[2]/div[10]/div/button[2]").click
      #@helper.getElementByAttribute(@driver, :tag_name, 'button', 'title', 'Add Products').click
      addProducts()
    elsif @testDataJSON['CreateOpportunity']['Opportunity'][0]['Action'] == 'close' then
      puts 'close----->'
      @wait.until {!@driver.find_element(:id,"spinner").displayed?}
      #//*[@id="lightning"]/div[3]/div/div[2]/div[11]/div/button[3]
      #//*[@id="lightning"]/div[3]/div/div[2]/div[10]/div/button[3]
      @driver.find_element(:xpath, "//div[@id='lightning']/div[3]/div/div[2]/div[10]/div/button[3]").click
=begin
        lightningDiv = @driver.find_element(:id, "lightning")

        buttons = lightningDiv.find_elements(:tag_name, "button")
        puts buttons.size

        buttons.each do |button|
          puts "121"
          puts button.attribute('title')
          if button.attribute('title') == 'Close' then
            sleep(30)
            puts button.attribute('title')
            #@wait.until {button.displayed?}
            puts 'clicking on button'
            button.click
            break
          end
        end
=end   

        #button = @helper.getElementByAttribute(@driver, :tag_name, 'button', 'title', 'Close')
        #@wait.until {button.displayed?}
        #sleep(10)
        #button.click     
    end
        


    #click on add product
    

    
 end


 def  goToCreateOppPageFromJourney(email)
    puts "in goToCreateOppPageFromJourney"
    puts "search email"
    #@wait.until {!@driver.find_element(:id,"spinner").displayed?}
    @wait.until {@driver.find_element(:id,"phSearchInput").displayed?}
    @driver.find_element(:id, "phSearchInput").clear
    @driver.find_element(:id, "phSearchInput").send_keys "#{email}"
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
    EnziUIUtility.wait(@driver,:id, "Primary_Email__c",@timeSettingMap['Wait']['Environment']['Lightening']['Max'])
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
    sleep(0)
    @size = @driver.find_elements(:xpath, "//iframe[contains(@id, 'ext-comp-')]").size
    puts @size
    frameid3 = @driver.find_elements(:xpath, "//iframe[contains(@id, 'ext-comp-')]")[@size - 2].attribute('id')
    puts frameid3
    puts "switching to frame"
    @driver.switch_to.frame(frameid3)
    puts "fill the form----"
  end
end
