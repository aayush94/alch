// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

alchemy.factory('SessionsApiClient', [
        '$http',
        function($http) {
            var o = {
                sessions: []
            };

            o.createSession = function(showingId) {
                return $http.post('/showings/' + showingId + '/session').then(function(res) {
                    return res.data;
                });
            };

            o.getSession = function(sessionId) {
                return $http.get('/sessions/' + sessionId).then(function(res) {
                    return res.data;
                });
            };

            o.makeChoice = function(sessionId, toNode) {
                return $http.post('/sessions/' + sessionId + '/decide', toNode).then(function(res){
                    return res.data;
                });
            };

            o.restartSession = function(sessionId) {
                var sessionIdObject = {"session_Id": sessionId};
                return $http.post('/sessions/' + sessionId + '/restart', sessionIdObject).then(function(res){
                    return res.data;
                });
            };

            return o;
        }
    ]);
