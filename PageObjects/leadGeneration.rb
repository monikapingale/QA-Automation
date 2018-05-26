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

class LeadGeneration
  @mapRecordType = nil
  @salesforceBulk = nil
  @testDataJSON = nil
  @timeSettingMap = nil
  @mapCredentials = nil
  @salesConsoleSetting = nil

  def initialize(driver,helper)
    puts "in Lead::initialize"
    @mapRecordType = Hash.new
    @driver = driver
    @helper = helper
    @testDataJSON = @helper.getRecordJSON()
    @timeSettingMap = @helper.instance_variable_get(:@timeSettingMap)
    @mapCredentials = @helper.instance_variable_get(:@mapCredentials)
    @salesforceBulk = @helper.instance_variable_get(:@salesforceBulk)
    @restforce = @helper.instance_variable_get(:@restForce)
    @wait = Selenium::WebDriver::Wait.new(:timeout => @timeSettingMap['Wait']['Environment']['Lightening']['Max'])
    #@objSFRest = SfRESTService.new(@mapCredentials['Staging']['WeWork System Administrator']['grant_type'],@mapCredentials['Staging']['WeWork System Administrator']['client_id'],@mapCredentials['Staging']['WeWork System Administrator']['client_secret'],@mapCredentials['Staging']['WeWork System Administrator']['username'],@mapCredentials['Staging']['WeWork System Administrator']['password'])
    #recordTypeIds = Salesforce.getRecords(@salesforceBulk,'RecordType',"Select id,Name from RecordType where SObjectType = 'Account'")
    
    recordTypeIds = @helper.getSalesforceRecordByRestforce("Select id,Name from RecordType where SObjectType = 'Account'")
    @salesConsoleSetting = @helper.instance_variable_get(:@restForce).getRecords("SELECT name,Data__c FROM Setting__c WHERE name IN ('User/Queue Journey Creation','Lead:Lead and Lead Source Details')")
    puts "sales conso;e setting--->"
    puts @salesConsoleSetting
    if !recordTypeIds.nil? && recordTypeIds[0] != nil then
      recordTypeIds.each do |typeid|
        @mapRecordType.store(typeid.fetch('Name'),typeid.fetch('Id'))
      end
    end
    puts "mapRecordType"
    puts @mapRecordType
    #createCommonTestData()
  end

  def createCommonTestData
    puts "creating common test Data"
    #create 2 acc- org and sales
    #create 1 contact related to sales
    accountJSON = @testDataJSON['Account']
    @testDataJSON['Account'][0]["RecordTypeId"] = @mapRecordType["Consumer"]
    @testDataJSON['Account'][1]["RecordTypeId"] = @mapRecordType["Consumer"]
    @testDataJSON['Account'][2]["RecordTypeId"] = @mapRecordType["Consumer"]
    puts "Account---->"
    puts @testDataJSON['Account']
    #puts @testDataJSON['Account'][1]
    #creare acc
    
    account = @helper.createSalesforceRecords('Account',@testDataJSON['Account'])
    #orgAccount = @helper.createRecord('Account',@testDataJSON['Account'][0])
    #salesAccount = @helper.createRecord('Account',@testDataJSON['Account'][1])
    puts account

    #create contact
    contactJSON = @testDataJSON['Contact']
    contactJSON[0]["AccountId"] = account[0].fetch("Id")
    contact = @helper.createRecord('Contact',@testDataJSON['Contact'][0])
    #puts contact[0].fetch('Id')

  end

  def leadCreateSfBulk()
    Salesforce.createRecords(@salesforceBulk, 'Lead', @testDataJSON["AccountAssignment"]["GenerateLeadFromWeb"][0]["BuildingName"])
  end

  def createLeadFromWeb(emailId)
      puts "Lead::createLeadFromWeb"
      @testDataJSON['CreateLeadFromWeb'][0]['Email'] = emailId
      @driver.get "https://www-staging.wework.com/buildings/#{@testDataJSON["CreateLeadFromWeb"][0]["BuildingName"]}--#{@testDataJSON["CreateLeadFromWeb"][0]["City"]}"
      sleep(10)
      EnziUIUtility.wait(@driver, :id, "tourFormContactNameField", @timeSettingMap['Wait']['Environment']['Lightening']['Min'])
      EnziUIUtility.setValue(@driver, :id, "tourFormContactNameField", "#{@testDataJSON['CreateLeadFromWeb'][0]['Name']}")

      EnziUIUtility.wait(@driver, :id, "tourFormEmailField", @timeSettingMap['Wait']['Environment']['Lightening']['Min'])
      EnziUIUtility.setValue(@driver, :id, "tourFormEmailField", "#{emailId}")

      EnziUIUtility.wait(@driver, :id, "tourFormPhoneField", @timeSettingMap['Wait']['Environment']['Lightening']['Min'])
      EnziUIUtility.setValue(@driver, :id, "tourFormPhoneField", "#{@testDataJSON['CreateLeadFromWeb'][0]['PhoneNumber']}")

      sleep(3)
      @driver.find_element(:name, "move_in_time_frame").click
      Selenium::WebDriver::Support::Select.new(@driver.find_element(:name, "move_in_time_frame")).select_by(:text, "This Month")
      sleep(2)
      @driver.find_element(:name, "desired_capacity").clear
      @driver.find_element(:name, "desired_capacity").send_keys @testDataJSON['CreateLeadFromWeb'][0]['NumberOfPeople']

      sleep(3)
      EnziUIUtility.clickElement(@driver, :id, "tourFormStepOneSubmitButton")
      puts "lead Created With email = >   #{emailId}"
      return true
    rescue Exception => e
      raise e
      return false
  end


  def createLeadFromStdSalesforce(email)
    puts @testDataJSON['Lead']
    records_to_insert = Hash.new
    records_to_insert.store('Name','Kishor_shinde')
    record = @helper.createRecords(sObject,records_to_insert)
    puts record
    return record    
  end

  def createLeadStdsalesforce
    puts "in Lead::createLeadStdsalesforce"
    EnziUIUtility.wait(@driver, :link, "Leads", @timeSettingMap['Wait']['Environment']['Lightening']['Max'])      
    @driver.find_element(:link, "Leads").click
    @driver.find_element(:name, "new").click
    #select record type
    EnziUIUtility.wait(@driver, :id, "p3", @timeSettingMap['Wait']['Environment']['Lightening']['Max'])    
    @driver.find_element(:id, "p3").click
    Selenium::WebDriver::Support::Select.new(@driver.find_element(:id, "p3")).select_by(:text, @testDataJSON['Lead'][0]['RecordType'])
    #click on continue
    @driver.find_element(:xpath, "(//input[@name='save'])[2]").click
    #selct salutation
    @driver.find_element(:id, "name_salutationlea2").click
    Selenium::WebDriver::Support::Select.new(@driver.find_element(:id, "name_salutationlea2")).select_by(:text, "Mr.")
    #enter first name
    @driver.find_element(:id, "name_firstlea2").click
    @driver.find_element(:id, "name_firstlea2").clear
    @driver.find_element(:id, "name_firstlea2").send_keys @testDataJSON['Lead'][0]['FirstName']
    #enter last name
    @driver.find_element(:id, "name_lastlea2").click
    @driver.find_element(:id, "name_lastlea2").clear
    @driver.find_element(:id, "name_lastlea2").send_keys @testDataJSON['Lead'][0]['LastName']
    #enter email
    @driver.find_element(:id, "lea11").click
    @driver.find_element(:id, "lea11").clear
    @driver.find_element(:id, "lea11").send_keys @testDataJSON['Lead'][0]['Email']
    #enter company name
    @driver.find_element(:id, "lea3").click
    @driver.find_element(:id, "lea3").clear
    @driver.find_element(:id, "lea3").send_keys @testDataJSON['Lead'][0]['Company']
    #enter Org Acc name
    @driver.find_element(:id, "CF00N0G00000DkNxF").click
    @driver.find_element(:id, "CF00N0G00000DkNxF").clear
    @driver.find_element(:id, "CF00N0G00000DkNxF").send_keys "john.snow_Org_qaauto12121212"
    #select lead Source
    @driver.find_element(:id, "lea5").click
    Selenium::WebDriver::Support::Select.new(@driver.find_element(:id, "lea5")).select_by(:text, @testDataJSON['Lead'][0]['leadSource'])
    #select lead source details
    @driver.find_element(:id, "00NF0000008jx4n").click
    @driver.find_element(:id, "00NF0000008jx4n").clear
    @driver.find_element(:id, "00NF0000008jx4n").send_keys @testDataJSON['Lead'][0]['lead_Source_Detail__c']
    #select lead status
    @driver.find_element(:id, "lea13").click
    Selenium::WebDriver::Support::Select.new(@driver.find_element(:id, "lea13")).select_by(:text, @testDataJSON['Lead'][0]['Lead Status'])
    #generate journey
    if @testDataJSON['Lead'][0]['Generate Journey'] then
      @driver.find_element(:id, "00NF000000DWYhq").click
    end

    #restart journey
    if @testDataJSON['Lead'][0]['Restart Journey'] then
      @driver.find_element(:id, "00NF000000DSawf").click
    end

    #Interested in no of desk(s)
    @driver.find_element(:id, "00N0G00000DKsrf").click
    @driver.find_element(:id, "00N0G00000DKsrf").clear
    @driver.find_element(:id, "00N0G00000DKsrf").send_keys @testDataJSON['Lead'][0]['Interested in Number of Desk(s)']

    #Selcet type
    @driver.find_element(:id, "00NF0000008jx4d").click
    Selenium::WebDriver::Support::Select.new(@driver.find_element(:id, "00NF0000008jx4d")).select_by(:text, @testDataJSON['Lead'][0]['Type'])
    #select Market
    @driver.find_element(:id, "00NF000000DWHcN").click
    Selenium::WebDriver::Support::Select.new(@driver.find_element(:id, "00NF000000DWHcN")).select_by(:text, @testDataJSON['Lead'][0]['Market'])

    #select Locale
    @driver.find_element(:id, "00NF000000DW96x").click
    Selenium::WebDriver::Support::Select.new(@driver.find_element(:id, "00NF000000DW96x")).select_by(:text, @testDataJSON['Lead'][0]['Locale'])
    
    #enter Building interested in
    @driver.find_element(:id, "CF00NF000000DW8Sn").click
    @driver.find_element(:id, "CF00NF000000DW8Sn").clear
    @driver.find_element(:id, "CF00NF000000DW8Sn").send_keys @testDataJSON['Lead'][0]['Building Interested In']

    #Select Country Code
    @driver.find_element(:id, "00NF000000DW97C").click
    Selenium::WebDriver::Support::Select.new(@driver.find_element(:id, "00NF000000DW97C")).select_by(:text, @testDataJSON['Lead'][0]['Country Code'])

    puts "select Market Interested"
    sleep(10)
    # ERROR: Caught exception [ERROR: Unsupported command [addSelection | id=00NF000000DSdDJ_unselected | label=Amsterdam]]
    @driver.find_element(:xpath, "//option[@value='0']").click
    @driver.find_element(:id, "00NF000000DSdDJ_right_arrow").click
    # ERROR: Caught exception [ERROR: Unsupported command [doubleClick | //option[@value='0'] | ]]
    # ERROR: Caught exception [ERROR: Unsupported command [addSelection | id=00NF000000DSdDJ_unselected | label=Atlanta]]
    sleep(5)
    @driver.find_element(:xpath, "//option[@value='2']").click
    @driver.find_element(:id, "00NF000000DSdDJ_right_arrow").click
    # ERROR: Caught exception [ERROR: Unsupported command [doubleClick | //option[@value='2'] | ]]

    #enter Number of Full Time Employees
    @driver.find_element(:id, "00N0G00000DKsrg").click
    @driver.find_element(:id, "00N0G00000DKsrg").clear
    @driver.find_element(:id, "00N0G00000DKsrg").send_keys @testDataJSON['Lead'][0]['Number of Full Time Employees']


    #Locations Interested
    # ERROR: Caught exception [ERROR: Unsupported command [addSelection | id=00NF0000008jx61_unselected | label=AMS-Labs]]
    @driver.find_element(:xpath, "(//option[@value='0'])[2]").click
    @driver.find_element(:id, "00NF0000008jx61_right_arrow").click
    # ERROR: Caught exception [ERROR: Unsupported command [doubleClick | xpath=(//option[@value='0'])[2] | ]]
    # ERROR: Caught exception [ERROR: Unsupported command [addSelection | id=00NF0000008jx61_unselected | label=AMS-Strawinskylaan]]
    @driver.find_element(:xpath, "(//option[@value='2'])[2]").click
    @driver.find_element(:id, "00NF0000008jx61_right_arrow").click
    # ERROR: Caught exception [ERROR: Unsupported command [doubleClick | xpath=(//option[@value='2'])[2] | ]]

    #enter reffer Name
    @driver.find_element(:id, "CF00NF000000DVv35").click
    @driver.find_element(:id, "CF00NF000000DVv35").clear
    @driver.find_element(:id, "CF00NF000000DVv35").send_keys "john snow_QaAuto_121"

    #enter reffer Email
    @driver.find_element(:id, "00N0G00000DkPYC").click
    @driver.find_element(:id, "00N0G00000DkPYC").clear
    @driver.find_element(:id, "00N0G00000DkPYC").send_keys @testDataJSON['Lead'][0]['Referrer Email']

    #enter reffer name
    @driver.find_element(:id, "00NF000000CbxMW").click
    @driver.find_element(:id, "00NF000000CbxMW").clear
    @driver.find_element(:id, "00NF000000CbxMW").send_keys @testDataJSON['Lead'][0]['Referrer Name']
    
    #lead Assignment rule---
    if @testDataJSON['Lead'][0]['Assign using active assignment rule'] then
      @driver.find_element(:id, "lea21").click
    end

    #@driver.find_element(:xpath, "(//input[@name='save'])[2]").click
    #@driver.find_element(:id, "CF00NF000000DVv35_lkid").click
    #Selenium::WebDriver::Support::Select.new(@driver.find_element(:id, "CF00NF000000DVv35_lkid")).select_by(:text, "John Snow")
    @driver.find_element(:xpath, "(//input[@name='save'])[2]").click
  end

  def update(sObject, updated_values)
    #updated_account = Hash["name" => "Test Account -- Updated", "id" => "a00A0001009zA2m"] # Nearly identical to an insert, but we need to pass the salesforce id.

    #puts updated_values
    #puts sObject
    #records_to_update.push(updated_account)
    Salesforce.updateRecord(@salesforceBulk, sObject, updated_values)
  end

  def self.getElementByAttribute(driver, elementFindBy, elementIdentity, attributeName, attributeValue)
    #puts "in accountAssignment::getElementByAttribute"
    driver.execute_script("arguments[0].scrollIntoView();", driver.find_element(elementFindBy, elementIdentity))
    #puts "in getElementByAttribute #{attributeValue}"
    elements = driver.find_elements(elementFindBy, elementIdentity)
    elements.each do |element|
      if element.attribute(attributeName) != nil then
        if element.attribute(attributeName).include? attributeValue then
          #puts "element found"
          return element
        end
      end
    end
  end

  def loginToSalesforce()
    #puts "in AccountAssignmentFromLead:loginToSalesforce"
    @driver.get "https://test.salesforce.com/login.jsp?pw=#{@mapCredentials['Staging']['WeWork System Administrator']['password']}&un=#{@mapCredentials['Staging']['WeWork System Administrator']['username']}"
    switchToClassic(@driver)
    EnziUIUtility.wait(@driver,:id, "phHeaderLogoImage",@timeSettingMap['Wait']['Environment']['Lightening']['Max'])
    return true
      #EnziUIUtility.wait(@driver,:id, "phHeaderLogoImage",60)
  rescue Exception => e
    puts e
    return nil
  end

  #Use: This function is Used to switching to classic from lightening
  def switchToClassic(driver)
    sleep(5)
    @driver = driver
    if @driver.current_url().include? "lightning" then
      #puts "String 'lightning'"
      EnziUIUtility.wait(@driver, :class, "oneUserProfileCardTrigger", @timeSettingMap['Wait']['Environment']['Lightening']['Max'])
      @driver.find_element(:class, "oneUserProfileCardTrigger").click
      EnziUIUtility.wait(@driver, :class, "profile-card-footer", @timeSettingMap['Wait']['Environment']['Lightening']['Max'])
      @driver.find_element(:link, "Switch to Salesforce Classic").click
    else
      puts "You are already on Classic..."
    end
  end

  def fetchLeadDetails(leadEmailId)
    puts "in Lead::fetchLeadDetails"
    puts leadEmailId
    #sleep(20)
    lead = nil
    index = 0
    until !lead.nil? && lead[0] != nil do
      if index == 3 then
        puts "breaking loop"
        break
      end
      puts index
      puts "get lead record after 10 sec"      
      #sleep(10)
      lead = @helper.getSalesforceRecordByRestforce("SELECT Id,RecordType.Name,Type__c,Interested_in_Number_of_Desks__c,Generate_Journey__c,Account__c,Market__c,Has_Active_Journey__c,Markets_Interested__c,Referrer__c,Referral_Company_Name__c,Referrer_Name__c,Referrer_Email__c,RecordType.Id,Company,CreatedDate,Phone,Email,Company_Size__c,Status,LeadSource,Lead_Source_Detail__c,isConverted,Name,Owner.Id,Owner.Name,Journey_Created_On__c,Locations_Interested__c,Building_Interested_Name__c,Building_Interested_In__c,Number_of_Full_Time_Employees__c FROM Lead WHERE email = '#{leadEmailId}'")
      puts "*******"
      index  = index + 1
    end
    if index != 3 then
      puts "Lead found successfully with given email"
      return lead
    else
      puts "Lead Not found with given email"
      return nil
    end    
    rescue Exception => e
      puts e
      return nil
  end


  def isGenerateJourney(userId,leadSource,leadSourceDetail=nil,isGenerateJourney=nil)
    puts "userId ---> #{userId}"
    puts "leadSource---> #{leadSource}"
    puts "leadSourceDetail--->#{leadSourceDetail}"
    puts "isGenerateJourney---> #{isGenerateJourney}"
    userHasPermission = false
    isSourceHasPermission = false
    overrideLeadSource = false
    #puts @salesConsoleSetting[0]    
    #puts @salesConsoleSetting[1]["Data__c"]
    #settings = @helper.instance_variable_get(:@restForce).getRecords("SELECT name,Data__c FROM Setting__c WHERE name IN ('User/Queue Journey Creation','Lead:Lead and Lead Source Details')")
      JSON.parse(@salesConsoleSetting[1]["Data__c"])["allowedUsers"].each do |user|
       if user["Id"].eql? userId
         userHasPermission = true
       end
      end
      @helper.addLogs("[Result ]   : User is in setting - #{userHasPermission ? "Yes" : "No"}\n")
      @helper.addLogs("[Step ]     : Checking lead source has permission for journey creation")
    #leadSource = @helper.instance_variable_get(:@restForce).getRecords("SELECT name,Data__c FROM Setting__c WHERE name = 'Lead:Lead and Lead Source Details'")
      JSON.parse(@salesConsoleSetting[0]["Data__c"])["LeadSource"].each do |source|
       if source['name'].eql? leadSource
         isSourceHasPermission = true
         overrideLeadSource = source["OverrideLeadSoruce"]
       end
      end
      isLeadSourceDetailHasPermission = false
      if !leadSourceDetail.nil? && overrideLeadSource == false then
        JSON.parse(@salesConsoleSetting[0]["Data__c"])["LeadSourceDetails"].each do |sourceDetails|
          if sourceDetails.eql? leadSourceDetail
              isLeadSourceDetailHasPermission = true
          end
        end
      end
      if overrideLeadSource == false then
        generateJourney  = userHasPermission && isSourceHasPermission && isLeadSourceDetailHasPermission 
      else
        generateJourney  = userHasPermission && isSourceHasPermission
      end

      if !isGenerateJourney.nil? then
        generateJourney = generateJourney && isGenerateJourney
      end           
            
  end

  def fetchJourneyDetails(leadEmailId)
    return checkRecordCreated("Journey__c", "SELECT id,Owner.Name,Owner.Id,CreatedDate,Name,Building_Interested_In__c,Company_Name__c,Country_Code__c,Primary_Phone__c,Primary_Email__c,Email__c,Email_Opt_Out__c,First_Name__c,Full_Time_Employees__c,Interested_in_Number_of_Desks__c,Status__c,Lead_Contact_ID__c,Lead_Source__c,Lead_Source_Detail__c,Locale__c,Locations_Interested__c,Looking_For_Number_Of_Desk__c,Market__c,Markets_Interested__c,Mobile__c,Move_In_Time_Frame__c,NMD_Next_Contact_Date__c,Number_of_Desk__c FROM Journey__c WHERE Primary_Email__c = '#{leadEmailId}' order by CreatedDate")
  end

  def fetchBuildingDetails(buildingName)
    return checkRecordCreated("Building__c", "SELECT id,Cluster_Sales_Lead_Name__c,name,Community_Lead__c,Market__c,UUID__C FROM Building__c WHERE Name = '#{buildingName}'")
  end

  def fetchAccountDetails(primaryMember)
    #,Unomy_Location_Country__c,Unomy_Location_State__c,Unomy_Location_City__c,Primary_Member__c,Interested_in_Number_of_Desks__c,BillingCountry,BillingState,BillingCity
    return checkRecordCreated("Account", "SELECT id,Allow_Merge__c,Name,Owner.Id,Owner.Name,RecordType.Name,Number_of_Full_Time_Employees__c,Interested_in_Number_of_Desks__c,Unomy_Location_Country__c,Unomy_Location_State__c,Unomy_Location_City__c,BillingCountry,BillingState,BillingCity FROM Account WHERE Primary_Member__c = '#{primaryMember}'")
  end

  def fetchContactDetails(leadEmailId)
    return checkRecordCreated("Contact", "SELECT id,Looking_For_Number_Of_Desk__c,Name,Owner.Id,Owner.Name,RecordType.Name,Number_of_Full_Time_Employees__c FROM Contact WHERE Email = '#{leadEmailId}'")
  end

  def fetchOpportunityDetails(primaryMember)
    return checkRecordCreated("Opportunity", "SELECT id,Quantity__c,name,Owner.Id,Owner.Name,Primary_Member__c,Deal_Type__c,RecordType.Name,Interested_in_Number_of_Desks__c FROM Opportunity WHERE Primary_Member__c = '#{primaryMember}'")
    
