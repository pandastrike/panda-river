# Iterators

    {identity, curry} = require "fairmont-core"

    # TODO: add this to core?
    either = curry (f, g) -> -> (f arguments...) || (g arguments...)

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

If we don't have an iterable, we might have a function. In that case, we assume we're dealing with an iterator function that simply hasn't been properly tagged. (Or, put another way, that we're calling `iterator` specifically to tag it.)

    Method.define iterator, isFunction, (f) ->
      f.next = f
      f[Symbol.iterator] = -> @this
      f

The simplest case is to just call the iterator method on the value. We can do this when we have something iterable. We have sync and async variants. These are defined last to avoid infinite recursion.

    Method.define iterator, isIterable, (i) -> i[Symbol.iterator]()

For the moment, generator functions in Node aren't iterables for some reason. So we'll add this case here for the moment.

    Method.define iterator, isGenerator, (g) -> g()

(If what you want is an async iterator from a generator function, use `async` to adapt it into a function that returns promises first and then call `asyncIterator`.)

## isIteratorFunction

We want to be able to detect whether we have an iterator function. Iterators that are also functions are iterator functions.

    isIteratorFunction = (f) -> (isFunction f) && (isIterator f)

## iteratorFunction

`iteratorFunction` takes a value and tries to return an `IteratorFunction` based upon it. We're using predicates here throughout because they have a higher precedence than `constructor` matches.

It might seem rather strange that there's no corresponding `asyncIteratorFunction`. This is because `iteratorFunction` already handles both cases. If you have an async iteratable or iterator, `iteratorFunction` will still return you something that satisfies `isAsyncIteratorFunction`.

If you want to _construct_ an async iterator function, use `asyncIterator` with a function that returns a promise.

    iteratorFunction = Method.create()

If we get an iterable, we want an iterator for it, and then to turn that into an iterator function.

    Method.define iteratorFunction, isIterable,
      (x) -> iteratorFunction iterator x

If we get an iterator as a value, we simply need to wrap it in a function that calls it's `next` method, and then call `iterator` on that. We define this after the method taking iterables, since iterators are iterables, and we want this function to have precedence.

    Method.define iteratorFunction, isIterator,
      (i) -> iterator (-> i.next())

If given a function that isn't already an iterator (or an iterator function), we can convert that into an iterator function by simply calling `iterator` on the value, since it's already a function.

    Method.define iteratorFunction, isFunction, (f) -> iterator f

Now we can define the trivial case, where we already have an iterator function and just need to return it. This comes last so that it has the highest precedence, since iterator functions are both iterators and functions (and would thus match each of the previous rules and cause an infinite recursion).

    Method.define iteratorFunction, isIteratorFunction, identity

---

    module.exports = {isIterable, iterator, isIterator,
      isIteratorFunction, iteratorFunction}
