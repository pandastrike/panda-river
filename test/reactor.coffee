assert = require "assert"
Amen = require "amen"

Amen.describe "Reactors", (context) ->

  {isReagent, reactor, isReactor,
    isReactorFunction, reactorFunction} = require "../src/reactor"

  W = require "when"

  context.test "isReagent"

  context.test "reactorFunction", ->
    context.test "isReactorFunction", ->
      assert isReactorFunction reactorFunction W [1..5]