=begin
    opp = Salesforce.getRecords(@salesforceBulk, "Opportunity", "SELECT id,StageName,Quantity__c,name,Owner.Id,Owner.Name,Primary_Member__c,Deal_Type__c,RecordType.Name,Interested_in_Number_of_Desks__c FROM Opportunity WHERE Primary_Member__c = '#{primaryMember}'")
    if opp.result.records.size > 1 then
      puts "multiple records found"
      if opp.result.records[0] != nil then
        puts 'opp present'
        records = Hash.new
        i = 0
        until opp.result.records[i] == nil do
          eachRecord = Hash.new
          puts opp
          puts opp.result.records
          puts opp.result.records[i].fetch('StageName')
          records.store("#{opp.result.records[i].fetch('Id')}", opp.result.records[i])
          i = i + 1
        end
        return records
      end
    else
      return checkRecordCreated("Opportunity", "SELECT id,Quantity__c,name,Owner.Id,Owner.Name,Primary_Member__c,Deal_Type__c,RecordType.Name,Interested_in_Number_of_Desks__c FROM Opportunity WHERE Primary_Member__c = '#{primaryMember}'")
    end
=end
  end

  def fetAccOwnerQueue(portFolio, recordType)
    #puts "in AccountAssignmentFromLead:fetAccOwnerQueue"
    #puts "portFolio---> #{portFolio}"
    #puts "recordType ----> #{recordType}"
    accQueue = Salesforce.getRecords(@salesforceBulk, "Account_Queue__c", "SELECT id, Member__c FROM Account_Queue__c where Is_Member_Active__c = true and Is_Queue_Active__c = true and Portfolio__c = '#{portFolio}' and Account_Record_Type__c = '#{recordType}'", nil)
    #accQueue = checkRecordCreated("Account_Queue__c","SELECT id, Member__c FROM Account_Queue__c where Is_Member_Active__c = true and Is_Queue_Active__c = true and Portfolio__c = '#{portFolio}' and Account_Record_Type__c = '#{recordType}'")
    #puts accQueue.result.records[0] != nil
    if accQueue.result.records[0] != nil then
      puts 'accQueue present'
      members = []
      i = 0
      until accQueue.result.records[i] == nil do
        members.push(accQueue.result.records[i].fetch('Member__c'))
        i = i + 1
      end
      return members
    else
      puts 'accqueue not Present'
      queue = Salesforce.getRecords(@salesforceBulk, "Setting__c", "select Id,Name,Data__c from Setting__c where Name = 'APIUserContactInfo'", nil).result.records[0]
      return queue
    end
  end


  def fetchProductDetails(oppId)
    #puts "in fetchProductDetails"
    return checkRecordCreated("OpportunityLineItem", "SELECT Id,Quantity FROM OpportunityLineItem WHERE OpportunityId = '#{oppId}'")
  end

  def fetchRecordTypeId(sObject)
    @mapRecordType = Hash.new
    recordTypeIds = @helper.getSalesforceRecordByRestforce("Select id,Name from RecordType where SObjectType = '#{sObject}'")
    if recordTypeIds[0] != nil then
      recordTypeIds.each do |type|
        @mapRecordType.store(type['Name'], type['Id'])
      end
    end
    #puts @mapRecordType
    return @mapRecordType
  end


  def updateProductAndOpp(oppid, quantityToUpdate, accId, recordTppeToUpdate)
    #puts "in updateProductAndOpp"
    product = fetchProductDetails(oppid)
    #puts product[0].fetch('Id')
    updated_product = {Id: "#{product[0].fetch('Id')}", Quantity: "#{quantityToUpdate}"}
    #updated_product = Hash["Quantity" => "#{quantityToUpdate}", "id" => "#{product[0].fetch('Id')}"]
    #puts updated_product
    #puts @restforce.updateRecord('OpportunityLineItem', updated_product)
    #update('OpportunityLineItem', updated_product)
    mapRecordType = fetchRecordTypeId('Account')
    #puts mapRecordType['Mid Market']
    updated_Acc = {Id: accId, RecordTypeId: mapRecordType["#{recordTppeToUpdate}"]}
    #puts updated_Acc
    #updated_Acc = Hash["RecordTypeId" => mapRecordType["#{recordTppeToUpdate}"], "id" => accId]
    @restforce.updateRecord('Account', updated_Acc)
    #update('Account', updated_Acc)
    #puts "account recordTypeupdated"
    return true
  end

  def checkRecordCreated(sObject, query)
    #puts "in AccountAssignmentFromLead:checkRecordCreated"
    result = @helper.getSalesforceRecordByRestforce("#{query}")
    #Salesforce.addRecordsToDelete(sObject, result.result.records[0].fetch('Id'))
    #puts "#{sObject} created => #{result[0]}"
    return result
  rescue
    puts "No record found111111"
    return nil
  end

  def goToDetailPage(sObjectId)
    begin
      #puts "in AccountAssignmentFromLead:goToDetailPage"
      url = @driver.current_url();
      newUrl = url.split('/')
      @driver.get "#{newUrl[0]}//#{newUrl[2]}/#{sObjectId}"
      clickManageTour()
      return true
    rescue
      return false
    end

  end

  def clickManageTour()
    EnziUIUtility.wait(@driver, :name, "lightning_manage_tours", @timeSettingMap['Wait']['Environment']['Lightening']['Max'])
    @driver.find_element(:name, "lightning_manage_tours").click
    EnziUIUtility.switchToWindow(@driver, @driver.current_url())
  end

  def openManageTouFromJourney(sObjectId)

    begin
      #puts "in AccountAssignmentFromLead:openManageTouFromJourney"
      url = @driver.current_url();
      newUrl = url.split('/')
      finalURL = "#{newUrl[0]}//#{newUrl[2]}/#{sObjectId}"
      #puts finalURL
      @driver.get "#{newUrl[0]}//#{newUrl[2]}/#{sObjectId}"
      EnziUIUtility.wait(@driver, :id, "actionDropdown", @timeSettingMap['Wait']['Environment']['Lightening']['Max'])

      #sleep(2)
      @wait.until {!@driver.find_element(:id, "spinner").displayed?}

      @driver.find_element(:id, "actionDropdown").click

      EnziUIUtility.switchToWindow(@driver, @driver.current_url())

      #sleep(2)
      @wait.until {!@driver.find_element(:id, "spinner").displayed?}

      @driver.find_element(:id, "action:0").click

      sleep(20)
      return true
    rescue Exception => e
      raise e
    end
  end

  def goToDetailPageJourney(sObjectId)
    begin
      #puts "in AccountAssignmentFromLead:goToDetailPage"
      url = @driver.current_url();
      newUrl = url.split('/')
      finalURL = "#{newUrl[0]}//#{newUrl[2]}/#{sObjectId}"
      #puts finalURL
      @driver.get "#{newUrl[0]}//#{newUrl[2]}/#{sObjectId}"

      EnziUIUtility.wait(@driver, :id, "taction:0", @timeSettingMap['Wait']['Environment']['Lightening']['Max'])

      EnziUIUtility.wait(@driver, :id, "taction:0", @timeSettingMap['Wait']['Environment']['Lightening']['Max'])

      #click on Add Opportunity
      @driver.find_element(:id, "taction:0").click

      #puts "########"
      #puts @driver.current_url()
      EnziUIUtility.switchToWindow(@driver, @driver.current_url())
      #puts "$$$$$$$$"
      return true
    rescue
      return false
    end

  end

  def bookTour(count, bookTour, isCreateOpp = nil)    
        if isCreateOpp then
            @testDataJSON["AccountAssignment"]["tour"][count]['opportunity'] = @testDataJSON["AccountAssignment"]["tour"][count]['opportunity'] + SecureRandom.random_number(10000000000).to_s
        end
        @wait.until {!@driver.find_element(:id, "spinner").displayed?}

        EnziUIUtility.wait(@driver, :id, "FTE", @timeSettingMap['Wait']['Environment']['Lightening']['Max'])

        @wait.until {!@driver.find_element(:id, "spinner").displayed?}

        if !@driver.find_elements(:id, "Phone").empty? && @driver.find_element(:id, "Phone").attribute('value').eql?("") then
            #puts "*1"
            EnziUIUtility.setValue(@driver, :id, "Phone", "#{@testDataJSON["AccountAssignment"]["tour"][count]['phone']}")
        end
        if !@driver.find_elements(:id, "FTE").empty? && @driver.find_element(:id, "FTE").attribute('value').eql?("") then
            #puts "FTE"
            #puts @testDataJSON["AccountAssignment"]["tour"][count]['companySize']
            EnziUIUtility.setValue(@driver, :id, "FTE", "#{@testDataJSON["AccountAssignment"]["tour"][count]['companySize']}")
        end
        #if !@driver.find_elements(:id,"InterestedDesks").empty? && @driver.find_element(:id,"InterestedDesks").attribute('value').eql?("") then
        #puts "InterestedDesks"
        #puts @testDataJSON['AccountAssignment']['tour'][count]['numberOfDesks']
        @driver.find_element(:id, "InterestedDesks").clear
        EnziUIUtility.setValue(@driver, :id, "InterestedDesks", "#{@testDataJSON['AccountAssignment']['tour'][count]['numberOfDesks']}")
        #@driver.find_element(:id, "InterestedDesks").send_keys "25"
        #end
        if !@driver.find_elements(:id, "Opportunity").empty? && @driver.find_element(:id, "Opportunity").attribute('value').eql?("") then
            #puts "*4"
            EnziUIUtility.setValue(@driver, :id, "Opportunity", "#{@testDataJSON["AccountAssignment"]["tour"][count]['opportunity']}")
            #puts AccountAssignmentFromLead.getElementByAttribute(@driver,:tag_name,"a","title","Create New").attribute('title')

            #@wait.until {!@driver.find_element(:id ,"spinner").displayed?}

            #AccountAssignmentFromLead.getElementByAttribute(@driver,:tag_name,"a","title","Create New").click

        end

        if isCreateOpp then
            #puts "*5"
            EnziUIUtility.setValue(@driver, :id, "Opportunity", "#{@testDataJSON["AccountAssignment"]["tour"][count]['opportunity']}")
            createNewElement = AccountAssignmentFromLead.getElementByAttribute(@driver, :tag_name, "a", "title", "Create New")
            @wait.until {createNewElement.displayed?}
            @wait.until {!@driver.find_element(:id, "spinner").displayed?}
            sleep(2)
            createNewElement.click
            #puts "Clicked on Create Opp"
            #AccountAssignmentFromLead.getElementByAttribute(@driver,:tag_name,"a","title","Create New").click
            #sleep(20)
        end

        #EnziUIUtility.wait(@driver,:name ,"lightning_manage_tours",@timeSettingMap['Wait']['Environment']['Lightening']['Max'])
        #sleep(5)

        AccountAssignmentFromLead.getElementByAttribute(@driver, :tag_name, "option", "text", "No").click
        #AccountAssignmentFromLead.getElementByAttribute(@driver,:tag_name,"option","text","No").click

        AccountAssignmentFromLead.getElementByAttribute(@driver, :tag_name, "option", "text", "WeWork").click

        container = @driver.find_element(:id, "BookTours#{count}")
        #puts "1"

        AccountAssignmentFromLead.selectBuilding(container, "#{@testDataJSON["AccountAssignment"]["tour"][count]['building']}", @timeSettingMap, @driver)

        @wait.until {!@driver.find_element(:id, "spinner").displayed?}

        #AccountAssignmentFromLead.selectTourDate(container,@timeSettingMap,@driver,@selectorSettingMap)
        AccountAssignmentFromLead.getElementByAttribute(@driver, :tag_name, 'input', 'placeholder', 'Select Tour Date').click

        selectDateFromDatePicker(container, @driver)

        #puts "8"
        sleep(1)
        if @driver.find_elements(:class, "startTime").size > 0 then
            #puts "9"
            AccountAssignmentFromLead.setElementValue(container, "startTime", nil)
        else
            #puts "10"
            AccountAssignmentFromLead.setElementValue(container, "startTime2", "4:00PM")
        end

        @wait.until {!@driver.find_element(:id, "spinner").displayed?}
        if bookTour then
            #puts "11"
            #puts "book a tour"
            EnziUIUtility.selectElement(@driver, "Book Tours", "button").click
            #EnziUIUtility.switchToWindow(@driver,@driver.current_url())
            #EnziUIUtility.wait(@driver,:id,"header43",@timeSettingMap['Wait']['Environment']['Lightening']['Max'])
        end
        return true
  
  rescue Exception => e
    puts e
    raise e
  end

  def addOpportunity()
    #puts "AccountAssignmentFromLead::addOpportunity"

    EnziUIUtility.wait(@driver, :id, "lightning", @timeSettingMap['Wait']['Environment']['Lightening']['Max'])

    #EnziUIUtility.wait(@driver,:title,"Journey Name",@timeSettingMap['Wait']['Environment']['Lightening']['Max'])


    #puts "1111111111111111222222"
    #puts AccountAssignmentFromLead.getElementByAttribute(@driver,:tag_name,"h1","title","Journey Name").text
    @wait.until {AccountAssignmentFromLead.getElementByAttribute(@driver, :tag_name, "h1", "title", "Journey Name").displayed?}

    @wait.until {!@driver.find_element(:id, "spinner").displayed?}

    sleep(5)


    #element = AccountAssignmentFromLead.getElementByAttribute(@driver,:tag_name,"button","title","Add Opportunity")
    #@wait.until {element.displayed?}
    #@driver.execute_script("return arguments[0];" , element).click


    EnziUIUtility.wait(@driver, :id, "header43", @timeSettingMap['Wait']['Environment']['Lightening']['Max'])

    EnziUIUtility.wait(@driver, :id, "Number_of_Full_Time_Employees__c", @timeSettingMap['Wait']['Environment']['Lightening']['Max'])

    @driver.find_element(:id, "Number_of_Full_Time_Employees__c").clear
    EnziUIUtility.setValue(@driver, :id, "Number_of_Full_Time_Employees__c", "#{@testDataJSON["AccountAssignment"]['tour'][0]['companySize']}")

    EnziUIUtility.wait(@driver, :id, "Interested_in_Number_of_Desks__c", @timeSettingMap['Wait']['Environment']['Lightening']['Max'])
    @driver.find_element(:id, "Interested_in_Number_of_Desks__c").clear
    EnziUIUtility.setValue(@driver, :id, "Interested_in_Number_of_Desks__c", "#{@testDataJSON["AccountAssignment"]['tour'][0]['numberOfDesks']}")


    EnziUIUtility.wait(@driver, :id, "Building__c", @timeSettingMap['Wait']['Environment']['Lightening']['Max'])
    @driver.find_element(:id, "Building__c").clear
    EnziUIUtility.setValue(@driver, :id, "Building__c", "#{@testDataJSON["AccountAssignment"]['tour'][0]['building']}")


    @wait.until {!@driver.find_element(:id, "spinner").displayed?}

    @wait.until {!@driver.find_element(:id, "spinner").displayed?}

    EnziUIUtility.wait(@driver, :id, "Building__clist", @timeSettingMap['Wait']['Environment']['Lightening']['Max'])

    #puts AccountAssignmentFromLead.getElementByAttribute(@driver,:tag_name,"li","title","MUM-BKC")[2].attribute('title')
    #@wait.until {AccountAssignmentFromLead.getElementByAttribute(@driver,:tag_name,"li","title","MUM-BKC")[2].displayed?}

    sleep(2)
    AccountAssignmentFromLead.getElementByAttribute(@driver, :tag_name, "mark", "text", "#{@testDataJSON["AccountAssignment"]['tour'][0]['building']}")[0].click

    AccountAssignmentFromLead.getElementByAttribute(@driver, :tag_name, "button", "title", "Save").click

    @wait.until {!@driver.find_element(:id, "spinner").displayed?}

    return true
  rescue Exception => e
    puts e
    return false
  end

  def self.setValue(driver, findBy, elementIdentification, val)
    #puts "in enziUtility:setValue #{val}"

    element = driver.find_element(findBy, elementIdentification)
    if element.enabled? then
      element.clear()
      element.send_keys val
    else
      return "cant set value of disabled input element"
    end
  end

  def self.selectBuilding(container, value, waitTime, driver)
    wait = Selenium::WebDriver::Wait.new(:timeout => waitTime['Wait']['Environment']['Lightening']['Min'])
    if driver.find_elements(:class, "building").size > 0 then
      innerDiv = container.find_elements(:class, "building")
    else
      innerDiv = container.find_elements(:class, "building2")
    end

    innerFields = innerDiv[0].find_elements(:class, "cEnziField")
    innerFieldDivContainer = innerFields[3].find_elements(:tag_name, "div")
    inputFieldInnerDiv = innerFieldDivContainer[4].find_elements(:tag_name, "div")
    inputField = inputFieldInnerDiv[0].find_elements(:tag_name, "div")
    wait.until {inputFieldInnerDiv[9].find_elements(:tag_name, "input")}
    if value == nil then
      return inputFieldInnerDiv[9].find_elements(:tag_name, "input")[0]
    end
    inputFieldInnerDiv[9].find_elements(:tag_name, "input")[0].clear
    inputFieldInnerDiv[9].find_elements(:tag_name, "input")[0].send_keys "#{value}"
    wait.until {!driver.find_element(:id, "spinner").displayed?}
    wait.until {inputFieldInnerDiv[11].find_elements(:class, "slds-lookup__list")}

    #sleep(waitTime['Sleep']['Environment']['Lightening']['Min'])
    list = inputFieldInnerDiv[11].find_elements(:tag_name, "ul")
    value = list[0].find_elements(:tag_name, "li")
    wait.until {value[1].displayed?}

    value[1].click
  end

  def self.selectTourDate(container, waitTime, driver, selector)
    wait = Selenium::WebDriver::Wait.new(:timeout => waitTime['Wait']['Environment']['Lightening']['Min'])
    if driver.find_elements(:class, "tourDate").size > 0 then
      innerDiv = container.find_elements(:class, "tourDate")
    else
      innerDiv = container.find_elements(:class, "tourDate2")
    end
    innerFields = innerDiv[0].find_elements(:class, "cEnziField")
    innerFieldDivContainer = innerFields[3].find_elements(:tag_name, "div")
    inputFieldOuterDiv = innerFieldDivContainer[4].find_elements(:tag_name, "div")
    inputFieldInnerDiv = inputFieldOuterDiv[0].find_elements(:tag_name, "div")
    wait.until {inputFieldInnerDiv[7].displayed?}
    sleep(waitTime['Sleep']['Environment']['Lightening']['Min'])
    if inputFieldInnerDiv[7].displayed? then
      wait.until {inputFieldInnerDiv[7].displayed?}
      inputFieldInnerDiv[7].click
    end
    inputFieldInnerDiv[7].find_elements(:tag_name, "input")[0]
  end

  def self.closeErrorAndSelectNextDate(noOfDaysToAdd)
    #puts "5"
    #@driver.find_elements(:class,"slds-theme--error")[0].text.eql? "No times slots available for the selected date" then
    EnziUIUtility.wait(@driver, :class, "slds-icon slds-icon--small", @timeSettingMap['Wait']['Environment']['Lightening']['Min'])
    @driver.find_elements(:class, "slds-icon slds-icon--small")[0].click
    AccountAssignmentFromLead.selectTourDate(container, @timeSettingMap, @driver, @selectorSettingMap)
    @wait.until {!@driver.find_element(:id, "spinner").displayed?}
    begin
      @wait.until {container.find_element(:id, Date.today.next_day(noOfDaysToAdd).to_s)}
      container.find_element(:id, Date.today.next_day(noOfDaysToAdd).to_s).click
    rescue Exception => e
      puts e
      AccountAssignmentFromLead.getElementByAttribute(@driver, :tag_name, 'button', 'title', 'Next Month').click
      container.find_element(:id, Date.today.next_day(28).to_s).click
    end

  end

  def addDays(date)

    #puts 'in addDays'
    #puts date
    if date.saturday? then
      #puts "sat"
      date1 = date.next_day(7)
      return date1
    elsif date.sunday? then
      #puts "sun"
      date1 = date.next_day(8)
      return date1
    else
      #puts 'other'
      date1 = date.next_day(7)
    end
    return date1
  end

  def selectDate(driver, date, container)
    #puts 'in selectdate'
    sleep(1)
    AccountAssignmentFromLead.getElementByAttribute(@driver, :tag_name, 'input', 'placeholder', 'Select Tour Date').click

    @wait = Selenium::WebDriver::Wait.new(:timeout => @timeSettingMap['Wait']['Environment']['Lightening']['Max'])

    #puts date
    #puts Date::MONTHNAMES[date.month]
    sleep(2)
    #puts "month in calender"
    #puts driver.find_elements(:id, 'month')[0].text
    #puts driver.find_elements(:id, 'month')[0].size
    @wait.until {driver.find_element(:id, 'month')}
    if Date::MONTHNAMES[date.month] != driver.find_elements(:id, 'month')[0].text then
      #puts "month not match"
      #sleep(5)
      @driver.find_element(:css, "lightning-icon.slds-icon-utility-right.slds-icon_container > lightning-primitive-icon > svg.slds-icon.slds-icon-text-default.slds-icon_xx-small > use").click
      #AccountAssignmentFromLead.getElementByAttribute(@driver, :tag_name, 'button', 'text', 'Next Month')[1].click
    end
    @wait.until {container.find_element(:id, date.to_s)}
    container.find_element(:id, date.to_s).click
    #puts 'date selected'
    sleep(2)
    if driver.find_elements(:tag_name, "h2")[0].text.eql? "No times slots available for the selected date" then
      puts "error ------ No Time Slots------"
      #EnziUIUtility.wait(driver, :class, "slds-icon--small", @timeSettingMap['Wait']['Environment']['Lightening']['Min'])
      AccountAssignmentFromLead.getElementByAttribute(@driver, :tag_name, 'button', 'title', 'Close').click
      #driver.find_elements(:class, "slds-icon--small")[1].click
      return false
    else
      puts 'no error'
      return true
    end
  end

  def selectDateFromDatePicker(container, driver)
    #puts "In selectDateFromDatePicker"
    @wait = Selenium::WebDriver::Wait.new(:timeout => @timeSettingMap['Wait']['Environment']['Lightening']['Max'])
    @wait.until {!@driver.find_element(:id, "spinner").displayed?}
    AccountAssignmentFromLead.selectTourDate(container, @timeSettingMap, @driver, @selectorSettingMap)
    @wait.until {!@driver.find_element(:id, "spinner").displayed?}

    date = Date.today
    #puts date

    until selectDate(@driver, date, container) == true do
      date = addDays(date)
    end


