import {identity, curry, binary, negate} from "panda-garden"
import {Method} from "panda-generics"
import {isFunction, isType} from "panda-parchment"

Symbol.asyncIterator ?= Symbol "asyncIterator"

isAsyncGeneratorFunction = do ->
  f = -> yield await null
  isType f.constructor

isReagent = isAsyncIterable = (x) ->
  (isFunction x?[Symbol.asyncIterator]) || (isAsyncGeneratorFunction x)

isReactor = isAsyncIterator = (x) -> (isFunction x?.next) && (isReagent x)

reactor = asyncIterator = Method.create
  default: "unable to create reactor from value"

Method.define reactor, isFunction, (f) ->
  next: f
  [Symbol.asyncIterator]: -> @

Method.define reactor, isReagent, (r) -> r[Symbol.asyncIterator]()

Method.define reactor, isAsyncGeneratorFunction, (g) -> g()

Method.define reactor, isReactor, (r) -> r

module.exports = {isReagent, reactor, isReactor}
