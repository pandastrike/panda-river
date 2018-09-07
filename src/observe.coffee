{isObject} = require "panda-parchment"
{queue} = require "./adapters"

proxy = (target, handlers) -> new Proxy target, handlers

# TODO: add additional supported types
isObservable = (target) ->
  isObject target ||
    isArray target

observe = (root) ->

  {enqueue, dequeue} = queue()

  handlers =
    defineProperty: enqueue
    deleteProperty: enqueue
    set: (target, key, value) ->
      target[key] = value
      enqueue root

  observed = []

  _observe = (target) ->
    for key, value of target when isObservable value
      unless value in observed
        observed.push value
        target[key] = _observe value
    proxy target, handlers

  proxy: _observe root
  reactor: dequeue

module.exports = {proxy, observe}
