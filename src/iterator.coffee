import {identity, curry} from "@pandastrike/garden"
import Method from "panda-generics"
import {isKind, isFunction, isGeneratorFunction} from "panda-parchment"

{create, define} = Method

isIterable = (x) ->
  (isFunction x?[Symbol.iterator]) || (isGeneratorFunction x)

isIterator = (x) -> (isFunction x?.next) && (isIterable x)

iterator = create
  name: "iterator"
  description: "produces an iterator from an input"
  default: "unable to create iterator from value"

define iterator, isFunction, (f) ->
  next: f
  [Symbol.iterator]: -> @

define iterator, isIterable, (i) -> i[Symbol.iterator]()

define iterator, isGeneratorFunction, (g) -> g()

define iterator, isIterator, (i) -> i

next = (i) -> i.next()
value = ({value}) -> value
isDone = ({done}) -> done

export {isIterable, iterator, isIterator, next, value, isDone}
