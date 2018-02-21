assert = require "assert"
import {follow} from "fairmont-helpers"
import {isReagent, reactor, isReactor} from "../src/reactor"

testReactors = (test) ->

  counter = (n = 0) -> reactor -> follow {done: false, value: n++}

  test "Reactors", [

    test "isReagent", -> assert isReagent counter()

    test "reactor", [

      test "isReactor", -> assert isReactor counter()

    ]
  ]

export {testReactors}