=begin
      puts "today - not friday or sat"
      @wait.until {container.find_element(:id ,Date.today.next_day(1).to_s)}
      begin
        container.find_element(:id ,Date.today.next_day(28).to_s).click

      rescue Exception => e
        puts e
        #container.find_element(:id ,Date.today.next_day(28).to_s).click

        AccountAssignmentFromLead.getElementByAttribute(@driver,:tag_name,'button','title','Next Month').click
        container.find_element(:id ,Date.today.next_day(28).to_s).click

      end
=end

=begin
      sleep(5)
      if @driver.find_elements(:tag_name,"h2")[0].text.eql? "No times slots available for the selected date" then
        puts "7"
        #@driver.find_elements(:class,"slds-theme--error")[0].text.eql? "No times slots available for the selected date" then
        EnziUIUtility.wait(@driver,:class,"slds-icon--small",@timeSettingMap['Wait']['Environment']['Lightening']['Min'])
        @driver.find_elements(:class,"slds-icon--small")[1].click
        AccountAssignmentFromLead.selectTourDate(container,@timeSettingMap,@driver,@selectorSettingMap)
        @wait.until {!@driver.find_element(:id ,"spinner").displayed?}
        @wait.until {container.find_element(:id ,Date.today.next_day(7).to_s)}
        container.find_element(:id ,Date.today.next_day(7).to_s).click

      end
