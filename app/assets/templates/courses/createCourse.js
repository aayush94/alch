alchemy.directive('createCourse', ['CourseApiClient', 'Util',
    function(CourseApiClient, Util) {
        return {
            restrict: 'E',
            templateUrl: 'courses/_create-course-form.html',
            controller: ['$scope', '$element', function($scope, $element) {
                $scope.createCourse = function(course) {
                    return CourseApiClient.createCourse(course).then(function(data) {
                        Util.showAlert('success', 'Created course ' + data.title);
                        $scope.courses.push(data);
                        $scope.course.title = "";
                    }, function(error) {
                        Util.showRailsError(error);
                        $scope.course.title = "";
                    });
                }
            }]
        }
    }]);
