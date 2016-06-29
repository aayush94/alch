alchemy.directive('createScenario', ['$state', 'ScenarioApiClient', 'Util',
    function($state, ScenarioApiClient, Util) {
        return {
            restrict: 'E',
            templateUrl: 'scenarios/_create-scenario-form.html',
            controller: ['$scope', '$element', function($scope, $element) {

                $scope.scenario = {};
                $scope.forms = {};

                $scope.createScenario = function(scenario) {
                    return ScenarioApiClient.createScenario(scenario).then(function(res) {
                        $scope.scenarios.push(res);
                        clearFields();
                        $scope.forms.newScenarioForm.$setPristine();
                        goToScenario(res);
                    }, function(error) {
                        Util.showRailsError(error);
                    });
                };

                $scope.createScenarioCopy = function(scenario) {
                    return ScenarioApiClient.copyScenario(scenario.toCopy.id, scenario.newName, scenario.newDescription).then(function(res) {
                        $scope.scenarios.push(res);
                        clearFields();
                        $scope.forms.copyScenarioForm.$setPristine();
                        goToScenario(res)
                    }, function(error) {
                        Util.showRailsError(error);
                    });
                };

                var clearFields = function() {
                    $scope.scenario.newName = "";
                    $scope.scenario.newDescription = "";
                    $scope.scenario.toCopy = "";
                    $scope.scenario.name = "";
                    $scope.scenario.description = "";
                };

                var goToScenario = function(scenario) {
                    $state.go('nodeBuilder', {scenarioId: scenario.id, nodeId: scenario.root_node_id});
                };
            }]
        }
    }]);
