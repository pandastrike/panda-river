assert = require "assert"
Amen = require "amen"

Amen.describe "Iterators", (context) ->

  {isIterable, iterator, isIterator,
    isIteratorFunction, iteratorFunction} = require "../src/iterator"

  context.test "isIterable", -> assert isIterable [1..5]

  context.test "iteratorFunction", ->
    context.test "isIteratorFunction", ->
      assert isIteratorFunction iteratorFunction [1..5]
