// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
alchemy.factory('ScenarioApiClient', [
    '$http',
    function($http) {
        var client = {};

        client.copyScenario = function(scenarioId, newName, newDescription) {
          return $http.post('/scenarios/' + scenarioId + '/copy', {name: newName, description: newDescription}).then(function(res) {
              return res.data;
          })
        };

        client.getScenarios = function() {
            return $http.get('/scenarios/').then(function(res) {
                return res.data;
            })
        };

        client.getScenario = function(scenarioId) {
          return $http.get('/scenarios/' + scenarioId).then(function(res) {
              return res.data;
          })
        };

        client.getNode = function(scenarioId, nodeId) {
            var baseUrl = formatBaseNodeUrl(scenarioId, nodeId);
            return $http.get(baseUrl).then(function(res) {
                return res.data;
            });
        };

        client.getNodes = function(scenarioId) {
            return $http.get('/scenarios/' + scenarioId + '/nodes').then(function(res) {
                return res.data;
            })
        };

        client.updateNode = function(scenarioId, node) {
            var baseUrl = formatBaseNodeUrl(scenarioId, node.id);
            return $http.put(baseUrl, node).then(function(res) {
                return res.data;
            });
        };

        client.createNode = function(scenarioId) {
            return $http.post('/scenarios/' + scenarioId + '/nodes', {}).then(function(res) {
                return res.data;
            });
        };

        client.deleteNode = function(scenarioId, nodeId) {
            var baseUrl = formatBaseNodeUrl(scenarioId, nodeId);

            return $http.delete(baseUrl).then(function(res) {
               return res.data;
            });
        };

        client.createChoice = function(scenarioId, nodeId) {
            var newChoice = {choice: {text: ""}};
            var baseUrl = formatBaseNodeUrl(scenarioId, nodeId);

            return $http.post(baseUrl + '/choices', newChoice).then(function(res) {
                return res.data;
            });
        };

        client.deleteChoice = function(scenarioId, nodeId, choice) {
            var baseUrl = formatBaseNodeUrl(scenarioId, nodeId);
            return $http.delete(baseUrl + '/choices/' + choice.id).then(function(res) {
                return res.data;
            });
        };

        client.getChoices = function(scenarioId, nodeId) {
            var baseUrl = formatBaseNodeUrl(scenarioId, nodeId);
            return $http.get(baseUrl + '/choices').then(function(res) {
                return res.data;
            });
        };

        client.updateChoice = function(scenarioId, nodeId, choice) {
            var baseUrl = formatBaseNodeUrl(scenarioId, nodeId);
            return $http.put(baseUrl + '/choices/' + choice.id, choice).then(function(res) {
                return res.data;
            });
        };

        client.createScenario = function(scenario) {
            return $http.post('/scenarios.json', scenario).then(function(res) {
                return res.data;
            });
        };

        client.getAllScenarios = function() {
            return $http.get('/scenarios.json').then(function(res) {
                return res.data;
            });
        };

        client.getTree = function(scenarioId) {
            var route = '/scenarios/' + scenarioId + '/tree';
            return $http.get(route);
        };

        client.updateScenario = function(scenario,scenarioName){
            return $http.put('/scenarios/'+ scenario.id, {name: scenarioName}).then(function(res) {
                return res.data;
            });
        };

        return client;
    }
]);


function formatBaseNodeUrl(scenarioId, nodeId) {
    return '/scenarios/' + scenarioId + '/nodes/' + nodeId;
}
