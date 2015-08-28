{identity, curry} = require "fairmont-core"

{Method} = require "fairmont-multimethods"

{isFunction, isGenerator, isDefined,
  isPromise, async} = require "fairmont-helpers"

isIterable = (x) -> (x? && (isFunction x[Symbol.iterator]) || (isGenerator x))

isIterator = (x) -> (x? && (isFunction x.next) && (isIterable x))

iterator = Method.create()

Method.define iterator, isFunction, (f) ->
  f.next = f
  f[Symbol.iterator] = -> f
  f

Method.define iterator, isIterable, (i) -> i[Symbol.iterator]()

Method.define iterator, isGenerator, (g) -> g()

next = (i) -> i.next()
value = (x) -> x.value
isDone = (x) -> x.done

module.exports = {isIterable, iterator, isIterator, next, value, isDone}
