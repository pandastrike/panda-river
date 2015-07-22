{createWriteStream} = require "fs"
{join, basename} = require "path"
{spread, glob, read, write, mkdirp,
  start, flow, map, async} = require "fairmont"
jade = require "jade"
coffee = require "coffee-script"
browserify = require "browserify"

templates = async ->

  mkdirp "0777", "build"

  start flow [

    yield glob "src/*.jade", "./"

    map (path) ->
      filename = basename path, ".jade"
      [filename, (do jade.compileFile path)]

    map ([filename, html]) ->
      write (join "build", "#{filename}.html"), html

  ]

code = async ->

  mkdirp "0777", "build"

  start flow [

    yield glob "src/*.coffee", "./"

    map async (path) ->
      filename = basename path, ".coffee"
      [filename, (coffee.compile (yield read path))]

    map async (p) ->
      [filename, js] = yield p
      write (join "lib", "#{filename}.js"), js

  ]

bundle = async ->

  b = browserify()

  yield start flow [

    yield glob "lib/*.js", "./"

    map (path) ->
      b.add path

  ]

  b.bundle().pipe createWriteStream join "build", "app.js"


templates().then -> console.log "Task 'templates': done."

code().then ->

  console.log "Task 'code': done."

  bundle().then ->
    console.log "Task 'bundle' done."
