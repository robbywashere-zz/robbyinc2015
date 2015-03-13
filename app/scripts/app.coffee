require('./app/scripts/lib/module.coffee')

app = angular.module('myApp',[ 'templates','ui.router','templates','angular-loading-bar','Devise'])

app.config ($stateProvider, $locationProvider, $urlRouterProvider) ->


  $urlRouterProvider.otherwise '/'
  $locationProvider.html5Mode true

  $stateProvider

    .state 'home',
      url: '/home',
      templateUrl: 'pages/home.html'

    .state 'noauth',
      url: '',
      templateUrl: 'layout/noauth.html'

    .state 'app',
      url: '',
      templateUrl: 'layout/app.html'
      resolve:
        session: (Auth, $state) ->
          Auth.currentUser().catch (error) ->
            return error

      controller: ($state, session, $scope) ->
#        if session.status >= 400
#          $state.go 'noauth.login',
#            redirectTo: $state.$current.name

#    .state 'noauth.root',
#      url: '/',
#      template: 'Not Logged In'
#
#    .state 'auth.root',
#      url: '/',
#      template: 'Logged In'

    .state 'noauth.root',
      url: '/',
      template: 'No Auth Root'
      controller: ($state) ->
        $state.go 'app.dashboard',

    .state 'noauth.login',
      url: '/login',
      template: 'Login'

    .state 'app.users',
      url: '/users',
      views:
        menu:
          templateUrl: 'pages/users/modules/menu.html'
        main:
          templateUrl: 'pages/users/index.html'

    .state 'app.users#new',
      url: '/users-new',
      templateUrl: 'pages/users/new.html'

    .state 'app.users#profile',
      url: '/users-profile',
      templateUrl: 'pages/users/profile.html'


    .state 'app.properties',
      url: '/properties',
      views:
        menu:
          templateUrl: 'pages/properties/modules/menu.html'
        main:
          templateUrl: 'pages/properties/index.html'

    .state 'app.reports',
      url: '/reports',
      views:
        menu:
          templateUrl: 'pages/reports/modules/menu.html'
        main:
          templateUrl: 'pages/reports/index.html'

    .state 'app.dashboard',
      url: '/dashboard',
      views:
        menu:
          templateUrl: 'pages/dashboard/modules/menu.html'
        main:
          templateUrl: 'pages/dashboard/index.html'

    .state 'app.map',
      url: '/map',
      views:
        menu:
          templateUrl: 'pages/map/modules/menu.html'
        main:
          templateUrl: 'pages/map/index.html'

    .state 'app.settings',
      url: '/settings',
      views:
        menu:
          templateUrl: 'pages/settings/modules/menu.html'
        main:
          templateUrl: 'pages/settings/index.html'


    .state 'layout',
      url: '/layout',
      templateUrl: 'layout/main.html'

    .state 'layout.child',
      url: '/child',
      templateUrl: 'layout/child.html'



app.directive 'authenticated', (Auth) ->
  restrict: 'A'
  link: (scope,element, attr) ->
    scope.$watch Auth.isAuthenticated, (isAuth) ->
      attr.$set('authenticated', isAuth)


app.run ($rootScope, $state) ->
  $rootScope.$on "$stateChangeSuccess", (event, toState, toParams, fromState) ->
    $state.previous = fromState
