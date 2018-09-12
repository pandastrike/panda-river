import assert from "assert"
import {test} from "amen"

import {isIterator} from "../src/iterator"
import {isReactor} from "../src/reactor"
import {isProducer, producer,
  repeat, wait, events, stream, union, flow} from "../src/adapters"

export default [
  test "producer", ->
    assert isIterator (producer [])
    assert isReactor (producer -> yield await null)

  test "repeat", ->
    x = 0
    for i from repeat 0
      break if x++ > 5
      assert.equal 0, i
  test "wait"
  test "events"
  test "stream"
  test "union"
  test "flow"
]
