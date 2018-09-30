import {test} from "amen"
assert = require "assert"

import {map, project, accumulate, select, filter, reject, compact,
  tee, partition, take, limit, wait, lines, throttle} from "../src/filters"

{odd, merge, follow} = require "panda-parchment"

# we need to do things with the values
square = (x) -> x * x
add = (x, y) -> x + y

spec = (name, {expected, filter, iterable}) ->

  test name, [
    test "iterator", ->
      assert.deepEqual expected,
        (x for x from filter iterable)

    test "reactor", ->
      r = -> yield x for await x from iterable
      assert.deepEqual expected,
        (x for await x from filter r)
  ]

export default [

  spec "map",
    expected: [1, 4, 9, 16]
    filter: map square
    iterable: [1..4]

  spec "accumulate",
    expected: [1, 3, 6, 10]
    filter: accumulate add, 0
    iterable: [1..4]

  spec "select",
    expected: [1, 3, 5]
    filter: select odd
    iterable: [1..5]

  spec "tee",
    expected: [1..4]
    filter: tee square
    iterable: [1..4]

  spec "partition",
    expected: [[1, 2], [3, 4]]
    filter: partition 2
    iterable: [1..4]

  spec "take",
    expected: [1..3]
    filter: take (x) -> x <= 3
    iterable: [1..4]

  test "throttle"

  spec "lines",
    expected: [ "one", "two", "three" ]
    filter: lines
    iterable: [ "one\ntwo", "\nthree" ]

]
