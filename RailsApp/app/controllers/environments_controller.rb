class EnvironmentsController < ApplicationController
  protect_from_forgery with: :null_session

  # GET /environments
  # GET /environments.json
  def index
    render json: {status: 200, output: Environment.select(:name)}
  end

  # GET /environments/1
  # GET /environments/1.json
  def show
    render json: {status: 200, output: Environment.select(:id,:name,:env_type,:parameters).where(name: params["id"]).take}
  end

  # GET /environments/new
  def new
    @environment = Environment.new
  end

  # GET /environments/1/edit
  def edit
    tempDataHolder = []
    Environment.select(:name).each do |env|
      tempDataHolder.push(env["name"])
    end
    render json: {status: 200, output: tempDataHolder}
  end

  # POST /environments
  # POST /environments.json
  def create
    environment = Environment.new(environment_params)
    existsEnvironment = Environment.where(:name => environment.name)
    if existsEnvironment.empty?
      if environment.env_type.eql?('Salesforce')
        credentailsObj = eval(environment.parameters)
        salesforceConObj = SalesforceCon.new
        salesforceConObj = SalesforceCon.all
        @@client = Restforce.new(username: credentailsObj[:sf_username],
                                 password: credentailsObj[:password],
                                 host: 'test.salesforce.com',
                                 client_id: salesforceConObj[0]['client_id'],
                                 client_secret: salesforceConObj[0]['client_secret'],
                                 grant_type: "password",
                                 api_version: '41.0')
        begin
          userInfo = @@client.user_info.to_h
          if userInfo['active']
            if Setting.where(name: 'allowedProfiles')['profile'].include? @@client.query("SELECT Id, Profile.name FROM User WHERE Id = '#{userInfo['user_id']}'").current_page[0]['Profile']['Name']
              if  !Environment.where(name: environment.name).take.nil?
                render json: { status: 500, output: 'User Already Exists !!'}
              else
                if environment.save
                  render json: { status: 200, output: Environment.all}
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
          if environment.save
            render json: { status: 200, output: Environment.all}
          else
            render json: { status: 500, output: 'Error'}
          end
      end
    else
      if existsEnvironment.update(:name => environment.name,:parameters => environment.parameters,:env_type => environment.env_type)
        render json: { status: 200, output: Environment.all}
      else
        render json: { status: 500, output: 'Update Failed'}
      end
    end
  end

  # PATCH/PUT /environments/1
  # PATCH/PUT /environments/1.json
  def update
    respond_to do |format|
      if @environment.update(environment_params)
        format.html { redirect_to @environment, notice: 'Environment was successfully updated.' }
        format.json { render :show, status: :ok, location: @environment }
      else
        format.html { render :edit }
        format.json { render json: @environment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /environments/1
  # DELETE /environments/1.json
  def destroy
    if Environment.where(:name => params[:id]).take.destroy
      render json: { status: 200, output: Environment.select(:name)}
    else
      render json: { status: 500, output: "Error occured during deletion"}
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_environment
      @environment = Environment.where(:name => params[:id]).take
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def environment_params
      params.require(:environment).permit(:name, :parameters, :env_type)
    end
end
