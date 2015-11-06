{createReadStream} = require "fs"

assert = require "assert"

Amen = require "amen"

{next, value, isDone} = require "../src/iterator"

{producer, pull, repeat, events,
  stream, flow, combine} = require "../src/adapters"

{map, lines} = require "../src/filters"

Amen.describe "Adapters", (context) ->

  context.test "pull"

  context.test "pull (non-promise)"

  context.test "pull (undefined)" #, ->
    # i = flow [
    #   [1..5]
    #   map (x) -> undefined
    #   pull
    # ]
    # assert next i
    # assert next i
    # assert next i
    # assert next i
    # assert next i
    # assert isDone i

  context.test "events", ->
    i = events "data", createReadStream "test/data/lines.txt"
    assert (yield i()).value.toString() == "one\ntwo\nthree\n"
    assert (yield i()).done

  context.test "stream", ->
    i = stream createReadStream "test/data/lines.txt"
    assert ((yield i()).value.toString() == "one\ntwo\nthree\n")
    assert (yield i()).done

  context.test "flow", ->
    i = flow [
      [1..5]
      map (n) -> n * 2
    ]
    assert 2 == value next i
    assert 4 == value next i
    assert 6 == value next i
    assert 8 == value next i
    assert 10 == value next i
    assert isDone next i

  context.test "flow (reactive)", ->

    i = flow [
      stream createReadStream "./test/data/lines.txt"
      lines
      map (line) -> line[0]
    ]

    assert (yield i()).value == "o"
    assert (yield i()).value == "t"
    assert (yield i()).value == "t"
    assert (yield i().done)

  context.test "flow (argument list)", ->

    i = flow (stream createReadStream "./test/data/lines.txt"), lines

    assert (yield i()).value == "one"
    assert (yield i()).value == "two"
    assert (yield i()).value == "three"
    assert (yield i().done)

  context.test "combine", ->
    a = [1..5]
    b = [1..5]
    i = combine a, b
    (assert !(yield (next i)).done) for j in [1..10]
    assert (yield (next i)).done
