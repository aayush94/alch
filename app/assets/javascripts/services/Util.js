alchemy.factory('Util', [
    '$rootScope', '$modal',
    function($rootScope, $modal) {
        var u = {};

        u.showAlert = function(type, msg) {
            var alert = { type: type, msg: msg };

            if (alertAlreadyExists(alert)) {
                return;
            }

            $rootScope.alerts.push(alert);
        };

        u.showRailsError = function(error) {
            var errorKeys = Object.keys(error.data);

            _.each(errorKeys, function (errorKey) {
               // Format the key
               var formattedKey =  capitalize(errorKey);
               // Create an error for each error in the errorKey
               var keyErrors = error.data[errorKey];

               var alertTemplate = function(currentError) {
                 return { type: 'danger', msg: formattedKey + " " + currentError };
               };

               if(_.isArray(keyErrors)) {
                 _.each(keyErrors, function(currentError) {
                   var alert = alertTemplate(currentError);
                   if (!alertAlreadyExists(alert)) {
                     $rootScope.alerts.push(alert);
                   }
                 });
               } else if(_.isString(keyErrors)) {
                   var alert = alertTemplate(keyErrors);
                   if (!alertAlreadyExists(alert)) {
                     $rootScope.alerts.push(alert);
                   }
               }
            });
        };

        u.showRegistrationError = function(error) {
            var error = formatRegistrationError(error);
            var alert = { type: 'danger', msg: error };

            $rootScope.alerts.push(alert);
        };

        u.openConfirmationModal = function(title, body) {
            var modalInstance = $modal.open({
                templateUrl: '_confirmation-modal.html',
                size: 'md',
                controller: ['$scope', function($scope) {
                    $scope.modalTitle = title;
                    $scope.modalBody = body;

                    $scope.ok = function () {
                        modalInstance.close();
                    };

                    $scope.cancel = function () {
                        modalInstance.dismiss('cancel');
                    };
                }]
            });

            return modalInstance;
        };

        u.nodeHoverTemplate = function(title, body) {
          var text = "<div class='tree-popup'>";
          text += "<strong>" + title + "</strong>";

          if(body) {
            text += "<br>" + body;
          }

          text += "</div>";
          return text;
        };

        var alertAlreadyExists = function(alert) {
            return _.find($rootScope.alerts, function(a) {
                return alert.msg === a.msg && alert.type === a.type;
            });
        };

        return u;
    }]);

function formatRailsError(error) {
    var fieldName = Object.keys(error.data)[0];
    return capitalize(fieldName) + " " + error.data[fieldName][0];
}

function formatRegistrationError(error) {
    var fieldName = Object.keys(error.data.errors)[0];
    return capitalize(fieldName) + " " + error.data.errors[fieldName][0];
}

function capitalize(field) {
    return field.charAt(0).toUpperCase() + field.slice(1);
}
