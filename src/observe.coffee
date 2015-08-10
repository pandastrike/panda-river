{EventEmitter} = require "events"

{compose} = require "fairmont-core"
{isDefined, isArray, isObject,
  isFunction, property} = require "fairmont-helpers"
{Method} = require "fairmont-multimethods"

isSource = compose isFunction, property "on"

observe = Method.create()

Method.define observe, isDefined, (object) ->
  observe object, new EventEmitter

Method.define observe, isObject, isSource, (object, events) ->

  Object.observe object, ->
    events.emit "change", object

  for key, value of object
    do (key, value) ->
      if isObject value
        observe value, events

  events

Method.define observe, isArray, isSource, (object, events) ->

  Array.observe object, ->
    events.emit "change", object

  for key, value of object
    do (key, value) ->
      if isObject value
        observe value, events

  events

module.exports = {observe}
