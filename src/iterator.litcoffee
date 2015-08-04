# Iterators

    {identity, curry} = require "fairmont-core"

    {Method} = require "fairmont-multimethods"

    {isFunction, isGenerator, isDefined,
      isPromise, async} = require "fairmont-helpers"

## isIterable

We want a simple predicate to tell us if something is an iterator. This is simple enough: it should have a `Symbol.iterator` property. However, generators in Node don't look like iterables (yet?). So we add that case.

    isIterable = (x) -> (x?[Symbol.iterator]?) || (x? && isGenerator x)

## isIterator

    isIterator = (x) -> x?.next? && isIterable x

## iterator

The `iterator` function takes a given value and attempts to return an iterator based upon it. We're using predicates here throughout because they have a higher precedence than `constructor` matches.

    iterator = Method.create()

If we don't have an iterable, we might have a function. In that case, we assume we're dealing with an iterator function (a function that keeps returning the `next` value), so we turn it into a proper iterator. This allows us to easily define iterators from simple functions.

    Method.define iterator, isFunction, (f) ->
      f.next = f
      f[Symbol.iterator] = -> @this
      f

The simplest case is to just call the iterator method on the value. We can do this when we have something iterable. We have sync and async variants. These are defined last to avoid infinite recursion.

    Method.define iterator, isIterable, (i) -> i[Symbol.iterator]()

For the moment, generator functions in Node aren't iterables for some reason. So we'll add this case here for the moment.

    Method.define iterator, isGenerator, (g) -> g()

(If what you want is an async iterator from a generator function (that is, a co-routine) use `async` to adapt it into a function that returns promises first and then call `reactor` on it.)

    next = (i) -> i.next()

---

    module.exports = {isIterable, iterator, isIterator, next}
