assert = require "assert"
Amen = require "amen"

Amen.describe "Iterators", (context) ->

  {isIterable, iterator, isIterator,
    next, value, isDone} = require "../src/iterator"

  context.test "isIterable", ->
    assert isIterable [1..5]
    assert !(isIterable 7)

  context.test "iterator", ->
    i = iterator [1..5]
    assert 1 == value next i
    assert 2 == value next i
    assert 3 == value next i
    assert 4 == value next i
    assert 5 == value next i
    assert isDone next i

    context.test "isIterator", ->
      assert isIterator iterator [1..5]
