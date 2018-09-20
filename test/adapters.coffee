import assert from "assert"
import {createReadStream} from "fs"
import EventEmitter from "events"
import {test} from "amen"

import {follow, sleep} from "panda-parchment"

import {isIterator} from "../src/iterator"
import {isReactor} from "../src/reactor"
import {map, tee, wait} from "../src/filters"

import {isProducer, producer,
  repeat, events, read, union, flow, go} from "../src/adapters"

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
        await sleep 1
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

  test "union"
  # test "union", ->
  #   assert.deepEqual [ 1, 1, 2, 2, 3, 3, 4, 4, 5, 5 ],
  #     (x for await x from (union [1..5], [1..5]))

  test "flow", ->
    r = flow [
      [1..5]
      map (x) -> x * 2
      tee -> sleep 1
      wait
    ]
    assert.deepEqual [ 2, 4, 6, 8, 10 ],
      (x for await x from r)

  test "go", ->
    results = []
    await go [
      [1..5]
      map (x) -> x * 2
      tee -> sleep 1
      wait
      map (x) -> results.push x
    ]
    assert.deepEqual [ 2, 4, 6, 8, 10 ], results

]
