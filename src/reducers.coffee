import {curry, binary, ternary, noOp, negate} from "panda-garden"
import {isFunction, isDefined, isArray, push, add} from "panda-parchment"
import {Method} from "panda-generics"
import {isIterable, isIterator, iterator} from "./iterator"
import {isReagent, isReactor, reactor} from "./reactor"
import {producer} from "./adapters"

isAny = (x) -> true

define = ({name, description, terms, iterator, reactor}) ->

  f = Method.create
    description: description
    default: -> throw "#{name}: invalid arguments"

  Method.define f, terms..., isDefined, (args..., last) ->
    if args.length == terms.length
      f args..., producer last
    else
      throw "#{name}: wrong number of arguments"

  Method.define f, terms..., isIterator, iterator

  Method.define f, terms..., isReactor, reactor

  f

start = define
  name: "start"
  description: "Obtain products but do nothing with them."
  terms: []
  iterator: (i) -> undefined for x from i ; undefined
  reactor: (r) -> undefined for await x from r ; undefined

# The point here is to avoid using memory.
each = curry binary define
  name: "each"
  description: "Apply a function to each product, returning undefined."
  terms: [isFunction]
  iterator: (f, i) -> f x for x from i ; undefined
  reactor: (f, r) -> f x for await x from r ; undefined

reduce = fold = curry ternary define
  name: "fold/reduce"
  description: "Fold or reduce a producer into a value."
  terms: [isFunction, isAny]
  iterator: (f, k, i) -> (k = f k, x) for x from i ; k
  reactor: (f, k, r) -> (k = f k, x) for await x from r ; k

collect = (p) -> reduce push, [], p

reduceRight = foldr = curry ternary define
  name: "foldr/reduceRight"
  description: "Fold or reduce a producer into a value."
  terms: [isFunction, isAny]
  iterator: (f, k, i) -> (collect i).reduceRight f, k
  reactor: (f, k, r) -> (await collect r).reduceRight f, k

any = curry binary define
  name: "any"
  description: "Return true if any product satisfies the predicate."
  terms: [isFunction]
  iterator: (f, i) ->
    for x from i
      return true if f x
    false
  reactor: (f, r) ->
    for await x from r
      return true if f x
    false

all = curry (f, p) -> !(any (negate f), p)

sum = (ax) -> fold add, 0, ax

average = (i) ->
  j = 0 # current count
  f = (r, n) -> r += ((n - r)/++j)
  fold f, 0, i

delimit = curry (d, i) ->
  f = (r, s) -> if r == "" then r += s else r += d + s
  fold f, "", i

export {reduce, fold, foldr, reduceRight,
  collect, each, start, any, all, sum, average, delimit}
