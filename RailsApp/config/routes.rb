Rails.application.routes.draw do

  resources :environments
  resources :settings
  resources :credentials
  resources :credentails
  resources :templates
  resources :users
  resources :posts
  root 'getdata#home'
  match "generateSpec" => "getdata#generateSpec", :via => :post, :as => :generateSpec
  get "downloadZip/:zip" , to: "getdata#sendZip"
  get "deactivate/:user_id", to: "users#deactivate"
  get "scheduledTemplates" , to: "templates#scheduledTemplates"
  get 'schedule/:job' , to: "templates#scheduleJob"
  get "getServers/:id" , :to => 'credentials#getServers'
  get "pauseJob/:job" , :to => 'templates#pauseJob'
  get 'getTestRail/:username' , :to => 'getdata#connectToTestRail'
  get 'logout' , :to  => 'getdata#logout'
  get 'jenkins_servers/:id' , :to => 'jenkins_servers#show'
  get 'app' , :to => 'dashboard#index'
  get 'insertTemplates' , :to => 'templates#create'
  get 'users' , :to => 'users#index'
  get 'getTemplates' , :to => 'templates#get'
  get 'autherize', :to => 'getdata#authorize'
  get 'getProfiles/:instance', :to => 'salesforce#getProfiles'
  get 'getUsers/:instance', :to => 'salesforce#getUsers'
  get 'buildJob/:options', :to => 'templates#runJob'
  #get 'deleteRow/:options', :to => 'getdata#deleteRow'
  #get 'application', :to => 'getdata#home'
  #get 'generateSpec/:specInfo' , to: "getdata#generateSpec"
  get 'application/advancedOptions', :to => 'dashboard#index'
  get 'goToApp', :to => 'getdata#goToApp'
  #get 'getdata/runspec', :to => 'getdata#runSpec'
  #get 'getParams' , :to => 'getdata#getParams'
  #get 'readFile' , :to => 'getdata#readFile'
  get 'getTestRailData/:dataToGet' , :to => 'getdata#getFromTestRail'
  #get 'getSalesforceInstances' , :to => 'getdata#getSalesforceInstances'
  #get 'insertData/:dataToInsert' , :to => 'getdata#insertData'
  resources :jenkins_servers
  get '*path' => 'application#index'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
