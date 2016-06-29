
alchemy.controller("NavController", ['$location', '$rootScope', '$scope', '$state', '$stateParams', 'Auth', function($location, $rootScope, $scope, $state, $stateParams, Auth) {

  $scope.signedIn = Auth.isAuthenticated;

  $scope.logout = Auth.logout;

  $scope.$on('devise:logout', function() {
    $rootScope.currentUser = {};
    $state.go("login");
  });

  $scope.isActive = function(path) {
    return $location.path().substr(0, path.length) == path;
  };

}]);
