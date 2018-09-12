assert = require "assert"
import {test} from "amen"
import {iterator, next, value, isDone} from "../src/iterator"
import {isReagent, reactor, isReactor} from "../src/reactor"

f = -> yield x for await x from [1..2]
export default [

  test "isReagent", ->
    assert isReagent [Symbol.asyncIterator]: ->

  test "isReactor", ->
    assert isReactor reactor f

  test "reactor/next/value/isDone", ->
    r = f()
    assert 1 == value await next r
    assert 2 == value await next r
    assert isDone await next r

]
