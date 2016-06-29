alchemy.directive('createShowing', ['$stateParams', 'ScenarioApiClient', 'CourseApiClient', 'Util', 'Messages',
    function($stateParams, ScenarioApiClient, CourseApiClient, Util, Messages) {
        return {
            restrict: 'E',
            templateUrl: 'courses/showings/_create-showing-form.html',
            controller: ['$scope', '$element', function($scope, $element) {

                ScenarioApiClient.getAllScenarios().then(function(data) {
                    $scope.scenarios = data;
                });

                $scope.scenario = {};

                $scope.createShowing = function(showing) {
                    if(showing.start_time > showing.end_time){
                        Util.showAlert('warning', 'Start date must be before end date.');
                        return;
                    }

                    var modal = Util.openConfirmationModal(Messages.Modals.CREATE_SHOWING_TITLE, Messages.Modals.CREATE_SHOWING_BODY);

                    modal.result.then(function() {
                        showing.name = showing.selected.name;
                        showing.scenario_id = showing.selected.id;
                        showing.is_graded = showing.type === $scope.scenarioTypes[0];

                        return CourseApiClient.createShowing($stateParams.id, showing).then(function(data) {
                            $scope.showings.push(data);

                            $scope.scenario.start_time = "";
                            $scope.scenario.end_time = "";
                            $scope.scenario.selected = "";
                            $scope.scenario.type = "";
                            $scope.scenario.max_attempts = "";

                            Util.showAlert('success', 'Assigned scenario ' + showing.name);
                        }, function(error) {
                            Util.showRailsError(error)
                        });
                    });
                };

                $scope.open = function($event, opened) {
                    $event.preventDefault();
                    $event.stopPropagation();

                    $scope[opened] = true;
                };

                $scope.dateOptions = {
                    formatYear: 'yy',
                    startingDay: 1
                };

                $scope.format = 'dd-MMMM-yyyy';

                $scope.scenarioTypes = ['Graded', 'Practice'];
            }]
        }
    }]);
