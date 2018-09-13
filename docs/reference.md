# River API Reference

> These are a work-in progress.

## Terms

|     term | meaning                                                      |
| -------: | ------------------------------------------------------------ |
| iterator | An object that follows the [Iterator Protocol](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Iteration_protocols#The_iterator_protocol). |
|  reactor | Shorthand for an [asynchronous iterator](https://github.com/tc39/proposal-async-iteration#async-iterators-and-async-iterables). |
| producer | An object that's either an iterator or reactor.              |
|  adapter | A function that transforms a value into a producer.          |
|   filter | A function that transforms a producer into another kind of producer. |
|  reducer | A function that transforms a producer into an ordinary value, like an array or a number. |
|  generic | A function that is polymorphic across one or more of its arguments. |



## Adapters

Adapters are functions that take a value and return a producer.

### producer

_**producer** value &rarr; producer_

| name                 | type     | description                                           |
| -------------------- | -------- | ----------------------------------------------------- |
| value                | any      | Any value intended to be transformed into a producer. |
| &rarr;&nbsp;producer | producer | A producer (an iterator or reactor).                  |

#### Example

```coffeescript
assert isIterator (producer [])
assert isReactor (producer -> yield await null)
```



### events

_**events** name, source &rarr; reactor_

| name                | type    | description                                                  |
| ------------------- | ------- | ------------------------------------------------------------ |
| name                | string  | The name of the event to produce.                            |
| source              | object  | The source of the events. Must have an `on` method for registering handlers. |
| &rarr;&nbsp;reactor | reactor | A reactor that produces the named events from the source.    |

### read

_**read** stream &rarr; reactor_

| name                | type    | description                                                  |
| ------------------- | ------- | ------------------------------------------------------------ |
| stream              | stream  | A readable stream-like object, with `data`, `error`, and `end` events. |
| &rarr;&nbsp;reactor | reactor | A reactor that produces the data events from the stream.     |

### union

### flow

### go

## Filters

### tee

### map

### project

### accumulate

### select

### reject

### compact

### flatten

### junction

### fork

### partition

### take

### limit

### wait

### lines

### throttle

## Reducers

### start

### each

### collect

### fold/reduce

### foldr/reduceRight

### any

### all

### zip

### sum

### average

### delimit

### write
