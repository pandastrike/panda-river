assert = require "assert"
Amen = require "amen"
{promise} = require "when"

{events} = require "../src/adapters"
{evented} = require "../src/evented"

Amen.describe "Evented Data", (context) ->

  # TODO: this is not a great test, since it doesn't return if it fails
  context.test "change events", ->
    x = foo: 5, bar: baz: 3
    z = evented x
    p = promise (resolve) ->
      z.once "change", -> resolve()
    x.foo = 7
    yield p

    context.test "nested change events", ->
      p = promise (resolve) ->
        z.once "change", -> resolve()
      x.bar.baz = 5
      yield p

  context.test "for arrays", ->
    x = [1..5]
    z = evented x
    p = promise (resolve) ->
      z.once "change", -> resolve()
    x.shift()
    yield p


  context.test "as event stream", ->
    x = foo: 5
    z = evented x
    i = events "change", z
    x.foo = 7
    yield i()
