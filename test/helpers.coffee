{createReadStream} = require "fs"

assert = require "assert"
Amen = require "amen"

{next} = require "../src/iterator"
{go} = require "../src/helpers"
{map, lines} = require "../src/filters"
{stream} = require "../src/adapters"

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
