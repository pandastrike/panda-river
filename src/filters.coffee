import {isFunction, isDefined, isNumber, property, query} from "panda-parchment"
import {curry, binary, ternary, negate, tee as _tee} from "panda-garden"
{Method} = require "panda-generics"
{iterator, iteratorFunction, isIterator, next} = require "./iterator"
{reactor, reactorFunction, isReactor} = require "./reactor"
{producer} = require "./adapters"
isAny = (x) -> true

define = ({name, description, terms, iterator, reactor}) ->
  f = Method.create
    description: description
    default: (args..., last) ->
      if args.length == terms.length
        f args..., producer last
      else
        throw "#{name}: wrong number of arguments"

  Method.define f, terms..., isIterator, iterator
  Method.define f, terms..., isReactor, reactor
  f

# map

map = curry binary define
  name: "map"
  description: "Apply a transformation function to an iterator's products."
  terms: [ isFunction ]
  iterator: (f, i) -> do -> yield (f x) for x from i
  reactor: (f, r) -> do -> yield (f x) for await x from r

# accumulate

accumulate = curry ternary define
  name: "accumulate"
  description: "Apply a transformation function to an iterator's products,
    producing an accumulated result."
  terms: [ isFunction, isAny ]
  iterator: (f, k, i) -> do -> yield (k = f k, x) for x from i
  reactor: (f, k, r) -> do -> yield (k = f k, x) for await x from r

# select

select = filter = curry binary define
  name: "select"
  description: "Apply a filtering function to products of an iterator."
  terms: [ isFunction ]
  iterator: (f, i) -> do -> yield x for x from i when f x
  reactor: (f, r) -> do -> yield x for await x from r when f x

# tee

tee = curry binary define
  name: "tee"
  description: "Apply a function to an iterator's products, returning them."
  terms: [ isFunction ]
  iterator: (f, i) -> do -> yield ((_tee f) x) for x from i
  reactor: (f, r) -> do -> yield ((_tee f) x) for await x from r


# partition

partition = curry binary define
  name: "partition"
  description: "Batches an interator's products in groups of N."
  terms: [ isNumber ]

  iterator:(n, i) ->
    do ->
      batch = []
      for x from i
        batch.push x
        if batch.length == n
          yield batch
          batch = []
      if batch.length > 0
        yield batch

  reactor: (n, r) ->
    do ->
      batch = []
      for await x from r
        batch.push x
        if batch.length == n
          yield batch
          batch = []
      if batch.length > 0
        yield batch















reject = curry (f, i) -> select (negate f), i


project = curry (p, i) -> map (property p), i

compact = select isDefined



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

# TODO: generalize beyond strings
# Need a combine function to go with the split function?
# For now, this is just an internal method...used by
# `lines` below.
pour = Method.create()

Method.define pour, isFunction, isDefined,
  (f, x) -> pour f, (producer x)

Method.define pour, isFunction, isIterator, (f, i) ->
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

Method.define pour, isFunction, isReactor, (f, i) ->
  lines = []
  remainder = ""
  reactor ->
    if lines.length > 0
      {value: lines.shift(), done: false}
    else
      {value, done} = await next i
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

pour = curry binary pour

lines = pour (s) -> s.toString().split("\n")


throttle = curry (ms, i) ->
  last = 0
  reactor ->
    loop
      {done, value} = await next i
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
  lines, tee, throttle, pump}
