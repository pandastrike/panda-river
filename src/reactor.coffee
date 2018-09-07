import {identity, curry, binary, negate} from "panda-garden"
import {Method} from "panda-generics"
import {follow, isFunction, isAsyncFunction, isType} from "panda-parchment"

console.log isAsyncFunction

# TODO: move stubs into helpers
isAsyncGeneratorFunction = -> false
isFunctionLike = (x) -> x?.apply?

isReagent = isAsyncIterable = (x) ->
  (x? && (isFunction x[Symbol.asyncIterator]) ||
    (isAsyncGeneratorFunction x))

isReactor = isAsyncIterator = (x) ->
  (isFunctionLike x?.next) && (x?[Symbol.asyncIterator])
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
