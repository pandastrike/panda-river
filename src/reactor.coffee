W = require "when"

{identity, curry, binary,
  negate} = require "fairmont-core"

# TODO: add this to core?
either = curry (f, g) -> -> (f arguments...) || (g arguments...)

{Method} = require "fairmont-multimethods"
{property, query, has, isFunction, isGenerator, isDefined,
  isPromise, async} = require "fairmont-helpers"

isReagent = isAsyncIterable = (x) -> x?[Symbol.asyncIterator]?

isReactor = isAsyncIterator = (x) -> x?.next? && isAsyncIterable x

reactor = asyncIterator = Method.create()

Method.define reactor, isFunction, (f) ->
  f.next = f
  f[Symbol.asyncIterator] = -> @this
  f

Method.define reactor, isAsyncIterable, (i) -> i[Symbol.asyncIterator]()

Method.define reactor, isGenerator, (g) -> g()

module.exports = {isReagent, isAsyncIterable,
  reactor, asyncIterator, isReactor, isAsyncIterator}
