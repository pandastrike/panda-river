assert = require "assert"
import {follow} from "panda-parchment"
import {iterator, next, value, isDone} from "../src/iterator"
import {isReagent, reactor, isReactor} from "../src/reactor"

testReactors = (test) ->

  # emulate an async counter
  createCounter = (array) ->
    i = iterator array
    reactor -> follow next i

  test "Reactors", [

    test "isReagent", ->
      assert isReagent createCounter []

    test "isReactor", ->
      assert isReactor createCounter []

    test "reactor/next/value/isDone", ->
      r = createCounter [1..2]
      assert 1 == value await next r
      assert 2 == value await next r
      assert isDone await next r

  ]

export {testReactors}
