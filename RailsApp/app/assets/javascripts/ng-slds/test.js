var app = angular.module("testapp", ["directive-factory","service-factory"]);
app.controller("testcontroller", ["$scope", "$utils", function ($scope, $utils) {
    $scope.options = ["abc", "xyz", "pqr"];
    $scope.meta = [{ "name": "Id", "label": "Id" }, { "name": "Name", "label": "Name" }];
    $scope.data = [{ "Id": "1", "Name": "Ajay" }, { "Id": "2", "Name": "Sneha" }];
    $scope.treedata = [{ "id": "1", "label": "node1", "childs": [{ "id": "3", "label": "node3" }, { "id": "4", "label": "node4" }] }, { "id": "2", "label": "node2", "childs": [{ "id": "5", "label": "node5" }, { "id": "6", "label": "node6" }] }];
}])