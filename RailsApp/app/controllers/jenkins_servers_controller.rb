class JenkinsServersController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :set_jenkins_server, only: [:show, :edit, :update, :destroy]

  # GET /jenkins_servers
  # GET /jenkins_servers.json
  def index
    render json: {status: 200, output:JenkinsServer.all }
  end

  # GET /jenkins_servers/1
  # GET /jenkins_servers/1.json
  def show
    render json: {status: 200, output: JenkinsServer.select(:name,:url,:os,:browser,:username).where(name: params[:id]).take}
  end

  # GET /jenkins_servers/new
  def new
    @jenkins_server = JenkinsServer.new
  end

  # GET /jenkins_servers/1/edit
  def edit
    render json: {status: 200, output:JenkinsServer.select(:name) }
  end

  # POST /jenkins_servers
  # POST /jenkins_servers.json
  def create
    begin
      @jenkins_server = JenkinsServer.new(jenkins_server_params)
      puts @jenkins_server.browser
      @jenkins_server.browser = params['browser']
      existsServer = JenkinsServer.where(:url => @jenkins_server.url)
      #@@res =  @@con.exec('SELECT * FROM "QAAuto"."Credentials" WHERE "Credentials"."type" = '+"'jenkins'")
      if existsServer.empty?
      EnziJenkinsUtility::JenkinsUtility.new(@jenkins_server.username, @jenkins_server.password, @jenkins_server.url)
        if @jenkins_server.save
          render json: {status: 200, output: JenkinsServer.all}
        else
          render json: {status: 500, output: "Error Occured !"}
        end
      else
        if existsServer.update(:name => @jenkins_server.name,:username => @jenkins_server.username,:password => @jenkins_server.password , :url => @jenkins_server.url,:os => @jenkins_server.os,:browser => @jenkins_server.browser)
          render json: {status: 200, output: JenkinsServer.all}
        else
          render json: {status: 500, output: "Update Failed !"}
        end
      end
    rescue Exception => exp
      render json: {status: 500, output: "Invalid username or password !"}
    end
  end

  # PATCH/PUT /jenkins_servers/1
  # PATCH/PUT /jenkins_servers/1.json
  def update
    respond_to do |format|
      if @jenkins_server.update(jenkins_server_params)
        format.html { redirect_to @jenkins_server, notice: 'Jenkins server was successfully updated.' }
        format.json { render :show, status: :ok, location: @jenkins_server }
      else
        format.html { render :edit }
        format.json { render json: @jenkins_server.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /jenkins_servers/1
  # DELETE /jenkins_servers/1.json
  def destroy
    if JenkinsServer.where(:name => params['id']).take.destroy
      index()
    else
      render json: {status: 500, output: "Invalid Input"}
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_jenkins_server
      @jenkins_server = JenkinsServer.where(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def jenkins_server_params
      params.require(:jenkins_server).permit(:browser,:name, :username, :password, :url, :os)
    end
end
