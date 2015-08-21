assert = require "assert"
Amen = require "amen"
{promise} = require "when"

{next} = require "../src/iterator"
{events} = require "../src/adapters"
{observe} = require "../src/observe"

Amen.describe "Observe", (context) ->

  # TODO: this is not a great test, since it doesn't return if it fails
  context.test "change events", ->
    y = undefined
    x = value: 7
    observe x
    .on "change", (x) -> y = x.value
    x.value = 3
    setImmediate -> assert y == 3

    context.test "nested change events", ->
      y = undefined
      x = value: value: 7
      observe x
      .on "change", (x) -> y = x.value
      x.value.value = 3
      setImmediate -> assert y == 3

  context.test "for arrays", ->
    y = undefined
    x = [1..5]
    observe x
    .on "change", (x) -> y = x[3]
    x[3] = 0
    setImmediate -> assert y == 0


  context.test "as event stream", ->
    y = undefined
    x = value: 7
    i = events "change", observe x
    x.value = 3
    assert (yield next i).value.value == 3
