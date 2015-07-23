{createWriteStream} = require "fs"
{join, basename} = require "path"
{glob, read, write, mkdirp, partial, _, isPromise,
  start, flow, map, async} = require "fairmont"
jade = require "jade"
coffee = require "coffee-script"
browserify = require "browserify"
express = require "express"
morgan = require "morgan"

glob = partial glob, _, "./"

compileJade = (path) ->
  filename = basename path, ".jade"
  [filename, (do jade.compileFile path)]

compileCoffeeScript = async (path) ->
  filename = basename path, ".coffee"
  [filename, (coffee.compile (yield read path))]

writeFile = (directory, extension) ->
  async (x) ->
    if isPromise x
      x = yield x
    [filename, content] = x
    yield write join directory, "#{filename}.#{extension}"

{task} = require "./task"

task "default", "templates", "bundle"

task "directories", async -> yield mkdirp "0777", "build"

task "templates", "directories", async ->
  yield start flow [
    yield glob "src/*.jade"
    map compileJade
    map writeFile "build", ".html"
  ]

task "code", "directories", async ->
  yield start flow [
    yield glob "src/*.coffee"
    map compileCoffeeScript
    map writeFile "lib", ".js"
  ]

task "bundle", "code", async ->
  b = browserify()
  yield start flow [
    yield glob "lib/*.js"
    map (path) -> b.add path
  ]
  b.bundle().pipe createWriteStream join "build", "app.js"

task "serve", ->
  app = express()
  app.use morgan "combined"
  app.use express.static "./build"
  app.listen 1337
