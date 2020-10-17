import {identity, curry, binary, negate} from "@pandastrike/garden"
import Method from "panda-generics"
import {isFunction, isType} from "panda-parchment"

{create, define} = Method

Symbol.asyncIterator ?= Symbol "asyncIterator"

isAsyncGeneratorFunction = do ->
  f = -> yield await null
  isType f.constructor

isReagent = isAsyncIterable = (x) ->
  (isFunction x?[Symbol.asyncIterator]) || (isAsyncGeneratorFunction x)

isReactor = isAsyncIterator = (x) -> (isFunction x?.next) && (isReagent x)

reactor = asyncIterator = create
  name: "reactor"
  description: "produces a reactor from an input"
  default: "unable to create reactor from value"

define reactor, isFunction, (f) ->
  next: f
  [Symbol.asyncIterator]: -> @

define reactor, isReagent, (r) -> r[Symbol.asyncIterator]()

define reactor, isAsyncGeneratorFunction, (g) -> g()

define reactor, isReactor, (r) -> r

export {isReagent, reactor, isReactor}
