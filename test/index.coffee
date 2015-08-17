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

(require "./#{target}") for target in targets
