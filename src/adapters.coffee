import {Method} from "panda-generics"
import {identity, curry} from "panda-garden"
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
  source.on name, (event) -> handler event
  loop
    yield await promise (resolve) -> handler = resolve

# stream

stream = (s) ->
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

union = (producers) ->

  product = undefined

  produce = (x) ->
    _resolve x
    product = promise (resolve, reject) -> _resolve = resolve

  for producer in producers
    do (producer) -> produce x for await x from producer

  loop
    yield await product

# flow

isFunctionList = (fx...) ->
  for f in fx when !isFunction f
    return false
  true

flow = Method.create
  description: "Compose functions and a producer."
  default: (x, fx...) -> flow (producer x), fx...

Method.define flow, isProducer, isFunction, (p, f) ->
  map f, p

Method.define flow, isProducer, isFunctionList, (p, fx...) ->
  flow p, (pipe fx...)

Method.define flow, isArray, (ax) -> flow ax...

export {isProducer, producer, repeat, events, stream, union, flow}
