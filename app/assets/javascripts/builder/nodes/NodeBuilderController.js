alchemy.controller('NodeBuilderController', [
    '$scope',
    '$state',
    '$modal',
    '$stateParams',
    'ScenarioApiClient',
    'Util',
    'node',
    'Messages',
    function($scope, $state, $modal, $stateParams, ScenarioApiClient, Util, node, Messages) {
        $scope.node = node;

        $scope.$on("scenario-tree:node-selected", function(event, params) {
          var scenarioId = $stateParams.scenarioId;

          ScenarioApiClient.updateNode(scenarioId, $scope.node).then(function() {
            var nodeId = parseInt(params.nodes[0], 10);
            var stateParams = { scenarioId: scenarioId, nodeId: nodeId };
            $state.go('nodeBuilder', stateParams);
          }, function(error) {
            Util.showRailsError(error);
          });
        });

        $scope.getNodeTypeClass = function(node) {
          if(node.is_failure) {
            return "failure";
          } else if(node.is_goal) {
            return "goal";
          } else if(node.is_start) {
            return "start";
          } else {
            return "normal";
          }
        };

        $scope.deleteNode = function() {
          var modal = Util.openConfirmationModal(Messages.Modals.DELETE_NODE_TITLE, Messages.Modals.DELETE_NODE_BODY);

          modal.result.then(function() {
              ScenarioApiClient.deleteNode($stateParams.scenarioId, $stateParams.nodeId).then(function(data) {
                  goToStartNode();
              });
          });
        };

        var goToStartNode = function() {
            var scenarioId = $stateParams.scenarioId;

            ScenarioApiClient.getScenario(scenarioId).then(function(data) {
                $state.go('nodeBuilder', {scenarioId: scenarioId, nodeId: data.root_node_id});
            })
        };
    }
]);
