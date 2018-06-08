require "json"
require "selenium-webdriver"
require "rspec"
#require_relative File.expand_path('',Dir.pwd )+"/specHelper.rb"
require_relative File.expand_path('..',Dir.pwd )+"/specHelper.rb"

require_relative '../PageObjects/CreateOppManageProduct.rb'
require_relative '../PageObjects/leadGeneration.rb'

include RSpec::Expectations

describe "SendToEnterpriseManageProduct" do

  before(:each) do
    @helper = Helper.new
    @driver = Selenium::WebDriver.for :chrome
    @testDataJSON = @helper.getRecordJSON()

    @objLeadGeneration = LeadGeneration.new(@driver,@helper)
    @createoppEnt= CreateOppManageProduct.new(@driver,@helper)    
    #@driver = ARGV[0]
    @accept_next_alert = true
    @driver.manage.timeouts.implicit_wait = 30
    @verification_errors = []    

=begin
    @timeSettingMap = YAML.load_file("D:/QAauto/timeSettings.yaml")
    @verification_errors = []
    @leadsTestData=@helper.instance_variable_get(:@sObjectRecords)[1]['CreateOpportunity'][0]['lead']
    @leadsTestData[0]['email'] = "test_johnsmith#{rand(99999999999999)}@example.com"
    @leadEmailId=@leadsTestData[0]['email']
    @leadsTestData[0]['company'] = "Test_johnsmith1#{rand(99999999999999)}"
    @oppTestData=@helper.instance_variable_get(:@sObjectRecords)[1]['CreateOpportunity'][1]['createOpp']
    @oppTestData[0]['accountName']="test_Enterprise1#{rand(99999999999999)}"
    @oppAccName=@oppTestData[0]['accountName']
    @wait = Selenium::WebDriver::Wait.new(:timeout => @timeSettingMap['Wait']['Environment']['Lightening']['Min'])


