{start, flow, map, async, isString, asyncIterator} = require "fairmont"

apply = async (f) -> yield f()

_tasks = {}
lookup = (name) ->
  if (_task = _tasks[name])?
    _task
  else
    console.error "Warning: Task '#{name}' is not defined."
    (async -> yield null)

task = async (name, tasks..., f) ->

  if arguments.length == 0
    yield _tasks.default()

  else if arguments.length == 1
    yield _tasks[name]()

  else

    if isString f
      tasks.push f
      f = undefined

    started = false
    _tasks[name] = async ->
      if !started
        started = true
        console.log "Task '#{name}' is starting…"
        {collect} = require "fairmont"
        resets = yield collect flow [
          tasks
          map lookup
          map apply
          # TODO: ugh
          # okay: the reason for this little mess is that we don't have a way
          # to convert a sync iterator into an async iterator based on the
          # return value from the iterator (or any other way, besides writing
          # a little wrapper function like this. the task function is async
          # so the map iterator ultimately returns a promise
          (i) ->
            asyncIterator async ->
              {done, value} = i()
              if done then {done} else {done, value: yield value}
        ]
        yield f?()
        console.log "Task '#{name}' is done."
        started = false

module.exports = {task}
