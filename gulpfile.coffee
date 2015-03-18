

gulp = require 'gulp'

gulp_sync = require 'run-sequence'

$require = require 'rekuire'

$config = $require 'config/config'

path = require 'path'

browserify = require 'browserify'

through = require 'through2'

gutil = require 'gulp-util'
coffee = require 'gulp-coffee'
rename = require 'gulp-rename'
sourcemaps = require 'gulp-sourcemaps'
ng_template = require 'gulp-angular-templatecache'
jade = require 'gulp-jade'
inject = require 'gulp-inject'
concat = require 'gulp-concat'
uglify = require 'gulp-uglify'
sass = require 'gulp-sass'
ruby_sass = require 'gulp-ruby-sass'
gulpif = require 'gulp-if'

css_min = require 'gulp-cssmin'
gulp_data = require 'gulp-data'

size = require('gulp-size')



$meta_data = ->
  delete require.cache[$require.path('app/templates/data/meta')]
  $require('app/templates/data/meta')
    
  


browser_sync = require 'browser-sync'

ng_annotate = require 'gulp-ng-annotate'

spawn = require('child_process').spawn


del = require 'del'

$error_handler = (err) ->
  gutil.log err.message
  @emit 'end'


$print = through.obj (file,enc,cb) ->
  console.log file.path.toString()
  console.log file.contents.toString()
  @push file
  do cb



$js_compiled = (read = false) ->
  gulp.src path.join($config.output.assets.js, '*.js'), read: read

$css_compiled = (read = false) ->
  gulp.src path.join($config.output.assets.css, '*.css'), read: read


$js_compiled_min = ->
  src = path.join($config.output.assets.js,$config.output.build.js)
  gulp.src(src, read: false)

$css_compiled_min = ->
  src = path.join($config.output.assets.css,$config.output.build.css)
  gulp.src(src, read: false)



$bfy = -> new through.obj (file,enc,cb) ->
  browserify(file, { debug: true, baseDir: 'app' })
  .transform('coffeeify')
  .bundle (err,src) =>
 	  if err
      @emit 'error', err
    else
      file.contents = new Buffer src
      @push file
    do cb





gulp.task 'inject', ->
  gulp.src $config.input.index
    .pipe gulp_data($data)
    .pipe do jade
    .pipe inject(do $js_compiled, ignorePath: $config.output.root)
    .pipe inject(do $css_compiled, ignorePath: $config.output.root)
    #.pipe $print
    .pipe gulp.dest $config.output.root

gulp.task 'static:inject', ->

  opts = { ignorePath: $config.output.root }

  gulp.src path.join($config.output.root,'**/*.html')

    .pipe gulpif $config._deploy, inject($css_compiled_min(), opts), inject($css_compiled(), opts)
    .pipe gulpif $config._deploy, inject($js_compiled_min(), opts), inject($js_compiled(), opts)

    .pipe gulp.dest $config.output.root




gulp.task 'inject.min', ->

  gulp.src $config.input.index
    .pipe gulp_data($data)
    .pipe do jade
    .pipe inject(do $js_compiled_min, ignorePath: $config.output.root)
    .pipe inject(do $css_compiled_min, ignorePath: $config.output.root)
    #.pipe $print
    .pipe gulp.dest $config.output.root


gulp.task 'clean', (cb) ->
  del $config.output.root, cb


gulp.task 'bower:info', ->
  wiredep = require 'wiredep'
  excludes = require('./bower.json')['exclude']
  bower = wiredep exclude: excludes

  Object.keys(bower).forEach (key) ->
    if Array.isArray(bower[key])
      console.log gutil.colors.magenta("Bower " + key + ":")
      console.log gutil.colors.yellow(bower[key].join("\n")), "\n"

  console.log gutil.colors.magenta("Bower excluding:")
  console.log gutil.colors.red(excludes.join("\n")), "\n"


  
gulp.task 'static:build', (cb) ->
  gulp_sync 'clean',
    ['scripts:coffee',
    'scripts:vendor',
    'styles', 'copy'],
    'static:pages',
    'static:inject',
    cb


gulp.task 'static', ['static:build','static:watch','static:serve']


gulp.task 'static:deploy', (cb) ->
  $config._deploy = true
  gulp_sync 'clean',
    ['scripts:coffee',
    'scripts:vendor',
    'styles',
    'copy'],
    'uglify',
    'static:pages',
    'static:inject',
    cb

gulp.task 'default', (cb) ->
  gulp_sync 'clean', ['scripts', 'styles', 'copy'], 'inject', 'serve', 'watch', cb

gulp.task 'prod', (cb) ->
  gulp_sync 'clean', ['scripts', 'styles', 'copy'], 'uglify', 'inject.min', cb

gulp.task 'scripts', ['scripts:coffee','scripts:ng-jade','scripts:vendor']

gulp.task 'styles', ['styles:sass','styles:vendor']

gulp.task 'uglify', ['uglify:js', 'uglify:css'], ->


gulp.task 'copy', ->
  gulp.src($config.input.assets)
    .pipe(gulp.dest($config.output.assets.root))


