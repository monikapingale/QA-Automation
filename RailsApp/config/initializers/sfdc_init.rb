# config/initializers/sfdc_init.rb


=begin
SFDC_CONFIG = YAML.load_file("#{Rails.root}/config/salesforce.yml")
SfBulk = nil
SfBulk = SalesforceBulk::Api.new(SFDC_CONFIG['username'], SFDC_CONFIG['password'], true)
Users = SfBulk.query("User", "SELECT Id,name,Profile.name FROM User WHERE IsActive = true")
Profiles = SfBulk.query("Profile", "SELECT name,UserLicense.name FROM Profile WHERE id IN (SELECT profileid FROM User WHERE IsActive = true) and UserLicense.name = 'Salesforce'")
arrUser = []
arrProfiles = []
Users.result.records.each do |@@users|
  arrUser.push(JSON.parse(@@users.to_hash().to_s.gsub('\xC3\x','').gsub('=>',':')))
end
Users =  arrUser
Profiles.result.records.each do |profile|
  arrProfiles.push(profile.to_hash())
end
Profiles = arrProfiles
=end
             #.uniq.to_s.gsub('=>',':')
    #for(var innerArray in response.data['output'][outerArray]){
        #var profileMap = {};
    #profileMap[response.data['output'][outerArray][innerArray][0]] = response.data['output'][outerArray][innerArray][1];
    #$scope.arrProfiles.unshift(profileMap);

#Profiles = SfBulk.query("User", "SELECT name FROM User")
#puts Profiles.result.records.inspect
#puts Users
