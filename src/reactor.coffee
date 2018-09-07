import {identity, curry, binary, negate} from "fairmont-core"
import {Method} from "fairmont-multimethods"
import {follow, isFunction, isAsyncFunction, isType} from "fairmont-helpers"

console.log isAsyncFunction

# TODO: move stubs into helpers
isAsyncGeneratorFunction = -> false
isFunctionLike = (x) -> x?.apply?

isReagent = isAsyncIterable = (x) ->
  (x? && (isFunction x[Symbol.asyncIterator]) ||
    (isAsyncGeneratorFunction x))

isReactor = isAsyncIterator = (x) ->
  (isFunctionLike x?.next) && (x?[@@asyncIterator])
  (x?.next? && (isReagent x))

reactor = asyncIterator = Method.create
  default: "unable to create reactor from value"

Method.define reactor, isFunctionLike, (f) ->
  next: f
  [Symbol.asyncIterator]: -> @

Method.define reactor, ((x) -> isFunctionLike x[Symbol.asyncIterator]),
  (i) -> i[Symbol.asyncIterator]()

Method.define reactor, isAsyncGeneratorFunction, (g) -> g()

module.exports = {isReagent, reactor, isReactor}
