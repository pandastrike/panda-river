import {identity, curry, binary, negate} from "fairmont-core"
import {Method} from "fairmont-multimethods"
import {follow, isGeneratorFunction, isType} from "fairmont-helpers"

# can async generators be normal generators that return async iterators?
# can async iterators be normal iterators that return promises?
# we take a conservative approach and assume the answer is yes to both
#
# thus:
# - isGeneratorFunctionLike instead of isAsyncGeneratorFunction
# - isFunctionLike instead of isAsyncFunction
#
# also until we know what kind of constructor an async generator returns
# we're sort of just faking it here ...

# TODO: add to helpers?
# isAsyncGeneratorFunction = isType (-> await yield null ).constructor
# isFunctionLike = isKind Function
isFunctionLike = (x) -> x.call?

# isGeneratorFunctionLike = (f) ->
#   (isGeneratorFunction f) || (isAsyncGeneratorFunction f)
isGeneratorFunctionLike = isGeneratorFunction

isReagent = isAsyncIterable = (x) ->
  (x? && isFunctionLike x[Symbol.asyncIterator] ||
    (isGeneratorFunctionLike x))


isReactor = isAsyncIterator = (x) ->
  (x? && (isFunctionLike x.next) && (isReagent x))

reactor = asyncIterator = Method.create()

Method.define reactor, isFunctionLike, (f) ->
  g = -> follow f arguments...
  g.next = g
  g[Symbol.asyncIterator] = -> g
  g

Method.define reactor, isReagent, (i) -> i[Symbol.asyncIterator]()

Method.define reactor, isGeneratorFunctionLike, (g) -> g()

module.exports = {isReagent, reactor, isReactor}
