# Example: Reactive Web Server

This is a trivial Web server implemented in a reactive style.
This example builds on what the [echo server example](./echo-server.litcoffee).
The middleware style of processing requests popularized by Rack and Express is a natural result of using functional reactive programming with an HTTP server.
Except that none of the functions need to worry about a `next` function.

We create the server like we would normally do, except we don't pass in a callback.
Instead, we're going to use it to generate request/response pairs.

    http = require "http"

    server = http.createServer().listen(1337)

We'll define a very silly logger, for demonstration purposes.

    logger = (request, response) ->
      console.log request.method, request.url, response.statusCode

Let's pick up a few building blocks from Fairmont.

    {spread, spread} = require "fairmont"
    {start, flow, events, select, tee, map, iterator} = require "../src"

We're ready now to implement our Web server.

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

We kick off the flow, as always, with `start flow`.
We pick up request events from the server.
Since `events` produces an array for events whose handlers take multiple arguments, we use `spread` to take that array and turn it back into an argument list.
We're only interested here in `GET` requests, so we use `select` to filter out others requests.
We're going to further narrow our interest to only the root resource.
In real life, you might use a request classifier here.
We might also do, say, authentication here.
We respond with a status code of `200` and content body of `hello, world`.
The `tee` function returns an iterator function that operates on the value produced by the iterator, but then produces the original value.
(In contrast to `map`, which produces the result of applying the function.)
It's kind of like calling `next` with conventional middleware.
This allows us to do something with the request, but also pass it along to the next iterator function.
Finally, we log the result.

As you can see, this works a lot of like middleware in a package like Express. FRP style effectively allows us to replicate middleware with no extra code.
