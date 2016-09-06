
alchemy.controller("AuthController", ['$rootScope', '$scope', '$state', '$stateParams', 'Auth', 'Util', 'universities',
    function($rootScope, $scope, $state, $stateParams, Auth, Util, universities) {

  $scope.user = {};

  $scope.universities = universities;
  

  $scope.login = function() {
    Auth.login($scope.user).then(function(){
      $state.go('dashboard');
    }, function(error) {
        Util.showAlert('danger', error.error);
    });
  };
  
  $scope.forgot = function() {
    Auth.sendResetPasswordInstructions($scope.user);
    //.then(function() {
      //$state.go('loginForm');
   // });
};
  $scope.signup = function() {

    $scope.user.university_id = $scope.universities.selected.id;
    Auth.register($scope.user).then(function(){
      $state.go('dashboard');

    }, function(error) {
        Util.showRegistrationError(error);
    });
  };

  $scope.$on('devise:unauthorized', function(event, xhr, deferred) {
    var error = xhr.data.error;
    Util.showAlert('danger', error);
  });
}]);
