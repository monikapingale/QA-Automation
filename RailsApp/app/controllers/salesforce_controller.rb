require 'restforce'
class SalesforceController < ApplicationController
  before_action
  def getProfiles()
    credetialObj = eval(Environment.where(name: params[:instance]).take.parameters.gsub(':','=>'))
    salesforceConObj = SalesforceCon.new
    salesforceConObj = SalesforceCon.all
    @@client = Restforce.new(username: credetialObj["sf_username"],
                             password: credetialObj["sf_password"],
                             host: 'test.salesforce.com',
                             client_id: salesforceConObj[0]['client_id'],
                             client_secret: salesforceConObj[0]['client_secret'],
                             grant_type: "password",
                             api_version: '41.0')
    restCollection =  @@client.query("SELECT id,name FROM Profile WHERE id IN (SELECT profileid FROM User WHERE IsActive = true) and UserLicense.name = 'Salesforce'")
    arrProfiles = []
     restCollection.each do |collection|
       arrProfiles.push('id' => collection['Id'] , 'name' => collection['Name'])
     end
    render json: { status: 200, output:arrProfiles}
  end
  def getUsers()
    credetialObj = eval(Environment.where(name: params[:instance]).take.parameters.gsub(':','=>'))
    salesforceConObj = SalesforceCon.new
    salesforceConObj = SalesforceCon.all
    @@client = Restforce.new(username: credetialObj["sf_username"],
                             password: credetialObj["sf_password"],
                             host: 'test.salesforce.com',
                             client_id: salesforceConObj[0]['client_id'],
                             client_secret: salesforceConObj[0]['client_secret'],
                             grant_type: "password",
                             api_version: '41.0')

    restCollection =  @@client.query("SELECT Id,name,Profile.name FROM User WHERE IsActive = true")
    arrUsers = []
    restCollection.each do |collection|
      arrUsers.push('id' => collection['Id'] , 'name' => collection['Name'])
    end
    render json: { status: 200, output:arrUsers}
  end

end
