{start, flow, events, map, evented} = require "fairmont-reactive"

$ = require "jquery"

$ ->

  data = {}

  start flow [
    events "click", $("a")
    map -> data.counter++
  ]

  console.log evented
