{task} = require "./task"
require "./tasks"

tasks = process.argv[2..]
if tasks.length == 0
  task "default"
else
  (task name) for name in tasks
