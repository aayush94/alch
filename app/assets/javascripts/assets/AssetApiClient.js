// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

alchemy.factory('AssetApiClient', [
    '$http',
    function($http) {
        var client = {};

        client.getAssets = function() {
            return $http.get('/assets.json').then(function(res) {
                return res.data;
            })
        };

        return client;
    }
]);