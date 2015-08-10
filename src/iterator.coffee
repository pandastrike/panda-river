{identity, curry} = require "fairmont-core"

{Method} = require "fairmont-multimethods"

{isFunction, isGenerator, isDefined,
  isPromise, async} = require "fairmont-helpers"

isIterable = (x) -> (x?[Symbol.iterator]?) || (x? && isGenerator x)

isIterator = (x) -> x?.next? && isIterable x

iterator = Method.create()

Method.define iterator, isFunction, (f) ->
  f.next = f
  f[Symbol.iterator] = -> @this
  f

Method.define iterator, isIterable, (i) -> i[Symbol.iterator]()

Method.define iterator, isGenerator, (g) -> g()

next = (i) -> i.next()

module.exports = {isIterable, iterator, isIterator, next}
