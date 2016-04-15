{resolve} = require "when"

{identity, curry, binary,
  negate} = require "fairmont-core"

# TODO: add this to core?
either = curry (f, g) -> -> (f arguments...) || (g arguments...)

{Method} = require "fairmont-multimethods"
{property, query, has, isFunction, isGeneratorFunction, isDefined,
  isPromise, async} = require "fairmont-helpers"

isReagent = (x) -> (x? && isFunction x[Symbol.asyncIterator])

isReactor = (x) -> (x? && (isFunction x.next) && (isReagent x))

reactor = asyncIterator = Method.create()

Method.define reactor, isFunction, (f) ->
  g = ->
    x = f arguments...
    if isPromise x then x else resolve x
  g.next = g
  g[Symbol.asyncIterator] = -> g
  g

Method.define reactor, isReagent, (i) -> i[Symbol.asyncIterator]()

Method.define reactor, isGeneratorFunction, (g) -> g()

module.exports = {isReagent, reactor, isReactor}
