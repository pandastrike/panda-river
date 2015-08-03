{start, flow, events, map, evented} = require "fairmont-reactive"

$ = require "jquery"

$ ->

  data = counter: 0

  start flow [
    events "click", $("a")
    map -> data.counter++
  ]

  start flow [
    events "change", evented data
    map ->
      $("p#counter")
      .html data.counter
  ]