=end

  end

  def self.setElementValue(container, elementToset, value = nil)
    #puts elementToset
    #puts value
    #puts "12"
    dropdown = AccountAssignmentFromLead.getElement("select", elementToset, container)
    if value != nil then
      #puts "13"
      EnziUIUtility.selectElement(dropdown[0], "#{value}", "option")[0].click
    end
    if dropdown[0].find_elements(:tag_name, "option").size > 1 then
      #puts "11"
      dropdown[0].find_elements(:tag_name, "option")[1].click
    end
    #puts dropdown[0].size
    #dropdown[0]
  end

  def self.getElement(tagName, elementToset, container)
    #puts '21'
    innerDiv = container.find_elements(:class, "#{elementToset}")
    innerFields = innerDiv[0].find_elements(:class, "cEnziField")
    innerFieldDivContainer = innerFields[3].find_elements(:tag_name, "div")
    innerFieldDivContainer[4].find_elements(:tag_name, "#{tagName}")
  end

  def duplicateAccountSelector(option, account)
    @wait.until {@driver.find_element(:id, "header43").displayed?}
    if account.eql? nil then
      EnziUIUtility.wait(@driver, :id, "enzi-data-table-container", @timeSettingMap['Wait']['Environment']['Lightening']['Max'])
      optionToselect = EnziUIUtility.selectElement(@driver, "#{option}", "button")
      @wait.until {optionToselect}
      optionToselect.click
      @wait.until {!@driver.find_element(:id, "spinner").displayed?}
      EnziUIUtility.wait(@driver, :id, "enzi-data-table-container", @timeSettingMap['Wait']['Environment']['Lightening']['Min'])
      @wait.until {!@driver.find_element(:id, "spinner").displayed?}
      sleep(@timeSettingMap['Sleep']['Environment']['Lightening']['Min'])
    else
      @wait.until {@driver.find_element(:class, "slds-radio_faux").displayed?}
      if !@driver.find_elements(:class, "slds-radio_faux").empty? then
        @driver.find_elements(:class, "slds-radio_faux")[0].click
        @driver.find_elements(:class, "slds-radio_faux")[0].click
        EnziUIUtility.selectElement(@driver, "#{option}", "button").click
      end

      @wait.until {!@driver.find_element(:id, "spinner").displayed?}
    end
    return true
  rescue
    return false
  end

  def getOwnerbasedOnAddress(account)

    portfolio = nil
    #puts account
    if account.fetch('BillingCountry') != nil then
      #puts "00"
      portfolio = Salesforce.getRecords(@salesforceBulk, "Country__c", "Select Id,Name,Portfolio__c From Country__c where Name = '#{account.fetch('BillingCountry')}'", nil)
      puts portfolio.result.records
    elsif account.fetch('BillingState') != nil then
      #puts "01"
      portfolio = Salesforce.getRecords(@salesforceBulk, "State__c", "Select Id,Name,Portfolio__c From Country__c where Name = '#{account.fetch('BillingState')}'", nil)
      puts portfolio.result.records
    elsif account.fetch('BillingCity') != nil then
      #puts '02'
      portfolio = Salesforce.getRecords(@salesforceBulk, "City__c", "Select Id,Name,Portfolio__c From Country__c where Name = '#{account.fetch('BillingCity')}'", nil)
      puts portfolio.result.records
    end

    if portfolio.result.records[0] != nil && (portfolio.result.records[0].fetch('Portfolio__c') != nil || portfolio.result.records[0].fetch('Portfolio__c') != '') then
      #puts '03'
      ownerQueue = fetAccOwnerQueue("#{portfolio.result.records[0].fetch('Portfolio__c')}", "#{account.fetch('RecordType.Name')}")
      #puts ownerQueue
      return ownerQueue
    else
      #puts 'no owner queue'
      return nil

    end

  end

