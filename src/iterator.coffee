import {identity, curry} from "fairmont-core"
import {Method} from "fairmont-multimethods"
import {isFunction, isGeneratorFunction} from "fairmont-helpers"

isIterable = (x) ->
  (x? && (isFunction x[Symbol.iterator]) || (isGeneratorFunction x))

isIterator = (x) -> (x? && (isFunction x.next) && (isIterable x))

iterator = Method.create()

Method.define iterator, isFunction, (f) ->
  g = -> f arguments...
  g.next = g
  g[Symbol.iterator] = -> g
  g

Method.define iterator, isIterable, (i) -> i[Symbol.iterator]()

Method.define iterator, isGeneratorFunction, (g) -> g()

next = (i) -> i.next()
value = ({value}) -> value
isDone = ({done}) -> done

module.exports = {isIterable, iterator, isIterator, next, value, isDone}
