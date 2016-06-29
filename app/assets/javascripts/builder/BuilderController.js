alchemy.controller("BuilderController", ['$scope', '$http', 'Auth', 'scenarios', function($scope, $http, Auth, scenarios) {
  $scope.scenarios = scenarios;
  $scope.user = Auth.currentUser();
}]);
