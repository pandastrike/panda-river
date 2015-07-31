# Filters

Filters transform an iterator or reactor into another iterator/reactor.

    _when = require "when"
    {curry, binary, negate} = require "fairmont-core"
    {isFunction, isDefined, property, query, async} = require "fairmont-helpers"
    {Method} = require "fairmont-multimethods"
    {iterator, iteratorFunction, isIteratorFunction} = require "./iterator"
    {reactor, reactorFunction, isReactorFunction} = require "./reactor"
    {producer} = require "./adapters"

## map

Return a new iterator that will apply the given function to each value produced by the iterator.

    map = Method.create()

    Method.define map, Function, isDefined,
      (f, x) -> map f, (producer x)

    Method.define map, Function, isIteratorFunction, (f, i) ->
      iterator ->
        {done, value} = i()
        if done then {done} else {done, value: (f value)}

    Method.define map, Function, isReactorFunction, (f, i) ->
      reactor ->
        i().then ({done, value}) ->
          if done then {done} else {done, value: (f value)}

    map = curry binary map

## select/filter

Given a function and an iterator, return an iterator that produces values from the given iterator for which the function returns true.

    select = Method.create()

    Method.define select, Function, isDefined,
      (f, x) -> select f, (producer x)

    Method.define select, Function, isIteratorFunction,
      (f, i) ->
        iterator ->
          loop
            {done, value} = i()
            break if done || (f value)
          {done, value}

    Method.define select, Function, isReactorFunction,
      (f, i) ->
        p = (({done, value}) -> done || (f value))

        reactor -> _when.iterate i, p, (->), i()

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
      partition n, (producer x)

    Method.define partition, Number, isIteratorFunction, (n, i) ->
      iterator ->
        batch = []
        loop
          {done, value} = i()
          break if done
          batch.push value
          break if batch.length == n
        if done then {done} else {value: batch, done}

    Method.define partition, Number, isReactorFunction, (n, i) ->
      reactor async ->
        batch = []
        loop
          {done, value} = yield i()
          break if done
          batch.push value
          break if batch.length == n
        if done then {done} else {value: batch, done}

## take

Given a function and an iterator, return an iterator that produces values from the given iterator until the given function returns false when applied to the given iterator's values.

    # TODO: add asynchronous version

    take = Method.create()

    Method.define take, Function, isDefined,
      (f, x) -> take f, (producer x)

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

## split

Given a function and an iterator, produce a new iterator whose values are delimited based on the given function.

    split = Method.create()

    Method.define split, Function, isDefined,
      (f, x) -> split f, (producer x)

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

    Method.define split, Function, isReactorFunction, (f, i) ->
      lines = []
      remainder = ""
      reactor async ->
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
      reactor ->
        i().then ({done, value}) ->
          (f value) unless done
          {done, value}

## throttle

    # TODO: need to add synchronous version

    throttle = curry (ms, i) ->
      last = 0
      reactor async ->
        loop
          {done, value} = yield i()
          break if done
          now = Date.now()
          break if now - last >= ms
        last = now
        {done, value}

## pump

Write the values produced by the iterator to a stream.

    pump = Method.create()

    isStreamLike = (s) ->
      s? && (isFunction s.write) && (isFunction s.end)

    Method.define pump, isStreamLike, isDefined,
      (s, x) -> pump s, (producer x)

    Method.define pump, isStreamLike, isIteratorFunction,
      (s, i) ->
        iterator ->
          {done, value} = i()
          if done then s.end() else s.write value
          {done, value: s}

    Method.define pump, isStreamLike, isReactorFunction,
      reactor (s, i) ->
        p = i()
        p.then ({done, value}) ->
          if done then s.end() else s.write value
          {done, value: s}

    pump = curry binary pump

---

    module.exports = {map, select, filter, reject, project, compact,
      partition, take, takeN, where, split, lines, tee, throttle, pump}
