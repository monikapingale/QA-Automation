class Kickbox_Importer
  def initialize(driver,helper)
    puts "Initializing page object"
    @mapRecordType = Hash.new
    @driver = driver
    @helper = helper
    @testDataJSON = @helper.getRecordJSON()
    @timeSettingMap = @helper.instance_variable_get(:@timeSettingMap)
    @mapCredentials = @helper.instance_variable_get(:@mapCredentials)
    @salesforceBulk = @helper.instance_variable_get(:@salesforceBulk)
    @restforce = @helper.instance_variable_get(:@restForce)
    @wait = Selenium::WebDriver::Wait.new(:timeout => @timeSettingMap['Wait']['Environment']['Lightening']['Max'])
    @userInfo = @restforce.getUserInfo
    @settings = @restforce.getRecords("SELECT name,Data__c FROM Setting__c WHERE name IN ('User/Queue Journey Creation','Lead:Lead and Lead Source Details')")
    @testDataJSON['Lead'][0]['Email'] = "john.snow_qaauto-#{rand(99999999)}@example.com"
    @testDataJSON['Lead'][0]['Number_of_Full_Time_Employees__c'] = 10
    @testDataJSON['Lead'][0]['Interested_in_Number_of_Desks__c'] = 5
    @testDataJSON['Lead'][0]['Lead_Source_Detail__c'] = "Inbound Call Page"
    @testDataJSON['Lead'][0]['LeadSource'] = "Inbound Call"
  end
  def createLead(isOverrideLeadSourceDetail)

    @wait.until {@driver.find_element(:id, "page-content-wrapper")}
    @driver.find_element(:id, "page-content-wrapper").find_elements(:tag_name, "input")[0].clear
    @driver.find_element(:id, "page-content-wrapper").find_elements(:tag_name, "input")[0].send_keys("#{@testDataJSON['Lead'][0]['Email']}")
    @wait.until {!@driver.find_element(:id, "spinnerContainer").displayed?}
    @driver.find_element(:id, "btnSearch").click
    @wait.until {@driver.find_element(:class, "create-new-contact")}
    @wait.until {@driver.find_element(:class, "create-new-contact").displayed?}
    @wait.until {!@driver.find_element(:id, "spinnerContainer").displayed?}
    @driver.find_element(:class, "create-new-contact").click
    @wait.until {@driver.find_element(:id, "inputFirstName").displayed?}
    @driver.find_element(:id, "inputFirstName").send_keys "#{@testDataJSON['Lead'][0]['FirstName']}"
    @driver.find_element(:id, "inputLastName").send_keys "#{@testDataJSON['Lead'][0]['LastName']}"
    if @driver.find_element(:id, "inputEmail").attribute('value').eql?("")
      @driver.find_element(:id, "inputEmail").send_keys "#{@testDataJSON['Lead'][0]['Email']}"
    end
    @driver.find_element(:id, "inputPhone").send_keys "#{@testDataJSON['Lead'][0]['Phone']}"
    @driver.find_element(:id, "inputCompany").send_keys "#{@testDataJSON['Lead'][0]['Company']}"
    @driver.find_element(:id, "companySize").send_keys "#{@testDataJSON['Lead'][0]['Number_of_Full_Time_Employees__c']}"
    @driver.find_element(:id, "numberofDesks").send_keys "#{@testDataJSON['Lead'][0]['Interested_in_Number_of_Desks__c']}"
    leadSourceDrpdwn = @driver.find_element(:id, "sel1")
    leadSourceDrpdwn.click
    leadSourceDrpdwn.find_elements(:tag_name, "option")[3].click
    if isOverrideLeadSourceDetail
      @driver.find_element(:id, "leadSourceDetail").clear
    end
    building = @driver.find_element(:id, "inputLeadBuilding")
    @wait.until {building.displayed?}
    building.find_elements(:tag_name, "input")[0].send_keys("#{@testDataJSON['Lead'][0]["Building_Interested_In__c"]}")
    @wait.until {!@driver.find_element(:id, "spinnerContainer").displayed?}
    list = building.find_element(:tag_name, "ul")
    @wait.until {list.find_elements(:tag_name, "li")[1].displayed?}
    list.find_elements(:tag_name, "li")[1].click
    sleep(5)
    EnziUIUtility.selectElement(@driver, "Save", "button").click
  end
  def journeyAction(days)
    @driver.switch_to.default_content
    @helper.instance_variable_get(:@wait).until {@driver.find_element(:id, "servicedesk").find_elements(:tag_name, "iframe").size > 1}
    puts "switching to frame"
    sleep(20)
    puts @driver.find_element(:id, "ext-gen26").find_elements(:xpath, "//div[starts-with(@id, 'scc-pt-')]")[@driver.find_element(:id, "ext-gen26").find_elements(:xpath, "//div[starts-with(@id, 'scc-st-')]").size-1].find_elements(:tag_name, "iframe")[0].attribute("name")
    EnziUIUtility.switchToFrame(@driver, @driver.find_element(:id, "ext-gen26").find_elements(:xpath, "//div[starts-with(@id, 'scc-pt-')]")[@driver.find_element(:id, "ext-gen26").find_elements(:xpath, "//div[starts-with(@id, 'scc-st-')]").size-1].find_elements(:tag_name, "iframe")[0].attribute("name"))
    @helper.instance_variable_get(:@wait).until {@driver.find_element(:id, "actionDropdown").displayed?}
    @driver.find_element(:id,'actionDropdown').click
    sleep(0)
    @helper.instance_variable_get(:@wait).until {@driver.find_element(:id,'action:1').displayed?}
    @driver.find_element(:id,"action:1").click
    sleep(0)
    @helper.instance_variable_get(:@wait).until {@driver.find_element(:id,"header43").displayed?}
    sleep(8)
    @helper.instance_variable_get(:@wait).until {@driver.find_element(:id, "frame").displayed?}
    @driver.switch_to.frame(@driver.find_element(:id, "frame").attribute('id'))
    @helper.instance_variable_get(:@wait).until {@driver.find_element(:id,"FollowUpAfter").displayed?}
    sleep(1)
    @driver.find_element(:id,"FollowUpAfter").click
    @driver.find_element(:id,"FollowUpAfter").find_elements(:tag_name,"option")[days].click
    EnziUIUtility.selectElement(@driver, "Save", "button").click
  end
  def getRecord(query)
    index = 1
    record = []
    until index < 6 && !record[0].nil?
      puts "Getting info.."
      record = @helper.instance_variable_get(:@restForce).getRecords(query)
      index += 1
    end
    record
  end
end