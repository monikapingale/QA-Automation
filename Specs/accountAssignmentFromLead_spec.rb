
require_relative File.expand_path('',Dir.pwd )+"/specHelper.rb"
#require_relative File.expand_path('..',Dir.pwd )+"/specHelper.rb"


#require_relative '../PageObjects/accountAssignmentFromLead.rb'
#require_relative 'WeWork/Modules/AccountAssignment/PageObjects/accountAssignmentFromLead.rb'
require_relative '../PageObjects/accountAssignmentFromLead.rb'
require 'json'
require 'yaml'
require 'selenium-webdriver'
require 'rspec'
require 'rails'
require 'httparty'

describe 'AccountAssignmentFromLead' do
  
  before(:all){
    @helper = Helper.new
    #@driver = Selenium::WebDriver.for :chrome
    @driver = ARGV[0]
    @testDataJSON = @helper.getRecordJSON()
    @objAccAssignmentFromLead = AccountAssignmentFromLead.new(@driver,@helper)
  }  

 context "by Create Account and Dont Merge" do


  it "test", :'159'=> 'true' do
    @driver.get "https://test.salesforce.com/login.jsp?pw=Anujgagare@525255&un=kishor.shinde@wework.com.staging"
    sleep(10)
    puts "1245445124545"

    EnziUIUtility.switchToWindow(@driver, @driver.current_url())
    #@driver.find_element(:xpath, "//button[contains(@id, 'listButtons')]/ul/li[1]/input[1]").click

    #//*[@id="00B0G000008DH6V_listButtons"]/ul/li[1]/input[1]
    #@driver.get "https://wework--staging.cs96.my.salesforce.com/console?tsid=02uF00000011Ncb"
    sleep(5)
    puts "12121"
    #@driver.find_element(:id,'allBox').click
    
    #@driver.switch_to.default_content
    #//*[@id="ext-comp-1005"]
    #actionDropdown
    #//*[@id="actionDropdown"]

    puts @driver.find_elements(:xpath, "//iframe[contains(@id, 'ext-comp-')]").size
    puts @driver.find_elements(:xpath, "//iframe[contains(@id, 'ext-comp-')]")[0].attribute('id')
    
    puts @driver.find_elements(:xpath, "//iframe[contains(@id, 'ext-comp-')]")[1].attribute('id')
    

    frameid = @driver.find_elements(:xpath, "//iframe[contains(@id, 'ext-comp-')]")[1].attribute('id')
    puts frameid
    @driver.switch_to.frame(frameid)
    #EnziUIUtility.switchToWindow(@driver, @driver.current_url())
    sleep(10)
    #puts @driver.find_element(:id,"#{frameid}").attribute('name')
    sleep(5)
    puts "8888"


    sleep(70)
    @driver.find_element(:id,'actionDropdown').click
    #@driver.find_element(:id,'actionDropdown').click
    puts "45454"
    sleep(10)
     end

  it "C2022 : To check account assignment for Record Type Consumer and Deal type Transactional.", :'2022'=> 'true' do
      begin
          @helper.addLogs('C:2022 To check account assignment for Record Type Consumer and Deal type Transactional.','2022')

          @testDataJSON['AccountAssignment']["GenerateLeadFromWeb"][0]["BuildingName"]  = 'marol'
          @testDataJSON['AccountAssignment']["GenerateLeadFromWeb"][0]["City"]  = 'mumbai'
          @testDataJSON['AccountAssignment']['tour'][0]['companySize']  = '15'
          @testDataJSON['AccountAssignment']['tour'][0]['numberOfDesks']  = '5'
          @testDataJSON['AccountAssignment']['tour'][0]['building']  = 'MUM-BKC'          

          @helper.addLogs("[Step    ] get building details of #{@testDataJSON['AccountAssignment']["tour"][0]["building"]}")
          building = @objAccAssignmentFromLead.fetchBuildingDetails(@testDataJSON['AccountAssignment']["tour"][0]["building"])
          expect(building).to_not eq nil

          @testDataJSON['AccountAssignment']['LeadJSON'][0]['body']['buildings_interested_uuids'][0]  = building[0].fetch('UUID__c')

          @helper.addLogs("[Step    ] Creating lead")
          emailId = @objAccAssignmentFromLead.createLead()
          puts emailId
          #expect(@driver.title).to match("Coworking Office Sambhav BKC | WeWork")

          puts "lead created from web with emailId = #{emailId}"
          @helper.addLogs("[Validate]  Lead should be created")
    
          lead = @objAccAssignmentFromLead.fetchLeadDetails(emailId)
          expect(lead[0]).to_not eq nil

          @helper.addLogs("[Expected]  Lead created successfully with emailId = #{emailId}")
          expect(lead[0].fetch('Id')).to_not eq 'nil'
          @helper.addLogs("[Result  ]  Success ")

          @helper.addLogs("[Step    ] logging to salesforce")
          expect(@objAccAssignmentFromLead.loginToSalesforce).to_not eq nil

          @helper.addLogs("[Step    ] go to details page of created lead and Clicking on 'Manage/book Tour' button")
          expect(@objAccAssignmentFromLead.goToDetailPage(lead[0].fetch('Id'))).to eq true

          @helper.addLogs("[Validate] Checking Manage Tour page when user click on 'Manage/book tour' button")
          expect(@driver.title).to match("Manage Tours")
          @helper.addLogs("[Expected] Manage tour page opened successfully with Page Title= Manage Tours \n[Result  ]  Success")

          @helper.addLogs("[Step    ] filling all required fields and booked a tour")

          expect(@objAccAssignmentFromLead.bookTour(0,true)).to eq true

          @helper.addLogs("[Step    ] click on Create Account and Don't Merge")
          expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Don't Merge",nil)).to eq true          

          @helper.addLogs("[Step    ] checking fields...")

          @helper.addLogs("[Step    ] get Contact details")
          contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
          expect(contact[0].size != 0).to eq true
          expect(contact[0]).to_not eq nil
        
          puts contact[0].attrs
          puts contact[0].fetch('Id')
          puts contact[0].fetch('RecordType')['Name']
          expect(contact).to_not eq nil

          @helper.addLogs("[Validate] contact:RecordType.Name")
          expect(contact[0].fetch('RecordType')['Name']).to eq "Consumer"
          @helper.addLogs("[Result  ]  Success")

          @helper.addLogs("[Validate] contact:Owner.Id")
          expect(contact[0].fetch('Owner')['Id']).to eq "#{building[0].fetch('Community_Lead__c')}"
          @helper.addLogs("[Result  ]  Success")

          @helper.addLogs("[Validate] contact:Number_of_Full_Time_Employees__c")
          expect(contact[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
          @helper.addLogs("[Result  ]  Success")

          @helper.addLogs("[Validate] contact:Looking_For_Number_Of_Desk__c")
          expect(contact[0].fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
          @helper.addLogs("[Result  ]  Success")

          puts "get Opportunity details"
          opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact[0].fetch('Id')}")
          expect(opportunity[0].size != 0).to eq true
          expect(opportunity[0]).to_not eq nil
          puts opportunity

          @helper.addLogs("[Validate] opportunity:RecordType.Name")
          expect(opportunity[0].fetch('RecordType')['Name']).to eq "Consumer"
          @helper.addLogs("[Result  ]  Success")

          @helper.addLogs("[Validate] opportunity:Deal_Type__c")
          expect(opportunity[0].fetch('Deal_Type__c')).to eq "Transactional"
          @helper.addLogs("[Result  ]  Success")

          @helper.addLogs("[Validate] opportunity:Owner.Id")
          expect(opportunity[0].fetch('Owner')['Id']).to eq "#{building[0].fetch('Community_Lead__c')}"
          @helper.addLogs("[Result  ]  Success")

          @helper.addLogs("[Validate] opportunity:Quantity__c")
          expect(opportunity[0].fetch('Quantity__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
          @helper.addLogs("[Result  ]  Success")

          puts "get Account Details"
          account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact[0].fetch('Id')}")
          expect(account[0].size != 0).to eq true
          expect(account[0]).to_not eq nil
          
          @helper.addLogs("[Validate] account:RecordType.Name")
          expect(account[0].fetch('RecordType')['Name']).to eq "Consumer"
          @helper.addLogs("[Result  ]  Success")

          @helper.addLogs("[Validate] account:Owner.Id")
          expect(account[0].fetch('Owner')['Id']).to eq "#{building[0].fetch('Community_Lead__c')}"
          @helper.addLogs("[Result  ]  Success")

          @helper.addLogs("[Validate] account:Number_of_Full_Time_Employees__c")
          expect(account[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
          @helper.addLogs("[Result  ]  Success")
  
          @helper.addLogs("[Validate] account:Interested_in_Number_of_Desks__c")
          expect(account[0].fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
          @helper.addLogs("[Result  ]  Success")

          @helper.postSuccessResult('2022')
      rescue Exception => e
          @helper.postFailResult(e,'2022')
      end
  end

  it "C2028 : To check account assignment for Record Type Consumer and Deal type Relational.", :'2028'=> 'true' do
      begin
          @helper.addLogs("C2028 : To check account assignment for Record Type Consumer and Deal type Relational.",'2028')
          
          @testDataJSON['AccountAssignment']["GenerateLeadFromWeb"][0]["BuildingName"]  = 'marol'
          @testDataJSON['AccountAssignment']["GenerateLeadFromWeb"][0]["City"]  = 'mumbai'
          @testDataJSON['AccountAssignment']['tour'][0]['companySize']  = '15'
          @testDataJSON['AccountAssignment']['tour'][0]['numberOfDesks']  = '13'
          @testDataJSON['AccountAssignment']['tour'][0]['building']  = 'MUM-BKC'
          
          @helper.addLogs("[Step    ] booking tour from WebSite")
          emailId = @objAccAssignmentFromLead.createLead()
          expect(@driver.title).to match("Coworking Office")

          @helper.addLogs("[Validate]  Lead should be created")
          lead = @objAccAssignmentFromLead.fetchLeadDetails(emailId)
          expect(lead[0]).to_not eq nil
          @helper.addLogs("[Expected]  Lead created successfully with emailId = #{emailId} \n[Result  ]  Success ")

          @helper.addLogs("[Step    ] logging to salesforce")
          @objAccAssignmentFromLead.loginToSalesforce

          @helper.addLogs("[Step    ] go to details page of created lead and Clicking on 'Manage/book Tour' button")
          expect(@objAccAssignmentFromLead.goToDetailPage(lead[0].fetch('Id'))).to eq true


          @helper.addLogs("[Validate] Checking Manage Tour page when user click on 'Manage/book tour' button")
          expect(@driver.title).to match("Manage Tours")
          @helper.addLogs("[Expected] Manage tour page opened successfully with Page Title= Manage Tours \n[Result  ]  Success")

          @helper.addLogs("[Step    ] filling all required fields and booked a tour")

          expect(@objAccAssignmentFromLead.bookTour(0,true)).to eq true

          @helper.addLogs("[Step    ] click on Create Account and Don't Merge")
          @objAccAssignmentFromLead.instance_variable_get(:@wait).until {@driver.find_element(:id ,"header43").displayed?}
          expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Don't Merge",nil)).to eq true

          @helper.addLogs("[Step    ] checking fields...")

          @helper.addLogs("[Step    ] get building details of #{@testDataJSON['AccountAssignment']["tour"][0]["building"]}")
          building = @objAccAssignmentFromLead.fetchBuildingDetails(@testDataJSON['AccountAssignment']["tour"][0]["building"])
          expect(building[0]).to_not eq nil
          
          @helper.addLogs("[Step    ] get Contact details")
          contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
          expect(contact[0]).to_not eq nil
          
          @helper.addLogs("[Validate] contact:RecordType.Name")
          expect(contact[0].fetch('RecordType')['Name']).to eq "Consumer"
          @helper.addLogs("[Result  ]  Success")

          @helper.addLogs("[Validate] contact:Owner.Id")
          puts contact[0].fetch('Owner')['Name']
          puts contact[0].fetch('Owner')['Name'].to_s
          puts building[0].fetch('Cluster_Sales_Lead_Name__c')
          puts building[0].fetch('Cluster_Sales_Lead_Name__c').to_s
          expect(contact[0].fetch('Owner')['Name'].to_s).to eq building[0].fetch('Cluster_Sales_Lead_Name__c').to_s
          @helper.addLogs("[Result  ]  Success")

          @helper.addLogs("[Validate] contact:Number_of_Full_Time_Employees__c")
          expect(contact[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
          @helper.addLogs("[Result  ]  Success")

          @helper.addLogs("[Validate] contact:Looking_For_Number_Of_Desk__c")
          expect(contact[0].fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
          @helper.addLogs("[Result  ]  Success")

          puts "get Opportunity details"
          opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact[0].fetch('Id')}")
          
          @helper.addLogs("[Validate] opportunity:RecordType.Name")
          expect(opportunity[0].fetch('RecordType')['Name']).to eq "Consumer"
          @helper.addLogs("[Result  ]  Success")

          @helper.addLogs("[Validate] opportunity:Deal_Type__c")
          expect(opportunity[0].fetch('Deal_Type__c')).to eq "Relational"
          @helper.addLogs("[Result  ]  Success")

          @helper.addLogs("[Validate] opportunity:Owner.Id")
          expect(opportunity[0].fetch('Owner')['Name']).to eq "#{building[0].fetch('Cluster_Sales_Lead_Name__c')}"
          @helper.addLogs("[Result  ]  Success")

          @helper.addLogs("[Validate] opportunity:Quantity__c")
          expect(opportunity[0].fetch('Quantity__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
          @helper.addLogs("[Result  ]  Success")

          puts "get Account Details"
          account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact[0].fetch('Id')}")
          
          @helper.addLogs("[Validate] account:RecordType.Name")
          expect(account[0].fetch('RecordType')['Name']).to eq "Consumer"
          @helper.addLogs("[Result  ]  Success")

          @helper.addLogs("[Validate] account:Owner.Name")
          expect(account[0].fetch('Owner')['Name']).to eq "#{building[0].fetch('Cluster_Sales_Lead_Name__c')}"
          @helper.addLogs("[Result  ]  Success")

          @helper.addLogs("[Validate] account:Number_of_Full_Time_Employees__c")
          expect(account[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
          @helper.addLogs("[Result  ]  Success")

          @helper.addLogs("[Validate] account:Interested_in_Number_of_Desks__c")
          expect(account[0].fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
          @helper.addLogs("[Result  ]  Success")

          @helper.postSuccessResult('2028')
      rescue Exception => e
          @helper.postFailResult(e,'2028')
      end
  end

  it "C2040 : To check account assignment for Record Type Consumer and Deal type Strategic.", :'2040'=> 'true' do
    begin
      @helper.addLogs("C2040 : To check account assignment for Record Type Consumer and Deal type Strategic.",'2040')

      @testDataJSON['AccountAssignment']["GenerateLeadFromWeb"][0]["BuildingName"]  = 'marol'
      @testDataJSON['AccountAssignment']["GenerateLeadFromWeb"][0]["City"]  = 'mumbai'
      @testDataJSON['AccountAssignment']['tour'][0]['companySize']  = '15'
      @testDataJSON['AccountAssignment']['tour'][0]['numberOfDesks']  = '25'
      @testDataJSON['AccountAssignment']['tour'][0]['building']  = 'MUM-BKC'

      @helper.addLogs("[Step    ] booking tour from WebSite")
      emailId = @objAccAssignmentFromLead.createLead()
      expect(@driver.title).to match("Coworking Office")  # Sambhav BKC | WeWork")

      @helper.addLogs("[Validate]  Lead should be created")
      lead = @objAccAssignmentFromLead.fetchLeadDetails(emailId)
      expect(lead[0]).to_not eq nil
      @helper.addLogs("[Expected]  Lead created successfully with emailId = #{emailId} \n[Result  ]  Success ")

      @helper.addLogs("[Step    ] logging to salesforce")
      @objAccAssignmentFromLead.loginToSalesforce

      @helper.addLogs("[Step    ] go to details page of created lead and Clicking on 'Manage/book Tour' button")
      expect(@objAccAssignmentFromLead.goToDetailPage(lead[0].fetch('Id'))).to eq true


      @helper.addLogs("[Validate] Checking Manage Tour page when user click on 'Manage/book tour' button")
      expect(@driver.title).to match("Manage Tours")
      @helper.addLogs("[Expected] Manage tour page opened successfully with Page Title= Manage Tours \n[Result  ]  Success")

      @helper.addLogs("[Step    ] filling all required fields and booked a tour")

      expect(@objAccAssignmentFromLead.bookTour(0,true)).to eq true

      @helper.addLogs("[Step    ] click on Create Account and Don't Merge")
      @objAccAssignmentFromLead.instance_variable_get(:@wait).until {@driver.find_element(:id ,"header43").displayed?}
      expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Don't Merge",nil)).to eq true

      @helper.addLogs("[Step    ] checking fields...")

      @helper.addLogs("[Step    ] get building details of #{@testDataJSON['AccountAssignment']["tour"][0]["building"]}")
      building = @objAccAssignmentFromLead.fetchBuildingDetails(@testDataJSON['AccountAssignment']["tour"][0]["building"])
      expect(building[0]).to_not eq nil
      
      @helper.addLogs("[Step    ] get accQueue details")
      accQueue = @objAccAssignmentFromLead.fetAccOwnerQueue(building[0].fetch('Market__c'),'Consumer')

      @helper.addLogs("[Step    ] get Contact details")
      contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
      expect(contact[0]).to_not eq nil
      
      @helper.addLogs("[Validate] contact:RecordType.Name")
      expect(contact[0].fetch('RecordType')['Name']).to eq "Consumer"
      @helper.addLogs("[Result  ]  Success")

      @helper.addLogs("[Validate] contact:Owner.Id")
      ownerAssign = accQueue.include? contact[0].fetch('Owner')['Id']
      expect(ownerAssign).to eq true
      #expect(contact[0].fetch('Owner')['Id']).to eq "#{accQueue.fetch('Member__c')}"
      @helper.addLogs("[Result  ]  Success")

      @helper.addLogs("[Validate] contact:Number_of_Full_Time_Employees__c")
      expect(contact[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
      @helper.addLogs("[Result  ]  Success")

      @helper.addLogs("[Validate] contact:Looking_For_Number_Of_Desk__c")
      expect(contact[0].fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
      @helper.addLogs("[Result  ]  Success")

      puts "get Opportunity details"
      opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact[0].fetch('Id')}")
      expect(opportunity[0]).to_not eq nil
      
      @helper.addLogs("[Validate] opportunity:RecordType.Name")
      expect(opportunity[0].fetch('RecordType')['Name']).to eq "Consumer"
      @helper.addLogs("[Result  ]  Success")

      @helper.addLogs("[Validate] opportunity:Deal_Type__c")
      expect(opportunity[0].fetch('Deal_Type__c')).to eq "Strategic"
      @helper.addLogs("[Result  ]  Success")

      @helper.addLogs("[Validate] opportunity:Owner.Id")
      puts opportunity[0].fetch('Owner')['Id']
      ownerAssign = accQueue.include? opportunity[0].fetch('Owner')['Id']
      expect(ownerAssign).to eq true
      #expect(opportunity[0].fetch('Owner')['Id']).to eq "#{accQueue.fetch('Member__c')}"
      @helper.addLogs("[Result  ]  Success")

      @helper.addLogs("[Validate] opportunity:Quantity__c")
      expect(opportunity[0].fetch('Quantity__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
      @helper.addLogs("[Result  ]  Success")

      puts "get Account Details"
      account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact[0].fetch('Id')}")
      expect(account[0]).to_not eq nil
      
      @helper.addLogs("[Validate] account:RecordType.Name")
      expect(account[0].fetch('RecordType')['Name']).to eq "Consumer"
      @helper.addLogs("[Result  ]  Success")

      @helper.addLogs("[Validate] account:Owner.Name")
      ownerAssign = accQueue.include? account[0].fetch('Owner')['Id']
      expect(ownerAssign).to eq true

      #expect(account[0].fetch('Owner')['Id']).to eq "#{accQueue.fetch('Member__c')}"
      @helper.addLogs("[Result  ]  Success")

      @helper.addLogs("[Validate] account:Number_of_Full_Time_Employees__c")
      expect(account[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
      @helper.addLogs("[Result  ]  Success")

      @helper.addLogs("[Validate] account:Interested_in_Number_of_Desks__c")
      expect(account[0].fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
      @helper.addLogs("[Result  ]  Success")

      @helper.postSuccessResult('2040')
    rescue Exception => e
      raise e
      @helper.postFailResult(e,'2040')
    end
  end

  it "C2041 : To check account assignment for Record Type Consumer and Deal type Relational.", :'2041'=> 'true'  do
    begin
      @helper.addLogs("C2041 : To check account assignment for Record Type Consumer and Deal type Strategic.(Queue is not present in the Account Queue Setting).",'2041')

      @testDataJSON['AccountAssignment']["GenerateLeadFromWeb"][0]["BuildingName"]  = 'marol'
      @testDataJSON['AccountAssignment']["GenerateLeadFromWeb"][0]["City"]  = 'mumbai'
      @testDataJSON['AccountAssignment']['tour'][0]['companySize']  = '15'
      @testDataJSON['AccountAssignment']['tour'][0]['numberOfDesks']  = '25'      
      @testDataJSON['AccountAssignment']['tour'][0]['building']  = 'SYD-Martin Place'

      #puts caseInfo
      @helper.addLogs("[Step    ] booking tour from WebSite")
      emailId = @objAccAssignmentFromLead.createLead()
      #expect(@driver.title).to match("Coworking Office Sambhav BKC | WeWork")

      sleep (10)
      @helper.addLogs("[Validate]  Lead should be created")
      lead = @objAccAssignmentFromLead.fetchLeadDetails(emailId)
      expect(lead[0]).to_not eq 'nil'

      @helper.addLogs("[Expected]  Lead created successfully with emailId = #{emailId} \n[Result  ]  Success ")

      @helper.addLogs("[Step    ] logging to salesforce")
      @objAccAssignmentFromLead.loginToSalesforce

      @helper.addLogs("[Step    ] go to details page of created lead and Clicking on 'Manage/book Tour' button")
      expect(@objAccAssignmentFromLead.goToDetailPage(lead[0].fetch('Id'))).to eq true


      @helper.addLogs("[Validate] Checking Manage Tour page when user click on 'Manage/book tour' button")
      expect(@driver.title).to match("Manage Tours")
      @helper.addLogs("[Expected] Manage tour page opened successfully with Page Title= Manage Tours \n[Result  ]  Success")

      @helper.addLogs("[Step    ] filling all required fields and booked a tour")
      

      expect(@objAccAssignmentFromLead.bookTour(0,true)).to eq true

      @helper.addLogs("[Step    ] click on Create Account and Don't Merge")
      @objAccAssignmentFromLead.instance_variable_get(:@wait).until {@driver.find_element(:id ,"header43").displayed?}
      expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Don't Merge",nil)).to eq true

      @helper.addLogs("[Step    ] checking fields...")

      @helper.addLogs("[Step    ] get building details of #{@testDataJSON['AccountAssignment']["tour"][0]["building"]}")
      building = @objAccAssignmentFromLead.fetchBuildingDetails(@testDataJSON['AccountAssignment']["tour"][0]["building"])
      expect(building[0]).to_not eq nil
      
      #@helper.addLogs("[Step    ] get accQueue details")
      #accQueue = @objAccAssignmentFromLead.fetAccOwnerQueue(building[0].fetch('Market__c'),'Consumer')

      @helper.addLogs("[Step    ] get Contact details")
      contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
      expect(contact[0]).to_not eq nil
      
      @helper.addLogs("[Validate] contact:RecordType.Name")
      expect(contact[0].fetch('RecordType')['Name']).to eq "Consumer"
      @helper.addLogs("[Result  ]  Success")

      @helper.addLogs("[Validate] contact:Owner.Id")
      expect(contact[0].fetch('Owner')['Id']).to eq "005F0000003KmbwIAC"
      @helper.addLogs("[Result  ]  Success")

      @helper.addLogs("[Validate] contact:Number_of_Full_Time_Employees__c")
      expect(contact[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
      @helper.addLogs("[Result  ]  Success")

      @helper.addLogs("[Validate] contact:Looking_For_Number_Of_Desk__c")
      expect(contact[0].fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
      @helper.addLogs("[Result  ]  Success")

      puts "get Opportunity details"
      opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact[0].fetch('Id')}")
      expect(opportunity[0]).to_not eq nil
      
      @helper.addLogs("[Validate] opportunity:RecordType.Name")
      expect(opportunity[0].fetch('RecordType')['Name']).to eq "Consumer"
      @helper.addLogs("[Result  ]  Success")

      @helper.addLogs("[Validate] opportunity:Deal_Type__c")
      expect(opportunity[0].fetch('Deal_Type__c')).to eq "Strategic"
      @helper.addLogs("[Result  ]  Success")

      @helper.addLogs("[Validate] opportunity:Owner.Id")
      expect(opportunity[0].fetch('Owner')['Id']).to eq "005F0000003KmbwIAC"
      @helper.addLogs("[Result  ]  Success")

      @helper.addLogs("[Validate] opportunity:Quantity__c")
      expect(opportunity[0].fetch('Quantity__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
      @helper.addLogs("[Result  ]  Success")

      puts "get Account Details"
      account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact[0].fetch('Id')}")
      expect(account[0]).to_not eq nil
      
      @helper.addLogs("[Validate] account:RecordType.Name")
      expect(account[0].fetch('RecordType')['Name']).to eq "Consumer"
      @helper.addLogs("[Result  ]  Success")

      @helper.addLogs("[Validate] account:Owner.Name")
      expect(account[0].fetch('Owner')['Id']).to eq "005F0000003KmbwIAC"
      @helper.addLogs("[Result  ]  Success")

      @helper.addLogs("[Validate] account:Number_of_Full_Time_Employees__c")
      expect(account[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
      @helper.addLogs("[Result  ]  Success")

      @helper.addLogs("[Validate] account:Interested_in_Number_of_Desks__c")
      expect(account[0].fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
      @helper.addLogs("[Result  ]  Success")

    @helper.postSuccessResult('2041')
    rescue Exception => e
      raise e
      @helper.postFailResult(e,'2041')
    end

  end

  it "C2042 : To Check Account assignment for Record Type Mid-Market and Deal type Transactional.", :'2042'=> 'true' do
    begin
      @helper.addLogs("C2042 : To Check Account assignment for Record Type Mid-Market and Deal type Transactional.",'2042')
      @testDataJSON['AccountAssignment']['tour'][0]['building']  = 'SYD-Martin Place'
      @testDataJSON['AccountAssignment']['tour'][0]['companySize']  = '24'
      @testDataJSON['AccountAssignment']['tour'][0]['numberOfDesks']  = '7'

      #puts caseInfo
      @helper.addLogs("[Step    ] booking tour from WebSite")
      emailId = @objAccAssignmentFromLead.createLead()
      #expect(@driver.title).to match("Coworking Office Sambhav BKC | WeWork")

      @helper.addLogs("[Validate]  Lead should be created")
      lead = @objAccAssignmentFromLead.fetchLeadDetails(emailId)
      expect(lead[0]).to_not eq nil
      @helper.addLogs("[Expected]  Lead created successfully with emailId = #{emailId} \n[Result  ]  Success ")

      @helper.addLogs("[Step    ] logging to salesforce")
      @objAccAssignmentFromLead.loginToSalesforce

      @helper.addLogs("[Step    ] go to details page of created lead and Clicking on 'Manage/book Tour' button")
      expect(@objAccAssignmentFromLead.goToDetailPage(lead[0].fetch('Id'))).to eq true

      @helper.addLogs("[Validate] Checking Manage Tour page when user click on 'Manage/book tour' button")
      expect(@driver.title).to match("Manage Tours")
      @helper.addLogs("[Expected] Manage tour page opened successfully with Page Title= Manage Tours \n[Result  ]  Success")

      @helper.addLogs("[Step    ] filling all required fields and booked a tour")

      expect(@objAccAssignmentFromLead.bookTour(0,true)).to eq true

      @helper.addLogs("[Step    ] click on Create Account and Don't Merge")
      @objAccAssignmentFromLead.instance_variable_get(:@wait).until {@driver.find_element(:id ,"header43").displayed?}
      expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Don't Merge",nil)).to eq true

      @helper.addLogs("[Step    ] checking fields...")

      @helper.addLogs("[Step    ] get building details of #{@testDataJSON['AccountAssignment']["tour"][0]["building"]}")
      building = @objAccAssignmentFromLead.fetchBuildingDetails(@testDataJSON['AccountAssignment']["tour"][0]["building"])
      expect(building[0]).to_not eq nil
      
      @helper.addLogs("[Step    ] get Contact details")
      contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
      expect(contact[0]).to_not eq nil
      
      @helper.addLogs("[Validate] contact:RecordType.Name")
      expect(contact[0].fetch('RecordType')['Name']).to eq "Mid Market"
      @helper.addLogs("[Result  ]  Success")

      @helper.addLogs("[Validate] contact:Owner.Id")
      expect(contact[0].fetch('Owner')['Id']).to eq "#{building[0].fetch('Community_Lead__c')}"
      @helper.addLogs("[Result  ]  Success")

      @helper.addLogs("[Validate] contact:Number_of_Full_Time_Employees__c")
      expect(contact[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
      @helper.addLogs("[Result  ]  Success")

      @helper.addLogs("[Validate] contact:Looking_For_Number_Of_Desk__c")
      expect(contact[0].fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
      @helper.addLogs("[Result  ]  Success")

      puts "get Opportunity details"
      opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact[0].fetch('Id')}")
      expect(opportunity[0]).to_not eq nil
      
      @helper.addLogs("[Validate] opportunity:RecordType.Name")
      expect(opportunity[0].fetch('RecordType')['Name']).to eq "Mid Market"
      @helper.addLogs("[Result  ]  Success")

      @helper.addLogs("[Validate] opportunity:Deal_Type__c")
      expect(opportunity[0].fetch('Deal_Type__c')).to eq "Transactional"
      @helper.addLogs("[Result  ]  Success")

      @helper.addLogs("[Validate] opportunity:Owner.Id")
      expect(opportunity[0].fetch('Owner')['Id']).to eq "#{building[0].fetch('Community_Lead__c')}"
      @helper.addLogs("[Result  ]  Success")

      @helper.addLogs("[Validate] opportunity:Quantity__c")
      expect(opportunity[0].fetch('Quantity__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
      @helper.addLogs("[Result  ]  Success")

      puts "get Account Details"
      account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact[0].fetch('Id')}")
      expect(account[0]).to_not eq nil
      
      @helper.addLogs("[Validate] account:RecordType.Name")
      expect(account[0].fetch('RecordType')['Name']).to eq "Mid Market"
      @helper.addLogs("[Result  ]  Success")

      @helper.addLogs("[Validate] account:Owner.Id")
      expect(account[0].fetch('Owner')['Id']).to eq "#{building[0].fetch('Community_Lead__c')}"
      @helper.addLogs("[Result  ]  Success")

      @helper.addLogs("[Validate] account:Number_of_Full_Time_Employees__c")
      expect(account[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
      @helper.addLogs("[Result  ]  Success")

      @helper.addLogs("[Validate] account:Interested_in_Number_of_Desks__c")
      expect(account[0].fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
      @helper.addLogs("[Result  ]  Success")

    @helper.postSuccessResult('2042')
    rescue Exception => e
      raise e
      @helper.postFailResult(e,'2042')
    end

  end

  it "C2043 : To Check Account Assignment for Record type Mid-Market and Deal type Relational.", :'2043'=> 'true' do
    begin
      @helper.addLogs("C2043 : To Check Account Assignment for Record type Mid-Market and Deal type Relational.",'2043')
      
      @testDataJSON['AccountAssignment']['tour'][0]['building']  = 'SYD-Martin Place'
      @testDataJSON['AccountAssignment']['tour'][0]['companySize']  = '24'
      @testDataJSON['AccountAssignment']['tour'][0]['numberOfDesks']  = '15'

      @helper.addLogs("[Step    ] booking tour from WebSite")
      emailId = @objAccAssignmentFromLead.createLead()
      expect(@driver.title).to match("Coworking Office")# Sambhav BKC | WeWork")

      @helper.addLogs("[Validate]  Lead should be created")
      lead = @objAccAssignmentFromLead.fetchLeadDetails(emailId)
      expect(lead[0]).to_not eq nil
      @helper.addLogs("[Expected]  Lead created successfully with emailId = #{emailId} \n[Result  ]  Success ")

      @helper.addLogs("[Step    ] logging to salesforce")
      @objAccAssignmentFromLead.loginToSalesforce

      @helper.addLogs("[Step    ] go to details page of created lead and Clicking on 'Manage/book Tour' button")
      expect(@objAccAssignmentFromLead.goToDetailPage(lead[0].fetch('Id'))).to eq true

      @helper.addLogs("[Validate] Checking Manage Tour page when user click on 'Manage/book tour' button")
      expect(@driver.title).to match("Manage Tours")
      @helper.addLogs("[Expected] Manage tour page opened successfully with Page Title= Manage Tours \n[Result  ]  Success")

      @helper.addLogs("[Step    ] filling all required fields and booked a tour")
      expect(@objAccAssignmentFromLead.bookTour(0,true)).to eq true

      @helper.addLogs("[Step    ] click on Create Account and Don't Merge")
      @objAccAssignmentFromLead.instance_variable_get(:@wait).until {@driver.find_element(:id ,"header43").displayed?}
      expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Don't Merge",nil)).to eq true

      @helper.addLogs("[Step    ] checking fields...")

      @helper.addLogs("[Step    ] get building details of #{@testDataJSON['AccountAssignment']["tour"][0]["building"]}")
      building = @objAccAssignmentFromLead.fetchBuildingDetails(@testDataJSON['AccountAssignment']["tour"][0]["building"])
      expect(building[0]).to_not eq nil
      
      @helper.addLogs("[Step    ] get Contact details")
      contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
      expect(contact[0]).to_not eq nil
      
      @helper.addLogs("[Validate] contact:RecordType.Name")
      expect(contact[0].fetch('RecordType')['Name']).to eq "Mid Market"
      @helper.addLogs("[Result  ]  Success")

      @helper.addLogs("[Validate] contact:Owner.Id")
      expect(contact[0].fetch('Owner')['Name']).to eq "#{building[0].fetch('Cluster_Sales_Lead_Name__c')}"
      @helper.addLogs("[Result  ]  Success")

      @helper.addLogs("[Validate] contact:Number_of_Full_Time_Employees__c")
      expect(contact[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
      @helper.addLogs("[Result  ]  Success")

      @helper.addLogs("[Validate] contact:Looking_For_Number_Of_Desk__c")
      expect(contact[0].fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
      @helper.addLogs("[Result  ]  Success")

      puts "get Opportunity details"
      opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact[0].fetch('Id')}")
      expect(opportunity[0]).to_not eq nil
      
      @helper.addLogs("[Validate] opportunity:RecordType.Name")
      expect(opportunity[0].fetch('RecordType')['Name']).to eq "Mid Market"
      @helper.addLogs("[Result  ]  Success")

      @helper.addLogs("[Validate] opportunity:Deal_Type__c")
      expect(opportunity[0].fetch('Deal_Type__c')).to eq "Relational"
      @helper.addLogs("[Result  ]  Success")

      @helper.addLogs("[Validate] opportunity:Owner.Id")
      expect(opportunity[0].fetch('Owner')['Name']).to eq "#{building[0].fetch('Cluster_Sales_Lead_Name__c')}"
      @helper.addLogs("[Result  ]  Success")

      @helper.addLogs("[Validate] opportunity:Quantity__c")
      expect(opportunity[0].fetch('Quantity__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
      @helper.addLogs("[Result  ]  Success")

      puts "get Account Details"
      account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact[0].fetch('Id')}")
      expect(account[0]).to_not eq nil
      
      @helper.addLogs("[Validate] account:RecordType.Name")
      expect(account[0].fetch('RecordType')['Name']).to eq "Mid Market"
      @helper.addLogs("[Result  ]  Success")

      @helper.addLogs("[Validate] account:Owner.Name")
      expect(account[0].fetch('Owner')['Name']).to eq "#{building[0].fetch('Cluster_Sales_Lead_Name__c')}"
      @helper.addLogs("[Result  ]  Success")

      @helper.addLogs("[Validate] account:Number_of_Full_Time_Employees__c")
      expect(account[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
      @helper.addLogs("[Result  ]  Success")

      @helper.addLogs("[Validate] account:Interested_in_Number_of_Desks__c")
      expect(account[0].fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
      @helper.addLogs("[Result  ]  Success")

    @helper.postSuccessResult('2043')
    rescue Exception => e
      raise e
      @helper.postFailResult(e,'2043')
    end

  end

  it "C2044 : To Check Account Assignment from Record type Mid-Market and Deal Type Strategic.", :'2044'=> 'true' do
    begin
      @helper.addLogs("C2044 : To check account assignment for Record Type Consumer and Deal type Relational.",'2044')

      @testDataJSON['AccountAssignment']['tour'][0]['building']  = 'SYD-Martin Place'
      @testDataJSON['AccountAssignment']['tour'][0]['companySize']  = '24'
      @testDataJSON['AccountAssignment']['tour'][0]['numberOfDesks']  = '27'

      
      #puts caseInfo
      @helper.addLogs("[Step    ] booking tour from WebSite")
      emailId = @objAccAssignmentFromLead.createLead()
      expect(@driver.title).to match("Coworking Office")# Sambhav BKC | WeWork")

      @helper.addLogs("[Validate]  Lead should be created")
      lead = @objAccAssignmentFromLead.fetchLeadDetails(emailId)
      expect(lead[0]).to_not eq nil
      @helper.addLogs("[Expected]  Lead created successfully with emailId = #{emailId} \n[Result  ]  Success ")

      @helper.addLogs("[Step    ] logging to salesforce")
      @objAccAssignmentFromLead.loginToSalesforce

      @helper.addLogs("[Step    ] go to details page of created lead and Clicking on 'Manage/book Tour' button")
      expect(@objAccAssignmentFromLead.goToDetailPage(lead[0].fetch('Id'))).to eq true


      @helper.addLogs("[Validate] Checking Manage Tour page when user click on 'Manage/book tour' button")
      expect(@driver.title).to match("Manage Tours")
      @helper.addLogs("[Expected] Manage tour page opened successfully with Page Title= Manage Tours \n[Result  ]  Success")

      @helper.addLogs("[Step    ] filling all required fields and booked a tour")

      expect(@objAccAssignmentFromLead.bookTour(0,true)).to eq true

      @helper.addLogs("[Step    ] click on Create Account and Don't Merge")
      @objAccAssignmentFromLead.instance_variable_get(:@wait).until {@driver.find_element(:id ,"header43").displayed?}
      expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Don't Merge",nil)).to eq true

      @helper.addLogs("[Step    ] checking fields...")

      @helper.addLogs("[Step    ] get building details of #{@testDataJSON['AccountAssignment']["tour"][0]["building"]}")
      building = @objAccAssignmentFromLead.fetchBuildingDetails(@testDataJSON['AccountAssignment']["tour"][0]["building"])
      expect(building[0]).to_not eq nil
      
      @helper.addLogs("[Step    ] get accQueue details")

      accQueue = @objAccAssignmentFromLead.fetAccOwnerQueue(building[0].fetch('Market__c'),'Mid Market')

      @helper.addLogs("[Step    ] get Contact details")
      contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
      expect(contact[0]).to_not eq nil
      
      @helper.addLogs("[Validate] contact:RecordType.Name")
      expect(contact[0].fetch('RecordType')['Name']).to eq "Mid Market"
      @helper.addLogs("[Result  ]  Success")

      @helper.addLogs("[Validate] contact:Owner.Id")

      puts accQueue.include? contact[0].fetch('Owner')['Id']
      ownerAssign = accQueue.include? contact[0].fetch('Owner')['Id']
      expect(ownerAssign).to eq true

      #expect(contact[0].fetch('Owner')['Id']).to eq "#{accQueue.fetch('Member__c')}"
      @helper.addLogs("[Result  ]  Success")

      @helper.addLogs("[Validate] contact:Number_of_Full_Time_Employees__c")
      expect(contact[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
      @helper.addLogs("[Result  ]  Success")

      @helper.addLogs("[Validate] contact:Looking_For_Number_Of_Desk__c")
      expect(contact[0].fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
      @helper.addLogs("[Result  ]  Success")

      puts "get Opportunity details"
      opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact[0].fetch('Id')}")
      expect(opportunity[0]).to_not eq nil
      
      @helper.addLogs("[Validate] opportunity:RecordType.Name")
      expect(opportunity[0].fetch('RecordType')['Name']).to eq "Mid Market"
      @helper.addLogs("[Result  ]  Success")

      @helper.addLogs("[Validate] opportunity:Deal_Type__c")
      expect(opportunity[0].fetch('Deal_Type__c')).to eq "Strategic"
      @helper.addLogs("[Result  ]  Success")

      @helper.addLogs("[Validate] opportunity:Owner.Id")
      ownerAssign = accQueue.include? opportunity[0].fetch('Owner')['Id']
      expect(ownerAssign).to eq true

      #expect(opportunity[0].fetch('Owner')['Id']).to eq "#{accQueue.fetch('Member__c')}"
      @helper.addLogs("[Result  ]  Success")

      @helper.addLogs("[Validate] opportunity:Quantity__c")
      expect(opportunity[0].fetch('Quantity__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
      @helper.addLogs("[Result  ]  Success")

      puts "get Account Details"
      account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact[0].fetch('Id')}")
      expect(account[0]).to_not eq nil
      
      @helper.addLogs("[Validate] account:RecordType.Name")
      expect(account[0].fetch('RecordType')['Name']).to eq "Mid Market"
      @helper.addLogs("[Result  ]  Success")

      @helper.addLogs("[Validate] account:Owner.Name")
      ownerAssign = accQueue.include? account[0].fetch('Owner')['Id']
      expect(ownerAssign).to eq true
      #expect(account[0].fetch('Owner')['Id']).to eq "#{accQueue.fetch('Member__c')}"
      @helper.addLogs("[Result  ]  Success")

      @helper.addLogs("[Validate] account:Number_of_Full_Time_Employees__c")
      expect(account[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
      @helper.addLogs("[Result  ]  Success")

      @helper.addLogs("[Validate] account:Interested_in_Number_of_Desks__c")
      expect(account[0].fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
      @helper.addLogs("[Result  ]  Success")

    @helper.postSuccessResult('2044')
    rescue Exception => e
      raise e
      @helper.postFailResult(e,'2044')
    end

  end

  it "C2045 : To Check Account Assignment for Record Type Enterprise and Deal type Transactional.", :'2045'=> 'true' do
    begin
      @helper.addLogs("C2045 : To Check Account Assignment for Record Type Enterprise and Deal type Transactional.",'2045')

      @testDataJSON['AccountAssignment']['tour'][0]['building']  = 'MEL-Bourke Street'
      @testDataJSON['AccountAssignment']['tour'][0]['companySize']  = '1200'
      @testDataJSON['AccountAssignment']['tour'][0]['numberOfDesks']  = '7'

      @helper.addLogs("[Step    ] booking tour from WebSite")
      emailId = @objAccAssignmentFromLead.createLead()
      expect(@driver.title).to match("Coworking Office")# Sambhav BKC | WeWork")

      @helper.addLogs("[Validate]  Lead should be created")
      lead = @objAccAssignmentFromLead.fetchLeadDetails(emailId)
      expect(lead[0]).to_not eq nil
      @helper.addLogs("[Expected]  Lead created successfully with emailId = #{emailId} \n[Result  ]  Success ")

      @helper.addLogs("[Step    ] logging to salesforce")
      @objAccAssignmentFromLead.loginToSalesforce

      @helper.addLogs("[Step    ] go to details page of created lead and Clicking on 'Manage/book Tour' button")
      expect(@objAccAssignmentFromLead.goToDetailPage(lead[0].fetch('Id'))).to eq true

      @helper.addLogs("[Validate] Checking Manage Tour page when user click on 'Manage/book tour' button")
      expect(@driver.title).to match("Manage Tours")
      @helper.addLogs("[Expected] Manage tour page opened successfully with Page Title= Manage Tours \n[Result  ]  Success")

      @helper.addLogs("[Step    ] filling all required fields and booked a tour")

      expect(@objAccAssignmentFromLead.bookTour(0,true)).to eq true

      @helper.addLogs("[Step    ] click on Create Account and Don't Merge")
      @objAccAssignmentFromLead.instance_variable_get(:@wait).until {@driver.find_element(:id ,"header43").displayed?}
      expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Don't Merge",nil)).to eq true

      @helper.addLogs("[Step    ] checking fields...")

      @helper.addLogs("[Step    ] get building details of #{@testDataJSON['AccountAssignment']["tour"][0]["building"]}")
      building = @objAccAssignmentFromLead.fetchBuildingDetails(@testDataJSON['AccountAssignment']["tour"][0]["building"])
      expect(building[0]).to_not eq nil
      
      @helper.addLogs("[Step    ] get accQueue details")
      accQueue = @objAccAssignmentFromLead.fetAccOwnerQueue(building[0].fetch('Market__c'),'Enterprise Solutions')

      @helper.addLogs("[Step    ] get Contact details")
      contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
      expect(contact[0]).to_not eq nil
      
      @helper.addLogs("[Validate] contact:RecordType.Name")
      expect(contact[0].fetch('RecordType')['Name']).to eq "Enterprise Solutions"
      @helper.addLogs("[Result  ]  Success")

      @helper.addLogs("[Validate] contact:Owner.Id")

      ownerAssign = accQueue.include? contact[0].fetch('Owner')['Id']
      expect(ownerAssign).to eq true
      #expect(contact[0].fetch('Owner')['Id']).to eq "#{accQueue.fetch('Member__c')}"
      @helper.addLogs("[Result  ]  Success")

      @helper.addLogs("[Validate] contact:Number_of_Full_Time_Employees__c")
      expect(contact[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
      @helper.addLogs("[Result  ]  Success")

      @helper.addLogs("[Validate] contact:Looking_For_Number_Of_Desk__c")
      expect(contact[0].fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
      @helper.addLogs("[Result  ]  Success")

      puts "get Opportunity details"
      opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact[0].fetch('Id')}")
      expect(opportunity[0]).to_not eq nil
      
      @helper.addLogs("[Validate] opportunity:RecordType.Name")
      expect(opportunity[0].fetch('RecordType')['Name']).to eq "Enterprise Solutions"
      @helper.addLogs("[Result  ]  Success")

      @helper.addLogs("[Validate] opportunity:Deal_Type__c")
      expect(opportunity[0].fetch('Deal_Type__c')).to eq "Transactional"
      @helper.addLogs("[Result  ]  Success")

      @helper.addLogs("[Validate] opportunity:Owner.Id")
      ownerAssign = accQueue.include? opportunity[0].fetch('Owner')['Id']
      expect(ownerAssign).to eq true
      #expect(opportunity[0].fetch('Owner')['Id']).to eq "#{accQueue.fetch('Member__c')}"
      @helper.addLogs("[Result  ]  Success")

      @helper.addLogs("[Validate] opportunity:Quantity__c")
      expect(opportunity[0].fetch('Quantity__c').to_i).to eq @testDataJSON['AccountAssignment']['tour'][0]['numberOfDesks'].to_i
      @helper.addLogs("[Result  ]  Success")

      puts "get Account Details"
      account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact[0].fetch('Id')}")
      expect(account[0]).to_not eq nil
      
      @helper.addLogs("[Validate] account:RecordType.Name")
      expect(account[0].fetch('RecordType')['Name']).to eq "Enterprise Solutions"
      @helper.addLogs("[Result  ]  Success")

      @helper.addLogs("[Validate] account:Owner.Name")
      ownerAssign = accQueue.include? account[0].fetch('Owner')['Id']
      expect(ownerAssign).to eq true

      #expect(account[0].fetch('Owner')['Id']).to eq "#{accQueue.fetch('Member__c')}"
      @helper.addLogs("[Result  ]  Success")

      @helper.addLogs("[Validate] account:Number_of_Full_Time_Employees__c")
      expect(account[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
      @helper.addLogs("[Result  ]  Success")

      @helper.addLogs("[Validate] account:Interested_in_Number_of_Desks__c")
      expect(account[0].fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
      @helper.addLogs("[Result  ]  Success")

    @helper.postSuccessResult('2045')
    rescue Exception => e
      raise e
      @helper.postFailResult(e,'2045')
    end

  end

  it "C2046 : To Check Account Assignment for Record Type Enterprise and Deal type Relational.", :'2046'=> 'true' do
    begin
      @helper.addLogs("C2046 : To Check Account Assignment for Record Type Enterprise and Deal type Relational.",'2046')
      @testDataJSON['AccountAssignment']['tour'][0]['building']  = 'SYD-Martin Place'
      @testDataJSON['AccountAssignment']['tour'][0]['companySize']  = '1200'
      @testDataJSON['AccountAssignment']['tour'][0]['numberOfDesks']  = '15'
     
      #puts caseInfo
      @helper.addLogs("[Step    ] booking tour from WebSite")
      emailId = @objAccAssignmentFromLead.createLead()
      expect(@driver.title).to match("Coworking Office")# Sambhav BKC | WeWork")

      @helper.addLogs("[Validate]  Lead should be created")
      lead = @objAccAssignmentFromLead.fetchLeadDetails(emailId)
      expect(lead[0]).to_not eq nil
      @helper.addLogs("[Expected]  Lead created successfully with emailId = #{emailId} \n[Result  ]  Success ")

      @helper.addLogs("[Step    ] logging to salesforce")
      @objAccAssignmentFromLead.loginToSalesforce

      @helper.addLogs("[Step    ] go to details page of created lead and Clicking on 'Manage/book Tour' button")
      expect(@objAccAssignmentFromLead.goToDetailPage(lead[0].fetch('Id'))).to eq true


      @helper.addLogs("[Validate] Checking Manage Tour page when user click on 'Manage/book tour' button")
      expect(@driver.title).to match("Manage Tours")
      @helper.addLogs("[Expected] Manage tour page opened successfully with Page Title= Manage Tours \n[Result  ]  Success")

      @helper.addLogs("[Step    ] filling all required fields and booked a tour")

      expect(@objAccAssignmentFromLead.bookTour(0,true)).to eq true

      @helper.addLogs("[Step    ] click on Create Account and Don't Merge")
      @objAccAssignmentFromLead.instance_variable_get(:@wait).until {@driver.find_element(:id ,"header43").displayed?}
      expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Don't Merge",nil)).to eq true

      @helper.addLogs("[Step    ] checking fields...")

      @helper.addLogs("[Step    ] get building details of #{@testDataJSON['AccountAssignment']["tour"][0]["building"]}")
      building = @objAccAssignmentFromLead.fetchBuildingDetails(@testDataJSON['AccountAssignment']["tour"][0]["building"])
      expect(building[0]).to_not eq nil
      
      @helper.addLogs("[Step    ] get accQueue details")
      accQueue = @objAccAssignmentFromLead.fetAccOwnerQueue(building[0].fetch('Market__c'),'Enterprise Solutions')

      #accQueue = @objAccAssignmentFromLead.fetAccOwnerQueue('a2V0G000003H8zoUAC','Enterprise Solutions')

      @helper.addLogs("[Step    ] get Contact details")
      contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
      #contact = @objAccAssignmentFromLead.fetchContactDetails("john.smith1004201828@example.com")
      expect(contact[0]).to_not eq nil
      
      @helper.addLogs("[Validate] contact:RecordType.Name")
      expect(contact[0].fetch('RecordType')['Name']).to eq "Enterprise Solutions"
      @helper.addLogs("[Result  ]  Success")

      @helper.addLogs("[Validate] contact:Owner.Id")
      puts accQueue.include? contact[0].fetch('Owner')['Id']
      ownerAssign = accQueue.include? contact[0].fetch('Owner')['Id']
      expect(ownerAssign).to eq true
      @helper.addLogs("[Result  ]  Success")

      @helper.addLogs("[Validate] contact:Number_of_Full_Time_Employees__c")
      expect(contact[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
      @helper.addLogs("[Result  ]  Success")

      @helper.addLogs("[Validate] contact:Looking_For_Number_Of_Desk__c")
      expect(contact[0].fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
      @helper.addLogs("[Result  ]  Success")

      puts "get Opportunity details"
      opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact[0].fetch('Id')}")
      expect(opportunity[0]).to_not eq nil
      
      @helper.addLogs("[Validate] opportunity:RecordType.Name")
      expect(opportunity[0].fetch('RecordType')['Name']).to eq "Enterprise Solutions"
      @helper.addLogs("[Result  ]  Success")

      @helper.addLogs("[Validate] opportunity:Deal_Type__c")
      expect(opportunity[0].fetch('Deal_Type__c')).to eq "Relational"
      @helper.addLogs("[Result  ]  Success")

      @helper.addLogs("[Validate] opportunity:Owner.Id")
      ownerAssign = accQueue.include? opportunity[0].fetch('Owner')['Id']
      expect(ownerAssign).to eq true
      @helper.addLogs("[Result  ]  Success")

      @helper.addLogs("[Validate] opportunity:Quantity__c")
      expect(opportunity[0].fetch('Quantity__c').to_i).to eq @testDataJSON['AccountAssignment']['tour'][0]['numberOfDesks'].to_i
      @helper.addLogs("[Result  ]  Success")

      puts "get Account Details"
      account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact[0].fetch('Id')}")
      expect(account[0]).to_not eq nil
      
      @helper.addLogs("[Validate] account:RecordType.Name")
      expect(account[0].fetch('RecordType')['Name']).to eq "Enterprise Solutions"
      @helper.addLogs("[Result  ]  Success")

      @helper.addLogs("[Validate] account:Owner.Name")
      ownerAssign = accQueue.include? account[0].fetch('Owner')['Id']
      expect(ownerAssign).to eq true
      @helper.addLogs("[Result  ]  Success")

      @helper.addLogs("[Validate] account:Number_of_Full_Time_Employees__c")
      expect(account[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
      @helper.addLogs("[Result  ]  Success")

      @helper.addLogs("[Validate] account:Interested_in_Number_of_Desks__c")
      expect(account[0].fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
      @helper.addLogs("[Result  ]  Success")

    @helper.postSuccessResult('2046')
    rescue Exception => e
      raise e
      @helper.postFailResult(e,'2046')
    end

  end

  it "C2047 : To Check Account Assignment for Record Type Enterprise and Deal Type Strategic.", :'2047'=> 'true' do
    begin
      @testDataJSON['AccountAssignment']['tour'][0]['building']  = 'SYD-Martin Place'
      @testDataJSON['AccountAssignment']['tour'][0]['companySize']  = '1200'
      @testDataJSON['AccountAssignment']['tour'][0]['numberOfDesks']  = '27'

      @helper.addLogs("C2047 : To Check Account Assignment for Record Type Enterprise and Deal type Strategic.",'2047')

      #puts caseInfo
      @helper.addLogs("[Step    ] booking tour from WebSite")
      emailId = @objAccAssignmentFromLead.createLead()
      expect(@driver.title).to match("Coworking Office Sambhav BKC | WeWork")

      @helper.addLogs("[Validate]  Lead should be created")
      lead = @objAccAssignmentFromLead.fetchLeadDetails(emailId)
      expect(lead[0]).to_not eq nil
      @helper.addLogs("[Expected]  Lead created successfully with emailId = #{emailId} \n[Result  ]  Success ")

      @helper.addLogs("[Step    ] logging to salesforce")
      @objAccAssignmentFromLead.loginToSalesforce

      @helper.addLogs("[Step    ] go to details page of created lead and Clicking on 'Manage/book Tour' button")
      expect(@objAccAssignmentFromLead.goToDetailPage(lead[0].fetch('Id'))).to eq true


      @helper.addLogs("[Validate] Checking Manage Tour page when user click on 'Manage/book tour' button")
      expect(@driver.title).to match("Manage Tours")
      @helper.addLogs("[Expected] Manage tour page opened successfully with Page Title= Manage Tours \n[Result  ]  Success")

      @helper.addLogs("[Step    ] filling all required fields and booked a tour")

      expect(@objAccAssignmentFromLead.bookTour(0,true)).to eq true

      @helper.addLogs("[Step    ] click on Create Account and Don't Merge")
      @objAccAssignmentFromLead.instance_variable_get(:@wait).until {@driver.find_element(:id ,"header43").displayed?}
      expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Don't Merge",nil)).to eq true

      @helper.addLogs("[Step    ] checking fields...")

      @helper.addLogs("[Step    ] get building details of #{@testDataJSON['AccountAssignment']["tour"][0]["building"]}")
      building = @objAccAssignmentFromLead.fetchBuildingDetails(@testDataJSON['AccountAssignment']["tour"][0]["building"])
      expect(building[0]).to_not eq nil
      
      @helper.addLogs("[Step    ] get accQueue details")
      accQueue = @objAccAssignmentFromLead.fetAccOwnerQueue(building[0].fetch('Market__c'),'Enterprise Solutions')

      #accQueue = @objAccAssignmentFromLead.fetAccOwnerQueue('a2V0G000003H8zoUAC','Enterprise Solutions')

      @helper.addLogs("[Step    ] get Contact details")
      contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
      #contact = @objAccAssignmentFromLead.fetchContactDetails("john.smith1004201828@example.com")
      expect(contact[0]).to_not eq nil
      
      @helper.addLogs("[Validate] contact:RecordType.Name")
      expect(contact[0].fetch('RecordType')['Name']).to eq "Enterprise Solutions"
      @helper.addLogs("[Result  ]  Success")

      @helper.addLogs("[Validate] contact:Owner.Id")
      puts accQueue.include? contact[0].fetch('Owner')['Id']
      ownerAssign = accQueue.include? contact[0].fetch('Owner')['Id']
      expect(ownerAssign).to eq true
      @helper.addLogs("[Result  ]  Success")

      @helper.addLogs("[Validate] contact:Number_of_Full_Time_Employees__c")
      expect(contact[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
      @helper.addLogs("[Result  ]  Success")

      @helper.addLogs("[Validate] contact:Looking_For_Number_Of_Desk__c")
      expect(contact[0].fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
      @helper.addLogs("[Result  ]  Success")

      puts "get Opportunity details"
      opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact[0].fetch('Id')}")
      expect(opportunity[0]).to_not eq nil
      
      @helper.addLogs("[Validate] opportunity:RecordType.Name")
      expect(opportunity[0].fetch('RecordType')['Name']).to eq "Enterprise Solutions"
      @helper.addLogs("[Result  ]  Success")

      @helper.addLogs("[Validate] opportunity:Deal_Type__c")
      expect(opportunity[0].fetch('Deal_Type__c')).to eq "Strategic"
      @helper.addLogs("[Result  ]  Success")

      @helper.addLogs("[Validate] opportunity:Owner.Id")
      ownerAssign = accQueue.include? opportunity[0].fetch('Owner')['Id']
      expect(ownerAssign).to eq true
      @helper.addLogs("[Result  ]  Success")

      @helper.addLogs("[Validate] opportunity:Quantity__c")
      expect(opportunity[0].fetch('Quantity__c').to_i).to eq @testDataJSON['AccountAssignment']['tour'][0]['numberOfDesks'].to_i
      @helper.addLogs("[Result  ]  Success")

      puts "get Account Details"
      account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact[0].fetch('Id')}")
      expect(account[0]).to_not eq nil
      
      @helper.addLogs("[Validate] account:RecordType.Name")
      expect(account[0].fetch('RecordType')['Name']).to eq "Enterprise Solutions"
      @helper.addLogs("[Result  ]  Success")

      @helper.addLogs("[Validate] account:Owner.Name")
      ownerAssign = accQueue.include? account[0].fetch('Owner')['Id']
      expect(ownerAssign).to eq true
      @helper.addLogs("[Result  ]  Success")

      @helper.addLogs("[Validate] account:Number_of_Full_Time_Employees__c")
      expect(account[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
      @helper.addLogs("[Result  ]  Success")

      @helper.addLogs("[Validate] account:Interested_in_Number_of_Desks__c")
      expect(account[0].fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
      @helper.addLogs("[Result  ]  Success")

    @helper.postSuccessResult('2047')
    rescue Exception => e
      raise e
      @helper.postFailResult(e,'2047')
    end

  end

 end

 context "by Create Acc and Merge" do

   it "C2048 : To check account assignment for Record Type Consumer and Deal type Transactional.", :'2048'=> 'true' do
     begin
       @helper.addLogs("C2048 : To check account assignment for Record Type Consumer and Deal type Transactional.",'2048')

       @testDataJSON['AccountAssignment']['tour'][0]['companySize']  = '15'
       @testDataJSON['AccountAssignment']['tour'][0]['numberOfDesks']  = '5'
       @testDataJSON['AccountAssignment']['tour'][0]['building']  = 'SYD-Martin Place'

       @helper.addLogs("[Step    ] booking tour from WebSite")
       emailId = @objAccAssignmentFromLead.createLead()
       expect(@driver.title).to match("Coworking Office")# Sambhav BKC | WeWork")

       @helper.addLogs("[Validate]  Lead should be created")
       lead = @objAccAssignmentFromLead.fetchLeadDetails(emailId)
       expect(lead[0]).to_not eq nil
       expect(lead.size == 1).to eq true
       @helper.addLogs("[Expected]  Lead created successfully with emailId = #{emailId} \n[Result  ]  Success ")

       @helper.addLogs("[Step    ] logging to salesforce")
       expect(@objAccAssignmentFromLead.loginToSalesforce).to_not eq nil

       @helper.addLogs("[Step    ] go to details page of created lead and Clicking on 'Manage/book Tour' button")
       expect(@objAccAssignmentFromLead.goToDetailPage(lead[0].fetch('Id'))).to eq true


       @helper.addLogs("[Validate] Checking Manage Tour page when user click on 'Manage/book tour' button")
       expect(@driver.title).to match("Manage Tours")
       @helper.addLogs("[Expected] Manage tour page opened successfully with Page Title= Manage Tours \n[Result  ]  Success")

       @helper.addLogs("[Step    ] filling all required fields and booked a tour")

       expect(@objAccAssignmentFromLead.bookTour(0,true)).to eq true

       @helper.addLogs("[Step    ] click on Create Account and Merge")
       expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Merge",nil)).to eq true

       @helper.addLogs("[Step    ] checking fields...")

       @helper.addLogs("[Step    ] get building details of #{@testDataJSON['AccountAssignment']["tour"][0]["building"]}")
       building = @objAccAssignmentFromLead.fetchBuildingDetails(@testDataJSON['AccountAssignment']["tour"][0]["building"])
       expect(building[0]).to_not eq nil

       @helper.addLogs("[Step    ] get Contact details")
       contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
       expect(contact[0]).to_not eq nil

       @helper.addLogs("[Validate] contact:RecordType.Name")
       expect(contact[0].fetch('RecordType')['Name']).to eq "Consumer"
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] contact:Owner.Id")
       expect(contact[0].fetch('Owner')['Id']).to eq "#{building[0].fetch('Community_Lead__c')}"
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] contact:Number_of_Full_Time_Employees__c")
       expect(contact[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] contact:Looking_For_Number_Of_Desk__c")
       expect(contact[0].fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
       @helper.addLogs("[Result  ]  Success")

       puts "get Opportunity details"
       opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact[0].fetch('Id')}")
       expect(opportunity[0]).to_not eq nil

       @helper.addLogs("[Validate] opportunity:RecordType.Name")
       expect(opportunity[0].fetch('RecordType')['Name']).to eq "Consumer"
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] opportunity:Deal_Type__c")
       expect(opportunity[0].fetch('Deal_Type__c')).to eq "Transactional"
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] opportunity:Owner.Id")
       puts opportunity[0].fetch('Owner')['Id']
       puts "#{building[0].fetch('Community_Lead__c')}"
       expect(opportunity[0].fetch('Owner')['Id']).to eq "#{building[0].fetch('Community_Lead__c')}".to_s
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] opportunity:Quantity__c")
       expect(opportunity[0].fetch('Quantity__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
       @helper.addLogs("[Result  ]  Success")

       puts "get Account Details"
       account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact[0].fetch('Id')}")
       expect(account[0]).to_not eq nil

       @helper.addLogs("[Validate] account:RecordType.Name")
       expect(account[0].fetch('RecordType')['Name']).to eq "Consumer"
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] account:Owner.Id")
       expect(account[0].fetch('Owner')['Id']).to eq "#{building[0].fetch('Community_Lead__c')}".to_s
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] account:Number_of_Full_Time_Employees__c")
       expect(account[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] account:Interested_in_Number_of_Desks__c")
       expect(account[0].fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] account:Allow_Merge__c")
       expect(account[0].fetch('Allow_Merge__c')).to eq true
       @helper.addLogs("[Result  ]  Success")

     @helper.postSuccessResult('2048')
    rescue Exception => e
      raise e
      @helper.postFailResult(e,'2048')
    end

   end


   it "C2049 : To check account assignment for Record Type Consumer and Deal type Relational.", :'2049'=> 'true' do
     begin
       @helper.addLogs("C2049 : To check account assignment for Record Type Consumer and Deal type Relational.",'2049')

       @testDataJSON['AccountAssignment']['tour'][0]['companySize']  = '15'
       @testDataJSON['AccountAssignment']['tour'][0]['numberOfDesks']  = '13'

       @helper.addLogs("[Step    ] booking tour from WebSite")
       emailId = @objAccAssignmentFromLead.createLead()
       expect(@driver.title).to match("Coworking Office")# Sambhav BKC | WeWork")

       @helper.addLogs("[Validate]  Lead should be created")
       lead = @objAccAssignmentFromLead.fetchLeadDetails(emailId)
       expect(lead[0]).to_not eq nil
       expect(lead.size == 1).to eq true
       @helper.addLogs("[Expected]  Lead created successfully with emailId = #{emailId} \n[Result  ]  Success ")

       @helper.addLogs("[Step    ] logging to salesforce")
       @objAccAssignmentFromLead.loginToSalesforce

       @helper.addLogs("[Step    ] go to details page of created lead and Clicking on 'Manage/book Tour' button")
       expect(@objAccAssignmentFromLead.goToDetailPage(lead[0].fetch('Id'))).to eq true


       @helper.addLogs("[Validate] Checking Manage Tour page when user click on 'Manage/book tour' button")
       expect(@driver.title).to match("Manage Tours")
       @helper.addLogs("[Expected] Manage tour page opened successfully with Page Title= Manage Tours \n[Result  ]  Success")

       @helper.addLogs("[Step    ] filling all required fields and booked a tour")

       expect(@objAccAssignmentFromLead.bookTour(0,true)).to eq true

       @helper.addLogs("[Step    ] click on Create Account and Merge")
       @objAccAssignmentFromLead.instance_variable_get(:@wait).until {@driver.find_element(:id ,"header43").displayed?}
       expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Merge",nil)).to eq true

       @helper.addLogs("[Step    ] checking fields...")

       @helper.addLogs("[Step    ] get building details of #{@testDataJSON['AccountAssignment']["tour"][0]["building"]}")
       building = @objAccAssignmentFromLead.fetchBuildingDetails(@testDataJSON['AccountAssignment']["tour"][0]["building"])
       expect(building[0]).to_not eq nil

       @helper.addLogs("[Step    ] get Contact details")
       contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
       expect(contact[0]).to_not eq nil

       @helper.addLogs("[Validate] contact:RecordType.Name")
       expect(contact[0].fetch('RecordType')['Name']).to eq "Consumer"
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] contact:Owner.Id")
       expect(contact[0].fetch('Owner')['Name']).to eq "#{building[0].fetch('Cluster_Sales_Lead_Name__c')}"
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] contact:Number_of_Full_Time_Employees__c")
       expect(contact[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] contact:Looking_For_Number_Of_Desk__c")
       expect(contact[0].fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
       @helper.addLogs("[Result  ]  Success")

       puts "get Opportunity details"
       opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact[0].fetch('Id')}")
       expect(opportunity[0]).to_not eq nil

       @helper.addLogs("[Validate] opportunity:RecordType.Name")
       expect(opportunity[0].fetch('RecordType')['Name']).to eq "Consumer"
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] opportunity:Deal_Type__c")
       expect(opportunity[0].fetch('Deal_Type__c')).to eq "Relational"
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] opportunity:Owner.Id")
       expect(opportunity[0].fetch('Owner')['Name']).to eq "#{building[0].fetch('Cluster_Sales_Lead_Name__c')}"
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] opportunity:Quantity__c")
       expect(opportunity[0].fetch('Quantity__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
       @helper.addLogs("[Result  ]  Success")

       puts "get Account Details"
       account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact[0].fetch('Id')}")
       expect(account[0]).to_not eq nil

       @helper.addLogs("[Validate] account:RecordType.Name")
       expect(account[0].fetch('RecordType')['Name']).to eq "Consumer"
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] account:Owner.Name")
       expect(account[0].fetch('Owner')['Name']).to eq "#{building[0].fetch('Cluster_Sales_Lead_Name__c')}"
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] account:Number_of_Full_Time_Employees__c")
       expect(account[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] account:Interested_in_Number_of_Desks__c")
       expect(account[0].fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] account:Allow_Merge__c")
       expect(account[0].fetch('Allow_Merge__c')).to eq true
       @helper.addLogs("[Result  ]  Success")

       @helper.postSuccessResult('2049')
    rescue Exception => e
       raise e
       @helper.postFailResult(e,'2049')
    end

   end


   it "C2050 : To check account assignment for Record Type Consumer and Deal type Strategic.", :'2050'=> 'true' do
     begin
       @helper.addLogs("C2050 : To check account assignment for Record Type Consumer and Deal type Strategic.",'2050')

       @testDataJSON['AccountAssignment']['tour'][0]['companySize']  = '15'
       @testDataJSON['AccountAssignment']['tour'][0]['numberOfDesks']  = '25'

       @helper.addLogs("[Step    ] booking tour from WebSite")
       emailId = @objAccAssignmentFromLead.createLead()
       expect(@driver.title).to match("Coworking Office")# Sambhav BKC | WeWork")

       @helper.addLogs("[Validate]  Lead should be created")
       lead = @objAccAssignmentFromLead.fetchLeadDetails(emailId)
       expect(lead[0]).to_not eq nil
       @helper.addLogs("[Expected]  Lead created successfully with emailId = #{emailId} \n[Result  ]  Success ")

       @helper.addLogs("[Step    ] logging to salesforce")
       @objAccAssignmentFromLead.loginToSalesforce

       @helper.addLogs("[Step    ] go to details page of created lead and Clicking on 'Manage/book Tour' button")
       expect(@objAccAssignmentFromLead.goToDetailPage(lead[0].fetch('Id'))).to eq true


       @helper.addLogs("[Validate] Checking Manage Tour page when user click on 'Manage/book tour' button")
       expect(@driver.title).to match("Manage Tours")
       @helper.addLogs("[Expected] Manage tour page opened successfully with Page Title= Manage Tours \n[Result  ]  Success")

       @helper.addLogs("[Step    ] filling all required fields and booked a tour")

       expect(@objAccAssignmentFromLead.bookTour(0,true)).to eq true

       @helper.addLogs("[Step    ] click on Create Account and Merge")
       @objAccAssignmentFromLead.instance_variable_get(:@wait).until {@driver.find_element(:id ,"header43").displayed?}
       expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Merge",nil)).to eq true

       @helper.addLogs("[Step    ] checking fields...")

       @helper.addLogs("[Step    ] get building details of #{@testDataJSON['AccountAssignment']["tour"][0]["building"]}")
       building = @objAccAssignmentFromLead.fetchBuildingDetails(@testDataJSON['AccountAssignment']["tour"][0]["building"])
       expect(building[0]).to_not eq nil

       @helper.addLogs("[Step    ] get accQueue details")
       accQueue = @objAccAssignmentFromLead.fetAccOwnerQueue(building[0].fetch('Market__c'),'Consumer')

       @helper.addLogs("[Step    ] get Contact details")
       contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
       expect(contact[0]).to_not eq nil

       @helper.addLogs("[Validate] contact:RecordType.Name")
       expect(contact[0].fetch('RecordType')['Name']).to eq "Consumer"
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] contact:Owner.Id")
       ownerAssign = accQueue.include? contact[0].fetch('Owner')['Id']
       expect(ownerAssign).to eq true
       #expect(contact[0].fetch('Owner')['Id']).to eq "#{accQueue.fetch('Member__c')}"
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] contact:Number_of_Full_Time_Employees__c")
       expect(contact[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] contact:Looking_For_Number_Of_Desk__c")
       expect(contact[0].fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
       @helper.addLogs("[Result  ]  Success")

       puts "get Opportunity details"
       opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact[0].fetch('Id')}")
       expect(opportunity[0]).to_not eq nil

       @helper.addLogs("[Validate] opportunity:RecordType.Name")
       expect(opportunity[0].fetch('RecordType')['Name']).to eq "Consumer"
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] opportunity:Deal_Type__c")
       expect(opportunity[0].fetch('Deal_Type__c')).to eq "Strategic"
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] opportunity:Owner.Id")
       ownerAssign = accQueue.include? opportunity[0].fetch('Owner')['Id']
       expect(ownerAssign).to eq true
       #expect(opportunity[0].fetch('Owner')['Id']).to eq "#{accQueue.fetch('Member__c')}"
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] opportunity:Quantity__c")
       expect(opportunity[0].fetch('Quantity__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
       @helper.addLogs("[Result  ]  Success")

       puts "get Account Details"
       account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact[0].fetch('Id')}")
       expect(account[0]).to_not eq nil

       @helper.addLogs("[Validate] account:RecordType.Name")
       expect(account[0].fetch('RecordType')['Name']).to eq "Consumer"
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] account:Owner.Name")
       ownerAssign = accQueue.include? account[0].fetch('Owner')['Id']
       expect(ownerAssign).to eq true

       #expect(account[0].fetch('Owner')['Id']).to eq "#{accQueue.fetch('Member__c')}"
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] account:Number_of_Full_Time_Employees__c")
       expect(account[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] account:Interested_in_Number_of_Desks__c")
       expect(account[0].fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] account:Allow_Merge__c")
       expect(account[0].fetch('Allow_Merge__c')).to eq true
       @helper.addLogs("[Result  ]  Success")

     @helper.postSuccessResult('2050')
    rescue Exception => e
       raise e
       @helper.postFailResult(e,'2050')
    end
   end


   it "C2051 : To check account assignment for Record Type Consumer and Deal type Relational.", :'2051'=> 'true'  do
     begin
       @helper.addLogs("C2051 : To check account assignment for Record Type Consumer and Deal type Strategic.(Queue is not present in the Account Queue Setting).",'2051')

       @testDataJSON['AccountAssignment']['tour'][0]['building']  = 'SYD-Martin Place'
       @testDataJSON['AccountAssignment']['tour'][0]['companySize']  = '15'
       @testDataJSON['AccountAssignment']['tour'][0]['numberOfDesks']  = '25'

       @helper.addLogs("[Step    ] booking tour from WebSite")
       emailId = @objAccAssignmentFromLead.createLead()
       #expect(@driver.title).to match("Coworking Office Sambhav BKC | WeWork")

       sleep (10)
       @helper.addLogs("[Validate]  Lead should be created")
       lead = @objAccAssignmentFromLead.fetchLeadDetails(emailId)
       expect(lead[0]).to_not eq nil

       @helper.addLogs("[Expected]  Lead created successfully with emailId = #{emailId} \n[Result  ]  Success ")

       @helper.addLogs("[Step    ] logging to salesforce")
       @objAccAssignmentFromLead.loginToSalesforce

       @helper.addLogs("[Step    ] go to details page of created lead and Clicking on 'Manage/book Tour' button")
       expect(@objAccAssignmentFromLead.goToDetailPage(lead[0].fetch('Id'))).to eq true

       @helper.addLogs("[Validate] Checking Manage Tour page when user click on 'Manage/book tour' button")
       expect(@driver.title).to match("Manage Tours")
       @helper.addLogs("[Expected] Manage tour page opened successfully with Page Title= Manage Tours \n[Result  ]  Success")

       @helper.addLogs("[Step    ] filling all required fields and booked a tour")
       expect(@objAccAssignmentFromLead.bookTour(0,true)).to eq true

       @helper.addLogs("[Step    ] click on Create Account and Don't Merge")
       @objAccAssignmentFromLead.instance_variable_get(:@wait).until {@driver.find_element(:id ,"header43").displayed?}
       expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Merge",nil)).to eq true

       @helper.addLogs("[Step    ] checking fields...")

       @helper.addLogs("[Step    ] get building details of #{@testDataJSON['AccountAssignment']["tour"][0]["building"]}")
       building = @objAccAssignmentFromLead.fetchBuildingDetails(@testDataJSON['AccountAssignment']["tour"][0]["building"])
       expect(building[0]).to_not eq nil

       #@helper.addLogs("[Step    ] get accQueue details")
       #accQueue = @objAccAssignmentFromLead.fetAccOwnerQueue(building[0].fetch('Market__c'),'Consumer')

       @helper.addLogs("[Step    ] get Contact details")
       contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
       expect(contact[0]).to_not eq nil

       @helper.addLogs("[Validate] contact:RecordType.Name")
       expect(contact[0].fetch('RecordType')['Name']).to eq "Consumer"
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] contact:Owner.Id")
       expect(contact[0].fetch('Owner')['Id']).to eq "005F0000003KmbwIAC"
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] contact:Number_of_Full_Time_Employees__c")
       expect(contact[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] contact:Looking_For_Number_Of_Desk__c")
       expect(contact[0].fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
       @helper.addLogs("[Result  ]  Success")

       puts "get Opportunity details"
       opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact[0].fetch('Id')}")
        expect(opportunity[0]).to_not eq nil

       @helper.addLogs("[Validate] opportunity:RecordType.Name")
       expect(opportunity[0].fetch('RecordType')['Name']).to eq "Consumer"
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] opportunity:Deal_Type__c")
       expect(opportunity[0].fetch('Deal_Type__c')).to eq "Strategic"
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] opportunity:Owner.Id")
       expect(opportunity[0].fetch('Owner')['Id']).to eq "005F0000003KmbwIAC"
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] opportunity:Quantity__c")
       expect(opportunity[0].fetch('Quantity__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
       @helper.addLogs("[Result  ]  Success")

       puts "get Account Details"
       account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact[0].fetch('Id')}")
       expect(account[0]).to_not eq nil

       @helper.addLogs("[Validate] account:RecordType.Name")
       expect(account[0].fetch('RecordType')['Name']).to eq "Consumer"
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] account:Owner.Name")
       expect(account[0].fetch('Owner')['Id']).to eq "005F0000003KmbwIAC"
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] account:Number_of_Full_Time_Employees__c")
       expect(account[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] account:Interested_in_Number_of_Desks__c")
       expect(account[0].fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] account:Allow_Merge__c")
       expect(account[0].fetch('Allow_Merge__c')).to eq true
       
     @helper.postSuccessResult('2051')
    rescue Exception => e
       raise e
       @helper.postFailResult(e,'2051')
    end

   end

   it "C2052 : To Check Account assignment for Record Type Mid-Market and Deal type Transactional.", :'2052'=> 'true' do
     begin
       @helper.addLogs("C2052 : To Check Account assignment for Record Type Mid-Market and Deal type Transactional.",'2052')
       @testDataJSON['AccountAssignment']['tour'][0]['building']  = 'SYD-Martin Place'
       @testDataJSON['AccountAssignment']['tour'][0]['companySize']  = '24'
       @testDataJSON['AccountAssignment']['tour'][0]['numberOfDesks']  = '7'

       @helper.addLogs("[Step    ] booking tour from WebSite")
       emailId = @objAccAssignmentFromLead.createLead()
       #expect(@driver.title).to match("Coworking Office Sambhav BKC | WeWork")

       @helper.addLogs("[Validate]  Lead should be created")
       lead = @objAccAssignmentFromLead.fetchLeadDetails(emailId)
          expect(lead[0]).to_not eq nil
       @helper.addLogs("[Expected]  Lead created successfully with emailId = #{emailId} \n[Result  ]  Success ")

       @helper.addLogs("[Step    ] logging to salesforce")
       @objAccAssignmentFromLead.loginToSalesforce

       @helper.addLogs("[Step    ] go to details page of created lead and Clicking on 'Manage/book Tour' button")
       expect(@objAccAssignmentFromLead.goToDetailPage(lead[0].fetch('Id'))).to eq true

       @helper.addLogs("[Validate] Checking Manage Tour page when user click on 'Manage/book tour' button")
       expect(@driver.title).to match("Manage Tours")
       @helper.addLogs("[Expected] Manage tour page opened successfully with Page Title= Manage Tours \n[Result  ]  Success")

       @helper.addLogs("[Step    ] filling all required fields and booked a tour")

       expect(@objAccAssignmentFromLead.bookTour(0,true)).to eq true

       @helper.addLogs("[Step    ] click on Create Account and Merge")
       @objAccAssignmentFromLead.instance_variable_get(:@wait).until {@driver.find_element(:id ,"header43").displayed?}
       expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Merge",nil)).to eq true

       @helper.addLogs("[Step    ] checking fields...")

       @helper.addLogs("[Step    ] get building details of #{@testDataJSON['AccountAssignment']["tour"][0]["building"]}")
       building = @objAccAssignmentFromLead.fetchBuildingDetails(@testDataJSON['AccountAssignment']["tour"][0]["building"])
       expect(building[0]).to_not eq nil

       @helper.addLogs("[Step    ] get Contact details")
       contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
       expect(contact[0]).to_not eq nil

       @helper.addLogs("[Validate] contact:RecordType.Name")
       expect(contact[0].fetch('RecordType')['Name']).to eq "Mid Market"
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] contact:Owner.Id")
       expect(contact[0].fetch('Owner')['Id']).to eq "#{building[0].fetch('Community_Lead__c')}"
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] contact:Number_of_Full_Time_Employees__c")
       expect(contact[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] contact:Looking_For_Number_Of_Desk__c")
       expect(contact[0].fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
       @helper.addLogs("[Result  ]  Success")

       puts "get Opportunity details"
       opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact[0].fetch('Id')}")
       expect(opportunity[0]).to_not eq nil

       @helper.addLogs("[Validate] opportunity:RecordType.Name")
       expect(opportunity[0].fetch('RecordType')['Name']).to eq "Mid Market"
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] opportunity:Deal_Type__c")
       expect(opportunity[0].fetch('Deal_Type__c')).to eq "Transactional"
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] opportunity:Owner.Id")
       expect(opportunity[0].fetch('Owner')['Id']).to eq "#{building[0].fetch('Community_Lead__c')}"
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] opportunity:Quantity__c")
       expect(opportunity[0].fetch('Quantity__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
       @helper.addLogs("[Result  ]  Success")

       puts "get Account Details"
       account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact[0].fetch('Id')}")
       expect(account[0]).to_not eq nil

       @helper.addLogs("[Validate] account:RecordType.Name")
       expect(account[0].fetch('RecordType')['Name']).to eq "Mid Market"
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] account:Owner.Id")
       expect(account[0].fetch('Owner')['Id']).to eq "#{building[0].fetch('Community_Lead__c')}"
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] account:Number_of_Full_Time_Employees__c")
       expect(account[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] account:Interested_in_Number_of_Desks__c")
       expect(account[0].fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] account:Allow_Merge__c")
       expect(account[0].fetch('Allow_Merge__c')).to eq true
       @helper.addLogs("[Result  ]  Success")

     @helper.postSuccessResult('2052')
    rescue Exception => e
       raise e
       @helper.postFailResult(e,'2052')
    end
   end

   it "C2053 : To Check Account Assignment for Record type Mid-Market and Deal type Relational.", :'2053'=> 'true' do
     begin
       @helper.addLogs("C2053 : To Check Account Assignment for Record type Mid-Market and Deal type Relational.",'2053')

       @testDataJSON['AccountAssignment']['tour'][0]['building']  = 'SYD-Martin Place'
       @testDataJSON['AccountAssignment']['tour'][0]['companySize']  = '24'
       @testDataJSON['AccountAssignment']['tour'][0]['numberOfDesks']  = '15'

       @helper.addLogs("[Step    ] booking tour from WebSite")
       emailId = @objAccAssignmentFromLead.createLead()
       expect(@driver.title).to match("Coworking Office")# Sambhav BKC | WeWork")

       @helper.addLogs("[Validate]  Lead should be created")
       lead = @objAccAssignmentFromLead.fetchLeadDetails(emailId)
       expect(lead[0]).to_not eq nil
       @helper.addLogs("[Expected]  Lead created successfully with emailId = #{emailId} \n[Result  ]  Success ")

       @helper.addLogs("[Step    ] logging to salesforce")
       @objAccAssignmentFromLead.loginToSalesforce

       @helper.addLogs("[Step    ] go to details page of created lead and Clicking on 'Manage/book Tour' button")
       expect(@objAccAssignmentFromLead.goToDetailPage(lead[0].fetch('Id'))).to eq true


       @helper.addLogs("[Validate] Checking Manage Tour page when user click on 'Manage/book tour' button")
       expect(@driver.title).to match("Manage Tours")
       @helper.addLogs("[Expected] Manage tour page opened successfully with Page Title= Manage Tours \n[Result  ]  Success")

       @helper.addLogs("[Step    ] filling all required fields and booked a tour")
       expect(@objAccAssignmentFromLead.bookTour(0,true)).to eq true

       @helper.addLogs("[Step    ] click on Create Account and Don't Merge")
       @objAccAssignmentFromLead.instance_variable_get(:@wait).until {@driver.find_element(:id ,"header43").displayed?}
       expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Merge",nil)).to eq true

       @helper.addLogs("[Step    ] checking fields...")

       @helper.addLogs("[Step    ] get building details of #{@testDataJSON['AccountAssignment']["tour"][0]["building"]}")
       building = @objAccAssignmentFromLead.fetchBuildingDetails(@testDataJSON['AccountAssignment']["tour"][0]["building"])
       expect(building[0]).to_not eq nil

       @helper.addLogs("[Step    ] get Contact details")
       contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
       expect(contact[0]).to_not eq nil

       @helper.addLogs("[Validate] contact:RecordType.Name")
       expect(contact[0].fetch('RecordType')['Name']).to eq "Mid Market"
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] contact:Owner.Id")
       expect(contact[0].fetch('Owner')['Name']).to eq "#{building[0].fetch('Cluster_Sales_Lead_Name__c')}"
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] contact:Number_of_Full_Time_Employees__c")
       expect(contact[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] contact:Looking_For_Number_Of_Desk__c")
       expect(contact[0].fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
       @helper.addLogs("[Result  ]  Success")

       puts "get Opportunity details"
       opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact[0].fetch('Id')}")
       expect(opportunity[0]).to_not eq nil

       @helper.addLogs("[Validate] opportunity:RecordType.Name")
       expect(opportunity[0].fetch('RecordType')['Name']).to eq "Mid Market"
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] opportunity:Deal_Type__c")
       expect(opportunity[0].fetch('Deal_Type__c')).to eq "Relational"
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] opportunity:Owner.Id")
       expect(opportunity[0].fetch('Owner')['Name']).to eq "#{building[0].fetch('Cluster_Sales_Lead_Name__c')}"
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] opportunity:Quantity__c")
       expect(opportunity[0].fetch('Quantity__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
       @helper.addLogs("[Result  ]  Success")

       puts "get Account Details"
       account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact[0].fetch('Id')}")
       expect(account[0]).to_not eq nil

       @helper.addLogs("[Validate] account:RecordType.Name")
       expect(account[0].fetch('RecordType')['Name']).to eq "Mid Market"
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] account:Owner.Name")
       expect(account[0].fetch('Owner')['Name']).to eq "#{building[0].fetch('Cluster_Sales_Lead_Name__c')}"
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] account:Number_of_Full_Time_Employees__c")
       expect(account[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] account:Interested_in_Number_of_Desks__c")
       expect(account[0].fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] account:Allow_Merge__c")
       expect(account[0].fetch('Allow_Merge__c')).to eq true
       @helper.postSuccessResult('2053')
    rescue Exception => e
       raise e
       @helper.postFailResult(e,'2053')
    end

   end

   it "C2054 : To Check Account Assignment from Record type Mid-Market and Deal Type Strategic.", :'2054'=> 'true' do
     begin
       @helper.addLogs("C2054 : To check account assignment for Record Type Consumer and Deal type Relational.",'2054')

       @testDataJSON['AccountAssignment']['tour'][0]['building']  = 'SYD-Martin Place'
       @testDataJSON['AccountAssignment']['tour'][0]['companySize']  = '24'
       @testDataJSON['AccountAssignment']['tour'][0]['numberOfDesks']  = '27'

       @helper.addLogs("[Step    ] booking tour from WebSite")
       emailId = @objAccAssignmentFromLead.createLead()
       expect(@driver.title).to match("Coworking Office")# Sambhav BKC | WeWork")

       @helper.addLogs("[Validate]  Lead should be created")
       lead = @objAccAssignmentFromLead.fetchLeadDetails(emailId)
       expect(lead[0]).to_not eq nil
       @helper.addLogs("[Expected]  Lead created successfully with emailId = #{emailId} \n[Result  ]  Success ")

       @helper.addLogs("[Step    ] logging to salesforce")
       @objAccAssignmentFromLead.loginToSalesforce

       @helper.addLogs("[Step    ] go to details page of created lead and Clicking on 'Manage/book Tour' button")
       expect(@objAccAssignmentFromLead.goToDetailPage(lead[0].fetch('Id'))).to eq true


       @helper.addLogs("[Validate] Checking Manage Tour page when user click on 'Manage/book tour' button")
       expect(@driver.title).to match("Manage Tours")
       @helper.addLogs("[Expected] Manage tour page opened successfully with Page Title= Manage Tours \n[Result  ]  Success")

       @helper.addLogs("[Step    ] filling all required fields and booked a tour")

       expect(@objAccAssignmentFromLead.bookTour(0,true)).to eq true

       @helper.addLogs("[Step    ] click on Create Account and Merge")
       @objAccAssignmentFromLead.instance_variable_get(:@wait).until {@driver.find_element(:id ,"header43").displayed?}
       expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Merge",nil)).to eq true

       @helper.addLogs("[Step    ] checking fields...")

       @helper.addLogs("[Step    ] get building details of #{@testDataJSON['AccountAssignment']["tour"][0]["building"]}")
       building = @objAccAssignmentFromLead.fetchBuildingDetails(@testDataJSON['AccountAssignment']["tour"][0]["building"])
       expect(building[0]).to_not eq nil

       @helper.addLogs("[Step    ] get accQueue details")

       accQueue = @objAccAssignmentFromLead.fetAccOwnerQueue(building[0].fetch('Market__c'),'Mid Market')

       @helper.addLogs("[Step    ] get Contact details")
       contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
       expect(contact[0]).to_not eq nil

       @helper.addLogs("[Validate] contact:RecordType.Name")
       expect(contact[0].fetch('RecordType')['Name']).to eq "Mid Market"
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] contact:Owner.Id")

       puts accQueue.include? contact[0].fetch('Owner')['Id']
       ownerAssign = accQueue.include? contact[0].fetch('Owner')['Id']
       expect(ownerAssign).to eq true

       #expect(contact[0].fetch('Owner')['Id']).to eq "#{accQueue.fetch('Member__c')}"
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] contact:Number_of_Full_Time_Employees__c")
       expect(contact[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] contact:Looking_For_Number_Of_Desk__c")
       expect(contact[0].fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
       @helper.addLogs("[Result  ]  Success")

       puts "get Opportunity details"
       opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact[0].fetch('Id')}")
       expect(opportunity[0]).to_not eq nil

       @helper.addLogs("[Validate] opportunity:RecordType.Name")
       expect(opportunity[0].fetch('RecordType')['Name']).to eq "Mid Market"
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] opportunity:Deal_Type__c")
       expect(opportunity[0].fetch('Deal_Type__c')).to eq "Strategic"
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] opportunity:Owner.Id")
       ownerAssign = accQueue.include? opportunity[0].fetch('Owner')['Id']
       expect(ownerAssign).to eq true

       #expect(opportunity[0].fetch('Owner')['Id']).to eq "#{accQueue.fetch('Member__c')}"
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] opportunity:Quantity__c")
       expect(opportunity[0].fetch('Quantity__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
       @helper.addLogs("[Result  ]  Success")

       puts "get Account Details"
       account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact[0].fetch('Id')}")
       expect(account[0]).to_not eq nil

       @helper.addLogs("[Validate] account:RecordType.Name")
       expect(account[0].fetch('RecordType')['Name']).to eq "Mid Market"
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] account:Owner.Name")
       ownerAssign = accQueue.include? account[0].fetch('Owner')['Id']
       expect(ownerAssign).to eq true
       #expect(account[0].fetch('Owner')['Id']).to eq "#{accQueue.fetch('Member__c')}"
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] account:Number_of_Full_Time_Employees__c")
       expect(account[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] account:Interested_in_Number_of_Desks__c")
       expect(account[0].fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] account:Allow_Merge__c")
       expect(account[0].fetch('Allow_Merge__c')).to eq true
       @helper.postSuccessResult('2054')
    rescue Exception => e
       raise e
       @helper.postFailResult(e,'2054')
    end

   end

   it "C2055 : To Check Account Assignment for Record Type Enterprise and Deal type Transactional.", :'2055'=> 'true' do
     begin
       @helper.addLogs("C2055 : To Check Account Assignment for Record Type Enterprise and Deal type Transactional.",'2055')

       @testDataJSON['AccountAssignment']['tour'][0]['building']  = 'MEL-Bourke Street'
       @testDataJSON['AccountAssignment']['tour'][0]['companySize']  = '1200'
       @testDataJSON['AccountAssignment']['tour'][0]['numberOfDesks']  = '7'

       @helper.addLogs("[Step    ] booking tour from WebSite")
       emailId = @objAccAssignmentFromLead.createLead()
       expect(@driver.title).to match("Coworking Office")# Sambhav BKC | WeWork")

       @helper.addLogs("[Validate]  Lead should be created")
       lead = @objAccAssignmentFromLead.fetchLeadDetails(emailId)
          expect(lead[0]).to_not eq nil
       @helper.addLogs("[Expected]  Lead created successfully with emailId = #{emailId} \n[Result  ]  Success ")

       @helper.addLogs("[Step    ] logging to salesforce")
       @objAccAssignmentFromLead.loginToSalesforce

       @helper.addLogs("[Step    ] go to details page of created lead and Clicking on 'Manage/book Tour' button")
       expect(@objAccAssignmentFromLead.goToDetailPage(lead[0].fetch('Id'))).to eq true


       @helper.addLogs("[Validate] Checking Manage Tour page when user click on 'Manage/book tour' button")
       expect(@driver.title).to match("Manage Tours")
       @helper.addLogs("[Expected] Manage tour page opened successfully with Page Title= Manage Tours \n[Result  ]  Success")

       @helper.addLogs("[Step    ] filling all required fields and booked a tour")

       expect(@objAccAssignmentFromLead.bookTour(0,true)).to eq true

       @helper.addLogs("[Step    ] click on Create Account and Don't Merge")
       @objAccAssignmentFromLead.instance_variable_get(:@wait).until {@driver.find_element(:id ,"header43").displayed?}
       expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Merge",nil)).to eq true

       @helper.addLogs("[Step    ] checking fields...")

       @helper.addLogs("[Step    ] get building details of #{@testDataJSON['AccountAssignment']["tour"][0]["building"]}")
       building = @objAccAssignmentFromLead.fetchBuildingDetails(@testDataJSON['AccountAssignment']["tour"][0]["building"])
       expect(building[0]).to_not eq nil

       @helper.addLogs("[Step    ] get accQueue details")
       accQueue = @objAccAssignmentFromLead.fetAccOwnerQueue(building[0].fetch('Market__c'),'Enterprise Solutions')

       @helper.addLogs("[Step    ] get Contact details")
       contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
       expect(contact[0]).to_not eq nil

       @helper.addLogs("[Validate] contact:RecordType.Name")
       expect(contact[0].fetch('RecordType')['Name']).to eq "Enterprise Solutions"
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] contact:Owner.Id")

       ownerAssign = accQueue.include? contact[0].fetch('Owner')['Id']
       expect(ownerAssign).to eq true
       #expect(contact[0].fetch('Owner')['Id']).to eq "#{accQueue.fetch('Member__c')}"
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] contact:Number_of_Full_Time_Employees__c")
       expect(contact[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] contact:Looking_For_Number_Of_Desk__c")
       expect(contact[0].fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
       @helper.addLogs("[Result  ]  Success")

       puts "get Opportunity details"
       opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact[0].fetch('Id')}")
       expect(opportunity[0]).to_not eq nil

       @helper.addLogs("[Validate] opportunity:RecordType.Name")
       expect(opportunity[0].fetch('RecordType')['Name']).to eq "Enterprise Solutions"
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] opportunity:Deal_Type__c")
       expect(opportunity[0].fetch('Deal_Type__c')).to eq "Transactional"
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] opportunity:Owner.Id")
       ownerAssign = accQueue.include? opportunity[0].fetch('Owner')['Id']
       expect(ownerAssign).to eq true
       #expect(opportunity[0].fetch('Owner')['Id']).to eq "#{accQueue.fetch('Member__c')}"
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] opportunity:Quantity__c")
       expect(opportunity[0].fetch('Quantity__c').to_i).to eq @testDataJSON['AccountAssignment']['tour'][0]['numberOfDesks'].to_i
       @helper.addLogs("[Result  ]  Success")

       puts "get Account Details"
       account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact[0].fetch('Id')}")
       expect(account[0]).to_not eq nil

       @helper.addLogs("[Validate] account:RecordType.Name")
       expect(account[0].fetch('RecordType')['Name']).to eq "Enterprise Solutions"
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] account:Owner.Name")
       ownerAssign = accQueue.include? account[0].fetch('Owner')['Id']
       expect(ownerAssign).to eq true

       #expect(account[0].fetch('Owner')['Id']).to eq "#{accQueue.fetch('Member__c')}"
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] account:Number_of_Full_Time_Employees__c")
       expect(account[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] account:Interested_in_Number_of_Desks__c")
       expect(account[0].fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] account:Allow_Merge__c")
       expect(account[0].fetch('Allow_Merge__c')).to eq true
       @helper.postSuccessResult('2055')
    rescue Exception => e
       raise e
       @helper.postFailResult(e,'2055')
    end

   end

   it "C2056 : To Check Account Assignment for Record Type Enterprise and Deal type Relational.", :'2056'=> 'true' do
     begin
      @helper.addLogs("C2056 : To Check Account Assignment for Record Type Enterprise and Deal type Relational.",'2056')
       @testDataJSON['AccountAssignment']['tour'][0]['building']  = 'SYD-Martin Place'
       @testDataJSON['AccountAssignment']['tour'][0]['companySize']  = '1200'
       @testDataJSON['AccountAssignment']['tour'][0]['numberOfDesks']  = '15'

       @helper.addLogs("[Step    ] booking tour from WebSite")
       emailId = @objAccAssignmentFromLead.createLead()
       expect(@driver.title).to match("Coworking Office")# Sambhav BKC | WeWork")

       @helper.addLogs("[Validate]  Lead should be created")
       lead = @objAccAssignmentFromLead.fetchLeadDetails(emailId)
          expect(lead[0]).to_not eq nil
       @helper.addLogs("[Expected]  Lead created successfully with emailId = #{emailId} \n[Result  ]  Success ")

       @helper.addLogs("[Step    ] logging to salesforce")
       @objAccAssignmentFromLead.loginToSalesforce

       @helper.addLogs("[Step    ] go to details page of created lead and Clicking on 'Manage/book Tour' button")
       expect(@objAccAssignmentFromLead.goToDetailPage(lead[0].fetch('Id'))).to eq true


       @helper.addLogs("[Validate] Checking Manage Tour page when user click on 'Manage/book tour' button")
       expect(@driver.title).to match("Manage Tours")
       @helper.addLogs("[Expected] Manage tour page opened successfully with Page Title= Manage Tours \n[Result  ]  Success")

       @helper.addLogs("[Step    ] filling all required fields and booked a tour")

       expect(@objAccAssignmentFromLead.bookTour(0,true)).to eq true

       @helper.addLogs("[Step    ] click on Create Account and Don't Merge")
       @objAccAssignmentFromLead.instance_variable_get(:@wait).until {@driver.find_element(:id ,"header43").displayed?}
       expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Merge",nil)).to eq true

       @helper.addLogs("[Step    ] checking fields...")

       @helper.addLogs("[Step    ] get building details of #{@testDataJSON['AccountAssignment']["tour"][0]["building"]}")
       building = @objAccAssignmentFromLead.fetchBuildingDetails(@testDataJSON['AccountAssignment']["tour"][0]["building"])
       expect(building[0]).to_not eq nil


       @helper.addLogs("[Step    ] get accQueue details")
       accQueue = @objAccAssignmentFromLead.fetAccOwnerQueue(building[0].fetch('Market__c'),'Enterprise Solutions')

       #accQueue = @objAccAssignmentFromLead.fetAccOwnerQueue('a2V0G000003H8zoUAC','Enterprise Solutions')

       @helper.addLogs("[Step    ] get Contact details")
       contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
       #contact = @objAccAssignmentFromLead.fetchContactDetails("john.smith1004201828@example.com")
       expect(contact[0]).to_not eq nil

       @helper.addLogs("[Validate] contact:RecordType.Name")
       expect(contact[0].fetch('RecordType')['Name']).to eq "Enterprise Solutions"
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] contact:Owner.Id")
       puts accQueue.include? contact[0].fetch('Owner')['Id']
       ownerAssign = accQueue.include? contact[0].fetch('Owner')['Id']
       expect(ownerAssign).to eq true
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] contact:Number_of_Full_Time_Employees__c")
       expect(contact[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] contact:Looking_For_Number_Of_Desk__c")
       expect(contact[0].fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
       @helper.addLogs("[Result  ]  Success")

       puts "get Opportunity details"
       opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact[0].fetch('Id')}")
       expect(opportunity[0]).to_not eq nil


       @helper.addLogs("[Validate] opportunity:RecordType.Name")
       expect(opportunity[0].fetch('RecordType')['Name']).to eq "Enterprise Solutions"
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] opportunity:Deal_Type__c")
       expect(opportunity[0].fetch('Deal_Type__c')).to eq "Relational"
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] opportunity:Owner.Id")
       ownerAssign = accQueue.include? opportunity[0].fetch('Owner')['Id']
       expect(ownerAssign).to eq true
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] opportunity:Quantity__c")
       expect(opportunity[0].fetch('Quantity__c').to_i).to eq @testDataJSON['AccountAssignment']['tour'][0]['numberOfDesks'].to_i
       @helper.addLogs("[Result  ]  Success")

       puts "get Account Details"
       account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact[0].fetch('Id')}")
       expect(contact[0]).to_not eq nil

       @helper.addLogs("[Validate] account:RecordType.Name")
       expect(account[0].fetch('RecordType')['Name']).to eq "Enterprise Solutions"
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] account:Owner.Name")
       ownerAssign = accQueue.include? account[0].fetch('Owner')['Id']
       expect(ownerAssign).to eq true
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] account:Number_of_Full_Time_Employees__c")
       expect(account[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] account:Interested_in_Number_of_Desks__c")
       expect(account[0].fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] account:Allow_Merge__c")
       expect(account[0].fetch('Allow_Merge__c')).to eq true
       @helper.postSuccessResult('2056')
    rescue Exception => e
       raise e
       @helper.postFailResult(e,'2056')
    end

   end

   it "C2057 : To Check Account Assignment for Record Type Enterprise and Deal Type Strategic.", :'2057'=> 'true' do
     begin
       @helper.addLogs("C2057 : To Check Account Assignment for Record Type Enterprise and Deal type Strategic.","2057")

       @testDataJSON['AccountAssignment']['tour'][0]['building']  = 'SYD-Martin Place'
       @testDataJSON['AccountAssignment']['tour'][0]['companySize']  = '1200'
       @testDataJSON['AccountAssignment']['tour'][0]['numberOfDesks']  = '27'       
       
       @helper.addLogs("[Step    ] booking tour from WebSite")
       emailId = @objAccAssignmentFromLead.createLead()
       expect(@driver.title).to match("Coworking Office")# Sambhav BKC | WeWork")

       @helper.addLogs("[Validate]  Lead should be created")
       lead = @objAccAssignmentFromLead.fetchLeadDetails(emailId)
       expect(lead[0]).to_not eq nil
       @helper.addLogs("[Expected]  Lead created successfully with emailId = #{emailId} \n[Result  ]  Success ")

       @helper.addLogs("[Step    ] logging to salesforce")
       @objAccAssignmentFromLead.loginToSalesforce

       @helper.addLogs("[Step    ] go to details page of created lead and Clicking on 'Manage/book Tour' button")
       expect(@objAccAssignmentFromLead.goToDetailPage(lead[0].fetch('Id'))).to eq true


       @helper.addLogs("[Validate] Checking Manage Tour page when user click on 'Manage/book tour' button")
       expect(@driver.title).to match("Manage Tours")
       @helper.addLogs("[Expected] Manage tour page opened successfully with Page Title= Manage Tours \n[Result  ]  Success")

       @helper.addLogs("[Step    ] filling all required fields and booked a tour")

       expect(@objAccAssignmentFromLead.bookTour(0,true)).to eq true

       @helper.addLogs("[Step    ] click on Create Account and Don't Merge")
       @objAccAssignmentFromLead.instance_variable_get(:@wait).until {@driver.find_element(:id ,"header43").displayed?}
       expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Merge",nil)).to eq true

       @helper.addLogs("[Step    ] checking fields...")

       @helper.addLogs("[Step    ] get building details of #{@testDataJSON['AccountAssignment']["tour"][0]["building"]}")
       building = @objAccAssignmentFromLead.fetchBuildingDetails(@testDataJSON['AccountAssignment']["tour"][0]["building"])
       expect(building[0]).to_not eq nil


       @helper.addLogs("[Step    ] get accQueue details")
       accQueue = @objAccAssignmentFromLead.fetAccOwnerQueue(building[0].fetch('Market__c'),'Enterprise Solutions')

       #accQueue = @objAccAssignmentFromLead.fetAccOwnerQueue('a2V0G000003H8zoUAC','Enterprise Solutions')

       @helper.addLogs("[Step    ] get Contact details")
       contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
       #contact = @objAccAssignmentFromLead.fetchContactDetails("john.smith1004201828@example.com")
       expect(contact[0]).to_not eq nil

       @helper.addLogs("[Validate] contact:RecordType.Name")
       expect(contact[0].fetch('RecordType')['Name']).to eq "Enterprise Solutions"
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] contact:Owner.Id")
       puts accQueue.include? contact[0].fetch('Owner')['Id']
       ownerAssign = accQueue.include? contact[0].fetch('Owner')['Id']
       expect(ownerAssign).to eq true
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] contact:Number_of_Full_Time_Employees__c")
       expect(contact[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] contact:Looking_For_Number_Of_Desk__c")
       expect(contact[0].fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
       @helper.addLogs("[Result  ]  Success")

       puts "get Opportunity details"
       opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact[0].fetch('Id')}")
       expect(opportunity[0]).to_not eq nil


       @helper.addLogs("[Validate] opportunity:RecordType.Name")
       expect(opportunity[0].fetch('RecordType')['Name']).to eq "Enterprise Solutions"
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] opportunity:Deal_Type__c")
       expect(opportunity[0].fetch('Deal_Type__c')).to eq "Strategic"
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] opportunity:Owner.Id")
       ownerAssign = accQueue.include? opportunity[0].fetch('Owner')['Id']
       expect(ownerAssign).to eq true
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] opportunity:Quantity__c")
       expect(opportunity[0].fetch('Quantity__c').to_i).to eq @testDataJSON['AccountAssignment']['tour'][0]['numberOfDesks'].to_i
       @helper.addLogs("[Result  ]  Success")

       puts "get Account Details"
       account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact[0].fetch('Id')}")
       expect(account[0]).to_not eq nil

       @helper.addLogs("[Validate] account:RecordType.Name")
       expect(account[0].fetch('RecordType')['Name']).to eq "Enterprise Solutions"
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] account:Owner.Name")
       ownerAssign = accQueue.include? account[0].fetch('Owner')['Id']
       expect(ownerAssign).to eq true
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] account:Number_of_Full_Time_Employees__c")
       expect(account[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] account:Interested_in_Number_of_Desks__c")
       expect(account[0].fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
       @helper.addLogs("[Result  ]  Success")

       @helper.addLogs("[Validate] account:Allow_Merge__c")
       expect(account[0].fetch('Allow_Merge__c')).to eq true
       @helper.postSuccessResult('2057')
    rescue Exception => e
       raise e
       @helper.postFailResult(e,'2057')
    end
   end


 end

  context "by Add Opportunity with create acc and merge" do

    it "C2058 : To check account assignment for Record Type Consumer and Deal type Transactional.", :'20581'=> 'true' do
      begin
        @helper.addLogs("C2058 : To check account assignment for Record Type Consumer and Deal type Transactional.",'2058')

        @testDataJSON['AccountAssignment']['tour'][0]['companySize']  = '15'
        @testDataJSON['AccountAssignment']['tour'][0]['numberOfDesks']  = '5'
        @testDataJSON['AccountAssignment']['tour'][0]['building']  = 'MUM-BKC'

        @helper.addLogs("[Step    ] booking tour from WebSite")
        emailId = @objAccAssignmentFromLead.createLead()
        expect(@driver.title).to match("Coworking Office")# Sambhav BKC | WeWork")

        @helper.addLogs("[Validate]  Journey should be created")
        journey = @objAccAssignmentFromLead.fetchJourneyDetails(emailId)
        expect(journey[0]).to_not eq nil
        @helper.addLogs("[Expected]  Journey created successfully with emailId = #{emailId} \n[Result  ]  Success ")

        @helper.addLogs("[Step    ] logging to salesforce")
        expect(@objAccAssignmentFromLead.loginToSalesforce).to_not eq nil

        @helper.addLogs("[Step    ] go to details page of created Journey and Clicking on 'Add Opportunity' button")
        expect(@objAccAssignmentFromLead.goToDetailPageJourney(journey[0].fetch('Id'))).to eq true


        @helper.addLogs("[Validate] Checking Add Opportunity when user click on 'Add Opportunity' button")
        expect(@driver.title).to match("Add Opportunity")
        @helper.addLogs("[Expected] Manage tour page opened successfully with Page Title= Add Opportunity \n[Result  ]  Success")

        @helper.addLogs("[Step    ] filling all required fields and Add Opportunity")

        expect(@objAccAssignmentFromLead.addOpportunity()).to eq true

        @helper.addLogs("[Step    ] click on Create Account and Merge")
        expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Merge",nil)).to eq true

        @helper.addLogs("[Step    ] checking fields...")

        @helper.addLogs("[Step    ] get building details of #{@testDataJSON['AccountAssignment']["tour"][0]["building"]}")
        building = @objAccAssignmentFromLead.fetchBuildingDetails(@testDataJSON['AccountAssignment']["tour"][0]["building"])
        expect(building[0]).to_not eq nil

        @helper.addLogs("[Step    ] get Contact details")
        contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
        expect(contact[0]).to_not eq nil

        @helper.addLogs("[Validate] contact:RecordType.Name")
        expect(contact[0].fetch('RecordType')['Name']).to eq "Consumer"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] contact:Owner.Id")
        expect(contact[0].fetch('Owner')['Id']).to eq "#{building[0].fetch('Community_Lead__c')}"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] contact:Number_of_Full_Time_Employees__c")
        expect(contact[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] contact:Looking_For_Number_Of_Desk__c")
        expect(contact[0].fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        puts "get Opportunity details"
        opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact[0].fetch('Id')}")
        expect(opportunity[0]).to_not eq nil

        @helper.addLogs("[Validate] opportunity:RecordType.Name")
        expect(opportunity[0].fetch('RecordType')['Name']).to eq "Consumer"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] opportunity:Deal_Type__c")
        expect(opportunity[0].fetch('Deal_Type__c')).to eq "Transactional"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] opportunity:Owner.Id")
        expect(opportunity[0].fetch('Owner')['Id']).to eq "#{building[0].fetch('Community_Lead__c')}"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] opportunity:Quantity__c")
        expect(opportunity[0].fetch('Quantity__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        puts "get Account Details"
        account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact[0].fetch('Id')}")
        expect(account[0]).to_not eq nil

        @helper.addLogs("[Validate] account:RecordType.Name")
        expect(account[0].fetch('RecordType')['Name']).to eq "Consumer"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Owner.Id")
        expect(account[0].fetch('Owner')['Id']).to eq "#{building[0].fetch('Community_Lead__c')}"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Number_of_Full_Time_Employees__c")
        expect(account[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Interested_in_Number_of_Desks__c")
        expect(account[0].fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Allow_Merge__c")
        expect(account[0].fetch('Allow_Merge__c')).to eq true
        @helper.postSuccessResult('2058')
    rescue Exception => e
       raise e
       @helper.postFailResult(e,'2058')
    end

    end


    it "C2071 : To check account assignment for Record Type Consumer and Deal type Relational.", :'20711'=> 'true' do
      begin
        @helper.addLogs("C2071 : To check account assignment for Record Type Consumer and Deal type Relational.",'2071')

        @testDataJSON['AccountAssignment']['tour'][0]['companySize']  = '15'
        @testDataJSON['AccountAssignment']['tour'][0]['numberOfDesks']  = '13'
        @testDataJSON['AccountAssignment']['tour'][0]['building']  = 'MUM-BKC'

        @helper.addLogs("[Step    ] booking tour from WebSite")
        emailId = @objAccAssignmentFromLead.createLead()
        expect(@driver.title).to match("Coworking Office")# Sambhav BKC | WeWork")

=begin
        @helper.addLogs("[Validate]  Lead should be created")
        lead[0].fetch('Id') = @objAccAssignmentFromLead.fetchLeadDetails(emailId).fetch('Id')
        expect(lead[0].fetch('Id')).to_not eq 'nil'
        @helper.addLogs("[Expected]  Lead created successfully with emailId = #{emailId} \n[Result  ]  Success ")
=end

        @helper.addLogs("[Validate]  Journey should be created")
        journey = @objAccAssignmentFromLead.fetchJourneyDetails(emailId)
        expect(journey[0]).to_not eq nil
        @helper.addLogs("[Expected]  Journey created successfully with emailId = #{emailId} \n[Result  ]  Success ")

        @helper.addLogs("[Step    ] logging to salesforce")
        expect(@objAccAssignmentFromLead.loginToSalesforce).to_not eq nil

        @helper.addLogs("[Step    ] go to details page of created Journey and Clicking on 'Add Opportunity' button")
        expect(@objAccAssignmentFromLead.goToDetailPageJourney(journey[0].fetch('Id'))).to eq true


        @helper.addLogs("[Validate] Checking Add Opportunity when user click on 'Add Opportunity' button")
        expect(@driver.title).to match("Add Opportunity")
        @helper.addLogs("[Expected] Manage tour page opened successfully with Page Title= Add Opportunity \n[Result  ]  Success")

        @helper.addLogs("[Step    ] filling all required fields and Add Opportunity")

        expect(@objAccAssignmentFromLead.addOpportunity()).to eq true

        @helper.addLogs("[Step    ] click on Create Account and Merge")
        #@objAccAssignmentFromLead.instance_variable_get(:@wait).until {@driver.find_element(:id ,"header43").displayed?}
        expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Merge",nil)).to eq true

        @helper.addLogs("[Step    ] checking fields...")

        @helper.addLogs("[Step    ] get building details of #{@testDataJSON['AccountAssignment']["tour"][0]["building"]}")
        building = @objAccAssignmentFromLead.fetchBuildingDetails(@testDataJSON['AccountAssignment']["tour"][0]["building"])
        expect(building[0]).to_not eq nil

        @helper.addLogs("[Step    ] get Contact details")
        contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
        expect(contact[0]).to_not eq nil

        @helper.addLogs("[Validate] contact:RecordType.Name")
        expect(contact[0].fetch('RecordType')['Name']).to eq "Consumer"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] contact:Owner.Id")
        expect(contact[0].fetch('Owner')['Name']).to eq "#{building[0].fetch('Cluster_Sales_Lead_Name__c')}"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] contact:Number_of_Full_Time_Employees__c")
        expect(contact[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] contact:Looking_For_Number_Of_Desk__c")
        expect(contact[0].fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        puts "get Opportunity details"
        opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact[0].fetch('Id')}")

        @helper.addLogs("[Validate] opportunity:RecordType.Name")
        expect(opportunity[0].fetch('RecordType')['Name']).to eq "Consumer"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] opportunity:Deal_Type__c")
        expect(opportunity[0].fetch('Deal_Type__c')).to eq "Relational"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] opportunity:Owner.Id")
        expect(opportunity[0].fetch('Owner')['Name']).to eq "#{building[0].fetch('Cluster_Sales_Lead_Name__c')}"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] opportunity:Quantity__c")
        expect(opportunity[0].fetch('Quantity__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        puts "get Account Details"
        account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact[0].fetch('Id')}")

        @helper.addLogs("[Validate] account:RecordType.Name")
        expect(account[0].fetch('RecordType')['Name']).to eq "Consumer"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Owner.Name")
        expect(account[0].fetch('Owner')['Name']).to eq "#{building[0].fetch('Cluster_Sales_Lead_Name__c')}"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Number_of_Full_Time_Employees__c")
        expect(account[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Interested_in_Number_of_Desks__c")
        expect(account[0].fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Allow_Merge__c")
        expect(account[0].fetch('Allow_Merge__c')).to eq true
        @helper.postSuccessResult('2071')
    rescue Exception => e
       raise e
       @helper.postFailResult(e,'2071')
    end

    end


    it "C2072 : To check account assignment for Record Type Consumer and Deal type Strategic.", :'20721'=> 'true' do
      begin
        @helper.addLogs("C2072 : To check account assignment for Record Type Consumer and Deal type Strategic.",'2072')

        @testDataJSON['AccountAssignment']['tour'][0]['companySize']  = '15'
        @testDataJSON['AccountAssignment']['tour'][0]['numberOfDesks']  = '25'
        @testDataJSON['AccountAssignment']['tour'][0]['building']  = 'MUM-BKC'

        @helper.addLogs("[Step    ] booking tour from WebSite")
        emailId = @objAccAssignmentFromLead.createLead()
        expect(@driver.title).to match("Coworking Office")# Sambhav BKC | WeWork")

        @helper.addLogs("[Validate]  Journey should be created")
        journey = @objAccAssignmentFromLead.fetchJourneyDetails(emailId)
        expect(journey[0]).to_not eq 'nil'
        @helper.addLogs("[Expected]  Journey created successfully with emailId = #{emailId} \n[Result  ]  Success ")

        @helper.addLogs("[Step    ] logging to salesforce")
        expect(@objAccAssignmentFromLead.loginToSalesforce).to_not eq nil

        @helper.addLogs("[Step    ] go to details page of created Journey and Clicking on 'Add Opportunity' button")
        expect(@objAccAssignmentFromLead.goToDetailPageJourney(journey[0].fetch('Id'))).to eq true


        @helper.addLogs("[Validate] Checking Add Opportunity when user click on 'Add Opportunity' button")
        expect(@driver.title).to match("Add Opportunity")
        @helper.addLogs("[Expected] Manage tour page opened successfully with Page Title= Add Opportunity \n[Result  ]  Success")

        @helper.addLogs("[Step    ] filling all required fields and Add Opportunity")

        expect(@objAccAssignmentFromLead.addOpportunity()).to eq true

        @helper.addLogs("[Step    ] click on Create Account and Merge")
        @objAccAssignmentFromLead.instance_variable_get(:@wait).until {@driver.find_element(:id ,"header43").displayed?}
        expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Merge",nil)).to eq true

        @helper.addLogs("[Step    ] checking fields...")

        @helper.addLogs("[Step    ] get building details of #{@testDataJSON['AccountAssignment']["tour"][0]["building"]}")
        building = @objAccAssignmentFromLead.fetchBuildingDetails(@testDataJSON['AccountAssignment']["tour"][0]["building"])
        expect(building[0]).to_not eq nil

        @helper.addLogs("[Step    ] get accQueue details")
        accQueue = @objAccAssignmentFromLead.fetAccOwnerQueue(building[0].fetch('Market__c'),'Consumer')

        @helper.addLogs("[Step    ] get Contact details")
        contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
        expect(contact[0]).to_not eq nil

        @helper.addLogs("[Validate] contact:RecordType.Name")
        expect(contact[0].fetch('RecordType')['Name']).to eq "Consumer"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] contact:Owner.Id")
        ownerAssign = accQueue.include? contact[0].fetch('Owner')['Id']
        expect(ownerAssign).to eq true
        #expect(contact[0].fetch('Owner')['Id']).to eq "#{accQueue.fetch('Member__c')}"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] contact:Number_of_Full_Time_Employees__c")
        expect(contact[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] contact:Looking_For_Number_Of_Desk__c")
        expect(contact[0].fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        puts "get Opportunity details"
        opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact[0].fetch('Id')}")
        expect(opportunity[0]).to_not eq nil

        @helper.addLogs("[Validate] opportunity:RecordType.Name")
        expect(opportunity[0].fetch('RecordType')['Name']).to eq "Consumer"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] opportunity:Deal_Type__c")
        expect(opportunity[0].fetch('Deal_Type__c')).to eq "Strategic"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] opportunity:Owner.Id")
        ownerAssign = accQueue.include? opportunity[0].fetch('Owner')['Id']
        expect(ownerAssign).to eq true
        #expect(opportunity[0].fetch('Owner')['Id']).to eq "#{accQueue.fetch('Member__c')}"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] opportunity:Quantity__c")
        expect(opportunity[0].fetch('Quantity__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        puts "get Account Details"
        account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact[0].fetch('Id')}")
        expect(account[0]).to_not eq nil

        @helper.addLogs("[Validate] account:RecordType.Name")
        expect(account[0].fetch('RecordType')['Name']).to eq "Consumer"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Owner.Name")
        ownerAssign = accQueue.include? account[0].fetch('Owner')['Id']
        expect(ownerAssign).to eq true

        #expect(account[0].fetch('Owner')['Id']).to eq "#{accQueue.fetch('Member__c')}"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Number_of_Full_Time_Employees__c")
        expect(account[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Interested_in_Number_of_Desks__c")
        expect(account[0].fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Allow_Merge__c")
        expect(account[0].fetch('Allow_Merge__c')).to eq true
        @helper.postSuccessResult('2072')
    rescue Exception => e
       raise e
       @helper.postFailResult(e,'2072')
    end
    end


    it "C2075 : To check account assignment for Record Type Consumer and Deal type Strategic.(Queue is not present in the Account Queue Setting)", :'12121'=> 'true'  do
      begin
        @helper.addLogs("C2075 : To check account assignment for Record Type Consumer and Deal type Strategic.(Queue is not present in the Account Queue Setting).",'2075')

        @testDataJSON['AccountAssignment']['tour'][0]['companySize']  = '15'
        @testDataJSON['AccountAssignment']['tour'][0]['numberOfDesks']  = '25'
        @testDataJSON['AccountAssignment']['tour'][0]['building']  = 'SYD-Martin Place'

        @helper.addLogs("[Step    ] booking tour from WebSite")
        emailId = @objAccAssignmentFromLead.createLead()
        expect(@driver.title).to match("Coworking Office")# Sambhav BKC | WeWork")

        @helper.addLogs("[Validate]  Journey should be created")
        journey = @objAccAssignmentFromLead.fetchJourneyDetails(emailId)
        expect(journey[0]).to_not eq nil
        @helper.addLogs("[Expected]  Journey created successfully with emailId = #{emailId} \n[Result  ]  Success ")

        @helper.addLogs("[Step    ] logging to salesforce")
        expect(@objAccAssignmentFromLead.loginToSalesforce).to_not eq nil

        @helper.addLogs("[Step    ] go to details page of created Journey and Clicking on 'Add Opportunity' button")
        expect(@objAccAssignmentFromLead.goToDetailPageJourney(journey[0].fetch('Id'))).to eq true


        @helper.addLogs("[Validate] Checking Add Opportunity when user click on 'Add Opportunity' button")
        expect(@driver.title).to match("Add Opportunity")
        @helper.addLogs("[Expected] Manage tour page opened successfully with Page Title= Add Opportunity \n[Result  ]  Success")

        @helper.addLogs("[Step    ] filling all required fields and Add Opportunity")

        expect(@objAccAssignmentFromLead.addOpportunity()).to eq true

        @helper.addLogs("[Step    ] click on Create Account and Merge")

        #@objAccAssignmentFromLead.instance_variable_get(:@wait).until {@driver.find_element(:id ,"header43").displayed?}
        expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Merge",nil)).to eq true

        @helper.addLogs("[Step    ] checking fields...")

        @helper.addLogs("[Step    ] get building details of #{@testDataJSON['AccountAssignment']["tour"][0]["building"]}")
        building = @objAccAssignmentFromLead.fetchBuildingDetails(@testDataJSON['AccountAssignment']["tour"][0]["building"])
        expect(building[0]).to_not eq nil

        #@helper.addLogs("[Step    ] get accQueue details")
        #accQueue = @objAccAssignmentFromLead.fetAccOwnerQueue(building[0].fetch('Market__c'),'Consumer')

        @helper.addLogs("[Step    ] get Contact details")
        contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
        expect(contact[0]).to_not eq nil

        @helper.addLogs("[Validate] contact:RecordType.Name")
        expect(contact[0].fetch('RecordType')['Name']).to eq "Consumer"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] contact:Owner.Id")
        expect(contact[0].fetch('Owner')['Id']).to eq "005F0000003KmbwIAC"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] contact:Number_of_Full_Time_Employees__c")
        expect(contact[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] contact:Looking_For_Number_Of_Desk__c")
        expect(contact[0].fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        puts "get Opportunity details"
        opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact[0].fetch('Id')}")

        @helper.addLogs("[Validate] opportunity:RecordType.Name")
        expect(opportunity[0].fetch('RecordType')['Name']).to eq "Consumer"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] opportunity:Deal_Type__c")
        expect(opportunity[0].fetch('Deal_Type__c')).to eq "Strategic"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] opportunity:Owner.Id")
        expect(opportunity[0].fetch('Owner')['Id']).to eq "005F0000003KmbwIAC"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] opportunity:Quantity__c")
        expect(opportunity[0].fetch('Quantity__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        puts "get Account Details"
        account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact[0].fetch('Id')}")

        @helper.addLogs("[Validate] account:RecordType.Name")
        expect(account[0].fetch('RecordType')['Name']).to eq "Consumer"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Owner.Name")
        expect(account[0].fetch('Owner')['Id']).to eq "005F0000003KmbwIAC"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Number_of_Full_Time_Employees__c")
        expect(account[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Interested_in_Number_of_Desks__c")
        expect(account[0].fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Allow_Merge__c")
        expect(account[0].fetch('Allow_Merge__c')).to eq true
        @helper.postSuccessResult('2075')
    rescue Exception => e
       raise e
       @helper.postFailResult(e,'2075')
    end

    end

    it "C2075 : To Check Account assignment for Record Type Mid-Market and Deal type Transactional.", :'20751'=> 'true' do
      begin
        @helper.addLogs("C2074 : To Check Account assignment for Record Type Mid-Market and Deal type Transactional.",'2075')
        @testDataJSON['AccountAssignment']['tour'][0]['building']  = 'SYD-Martin Place'
        @testDataJSON['AccountAssignment']['tour'][0]['companySize']  = '24'
        @testDataJSON['AccountAssignment']['tour'][0]['numberOfDesks']  = '7'

        @helper.addLogs("[Step    ] booking tour from WebSite")
        emailId = @objAccAssignmentFromLead.createLead()
        expect(@driver.title).to match("Coworking Office")# Sambhav BKC | WeWork")

        @helper.addLogs("[Validate]  Journey should be created")
        journey = @objAccAssignmentFromLead.fetchJourneyDetails(emailId)
        expect(journey[0]).to_not eq nil
        @helper.addLogs("[Expected]  Journey created successfully with emailId = #{emailId} \n[Result  ]  Success ")

        @helper.addLogs("[Step    ] logging to salesforce")
        expect(@objAccAssignmentFromLead.loginToSalesforce).to_not eq nil

        @helper.addLogs("[Step    ] go to details page of created Journey and Clicking on 'Add Opportunity' button")
        expect(@objAccAssignmentFromLead.goToDetailPageJourney(journey[0].fetch('Id'))).to eq true


        @helper.addLogs("[Validate] Checking Add Opportunity when user click on 'Add Opportunity' button")
        expect(@driver.title).to match("Add Opportunity")
        @helper.addLogs("[Expected] Manage tour page opened successfully with Page Title= Add Opportunity \n[Result  ]  Success")

        @helper.addLogs("[Step    ] filling all required fields and Add Opportunity")
        expect(@objAccAssignmentFromLead.addOpportunity()).to eq true

        @helper.addLogs("[Step    ] click on Create Account and Merge")
        #@objAccAssignmentFromLead.instance_variable_get(:@wait).until {@driver.find_element(:id ,"header43").displayed?}
        expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Merge",nil)).to eq true

        @helper.addLogs("[Step    ] checking fields...")

        @helper.addLogs("[Step    ] get building details of #{@testDataJSON['AccountAssignment']["tour"][0]["building"]}")
        building = @objAccAssignmentFromLead.fetchBuildingDetails(@testDataJSON['AccountAssignment']["tour"][0]["building"])
        expect(building[0]).to_not eq nil

        @helper.addLogs("[Step    ] get Contact details")
        contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
        expect(contact[0]).to_not eq nil

        @helper.addLogs("[Validate] contact:RecordType.Name")
        expect(contact[0].fetch('RecordType')['Name']).to eq "Mid Market"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] contact:Owner.Id")
        expect(contact[0].fetch('Owner')['Id']).to eq "#{building[0].fetch('Community_Lead__c')}"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] contact:Number_of_Full_Time_Employees__c")
        expect(contact[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] contact:Looking_For_Number_Of_Desk__c")
        expect(contact[0].fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        puts "get Opportunity details"
        opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact[0].fetch('Id')}")

        @helper.addLogs("[Validate] opportunity:RecordType.Name")
        expect(opportunity[0].fetch('RecordType')['Name']).to eq "Mid Market"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] opportunity:Deal_Type__c")
        expect(opportunity[0].fetch('Deal_Type__c')).to eq "Transactional"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] opportunity:Owner.Id")
        expect(opportunity[0].fetch('Owner')['Id']).to eq "#{building[0].fetch('Community_Lead__c')}"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] opportunity:Quantity__c")
        expect(opportunity[0].fetch('Quantity__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        puts "get Account Details"
        account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact[0].fetch('Id')}")

        @helper.addLogs("[Validate] account:RecordType.Name")
        expect(account[0].fetch('RecordType')['Name']).to eq "Mid Market"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Owner.Id")
        expect(account[0].fetch('Owner')['Id']).to eq "#{building[0].fetch('Community_Lead__c')}"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Number_of_Full_Time_Employees__c")
        expect(account[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Interested_in_Number_of_Desks__c")
        expect(account[0].fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Allow_Merge__c")
        expect(account[0].fetch('Allow_Merge__c')).to eq true
        @helper.postSuccessResult('2075')
    rescue Exception => e
       raise e
       @helper.postFailResult(e,'2075')
    end

    end

    it "C2074 : To Check Account Assignment for Record type Mid-Market and Deal type Relational.", :'20741'=> 'true' do
      begin
        @helper.addLogs("C2074 : To Check Account Assignment for Record type Mid-Market and Deal type Relational.",'2074')

        @testDataJSON['AccountAssignment']['tour'][0]['building']  = 'SYD-Martin Place'
        @testDataJSON['AccountAssignment']['tour'][0]['companySize']  = '24'
        @testDataJSON['AccountAssignment']['tour'][0]['numberOfDesks']  = '15'

        @helper.addLogs("[Step    ] booking tour from WebSite")
        emailId = @objAccAssignmentFromLead.createLead()
        expect(@driver.title).to match("Coworking Office Sambhav BKC | WeWork")

        @helper.addLogs("[Validate]  Journey should be created")
        journey = @objAccAssignmentFromLead.fetchJourneyDetails(emailId)
        expect(journey[0]).to_not eq nil
        @helper.addLogs("[Expected]  Journey created successfully with emailId = #{emailId} \n[Result  ]  Success ")

        @helper.addLogs("[Step    ] logging to salesforce")
        expect(@objAccAssignmentFromLead.loginToSalesforce).to_not eq nil

        @helper.addLogs("[Step    ] go to details page of created Journey and Clicking on 'Add Opportunity' button")
        expect(@objAccAssignmentFromLead.goToDetailPageJourney(journey[0].fetch('Id'))).to eq true


        @helper.addLogs("[Validate] Checking Add Opportunity when user click on 'Add Opportunity' button")
        expect(@driver.title).to match("Add Opportunity")
        @helper.addLogs("[Expected] Manage tour page opened successfully with Page Title= Add Opportunity \n[Result  ]  Success")

        @helper.addLogs("[Step    ] filling all required fields and Add Opportunity")

        expect(@objAccAssignmentFromLead.addOpportunity()).to eq true

        @helper.addLogs("[Step    ] click on Create Account and Merge")
        #@objAccAssignmentFromLead.instance_variable_get(:@wait).until {@driver.find_element(:id ,"header43").displayed?}
        expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Merge",nil)).to eq true

        @helper.addLogs("[Step    ] checking fields...")

        @helper.addLogs("[Step    ] get building details of #{@testDataJSON['AccountAssignment']["tour"][0]["building"]}")
        building = @objAccAssignmentFromLead.fetchBuildingDetails(@testDataJSON['AccountAssignment']["tour"][0]["building"])
        expect(building[0]).to_not eq nil

        @helper.addLogs("[Step    ] get Contact details")
        contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
        expect(contact[0]).to_not eq nil

        @helper.addLogs("[Validate] contact:RecordType.Name")
        expect(contact[0].fetch('RecordType')['Name']).to eq "Mid Market"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] contact:Owner.Id")
        expect(contact[0].fetch('Owner')['Name']).to eq "#{building[0].fetch('Cluster_Sales_Lead_Name__c')}"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] contact:Number_of_Full_Time_Employees__c")
        expect(contact[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] contact:Looking_For_Number_Of_Desk__c")
        expect(contact[0].fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        puts "get Opportunity details"
        opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact[0].fetch('Id')}")
        expect(opportunity[0]).to_not eq nil

        @helper.addLogs("[Validate] opportunity:RecordType.Name")
        expect(opportunity[0].fetch('RecordType')['Name']).to eq "Mid Market"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] opportunity:Deal_Type__c")
        expect(opportunity[0].fetch('Deal_Type__c')).to eq "Relational"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] opportunity:Owner.Id")
        expect(opportunity[0].fetch('Owner')['Name']).to eq "#{building[0].fetch('Cluster_Sales_Lead_Name__c')}"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] opportunity:Quantity__c")
        expect(opportunity[0].fetch('Quantity__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        puts "get Account Details"
        account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact[0].fetch('Id')}")
        expect(account[0]).to_not eq nil

        @helper.addLogs("[Validate] account:RecordType.Name")
        expect(account[0].fetch('RecordType')['Name']).to eq "Mid Market"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Owner.Name")
        expect(account[0].fetch('Owner')['Name']).to eq "#{building[0].fetch('Cluster_Sales_Lead_Name__c')}"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Number_of_Full_Time_Employees__c")
        expect(account[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Interested_in_Number_of_Desks__c")
        expect(account[0].fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Allow_Merge__c")
        expect(account[0].fetch('Allow_Merge__c')).to eq true
        @helper.postSuccessResult('2074')
    rescue Exception => e
       raise e
       @helper.postFailResult(e,'2074')
    end

    end

    it "C2064 : To Check Account Assignment from Record type Mid-Market and Deal Type Strategic.", :'20641'=> 'true' do
      begin
        @helper.addLogs("C2064 : To check account assignment for Record Type Consumer and Deal type Relational.",'2064')

        @testDataJSON['AccountAssignment']['tour'][0]['building']  = 'SYD-Martin Place'
        @testDataJSON['AccountAssignment']['tour'][0]['companySize']  = '24'
        @testDataJSON['AccountAssignment']['tour'][0]['numberOfDesks']  = '27'

        @helper.addLogs("[Step    ] booking tour from WebSite")
        emailId = @objAccAssignmentFromLead.createLead()
        expect(@driver.title).to match("Coworking Office")# Sambhav BKC | WeWork")

        @helper.addLogs("[Validate]  Journey should be created")
        journey = @objAccAssignmentFromLead.fetchJourneyDetails(emailId)
        expect(journey[0]).to_not eq nil
        @helper.addLogs("[Expected]  Journey created successfully with emailId = #{emailId} \n[Result  ]  Success ")

        @helper.addLogs("[Step    ] logging to salesforce")
        expect(@objAccAssignmentFromLead.loginToSalesforce).to_not eq nil

        @helper.addLogs("[Step    ] go to details page of created Journey and Clicking on 'Add Opportunity' button")
        expect(@objAccAssignmentFromLead.goToDetailPageJourney(journey[0].fetch('Id'))).to eq true


        @helper.addLogs("[Validate] Checking Add Opportunity when user click on 'Add Opportunity' button")
        expect(@driver.title).to match("Add Opportunity")
        @helper.addLogs("[Expected] Manage tour page opened successfully with Page Title= Add Opportunity \n[Result  ]  Success")

        @helper.addLogs("[Step    ] filling all required fields and Add Opportunity")

        expect(@objAccAssignmentFromLead.addOpportunity()).to eq true

        @helper.addLogs("[Step    ] click on Create Account and Merge")
        @objAccAssignmentFromLead.instance_variable_get(:@wait).until {@driver.find_element(:id ,"header43").displayed?}
        expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Merge",nil)).to eq true

        @helper.addLogs("[Step    ] checking fields...")

        @helper.addLogs("[Step    ] get building details of #{@testDataJSON['AccountAssignment']["tour"][0]["building"]}")
        building = @objAccAssignmentFromLead.fetchBuildingDetails(@testDataJSON['AccountAssignment']["tour"][0]["building"])
        expect(building[0]).to_not eq nil

        @helper.addLogs("[Step    ] get accQueue details")

        accQueue = @objAccAssignmentFromLead.fetAccOwnerQueue(building[0].fetch('Market__c'),'Mid Market')

        @helper.addLogs("[Step    ] get Contact details")
        contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
        expect(contact[0]).to_not eq nil

        @helper.addLogs("[Validate] contact:RecordType.Name")
        expect(contact[0].fetch('RecordType')['Name']).to eq "Mid Market"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] contact:Owner.Id")

        puts accQueue.include? contact[0].fetch('Owner')['Id']
        ownerAssign = accQueue.include? contact[0].fetch('Owner')['Id']
        expect(ownerAssign).to eq true

        #expect(contact[0].fetch('Owner')['Id']).to eq "#{accQueue.fetch('Member__c')}"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] contact:Number_of_Full_Time_Employees__c")
        expect(contact[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] contact:Looking_For_Number_Of_Desk__c")
        expect(contact[0].fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        puts "get Opportunity details"
        opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact[0].fetch('Id')}")
        expect(opportunity[0]).to_not eq nil

        @helper.addLogs("[Validate] opportunity:RecordType.Name")
        expect(opportunity[0].fetch('RecordType')['Name']).to eq "Mid Market"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] opportunity:Deal_Type__c")
        expect(opportunity[0].fetch('Deal_Type__c')).to eq "Strategic"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] opportunity:Owner.Id")
        ownerAssign = accQueue.include? opportunity[0].fetch('Owner')['Id']
        expect(ownerAssign).to eq true

        #expect(opportunity[0].fetch('Owner')['Id']).to eq "#{accQueue.fetch('Member__c')}"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] opportunity:Quantity__c")
        expect(opportunity[0].fetch('Quantity__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        puts "get Account Details"
        account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact[0].fetch('Id')}")
        expect(account[0]).to_not eq nil

        @helper.addLogs("[Validate] account:RecordType.Name")
        expect(account[0].fetch('RecordType')['Name']).to eq "Mid Market"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Owner.Name")
        ownerAssign = accQueue.include? account[0].fetch('Owner')['Id']
        expect(ownerAssign).to eq true
        #expect(account[0].fetch('Owner')['Id']).to eq "#{accQueue.fetch('Member__c')}"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Number_of_Full_Time_Employees__c")
        expect(account[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Interested_in_Number_of_Desks__c")
        expect(account[0].fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Allow_Merge__c")
        expect(account[0].fetch('Allow_Merge__c')).to eq true
        @helper.postSuccessResult('2064')
    rescue Exception => e
       raise e
       @helper.postFailResult(e,'2064')
    end

    end

    it "C2065 : To Check Account Assignment for Record Type Enterprise and Deal type Transactional.", :'20651'=> 'true' do
      begin
        @helper.addLogs("C2065 : To Check Account Assignment for Record Type Enterprise and Deal type Transactional.",'2065')

        @testDataJSON['AccountAssignment']['tour'][0]['building']  = 'MEL-Bourke Street'
        @testDataJSON['AccountAssignment']['tour'][0]['companySize']  = '1200'
        @testDataJSON['AccountAssignment']['tour'][0]['numberOfDesks']  = '7'

        @helper.addLogs("[Step    ] booking tour from WebSite")
        emailId = @objAccAssignmentFromLead.createLead()
        expect(@driver.title).to match("Coworking Office")# Sambhav BKC | WeWork")

        @helper.addLogs("[Validate]  Journey should be created")
        journey = @objAccAssignmentFromLead.fetchJourneyDetails(emailId)
        expect(journey[0]).to_not eq nil
        @helper.addLogs("[Expected]  Journey created successfully with emailId = #{emailId} \n[Result  ]  Success ")

        @helper.addLogs("[Step    ] logging to salesforce")
        expect(@objAccAssignmentFromLead.loginToSalesforce).to_not eq nil

        @helper.addLogs("[Step    ] go to details page of created Journey and Clicking on 'Add Opportunity' button")
        expect(@objAccAssignmentFromLead.goToDetailPageJourney(journey[0].fetch('Id'))).to eq true


        @helper.addLogs("[Validate] Checking Add Opportunity when user click on 'Add Opportunity' button")
        expect(@driver.title).to match("Add Opportunity")
        @helper.addLogs("[Expected] Manage tour page opened successfully with Page Title= Add Opportunity \n[Result  ]  Success")

        @helper.addLogs("[Step    ] filling all required fields and Add Opportunity")

        expect(@objAccAssignmentFromLead.addOpportunity()).to eq true

        @helper.addLogs("[Step    ] click on Create Account and Merge")
        @objAccAssignmentFromLead.instance_variable_get(:@wait).until {@driver.find_element(:id ,"header43").displayed?}
        expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Merge",nil)).to eq true

        @helper.addLogs("[Step    ] checking fields...")
        @helper.addLogs("[Step    ] get building details of #{@testDataJSON['AccountAssignment']["tour"][0]["building"]}")
        building = @objAccAssignmentFromLead.fetchBuildingDetails(@testDataJSON['AccountAssignment']["tour"][0]["building"])
        expect(building[0]).to_not eq nil

        @helper.addLogs("[Step    ] get accQueue details")
        accQueue = @objAccAssignmentFromLead.fetAccOwnerQueue(building[0].fetch('Market__c'),'Enterprise Solutions')

        @helper.addLogs("[Step    ] get Contact details")
        contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
        expect(contact[0]).to_not eq nil

        @helper.addLogs("[Validate] contact:RecordType.Name")
        expect(contact[0].fetch('RecordType')['Name']).to eq "Enterprise Solutions"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] contact:Owner.Id")

        ownerAssign = accQueue.include? contact[0].fetch('Owner')['Id']
        expect(ownerAssign).to eq true
        #expect(contact[0].fetch('Owner')['Id']).to eq "#{accQueue.fetch('Member__c')}"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] contact:Number_of_Full_Time_Employees__c")
        expect(contact[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] contact:Looking_For_Number_Of_Desk__c")
        expect(contact[0].fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        puts "get Opportunity details"
        opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact[0].fetch('Id')}")
        expect(opportunity[0]).to_not eq nil

        @helper.addLogs("[Validate] opportunity:RecordType.Name")
        expect(opportunity[0].fetch('RecordType')['Name']).to eq "Enterprise Solutions"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] opportunity:Deal_Type__c")
        expect(opportunity[0].fetch('Deal_Type__c')).to eq "Transactional"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] opportunity:Owner.Id")
        ownerAssign = accQueue.include? opportunity[0].fetch('Owner')['Id']
        expect(ownerAssign).to eq true
        #expect(opportunity[0].fetch('Owner')['Id']).to eq "#{accQueue.fetch('Member__c')}"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] opportunity:Quantity__c")
        expect(opportunity[0].fetch('Quantity__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        puts "get Account Details"
        account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact[0].fetch('Id')}")
        expect(account[0]).to_not eq nil

        @helper.addLogs("[Validate] account:RecordType.Name")
        expect(account[0].fetch('RecordType')['Name']).to eq "Enterprise Solutions"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Owner.Name")
        ownerAssign = accQueue.include? account[0].fetch('Owner')['Id']
        expect(ownerAssign).to eq true

        #expect(account[0].fetch('Owner')['Id']).to eq "#{accQueue.fetch('Member__c')}"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Number_of_Full_Time_Employees__c")
        expect(account[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Interested_in_Number_of_Desks__c")
        expect(account[0].fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Allow_Merge__c")
        expect(account[0].fetch('Allow_Merge__c')).to eq true
        @helper.postSuccessResult('2064')
    rescue Exception => e
       raise e
       @helper.postFailResult(e,'2064')
    end

    end

    it "C2066 : To Check Account Assignment for Record Type Enterprise and Deal type Relational.", :'20661'=> 'true' do
      begin
        @helper.addLogs("C2056 : To Check Account Assignment for Record Type Enterprise and Deal type Relational.",'2066')
        @testDataJSON['AccountAssignment']['tour'][0]['building']  = 'SYD-Martin Place'
        @testDataJSON['AccountAssignment']['tour'][0]['companySize']  = '1200'
        @testDataJSON['AccountAssignment']['tour'][0]['numberOfDesks']  = '15'
        
        @helper.addLogs("[Step    ] booking tour from WebSite")
        emailId = @objAccAssignmentFromLead.createLead()
        expect(@driver.title).to match("Coworking Office")# Sambhav BKC | WeWork")

        @helper.addLogs("[Validate]  Journey should be created")
        journey = @objAccAssignmentFromLead.fetchJourneyDetails(emailId)
        expect(journey).to_not eq nil
        @helper.addLogs("[Expected]  Journey created successfully with emailId = #{emailId} \n[Result  ]  Success ")

        @helper.addLogs("[Step    ] logging to salesforce")
        expect(@objAccAssignmentFromLead.loginToSalesforce).to_not eq nil

        @helper.addLogs("[Step    ] go to details page of created Journey and Clicking on 'Add Opportunity' button")
        expect(@objAccAssignmentFromLead.goToDetailPageJourney(journey[0].fetch('Id'))).to eq true


        @helper.addLogs("[Validate] Checking Add Opportunity when user click on 'Add Opportunity' button")
        expect(@driver.title).to match("Add Opportunity")
        @helper.addLogs("[Expected] Manage tour page opened successfully with Page Title= Add Opportunity \n[Result  ]  Success")

        @helper.addLogs("[Step    ] filling all required fields and Add Opportunity")

        expect(@objAccAssignmentFromLead.addOpportunity()).to eq true

        @helper.addLogs("[Step    ] click on Create Account and Merge")
        @objAccAssignmentFromLead.instance_variable_get(:@wait).until {@driver.find_element(:id ,"header43").displayed?}
        expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Merge",nil)).to eq true

        @helper.addLogs("[Step    ] checking fields...")

        @helper.addLogs("[Step    ] get building details of #{@testDataJSON['AccountAssignment']["tour"][0]["building"]}")
        building = @objAccAssignmentFromLead.fetchBuildingDetails(@testDataJSON['AccountAssignment']["tour"][0]["building"])
        expect(building[0]).to_not eq nil


        @helper.addLogs("[Step    ] get accQueue details")
        accQueue = @objAccAssignmentFromLead.fetAccOwnerQueue(building[0].fetch('Market__c'),'Enterprise Solutions')

        #accQueue = @objAccAssignmentFromLead.fetAccOwnerQueue('a2V0G000003H8zoUAC','Enterprise Solutions')

        @helper.addLogs("[Step    ] get Contact details")
        contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
        #contact = @objAccAssignmentFromLead.fetchContactDetails("john.smith1004201828@example.com")
        expect(contact[0]).to_not eq nil

        @helper.addLogs("[Validate] contact:RecordType.Name")
        expect(contact[0].fetch('RecordType')['Name']).to eq "Enterprise Solutions"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] contact:Owner.Id")
        puts accQueue.include? contact[0].fetch('Owner')['Id']
        ownerAssign = accQueue.include? contact[0].fetch('Owner')['Id']
        expect(ownerAssign).to eq true
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] contact:Number_of_Full_Time_Employees__c")
        expect(contact[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] contact:Looking_For_Number_Of_Desk__c")
        expect(contact[0].fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        puts "get Opportunity details"
        opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact[0].fetch('Id')}")
        expect(opportunity[0]).to_not eq nil

        @helper.addLogs("[Validate] opportunity:RecordType.Name")
        expect(opportunity[0].fetch('RecordType')['Name']).to eq "Enterprise Solutions"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] opportunity:Deal_Type__c")
        expect(opportunity[0].fetch('Deal_Type__c')).to eq "Relational"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] opportunity:Owner.Id")
        ownerAssign = accQueue.include? opportunity[0].fetch('Owner')['Id']
        expect(ownerAssign).to eq true
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] opportunity:Quantity__c")
        expect(opportunity[0].fetch('Quantity__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        puts "get Account Details"
        account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact[0].fetch('Id')}")

        @helper.addLogs("[Validate] account:RecordType.Name")
        expect(account[0].fetch('RecordType')['Name']).to eq "Enterprise Solutions"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Owner.Name")
        ownerAssign = accQueue.include? account[0].fetch('Owner')['Id']
        expect(ownerAssign).to eq true
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Number_of_Full_Time_Employees__c")
        expect(account[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Interested_in_Number_of_Desks__c")
        expect(account[0].fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Allow_Merge__c")
        expect(account[0].fetch('Allow_Merge__c')).to eq true
        @helper.postSuccessResult('2066')
    rescue Exception => e
       raise e
       @helper.postFailResult(e,'2066')
    end

    end

    it "C2067 : To Check Account Assignment for Record Type Enterprise and Deal Type Strategic.", :'20671'=> 'true' do
      begin
        @helper.addLogs("C2057 : To Check Account Assignment for Record Type Enterprise and Deal type Strategic.",'2067')
        @testDataJSON['AccountAssignment']['tour'][0]['building']  = 'SYD-Martin Place'
        @testDataJSON['AccountAssignment']['tour'][0]['companySize']  = '1200'
        @testDataJSON['AccountAssignment']['tour'][0]['numberOfDesks']  = '27'

        @helper.addLogs("[Step    ] booking tour from WebSite")
        emailId = @objAccAssignmentFromLead.createLead()
        expect(@driver.title).to match("Coworking Office")# Sambhav BKC | WeWork")

        @helper.addLogs("[Validate]  Journey should be created")
        journey = @objAccAssignmentFromLead.fetchJourneyDetails(emailId)
        expect(journey[0]).to_not eq nil
        @helper.addLogs("[Expected]  Journey created successfully with emailId = #{emailId} \n[Result  ]  Success ")

        @helper.addLogs("[Step    ] logging to salesforce")
        expect(@objAccAssignmentFromLead.loginToSalesforce).to_not eq nil

        @helper.addLogs("[Step    ] go to details page of created Journey and Clicking on 'Add Opportunity' button")
        expect(@objAccAssignmentFromLead.goToDetailPageJourney(journey[0].fetch('Id'))).to eq true


        @helper.addLogs("[Validate] Checking Add Opportunity when user click on 'Add Opportunity' button")
        expect(@driver.title).to match("Add Opportunity")
        @helper.addLogs("[Expected] Manage tour page opened successfully with Page Title= Add Opportunity \n[Result  ]  Success")

        @helper.addLogs("[Step    ] filling all required fields and Add Opportunity")

        expect(@objAccAssignmentFromLead.addOpportunity()).to eq true

        @helper.addLogs("[Step    ] click on Create Account and Merge")
        @objAccAssignmentFromLead.instance_variable_get(:@wait).until {@driver.find_element(:id ,"header43").displayed?}
        expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Merge",nil)).to eq true

        @helper.addLogs("[Step    ] checking fields...")

        @helper.addLogs("[Step    ] get building details of #{@testDataJSON['AccountAssignment']["tour"][0]["building"]}")
        building = @objAccAssignmentFromLead.fetchBuildingDetails(@testDataJSON['AccountAssignment']["tour"][0]["building"])
        expect(building[0]).to_not eq nil


        @helper.addLogs("[Step    ] get accQueue details")
        accQueue = @objAccAssignmentFromLead.fetAccOwnerQueue(building[0].fetch('Market__c'),'Enterprise Solutions')

        #accQueue = @objAccAssignmentFromLead.fetAccOwnerQueue('a2V0G000003H8zoUAC','Enterprise Solutions')

        @helper.addLogs("[Step    ] get Contact details")
        contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
        #contact = @objAccAssignmentFromLead.fetchContactDetails("john.smith1004201828@example.com")
        expect(contact[0]).to_not eq nil

        @helper.addLogs("[Validate] contact:RecordType.Name")
        expect(contact[0].fetch('RecordType')['Name']).to eq "Enterprise Solutions"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] contact:Owner.Id")
        puts accQueue.include? contact[0].fetch('Owner')['Id']
        ownerAssign = accQueue.include? contact[0].fetch('Owner')['Id']
        expect(ownerAssign).to eq true
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] contact:Number_of_Full_Time_Employees__c")
        expect(contact[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] contact:Looking_For_Number_Of_Desk__c")
        expect(contact[0].fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        puts "get Opportunity details"
        opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact[0].fetch('Id')}")
        expect(opportunity[0]).to_not eq nil


        @helper.addLogs("[Validate] opportunity:RecordType.Name")
        expect(opportunity[0].fetch('RecordType')['Name']).to eq "Enterprise Solutions"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] opportunity:Deal_Type__c")
        expect(opportunity[0].fetch('Deal_Type__c')).to eq "Strategic"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] opportunity:Owner.Id")
        ownerAssign = accQueue.include? opportunity[0].fetch('Owner')['Id']
        expect(ownerAssign).to eq true
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] opportunity:Quantity__c")
        expect(opportunity[0].fetch('Quantity__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        puts "get Account Details"
        account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact[0].fetch('Id')}")
        expect(account[0]).to_not eq nil

        @helper.addLogs("[Validate] account:RecordType.Name")
        expect(account[0].fetch('RecordType')['Name']).to eq "Enterprise Solutions"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Owner.Name")
        ownerAssign = accQueue.include? account[0].fetch('Owner')['Id']
        expect(ownerAssign).to eq true
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Number_of_Full_Time_Employees__c")
        expect(account[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Interested_in_Number_of_Desks__c")
        expect(account[0].fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Allow_Merge__c")
        expect(account[0].fetch('Allow_Merge__c')).to eq true
        @helper.postSuccessResult('2067')
    rescue Exception => e
       raise e
       @helper.postFailResult(e,'2067')
    end
    end
  end

  context "by Add Opportunity with create acc and Don't merge" do

    it "C2058 : To check account assignment for Record Type Consumer and Deal type Transactional.", :'2058'=> 'true' do
      begin
        @helper.addLogs("C2058 : To check account assignment for Record Type Consumer and Deal type Transactional.",'2058')

        @testDataJSON['AccountAssignment']['tour'][0]['companySize']  = '15'
        @testDataJSON['AccountAssignment']['tour'][0]['numberOfDesks']  = '5'
        @testDataJSON['AccountAssignment']['tour'][0]['building']  = 'MUM-BKC'

        @helper.addLogs("[Step    ] booking tour from WebSite")
        emailId = @objAccAssignmentFromLead.createLead()
        expect(@driver.title).to match("Coworking Office")# Sambhav BKC | WeWork")

        @helper.addLogs("[Validate]  Journey should be created")
        journey = @objAccAssignmentFromLead.fetchJourneyDetails(emailId)
        expect(journey[0]).to_not eq 'nil'
        @helper.addLogs("[Expected]  Journey created successfully with emailId = #{emailId} \n[Result  ]  Success ")

        @helper.addLogs("[Step    ] logging to salesforce")
        expect(@objAccAssignmentFromLead.loginToSalesforce).to_not eq nil

        @helper.addLogs("[Step    ] go to details page of created Journey and Clicking on 'Add Opportunity' button")
        expect(@objAccAssignmentFromLead.goToDetailPageJourney(journey[0].fetch('Id'))).to eq true


        @helper.addLogs("[Validate] Checking Add Opportunity when user click on 'Add Opportunity' button")
        expect(@driver.title).to match("Add Opportunity")
        @helper.addLogs("[Expected] Manage tour page opened successfully with Page Title= Add Opportunity \n[Result  ]  Success")

        @helper.addLogs("[Step    ] filling all required fields and Add Opportunity")

        expect(@objAccAssignmentFromLead.addOpportunity()).to eq true

        @helper.addLogs("[Step    ] click on Create Account and Don't Merge")
        expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Don't Merge",nil)).to eq true

        @helper.addLogs("[Step    ] checking fields...")

        @helper.addLogs("[Step    ] get building details of #{@testDataJSON['AccountAssignment']["tour"][0]["building"]}")
        building = @objAccAssignmentFromLead.fetchBuildingDetails(@testDataJSON['AccountAssignment']["tour"][0]["building"])
        expect(building[0]).to_not eq nil

        @helper.addLogs("[Step    ] get Contact details")
        contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
        expect(contact[0]).to_not eq nil

        @helper.addLogs("[Validate] contact:RecordType.Name")
        expect(contact[0].fetch('RecordType')['Name']).to eq "Consumer"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] contact:Owner.Id")
        expect(contact[0].fetch('Owner')['Id']).to eq "#{building[0].fetch('Community_Lead__c')}"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] contact:Number_of_Full_Time_Employees__c")
        expect(contact[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] contact:Looking_For_Number_Of_Desk__c")
        expect(contact[0].fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        puts "get Opportunity details"
        opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact[0].fetch('Id')}")
        expect(opportunity[0]).to_not eq nil

        @helper.addLogs("[Validate] opportunity:RecordType.Name")
        expect(opportunity[0].fetch('RecordType')['Name']).to eq "Consumer"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] opportunity:Deal_Type__c")
        expect(opportunity[0].fetch('Deal_Type__c')).to eq "Transactional"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] opportunity:Owner.Id")
        expect(opportunity[0].fetch('Owner')['Id']).to eq "#{building[0].fetch('Community_Lead__c')}"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] opportunity:Quantity__c")
        expect(opportunity[0].fetch('Quantity__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        puts "get Account Details"
        account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact[0].fetch('Id')}")
        expect(account[0]).to_not eq nil

        @helper.addLogs("[Validate] account:RecordType.Name")
        expect(account[0].fetch('RecordType')['Name']).to eq "Consumer"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Owner.Id")
        expect(account[0].fetch('Owner')['Id']).to eq "#{building[0].fetch('Community_Lead__c')}"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Number_of_Full_Time_Employees__c")
        expect(account[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Interested_in_Number_of_Desks__c")
        expect(account[0].fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Allow_Merge__c")
        expect(account[0].fetch('Allow_Merge__c')).to eq false
        @helper.postSuccessResult('2058')
    rescue Exception => e
       raise e
       @helper.postFailResult(e,'2058')
    end

    end

    it "C2071 : To check account assignment for Record Type Consumer and Deal type Relational.", :'2071'=> 'true' do
      begin
        @helper.addLogs("C2071 : To check account assignment for Record Type Consumer and Deal type Relational.",'2071')

        @testDataJSON['AccountAssignment']['tour'][0]['companySize']  = '15'
        @testDataJSON['AccountAssignment']['tour'][0]['numberOfDesks']  = '13'
        @testDataJSON['AccountAssignment']['tour'][0]['building']  = 'MUM-BKC'

        @helper.addLogs("[Step    ] booking tour from WebSite")
        emailId = @objAccAssignmentFromLead.createLead()
        expect(@driver.title).to match("Coworking Office")

        @helper.addLogs("[Validate]  Journey should be created")
        journey = @objAccAssignmentFromLead.fetchJourneyDetails(emailId)
        expect(journey[0]).to_not eq nil
        @helper.addLogs("[Expected]  Journey created successfully with emailId = #{emailId} \n[Result  ]  Success ")

        @helper.addLogs("[Step    ] logging to salesforce")
        expect(@objAccAssignmentFromLead.loginToSalesforce).to_not eq nil

        @helper.addLogs("[Step    ] go to details page of created Journey and Clicking on 'Add Opportunity' button")
        expect(@objAccAssignmentFromLead.goToDetailPageJourney(journey[0].fetch('Id'))).to eq true


        @helper.addLogs("[Validate] Checking Add Opportunity when user click on 'Add Opportunity' button")
        expect(@driver.title).to match("Add Opportunity")
        @helper.addLogs("[Expected] Manage tour page opened successfully with Page Title= Add Opportunity \n[Result  ]  Success")

        @helper.addLogs("[Step    ] filling all required fields and Add Opportunity")

        expect(@objAccAssignmentFromLead.addOpportunity()).to eq true

        @helper.addLogs("[Step    ] click on Create Account and Don't Merge")
        expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Don't Merge",nil)).to eq true

        @helper.addLogs("[Step    ] checking fields...")

        @helper.addLogs("[Step    ] get building details of #{@testDataJSON['AccountAssignment']["tour"][0]["building"]}")
        building = @objAccAssignmentFromLead.fetchBuildingDetails(@testDataJSON['AccountAssignment']["tour"][0]["building"])
        expect(building[0]).to_not eq nil

        @helper.addLogs("[Step    ] get Contact details")
        contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
        expect(contact[0]).to_not eq nil

        @helper.addLogs("[Validate] contact:RecordType.Name")
        expect(contact[0].fetch('RecordType')['Name']).to eq "Consumer"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] contact:Owner.Id")
        expect(contact[0].fetch('Owner')['Name']).to eq "#{building[0].fetch('Cluster_Sales_Lead_Name__c')}"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] contact:Number_of_Full_Time_Employees__c")
        expect(contact[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] contact:Looking_For_Number_Of_Desk__c")
        expect(contact[0].fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        puts "get Opportunity details"
        opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact[0].fetch('Id')}")
        expect(opportunity[0]).to_not eq nil

        @helper.addLogs("[Validate] opportunity:RecordType.Name")
        expect(opportunity[0].fetch('RecordType')['Name']).to eq "Consumer"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] opportunity:Deal_Type__c")
        expect(opportunity[0].fetch('Deal_Type__c')).to eq "Relational"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] opportunity:Owner.Id")
        expect(opportunity[0].fetch('Owner')['Name']).to eq "#{building[0].fetch('Cluster_Sales_Lead_Name__c')}"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] opportunity:Quantity__c")
        expect(opportunity[0].fetch('Quantity__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        puts "get Account Details"
        account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact[0].fetch('Id')}")
        expect(account[0]).to_not eq nil

        @helper.addLogs("[Validate] account:RecordType.Name")
        expect(account[0].fetch('RecordType')['Name']).to eq "Consumer"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Owner.Name")
        expect(account[0].fetch('Owner')['Name']).to eq "#{building[0].fetch('Cluster_Sales_Lead_Name__c')}"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Number_of_Full_Time_Employees__c")
        expect(account[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Interested_in_Number_of_Desks__c")
        expect(account[0].fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Allow_Merge__c")
        expect(account[0].fetch('Allow_Merge__c')).to eq false
        @helper.postSuccessResult('2071')
    rescue Exception => e
       raise e
       @helper.postFailResult(e,'2071')
    end

    end

    it "C2072 : To check account assignment for Record Type Consumer and Deal type Strategic.", :'2072'=> 'true' do
      begin
        @helper.addLogs("C2072 : To check account assignment for Record Type Consumer and Deal type Strategic.",'2072')

        @testDataJSON['AccountAssignment']['tour'][0]['companySize']  = '15'
        @testDataJSON['AccountAssignment']['tour'][0]['numberOfDesks']  = '25'

  
        @helper.addLogs("[Step    ] booking tour from WebSite")
        emailId = @objAccAssignmentFromLead.createLead()
        expect(@driver.title).to match("Coworking Office")# Sambhav BKC | WeWork")

        @helper.addLogs("[Validate]  Journey should be created")
        journey = @objAccAssignmentFromLead.fetchJourneyDetails(emailId)
        expect(journey[0]).to_not eq nil
        @helper.addLogs("[Expected]  Journey created successfully with emailId = #{emailId} \n[Result  ]  Success ")

        @helper.addLogs("[Step    ] logging to salesforce")
        expect(@objAccAssignmentFromLead.loginToSalesforce).to_not eq nil

        @helper.addLogs("[Step    ] go to details page of created Journey and Clicking on 'Add Opportunity' button")
        expect(@objAccAssignmentFromLead.goToDetailPageJourney(journey[0].fetch('Id'))).to eq true


        @helper.addLogs("[Validate] Checking Add Opportunity when user click on 'Add Opportunity' button")
        expect(@driver.title).to match("Add Opportunity")
        @helper.addLogs("[Expected] Manage tour page opened successfully with Page Title= Add Opportunity \n[Result  ]  Success")

        @helper.addLogs("[Step    ] filling all required fields and Add Opportunity")

        expect(@objAccAssignmentFromLead.addOpportunity()).to eq true

        @helper.addLogs("[Step    ] click on Create Account and Don't Merge")
        expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Don't Merge",nil)).to eq true

        @helper.addLogs("[Step    ] checking fields...")

        @helper.addLogs("[Step    ] get building details of #{@testDataJSON['AccountAssignment']["tour"][0]["building"]}")
        building = @objAccAssignmentFromLead.fetchBuildingDetails(@testDataJSON['AccountAssignment']["tour"][0]["building"])
        expect(building[0]).to_not eq nil

        @helper.addLogs("[Step    ] get accQueue details")
        accQueue = @objAccAssignmentFromLead.fetAccOwnerQueue(building[0].fetch('Market__c'),'Consumer')

        @helper.addLogs("[Step    ] get Contact details")
        contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
        expect(contact[0]).to_not eq nil

        @helper.addLogs("[Validate] contact:RecordType.Name")
        expect(contact[0].fetch('RecordType')['Name']).to eq "Consumer"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] contact:Owner.Id")
        ownerAssign = accQueue.include? contact[0].fetch('Owner')['Id']
        expect(ownerAssign).to eq true
        #expect(contact[0].fetch('Owner')['Id']).to eq "#{accQueue.fetch('Member__c')}"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] contact:Number_of_Full_Time_Employees__c")
        expect(contact[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] contact:Looking_For_Number_Of_Desk__c")
        expect(contact[0].fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        puts "get Opportunity details"
        opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact[0].fetch('Id')}")
        expect(opportunity[0]).to_not eq nil

        @helper.addLogs("[Validate] opportunity:RecordType.Name")
        expect(opportunity[0].fetch('RecordType')['Name']).to eq "Consumer"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] opportunity:Deal_Type__c")
        expect(opportunity[0].fetch('Deal_Type__c')).to eq "Strategic"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] opportunity:Owner.Id")
        ownerAssign = accQueue.include? opportunity[0].fetch('Owner')['Id']
        expect(ownerAssign).to eq true
        #expect(opportunity[0].fetch('Owner')['Id']).to eq "#{accQueue.fetch('Member__c')}"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] opportunity:Quantity__c")
        expect(opportunity[0].fetch('Quantity__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        puts "get Account Details"
        account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact[0].fetch('Id')}")
        expect(account[0]).to_not eq nil

        @helper.addLogs("[Validate] account:RecordType.Name")
        expect(account[0].fetch('RecordType')['Name']).to eq "Consumer"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Owner.Name")
        ownerAssign = accQueue.include? account[0].fetch('Owner')['Id']
        expect(ownerAssign).to eq true

        #expect(account[0].fetch('Owner')['Id']).to eq "#{accQueue.fetch('Member__c')}"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Number_of_Full_Time_Employees__c")
        expect(account[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Interested_in_Number_of_Desks__c")
        expect(account[0].fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Allow_Merge__c")
        expect(account[0].fetch('Allow_Merge__c')).to eq false
        @helper.postSuccessResult('2072')
    rescue Exception => e
       raise e
       @helper.postFailResult(e,'2072')
    end

    end

    it "C2072 : To check account assignment for Record Type Consumer and Deal type Strategic.(Queue is not present in the Account Queue Setting)", :'1212112'=> 'true'  do
      begin
        @helper.addLogs("C2072 : To check account assignment for Record Type Consumer and Deal type Strategic.(Queue is not present in the Account Queue Setting).",'2072')

        @testDataJSON['AccountAssignment']['tour'][0]['companySize']  = '15'
        @testDataJSON['AccountAssignment']['tour'][0]['numberOfDesks']  = '25'
        @testDataJSON['AccountAssignment']['tour'][0]['building']  = 'SYD-Martin Place'

        @helper.addLogs("[Step    ] booking tour from WebSite")
        emailId = @objAccAssignmentFromLead.createLead()
        expect(@driver.title).to match("Coworking Office")# Sambhav BKC | WeWork")


        @helper.addLogs("[Validate]  Journey should be created")
        journey = @objAccAssignmentFromLead.fetchJourneyDetails(emailId)
        expect(journey[0]).to_not eq nil
        @helper.addLogs("[Expected]  Journey created successfully with emailId = #{emailId} \n[Result  ]  Success ")

        @helper.addLogs("[Step    ] logging to salesforce")
        expect(@objAccAssignmentFromLead.loginToSalesforce).to_not eq nil

        @helper.addLogs("[Step    ] go to details page of created Journey and Clicking on 'Add Opportunity' button")
        expect(@objAccAssignmentFromLead.goToDetailPageJourney(journey[0].fetch('Id'))).to eq true


        @helper.addLogs("[Validate] Checking Add Opportunity when user click on 'Add Opportunity' button")
        expect(@driver.title).to match("Add Opportunity")
        @helper.addLogs("[Expected] Manage tour page opened successfully with Page Title= Add Opportunity \n[Result  ]  Success")

        @helper.addLogs("[Step    ] filling all required fields and Add Opportunity")

        expect(@objAccAssignmentFromLead.addOpportunity()).to eq true

        @helper.addLogs("[Step    ] click on Create Account and Don't Merge")
        expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Don't Merge",nil)).to eq true

        @helper.addLogs("[Step    ] checking fields...")

        @helper.addLogs("[Step    ] get building details of #{@testDataJSON['AccountAssignment']["tour"][0]["building"]}")
        building = @objAccAssignmentFromLead.fetchBuildingDetails(@testDataJSON['AccountAssignment']["tour"][0]["building"])
        expect(building[0]).to_not eq nil

        #@helper.addLogs("[Step    ] get accQueue details")
        #accQueue = @objAccAssignmentFromLead.fetAccOwnerQueue(building[0].fetch('Market__c'),'Consumer')

        @helper.addLogs("[Step    ] get Contact details")
        contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
        expect(contact[0]).to_not eq nil

        @helper.addLogs("[Validate] contact:RecordType.Name")
        expect(contact[0].fetch('RecordType')['Name']).to eq "Consumer"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] contact:Owner.Id")
        expect(contact[0].fetch('Owner')['Id']).to eq "005F0000003KmbwIAC"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] contact:Number_of_Full_Time_Employees__c")
        expect(contact[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] contact:Looking_For_Number_Of_Desk__c")
        expect(contact[0].fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        puts "get Opportunity details"
        opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact[0].fetch('Id')}")
        expect(opportunity[0]).to_not eq nil

        @helper.addLogs("[Validate] opportunity:RecordType.Name")
        expect(opportunity[0].fetch('RecordType')['Name']).to eq "Consumer"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] opportunity:Deal_Type__c")
        expect(opportunity[0].fetch('Deal_Type__c')).to eq "Strategic"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] opportunity:Owner.Id")
        expect(opportunity[0].fetch('Owner')['Id']).to eq "005F0000003KmbwIAC"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] opportunity:Quantity__c")
        expect(opportunity[0].fetch('Quantity__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        puts "get Account Details"
        account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact[0].fetch('Id')}")
        expect(account[0]).to_not eq nil

        @helper.addLogs("[Validate] account:RecordType.Name")
        expect(account[0].fetch('RecordType')['Name']).to eq "Consumer"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Owner.Name")
        expect(account[0].fetch('Owner')['Id']).to eq "005F0000003KmbwIAC"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Number_of_Full_Time_Employees__c")
        expect(account[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Interested_in_Number_of_Desks__c")
        expect(account[0].fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Allow_Merge__c")
        expect(account[0].fetch('Allow_Merge__c')).to eq false
        @helper.postSuccessResult('2072')
    rescue Exception => e
       raise e
       @helper.postFailResult(e,'2072')
    end

    end

    it "C2075 : To Check Account assignment for Record Type Mid-Market and Deal type Transactional.", :'2075'=> 'true' do
      begin
        @helper.addLogs("C2052 : To Check Account assignment for Record Type Mid-Market and Deal type Transactional.",'2075')
        @testDataJSON['AccountAssignment']['tour'][0]['building']  = 'SYD-Martin Place'
        @testDataJSON['AccountAssignment']['tour'][0]['companySize']  = '24'
        @testDataJSON['AccountAssignment']['tour'][0]['numberOfDesks']  = '7'

        @helper.addLogs("[Step    ] booking tour from WebSite")
        emailId = @objAccAssignmentFromLead.createLead()
        expect(@driver.title).to match("Coworking Office")# Sambhav BKC | WeWork")

        @helper.addLogs("[Validate]  Journey should be created")
        journey = @objAccAssignmentFromLead.fetchJourneyDetails(emailId)
        expect(journey[0]).to_not eq nil
        @helper.addLogs("[Expected]  Journey created successfully with emailId = #{emailId} \n[Result  ]  Success ")

        @helper.addLogs("[Step    ] logging to salesforce")
        expect(@objAccAssignmentFromLead.loginToSalesforce).to_not eq nil

        @helper.addLogs("[Step    ] go to details page of created Journey and Clicking on 'Add Opportunity' button")
        expect(@objAccAssignmentFromLead.goToDetailPageJourney(journey[0].fetch('Id'))).to eq true


        @helper.addLogs("[Validate] Checking Add Opportunity when user click on 'Add Opportunity' button")
        expect(@driver.title).to match("Add Opportunity")
        @helper.addLogs("[Expected] Manage tour page opened successfully with Page Title= Add Opportunity \n[Result  ]  Success")

        @helper.addLogs("[Step    ] filling all required fields and Add Opportunity")

        expect(@objAccAssignmentFromLead.addOpportunity()).to eq true

        @helper.addLogs("[Step    ] click on Create Account and Don't Merge")
        expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Don't Merge",nil)).to eq true

        @helper.addLogs("[Step    ] checking fields...")

        @helper.addLogs("[Step    ] get building details of #{@testDataJSON['AccountAssignment']["tour"][0]["building"]}")
        building = @objAccAssignmentFromLead.fetchBuildingDetails(@testDataJSON['AccountAssignment']["tour"][0]["building"])
        expect(building[0]).to_not eq nil

        @helper.addLogs("[Step    ] get Contact details")
        contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
        expect(contact[0]).to_not eq nil

        @helper.addLogs("[Validate] contact:RecordType.Name")
        expect(contact[0].fetch('RecordType')['Name']).to eq "Mid Market"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] contact:Owner.Id")
        expect(contact[0].fetch('Owner')['Id']).to eq "#{building[0].fetch('Community_Lead__c')}"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] contact:Number_of_Full_Time_Employees__c")
        expect(contact[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] contact:Looking_For_Number_Of_Desk__c")
        expect(contact[0].fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        puts "get Opportunity details"
        opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact[0].fetch('Id')}")
        expect(opportunity[0]).to_not eq nil

        @helper.addLogs("[Validate] opportunity:RecordType.Name")
        expect(opportunity[0].fetch('RecordType')['Name']).to eq "Mid Market"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] opportunity:Deal_Type__c")
        expect(opportunity[0].fetch('Deal_Type__c')).to eq "Transactional"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] opportunity:Owner.Id")
        expect(opportunity[0].fetch('Owner')['Id']).to eq "#{building[0].fetch('Community_Lead__c')}"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] opportunity:Quantity__c")
        expect(opportunity[0].fetch('Quantity__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        puts "get Account Details"
        account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact[0].fetch('Id')}")
        expect(account[0]).to_not eq nil

        @helper.addLogs("[Validate] account:RecordType.Name")
        expect(account[0].fetch('RecordType')['Name']).to eq "Mid Market"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Owner.Id")
        expect(account[0].fetch('Owner')['Id']).to eq "#{building[0].fetch('Community_Lead__c')}"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Number_of_Full_Time_Employees__c")
        expect(account[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Interested_in_Number_of_Desks__c")
        expect(account[0].fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Allow_Merge__c")
        expect(account[0].fetch('Allow_Merge__c')).to eq false
        @helper.postSuccessResult('2075')
    rescue Exception => e
       raise e
       @helper.postFailResult(e,'2075')
    end

    end

    it "C2074 : To Check Account Assignment for Record type Mid-Market and Deal type Relational.", :'2074'=> 'true' do
      begin
        @helper.addLogs("C2053 : To Check Account Assignment for Record type Mid-Market and Deal type Relational.",'2074')

        @testDataJSON['AccountAssignment']['tour'][0]['building']  = 'SYD-Martin Place'
        @testDataJSON['AccountAssignment']['tour'][0]['companySize']  = '24'
        @testDataJSON['AccountAssignment']['tour'][0]['numberOfDesks']  = '15'

        @helper.addLogs("[Step    ] booking tour from WebSite")
        emailId = @objAccAssignmentFromLead.createLead()
        expect(@driver.title).to match("Coworking Office")# Sambhav BKC | WeWork")

        @helper.addLogs("[Validate]  Journey should be created")
        journey = @objAccAssignmentFromLead.fetchJourneyDetails(emailId)
        expect(journey[0]).to_not eq nil
        @helper.addLogs("[Expected]  Journey created successfully with emailId = #{emailId} \n[Result  ]  Success ")

        @helper.addLogs("[Step    ] logging to salesforce")
        expect(@objAccAssignmentFromLead.loginToSalesforce).to_not eq nil

        @helper.addLogs("[Step    ] go to details page of created Journey and Clicking on 'Add Opportunity' button")
        expect(@objAccAssignmentFromLead.goToDetailPageJourney(journey[0].fetch('Id'))).to eq true


        @helper.addLogs("[Validate] Checking Add Opportunity when user click on 'Add Opportunity' button")
        expect(@driver.title).to match("Add Opportunity")
        @helper.addLogs("[Expected] Manage tour page opened successfully with Page Title= Add Opportunity \n[Result  ]  Success")

        @helper.addLogs("[Step    ] filling all required fields and Add Opportunity")

        expect(@objAccAssignmentFromLead.addOpportunity()).to eq true

        @helper.addLogs("[Step    ] click on Create Account and Don't Merge")
        expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Don't Merge",nil)).to eq true

        @helper.addLogs("[Step    ] checking fields...")

        @helper.addLogs("[Step    ] get building details of #{@testDataJSON['AccountAssignment']["tour"][0]["building"]}")
        building = @objAccAssignmentFromLead.fetchBuildingDetails(@testDataJSON['AccountAssignment']["tour"][0]["building"])
        expect(building[0]).to_not eq nil

        @helper.addLogs("[Step    ] get Contact details")
        contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
        expect(contact[0]).to_not eq nil

        @helper.addLogs("[Validate] contact:RecordType.Name")
        expect(contact[0].fetch('RecordType')['Name']).to eq "Mid Market"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] contact:Owner.Id")
        expect(contact[0].fetch('Owner')['Name']).to eq "#{building[0].fetch('Cluster_Sales_Lead_Name__c')}"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] contact:Number_of_Full_Time_Employees__c")
        expect(contact[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] contact:Looking_For_Number_Of_Desk__c")
        expect(contact[0].fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        puts "get Opportunity details"
        opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact[0].fetch('Id')}")
        expect(opportunity[0]).to_not eq nil

        @helper.addLogs("[Validate] opportunity:RecordType.Name")
        expect(opportunity[0].fetch('RecordType')['Name']).to eq "Mid Market"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] opportunity:Deal_Type__c")
        expect(opportunity[0].fetch('Deal_Type__c')).to eq "Relational"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] opportunity:Owner.Id")
        expect(opportunity[0].fetch('Owner')['Name']).to eq "#{building[0].fetch('Cluster_Sales_Lead_Name__c')}"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] opportunity:Quantity__c")
        expect(opportunity[0].fetch('Quantity__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        puts "get Account Details"
        account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact[0].fetch('Id')}")
        expect(account[0]).to_not eq nil

        @helper.addLogs("[Validate] account:RecordType.Name")
        expect(account[0].fetch('RecordType')['Name']).to eq "Mid Market"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Owner.Name")
        expect(account[0].fetch('Owner')['Name']).to eq "#{building[0].fetch('Cluster_Sales_Lead_Name__c')}"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Number_of_Full_Time_Employees__c")
        expect(account[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Interested_in_Number_of_Desks__c")
        expect(account[0].fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Allow_Merge__c")
        expect(account[0].fetch('Allow_Merge__c')).to eq false
        @helper.postSuccessResult('2074')
    rescue Exception => e
       raise e
       @helper.postFailResult(e,'2074')
    end

    end

    it "C2064 : To Check Account Assignment from Record type Mid-Market and Deal Type Strategic.", :'2064'=> 'true' do
      begin
        @helper.addLogs("C2054 : To check account assignment for Record Type Consumer and Deal type Relational.",'2064')

        @testDataJSON['AccountAssignment']['tour'][0]['building']  = 'SYD-Martin Place'
        @testDataJSON['AccountAssignment']['tour'][0]['companySize']  = '24'
        @testDataJSON['AccountAssignment']['tour'][0]['numberOfDesks']  = '27'

        @helper.addLogs("[Step    ] booking tour from WebSite")
        emailId = @objAccAssignmentFromLead.createLead()
        expect(@driver.title).to match("Coworking Office Sambhav BKC | WeWork")

        @helper.addLogs("[Validate]  Journey should be created")
        journey = @objAccAssignmentFromLead.fetchJourneyDetails(emailId)
        expect(journey[0]).to_not eq nil
        @helper.addLogs("[Expected]  Journey created successfully with emailId = #{emailId} \n[Result  ]  Success ")

        @helper.addLogs("[Step    ] logging to salesforce")
        expect(@objAccAssignmentFromLead.loginToSalesforce).to_not eq nil

        @helper.addLogs("[Step    ] go to details page of created Journey and Clicking on 'Add Opportunity' button")
        expect(@objAccAssignmentFromLead.goToDetailPageJourney(journey[0].fetch('Id'))).to eq true


        @helper.addLogs("[Validate] Checking Add Opportunity when user click on 'Add Opportunity' button")
        expect(@driver.title).to match("Add Opportunity")
        @helper.addLogs("[Expected] Manage tour page opened successfully with Page Title= Add Opportunity \n[Result  ]  Success")

        @helper.addLogs("[Step    ] filling all required fields and Add Opportunity")

        expect(@objAccAssignmentFromLead.addOpportunity()).to eq true

        @helper.addLogs("[Step    ] click on Create Account and Don't Merge")
        expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Don't Merge",nil)).to eq true

        @helper.addLogs("[Step    ] checking fields...")

        @helper.addLogs("[Step    ] get building details of #{@testDataJSON['AccountAssignment']["tour"][0]["building"]}")
        building = @objAccAssignmentFromLead.fetchBuildingDetails(@testDataJSON['AccountAssignment']["tour"][0]["building"])
        expect(building[0]).to_not eq nil

        @helper.addLogs("[Step    ] get accQueue details")

        accQueue = @objAccAssignmentFromLead.fetAccOwnerQueue(building[0].fetch('Market__c'),'Mid Market')

        @helper.addLogs("[Step    ] get Contact details")
        contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
        expect(contact[0]).to_not eq nil

        @helper.addLogs("[Validate] contact:RecordType.Name")
        expect(contact[0].fetch('RecordType')['Name']).to eq "Mid Market"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] contact:Owner.Id")

        puts accQueue.include? contact[0].fetch('Owner')['Id']
        ownerAssign = accQueue.include? contact[0].fetch('Owner')['Id']
        expect(ownerAssign).to eq true

        #expect(contact[0].fetch('Owner')['Id']).to eq "#{accQueue.fetch('Member__c')}"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] contact:Number_of_Full_Time_Employees__c")
        expect(contact[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] contact:Looking_For_Number_Of_Desk__c")
        expect(contact[0].fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        puts "get Opportunity details"
        opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact[0].fetch('Id')}")
        expect(opportunity[0]).to_not eq nil

        @helper.addLogs("[Validate] opportunity:RecordType.Name")
        expect(opportunity[0].fetch('RecordType')['Name']).to eq "Mid Market"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] opportunity:Deal_Type__c")
        expect(opportunity[0].fetch('Deal_Type__c')).to eq "Strategic"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] opportunity:Owner.Id")
        ownerAssign = accQueue.include? opportunity[0].fetch('Owner')['Id']
        expect(ownerAssign).to eq true

        #expect(opportunity[0].fetch('Owner')['Id']).to eq "#{accQueue.fetch('Member__c')}"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] opportunity:Quantity__c")
        expect(opportunity[0].fetch('Quantity__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        puts "get Account Details"
        account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact[0].fetch('Id')}")
        expect(account[0]).to_not eq nil

        @helper.addLogs("[Validate] account:RecordType.Name")
        expect(account[0].fetch('RecordType')['Name']).to eq "Mid Market"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Owner.Name")
        ownerAssign = accQueue.include? account[0].fetch('Owner')['Id']
        expect(ownerAssign).to eq true
        #expect(account[0].fetch('Owner')['Id']).to eq "#{accQueue.fetch('Member__c')}"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Number_of_Full_Time_Employees__c")
        expect(account[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Interested_in_Number_of_Desks__c")
        expect(account[0].fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Allow_Merge__c")
        expect(account[0].fetch('Allow_Merge__c')).to eq false
        @helper.postSuccessResult('2064')
    rescue Exception => e
       raise e
       @helper.postFailResult(e,'2064')
    end

    end

    it "C2065 : To Check Account Assignment for Record Type Enterprise and Deal type Transactional.", :'2065'=> 'true' do
      begin
        @helper.addLogs("C2055 : To Check Account Assignment for Record Type Enterprise and Deal type Transactional.",'2065')

        @testDataJSON['AccountAssignment']['tour'][0]['building']  = 'MEL-Bourke Street'
        @testDataJSON['AccountAssignment']['tour'][0]['companySize']  = '1200'
        @testDataJSON['AccountAssignment']['tour'][0]['numberOfDesks']  = '7'

        @helper.addLogs("[Step    ] booking tour from WebSite")
        emailId = @objAccAssignmentFromLead.createLead()
        expect(@driver.title).to match("Coworking Office")# Sambhav BKC | WeWork")

        @helper.addLogs("[Validate]  Journey should be created")
        journey = @objAccAssignmentFromLead.fetchJourneyDetails(emailId)
        expect(journey[0]).to_not eq nil
        @helper.addLogs("[Expected]  Journey created successfully with emailId = #{emailId} \n[Result  ]  Success ")

        @helper.addLogs("[Step    ] logging to salesforce")
        expect(@objAccAssignmentFromLead.loginToSalesforce).to_not eq nil

        @helper.addLogs("[Step    ] go to details page of created Journey and Clicking on 'Add Opportunity' button")
        expect(@objAccAssignmentFromLead.goToDetailPageJourney(journey[0].fetch('Id'))).to eq true


        @helper.addLogs("[Validate] Checking Add Opportunity when user click on 'Add Opportunity' button")
        expect(@driver.title).to match("Add Opportunity")
        @helper.addLogs("[Expected] Manage tour page opened successfully with Page Title= Add Opportunity \n[Result  ]  Success")

        @helper.addLogs("[Step    ] filling all required fields and Add Opportunity")

        expect(@objAccAssignmentFromLead.addOpportunity()).to eq true

        @helper.addLogs("[Step    ] click on Create Account and Don't Merge")
        expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Don't Merge",nil)).to eq true

        @helper.addLogs("[Step    ] checking fields...")

        @helper.addLogs("[Step    ] get building details of #{@testDataJSON['AccountAssignment']["tour"][0]["building"]}")
        building = @objAccAssignmentFromLead.fetchBuildingDetails(@testDataJSON['AccountAssignment']["tour"][0]["building"])
        expect(building[0]).to_not eq nil

        @helper.addLogs("[Step    ] get accQueue details")
        accQueue = @objAccAssignmentFromLead.fetAccOwnerQueue(building[0].fetch('Market__c'),'Enterprise Solutions')

        @helper.addLogs("[Step    ] get Contact details")
        contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
        expect(contact[0]).to_not eq nil

        @helper.addLogs("[Validate] contact:RecordType.Name")
        expect(contact[0].fetch('RecordType')['Name']).to eq "Enterprise Solutions"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] contact:Owner.Id")

        ownerAssign = accQueue.include? contact[0].fetch('Owner')['Id']
        expect(ownerAssign).to eq true
        #expect(contact[0].fetch('Owner')['Id']).to eq "#{accQueue.fetch('Member__c')}"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] contact:Number_of_Full_Time_Employees__c")
        expect(contact[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] contact:Looking_For_Number_Of_Desk__c")
        expect(contact[0].fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        puts "get Opportunity details"
        opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact[0].fetch('Id')}")
        expect(opportunity[0]).to_not eq nil

        @helper.addLogs("[Validate] opportunity:RecordType.Name")
        expect(opportunity[0].fetch('RecordType')['Name']).to eq "Enterprise Solutions"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] opportunity:Deal_Type__c")
        expect(opportunity[0].fetch('Deal_Type__c')).to eq "Transactional"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] opportunity:Owner.Id")
        ownerAssign = accQueue.include? opportunity[0].fetch('Owner')['Id']
        expect(ownerAssign).to eq true
        #expect(opportunity[0].fetch('Owner')['Id']).to eq "#{accQueue.fetch('Member__c')}"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] opportunity:Quantity__c")
        expect(opportunity[0].fetch('Quantity__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        puts "get Account Details"
        account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact[0].fetch('Id')}")
        expect(account[0]).to_not eq nil

        @helper.addLogs("[Validate] account:RecordType.Name")
        expect(account[0].fetch('RecordType')['Name']).to eq "Enterprise Solutions"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Owner.Name")
        ownerAssign = accQueue.include? account[0].fetch('Owner')['Id']
        expect(ownerAssign).to eq true

        #expect(account[0].fetch('Owner')['Id']).to eq "#{accQueue.fetch('Member__c')}"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Number_of_Full_Time_Employees__c")
        expect(account[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Interested_in_Number_of_Desks__c")
        expect(account[0].fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Allow_Merge__c")
        expect(account[0].fetch('Allow_Merge__c')).to eq false
        @helper.postSuccessResult('2065')
    rescue Exception => e
       raise e
       @helper.postFailResult(e,'2065')
    end

    end

    it "C2066 : To Check Account Assignment for Record Type Enterprise and Deal type Relational.", :'2066'=> 'true' do
      begin
        @helper.addLogs("C2056 : To Check Account Assignment for Record Type Enterprise and Deal type Relational.",'2066')
        @testDataJSON['AccountAssignment']['tour'][0]['building']  = 'SYD-Martin Place'
        @testDataJSON['AccountAssignment']['tour'][0]['companySize']  = '1200'
        @testDataJSON['AccountAssignment']['tour'][0]['numberOfDesks']  = '15'
        
        @helper.addLogs("[Step    ] booking tour from WebSite")
        emailId = @objAccAssignmentFromLead.createLead()
        expect(@driver.title).to match("Coworking Office")# Sambhav BKC | WeWork")

        @helper.addLogs("[Validate]  Journey should be created")
        journey = @objAccAssignmentFromLead.fetchJourneyDetails(emailId)
        expect(journey[0]).to_not eq nil
        @helper.addLogs("[Expected]  Journey created successfully with emailId = #{emailId} \n[Result  ]  Success ")

        @helper.addLogs("[Step    ] logging to salesforce")
        expect(@objAccAssignmentFromLead.loginToSalesforce).to_not eq nil

        @helper.addLogs("[Step    ] go to details page of created Journey and Clicking on 'Add Opportunity' button")
        expect(@objAccAssignmentFromLead.goToDetailPageJourney(journey[0].fetch('Id'))).to eq true


        @helper.addLogs("[Validate] Checking Add Opportunity when user click on 'Add Opportunity' button")
        expect(@driver.title).to match("Add Opportunity")
        @helper.addLogs("[Expected] Manage tour page opened successfully with Page Title= Add Opportunity \n[Result  ]  Success")

        @helper.addLogs("[Step    ] filling all required fields and Add Opportunity")

        expect(@objAccAssignmentFromLead.addOpportunity()).to eq true

        @helper.addLogs("[Step    ] click on Create Account and Don't Merge")
        expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Don't Merge",nil)).to eq true

        @helper.addLogs("[Step    ] checking fields...")

        @helper.addLogs("[Step    ] get building details of #{@testDataJSON['AccountAssignment']["tour"][0]["building"]}")
        building = @objAccAssignmentFromLead.fetchBuildingDetails(@testDataJSON['AccountAssignment']["tour"][0]["building"])
        expect(building[0]).to_not eq nil


        @helper.addLogs("[Step    ] get accQueue details")
        accQueue = @objAccAssignmentFromLead.fetAccOwnerQueue(building[0].fetch('Market__c'),'Enterprise Solutions')

        #accQueue = @objAccAssignmentFromLead.fetAccOwnerQueue('a2V0G000003H8zoUAC','Enterprise Solutions')

        @helper.addLogs("[Step    ] get Contact details")
        contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
        #contact = @objAccAssignmentFromLead.fetchContactDetails("john.smith1004201828@example.com")
        expect(contact[0]).to_not eq nil

        @helper.addLogs("[Validate] contact:RecordType.Name")
        expect(contact[0].fetch('RecordType')['Name']).to eq "Enterprise Solutions"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] contact:Owner.Id")
        puts accQueue.include? contact[0].fetch('Owner')['Id']
        ownerAssign = accQueue.include? contact[0].fetch('Owner')['Id']
        expect(ownerAssign).to eq true
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] contact:Number_of_Full_Time_Employees__c")
        expect(contact[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] contact:Looking_For_Number_Of_Desk__c")
        expect(contact[0].fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        puts "get Opportunity details"
        opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact[0].fetch('Id')}")
        expect(opportunity[0]).to_not eq nil

        @helper.addLogs("[Validate] opportunity:RecordType.Name")
        expect(opportunity[0].fetch('RecordType')['Name']).to eq "Enterprise Solutions"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] opportunity:Deal_Type__c")
        expect(opportunity[0].fetch('Deal_Type__c')).to eq "Relational"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] opportunity:Owner.Id")
        ownerAssign = accQueue.include? opportunity[0].fetch('Owner')['Id']
        expect(ownerAssign).to eq true
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] opportunity:Quantity__c")
        expect(opportunity[0].fetch('Quantity__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        puts "get Account Details"
        account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact[0].fetch('Id')}")
        expect(account[0]).to_not eq nil

        @helper.addLogs("[Validate] account:RecordType.Name")
        expect(account[0].fetch('RecordType')['Name']).to eq "Enterprise Solutions"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Owner.Name")
        ownerAssign = accQueue.include? account[0].fetch('Owner')['Id']
        expect(ownerAssign).to eq true
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Number_of_Full_Time_Employees__c")
        expect(account[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Interested_in_Number_of_Desks__c")
        expect(account[0].fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Allow_Merge__c")
        expect(account[0].fetch('Allow_Merge__c')).to eq false
        @helper.postSuccessResult('2066')
    rescue Exception => e
       raise e
       @helper.postFailResult(e,'2066')
    end

    end

    it "C2067 : To Check Account Assignment for Record Type Enterprise and Deal Type Strategic.", :'2067'=> 'true' do
      begin
        @helper.addLogs("C2057 : To Check Account Assignment for Record Type Enterprise and Deal type Strategic.",'2067')
        @testDataJSON['AccountAssignment']['tour'][0]['building']  = 'SYD-Martin Place'
        @testDataJSON['AccountAssignment']['tour'][0]['companySize']  = '1200'
        @testDataJSON['AccountAssignment']['tour'][0]['numberOfDesks']  = '27'
        
        @helper.addLogs("[Step    ] booking tour from WebSite")
        emailId = @objAccAssignmentFromLead.createLead()
        expect(@driver.title).to match("Coworking Office")# Sambhav BKC | WeWork")

        @helper.addLogs("[Validate]  Journey should be created")
        journey = @objAccAssignmentFromLead.fetchJourneyDetails(emailId)
        expect(journey[0]).to_not eq nil
        @helper.addLogs("[Expected]  Journey created successfully with emailId = #{emailId} \n[Result  ]  Success ")

        @helper.addLogs("[Step    ] logging to salesforce")
        expect(@objAccAssignmentFromLead.loginToSalesforce).to_not eq nil

        @helper.addLogs("[Step    ] go to details page of created Journey and Clicking on 'Add Opportunity' button")
        expect(@objAccAssignmentFromLead.goToDetailPageJourney(journey[0].fetch('Id'))).to eq true


        @helper.addLogs("[Validate] Checking Add Opportunity when user click on 'Add Opportunity' button")
        expect(@driver.title).to match("Add Opportunity")
        @helper.addLogs("[Expected] Manage tour page opened successfully with Page Title= Add Opportunity \n[Result  ]  Success")

        @helper.addLogs("[Step    ] filling all required fields and Add Opportunity")

        expect(@objAccAssignmentFromLead.addOpportunity()).to eq true

        @helper.addLogs("[Step    ] click on Create Account and Don't Merge")
        expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Don't Merge",nil)).to eq true

        @helper.addLogs("[Step    ] checking fields...")

        @helper.addLogs("[Step    ] get building details of #{@testDataJSON['AccountAssignment']["tour"][0]["building"]}")
        building = @objAccAssignmentFromLead.fetchBuildingDetails(@testDataJSON['AccountAssignment']["tour"][0]["building"])
        expect(building[0]).to_not eq nil


        @helper.addLogs("[Step    ] get accQueue details")
        accQueue = @objAccAssignmentFromLead.fetAccOwnerQueue(building[0].fetch('Market__c'),'Enterprise Solutions')

        #accQueue = @objAccAssignmentFromLead.fetAccOwnerQueue('a2V0G000003H8zoUAC','Enterprise Solutions')

        @helper.addLogs("[Step    ] get Contact details")
        contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
        #contact = @objAccAssignmentFromLead.fetchContactDetails("john.smith1004201828@example.com")
        expect(contact[0]).to_not eq nil

        @helper.addLogs("[Validate] contact:RecordType.Name")
        expect(contact[0].fetch('RecordType')['Name']).to eq "Enterprise Solutions"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] contact:Owner.Id")
        puts accQueue.include? contact[0].fetch('Owner')['Id']
        ownerAssign = accQueue.include? contact[0].fetch('Owner')['Id']
        expect(ownerAssign).to eq true
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] contact:Number_of_Full_Time_Employees__c")
        expect(contact[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] contact:Looking_For_Number_Of_Desk__c")
        expect(contact[0].fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        puts "get Opportunity details"
        opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact[0].fetch('Id')}")
        expect(opportunity[0]).to_not eq nil

        @helper.addLogs("[Validate] opportunity:RecordType.Name")
        expect(opportunity[0].fetch('RecordType')['Name']).to eq "Enterprise Solutions"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] opportunity:Deal_Type__c")
        expect(opportunity[0].fetch('Deal_Type__c')).to eq "Strategic"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] opportunity:Owner.Id")
        ownerAssign = accQueue.include? opportunity[0].fetch('Owner')['Id']
        expect(ownerAssign).to eq true
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] opportunity:Quantity__c")
        expect(opportunity[0].fetch('Quantity__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        puts "get Account Details"
        account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact[0].fetch('Id')}")
        expect(account[0]).to_not eq nil

        @helper.addLogs("[Validate] account:RecordType.Name")
        expect(account[0].fetch('RecordType')['Name']).to eq "Enterprise Solutions"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Owner.Name")
        ownerAssign = accQueue.include? account[0].fetch('Owner')['Id']
        expect(ownerAssign).to eq true
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Number_of_Full_Time_Employees__c")
        expect(account[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Interested_in_Number_of_Desks__c")
        expect(account[0].fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Allow_Merge__c")
        expect(account[0].fetch('Allow_Merge__c')).to eq false
        @helper.postSuccessResult('2067')
    rescue Exception => e
       raise e
       @helper.postFailResult(e,'2067')
    end

    end
  end

  context "by Account Reassignment with Create Account and Dont Merge" do

    it "C2076 : To check the Account reassignment for Record type changes from Consumer to Mid-Market.", :'2076'=> 'true' do
      begin
        @helper.addLogs("C2076 : To check the Account reassignment for Record type changes from Consumer to Mid-Market.",'2076')

        @testDataJSON['AccountAssignment']['tour'][0]['companySize']  = '15'
        @testDataJSON['AccountAssignment']['tour'][0]['numberOfDesks']  = '5'

        @helper.addLogs("[Step    ] booking tour from WebSite")
        emailId = @objAccAssignmentFromLead.createLead()
        expect(@driver.title).to match("Coworking Office")# Sambhav BKC | WeWork")

        @helper.addLogs("[Validate]  Lead should be created")
        lead = @objAccAssignmentFromLead.fetchLeadDetails(emailId)
        expect(lead[0]).to_not eq nil
        @helper.addLogs("[Expected]  Lead created successfully with emailId = #{emailId} \n[Result  ]  Success ")

        @helper.addLogs("[Step    ] logging to salesforce")
        expect(@objAccAssignmentFromLead.loginToSalesforce).to_not eq nil

        @helper.addLogs("[Step    ] go to details page of created lead and Clicking on 'Manage/book Tour' button")
        expect(@objAccAssignmentFromLead.goToDetailPage(lead[0].fetch('Id'))).to eq true

        @helper.addLogs("[Validate] Checking Manage Tour page when user click on 'Manage/book tour' button")
        expect(@driver.title).to match("Manage Tours")
        @helper.addLogs("[Expected] Manage tour page opened successfully with Page Title= Manage Tours \n[Result  ]  Success")

        @helper.addLogs("[Step    ] filling all required fields and booked a tour")

        expect(@objAccAssignmentFromLead.bookTour(0,true)).to eq true

        @helper.addLogs("[Step    ] click on Create Account and Don't Merge")
        expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Don't Merge",nil)).to eq true

        @helper.addLogs("[Step    ] checking fields...")

        @helper.addLogs("[Step    ] get building details of #{@testDataJSON['AccountAssignment']["tour"][0]["building"]}")
        building = @objAccAssignmentFromLead.fetchBuildingDetails(@testDataJSON['AccountAssignment']["tour"][0]["building"])
        expect(building[0]).to_not eq nil

        @helper.addLogs("[Step    ] get Contact details")
        contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
        expect(contact[0]).to_not eq nil

        @helper.addLogs("[Validate] contact:RecordType.Name")
        expect(contact[0].fetch('RecordType')['Name']).to eq "Consumer"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] contact:Owner.Id")
        expect(contact[0].fetch('Owner')['Id']).to eq "#{building[0].fetch('Community_Lead__c')}"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] contact:Number_of_Full_Time_Employees__c")
        expect(contact[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] contact:Looking_For_Number_Of_Desk__c")
        expect(contact[0].fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        puts "get Account Details"
        account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact[0].fetch('Id')}")
        expect(account[0]).to_not eq nil

        @helper.addLogs("[Validate] account:RecordType.Name")
        expect(account[0].fetch('RecordType')['Name']).to eq "Consumer"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Owner.Id")
        expect(account[0].fetch('Owner')['Id']).to eq "#{building[0].fetch('Community_Lead__c')}"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Number_of_Full_Time_Employees__c")
        expect(account[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Interested_in_Number_of_Desks__c")
        expect(account[0].fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        puts "get Opportunity details"
        opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact[0].fetch('Id')}")
        expect(opportunity[0]).to_not eq nil

        @helper.addLogs("[Validate] opportunity:RecordType.Name")
        expect(opportunity[0].fetch('RecordType')['Name']).to eq "Consumer"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] opportunity:Deal_Type__c")
        expect(opportunity[0].fetch('Deal_Type__c')).to eq "Transactional"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] opportunity:Owner.Id")
        expect(opportunity[0].fetch('Owner')['Id']).to eq "#{building[0].fetch('Community_Lead__c')}"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] opportunity:Quantity__c")
        expect(opportunity[0].fetch('Quantity__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        expect(@objAccAssignmentFromLead.updateProductAndOpp("#{opportunity[0].fetch('Id')}",'19',account[0].fetch('Id'),'Mid Market')).to eq true
        sleep(20)
        @helper.addLogs("[Step    ] get Contact details")
        contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
        expect(contact[0]).to_not eq nil
        
        @helper.addLogs("[Validate] contact:RecordType.Name")
        expect(contact[0].fetch('RecordType')['Name']).to eq "Mid Market"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] contact:Owner.Id")
        expect(contact[0].fetch('Owner')['Name']).to eq "#{building[0].fetch('Cluster_Sales_Lead_Name__c')}"
        @helper.addLogs("[Result  ]  Success")

        puts "get Account Details"
        account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact[0].fetch('Id')}")
        expect(account[0]).to_not eq nil

        @helper.addLogs("[Validate] account:RecordType.Name")
        expect(account[0].fetch('RecordType')['Name']).to eq "Mid Market"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Owner.Id")
        expect(account[0].fetch('Owner')['Name']).to eq "#{building[0].fetch('Cluster_Sales_Lead_Name__c')}"
        @helper.addLogs("[Result  ]  Success")

        puts "get Opportunity details"
        opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact[0].fetch('Id')}")
        expect(opportunity[0]).to_not eq nil

        @helper.addLogs("[Validate] opportunity:RecordType.Name")
        expect(opportunity[0].fetch('RecordType')['Name']).to eq "Mid Market"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] opportunity:Deal_Type__c")
        expect(opportunity[0].fetch('Deal_Type__c')).to eq "Relational"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] opportunity:Owner.Id")
        expect(opportunity[0].fetch('Owner')['Name']).to eq "#{building[0].fetch('Cluster_Sales_Lead_Name__c')}"
        @helper.postSuccessResult('2076')
    rescue Exception => e
       raise e
       @helper.postFailResult(e,'2076')
    end

    end

    it "C2077 : To check the Account reassignment for Record Type changes from Consumer to Enterprise.", :'2077'=> 'true' do
      begin
        @helper.addLogs("C2077 : To check account assignment for Record Type Consumer and Deal type Transactional.",'2077')

        @testDataJSON['AccountAssignment']['tour'][0]['companySize']  = '15'
        @testDataJSON['AccountAssignment']['tour'][0]['numberOfDesks']  = '5'
        @testDataJSON['AccountAssignment']["UpdatedAccount"][0]["Number_of_Full_Time_Employees__c"] = '1200'

        @helper.addLogs("[Step    ] booking tour from WebSite")
        emailId = @objAccAssignmentFromLead.createLead()
        expect(@driver.title).to match("Coworking Office Sambhav BKC | WeWork")

        @helper.addLogs("[Validate]  Lead should be created")
        lead = @objAccAssignmentFromLead.fetchLeadDetails(emailId).fetch('Id')
        expect(lead[0]).to_not eq 'nil'
        @helper.addLogs("[Expected]  Lead created successfully with emailId = #{emailId} \n[Result  ]  Success ")

        @helper.addLogs("[Step    ] logging to salesforce")
        expect(@objAccAssignmentFromLead.loginToSalesforce).to_not eq nil

        @helper.addLogs("[Step    ] go to details page of created lead and Clicking on 'Manage/book Tour' button")
        expect(@objAccAssignmentFromLead.goToDetailPage(lead[0].fetch('Id'))).to eq true


        @helper.addLogs("[Validate] Checking Manage Tour page when user click on 'Manage/book tour' button")
        expect(@driver.title).to match("Manage Tours")
        @helper.addLogs("[Expected] Manage tour page opened successfully with Page Title= Manage Tours \n[Result  ]  Success")

        @helper.addLogs("[Step    ] filling all required fields and booked a tour")

        expect(@objAccAssignmentFromLead.bookTour(0,true)).to eq true

        @helper.addLogs("[Step    ] click on Create Account and Don't Merge")
        expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Don't Merge",nil)).to eq true

        @helper.addLogs("[Step    ] checking fields...")

        @helper.addLogs("[Step    ] get building details of #{@testDataJSON['AccountAssignment']["tour"][0]["building"]}")
        building = @objAccAssignmentFromLead.fetchBuildingDetails(@testDataJSON['AccountAssignment']["tour"][0]["building"])
        expect(building[0]).to_not eq nil

        @helper.addLogs("[Step    ] get accQueue details")
        accQueue = @objAccAssignmentFromLead.fetAccOwnerQueue(building[0].fetch('Market__c'),'Enterprise Solutions')

        @helper.addLogs("[Step    ] get Contact details")
        contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
        expect(contact[0]).to_not eq nil

        @helper.addLogs("[Validate] contact:RecordType.Name")
        expect(contact[0].fetch('RecordType')['Name']).to eq "Consumer"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] contact:Owner.Id")
        expect(contact[0].fetch('Owner')['Id']).to eq "#{building[0].fetch('Community_Lead__c')}"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] contact:Number_of_Full_Time_Employees__c")
        expect(contact[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] contact:Looking_For_Number_Of_Desk__c")
        expect(contact[0].fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
        @helper.addLogs("[Result  ]  Success")


        puts "get Account Details"
        account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact[0].fetch('Id')}")
        expect(account[0]).to_not eq nil

        @helper.addLogs("[Validate] account:RecordType.Name")
        expect(account[0].fetch('RecordType')['Name']).to eq "Consumer"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Owner.Id")
        expect(account[0].fetch('Owner')['Id']).to eq "#{building[0].fetch('Community_Lead__c')}"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Number_of_Full_Time_Employees__c")
        expect(account[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Interested_in_Number_of_Desks__c")
        expect(account[0].fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        puts "get Opportunity details"
        opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact[0].fetch('Id')}")
        expect(opportunity[0]).to_not eq nil

        @helper.addLogs("[Validate] opportunity:RecordType.Name")
        expect(opportunity[0].fetch('RecordType')['Name']).to eq "Consumer"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] opportunity:Deal_Type__c")
        expect(opportunity[0].fetch('Deal_Type__c')).to eq "Transactional"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] opportunity:Owner.Id")
        expect(opportunity[0].fetch('Owner')['Id']).to eq "#{building[0].fetch('Community_Lead__c')}"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] opportunity:Quantity__c")
        expect(opportunity[0].fetch('Quantity__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        #@objAccAssignmentFromLead.updateProductAndOpp("#{opportunity[0].fetch('Id')}",'19',account[0].fetch('Id'),'Enterprise Solutions')

        updated_Acc = Hash["Number_of_Full_Time_Employees__c" => "#{@testDataJSON['AccountAssignment']["UpdatedAccount"][0]["Number_of_Full_Time_Employees__c"]}", "id" => account[0].fetch('Id')]

        @objAccAssignmentFromLead.update('Account',updated_Acc)
        sleep(20)

        puts "get Account Details"
        account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact[0].fetch('Id')}")
        expect(account[0]).to_not eq nil

        @helper.addLogs("[Validate] account:RecordType.Name")
        expect(account[0].fetch('RecordType')['Name']).to eq "Enterprise Solutions"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] contact:Owner.Id")
        expect(accQueue.include? account[0].fetch('Owner')['Id']).to eq true
        @helper.addLogs("[Result  ]  Success")


        @helper.addLogs("[Step    ] get Contact details")
        contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
        expect(contact[0]).to_not eq nil

        @helper.addLogs("[Validate] contact:RecordType.Name")
        expect(contact[0].fetch('RecordType')['Name']).to eq "Enterprise Solutions"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] contact:Owner.Id")
        puts accQueue.include? contact[0].fetch('Owner')['Id']
        ownerAssign = accQueue.include? contact[0].fetch('Owner')['Id']
        expect(ownerAssign).to eq true
        @helper.addLogs("[Result  ]  Success")


        puts "get Opportunity details"
        opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact[0].fetch('Id')}")
        expect(opportunity[0]).to_not eq nil

        @helper.addLogs("[Validate] opportunity:RecordType.Name")
        expect(opportunity[0].fetch('RecordType')['Name']).to eq "Enterprise Solutions"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] opportunity:Deal_Type__c")
        expect(opportunity[0].fetch('Deal_Type__c')).to eq "Relational"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] contact:Owner.Id")
        puts accQueue.include? opportunity[0].fetch('Owner')['Id'] 
        expect(accQueue.include? opportunity[0].fetch('Owner')['Id']).to eq true
        @helper.postSuccessResult('2077')
    rescue Exception => e
       raise e
       @helper.postFailResult(e,'2077')
    end
    end

  end

  context "account reassignment for closed won opportunity" do
    it "C2136 : To check the Account reassignment for closed Won opp- Mid-Market.", :'2136'=> 'true' do
      begin
        @helper.addLogs("C2076 : To check account assignment for Record Type Consumer and Deal type Transactional.",'2136')
        @testDataJSON['AccountAssignment']['tour'][0]['building']  = 'MUM-BKC'
        @testDataJSON['AccountAssignment']['tour'][0]['companySize']  = '25'
        @testDataJSON['AccountAssignment']['tour'][0]['numberOfDesks']  = '5'

        @helper.addLogs("[Step    ] booking tour from WebSite")
        emailId = @objAccAssignmentFromLead.createLead()
        expect(@driver.title).to match("Coworking Office")# Sambhav BKC | WeWork")

        @helper.addLogs("[Validate]  Journey should be created")
        journey = @objAccAssignmentFromLead.fetchJourneyDetails(emailId)
        expect(journey[0]).to_not eq nil
        @helper.addLogs("[Expected]  Journey created successfully with emailId = #{emailId} \n[Result  ]  Success ")

        @helper.addLogs("[Step    ] logging to salesforce")
        expect(@objAccAssignmentFromLead.loginToSalesforce).to_not eq nil

        @helper.addLogs("[Step    ] go to details page of created Journey and Clicking on 'Manage Tours' button")
        expect(@objAccAssignmentFromLead.openManageTouFromJourney(journey[0].fetch('Id'))).to eq true

        @helper.addLogs("[Validate] Checking Manage Tour page when user click on 'Manage/book tour' button")
        expect(@driver.title).to match("Manage Tours")
        @helper.addLogs("[Expected] Manage tour page opened successfully with Page Title= Manage Tours \n[Result  ]  Success")

        @helper.addLogs("[Step    ] filling all required fields and booked a tour")

        expect(@objAccAssignmentFromLead.bookTour(0,true,false)).to eq true

        @helper.addLogs("[Step    ] click on Create Account and Don't Merge")
        expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Don't Merge",nil)).to eq true

        @helper.addLogs("[Step    ] checking fields...")

        @helper.addLogs("[Step    ] get building details of #{@testDataJSON['AccountAssignment']["tour"][0]["building"]}")
        building = @objAccAssignmentFromLead.fetchBuildingDetails(@testDataJSON['AccountAssignment']["tour"][0]["building"])
        expect(building[0]).to_not eq nil

        @helper.addLogs("[Step    ] get Contact details")
        contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
        expect(contact[0]).to_not eq nil
        puts contact[0].fetch('Owner')['Name']   #********

        @helper.addLogs("[Validate] contact:RecordType.Name")
        expect(contact[0].fetch('RecordType')['Name']).to eq "Mid Market"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] contact:Owner.Id")
        expect(contact[0].fetch('Owner')['Id']).to eq "#{building[0].fetch('Community_Lead__c')}"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] contact:Number_of_Full_Time_Employees__c")
        expect(contact[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] contact:Looking_For_Number_Of_Desk__c")
        expect(contact[0].fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        puts "get Opportunity details"
        opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact[0].fetch('Id')}")
        expect(opportunity[0]).to_not eq nil

        @helper.addLogs("[Validate] opportunity:RecordType.Name")
        expect(opportunity[0].fetch('RecordType')['Name']).to eq "Mid Market"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] opportunity:Deal_Type__c")
        expect(opportunity[0].fetch('Deal_Type__c')).to eq "Transactional"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] opportunity:Owner.Id")
        expect(opportunity[0].fetch('Owner')['Id']).to eq "#{building[0].fetch('Community_Lead__c')}"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] opportunity:Quantity__c")
        expect(opportunity[0].fetch('Quantity__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        puts "get Account Details"
        account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact[0].fetch('Id')}")
        expect(account[0]).to_not eq nil

        @helper.addLogs("[Validate] account:RecordType.Name")
        expect(account[0].fetch('RecordType')['Name']).to eq "Mid Market"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Owner.Id")
        expect(account[0].fetch('Owner')['Id']).to eq "#{building[0].fetch('Community_Lead__c')}"
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Number_of_Full_Time_Employees__c")
        expect(account[0].fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["companySize"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        @helper.addLogs("[Validate] account:Interested_in_Number_of_Desks__c")
        expect(account[0].fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@testDataJSON['AccountAssignment']["tour"][0]["numberOfDesks"]}".to_i
        @helper.addLogs("[Result  ]  Success")

        #go to contact -> manage tour
        # create opp
        puts "1236"
        @helper.addLogs("[Step    ] Go to Contact detail page and book a tour by creating new opportunity")
        expect(@objAccAssignmentFromLead.goToDetailPage(contact[0].fetch('Id'))).to eq true
        expect(@objAccAssignmentFromLead.bookTour(0,true,true)).to eq true

        #go to Account
        # Change address
        @helper.addLogs("[Step    ] Update Account Address")
        updated_account = Hash['name' => "#{@testDataJSON['AccountAssignment']["UpdatedAccount"][0]["BillingCountry"]}","BillingCountry" => "#{@testDataJSON['AccountAssignment']["UpdatedAccount"][0]["BillingCountry"]}", "id" => account[0].fetch('Id')]
        #puts updated_account
        @objAccAssignmentFromLead.update('Account',updated_account)

        # change opp stage closed won
        @helper.addLogs("[Step    ] Update Opportunity Stage")
        updated_opp = Hash["StageName" => "#{@testDataJSON['AccountAssignment']["UpdatedOpportunity"][0]["StageName"]}", "id" => opportunity[0].fetch('Id')]
        @objAccAssignmentFromLead.update('Opportunity',updated_opp)

        @helper.addLogs("[Step    ] get Updated Account Details")
        account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact[0].fetch('Id')}")
        expect(account[0]).to_not eq nil
        puts account

        @helper.addLogs("[Step    ] get Owner based on address on Account")
        accQueue  = @objAccAssignmentFromLead.getOwnerbasedOnAddress(account)
        expect(accQueue[0]).to_not eq nil

        @helper.addLogs("[Validate] account:Owner.Id")
        expect(accQueue.include? account[0].fetch('Owner')['Id']).to eq true

        @helper.addLogs("[Step    ] get Updated Contact details")
        contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
        expect(contact[0]).to_not eq nil
        puts contact

        @helper.addLogs("[Validate] contact:Owner.Id")
        expect(accQueue.include? contact[0].fetch('Owner')['Id']).to eq true

        @helper.addLogs("[Step    ] get Updated Opportunity details")
        opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact[0].fetch('Id')}")
        expect(opportunity[0]).to_not eq nil
        puts opportunity

        puts opportunity[0].keys.size
        puts opportunity[0].keys[0]
        puts opportunity[0].values_at(opportunity[0].keys[0])
        puts opportunity[0].values_at(opportunity[0].keys[0]).class
        puts opportunity[0].values_at(opportunity[0].keys[0])[0]
        puts "12121212112121212"
        puts opportunity[0].values_at(opportunity[0].keys[0])[0].size

        i = 0
        until opportunity[0].keys[i] == nil do
          if opportunity[0].values_at(opportunity[0].keys[i])[0].fetch('StageName') != 'Closed Won' then
            @helper.addLogs("[Validate] opportunity:Owner.Id")
            expect(accQueue.include? opportunity[0].values_at(opportunity[0].keys[i])[0].fetch('Owner')['Id']).to eq true
          end
          i = i + 1
        end

      rescue Exception => e
        @helper.addLogs("[Result  ]  Fail")
        raise e
      end

    end

  end

    after(:all){

  }
  after(:each){

  }
  end