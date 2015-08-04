# Adapters

Adapters create producers (iterators or reactors) from other values.

    _when = require "when"
    {promise, reject, resolve} = _when
    {curry, compose, binary, identity} = require "fairmont-core"
    {isFunction, isDefined, isPromise, property} = require "fairmont-helpers"
    {Method} = require "fairmont-multimethods"
    {producer} = require "./adapters"
    {isIterable, isIterator, isIterator, iterator, next} = require "./iterator"
    {isReagent, isReactor, isReactor, reactor} = require "./reactor"

## producer

The most basic adapter simply takes a non-producer value and attempts to make it into a producer (either an iterator or reactor).

    producer = Method.create()

    Method.define producer, isIterable, (x) -> iterator x
    Method.define producer, isReagent, (x) -> reactor x
    Method.define producer, isIterator, identity
    Method.define producer, isReactor, identity
    Method.define producer, isPromise, (p) ->
      _p = p.then (x) -> iterator x
      reactor -> _p.then (i) -> next i

## pull

Transform a synchronous iterator into an asynchronous iterator by extracting a Promise from the value produced by the iterator. The extracted Promise yields the value the original promise resolves to.

    pull = Method.create()

    Method.define pull, isDefined, (x) -> pull producer x

    Method.define pull, isIterator, (i) ->
      reactor ->
        {done, value} = next i
        if done then (_when {done}) else value.then (value) -> {done, value}

    Method.define pull, isReactor, (i) ->
      reactor ->
        i().then ({done, value}) ->
          if done then (_when {done}) else value.then (value) -> {done, value}

## repeat

Analogous to `wrap`for an iterator. Always produces the same value `x`.

    repeat = (x) -> (iterator -> done: false, value: x)

## events

    events = Method.create()
    isSource = compose isFunction, property "on"

    Method.define events, String, isSource, (name, source) ->
      events {name, end: "end", error: "error"}, source

    Method.define events, Object, isSource, (map, source) ->
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

## stream

Turns a stream into reactor.

    stream = events "data"

## flow

We don't use `reduce` here to avoid a circular dependency.

    flow = ([x, fx...]) -> fx.reduce ((i,f) -> f i), (producer x)



---

    module.exports = {producer, pull, repeat, events, stream, flow}