end

#object = AccountAssignmentFromLead.new(Selenium::WebDriver.for :chrome)
#object.loginToSalesforce
#puts object.createLead()
#puts object.fetAccOwnerQueue('a2V0G000003H8zoUAC','Enterprise Solutions')
#object.goToDetailPageJourney('a0j0x000000GhSA')
#object.addOpportunity
# 00k0x000003fBNeAAM
#

=begin
puts object.openManageTouFromJourney('a0j0x000000GhSA')
puts object.bookTour(0,true)
sleep(30)
=end


#updated_sObject = Hash["RecordTypeId" => "0120G000001USrkQAG", "id" => "0060x000004bDSq"] # Nearly identical to an insert, but we need to pass the salesforce id.

#object.fetchRecordTypeId('Opportunity')
#puts "1111111"
#puts object.update('OpportunityLineItem',updated_sObject)
#puts object.update('Opportunity',updated_sObject)
#
#
#object.goToDetailPage("0030x00000BbIvI")
#object.bookTour(0,true,true)
#
=begin
result = object.fetchAccountDetails('0030x00000BbIvI')
puts result
puts result.fetch('BillingCountry')
puts result.fetch('Id')

updated_account = Hash["name" => "Test Account -- Updated","BillingCountry" => 'India', "id" => result.fetch('Id')] # Nearly identical to an insert, but we need to pass the salesforce id.
puts updated_account
object.update('Account',updated_account)


