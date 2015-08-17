{createReadStream} = require "fs"

_when = require "when"

assert = require "assert"
Amen = require "amen"

{next} = require "../src/iterator"

{map, accumulate, select, filter, reject, project, compact,
  partition, take, takeN, where, split, lines, tee,
  throttle, pump} = require "../src/filters"

{odd, w} = require "fairmont"

{reactor} = require "../src/reactor"
counter = (n = 0) -> reactor -> _when {done: false, value: n++}

Amen.describe "Filters", (context) ->

  context.test "map", ->
    i = map Math.sqrt, [1, 4, 9]
    assert i().value == 1
    assert i().value == 2
    assert i().value == 3
    assert i().done

  context.test "accumulate", ->
    add = (x, y) -> x + y
    i = accumulate add, 0, [1..5]
    assert (next i).value == 1
    assert (next i).value == 3
    assert (next i).value == 6

  context.test "accumulate (reactor)", ->
    add = (x, y) -> x + y
    i = accumulate add, 0, (counter 1)
    assert (yield next i).value == 1
    assert (yield next i).value == 3
    assert (yield next i).value == 6

  context.test "select", ->
    i = select odd, [1..9]
    assert i().value == 1
    assert i().value == 3

  context.test "select (w/reactor)", ->
    i = select odd, counter()
    assert (yield i()).value == 1
    assert (yield i()).value == 3

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

  context.test "split", ->
    i = split ((x) -> x.split("\n")), ["one\ntwo\n", "three\nfour"]
    assert i().value == "one"
    assert i().value == "two"
    assert i().value == "three"
    assert i().value == "four"
    assert i().done

  context.test "lines", ->
    i = lines ["one\ntwo\n", "three\nfour"]
    assert ((yield i()).value) == "one"
    assert ((yield i()).value) == "two"
    assert ((yield i()).value) == "three"
    assert ((yield i()).value) == "four"
    assert ((yield i()).done)
