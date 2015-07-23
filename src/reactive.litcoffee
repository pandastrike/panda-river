# Reactive Programming Functions

## flow

      {curry} = require "fairmont-core"
      {async} = require "fairmont-helpers"
      {iterator, asyncIterator} = require "./iterator"
      {reduce} = require "./reducer"

      flow = ([i, fx...]) -> reduce i, ((i,f) -> f i), fx

## start

      # TODO: need to add synchronous version

      start = async (i) ->
        loop
          {done, value} = yield i()
          break if done


## pump

      # TODO: need to add synchronous version

      pump = curry (s, i) ->
        asyncIterator async ->
          {done, value} = yield i()
          if !done
            value: (s.write value)
            done: false
          else
            s.end()
            {done}

## tee

      # TODO: need to add synchronous version

      tee = curry (f, i) ->
        asyncIterator async ->
          {done, value} = yield i()
          (f value) unless done
          {done, value}


## throttle

      throttle = curry (ms, i) ->
        last = 0
        asyncIterator async ->
          loop
            {done, value} = yield i()
            break if done
            now = Date.now()
            break if now - last >= ms
          last = now
          {done, value}

---

      module.exports = {flow, start, pump, tee, throttle}
