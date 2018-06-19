require 'jenkins_api_client'
require 'pg'
require 'net/http'
class TemplatesController < ApplicationController
  protect_from_forgery with: :null_session

  # GET /templates
  # GET /templates.json
  def index
    templateArr = []
    Template.where(:scheduled => false).order(:created_at).each  do |template|
      tempArr = []
      template.attributes.keys.each do |key|
        if template[key].is_a?(Array)
          tempValueHolder = []
          template[key].each do |key|
            tempValueHolder.push({'name' => key['name'], 'url' => key['url']})
          end
          tempArr.push({'label' => key , 'value' => tempValueHolder , 'job' => template['Job']})
        else
          if !template[key].is_a?(ActiveSupport::TimeWithZone)
              tempArr.push({'label' => key , 'value' => template[key] ,  'job' => template['Job']})
          end
        end
      end
      templateArr.push(tempArr)
    end
    render json: {status: 200, output: templateArr}
  end

  # GET /templates/1
  # GET /templates/1.json
  def show
    template =  Template.where(:Job => params['id']).take
    template = template.attributes
    tempValueHolder = []
    template['Project'].each do |project|
      tempValueHolder.push("<a href=#{project['url']} target='_blank'>#{project['name']}</a>")
    end
    template['Project'] = tempValueHolder.join(",")
    tempValueHolder = []
    template['Suit'].each do |suit|
      tempValueHolder.push("<a href=#{suit['url']} target='blank'>#{suit['name']}</a>")
    end
    template['Suit'] = tempValueHolder.join(",")
    tempValueHolder = []
    template['Section'].each do |section|
      tempValueHolder.push("<a href=#{section['url']} target='blank'>#{section['name']}</a>")
    end
    template['Section'] = tempValueHolder.join(",")
    tempValueHolder = []
    template['Profile'].each do |project|
      tempValueHolder.push(project['name'])
    end
    template['Profile'] = tempValueHolder.join(",")
    tempValueHolder = []
    template['jenkinsServer'].each do |server|
      tempValueHolder.push("<a href=#{JenkinsServer.where(:name => server['name']).take['url']}/job/#{template['Job']} target='blank'>#{server['name']}</a>")
    end
    template['jenkinsServer'] = tempValueHolder.join(',')
    render json: {status: 200, output: {'TestRailServer'=> "<a href=#{Credential.where(:username => template['TestRailServer']).take['hostName']} target='blank'>TestRail</a>" , 'JenkinsServer' => template['jenkinsServer'],'Project' => template['Project'], 'Suit' => template['Suit'] , 'Section' => template['Section'] , 'Profile' => template['Profile']}}
  end

  # GET /templates/new
  def new
    @template = Template.new
  end

  # GET /templates/1/edit
  def edit
    render json: {status: 200, output: Template.where(:Job => params['id']).take}
  end

  def get
    render json: {status: 200, output: Template.all.to_a}
  end
  def pauseJob
      response = ''
      template = Template.where(:Job => params[:job]).take
      template['jenkinsServer'].each do |server|
        begin
          response = connectToJenkins(server['name']).updateJob(params[:job],'*')
        rescue Exception => exp
          response = nil
        end
      end
      if !response.nil?
        template.update({'scheduled' => false})
        templateArr = []
        Template.where(:scheduled => true).each  do |template|
          puts template
          tempArr = []
          template.attributes.keys.each do |key|
            if template[key].is_a?(Array)
              tempValueHolder = []
              template[key].each do |key|
                tempValueHolder.push({'name' => key['name'], 'url' => key['url']})
              end
              tempArr.push({'label' => key , 'value' => tempValueHolder , 'job' => template['Job']})
            else
              if !template[key].is_a?(ActiveSupport::TimeWithZone)
                tempArr.push({'label' => key , 'value' => template[key] ,  'job' => template['Job']})
              end
            end
          end
          templateArr.push(tempArr)
        end
        render json: {status: 200, output: templateArr}
      else
        render json: {status: 500, output: "Error occured"}
      end
  end
  # POST /templates
  # POST /templates.json
  def create
    randomNumber = rand(999)
    begin
        template = Template.new(template_params)
        template.Name = params['Name']['name']
        template.Suit = params['Suit']
        template.Section = params['Section']
        template.Project = params['Project']
        template.Profile = params['Profile']
        template.Environment = params['Environment']
        template.TestRailServer = params['TestRailServer']
        tempBrowserHolder = []
        template.Browser = params['Browser']
        template.scheduled = false
        tempServerHolder = []
        params['jenkinsServer'].each do |server|
          tempServerHolder.push(server)
        end
        template.jenkinsServer = tempServerHolder
        puts template.new_record?
        if Template.where(:Job => template.Job).empty?
          template.Job = "#{template.Project}#{randomNumber}"
          response = createJob("WeWork#{randomNumber}", params)
          if !(response.nil?)
            if template.save
              index()
            else
              render json: {status: 500, output: "Error occured"}
            end
          else
            render json: {status: 500, output: "Error occured"}
          end
        else
          response = updateJob("#{template.Job}", params)
          if !(response.nil?)
            templateExists = Template.where(:Job => template.Job).take
            if templateExists.update(:Project=> template.Project,:Suit => template.Suit,:Section => template.Section,:Profile => template.Profile,:Browser => template.Profile, :TestRailServer => template.TestRailServer,:jenkinsServer => template.jenkinsServer,:Environment => template.Environment)
              index()
            else
              render json: {status: 500, output: "Update Failed"}
            end
          else
            render json: {status: 500, output: "Error occured"}
          end
        end
    rescue Exception => exp
      puts exp
      render json: {status: 500, output: "Host Is Not Reachable :("}
    end
  end

  # PATCH/PUT /templates/1
  # PATCH/PUT /templates/1.json
  def update
    respond_to do |format|
      if @template.update(template_params)
        format.html {redirect_to @template, notice: 'Template was successfully updated.'}
        format.json {render :show, status: :ok, location: @template}
      else
        format.html {render :edit}
        format.json {render json: @template.errors, status: :unprocessable_entity}
      end
    end
  end

  # DELETE /templates/1
  # DELETE /templates/1.json
  def destroy
    response = nil
    Template.where(:Job => params['id']).take['jenkinsServer'].each do |server|
      response = deleteJob(params['id'],server['name'])
    end
    if response
      if Template.where(:Job => params['id']).take.destroy
        index()
      else
        render json: {status: 500, output: "Delete Failed"}
      end
    else
      render json: {status: 500, output: "Delete Failed"}
    end
