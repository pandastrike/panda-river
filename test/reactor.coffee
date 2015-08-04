_when = require "when"

assert = require "assert"
Amen = require "amen"

{isReagent, reactor, isReactor} = require "../src/reactor"

Amen.describe "Reactors", (context) ->

  counter = (n = 0) -> reactor -> _when {done: false, value: n++}

  context.test "isReagent", ->
    assert isReagent counter()

  context.test "reactor", ->
    context.test "isReactor", ->
      assert isReactor counter()
