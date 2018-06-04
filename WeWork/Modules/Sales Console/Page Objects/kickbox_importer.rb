class Kickbox_Importer
  def initialize(driver, helper)
    puts "Initializing page object"
    @mapRecordType = Hash.new
    @driver = driver
    @helper = helper
    @testDataJSON = @helper.getRecordJSON()
    @testDataJSON['Lead'][0]['Number_of_Full_Time_Employees__c'] = 10
    @testDataJSON['Lead'][0]['Interested_in_Number_of_Desks__c'] = 5
    @testDataJSON['Lead'][0]['Status'] = "Open"
    @testDataJSON['Lead'][0]['LeadSource'] = "Inbound Call"
    @testDataJSON['Lead'][0]['lead_Source_Detail__c'] = "Inbound Call Page"
    @testDataJSON['Lead'][0]['Locale__c'] = "en-US"
    @testDataJSON['Lead'][0]['Country_Code__c'] = "IN"
    @timeSettingMap = @helper.instance_variable_get(:@timeSettingMap)
    @mapCredentials = @helper.instance_variable_get(:@mapCredentials)
    @salesforceBulk = @helper.instance_variable_get(:@salesforceBulk)
    @restforce = @helper.instance_variable_get(:@restForce)
    @csv = {"Lead"=>["Header"=>['First Name','Last Name','Email','Phone','Company','Locale','Lead source','Lead source detail','Country code','Locations interested','Status','Generate Journey']],"Contact"=>["Header"=>['First Name','Last Name','Email','Phone','Company','Locale','Lead source','Lead source detail','Country code','Locations interested','Status','Generate Journey']]}
    @wait = Selenium::WebDriver::Wait.new(:timeout => @timeSettingMap['Wait']['Environment']['Lightening']['Max'])
    @userInfo = @restforce.getUserInfo
    @settings = @restforce.getRecords("SELECT name,Data__c FROM Setting__c WHERE name IN ('User/Queue Journey Creation','Lead:Lead and Lead Source Details','Unassigned NMD US Queue','SplashEventJourney')")
  end

  def open_tab(what, button)
    @helper.instance_variable_get(:@wait).until {@driver.find_element(:name, "ext-comp-1005")}
    istabOpen = false
    @driver.find_elements(:class, "tabText").each do |tab|
      if tab.text.eql?(what)
        istabOpen = true
        break;
      end
    end
    @driver.switch_to.default_content
    if !@driver.find_elements(:id, "RPPWarning").empty?
      @driver.find_element(:id, "RPPCancelButton").click
    end
    EnziUIUtility.switchToFrame(@driver, "ext-comp-1005")
    if !istabOpen
      @driver.find_element(:name, button).click
    end
  end

  def upload_csv(email, generate_journey = nil, campaign_name = nil, is_generate_journey,checkForLeadCreation,type)
    @testDataJSON['Lead'][0]['Email'] = email
    type.eql?('Contact') ? @testDataJSON['Lead'][0]['Status'] = "Inactive" : @testDataJSON['Lead'][0]['Status'] = "Open"
    CSV.open("E:/QA-Automation/leadImporter.csv", "wb") do |csv|
      csv << @csv[type][0]['Header']
      generate_journey.nil? ? csv << ["#{@testDataJSON['Lead'][0]['FirstName']}", "#{@testDataJSON['Lead'][0]['LastName']}", "#{@testDataJSON['Lead'][0]['Email']}", "#{@testDataJSON['Lead'][0]['Phone']}", "#{@testDataJSON['Lead'][0]['Company']}", "#{@testDataJSON['Lead'][0]['Locale__c']}", "#{@testDataJSON['Lead'][0]['LeadSource']}", "#{@testDataJSON['Lead'][0]['lead_Source_Detail__c']}", "", "#{@testDataJSON['Lead'][0]['Building_Interested_In__c']}", "open"] : csv << ["#{@testDataJSON['Lead'][0]['FirstName']}", "#{@testDataJSON['Lead'][0]['LastName']}", "#{@testDataJSON['Lead'][0]['Email']}", "#{@testDataJSON['Lead'][0]['Phone']}", "#{@testDataJSON['Lead'][0]['Company']}", "en-US", "#{@testDataJSON['Lead'][0]['LeadSource']}", "#{@testDataJSON['Lead'][0]['lead_Source_Detail__c']}", "IN", "#{@testDataJSON['Lead'][0]['Building_Interested_In__c']}", "open", generate_journey]
    end
    @helper.addLogs("[Step ]  : Browse csv")
    @driver.switch_to.default_content
    @helper.instance_variable_get(:@wait).until {@driver.find_element(:id, "servicedesk").find_elements(:tag_name, "iframe").size > 1}
    EnziUIUtility.switchToFrame(@driver, @driver.find_element(:id, "servicedesk").find_elements(:tag_name, "iframe")[0].attribute("name"))
    @helper.instance_variable_get(:@wait).until {@driver.find_element(:class, "file-browse").displayed?}
    @helper.instance_variable_get(:@wait).until {@driver.find_element(:id, "csvUpload")}
    @driver.find_element(:id, "csvUpload").send_keys "E:/QA-Automation/leadImporter.csv"
    @helper.addLogs("[Result ]   : Csv browsed successfully")
    @helper.instance_variable_get(:@wait).until {!@driver.find_element(:id, "spinnerContainer").displayed?}
    @driver.find_element(:id, "checkbox-308").find_element(:xpath, "..").click if is_generate_journey
    if !campaign_name.nil?
      @driver.find_element(:id, "checkbox-309").find_element(:xpath, "..").click
      campaignLookup = @driver.find_element(:id, "inputCampaign")
      campaignLookup.find_elements(:tag_name, "input")[0].send_keys campaign_name
      @helper.instance_variable_get(:@wait).until {campaignLookup.find_elements(:tag_name, "ul")[0].find_elements(:tag_name, "li")[1].displayed?}
      campaignLookup.find_elements(:tag_name, "ul")[0].find_elements(:tag_name, "li")[1].click
    end
    EnziUIUtility.selectElement(@driver, "Upload", "button").click
    if checkForLeadCreation
      @helper.addLogs("[Validate ] : Checking Lead creation")
      leadInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id , CreatedDate,Owner.Name,Owner.Id,	Generate_Journey__c, 	Locale__c, LeadSource,Journey_Created_On__c ,Country_Code__c, Lead_Source_Detail__c , Building_Interested_In__c , Building_Interested_Name__c ,Locations_Interested__c , Email , Phone , Company , Name , Status  FROM Lead WHERE Email = '#{@testDataJSON['Lead'][0]['Email']}'")
      index = 1
      until !leadInfo[0].nil?
        if index.eql? 10
          break;
        end
        sleep(30)
        puts "Waiting for lead creation.....30 seconds"
        puts "Getting created lead info - Throw #{index}"
        leadInfo = @helper.instance_variable_get(:@restForce).getRecords("SELECT id ,CreatedDate, Owner.Name,Owner.Id,	Generate_Journey__c, 	Locale__c, LeadSource,Journey_Created_On__c ,Country_Code__c, Lead_Source_Detail__c , Building_Interested_In__c , Building_Interested_Name__c ,Locations_Interested__c , Email , Phone , Company , Name  , Status  FROM Lead WHERE Email = '#{@testDataJSON['Lead'][0]['Email']}'")
        index += 1
      end
    end
    CSV.open("E:/QA-Automation/leadImporter.csv", "wb") do |csv|
      csv << []
    end
    leadInfo
  end

  def getOwnerByCampaignAssignment(campaignName)
    campaign = @helper.getSalesforceRecordByRestforce("SELECT id,Name,IsActive,City__c,Lead_Owner__c,Email_Address__c FROM Campaign Where Name = '#{campaignName}'")[0]
    allCriteriasChecked = false
    if !campaign.nil? then
      if campaign.fetch('Lead_Owner__c') != nil then
        if campaign.fetch('Lead_Owner__c').start_with? "00G" then
          group = @helper.instance_variable_get(:@restForce).getRecords("SELECT Id,Name FROM Group WHERE Id = '#{campaign.fetch('Lead_Owner__c')}'")[0]
          if group.nil? then
            allCriteriasChecked = true
            puts "No record found with given Group"
          else
            return group[0].fetch('Id')
          end
        else
          puts "Owner assigned is User"
          user = @helper.instance_variable_get(:@restForce).getRecords("SELECT Id,Name FROM User WHERE Id = '#{campaign.fetch('Lead_Owner__c')}' and IsActive = true")[0]
          if user.nil? then
            allCriteriasChecked = true
            puts "No active record found with given user"
          else
            return user.fetch('Id')
          end
        end
      end
      if campaign.fetch('Email_Address__c') != nil then
        building = @restForce.getRecords("SELECT id,Cluster_Sales_Lead_Name__c,name,Community_Lead__c,Email__c,Market__c,UUID__C FROM Building__c WHERE Email__c = '#{campaign.fetch('Email_Address__c')}'")

        buildingId = nil
        if building[0].fetch('Id').size == 18 then
          buildingId = building[0].fetch('Id').chop().chop().chop()
        end
        JSON.parse(@settings[1]["Data__c"]).each do |setting|
          if !setting['Buildings'].nil? && setting['Buildings'].include?("#{buildingId}") then
            if setting['userId'].start_with? "00G" then
              puts "Owner assigned is Queue"
              group = @helper.instance_variable_get(:@restForce).getRecords("SELECT Id,Name FROM Group WHERE Id = '#{setting['userId']}'")[0]
              if group.nil? then
                allCriteriasChecked = true
                puts "No record found with given Group"
              else
                return group[0].fetch('Id')
              end
            else
              user = @helper.instance_variable_get(:@restForce).getRecords("SELECT Id,Name FROM User WHERE Id = '#{setting['userId']}' and IsActive = true")[0]
              if user.nil? then
                allCriteriasChecked = true
                puts "No active record found with given user"
              else
                return user[0].fetch('Id')
              end
            end
          end
        end
      end
      if campaign.fetch('City__c') != nil then
        #puts "12112121212121212454545454"
        #puts "owner--> #{campaign[0].fetch('City__c')}"
        JSON.parse(@settings[1]["Data__c"]).each do |setting|
          #puts setting['Buildings'].class
          #puts setting['Buildings']
          #puts "@@@@@@@@@@@@@@@@@@@@@@@@"

          #puts setting['Buildings'].include?(buildingId)
          if !setting['City'].nil? && setting['City'].include?("#{campaign.fetch('City__c')}") then
            puts "city found in--->"

            if setting['userId'].start_with? "00G" then
              puts "Owner assigned is Queue"
              group = @helper.instance_variable_get(:@restForce).getRecords("SELECT Id,Name FROM Group WHERE Id = '#{setting['userId']}'")[0]
              puts "group#{group}"
              if group.nil? then
                puts "No record found with given Group"
              else
                puts "owner--> #{setting['userId']}"
                return group[0].fetch('Id')
              end
            else
              puts "Owner assigned is User"
              user = @helper.instance_variable_get(:@restForce).getRecords("SELECT Id,Name FROM User WHERE Id = '#{setting['userId']}' and IsActive = true")[0]
              if user.nil? then
                puts "No active record found with given user"
              else
                puts "owner--> #{setting['userId']}"
                return user[0].fetch('Id')
              end
            end
          end
        end
      end
      if allCriteriasChecked || (campaign.fetch('Lead_Owner__c').nil? && campaign.fetch('Email_Address__c').nil? && campaign.fetch('Lead_Owner__c').nil?) then
        puts "owner--> #{settings[2]['Data__c']['UnassignedNMDUSQueue']}"
        return settings[2]['Data__c']['UnassignedNMDUSQueue']
      end
    end
  end
  def getExistingContact(owner,isJourneyPresent,isActivityPresent)
    contactInfo = nil
    @helper.instance_variable_get(:@restForce).getRecords("select id,Email,(select id from tasks) from contact where Has_Active_Journey__c = #{isJourneyPresent} and CreatedBy.Name IN ('Veena Hegane','Ashotosh Thakur','Monika Pingale','Kishor Shinde') AND Email != null").each do |contact|
      if isActivityPresent
        if !contact['Tasks'].nil?
          contactInfo = contact
          break;
        end
      else
        if contact['Tasks'].nil?
          contactInfo = contact
          break;
        end
      end
    end
    contactInfo
  end
  def checkJobStatus
    checkJobStatus = 'k'
    until checkJobStatus.nil?
      @helper.addLogs("[Step ]  : Waiting for apex job completion")
      sleep(10)
      checkJobStatus = @helper.instance_variable_get(:@restForce).getRecords("SELECT JobType,MethodName,TotalJobItems,ApexClassID,status FROM AsyncApexJob WHERE apexclassid = '01p0G000004TXQj' AND status != 'Completed'")[0]
      !checkJobStatus.nil? ? @helper.addLogs("[Step ]  : Status is  - #{checkJobStatus.fetch('Status')}"): @helper.addLogs("[Result ] : Job Completed")
    end
    sleep(40)
  end

end