=begin
    begin
      template = Template.where(:job => params['id']).take
      puts template
      template['jenkinsServer'].each do |server|
        deleteJob(template['job'],server)
      end
      if template.destroy
        index()
      else
        render json: {status: 500, output: "Invalid Input"}
      end
    rescue Exception => exp
      render json: {status: 500, output: "Delete Failed"}
    end
=end
  end
  def connectToJenkins(host)
    credetialObj = Credential.new
    credetialObj = JenkinsServer.where(name: host).take
    #@@res =  @@con.exec('SELECT * FROM "QAAuto"."Credentials" WHERE "Credentials"."type" = '+"'jenkins'")
    EnziJenkinsUtility::JenkinsUtility.new(credetialObj.username, credetialObj.password, credetialObj.url)
  end
  def scheduleJob()
    options = params[:job].split('&')
    response = ''
    template = Template.where(:Job => options[0]).take
    template['jenkinsServer'].each do |server|
      response = connectToJenkins(server['name']).updateJob(options[0],options[1])
    end
    puts response
      template.update({'scheduled' => true}).inspect
    templateArr = []
    Template.where(:scheduled => false).each  do |template|
      tempArr = []
      template.attributes.keys.each do |key|
        if template[key].is_a?(Array)
          tempValueHolder = []
          template[key].each do |key|
            tempValueHolder.push({'name' => key['name'], 'url' => key['url']})
          end
          tempArr.push({'label' => key , 'value' => tempValueHolder , 'job' => template['Job']})
        else
          if !template[key].is_a?(ActiveSupport::TimeWithZone)
            tempArr.push({'label' => key , 'value' => template[key] ,  'job' => template['Job']})
          end
        end
      end
      templateArr.push(tempArr)
    end
    render json: {status: 200, output: templateArr}
  end
  def createJob(jobName, job)
    tempDataHolder = []
    job[:jenkinsServer].each do |server|
      jenkinsClient = connectToJenkins(server['name']);
      job['Browser'].uniq.each do |browser|
        if browser['name'].eql?(server['name'])
          puts browser['value']
          tempDataHolder.push(browser['value'])
        end
      end
      job['Browser'] = tempDataHolder.join(',')
      job['Profile'].each do |profile|
        tempDataHolder.push(profile['name'])
      end
      job['Profile'] = tempDataHolder.join(',')
      tempDataHolder = []
      job['Project'].each do |project|
        tempDataHolder.push(project['id'])
      end
      job['Project'] = tempDataHolder.join(',')
      tempDataHolder = []
      job['Suit'].each do |suit|
        tempDataHolder.push(suit['id'])
      end
      job['Suit'] = tempDataHolder.join(',')
      tempDataHolder = []
      job['Section'].each do |section|
        tempDataHolder.push(section['id'])
      end
      job['Section'] = tempDataHolder.join(',')
      jobConfig = Nokogiri::XML::Document.parse(File.read("jenkins_job_config.xml")).to_s
      hashJobConfig = ActiveSupport::JSON.decode(Hash.from_xml(jobConfig).to_json)
      puts hashJobConfig
      hashJobConfig["project"]["builders"]["hudson.tasks.BatchFile"] = {"command"=>"cd ..\n cd startRailsServer \n rspec specManager.rb"}
      puts "---------------------------------------------------------------------------------------------"
      puts hashJobConfig
      puts "---------------------------------------------------------------------------------------------"
      #puts hashJobConfig['project']['properties']['hudson.model.ParametersDefinitionProperty']['parameterDefinitions'].to_xml(:skip_types => true , :root =>'parameterDefinitions')
      hashJobConfig['project']['properties']['hudson.model.ParametersDefinitionProperty']['parameterDefinitions']['hudson.model.StringParameterDefinition'].each do |parameter|

        if !(job[parameter['defaultValue']].nil?) && job[parameter['defaultValue']].length > 0
          parameter['defaultValue'] = job[parameter['defaultValue']]
        else
          parameter['defaultValue'] = ''
        end
      end
      #file = File.open("jenkins_job_config.xml","w")
      #puts file.write(hashJobConfig.to_xml())
      #puts newjobConfig.remove_attribute('hash')
      #.gsub('1' , "").gsub('1' , "").gsub('%&gt;','')
      #tempDataHolder = ''