=end

    #@leadsTestData=@helper.instance_variable_get(:@sObjectRecords)['CreateOpportunity'][0]['lead']
    #@leadsTestData[0]['email'] = "test_johnsmith#{rand(99999999999999)}@example.com"
    #@leadEmailId=@leadsTestData[0]['email']
    #@leadsTestData[0]['company'] = "Test_johnsmith1#{rand(99999999999999)}"
    #@oppTestData=@helper.instance_variable_get(:@sObjectRecords)['CreateOpportunity'][1]['createOpp']
    #@oppTestData[0]['accountName']="test_Enterprise1#{rand(99999999999999)}"
    #@oppAccName=@oppTestData[0]['accountName']
    #puts @oppAccName    
    #@wait = Selenium::WebDriver::Wait.new(:timeout => @timeSettingMap['Wait']['Environment']['Lightening']['Min'])
  end

  after(:all) do
    
    @driver.quit
    @verification_errors.should == []
  end

  it "Create opportunity and add product from lead", :"2172"=> true do
    begin
        @helper.addLogs('C:2172 Create opportunity and add product from lead.','2172')

        @testDataJSON['CreateLeadFromWeb'][0]["BuildingName"]  = 'marol'
        @testDataJSON['CreateLeadFromWeb'][0]["City"]  = 'mumbai'
        @testDataJSON['CreateLeadFromWeb'][0]["Building"]  = 'MUM-Marol'
        @testDataJSON['CreateLeadFromWeb'][0]['Email'] = @testDataJSON['CreateLeadFromWeb'][0]['Name'] + SecureRandom.random_number(10000000000).to_s + "@example.com"

        @testDataJSON['CreateOpportunity']['Opportunity'][0]['account'] = 'newOrg'
        #set org name to search
        #@testDataJSON['CreateOpportunity']['Opportunity'][0]['accountName'] = 'test_Enterprise1'
        @testDataJSON['CreateOpportunity']['Opportunity'][0]['Number_of_Full_Time_Employees__c'] = '1600'
        @testDataJSON['CreateOpportunity']['Opportunity'][0]['opportunityRole'] = 'Decision Maker'        
        @testDataJSON['CreateOpportunity']['Opportunity'][0]['BuildingOrGeography'] = 'building'
        @testDataJSON['CreateOpportunity']['Opportunity'][0]['BuildingOrGeographyName'] = 'AMS-Metropool'

        @testDataJSON['CreateOpportunity']['Opportunity'][0]['Action'] = 'addProducts'

        @testDataJSON['CreateOpportunity']['Product'][0]['ProductFamily'] = 'WeWork'
        @testDataJSON['CreateOpportunity']['Product'][0]['Product'] = 'Deal'
        #@testDataJSON['CreateOpportunity']['Product'][0]['ProductCategory'] = 'Large Office(WWLO)'
        @testDataJSON['CreateOpportunity']['Product'][0]['Quantity'] = '150'
        @testDataJSON['CreateOpportunity']['Product'][0]['BuildingOrGeography'] = 'Geography'
        @testDataJSON['CreateOpportunity']['Product'][0]['BuildingOrGeographyName'] = 'Baner Gaon, Baner, Pune, Maharashtra 411045, India'
        @testDataJSON['CreateOpportunity']['Product'][0]['isPrimaryProductToSet'] = 'false'
        @testDataJSON['CreateOpportunity']['Product'][0]['Action'] = 'Save Product'

        @helper.addLogs('Go to Staging website and create lead')
        @testDataJSON['MarketingLandingPage'][0]['Email'] = @testDataJSON['MarketingLandingPage'][0]['Name'] + SecureRandom.random_number(10000000000).to_s + "@example.com"            
        @testDataJSON['CreateLeadFromWeb'][0]['Email'] = @testDataJSON['MarketingLandingPage'][0]['Email']
        expect(@objLeadGeneration.createLeadFromMarketingPage()).to eq true
        @helper.addLogs('Success')
      
        @helper.addLogs('Login to salesforce')            
        expect(@createoppEnt.loginToSalesforce()).to eq true
        @helper.addLogs('Success')

        @helper.addLogs('Go to Sales Console App')            
        expect(@helper.go_to_app(@driver,'Sales Console')).to eq true
        @helper.addLogs('Success')

        #@helper.addLogs("[Step ]     : Fetch lead deatails")            
        #insertedLeadInfo = @objLeadGeneration.fetchLeadDetails(@testDataJSON['CreateLeadFromWeb'][0]['Email'])
        #expect(insertedLeadInfo).to_not eq nil
        #expect(insertedLeadInfo.size).to eq 1
        #expect(insertedLeadInfo[0]).to_not eq nil  
        #insertedLeadInfo =  insertedLeadInfo[0]      
        #@helper.addLogs("[Result ]   : Success\n")

        #@testDataJSON['CreateLeadFromWeb'][0]['Email'] = 'john.sparrow4680545080@example.com'
        #@driver.get "https://wework--staging.cs96.my.salesforce.com/console?tsid=02uF00000011Ncb"

        @helper.addLogs("[Step ]     : Go to create opp page of created journey")
        @createoppEnt.goToCreateOppPageFromJourney(@testDataJSON['CreateLeadFromWeb'][0]['Email'])
        @helper.addLogs("[Result ]   : Success\n")
    
        #sleep(10)
        @helper.addLogs("[Step ]     : filling Create opp form")
        @createoppEnt.createOppEnt()
        @helper.addLogs("[Result ]   : Success\n")
        
        sleep(50)
        #@driver.switch_to.default_content
=begin
    @driver.find_element(:id, "phSearchInput").clear
    @driver.find_element(:id, "phSearchInput").send_keys @testDataJSON['CreateLeadFromWeb'][0]['Email']

    sleep(5)
    @driver.find_element(:xpath, "//div[@id='phSearchInput_autoCompleteRowId_0']/span/span").click

    #sw to frame
    #sleep(10)
    EnziUIUtility.switchToWindow(@driver, @driver.current_url())
    puts @driver.find_elements(:xpath, "//iframe[contains(@id, 'ext-comp-')]").size

    puts @driver.find_elements(:xpath, "//iframe[contains(@id, 'ext-comp-')]")[0].attribute('id')
    @size  = @driver.find_elements(:xpath, "//iframe[contains(@id, 'ext-comp-')]").size

    frameid = @driver.find_elements(:xpath, "//iframe[contains(@id, 'ext-comp-')]")[@size - 1 - 1].attribute('id')
    puts frameid
    puts "switching to frame"
    @driver.switch_to.frame(frameid)
    puts "click on link"
    


