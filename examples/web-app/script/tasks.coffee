{createWriteStream} = require "fs"
{join} = require "path"
{mkdirp, start, flow, map, async} = require "fairmont"
{glob, compileJade, compileCoffeeScript,
  writeFile, watchFile} = require "./helpers"
browserify = require "browserify"
express = require "express"
morgan = require "morgan"

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

task "watch-templates", async ->
  yield start flow [
    yield glob "src/*.jade"
    map watchFile -> task "templates"
  ]

task "watch-code", async ->
  yield start flow [
    yield glob "src/*.coffee"
    map watchFile -> task "bundle"
  ]

task "watch", "watch-code", "watch-templates"

task "serve", ->
  app = express()
  app.use morgan "combined"
  app.use express.static "./build"
  app.listen 1337