=begin
    job.keys.each do |key|
      if job[key].is_a?(Array)
        tempDataHolder = ""
        job[key].each do |value|
          if value.key?('id')
            tempDataHolder = tempDataHolder + value['id'] + ','
          end
        end
      end
      puts key
      config = config.gsub("#{key}",tempDataHolder.chomp(','))
    end
=end
      #puts Nokogiri::XML::Document.parse(File.read("jenkins_job_config.xml")).to_s.gsub('1' , "").gsub('1' , "").gsub('%&gt;','')
      temp = hashJobConfig['project'].to_xml( :skip_instruct => true, :root => 'project').to_s.gsub('nil="true"', '').sub!("<hudson.model.StringParameterDefinition>", '').split('</parameterDefinitions>')
      finalJobConfig = temp[0].strip.chomp('</hudson.model.StringParameterDefinition>') + '</parameterDefinitions>' + temp[1]
      if JenkinsServer.where(name: server['name']).take['os'].eql? 'Mac'
        finalJobConfig = finalJobConfig.gsub("BatchFile" , "Shell")
      end
      puts finalJobConfig
      jenkinsClient.createJob(jobName, finalJobConfig)
    end
    #jenkinsClient.createJob(jobName,hashJobConfig['project'].to_xml(:skip_types => true ,:skip_instruct => true ,:exclude => 'hudson.model.StringParameterDefinition',:root => 'project').to_s.gsub('nil="true"','').sub!("<hudson.model.StringParameterDefinition>", ''))
  end
  def scheduledTemplates
    templateArr = []
    Template.where(:scheduled => true).each  do |template|
      puts template
      tempArr = []
      template.attributes.keys.each do |key|
        if template[key].is_a?(Array)
          tempValueHolder = []
          template[key].each do |key|
            tempValueHolder.push({'name' => key['name'], 'url' => key['url']})
          end
          tempArr.push({'label' => key , 'value' => tempValueHolder , 'job' => template['Job']})
        else
          if !template[key].is_a?(ActiveSupport::TimeWithZone)
            tempArr.push({'label' => key , 'value' => template[key] ,  'job' => template['Job']})
          end
        end
      end
      templateArr.push(tempArr)
    end
    render json: {status: 200, output: templateArr}
  end

  def runJob()
    begin
      options = params[:options].split('&')
      response = nil
      job = Template.where(:Job => "#{options[0]}").take
      job['jenkinsServer'].each do |server|
        serverInfo = JenkinsServer.where(name: server['name']).take
        if options[1].eql? true || serverInfo['os'].eql?('Mac')
          jenkinsClient = connectToJenkins(server['name'])
          response = jenkinsClient.buildJob(options[0], {'PROJECT_ID' => 4}, {'build_start_timeout' => 100})
        else
          job['Browser'].uniq.each do |browser|
            if browser['name'].eql?(server['name'])
              job['Browser'] = browser['value']
            end
          end
          puts job['Browser']
          tempDataHolder = []
          job['Profile'].each do |profile|
            tempDataHolder.push(profile['name'])
          end
          job['Profile'] = tempDataHolder.join(',')
          tempDataHolder = []
          job['Project'].each do |project|
            tempDataHolder.push(project['id'])
          end
          job['Project'] = tempDataHolder.join(',')
          tempDataHolder = []
          job['Suit'].each do |suit|
            tempDataHolder.push(suit['id'])
          end
          job['Suit'] = tempDataHolder.join(',')
          tempDataHolder = []
          job['Section'].each do |section|
            tempDataHolder.push(section['id'])
          end
          job['Section'] = tempDataHolder.join(',')
          uri = URI(serverInfo['url'].gsub('8080','3000/application'))
          params = { :PROJECT_ID => job['Project'], :SUIT_ID => job['Suit'] , :SECTION_ID => job['Section'] , :PROFILE =>  job['Profile'] , :BROWSERS => job['Browser']}
          puts params
          uri.query = URI.encode_www_form(params)
          res = Net::HTTP.get_response(uri)
          puts res.inspect
          response = res.body if res.is_a?(Net::HTTPSuccess)
        end
      end
      if response.nil?
        render json: {status: 500, output: 'Build Failed'}
      else
        render json: {status: 200, output: response}
      end
    rescue Exception => exp
      render json: {status: 500, output: 'Host is not reachable'}
    end
  end

  def updateJob(jobName,job)
    tempDataHolder = []
    job[:jenkinsServer].each do |server|
      jenkinsClient = connectToJenkins(server['name']);
      job['Browser'].uniq.each do |browser|
        if browser['name'].eql?(server['name'])
          puts browser['value']
          tempDataHolder.push(browser['value'])
        end
      end
      job['Browser'] = tempDataHolder.uniq.join(',')
      tempDataHolder = []
      job['Profile'].each do |profile|
        tempDataHolder.push(profile['name'])
      end
      job['Profile'] = tempDataHolder.join(',')
      tempDataHolder = []
      job['Project'].each do |project|
        tempDataHolder.push(project['id'])
      end
      job['Project'] = tempDataHolder.join(',')
      tempDataHolder = []
      job['Suit'].each do |suit|
        tempDataHolder.push(suit['id'])
      end
      job['Suit'] = tempDataHolder.join(',')
      tempDataHolder = []
      job['Section'].each do |section|
        tempDataHolder.push(section['id'])
      end
      job['Section'] = tempDataHolder.join(',')
      jobConfig = Nokogiri::XML::Document.parse(File.read("jenkins_job_config.xml")).to_s
      hashJobConfig = ActiveSupport::JSON.decode(Hash.from_xml(jobConfig).to_json)
      hashJobConfig["project"]["builders"]["hudson.tasks.BatchFile"] = {"command"=>"cd ..\n cd startRailsServer \n rspec specManager.rb"}
      #puts hashJobConfig['project']['properties']['hudson.model.ParametersDefinitionProperty']['parameterDefinitions'].to_xml(:skip_types => true , :root =>'parameterDefinitions')
      hashJobConfig['project']['properties']['hudson.model.ParametersDefinitionProperty']['parameterDefinitions']['hudson.model.StringParameterDefinition'].each do |parameter|

        if !(job[parameter['defaultValue']].nil?) && job[parameter['defaultValue']].length > 0
          parameter['defaultValue'] = job[parameter['defaultValue']]
        else
          parameter['defaultValue'] = ''
        end
      end
    temp = hashJobConfig['project'].to_xml(:skip_types => true, :skip_instruct => true, :root => 'project').to_s.gsub('nil="true"', '').sub!("<hudson.model.StringParameterDefinition>", '').split('</parameterDefinitions>')
    finalJobConfig = temp[0].strip.chomp('</hudson.model.StringParameterDefinition>') + '</parameterDefinitions>' + temp[1]
    jenkinsClient.updateJob(jobName, finalJobConfig)
    end
  end
  def deleteJob(jobName,server)
    puts "In delete"
    puts "#{server}"
    jenkinsClient = connectToJenkins(server)
    jenkinsClient.deleteJob(jobName)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_template
    @template = Template.where(:job => params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def template_params
    params.require(:template).permit(:Name, :Project, :Suit, :Section, :Browser, :Profile, :Job , :jenkinsServer)
  end
end