@driver.find_element(:xpath, " //*[@id='Journey__c_body']/table/tbody/tr[2]/th/a").click
puts "click on actionDropdown"
#sleep(30)


EnziUIUtility.switchToWindow(@driver, @driver.current_url())
#sleep(5)
    puts @driver.find_elements(:xpath, "//iframe[contains(@id, 'ext-comp-')]").size
    puts "121211212"
    @size = @driver.find_elements(:xpath, "//iframe[contains(@id, 'ext-comp-')]").size
    puts @driver.find_elements(:xpath, "//iframe[contains(@id, 'ext-comp-')]")[@size - 1].attribute('id')
    puts @driver.find_elements(:xpath, "//iframe[contains(@id, 'ext-comp-')]")[@size - 1 - 1].attribute('id')
    
    frameid2 = @driver.find_elements(:xpath, "//iframe[contains(@id, 'ext-comp-')]")[@size -2].attribute('id')
    puts frameid2
    puts "switching to frame"
    sleep(0)
    @driver.switch_to.frame(frameid2)
    puts "retetretre"
    #sleep(10)
    @driver.find_element(:id,'actionDropdown').click
    sleep(5)
    @driver.find_element(:xpath, "//li[@id='action:7']/a/span").click
=end

            

=begin
    #@helper.addLogs('C:2 To check opportunity is created from lead through Send to Enterprise','2')
    @driver.get "https://wework--staging.cs96.my.salesforce.com/"
    @driver.find_element(:id, "username").clear
    @driver.find_element(:id, "username").send_keys @helper.instance_variable_get(:@mapCredentials)['Staging']['WeWork System Administrator']['username']
    @driver.find_element(:id, "password").clear
    @driver.find_element(:id, "password").send_keys @helper.instance_variable_get(:@mapCredentials)['Staging']['WeWork System Administrator']['password']
    @driver.find_element(:id, "Login").click
    puts "Login sucessfully \n"

    @wait.until {@driver.find_element(:id ,"tsidLabel").displayed? }
    puts @driver.current_url()
    @result= @helper.createSalesforceRecord('Lead',@leadsTestData)
    puts @result
    url = @driver.current_url();
    newUrl = url.split('/')
    @driver.get "#{newUrl[0]}//#{newUrl[2]}/#{@result[0]['Id']}"
    puts "Lead created suceessfully\n "

    portfolio= @helper.getSalesforceRecord('Building__c',"select Market__r.Name, Market__c, Id, Name, Address__c from Building__c where Name= '#{@oppTestData[0]['building']}'")
    port =  portfolio[0].fetch("Market__r.Name")
    puts port
    result1= @helper.getSalesforceRecord('Account_Queue__c',"SELECT Member__c from Account_Queue__c where Account_Record_Type__c= 'Enterprise Solutions' AND Market__c='#{port}'")
    puts result1.class

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
    sleep(11)
    @driver.find_element(:id, "Geography__c:0").send_keys  @oppTestData[0]['geography']

    #geography on manage product is selected

    outerContainer = @driver.find_element(:id, "Geography__c:0list")
    @wait.until {!outerContainer.find_element(:id,"spinner").displayed?}
    geolist=outerContainer.find_elements(:tag_name,"ul")[0]
    @wait.until {geolist.displayed?}
    @wait.until {!outerContainer.find_element(:id,"spinner").displayed?}
    geo= geolist.find_elements(:tag_name,"li")[1]
    @wait.until {geo.displayed?}
    geo.click
    @wait.until {!@driver.find_element(:id,"spinner").displayed?}

    #@helper.getElementByAttribute(@driver,:tag_name ,"div","title",@oppTestData[0]['geography'])[0].click
    sleep(5)
