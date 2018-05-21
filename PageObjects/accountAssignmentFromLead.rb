require 'enziUIUtility'
require 'enziSalesforce'
require 'json'
require 'yaml'
require 'selenium-webdriver'
require 'date'
#require_relative File.expand_path("",Dir.pwd)+"/sfRESTService.rb"

class AccountAssignmentFromLead
  @mapRecordType = nil
  @salesforceBulk = nil
  @sObjectRecords = nil
  @timeSettingMap = nil
  @mapCredentials = nil

  def initialize(driver,helper)
    puts "in AccountAssignment:initialize"
    @driver = driver
    @helper = helper
    @sObjectRecords = @helper.getRecordJSON()
    @timeSettingMap = @helper.instance_variable_get(:@timeSettingMap)
    @mapCredentials = @helper.instance_variable_get(:@mapCredentials)
    @salesforceBulk = @helper.instance_variable_get(:@salesforceBulk)
    @restforce = @helper.instance_variable_get(:@restForce)
    #puts @mapCredentials['Staging']['WeWork System Administrator']['username']
    #puts @mapCredentials['Staging']['WeWork System Administrator']['password']
    #@selectorSettingMap = YAML.load_file(File.expand_path('..', Dir.pwd) + '/TestData/selectorSetting.yaml')
    #@selectorSettingMap['screenSize']['actual'] = @driver.manage.window.size.width
    @wait = Selenium::WebDriver::Wait.new(:timeout => @timeSettingMap['Wait']['Environment']['Lightening']['Max'])
    
    #@objSFRest = SfRESTService.new(@mapCredentials['Staging']['WeWork System Administrator']['grant_type'],@mapCredentials['Staging']['WeWork System Administrator']['client_id'],@mapCredentials['Staging']['WeWork System Administrator']['client_secret'],@mapCredentials['Staging']['WeWork System Administrator']['username'],@mapCredentials['Staging']['WeWork System Administrator']['password'])
  end

  def leadCreate()
    Salesforce.createRecords(@salesforceBulk, 'Lead', @sObjectRecords["AccountAssignment"]["GenerateLeadFromWeb"][0]["BuildingName"])
  end

  def createLead()
    puts "in create Lead"
      emailId = @sObjectRecords["AccountAssignment"]["GenerateLeadFromWeb"][0]["Name"] + SecureRandom.random_number(10000000000).to_s + "@example.com"
      @sObjectRecords['AccountAssignment']['tour'][0]['email'] = emailId
      puts "Create lead from website"
      @driver.get "https://www-staging.wework.com/buildings/#{@sObjectRecords["AccountAssignment"]["GenerateLeadFromWeb"][0]["BuildingName"]}--#{@sObjectRecords["AccountAssignment"]["GenerateLeadFromWeb"][0]["City"]}"

      EnziUIUtility.wait(@driver, :id, "tourFormContactNameField", @timeSettingMap['Wait']['Environment']['Lightening']['Min'])
      EnziUIUtility.setValue(@driver, :id, "tourFormContactNameField", "#{@sObjectRecords['AccountAssignment']['GenerateLeadFromWeb'][0]['Name']}")

      EnziUIUtility.wait(@driver, :id, "tourFormEmailField", @timeSettingMap['Wait']['Environment']['Lightening']['Min'])
      EnziUIUtility.setValue(@driver, :id, "tourFormEmailField", "#{emailId}")

      EnziUIUtility.wait(@driver, :id, "tourFormPhoneField", @timeSettingMap['Wait']['Environment']['Lightening']['Min'])
      EnziUIUtility.setValue(@driver, :id, "tourFormPhoneField", "#{@sObjectRecords['AccountAssignment']['GenerateLeadFromWeb'][0]['PhoneNumber']}")

      AccountAssignmentFromLead.getElementByAttribute(@driver, :tag_name, "option", "text", "#{@sObjectRecords['AccountAssignment']['GenerateLeadFromWeb'][0]['MoveInDate']}")[0].click

      AccountAssignmentFromLead.getElementByAttribute(@driver, :tag_name, "option", "text", "#{@sObjectRecords['AccountAssignment']['GenerateLeadFromWeb'][0]['NumberOfPeople']}")[0].click
      sleep(3)
      EnziUIUtility.clickElement(@driver, :id, "tourFormStepOneSubmitButton")
      puts "lead Created With email = >   #{emailId}"
      return emailId    
    rescue Exception => e
      raise e
      #return nil
  end

  def update(sObject, updated_values)
    #updated_account = Hash["name" => "Test Account -- Updated", "id" => "a00A0001009zA2m"] # Nearly identical to an insert, but we need to pass the salesforce id.

    puts updated_values
    puts sObject
    #records_to_update.push(updated_account)
    Salesforce.updateRecord(@salesforceBulk, sObject, updated_values)
  end

  def self.getElementByAttribute(driver, elementFindBy, elementIdentity, attributeName, attributeValue)
    puts "in accountAssignment::getElementByAttribute"
    driver.execute_script("arguments[0].scrollIntoView();", driver.find_element(elementFindBy, elementIdentity))
    puts "in getElementByAttribute #{attributeValue}"
    elements = driver.find_elements(elementFindBy, elementIdentity)
    elements.each do |element|
      if element.attribute(attributeName) != nil then
        if element.attribute(attributeName).include? attributeValue then
          puts "element found"
          return element
        end
      end
    end
  end

  def loginToSalesforce()
    puts "in AccountAssignmentFromLead:loginToSalesforce"
    @driver.get "https://test.salesforce.com/login.jsp?pw=#{@mapCredentials['Staging']['WeWork System Administrator']['password']}&un=#{@mapCredentials['Staging']['WeWork System Administrator']['username']}"
    switchToClassic(@driver)
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
      #puts "You are already on Classic..."
    end
  end

  def fetchLeadDetails(leadEmailId)
    puts "in AccountAssignmentFromLead::fetchLeadDetails"
    sleep(10)
    lead = @helper.getSalesforceRecordByRestforce("SELECT Id,Email,LeadSource,Lead_Source_Detail__c,isConverted,Name,Owner.Id FROM Lead WHERE email = '#{leadEmailId}'")
    if lead[0] != nil then
      puts "get lead record"
      return lead
    else
      sleep(10)
      lead = @helper.getSalesforceRecordByRestforce("SELECT Id,Email,LeadSource,Lead_Source_Detail__c,isConverted,Name,Owner.Id FROM Lead WHERE email = '#{leadEmailId}'")
      if lead[0] != nil then
        puts "get lead record"
        return lead
      else
        sleep(10)
        lead = @helper.getSalesforceRecordByRestforce("SELECT Id,Email,LeadSource,Lead_Source_Detail__c,isConverted,Name,Owner.Id FROM Lead WHERE email = '#{leadEmailId}'")
        if lead[0] != nil then
          puts "get lead record"
          return lead
        else
          return nil
        end
      end
    end

  end

  def fetchJourneyDetails(leadEmailId)
    sleep(30)
    return checkRecordCreated("Journey__c", "SELECT id FROM Journey__c WHERE Primary_Email__c = '#{leadEmailId}'")