gulp.task 'uglify:js', ->
  $js_compiled(true)
    .on 'error', $error_handler
    .pipe concat($config.output.build.js)
    .pipe do uglify
    .pipe size showFiles: true, gzip: true
    .pipe gulp.dest($config.output.assets.js)



#gulp.task 'scripts:vendor', ['scripts:vendor:css', 'bundle_vendor:js']

gulp.task 'styles:vendor', ->
    gulp.src $config.input.vendor_css
      .pipe do sourcemaps.init
      .pipe concat $config.output.compiled.vendor_css
      .pipe do sourcemaps.write
      .pipe do $css_dest
      .pipe gulp.dest $config.output.assets.css

gulp.task 'styles:vendor', ->
    gulp.src $config.input.vendor_css
      .pipe do sourcemaps.init
      .pipe concat $config.output.compiled.vendor_css
      .pipe do sourcemaps.write
      .pipe gulp.dest $config.output.assets.css

gulp.task 'scripts:vendor', ->
    gulp.src $config.input.vendor_js
      .pipe do sourcemaps.init
      .pipe concat $config.output.compiled.vendor_js
      .pipe do sourcemaps.write
      .pipe gulp.dest($config.output.assets.js)

gulp.task 'static:pages', ->

    gulp.src $config.input.templates
    .pipe gulp_data (file)->

      page: require path.format
        dir: path.join(__dirname,$config.input.data)
        base: path.parse(file.path).name

      meta: do $meta_data

    .on 'error', $error_handler
    .pipe jade pretty: true
    .on 'error', $error_handler
    .pipe gulp.dest($config.output.root)




gulp.task 'uglify:css', ->
  $css_compiled(true)
    .on 'error', $error_handler
    .pipe concat($config.output.build.css)
    .pipe do css_min
    .pipe size showFiles: true, gzip: true
    .pipe gulp.dest $config.output.assets.css

gulp.task 'scripts:ng-jade', ->
  gulp.src $config.input.templates
    .pipe gulp_data($data)
    .pipe do jade
    .on 'error', $error_handler
    .pipe ng_template(standalone: true)
    .on 'error', $error_handler
    .pipe rename($config.output.compiled.templates)
    .pipe gulp.dest($config.output.assets.js)
    #.pipe $print
  

gulp.task 'config', ->
  gutil.log $config

gulp.task 'styles:sass', ->
  gulp.src $config.input.sass
  .pipe do sourcemaps.init
  .pipe sass(indentedSyntax: true, includePaths: $config.input.sass_loadpath)
  .on 'error', (err) -> $error_handler.call(@, message: err.toString())
  .pipe do sourcemaps.write
  .pipe rename($config.output.compiled.sass)
  .pipe gulp.dest $config.output.assets.css



gulp.task 'scripts:coffee', ->
  gulp.src $config.input.coffee, base: 'app'
  .pipe do sourcemaps.init
  .pipe concat $config.output.compiled.coffee
  .pipe coffee bare: true
  .on 'error', (err) -> $error_handler.call(@, message: err.toString())
  .pipe do $bfy
  .on 'error', $error_handler
  .pipe do ng_annotate
  .on 'error', $error_handler
  .pipe gulp.dest $config.output.assets.js
  .pipe do sourcemaps.write


gulp.task 'scripts:vendor', ->
  gulp.src $config.input.vendor_js
  .on 'error', $error_handler
  .pipe do sourcemaps.init
  .pipe concat($config.output.compiled.vendor_js, newLine: ';')
  #.pipe do ng_annotate
  .pipe do sourcemaps.write
  .pipe gulp.dest $config.output.assets.js


gulp.task "static:serve", ->
  browser_sync
    server:
      baseDir: $config.output.root
    port: 8888
    open: false

gulp.task "serve", ->
  assets = new RegExp "^/(#{(value for key, value of $config.output.assets).join('|')})"
  browser_sync
    server:
      baseDir: $config.output.root
      middleware: (req, res, next) ->
        $config.output.assets
        req.url = "/#{$config.output.index}" unless assets.test(req.url)
        next()

    port: 8888
    open: false



gulp.task "watch", ->
  gulp.watch $config.watch.sass, ['styles:sass', browser_sync.reload]
  gulp.watch $config.watch.coffee, ['scripts:coffee', browser_sync.reload]
  gulp.watch $config.watch.templates, ['scripts:ng-jade', browser_sync.reload]
  gulp.watch $config.watch.data, ['scripts:ng-jade','inject', browser_sync.reload]
  gulp.watch $config.watch.index, ['inject', browser_sync.reload]
  

gulp.task "static:watch", ->
  gulp.watch $config.watch.sass, ['styles:sass', browser_sync.reload]
  gulp.watch $config.watch.coffee, ['scripts:coffee', browser_sync.reload]
  gulp.watch [].concat($config.watch.templates,$config.watch.data), ['static:build', browser_sync.reload]

gulp.task "auto", ->
  spawnChildren = (e) ->
    
    # kill previous spawned process
    p.kill()  if p
    
    # `spawn` a child `gulp` process linked to the parent `stdio`
    p = spawn("gulp",
      stdio: "inherit"
    )
    return
  p = undefined
  gulp.watch "gulpfile.coffee", spawnChildren
  spawnChildren()
  return