=end
=begin
    #staginglogin
    #@createoppEnt.Salesforcelogin
    #@createoppEnt.createRecord
    #@createoppEnt.createOppEnt

    @helper.getElementByAttribute(@driver,:tag_name ,"button","title","Save Products").click
    sleep(60)

    portfolio= @helper.getSalesforceRecord('Building__c',"select Market__r.Name, Market__c, Id, Name, Address__c from Building__c where Name= '#{@oppTestData[0]['building']}'")
    port =  portfolio[0].fetch("Market__r.Name")
    puts port
    result1= @helper.getSalesforceRecord('Account_Queue__c',"SELECT Member__c from Account_Queue__c where Account_Record_Type__c= 'Enterprise Solutions' AND Market__c='#{port}'")
    puts result1.class

    #puts "Checking owner of opportunity"
    #
    passedLogs = @helper.addLogs("[Step    ] To check lead is converted")
    expect(@helper.getSalesforceRecord("Lead","SELECT id,isConverted FROM Lead WHERE Email = '#{@leadsTestData[0]['email']}'")[0].fetch("IsConverted").eql? 'true').to be true
    passedLogs = @helper.addLogs("[Result  ]  Success")


    passedLogs = @helper.addLogs("[Step    ] To check account is created")
    account=@helper.getSalesforceRecord('Account',"SELECT id, Owner.Id, Owner.Name, RecordType.Name, Name FROM Account WHERE Name = '#{@oppTestData[0]['accountName']}'")
    expect(account).to_not eq nil
    puts account[0].fetch('Name')
    passedLogs = @helper.addLogs("[Validate] Account should be created with account name #{@oppAccName}")
    passedLogs = @helper.addLogs("[Result  ] Success")


    passedLogs = @helper.addLogs("[Step    ] To check contact is created")
    contact= @helper.getSalesforceRecord('Contact',"SELECT Id, Owner.Id, Owner.Name, Name,Account.Name,Email,RecordType.Name FROM Contact where Email= '#{@leadsTestData[0]['email']}'")
    expect(contact).to_not eq nil
    puts contact[0].fetch('Name')
    passedLogs = @helper.addLogs("[Validate] Contact should be created with email #{@leadsTestData[0]['email']}")
    passedLogs = @helper.addLogs("[Result  ] Success")

    passedLogs = @helper.addLogs("[Step    ] To check opportunity is created")
    puts account[0].fetch('Name')
    @acc=account[0].fetch('Name')
    opportunity=@helper.getSalesforceRecord('opportunity',"SELECT Name, Owner.Id, Owner.Name, StageName, Primary_Member__c,Primary_Member__r.Name, LeadSource, Lead_Source_Detail__c, Building__c,Building__r.Name, Building_Address__c, Territory__c, RecordType.Name, Deal_Type__c, Owner_Auto_Assign__c, Split_Opportunity__c, Account.Name, Interested_in_Number_of_Desks__c from opportunity where Account.Name='#{@oppTestData[0]['accountName']}'")
    expect(opportunity).to_not eq nil
    passedLogs = @helper.addLogs("[Result  ] Success")

    passedLogs = @helper.addLogs("[Step    ] To check product is created")
    product=@helper.getSalesforceRecord('OpportunityLineItem',"select Opportunity.Name,Product2.Name, ProductCode, Family__c, Product_Category__c, ProductCode__c, Building__c, Geography__c, Is_Primary_Product__c, Quantity from OpportunityLineItem where Opportunity.Name='#{opportunity[0].fetch('Name')}'")
    expect(product).to_not eq nil
    puts opportunity[0].fetch('Name')
    passedLogs = @helper.addLogs("[Result  ] Success")

    puts opportunity[0]
    puts result1[0].fetch('Member__c')
    puts result1
    accQue = Array.new
    result1.each do |user|
      accQue.push(user.fetch('Member__c'))
    end
    puts accQue
    #expect(opportunity.fetch('Owner.Id').include?.to eq "#{building.fetch('Community_Lead__c')}")
    puts accQue.include? opportunity[0].fetch('Owner.Id')

    passedLogs = @helper.addLogs("[Validate] Checking Owner of contact")
    expect(accQue.include? contact[0].fetch('Owner.Id')).to eq true
    puts "Contact owner is '#{contact[0].fetch('Owner.Name')}' \n "
    passedLogs = @helper.addLogs("[Result  ] Success")

    passedLogs = @helper.addLogs("[Validate] Checking record type of contact")
    expect(contact[0].fetch('RecordType.Name')).to eq "Enterprise Solutions"
    puts "Contact record type is'#{contact[0].fetch('RecordType.Name')}' \n"
    passedLogs = @helper.addLogs("[Result  ] Success")

    passedLogs = @helper.addLogs("[Validate] Checking Owner of account")
    expect(accQue.include? account[0].fetch('Owner.Id')).to eq true
    puts "Account owner is'#{account[0].fetch('Owner.Name')}' \n"
    passedLogs = @helper.addLogs("[Result  ] Success")

    passedLogs = @helper.addLogs("[Validate] Checking record type of account")
    expect(account[0].fetch('RecordType.Name')).to eq "Enterprise Solutions"
    puts "Account record type is'#{account[0].fetch('RecordType.Name')}' \n"
    passedLogs = @helper.addLogs("[Result  ] Success")

    passedLogs = @helper.addLogs("[Validate] Checking owner of opportunity")
    expect(accQue.include? opportunity[0].fetch('Owner.Id')).to eq true
    puts "Opportunity owner is'#{opportunity[0].fetch('Owner.Name')}' \n"
    passedLogs = @helper.addLogs("[Result  ] Success")

    passedLogs = @helper.addLogs("[Validate] Checking record type of opportunity")
    expect(opportunity[0].fetch('RecordType.Name')).to eq "Enterprise Solutions"
    puts "Opportunity record type is'#{opportunity[0].fetch('RecordType.Name')}' \n"
    passedLogs = @helper.addLogs("[Result  ] Success")

    passedLogs = @helper.addLogs("[Validate] Checking stage of opportunity")
    expect(opportunity[0].fetch('StageName')).to eq "Qualifying"
    puts "Opportunity stage is '#{opportunity[0].fetch('StageName')}' \n"
    passedLogs = @helper.addLogs("[Result  ] Success")

    passedLogs = @helper.addLogs("[Validate] Checking Account name on opportunity")
    expect(opportunity[0].fetch('Account.Name')).to eq @oppTestData[0]['accountName']
    puts "Account name on opportunity is '#{opportunity[0].fetch('Account.Name')}' \n"
    passedLogs = @helper.addLogs("[Result  ] Success")

    passedLogs = @helper.addLogs("[Validate] Checking Main Contact on opportunity")
    expect(opportunity[0].fetch('Primary_Member__c')).to eq contact[0].fetch('Id')
    puts "Main contact is '#{opportunity[0].fetch('Primary_Member__r.Name')}'  \n"
    passedLogs = @helper.addLogs("[Result  ] Success")

    #puts "Checking Interested No of Desk on opportunity"
    #expect(opportunity[0].fetch('Interested_in_Number_of_Desks__c')).to eq '@leadsTestData[0]['Interested_in_Number_of_Desks__c']
    #puts " Interested No of Desk on opportunity is #{opportunity[0].fetch('Interested_in_Number_of_Desks__c')} "

    passedLogs = @helper.addLogs("[Validate] Checking Building/Nearest Building on opportunity")
    expect(opportunity[0].fetch('Building__c')).to eq portfolio[0].fetch('Id')
    puts " Building/Nearest Building is '#{opportunity[0].fetch('Building__r.Name')}' \n"
    passedLogs = @helper.addLogs("[Result  ] Success")

    passedLogs = @helper.addLogs("[Validate] Checking Address on oppportunity")
    expect(opportunity[0].fetch('Building_Address__c')).to eq portfolio[0].fetch('Address__c')
    puts "Address of building on opportunity is '#{opportunity[0].fetch('Building_Address__c')}' \n"
    passedLogs = @helper.addLogs("[Result  ] Success")

    passedLogs = @helper.addLogs("[Validate] Checking Portfolio on opportunity")
    puts "Checking Portfolio on opportunity"
    expect(opportunity[0].fetch('Territory__c')).to eq portfolio[0].fetch('Market__r.Name')
    puts "Portfolio of building on opportunity is '#{opportunity[0].fetch('Territory__c')}' \n"
    passedLogs = @helper.addLogs("[Result  ] Success")

    passedLogs = @helper.addLogs("[Validate] Checking Lead source on opportunity")
    expect(opportunity[0].fetch('LeadSource')).to eq @leadsTestData[0]['leadSource']
    puts "Lead source on opportunity is '#{opportunity[0].fetch('LeadSource')}' \n"
    passedLogs = @helper.addLogs("[Result  ] Success")

    passedLogs = @helper.addLogs("[Validate] Checking Lead source Deatil on opportunity")
    expect(opportunity[0].fetch('Lead_Source_Detail__c')).to eq @leadsTestData[0]['lead_Source_Detail__c']
    puts "Lead source detail on opportunity is '#{opportunity[0].fetch('Lead_Source_Detail__c')}' \n"
    passedLogs = @helper.addLogs("[Result  ] Success")

    passedLogs = @helper.addLogs("[Validate] Checking Deal type on opportunity")
    expect(opportunity[0].fetch('Deal_Type__c')).to eq "Transactional"
    puts "Deal Type on opportunity is '#{opportunity[0].fetch('Deal_Type__c')}' \n"
    passedLogs = @helper.addLogs("[Result  ] Success")

    passedLogs = @helper.addLogs("[Validate] Checking Owner Auto Assign on opportunity")
    expect(opportunity[0].fetch('Owner_Auto_Assign__c')).to eq "true"
    puts "Owner Auto Assign on opportunity '#{opportunity[0].fetch('Owner_Auto_Assign__c')}' \n"
    passedLogs = @helper.addLogs("[Result  ] Success")


    #product=

