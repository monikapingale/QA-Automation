require_relative '../../Assignment/PageObjects/accountAssignmentFromLead.rb'
require 'json'
require 'yaml'
require 'selenium-webdriver'
require 'rspec'
#require 'faye'
require 'restforce'
require 'rails'
#require 'faye'
#require 'cookiejar'
require 'httparty'

require_relative File.expand_path('../..', Dir.pwd) + '/GemUtilities/EnziTestRailUtility/lib/EnziTestRailUtility.rb'
require_relative File.expand_path('',Dir.pwd )+ '/rollbarUtility.rb'




describe AccountAssignmentFromLead do
  RSpec.shared_examples "test" do
    context "Create Opportunity with global Action" do
      it 'Login by user', :test => true do
        puts "Shared examples....."
      end
    end
  end


  before(:all){
    @driver = Selenium::WebDriver.for :chrome
    @objAccAssignmentFromLead = AccountAssignmentFromLead.new(@driver)
    @testRailUtility = EnziTestRailUtility::TestRailUtility.new(@objAccAssignmentFromLead.instance_variable_get(:@mapCredentials)['TestRail']['username'],@objAccAssignmentFromLead.instance_variable_get(:@mapCredentials)['TestRail']['password'])
    @objRollbar = RollbarUtility.new()


  }

  it 'rollbar demo', :"451" => true do

    @@credentails = YAML.load_file('credentials.yaml')
    puts @@credentails
    data = {"grant_type"=>@@credentails['Nikhil']['grant_type'],"client_id"=>@@credentails['Nikhil']['client_id'],"client_secret"=>@@credentails['Nikhil']['client_secret'], "username"=>@@credentails['Nikhil']['username'],"password"=>"#{@@credentails['Nikhil']['password']}"}
    @@response = HTTParty.post("https://test.salesforce.com/services/oauth2/token",
                               :body => data,
                               :headers => {"Content-Type":'application/x-www-form-urlencoded'} , verify: false)
    puts @@response

    data1 = '{"body":{"last_name":"Smith","first_name":"John","email":"john.smith@example.com","phone":"8146185355","lead_source":"wework.com","lead_source_detail":"Book A Tour Form","utm_campaign_id":"701230000009Gd5","utm_campaign":"San Francisco - Modifier","utm_content":"utm contents","utm_medium":"cpc","utm_source":"ads-google","utm_term":"virtual +office +san +francisco","company_name":"John Smith","company_size":"21-50","company_industry":"Education","quick_quote_location":"New York City","notes":"Our Notes for","referral_code":"JetBlue","promo_code":"JetBlue","buildings_interested_uuids":["ebfec175-b235-4b92-b5ac-65202509137a"],"product_interests":["Office Space"],"product_line":"WeWork","locale":"US","country_code":"US","referrer_sfid":"","contact_referrer_only":true,"campaign_sfid":"7018A0000009txv"}}'

    url  = 'https://wework--nikhil.cs20.my.salesforce.com/services/apexrest/InboundLead/'

   postResponse = HTTParty.post(url,:body => data1,:headers => {"Content-Type":"application/json","Authorization" => "Bearer #{@@response['access_token']}"} , verify: false)
    puts postResponse
    puts postResponse['stackTrace']
    st = postResponse['stackTrace']


    Rollbar.configure do |config|
      config.access_token = "c1428909f1c446eca8396001c02c837f"
      #config.endpoint = 'https://api-alt.rollbar.com/api/1/item/'
      config.enabled = true
      config.environment = "sandbox"
      config.verify_ssl_peer = false
    end

    Rollbar.configure do |config|
      config.custom_data_method = lambda { { :Id => st, :Title => "title", :PassExpects => "passedExpects"}}
    end
    Rollbar.error("e")



    #@objRollbar.postRollbarData(caseInfo['id'], caseInfo['title'], passedLogs[caseInfo['id']])

    #

  end

 context "by Create Account and Dont Merge" do

  it "C2022 : To check account assignment for Record Type Consumer and Deal type Transactional.", :'2022'=> 'true' do
        begin

            caseInfo = @testRailUtility.getCase('2022')
            puts "C2022 : To check account assignment for Record Type Consumer and Deal type Transactional."

            @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['companySize']  = '15'
            @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['numberOfDesks']  = '5'
            @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['building']  = 'MUM-BKC'



            passedLogs = @objRollbar.addLog("[Step    ] get building details of #{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"]}", caseInfo['id'])
            building = @objAccAssignmentFromLead.fetchBuildingDetails(@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"])
            expect(building).to_not eq nil

            @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['LeadJSON'][0]['body']['buildings_interested_uuids'][0]  = building.fetch('UUID__c')


            passedLogs = @objRollbar.addLog("[Step    ] Creating lead")
            leadDetails = @objAccAssignmentFromLead.createLead()
            puts leadDetails
            puts leadDetails.class.class
            #expect(@driver.title).to match("Coworking Office Sambhav BKC | WeWork")

=begin
            #puts "lead created from web with emailId = #{emailId}"


            Restforce.log = true
            client = Restforce.new(username: 'monika.pingale@wework.com.qaauto',
                                   password: 'monikaPingale@123',
                                   host: 'test.salesforce.com',
                                   #security_token: 'l3WwT1P1u0BaUkLw8ocH5Wzp',
                                   client_id: '3MVG9PE4xB9wtoY9IbhNtYSuAVOegE_yR6h8s4fwIITYduuN1V8Tt84iUykgOM_X3lj7md_cCbNBlsN6D6LSc',
                                   client_secret: '3006740022073476903',
                                   authentication_callback: Proc.new { |x| puts x },
                                   api_version: '41.0',
                                   request_headers: { 'sforce-auto-assign' => 'FALSE' })


            #puts client
            #accounts = client.query_all("select Id, Name from Lead") #where emailId = #{emailId}")
            #puts accounts.map(&:Id)
            #puts accounts.class


            #client.picklist_values('Account', 'Type')
            #client.user_info
            #client.describe_layouts('Account', '0010x00000FFB8c')


            client.create!('PushTopic',
                           ApiVersion: '41.0',
                           Name: 'AllLeads6',
                           Description: 'All lead records',
                           NotifyForOperationCreate: 'true',
                           NotifyForOperationUpdate: 'true',
                           #NotifyForOperations: 'All',
                           NotifyForFields: 'All',
                           Query: 'select Id,name from opportunity')



            client.create!('PushTopic',
                           ApiVersion: '41.0',
                           Name: 'PushTopic_Lead',
                           Description: 'All lead records',
                           NotifyForOperationCreate: 'true',
                           NotifyForOperationUpdate: 'true',
                           #NotifyForOperations: 'All',
                           NotifyForFields: 'All',
                           Query: 'select Id,email from Lead')


              EM.run do
                # Subscribe to the PushTopic.
                client.subscribe 'AllLeads6' do |message|
                  puts message.inspect
                  raise StopIteration , message.inspect
                end
              end
            rescue Exception => StopIteration
              puts "catching event in pushtopic"
              puts StopIteration
              puts StopIteration['event']['type']
              puts StopIteration['sobject']['email']
            end
=end

            passedLogs = @objRollbar.addLog("[Validate]  Lead should be created")

            leadId = nil
            emailId  = nil
            if !(leadDetails.class == Array) then
              puts 'array not return'
              puts leadDetails.class
              emailId = leadDetails
              leadId = @objAccAssignmentFromLead.fetchLeadDetails(leadDetails).fetch('Id')
            else
              puts 'Array return'
              emailId = leadDetails[1]
              leadId = leadDetails[0]
            end


          puts leadDetails
          puts emailId
          puts leadId


            passedLogs = @objRollbar.addLog("[Expected]  Lead created successfully with emailId = #{emailId} \n[Result  ]  Success ")
            expect(leadId).to_not eq 'nil'

          if false and (@objAccAssignmentFromLead.instance_variable_get(:@mapCredentials)['Staging']['WeWork System Administrator']['username'].include? "staging" or @objAccAssignmentFromLead.instance_variable_get(:@mapCredentials)['Staging']['WeWork System Administrator']['username'].include? 'preprod') then
                passedLogs = @objRollbar.addLog("[Step    ] logging to salesforce")
                expect(@objAccAssignmentFromLead.loginToSalesforce).to_not eq nil

                passedLogs = @objRollbar.addLog("[Step    ] go to details page of created lead and Clicking on 'Manage/book Tour' button")
                expect(@objAccAssignmentFromLead.goToDetailPage(leadId)).to eq true


                passedLogs = @objRollbar.addLog("[Validate] Checking Manage Tour page when user click on 'Manage/book tour' button")
                expect(@driver.title).to match("Manage Tours")
                passedLogs = @objRollbar.addLog("[Expected] Manage tour page opened successfully with Page Title= Manage Tours \n[Result  ]  Success")

                passedLogs = @objRollbar.addLog("[Step    ] filling all required fields and booked a tour")

                expect(@objAccAssignmentFromLead.bookTour(0,true)).to eq true

                passedLogs = @objRollbar.addLog("[Step    ] click on Create Account and Don't Merge")
                expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Don't Merge",nil)).to eq true
          else
            #book a tour using restAPI
            #
            passedLogs = @objRollbar.addLog("[Step    ] Book a tour using restAPI")
            expect(@objAccAssignmentFromLead.bookTour(0,true)).to eq true

          end
            passedLogs = @objRollbar.addLog("[Step    ] checking fields...")



            passedLogs = @objRollbar.addLog("[Step    ] get Contact details")
            contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
            expect(contact).to_not eq nil

            passedLogs = @objRollbar.addLog("[Validate] contact:RecordType.Name")
            expect(contact.fetch('RecordType.Name')).to eq "Consumer"
            passedLogs = @objRollbar.addLog("[Result  ]  Success")

            passedLogs = @objRollbar.addLog("[Validate] contact:Owner.Id")
            expect(contact.fetch('Owner.Id')).to eq "#{building.fetch('Community_Lead__c')}"
            passedLogs = @objRollbar.addLog("[Result  ]  Success")

            passedLogs = @objRollbar.addLog("[Validate] contact:Number_of_Full_Time_Employees__c")
            expect(contact.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
            passedLogs = @objRollbar.addLog("[Result  ]  Success")

            passedLogs = @objRollbar.addLog("[Validate] contact:Looking_For_Number_Of_Desk__c")
            expect(contact.fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
            passedLogs = @objRollbar.addLog("[Result  ]  Success")

            puts "get Opportunity details"
            opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact.fetch('Id')}")
            puts opportunity

            passedLogs = @objRollbar.addLog("[Validate] opportunity:RecordType.Name")
            expect(opportunity.fetch('RecordType.Name')).to eq "Consumer"
            passedLogs = @objRollbar.addLog("[Result  ]  Success")

            passedLogs = @objRollbar.addLog("[Validate] opportunity:Deal_Type__c")
            expect(opportunity.fetch('Deal_Type__c')).to eq "Transactional"
            passedLogs = @objRollbar.addLog("[Result  ]  Success")

            passedLogs = @objRollbar.addLog("[Validate] opportunity:Owner.Id")
            expect(opportunity.fetch('Owner.Id')).to eq "#{building.fetch('Community_Lead__c')}"
            passedLogs = @objRollbar.addLog("[Result  ]  Success")

            passedLogs = @objRollbar.addLog("[Validate] opportunity:Quantity__c")
            expect(opportunity.fetch('Quantity__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
            passedLogs = @objRollbar.addLog("[Result  ]  Success")

            puts "get Account Details"
            account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact.fetch('Id')}")

            passedLogs = @objRollbar.addLog("[Validate] account:RecordType.Name")
            expect(account.fetch('RecordType.Name')).to eq "Consumer"
            passedLogs = @objRollbar.addLog("[Result  ]  Success")

            passedLogs = @objRollbar.addLog("[Validate] account:Owner.Id")
            expect(account.fetch('Owner.Id')).to eq "#{building.fetch('Community_Lead__c')}"
            passedLogs = @objRollbar.addLog("[Result  ]  Success")

            passedLogs = @objRollbar.addLog("[Validate] account:Number_of_Full_Time_Employees__c")
            expect(account.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
            passedLogs = @objRollbar.addLog("[Result  ]  Success")

            passedLogs = @objRollbar.addLog("[Validate] account:Interested_in_Number_of_Desks__c")
            expect(account.fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
            passedLogs = @objRollbar.addLog("[Result  ]  Success")

      rescue Exception => e
            passedLogs = @objRollbar.addLog("[Result  ]  Fail")
            raise e
      end

  end

  it "C2028 : To check account assignment for Record Type Consumer and Deal type Relational.", :'2028'=> 'true' do
    begin
      puts "C2028 : To check account assignment for Record Type Consumer and Deal type Relational."

      @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['companySize']  = '15'
      @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['numberOfDesks']  = '13'
      @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['building']  = 'MUM-BKC'

      caseInfo = @testRailUtility.getCase('2022')
      passedLogs = @objRollbar.addLog("[Step    ] booking tour from WebSite", caseInfo['id'])
      emailId = @objAccAssignmentFromLead.createLead()
      expect(@driver.title).to match("Coworking Office Sambhav BKC | WeWork")

      passedLogs = @objRollbar.addLog("[Validate]  Lead should be created")
      leadId = @objAccAssignmentFromLead.fetchLeadDetails(emailId).fetch('Id')
      expect(leadId).to_not eq 'nil'
      passedLogs = @objRollbar.addLog("[Expected]  Lead created successfully with emailId = #{emailId} \n[Result  ]  Success ")

      passedLogs = @objRollbar.addLog("[Step    ] logging to salesforce")
      @objAccAssignmentFromLead.loginToSalesforce

      passedLogs = @objRollbar.addLog("[Step    ] go to details page of created lead and Clicking on 'Manage/book Tour' button")
      expect(@objAccAssignmentFromLead.goToDetailPage(leadId)).to eq true


      passedLogs = @objRollbar.addLog("[Validate] Checking Manage Tour page when user click on 'Manage/book tour' button")
      expect(@driver.title).to match("Manage Tours")
      passedLogs = @objRollbar.addLog("[Expected] Manage tour page opened successfully with Page Title= Manage Tours \n[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Step    ] filling all required fields and booked a tour")

      expect(@objAccAssignmentFromLead.bookTour(0,true)).to eq true

      passedLogs = @objRollbar.addLog("[Step    ] click on Create Account and Don't Merge")
      @objAccAssignmentFromLead.instance_variable_get(:@wait).until {@driver.find_element(:id ,"header43").displayed?}
      expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Don't Merge",nil)).to eq true

      passedLogs = @objRollbar.addLog("[Step    ] checking fields...")

      passedLogs = @objRollbar.addLog("[Step    ] get building details of #{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"]}")
      building = @objAccAssignmentFromLead.fetchBuildingDetails(@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"])
      expect(building).to_not eq nil

      passedLogs = @objRollbar.addLog("[Step    ] get Contact details")
      contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
      expect(contact).to_not eq nil

      passedLogs = @objRollbar.addLog("[Validate] contact:RecordType.Name")
      expect(contact.fetch('RecordType.Name')).to eq "Consumer"
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Validate] contact:Owner.Id")
      expect(contact.fetch('Owner.Name')).to eq "#{building.fetch('Cluster_Sales_Lead_Name__c')}"
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Validate] contact:Number_of_Full_Time_Employees__c")
      expect(contact.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Validate] contact:Looking_For_Number_Of_Desk__c")
      expect(contact.fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      puts "get Opportunity details"
      opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact.fetch('Id')}")

      passedLogs = @objRollbar.addLog("[Validate] opportunity:RecordType.Name")
      expect(opportunity.fetch('RecordType.Name')).to eq "Consumer"
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Validate] opportunity:Deal_Type__c")
      expect(opportunity.fetch('Deal_Type__c')).to eq "Relational"
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Validate] opportunity:Owner.Id")
      expect(opportunity.fetch('Owner.Name')).to eq "#{building.fetch('Cluster_Sales_Lead_Name__c')}"
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Validate] opportunity:Quantity__c")
      expect(opportunity.fetch('Quantity__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      puts "get Account Details"
      account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact.fetch('Id')}")

      passedLogs = @objRollbar.addLog("[Validate] account:RecordType.Name")
      expect(account.fetch('RecordType.Name')).to eq "Consumer"
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Validate] account:Owner.Name")
      expect(account.fetch('Owner.Name')).to eq "#{building.fetch('Cluster_Sales_Lead_Name__c')}"
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Validate] account:Number_of_Full_Time_Employees__c")
      expect(account.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Validate] account:Interested_in_Number_of_Desks__c")
      expect(account.fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

    rescue Exception => e
      passedLogs = @objRollbar.addLog("[Result  ]  Fail")
      raise e
    end

  end

  it "C2040 : To check account assignment for Record Type Consumer and Deal type Strategic.", :'2040'=> 'true' do
    begin
      puts "C2040 : To check account assignment for Record Type Consumer and Deal type Strategic."

      @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['companySize']  = '15'
      @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['numberOfDesks']  = '25'

      caseInfo = @testRailUtility.getCase('2040')
      passedLogs = @objRollbar.addLog("[Step    ] booking tour from WebSite", caseInfo['id'])
      emailId = @objAccAssignmentFromLead.createLead()
      expect(@driver.title).to match("Coworking Office Sambhav BKC | WeWork")

      passedLogs = @objRollbar.addLog("[Validate]  Lead should be created")
      leadId = @objAccAssignmentFromLead.fetchLeadDetails(emailId).fetch('Id')
      expect(leadId).to_not eq 'nil'
      passedLogs = @objRollbar.addLog("[Expected]  Lead created successfully with emailId = #{emailId} \n[Result  ]  Success ")

      passedLogs = @objRollbar.addLog("[Step    ] logging to salesforce")
      @objAccAssignmentFromLead.loginToSalesforce

      passedLogs = @objRollbar.addLog("[Step    ] go to details page of created lead and Clicking on 'Manage/book Tour' button")
      expect(@objAccAssignmentFromLead.goToDetailPage(leadId)).to eq true


      passedLogs = @objRollbar.addLog("[Validate] Checking Manage Tour page when user click on 'Manage/book tour' button")
      expect(@driver.title).to match("Manage Tours")
      passedLogs = @objRollbar.addLog("[Expected] Manage tour page opened successfully with Page Title= Manage Tours \n[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Step    ] filling all required fields and booked a tour")

      expect(@objAccAssignmentFromLead.bookTour(0,true)).to eq true

      passedLogs = @objRollbar.addLog("[Step    ] click on Create Account and Don't Merge")
      @objAccAssignmentFromLead.instance_variable_get(:@wait).until {@driver.find_element(:id ,"header43").displayed?}
      expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Don't Merge",nil)).to eq true

      passedLogs = @objRollbar.addLog("[Step    ] checking fields...")

      passedLogs = @objRollbar.addLog("[Step    ] get building details of #{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"]}")
      building = @objAccAssignmentFromLead.fetchBuildingDetails(@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"])
      expect(building).to_not eq nil

      passedLogs = @objRollbar.addLog("[Step    ] get accQueue details")
      accQueue = @objAccAssignmentFromLead.fetAccOwnerQueue(building.fetch('Market__c'),'Consumer')

      passedLogs = @objRollbar.addLog("[Step    ] get Contact details")
      contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
      expect(contact).to_not eq nil

      passedLogs = @objRollbar.addLog("[Validate] contact:RecordType.Name")
      expect(contact.fetch('RecordType.Name')).to eq "Consumer"
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Validate] contact:Owner.Id")
      ownerAssign = accQueue.include? contact.fetch('Owner.Id')
      expect(ownerAssign).to eq true
      #expect(contact.fetch('Owner.Id')).to eq "#{accQueue.fetch('Member__c')}"
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Validate] contact:Number_of_Full_Time_Employees__c")
      expect(contact.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Validate] contact:Looking_For_Number_Of_Desk__c")
      expect(contact.fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      puts "get Opportunity details"
      opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact.fetch('Id')}")
      puts opportunity

      passedLogs = @objRollbar.addLog("[Validate] opportunity:RecordType.Name")
      expect(opportunity.fetch('RecordType.Name')).to eq "Consumer"
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Validate] opportunity:Deal_Type__c")
      expect(opportunity.fetch('Deal_Type__c')).to eq "Strategic"
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Validate] opportunity:Owner.Id")
      ownerAssign = accQueue.include? opportunity.fetch('Owner.Id')
      expect(ownerAssign).to eq true
      #expect(opportunity.fetch('Owner.Id')).to eq "#{accQueue.fetch('Member__c')}"
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Validate] opportunity:Quantity__c")
      expect(opportunity.fetch('Quantity__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      puts "get Account Details"
      account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact.fetch('Id')}")
      puts account

      passedLogs = @objRollbar.addLog("[Validate] account:RecordType.Name")
      expect(account.fetch('RecordType.Name')).to eq "Consumer"
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Validate] account:Owner.Name")
      ownerAssign = accQueue.include? account.fetch('Owner.Id')
      expect(ownerAssign).to eq true

      #expect(account.fetch('Owner.Id')).to eq "#{accQueue.fetch('Member__c')}"
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Validate] account:Number_of_Full_Time_Employees__c")
      expect(account.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Validate] account:Interested_in_Number_of_Desks__c")
      expect(account.fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

    rescue Exception => e
      passedLogs = @objRollbar.addLog("[Result  ]  Fail")
      raise e
    end

  end

  it "C2041 : To check account assignment for Record Type Consumer and Deal type Relational.", :'2041'=> 'true'  do
    begin
      puts "C2041 : To check account assignment for Record Type Consumer and Deal type Strategic.(Queue is not present in the Account Queue Setting)."

      caseInfo = @testRailUtility.getCase('2041')
      @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['building']  = 'SYD-Martin Place'

      #puts caseInfo
      passedLogs = @objRollbar.addLog("[Step    ] booking tour from WebSite", caseInfo['id'])
      emailId = @objAccAssignmentFromLead.createLead()
      #expect(@driver.title).to match("Coworking Office Sambhav BKC | WeWork")

      sleep (10)
      passedLogs = @objRollbar.addLog("[Validate]  Lead should be created")
      leadId = @objAccAssignmentFromLead.fetchLeadDetails(emailId).fetch('Id')
      expect(leadId).to_not eq 'nil'

      passedLogs = @objRollbar.addLog("[Expected]  Lead created successfully with emailId = #{emailId} \n[Result  ]  Success ")

      passedLogs = @objRollbar.addLog("[Step    ] logging to salesforce")
      @objAccAssignmentFromLead.loginToSalesforce

      passedLogs = @objRollbar.addLog("[Step    ] go to details page of created lead and Clicking on 'Manage/book Tour' button")
      expect(@objAccAssignmentFromLead.goToDetailPage(leadId)).to eq true


      passedLogs = @objRollbar.addLog("[Validate] Checking Manage Tour page when user click on 'Manage/book tour' button")
      expect(@driver.title).to match("Manage Tours")
      passedLogs = @objRollbar.addLog("[Expected] Manage tour page opened successfully with Page Title= Manage Tours \n[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Step    ] filling all required fields and booked a tour")
      @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['companySize']  = '15'
      @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['numberOfDesks']  = '25'

      expect(@objAccAssignmentFromLead.bookTour(0,true)).to eq true

      passedLogs = @objRollbar.addLog("[Step    ] click on Create Account and Don't Merge")
      @objAccAssignmentFromLead.instance_variable_get(:@wait).until {@driver.find_element(:id ,"header43").displayed?}
      expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Don't Merge",nil)).to eq true

      passedLogs = @objRollbar.addLog("[Step    ] checking fields...")

      passedLogs = @objRollbar.addLog("[Step    ] get building details of #{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"]}")
      building = @objAccAssignmentFromLead.fetchBuildingDetails(@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"])
      expect(building).to_not eq nil

      #passedLogs = @objRollbar.addLog("[Step    ] get accQueue details")
      #accQueue = @objAccAssignmentFromLead.fetAccOwnerQueue(building.fetch('Market__c'),'Consumer')

      passedLogs = @objRollbar.addLog("[Step    ] get Contact details")
      contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
      expect(contact).to_not eq nil

      passedLogs = @objRollbar.addLog("[Validate] contact:RecordType.Name")
      expect(contact.fetch('RecordType.Name')).to eq "Consumer"
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Validate] contact:Owner.Id")
      expect(contact.fetch('Owner.Id')).to eq "005F0000003KmbwIAC"
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Validate] contact:Number_of_Full_Time_Employees__c")
      expect(contact.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Validate] contact:Looking_For_Number_Of_Desk__c")
      expect(contact.fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      puts "get Opportunity details"
      opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact.fetch('Id')}")

      passedLogs = @objRollbar.addLog("[Validate] opportunity:RecordType.Name")
      expect(opportunity.fetch('RecordType.Name')).to eq "Consumer"
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Validate] opportunity:Deal_Type__c")
      expect(opportunity.fetch('Deal_Type__c')).to eq "Strategic"
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Validate] opportunity:Owner.Id")
      expect(opportunity.fetch('Owner.Id')).to eq "005F0000003KmbwIAC"
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Validate] opportunity:Quantity__c")
      expect(opportunity.fetch('Quantity__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      puts "get Account Details"
      account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact.fetch('Id')}")

      passedLogs = @objRollbar.addLog("[Validate] account:RecordType.Name")
      expect(account.fetch('RecordType.Name')).to eq "Consumer"
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Validate] account:Owner.Name")
      expect(account.fetch('Owner.Id')).to eq "005F0000003KmbwIAC"
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Validate] account:Number_of_Full_Time_Employees__c")
      expect(account.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Validate] account:Interested_in_Number_of_Desks__c")
      expect(account.fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

    rescue Exception => e
      passedLogs = @objRollbar.addLog("[Result  ]  Fail")
      raise e
    end

  end

  it "C2042 : To Check Account assignment for Record Type Mid-Market and Deal type Transactional.", :'2042'=> 'true' do
    begin
      puts "C2042 : To Check Account assignment for Record Type Mid-Market and Deal type Transactional."
      @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['building']  = 'SYD-Martin Place'
      @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['companySize']  = '24'
      @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['numberOfDesks']  = '7'


      caseInfo = @testRailUtility.getCase('2042')
      #puts caseInfo
      passedLogs = @objRollbar.addLog("[Step    ] booking tour from WebSite", caseInfo['id'])
      emailId = @objAccAssignmentFromLead.createLead()
      #expect(@driver.title).to match("Coworking Office Sambhav BKC | WeWork")

      passedLogs = @objRollbar.addLog("[Validate]  Lead should be created")
      leadId = @objAccAssignmentFromLead.fetchLeadDetails(emailId).fetch('Id')
      expect(leadId).to_not eq 'nil'
      passedLogs = @objRollbar.addLog("[Expected]  Lead created successfully with emailId = #{emailId} \n[Result  ]  Success ")

      passedLogs = @objRollbar.addLog("[Step    ] logging to salesforce")
      @objAccAssignmentFromLead.loginToSalesforce

      passedLogs = @objRollbar.addLog("[Step    ] go to details page of created lead and Clicking on 'Manage/book Tour' button")
      expect(@objAccAssignmentFromLead.goToDetailPage(leadId)).to eq true

      passedLogs = @objRollbar.addLog("[Validate] Checking Manage Tour page when user click on 'Manage/book tour' button")
      expect(@driver.title).to match("Manage Tours")
      passedLogs = @objRollbar.addLog("[Expected] Manage tour page opened successfully with Page Title= Manage Tours \n[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Step    ] filling all required fields and booked a tour")

      expect(@objAccAssignmentFromLead.bookTour(0,true)).to eq true

      passedLogs = @objRollbar.addLog("[Step    ] click on Create Account and Don't Merge")
      @objAccAssignmentFromLead.instance_variable_get(:@wait).until {@driver.find_element(:id ,"header43").displayed?}
      expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Don't Merge",nil)).to eq true

      passedLogs = @objRollbar.addLog("[Step    ] checking fields...")

      passedLogs = @objRollbar.addLog("[Step    ] get building details of #{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"]}")
      building = @objAccAssignmentFromLead.fetchBuildingDetails(@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"])
      expect(building).to_not eq nil

      passedLogs = @objRollbar.addLog("[Step    ] get Contact details")
      contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
      expect(contact).to_not eq nil

      passedLogs = @objRollbar.addLog("[Validate] contact:RecordType.Name")
      expect(contact.fetch('RecordType.Name')).to eq "Mid Market"
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Validate] contact:Owner.Id")
      expect(contact.fetch('Owner.Id')).to eq "#{building.fetch('Community_Lead__c')}"
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Validate] contact:Number_of_Full_Time_Employees__c")
      expect(contact.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Validate] contact:Looking_For_Number_Of_Desk__c")
      expect(contact.fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      puts "get Opportunity details"
      opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact.fetch('Id')}")

      passedLogs = @objRollbar.addLog("[Validate] opportunity:RecordType.Name")
      expect(opportunity.fetch('RecordType.Name')).to eq "Mid Market"
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Validate] opportunity:Deal_Type__c")
      expect(opportunity.fetch('Deal_Type__c')).to eq "Transactional"
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Validate] opportunity:Owner.Id")
      expect(opportunity.fetch('Owner.Id')).to eq "#{building.fetch('Community_Lead__c')}"
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Validate] opportunity:Quantity__c")
      expect(opportunity.fetch('Quantity__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      puts "get Account Details"
      account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact.fetch('Id')}")

      passedLogs = @objRollbar.addLog("[Validate] account:RecordType.Name")
      expect(account.fetch('RecordType.Name')).to eq "Mid Market"
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Validate] account:Owner.Id")
      expect(account.fetch('Owner.Id')).to eq "#{building.fetch('Community_Lead__c')}"
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Validate] account:Number_of_Full_Time_Employees__c")
      expect(account.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Validate] account:Interested_in_Number_of_Desks__c")
      expect(account.fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

    rescue Exception => e
      passedLogs = @objRollbar.addLog("[Result  ]  Fail")
      raise e
    end

  end

  it "C2043 : To Check Account Assignment for Record type Mid-Market and Deal type Relational.", :'2043'=> 'true' do
    begin
      puts "C2043 : To Check Account Assignment for Record type Mid-Market and Deal type Relational."

      caseInfo = @testRailUtility.getCase('2022')
      #puts caseInfo
      @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['building']  = 'SYD-Martin Place'
      @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['companySize']  = '24'
      @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['numberOfDesks']  = '15'

      passedLogs = @objRollbar.addLog("[Step    ] booking tour from WebSite", caseInfo['id'])
      emailId = @objAccAssignmentFromLead.createLead()
      expect(@driver.title).to match("Coworking Office Sambhav BKC | WeWork")

      passedLogs = @objRollbar.addLog("[Validate]  Lead should be created")
      leadId = @objAccAssignmentFromLead.fetchLeadDetails(emailId).fetch('Id')
      expect(leadId).to_not eq 'nil'
      passedLogs = @objRollbar.addLog("[Expected]  Lead created successfully with emailId = #{emailId} \n[Result  ]  Success ")

      passedLogs = @objRollbar.addLog("[Step    ] logging to salesforce")
      @objAccAssignmentFromLead.loginToSalesforce

      passedLogs = @objRollbar.addLog("[Step    ] go to details page of created lead and Clicking on 'Manage/book Tour' button")
      expect(@objAccAssignmentFromLead.goToDetailPage(leadId)).to eq true


      passedLogs = @objRollbar.addLog("[Validate] Checking Manage Tour page when user click on 'Manage/book tour' button")
      expect(@driver.title).to match("Manage Tours")
      passedLogs = @objRollbar.addLog("[Expected] Manage tour page opened successfully with Page Title= Manage Tours \n[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Step    ] filling all required fields and booked a tour")
      expect(@objAccAssignmentFromLead.bookTour(0,true)).to eq true

      passedLogs = @objRollbar.addLog("[Step    ] click on Create Account and Don't Merge")
      @objAccAssignmentFromLead.instance_variable_get(:@wait).until {@driver.find_element(:id ,"header43").displayed?}
      expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Don't Merge",nil)).to eq true

      passedLogs = @objRollbar.addLog("[Step    ] checking fields...")

      passedLogs = @objRollbar.addLog("[Step    ] get building details of #{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"]}")
      building = @objAccAssignmentFromLead.fetchBuildingDetails(@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"])
      expect(building).to_not eq nil

      passedLogs = @objRollbar.addLog("[Step    ] get Contact details")
      contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
      expect(contact).to_not eq nil

      passedLogs = @objRollbar.addLog("[Validate] contact:RecordType.Name")
      expect(contact.fetch('RecordType.Name')).to eq "Mid Market"
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Validate] contact:Owner.Id")
      expect(contact.fetch('Owner.Name')).to eq "#{building.fetch('Cluster_Sales_Lead_Name__c')}"
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Validate] contact:Number_of_Full_Time_Employees__c")
      expect(contact.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Validate] contact:Looking_For_Number_Of_Desk__c")
      expect(contact.fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      puts "get Opportunity details"
      opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact.fetch('Id')}")

      passedLogs = @objRollbar.addLog("[Validate] opportunity:RecordType.Name")
      expect(opportunity.fetch('RecordType.Name')).to eq "Mid Market"
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Validate] opportunity:Deal_Type__c")
      expect(opportunity.fetch('Deal_Type__c')).to eq "Relational"
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Validate] opportunity:Owner.Id")
      expect(opportunity.fetch('Owner.Name')).to eq "#{building.fetch('Cluster_Sales_Lead_Name__c')}"
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Validate] opportunity:Quantity__c")
      expect(opportunity.fetch('Quantity__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      puts "get Account Details"
      account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact.fetch('Id')}")

      passedLogs = @objRollbar.addLog("[Validate] account:RecordType.Name")
      expect(account.fetch('RecordType.Name')).to eq "Mid Market"
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Validate] account:Owner.Name")
      expect(account.fetch('Owner.Name')).to eq "#{building.fetch('Cluster_Sales_Lead_Name__c')}"
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Validate] account:Number_of_Full_Time_Employees__c")
      expect(account.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Validate] account:Interested_in_Number_of_Desks__c")
      expect(account.fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

    rescue Exception => e
      passedLogs = @objRollbar.addLog("[Result  ]  Fail")
      raise e
    end

  end

  it "C2044 : To Check Account Assignment from Record type Mid-Market and Deal Type Strategic.", :'2044'=> 'true' do
    begin
      puts "C2044 : To check account assignment for Record Type Consumer and Deal type Relational."

      @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['building']  = 'SYD-Martin Place'
      @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['companySize']  = '24'
      @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['numberOfDesks']  = '27'

      caseInfo = @testRailUtility.getCase('2044')
      #puts caseInfo
      passedLogs = @objRollbar.addLog("[Step    ] booking tour from WebSite", caseInfo['id'])
      emailId = @objAccAssignmentFromLead.createLead()
      expect(@driver.title).to match("Coworking Office Sambhav BKC | WeWork")

      passedLogs = @objRollbar.addLog("[Validate]  Lead should be created")
      leadId = @objAccAssignmentFromLead.fetchLeadDetails(emailId).fetch('Id')
      expect(leadId).to_not eq 'nil'
      passedLogs = @objRollbar.addLog("[Expected]  Lead created successfully with emailId = #{emailId} \n[Result  ]  Success ")

      passedLogs = @objRollbar.addLog("[Step    ] logging to salesforce")
      @objAccAssignmentFromLead.loginToSalesforce

      passedLogs = @objRollbar.addLog("[Step    ] go to details page of created lead and Clicking on 'Manage/book Tour' button")
      expect(@objAccAssignmentFromLead.goToDetailPage(leadId)).to eq true


      passedLogs = @objRollbar.addLog("[Validate] Checking Manage Tour page when user click on 'Manage/book tour' button")
      expect(@driver.title).to match("Manage Tours")
      passedLogs = @objRollbar.addLog("[Expected] Manage tour page opened successfully with Page Title= Manage Tours \n[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Step    ] filling all required fields and booked a tour")

      expect(@objAccAssignmentFromLead.bookTour(0,true)).to eq true

      passedLogs = @objRollbar.addLog("[Step    ] click on Create Account and Don't Merge")
      @objAccAssignmentFromLead.instance_variable_get(:@wait).until {@driver.find_element(:id ,"header43").displayed?}
      expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Don't Merge",nil)).to eq true

      passedLogs = @objRollbar.addLog("[Step    ] checking fields...")

      passedLogs = @objRollbar.addLog("[Step    ] get building details of #{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"]}")
      building = @objAccAssignmentFromLead.fetchBuildingDetails(@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"])
      expect(building).to_not eq nil

      passedLogs = @objRollbar.addLog("[Step    ] get accQueue details")

      accQueue = @objAccAssignmentFromLead.fetAccOwnerQueue(building.fetch('Market__c'),'Mid Market')

      passedLogs = @objRollbar.addLog("[Step    ] get Contact details")
      contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
      expect(contact).to_not eq nil

      passedLogs = @objRollbar.addLog("[Validate] contact:RecordType.Name")
      expect(contact.fetch('RecordType.Name')).to eq "Mid Market"
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Validate] contact:Owner.Id")

      puts accQueue.include? contact.fetch('Owner.Id')
      ownerAssign = accQueue.include? contact.fetch('Owner.Id')
      expect(ownerAssign).to eq true

      #expect(contact.fetch('Owner.Id')).to eq "#{accQueue.fetch('Member__c')}"
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Validate] contact:Number_of_Full_Time_Employees__c")
      expect(contact.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Validate] contact:Looking_For_Number_Of_Desk__c")
      expect(contact.fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      puts "get Opportunity details"
      opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact.fetch('Id')}")
      puts opportunity

      passedLogs = @objRollbar.addLog("[Validate] opportunity:RecordType.Name")
      expect(opportunity.fetch('RecordType.Name')).to eq "Mid Market"
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Validate] opportunity:Deal_Type__c")
      expect(opportunity.fetch('Deal_Type__c')).to eq "Strategic"
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Validate] opportunity:Owner.Id")
      ownerAssign = accQueue.include? opportunity.fetch('Owner.Id')
      expect(ownerAssign).to eq true

      #expect(opportunity.fetch('Owner.Id')).to eq "#{accQueue.fetch('Member__c')}"
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Validate] opportunity:Quantity__c")
      expect(opportunity.fetch('Quantity__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      puts "get Account Details"
      account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact.fetch('Id')}")
      puts account

      passedLogs = @objRollbar.addLog("[Validate] account:RecordType.Name")
      expect(account.fetch('RecordType.Name')).to eq "Mid Market"
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Validate] account:Owner.Name")
      ownerAssign = accQueue.include? account.fetch('Owner.Id')
      expect(ownerAssign).to eq true
      #expect(account.fetch('Owner.Id')).to eq "#{accQueue.fetch('Member__c')}"
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Validate] account:Number_of_Full_Time_Employees__c")
      expect(account.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Validate] account:Interested_in_Number_of_Desks__c")
      expect(account.fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

    rescue Exception => e
      passedLogs = @objRollbar.addLog("[Result  ]  Fail")
      raise e
    end

  end

  it "C2045 : To Check Account Assignment for Record Type Enterprise and Deal type Transactional.", :'2045'=> 'true' do
    begin
      puts "C2045 : To Check Account Assignment for Record Type Enterprise and Deal type Transactional."

      @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['building']  = 'MEL-Bourke Street'
      @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['companySize']  = '1200'
      @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['numberOfDesks']  = '7'

      caseInfo = @testRailUtility.getCase('2045')
      #puts caseInfo
      passedLogs = @objRollbar.addLog("[Step    ] booking tour from WebSite", caseInfo['id'])
      emailId = @objAccAssignmentFromLead.createLead()
      expect(@driver.title).to match("Coworking Office Sambhav BKC | WeWork")

      passedLogs = @objRollbar.addLog("[Validate]  Lead should be created")
      leadId = @objAccAssignmentFromLead.fetchLeadDetails(emailId).fetch('Id')
      expect(leadId).to_not eq 'nil'
      passedLogs = @objRollbar.addLog("[Expected]  Lead created successfully with emailId = #{emailId} \n[Result  ]  Success ")

      passedLogs = @objRollbar.addLog("[Step    ] logging to salesforce")
      @objAccAssignmentFromLead.loginToSalesforce

      passedLogs = @objRollbar.addLog("[Step    ] go to details page of created lead and Clicking on 'Manage/book Tour' button")
      expect(@objAccAssignmentFromLead.goToDetailPage(leadId)).to eq true


      passedLogs = @objRollbar.addLog("[Validate] Checking Manage Tour page when user click on 'Manage/book tour' button")
      expect(@driver.title).to match("Manage Tours")
      passedLogs = @objRollbar.addLog("[Expected] Manage tour page opened successfully with Page Title= Manage Tours \n[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Step    ] filling all required fields and booked a tour")

      expect(@objAccAssignmentFromLead.bookTour(0,true)).to eq true

      passedLogs = @objRollbar.addLog("[Step    ] click on Create Account and Don't Merge")
      @objAccAssignmentFromLead.instance_variable_get(:@wait).until {@driver.find_element(:id ,"header43").displayed?}
      expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Don't Merge",nil)).to eq true

      passedLogs = @objRollbar.addLog("[Step    ] checking fields...")

      passedLogs = @objRollbar.addLog("[Step    ] get building details of #{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"]}")
      building = @objAccAssignmentFromLead.fetchBuildingDetails(@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"])
      expect(building).to_not eq nil

      passedLogs = @objRollbar.addLog("[Step    ] get accQueue details")
      accQueue = @objAccAssignmentFromLead.fetAccOwnerQueue(building.fetch('Market__c'),'Enterprise Solutions')

      passedLogs = @objRollbar.addLog("[Step    ] get Contact details")
      contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
      expect(contact).to_not eq nil

      passedLogs = @objRollbar.addLog("[Validate] contact:RecordType.Name")
      expect(contact.fetch('RecordType.Name')).to eq "Enterprise Solutions"
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Validate] contact:Owner.Id")

      ownerAssign = accQueue.include? contact.fetch('Owner.Id')
      expect(ownerAssign).to eq true
      #expect(contact.fetch('Owner.Id')).to eq "#{accQueue.fetch('Member__c')}"
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Validate] contact:Number_of_Full_Time_Employees__c")
      expect(contact.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Validate] contact:Looking_For_Number_Of_Desk__c")
      expect(contact.fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      puts "get Opportunity details"
      opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact.fetch('Id')}")

      passedLogs = @objRollbar.addLog("[Validate] opportunity:RecordType.Name")
      expect(opportunity.fetch('RecordType.Name')).to eq "Enterprise Solutions"
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Validate] opportunity:Deal_Type__c")
      expect(opportunity.fetch('Deal_Type__c')).to eq "Transactional"
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Validate] opportunity:Owner.Id")
      ownerAssign = accQueue.include? opportunity.fetch('Owner.Id')
      expect(ownerAssign).to eq true
      #expect(opportunity.fetch('Owner.Id')).to eq "#{accQueue.fetch('Member__c')}"
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Validate] opportunity:Quantity__c")
      expect(opportunity.fetch('Quantity__c').to_i).to eq 0
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      puts "get Account Details"
      account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact.fetch('Id')}")

      passedLogs = @objRollbar.addLog("[Validate] account:RecordType.Name")
      expect(account.fetch('RecordType.Name')).to eq "Enterprise Solutions"
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Validate] account:Owner.Name")
      ownerAssign = accQueue.include? account.fetch('Owner.Id')
      expect(ownerAssign).to eq true

      #expect(account.fetch('Owner.Id')).to eq "#{accQueue.fetch('Member__c')}"
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Validate] account:Number_of_Full_Time_Employees__c")
      expect(account.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Validate] account:Interested_in_Number_of_Desks__c")
      expect(account.fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

    rescue Exception => e
      passedLogs = @objRollbar.addLog("[Result  ]  Fail")
      raise e
    end

  end

  it "C2046 : To Check Account Assignment for Record Type Enterprise and Deal type Relational.", :'2046'=> 'true' do
    begin
      @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['building']  = 'SYD-Martin Place'
      @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['companySize']  = '1200'
      @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['numberOfDesks']  = '15'

      puts "C2046 : To Check Account Assignment for Record Type Enterprise and Deal type Relational."

      caseInfo = @testRailUtility.getCase('2046')
      #puts caseInfo
      passedLogs = @objRollbar.addLog("[Step    ] booking tour from WebSite", caseInfo['id'])
      emailId = @objAccAssignmentFromLead.createLead()
      expect(@driver.title).to match("Coworking Office Sambhav BKC | WeWork")

      passedLogs = @objRollbar.addLog("[Validate]  Lead should be created")
      leadId = @objAccAssignmentFromLead.fetchLeadDetails(emailId).fetch('Id')
      expect(leadId).to_not eq 'nil'
      passedLogs = @objRollbar.addLog("[Expected]  Lead created successfully with emailId = #{emailId} \n[Result  ]  Success ")

      passedLogs = @objRollbar.addLog("[Step    ] logging to salesforce")
      @objAccAssignmentFromLead.loginToSalesforce

      passedLogs = @objRollbar.addLog("[Step    ] go to details page of created lead and Clicking on 'Manage/book Tour' button")
      expect(@objAccAssignmentFromLead.goToDetailPage(leadId)).to eq true


      passedLogs = @objRollbar.addLog("[Validate] Checking Manage Tour page when user click on 'Manage/book tour' button")
      expect(@driver.title).to match("Manage Tours")
      passedLogs = @objRollbar.addLog("[Expected] Manage tour page opened successfully with Page Title= Manage Tours \n[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Step    ] filling all required fields and booked a tour")

      expect(@objAccAssignmentFromLead.bookTour(0,true)).to eq true

      passedLogs = @objRollbar.addLog("[Step    ] click on Create Account and Don't Merge")
      @objAccAssignmentFromLead.instance_variable_get(:@wait).until {@driver.find_element(:id ,"header43").displayed?}
      expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Don't Merge",nil)).to eq true

      passedLogs = @objRollbar.addLog("[Step    ] checking fields...")

      passedLogs = @objRollbar.addLog("[Step    ] get building details of #{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"]}")
      building = @objAccAssignmentFromLead.fetchBuildingDetails(@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"])
      expect(building).to_not eq nil


      passedLogs = @objRollbar.addLog("[Step    ] get accQueue details")
      accQueue = @objAccAssignmentFromLead.fetAccOwnerQueue(building.fetch('Market__c'),'Enterprise Solutions')

      #accQueue = @objAccAssignmentFromLead.fetAccOwnerQueue('a2V0G000003H8zoUAC','Enterprise Solutions')

      passedLogs = @objRollbar.addLog("[Step    ] get Contact details")
      contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
      #contact = @objAccAssignmentFromLead.fetchContactDetails("john.smith1004201828@example.com")
      expect(contact).to_not eq nil

      passedLogs = @objRollbar.addLog("[Validate] contact:RecordType.Name")
      expect(contact.fetch('RecordType.Name')).to eq "Enterprise Solutions"
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Validate] contact:Owner.Id")
      puts accQueue.include? contact.fetch('Owner.Id')
      ownerAssign = accQueue.include? contact.fetch('Owner.Id')
      expect(ownerAssign).to eq true
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Validate] contact:Number_of_Full_Time_Employees__c")
      expect(contact.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Validate] contact:Looking_For_Number_Of_Desk__c")
      expect(contact.fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      puts "get Opportunity details"
      opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact.fetch('Id')}")
      expect(opportunity).to_not eq nil


      passedLogs = @objRollbar.addLog("[Validate] opportunity:RecordType.Name")
      expect(opportunity.fetch('RecordType.Name')).to eq "Enterprise Solutions"
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Validate] opportunity:Deal_Type__c")
      expect(opportunity.fetch('Deal_Type__c')).to eq "Relational"
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Validate] opportunity:Owner.Id")
      ownerAssign = accQueue.include? opportunity.fetch('Owner.Id')
      expect(ownerAssign).to eq true
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Validate] opportunity:Quantity__c")
      expect(opportunity.fetch('Quantity__c').to_i).to eq 0
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      puts "get Account Details"
      account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact.fetch('Id')}")

      passedLogs = @objRollbar.addLog("[Validate] account:RecordType.Name")
      expect(account.fetch('RecordType.Name')).to eq "Enterprise Solutions"
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Validate] account:Owner.Name")
      ownerAssign = accQueue.include? account.fetch('Owner.Id')
      expect(ownerAssign).to eq true
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Validate] account:Number_of_Full_Time_Employees__c")
      expect(account.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Validate] account:Interested_in_Number_of_Desks__c")
      expect(account.fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

    rescue Exception => e
      passedLogs = @objRollbar.addLog("[Result  ]  Fail")
      raise e
    end

  end

  it "C2047 : To Check Account Assignment for Record Type Enterprise and Deal Type Strategic.", :'2046'=> 'true' do
    begin
      @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['building']  = 'SYD-Martin Place'
      @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['companySize']  = '1200'
      @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['numberOfDesks']  = '27'

      puts "C2047 : To Check Account Assignment for Record Type Enterprise and Deal type Strategic."

      caseInfo = @testRailUtility.getCase('2047')
      #puts caseInfo
      passedLogs = @objRollbar.addLog("[Step    ] booking tour from WebSite", caseInfo['id'])
      emailId = @objAccAssignmentFromLead.createLead()
      expect(@driver.title).to match("Coworking Office Sambhav BKC | WeWork")

      passedLogs = @objRollbar.addLog("[Validate]  Lead should be created")
      leadId = @objAccAssignmentFromLead.fetchLeadDetails(emailId).fetch('Id')
      expect(leadId).to_not eq 'nil'
      passedLogs = @objRollbar.addLog("[Expected]  Lead created successfully with emailId = #{emailId} \n[Result  ]  Success ")

      passedLogs = @objRollbar.addLog("[Step    ] logging to salesforce")
      @objAccAssignmentFromLead.loginToSalesforce

      passedLogs = @objRollbar.addLog("[Step    ] go to details page of created lead and Clicking on 'Manage/book Tour' button")
      expect(@objAccAssignmentFromLead.goToDetailPage(leadId)).to eq true


      passedLogs = @objRollbar.addLog("[Validate] Checking Manage Tour page when user click on 'Manage/book tour' button")
      expect(@driver.title).to match("Manage Tours")
      passedLogs = @objRollbar.addLog("[Expected] Manage tour page opened successfully with Page Title= Manage Tours \n[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Step    ] filling all required fields and booked a tour")

      expect(@objAccAssignmentFromLead.bookTour(0,true)).to eq true

      passedLogs = @objRollbar.addLog("[Step    ] click on Create Account and Don't Merge")
      @objAccAssignmentFromLead.instance_variable_get(:@wait).until {@driver.find_element(:id ,"header43").displayed?}
      expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Don't Merge",nil)).to eq true

      passedLogs = @objRollbar.addLog("[Step    ] checking fields...")

      passedLogs = @objRollbar.addLog("[Step    ] get building details of #{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"]}")
      building = @objAccAssignmentFromLead.fetchBuildingDetails(@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"])
      expect(building).to_not eq nil


      passedLogs = @objRollbar.addLog("[Step    ] get accQueue details")
      accQueue = @objAccAssignmentFromLead.fetAccOwnerQueue(building.fetch('Market__c'),'Enterprise Solutions')

      #accQueue = @objAccAssignmentFromLead.fetAccOwnerQueue('a2V0G000003H8zoUAC','Enterprise Solutions')

      passedLogs = @objRollbar.addLog("[Step    ] get Contact details")
      contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
      #contact = @objAccAssignmentFromLead.fetchContactDetails("john.smith1004201828@example.com")
      expect(contact).to_not eq nil

      passedLogs = @objRollbar.addLog("[Validate] contact:RecordType.Name")
      expect(contact.fetch('RecordType.Name')).to eq "Enterprise Solutions"
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Validate] contact:Owner.Id")
      puts accQueue.include? contact.fetch('Owner.Id')
      ownerAssign = accQueue.include? contact.fetch('Owner.Id')
      expect(ownerAssign).to eq true
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Validate] contact:Number_of_Full_Time_Employees__c")
      expect(contact.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Validate] contact:Looking_For_Number_Of_Desk__c")
      expect(contact.fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      puts "get Opportunity details"
      opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact.fetch('Id')}")
      expect(opportunity).to_not eq nil


      passedLogs = @objRollbar.addLog("[Validate] opportunity:RecordType.Name")
      expect(opportunity.fetch('RecordType.Name')).to eq "Enterprise Solutions"
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Validate] opportunity:Deal_Type__c")
      expect(opportunity.fetch('Deal_Type__c')).to eq "Strategic"
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Validate] opportunity:Owner.Id")
      ownerAssign = accQueue.include? opportunity.fetch('Owner.Id')
      expect(ownerAssign).to eq true
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Validate] opportunity:Quantity__c")
      expect(opportunity.fetch('Quantity__c').to_i).to eq 0
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      puts "get Account Details"
      account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact.fetch('Id')}")

      passedLogs = @objRollbar.addLog("[Validate] account:RecordType.Name")
      expect(account.fetch('RecordType.Name')).to eq "Enterprise Solutions"
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Validate] account:Owner.Name")
      ownerAssign = accQueue.include? account.fetch('Owner.Id')
      expect(ownerAssign).to eq true
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Validate] account:Number_of_Full_Time_Employees__c")
      expect(account.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

      passedLogs = @objRollbar.addLog("[Validate] account:Interested_in_Number_of_Desks__c")
      expect(account.fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
      passedLogs = @objRollbar.addLog("[Result  ]  Success")

    rescue Exception => e
      passedLogs = @objRollbar.addLog("[Result  ]  Fail")
      raise e
    end

  end

 end

 context "by Create Acc and Merge" do

   it "C2048 : To check account assignment for Record Type Consumer and Deal type Transactional.", :'2048'=> 'true' do
     begin
       puts "C2048 : To check account assignment for Record Type Consumer and Deal type Transactional."

       @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['companySize']  = '15'
       @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['numberOfDesks']  = '5'
       @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['building']  = 'SYD-Martin Place'

       caseInfo = @testRailUtility.getCase('2048')
       #puts caseInfo
       passedLogs = @objRollbar.addLog("[Step    ] booking tour from WebSite", caseInfo['id'])
       emailId = @objAccAssignmentFromLead.createLead()
       expect(@driver.title).to match("Coworking Office Sambhav BKC | WeWork")

       passedLogs = @objRollbar.addLog("[Validate]  Lead should be created")
       leadId = @objAccAssignmentFromLead.fetchLeadDetails(emailId).fetch('Id')
       expect(leadId).to_not eq 'nil'
       passedLogs = @objRollbar.addLog("[Expected]  Lead created successfully with emailId = #{emailId} \n[Result  ]  Success ")

=begin
            #puts "lead created from web with emailId = #{emailId}"


            Restforce.log = true
            client = Restforce.new(username: 'monika.pingale@wework.com.qaauto',
                                   password: 'monikaPingale@123',
                                   host: 'test.salesforce.com',
                                   #security_token: 'l3WwT1P1u0BaUkLw8ocH5Wzp',
                                   client_id: '3MVG9PE4xB9wtoY9IbhNtYSuAVOegE_yR6h8s4fwIITYduuN1V8Tt84iUykgOM_X3lj7md_cCbNBlsN6D6LSc',
                                   client_secret: '3006740022073476903',
                                   authentication_callback: Proc.new { |x| puts x },
                                   api_version: '41.0',
                                   request_headers: { 'sforce-auto-assign' => 'FALSE' })


            #puts client
            #accounts = client.query_all("select Id, Name from Lead") #where emailId = #{emailId}")
            #puts accounts.map(&:Id)
            #puts accounts.class


            #client.picklist_values('Account', 'Type')
            #client.user_info
            #client.describe_layouts('Account', '0010x00000FFB8c')


            client.create!('PushTopic',
                           ApiVersion: '41.0',
                           Name: 'AllLeads6',
                           Description: 'All lead records',
                           NotifyForOperationCreate: 'true',
                           NotifyForOperationUpdate: 'true',
                           #NotifyForOperations: 'All',
                           NotifyForFields: 'All',
                           Query: 'select Id,name from opportunity')



            client.create!('PushTopic',
                           ApiVersion: '41.0',
                           Name: 'PushTopic_Lead',
                           Description: 'All lead records',
                           NotifyForOperationCreate: 'true',
                           NotifyForOperationUpdate: 'true',
                           #NotifyForOperations: 'All',
                           NotifyForFields: 'All',
                           Query: 'select Id,email from Lead')


              EM.run do
                # Subscribe to the PushTopic.
                client.subscribe 'AllLeads6' do |message|
                  puts message.inspect
                  raise StopIteration , message.inspect
                end
              end
            rescue Exception => StopIteration
              puts "catching event in pushtopic"
              puts StopIteration
              puts StopIteration['event']['type']
              puts StopIteration['sobject']['email']
            end
=end


       passedLogs = @objRollbar.addLog("[Step    ] logging to salesforce")
       expect(@objAccAssignmentFromLead.loginToSalesforce).to_not eq nil

       passedLogs = @objRollbar.addLog("[Step    ] go to details page of created lead and Clicking on 'Manage/book Tour' button")
       expect(@objAccAssignmentFromLead.goToDetailPage(leadId)).to eq true


       passedLogs = @objRollbar.addLog("[Validate] Checking Manage Tour page when user click on 'Manage/book tour' button")
       expect(@driver.title).to match("Manage Tours")
       passedLogs = @objRollbar.addLog("[Expected] Manage tour page opened successfully with Page Title= Manage Tours \n[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Step    ] filling all required fields and booked a tour")

       expect(@objAccAssignmentFromLead.bookTour(0,true)).to eq true

       passedLogs = @objRollbar.addLog("[Step    ] click on Create Account and Don't Merge")
       expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Merge",nil)).to eq true

       passedLogs = @objRollbar.addLog("[Step    ] checking fields...")

       passedLogs = @objRollbar.addLog("[Step    ] get building details of #{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"]}")
       building = @objAccAssignmentFromLead.fetchBuildingDetails(@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"])
       expect(building).to_not eq nil

       passedLogs = @objRollbar.addLog("[Step    ] get Contact details")
       contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
       expect(contact).to_not eq nil

       passedLogs = @objRollbar.addLog("[Validate] contact:RecordType.Name")
       expect(contact.fetch('RecordType.Name')).to eq "Consumer"
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] contact:Owner.Id")
       expect(contact.fetch('Owner.Id')).to eq "#{building.fetch('Community_Lead__c')}"
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] contact:Number_of_Full_Time_Employees__c")
       expect(contact.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] contact:Looking_For_Number_Of_Desk__c")
       expect(contact.fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       puts "get Opportunity details"
       opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact.fetch('Id')}")
       puts opportunity

       passedLogs = @objRollbar.addLog("[Validate] opportunity:RecordType.Name")
       expect(opportunity.fetch('RecordType.Name')).to eq "Consumer"
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] opportunity:Deal_Type__c")
       expect(opportunity.fetch('Deal_Type__c')).to eq "Transactional"
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] opportunity:Owner.Id")
       expect(opportunity.fetch('Owner.Id')).to eq "#{building.fetch('Community_Lead__c')}"
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] opportunity:Quantity__c")
       expect(opportunity.fetch('Quantity__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       puts "get Account Details"
       account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact.fetch('Id')}")

       passedLogs = @objRollbar.addLog("[Validate] account:RecordType.Name")
       expect(account.fetch('RecordType.Name')).to eq "Consumer"
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] account:Owner.Id")
       expect(account.fetch('Owner.Id')).to eq "#{building.fetch('Community_Lead__c')}"
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] account:Number_of_Full_Time_Employees__c")
       expect(account.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] account:Interested_in_Number_of_Desks__c")
       expect(account.fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] account:Allow_Merge__c")
       expect(account.fetch('Allow_Merge__c')).to eq "true"
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

     rescue Exception => e
       passedLogs = @objRollbar.addLog("[Result  ]  Fail")
       raise e
     end

   end


   it "C2049 : To check account assignment for Record Type Consumer and Deal type Relational.", :'2049'=> 'true' do
     begin
       puts "C2049 : To check account assignment for Record Type Consumer and Deal type Relational."

       @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['companySize']  = '15'
       @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['numberOfDesks']  = '13'

       caseInfo = @testRailUtility.getCase('2049')
       passedLogs = @objRollbar.addLog("[Step    ] booking tour from WebSite", caseInfo['id'])
       emailId = @objAccAssignmentFromLead.createLead()
       expect(@driver.title).to match("Coworking Office Sambhav BKC | WeWork")

       passedLogs = @objRollbar.addLog("[Validate]  Lead should be created")
       leadId = @objAccAssignmentFromLead.fetchLeadDetails(emailId).fetch('Id')
       expect(leadId).to_not eq 'nil'
       passedLogs = @objRollbar.addLog("[Expected]  Lead created successfully with emailId = #{emailId} \n[Result  ]  Success ")

       passedLogs = @objRollbar.addLog("[Step    ] logging to salesforce")
       @objAccAssignmentFromLead.loginToSalesforce

       passedLogs = @objRollbar.addLog("[Step    ] go to details page of created lead and Clicking on 'Manage/book Tour' button")
       expect(@objAccAssignmentFromLead.goToDetailPage(leadId)).to eq true


       passedLogs = @objRollbar.addLog("[Validate] Checking Manage Tour page when user click on 'Manage/book tour' button")
       expect(@driver.title).to match("Manage Tours")
       passedLogs = @objRollbar.addLog("[Expected] Manage tour page opened successfully with Page Title= Manage Tours \n[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Step    ] filling all required fields and booked a tour")

       expect(@objAccAssignmentFromLead.bookTour(0,true)).to eq true

       passedLogs = @objRollbar.addLog("[Step    ] click on Create Account and Don't Merge")
       @objAccAssignmentFromLead.instance_variable_get(:@wait).until {@driver.find_element(:id ,"header43").displayed?}
       expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Merge",nil)).to eq true

       passedLogs = @objRollbar.addLog("[Step    ] checking fields...")

       passedLogs = @objRollbar.addLog("[Step    ] get building details of #{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"]}")
       building = @objAccAssignmentFromLead.fetchBuildingDetails(@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"])
       expect(building).to_not eq nil

       passedLogs = @objRollbar.addLog("[Step    ] get Contact details")
       contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
       expect(contact).to_not eq nil

       passedLogs = @objRollbar.addLog("[Validate] contact:RecordType.Name")
       expect(contact.fetch('RecordType.Name')).to eq "Consumer"
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] contact:Owner.Id")
       expect(contact.fetch('Owner.Name')).to eq "#{building.fetch('Cluster_Sales_Lead_Name__c')}"
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] contact:Number_of_Full_Time_Employees__c")
       expect(contact.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] contact:Looking_For_Number_Of_Desk__c")
       expect(contact.fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       puts "get Opportunity details"
       opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact.fetch('Id')}")

       passedLogs = @objRollbar.addLog("[Validate] opportunity:RecordType.Name")
       expect(opportunity.fetch('RecordType.Name')).to eq "Consumer"
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] opportunity:Deal_Type__c")
       expect(opportunity.fetch('Deal_Type__c')).to eq "Relational"
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] opportunity:Owner.Id")
       expect(opportunity.fetch('Owner.Name')).to eq "#{building.fetch('Cluster_Sales_Lead_Name__c')}"
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] opportunity:Quantity__c")
       expect(opportunity.fetch('Quantity__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       puts "get Account Details"
       account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact.fetch('Id')}")

       passedLogs = @objRollbar.addLog("[Validate] account:RecordType.Name")
       expect(account.fetch('RecordType.Name')).to eq "Consumer"
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] account:Owner.Name")
       expect(account.fetch('Owner.Name')).to eq "#{building.fetch('Cluster_Sales_Lead_Name__c')}"
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] account:Number_of_Full_Time_Employees__c")
       expect(account.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] account:Interested_in_Number_of_Desks__c")
       expect(account.fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] account:Allow_Merge__c")
       expect(account.fetch('Allow_Merge__c')).to eq "true"
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

     rescue Exception => e
       passedLogs = @objRollbar.addLog("[Result  ]  Fail")
       raise e
     end

   end


   it "C2050 : To check account assignment for Record Type Consumer and Deal type Strategic.", :'2050'=> 'true' do
     begin
       puts "C2050 : To check account assignment for Record Type Consumer and Deal type Strategic."

       @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['companySize']  = '15'
       @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['numberOfDesks']  = '25'

       caseInfo = @testRailUtility.getCase('2050')
       passedLogs = @objRollbar.addLog("[Step    ] booking tour from WebSite", caseInfo['id'])
       emailId = @objAccAssignmentFromLead.createLead()
       expect(@driver.title).to match("Coworking Office Sambhav BKC | WeWork")

       passedLogs = @objRollbar.addLog("[Validate]  Lead should be created")
       leadId = @objAccAssignmentFromLead.fetchLeadDetails(emailId).fetch('Id')
       expect(leadId).to_not eq 'nil'
       passedLogs = @objRollbar.addLog("[Expected]  Lead created successfully with emailId = #{emailId} \n[Result  ]  Success ")

       passedLogs = @objRollbar.addLog("[Step    ] logging to salesforce")
       @objAccAssignmentFromLead.loginToSalesforce

       passedLogs = @objRollbar.addLog("[Step    ] go to details page of created lead and Clicking on 'Manage/book Tour' button")
       expect(@objAccAssignmentFromLead.goToDetailPage(leadId)).to eq true


       passedLogs = @objRollbar.addLog("[Validate] Checking Manage Tour page when user click on 'Manage/book tour' button")
       expect(@driver.title).to match("Manage Tours")
       passedLogs = @objRollbar.addLog("[Expected] Manage tour page opened successfully with Page Title= Manage Tours \n[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Step    ] filling all required fields and booked a tour")

       expect(@objAccAssignmentFromLead.bookTour(0,true)).to eq true

       passedLogs = @objRollbar.addLog("[Step    ] click on Create Account and Don't Merge")
       @objAccAssignmentFromLead.instance_variable_get(:@wait).until {@driver.find_element(:id ,"header43").displayed?}
       expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Merge",nil)).to eq true

       passedLogs = @objRollbar.addLog("[Step    ] checking fields...")

       passedLogs = @objRollbar.addLog("[Step    ] get building details of #{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"]}")
       building = @objAccAssignmentFromLead.fetchBuildingDetails(@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"])
       expect(building).to_not eq nil

       passedLogs = @objRollbar.addLog("[Step    ] get accQueue details")
       accQueue = @objAccAssignmentFromLead.fetAccOwnerQueue(building.fetch('Market__c'),'Consumer')

       passedLogs = @objRollbar.addLog("[Step    ] get Contact details")
       contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
       expect(contact).to_not eq nil

       passedLogs = @objRollbar.addLog("[Validate] contact:RecordType.Name")
       expect(contact.fetch('RecordType.Name')).to eq "Consumer"
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] contact:Owner.Id")
       ownerAssign = accQueue.include? contact.fetch('Owner.Id')
       expect(ownerAssign).to eq true
       #expect(contact.fetch('Owner.Id')).to eq "#{accQueue.fetch('Member__c')}"
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] contact:Number_of_Full_Time_Employees__c")
       expect(contact.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] contact:Looking_For_Number_Of_Desk__c")
       expect(contact.fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       puts "get Opportunity details"
       opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact.fetch('Id')}")
       puts opportunity

       passedLogs = @objRollbar.addLog("[Validate] opportunity:RecordType.Name")
       expect(opportunity.fetch('RecordType.Name')).to eq "Consumer"
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] opportunity:Deal_Type__c")
       expect(opportunity.fetch('Deal_Type__c')).to eq "Strategic"
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] opportunity:Owner.Id")
       ownerAssign = accQueue.include? opportunity.fetch('Owner.Id')
       expect(ownerAssign).to eq true
       #expect(opportunity.fetch('Owner.Id')).to eq "#{accQueue.fetch('Member__c')}"
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] opportunity:Quantity__c")
       expect(opportunity.fetch('Quantity__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       puts "get Account Details"
       account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact.fetch('Id')}")
       puts account

       passedLogs = @objRollbar.addLog("[Validate] account:RecordType.Name")
       expect(account.fetch('RecordType.Name')).to eq "Consumer"
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] account:Owner.Name")
       ownerAssign = accQueue.include? account.fetch('Owner.Id')
       expect(ownerAssign).to eq true

       #expect(account.fetch('Owner.Id')).to eq "#{accQueue.fetch('Member__c')}"
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] account:Number_of_Full_Time_Employees__c")
       expect(account.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] account:Interested_in_Number_of_Desks__c")
       expect(account.fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] account:Allow_Merge__c")
       expect(account.fetch('Allow_Merge__c')).to eq "true"
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

     rescue Exception => e
       passedLogs = @objRollbar.addLog("[Result  ]  Fail")
       raise e
     end

   end


   it "C2051 : To check account assignment for Record Type Consumer and Deal type Relational.", :'2051'=> 'true'  do
     begin
       puts "C2051 : To check account assignment for Record Type Consumer and Deal type Strategic.(Queue is not present in the Account Queue Setting)."

       caseInfo = @testRailUtility.getCase('2051')
       @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['building']  = 'SYD-Martin Place'

       #puts caseInfo
       passedLogs = @objRollbar.addLog("[Step    ] booking tour from WebSite", caseInfo['id'])
       emailId = @objAccAssignmentFromLead.createLead()
       #expect(@driver.title).to match("Coworking Office Sambhav BKC | WeWork")

       sleep (10)
       passedLogs = @objRollbar.addLog("[Validate]  Lead should be created")
       leadId = @objAccAssignmentFromLead.fetchLeadDetails(emailId).fetch('Id')
       expect(leadId).to_not eq 'nil'

       passedLogs = @objRollbar.addLog("[Expected]  Lead created successfully with emailId = #{emailId} \n[Result  ]  Success ")

       passedLogs = @objRollbar.addLog("[Step    ] logging to salesforce")
       @objAccAssignmentFromLead.loginToSalesforce

       passedLogs = @objRollbar.addLog("[Step    ] go to details page of created lead and Clicking on 'Manage/book Tour' button")
       expect(@objAccAssignmentFromLead.goToDetailPage(leadId)).to eq true


       passedLogs = @objRollbar.addLog("[Validate] Checking Manage Tour page when user click on 'Manage/book tour' button")
       expect(@driver.title).to match("Manage Tours")
       passedLogs = @objRollbar.addLog("[Expected] Manage tour page opened successfully with Page Title= Manage Tours \n[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Step    ] filling all required fields and booked a tour")
       @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['companySize']  = '15'
       @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['numberOfDesks']  = '25'

       expect(@objAccAssignmentFromLead.bookTour(0,true)).to eq true

       passedLogs = @objRollbar.addLog("[Step    ] click on Create Account and Don't Merge")
       @objAccAssignmentFromLead.instance_variable_get(:@wait).until {@driver.find_element(:id ,"header43").displayed?}
       expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Merge",nil)).to eq true

       passedLogs = @objRollbar.addLog("[Step    ] checking fields...")

       passedLogs = @objRollbar.addLog("[Step    ] get building details of #{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"]}")
       building = @objAccAssignmentFromLead.fetchBuildingDetails(@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"])
       expect(building).to_not eq nil

       #passedLogs = @objRollbar.addLog("[Step    ] get accQueue details")
       #accQueue = @objAccAssignmentFromLead.fetAccOwnerQueue(building.fetch('Market__c'),'Consumer')

       passedLogs = @objRollbar.addLog("[Step    ] get Contact details")
       contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
       expect(contact).to_not eq nil

       passedLogs = @objRollbar.addLog("[Validate] contact:RecordType.Name")
       expect(contact.fetch('RecordType.Name')).to eq "Consumer"
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] contact:Owner.Id")
       expect(contact.fetch('Owner.Id')).to eq "005F0000003KmbwIAC"
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] contact:Number_of_Full_Time_Employees__c")
       expect(contact.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] contact:Looking_For_Number_Of_Desk__c")
       expect(contact.fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       puts "get Opportunity details"
       opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact.fetch('Id')}")

       passedLogs = @objRollbar.addLog("[Validate] opportunity:RecordType.Name")
       expect(opportunity.fetch('RecordType.Name')).to eq "Consumer"
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] opportunity:Deal_Type__c")
       expect(opportunity.fetch('Deal_Type__c')).to eq "Strategic"
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] opportunity:Owner.Id")
       expect(opportunity.fetch('Owner.Id')).to eq "005F0000003KmbwIAC"
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] opportunity:Quantity__c")
       expect(opportunity.fetch('Quantity__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       puts "get Account Details"
       account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact.fetch('Id')}")

       passedLogs = @objRollbar.addLog("[Validate] account:RecordType.Name")
       expect(account.fetch('RecordType.Name')).to eq "Consumer"
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] account:Owner.Name")
       expect(account.fetch('Owner.Id')).to eq "005F0000003KmbwIAC"
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] account:Number_of_Full_Time_Employees__c")
       expect(account.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] account:Interested_in_Number_of_Desks__c")
       expect(account.fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] account:Allow_Merge__c")
       expect(account.fetch('Allow_Merge__c')).to eq "true"
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

     rescue Exception => e
       passedLogs = @objRollbar.addLog("[Result  ]  Fail")
       raise e
     end

   end

   it "C2052 : To Check Account assignment for Record Type Mid-Market and Deal type Transactional.", :'2052'=> 'true' do
     begin
       puts "C2052 : To Check Account assignment for Record Type Mid-Market and Deal type Transactional."
       @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['building']  = 'SYD-Martin Place'
       @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['companySize']  = '24'
       @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['numberOfDesks']  = '7'


       caseInfo = @testRailUtility.getCase('2052')
       #puts caseInfo
       passedLogs = @objRollbar.addLog("[Step    ] booking tour from WebSite", caseInfo['id'])
       emailId = @objAccAssignmentFromLead.createLead()
       #expect(@driver.title).to match("Coworking Office Sambhav BKC | WeWork")

       passedLogs = @objRollbar.addLog("[Validate]  Lead should be created")
       leadId = @objAccAssignmentFromLead.fetchLeadDetails(emailId).fetch('Id')
       expect(leadId).to_not eq 'nil'
       passedLogs = @objRollbar.addLog("[Expected]  Lead created successfully with emailId = #{emailId} \n[Result  ]  Success ")

       passedLogs = @objRollbar.addLog("[Step    ] logging to salesforce")
       @objAccAssignmentFromLead.loginToSalesforce

       passedLogs = @objRollbar.addLog("[Step    ] go to details page of created lead and Clicking on 'Manage/book Tour' button")
       expect(@objAccAssignmentFromLead.goToDetailPage(leadId)).to eq true

       passedLogs = @objRollbar.addLog("[Validate] Checking Manage Tour page when user click on 'Manage/book tour' button")
       expect(@driver.title).to match("Manage Tours")
       passedLogs = @objRollbar.addLog("[Expected] Manage tour page opened successfully with Page Title= Manage Tours \n[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Step    ] filling all required fields and booked a tour")

       expect(@objAccAssignmentFromLead.bookTour(0,true)).to eq true

       passedLogs = @objRollbar.addLog("[Step    ] click on Create Account and Don't Merge")
       @objAccAssignmentFromLead.instance_variable_get(:@wait).until {@driver.find_element(:id ,"header43").displayed?}
       expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Merge",nil)).to eq true

       passedLogs = @objRollbar.addLog("[Step    ] checking fields...")

       passedLogs = @objRollbar.addLog("[Step    ] get building details of #{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"]}")
       building = @objAccAssignmentFromLead.fetchBuildingDetails(@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"])
       expect(building).to_not eq nil

       passedLogs = @objRollbar.addLog("[Step    ] get Contact details")
       contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
       expect(contact).to_not eq nil

       passedLogs = @objRollbar.addLog("[Validate] contact:RecordType.Name")
       expect(contact.fetch('RecordType.Name')).to eq "Mid Market"
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] contact:Owner.Id")
       expect(contact.fetch('Owner.Id')).to eq "#{building.fetch('Community_Lead__c')}"
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] contact:Number_of_Full_Time_Employees__c")
       expect(contact.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] contact:Looking_For_Number_Of_Desk__c")
       expect(contact.fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       puts "get Opportunity details"
       opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact.fetch('Id')}")

       passedLogs = @objRollbar.addLog("[Validate] opportunity:RecordType.Name")
       expect(opportunity.fetch('RecordType.Name')).to eq "Mid Market"
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] opportunity:Deal_Type__c")
       expect(opportunity.fetch('Deal_Type__c')).to eq "Transactional"
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] opportunity:Owner.Id")
       expect(opportunity.fetch('Owner.Id')).to eq "#{building.fetch('Community_Lead__c')}"
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] opportunity:Quantity__c")
       expect(opportunity.fetch('Quantity__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       puts "get Account Details"
       account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact.fetch('Id')}")

       passedLogs = @objRollbar.addLog("[Validate] account:RecordType.Name")
       expect(account.fetch('RecordType.Name')).to eq "Mid Market"
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] account:Owner.Id")
       expect(account.fetch('Owner.Id')).to eq "#{building.fetch('Community_Lead__c')}"
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] account:Number_of_Full_Time_Employees__c")
       expect(account.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] account:Interested_in_Number_of_Desks__c")
       expect(account.fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] account:Allow_Merge__c")
       expect(account.fetch('Allow_Merge__c')).to eq "true"
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

     rescue Exception => e
       passedLogs = @objRollbar.addLog("[Result  ]  Fail")
       raise e
     end

   end

   it "C2053 : To Check Account Assignment for Record type Mid-Market and Deal type Relational.", :'2053'=> 'true' do
     begin
       puts "C2053 : To Check Account Assignment for Record type Mid-Market and Deal type Relational."

       caseInfo = @testRailUtility.getCase('2053')
       #puts caseInfo
       @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['building']  = 'SYD-Martin Place'
       @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['companySize']  = '24'
       @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['numberOfDesks']  = '15'

       passedLogs = @objRollbar.addLog("[Step    ] booking tour from WebSite", caseInfo['id'])
       emailId = @objAccAssignmentFromLead.createLead()
       expect(@driver.title).to match("Coworking Office Sambhav BKC | WeWork")

       passedLogs = @objRollbar.addLog("[Validate]  Lead should be created")
       leadId = @objAccAssignmentFromLead.fetchLeadDetails(emailId).fetch('Id')
       expect(leadId).to_not eq 'nil'
       passedLogs = @objRollbar.addLog("[Expected]  Lead created successfully with emailId = #{emailId} \n[Result  ]  Success ")

       passedLogs = @objRollbar.addLog("[Step    ] logging to salesforce")
       @objAccAssignmentFromLead.loginToSalesforce

       passedLogs = @objRollbar.addLog("[Step    ] go to details page of created lead and Clicking on 'Manage/book Tour' button")
       expect(@objAccAssignmentFromLead.goToDetailPage(leadId)).to eq true


       passedLogs = @objRollbar.addLog("[Validate] Checking Manage Tour page when user click on 'Manage/book tour' button")
       expect(@driver.title).to match("Manage Tours")
       passedLogs = @objRollbar.addLog("[Expected] Manage tour page opened successfully with Page Title= Manage Tours \n[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Step    ] filling all required fields and booked a tour")
       expect(@objAccAssignmentFromLead.bookTour(0,true)).to eq true

       passedLogs = @objRollbar.addLog("[Step    ] click on Create Account and Don't Merge")
       @objAccAssignmentFromLead.instance_variable_get(:@wait).until {@driver.find_element(:id ,"header43").displayed?}
       expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Merge",nil)).to eq true

       passedLogs = @objRollbar.addLog("[Step    ] checking fields...")

       passedLogs = @objRollbar.addLog("[Step    ] get building details of #{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"]}")
       building = @objAccAssignmentFromLead.fetchBuildingDetails(@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"])
       expect(building).to_not eq nil

       passedLogs = @objRollbar.addLog("[Step    ] get Contact details")
       contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
       expect(contact).to_not eq nil

       passedLogs = @objRollbar.addLog("[Validate] contact:RecordType.Name")
       expect(contact.fetch('RecordType.Name')).to eq "Mid Market"
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] contact:Owner.Id")
       expect(contact.fetch('Owner.Name')).to eq "#{building.fetch('Cluster_Sales_Lead_Name__c')}"
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] contact:Number_of_Full_Time_Employees__c")
       expect(contact.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] contact:Looking_For_Number_Of_Desk__c")
       expect(contact.fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       puts "get Opportunity details"
       opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact.fetch('Id')}")

       passedLogs = @objRollbar.addLog("[Validate] opportunity:RecordType.Name")
       expect(opportunity.fetch('RecordType.Name')).to eq "Mid Market"
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] opportunity:Deal_Type__c")
       expect(opportunity.fetch('Deal_Type__c')).to eq "Relational"
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] opportunity:Owner.Id")
       expect(opportunity.fetch('Owner.Name')).to eq "#{building.fetch('Cluster_Sales_Lead_Name__c')}"
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] opportunity:Quantity__c")
       expect(opportunity.fetch('Quantity__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       puts "get Account Details"
       account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact.fetch('Id')}")

       passedLogs = @objRollbar.addLog("[Validate] account:RecordType.Name")
       expect(account.fetch('RecordType.Name')).to eq "Mid Market"
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] account:Owner.Name")
       expect(account.fetch('Owner.Name')).to eq "#{building.fetch('Cluster_Sales_Lead_Name__c')}"
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] account:Number_of_Full_Time_Employees__c")
       expect(account.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] account:Interested_in_Number_of_Desks__c")
       expect(account.fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] account:Allow_Merge__c")
       expect(account.fetch('Allow_Merge__c')).to eq "true"
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

     rescue Exception => e
       passedLogs = @objRollbar.addLog("[Result  ]  Fail")
       raise e
     end

   end

   it "C2054 : To Check Account Assignment from Record type Mid-Market and Deal Type Strategic.", :'2054'=> 'true' do
     begin
       puts "C2054 : To check account assignment for Record Type Consumer and Deal type Relational."

       @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['building']  = 'SYD-Martin Place'
       @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['companySize']  = '24'
       @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['numberOfDesks']  = '27'

       caseInfo = @testRailUtility.getCase('2054')
       #puts caseInfo
       passedLogs = @objRollbar.addLog("[Step    ] booking tour from WebSite", caseInfo['id'])
       emailId = @objAccAssignmentFromLead.createLead()
       expect(@driver.title).to match("Coworking Office Sambhav BKC | WeWork")

       passedLogs = @objRollbar.addLog("[Validate]  Lead should be created")
       leadId = @objAccAssignmentFromLead.fetchLeadDetails(emailId).fetch('Id')
       expect(leadId).to_not eq 'nil'
       passedLogs = @objRollbar.addLog("[Expected]  Lead created successfully with emailId = #{emailId} \n[Result  ]  Success ")

       passedLogs = @objRollbar.addLog("[Step    ] logging to salesforce")
       @objAccAssignmentFromLead.loginToSalesforce

       passedLogs = @objRollbar.addLog("[Step    ] go to details page of created lead and Clicking on 'Manage/book Tour' button")
       expect(@objAccAssignmentFromLead.goToDetailPage(leadId)).to eq true


       passedLogs = @objRollbar.addLog("[Validate] Checking Manage Tour page when user click on 'Manage/book tour' button")
       expect(@driver.title).to match("Manage Tours")
       passedLogs = @objRollbar.addLog("[Expected] Manage tour page opened successfully with Page Title= Manage Tours \n[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Step    ] filling all required fields and booked a tour")

       expect(@objAccAssignmentFromLead.bookTour(0,true)).to eq true

       passedLogs = @objRollbar.addLog("[Step    ] click on Create Account and Merge")
       @objAccAssignmentFromLead.instance_variable_get(:@wait).until {@driver.find_element(:id ,"header43").displayed?}
       expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Merge",nil)).to eq true

       passedLogs = @objRollbar.addLog("[Step    ] checking fields...")

       passedLogs = @objRollbar.addLog("[Step    ] get building details of #{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"]}")
       building = @objAccAssignmentFromLead.fetchBuildingDetails(@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"])
       expect(building).to_not eq nil

       passedLogs = @objRollbar.addLog("[Step    ] get accQueue details")

       accQueue = @objAccAssignmentFromLead.fetAccOwnerQueue(building.fetch('Market__c'),'Mid Market')

       passedLogs = @objRollbar.addLog("[Step    ] get Contact details")
       contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
       expect(contact).to_not eq nil

       passedLogs = @objRollbar.addLog("[Validate] contact:RecordType.Name")
       expect(contact.fetch('RecordType.Name')).to eq "Mid Market"
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] contact:Owner.Id")

       puts accQueue.include? contact.fetch('Owner.Id')
       ownerAssign = accQueue.include? contact.fetch('Owner.Id')
       expect(ownerAssign).to eq true

       #expect(contact.fetch('Owner.Id')).to eq "#{accQueue.fetch('Member__c')}"
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] contact:Number_of_Full_Time_Employees__c")
       expect(contact.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] contact:Looking_For_Number_Of_Desk__c")
       expect(contact.fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       puts "get Opportunity details"
       opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact.fetch('Id')}")
       puts opportunity

       passedLogs = @objRollbar.addLog("[Validate] opportunity:RecordType.Name")
       expect(opportunity.fetch('RecordType.Name')).to eq "Mid Market"
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] opportunity:Deal_Type__c")
       expect(opportunity.fetch('Deal_Type__c')).to eq "Strategic"
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] opportunity:Owner.Id")
       ownerAssign = accQueue.include? opportunity.fetch('Owner.Id')
       expect(ownerAssign).to eq true

       #expect(opportunity.fetch('Owner.Id')).to eq "#{accQueue.fetch('Member__c')}"
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] opportunity:Quantity__c")
       expect(opportunity.fetch('Quantity__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       puts "get Account Details"
       account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact.fetch('Id')}")
       puts account

       passedLogs = @objRollbar.addLog("[Validate] account:RecordType.Name")
       expect(account.fetch('RecordType.Name')).to eq "Mid Market"
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] account:Owner.Name")
       ownerAssign = accQueue.include? account.fetch('Owner.Id')
       expect(ownerAssign).to eq true
       #expect(account.fetch('Owner.Id')).to eq "#{accQueue.fetch('Member__c')}"
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] account:Number_of_Full_Time_Employees__c")
       expect(account.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] account:Interested_in_Number_of_Desks__c")
       expect(account.fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] account:Allow_Merge__c")
       expect(account.fetch('Allow_Merge__c')).to eq "true"
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

     rescue Exception => e
       passedLogs = @objRollbar.addLog("[Result  ]  Fail")
       raise e
     end

   end

   it "C2055 : To Check Account Assignment for Record Type Enterprise and Deal type Transactional.", :'2055'=> 'true' do
     begin
       puts "C2055 : To Check Account Assignment for Record Type Enterprise and Deal type Transactional."

       @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['building']  = 'MEL-Bourke Street'
       @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['companySize']  = '1200'
       @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['numberOfDesks']  = '7'

       caseInfo = @testRailUtility.getCase('2055')
       #puts caseInfo
       passedLogs = @objRollbar.addLog("[Step    ] booking tour from WebSite", caseInfo['id'])
       emailId = @objAccAssignmentFromLead.createLead()
       expect(@driver.title).to match("Coworking Office Sambhav BKC | WeWork")

       passedLogs = @objRollbar.addLog("[Validate]  Lead should be created")
       leadId = @objAccAssignmentFromLead.fetchLeadDetails(emailId).fetch('Id')
       expect(leadId).to_not eq 'nil'
       passedLogs = @objRollbar.addLog("[Expected]  Lead created successfully with emailId = #{emailId} \n[Result  ]  Success ")

       passedLogs = @objRollbar.addLog("[Step    ] logging to salesforce")
       @objAccAssignmentFromLead.loginToSalesforce

       passedLogs = @objRollbar.addLog("[Step    ] go to details page of created lead and Clicking on 'Manage/book Tour' button")
       expect(@objAccAssignmentFromLead.goToDetailPage(leadId)).to eq true


       passedLogs = @objRollbar.addLog("[Validate] Checking Manage Tour page when user click on 'Manage/book tour' button")
       expect(@driver.title).to match("Manage Tours")
       passedLogs = @objRollbar.addLog("[Expected] Manage tour page opened successfully with Page Title= Manage Tours \n[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Step    ] filling all required fields and booked a tour")

       expect(@objAccAssignmentFromLead.bookTour(0,true)).to eq true

       passedLogs = @objRollbar.addLog("[Step    ] click on Create Account and Don't Merge")
       @objAccAssignmentFromLead.instance_variable_get(:@wait).until {@driver.find_element(:id ,"header43").displayed?}
       expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Merge",nil)).to eq true

       passedLogs = @objRollbar.addLog("[Step    ] checking fields...")

       passedLogs = @objRollbar.addLog("[Step    ] get building details of #{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"]}")
       building = @objAccAssignmentFromLead.fetchBuildingDetails(@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"])
       expect(building).to_not eq nil

       passedLogs = @objRollbar.addLog("[Step    ] get accQueue details")
       accQueue = @objAccAssignmentFromLead.fetAccOwnerQueue(building.fetch('Market__c'),'Enterprise Solutions')

       passedLogs = @objRollbar.addLog("[Step    ] get Contact details")
       contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
       expect(contact).to_not eq nil

       passedLogs = @objRollbar.addLog("[Validate] contact:RecordType.Name")
       expect(contact.fetch('RecordType.Name')).to eq "Enterprise Solutions"
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] contact:Owner.Id")

       ownerAssign = accQueue.include? contact.fetch('Owner.Id')
       expect(ownerAssign).to eq true
       #expect(contact.fetch('Owner.Id')).to eq "#{accQueue.fetch('Member__c')}"
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] contact:Number_of_Full_Time_Employees__c")
       expect(contact.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] contact:Looking_For_Number_Of_Desk__c")
       expect(contact.fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       puts "get Opportunity details"
       opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact.fetch('Id')}")

       passedLogs = @objRollbar.addLog("[Validate] opportunity:RecordType.Name")
       expect(opportunity.fetch('RecordType.Name')).to eq "Enterprise Solutions"
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] opportunity:Deal_Type__c")
       expect(opportunity.fetch('Deal_Type__c')).to eq "Transactional"
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] opportunity:Owner.Id")
       ownerAssign = accQueue.include? opportunity.fetch('Owner.Id')
       expect(ownerAssign).to eq true
       #expect(opportunity.fetch('Owner.Id')).to eq "#{accQueue.fetch('Member__c')}"
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] opportunity:Quantity__c")
       expect(opportunity.fetch('Quantity__c').to_i).to eq 0
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       puts "get Account Details"
       account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact.fetch('Id')}")

       passedLogs = @objRollbar.addLog("[Validate] account:RecordType.Name")
       expect(account.fetch('RecordType.Name')).to eq "Enterprise Solutions"
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] account:Owner.Name")
       ownerAssign = accQueue.include? account.fetch('Owner.Id')
       expect(ownerAssign).to eq true

       #expect(account.fetch('Owner.Id')).to eq "#{accQueue.fetch('Member__c')}"
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] account:Number_of_Full_Time_Employees__c")
       expect(account.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] account:Interested_in_Number_of_Desks__c")
       expect(account.fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] account:Allow_Merge__c")
       expect(account.fetch('Allow_Merge__c')).to eq "true"
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

     rescue Exception => e
       passedLogs = @objRollbar.addLog("[Result  ]  Fail")
       raise e
     end

   end

   it "C2056 : To Check Account Assignment for Record Type Enterprise and Deal type Relational.", :'2056'=> 'true' do
     begin
       @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['building']  = 'SYD-Martin Place'
       @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['companySize']  = '1200'
       @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['numberOfDesks']  = '15'

       puts "C2056 : To Check Account Assignment for Record Type Enterprise and Deal type Relational."

       caseInfo = @testRailUtility.getCase('2056')
       #puts caseInfo
       passedLogs = @objRollbar.addLog("[Step    ] booking tour from WebSite", caseInfo['id'])
       emailId = @objAccAssignmentFromLead.createLead()
       expect(@driver.title).to match("Coworking Office Sambhav BKC | WeWork")

       passedLogs = @objRollbar.addLog("[Validate]  Lead should be created")
       leadId = @objAccAssignmentFromLead.fetchLeadDetails(emailId).fetch('Id')
       expect(leadId).to_not eq 'nil'
       passedLogs = @objRollbar.addLog("[Expected]  Lead created successfully with emailId = #{emailId} \n[Result  ]  Success ")

       passedLogs = @objRollbar.addLog("[Step    ] logging to salesforce")
       @objAccAssignmentFromLead.loginToSalesforce

       passedLogs = @objRollbar.addLog("[Step    ] go to details page of created lead and Clicking on 'Manage/book Tour' button")
       expect(@objAccAssignmentFromLead.goToDetailPage(leadId)).to eq true


       passedLogs = @objRollbar.addLog("[Validate] Checking Manage Tour page when user click on 'Manage/book tour' button")
       expect(@driver.title).to match("Manage Tours")
       passedLogs = @objRollbar.addLog("[Expected] Manage tour page opened successfully with Page Title= Manage Tours \n[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Step    ] filling all required fields and booked a tour")

       expect(@objAccAssignmentFromLead.bookTour(0,true)).to eq true

       passedLogs = @objRollbar.addLog("[Step    ] click on Create Account and Don't Merge")
       @objAccAssignmentFromLead.instance_variable_get(:@wait).until {@driver.find_element(:id ,"header43").displayed?}
       expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Merge",nil)).to eq true

       passedLogs = @objRollbar.addLog("[Step    ] checking fields...")

       passedLogs = @objRollbar.addLog("[Step    ] get building details of #{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"]}")
       building = @objAccAssignmentFromLead.fetchBuildingDetails(@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"])
       expect(building).to_not eq nil


       passedLogs = @objRollbar.addLog("[Step    ] get accQueue details")
       accQueue = @objAccAssignmentFromLead.fetAccOwnerQueue(building.fetch('Market__c'),'Enterprise Solutions')

       #accQueue = @objAccAssignmentFromLead.fetAccOwnerQueue('a2V0G000003H8zoUAC','Enterprise Solutions')

       passedLogs = @objRollbar.addLog("[Step    ] get Contact details")
       contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
       #contact = @objAccAssignmentFromLead.fetchContactDetails("john.smith1004201828@example.com")
       expect(contact).to_not eq nil

       passedLogs = @objRollbar.addLog("[Validate] contact:RecordType.Name")
       expect(contact.fetch('RecordType.Name')).to eq "Enterprise Solutions"
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] contact:Owner.Id")
       puts accQueue.include? contact.fetch('Owner.Id')
       ownerAssign = accQueue.include? contact.fetch('Owner.Id')
       expect(ownerAssign).to eq true
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] contact:Number_of_Full_Time_Employees__c")
       expect(contact.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] contact:Looking_For_Number_Of_Desk__c")
       expect(contact.fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       puts "get Opportunity details"
       opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact.fetch('Id')}")
       expect(opportunity).to_not eq nil


       passedLogs = @objRollbar.addLog("[Validate] opportunity:RecordType.Name")
       expect(opportunity.fetch('RecordType.Name')).to eq "Enterprise Solutions"
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] opportunity:Deal_Type__c")
       expect(opportunity.fetch('Deal_Type__c')).to eq "Relational"
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] opportunity:Owner.Id")
       ownerAssign = accQueue.include? opportunity.fetch('Owner.Id')
       expect(ownerAssign).to eq true
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] opportunity:Quantity__c")
       expect(opportunity.fetch('Quantity__c').to_i).to eq 0
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       puts "get Account Details"
       account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact.fetch('Id')}")

       passedLogs = @objRollbar.addLog("[Validate] account:RecordType.Name")
       expect(account.fetch('RecordType.Name')).to eq "Enterprise Solutions"
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] account:Owner.Name")
       ownerAssign = accQueue.include? account.fetch('Owner.Id')
       expect(ownerAssign).to eq true
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] account:Number_of_Full_Time_Employees__c")
       expect(account.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] account:Interested_in_Number_of_Desks__c")
       expect(account.fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] account:Allow_Merge__c")
       expect(account.fetch('Allow_Merge__c')).to eq "true"
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

     rescue Exception => e
       passedLogs = @objRollbar.addLog("[Result  ]  Fail")
       raise e
     end

   end

   it "C2057 : To Check Account Assignment for Record Type Enterprise and Deal Type Strategic.", :'2057'=> 'true' do
     begin
       @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['building']  = 'SYD-Martin Place'
       @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['companySize']  = '1200'
       @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['numberOfDesks']  = '27'

       puts "C2057 : To Check Account Assignment for Record Type Enterprise and Deal type Strategic."

       caseInfo = @testRailUtility.getCase('2057')
       #puts caseInfo
       passedLogs = @objRollbar.addLog("[Step    ] booking tour from WebSite", caseInfo['id'])
       emailId = @objAccAssignmentFromLead.createLead()
       expect(@driver.title).to match("Coworking Office Sambhav BKC | WeWork")

       passedLogs = @objRollbar.addLog("[Validate]  Lead should be created")
       leadId = @objAccAssignmentFromLead.fetchLeadDetails(emailId).fetch('Id')
       expect(leadId).to_not eq 'nil'
       passedLogs = @objRollbar.addLog("[Expected]  Lead created successfully with emailId = #{emailId} \n[Result  ]  Success ")

       passedLogs = @objRollbar.addLog("[Step    ] logging to salesforce")
       @objAccAssignmentFromLead.loginToSalesforce

       passedLogs = @objRollbar.addLog("[Step    ] go to details page of created lead and Clicking on 'Manage/book Tour' button")
       expect(@objAccAssignmentFromLead.goToDetailPage(leadId)).to eq true


       passedLogs = @objRollbar.addLog("[Validate] Checking Manage Tour page when user click on 'Manage/book tour' button")
       expect(@driver.title).to match("Manage Tours")
       passedLogs = @objRollbar.addLog("[Expected] Manage tour page opened successfully with Page Title= Manage Tours \n[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Step    ] filling all required fields and booked a tour")

       expect(@objAccAssignmentFromLead.bookTour(0,true)).to eq true

       passedLogs = @objRollbar.addLog("[Step    ] click on Create Account and Don't Merge")
       @objAccAssignmentFromLead.instance_variable_get(:@wait).until {@driver.find_element(:id ,"header43").displayed?}
       expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Merge",nil)).to eq true

       passedLogs = @objRollbar.addLog("[Step    ] checking fields...")

       passedLogs = @objRollbar.addLog("[Step    ] get building details of #{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"]}")
       building = @objAccAssignmentFromLead.fetchBuildingDetails(@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"])
       expect(building).to_not eq nil


       passedLogs = @objRollbar.addLog("[Step    ] get accQueue details")
       accQueue = @objAccAssignmentFromLead.fetAccOwnerQueue(building.fetch('Market__c'),'Enterprise Solutions')

       #accQueue = @objAccAssignmentFromLead.fetAccOwnerQueue('a2V0G000003H8zoUAC','Enterprise Solutions')

       passedLogs = @objRollbar.addLog("[Step    ] get Contact details")
       contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
       #contact = @objAccAssignmentFromLead.fetchContactDetails("john.smith1004201828@example.com")
       expect(contact).to_not eq nil

       passedLogs = @objRollbar.addLog("[Validate] contact:RecordType.Name")
       expect(contact.fetch('RecordType.Name')).to eq "Enterprise Solutions"
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] contact:Owner.Id")
       puts accQueue.include? contact.fetch('Owner.Id')
       ownerAssign = accQueue.include? contact.fetch('Owner.Id')
       expect(ownerAssign).to eq true
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] contact:Number_of_Full_Time_Employees__c")
       expect(contact.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] contact:Looking_For_Number_Of_Desk__c")
       expect(contact.fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       puts "get Opportunity details"
       opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact.fetch('Id')}")
       expect(opportunity).to_not eq nil


       passedLogs = @objRollbar.addLog("[Validate] opportunity:RecordType.Name")
       expect(opportunity.fetch('RecordType.Name')).to eq "Enterprise Solutions"
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] opportunity:Deal_Type__c")
       expect(opportunity.fetch('Deal_Type__c')).to eq "Strategic"
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] opportunity:Owner.Id")
       ownerAssign = accQueue.include? opportunity.fetch('Owner.Id')
       expect(ownerAssign).to eq true
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] opportunity:Quantity__c")
       expect(opportunity.fetch('Quantity__c').to_i).to eq 0
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       puts "get Account Details"
       account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact.fetch('Id')}")

       passedLogs = @objRollbar.addLog("[Validate] account:RecordType.Name")
       expect(account.fetch('RecordType.Name')).to eq "Enterprise Solutions"
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] account:Owner.Name")
       ownerAssign = accQueue.include? account.fetch('Owner.Id')
       expect(ownerAssign).to eq true
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] account:Number_of_Full_Time_Employees__c")
       expect(account.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] account:Interested_in_Number_of_Desks__c")
       expect(account.fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

       passedLogs = @objRollbar.addLog("[Validate] account:Allow_Merge__c")
       expect(account.fetch('Allow_Merge__c')).to eq "true"
       passedLogs = @objRollbar.addLog("[Result  ]  Success")

     rescue Exception => e
       passedLogs = @objRollbar.addLog("[Result  ]  Fail")
       raise e
     end

   end


 end

  context "by Add Opportunity with create acc and merge" do

    it "C2058 : To check account assignment for Record Type Consumer and Deal type Transactional.", :'2058'=> 'true' do
      begin
        puts "C2058 : To check account assignment for Record Type Consumer and Deal type Transactional."

        @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['companySize']  = '15'
        @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['numberOfDesks']  = '5'
        @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['building']  = 'MUM-BKC'

        caseInfo = @testRailUtility.getCase('2058')
        #puts caseInfo
        passedLogs = @objRollbar.addLog("[Step    ] booking tour from WebSite", caseInfo['id'])
        emailId = @objAccAssignmentFromLead.createLead()
        expect(@driver.title).to match("Coworking Office Sambhav BKC | WeWork")





        passedLogs = @objRollbar.addLog("[Validate]  Journey should be created")
        journey = @objAccAssignmentFromLead.fetchJourneyDetails(emailId)
        expect(journey).to_not eq 'nil'
        passedLogs = @objRollbar.addLog("[Expected]  Journey created successfully with emailId = #{emailId} \n[Result  ]  Success ")

        passedLogs = @objRollbar.addLog("[Step    ] logging to salesforce")
        expect(@objAccAssignmentFromLead.loginToSalesforce).to_not eq nil

        passedLogs = @objRollbar.addLog("[Step    ] go to details page of created Journey and Clicking on 'Add Opportunity' button")
        expect(@objAccAssignmentFromLead.goToDetailPageJourney(journey.fetch('Id'))).to eq true


        passedLogs = @objRollbar.addLog("[Validate] Checking Add Opportunity when user click on 'Add Opportunity' button")
        expect(@driver.title).to match("Add Opportunity")
        passedLogs = @objRollbar.addLog("[Expected] Manage tour page opened successfully with Page Title= Add Opportunity \n[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Step    ] filling all required fields and Add Opportunity")

        expect(@objAccAssignmentFromLead.addOpportunity()).to eq true

        passedLogs = @objRollbar.addLog("[Step    ] click on Create Account and Merge")
        expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Merge",nil)).to eq true

        passedLogs = @objRollbar.addLog("[Step    ] checking fields...")

        passedLogs = @objRollbar.addLog("[Step    ] get building details of #{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"]}")
        building = @objAccAssignmentFromLead.fetchBuildingDetails(@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"])
        expect(building).to_not eq nil

        passedLogs = @objRollbar.addLog("[Step    ] get Contact details")
        contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
        expect(contact).to_not eq nil

        passedLogs = @objRollbar.addLog("[Validate] contact:RecordType.Name")
        expect(contact.fetch('RecordType.Name')).to eq "Consumer"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] contact:Owner.Id")
        expect(contact.fetch('Owner.Id')).to eq "#{building.fetch('Community_Lead__c')}"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] contact:Number_of_Full_Time_Employees__c")
        expect(contact.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] contact:Looking_For_Number_Of_Desk__c")
        expect(contact.fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        puts "get Opportunity details"
        opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact.fetch('Id')}")
        puts opportunity

        passedLogs = @objRollbar.addLog("[Validate] opportunity:RecordType.Name")
        expect(opportunity.fetch('RecordType.Name')).to eq "Consumer"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:Deal_Type__c")
        expect(opportunity.fetch('Deal_Type__c')).to eq "Transactional"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:Owner.Id")
        expect(opportunity.fetch('Owner.Id')).to eq "#{building.fetch('Community_Lead__c')}"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:Quantity__c")
        expect(opportunity.fetch('Quantity__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        puts "get Account Details"
        account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact.fetch('Id')}")

        passedLogs = @objRollbar.addLog("[Validate] account:RecordType.Name")
        expect(account.fetch('RecordType.Name')).to eq "Consumer"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Owner.Id")
        expect(account.fetch('Owner.Id')).to eq "#{building.fetch('Community_Lead__c')}"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Number_of_Full_Time_Employees__c")
        expect(account.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Interested_in_Number_of_Desks__c")
        expect(account.fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Allow_Merge__c")
        expect(account.fetch('Allow_Merge__c')).to eq "true"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

      rescue Exception => e
        passedLogs = @objRollbar.addLog("[Result  ]  Fail")
        raise e
      end

    end


    it "C2049 : To check account assignment for Record Type Consumer and Deal type Relational.", :'2'=> 'true' do
      begin
        puts "C2049 : To check account assignment for Record Type Consumer and Deal type Relational."

        @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['companySize']  = '15'
        @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['numberOfDesks']  = '13'
        @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['building']  = 'MUM-BKC'


        caseInfo = @testRailUtility.getCase('2049')
        passedLogs = @objRollbar.addLog("[Step    ] booking tour from WebSite", caseInfo['id'])
        emailId = @objAccAssignmentFromLead.createLead()
        expect(@driver.title).to match("Coworking Office Sambhav BKC | WeWork")

=begin
        passedLogs = @objRollbar.addLog("[Validate]  Lead should be created")
        leadId = @objAccAssignmentFromLead.fetchLeadDetails(emailId).fetch('Id')
        expect(leadId).to_not eq 'nil'
        passedLogs = @objRollbar.addLog("[Expected]  Lead created successfully with emailId = #{emailId} \n[Result  ]  Success ")
=end

        passedLogs = @objRollbar.addLog("[Validate]  Journey should be created")
        journey = @objAccAssignmentFromLead.fetchJourneyDetails(emailId)
        expect(journey).to_not eq nil
        passedLogs = @objRollbar.addLog("[Expected]  Journey created successfully with emailId = #{emailId} \n[Result  ]  Success ")

        passedLogs = @objRollbar.addLog("[Step    ] logging to salesforce")
        expect(@objAccAssignmentFromLead.loginToSalesforce).to_not eq nil

        passedLogs = @objRollbar.addLog("[Step    ] go to details page of created Journey and Clicking on 'Add Opportunity' button")
        expect(@objAccAssignmentFromLead.goToDetailPageJourney(journey.fetch('Id'))).to eq true


        passedLogs = @objRollbar.addLog("[Validate] Checking Add Opportunity when user click on 'Add Opportunity' button")
        expect(@driver.title).to match("Add Opportunity")
        passedLogs = @objRollbar.addLog("[Expected] Manage tour page opened successfully with Page Title= Add Opportunity \n[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Step    ] filling all required fields and Add Opportunity")

        expect(@objAccAssignmentFromLead.addOpportunity()).to eq true

        passedLogs = @objRollbar.addLog("[Step    ] click on Create Account and Merge")
        #@objAccAssignmentFromLead.instance_variable_get(:@wait).until {@driver.find_element(:id ,"header43").displayed?}
        expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Merge",nil)).to eq true

        passedLogs = @objRollbar.addLog("[Step    ] checking fields...")

        passedLogs = @objRollbar.addLog("[Step    ] get building details of #{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"]}")
        building = @objAccAssignmentFromLead.fetchBuildingDetails(@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"])
        expect(building).to_not eq nil

        passedLogs = @objRollbar.addLog("[Step    ] get Contact details")
        contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
        expect(contact).to_not eq nil

        passedLogs = @objRollbar.addLog("[Validate] contact:RecordType.Name")
        expect(contact.fetch('RecordType.Name')).to eq "Consumer"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] contact:Owner.Id")
        expect(contact.fetch('Owner.Name')).to eq "#{building.fetch('Cluster_Sales_Lead_Name__c')}"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] contact:Number_of_Full_Time_Employees__c")
        expect(contact.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] contact:Looking_For_Number_Of_Desk__c")
        expect(contact.fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        puts "get Opportunity details"
        opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact.fetch('Id')}")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:RecordType.Name")
        expect(opportunity.fetch('RecordType.Name')).to eq "Consumer"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:Deal_Type__c")
        expect(opportunity.fetch('Deal_Type__c')).to eq "Relational"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:Owner.Id")
        expect(opportunity.fetch('Owner.Name')).to eq "#{building.fetch('Cluster_Sales_Lead_Name__c')}"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:Quantity__c")
        expect(opportunity.fetch('Quantity__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        puts "get Account Details"
        account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact.fetch('Id')}")

        passedLogs = @objRollbar.addLog("[Validate] account:RecordType.Name")
        expect(account.fetch('RecordType.Name')).to eq "Consumer"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Owner.Name")
        expect(account.fetch('Owner.Name')).to eq "#{building.fetch('Cluster_Sales_Lead_Name__c')}"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Number_of_Full_Time_Employees__c")
        expect(account.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Interested_in_Number_of_Desks__c")
        expect(account.fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Allow_Merge__c")
        expect(account.fetch('Allow_Merge__c')).to eq "true"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

      rescue Exception => e
        passedLogs = @objRollbar.addLog("[Result  ]  Fail")
        raise e
      end

    end


    it "C2050 : To check account assignment for Record Type Consumer and Deal type Strategic.", :'3'=> 'true' do
      begin
        puts "C2050 : To check account assignment for Record Type Consumer and Deal type Strategic."

        @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['companySize']  = '15'
        @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['numberOfDesks']  = '25'

        caseInfo = @testRailUtility.getCase('2050')
        passedLogs = @objRollbar.addLog("[Step    ] booking tour from WebSite", caseInfo['id'])
        emailId = @objAccAssignmentFromLead.createLead()
        expect(@driver.title).to match("Coworking Office Sambhav BKC | WeWork")

        passedLogs = @objRollbar.addLog("[Validate]  Journey should be created")
        journey = @objAccAssignmentFromLead.fetchJourneyDetails(emailId)
        expect(journey).to_not eq 'nil'
        passedLogs = @objRollbar.addLog("[Expected]  Journey created successfully with emailId = #{emailId} \n[Result  ]  Success ")

        passedLogs = @objRollbar.addLog("[Step    ] logging to salesforce")
        expect(@objAccAssignmentFromLead.loginToSalesforce).to_not eq nil

        passedLogs = @objRollbar.addLog("[Step    ] go to details page of created Journey and Clicking on 'Add Opportunity' button")
        expect(@objAccAssignmentFromLead.goToDetailPageJourney(journey.fetch('Id'))).to eq true


        passedLogs = @objRollbar.addLog("[Validate] Checking Add Opportunity when user click on 'Add Opportunity' button")
        expect(@driver.title).to match("Add Opportunity")
        passedLogs = @objRollbar.addLog("[Expected] Manage tour page opened successfully with Page Title= Add Opportunity \n[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Step    ] filling all required fields and Add Opportunity")

        expect(@objAccAssignmentFromLead.addOpportunity()).to eq true

        passedLogs = @objRollbar.addLog("[Step    ] click on Create Account and Merge")
        @objAccAssignmentFromLead.instance_variable_get(:@wait).until {@driver.find_element(:id ,"header43").displayed?}
        expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Merge",nil)).to eq true

        passedLogs = @objRollbar.addLog("[Step    ] checking fields...")

        passedLogs = @objRollbar.addLog("[Step    ] get building details of #{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"]}")
        building = @objAccAssignmentFromLead.fetchBuildingDetails(@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"])
        expect(building).to_not eq nil

        passedLogs = @objRollbar.addLog("[Step    ] get accQueue details")
        accQueue = @objAccAssignmentFromLead.fetAccOwnerQueue(building.fetch('Market__c'),'Consumer')

        passedLogs = @objRollbar.addLog("[Step    ] get Contact details")
        contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
        expect(contact).to_not eq nil

        passedLogs = @objRollbar.addLog("[Validate] contact:RecordType.Name")
        expect(contact.fetch('RecordType.Name')).to eq "Consumer"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] contact:Owner.Id")
        ownerAssign = accQueue.include? contact.fetch('Owner.Id')
        expect(ownerAssign).to eq true
        #expect(contact.fetch('Owner.Id')).to eq "#{accQueue.fetch('Member__c')}"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] contact:Number_of_Full_Time_Employees__c")
        expect(contact.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] contact:Looking_For_Number_Of_Desk__c")
        expect(contact.fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        puts "get Opportunity details"
        opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact.fetch('Id')}")
        puts opportunity

        passedLogs = @objRollbar.addLog("[Validate] opportunity:RecordType.Name")
        expect(opportunity.fetch('RecordType.Name')).to eq "Consumer"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:Deal_Type__c")
        expect(opportunity.fetch('Deal_Type__c')).to eq "Strategic"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:Owner.Id")
        ownerAssign = accQueue.include? opportunity.fetch('Owner.Id')
        expect(ownerAssign).to eq true
        #expect(opportunity.fetch('Owner.Id')).to eq "#{accQueue.fetch('Member__c')}"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:Quantity__c")
        expect(opportunity.fetch('Quantity__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        puts "get Account Details"
        account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact.fetch('Id')}")
        puts account

        passedLogs = @objRollbar.addLog("[Validate] account:RecordType.Name")
        expect(account.fetch('RecordType.Name')).to eq "Consumer"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Owner.Name")
        ownerAssign = accQueue.include? account.fetch('Owner.Id')
        expect(ownerAssign).to eq true

        #expect(account.fetch('Owner.Id')).to eq "#{accQueue.fetch('Member__c')}"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Number_of_Full_Time_Employees__c")
        expect(account.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Interested_in_Number_of_Desks__c")
        expect(account.fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Allow_Merge__c")
        expect(account.fetch('Allow_Merge__c')).to eq "true"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

      rescue Exception => e
        passedLogs = @objRollbar.addLog("[Result  ]  Fail")
        raise e
      end

    end


    it "C2051 : To check account assignment for Record Type Consumer and Deal type Relational.", :'4'=> 'true'  do
      begin
        @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['companySize']  = '15'
        @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['numberOfDesks']  = '25'

        puts "C2051 : To check account assignment for Record Type Consumer and Deal type Strategic.(Queue is not present in the Account Queue Setting)."

        caseInfo = @testRailUtility.getCase('2051')
        @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['building']  = 'SYD-Martin Place'

        #puts caseInfo
        passedLogs = @objRollbar.addLog("[Step    ] booking tour from WebSite", caseInfo['id'])
        emailId = @objAccAssignmentFromLead.createLead()
        #expect(@driver.title).to match("Coworking Office Sambhav BKC | WeWork")


        passedLogs = @objRollbar.addLog("[Validate]  Journey should be created")
        journey = @objAccAssignmentFromLead.fetchJourneyDetails(emailId)
        expect(journey).to_not eq nil
        passedLogs = @objRollbar.addLog("[Expected]  Journey created successfully with emailId = #{emailId} \n[Result  ]  Success ")

        passedLogs = @objRollbar.addLog("[Step    ] logging to salesforce")
        expect(@objAccAssignmentFromLead.loginToSalesforce).to_not eq nil

        passedLogs = @objRollbar.addLog("[Step    ] go to details page of created Journey and Clicking on 'Add Opportunity' button")
        expect(@objAccAssignmentFromLead.goToDetailPageJourney(journey.fetch('Id'))).to eq true


        passedLogs = @objRollbar.addLog("[Validate] Checking Add Opportunity when user click on 'Add Opportunity' button")
        expect(@driver.title).to match("Add Opportunity")
        passedLogs = @objRollbar.addLog("[Expected] Manage tour page opened successfully with Page Title= Add Opportunity \n[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Step    ] filling all required fields and Add Opportunity")

        expect(@objAccAssignmentFromLead.addOpportunity()).to eq true

        passedLogs = @objRollbar.addLog("[Step    ] click on Create Account and Merge")

        #@objAccAssignmentFromLead.instance_variable_get(:@wait).until {@driver.find_element(:id ,"header43").displayed?}
        expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Merge",nil)).to eq true

        passedLogs = @objRollbar.addLog("[Step    ] checking fields...")

        passedLogs = @objRollbar.addLog("[Step    ] get building details of #{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"]}")
        building = @objAccAssignmentFromLead.fetchBuildingDetails(@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"])
        expect(building).to_not eq nil

        #passedLogs = @objRollbar.addLog("[Step    ] get accQueue details")
        #accQueue = @objAccAssignmentFromLead.fetAccOwnerQueue(building.fetch('Market__c'),'Consumer')

        passedLogs = @objRollbar.addLog("[Step    ] get Contact details")
        contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
        expect(contact).to_not eq nil

        passedLogs = @objRollbar.addLog("[Validate] contact:RecordType.Name")
        expect(contact.fetch('RecordType.Name')).to eq "Consumer"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] contact:Owner.Id")
        expect(contact.fetch('Owner.Id')).to eq "005F0000003KmbwIAC"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] contact:Number_of_Full_Time_Employees__c")
        expect(contact.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] contact:Looking_For_Number_Of_Desk__c")
        expect(contact.fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        puts "get Opportunity details"
        opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact.fetch('Id')}")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:RecordType.Name")
        expect(opportunity.fetch('RecordType.Name')).to eq "Consumer"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:Deal_Type__c")
        expect(opportunity.fetch('Deal_Type__c')).to eq "Strategic"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:Owner.Id")
        expect(opportunity.fetch('Owner.Id')).to eq "005F0000003KmbwIAC"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:Quantity__c")
        expect(opportunity.fetch('Quantity__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        puts "get Account Details"
        account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact.fetch('Id')}")

        passedLogs = @objRollbar.addLog("[Validate] account:RecordType.Name")
        expect(account.fetch('RecordType.Name')).to eq "Consumer"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Owner.Name")
        expect(account.fetch('Owner.Id')).to eq "005F0000003KmbwIAC"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Number_of_Full_Time_Employees__c")
        expect(account.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Interested_in_Number_of_Desks__c")
        expect(account.fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Allow_Merge__c")
        expect(account.fetch('Allow_Merge__c')).to eq "true"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

      rescue Exception => e
        passedLogs = @objRollbar.addLog("[Result  ]  Fail")
        raise e
      end

    end

    it "C2052 : To Check Account assignment for Record Type Mid-Market and Deal type Transactional.", :'5'=> 'true' do
      begin
        puts "C2052 : To Check Account assignment for Record Type Mid-Market and Deal type Transactional."
        @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['building']  = 'SYD-Martin Place'
        @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['companySize']  = '24'
        @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['numberOfDesks']  = '7'


        caseInfo = @testRailUtility.getCase('2052')
        #puts caseInfo
        passedLogs = @objRollbar.addLog("[Step    ] booking tour from WebSite", caseInfo['id'])
        emailId = @objAccAssignmentFromLead.createLead()
        #expect(@driver.title).to match("Coworking Office Sambhav BKC | WeWork")

        passedLogs = @objRollbar.addLog("[Validate]  Journey should be created")
        journey = @objAccAssignmentFromLead.fetchJourneyDetails(emailId)
        expect(journey).to_not eq nil
        passedLogs = @objRollbar.addLog("[Expected]  Journey created successfully with emailId = #{emailId} \n[Result  ]  Success ")

        passedLogs = @objRollbar.addLog("[Step    ] logging to salesforce")
        expect(@objAccAssignmentFromLead.loginToSalesforce).to_not eq nil

        passedLogs = @objRollbar.addLog("[Step    ] go to details page of created Journey and Clicking on 'Add Opportunity' button")
        expect(@objAccAssignmentFromLead.goToDetailPageJourney(journey.fetch('Id'))).to eq true


        passedLogs = @objRollbar.addLog("[Validate] Checking Add Opportunity when user click on 'Add Opportunity' button")
        expect(@driver.title).to match("Add Opportunity")
        passedLogs = @objRollbar.addLog("[Expected] Manage tour page opened successfully with Page Title= Add Opportunity \n[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Step    ] filling all required fields and Add Opportunity")

        expect(@objAccAssignmentFromLead.addOpportunity()).to eq true

        passedLogs = @objRollbar.addLog("[Step    ] click on Create Account and Merge")
        #@objAccAssignmentFromLead.instance_variable_get(:@wait).until {@driver.find_element(:id ,"header43").displayed?}
        expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Merge",nil)).to eq true

        passedLogs = @objRollbar.addLog("[Step    ] checking fields...")

        passedLogs = @objRollbar.addLog("[Step    ] get building details of #{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"]}")
        building = @objAccAssignmentFromLead.fetchBuildingDetails(@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"])
        expect(building).to_not eq nil

        passedLogs = @objRollbar.addLog("[Step    ] get Contact details")
        contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
        expect(contact).to_not eq nil

        passedLogs = @objRollbar.addLog("[Validate] contact:RecordType.Name")
        expect(contact.fetch('RecordType.Name')).to eq "Mid Market"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] contact:Owner.Id")
        expect(contact.fetch('Owner.Id')).to eq "#{building.fetch('Community_Lead__c')}"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] contact:Number_of_Full_Time_Employees__c")
        expect(contact.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] contact:Looking_For_Number_Of_Desk__c")
        expect(contact.fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        puts "get Opportunity details"
        opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact.fetch('Id')}")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:RecordType.Name")
        expect(opportunity.fetch('RecordType.Name')).to eq "Mid Market"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:Deal_Type__c")
        expect(opportunity.fetch('Deal_Type__c')).to eq "Transactional"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:Owner.Id")
        expect(opportunity.fetch('Owner.Id')).to eq "#{building.fetch('Community_Lead__c')}"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:Quantity__c")
        expect(opportunity.fetch('Quantity__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        puts "get Account Details"
        account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact.fetch('Id')}")

        passedLogs = @objRollbar.addLog("[Validate] account:RecordType.Name")
        expect(account.fetch('RecordType.Name')).to eq "Mid Market"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Owner.Id")
        expect(account.fetch('Owner.Id')).to eq "#{building.fetch('Community_Lead__c')}"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Number_of_Full_Time_Employees__c")
        expect(account.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Interested_in_Number_of_Desks__c")
        expect(account.fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Allow_Merge__c")
        expect(account.fetch('Allow_Merge__c')).to eq "true"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

      rescue Exception => e
        passedLogs = @objRollbar.addLog("[Result  ]  Fail")
        raise e
      end

    end

    it "C2053 : To Check Account Assignment for Record type Mid-Market and Deal type Relational.", :'6'=> 'true' do
      begin
        puts "C2053 : To Check Account Assignment for Record type Mid-Market and Deal type Relational."

        caseInfo = @testRailUtility.getCase('2053')
        #puts caseInfo
        @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['building']  = 'SYD-Martin Place'
        @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['companySize']  = '24'
        @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['numberOfDesks']  = '15'

        passedLogs = @objRollbar.addLog("[Step    ] booking tour from WebSite", caseInfo['id'])
        emailId = @objAccAssignmentFromLead.createLead()
        expect(@driver.title).to match("Coworking Office Sambhav BKC | WeWork")

        passedLogs = @objRollbar.addLog("[Validate]  Journey should be created")
        journey = @objAccAssignmentFromLead.fetchJourneyDetails(emailId)
        expect(journey).to_not eq nil
        passedLogs = @objRollbar.addLog("[Expected]  Journey created successfully with emailId = #{emailId} \n[Result  ]  Success ")

        passedLogs = @objRollbar.addLog("[Step    ] logging to salesforce")
        expect(@objAccAssignmentFromLead.loginToSalesforce).to_not eq nil

        passedLogs = @objRollbar.addLog("[Step    ] go to details page of created Journey and Clicking on 'Add Opportunity' button")
        expect(@objAccAssignmentFromLead.goToDetailPageJourney(journey.fetch('Id'))).to eq true


        passedLogs = @objRollbar.addLog("[Validate] Checking Add Opportunity when user click on 'Add Opportunity' button")
        expect(@driver.title).to match("Add Opportunity")
        passedLogs = @objRollbar.addLog("[Expected] Manage tour page opened successfully with Page Title= Add Opportunity \n[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Step    ] filling all required fields and Add Opportunity")

        expect(@objAccAssignmentFromLead.addOpportunity()).to eq true

        passedLogs = @objRollbar.addLog("[Step    ] click on Create Account and Merge")
        #@objAccAssignmentFromLead.instance_variable_get(:@wait).until {@driver.find_element(:id ,"header43").displayed?}
        expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Merge",nil)).to eq true

        passedLogs = @objRollbar.addLog("[Step    ] checking fields...")

        passedLogs = @objRollbar.addLog("[Step    ] get building details of #{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"]}")
        building = @objAccAssignmentFromLead.fetchBuildingDetails(@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"])
        expect(building).to_not eq nil

        passedLogs = @objRollbar.addLog("[Step    ] get Contact details")
        contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
        expect(contact).to_not eq nil

        passedLogs = @objRollbar.addLog("[Validate] contact:RecordType.Name")
        expect(contact.fetch('RecordType.Name')).to eq "Mid Market"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] contact:Owner.Id")
        expect(contact.fetch('Owner.Name')).to eq "#{building.fetch('Cluster_Sales_Lead_Name__c')}"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] contact:Number_of_Full_Time_Employees__c")
        expect(contact.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] contact:Looking_For_Number_Of_Desk__c")
        expect(contact.fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        puts "get Opportunity details"
        opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact.fetch('Id')}")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:RecordType.Name")
        expect(opportunity.fetch('RecordType.Name')).to eq "Mid Market"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:Deal_Type__c")
        expect(opportunity.fetch('Deal_Type__c')).to eq "Relational"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:Owner.Id")
        expect(opportunity.fetch('Owner.Name')).to eq "#{building.fetch('Cluster_Sales_Lead_Name__c')}"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:Quantity__c")
        expect(opportunity.fetch('Quantity__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        puts "get Account Details"
        account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact.fetch('Id')}")

        passedLogs = @objRollbar.addLog("[Validate] account:RecordType.Name")
        expect(account.fetch('RecordType.Name')).to eq "Mid Market"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Owner.Name")
        expect(account.fetch('Owner.Name')).to eq "#{building.fetch('Cluster_Sales_Lead_Name__c')}"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Number_of_Full_Time_Employees__c")
        expect(account.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Interested_in_Number_of_Desks__c")
        expect(account.fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Allow_Merge__c")
        expect(account.fetch('Allow_Merge__c')).to eq "true"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

      rescue Exception => e
        passedLogs = @objRollbar.addLog("[Result  ]  Fail")
        raise e
      end

    end

    it "C2054 : To Check Account Assignment from Record type Mid-Market and Deal Type Strategic.", :'7'=> 'true' do
      begin
        puts "C2054 : To check account assignment for Record Type Consumer and Deal type Relational."

        @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['building']  = 'SYD-Martin Place'
        @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['companySize']  = '24'
        @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['numberOfDesks']  = '27'

        caseInfo = @testRailUtility.getCase('2054')
        #puts caseInfo
        passedLogs = @objRollbar.addLog("[Step    ] booking tour from WebSite", caseInfo['id'])
        emailId = @objAccAssignmentFromLead.createLead()
        expect(@driver.title).to match("Coworking Office Sambhav BKC | WeWork")

        passedLogs = @objRollbar.addLog("[Validate]  Journey should be created")
        journey = @objAccAssignmentFromLead.fetchJourneyDetails(emailId)
        expect(journey).to_not eq nil
        passedLogs = @objRollbar.addLog("[Expected]  Journey created successfully with emailId = #{emailId} \n[Result  ]  Success ")

        passedLogs = @objRollbar.addLog("[Step    ] logging to salesforce")
        expect(@objAccAssignmentFromLead.loginToSalesforce).to_not eq nil

        passedLogs = @objRollbar.addLog("[Step    ] go to details page of created Journey and Clicking on 'Add Opportunity' button")
        expect(@objAccAssignmentFromLead.goToDetailPageJourney(journey.fetch('Id'))).to eq true


        passedLogs = @objRollbar.addLog("[Validate] Checking Add Opportunity when user click on 'Add Opportunity' button")
        expect(@driver.title).to match("Add Opportunity")
        passedLogs = @objRollbar.addLog("[Expected] Manage tour page opened successfully with Page Title= Add Opportunity \n[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Step    ] filling all required fields and Add Opportunity")

        expect(@objAccAssignmentFromLead.addOpportunity()).to eq true

        passedLogs = @objRollbar.addLog("[Step    ] click on Create Account and Merge")
        @objAccAssignmentFromLead.instance_variable_get(:@wait).until {@driver.find_element(:id ,"header43").displayed?}
        expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Merge",nil)).to eq true

        passedLogs = @objRollbar.addLog("[Step    ] checking fields...")

        passedLogs = @objRollbar.addLog("[Step    ] get building details of #{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"]}")
        building = @objAccAssignmentFromLead.fetchBuildingDetails(@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"])
        expect(building).to_not eq nil

        passedLogs = @objRollbar.addLog("[Step    ] get accQueue details")

        accQueue = @objAccAssignmentFromLead.fetAccOwnerQueue(building.fetch('Market__c'),'Mid Market')

        passedLogs = @objRollbar.addLog("[Step    ] get Contact details")
        contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
        expect(contact).to_not eq nil

        passedLogs = @objRollbar.addLog("[Validate] contact:RecordType.Name")
        expect(contact.fetch('RecordType.Name')).to eq "Mid Market"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] contact:Owner.Id")

        puts accQueue.include? contact.fetch('Owner.Id')
        ownerAssign = accQueue.include? contact.fetch('Owner.Id')
        expect(ownerAssign).to eq true

        #expect(contact.fetch('Owner.Id')).to eq "#{accQueue.fetch('Member__c')}"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] contact:Number_of_Full_Time_Employees__c")
        expect(contact.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] contact:Looking_For_Number_Of_Desk__c")
        expect(contact.fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        puts "get Opportunity details"
        opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact.fetch('Id')}")
        puts opportunity

        passedLogs = @objRollbar.addLog("[Validate] opportunity:RecordType.Name")
        expect(opportunity.fetch('RecordType.Name')).to eq "Mid Market"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:Deal_Type__c")
        expect(opportunity.fetch('Deal_Type__c')).to eq "Strategic"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:Owner.Id")
        ownerAssign = accQueue.include? opportunity.fetch('Owner.Id')
        expect(ownerAssign).to eq true

        #expect(opportunity.fetch('Owner.Id')).to eq "#{accQueue.fetch('Member__c')}"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:Quantity__c")
        expect(opportunity.fetch('Quantity__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        puts "get Account Details"
        account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact.fetch('Id')}")
        puts account

        passedLogs = @objRollbar.addLog("[Validate] account:RecordType.Name")
        expect(account.fetch('RecordType.Name')).to eq "Mid Market"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Owner.Name")
        ownerAssign = accQueue.include? account.fetch('Owner.Id')
        expect(ownerAssign).to eq true
        #expect(account.fetch('Owner.Id')).to eq "#{accQueue.fetch('Member__c')}"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Number_of_Full_Time_Employees__c")
        expect(account.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Interested_in_Number_of_Desks__c")
        expect(account.fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Allow_Merge__c")
        expect(account.fetch('Allow_Merge__c')).to eq "true"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

      rescue Exception => e
        passedLogs = @objRollbar.addLog("[Result  ]  Fail")
        raise e
      end

    end

    it "C2055 : To Check Account Assignment for Record Type Enterprise and Deal type Transactional.", :'8'=> 'true' do
      begin
        puts "C2055 : To Check Account Assignment for Record Type Enterprise and Deal type Transactional."

        @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['building']  = 'MEL-Bourke Street'
        @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['companySize']  = '1200'
        @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['numberOfDesks']  = '7'

        caseInfo = @testRailUtility.getCase('2055')
        #puts caseInfo
        passedLogs = @objRollbar.addLog("[Step    ] booking tour from WebSite", caseInfo['id'])
        emailId = @objAccAssignmentFromLead.createLead()
        expect(@driver.title).to match("Coworking Office Sambhav BKC | WeWork")

        passedLogs = @objRollbar.addLog("[Validate]  Journey should be created")
        journey = @objAccAssignmentFromLead.fetchJourneyDetails(emailId)
        expect(journey).to_not eq nil
        passedLogs = @objRollbar.addLog("[Expected]  Journey created successfully with emailId = #{emailId} \n[Result  ]  Success ")

        passedLogs = @objRollbar.addLog("[Step    ] logging to salesforce")
        expect(@objAccAssignmentFromLead.loginToSalesforce).to_not eq nil

        passedLogs = @objRollbar.addLog("[Step    ] go to details page of created Journey and Clicking on 'Add Opportunity' button")
        expect(@objAccAssignmentFromLead.goToDetailPageJourney(journey.fetch('Id'))).to eq true


        passedLogs = @objRollbar.addLog("[Validate] Checking Add Opportunity when user click on 'Add Opportunity' button")
        expect(@driver.title).to match("Add Opportunity")
        passedLogs = @objRollbar.addLog("[Expected] Manage tour page opened successfully with Page Title= Add Opportunity \n[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Step    ] filling all required fields and Add Opportunity")

        expect(@objAccAssignmentFromLead.addOpportunity()).to eq true

        passedLogs = @objRollbar.addLog("[Step    ] click on Create Account and Merge")
        @objAccAssignmentFromLead.instance_variable_get(:@wait).until {@driver.find_element(:id ,"header43").displayed?}
        expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Merge",nil)).to eq true

        passedLogs = @objRollbar.addLog("[Step    ] checking fields...")

        passedLogs = @objRollbar.addLog("[Step    ] get building details of #{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"]}")
        building = @objAccAssignmentFromLead.fetchBuildingDetails(@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"])
        expect(building).to_not eq nil

        passedLogs = @objRollbar.addLog("[Step    ] get accQueue details")
        accQueue = @objAccAssignmentFromLead.fetAccOwnerQueue(building.fetch('Market__c'),'Enterprise Solutions')

        passedLogs = @objRollbar.addLog("[Step    ] get Contact details")
        contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
        expect(contact).to_not eq nil

        passedLogs = @objRollbar.addLog("[Validate] contact:RecordType.Name")
        expect(contact.fetch('RecordType.Name')).to eq "Enterprise Solutions"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] contact:Owner.Id")

        ownerAssign = accQueue.include? contact.fetch('Owner.Id')
        expect(ownerAssign).to eq true
        #expect(contact.fetch('Owner.Id')).to eq "#{accQueue.fetch('Member__c')}"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] contact:Number_of_Full_Time_Employees__c")
        expect(contact.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] contact:Looking_For_Number_Of_Desk__c")
        expect(contact.fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        puts "get Opportunity details"
        opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact.fetch('Id')}")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:RecordType.Name")
        expect(opportunity.fetch('RecordType.Name')).to eq "Enterprise Solutions"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:Deal_Type__c")
        expect(opportunity.fetch('Deal_Type__c')).to eq "Transactional"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:Owner.Id")
        ownerAssign = accQueue.include? opportunity.fetch('Owner.Id')
        expect(ownerAssign).to eq true
        #expect(opportunity.fetch('Owner.Id')).to eq "#{accQueue.fetch('Member__c')}"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:Quantity__c")
        expect(opportunity.fetch('Quantity__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        puts "get Account Details"
        account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact.fetch('Id')}")

        passedLogs = @objRollbar.addLog("[Validate] account:RecordType.Name")
        expect(account.fetch('RecordType.Name')).to eq "Enterprise Solutions"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Owner.Name")
        ownerAssign = accQueue.include? account.fetch('Owner.Id')
        expect(ownerAssign).to eq true

        #expect(account.fetch('Owner.Id')).to eq "#{accQueue.fetch('Member__c')}"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Number_of_Full_Time_Employees__c")
        expect(account.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Interested_in_Number_of_Desks__c")
        expect(account.fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Allow_Merge__c")
        expect(account.fetch('Allow_Merge__c')).to eq "true"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

      rescue Exception => e
        passedLogs = @objRollbar.addLog("[Result  ]  Fail")
        raise e
      end

    end

    it "C2056 : To Check Account Assignment for Record Type Enterprise and Deal type Relational.", :'9'=> 'true' do
      begin
        @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['building']  = 'SYD-Martin Place'
        @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['companySize']  = '1200'
        @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['numberOfDesks']  = '15'

        puts "C2056 : To Check Account Assignment for Record Type Enterprise and Deal type Relational."

        caseInfo = @testRailUtility.getCase('2056')
        #puts caseInfo
        passedLogs = @objRollbar.addLog("[Step    ] booking tour from WebSite", caseInfo['id'])
        emailId = @objAccAssignmentFromLead.createLead()
        expect(@driver.title).to match("Coworking Office Sambhav BKC | WeWork")

        passedLogs = @objRollbar.addLog("[Validate]  Journey should be created")
        journey = @objAccAssignmentFromLead.fetchJourneyDetails(emailId)
        expect(journey).to_not eq nil
        passedLogs = @objRollbar.addLog("[Expected]  Journey created successfully with emailId = #{emailId} \n[Result  ]  Success ")

        passedLogs = @objRollbar.addLog("[Step    ] logging to salesforce")
        expect(@objAccAssignmentFromLead.loginToSalesforce).to_not eq nil

        passedLogs = @objRollbar.addLog("[Step    ] go to details page of created Journey and Clicking on 'Add Opportunity' button")
        expect(@objAccAssignmentFromLead.goToDetailPageJourney(journey.fetch('Id'))).to eq true


        passedLogs = @objRollbar.addLog("[Validate] Checking Add Opportunity when user click on 'Add Opportunity' button")
        expect(@driver.title).to match("Add Opportunity")
        passedLogs = @objRollbar.addLog("[Expected] Manage tour page opened successfully with Page Title= Add Opportunity \n[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Step    ] filling all required fields and Add Opportunity")

        expect(@objAccAssignmentFromLead.addOpportunity()).to eq true

        passedLogs = @objRollbar.addLog("[Step    ] click on Create Account and Merge")
        @objAccAssignmentFromLead.instance_variable_get(:@wait).until {@driver.find_element(:id ,"header43").displayed?}
        expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Merge",nil)).to eq true

        passedLogs = @objRollbar.addLog("[Step    ] checking fields...")

        passedLogs = @objRollbar.addLog("[Step    ] get building details of #{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"]}")
        building = @objAccAssignmentFromLead.fetchBuildingDetails(@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"])
        expect(building).to_not eq nil


        passedLogs = @objRollbar.addLog("[Step    ] get accQueue details")
        accQueue = @objAccAssignmentFromLead.fetAccOwnerQueue(building.fetch('Market__c'),'Enterprise Solutions')

        #accQueue = @objAccAssignmentFromLead.fetAccOwnerQueue('a2V0G000003H8zoUAC','Enterprise Solutions')

        passedLogs = @objRollbar.addLog("[Step    ] get Contact details")
        contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
        #contact = @objAccAssignmentFromLead.fetchContactDetails("john.smith1004201828@example.com")
        expect(contact).to_not eq nil

        passedLogs = @objRollbar.addLog("[Validate] contact:RecordType.Name")
        expect(contact.fetch('RecordType.Name')).to eq "Enterprise Solutions"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] contact:Owner.Id")
        puts accQueue.include? contact.fetch('Owner.Id')
        ownerAssign = accQueue.include? contact.fetch('Owner.Id')
        expect(ownerAssign).to eq true
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] contact:Number_of_Full_Time_Employees__c")
        expect(contact.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] contact:Looking_For_Number_Of_Desk__c")
        expect(contact.fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        puts "get Opportunity details"
        opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact.fetch('Id')}")
        expect(opportunity).to_not eq nil


        passedLogs = @objRollbar.addLog("[Validate] opportunity:RecordType.Name")
        expect(opportunity.fetch('RecordType.Name')).to eq "Enterprise Solutions"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:Deal_Type__c")
        expect(opportunity.fetch('Deal_Type__c')).to eq "Relational"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:Owner.Id")
        ownerAssign = accQueue.include? opportunity.fetch('Owner.Id')
        expect(ownerAssign).to eq true
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:Quantity__c")
        expect(opportunity.fetch('Quantity__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        puts "get Account Details"
        account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact.fetch('Id')}")

        passedLogs = @objRollbar.addLog("[Validate] account:RecordType.Name")
        expect(account.fetch('RecordType.Name')).to eq "Enterprise Solutions"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Owner.Name")
        ownerAssign = accQueue.include? account.fetch('Owner.Id')
        expect(ownerAssign).to eq true
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Number_of_Full_Time_Employees__c")
        expect(account.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Interested_in_Number_of_Desks__c")
        expect(account.fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Allow_Merge__c")
        expect(account.fetch('Allow_Merge__c')).to eq "true"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

      rescue Exception => e
        passedLogs = @objRollbar.addLog("[Result  ]  Fail")
        raise e
      end

    end

    it "C2057 : To Check Account Assignment for Record Type Enterprise and Deal Type Strategic.", :'10'=> 'true' do
      begin
        @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['building']  = 'SYD-Martin Place'
        @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['companySize']  = '1200'
        @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['numberOfDesks']  = '27'

        puts "C2057 : To Check Account Assignment for Record Type Enterprise and Deal type Strategic."

        caseInfo = @testRailUtility.getCase('2057')
        #puts caseInfo
        passedLogs = @objRollbar.addLog("[Step    ] booking tour from WebSite", caseInfo['id'])
        emailId = @objAccAssignmentFromLead.createLead()
        expect(@driver.title).to match("Coworking Office Sambhav BKC | WeWork")

        passedLogs = @objRollbar.addLog("[Validate]  Journey should be created")
        journey = @objAccAssignmentFromLead.fetchJourneyDetails(emailId)
        expect(journey).to_not eq nil
        passedLogs = @objRollbar.addLog("[Expected]  Journey created successfully with emailId = #{emailId} \n[Result  ]  Success ")

        passedLogs = @objRollbar.addLog("[Step    ] logging to salesforce")
        expect(@objAccAssignmentFromLead.loginToSalesforce).to_not eq nil

        passedLogs = @objRollbar.addLog("[Step    ] go to details page of created Journey and Clicking on 'Add Opportunity' button")
        expect(@objAccAssignmentFromLead.goToDetailPageJourney(journey.fetch('Id'))).to eq true


        passedLogs = @objRollbar.addLog("[Validate] Checking Add Opportunity when user click on 'Add Opportunity' button")
        expect(@driver.title).to match("Add Opportunity")
        passedLogs = @objRollbar.addLog("[Expected] Manage tour page opened successfully with Page Title= Add Opportunity \n[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Step    ] filling all required fields and Add Opportunity")

        expect(@objAccAssignmentFromLead.addOpportunity()).to eq true

        passedLogs = @objRollbar.addLog("[Step    ] click on Create Account and Merge")
        @objAccAssignmentFromLead.instance_variable_get(:@wait).until {@driver.find_element(:id ,"header43").displayed?}
        expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Merge",nil)).to eq true

        passedLogs = @objRollbar.addLog("[Step    ] checking fields...")

        passedLogs = @objRollbar.addLog("[Step    ] get building details of #{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"]}")
        building = @objAccAssignmentFromLead.fetchBuildingDetails(@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"])
        expect(building).to_not eq nil


        passedLogs = @objRollbar.addLog("[Step    ] get accQueue details")
        accQueue = @objAccAssignmentFromLead.fetAccOwnerQueue(building.fetch('Market__c'),'Enterprise Solutions')

        #accQueue = @objAccAssignmentFromLead.fetAccOwnerQueue('a2V0G000003H8zoUAC','Enterprise Solutions')

        passedLogs = @objRollbar.addLog("[Step    ] get Contact details")
        contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
        #contact = @objAccAssignmentFromLead.fetchContactDetails("john.smith1004201828@example.com")
        expect(contact).to_not eq nil

        passedLogs = @objRollbar.addLog("[Validate] contact:RecordType.Name")
        expect(contact.fetch('RecordType.Name')).to eq "Enterprise Solutions"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] contact:Owner.Id")
        puts accQueue.include? contact.fetch('Owner.Id')
        ownerAssign = accQueue.include? contact.fetch('Owner.Id')
        expect(ownerAssign).to eq true
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] contact:Number_of_Full_Time_Employees__c")
        expect(contact.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] contact:Looking_For_Number_Of_Desk__c")
        expect(contact.fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        puts "get Opportunity details"
        opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact.fetch('Id')}")
        expect(opportunity).to_not eq nil


        passedLogs = @objRollbar.addLog("[Validate] opportunity:RecordType.Name")
        expect(opportunity.fetch('RecordType.Name')).to eq "Enterprise Solutions"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:Deal_Type__c")
        expect(opportunity.fetch('Deal_Type__c')).to eq "Strategic"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:Owner.Id")
        ownerAssign = accQueue.include? opportunity.fetch('Owner.Id')
        expect(ownerAssign).to eq true
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:Quantity__c")
        expect(opportunity.fetch('Quantity__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        puts "get Account Details"
        account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact.fetch('Id')}")

        passedLogs = @objRollbar.addLog("[Validate] account:RecordType.Name")
        expect(account.fetch('RecordType.Name')).to eq "Enterprise Solutions"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Owner.Name")
        ownerAssign = accQueue.include? account.fetch('Owner.Id')
        expect(ownerAssign).to eq true
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Number_of_Full_Time_Employees__c")
        expect(account.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Interested_in_Number_of_Desks__c")
        expect(account.fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Allow_Merge__c")
        expect(account.fetch('Allow_Merge__c')).to eq "true"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

      rescue Exception => e
        passedLogs = @objRollbar.addLog("[Result  ]  Fail")
        raise e
      end

    end
  end

  context "by Add Opportunity with create acc and Don't merge" do

    it "C2058 : To check account assignment for Record Type Consumer and Deal type Transactional.", :'11'=> 'true' do
      begin
        puts "C2058 : To check account assignment for Record Type Consumer and Deal type Transactional."

        @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['companySize']  = '15'
        @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['numberOfDesks']  = '5'
        @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['building']  = 'MUM-BKC'

        caseInfo = @testRailUtility.getCase('2058')
        #puts caseInfo
        passedLogs = @objRollbar.addLog("[Step    ] booking tour from WebSite", caseInfo['id'])
        emailId = @objAccAssignmentFromLead.createLead()
        expect(@driver.title).to match("Coworking Office Sambhav BKC | WeWork")

        passedLogs = @objRollbar.addLog("[Validate]  Journey should be created")
        journey = @objAccAssignmentFromLead.fetchJourneyDetails(emailId)
        expect(journey).to_not eq 'nil'
        passedLogs = @objRollbar.addLog("[Expected]  Journey created successfully with emailId = #{emailId} \n[Result  ]  Success ")

        passedLogs = @objRollbar.addLog("[Step    ] logging to salesforce")
        expect(@objAccAssignmentFromLead.loginToSalesforce).to_not eq nil

        passedLogs = @objRollbar.addLog("[Step    ] go to details page of created Journey and Clicking on 'Add Opportunity' button")
        expect(@objAccAssignmentFromLead.goToDetailPageJourney(journey.fetch('Id'))).to eq true


        passedLogs = @objRollbar.addLog("[Validate] Checking Add Opportunity when user click on 'Add Opportunity' button")
        expect(@driver.title).to match("Add Opportunity")
        passedLogs = @objRollbar.addLog("[Expected] Manage tour page opened successfully with Page Title= Add Opportunity \n[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Step    ] filling all required fields and Add Opportunity")

        expect(@objAccAssignmentFromLead.addOpportunity()).to eq true

        passedLogs = @objRollbar.addLog("[Step    ] click on Create Account and Don't Merge")
        expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Don't Merge",nil)).to eq true

        passedLogs = @objRollbar.addLog("[Step    ] checking fields...")

        passedLogs = @objRollbar.addLog("[Step    ] get building details of #{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"]}")
        building = @objAccAssignmentFromLead.fetchBuildingDetails(@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"])
        expect(building).to_not eq nil

        passedLogs = @objRollbar.addLog("[Step    ] get Contact details")
        contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
        expect(contact).to_not eq nil

        passedLogs = @objRollbar.addLog("[Validate] contact:RecordType.Name")
        expect(contact.fetch('RecordType.Name')).to eq "Consumer"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] contact:Owner.Id")
        expect(contact.fetch('Owner.Id')).to eq "#{building.fetch('Community_Lead__c')}"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] contact:Number_of_Full_Time_Employees__c")
        expect(contact.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] contact:Looking_For_Number_Of_Desk__c")
        expect(contact.fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        puts "get Opportunity details"
        opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact.fetch('Id')}")
        puts opportunity

        passedLogs = @objRollbar.addLog("[Validate] opportunity:RecordType.Name")
        expect(opportunity.fetch('RecordType.Name')).to eq "Consumer"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:Deal_Type__c")
        expect(opportunity.fetch('Deal_Type__c')).to eq "Transactional"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:Owner.Id")
        expect(opportunity.fetch('Owner.Id')).to eq "#{building.fetch('Community_Lead__c')}"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:Quantity__c")
        expect(opportunity.fetch('Quantity__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        puts "get Account Details"
        account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact.fetch('Id')}")

        passedLogs = @objRollbar.addLog("[Validate] account:RecordType.Name")
        expect(account.fetch('RecordType.Name')).to eq "Consumer"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Owner.Id")
        expect(account.fetch('Owner.Id')).to eq "#{building.fetch('Community_Lead__c')}"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Number_of_Full_Time_Employees__c")
        expect(account.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Interested_in_Number_of_Desks__c")
        expect(account.fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Allow_Merge__c")
        expect(account.fetch('Allow_Merge__c')).to eq "false"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

      rescue Exception => e
        passedLogs = @objRollbar.addLog("[Result  ]  Fail")
        raise e
      end

    end

    it "C2049 : To check account assignment for Record Type Consumer and Deal type Relational.", :'22'=> 'true' do
      begin
        puts "C2049 : To check account assignment for Record Type Consumer and Deal type Relational."

        @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['companySize']  = '15'
        @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['numberOfDesks']  = '13'
        @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['building']  = 'MUM-BKC'


        caseInfo = @testRailUtility.getCase('2049')
        passedLogs = @objRollbar.addLog("[Step    ] booking tour from WebSite", caseInfo['id'])
        emailId = @objAccAssignmentFromLead.createLead()
        expect(@driver.title).to match("Coworking Office Sambhav BKC | WeWork")

=begin
        passedLogs = @objRollbar.addLog("[Validate]  Lead should be created")
        leadId = @objAccAssignmentFromLead.fetchLeadDetails(emailId).fetch('Id')
        expect(leadId).to_not eq 'nil'
        passedLogs = @objRollbar.addLog("[Expected]  Lead created successfully with emailId = #{emailId} \n[Result  ]  Success ")
=end

        passedLogs = @objRollbar.addLog("[Validate]  Journey should be created")
        journey = @objAccAssignmentFromLead.fetchJourneyDetails(emailId)
        expect(journey).to_not eq nil
        passedLogs = @objRollbar.addLog("[Expected]  Journey created successfully with emailId = #{emailId} \n[Result  ]  Success ")

        passedLogs = @objRollbar.addLog("[Step    ] logging to salesforce")
        expect(@objAccAssignmentFromLead.loginToSalesforce).to_not eq nil

        passedLogs = @objRollbar.addLog("[Step    ] go to details page of created Journey and Clicking on 'Add Opportunity' button")
        expect(@objAccAssignmentFromLead.goToDetailPageJourney(journey.fetch('Id'))).to eq true


        passedLogs = @objRollbar.addLog("[Validate] Checking Add Opportunity when user click on 'Add Opportunity' button")
        expect(@driver.title).to match("Add Opportunity")
        passedLogs = @objRollbar.addLog("[Expected] Manage tour page opened successfully with Page Title= Add Opportunity \n[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Step    ] filling all required fields and Add Opportunity")

        expect(@objAccAssignmentFromLead.addOpportunity()).to eq true

        passedLogs = @objRollbar.addLog("[Step    ] click on Create Account and Don't Merge")
        expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Don't Merge",nil)).to eq true

        passedLogs = @objRollbar.addLog("[Step    ] checking fields...")

        passedLogs = @objRollbar.addLog("[Step    ] get building details of #{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"]}")
        building = @objAccAssignmentFromLead.fetchBuildingDetails(@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"])
        expect(building).to_not eq nil

        passedLogs = @objRollbar.addLog("[Step    ] get Contact details")
        contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
        expect(contact).to_not eq nil

        passedLogs = @objRollbar.addLog("[Validate] contact:RecordType.Name")
        expect(contact.fetch('RecordType.Name')).to eq "Consumer"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] contact:Owner.Id")
        expect(contact.fetch('Owner.Name')).to eq "#{building.fetch('Cluster_Sales_Lead_Name__c')}"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] contact:Number_of_Full_Time_Employees__c")
        expect(contact.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] contact:Looking_For_Number_Of_Desk__c")
        expect(contact.fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        puts "get Opportunity details"
        opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact.fetch('Id')}")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:RecordType.Name")
        expect(opportunity.fetch('RecordType.Name')).to eq "Consumer"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:Deal_Type__c")
        expect(opportunity.fetch('Deal_Type__c')).to eq "Relational"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:Owner.Id")
        expect(opportunity.fetch('Owner.Name')).to eq "#{building.fetch('Cluster_Sales_Lead_Name__c')}"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:Quantity__c")
        expect(opportunity.fetch('Quantity__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        puts "get Account Details"
        account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact.fetch('Id')}")

        passedLogs = @objRollbar.addLog("[Validate] account:RecordType.Name")
        expect(account.fetch('RecordType.Name')).to eq "Consumer"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Owner.Name")
        expect(account.fetch('Owner.Name')).to eq "#{building.fetch('Cluster_Sales_Lead_Name__c')}"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Number_of_Full_Time_Employees__c")
        expect(account.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Interested_in_Number_of_Desks__c")
        expect(account.fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Allow_Merge__c")
        expect(account.fetch('Allow_Merge__c')).to eq "true"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

      rescue Exception => e
        passedLogs = @objRollbar.addLog("[Result  ]  Fail")
        raise e
      end

    end

    it "C2050 : To check account assignment for Record Type Consumer and Deal type Strategic.", :'33'=> 'true' do
      begin
        puts "C2050 : To check account assignment for Record Type Consumer and Deal type Strategic."

        @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['companySize']  = '15'
        @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['numberOfDesks']  = '25'

        caseInfo = @testRailUtility.getCase('2050')
        passedLogs = @objRollbar.addLog("[Step    ] booking tour from WebSite", caseInfo['id'])
        emailId = @objAccAssignmentFromLead.createLead()
        expect(@driver.title).to match("Coworking Office Sambhav BKC | WeWork")

        passedLogs = @objRollbar.addLog("[Validate]  Journey should be created")
        journey = @objAccAssignmentFromLead.fetchJourneyDetails(emailId)
        expect(journey).to_not eq 'nil'
        passedLogs = @objRollbar.addLog("[Expected]  Journey created successfully with emailId = #{emailId} \n[Result  ]  Success ")

        passedLogs = @objRollbar.addLog("[Step    ] logging to salesforce")
        expect(@objAccAssignmentFromLead.loginToSalesforce).to_not eq nil

        passedLogs = @objRollbar.addLog("[Step    ] go to details page of created Journey and Clicking on 'Add Opportunity' button")
        expect(@objAccAssignmentFromLead.goToDetailPageJourney(journey.fetch('Id'))).to eq true


        passedLogs = @objRollbar.addLog("[Validate] Checking Add Opportunity when user click on 'Add Opportunity' button")
        expect(@driver.title).to match("Add Opportunity")
        passedLogs = @objRollbar.addLog("[Expected] Manage tour page opened successfully with Page Title= Add Opportunity \n[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Step    ] filling all required fields and Add Opportunity")

        expect(@objAccAssignmentFromLead.addOpportunity()).to eq true

        passedLogs = @objRollbar.addLog("[Step    ] click on Create Account and Don't Merge")
        expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Don't Merge",nil)).to eq true

        passedLogs = @objRollbar.addLog("[Step    ] checking fields...")

        passedLogs = @objRollbar.addLog("[Step    ] get building details of #{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"]}")
        building = @objAccAssignmentFromLead.fetchBuildingDetails(@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"])
        expect(building).to_not eq nil

        passedLogs = @objRollbar.addLog("[Step    ] get accQueue details")
        accQueue = @objAccAssignmentFromLead.fetAccOwnerQueue(building.fetch('Market__c'),'Consumer')

        passedLogs = @objRollbar.addLog("[Step    ] get Contact details")
        contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
        expect(contact).to_not eq nil

        passedLogs = @objRollbar.addLog("[Validate] contact:RecordType.Name")
        expect(contact.fetch('RecordType.Name')).to eq "Consumer"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] contact:Owner.Id")
        ownerAssign = accQueue.include? contact.fetch('Owner.Id')
        expect(ownerAssign).to eq true
        #expect(contact.fetch('Owner.Id')).to eq "#{accQueue.fetch('Member__c')}"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] contact:Number_of_Full_Time_Employees__c")
        expect(contact.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] contact:Looking_For_Number_Of_Desk__c")
        expect(contact.fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        puts "get Opportunity details"
        opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact.fetch('Id')}")
        puts opportunity

        passedLogs = @objRollbar.addLog("[Validate] opportunity:RecordType.Name")
        expect(opportunity.fetch('RecordType.Name')).to eq "Consumer"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:Deal_Type__c")
        expect(opportunity.fetch('Deal_Type__c')).to eq "Strategic"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:Owner.Id")
        ownerAssign = accQueue.include? opportunity.fetch('Owner.Id')
        expect(ownerAssign).to eq true
        #expect(opportunity.fetch('Owner.Id')).to eq "#{accQueue.fetch('Member__c')}"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:Quantity__c")
        expect(opportunity.fetch('Quantity__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        puts "get Account Details"
        account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact.fetch('Id')}")
        puts account

        passedLogs = @objRollbar.addLog("[Validate] account:RecordType.Name")
        expect(account.fetch('RecordType.Name')).to eq "Consumer"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Owner.Name")
        ownerAssign = accQueue.include? account.fetch('Owner.Id')
        expect(ownerAssign).to eq true

        #expect(account.fetch('Owner.Id')).to eq "#{accQueue.fetch('Member__c')}"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Number_of_Full_Time_Employees__c")
        expect(account.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Interested_in_Number_of_Desks__c")
        expect(account.fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Allow_Merge__c")
        expect(account.fetch('Allow_Merge__c')).to eq "false"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

      rescue Exception => e
        passedLogs = @objRollbar.addLog("[Result  ]  Fail")
        raise e
      end

    end

    it "C2051 : To check account assignment for Record Type Consumer and Deal type Relational.", :'44'=> 'true'  do
      begin
        @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['companySize']  = '15'
        @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['numberOfDesks']  = '25'

        puts "C2051 : To check account assignment for Record Type Consumer and Deal type Strategic.(Queue is not present in the Account Queue Setting)."

        caseInfo = @testRailUtility.getCase('2051')
        @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['building']  = 'SYD-Martin Place'

        #puts caseInfo
        passedLogs = @objRollbar.addLog("[Step    ] booking tour from WebSite", caseInfo['id'])
        emailId = @objAccAssignmentFromLead.createLead()
        #expect(@driver.title).to match("Coworking Office Sambhav BKC | WeWork")


        passedLogs = @objRollbar.addLog("[Validate]  Journey should be created")
        journey = @objAccAssignmentFromLead.fetchJourneyDetails(emailId)
        expect(journey).to_not eq nil
        passedLogs = @objRollbar.addLog("[Expected]  Journey created successfully with emailId = #{emailId} \n[Result  ]  Success ")

        passedLogs = @objRollbar.addLog("[Step    ] logging to salesforce")
        expect(@objAccAssignmentFromLead.loginToSalesforce).to_not eq nil

        passedLogs = @objRollbar.addLog("[Step    ] go to details page of created Journey and Clicking on 'Add Opportunity' button")
        expect(@objAccAssignmentFromLead.goToDetailPageJourney(journey.fetch('Id'))).to eq true


        passedLogs = @objRollbar.addLog("[Validate] Checking Add Opportunity when user click on 'Add Opportunity' button")
        expect(@driver.title).to match("Add Opportunity")
        passedLogs = @objRollbar.addLog("[Expected] Manage tour page opened successfully with Page Title= Add Opportunity \n[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Step    ] filling all required fields and Add Opportunity")

        expect(@objAccAssignmentFromLead.addOpportunity()).to eq true

        passedLogs = @objRollbar.addLog("[Step    ] click on Create Account and Don't Merge")
        expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Don't Merge",nil)).to eq true

        passedLogs = @objRollbar.addLog("[Step    ] checking fields...")

        passedLogs = @objRollbar.addLog("[Step    ] get building details of #{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"]}")
        building = @objAccAssignmentFromLead.fetchBuildingDetails(@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"])
        expect(building).to_not eq nil

        #passedLogs = @objRollbar.addLog("[Step    ] get accQueue details")
        #accQueue = @objAccAssignmentFromLead.fetAccOwnerQueue(building.fetch('Market__c'),'Consumer')

        passedLogs = @objRollbar.addLog("[Step    ] get Contact details")
        contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
        expect(contact).to_not eq nil

        passedLogs = @objRollbar.addLog("[Validate] contact:RecordType.Name")
        expect(contact.fetch('RecordType.Name')).to eq "Consumer"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] contact:Owner.Id")
        expect(contact.fetch('Owner.Id')).to eq "005F0000003KmbwIAC"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] contact:Number_of_Full_Time_Employees__c")
        expect(contact.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] contact:Looking_For_Number_Of_Desk__c")
        expect(contact.fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        puts "get Opportunity details"
        opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact.fetch('Id')}")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:RecordType.Name")
        expect(opportunity.fetch('RecordType.Name')).to eq "Consumer"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:Deal_Type__c")
        expect(opportunity.fetch('Deal_Type__c')).to eq "Strategic"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:Owner.Id")
        expect(opportunity.fetch('Owner.Id')).to eq "005F0000003KmbwIAC"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:Quantity__c")
        expect(opportunity.fetch('Quantity__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        puts "get Account Details"
        account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact.fetch('Id')}")

        passedLogs = @objRollbar.addLog("[Validate] account:RecordType.Name")
        expect(account.fetch('RecordType.Name')).to eq "Consumer"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Owner.Name")
        expect(account.fetch('Owner.Id')).to eq "005F0000003KmbwIAC"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Number_of_Full_Time_Employees__c")
        expect(account.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Interested_in_Number_of_Desks__c")
        expect(account.fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Allow_Merge__c")
        expect(account.fetch('Allow_Merge__c')).to eq "false"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

      rescue Exception => e
        passedLogs = @objRollbar.addLog("[Result  ]  Fail")
        raise e
      end

    end

    it "C2052 : To Check Account assignment for Record Type Mid-Market and Deal type Transactional.", :'55'=> 'true' do
      begin
        puts "C2052 : To Check Account assignment for Record Type Mid-Market and Deal type Transactional."
        @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['building']  = 'SYD-Martin Place'
        @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['companySize']  = '24'
        @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['numberOfDesks']  = '7'


        caseInfo = @testRailUtility.getCase('2052')
        #puts caseInfo
        passedLogs = @objRollbar.addLog("[Step    ] booking tour from WebSite", caseInfo['id'])
        emailId = @objAccAssignmentFromLead.createLead()
        #expect(@driver.title).to match("Coworking Office Sambhav BKC | WeWork")

        passedLogs = @objRollbar.addLog("[Validate]  Journey should be created")
        journey = @objAccAssignmentFromLead.fetchJourneyDetails(emailId)
        expect(journey).to_not eq nil
        passedLogs = @objRollbar.addLog("[Expected]  Journey created successfully with emailId = #{emailId} \n[Result  ]  Success ")

        passedLogs = @objRollbar.addLog("[Step    ] logging to salesforce")
        expect(@objAccAssignmentFromLead.loginToSalesforce).to_not eq nil

        passedLogs = @objRollbar.addLog("[Step    ] go to details page of created Journey and Clicking on 'Add Opportunity' button")
        expect(@objAccAssignmentFromLead.goToDetailPageJourney(journey.fetch('Id'))).to eq true


        passedLogs = @objRollbar.addLog("[Validate] Checking Add Opportunity when user click on 'Add Opportunity' button")
        expect(@driver.title).to match("Add Opportunity")
        passedLogs = @objRollbar.addLog("[Expected] Manage tour page opened successfully with Page Title= Add Opportunity \n[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Step    ] filling all required fields and Add Opportunity")

        expect(@objAccAssignmentFromLead.addOpportunity()).to eq true

        passedLogs = @objRollbar.addLog("[Step    ] click on Create Account and Don't Merge")
        expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Don't Merge",nil)).to eq true

        passedLogs = @objRollbar.addLog("[Step    ] checking fields...")

        passedLogs = @objRollbar.addLog("[Step    ] get building details of #{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"]}")
        building = @objAccAssignmentFromLead.fetchBuildingDetails(@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"])
        expect(building).to_not eq nil

        passedLogs = @objRollbar.addLog("[Step    ] get Contact details")
        contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
        expect(contact).to_not eq nil

        passedLogs = @objRollbar.addLog("[Validate] contact:RecordType.Name")
        expect(contact.fetch('RecordType.Name')).to eq "Mid Market"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] contact:Owner.Id")
        expect(contact.fetch('Owner.Id')).to eq "#{building.fetch('Community_Lead__c')}"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] contact:Number_of_Full_Time_Employees__c")
        expect(contact.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] contact:Looking_For_Number_Of_Desk__c")
        expect(contact.fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        puts "get Opportunity details"
        opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact.fetch('Id')}")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:RecordType.Name")
        expect(opportunity.fetch('RecordType.Name')).to eq "Mid Market"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:Deal_Type__c")
        expect(opportunity.fetch('Deal_Type__c')).to eq "Transactional"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:Owner.Id")
        expect(opportunity.fetch('Owner.Id')).to eq "#{building.fetch('Community_Lead__c')}"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:Quantity__c")
        expect(opportunity.fetch('Quantity__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        puts "get Account Details"
        account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact.fetch('Id')}")

        passedLogs = @objRollbar.addLog("[Validate] account:RecordType.Name")
        expect(account.fetch('RecordType.Name')).to eq "Mid Market"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Owner.Id")
        expect(account.fetch('Owner.Id')).to eq "#{building.fetch('Community_Lead__c')}"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Number_of_Full_Time_Employees__c")
        expect(account.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Interested_in_Number_of_Desks__c")
        expect(account.fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Allow_Merge__c")
        expect(account.fetch('Allow_Merge__c')).to eq "false"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

      rescue Exception => e
        passedLogs = @objRollbar.addLog("[Result  ]  Fail")
        raise e
      end

    end

    it "C2053 : To Check Account Assignment for Record type Mid-Market and Deal type Relational.", :'66'=> 'true' do
      begin
        puts "C2053 : To Check Account Assignment for Record type Mid-Market and Deal type Relational."

        caseInfo = @testRailUtility.getCase('2053')
        #puts caseInfo
        @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['building']  = 'SYD-Martin Place'
        @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['companySize']  = '24'
        @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['numberOfDesks']  = '15'

        passedLogs = @objRollbar.addLog("[Step    ] booking tour from WebSite", caseInfo['id'])
        emailId = @objAccAssignmentFromLead.createLead()
        expect(@driver.title).to match("Coworking Office Sambhav BKC | WeWork")

        passedLogs = @objRollbar.addLog("[Validate]  Journey should be created")
        journey = @objAccAssignmentFromLead.fetchJourneyDetails(emailId)
        expect(journey).to_not eq nil
        passedLogs = @objRollbar.addLog("[Expected]  Journey created successfully with emailId = #{emailId} \n[Result  ]  Success ")

        passedLogs = @objRollbar.addLog("[Step    ] logging to salesforce")
        expect(@objAccAssignmentFromLead.loginToSalesforce).to_not eq nil

        passedLogs = @objRollbar.addLog("[Step    ] go to details page of created Journey and Clicking on 'Add Opportunity' button")
        expect(@objAccAssignmentFromLead.goToDetailPageJourney(journey.fetch('Id'))).to eq true


        passedLogs = @objRollbar.addLog("[Validate] Checking Add Opportunity when user click on 'Add Opportunity' button")
        expect(@driver.title).to match("Add Opportunity")
        passedLogs = @objRollbar.addLog("[Expected] Manage tour page opened successfully with Page Title= Add Opportunity \n[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Step    ] filling all required fields and Add Opportunity")

        expect(@objAccAssignmentFromLead.addOpportunity()).to eq true

        passedLogs = @objRollbar.addLog("[Step    ] click on Create Account and Don't Merge")
        expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Don't Merge",nil)).to eq true

        passedLogs = @objRollbar.addLog("[Step    ] checking fields...")

        passedLogs = @objRollbar.addLog("[Step    ] get building details of #{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"]}")
        building = @objAccAssignmentFromLead.fetchBuildingDetails(@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"])
        expect(building).to_not eq nil

        passedLogs = @objRollbar.addLog("[Step    ] get Contact details")
        contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
        expect(contact).to_not eq nil

        passedLogs = @objRollbar.addLog("[Validate] contact:RecordType.Name")
        expect(contact.fetch('RecordType.Name')).to eq "Mid Market"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] contact:Owner.Id")
        expect(contact.fetch('Owner.Name')).to eq "#{building.fetch('Cluster_Sales_Lead_Name__c')}"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] contact:Number_of_Full_Time_Employees__c")
        expect(contact.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] contact:Looking_For_Number_Of_Desk__c")
        expect(contact.fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        puts "get Opportunity details"
        opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact.fetch('Id')}")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:RecordType.Name")
        expect(opportunity.fetch('RecordType.Name')).to eq "Mid Market"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:Deal_Type__c")
        expect(opportunity.fetch('Deal_Type__c')).to eq "Relational"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:Owner.Id")
        expect(opportunity.fetch('Owner.Name')).to eq "#{building.fetch('Cluster_Sales_Lead_Name__c')}"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:Quantity__c")
        expect(opportunity.fetch('Quantity__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        puts "get Account Details"
        account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact.fetch('Id')}")

        passedLogs = @objRollbar.addLog("[Validate] account:RecordType.Name")
        expect(account.fetch('RecordType.Name')).to eq "Mid Market"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Owner.Name")
        expect(account.fetch('Owner.Name')).to eq "#{building.fetch('Cluster_Sales_Lead_Name__c')}"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Number_of_Full_Time_Employees__c")
        expect(account.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Interested_in_Number_of_Desks__c")
        expect(account.fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Allow_Merge__c")
        expect(account.fetch('Allow_Merge__c')).to eq "false"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

      rescue Exception => e
        passedLogs = @objRollbar.addLog("[Result  ]  Fail")
        raise e
      end

    end

    it "C2054 : To Check Account Assignment from Record type Mid-Market and Deal Type Strategic.", :'77'=> 'true' do
      begin
        puts "C2054 : To check account assignment for Record Type Consumer and Deal type Relational."

        @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['building']  = 'SYD-Martin Place'
        @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['companySize']  = '24'
        @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['numberOfDesks']  = '27'

        caseInfo = @testRailUtility.getCase('2054')
        #puts caseInfo
        passedLogs = @objRollbar.addLog("[Step    ] booking tour from WebSite", caseInfo['id'])
        emailId = @objAccAssignmentFromLead.createLead()
        expect(@driver.title).to match("Coworking Office Sambhav BKC | WeWork")

        passedLogs = @objRollbar.addLog("[Validate]  Journey should be created")
        journey = @objAccAssignmentFromLead.fetchJourneyDetails(emailId)
        expect(journey).to_not eq nil
        passedLogs = @objRollbar.addLog("[Expected]  Journey created successfully with emailId = #{emailId} \n[Result  ]  Success ")

        passedLogs = @objRollbar.addLog("[Step    ] logging to salesforce")
        expect(@objAccAssignmentFromLead.loginToSalesforce).to_not eq nil

        passedLogs = @objRollbar.addLog("[Step    ] go to details page of created Journey and Clicking on 'Add Opportunity' button")
        expect(@objAccAssignmentFromLead.goToDetailPageJourney(journey.fetch('Id'))).to eq true


        passedLogs = @objRollbar.addLog("[Validate] Checking Add Opportunity when user click on 'Add Opportunity' button")
        expect(@driver.title).to match("Add Opportunity")
        passedLogs = @objRollbar.addLog("[Expected] Manage tour page opened successfully with Page Title= Add Opportunity \n[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Step    ] filling all required fields and Add Opportunity")

        expect(@objAccAssignmentFromLead.addOpportunity()).to eq true

        passedLogs = @objRollbar.addLog("[Step    ] click on Create Account and Don't Merge")
        expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Don't Merge",nil)).to eq true

        passedLogs = @objRollbar.addLog("[Step    ] checking fields...")

        passedLogs = @objRollbar.addLog("[Step    ] get building details of #{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"]}")
        building = @objAccAssignmentFromLead.fetchBuildingDetails(@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"])
        expect(building).to_not eq nil

        passedLogs = @objRollbar.addLog("[Step    ] get accQueue details")

        accQueue = @objAccAssignmentFromLead.fetAccOwnerQueue(building.fetch('Market__c'),'Mid Market')

        passedLogs = @objRollbar.addLog("[Step    ] get Contact details")
        contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
        expect(contact).to_not eq nil

        passedLogs = @objRollbar.addLog("[Validate] contact:RecordType.Name")
        expect(contact.fetch('RecordType.Name')).to eq "Mid Market"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] contact:Owner.Id")

        puts accQueue.include? contact.fetch('Owner.Id')
        ownerAssign = accQueue.include? contact.fetch('Owner.Id')
        expect(ownerAssign).to eq true

        #expect(contact.fetch('Owner.Id')).to eq "#{accQueue.fetch('Member__c')}"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] contact:Number_of_Full_Time_Employees__c")
        expect(contact.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] contact:Looking_For_Number_Of_Desk__c")
        expect(contact.fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        puts "get Opportunity details"
        opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact.fetch('Id')}")
        puts opportunity

        passedLogs = @objRollbar.addLog("[Validate] opportunity:RecordType.Name")
        expect(opportunity.fetch('RecordType.Name')).to eq "Mid Market"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:Deal_Type__c")
        expect(opportunity.fetch('Deal_Type__c')).to eq "Strategic"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:Owner.Id")
        ownerAssign = accQueue.include? opportunity.fetch('Owner.Id')
        expect(ownerAssign).to eq true

        #expect(opportunity.fetch('Owner.Id')).to eq "#{accQueue.fetch('Member__c')}"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:Quantity__c")
        expect(opportunity.fetch('Quantity__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        puts "get Account Details"
        account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact.fetch('Id')}")
        puts account

        passedLogs = @objRollbar.addLog("[Validate] account:RecordType.Name")
        expect(account.fetch('RecordType.Name')).to eq "Mid Market"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Owner.Name")
        ownerAssign = accQueue.include? account.fetch('Owner.Id')
        expect(ownerAssign).to eq true
        #expect(account.fetch('Owner.Id')).to eq "#{accQueue.fetch('Member__c')}"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Number_of_Full_Time_Employees__c")
        expect(account.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Interested_in_Number_of_Desks__c")
        expect(account.fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Allow_Merge__c")
        expect(account.fetch('Allow_Merge__c')).to eq "false"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

      rescue Exception => e
        passedLogs = @objRollbar.addLog("[Result  ]  Fail")
        raise e
      end

    end

    it "C2055 : To Check Account Assignment for Record Type Enterprise and Deal type Transactional.", :'88'=> 'true' do
      begin
        puts "C2055 : To Check Account Assignment for Record Type Enterprise and Deal type Transactional."

        @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['building']  = 'MEL-Bourke Street'
        @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['companySize']  = '1200'
        @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['numberOfDesks']  = '7'

        caseInfo = @testRailUtility.getCase('2055')
        #puts caseInfo
        passedLogs = @objRollbar.addLog("[Step    ] booking tour from WebSite", caseInfo['id'])
        emailId = @objAccAssignmentFromLead.createLead()
        expect(@driver.title).to match("Coworking Office Sambhav BKC | WeWork")

        passedLogs = @objRollbar.addLog("[Validate]  Journey should be created")
        journey = @objAccAssignmentFromLead.fetchJourneyDetails(emailId)
        expect(journey).to_not eq nil
        passedLogs = @objRollbar.addLog("[Expected]  Journey created successfully with emailId = #{emailId} \n[Result  ]  Success ")

        passedLogs = @objRollbar.addLog("[Step    ] logging to salesforce")
        expect(@objAccAssignmentFromLead.loginToSalesforce).to_not eq nil

        passedLogs = @objRollbar.addLog("[Step    ] go to details page of created Journey and Clicking on 'Add Opportunity' button")
        expect(@objAccAssignmentFromLead.goToDetailPageJourney(journey.fetch('Id'))).to eq true


        passedLogs = @objRollbar.addLog("[Validate] Checking Add Opportunity when user click on 'Add Opportunity' button")
        expect(@driver.title).to match("Add Opportunity")
        passedLogs = @objRollbar.addLog("[Expected] Manage tour page opened successfully with Page Title= Add Opportunity \n[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Step    ] filling all required fields and Add Opportunity")

        expect(@objAccAssignmentFromLead.addOpportunity()).to eq true

        passedLogs = @objRollbar.addLog("[Step    ] click on Create Account and Don't Merge")
        expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Don't Merge",nil)).to eq true

        passedLogs = @objRollbar.addLog("[Step    ] checking fields...")

        passedLogs = @objRollbar.addLog("[Step    ] get building details of #{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"]}")
        building = @objAccAssignmentFromLead.fetchBuildingDetails(@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"])
        expect(building).to_not eq nil

        passedLogs = @objRollbar.addLog("[Step    ] get accQueue details")
        accQueue = @objAccAssignmentFromLead.fetAccOwnerQueue(building.fetch('Market__c'),'Enterprise Solutions')

        passedLogs = @objRollbar.addLog("[Step    ] get Contact details")
        contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
        expect(contact).to_not eq nil

        passedLogs = @objRollbar.addLog("[Validate] contact:RecordType.Name")
        expect(contact.fetch('RecordType.Name')).to eq "Enterprise Solutions"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] contact:Owner.Id")

        ownerAssign = accQueue.include? contact.fetch('Owner.Id')
        expect(ownerAssign).to eq true
        #expect(contact.fetch('Owner.Id')).to eq "#{accQueue.fetch('Member__c')}"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] contact:Number_of_Full_Time_Employees__c")
        expect(contact.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] contact:Looking_For_Number_Of_Desk__c")
        expect(contact.fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        puts "get Opportunity details"
        opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact.fetch('Id')}")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:RecordType.Name")
        expect(opportunity.fetch('RecordType.Name')).to eq "Enterprise Solutions"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:Deal_Type__c")
        expect(opportunity.fetch('Deal_Type__c')).to eq "Transactional"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:Owner.Id")
        ownerAssign = accQueue.include? opportunity.fetch('Owner.Id')
        expect(ownerAssign).to eq true
        #expect(opportunity.fetch('Owner.Id')).to eq "#{accQueue.fetch('Member__c')}"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:Quantity__c")
        expect(opportunity.fetch('Quantity__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        puts "get Account Details"
        account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact.fetch('Id')}")

        passedLogs = @objRollbar.addLog("[Validate] account:RecordType.Name")
        expect(account.fetch('RecordType.Name')).to eq "Enterprise Solutions"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Owner.Name")
        ownerAssign = accQueue.include? account.fetch('Owner.Id')
        expect(ownerAssign).to eq true

        #expect(account.fetch('Owner.Id')).to eq "#{accQueue.fetch('Member__c')}"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Number_of_Full_Time_Employees__c")
        expect(account.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Interested_in_Number_of_Desks__c")
        expect(account.fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Allow_Merge__c")
        expect(account.fetch('Allow_Merge__c')).to eq "false"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

      rescue Exception => e
        passedLogs = @objRollbar.addLog("[Result  ]  Fail")
        raise e
      end

    end

    it "C2056 : To Check Account Assignment for Record Type Enterprise and Deal type Relational.", :'99'=> 'true' do
      begin
        @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['building']  = 'SYD-Martin Place'
        @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['companySize']  = '1200'
        @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['numberOfDesks']  = '15'

        puts "C2056 : To Check Account Assignment for Record Type Enterprise and Deal type Relational."

        caseInfo = @testRailUtility.getCase('2056')
        #puts caseInfo
        passedLogs = @objRollbar.addLog("[Step    ] booking tour from WebSite", caseInfo['id'])
        emailId = @objAccAssignmentFromLead.createLead()
        expect(@driver.title).to match("Coworking Office Sambhav BKC | WeWork")

        passedLogs = @objRollbar.addLog("[Validate]  Journey should be created")
        journey = @objAccAssignmentFromLead.fetchJourneyDetails(emailId)
        expect(journey).to_not eq nil
        passedLogs = @objRollbar.addLog("[Expected]  Journey created successfully with emailId = #{emailId} \n[Result  ]  Success ")

        passedLogs = @objRollbar.addLog("[Step    ] logging to salesforce")
        expect(@objAccAssignmentFromLead.loginToSalesforce).to_not eq nil

        passedLogs = @objRollbar.addLog("[Step    ] go to details page of created Journey and Clicking on 'Add Opportunity' button")
        expect(@objAccAssignmentFromLead.goToDetailPageJourney(journey.fetch('Id'))).to eq true


        passedLogs = @objRollbar.addLog("[Validate] Checking Add Opportunity when user click on 'Add Opportunity' button")
        expect(@driver.title).to match("Add Opportunity")
        passedLogs = @objRollbar.addLog("[Expected] Manage tour page opened successfully with Page Title= Add Opportunity \n[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Step    ] filling all required fields and Add Opportunity")

        expect(@objAccAssignmentFromLead.addOpportunity()).to eq true

        passedLogs = @objRollbar.addLog("[Step    ] click on Create Account and Don't Merge")
        expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Don't Merge",nil)).to eq true

        passedLogs = @objRollbar.addLog("[Step    ] checking fields...")

        passedLogs = @objRollbar.addLog("[Step    ] get building details of #{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"]}")
        building = @objAccAssignmentFromLead.fetchBuildingDetails(@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"])
        expect(building).to_not eq nil


        passedLogs = @objRollbar.addLog("[Step    ] get accQueue details")
        accQueue = @objAccAssignmentFromLead.fetAccOwnerQueue(building.fetch('Market__c'),'Enterprise Solutions')

        #accQueue = @objAccAssignmentFromLead.fetAccOwnerQueue('a2V0G000003H8zoUAC','Enterprise Solutions')

        passedLogs = @objRollbar.addLog("[Step    ] get Contact details")
        contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
        #contact = @objAccAssignmentFromLead.fetchContactDetails("john.smith1004201828@example.com")
        expect(contact).to_not eq nil

        passedLogs = @objRollbar.addLog("[Validate] contact:RecordType.Name")
        expect(contact.fetch('RecordType.Name')).to eq "Enterprise Solutions"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] contact:Owner.Id")
        puts accQueue.include? contact.fetch('Owner.Id')
        ownerAssign = accQueue.include? contact.fetch('Owner.Id')
        expect(ownerAssign).to eq true
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] contact:Number_of_Full_Time_Employees__c")
        expect(contact.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] contact:Looking_For_Number_Of_Desk__c")
        expect(contact.fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        puts "get Opportunity details"
        opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact.fetch('Id')}")
        expect(opportunity).to_not eq nil


        passedLogs = @objRollbar.addLog("[Validate] opportunity:RecordType.Name")
        expect(opportunity.fetch('RecordType.Name')).to eq "Enterprise Solutions"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:Deal_Type__c")
        expect(opportunity.fetch('Deal_Type__c')).to eq "Relational"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:Owner.Id")
        ownerAssign = accQueue.include? opportunity.fetch('Owner.Id')
        expect(ownerAssign).to eq true
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:Quantity__c")
        expect(opportunity.fetch('Quantity__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        puts "get Account Details"
        account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact.fetch('Id')}")

        passedLogs = @objRollbar.addLog("[Validate] account:RecordType.Name")
        expect(account.fetch('RecordType.Name')).to eq "Enterprise Solutions"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Owner.Name")
        ownerAssign = accQueue.include? account.fetch('Owner.Id')
        expect(ownerAssign).to eq true
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Number_of_Full_Time_Employees__c")
        expect(account.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Interested_in_Number_of_Desks__c")
        expect(account.fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Allow_Merge__c")
        expect(account.fetch('Allow_Merge__c')).to eq "false"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

      rescue Exception => e
        passedLogs = @objRollbar.addLog("[Result  ]  Fail")
        raise e
      end

    end

    it "C2057 : To Check Account Assignment for Record Type Enterprise and Deal Type Strategic.", :'1010'=> 'true' do
      begin
        @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['building']  = 'SYD-Martin Place'
        @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['companySize']  = '1200'
        @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['numberOfDesks']  = '27'

        puts "C2057 : To Check Account Assignment for Record Type Enterprise and Deal type Strategic."

        caseInfo = @testRailUtility.getCase('2057')
        #puts caseInfo
        passedLogs = @objRollbar.addLog("[Step    ] booking tour from WebSite", caseInfo['id'])
        emailId = @objAccAssignmentFromLead.createLead()
        expect(@driver.title).to match("Coworking Office Sambhav BKC | WeWork")

        passedLogs = @objRollbar.addLog("[Validate]  Journey should be created")
        journey = @objAccAssignmentFromLead.fetchJourneyDetails(emailId)
        expect(journey).to_not eq nil
        passedLogs = @objRollbar.addLog("[Expected]  Journey created successfully with emailId = #{emailId} \n[Result  ]  Success ")

        passedLogs = @objRollbar.addLog("[Step    ] logging to salesforce")
        expect(@objAccAssignmentFromLead.loginToSalesforce).to_not eq nil

        passedLogs = @objRollbar.addLog("[Step    ] go to details page of created Journey and Clicking on 'Add Opportunity' button")
        expect(@objAccAssignmentFromLead.goToDetailPageJourney(journey.fetch('Id'))).to eq true


        passedLogs = @objRollbar.addLog("[Validate] Checking Add Opportunity when user click on 'Add Opportunity' button")
        expect(@driver.title).to match("Add Opportunity")
        passedLogs = @objRollbar.addLog("[Expected] Manage tour page opened successfully with Page Title= Add Opportunity \n[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Step    ] filling all required fields and Add Opportunity")

        expect(@objAccAssignmentFromLead.addOpportunity()).to eq true

        passedLogs = @objRollbar.addLog("[Step    ] click on Create Account and Don't Merge")
        expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Don't Merge",nil)).to eq true

        passedLogs = @objRollbar.addLog("[Step    ] checking fields...")

        passedLogs = @objRollbar.addLog("[Step    ] get building details of #{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"]}")
        building = @objAccAssignmentFromLead.fetchBuildingDetails(@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"])
        expect(building).to_not eq nil


        passedLogs = @objRollbar.addLog("[Step    ] get accQueue details")
        accQueue = @objAccAssignmentFromLead.fetAccOwnerQueue(building.fetch('Market__c'),'Enterprise Solutions')

        #accQueue = @objAccAssignmentFromLead.fetAccOwnerQueue('a2V0G000003H8zoUAC','Enterprise Solutions')

        passedLogs = @objRollbar.addLog("[Step    ] get Contact details")
        contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
        #contact = @objAccAssignmentFromLead.fetchContactDetails("john.smith1004201828@example.com")
        expect(contact).to_not eq nil

        passedLogs = @objRollbar.addLog("[Validate] contact:RecordType.Name")
        expect(contact.fetch('RecordType.Name')).to eq "Enterprise Solutions"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] contact:Owner.Id")
        puts accQueue.include? contact.fetch('Owner.Id')
        ownerAssign = accQueue.include? contact.fetch('Owner.Id')
        expect(ownerAssign).to eq true
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] contact:Number_of_Full_Time_Employees__c")
        expect(contact.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] contact:Looking_For_Number_Of_Desk__c")
        expect(contact.fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        puts "get Opportunity details"
        opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact.fetch('Id')}")
        expect(opportunity).to_not eq nil


        passedLogs = @objRollbar.addLog("[Validate] opportunity:RecordType.Name")
        expect(opportunity.fetch('RecordType.Name')).to eq "Enterprise Solutions"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:Deal_Type__c")
        expect(opportunity.fetch('Deal_Type__c')).to eq "Strategic"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:Owner.Id")
        ownerAssign = accQueue.include? opportunity.fetch('Owner.Id')
        expect(ownerAssign).to eq true
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:Quantity__c")
        expect(opportunity.fetch('Quantity__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        puts "get Account Details"
        account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact.fetch('Id')}")

        passedLogs = @objRollbar.addLog("[Validate] account:RecordType.Name")
        expect(account.fetch('RecordType.Name')).to eq "Enterprise Solutions"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Owner.Name")
        ownerAssign = accQueue.include? account.fetch('Owner.Id')
        expect(ownerAssign).to eq true
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Number_of_Full_Time_Employees__c")
        expect(account.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Interested_in_Number_of_Desks__c")
        expect(account.fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Allow_Merge__c")
        expect(account.fetch('Allow_Merge__c')).to eq "false"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

      rescue Exception => e
        passedLogs = @objRollbar.addLog("[Result  ]  Fail")
        raise e
      end

    end
  end

  context "by Account Reassignment with Create Account and Dont Merge" do

    it "C2076 : To check the Account reassignment for Record type changes from Consumer to Mid-Market.", :'2076'=> 'true' do
      begin
        puts "C2076 : To check account assignment for Record Type Consumer and Deal type Transactional."

        @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['companySize']  = '15'
        @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['numberOfDesks']  = '5'

        caseInfo = @testRailUtility.getCase('2076')
        #puts caseInfo
        passedLogs = @objRollbar.addLog("[Step    ] booking tour from WebSite", caseInfo['id'])
        emailId = @objAccAssignmentFromLead.createLead()
        expect(@driver.title).to match("Coworking Office Sambhav BKC | WeWork")

        passedLogs = @objRollbar.addLog("[Validate]  Lead should be created")
        leadId = @objAccAssignmentFromLead.fetchLeadDetails(emailId).fetch('Id')
        expect(leadId).to_not eq 'nil'
        passedLogs = @objRollbar.addLog("[Expected]  Lead created successfully with emailId = #{emailId} \n[Result  ]  Success ")

=begin
            #puts "lead created from web with emailId = #{emailId}"


            Restforce.log = true
            client = Restforce.new(username: 'monika.pingale@wework.com.qaauto',
                                   password: 'monikaPingale@123',
                                   host: 'test.salesforce.com',
                                   #security_token: 'l3WwT1P1u0BaUkLw8ocH5Wzp',
                                   client_id: '3MVG9PE4xB9wtoY9IbhNtYSuAVOegE_yR6h8s4fwIITYduuN1V8Tt84iUykgOM_X3lj7md_cCbNBlsN6D6LSc',
                                   client_secret: '3006740022073476903',
                                   authentication_callback: Proc.new { |x| puts x },
                                   api_version: '41.0',
                                   request_headers: { 'sforce-auto-assign' => 'FALSE' })


            #puts client
            #accounts = client.query_all("select Id, Name from Lead") #where emailId = #{emailId}")
            #puts accounts.map(&:Id)
            #puts accounts.class


            #client.picklist_values('Account', 'Type')
            #client.user_info
            #client.describe_layouts('Account', '0010x00000FFB8c')


            client.create!('PushTopic',
                           ApiVersion: '41.0',
                           Name: 'AllLeads6',
                           Description: 'All lead records',
                           NotifyForOperationCreate: 'true',
                           NotifyForOperationUpdate: 'true',
                           #NotifyForOperations: 'All',
                           NotifyForFields: 'All',
                           Query: 'select Id,name from opportunity')



            client.create!('PushTopic',
                           ApiVersion: '41.0',
                           Name: 'PushTopic_Lead',
                           Description: 'All lead records',
                           NotifyForOperationCreate: 'true',
                           NotifyForOperationUpdate: 'true',
                           #NotifyForOperations: 'All',
                           NotifyForFields: 'All',
                           Query: 'select Id,email from Lead')


              EM.run do
                # Subscribe to the PushTopic.
                client.subscribe 'AllLeads6' do |message|
                  puts message.inspect
                  raise StopIteration , message.inspect
                end
              end
            rescue Exception => StopIteration
              puts "catching event in pushtopic"
              puts StopIteration
              puts StopIteration['event']['type']
              puts StopIteration['sobject']['email']
            end
=end


        passedLogs = @objRollbar.addLog("[Step    ] logging to salesforce")
        expect(@objAccAssignmentFromLead.loginToSalesforce).to_not eq nil

        passedLogs = @objRollbar.addLog("[Step    ] go to details page of created lead and Clicking on 'Manage/book Tour' button")
        expect(@objAccAssignmentFromLead.goToDetailPage(leadId)).to eq true


        passedLogs = @objRollbar.addLog("[Validate] Checking Manage Tour page when user click on 'Manage/book tour' button")
        expect(@driver.title).to match("Manage Tours")
        passedLogs = @objRollbar.addLog("[Expected] Manage tour page opened successfully with Page Title= Manage Tours \n[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Step    ] filling all required fields and booked a tour")

        expect(@objAccAssignmentFromLead.bookTour(0,true)).to eq true

        passedLogs = @objRollbar.addLog("[Step    ] click on Create Account and Don't Merge")
        expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Don't Merge",nil)).to eq true

        passedLogs = @objRollbar.addLog("[Step    ] checking fields...")

        passedLogs = @objRollbar.addLog("[Step    ] get building details of #{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"]}")
        building = @objAccAssignmentFromLead.fetchBuildingDetails(@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"])
        expect(building).to_not eq nil

        passedLogs = @objRollbar.addLog("[Step    ] get Contact details")
        contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
        expect(contact).to_not eq nil

        passedLogs = @objRollbar.addLog("[Validate] contact:RecordType.Name")
        expect(contact.fetch('RecordType.Name')).to eq "Consumer"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] contact:Owner.Id")
        expect(contact.fetch('Owner.Id')).to eq "#{building.fetch('Community_Lead__c')}"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] contact:Number_of_Full_Time_Employees__c")
        expect(contact.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] contact:Looking_For_Number_Of_Desk__c")
        expect(contact.fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")


        puts "get Account Details"
        account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact.fetch('Id')}")

        passedLogs = @objRollbar.addLog("[Validate] account:RecordType.Name")
        expect(account.fetch('RecordType.Name')).to eq "Consumer"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Owner.Id")
        expect(account.fetch('Owner.Id')).to eq "#{building.fetch('Community_Lead__c')}"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Number_of_Full_Time_Employees__c")
        expect(account.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Interested_in_Number_of_Desks__c")
        expect(account.fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        puts "get Opportunity details"
        opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact.fetch('Id')}")
        puts opportunity

        passedLogs = @objRollbar.addLog("[Validate] opportunity:RecordType.Name")
        expect(opportunity.fetch('RecordType.Name')).to eq "Consumer"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:Deal_Type__c")
        expect(opportunity.fetch('Deal_Type__c')).to eq "Transactional"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:Owner.Id")
        expect(opportunity.fetch('Owner.Id')).to eq "#{building.fetch('Community_Lead__c')}"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:Quantity__c")
        expect(opportunity.fetch('Quantity__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        expect(@objAccAssignmentFromLead.updateProductAndOpp("#{opportunity.fetch('Id')}",'19',account.fetch('Id'),'Mid Market')).to eq true

        passedLogs = @objRollbar.addLog("[Step    ] get Contact details")
        contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
        expect(contact).to_not eq nil

        sleep(20)

        passedLogs = @objRollbar.addLog("[Validate] contact:RecordType.Name")
        expect(contact.fetch('RecordType.Name')).to eq "Mid Market"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] contact:Owner.Id")
        expect(contact.fetch('Owner.Name')).to eq "#{building.fetch('Cluster_Sales_Lead_Name__c')}"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        puts "get Account Details"
        account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact.fetch('Id')}")

        passedLogs = @objRollbar.addLog("[Validate] account:RecordType.Name")
        expect(account.fetch('RecordType.Name')).to eq "Mid Market"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Owner.Id")
        expect(account.fetch('Owner.Name')).to eq "#{building.fetch('Cluster_Sales_Lead_Name__c')}"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        puts "get Opportunity details"
        opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact.fetch('Id')}")
        puts opportunity

        passedLogs = @objRollbar.addLog("[Validate] opportunity:RecordType.Name")
        expect(opportunity.fetch('RecordType.Name')).to eq "Mid Market"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:Deal_Type__c")
        expect(opportunity.fetch('Deal_Type__c')).to eq "Relational"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:Owner.Id")
        expect(opportunity.fetch('Owner.Name')).to eq "#{building.fetch('Cluster_Sales_Lead_Name__c')}"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

      rescue Exception => e
        passedLogs = @objRollbar.addLog("[Result  ]  Fail")
        raise e
      end

    end

    it "C2077 : To check the Account reassignment for Record Type changes from Consumer to Enterprise.", :'2077'=> 'true' do
      begin
        puts "C2076 : To check account assignment for Record Type Consumer and Deal type Transactional."

        @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['companySize']  = '15'
        @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['numberOfDesks']  = '5'
        @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["UpdatedAccount"][0]["Number_of_Full_Time_Employees__c"] = '1200'

        caseInfo = @testRailUtility.getCase('2076')
        #puts caseInfo
        passedLogs = @objRollbar.addLog("[Step    ] booking tour from WebSite", caseInfo['id'])
        emailId = @objAccAssignmentFromLead.createLead()
        expect(@driver.title).to match("Coworking Office Sambhav BKC | WeWork")

        passedLogs = @objRollbar.addLog("[Validate]  Lead should be created")
        leadId = @objAccAssignmentFromLead.fetchLeadDetails(emailId).fetch('Id')
        expect(leadId).to_not eq 'nil'
        passedLogs = @objRollbar.addLog("[Expected]  Lead created successfully with emailId = #{emailId} \n[Result  ]  Success ")

        passedLogs = @objRollbar.addLog("[Step    ] logging to salesforce")
        expect(@objAccAssignmentFromLead.loginToSalesforce).to_not eq nil

        passedLogs = @objRollbar.addLog("[Step    ] go to details page of created lead and Clicking on 'Manage/book Tour' button")
        expect(@objAccAssignmentFromLead.goToDetailPage(leadId)).to eq true


        passedLogs = @objRollbar.addLog("[Validate] Checking Manage Tour page when user click on 'Manage/book tour' button")
        expect(@driver.title).to match("Manage Tours")
        passedLogs = @objRollbar.addLog("[Expected] Manage tour page opened successfully with Page Title= Manage Tours \n[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Step    ] filling all required fields and booked a tour")

        expect(@objAccAssignmentFromLead.bookTour(0,true)).to eq true

        passedLogs = @objRollbar.addLog("[Step    ] click on Create Account and Don't Merge")
        expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Don't Merge",nil)).to eq true

        passedLogs = @objRollbar.addLog("[Step    ] checking fields...")

        passedLogs = @objRollbar.addLog("[Step    ] get building details of #{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"]}")
        building = @objAccAssignmentFromLead.fetchBuildingDetails(@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"])
        expect(building).to_not eq nil

        passedLogs = @objRollbar.addLog("[Step    ] get accQueue details")
        accQueue = @objAccAssignmentFromLead.fetAccOwnerQueue(building.fetch('Market__c'),'Enterprise Solutions')

        passedLogs = @objRollbar.addLog("[Step    ] get Contact details")
        contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
        expect(contact).to_not eq nil

        passedLogs = @objRollbar.addLog("[Validate] contact:RecordType.Name")
        expect(contact.fetch('RecordType.Name')).to eq "Consumer"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] contact:Owner.Id")
        expect(contact.fetch('Owner.Id')).to eq "#{building.fetch('Community_Lead__c')}"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] contact:Number_of_Full_Time_Employees__c")
        expect(contact.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] contact:Looking_For_Number_Of_Desk__c")
        expect(contact.fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")


        puts "get Account Details"
        account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact.fetch('Id')}")

        passedLogs = @objRollbar.addLog("[Validate] account:RecordType.Name")
        expect(account.fetch('RecordType.Name')).to eq "Consumer"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Owner.Id")
        expect(account.fetch('Owner.Id')).to eq "#{building.fetch('Community_Lead__c')}"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Number_of_Full_Time_Employees__c")
        expect(account.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Interested_in_Number_of_Desks__c")
        expect(account.fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        puts "get Opportunity details"
        opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact.fetch('Id')}")
        puts opportunity

        passedLogs = @objRollbar.addLog("[Validate] opportunity:RecordType.Name")
        expect(opportunity.fetch('RecordType.Name')).to eq "Consumer"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:Deal_Type__c")
        expect(opportunity.fetch('Deal_Type__c')).to eq "Transactional"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:Owner.Id")
        expect(opportunity.fetch('Owner.Id')).to eq "#{building.fetch('Community_Lead__c')}"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:Quantity__c")
        expect(opportunity.fetch('Quantity__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        #@objAccAssignmentFromLead.updateProductAndOpp("#{opportunity.fetch('Id')}",'19',account.fetch('Id'),'Enterprise Solutions')

        updated_Acc = Hash["Number_of_Full_Time_Employees__c" => "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["UpdatedAccount"][0]["Number_of_Full_Time_Employees__c"]}", "id" => account.fetch('Id')]

        @objAccAssignmentFromLead.update('Account',updated_Acc)
        sleep(20)

        puts "get Account Details"
        account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact.fetch('Id')}")

        passedLogs = @objRollbar.addLog("[Validate] account:RecordType.Name")
        expect(account.fetch('RecordType.Name')).to eq "Enterprise Solutions"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] contact:Owner.Id")
        ownerAssign = accQueue.include? account.fetch('Owner.Id')
        expect(ownerAssign).to eq true
        passedLogs = @objRollbar.addLog("[Result  ]  Success")


        passedLogs = @objRollbar.addLog("[Step    ] get Contact details")
        contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
        expect(contact).to_not eq nil

        passedLogs = @objRollbar.addLog("[Validate] contact:RecordType.Name")
        expect(contact.fetch('RecordType.Name')).to eq "Enterprise Solutions"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] contact:Owner.Id")
        puts accQueue.include? contact.fetch('Owner.Id')
        ownerAssign = accQueue.include? contact.fetch('Owner.Id')
        expect(ownerAssign).to eq true
        passedLogs = @objRollbar.addLog("[Result  ]  Success")


        puts "get Opportunity details"
        opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact.fetch('Id')}")
        puts opportunity

        passedLogs = @objRollbar.addLog("[Validate] opportunity:RecordType.Name")
        expect(opportunity.fetch('RecordType.Name')).to eq "Enterprise Solutions"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:Deal_Type__c")
        expect(opportunity.fetch('Deal_Type__c')).to eq "Relational"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] contact:Owner.Id")
        puts accQueue.include? opportunity.fetch('Owner.Id')
        ownerAssign = accQueue.include? opportunity.fetch('Owner.Id')
        expect(ownerAssign).to eq true
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

      rescue Exception => e
        passedLogs = @objRollbar.addLog("[Result  ]  Fail")
        raise e
      end

    end

  end

  context "account reassignment for closed won opportunity" do
    it "C2076 : To check the Account reassignment for closed Won opp- Mid-Market.", :'11'=> 'true' do
      begin
        puts "C2076 : To check account assignment for Record Type Consumer and Deal type Transactional."
        @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['building']  = 'MUM-BKC'
        @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['companySize']  = '25'
        @objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)['AssignmentRules']['tour'][0]['numberOfDesks']  = '5'

        caseInfo = @testRailUtility.getCase('2076')
        #puts caseInfo
        passedLogs = @objRollbar.addLog("[Step    ] booking tour from WebSite", caseInfo['id'])
        emailId = @objAccAssignmentFromLead.createLead()
        expect(@driver.title).to match("Coworking Office Sambhav BKC | WeWork")

=begin
        passedLogs = @objRollbar.addLog("[Validate]  Lead should be created")
        leadId = @objAccAssignmentFromLead.fetchLeadDetails(emailId).fetch('Id')
        expect(leadId).to_not eq 'nil'
        passedLogs = @objRollbar.addLog("[Expected]  Lead created successfully with emailId = #{emailId} \n[Result  ]  Success ")
=end

        passedLogs = @objRollbar.addLog("[Validate]  Journey should be created")
        journey = @objAccAssignmentFromLead.fetchJourneyDetails(emailId)
        expect(journey).to_not eq nil
        passedLogs = @objRollbar.addLog("[Expected]  Journey created successfully with emailId = #{emailId} \n[Result  ]  Success ")

        passedLogs = @objRollbar.addLog("[Step    ] logging to salesforce")
        expect(@objAccAssignmentFromLead.loginToSalesforce).to_not eq nil

        passedLogs = @objRollbar.addLog("[Step    ] go to details page of created Journey and Clicking on 'Manage Tours' button")
        expect(@objAccAssignmentFromLead.openManageTouFromJourney(journey.fetch('Id'))).to eq true


        passedLogs = @objRollbar.addLog("[Validate] Checking Manage Tour page when user click on 'Manage/book tour' button")
        expect(@driver.title).to match("Manage Tours")
        passedLogs = @objRollbar.addLog("[Expected] Manage tour page opened successfully with Page Title= Manage Tours \n[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Step    ] filling all required fields and booked a tour")

        expect(@objAccAssignmentFromLead.bookTour(0,true,false)).to eq true

        passedLogs = @objRollbar.addLog("[Step    ] click on Create Account and Don't Merge")
        expect(@objAccAssignmentFromLead.duplicateAccountSelector("Create Account and Don't Merge",nil)).to eq true

        passedLogs = @objRollbar.addLog("[Step    ] checking fields...")

        passedLogs = @objRollbar.addLog("[Step    ] get building details of #{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"]}")
        building = @objAccAssignmentFromLead.fetchBuildingDetails(@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["building"])
        expect(building).to_not eq nil

        passedLogs = @objRollbar.addLog("[Step    ] get Contact details")
        contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
        expect(contact).to_not eq nil
        puts contact.fetch('Owner.Name')   #********



        passedLogs = @objRollbar.addLog("[Validate] contact:RecordType.Name")
        expect(contact.fetch('RecordType.Name')).to eq "Mid Market"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] contact:Owner.Id")
        expect(contact.fetch('Owner.Id')).to eq "#{building.fetch('Community_Lead__c')}"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] contact:Number_of_Full_Time_Employees__c")
        expect(contact.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] contact:Looking_For_Number_Of_Desk__c")
        expect(contact.fetch('Looking_For_Number_Of_Desk__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        puts "get Opportunity details"
        opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact.fetch('Id')}")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:RecordType.Name")
        expect(opportunity.fetch('RecordType.Name')).to eq "Mid Market"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:Deal_Type__c")
        expect(opportunity.fetch('Deal_Type__c')).to eq "Transactional"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:Owner.Id")
        expect(opportunity.fetch('Owner.Id')).to eq "#{building.fetch('Community_Lead__c')}"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] opportunity:Quantity__c")
        expect(opportunity.fetch('Quantity__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        puts "get Account Details"
        account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact.fetch('Id')}")

        passedLogs = @objRollbar.addLog("[Validate] account:RecordType.Name")
        expect(account.fetch('RecordType.Name')).to eq "Mid Market"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Owner.Id")
        expect(account.fetch('Owner.Id')).to eq "#{building.fetch('Community_Lead__c')}"
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Number_of_Full_Time_Employees__c")
        expect(account.fetch('Number_of_Full_Time_Employees__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["companySize"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

        passedLogs = @objRollbar.addLog("[Validate] account:Interested_in_Number_of_Desks__c")
        expect(account.fetch('Interested_in_Number_of_Desks__c').to_i).to eq "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["tour"][0]["numberOfDesks"]}".to_i
        passedLogs = @objRollbar.addLog("[Result  ]  Success")



        #go to contact -> manage tour
        # create opp
        puts "1236"
        passedLogs = @objRollbar.addLog("[Step    ] Go to Contact detail page and book a tour by creating new opportunity")
        expect(@objAccAssignmentFromLead.goToDetailPage(contact.fetch('Id'))).to eq true
        expect(@objAccAssignmentFromLead.bookTour(0,true,true)).to eq true

        #go to Account
        # Change address
        passedLogs = @objRollbar.addLog("[Step    ] Update Account Address")
        updated_account = Hash['name' => "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["UpdatedAccount"][0]["BillingCountry"]}","BillingCountry" => "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["UpdatedAccount"][0]["BillingCountry"]}", "id" => account.fetch('Id')]
        #puts updated_account
        @objAccAssignmentFromLead.update('Account',updated_account)

        # change opp stage closed won
        passedLogs = @objRollbar.addLog("[Step    ] Update Opportunity Stage")
        updated_opp = Hash["StageName" => "#{@objAccAssignmentFromLead.instance_variable_get(:@sObjectRecords)["AssignmentRules"]["UpdatedOpportunity"][0]["StageName"]}", "id" => opportunity.fetch('Id')]
        @objAccAssignmentFromLead.update('Opportunity',updated_opp)

        passedLogs = @objRollbar.addLog("[Step    ] get Updated Account Details")
        account = @objAccAssignmentFromLead.fetchAccountDetails("#{contact.fetch('Id')}")
        puts account

        passedLogs = @objRollbar.addLog("[Step    ] get Owner based on address on Account")
        accQueue  = @objAccAssignmentFromLead.getOwnerbasedOnAddress(account)
        expect(accQueue).to_not eq nil

        passedLogs = @objRollbar.addLog("[Validate] account:Owner.Id")
        expect(accQueue.include? account.fetch('Owner.Id')).to eq true


        passedLogs = @objRollbar.addLog("[Step    ] get Updated Contact details")
        contact = @objAccAssignmentFromLead.fetchContactDetails("#{emailId}")
        puts contact
        passedLogs = @objRollbar.addLog("[Validate] contact:Owner.Id")
        expect(accQueue.include? contact.fetch('Owner.Id')).to eq true

        passedLogs = @objRollbar.addLog("[Step    ] get Updated Opportunity details")
        opportunity = @objAccAssignmentFromLead.fetchOpportunityDetails("#{contact.fetch('Id')}")
        puts opportunity

        puts opportunity.keys.size
        puts opportunity.keys[0]
        puts opportunity.values_at(opportunity.keys[0])
        puts opportunity.values_at(opportunity.keys[0]).class
        puts opportunity.values_at(opportunity.keys[0])[0]
        puts "12121212112121212"
        puts opportunity.values_at(opportunity.keys[0])[0].size


        i = 0
        until opportunity.keys[i] == nil do
          if opportunity.values_at(opportunity.keys[i])[0].fetch('StageName') != 'Closed Won' then
            passedLogs = @objRollbar.addLog("[Validate] opportunity:Owner.Id")
            expect(accQueue.include? opportunity.values_at(opportunity.keys[i])[0].fetch('Owner.Id')).to eq true
          end
          i = i + 1
        end

      rescue Exception => e
        passedLogs = @objRollbar.addLog("[Result  ]  Fail")
        raise e
      end

    end

  end

    after(:all){

  }
  after(:each){

  }
  end