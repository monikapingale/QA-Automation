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
    @driver.find_element(:id, "companySize").send_keys "#{@testDataJSON['Lead'][0]['CompanySize']}"
    @driver.find_element(:id, "numberofDesks").send_keys "#{@testDataJSON['Lead'][0]['NumberofDesks']}"
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