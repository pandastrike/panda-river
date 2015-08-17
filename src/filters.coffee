_when = require "when"
{curry, binary, negate} = require "fairmont-core"
{isFunction, isDefined, property,
  query, async} = require "fairmont-helpers"
{Method} = require "fairmont-multimethods"
{iterator, iteratorFunction, isIterator, next} = require "./iterator"
{reactor, reactorFunction, isReactor} = require "./reactor"
{producer} = require "./adapters"

map = Method.create()

Method.define map, Function, isDefined,
  (f, x) -> map f, (producer x)

Method.define map, Function, isIterator, (f, i) ->
  iterator ->
    {done, value} = next i
    if done then {done} else {done, value: (f value)}

Method.define map, Function, isReactor, (f, i) ->
  reactor ->
    (next i).then ({done, value}) ->
      if done then {done} else {done, value: (f value)}

map = curry binary map

select = Method.create()

Method.define select, Function, isDefined,
  (f, x) -> select f, (producer x)

Method.define select, Function, isIterator,
  (f, i) ->
    iterator ->
      loop
        {done, value} = next i
        break if done || (f value)
      {done, value}

Method.define select, Function, isReactor,
  (f, i) ->
    p = (({done, value}) -> done || (f value))
    j = -> next i
    reactor -> _when.iterate j, p, (->), j()

select = filter = curry binary select

reject = curry (f, i) -> select (negate f), i

accumulate = Method.create()

Method.define accumulate, Function, (-> true), isDefined,
  (f, k, x) -> accumulate f, k, (producer x)

Method.define accumulate, Function, (-> true), isIterator,
  (f, k, i) ->
    iterator ->
      {done, value} = next i
      if !done
        k = f k, value
        {value: k, done: false}
      else
        {done}

Method.define accumulate, Function, (-> true), isReactor,
  (f, k, i) ->
    reactor ->
      p = next i
      p.then ({done, value}) ->
        if !done
          k = f k, value
          {value: k, done: false}
        else
          {done}


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
    if done then {done} else {value: batch, done}

Method.define partition, Number, isReactor, (n, i) ->
  reactor async ->
    batch = []
    loop
      {done, value} = yield next i
      break if done
      batch.push value
      break if batch.length == n
    if done then {done} else {value: batch, done}

# TODO: add asynchronous version

take = Method.create()

Method.define take, Function, isDefined,
  (f, x) -> take f, (producer x)

Method.define take, Function, isIterator,
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

Method.define split, Function, isDefined,
  (f, x) -> split f, (producer x)

Method.define split, Function, isIterator, (f, i) ->
  lines = []
  remainder = ""
  iterator ->
    {value, done} = next i
    if !done
      [first, lines..., last] = f value
      first = remainder + first
      remainder = last
      {value: first, done}
    else if lines.length > 0
      {value: lines.shift(), done: false}
    else if remainder != ""
      value = remainder
      remainder = ""
      {value, done: false}
    else
      {done}

{resolve} = require "when"
Method.define split, Function, isReactor, (f, i) ->
  lines = []
  remainder = ""
  reactor async ->
    ({value, done} = yield next i) unless done
    if !done
      [first, lines..., last] = f value
      first = remainder + first
      remainder = last
      {value: first, done}
    else if lines.length > 0
      {value: lines.shift(), done: false}
    else if remainder != ""
      value = remainder
      remainder = ""
      {value, done: false}
    else
      {done}

split = curry binary split

lines = split (s) -> s.toString().split("\n")

# TODO: need to add synchronous version

tee = curry (f, i) ->
  reactor ->
    (next i).then ({done, value}) ->
      (f value) unless done
      {done, value}

# TODO: need to add synchronous version

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

module.exports = {map, accumulate, select, filter, reject,
  project, compact, partition, take, takeN, where,
  split, lines, tee, throttle, pump}
