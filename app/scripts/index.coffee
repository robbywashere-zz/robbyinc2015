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

    .state 'auth',
      url: '',
      templateUrl: 'layout/auth.html'
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
        $state.go 'auth.app',

    .state 'noauth.login',
      url: '/login',
      template: 'Login'

    .state 'auth.addUser',
      url: '/add-user',
      template: 'add user'

    .state 'auth.app',
      url: '/app',
      template: 'App Root'

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
