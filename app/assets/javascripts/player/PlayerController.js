alchemy.controller("PlayerController", ['$scope', '$state', '$modal', 'Auth', 'session', '$stateParams', 'SessionsApiClient', 'Util',
	function($scope, $state, $modal, Auth, session, $stateParams, SessionsApiClient, Util) {

    var decide = function(toNodeId) {
      var toNode = { "to_node_id": toNodeId };

			if($scope.justification && session.node.requires_justification)
				toNode.justification = $scope.justification;

			SessionsApiClient.makeChoice(session.id, toNode).then(function(res){
				$scope.session = res;
				$scope.choices = res.node.choices;
				$scope.justification = res.previous_justification;
			});
		};

    var promptJustification = function(toNodeId, currJustification) {

      var modal = $modal.open({
        templateUrl: 'player/_justification-modal.html',
        size: 'md',
        controller: ['$scope', function($scope) {
          $scope.newJustification = currJustification;
          $scope.ok = function () { modal.close($scope.newJustification); };
          $scope.cancel = function () { modal.dismiss('cancel'); };
        }]
      });

      modal.result.then(function(newJustification) {
        $scope.justification = newJustification;
        decide(toNodeId);
      });
    };

		$scope.session = session;
		$scope.choices = session.node.choices;
		$scope.justification = session.previous_justification;

		$scope.makeDecision = function(toNodeId){
      if($scope.session.node.requires_justification) {
        promptJustification(toNodeId, $scope.justification);
      } else {
        decide(toNodeId);
      }
    };

		$scope.restart = function(sessionId){
			SessionsApiClient.restartSession(sessionId).then(function(res){
				$scope.session = res;
				$scope.choices = res.node.choices;
        $scope.justification = res.previous_justification;
			}, function(error) {
				Util.showRailsError(error);
			});
		};

		$scope.goToResults = function(sessionId){
			$state.go('results', {sessionId: sessionId});
		};

		$scope.goToCourses = function(courseId){
			$state.go('courses', {id: courseId});
		};
	}]);
