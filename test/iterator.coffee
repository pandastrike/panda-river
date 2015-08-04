assert = require "assert"
Amen = require "amen"

Amen.describe "Iterators", (context) ->

  {isIterable, iterator, isIterator} = require "../src/iterator"

  context.test "isIterable", -> assert isIterable [1..5]

  context.test "iterator", ->
    context.test "isIterator", ->
      assert isIterator iterator [1..5]
