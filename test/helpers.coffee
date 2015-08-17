{createReadStream} = require "fs"
{EventEmitter} = require "events"

assert = require "assert"
Amen = require "amen"

{next} = require "../src/iterator"
{go} = require "../src/helpers"
{map, accumulate, lines} = require "../src/filters"
{flow, events, stream, combine} = require "../src/adapters"

Amen.describe "Helpers", (context) ->

  context.test "go", ->

    _lines = []

    yield go [
      stream createReadStream "./test/data/lines.txt"
      lines
      map (line) -> _lines.push line
    ]

    assert _lines.length == 3
    assert _lines[0] == "one"
    assert _lines[1] == "two"
    assert _lines[2] == "three"

  context.test "combine/accumulate example", ->
    click =
      increment: new EventEmitter
      decrement: new EventEmitter

    i = flow [
      events "change", click.increment
      map -> 1
    ]

    j = flow [
      events "change", click.decrement
      map -> -1
    ]

    k = flow [
      combine i, j
      accumulate ((a, b) -> a + b), 0
    ]

    # inc, dec
    click.increment.emit "change"
    assert (yield next k).value == 1
    click.decrement.emit "change"
    assert (yield next k).value == 0
    click.increment.emit "change"
    assert (yield next k).value == 1
    click.increment.emit "change"
    assert (yield next k).value == 2
    click.decrement.emit "change"
    assert (yield next k).value == 1
