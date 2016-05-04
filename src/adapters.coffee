Core = require "fairmont-core"
Helpers = require "fairmont-helpers"
{Method} = require "fairmont-multimethods"

{apply, pipe, curry, compose, binary, identity} = Core
{include, property, isEmpty} = Helpers
{isType, isDefined} = Helpers
{isString, isObject, isArray, isFunction} = Helpers
{promise, follow, isPromise} = Helpers

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

repeat = (x) -> (iterator -> done: false, value: x)

_pull = ({done, value}) ->
  if done
    follow {done}
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

# `queue` and `combine` return reactors because
# they don't make sense with iterators.
# That is, you'd just us arrays otherwise.

# create a reactor that can enqueue values
queue = ->

  done = false
  pending = []
  resolved = []

  end = ->
    done = true
    resolve {done} for {resolve} in pending

  enqueue = (value) ->
    unless done
      if pending.length == 0
        resolved.push {done, value}
      else
        {resolve, reject} = pending.shift()
        follow value
        .then (value) -> resolve {done, value}
        .catch reject

  dequeue = ->
    if resolved.length == 0
      if !done
        promise (resolve, reject) -> pending.push {resolve, reject}
      else
        {done}
    else
      resolved.shift()

  {enqueue, dequeue: (reactor dequeue), end}

# Similar to zip, except that one producer can race out in
# front of another and we produce values on at a time

combine = (px...) ->

  count = px.length
  {dequeue, enqueue, end} = queue()

  wait = (p) ->
    follow next p
    .then ({done, value}) ->
      if done
        end() if --count == 0
      else
        enqueue value
        wait p
    .catch (error) ->
      enqueue error

  (wait producer p) for p in px

  dequeue

events = Method.create()
isSource = compose isFunction, property "on"

do (defaults = end: "end", error: "error") ->

  Method.define events, isString, isSource, (name, source) ->
    events (include {name}, defaults), source

  Method.define events, isObject, isSource, (map, source) ->

    map = include defaults, map

    {enqueue, dequeue, end} = queue()

    source.on map.name, (ax...) ->
      value = if ax.length < 2 then ax[0] else ax
      enqueue value

    source.on map.end, end

    source.on map.error, enqueue

    dequeue

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

module.exports = {producer, pull, repeat, queue, events, stream, flow, combine}
