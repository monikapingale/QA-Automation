json.extract! credential, :id, :username, :password, :type, :hostName, :created_at, :updated_at
json.url credential_url(credential, format: :json)
