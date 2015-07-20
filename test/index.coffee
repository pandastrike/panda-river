targets = process.argv[2..]

if targets.length == 0
  targets = [
    "iterator"
    "reducer"
    "reactive"
  ]

(require "./#{target}") for target in targets
