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

#### product

A value returned by calling `next` on an iterator or reactor. Similarly, we say the value is _produced by_ the iterator or reactor.

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

Reactor equivalent to [`isIterable`](#isIterable).

#### isReactor

Reactor equivalent to [`isIterator`](#isIterator).

#### reactor

Reactor equivalent to [`iterator`](#iterator).

- If the value is a reactor, we return it.
- If the value is a reagent, we call its `Symbol.asyncIterator` method.
- If the value is a generator, we call the generator.
- If the value is a function, we construct an iterator from the function.

## Roadmap

You can get an idea of what we're planning by looking at the [issues list][tickets]. If you want something that isn't there, and you think it would be a good addition, please open a ticket.

[tickets]:https://github.com/pandastrike/panda-river/issues
