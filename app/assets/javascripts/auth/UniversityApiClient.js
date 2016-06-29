alchemy.factory('UniversityApiClient', [
    '$http',
    function($http) {

    		var o = {};

        	o.getUniversities = function() {
                return $http.get('/universities').then(function(res) {
                    return res.data;
                });
            };

    	    return o;
        }
]);