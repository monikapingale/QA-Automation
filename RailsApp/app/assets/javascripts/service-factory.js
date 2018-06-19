/*
var app = angular.module("service-factory", []);
app.service("$utils", ["$rootScope", "$compile", function ($scope, $compile) {
    this.getServerUrl = function () {
        return location.origin;
    }
    this.showProcessing = function () {
        $('body').append($compile("<we-spinner></we-spinner>")($scope));
    }
    this.hideProcessing = function () {
        $('we-spinner').remove();
    }
    this.showInfo = function (messege) {
        $('body').append($compile('<we-toaster type="info" messege="' + messege + '"></we-toaster>')($scope));
    }
    this.showSuccess = function (messege) {
        $('body').append($compile('<we-toaster type="success" messege="' + messege + '"></we-toaster>')($scope));
    }
    this.showError = function (messege) {
        $('body').append($compile('<we-toaster type="error" messege="' + messege + '"></we-toaster>')($scope));
    }
    this.showWarning = function (messege) {
        $('body').append($compile('<we-toaster type="warning" messege="' + messege + '"></we-toaster>')($scope));
    }
}])
app.service("$salesforce", function ($utils) {
    this.execute = function () {
        arguments[0] = "{!RemoteAction" + arguments[0] + "}";
        var onsuccess = arguments[arguments.length - 2];
        var onerror = arguments[arguments.length - 1];
        arguments.splice(arguments.length - 2, 1);
        arguments.splice(arguments.length - 1, 1);
        Visualforce.remoting.Manager.invokeAction(Visualforce.remoting.Manager, arguments, function (result, event) {
            if (event.status){
                onsuccess.apply(result);
            }else {
                if (onerror) {
                    onerror(event.message);
                } else {
                    $utils.showError(event.message);
                }
            }
        });
    }
})
app.service("$postgres", ["$rootScope", "$compile", "$http" ,'$utils','$q',function ($scope, $compile , $http,$utils,$q) {
    this.getAllRecords = function (entity) {
       return  $http.get(window.location.origin+'/'+entity)
            .then(function (response) {
                console.log(response['data']['output']);
                return response['data']['output'];
            });
    }
    this.getRecord = function (entity,id) {
        return $http.get(window.location.origin+'/'+entity+'/'+id )
            .then(function (response) {
                console.log(response['data']['output']);
                return response['data']['output'];
            });
    }
    this.insertRecord = function (table,record) {
            $utils.showProcessing();
            return $http.post(window.location.origin+'/'+table,JSON.stringify(record) ).then(function (response) {
                $utils.hideProcessing();
                if(response['data']['status'] !== 200)
                    $utils.showError(response['data']['output']);
                else {
                    $utils.showSuccess('Record Inserted successfully !');
                    return response['data']['output'];
                }
            });
    }
    this.deleteRecord = function (table,recordId) {
        $utils.showProcessing();
        return $http.delete(window.location.origin+'/'+table+'/'+recordId).then(function (response) {
            $utils.hideProcessing();
            if(response['data']['status'] !== 200)
                $utils.showError('Invalid Id');
            else {
                $utils.showSuccess('Record Deleted successfully !');
                return response['data']['output'];
            }
        });
    }

}])*/
var app=angular.module("service-factory",[]);app.service("$utils",["$rootScope","$compile",function($scope,$compile){this.getServerUrl=function(){return location.origin;}
    this.showProcessing=function(){$('body').append($compile("<we-spinner></we-spinner>")($scope));}
    this.hideProcessing=function(){$('we-spinner').remove();}
    this.showInfo=function(messege){$('body').append($compile('<we-toaster type="info" messege="'+messege+'"></we-toaster>')($scope));}
    this.showSuccess=function(messege){$('body').append($compile('<we-toaster type="success" messege="'+messege+'"></we-toaster>')($scope));}
    this.showError=function(messege){$('body').append($compile('<we-toaster type="error" messege="'+messege+'"></we-toaster>')($scope));}
    this.showWarning=function(messege){$('body').append($compile('<we-toaster type="warning" messege="'+messege+'"></we-toaster>')($scope));}}])
app.service("$salesforce",function($utils){this.execute=function(){arguments[0]="{!RemoteAction"+arguments[0]+"}";var onsuccess=arguments[arguments.length-2];var onerror=arguments[arguments.length-1];arguments.splice(arguments.length-2,1);arguments.splice(arguments.length-1,1);Visualforce.remoting.Manager.invokeAction(Visualforce.remoting.Manager,arguments,function(result,event){if(event.status){onsuccess.apply(result);}else{if(onerror){onerror(event.message);}else{$utils.showError(event.message);}}});}})
app.service("$postgres",["$rootScope","$compile","$http",'$utils','$q',function($scope,$compile,$http,$utils,$q){this.getAllRecords=function(entity){return $http.get(window.location.origin+'/'+entity).then(function(response){console.log(response['data']['output']);return response['data']['output'];});}
    this.getRecord=function(entity,id){return $http.get(window.location.origin+'/'+entity+'/'+id).then(function(response){console.log(response['data']['output']);return response['data']['output'];});}
    this.insertRecord=function(table,record,isUpdate){$utils.showProcessing();return $http.post(window.location.origin+'/'+table,JSON.stringify(record)).then(function(response){$utils.hideProcessing();if(response['data']['status']!==200)
        $utils.showError(response['data']['output']);else{isUpdate ? $utils.showSuccess('Record Inserted successfully !'): $utils.showSuccess('Record Inserted successfully !');return response['data']['output'];}});}
    this.deleteRecord=function(table,recordId){$utils.showProcessing();return $http.delete(window.location.origin+'/'+table+'/'+recordId).then(function(response){$utils.hideProcessing();if(response['data']['status']!==200)
        $utils.showError('Invalid Id');else{$utils.showSuccess('Record Deleted successfully !');return response['data']['output'];}});}}])