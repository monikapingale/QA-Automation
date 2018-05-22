require 'enziUIUtility'
require 'enziSalesforce'
require 'json'
require 'yaml'
require 'selenium-webdriver'
require 'date'

class LeadGeneration
  @mapRecordType = nil
  @salesforceBulk = nil
  @sObjectRecords = nil
  @timeSettingMap = nil
  @mapCredentials = nil

  def initialize(driver,helper)
    @driver = driver
    @helper = helper
    @sObjectRecords = @helper.getRecordJSON()
    @timeSettingMap = @helper.instance_variable_get(:@timeSettingMap)
    @mapCredentials = @helper.instance_variable_get(:@mapCredentials)
    @salesforceBulk = @helper.instance_variable_get(:@salesforceBulk)
    @restforce = @helper.instance_variable_get(:@restForce)
    puts @mapCredentials['Staging']['WeWork System Administrator']['username']
    puts @mapCredentials['Staging']['WeWork System Administrator']['password']
    @wait = Selenium::WebDriver::Wait.new(:timeout => @timeSettingMap['Wait']['Environment']['Lightening']['Max'])    
  end


  def createLead(emailId)
      @sObjectRecords['CreateLeadFromWeb'][0]['Email'] = emailId
      @driver.get "https://www-staging.wework.com/buildings/#{@sObjectRecords["CreateLeadFromWeb"][0]["BuildingName"]}--#{@sObjectRecords["CreateLeadFromWeb"][0]["City"]}"
      sleep(3)
      EnziUIUtility.wait(@driver, :id, "tourFormContactNameField", @timeSettingMap['Wait']['Environment']['Lightening']['Min'])
      EnziUIUtility.setValue(@driver, :id, "tourFormContactNameField", "#{@sObjectRecords['CreateLeadFromWeb'][0]['Name']}")

      EnziUIUtility.wait(@driver, :id, "tourFormEmailField", @timeSettingMap['Wait']['Environment']['Lightening']['Min'])
      EnziUIUtility.setValue(@driver, :id, "tourFormEmailField", "#{emailId}")

      EnziUIUtility.wait(@driver, :id, "tourFormPhoneField", @timeSettingMap['Wait']['Environment']['Lightening']['Min'])
      EnziUIUtility.setValue(@driver, :id, "tourFormPhoneField", "#{@sObjectRecords['CreateLeadFromWeb'][0]['PhoneNumber']}")


    @driver.find_element(:name, "move_in_time_frame").click
    Selenium::WebDriver::Support::Select.new(@driver.find_element(:name, "move_in_time_frame")).select_by(:text, "This Month")
    @driver.find_element(:name, "desired_capacity").clear
    @driver.find_element(:name, "desired_capacity").send_keys @sObjectRecords['CreateLeadFromWeb'][0]['NumberOfPeople']

     sleep(3)
      EnziUIUtility.clickElement(@driver, :id, "tourFormStepOneSubmitButton")
      puts "lead Created With email = >   #{emailId}"
      return true
    rescue Exception => e
      raise e
      return false
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

  def fetchLeadDetails(emailLead)
    #puts "in AccountAssignmentFromLead::fetchLeadDetails"
    sleep(20)
    lead = @helper.getSalesforceRecordByRestforce("SELECT Id,Name,Email,Owner.Name,CreatedDate,Company,Phone,LeadSource,Company_Size__c,Lead_Source_Detail__c,Status,Building_Interested_In__c,Building_Interested_Name__c,Locations_Interested__c,Journey_Created_On__c FROM Lead WHERE Email='#{emailLead}'")
    if lead[0] != nil then
      #puts "get lead record"
      return lead
    else
      sleep(10)
      lead = @helper.getSalesforceRecordByRestforce("SELECT Id,Name,Email,Owner.Name,CreatedDate,Company,Phone,LeadSource,Company_Size__c,Lead_Source_Detail__c,Status,Building_Interested_In__c,Building_Interested_Name__c,Locations_Interested__c,Journey_Created_On__c FROM Lead WHERE Email='#{emailLead}'")
      if lead[0] != nil then
        #puts "get lead record"
        return lead
      else
        sleep(10)
        lead = @helper.getSalesforceRecordByRestforce("SELECT Id,Name,Email,Owner.Name,CreatedDate,Company,Phone,LeadSource,Company_Size__c,Lead_Source_Detail__c,Status,Building_Interested_In__c,Building_Interested_Name__c,Locations_Interested__c,Journey_Created_On__c FROM Lead WHERE Email='#{emailLead}'")
        if lead[0] != nil then
          #puts "get lead record"
          return lead
        else
          return nil
        end
      end
    end
  rescue Exception => e
    puts e
    return nil
  end

  def fetchJourneyDetails(emailLead)
    sleep(30)
    return @helper.getSalesforceRecordByRestforce("SELECT Id,Status__c,NMD_Next_Contact_Date__c,Name,CreatedDate FROM Journey__c WHERE Primary_Email__c = '#{emailLead}' order by CreatedDate")

  end

  def fetchBuildingDetails(buildingName)
    return @helper.getSalesforceRecordByRestforce("SELECT id,Cluster_Sales_Lead_Name__c,name,Community_Lead__c,Market__c,UUID__C FROM Building__c WHERE Name = '#{buildingName}'")
  end

  def fetchAccountDetails(primaryMember)
    return @helper.getSalesforceRecordByRestforce("SELECT id,Allow_Merge__c,Name,Owner.Id,Owner.Name,RecordType.Name,Number_of_Full_Time_Employees__c,Interested_in_Number_of_Desks__c,Unomy_Location_Country__c,Unomy_Location_State__c,Unomy_Location_City__c,BillingCountry,BillingState,BillingCity FROM Account WHERE Primary_Member__c = '#{primaryMember}'")
  end

  def fetchContactDetails(emailLead)
    return @helper.getSalesforceRecordByRestforce("select id,Name,createdDate,Account.Id,Looking_For_Number_Of_Desk__c,Owner.Id,Owner.Name,RecordType.Name,Number_of_Full_Time_Employees__c,Email,Interested_in_Number_of_Desks__c from Contact where Email = '#{emailLead}'")
  end

  def fetchOpportunityDetails(primaryMember)
    return @helper.getSalesforceRecordByRestforce("SELECT id,Quantity__c,name,Owner.Id,Owner.Name,Primary_Member__c,Deal_Type__c,RecordType.Name,Interested_in_Number_of_Desks__c FROM Opportunity WHERE Primary_Member__c = '#{primaryMember}'")
  end

  def fetchActivityDetails(leadId)
    return @helper.getSalesforceRecordByRestforce("Select Id,Status,Owner.Name,Owner.Id, Subject, WhoId, Lead_Source__c, Lead_Source_Detail__c, Locations_Interested__c,Type FROM Task WHERE WhatId = '#{leadId}'")
  end

  def fetAccOwnerQueue(portFolio, recordType)

    accQueue = Salesforce.getRecords(@salesforceBulk, "Account_Queue__c", "SELECT id, Member__c FROM Account_Queue__c where Is_Member_Active__c = true and Is_Queue_Active__c = true and Portfolio__c = '#{portFolio}' and Account_Record_Type__c = '#{recordType}'", nil)
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
    return @helper.getSalesforceRecordByRestforce("SELECT Id,Quantity FROM OpportunityLineItem WHERE OpportunityId = '#{oppId}'")
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

end
