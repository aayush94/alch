alchemy.directive('scenarioList', ['ScenarioApiClient', 'Util',
    function(ScenarioApiClient, Util) {
        return {
            restrict: 'E',
            replace: true,
            templateUrl: 'scenarios/_scenario-list.html',
            controller: ['$scope', '$element', function($scope, $element) {

            	$scope.editScenarioName = function(scenario) {
                    return ScenarioApiClient.updateScenario(scenario, scenario.newName).then(function(res) {
                    scenario.name = scenario.newName;
                    }, function(error) {
                        Util.showRailsError(error);
                    });
                };
            }]
        }
    }]);
