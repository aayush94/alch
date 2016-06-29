alchemy.controller('ReportingController', ['$scope', 'CourseApiClient', 'courses',
    function($scope, CourseApiClient, courses) {
        $scope.courses = courses;

        $scope.courseTreeData = [{
            label: 'Courses',
            children: _.map(courses, function(course) {
               var gradedShowings = _.filter(course.showings, function(showing) {
                   return showing.is_graded;
               });

               var courseShowings = _.map(gradedShowings, function(showing) {
                   return {
                       label: showing.display_name,
                       data: {id: showing.id},
                       onSelect: function(branch) {
                           var showingId = branch.data.id;
                           $scope.selectedStudentUsername = null;
                           $scope.studentReport = {};

                           CourseApiClient.getShowingReport(showingId).then(function(report) {
                               $scope.reportType = "showing";
                               $scope.report = report;
                               $scope.showing = branch;
                               $scope.showing.reportType = 'Summary';
                               $scope.studentShowingGrid.data = report.sessions;
                               $scope.studentShowingGrid.columnDefs = showingColumnDefs;
                           });

                       }
                   };
               });

               return {
                   label: course.title,
                   data: {id: course.id},
                   onSelect: function(branch) {
                       var courseId = branch.data.id;
                       $scope.selectedStudentUsername = null;

                       CourseApiClient.getCourseReport(courseId).then(function(report) {
                          $scope.reportType = "course";
                          $scope.courseTitle = report.title;
                          $scope.report = report.report;
                          $scope.studentCourseGrid.data = report.students;
                          $scope.studentCourseGrid.columnDefs = courseColumnDefs;
                       });
                   },
                   noLeaf: true,
                   children: courseShowings
               };
            })
        }];

        $scope.studentCourseGrid = {};

        $scope.studentShowingGrid = {
            enableRowSelection: true,
            multiSelect: false,
            enableRowHeaderSelection: false,
            selectionRowHeaderWidth: 35,
            rowHeight: 35,
            showGridFooter: true
        };

        $scope.studentShowingGrid.onRegisterApi = function(gridApi) {
          $scope.gridApi = gridApi;
          gridApi.selection.on.rowSelectionChanged($scope, function(row) {
            var selectedStudent = getSelectedStudentId(row);

            if(selectedStudent) {
              CourseApiClient.getStudentShowingReport($scope.showing.data.id, selectedStudent.id).then(function(report) {
                $scope.studentReport = report;
                $scope.selectedStudentUsername = selectedStudent.username;
              });
            } else {
              $scope.studentReport = {};
              $scope.selectedStudentUsername = null;
            }
          });
        };

        $scope.hasAverage = function() {
          return $scope.report.courseAverage && $scope.report.courseAverage != 'N/A';
        }

        var getSelectedStudentId = function(row) {
            var allRows = row.grid.rows;
            var selected = _.find(allRows, {isSelected: true});
            return (!selected) ? {} : { id: selected.entity.user_id, username: selected.entity.username};
        };

        var showingColumnDefs = [{field: 'user_id', displayName: 'Student ID'},
                                 {field: 'username', displayName: 'Username'},
                                 {field: 'num_failures', displayName: 'Number Failures'},
                                 {field: 'status', displayName: 'Status'}];

        var courseColumnDefs = [{field: 'user_id', displayName: 'Student ID'},
                                {field: 'username', displayName: 'Username'},
                                {field: 'average', displayName: 'Average'}];
    }]);
