{start, flow, events, map, observe} = require "fairmont-reactive"

$ = require "jquery"

$ ->

  todos = []

  start flow [
    events "change", $("input")
    map (event) ->
      console.log arguments
  ]

  # start flow [
  #   events "change", observe data
  #   map ->
  #     $("p.counter")
  #     .html data.counter
  # ]
