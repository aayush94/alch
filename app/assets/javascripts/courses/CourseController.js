alchemy.controller('CourseController', [
    '$scope',
    '$state',
    '$modal',
    'Util',
    'CourseApiClient',
    'SessionsApiClient',
    'Auth',
    'course',
    'showings',
    'Messages',
    function($scope, $state, $modal, Util, CourseApiClient, SessionsApiClient, Auth, course, showings, Messages) {
        $scope.course = course;
        $scope.showings = showings;
        $scope.pluralize = $scope.showings.length > 1;

        $scope.open = function(showing) {
          if($scope.isSessionInactive(showing.user_session)) {
            $scope.openResults(showing);
          } else {
            $scope.openSession(showing);
          }
        };

        $scope.editShowing = function(showing) {
            var parentScenario = showing.scenario;
            $state.go('nodeBuilder', {scenarioId: parentScenario.id, nodeId: parentScenario.root_node_id});
        };

        $scope.hideShowing = function(showing) {
            var modal = Util.openConfirmationModal(Messages.Modals.HIDE_SHOWING_TITLE, Messages.Modals.HIDE_SHOWING_BODY);

            modal.result.then(function() {
                CourseApiClient.hideShowing($scope.course.id, showing.id).then(function() {
                    var hiddenShowing = $scope.showings.indexOf(showing);
                    $scope.showings.splice(hiddenShowing, 1);
                    Util.showAlert('success', 'Removed showing ' + showing.display_name);
                });
            });
        };

        $scope.changeStartEndDate = function(selectedShowing) {
            var modal = $modal.open({
                templateUrl: '_edit-date-modal.html',
                size: 'md',
                controller: ['$scope', function(scope) {
                    scope.newStartTime = selectedShowing.start_time;
                    scope.newEndTime = selectedShowing.end_time;

                    scope.dateOptions = {
                      formatYear: 'yy',
                      startingDay: 1
                    };

                    scope.dateFormat = 'dd-MMMM-yyyy';

                    scope.open = function($event, opened) {
                      $event.preventDefault();
                      $event.stopPropagation();

                      scope[opened] = true;
                    };

                    scope.ok = function() {
                      var newDates = {
                        start: scope.newStartTime,
                        end: scope.newEndTime
                      };

                      modal.close(newDates);
                    };

                    scope.cancel = function() {
                      modal.dismiss('cancel');
                    };
                }]
            });

            modal.result.then(function(newDates) {
              if(newDates.start && newDates.end && datesHaveChanged(newDates, selectedShowing)) {
                var data = { start_time: newDates.start, end_time: newDates.end };

                CourseApiClient.updateShowing($scope.course.id, selectedShowing.id, data)
                .then(function() {
                  selectedShowing.start_time = newDates.start;
                  selectedShowing.end_time = newDates.end;
                  Util.showAlert('success', 'Updated ' + selectedShowing.display_name);
                }, function(err) {
                  Util.showRailsError(err);
                });
              }
            });
        };

        var datesHaveChanged = function(newDates, selectedShowing) {
          return (newDates.start != selectedShowing.start_time) ||
            (newDates.end != selectedShowing.end_time);
        };

        $scope.isExpired = function(showing) {
          var end = new Date(showing.end_time).getTime();
          var now = new Date().getTime();
          return end <= now;
        };

        $scope.getAttemptsHeader = function(isInstructor) {
            if (isInstructor) {
                return "Max Attempts";
            }
            return "Attempts Remaining";
        };

        $scope.statusClass = function(status) {
         switch(status) {
            case "completed":
              return "label-success";
            case "failed":
              return "label-danger";
            default:
              return "label-default";
         }
        };

        $scope.getAttemptsData = function(isInstructor, showing) {
            var maxAttempts = showing.max_attempts;

            if (!showing.is_graded) {
                return "Unlimited";
            }

            if (isInstructor) {
                return maxAttempts;
            }

            if (!showing.user_session) {
                return maxAttempts;
            }

            return showing.user_session.attempts_remaining;
        };

        $scope.formatStatus = function(status) {
            if (!status) {
                return "Not Started";
            }
            return status.charAt(0).toUpperCase() + status.slice(1);
        };

        $scope.isSessionInactive = function(session) {
            return session && session.status && session.status !== sessionTypes[0];
        };

        $scope.openSession = function(showing) {
            var sessionId;
            if(!showing.user_session){
                SessionsApiClient.createSession(showing.id).then(function(res){
                    sessionId = res.id;
                    $state.go('player', {sessionId: sessionId});
                });
            } else {
                sessionId = showing.user_session.id;
                $state.go('player', {sessionId: sessionId});
            }
        };

        $scope.openResults = function(showing) {
            var sessionId = showing.user_session.id;
            $state.go('results', {sessionId: sessionId});
        };

        var sessionTypes = ["ongoing", "expired", "failed", "completed"];
    }
    ]);