=end


    #@wait.until{@driver.find_element(:id ,"tsidLabel").displayed? }
=begin
    puts @driver.current_url()
    @result= @helper.createSalesforceRecord('Lead',@leadsTestData)
    puts @result
    url = @driver.current_url();
    newUrl = url.split('/')
    @driver.get "#{newUrl[0]}//#{newUrl[2]}/#{@result[0]['Id']}"
    puts "Lead created suceessfully\n "
=end
   
    @helper.postSuccessResult('2172')
    rescue Exception => e
      @helper.postFailResult(e,'2172')
    end
  end



    it "Create opportunity and Save from lead", :"2173"=> true do
    begin
        @helper.addLogs('C:2172 Create opportunity and add product from lead.','2172')

        @testDataJSON['CreateLeadFromWeb'][0]["BuildingName"]  = 'marol'
        @testDataJSON['CreateLeadFromWeb'][0]["City"]  = 'mumbai'
        @testDataJSON['CreateLeadFromWeb'][0]["Building"]  = 'MUM-Marol'
        @testDataJSON['CreateLeadFromWeb'][0]['Email'] = @testDataJSON['CreateLeadFromWeb'][0]['Name'] + SecureRandom.random_number(10000000000).to_s + "@example.com"

        # newOrg   searchOrg   checkOrg
        @testDataJSON['CreateOpportunity']['Opportunity'][0]['account'] = 'searchOrg'
        #set org name to search
        @testDataJSON['CreateOpportunity']['Opportunity'][0]['accountName'] = 'test_Enterprise1'
        @testDataJSON['CreateOpportunity']['Opportunity'][0]['Number_of_Full_Time_Employees__c'] = '1600'
        @testDataJSON['CreateOpportunity']['Opportunity'][0]['opportunityRole'] = 'Decision Maker'
        #   building       geography      
        @testDataJSON['CreateOpportunity']['Opportunity'][0]['BuildingOrGeography'] = 'geography'
        @testDataJSON['CreateOpportunity']['Opportunity'][0]['BuildingOrGeographyName'] = 'Baner Gaon, Baner, Pune, Maharashtra 411045, India'

        # save&close       addProducts   close
        @testDataJSON['CreateOpportunity']['Opportunity'][0]['Action'] = 'addProducts'

        @testDataJSON['CreateOpportunity']['Product'][0]['ProductFamily'] = 'WeWork'
        @testDataJSON['CreateOpportunity']['Product'][0]['Product'] = 'Deal'
        #set if product is Desk
        #@testDataJSON['CreateOpportunity']['Product'][0]['ProductCategory'] = 'Large Office(WWLO)'
        @testDataJSON['CreateOpportunity']['Product'][0]['Quantity'] = '150'
        @testDataJSON['CreateOpportunity']['Product'][0]['BuildingOrGeography'] = 'Geography'
        @testDataJSON['CreateOpportunity']['Product'][0]['BuildingOrGeographyName'] = 'Pune, Maharashtra, India'
        @testDataJSON['CreateOpportunity']['Product'][0]['isPrimaryProductToSet'] = 'false'
        @testDataJSON['CreateOpportunity']['Product'][0]['Action'] = 'Save Product'

        @helper.addLogs('Go to Staging website and create lead') 
        @testDataJSON['MarketingLandingPage'][0]['Email'] = @testDataJSON['MarketingLandingPage'][0]['Name'] + SecureRandom.random_number(10000000000).to_s + "@example.com"            
        @testDataJSON['CreateLeadFromWeb'][0]['Email'] = @testDataJSON['MarketingLandingPage'][0]['Email']         
        expect(@objLeadGeneration.createLeadFromMarketingPage()).to eq true
        @helper.addLogs('Success')
      
        @helper.addLogs('Login to salesforce')            
        expect(@createoppEnt.loginToSalesforce()).to eq true
        @helper.addLogs('Success')

        @helper.addLogs('Go to Sales Console App')            
        expect(@helper.go_to_app(@driver,'Sales Console')).to eq true
        @helper.addLogs('Success')
