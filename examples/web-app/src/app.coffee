{start, flow, events, map} = require "fairmont-reactive"

$ = require "jquery"

$ ->

  start flow [
    events "click", $("a")
    map -> console.log "You clicked me!"
  ]
