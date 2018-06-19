/*
myApp.controller('DataCtrl', ['$scope', '$http', '$routeParams', '$location', '$utils', '$postgres', '$interval', function ($scope, $http, $routeParams, $location, $utils, $postgres, $interval) {

    $scope.schedule = {'cron' : '' , 'job' : ''};
    $scope.selectedInputs = [];
    $scope.response = {'type': '', 'message': ''};
    $scope.angular = angular;
    $scope.allTemplates = [];
    $scope.salesforceInstances = [];
    $scope.selectedInstance = '';
    $scope.profiles = [];
    $scope.users = [];
    $scope.template_fields = ['Name', 'Action'];
    $scope.selectedUniqueInputs = [];
    $scope.data = {'Suit': {}, 'Section': {}, 'Project': [], 'JenkinsServer': [], 'Browser': [], 'TestRailServer': []};
    $scope.Test = {
        'Suit': [],
        'Section': [],
        'Browser': [],
        'Profile': [],
        'Project': [],
        'Name': {'name': ''},
        'jenkinsServer': [],
        'TestRailServer': '',
        'Environment': '',
        'User': [],
        'Headless' : true
    };
    $scope.action = {
        'Suit': '',
        'Section': '',
        'Profile': '',
        'modal': 'slds-fade-in-close slds-backdrop--close',
        'tooltip': 'false',
        'warning': 'slds-fade-in-close slds-backdrop--close'
    };
    /!*document.getElementById("myValue").innerText = document.getElementById("uplodedFile").value;
    var fullPath = document.getElementById("uplodedFile").value;
    alert(fullPath.lastIndexOf("\\"))
    document.getElementById("path").innerText = fullPath.substring(0,fullPath.lastIndexOf("\\"));*!/
    $scope.selectedItem = '';
    console.log($scope.Test['jenkinsServer'])
    $scope.getTestRailData = function (dataToGet, item, id) {
        $http.get(window.location.origin + '/getTestRailData/' + dataToGet + '&' + item + '&' + id)
            .then(function (response) {
                if (item == 'Project') {
                    $scope.data['Project'] = response['data']['output'];
                }
                else {
                    /!*if(item == 'Section') {*!/
                    if (!(angular.equals($scope.data[item], response['data']['output'])) && !(angular.equals($scope.data[item], {}))) {
                        console.log(response['data']['output'])
                        $scope.data[item] = $scope.data[item].concat(response['data']['output']);
                        console.log($scope.data[item])
                    }
                    else
                        $scope.data[item] = response['data']['output'];
                    console.log($scope.data[item]);
                }
            });
    }

    $scope.init = function () {
        $postgres.getAllRecords('environments/1/edit').then(function (response) {
            $scope.salesforceInstances = response;
            $scope.Test['Environment'] = $scope.salesforceInstances[0];
            $scope.getProfiles($scope.Test['Environment']);
        });
        $postgres.getAllRecords('templates').then(function (response) {
            $scope.allTemplates = response;
        });


        $postgres.getAllRecords('jenkins_servers' + '/1' + '/edit').then(function (result) {
            console.log($scope.data['JenkinsServer']);
            $scope.data['JenkinsServer'] = result;
        })
        $postgres.getAllRecords('getServers' + '/testrail').then(function (response) {
            $scope.data['TestRailServer'] = response;
            $scope.Test['TestRailServer'] = response[0];
            $postgres.getAllRecords('getTestRail/' + $scope.Test['TestRailServer']).then(function (response) {
                $scope.getTestRailData('', 'Project');
            });
        });

    }
    $scope.init();

    $scope.removeSelectedItem = function (event, item) {
        $scope.Test[item].splice($scope.Test[item].indexOf({'id': event.target.id, 'name': event.target.name}), 1)
        $scope.selectedUniqueInputs.splice($scope.selectedUniqueInputs.indexOf(event.target.id), 1)
        $scope.action[item] = 'slds-is-close'
    }

    $scope.addSelectedOptions = function (event, item) {
        console.log(event.target.checked)
        if (item == 'Browser')
            if (!(event.target.checked)) {

                $scope.removeSelectedItem(event, item);
                return
            }
        angular.equals($scope.Test[item])
        if ($scope.selectedUniqueInputs.indexOf(event.target.id) < 0) {
            $scope.selectedUniqueInputs.push(event.target.id)
            $scope.Test[item].push({'id': event.target.id, 'name': event.target.name});
            $scope.action[item] = 'slds-is-close'
            if (($scope.Test['Suit'].length > 0) && (item === 'Suit'))
                $scope.getTestRailData(event.target.id, 'Section')
        }
    }

    $scope.$watch("Test.Suit", function (newValue, oldValue) {
        console.log(newValue)
        if (newValue.length < oldValue.length) {
            if (newValue.length == 0) {
                $scope.Test['Section'] = [];
                $scope.data['Section'] = [];
            }
            else
                for (value in newValue)
                    $scope.getTestRailData(newValue[value].id, 'Section', newValue[newValue.length - 1].project_id)
        }
        if (!(angular.equals(newValue, oldValue)) && (newValue.length > oldValue.length)) {
            $scope.getTestRailData(newValue[newValue.length - 1].id, 'Section', newValue[newValue.length - 1].project_id)
        }
    }, true);
    $scope.$watch("schedule.cron", function (newValue, oldValue) {
        if(newValue) {
            $utils.showProcessing();
            $postgres.getRecord('schedule', $scope.schedule['job'] + '&' + newValue).then(function (response) {
                response['data']
                if (response['data']['status'] !== 200) {
                    $utils.hideProcessing();
                    $utils.showError('Scheduled Failed');
                }
                else {
                    $utils.showSuccess('Template scheduled successfully!');
                }
            });
        }
    }, true);
    $scope.$watch("Test.TestRailServer", function (newValue, oldValue) {
        if (newValue)
            $scope.getTestRailData($scope.Test['TestRailServer'], 'Project');
    }, true);
    $scope.$watch("Test.jenkinsServer", function (newValue, oldValue) {
        if (newValue.length == 0) {
            $scope.data['Browser'] = [];
            return;
        }
        if (newValue.length > oldValue.length) {
            $scope.data['Browser'] = [];
            for (value in newValue)
                $postgres.getRecord('jenkins_servers', newValue[value]['name']).then(function (response) {
                    var tempPairHolder = {};
                    tempPairHolder["name"] = newValue[value]['name'];
                    tempPairHolder["value"] = response['browser'];
                    $scope.data['Browser'].push(tempPairHolder);
                });
        }
        else
            for (value in newValue) {
                $scope.data['Browser'] = [];
                $postgres.getRecord('jenkins_servers', newValue[value]['name']).then(function (response) {
                    var tempPairHolder = {};
                    tempPairHolder["name"] = newValue[value]['name'];
                    tempPairHolder["value"] = response['browser'];
                    $scope.data['Browser'].push(tempPairHolder);
                });
            }


    }, true);
    $scope.$watch("Test.Environment", function (newValue, oldValue) {
        if (newValue.length == 0) {
            $scope.users = [];
            $scope.profiles = [];
            return;
        }
        if (newValue.length > oldValue.length) {
            $postgres.getRecord('getProfiles', newValue).then(function (response) {
                if ($scope.profiles.length == 0)
                    $scope.profiles = response;
                else
                    $scope.profiles.concat(response);
            });
            $postgres.getRecord('getUsers', newValue).then(function (response) {
                if ($scope.users.length == 0)
                    $scope.users = response;
                else
                    $scope.users.concat(response);
            });
        } else {
            $scope.profiles = []
            $postgres.getRecord('getProfiles', oldValue).then(function (response) {
                if ($scope.profiles.length == 0)
                    $scope.profiles = response;
                else
                    $scope.profiles.concat(response);
            });
            $postgres.getRecord('getUsers', oldValue).then(function (response) {
                if ($scope.users.length == 0)
                    $scope.users = response;
                else
                    $scope.users.concat(response);
            });
        }
    }, true);
    $scope.$watch("Test.Project", function (newValue, oldValue) {
        console.log(newValue)
        if (newValue.length < oldValue.length) {
            if (newValue.length == 0) {
                $scope.Test['Suit'] = [];
                $scope.data['Suit'] = [];
            }
            else
                for (value in newValue)
                    $scope.getTestRailData(newValue[value].id, 'Suit')
        }
        if (!(angular.equals(newValue, oldValue)) && (newValue.length > oldValue.length))
            $scope.getTestRailData(newValue[newValue.length - 1].id, 'Suit')
    }, true);

    $scope.insertTest = function () {
        console.log($scope.Test)
        $scope.Test['Name']['name'] = $scope.Test['Project'][0]['name'] + '-Template' + ($scope.allTemplates.length + 1);
        $postgres.insertRecord('templates', $scope.Test).then(function (result) {
            $scope.allTemplates = result;
            $scope.action['modal'] = "slds-fade-in-close slds-backdrop--close";
            $scope.Test['Suit'] = []; $scope.Test['Section'] = []; $scope.Test['Browser'] = []; $scope.Test['Profile'] = []; $scope.Test['Project'] = []; $scope.Test['Name'] = {'name': ''} ; $scope.Test['jenkinsServer'] = '' ; $scope.Test['User'] = [];
        })

    }

    $scope.getProfiles = function (selectedInstance) {
        /!*$scope.profiles = $postgres.getRecord('getProfiles',selectedInstance);*!/
        $postgres.getRecord('getProfiles', selectedInstance).then(function (response) {
            $scope.profiles = response;
        });
    }

    $scope.getData = function (options) {
        if (options == 'Templates')
            $postgres.getAllRecords('getTemplates').then(function (response) {
                $scope.allTemplates = response;
            });
    }

    $scope.buildJob = function (jobName) {
        console.log(jobName)
        $utils.showProcessing();
        $http.get(window.location.origin + '/buildJob/' + jobName +'&'+$scope.Test['Headless'])
            .then(function (response) {
                $utils.hideProcessing();
                if (response['data']['status'] !== 200)
                    $utils.showError('Build Failed');
                else {
                    $utils.showSuccess('Build Run successfully ! with build number '+response['data']['output']);
                }
            });
    }
    $scope.deleteTemplate = function (id) {
        console.log(id);
        $postgres.deleteRecord('templates', id).then(function (response) {
            console.log($scope.allTemplates)
            $scope.allTemplates = response
        })
    }
    $scope.cloneTemplate = function (id) {
        $postgres.getRecord('templates', id + '/edit').then(function (result) {
            console.log(result);
            for (var test in $scope.Test) {
                $scope.Test[test] = result[test];
            }
            $scope.Test['Job'] = '';
            $scope.Test['Name']['name'] = $scope.Test['Project'][0]['name'] + '-Template' + ($scope.allTemplates.length + 1);
            $scope.Test['id'] = '';
            $scope.Test['jenkinsServer'] = result[''];
            $scope.action['modal'] = "slds-fade-in-open slds-backdrop--open";
        })
    }
    $scope.editTemplate = function (id) {
        $postgres.getRecord('templates', id + '/edit').then(function (result) {
            for (var test in $scope.Test) {
                $scope.Test[test] = result[test];
            }
            $scope.Test['Job'] = result['Job'];
            $scope.Test['id'] = result['id'];
            $scope.Test['Environment'] = result['Environment'];
            $scope.Test['TestRailServer'] = result['TestRailServer'];
            console.log($scope.Test);
            $scope.action['modal'] = "slds-fade-in-open slds-backdrop--open";
        })
    }

}]);

/!*
   $scope.runSpec = function () {
       if($scope.selectedInputs.length > 0)
       var config = {
           params: {
               User:"User",
               profiles: $scope.selectedInputs
           }
       }
       $http.get('http://localhost:3000/getParams')
           .then(function (response) {
               alert('relghe')
               console.log('response',response.data['output']);
               $scope.runId  = response.data['output']['RUN_ID'][0]
               });
       $http.get('http://localhost:3000/getdata/runspec',config)
           .then(function (response) {
               console.log('response',response.data);

               window.location.href = "https://enzigma.testrail.io/index.php?/runs/view/"+$scope.runId;
           });
   }
   $scope.removeSelectedItem = function(event){
       $scope.selectedInputs.splice($scope.selectedInputs.indexOf(event.target.id),1)
   }
   $scope.addSelectedOptions = function(){
       alert('called')
       /!*if($scope.selectedInputs.indexOf(event.target.id) < 0 )
           $scope.selectedInputs.push(event.target.id);*!/
           //$scope.selectedInputs.splice($scope.selectedInputs.indexOf(event.target.id),1
       console.log($scope.selectedInputs);
   }
   $http.get('http://localhost:3000/getdata/'+$routeParams.dataToGet)
           .then(function (response) {
               $scope.title = $routeParams.dataToGet;
               $scope.data = response['data']['output'];
               $scope.allData = response['data']['output'];
               $scope.tabSelected = true;
               $scope.totalPageSize = Math.trunc($scope.allData.length/$scope.pageSize);
           });*!/
*/
myApp.controller('DataCtrl',['$scope','$http','$routeParams','$location','$utils','$postgres','$interval',function($scope,$http,$routeParams,$location,$utils,$postgres,$interval){$scope.schedule={'cron':'','job':''};$scope.selectedInputs=[];$scope.response={'type':'','message':''};$scope.angular=angular;$scope.allTemplates=[];$scope.salesforceInstances=[];$scope.selectedInstance='';$scope.profiles=[];$scope.users=[];$scope.template_fields=['Name','Action'];$scope.selectedUniqueInputs=[];$scope.data={'Suit':{},'Section':{},'Project':[],'JenkinsServer':[],'Browser':[],'TestRailServer':[]};$scope.setting={'name':'','value':''};$scope.Test={'Suit':[],'Section':[],'Browser':[],'Profile':[],'Project':[],'Name':{'name':''},'jenkinsServer':[],'TestRailServer':'','Environment':'','User':[],'Headless':true};$scope.action={'Suit':'','Section':'','Profile':'','modal':'slds-fade-in-close slds-backdrop--close','tooltip':'false','warning':'slds-fade-in-close slds-backdrop--close'};$scope.selectedItem='';console.log($scope.Test['jenkinsServer'])
    $scope.getTestRailData=function(dataToGet,item,id){$http.get(window.location.origin+'/getTestRailData/'+dataToGet+'&'+item+'&'+id).then(function(response){if(item=='Project'){$scope.data['Project']=response['data']['output'];}
    else{if(!(angular.equals($scope.data[item],response['data']['output']))&&!(angular.equals($scope.data[item],{}))){console.log(response['data']['output'])
        $scope.data[item]=$scope.data[item].concat(response['data']['output']);console.log($scope.data[item])}
    else
        $scope.data[item]=response['data']['output'];console.log($scope.data[item]);}});}
    $scope.init=function(){$postgres.getAllRecords('environments/1/edit').then(function(response){$scope.salesforceInstances=response;$scope.Test['Environment']=$scope.salesforceInstances[0];$scope.getProfiles($scope.Test['Environment']);});$postgres.getAllRecords('templates').then(function(response){$scope.allTemplates=response;});$postgres.getAllRecords('jenkins_servers'+'/1'+'/edit').then(function(result){console.log($scope.data['JenkinsServer']);$scope.data['JenkinsServer']=result;})
        $postgres.getAllRecords('getServers'+'/testrail').then(function(response){$scope.data['TestRailServer']=response;$scope.Test['TestRailServer']=response[0];$postgres.getAllRecords('getTestRail/'+$scope.Test['TestRailServer']).then(function(response){$scope.getTestRailData('','Project');});});}
    $scope.init();$scope.removeSelectedItem=function(event,item){$scope.Test[item].splice($scope.Test[item].indexOf({'id':event.target.id,'name':event.target.name}),1);$scope.selectedUniqueInputs.splice($scope.selectedUniqueInputs.indexOf(event.target.id),1);$scope.action[item]='slds-is-close';}
    $scope.addSelectedOptions=function(event,item){console.log(event.target.checked);if(item=='Browser')
        if(!(event.target.checked)){$scope.removeSelectedItem(event,item);return}
        angular.equals($scope.Test[item]);if($scope.selectedUniqueInputs.indexOf(event.target.id)<0){$scope.selectedUniqueInputs.push(event.target.id);$scope.Test[item].push({'id':event.target.id,'name':event.target.name});$scope.action[item]='slds-is-close';if(($scope.Test['Suit'].length>0)&&(item==='Suit'))
            $scope.getTestRailData(event.target.id,'Section');}}
    $scope.$watch("Test.Suit",function(newValue,oldValue){console.log(newValue);if(newValue.length<oldValue.length){if(newValue.length==0){$scope.Test['Section']=[];$scope.data['Section']=[];}
    else
        for(value in newValue)
            $scope.getTestRailData(newValue[value].id,'Section',newValue[newValue.length-1].project_id);}
        if(!(angular.equals(newValue,oldValue))&&(newValue.length>oldValue.length)){$scope.getTestRailData(newValue[newValue.length-1].id,'Section',newValue[newValue.length-1].project_id)}},true);$scope.$watch("schedule.cron",function(newValue,oldValue){if(newValue){$utils.showProcessing();$postgres.getRecord('schedule',$scope.schedule['job']+'&'+newValue).then(function(response){console.log(response);$utils.hideProcessing();if(response == ''){$utils.showError('Scheduled Failed');}
    else{$utils.showSuccess('Template scheduled successfully!');$scope.allTemplates=response;$scope.openSchedular  = 'slds-slide-up-close slds-backdrop--close' ;}});}},true);$scope.$watch("Test.TestRailServer",function(newValue,oldValue){if(newValue)
        $scope.getTestRailData($scope.Test['TestRailServer'],'Project');},true);$scope.$watch("Test.jenkinsServer",function(newValue,oldValue){if(newValue.length==0){$scope.data['Browser']=[];return;}
        if(newValue.length>oldValue.length){$scope.data['Browser']=[];for(value in newValue)
            $postgres.getRecord('jenkins_servers',newValue[value]['name']).then(function(response){var tempPairHolder={};tempPairHolder["name"]=newValue[value]['name'];tempPairHolder["value"]=response['browser'];$scope.data['Browser'].push(tempPairHolder);});}
        else
            for(value in newValue){$scope.data['Browser']=[];$postgres.getRecord('jenkins_servers',newValue[value]['name']).then(function(response){var tempPairHolder={};tempPairHolder["name"]=newValue[value]['name'];tempPairHolder["value"]=response['browser'];$scope.data['Browser'].push(tempPairHolder);});}},true);$scope.$watch("Test.Environment",function(newValue,oldValue){if(newValue.length==0){$scope.users=[];$scope.profiles=[];return;}
        if(newValue.length>oldValue.length){$postgres.getRecord('getProfiles',newValue).then(function(response){if($scope.profiles.length==0)
            $scope.profiles=response;else
            $scope.profiles.concat(response);});$postgres.getRecord('getUsers',newValue).then(function(response){if($scope.users.length==0)
            $scope.users=response;else
            $scope.users.concat(response);});}else{$scope.profiles=[];$postgres.getRecord('getProfiles',oldValue).then(function(response){if($scope.profiles.length==0)
            $scope.profiles=response;else
            $scope.profiles.concat(response);});$postgres.getRecord('getUsers',oldValue).then(function(response){$scope.users.length==0?$scope.users=response:$scope.users.concat(response);});}},true);$scope.$watch("Test.Project",function(newValue,oldValue){console.log(newValue);if(newValue.length<oldValue.length){if(newValue.length==0){$scope.Test['Suit']=[];$scope.data['Suit']=[];}
    else
        for(value in newValue)
            $scope.getTestRailData(newValue[value].id,'Suit')}
        if(!(angular.equals(newValue,oldValue))&&(newValue.length>oldValue.length))
            $scope.getTestRailData(newValue[newValue.length-1].id,'Suit')},true);$scope.insertTest=function(){console.log($scope.Test)
        $scope.Test['Name']['name']=$scope.Test['Project'][0]['name']+'-Template'+($scope.allTemplates.length+1);$postgres.insertRecord('templates',$scope.Test).then(function(result){if(result != null){$scope.allTemplates=result;$scope.action['modal']="slds-fade-in-close slds-backdrop--close";$scope.Test['Suit']=[];$scope.Test['Section']=[];$scope.Test['Browser']=[];$scope.Test['Profile']=[];$scope.Test['Project']=[];$scope.Test['Name']={'name':''};$scope.Test['jenkinsServer']='';$scope.Test['User']=[];}})}
    $scope.getProfiles=function(selectedInstance){$postgres.getRecord('getProfiles',selectedInstance).then(function(response){$scope.profiles=response;});}
    $scope.getData=function(options){if(options=='Templates')
        $postgres.getAllRecords('getTemplates').then(function(response){$scope.allTemplates=response;});}
    $scope.buildJob=function(jobName){console.log(jobName);$utils.showProcessing();$http.get(window.location.origin+'/buildJob/'+jobName+'&'+$scope.Test['Headless']).then(function(response){$utils.hideProcessing();if(response['data']['status']!==200)
        $utils.showError('Build Failed');else{$utils.showSuccess('Build Run successfully ! with build number '+response['data']['output']);}});}
    $scope.deleteTemplate=function(id){console.log(id);$postgres.deleteRecord('templates',id).then(function(response){console.log($scope.allTemplates);$scope.allTemplates=response});}
    $scope.cloneTemplate=function(id){$postgres.getRecord('templates',id+'/edit').then(function(result){console.log(result);for(var test in $scope.Test){$scope.Test[test]=result[test];}
        $scope.Test['Job']='';$scope.Test['Name']['name']=$scope.Test['Project'][0]['name']+'-Template'+($scope.allTemplates.length+1);$scope.Test['id']='';$scope.Test['jenkinsServer']=result[''];$scope.action['modal']="slds-fade-in-open slds-backdrop--open";})}
    $scope.editTemplate=function(id){$postgres.getRecord('templates',id+'/edit').then(function(result){for(var test in $scope.Test){$scope.Test[test]=result[test];}
        $scope.Test['Job']=result['Job'];$scope.Test['id']=result['id'];$scope.Test['Environment']=result['Environment'];$scope.Test['TestRailServer']=result['TestRailServer'];console.log($scope.Test);$scope.action['modal']="slds-fade-in-open slds-backdrop--open";})}}]);
