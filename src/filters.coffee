_when = require "when"
{curry, binary, ternary, negate} = require "fairmont-core"
{isFunction, isDefined, property,
  query, async} = require "fairmont-helpers"
{Method} = require "fairmont-multimethods"
{iterator, iteratorFunction, isIterator, next} = require "./iterator"
{reactor, reactorFunction, isReactor} = require "./reactor"
{producer} = require "./adapters"

map = Method.create()

Method.define map, isFunction, isDefined,
  (f, x) -> map f, (producer x)

Method.define map, isFunction, isIterator, (f, i) ->
  iterator ->
    {done, value} = next i
    if done then {done} else {done, value: (f value)}

Method.define map, isFunction, isReactor, (f, r) ->
  reactor ->
    (next r).then ({done, value}) ->
      if done then {done} else {done, value: (f value)}

map = curry binary map

select = Method.create()

Method.define select, isFunction, isDefined,
  (f, x) -> select f, (producer x)

Method.define select, isFunction, isIterator,
  (f, i) ->
    iterator ->
      loop
        {done, value} = next i
        break if done || (f value)
      {done, value}

Method.define select, isFunction, isReactor,
  (f, i) ->
    p = (({done, value}) -> done || (f value))
    j = -> next i
    reactor -> _when.iterate j, p, (->), j()

select = filter = curry binary select

reject = curry (f, i) -> select (negate f), i

accumulate = Method.create()

Method.define accumulate, isFunction, ((x) -> true), isDefined,
  (f, k, x) -> accumulate f, k, (producer x)

Method.define accumulate, isFunction, ((x) -> true), isIterator,
  (f, k, i) ->
    iterator ->
      {done, value} = next i
      if !done
        k = f k, value
        {value: k, done: false}
      else
        {done}

Method.define accumulate, isFunction, ((x) -> true), isReactor,
  (f, k, r) ->
    reactor ->
      (next r).then ({done, value}) ->
        if !done
          k = f k, value
          {value: k, done: false}
        else
          {done}

accumulate = curry ternary accumulate

project = curry (p, i) -> map (property p), i

compact = select isDefined

partition = Method.create()

Method.define partition, Number, isDefined, (n, x) ->
  partition n, (producer x)

Method.define partition, Number, isIterator, (n, i) ->
  iterator ->
    batch = []
    loop
      {done, value} = next i
      break if done
      batch.push value
      break if batch.length == n
    if done && batch.length == 0
      {done}
    else
      {value: batch, done}

Method.define partition, Number, isReactor, (n, i) ->
  reactor async ->
    batch = []
    loop
      {done, value} = yield next i
      break if done
      batch.push value
      break if batch.length == n
    if done && batch.length == 0
      {done}
    else
      {value: batch, done}

partition = curry binary partition

take = Method.create()

Method.define take, isFunction, isDefined,
  (f, x) -> take f, (producer x)

Method.define take, isFunction, isIterator,
  (f, i) ->
    iterator ->
      if !done
        {done, value} = next i
        if !done && (f value)
          {value, done: false}
        else
          {done: true}

take = curry binary take

takeN = do ->
  f = (n, i = 0) -> -> i++ < n
  (n, i) -> take (f n), i

where = curry (example, i) -> select (query example), i

split = Method.create()

Method.define split, isFunction, isDefined,
  (f, x) -> split f, (producer x)

Method.define split, isFunction, isIterator, (f, i) ->
  lines = []
  remainder = ""
  iterator ->
    if lines.length > 0
      {value: lines.shift(), done: false}
    else
      {value, done} = next i
      if !done
        [first, lines..., last] = f value
        first = remainder + first
        remainder = last
        {value: first, done}
      else if remainder != ""
        value = remainder
        remainder = ""
        {value, done: false}
      else
        {done}

{resolve} = require "when"
Method.define split, isFunction, isReactor, (f, i) ->
  lines = []
  remainder = ""
  reactor async ->
    if lines.length > 0
      {value: lines.shift(), done: false}
    else
      {value, done} = yield next i
      if !done
        [first, lines..., last] = f value
        first = remainder + first
        remainder = last
        {value: first, done}
      else if remainder != ""
        value = remainder
        remainder = ""
        {value, done: false}
      else
        {done}

split = curry binary split

lines = split (s) -> s.toString().split("\n")

tee = Method.create()

Method.define tee, isFunction, isDefined, (f, x) -> tee f, (producer x)

Method.define tee, isFunction, isReactor, (f, r) ->
  reactor ->
    (next r).then ({done, value}) ->
      unless done
        # this bit of curious logic ensures that we return a promise
        # if f is actually async, that is, returns a promise.
        # that promise will resolve to the original value, but not until
        # f resolves it. this allows tee to be used when the caller
        # depends upon f having returned
        ((f value)?.then? -> {done, value}) || {done, value}
      else {done}

Method.define tee, isFunction, isIterator, (f, i) ->
  iterator ->
    {done, value} = next i
    unless done
      # see above...
      {done, value: ((f value)?.then? -> value) || value}
    else {done}

tee = curry binary tee

throttle = curry (ms, i) ->
  last = 0
  reactor async ->
    loop
      {done, value} = yield next i
      break if done
      now = Date.now()
      break if now - last >= ms
    last = now
    {done, value}

pump = Method.create()

isStreamLike = (s) ->
  s? && (isFunction s.write) && (isFunction s.end)

Method.define pump, isStreamLike, isDefined,
  (s, x) -> pump s, (producer x)

Method.define pump, isStreamLike, isIterator,
  (s, i) ->
    iterator ->
      {done, value} = next i
      if done then s.end() else s.write value
      {done, value: s}

Method.define pump, isStreamLike, isReactor,
  (s, i) ->
    reactor ->
      (next i).then ({done, value}) ->
        if done then s.end() else s.write value
        {done, value: s}

pump = curry binary pump

# TODO: filter version of flatten

# This version of flatten has very limited scope. It only deals with arrays,
# not producibles in general. This is good enough for our purposes here, to
# illlustrate the idea.

# flatten = (i) ->
#   stack = []
#   _next = ->
#     {done, value} = next r
#     if !done
#       if isArray value && !empty value
#         stack.push i
#         i = product value
#         do _next
#       else
#         {done, value}
#     else
#       if !empty stack
#         i = stack.pop()
#         do _next
#       else
#         {done}
#   iterator -> do _next

module.exports = {map, accumulate, select, filter, reject,
  project, compact, partition, take, takeN, where,
  split, lines, tee, throttle, pump}
