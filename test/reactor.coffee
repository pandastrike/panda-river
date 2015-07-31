_when = require "when"

assert = require "assert"
Amen = require "amen"

{isReagent, reactor, isReactor,
  isReactorFunction, reactorFunction} = require "../src/reactor"

Amen.describe "Reactors", (context) ->

  counter = (n = 0) -> reactor -> _when {done: false, value: n++}

  context.test "isReagent", ->
    assert isReagent counter()

  context.test "reactorFunction", ->
    context.test "isReactorFunction", ->
      assert isReactorFunction counter()
