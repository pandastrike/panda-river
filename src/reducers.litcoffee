# Reducer Functions

Some functions _reduce_ an iterator into another value. Once a reduce function is introduced, the associated iterator functions will run.

    {isIterable, iterator, isIterator, isIterator, next} = require "./iterator"

    {isReagent, reactor, isReactor, isReactor} = require "./reactor"

    {producer} = require "./adapters"

    {curry, binary, ternary, noOp, negate} = require "fairmont-core"

    {isFunction, isDefined, isArray, async,
      first, push, second, add} = require "fairmont-helpers"

    {Method} = require "fairmont-multimethods"

    next = (i) -> i.next()


## fold/reduce

Given an initial value, a function, and an iterator, reduce the iterator to a single value, ex: sum a list of integers.

    fold = Method.create()

    Method.define fold, Function, (-> true), isDefined,
      (f, x, y) -> fold x, f, (producer y)

    Method.define fold, Function, (-> true), isIterator,
      (f, x, i) ->
        loop
          {done, value} = next i
          break if done
          x = f x, value
        x

    Method.define fold, Function, (-> true), isReactor,
      async (f, x, i) ->
        loop
          {done, value} = yield next i
          break if done
          x = f x, value
        x

    Method.define fold, Function, (-> true), isArray,
      (f, x, ax) -> ax.reduce f, x

    reduce = fold = curry ternary fold

## foldr/reduceRight

Given function and an initial value, reduce an iterator to a single value, ex: sum a list of integers, starting from the right, or last, value.

    foldr = Method.create()

    Method.define foldr, Function, (-> true), isDefined,
      (f, x, y) -> foldr f, x, (producer y)

    Method.define foldr, Function, (-> true), isIterator,
      (f, x, i) -> (collect i).reduceRight f, x

    Method.define foldr, Function, (-> true), isReactor,
      (f, x, i) -> (collect i).then (ax) -> ax.reduceRight f, x

    Method.define foldr, Function, (-> true), isArray,
      (f, x, ax) -> ax.reduceRight f, x

    reduceRight = foldr = curry ternary foldr

## collect

Collect an iterator's values into an array.

    collect = (i) -> reduce push, [], i

## each

Apply a function to each element but discard the results. This is a reducer because there isn't any point in having an iterator that simply discards the value from another iterator. Basically, use `each` when you want to reduce an iterator without taking up any additional memory.

    each = curry (f, i) ->
      g = (_, x) -> (f x); _
      reduce g, undefined, i

## start

Works like `each` but doesn't apply a function to each element. This is useful with producers that encapsulate operations, like request processing in a server or handling browser events.

    start = reduce noOp, undefined

## any

Given a function and an iterator, return true if the given function returns true for any value produced by the iterator.

    any = Method.create()

    Method.define any, Function, isDefined, (f, x) ->
      any f, (producer x)

    Method.define any, Function, isIterator,
      (f, i) ->
        loop
          ({done, value} = next i)
          break if (done || (f value))
        !done

    Method.define any, Function, isReactor,
      async (f, i) ->
        loop
          ({done, value} = yield next i)
          break if (done || (f value))
        !done

    any = curry binary any

## all

Given a function and an iterator, return true if the function returns true for all the values produced by the iterator.

    all = Method.create()

    Method.define all, Function, isDefined, (f, x) -> all f, (producer x)

    Method.define all, Function, isIterator,
      (f, i) -> !any (negate f), i

    Method.define all, Function, isReactor,
      async (f, i) -> !(yield any (negate f), i)

    all = curry binary all

## zip

Given a function and two iterators, return an iterator that produces values by applying a function to the values produced by the given iterators.

    zip = Method.create()

    Method.define zip, Function, isDefined, isDefined,
      (f, x, y) -> zip f, (producer x), (producer y)

    Method.define zip, Function, isIterator, isIterator,
      (f, i, j) ->
        iterator ->
          x = next i
          y = next j
          if !x.done && !y.done
            value: (f x.value, y.value), done: false
          else
            done: true

## unzip

    unzip = (f, i) -> fold f, [[],[]], i

## assoc

Given an iterator that produces associative pairs, return an object whose keys are the first element of the pair and whose values are the second element of the pair.

    _assoc = (object, [key, value]) ->
      object[key] = value
      object

    assoc = reduce _assoc, {}

## flatten

    _flatten = (ax, a) ->
      if isIterable a
        ax.concat flatten a
      else
        ax.push a
        ax

    flatten = fold _flatten, []

## sum

Sum the numbers produced by a given iterator.

    sum = fold add, 0

## average

Average the numbers producced by a given iterator.

    average = (i) ->
      j = 0 # current count
      f = (r, n) -> r += ((n - r)/++j)
      fold f, 0, i

## join

Concatenate the strings produced by a given iterator. Unlike `Array::join`, this function does not delimit the strings. See also: `delimit`.

This is here instead of in [String Functions](./string.litcoffee) to avoid forward declaring `fold`.

    join = fold add, ""

## delimit

Like `join`, except that it takes a delimeter, separating each string with the delimiter. Similar to `Array::join`, except there's no default delimiter. The function is curried, though, so calling `delimit ' '` is analogous to `Array::join` with no delimiter argument.

    delimit = curry (d, i) ->
      f = (r, s) -> if r == "" then r += s else r += d + s
      fold f, "", i

---

    module.exports = {reduce, fold, reduce, foldr, reduceRight,
      collect, each, start, any, all, zip, unzip, assoc, flatten,
      sum, average, join, delimit}
