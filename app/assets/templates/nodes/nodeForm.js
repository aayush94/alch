alchemy.directive('nodeForm', ['$rootScope', '$state', '$stateParams', '$modal', 'ScenarioApiClient', 'Util', 'Messages',
    function($rootScope, $state, $stateParams, $modal, ScenarioApiClient, Util, Messages) {
        return {
            restrict: 'E',
            templateUrl: 'nodes/_build-node-form.html',
            controller: ['$scope', '$upload', '$element', function($scope, $upload, $element) {
                $scope.$on("node:update", function() {
                   ScenarioApiClient.getNode($stateParams.scenarioId, $stateParams.nodeId).then(function(data) {
                       $scope.node = data;
                       $scope.node.type = getNodeType(data);
                   })
                });

                $scope.node.type = getNodeType($scope.node);

                $scope.updateNode = function(node) {
                    if (isGoalOrFailureWithChoices(node)) {
                        var modal = Util.openConfirmationModal(Messages.Modals.REMOVE_CHOICES_TITLE, Messages.Modals.REMOVE_CHOICES_BODY);

                        modal.result.then(function() {
                            $scope.choices = [];
                            saveNode(node);
                        }, function() {
                            resetToRegularNode();
                        });
                    }
                    else {
                        saveNode(node);
                    }
                };

                $scope.updateNodeType = function(node) {
                  switch(node.type) {
                      case "regular":
                          node.is_goal = false;
                          node.is_failure = false;
                          break;
                      case "goal":
                          node.is_goal = true;
                          node.is_failure = false;
                          break;
                      case "failure":
                          node.is_goal = false;
                          node.is_failure = true;
                  }

                  $scope.updateNode(node);
                };

                $scope.addNode = function() {
                    // Create a new node and navigate to it
                    return ScenarioApiClient.createNode($stateParams.scenarioId).then(function(data) {
                        $state.go('nodeBuilder', { scenarioId: $stateParams.scenarioId, nodeId: data.id });
                    });
                };

                $scope.removeImage = function(node) {
                 node.asset_id = null;

                 if ($scope.updateNode(node)) {
                     $scope.node.asset = null;
                 }
                };

                 $scope.upload = function (file) {
                    $upload.upload({
                        url: '/assets',
                        method: 'POST',
                        file: file,
                        fileFormDataName: 'image'
                    });
                };

                $scope.openImageModal = function() {
                    var modalInstance = $modal.open({
                        templateUrl: 'nodes/_select-image-modal.html',
                        size: 'md',
                        controller: 'imageModal',
                        resolve: {
                            assets: ['AssetApiClient', function(AssetApiClient) {
                                return AssetApiClient.getAssets();
                            }]
                        }
                    });

                    modalInstance.result.then(function(asset) {
                            // Set selected image here
                            ScenarioApiClient.updateNode($stateParams.scenarioId, {id: $stateParams.nodeId, asset_id: asset.id}).then(function() {
                                $scope.node.asset = asset;
                            });
                        }, function() {
                            // Dismissed modal
                        })
                };

                var saveNode = function(node) {
                    return ScenarioApiClient.updateNode($stateParams.scenarioId, node).then(function(data) {
                        Util.showAlert('success', 'Saved current node.');
                        $rootScope.$broadcast("node:update", "updateNode");
                    }, function(error) {
                        Util.showRailsError(error);
                        return false;
                    });
                };

                var isGoalOrFailureWithChoices = function(node) {
                    return (node.is_goal || node.is_failure) && hasChoices(node);
                };

                var hasChoices = function(node) {
                    return node.choices && node.choices.length > 0;
                };

                var resetToRegularNode = function() {
                    $scope.node.type = "regular";
                    $scope.node.is_failure = false;
                    $scope.node.is_goal = false;
                };

                function getNodeType(node) {
                  if (!node.is_failure && !node.is_goal)
                    return "regular";
                  if (node.is_failure && !node.is_goal)
                    return "failure";
                  if (!node.is_failure && node.is_goal)
                    return "goal";
                };
            }]
        }
}]);
