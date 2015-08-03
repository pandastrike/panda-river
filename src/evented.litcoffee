## Evented Data

    {EventEmitter} = require "events"

    evented = (object) ->
      events = new EventEmitter
      events

    {compose} = require "fairmont-core"
    {isDefined, isArray, isObject,
      isFunction, property} = require "fairmont-helpers"
    {Method} = require "fairmont-multimethods"

    isSource = compose isFunction, property "on"

    evented = Method.create()

    Method.define evented, isDefined, (object) ->
      evented object, new EventEmitter

    Method.define evented, isObject, isSource, (object, events) ->

        Object.observe object, ->
          events.emit "change", object

        for key, value of object
          do (key, value) ->
            if isObject value
              evented value, events

        events

    Method.define evented, isArray, isSource, (object, events) ->

        Array.observe object, ->
          events.emit "change", object

        for key, value of object
          do (key, value) ->
            if isObject value
              evented value, events

        events

---

    module.exports = {evented}
