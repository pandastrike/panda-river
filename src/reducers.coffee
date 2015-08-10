{isIterable, iterator, isIterator, isIterator, next} = require "./iterator"

{isReagent, reactor, isReactor, isReactor} = require "./reactor"

{producer} = require "./adapters"

{curry, binary, ternary, noOp, negate} = require "fairmont-core"

{isFunction, isDefined, isArray, async,
  first, push, second, add} = require "fairmont-helpers"

{Method} = require "fairmont-multimethods"

next = (i) -> i.next()

fold = Method.create()

Method.define fold, Function, (-> true), isDefined,
  (f, x, y) -> fold x, f, (producer y)

Method.define fold, Function, (-> true), isIterator,
  (f, x, i) ->
    loop
      {done, value} = next i
      break if done
      x = f x, value
    x

Method.define fold, Function, (-> true), isReactor,
  async (f, x, i) ->
    loop
      {done, value} = yield next i
      break if done
      x = f x, value
    x

Method.define fold, Function, (-> true), isArray,
  (f, x, ax) -> ax.reduce f, x

reduce = fold = curry ternary fold

foldr = Method.create()

Method.define foldr, Function, (-> true), isDefined,
  (f, x, y) -> foldr f, x, (producer y)

Method.define foldr, Function, (-> true), isIterator,
  (f, x, i) -> (collect i).reduceRight f, x

Method.define foldr, Function, (-> true), isReactor,
  (f, x, i) -> (collect i).then (ax) -> ax.reduceRight f, x

Method.define foldr, Function, (-> true), isArray,
  (f, x, ax) -> ax.reduceRight f, x

reduceRight = foldr = curry ternary foldr

collect = (i) -> reduce push, [], i

each = curry (f, i) ->
  g = (_, x) -> (f x); _
  reduce g, undefined, i

start = reduce noOp, undefined

any = Method.create()

Method.define any, Function, isDefined, (f, x) ->
  any f, (producer x)

Method.define any, Function, isIterator,
  (f, i) ->
    loop
      ({done, value} = next i)
      break if (done || (f value))
    !done

Method.define any, Function, isReactor,
  async (f, i) ->
    loop
      ({done, value} = yield next i)
      break if (done || (f value))
    !done

any = curry binary any

all = Method.create()

Method.define all, Function, isDefined, (f, x) -> all f, (producer x)

Method.define all, Function, isIterator,
  (f, i) -> !any (negate f), i

Method.define all, Function, isReactor,
  async (f, i) -> !(yield any (negate f), i)

all = curry binary all

zip = Method.create()

Method.define zip, Function, isDefined, isDefined,
  (f, x, y) -> zip f, (producer x), (producer y)

Method.define zip, Function, isIterator, isIterator,
  (f, i, j) ->
    iterator ->
      x = next i
      y = next j
      if !x.done && !y.done
        value: (f x.value, y.value), done: false
      else
        done: true

unzip = (f, i) -> fold f, [[],[]], i

_assoc = (object, [key, value]) ->
  object[key] = value
  object

assoc = reduce _assoc, {}

_flatten = (ax, a) ->
  if isIterable a
    ax.concat flatten a
  else
    ax.push a
    ax

flatten = fold _flatten, []

sum = fold add, 0

average = (i) ->
  j = 0 # current count
  f = (r, n) -> r += ((n - r)/++j)
  fold f, 0, i

join = fold add, ""

delimit = curry (d, i) ->
  f = (r, s) -> if r == "" then r += s else r += d + s
  fold f, "", i

module.exports = {reduce, fold, reduce, foldr, reduceRight,
  collect, each, start, any, all, zip, unzip, assoc, flatten,
  sum, average, join, delimit}
