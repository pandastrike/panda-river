{isIterable, iterator, isIterator, isIterator, next} = require "./iterator"

{isReagent, reactor, isReactor, isReactor} = require "./reactor"

{producer} = require "./adapters"

{curry, binary, ternary, noOp, negate} = require "fairmont-core"

{isFunction, isDefined, isArray, async,
  first, push, second, add} = require "fairmont-helpers"

{Method} = require "fairmont-multimethods"

next = (i) -> i.next()

fold = Method.create()

Method.define fold, isFunction, ((x) -> true), isDefined,
  (f, x, y) -> fold x, f, (producer y)

Method.define fold, isFunction, ((x) -> true), isIterator,
  (f, x, i) ->
    loop
      {done, value} = next i
      break if done
      x = f x, value
    x

Method.define fold, isFunction, ((x) -> true), isReactor,
  async (f, x, i) ->
    loop
      {done, value} = yield next i
      break if done
      x = f x, value
    x

Method.define fold, isFunction, ((x) -> true), isArray,
  (f, x, ax) -> ax.reduce f, x

reduce = fold = curry ternary fold

foldr = Method.create()

Method.define foldr, isFunction, ((x) -> true), isDefined,
  (f, x, y) -> foldr f, x, (producer y)

Method.define foldr, isFunction, ((x) -> true), isIterator,
  (f, x, i) -> (collect i).reduceRight f, x

Method.define foldr, isFunction, ((x) -> true), isReactor,
  (f, x, i) -> (collect i).then (ax) -> ax.reduceRight f, x

Method.define foldr, isFunction, ((x) -> true), isArray,
  (f, x, ax) -> ax.reduceRight f, x

reduceRight = foldr = curry ternary foldr

collect = (i) -> reduce push, [], i

each = curry (f, i) ->
  g = (_, x) -> (f x); _
  reduce g, undefined, i

start = reduce noOp, undefined

any = Method.create()

Method.define any, isFunction, isDefined, (f, x) ->
  any f, (producer x)

Method.define any, isFunction, isIterator,
  (f, i) ->
    loop
      ({done, value} = next i)
      break if (done || (f value))
    !done

Method.define any, isFunction, isReactor,
  async (f, i) ->
    loop
      ({done, value} = yield next i)
      break if (done || (f value))
    !done

any = curry binary any

all = Method.create()

Method.define all, isFunction, isDefined, (f, x) -> all f, (producer x)

Method.define all, isFunction, isIterator,
  (f, i) -> !any (negate f), i

Method.define all, isFunction, isReactor,
  async (f, i) -> !(yield any (negate f), i)

all = curry binary all

# TODO: find and findLast, with array specializations

zip = Method.create()

Method.define zip, isFunction, isDefined, isDefined,
  (f, x, y) -> zip f, (producer x), (producer y)

Method.define zip, isFunction, isIterator, isIterator,
  (f, i, j) ->
    iterator ->
      x = next i
      y = next j
      if !x.done && !y.done
        value: (f x.value, y.value), done: false
      else
        done: true

# The semantics of unzip are sort of poorly defined, especially given that
# zip actually takes a function. But for unzip to take a function seems
# pointless, and to call it unzip if the inverse is actually `zip pair`
# seems like a misnomer. Also, I have no idea if this function is actually
# useful--it was only added for symmetry.

# unzip = (i) -> fold f, [[],[]], i

_assoc = (object, [key, value]) ->
  object[key] = value
  object

assoc = (ax) -> reduce _assoc, {}, ax

# TODO: Should flatten be a producer?

_flatten = (ax, a) ->
  if isIterable a
    ax.concat flatten a
  else
    ax.push a
    ax

flatten = (ax) -> fold _flatten, [], ax

sum = (ax) -> fold add, 0, ax

average = (i) ->
  j = 0 # current count
  f = (r, n) -> r += ((n - r)/++j)
  fold f, 0, i

delimit = curry (d, i) ->
  f = (r, s) -> if r == "" then r += s else r += d + s
  fold f, "", i

module.exports = {reduce, fold, reduce, foldr, reduceRight,
  collect, each, start, any, all, zip, assoc, flatten,
  sum, average, delimit}
