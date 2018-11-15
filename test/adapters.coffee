import assert from "assert"
import {createReadStream} from "fs"
import EventEmitter from "events"
import {test} from "amen"

import {follow} from "panda-parchment"

import {isIterator} from "../src/iterator"
import {isReactor} from "../src/reactor"
import {map} from "../src/filters"

import {isProducer, producer,
  repeat, events, read, union,
  flow, go, into, wait, pool} from "../src/adapters"

export default [
  test "producer", ->
    assert isIterator (producer [])
    assert isReactor (producer -> yield await null)

  test "repeat", ->
    x = 0
    for i from repeat 0
      break if x++ > 5
      assert.equal 0, i

  test "events", ->
    source = new EventEmitter
    do ->
      for i in [1..5]
        await follow 1
        source.emit "test", i
    j = 1
    for await i from (events "test", source)
      assert.equal j++, i
      break if i == 5

  test "read", ->
    content = ""
    for await data from (read createReadStream "test/data/lines.txt")
      content += data.toString()
    assert.equal "one\ntwo\nthree\n", content

  test "union", ->
    assert.deepEqual [ 1, 1, 2, 2, 3, 3, 4, 4, 5, 5 ],
      (x for await x from (union [1..5], [1..5]))

  test "flow", ->
    r = flow [
      [1..5]
      map (x) -> x * 2
    ]
    assert.deepEqual [ 2, 4, 6, 8, 10 ],
      (x for await x from r)

  test "go", [

    test "with producer", ->
      results = []
      await go [
        [1..5]
        map (x) -> x * 2
        map (x) -> results.push x
      ]
      assert.deepEqual [ 2, 4, 6, 8, 10 ], results

    test "with promise", ->
      results = []
      await go [
        follow [1..5]
        map (x) -> x * 2
        map (x) -> results.push x
      ]
      assert.deepEqual [ 2, 4, 6, 8, 10 ], results
  ]

  test "into", ->
    results = []
    await go [
      [1..5]
      map (n) -> [1..n]
      map into [
        map (n) -> results.push n
      ]
    ]
    assert.deepEqual [
      1,
      1, 2,
      1, 2, 3,
      1, 2, 3, 4,
      1, 2, 3, 4, 5
      ], results

  test "wait", ->
    results = []
    await go [
      [1..5]
      wait map (x) -> follow x * 2
      map (x) -> results.push x
    ]
    assert.deepEqual [ 2, 4, 6, 8, 10 ], results

  test "pool", ->
    results = []
    await go [
      [1..5]
      pool map (x) ->
        # prove that we don't append to the array until
        # all the results are in ...
        follow if results.length == 0 then x * 2
      map (x) -> results.push x
    ]
    assert.deepEqual [ 2, 4, 6, 8, 10 ], results


]
