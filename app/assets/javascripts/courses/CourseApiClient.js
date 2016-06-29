// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

alchemy.factory('CourseApiClient', [
        '$http',
        function($http) {
            var o = {
                courses: []
            };

            o.get = function(id) {
                return $http.get('/courses/' + id + '.json').then(function(res) {
                    return res.data;
                });
            };

            o.getShowings = function(id) {
                return $http.get('/courses/' + id + '/showings.json').then(function(res) {
                    return res.data;
                });
            };

            o.getCourseReport = function(courseId) {
                return $http.get('/courses/' + courseId + '/report').then(function(res) {
                    return res.data;
                });
            };

            o.getShowingReport = function(showingId) {
                return $http.get('/showings/' + showingId + '/report').then(function(res) {
                    return res.data;
                });
            };

            o.getStudentShowingReport = function(showingId, studentId) {
              var route = '/showings/' + showingId + '/student_report?sid=' + studentId;
              return $http.get(route).then(function(res) {
                  return res.data;
              });
            };

            o.createCourse = function(course) {
                return $http.post('/courses', course).then(function(res) {
                    return res.data;
                });
            };

            o.getEnrolledCourses = function() {
                return $http.get('/courses.json').then(function(res) {
                    return res.data;
                });
            };

            o.createShowing = function(courseId, showing) {
                return $http.post('/courses/' + courseId + '/showings.json', showing).then(function(res) {
                    return res.data;
                });
            };

            o.hideShowing = function(courseId, showingId) {
              return $http.put('/courses/' + courseId + '/showings/' + showingId, {hidden:true}).then(function(res) {
                  return res.data;
              });
            };

            o.updateShowing = function(courseId, showingId, data) {
              return $http.put('/courses/' + courseId + '/showings/' + showingId, data).then(function(res) {
                  return res.data;
              });
            };

            return o;
        }
    ]);
