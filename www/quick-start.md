# Panda River

Panda River is a JavaScript [caveat](#caveat) library for reactive programming in a functional style. River differs from libraries like RxJS by relying on JavaScript iterators and stand-alone functions (rather than method chaining). You can use the same functions whether you're working with arrays or events. And you can use common functional programming patterns, like composition and currying, to build up more powerful libraries.

##### Caveat

River is written in CoffeeScript, in case that's a show-stopper for you. But it's compiled into and otherwise entirely compatible with JavaScript.

Examples are also coded in JavaScript because I prefer to write them that way and because I think they're easier to read. That said, pull requests for JavaScript equivalents are welcome. :smile:

### Example

The _hello world_ of reactive programming is the humble counter. Given:

- `dom.increment`— a link that, when clicked, increments the counter
- `dom.counter` — an element that displays the counter
- `data.counter` — the application data, which, in this case, is just a counter

```coffee
go [
  events "click", dom.increment
  map -> data.counter++
]

go [
  events "change", observe data
  map -> dom.counter.textContent = data.counter
]
```

## Installation

`npm install panda-river`

### Terminology

#### reactor

Shorthand for asynchronous iterator.

#### producer

A shorthand for _iterator or reactor_. In other words, _producer_ may refer either to (synchronous) iterators or reactors (asynchronous iterators).

#### product

An object with `value` and `done` properties, returned or resolved by calling `next` on a producer.

## API

### Iterators

River provides helpers for using [iterators][] in a functional style.

[iterators]:https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Iterators_and_Generators

#### isIterable

Predicate testing whether a value is iterable.

```coffee
assert isIterable []
```

#### isIterator

A predicate testing whether a value is an iterator.

```coffee
assert isIterator ([][Symbol.iterator]())
# equivalent to:
assert isIterator iterator []
```

All iterators are iterable because the `Symbol.iterator` method returns the original iterator.

#### iterator

Transforms a given value into an iterator.

```coffee
assert isIterator iterator []
```

- If the value is an iterator, we return it.
- If the value is iterable, we call its `Symbol.iterator` method.
- If the value is a generator, we call the generator.
- If the value is a function, we construct an iterator from the function.

```coffee
counter = do (n = 0) -> iterator -> n++
assert isIterator counter
```

#### next

Function wrapper for the `next` method of an iterator.

#### value

Function wrapper for the `value` property of an iterator product.

#### isDone

Function wrapper for the `done` property of an iterator product.

### Reactors

Instead of returning products, asynchronous iterators (reactors) return Promises that resolve to products (objects with `done` and `value` properties).

#### isReagent

Reactor equivalent to [`isIterable`](#isIterable). Returns true if the value has a `Symbol.asyncIterator` property or is an asynchronous generator function.

#### isReactor

Reactor equivalent to [`isIterator`](#isIterator). Returns true if the value is an asynchronous generator or if its `next` method is an asynchronous function.

##### Warning

`isReactor` returns false for values whose `next` method is an ordinary synchronous function that promises products.

#### reactor

Reactor equivalent to [`iterator`](#iterator).

- If the value is a reactor, we return it.
- If the value is a reagent, we call its `Symbol.asyncIterator` method.
- If the value is an asynchronous generator, we call the generator.
- If the value is a function, we construct an reactor from the function.

### Producers

Sometimes we want to treat iterators and reactors in a uniform way. In fact, this is a core tenant of River.

#### isProducer

Predicate testing whether a value is an iterator or reactor.

#### producer

Transforms a value into a reactor or an iterator if possible.

- If the value is already a producer, we return it.
- If the value is a reagent, we return the corresponding reactor.
- If the value is iterable, we return the corresponding iterator.

## Roadmap

You can get an idea of what we're planning by looking at the [issues list][tickets]. If you want something that isn't there, and you think it would be a good addition, please open a ticket.

[tickets]:https://github.com/pandastrike/panda-river/issues
