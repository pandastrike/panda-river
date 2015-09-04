{go, events, map, observe} = require "fairmont-reactive"

$ = require "jquery"

$ ->

  data = counter: 0

  go [
    events "click", $("a[href='#increment']")
    map -> data.counter++
  ]

  go [
    events "change", observe data
    map ->
      $("p.counter")
      .html data.counter
  ]
