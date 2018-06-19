require 'restforce'
class CredentialsController < ApplicationController
  protect_from_forgery with: :null_session

  # GET /credentials
  # GET /credentials.json
  def index
    @credentials = Credential.all
  end

  def getServers
    tempDataHolder = []
    Credential.where(entity: params['id']).each do |server|
      tempDataHolder.push(server['username'])
    end
    puts tempDataHolder
    render json: { status: 200, output: tempDataHolder}
  end

  # GET /credentials/1
  # GET /credentials/1.json
  def show
    render json: { status: 200, output: Credential.where(username:  params['id']).select([:username,:hostName]).take}
  end

  # GET /credentials/new
  def new
    @credential = Credential.new
  end

  # GET /credentials/1/edit
  def edit
    if params['id'].eql?('jenkins')
      render json: { status: 200, output: Credential.where(entity:  params['id']).select([:hostName]).to_a}
      return
    else
      render json: { status: 200, output: Credential.where(entity:  params['id']).select([:username, :hostName])}
      return
    end
    render json: { status: 200, output: Credential.where(username:  params['id']).select([:username, :hostName])}

  end

  # POST /credentials
  # POST /credentials.json
  def create
    @credential = Credential.new(credential_params)
    puts @credential
    existsCredentail = Credential.where(:username => @credential.username)
    if existsCredentail.empty?
    if @credential.entity.eql?('salesforce')
      salesforceConObj = SalesforceCon.new
      salesforceConObj = SalesforceCon.all
      @@client = Restforce.new(username: @credential.username,
                               password: @credential.password,
                               host: 'test.salesforce.com',
                               client_id: salesforceConObj[0]['client_id'],
                               client_secret: salesforceConObj[0]['client_secret'],
                               grant_type: "password",
                               api_version: '41.0')
      begin
        userInfo = @@client.user_info.to_h
        if userInfo['active']
          if Setting.where(name: 'allowedProfiles')['profile'].include? @@client.query("SELECT Id, Profile.name FROM User WHERE Id = '#{userInfo['user_id']}'").current_page[0]['Profile']['Name']
            if  !Credential.where(hostName: @credential.hostName).take.nil?
            render json: { status: 500, output: 'User Already Exists !!'}
          else
              if @credential.save
                render json: { status: 200, output: Credential.where(entity:  @credential.entity).select([:username, :hostName]).as_json.values}
              else
                render json: { status: 500, output: "Credentilas invalid"}
              end
          end
          else
            render json: { status: 500, output: "Inactive User"}
          end
        else
          render json: { status: 500, output: "Profile Not Allowed"}
        end
      rescue Exception => exp
        puts exp
          render json: { status: 500, output: exp}
      end
    else
      if @credential.entity.eql?('jenkins')
        begin
          EnziJenkinsUtility::JenkinsUtility.new(@credential.username,@credential.password,@credential.hostName)
          if  !Credential.where(hostName: @credential.hostName).take.nil?
            render json: { status: 500, output: 'User Already Exists !!!'}
          else
            if @credential.save
              render json: { status: 200, output:  Credential.where(entity:  @credential.entity).select([:hostName]).to_a}
            else
              render json: { status: 500, output: "Credentilas invalid"}
            end
          end
        rescue Exception => exp
          render json: { status: 500, output: exp}
        end
      else
        if @credential.save
          render json: { status: 200, output:  Credential.where(entity:  @credential.entity).select([:username, :hostName]).to_a}
        else
          render json: { status: 500, output: "Credentilas invalid"}
        end
      end
    end
    else
      if existsCredentail.update(:username => @credential.username, :password => @credential.password, :hostName => @credential.hostName ,:entity => @credential.entity)
        render json: { status: 200, output:  Credential.where(entity:  @credential.entity).select([:username, :hostName]).to_a}
      else
        render json: { status: 500, output: "Credentilas invalid"}
      end
    end
  end

  # PATCH/PUT /credentials/1
  # PATCH/PUT /credentials/1.json
  def update
    respond_to do |format|
      if @credential.update(credential_params)
        format.html { redirect_to @credential, notice: 'Credential was successfully updated.' }
        format.json { render :show, status: :ok, location: @credential }
      else
        format.html { render :edit }
        format.json { render json: @credential.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /credentials/1
  # DELETE /credentials/1.json
  def destroy
    @credential.destroy
    respond_to do |format|
      format.html { redirect_to credentials_url, notice: 'Credential was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_credential
      @credential = Credential.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def credential_params
      params.require(:credential).permit(:username, :password, :entity, :hostName)
    end
end
