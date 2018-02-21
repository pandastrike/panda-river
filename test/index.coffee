import {print, test} from "amen"
import {testIterators} from "./iterator"
import {testReactors} from "./reactor"

targets = process.argv[2..]

if targets.length == 0
  targets = [
    "iterator"
    "reactor"
    "adapters"
    "filters"
    "reducers"
    "observe"
    "helpers"
  ]

do ->

  print await test "Panda River", [

    testIterators test
    testReactors test

  ]
