{createReadStream} = require "fs"
assert = require "assert"

{follow} = require "panda-parchment"

{next, value, isDone} = require "../src/iterator"

{map, accumulate, select, filter, reject, project, compact,
  partition, take, takeN, where, lines, tee,
  throttle, pump} = require "../src/filters"

{odd, w} = require "panda-parchment"

{iterator} = require "../src/iterator"
{reactor} = require "../src/reactor"

# iterator and reactor based on a range
# to produce values used in tests
counter = (range) ->
  iterator: range
  # convert iterable to async via generator
  # using do returns the async iterator
  reactor: -> yield x for await x from range

# we need to do things with the values
square = (x) -> x * x
add = (x, y) -> x + y

testFilters = (test) ->

  spec = (name, {expected, filter, producer: {iterator, reactor}}) ->

    test name, [
      test "iterator", ->
        assert.deepEqual expected,
          (x for x from filter iterator)

      test "reactor", ->
        assert.deepEqual expected,
          (x for await x from filter reactor)
    ]

  test "Filters", [

    spec "map",
      expected: [1, 4, 9, 16]
      filter: map square
      producer: counter [1..4]
    spec "accumulate",
      expected: [1, 3, 6, 10]
      filter: accumulate add, 0
      producer: counter [1..4]
    spec "select",
      expected: [1, 3, 5]
      filter: select odd
      producer: counter [1..5]
    spec "tee",
      expected: [1..4]
      filter: tee square
      producer: counter [1..4]
    spec "partition",
      expected: [[1, 2], [3, 4]]
      filter: partition 2
      producer: counter [1..4]
      

    #
    # test "select (iterator)", ->
    #   iteratorTest
  #   test "select", ->
  #     i = select odd, [1..9]
  #     assert i().value == 1
  #     assert i().value == 3
  #
  #   test "select (w/reactor)", ->
  #     i = select odd, counter()
  #     assert (yield i()).value == 1
  #     assert (yield i()).value == 3
  #
  #   test "reject", ->
  #     i = reject odd, [1..9]
  #     assert i().value == 2
  #     assert i().value == 4
  #
  #   test "project", ->
  #     i = project "length", w "one two three"
  #     assert i().value == 3
  #
  #   test "compact", ->
  #     i = compact [1, null, null, 2]
  #     assert i().value == 1
  #     assert i().value == 2
  #
  #   test "partition", ->
  #     i = partition 2, [0..9]
  #     assert i().value[0] == 0
  #     assert i().value[0] == 2
  #
  #   test "take", ->
  #
  #     test "takeN", ->
  #       i = takeN 3, [0..9]
  #       assert i().value == 0
  #       assert i().value == 1
  #       assert i().value == 2
  #       assert i().done
  #
  #   test "where", ->
  #     pair = (x, y) -> [x, y]
  #     i = where ["a", 1], [["a", 2], ["a", 1], ["b", 1], ["a", 1]]
  #     assert i().value?
  #     assert i().value?
  #     assert i().done
  #
  #   # test "split", ->
  #   #   i = split ((x) -> x.split("\n")), ["one\ntwo\n", "three\nfour"]
  #   #   assert i().value == "one"
  #   #   assert i().value == "two"
  #   #   assert i().value == "three"
  #   #   assert i().value == "four"
  #   #   assert i().done
  #   #
  #   test "lines", ->
  #     i = lines ["one\ntwo\n", "three\nfour"]
  #     assert ((yield i()).value) == "one"
  #     assert ((yield i()).value) == "two"
  #     assert ((yield i()).value) == "three"
  #     assert ((yield i()).value) == "four"
  #     assert ((yield i()).done)
  #
  ]


export {testFilters}
