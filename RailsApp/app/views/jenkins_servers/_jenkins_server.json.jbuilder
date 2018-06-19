json.extract! jenkins_server, :id, :name, :username, :password, :url, :os, :browser, :created_at, :updated_at
json.url jenkins_server_url(jenkins_server, format: :json)
