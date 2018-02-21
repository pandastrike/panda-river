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


## Roadmap

You can get an idea of what we're planning by looking at the [issues list][tickets]. If you want something that isn't there, and you think it would be a good addition, please open a ticket.

[tickets]:https://github.com/pandastrike/panda-river/issues
