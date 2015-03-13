#experimental state definition


module.exports =
  'home':
    url: '/home',
    templateUrl: 'pages/home.html'

  'noauth':
    url: '',
    templateUrl: 'layout/noauth.html'

  'app':
    url: '',
    templateUrl: 'layout/app.html'

  'noauth.root':
    url: '/',
    template: 'No Auth Root'
    controller: ($state) ->
      $state.go 'app.dashboard',

  'noauth.login':
    url: '/login',
    template: 'Login'

  'app.users':
    url: '/users',
    views:
      menu:
        templateUrl: 'pages/users/modules/menu.html'
      main:
        templateUrl: 'pages/users/index.html'

  'app.users#new':
    url: '/users-new',
    templateUrl: 'pages/users/new.html'

  'app.users#profile':
    url: '/users-profile',
    templateUrl: 'pages/users/profile.html'


  'app.properties':
    url: '/properties',
    views:
      menu:
        templateUrl: 'pages/properties/modules/menu.html'
      main:
        templateUrl: 'pages/properties/index.html'

  'app.reports':
    url: '/reports',
    views:
      menu:
        templateUrl: 'pages/reports/modules/menu.html'
      main:
        templateUrl: 'pages/reports/index.html'

  'app.dashboard':
    url: '/dashboard',
    views:
      menu:
        templateUrl: 'pages/dashboard/modules/menu.html'
      main:
        templateUrl: 'pages/dashboard/index.html'


  'layout':
    url: '/layout',
    templateUrl: 'layout/main.html'

  'layout.child':
    url: '/child',
    templateUrl: 'layout/child.html'
