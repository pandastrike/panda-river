global.$p = -> console.error arguments...
vm = require "vm"
fs = require "fs"
{resolve, basename, extname, dirname} = require "path"
tools = require "panda-builder"
{target} = tools require "gulp"

target "npm"

gulp = require "gulp"
del = require "del"
pug = require "gulp-pug"
stylus = require "gulp-stylus"
# TODO: switch to support for import
vhtml = (require "biscotti-html").default
vcss = (require "biscotti-css").default
bpp = (require "biscotti-cpp").default
{HTML} = require "panda-vdom"
coffeescript = require "coffeescript"
webserver = require "gulp-webserver"
thru = require "through2"
yaml = require "js-yaml"
webpack = require "webpack"
_pug = require "pug"
mdit = require "markdown-it"
replace = require "gulp-replace"
{first} = require "fairmont-helpers"

{task, series, parallel, src, dest, watch} = gulp

md = do ->
  _md = mdit
    html: true
    linkify: true
    typographer: true
  .use (require "markdown-it-anchor")
  .use (require "markdown-it-implicit-figures")
  (text) -> _md.render text

tee = (f) ->
  thru.obj (file, encoding, callback) ->
    await f file, encoding
    callback null, file

pluck = (key, f) ->
  tee (file) -> f file[key]

extension = (extension) ->
  tee (file) ->
    file.extname = extension

content = (f) ->
  tee (file, encoding) ->
    file.contents = Buffer.from await f (file.contents.toString encoding), file

globExtension = ext = (extension) ->
  [ "www/**/*.#{extension}", "!**/_*/**" ]

task "www:server", ->
  src "build/www"
  .pipe webserver
      livereload: true
      port: 8080

task "www:clean", ->
  del "build/www"

task "www:pug:html", ->
  src ext "pug"
  .pipe pug
    basedir: "www"
    filters:
      markdown: (text) -> md text
  .pipe dest "build/www"

task "www:vhtml:html", ->
  src ext "vhtml"
  .pipe content (string) ->
    render = do vhtml
    HTML.render first await render content: string
  .pipe extension ".html"
  .pipe dest "build/www"

task "www:bpp:html", ->
  src ext "bpp"
  .pipe content (string) ->
    render = bpp {require}
    await render content: string
  .pipe extension ".html"
  .pipe dest "build/www"


task "www:css", ->
  src ext "styl"
  .pipe stylus()
  .pipe dest "build/www"

task "www:js", ->
  new Promise (yay, nay) ->
    webpack
      mode: "production"
      entry: "./www/site.coffee"
      output:
        path: resolve "build/www"
        filename: "site.js"
      module:
        rules: [
          test: /\.coffee$/
          use: [
            {
              loader: 'coffee-loader',
              options: { sourceMap: true }
            }
          ]
        ]
      resolve:
        modules: [
          # path.resolve "lib"
          resolve "node_modules"
        ]
        extensions: [ ".js", ".json", ".coffee" ]
      (error, result) ->
        console.error result.toString colors: true
        if error? || result.hasErrors()
          nay error
        else
          yay()

task "www:copy", ->
  src [ "www/images/**/*" ]
  .pipe dest "build/www/images"

# watch doesn't take a task name for some reason
# so we need to first define this as a function
build = series "www:clean",
  parallel "www:pug:html", "www:bpp:html", "www:css", "www:js", "www:copy"

task "www:build", build

task "www:watch", ->
  # TODO this isn't picking up changes
  # to the stylus or coffeescript files
  watch [ "www/**/*" ], build

task "www:dev",
  series "www:build", parallel "www:watch", "www:server"
