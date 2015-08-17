{createReadStream} = require "fs"

assert = require "assert"

Amen = require "amen"

{next} = require "../src/iterator"

{producer, pull, repeat, events,
  stream, flow, combine} = require "../src/adapters"

{map, lines} = require "../src/filters"

Amen.describe "Adapters", (context) ->

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
