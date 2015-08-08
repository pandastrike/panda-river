# Fairmont/Reactive

[Fairmont][0]/Reactive is a JavaScript library for functional reactive programming.

[0]:https://github.com/pandastrike/fairmont

Here's a simple 'hello, world' Web server written in a functional, reactive style using Fairmont.

### In JavaScript

```javascript
start(flow([

  events("request", server),

  select(spread(function(request) {
    return request.method === "GET";
  })),

  select(spread(function(request) {
    return request.url === "/";
  })),

  tee(spread(function(ignored, response) {
    response.statusCode = 200;
    response.write("hello, world");
    response.end();
  })),

  map(spread(logger));

]));
```

### In CoffeeScript
```coffee
start flow [
  events "request", server
  select spread (request) -> request.method == "GET"
  select spread (request) -> request.url == "/"
  tee spread (ignored, response) ->
    response.statusCode = 200
    response.write "hello, world"
    response.end()
  map spread logger
]
```

## Examples

You can get a feel for what [Fairmont][0] can do for you by [checking out the examples](./examples).

## Introduction

### Iterators

An _iterator_ is an ES6 iterator, with a `next` function that produces a value wrapper.
A _value wrapper_ is what iterators produce, with `done` and `value` properties.
These are part of the ES6 standard.

### Reactors

An _asynchronous iterator_ is an iterator that produces promises that resolve to value wrappers.
These are a proposed part of ES7.
An _asynchronous iterator function_ is a function that returns promises that resolve to value wrappers.

A _reactor_ is [Fairmont][0] lingo for an asynchronous iterator.

When talking about values that could be iterators or reactors, we will sometimes say _producers_.

### Adapters, Filters, and Reducers

An _adapter_ creates a producer (an iterator or reactor) from a non-producer.
An _iterator filter_ is a function that takes an iterator and returns another iterator.
Iterator filters are just called _filters_ for convenience whenever it isn't ambiguous.

An _iterator reducer_ is a function that takes an iterator and returns a value that isn't an iterator.
Iterator reducers are just called _reducers_ for convenience whenever it isn't ambiguous.

When talking about functions that could be adapters, filters, or reducers, we will sometimes say _transforms_.

### Polymorphic Filters And Reducers

Most transforms are implemented for both iterators and reactors.
For example, if we pass an iterator to `map` we'll get back an iterator. Whereas if we pass it a reactor, we'll get back a reactor.
Similarly, if we pass an iterator to `collect` we'll get back an array.
If we pass it a reactor, we'll get back a promise that resolves to an array.

Many values that aren't iterators or reactors will be coerced into one or the other when passed to a transform or reduction.
For example, if you pass an array into `map`, the array will be coerced into an iterator.
Similarly, if you pass a promise into `map`, the promise will be coerced into a reactor.

## About Fairmont

[Fairmont][0] takes full advantage of ES6+ features like iterators (including async iterators, called _reactors_), generators, and promises. Inspired by libraries like [Underscore](http://underscorejs.org/) and many others, [Fairmont][0] features include:

* reactive programming support through async iterators
* lazy evaluation on collection operations via iterators
* core functional operations, like currying and composition
* bridge functions for integrating with OOP-based libraries
* common file and stream based operations
* streams and event emitters modeled as reactors
* seamless integration between synchronous and asynchronous operations
* … and more!

## Status

[Fairmont][0] is still under heavy development and is `beta` quality, meaning you should probably not use it in your production code.

## Roadmap

You can get an idea of what we're planning by looking at the [issues list][200]. If you want something that isn't there, and you think it would be a good addition, please open a ticket.

[200]:https://github.com/pandastrike/fairmont/issues
