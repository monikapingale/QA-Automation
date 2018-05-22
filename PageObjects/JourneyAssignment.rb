require 'enziUIUtility'
require 'salesforce'
require 'json'
require 'yaml'
require 'selenium-webdriver'
require 'date'

class JourneyAssignment 
  @mapRecordType = nil
  @salesforceBulk = nil
  @sObjectRecords = nil
  @timeSettingMap = nil
  @mapCredentials = nil
  @testDataJSON= nil

   def initialize(driver,helper)

    @driver = driver
    @helper = helper
    @testDataJSON = @helper.getRecordJSON()
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

  def createLead()
  	@driver.get "https://wework--staging.cs96.my.salesforce.com/?un=ashutosh.thakur@wework.com.staging&pw=Ashu@12345"
    @wait.until {@driver.find_element(:id, "tsidLabel").displayed?}
    @driver.find_element(:id, "tsidLabel").click
    @wait.until {@driver.find_element(:link, "Sales Console").displayed?}
    @driver.find_element(:link, "Sales Console").click
    @driver.find_element(:xpath, "//button[@id='ext-gen63']/div/span").click
   	#sleep(10)
    @driver.switch_to.frame('scc_widget_Inbound_Call')
    #@wait.until {@driver.find_element(:type, "text").displayed?}
    #@driver.find_element(:xpath, "//input[@type='text']").click
    @testDataJSON['InboundLead'][0]['Email'] = @testDataJSON['InboundLead'][0]['FirstName'] + SecureRandom.random_number(10000000000).to_s + "@example.com" 
    emailLead = @testDataJSON['InboundLead'][0]['Email']
    puts "\n"
    puts emailLead
    @driver.find_element(:xpath, "//input[@type='text']").send_keys @testDataJSON['InboundLead'][0]['Email']
    @wait.until {@driver.find_element(:id, "btnSearch").displayed?}
    puts "Click on Search Button"
      sleep(5)
    @driver.find_element(:xpath, "//button[@id='btnSearch']/span").click


    @wait.until {!@driver.find_element(:id, "spinnerContainer").displayed?}
    @wait.until {@driver.find_element(:id, "page-content-wrapper").displayed?}
   
   	puts "Click on New Lead Button"
    #@driver.find_element(:xpath, "//span[@class='default-font']").click
    @driver.find_element(:xpath, "//div[@id='page-content-wrapper']/div/div[2]/div/div/button/span").click
    !60.times{ break if (@driver.find_element(:id, "inputFirstName").displayed? rescue false); sleep 1 }
    @driver.find_element(:id, "inputFirstName").click
    @driver.find_element(:id, "inputFirstName").clear
    @driver.find_element(:id, "inputFirstName").send_keys @testDataJSON['InboundLead'][0]['FirstName']
    @driver.find_element(:id, "inputLastName").clear
    @driver.find_element(:id, "inputLastName").send_keys @testDataJSON['InboundLead'][0]['LastName']
    @driver.find_element(:id, "inputPhone").clear
    @driver.find_element(:id, "inputPhone").send_keys @testDataJSON['InboundLead'][0]['Phone']
    @driver.find_element(:id, "inputCompany").clear
    @driver.find_element(:id, "inputCompany").send_keys @testDataJSON['InboundLead'][0]['Company']
    @driver.find_element(:id, "companySize").click
    @driver.find_element(:id, "companySize").clear
    @driver.find_element(:id, "companySize").send_keys @testDataJSON['InboundLead'][0]['CompanySize']
    @driver.find_element(:id, "numberofDesks").click
    @driver.find_element(:id, "numberofDesks").clear
    @driver.find_element(:id, "numberofDesks").send_keys @testDataJSON['InboundLead'][0]['NumberofDesks']
    @driver.find_element(:id, "sel1").click
    @driver.find_element(:id, "sel1").click
    @driver.find_element(:name, "autocomplete").click
    @driver.find_element(:name, "autocomplete").clear
    @driver.find_element(:name, "autocomplete").send_keys "MUM"
    @driver.find_element(:link, "MUM-BKC").click
    @driver.find_element(:xpath, "(//button[@type='button'])[3]").click
    @driver.find_element(:link, "Open").click
	puts "lead Created With email = > #{emailLead}"
	return emailLead    
    rescue Exception => e
      raise e
      #return nil
  end

