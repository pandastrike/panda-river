# Fairmont-Reactive

Fairmont-Reactive is a JavaScript library for functional reactive programming. It's part of the [Fairmont][] library. You can use it by itself, or simply as part of the [Fairmont][] library.

## Installation

`npm install fairmont-reactive`

## Examples

Here's a simple reactive Web app implementing a counter using Fairmont's Reactive programming functions.

In JavaScript:

```javascript
var $ = require("jquery"),
  F = require("fairmont");

$(function() {

  var data = { counter: 0 };

  F.start(F.flow([
    F.events("click", $("a[href='#increment']")),
    F.map(function() { data.counter++; })
  ]));

  F.start(F.flow([
    F.events("change", F.observe(data)),
    F.map(function() {
      $("p.counter")
        .html(data.counter);
    })
  ]));
});

```

In CoffeeScript:

```coffeescript
{start, flow, events, map, observe} = require "fairmont-reactive"

$ = require "jquery"

$ ->

  data = counter: 0

  start flow [
    events "click", $("a[href='#increment']")
    map -> data.counter++
  ]

  start flow [
    events "change", observe data
    map ->
      $("p.counter")
      .html data.counter
  ]
```

Check out our other reactive examples:

- an [echo server][]
- a [Web server][]
- a [file watcher][]

[echo server]:https://github.com/pandastrike/fairmont-reactive/blob/master/examples/echo-server.litcoffee
[Web server]:https://github.com/pandastrike/fairmont-reactive/blob/master/examples/web-server.litcoffee
[file watcher]:https://github.com/pandastrike/fairmont-reactive/blob/master/examples/file-watcher.litcoffee

## Documentation

Check out the [wiki][] for an getting started guides, tutorials, and reference documentation.

## Status

[Fairmont][0] is still under heavy development and is `beta` quality, meaning you should probably not use it in your production code.

## Roadmap

You can get an idea of what we're planning by looking at the [issues list][200]. If you want something that isn't there, and you think it would be a good addition, please open a ticket.

[tickets]:https://github.com/pandastrike/fairmont/issues
[Fairmont]:https://github.com/pandastrike/fairmont
[wiki]:https://github.com/pandastrike/fairmont/wiki