=begin
        @helper.addLogs("[Step ]     : Fetch lead deatails")            
        insertedLeadInfo = @objLeadGeneration.fetchLeadDetails(@testDataJSON['CreateLeadFromWeb'][0]['Email'])
        expect(insertedLeadInfo).to_not eq nil
        expect(insertedLeadInfo.size).to eq 1
        expect(insertedLeadInfo[0]).to_not eq nil  
        insertedLeadInfo =  insertedLeadInfo[0]      
        @helper.addLogs("[Result ]   : Success\n")
=end
        @helper.addLogs("[Step ]     : Go to create opp page of created journey")
        @createoppEnt.goToCreateOppPageFromJourney(@testDataJSON['CreateLeadFromWeb'][0]['Email'])
        @helper.addLogs("[Result ]   : Success\n")
    
        @helper.addLogs("[Step ]     : filling Create opp form")
        @createoppEnt.createOppEnt()
        @helper.addLogs("[Result ]   : Success\n")
        
        sleep(50)
        #@driver.switch_to.default_content

    @helper.postSuccessResult('2172')
    rescue Exception => e
      @helper.postFailResult(e,'2172')
    end
  end

  it "Create opportunity and Save from lead", :"2174"=> true do
    begin
        @helper.addLogs('C:2172 Create opportunity and add product from lead.','2174')

        @testDataJSON['CreateLeadFromWeb'][0]["BuildingName"]  = 'marol'
        @testDataJSON['CreateLeadFromWeb'][0]["City"]  = 'mumbai'
        @testDataJSON['CreateLeadFromWeb'][0]["Building"]  = 'MUM-Marol'
        @testDataJSON['CreateLeadFromWeb'][0]['Email'] = @testDataJSON['CreateLeadFromWeb'][0]['Name'] + SecureRandom.random_number(10000000000).to_s + "@example.com"

        # newOrg   searchOrg   checkOrg
        @testDataJSON['CreateOpportunity']['Opportunity'][0]['account'] = 'searchOrg'
        #set org name to search
        @testDataJSON['CreateOpportunity']['Opportunity'][0]['accountName'] = 'test_Enterprise1'
        @testDataJSON['CreateOpportunity']['Opportunity'][0]['Number_of_Full_Time_Employees__c'] = '1600'
        @testDataJSON['CreateOpportunity']['Opportunity'][0]['opportunityRole'] = 'Decision Maker'
        #   building       geography      
        @testDataJSON['CreateOpportunity']['Opportunity'][0]['BuildingOrGeography'] = 'building'
        @testDataJSON['CreateOpportunity']['Opportunity'][0]['BuildingOrGeographyName'] = 'MUM-BKC'

        # save&close       addProducts   close
        @testDataJSON['CreateOpportunity']['Opportunity'][0]['Action'] = 'addProducts'

        @testDataJSON['CreateOpportunity']['Product'][0]['ProductFamily'] = 'WeWork'
        @testDataJSON['CreateOpportunity']['Product'][0]['Product'] = 'Desk'
        #set if product is Desk
        @testDataJSON['CreateOpportunity']['Product'][0]['ProductCategory'] = 'Large Office(WWLO)'
        @testDataJSON['CreateOpportunity']['Product'][0]['Quantity'] = '150'
        @testDataJSON['CreateOpportunity']['Product'][0]['BuildingOrGeography'] = 'Building'
        @testDataJSON['CreateOpportunity']['Product'][0]['BuildingOrGeographyName'] = 'MUM-Marol'
        @testDataJSON['CreateOpportunity']['Product'][0]['isPrimaryProductToSet'] = 'false'
        @testDataJSON['CreateOpportunity']['Product'][0]['Action'] = 'Save Product'

        @helper.addLogs('Go to Staging website and create lead') 
        @testDataJSON['MarketingLandingPage'][0]['Email'] = @testDataJSON['MarketingLandingPage'][0]['Name'] + SecureRandom.random_number(10000000000).to_s + "@example.com"            
        @testDataJSON['CreateLeadFromWeb'][0]['Email'] = @testDataJSON['MarketingLandingPage'][0]['Email']         
        expect(@objLeadGeneration.createLeadFromMarketingPage()).to eq true
        @helper.addLogs('Success')
      
        @helper.addLogs('Login to salesforce')            
        expect(@createoppEnt.loginToSalesforce()).to eq true
        @helper.addLogs('Success')

        @helper.addLogs('Go to Sales Console App')            
        expect(@helper.go_to_app(@driver,'Sales Console')).to eq true
        @helper.addLogs('Success')
