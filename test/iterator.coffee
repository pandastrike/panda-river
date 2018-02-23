assert = require "assert"
import {isIterable, iterator, isIterator,
  next, value, isDone} from "../src/iterator"

testIterators = (test) ->

  test "Iterators", [

    test "isIterable", ->
      assert isIterable []
      assert isIterable iterator []

    test "isIterator", ->
      assert isIterator iterator []

    test "iterator/next/value/isDone", ->
      i = iterator [1..2]
      assert 1 == value next i
      assert 2 == value next i
      assert isDone next i

  ]

export {testIterators}
