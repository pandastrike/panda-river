assert = require "assert"
Amen = require "amen"
{follow} = require "fairmont-helpers"

{isReagent, reactor, isReactor} = require "../src/reactor"

Amen.describe "Reactors", (context) ->

  counter = (n = 0) -> reactor -> follow {done: false, value: n++}

  context.test "isReagent", ->
    assert isReagent counter()

  context.test "reactor", ->
    context.test "isReactor", ->
      assert isReactor counter()
