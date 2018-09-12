import {print, test} from "amen"
import {default as iterators} from "./iterator"
import {default as reactors} from "./reactor"
import {default as adapters} from "./adapters"
import {default as filters} from "./filters"

# modules = { iterators, reactors, adapters, filters }
modules = { iterators, reactors, adapters, filters }
targets = process.env.PANDA_RIVER_TARGETS?.split /\s+/
targets ?= []

for target in targets when !modules[target]?
  console.error "invalid target: '#{target}'"
  process.exit -1

valid = (module) -> targets.length == 0 || (module in targets)

do ->
  print await test "Panda River",
    (test name, module) for name, module of modules when valid name
