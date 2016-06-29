alchemy.controller("DashboardController", ['$rootScope', '$scope', '$stateParams', '$http', 'enrolledCourses', 'Auth', 'Util',
    function($root, $scope, $stateParams, $http, enrolledCourses, Auth, Util) {
        $scope.courses = enrolledCourses;

        $scope.setInstructorPermission = function() {
          return $http.put('/users/elevate_to_instructor.json', $scope.targetUser).then(function(data) {
            Util.showAlert('success', data.data.success);
            $scope.targetUser.email = "";
          }, function(error) {
            Util.showAlert('danger', error.data.failure);
            $scope.targetUser.email = "";
          });
        };

        $scope.access = function() {
          var payload = { access_code: $scope.accessCode };

          return $http.put('/courses/enroll', payload).then(function(resp) {
            Util.showAlert('success', "You have been successfully enrolled.");
            $scope.accessCode = "";
            $scope.courses.push(resp.data);
          }, function(error) {
            if (error.data.error) {
              Util.showAlert('danger', error.data.error);
            }
            else {
              Util.showAlert('danger', error.data.user_id[0]);
            }
          });
        };
    }]);
