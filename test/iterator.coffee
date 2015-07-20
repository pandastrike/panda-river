assert = require "assert"
Amen = require "amen"

Amen.describe "Iterator functions", (context) ->

  {createReadStream} = require "fs"

  {isIterable, isAsyncIterable,
    iterator, isIterator, isAsyncIterator,
    isIteratorFunction, isAsyncIteratorFunction, iteratorFunction,
    repeat, map, select, reject, filter, project, compact,
    partition, where, take, takeN,
    events, stream, lines, split} = require "../src/iterator"

  {odd, w} = require "fairmont-helpers"

  context.test "isIterable", -> assert isIterable [1, 2, 3]

  context.test "iteratorFunction", ->
    assert isIteratorFunction iteratorFunction [1..5]

  context.test "map", ->
    i = map Math.sqrt, [1, 4, 9]
    assert i().value == 1
    assert i().value == 2
    assert i().value == 3
    assert i().done

  context.test "select", ->
    i = select odd, [1..9]
    assert i().value == 1
    assert i().value == 3

  context.test "reject", ->
    i = reject odd, [1..9]
    assert i().value == 2
    assert i().value == 4

  context.test "project", ->
    i = project "length", w "one two three"
    assert i().value == 3

  context.test "compact", ->
    i = compact [1, null, null, 2]
    assert i().value == 1
    assert i().value == 2

  context.test "partition", ->
    i = partition 2, [0..9]
    assert i().value[0] == 0
    assert i().value[0] == 2

  context.test "take", ->

    context.test "takeN", ->
      i = takeN 3, [0..9]
      assert i().value == 0
      assert i().value == 1
      assert i().value == 2
      assert i().done

  context.test "where", ->
    pair = (x, y) -> [x, y]
    i = where ["a", 1], [["a", 2], ["a", 1], ["b", 1], ["a", 1]]
    assert i().value?
    assert i().value?
    assert i().done

  context.test "events", ->
    i = events "data", createReadStream "test/data/lines.txt"
    assert (yield i()).value.toString() == "one\ntwo\nthree\n"
    assert (yield i()).done

  context.test "stream", ->
    i = stream createReadStream "test/data/lines.txt"
    assert ((yield i()).value.toString() == "one\ntwo\nthree\n")
    assert (yield i()).done

  context.test "split", ->
    i = split ((x) -> x.split("\n")), ["one\ntwo\n", "three\nfour"]
    assert i().value == "one"
    assert i().value == "two"
    assert i().value == "three"
    assert i().value == "four"
    assert i().done

  context.test "lines", ->
    i = lines stream createReadStream "test/data/lines.txt"
    assert ((yield i()).value) == "one"
    assert ((yield i()).value) == "two"
    assert ((yield i()).value) == "three"
    assert ((yield i()).done)
