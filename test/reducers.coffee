import assert from "assert"
import {test} from "amen"

import {identity} from "panda-garden"
import {first, add, odd, push, w} from "panda-parchment"

import {reduce, fold, foldr, collect, each, start, any, all,
  sum, average, delimit} from "../src/reducers"

spec = (name, {expected, reducer, iterable}) ->

  test name, [
    test "iterator", ->
      assert.deepEqual expected, reducer iterable

    test "reactor", ->
      r = -> yield x for await x from iterable
      assert.deepEqual expected, await reducer r
  ]

export default [

  spec "collect",
    iterable: [1..5]
    expected: [1..5]
    reducer: collect

  spec "each",
    iterable: [1..5]
    expected: undefined
    reducer: each do (y=1) ->
      (x) ->
        assert x == y
        y = (y % 5) + 1

  spec "fold/reduce",
    iterable: [1..5]
    expected: 15
    reducer: fold add, 0

  spec "foldr/reduceRight",
    iterable: "panama"
    expected: "amanap"
    reducer: foldr add, ""

  spec "any",
    iterable: [1..5]
    expected: true
    reducer: any odd

  spec "all",
    iterable: [1..5]
    expected: false
    reducer: all odd

  spec "sum",
    iterable: [1..5]
    expected: 15
    reducer: sum

  spec "average",
    iterable: [1..5]
    expected: 3
    reducer: average

  spec "delimit",
    iterable: [ "one", "two", "three" ]
    expected: "one, two, three"
    reducer: delimit ", "
]
