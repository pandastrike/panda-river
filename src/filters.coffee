import {isFunction, isDefined, isNumber, property} from "panda-parchment"
import {curry, binary, ternary, negate, tee as _tee} from "panda-garden"
{Method} = require "panda-generics"
{isIterator} = require "./iterator"
{isReactor} = require "./reactor"
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
  iterator: (f, i) -> yield (f x) for x from i
  reactor: (f, r) -> yield (f x) for await x from r

# project

project = curry (p, i) -> map (property p), i

# accumulate

accumulate = curry ternary define
  name: "accumulate"
  description: "Apply a transformation function to an iterator's products,
    producing an accumulated result."
  terms: [ isFunction, isAny ]
  iterator: (f, k, i) -> yield (k = f k, x) for x from i
  reactor: (f, k, r) -> yield (k = f k, x) for await x from r

# select

select = filter = curry binary define
  name: "select"
  description: "Apply a filtering function to products of an iterator."
  terms: [ isFunction ]
  iterator: (f, i) -> yield x for x from i when f x
  reactor: (f, r) -> yield x for await x from r when f x

# reject

reject = curry (f, i) -> select (negate f), i

# compact

compact = select isDefined

# tee

tee = curry binary define
  name: "tee"
  description: "Apply a function to an iterator's products, returning them."
  terms: [ isFunction ]
  iterator: (f, i) -> yield ((_tee f) x) for x from i
  reactor: (f, r) -> yield ((_tee f) x) for await x from r

# partition

partition = curry binary define
  name: "partition"
  description: "Batches an interator's products in groups of N."
  terms: [ isNumber ]

  iterator:(n, i) ->
    batch = []
    for x from i
      batch.push x
      if batch.length == n
        yield batch
        batch = []
    if batch.length > 0
      yield batch

  reactor: (n, r) ->
    batch = []
    for await x from r
      batch.push x
      if batch.length == n
        yield batch
        batch = []
    if batch.length > 0
      yield batch

# take

take = curry binary define
  name: "take"
  description: "Apply a function to each product until it returns false."
  terms: [ isFunction ]

  iterator: (f, i) ->
    for x from i
      if f x
        yield x
      else
        break

  reactor: (f, r) ->
    for await x from r
      if f x
        yield x
      else
        break

# limit

limit = do ->
  f = (n, i = 0) -> -> i++ < n
  (n, i) -> take (f n), i

# pour

# TODO: generalize beyond strings
# possibly with a 2nd “combine” function?

pour = curry binary define
  name: "pour"
  description: "Transforms the unit of iteration, ex: from blocks to lines."
  terms: [ isFunction ]
  iterator: (f, i) ->
    remainder = ""
    for x from i
      [first, lines..., last] = f x
      yield remainder + first
      remainder = last
      yield line for line in lines
    if remainder != ""
      yield remainder
  reactor: (f, r) ->
    remainder = ""
    for await x from r
      [first, lines..., last] = f x
      yield remainder + first
      remainder = last
      yield line for line in lines
    if remainder != ""
      yield remainder

# lines

lines = pour (s) -> s.toString().split("\n")

# throttle

throttle = debounce = curry (interval, r) ->
  last = 0
  for await x from r
    if (Date.now() - last) >= interval
      yield x

export {map, project, accumulate, select, filter, reject, compact,
  tee, partition, take, limit, lines, throttle}
