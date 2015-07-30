# Filters

## repeat

Analogous to `wrap`for an iterator. Always produces the same value `x`.

    repeat = (x) -> (iterator -> done: false, value: x)

## map

Return a new iterator that will apply the given function to each value produced by the iterator.

    map = Method.create()

    Method.define map, Function, isDefined,
      (f, x) -> map f, (iteratorFunction x)

    Method.define map, Function, isIteratorFunction, (f, i) ->
      iterator ->
        {done, value} = i()
        if done then {done} else {done, value: (f value)}

    Method.define map, Function, isAsyncIteratorFunction, (f, i) ->
      asyncIterator ->
        i().then ({done, value}) ->
          if done then {done} else {done, value: (f value)}

    map = curry binary map

## select/filter

Given a function and an iterator, return an iterator that produces values from the given iterator for which the function returns true.

    select = Method.create()

    Method.define select, Function, isDefined,
      (f, x) -> select f, (iteratorFunction x)

    Method.define select, Function, isIteratorFunction,
      (f, i) ->
        iterator ->
          loop
            {done, value} = i()
            break if done || (f value)
          {done, value}

    Method.define select, Function, isAsyncIteratorFunction,
      (f, i) ->
        p = (({done, value}) -> done || (f value))

        asyncIterator -> W.iterate i, p, (->), i()

    select = filter = curry binary select

## reject

Given a function and an iterator, return an iterator that produces values from the given iterator for which the function returns false.

    reject = curry (f, i) -> select (negate f), i

## project

    project = curry (p, i) -> map (property p), i

## compact

    compact = select isDefined

## partition

    partition = Method.create()

    Method.define partition, Number, isDefined, (n, x) ->
      partition n, (iteratorFunction x)

    Method.define partition, Number, isIteratorFunction, (n, i) ->
      iterator ->
        batch = []
        loop
          {done, value} = i()
          break if done
          batch.push value
          break if batch.length == n
        if done then {done} else {value: batch, done}

    Method.define partition, Number, isAsyncIteratorFunction, (n, i) ->
      asyncIterator async ->
        batch = []
        loop
          {done, value} = yield i()
          break if done
          batch.push value
          break if batch.length == n
        if done then {done} else {value: batch, done}

## take

Given a function and an iterator, return an iterator that produces values from the given iterator until the given function returns false when applied to the given iterator's values.

    take = Method.create()

    Method.define take, Function, isDefined,
      (f, x) -> take f, (iteratorFunction x)

    Method.define take, Function, isIteratorFunction,
      (f, i) ->
        iterator ->
          if !done
            {done, value} = i()
            if !done && (f value)
              {value, done: false}
            else
              {done: true}

    take = curry binary take

## takeN

Given an iterator, produces the first N values from the given iterator.

    takeN = do ->
      f = (n, i = 0) -> -> i++ < n
      (n, i) -> take (f n), i

## where

Performs a `select` using a given object object. See `query`.

    where = curry (example, i) -> select (query example), i

## events

    events = Method.create()
    isSource = compose isFunction, property "on"

    Method.define events, String, isSource, (name, source) ->
      events {name, end: "end", error: "error"}, source

We use `do` here to avoid redefining `reject`.

    Method.define events, Object, isSource, do (reject) ->

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

## split

Given a function and an iterator, produce a new iterator whose values are delimited based on the given function.

    split = Method.create()

    Method.define split, Function, isDefined,
      (f, x) -> split f, (iteratorFunction x)

    Method.define split, Function, isIteratorFunction, (f, i) ->
      lines = []
      remainder = ""
      iterator ->
        if lines.length > 0
          value: lines.shift(), done: false
        else
          {value, done} = i()
          if !done
            [first, lines..., last] = f value
            first = remainder + first
            remainder = last
            {value: first, done}
          else if remainder != ""
            value = remainder
            remainder = ""
            {value, done: false}
          else
            {done}

    Method.define split, Function, isAsyncIteratorFunction, (f, i) ->
      lines = []
      remainder = ""
      asyncIterator async ->
        if lines.length > 0
          value: lines.shift(), done: false
        else
          {value, done} = yield i()
          if !done
            [first, lines..., last] = f value
            first = remainder + first
            remainder = last
            {value: first, done}
          else if remainder != ""
            value = remainder
            remainder = ""
            {value, done: false}
          else
            {done}

    split = curry binary split

## lines

    lines = split (s) -> s.toString().split("\n")


## flow

      {curry} = require "fairmont-core"
      {async} = require "fairmont-helpers"
      {iterator, asyncIterator} = require "./iterator"
      {reduce} = require "./reducer"

      flow = ([i, fx...]) -> reduce i, ((i,f) -> f i), fx

## start

      # TODO: need to add synchronous version

      start = async (i) ->
        loop
          {done, value} = yield i()
          break if done

## split

Given a function and an iterator, produce a new iterator whose values are delimited based on the given function.

    split = Method.create()

    Method.define split, Function, isDefined,
      (f, x) -> split f, (iteratorFunction x)

    Method.define split, Function, isIteratorFunction, (f, i) ->
      lines = []
      remainder = ""
      iterator ->
        if lines.length > 0
          value: lines.shift(), done: false
        else
          {value, done} = i()
          if !done
            [first, lines..., last] = f value
            first = remainder + first
            remainder = last
            {value: first, done}
          else if remainder != ""
            value = remainder
            remainder = ""
            {value, done: false}
          else
            {done}

    Method.define split, Function, isAsyncIteratorFunction, (f, i) ->
      lines = []
      remainder = ""
      asyncIterator async ->
        if lines.length > 0
          value: lines.shift(), done: false
        else
          {value, done} = yield i()
          if !done
            [first, lines..., last] = f value
            first = remainder + first
            remainder = last
            {value: first, done}
          else if remainder != ""
            value = remainder
            remainder = ""
            {value, done: false}
          else
            {done}

    split = curry binary split

## lines

    lines = split (s) -> s.toString().split("\n")


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
