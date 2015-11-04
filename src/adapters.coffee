_when = require "when"
{promise, reject, resolve} = _when
{apply, pipe, curry, compose, binary, identity} = require "fairmont-core"
{isType, isString, isObject, isEmpty, isFunction, isArray, isDefined, isPromise,
  property} = require "fairmont-helpers"
{Method} = require "fairmont-multimethods"
{producer} = require "./adapters"
{isIterable, isIterator, isIterator, iterator, next} = require "./iterator"
{isReagent, isReactor, isReactor, reactor} = require "./reactor"

isProducer = (x) -> (isIterator x) || (isReactor x)

producer = Method.create()

Method.define producer, isIterable, (x) -> iterator x
Method.define producer, isReagent, (x) -> reactor x
Method.define producer, isProducer, identity
Method.define producer, isPromise, (p) ->
  _p = p.then (x) -> iterator x
  reactor -> _p.then (i) -> next i

_pull = ({done, value}) ->
  if done
    (_when {done})
  else if value?.then?
    value.then (value) -> {done, value}
  else
    {done, value}

pull = Method.create()

Method.define pull, isDefined, (x) -> pull producer x

Method.define pull, isIterator, (i) ->
  reactor -> _pull next i

Method.define pull, isReactor, (i) ->
  reactor -> (next i).then _pull

combine = (px...) ->
  # this is basically a cut-and-paste job from the implementation
  # of ::events below...this suggests there might be a common
  # function here that both of these could be based on
  count = px.length
  done = false
  pending = []
  resolved = []

  enqueue = (x) ->
    if pending.length == 0
      resolved.push x
    else
      p = pending.shift()
      x
      .then p.resolve
      .catch p.reject

  dequeue = ->
    if resolved.length == 0
      if !done
        promise (resolve, reject) -> pending.push {resolve, reject}
      else
        resolve {done}
    else
      resolved.shift()

  wait = (p) ->
    x = next p
    if isPromise x
      x
      .then (y) ->
        wait p
        enqueue x
      .catch (e) ->
        enqueue e
        count--
        if count == 0
          done = true
    else
      if !x.done
        wait p
        enqueue x
      else
        count--
        if count == 0
          done = true

  (wait (producer p)) for p in px

  reactor dequeue


repeat = (x) -> (iterator -> done: false, value: x)

events = Method.create()
isSource = compose isFunction, property "on"

Method.define events, isString, isSource, (name, source) ->
  events {name, end: "end", error: "error"}, source

Method.define events, isObject, isSource, (map, source) ->
  {name, end, error} = map
  end ?= "end"
  error ?= "error"
  done = false
  pending = []
  resolved = []

  enqueue = (x) ->
    if pending.length == 0
      resolved.push x
    else
      p = pending.shift()
      x.then(p.resolve).catch(p.reject)

  dequeue = ->
    if resolved.length == 0
      if !done
        promise (resolve, reject) -> pending.push {resolve, reject}
      else
        resolve {done}
    else
      resolved.shift()

  source.on name, (ax...) ->
    value = if ax.length < 2 then ax[0] else ax
    enqueue resolve {done, value}

  source.on end, (error) ->
    done = true
    enqueue resolve {done}
  source.on error, (error) -> enqueue reject error

  reactor dequeue

events = curry binary events

stream = events "data"

flow = Method.create()

isFunctionList = (fx...) ->
  for f in fx
    return false if !isFunction f
  true

Method.define flow, isDefined, isFunctionList,
  (x, fx...) -> flow (producer x), fx...

Method.define flow, isArray, (ax) -> flow ax...

Method.define flow, isProducer, isFunctionList,
  (p, fx...) -> apply (pipe fx...), p

module.exports = {producer, pull, repeat, events, stream, flow, combine}
