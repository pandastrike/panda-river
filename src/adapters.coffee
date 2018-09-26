import {Method} from "panda-generics"
import {identity, curry, pipe} from "panda-garden"
import {promise, follow, reject, isArray, isFunction} from "panda-parchment"

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
  source.on name, (event) -> q.enqueue event
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
