
var alchemy = angular.module('alchemy', ['ui.router', 'ui.bootstrap', 'ui.select', 'ui.grid', 'ui.grid.selection', 'ngSanitize', 'templates', 'Devise', 'angularFileUpload', 'angular-ladda', 'angularBootstrapNavTree']);

alchemy.config(['$stateProvider', '$urlRouterProvider', 'AuthInterceptProvider', function($stateProvider, $urlRouterProvider, AuthInterceptProvider ) {

  //// ROUTER ////////////////////////////////
  $stateProvider
  .state('dashboard', {
    url: '/dashboard',
    templateUrl: 'dashboard/_dashboard.html',
    controller: 'DashboardController',
    resolve: {
      enrolledCourses: ['CourseApiClient', function(CourseApiClient) {
        return CourseApiClient.getEnrolledCourses();
      }]
    }
  })
  .state('courses', {
    url: '/courses/{id}',
    templateUrl: 'courses/_courses.html',
    controller: 'CourseController',
    resolve: {
      course: ['$stateParams', 'CourseApiClient', function($stateParams, CourseApiClient) {
        return CourseApiClient.get($stateParams.id);
      }],
      showings: ['$stateParams', 'CourseApiClient', function($stateParams, CourseApiClient) {
        return CourseApiClient.getShowings($stateParams.id);
      }]
    }
  })
  .state('reporting', {
    url: '/reporting',
    templateUrl: 'reporting/_reporting.html',
    controller: 'ReportingController',
    resolve: {
      courses: ['CourseApiClient', function(CourseApiClient) {
        return CourseApiClient.getEnrolledCourses();
      }]
    }
  })
  .state('builder', {
    url: '/builder',
    templateUrl: 'builder/_builder.html',
    controller: "BuilderController",
    onEnter: ['$state', 'Auth', function($state, Auth) {
      if(Auth.isAuthenticated()) {
        var user = Auth._currentUser;
        if (user.role === "guest" || user.role === "student") {
          $state.go("dashboard");
        }
      }
    }],
    resolve: {
      scenarios: ['ScenarioApiClient', function(ScenarioApiClient) {
        return ScenarioApiClient.getScenarios();
      }]
    }
  })
  .state('nodeBuilder', {
    url: '/builder/scenarios/{scenarioId}/nodes/{nodeId}',
    templateUrl: 'builder/nodes/_build-nodes.html',
    controller: 'NodeBuilderController',
    resolve: {
      node: ['$stateParams', 'ScenarioApiClient', function($stateParams, ScenarioApiClient) {
        return ScenarioApiClient.getNode($stateParams.scenarioId, $stateParams.nodeId);
      }]
    }
  })
  .state('player', {
    url: '/player/{sessionId}',
    templateUrl: 'player/_player.html',
    controller: "PlayerController",
    resolve: {
      session: ['$stateParams', 'SessionsApiClient', function($stateParams, SessionsApiClient) {
        return SessionsApiClient.getSession($stateParams.sessionId);
      }]
    }
  })
  .state('results', {
    url: '/player/{sessionId}/results',
    templateUrl: 'results/_results.html',
    controller: "ResultsController",
    resolve: {
      session: ['$stateParams', 'SessionsApiClient', function($stateParams, SessionsApiClient) {
        return SessionsApiClient.getSession($stateParams.sessionId);
      }
      ]},
      onEnter: ['$state', 'session', function($state, session) {
        if(session.status == "ongoing") {
          $state.go("player", {sessionId: session.id});
        }
      }]
    })
  .state('login', {
    url: '/login',
    templateUrl: 'auth/_login.html',
    controller: 'AuthController',
    resolve: {
      universities: ['UniversityApiClient', function(UniversityApiClient) {
        return UniversityApiClient.getUniversities();
      }
      ]},
      onEnter: ['$state', 'Auth', function($state, Auth) {
        if(Auth.isAuthenticated()) {
          $state.go("dashboard");
        }
      }]
    })
  .state('signup', {
    url: '/signup',
    templateUrl: 'auth/_signup.html',
    controller: 'AuthController',
    resolve: {
      universities: ['UniversityApiClient', function(UniversityApiClient) {
        return UniversityApiClient.getUniversities();
      }
      ]},
      onEnter: ['$state', 'Auth', function($state, Auth) {
        if(Auth.isAuthenticated()) {
          $state.go("dashboard");
        }
      }]
    });

    $urlRouterProvider.otherwise( function($injector, $location) {
      var $state = $injector.get("$state");
      $state.go("login");
    });

  //// AUTH ////////////////////////////////
  AuthInterceptProvider.interceptAuth(true);

}]);

alchemy.run(['$rootScope', '$state', 'Auth', function($rootScope, $state, Auth) {

  $rootScope.$on('$stateChangeStart', function (event, toState, toParams) {

    if(toState.name === "login")
      return;

    Auth.currentUser().then(function(currentUser) {
      $rootScope.currentUser = currentUser;
      $rootScope.currentUser.isStudent = currentUser.role === "student";
      $rootScope.currentUser.isInstructor = currentUser.role === "instructor" || currentUser.role === "admin";
    });

  });

  // Route all 401 unauthorized responses to login
  $rootScope.$on('devise:unauthorized', function(event, xhr, deferred) {
    $rootScope.currentUser = {};
    $state.go('login');
  });

  // Clear all alerts on navigate
  $rootScope.$on('$locationChangeStart', function() {
    $rootScope.alerts = [];
  });

}]);
