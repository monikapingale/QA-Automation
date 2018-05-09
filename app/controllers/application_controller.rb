class ApplicationController < ActionController::API
 
 #before_filter :add_allow_credentials_headers, only: [:options]
 #def add_allow_credentials_headers
 #response.headers['Access-Control-Allow-Origin'] = request.headers['Origin'] || '*'
 #    response.headers['Access-Control-Allow-Credentials'] = 'true'
 #   response.headers['Access-Control-Allow-Headers'] = 'accept, content-type'
 #end
 
 #def options
 #   head :ok
 #end
    
    def index
        uri    = URI.parse(request.url)
        params = CGI.parse(uri.query)
        # params is now {"id"=>["4"], "empid"=>["6"]}
        
        #id     = params['id'].first
        #puts params
        projectId = params['PROJECT_ID'][0]
        suitId = params['SUIT_ID'][0]
        
        sectionId = params['SECTION_ID'][0]
        
        caseId = params['CASE_ID'][0]
        
        runId = params['RUN_ID'][0]
        
        browsers = params['BROWSERS'][0]
        
        ENV['RUN_ID']= runId
        pid = spawn("ruby /Users/sachin.chavan/.jenkins/workspace/StartRailsServer/specManager.rb project:#{projectId} suit:#{suitId} section:#{sectionId} case:#{caseId} browser:#{browsers}")
        puts "#{pid}"
        Process.detach(pid)
        #var = exec( "ruby /Users/sachin.chavan/.jenkins/workspace/TeamQA-BuildRubyScriptManually/specManager.rb project:#{projectId} suit:#{suitId} section:#{sectionId} case:#{caseId} browser:'#{browsers}'" )
        render json: { status: 200, output:params}
 
    end
end
