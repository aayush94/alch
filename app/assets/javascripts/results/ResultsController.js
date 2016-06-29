alchemy.controller("ResultsController", ['$scope', '$state', 'session', '$stateParams', 'SessionsApiClient', 'Util',
	function($scope, $state, session, $stateParams, SessionsApiClient, Util) {
		console.log("ResultsController loaded.");
		$scope.session = session;

		$scope.goToCourses = function(courseId){
			$state.go('courses', {id: courseId});
		};
	}]);