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

    logger = ({request, response}) ->
      {method, url} = request
      code = response.statusCode
      console.log "#{method} #{url} - #{code}"

Let's pick up a few building blocks from Fairmont.

    {spread, spread} = require "fairmont"
    {go, events, select, tee, map} = require "../src"

We're ready now to implement our Web server.
We kick things off with `go`.

    go [

We pick up request events from the server.

      events "request", server

We create a request context.
Since `events` produces an array for events whose handlers take multiple arguments, we use `spread` to take that array and turn it back into an argument list.

      map spread (request, response) -> {request, response}

We use `tee` to process the request, but also pass it on to the next function in our middleware stack.

      tee ({request, response}) ->

We have a very simple request processor that only handles `GET /` requests.

        {method, url} = request
        if url == "/"
          if method == "GET"
            response.statusCode = 200
            response.end "hello, world"
          else
            response.statusCode = 405
            response.end "Method Not Allowed"
        else
          response.statusCode = 404
          response.end "Not Found"

We pass the request to next function in our middleware stack, the logger.

      tee logger
    ]

As you can see, functional reactive programming allows us to implement a middleware-like design with no additional framework code.
