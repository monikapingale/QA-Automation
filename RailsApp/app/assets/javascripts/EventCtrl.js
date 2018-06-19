/*myApp.controller('EventCtrl',['$scope','$http', function($scope,$http) {
    $scope.listItems = [{'url' : '#!templates','label' : 'Templates' , 'icon' : 'fas fa-copy','isActive':'active'},{'url' : '#!scheduledTemplates', 'label' : 'Scheduled Templates', 'icon' : 'fas fa-calendar-alt','isActive':''},{'url' : '#!instances', 'label' : 'Environments', 'icon' : 'fab fa-envira','isActive':''},{'url' : '#!testRail', 'label' : 'TestRail', 'icon' : 'fas fa-copy','isActive':''},{'url' : '#!allSettings', 'label' : 'Settings', 'icon' : 'fas fa-cogs','isActive':''},{'url' : '#!jenkins', 'label' : 'Jenkins Servers', 'icon' : 'fab fa-jenkins','isActive':''},{'url' : '#!specs', 'label' : 'Generate spec structure', 'icon' : 'fas fa-pen-square','isActive':''}]
    /!* $scope.arrProfiles = [];
    $scope.selectedInputs = [];
    $scope.pageSize = 5;
    $scope.pageSizes = [5,10,20,50,100];
    $scope.offset = $scope.pageSize;
    $scope.allData = [];
    $scope.runId = "";
    $scope.tabSelected = false;
    $scope.page = Math.floor($scope.offset/$scope.offset);
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
    $scope.addSelectedOptions = function(event){
        if($scope.selectedInputs.indexOf(event.target.id) < 0 )
            $scope.selectedInputs.push(event.target.id);
            //$scope.selectedInputs.splice($scope.selectedInputs.indexOf(event.target.id),1)
        console.log($scope.selectedInputs);
    }
    $scope.setPagesize = function(){
        $scope.offset = $scope.pageSize;
    }
    $scope.first = function(){
        $scope.data = $scope.allData;
        $scope.offset = 0
        $scope.page = 1
    }
    $scope.last = function(){
        $scope.data = $scope.allData;
        $scope.offset = (Math.trunc($scope.allData.length/$scope.pageSize))*$scope.pageSize;
        $scope.data = $scope.data.slice((Math.trunc($scope.allData.length/$scope.pageSize))*$scope.pageSize);
        $scope.page = $scope.totalPageSize
    }

    $scope.next = function(){
        $scope.data = $scope.allData;
        $scope.offset = $scope.offset + $scope.pageSize;
        console.log($scope.pageSize)
        $scope.data = $scope.data.slice($scope.offset);
        $scope.page ++;
    }
    $scope.previous = function(){
        $scope.data = $scope.allData;
        if($scope.offset >= $scope.allData.length) {
            $scope.offset = $scope.offset - ($scope.pageSize+$scope.pageSize);
            $scope.data = $scope.data.slice($scope.offset);
        }
        else {
            $scope.data = $scope.data.slice($scope.offset);
            $scope.offset = $scope.offset - $scope.pageSize;
        }
        $scope.page --;
    }
	$scope.getData = function (dataToGet) {
          $http.get('http://localhost:3000/getdata/'+dataToGet)
              .then(function (response) {

                  $scope.title = dataToGet;
                  $scope.data = response['data']['output'];
                  $scope.allData = response['data']['output'];
                  $scope.tabSelected = true;
                  $scope.totalPageSize = Math.trunc($scope.allData.length / $scope.pageSize);
              });
      }

*!/

}]);*/
myApp.controller('EventCtrl',['$scope','$http',function($scope,$http){$scope.angular=angular;$scope.listItems=[{'url':'#!templates','label':'Templates','icon':'fas fa-copy','isActive':'active'},{'url':'#!scheduledTemplates','label':'Scheduled Templates','icon':'fas fa-calendar-alt','isActive':''},{'url':'#!instances','label':'Environments','icon':'fab fa-envira','isActive':''},{'url':'#!testRail','label':'TestRail','icon':'fas fa-copy','isActive':''},{'url':'#!allSettings','label':'Settings','icon':'fas fa-cogs','isActive':''},{'url':'#!jenkins','label':'Jenkins Servers','icon':'fab fa-jenkins','isActive':''},{'url':'#!specs','label':'Generate spec structure','icon':'fas fa-pen-square','isActive':''}];$scope.action = false;$scope.hidePopup = function(){setTimeout(function(){$scope.action = false;$scope.$apply();},100);}}]);
