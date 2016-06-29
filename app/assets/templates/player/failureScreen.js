alchemy.directive('failureScreen', ['$state',
    function($state) {
        return {
            restrict: 'E',
            templateUrl: 'player/_failure-screen.html',
            controller: ['$scope', function($scope) {
                $scope.returnToCourse = function(course) {
                    $state.go('courses', {id: course.id});
                };
            }]
        }
    }
]);
