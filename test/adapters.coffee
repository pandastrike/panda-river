{createReadStream} = require "fs"

assert = require "assert"

Amen = require "amen"

{next, value, isDone} = require "../src/iterator"

{producer, repeat, pull, queue, events,
  stream, flow, combine} = require "../src/adapters"

{map, lines} = require "../src/filters"
{collect} = require "../src/reducers"

Amen.describe "Adapters", (context) ->

  context.test "pull"

  context.test "pull (non-promise)"

  context.test "pull (undefined)" #, ->
    # i = flow [
    #   [1..5]
    #   map (x) -> undefined
    #   pull
    # ]
    # assert next i
    # assert next i
    # assert next i
    # assert next i
    # assert next i
    # assert isDone i

  context.test "queue", ->
    {enqueue, dequeue, end} = queue()
    enqueue 1
    setImmediate -> enqueue 2
    setImmediate -> end()
    assert.equal 1, (value yield next dequeue)
    assert.equal 2, (value yield next dequeue)
    assert.equal true, (isDone yield next dequeue)

  context.test "combine", ->
    i = combine [1..5], [1..5]
    assert.equal 10, (yield collect i).length

  context.test "events", ->
    i = events "data", createReadStream "test/data/lines.txt"
    assert (yield i()).value.toString() == "one\ntwo\nthree\n"
    assert (yield i()).done

  context.test "stream", ->
    i = stream createReadStream "test/data/lines.txt"
    assert ((yield i()).value.toString() == "one\ntwo\nthree\n")
    assert (yield i()).done

  context.test "flow", ->
    i = flow [1..5], map (n) -> n * 2
    assert.deepEqual (n * 2 for n in [1..5]),
      collect i

  context.test "flow (reactive)", ->
    assert.deepEqual [ "one", "two", "three" ],
      yield collect flow [
        stream createReadStream "./test/data/lines.txt"
        lines
      ]
