# Adapters

    {curry, binary} = require "fairmont-core"
    {isFunction, isDefined} = require "fairmont-helpers"
    {Method} = require "fairmont-multimethods"
    {producer} = require "./adapters"
    {iterator, iteratorFunction, isIteratorFunction} = require "./iterator"
    {reactor, reactorFunction, isReactorFunction} = require "./reactor"

## producer

The most basic adapter simply takes a non-producer value and attempts to make it into a producer (either an iterator or reactor).

    producer = Method.create()

    Method.define producer, isIterable, (x) -> iteratorFunction x
    Method.define producer, isReagent, (x) -> reactorFunction x
    Method.define producer, isIterator, (i) -> iteratorFunction i
    Method.define producer, isReactor, (r) -> reactorFunction r
    Method.define producer, isIteratorFunction, identity
    Method.define producer, isReactorFunction, identity
    Method.define producer, isPromise, (p) -> reactorFunction p

## pull

Transform a synchronous iterator into an asynchronous iterator by extracting a Promise from the value produced by the iterator. The extracted Promise yields the value the original promise resolves to.

    pull = Method.create()

    Method.define pull, isDefined, (x) -> pull producer x

    Method.define pull, isIteratorFunction, (i) ->
      reactor ->
        {done, value} = i()
        if done then (W {done}) else value.then (value) -> {done, value}

    Method.define pull, isAsyncIteratorFunction, (i) ->
      reactor ->
        i().then ({done, value}) ->
          if done then (W {done}) else value.then (value) -> {done, value}

## repeat

Analogous to `wrap`for an iterator. Always produces the same value `x`.

    repeat = (x) -> (iterator -> done: false, value: x)

## events

    events = Method.create()
    isSource = compose isFunction, property "on"

    Method.define events, String, isSource, (name, source) ->
      events {name, end: "end", error: "error"}, source

    Method.define events, Object, isSource, ->

      {promise, reject, resolve} = require "when"

      (map, source) ->
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

        asyncIterator dequeue

    events = curry binary events

## stream

Turns a stream into an iterator function.

    stream = events "data"

## flow

      {curry} = require "fairmont-core"
      {async} = require "fairmont-helpers"
      {iterator, asyncIterator} = require "./iterator"
      {reduce} = require "./reducer"

      flow = ([i, fx...]) -> reduce i, ((i,f) -> f i), fx

## pump

      # TODO: need to add synchronous version

      pump = curry (s, i) ->
        asyncIterator async ->
          {done, value} = yield i()
          if !done
            value: (s.write value)
            done: false
          else
            s.end()
            {done}

## tee

      # TODO: need to add synchronous version

      tee = curry (f, i) ->
        asyncIterator async ->
          {done, value} = yield i()
          (f value) unless done
          {done, value}


## throttle

      throttle = curry (ms, i) ->
        last = 0
        asyncIterator async ->
          loop
            {done, value} = yield i()
            break if done
            now = Date.now()
            break if now - last >= ms
          last = now
          {done, value}

---

      module.exports = {flow, start, pump, tee, throttle}