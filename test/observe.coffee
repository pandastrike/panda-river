assert = require "assert"
Amen = require "amen"
{promise} = require "when"

{next, value} = require "../src/iterator"
{observe} = require "../src/observe"

Amen.describe "Observe", (context) ->
  context.test "change events", ->
    {proxy, reactor} = observe value: 7
    setImmediate -> proxy.value = 3
    assert.deepEqual value: 3,
      value yield next reactor

    do (proxy, reactor) ->
      context.test "nested change events", ->
        {proxy, reactor} = observe value: value: 7
        setImmediate -> proxy.value.value = 5
        assert.deepEqual value: value: 5,
          value yield next reactor

    do (proxy, reactor) ->
      context.test "for arrays", ->
        {proxy, reactor} = observe [1..5]
        setImmediate -> proxy.shift()
        assert.deepEqual [2..5],
          value yield next reactor
