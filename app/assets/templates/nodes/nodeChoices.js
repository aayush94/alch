alchemy.directive('nodeChoices', ['$rootScope', '$state', '$stateParams', 'ScenarioApiClient', 'Util',
    function($rootScope, $state, $stateParams, ScenarioApiClient, Util) {
        return {
            restrict: 'E',
            templateUrl: 'nodes/_node-choices.html',
            controller: ['$scope', '$element', function($scope, $element) {
                ScenarioApiClient.getChoices($stateParams.scenarioId, $stateParams.nodeId).then(function(data) {
                    $scope.choices = data;
                });

                ScenarioApiClient.getNodes($stateParams.scenarioId).then(function(data) {
                    $scope.nodes = data;
                });

                $scope.createChoice = function() {
                    var numChoices = $scope.choices.length;

                    if (numChoices >= 5) {
                        Util.showAlert('warning', 'Cannot add more than 5 choices.');
                        return;
                    }

                    ScenarioApiClient.createChoice($stateParams.scenarioId, $stateParams.nodeId).then(function(data) {
                        $scope.choices.push(data);
                        $rootScope.$broadcast("node:update", "createChoice");
                    }, function(error) {});
                };

                $scope.filterCurrentNode = function(nodes) {
                    var currentNodeId = parseInt($stateParams.nodeId, 10);

                    return  _.filter(nodes, function(node) {
                        return node.id !== currentNodeId;
                    });
                };

                $scope.deleteChoice = function(choice) {
                    ScenarioApiClient.deleteChoice($stateParams.scenarioId, $stateParams.nodeId, choice).then(function(data) {
                        var removedChoice = $scope.choices.indexOf(choice);
                        $scope.choices.splice(removedChoice, 1);
                        $rootScope.$broadcast("node:update", "deleteChoice");
                    })
                };

                $scope.updateChoice = function(choice) {
                    ScenarioApiClient.updateChoice($stateParams.scenarioId, $stateParams.nodeId, choice).then(function(data) {
                        $rootScope.$broadcast("node:update", "updateChoice");
                    }, function(error) {});
                };

                $scope.formatChoiceText = function(text) {
                    if (text === "") {
                        return "Enter Choice Text";
                    }
                    return text;
                };

                $scope.updateChoiceLink = function(choice, to_node) {
                    $scope.updateChoice({id: choice.id, to_node_id: to_node.id});
                    var updatedChoice = $scope.choices.indexOf(choice);
                    $scope.choices[updatedChoice].to_node_id = to_node.id;
                };

                $scope.clearChoiceLink = function(choice) {
                    $scope.updateChoice({id: choice.id, to_node_id: null});
                    var updatedChoice = $scope.choices.indexOf(choice);
                    $scope.choices[updatedChoice].to_node_id = 'N/A';
                };
            }]
        }
    }
]);
