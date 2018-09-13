import {Method} from "panda-generics"
import {identity, curry, pipe} from "panda-garden"
import {promise, isArray, isFunction} from "panda-parchment"

import {isIterable, isIterator, iterator} from "./iterator"
import {isReagent, isReactor, reactor} from "./reactor"

# isProducer

isProducer = (x) -> (isIterator x) || (isReactor x)

# producer

producer = Method.create
  description: "Attempts to turn its argument into an iterator or reactor."

Method.define producer, isIterable, (x) -> iterator x
Method.define producer, isReagent, (x) -> reactor x
Method.define producer, isProducer, identity

# repeat

repeat = (x) -> loop yield x ; return

# events

events = curry (name, source) ->
  handler = undefined
  source.on name, (event) ->
    handler event
  loop
    yield await promise (resolve) -> handler = resolve

# read

read = (s) ->
  _resolve = _reject = undefined
  end = false
  s.on "data", (data) -> _resolve data
  s.on "error", (error) -> _reject error
  s.on "end", -> end = true; _resolve()
  loop
    data = await promise (resolve, reject) ->
      _resolve = resolve
      _reject = reject
    if end then break else yield data

# union

union = (px...) ->

  _resolve = undefined
  queue = []
  i = 0

  for p in px
    do (p) ->
      for await x from producer p
        queue.push x
        _resolve()
      i++

  while i < px.length
    await promise (resolve) -> _resolve = resolve
    # copy queue before yielding values
    _queue = (x for x in queue); queue = []
    yield x for x in _queue
  # resolve the values that came in at the end
  yield x for x in queue

# flow

isFunctionList = (fx...) ->
  for f in fx when !isFunction f
    return false
  true

flow = Method.create
  description: "Compose functions and a producer."
  default: (x, fx...) -> flow (producer x), fx...

Method.define flow, isProducer, isFunctionList, (p, fx...) ->
  flow p, (pipe fx...)

Method.define flow, isProducer, isFunction, (p, f) -> f p

Method.define flow, isArray, (ax) -> flow ax...

# TODO: is there a way to determine if result of a flow
# (function composition) is going to be async or sync?
# I don't think so, but that means we have to assume
# async here. We might consider a modifier fn that
# can tag a flow as sync so we can avoid that.
go = (args...) ->
  undefined for await x from flow args...
  ;;


export {isProducer, producer, repeat, events, read, union, flow, go}