=begin
    puts "in AccountAssignmentFromLead::fetchJourneyDetails"
    journey = Salesforce.getRecords(@salesforceBulk,"Journey__c","SELECT id FROM Journey__c WHERE Primary_Email__c = '#{leadEmailId}'")
    if journey.result.records[0] != nil then
      puts "get journey record"
      return journey.result.records[0]
    else
      return nil
    end
=end

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
    puts "in AccountAssignmentFromLead:fetAccOwnerQueue"
    puts "portFolio---> #{portFolio}"
    puts "recordType ----> #{recordType}"
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
    puts "in fetchProductDetails"
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
    puts "in updateProductAndOpp"
    product = fetchProductDetails(oppid)
    puts product[0].fetch('Id')
    updated_product = {Id: "#{product[0].fetch('Id')}", Quantity: "#{quantityToUpdate}"}
    #updated_product = Hash["Quantity" => "#{quantityToUpdate}", "id" => "#{product[0].fetch('Id')}"]
    puts updated_product
    puts @restforce.updateRecord('OpportunityLineItem', updated_product)
    #update('OpportunityLineItem', updated_product)
    mapRecordType = fetchRecordTypeId('Account')
    puts mapRecordType['Mid Market']
    updated_Acc = {Id: accId, RecordTypeId: mapRecordType["#{recordTppeToUpdate}"]}
    puts updated_Acc
    #updated_Acc = Hash["RecordTypeId" => mapRecordType["#{recordTppeToUpdate}"], "id" => accId]
    @restforce.updateRecord('Account', updated_Acc)
    #update('Account', updated_Acc)
    puts "account recordTypeupdated"
    return true
  end

  def checkRecordCreated(sObject, query)
    puts "in AccountAssignmentFromLead:checkRecordCreated"
    result = @helper.getSalesforceRecordByRestforce("#{query}")
    #Salesforce.addRecordsToDelete(sObject, result.result.records[0].fetch('Id'))
    puts "#{sObject} created => #{result[0]}"
    return result
  rescue
    puts "No record found111111"
    return nil
  end

  def goToDetailPage(sObjectId)
    begin
      puts "in AccountAssignmentFromLead:goToDetailPage"
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
      puts "in AccountAssignmentFromLead:openManageTouFromJourney"
      url = @driver.current_url();
      newUrl = url.split('/')
      finalURL = "#{newUrl[0]}//#{newUrl[2]}/#{sObjectId}"
      puts finalURL
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
      puts "in AccountAssignmentFromLead:goToDetailPage"
      url = @driver.current_url();
      newUrl = url.split('/')
      finalURL = "#{newUrl[0]}//#{newUrl[2]}/#{sObjectId}"
      puts finalURL
      @driver.get "#{newUrl[0]}//#{newUrl[2]}/#{sObjectId}"

      EnziUIUtility.wait(@driver, :id, "taction:0", @timeSettingMap['Wait']['Environment']['Lightening']['Max'])

      EnziUIUtility.wait(@driver, :id, "taction:0", @timeSettingMap['Wait']['Environment']['Lightening']['Max'])

      #click on Add Opportunity
      @driver.find_element(:id, "taction:0").click

      puts "########"
      puts @driver.current_url()
      EnziUIUtility.switchToWindow(@driver, @driver.current_url())
      puts "$$$$$$$$"
      return true
    rescue
      return false
    end

  end

  def bookTour(count, bookTour, isCreateOpp = nil)    
        if isCreateOpp then
            @sObjectRecords["AccountAssignment"]["tour"][count]['opportunity'] = @sObjectRecords["AccountAssignment"]["tour"][count]['opportunity'] + SecureRandom.random_number(10000000000).to_s
        end
        @wait.until {!@driver.find_element(:id, "spinner").displayed?}

        EnziUIUtility.wait(@driver, :id, "FTE", @timeSettingMap['Wait']['Environment']['Lightening']['Max'])

        @wait.until {!@driver.find_element(:id, "spinner").displayed?}

        if !@driver.find_elements(:id, "Phone").empty? && @driver.find_element(:id, "Phone").attribute('value').eql?("") then
            puts "*1"
            EnziUIUtility.setValue(@driver, :id, "Phone", "#{@sObjectRecords["AccountAssignment"]["tour"][count]['phone']}")
        end
        if !@driver.find_elements(:id, "FTE").empty? && @driver.find_element(:id, "FTE").attribute('value').eql?("") then
            puts "FTE"
            puts @sObjectRecords["AccountAssignment"]["tour"][count]['companySize']
            EnziUIUtility.setValue(@driver, :id, "FTE", "#{@sObjectRecords["AccountAssignment"]["tour"][count]['companySize']}")
        end
        #if !@driver.find_elements(:id,"InterestedDesks").empty? && @driver.find_element(:id,"InterestedDesks").attribute('value').eql?("") then
        puts "InterestedDesks"
        puts @sObjectRecords['AccountAssignment']['tour'][count]['numberOfDesks']
        @driver.find_element(:id, "InterestedDesks").clear
        EnziUIUtility.setValue(@driver, :id, "InterestedDesks", "#{@sObjectRecords['AccountAssignment']['tour'][count]['numberOfDesks']}")
        #@driver.find_element(:id, "InterestedDesks").send_keys "25"
        #end
        if !@driver.find_elements(:id, "Opportunity").empty? && @driver.find_element(:id, "Opportunity").attribute('value').eql?("") then
            puts "*4"
            EnziUIUtility.setValue(@driver, :id, "Opportunity", "#{@sObjectRecords["AccountAssignment"]["tour"][count]['opportunity']}")
            #puts AccountAssignmentFromLead.getElementByAttribute(@driver,:tag_name,"a","title","Create New").attribute('title')

            #@wait.until {!@driver.find_element(:id ,"spinner").displayed?}

            #AccountAssignmentFromLead.getElementByAttribute(@driver,:tag_name,"a","title","Create New").click

        end

        if isCreateOpp then
            puts "*5"
            EnziUIUtility.setValue(@driver, :id, "Opportunity", "#{@sObjectRecords["AccountAssignment"]["tour"][count]['opportunity']}")
            createNewElement = AccountAssignmentFromLead.getElementByAttribute(@driver, :tag_name, "a", "title", "Create New")
            @wait.until {createNewElement.displayed?}
            @wait.until {!@driver.find_element(:id, "spinner").displayed?}
            sleep(2)
            createNewElement.click
            puts "Clicked on Create Opp"
            #AccountAssignmentFromLead.getElementByAttribute(@driver,:tag_name,"a","title","Create New").click
            #sleep(20)
        end

        #EnziUIUtility.wait(@driver,:name ,"lightning_manage_tours",@timeSettingMap['Wait']['Environment']['Lightening']['Max'])
        #sleep(5)

        AccountAssignmentFromLead.getElementByAttribute(@driver, :tag_name, "option", "text", "No").click
        #AccountAssignmentFromLead.getElementByAttribute(@driver,:tag_name,"option","text","No").click

        AccountAssignmentFromLead.getElementByAttribute(@driver, :tag_name, "option", "text", "WeWork").click

        container = @driver.find_element(:id, "BookTours#{count}")
        puts "1"

        AccountAssignmentFromLead.selectBuilding(container, "#{@sObjectRecords["AccountAssignment"]["tour"][count]['building']}", @timeSettingMap, @driver)

        @wait.until {!@driver.find_element(:id, "spinner").displayed?}

        #AccountAssignmentFromLead.selectTourDate(container,@timeSettingMap,@driver,@selectorSettingMap)
        AccountAssignmentFromLead.getElementByAttribute(@driver, :tag_name, 'input', 'placeholder', 'Select Tour Date').click

        selectDateFromDatePicker(container, @driver)

        puts "8"
        if @driver.find_elements(:class, "startTime").size > 0 then
            puts "9"
            AccountAssignmentFromLead.setElementValue(container, "startTime", nil)
        else
            puts "10"
            AccountAssignmentFromLead.setElementValue(container, "startTime2", "4:00PM")
        end

        @wait.until {!@driver.find_element(:id, "spinner").displayed?}
        if bookTour then
            puts "11"
            puts "book a tour"
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
    puts "AccountAssignmentFromLead::addOpportunity"

    EnziUIUtility.wait(@driver, :id, "lightning", @timeSettingMap['Wait']['Environment']['Lightening']['Max'])

    #EnziUIUtility.wait(@driver,:title,"Journey Name",@timeSettingMap['Wait']['Environment']['Lightening']['Max'])


    puts "1111111111111111222222"
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
    EnziUIUtility.setValue(@driver, :id, "Number_of_Full_Time_Employees__c", "#{@sObjectRecords["AccountAssignment"]['tour'][0]['companySize']}")

    EnziUIUtility.wait(@driver, :id, "Interested_in_Number_of_Desks__c", @timeSettingMap['Wait']['Environment']['Lightening']['Max'])
    @driver.find_element(:id, "Interested_in_Number_of_Desks__c").clear
    EnziUIUtility.setValue(@driver, :id, "Interested_in_Number_of_Desks__c", "#{@sObjectRecords["AccountAssignment"]['tour'][0]['numberOfDesks']}")


    EnziUIUtility.wait(@driver, :id, "Building__c", @timeSettingMap['Wait']['Environment']['Lightening']['Max'])
    @driver.find_element(:id, "Building__c").clear
    EnziUIUtility.setValue(@driver, :id, "Building__c", "#{@sObjectRecords["AccountAssignment"]['tour'][0]['building']}")


    @wait.until {!@driver.find_element(:id, "spinner").displayed?}

    @wait.until {!@driver.find_element(:id, "spinner").displayed?}

    EnziUIUtility.wait(@driver, :id, "Building__clist", @timeSettingMap['Wait']['Environment']['Lightening']['Max'])

    #puts AccountAssignmentFromLead.getElementByAttribute(@driver,:tag_name,"li","title","MUM-BKC")[2].attribute('title')
    #@wait.until {AccountAssignmentFromLead.getElementByAttribute(@driver,:tag_name,"li","title","MUM-BKC")[2].displayed?}

    sleep(2)
    AccountAssignmentFromLead.getElementByAttribute(@driver, :tag_name, "mark", "text", "#{@sObjectRecords["AccountAssignment"]['tour'][0]['building']}")[0].click

    AccountAssignmentFromLead.getElementByAttribute(@driver, :tag_name, "button", "title", "Save").click

    @wait.until {!@driver.find_element(:id, "spinner").displayed?}

    return true
  rescue Exception => e
    puts e
    return false
  end

  def self.setValue(driver, findBy, elementIdentification, val)
    puts "in enziUtility:setValue #{val}"

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
    puts "5"
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

    puts 'in addDays'
    puts date
    if date.saturday? then
      puts "sat"
      date1 = date.next_day(7)
      return date1
    elsif date.sunday? then
      puts "sun"
      date1 = date.next_day(8)
      return date1
    else
      puts 'other'
      date1 = date.next_day(7)
    end
    return date1
  end

  def selectDate(driver, date, container)
    puts 'in selectdate'
    AccountAssignmentFromLead.getElementByAttribute(@driver, :tag_name, 'input', 'placeholder', 'Select Tour Date').click

    @wait = Selenium::WebDriver::Wait.new(:timeout => @timeSettingMap['Wait']['Environment']['Lightening']['Max'])

    puts date
    puts Date::MONTHNAMES[date.month]
    #sleep(2)
    puts "month in calender"
    puts driver.find_elements(:id, 'month')[0].text
    puts driver.find_elements(:id, 'month')[0].size
    @wait.until {driver.find_element(:id, 'month')}
    if Date::MONTHNAMES[date.month] != driver.find_elements(:id, 'month')[0].text then
      puts "month not match"
      #sleep(5)
      @driver.find_element(:css, "lightning-icon.slds-icon-utility-right.slds-icon_container > lightning-primitive-icon > svg.slds-icon.slds-icon-text-default.slds-icon_xx-small > use").click
      #AccountAssignmentFromLead.getElementByAttribute(@driver, :tag_name, 'button', 'text', 'Next Month')[1].click
    end
    @wait.until {container.find_element(:id, date.to_s)}
    container.find_element(:id, date.to_s).click
    puts 'date selected'
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
    puts "In selectDateFromDatePicker"
    @wait = Selenium::WebDriver::Wait.new(:timeout => @timeSettingMap['Wait']['Environment']['Lightening']['Max'])
    @wait.until {!@driver.find_element(:id, "spinner").displayed?}
    AccountAssignmentFromLead.selectTourDate(container, @timeSettingMap, @driver, @selectorSettingMap)
    @wait.until {!@driver.find_element(:id, "spinner").displayed?}

    date = Date.today
    puts date

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
    puts elementToset
    puts value
    puts "12"
    dropdown = AccountAssignmentFromLead.getElement("select", elementToset, container)
    if value != nil then
      puts "13"
      EnziUIUtility.selectElement(dropdown[0], "#{value}", "option")[0].click
    end
    if dropdown[0].find_elements(:tag_name, "option").size > 1 then
      puts "11"
      dropdown[0].find_elements(:tag_name, "option")[1].click
    end
    puts dropdown[0].size
    #dropdown[0]
  end

  def self.getElement(tagName, elementToset, container)
    puts '21'
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
    puts account
    if account.fetch('BillingCountry') != nil then
      puts "00"
      portfolio = Salesforce.getRecords(@salesforceBulk, "Country__c", "Select Id,Name,Portfolio__c From Country__c where Name = '#{account.fetch('BillingCountry')}'", nil)
      puts portfolio.result.records
    elsif account.fetch('BillingState') != nil then
      puts "01"
      portfolio = Salesforce.getRecords(@salesforceBulk, "State__c", "Select Id,Name,Portfolio__c From Country__c where Name = '#{account.fetch('BillingState')}'", nil)
      puts portfolio.result.records
    elsif account.fetch('BillingCity') != nil then
      puts '02'
      portfolio = Salesforce.getRecords(@salesforceBulk, "City__c", "Select Id,Name,Portfolio__c From Country__c where Name = '#{account.fetch('BillingCity')}'", nil)
      puts portfolio.result.records
    end

    if portfolio.result.records[0] != nil && (portfolio.result.records[0].fetch('Portfolio__c') != nil || portfolio.result.records[0].fetch('Portfolio__c') != '') then
      puts '03'
      ownerQueue = fetAccOwnerQueue("#{portfolio.result.records[0].fetch('Portfolio__c')}", "#{account.fetch('RecordType.Name')}")
      puts ownerQueue
      return ownerQueue
    else
      puts 'no owner queue'
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