=begin
		def followUp()
	   	@driver.get "https://wework--staging.cs96.my.salesforce.com/?un=ashutosh.thakur@wework.com.staging&pw=Ashu@12345"
	    @wait.until {@driver.find_element(:id, "tsidLabel").displayed?}
	    @driver.find_element(:id, "tsidLabel").click
	    @wait.until {@driver.find_element(:link, "Sales Console").displayed?}
	    @driver.find_element(:link, "Sales Console").click
	    @driver.find_element(:xpath, "//button[@id='ext-gen63']/div/span").click
	   	#sleep(10)
	    @driver.switch_to.frame('scc_widget_Inbound_Call')
	    #@wait.until {@driver.find_element(:type, "text").displayed?}
	    #@driver.find_element(:xpath, "//input[@type='text']").click
	    @testDataJSON['InboundLead'][0]['Email'] = @testDataJSON['InboundLead'][0]['FirstName'] + SecureRandom.random_number(10000000000).to_s + "@example.com" 
	    emailLead = @testDataJSON['InboundLead'][0]['Email']
	    puts "\n"
	    puts emailLead
	    @driver.find_element(:xpath, "//input[@type='text']").send_keys @testDataJSON['InboundLead'][0]['Email']
	    @wait.until {@driver.find_element(:id, "btnSearch").displayed?}
	    puts "Click on Search Button"
	      sleep(5)
	    @driver.find_element(:xpath, "//button[@id='btnSearch']/span").click


	    @wait.until {!@driver.find_element(:id, "spinnerContainer").displayed?}
	    @wait.until {@driver.find_element(:id, "page-content-wrapper").displayed?}
	   
	   	puts "Click on New Lead Button"
	    #@driver.find_element(:xpath, "//span[@class='default-font']").click
	    @driver.find_element(:xpath, "//div[@id='page-content-wrapper']/div/div[2]/div/div/button/span").click
	    !60.times{ break if (@driver.find_element(:id, "inputFirstName").displayed? rescue false); sleep 1 }
	    @driver.find_element(:id, "inputFirstName").click
	    @driver.find_element(:id, "inputFirstName").clear
	    @driver.find_element(:id, "inputFirstName").send_keys @testDataJSON['InboundLead'][0]['FirstName']
	    @driver.find_element(:id, "inputLastName").clear
	    @driver.find_element(:id, "inputLastName").send_keys @testDataJSON['InboundLead'][0]['LastName']
	    @driver.find_element(:id, "inputPhone").clear
	    @driver.find_element(:id, "inputPhone").send_keys @testDataJSON['InboundLead'][0]['Phone']
	    @driver.find_element(:id, "inputCompany").clear
	    @driver.find_element(:id, "inputCompany").send_keys @testDataJSON['InboundLead'][0]['Company']
	    @driver.find_element(:id, "companySize").click
	    @driver.find_element(:id, "companySize").clear
	    @driver.find_element(:id, "companySize").send_keys @testDataJSON['InboundLead'][0]['CompanySize']
	    @driver.find_element(:id, "numberofDesks").click
	    @driver.find_element(:id, "numberofDesks").clear
	    @driver.find_element(:id, "numberofDesks").send_keys @testDataJSON['InboundLead'][0]['NumberofDesks']
	    @driver.find_element(:id, "sel1").click
	    @driver.find_element(:id, "sel1").click
	    @driver.find_element(:name, "autocomplete").click
	    @driver.find_element(:name, "autocomplete").clear
	    @driver.find_element(:name, "autocomplete").send_keys "MUM"
	    @driver.find_element(:link, "MUM-BKC").click
	    @driver.find_element(:xpath, "(//button[@type='button'])[3]").click
		puts "lead Created With email = > #{emailLead}"
		return emailLead    
	    rescue Exception => e
	      raise e
    end
=end
end
