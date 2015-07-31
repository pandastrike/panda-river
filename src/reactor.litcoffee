# Reactors

    W = require "when"

    {identity, curry, compose, binary,
      negate} = require "fairmont-core"

    # TODO: add this to core?
    either = curry (f, g) -> -> (f arguments...) || (g arguments...)

    {Method} = require "fairmont-multimethods"
    {property, query, has, isFunction, isGenerator, isDefined,
      isPromise, async} = require "fairmont-helpers"

## isReagent, isAsyncIterable

    isReagent = isAsyncIterable = (x) -> x?[Symbol.asyncIterator]?

## isReactor, isAsyncIterator

    isReactor = isAsyncIterator = (x) -> x?.next? && isAsyncIterable x

## reactor, asyncIterator

The `reactor` function is analogous to the `iterator` function—it's job is to ensure that the object given as an argument is a proper asynchronous iterator.

    reactor = asyncIterator = Method.create()

    Method.define reactor, isFunction, (f) ->
      f.next = f
      f[Symbol.asyncIterator] = -> @this
      f

    Method.define reactor, isAsyncIterable, (i) -> i[Symbol.asyncIterator]()

For the moment, generator functions in Node aren't iterables for some reason. So we'll add this case here for the moment.

    Method.define reactor, isGenerator, (g) -> g()

## isReactorFunction, isAsyncIteratorFunction

This is the async variant of `isIteratorFunction`.

    isReactorFunction = isAsyncIteratorFunction = (f) ->
      (isFunction f) && (isAsyncIterator f)

## reactorFunction, asyncIteratorFunction

    reactorFunction = asyncIteratorFunction = Method.create()

    Method.define reactorFunction, isReagent,
      (x) -> reactorFunction reactor x

    Method.define reactorFunction, isReactor,
      (r) -> reactor (-> i.next())

    Method.define reactorFunction, isFunction, (f) -> reactor f

    Method.define reactorFunction, isReactorFunction, identity

---

    module.exports = {isReagent, isAsyncIterable,
      reactor, asyncIterator, isReactor, isAsyncIterator,
      reactorFunction, asyncIteratorFunction,
      isReactorFunction, isAsyncIteratorFunction}
