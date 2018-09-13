# Panda River

Panda River is a JavaScript library for reactive programming in a functional style. River differs from libraries like RxJS by relying on JavaScript iterators and stand-alone functions (rather than method chaining). You can use the same functions whether you're working with arrays or events. And you can use common functional programming patterns, like composition and currying, to build up more powerful libraries.

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

`npm i panda-river`

## API

- [Reference.](./docs/reference.md)
