{join, basename} = require "path"
{glob, read, write, partial, _, isPromise,
  async, curry, map, start, flow, events,
  throttle} = require "fairmont"
jade = require "jade"
coffee = require "coffee-script"
fs = require "fs"

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
    yield write (join directory, "#{filename}#{extension}"), content

watchFile = curry (f, path) ->

  console.log "Watching file [#{path}] for changes..."

  start flow [
    events "change", fs.watch path
    throttle 5000
    map ->
      console.log "Change detected for file [#{path}]..."
      f()
    ]

module.exports = {glob, compileJade, compileCoffeeScript,
  writeFile, watchFile}
