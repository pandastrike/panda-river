import {Method} from "panda-generics"
import {identity, curry, binary, compose, pipe, flip} from "panda-garden"
import {promise, follow, reject, all,
  isDefined, isArray, isFunction, isPromise} from "panda-parchment"

import {isIterable, isIterator, iterator} from "./iterator"
import {isReagent, isReactor, reactor} from "./reactor"
import {start, collect} from "./reducers"

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

# queue

queue = ->
  q = []
  p = []
  enqueue: (value) ->
    if p.length > 0
      resolve = p.shift()
      resolve value
    else
      q.push value
  dequeue: dq = ->
    if q.length > 0
      follow q.shift()
    else
      promise (resolve) -> p.push resolve
  idle: -> p.length == 0 && q.length == 0

# events

events = curry (name, source) ->
  q = queue()
  if source.on?
    source.on name, (event) -> q.enqueue event
  else if source.addEventListener?
    source.addEventListener name, (event) -> q.enqueue event
  else throw new TypeError "events: source must support
    `on` or `addEventListener` method"
  loop yield await q.dequeue()

# read

read = (s) ->
  q = queue()
  end = false
  s.on "data", (data) -> q.enqueue data
  s.on "error", (error) -> q.enqueue reject error
  s.on "end", ->
    end = true
    q.enqueue undefined

  loop
    data = await q.dequeue()
    if end then break else yield data

# union

union = (px...) ->
  q = queue()
  done = 0
  for p in px
    do (p) ->
      q.enqueue x for await x from p
      done++
  loop
    yield await q.dequeue()
    break if done == px.length
  yield await q.dequeue() until q.idle()

# flow

isFunctionList = (fx...) ->
  return false for f in fx when !isFunction f
  true

flow = Method.create
  description: "Compose functions and a producer."

# check for promise

Method.define flow, isDefined, isArray, (x, ax) -> flow x, ax...
Method.define flow, isDefined, isFunctionList, (x, fx...) -> flow x, pipe fx...
Method.define flow, isDefined, isFunction, (x, f) -> flow (producer x), f
Method.define flow, isPromise, isFunction, (x, f) -> flow (await x), f
Method.define flow, isProducer, isFunction, (p, f) -> f p
Method.define flow, isArray, (ax) -> flow ax...

go = compose start, flow

into = curry binary flip go

wait = curry (filter, producer) ->
  yield await x for await x from filter producer

pool = curry (filter, producer) ->
  yield x for x in await all collect filter producer

export {isProducer, producer, repeat,
  events, read, union,
  flow, go, into, wait, pool}