=begin
        @helper.addLogs("[Step ]     : Fetch lead deatails")            
        insertedLeadInfo = @objLeadGeneration.fetchLeadDetails(@testDataJSON['CreateLeadFromWeb'][0]['Email'])
        expect(insertedLeadInfo).to_not eq nil
        expect(insertedLeadInfo.size).to eq 1
        expect(insertedLeadInfo[0]).to_not eq nil  
        insertedLeadInfo =  insertedLeadInfo[0]      
        @helper.addLogs("[Result ]   : Success\n")
=end
        @helper.addLogs("[Step ]     : Go to create opp page of created journey")
        @createoppEnt.goToCreateOppPageFromJourney(@testDataJSON['CreateLeadFromWeb'][0]['Email'])
        @helper.addLogs("[Result ]   : Success\n")
    
        @helper.addLogs("[Step ]     : filling Create opp form")
        @createoppEnt.createOppEnt()
        @helper.addLogs("[Result ]   : Success\n")
        
        sleep(50)
        #@driver.switch_to.default_content

    @helper.postSuccessResult('2174')
    rescue Exception => e
      @helper.postFailResult(e,'2174')
    end
  end

  def element_present?(how, what)
    @driver.find_element(how, what)
    true
  rescue Selenium::WebDriver::Error::NoSuchElementError
    false
  end

  def alert_present?()
    @driver.switch_to.alert
    true
  rescue Selenium::WebDriver::Error::NoAlertPresentError
    false
  end

  def verify(&blk)
    yield
  rescue ExpectationNotMetError => ex
    @verification_errors << ex
  end

  def close_alert_and_get_its_text(how, what)
    alert = @driver.switch_to().alert()
    alert_text = alert.text
    if (@accept_next_alert) then
      alert.accept()
    else
      alert.dismiss()
    end
    alert_text
  ensure
    @accept_next_alert = true
  end
end