result = object.fetchAccountDetails('0030x00000BbIvI')
puts result

puts object.getOwnerbasedOnAddress(result)
=end

=begin
result = object.fetchAccountDetails('0030x00000BbIvI')
json = object.getOwnerbasedOnAddress(result)
puts json.size
=end


#puts object.fetAccOwnerQueue('a2V0G000003H8zoUAC','Mid Market')
=begin
opportunity = object.fetchOpportunityDetails('0030x00000BshHrAAJ')
puts opportunity.keys
puts opportunity.values_at(opportunity.keys[0]).class
puts opportunity.values_at(opportunity.keys[0])[0].class

puts opportunity.values_at(opportunity.keys[0])[0].fetch('Id')

puts opportunity.values_at(opportunity.keys[0])[0]



  i = 0
  until opportunity.keys[i] == nil do

    puts i

    if opportunity.values_at(opportunity.keys[i])[0].fetch('StageName') != 'Closed Won' then
      puts "hello #{i}"
      puts opportunity.values_at(opportunity.keys[i])[0].fetch('StageName')
      puts opportunity.values_at(opportunity.keys[i])[0].fetch('Id')
      puts opportunity.values_at(opportunity.keys[i])[0].fetch('Owner.Id')
    end

    i = i + 1
  end


puts "the end...."
=end
