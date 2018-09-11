import {identity, curry} from "panda-garden"
import {Method} from "panda-generics"
import {isKind, isFunction, isGeneratorFunction} from "panda-parchment"

isIterable = (x) -> isFunction x?[Symbol.iterator]

isIterator = (x) -> (isFunction x?.next) && (isIterable x)

iterator = Method.create
  default: "unable to create iterator from value"

Method.define iterator, isFunction, (f) ->
  next: f
  [Symbol.iterator]: -> @

Method.define iterator, isIterable, (i) -> i[Symbol.iterator]()

Method.define iterator, isGeneratorFunction, (g) -> g()

Method.define iterator, isIterator, (i) -> i

next = (i) -> i.next()
value = ({value}) -> value
isDone = ({done}) -> done

module.exports = {isIterable, iterator, isIterator, next, value, isDone}
