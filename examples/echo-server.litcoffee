# Example: Reactive Echo Server

This is a trivial example of a reactive style of programming. It's a simple echo server. It would be much easier to just write this as a one-liner where we pipe the connection back to itself. However, it's the simplicity of the example that makes it good for demonstrating reactive programming.

We create the server just like we usually would, except we don't set up a callback for connections. We're going to listen for `connection` events instead.

    net = require "net"
    server = net.createServer().listen(1337)

Let's grab the necessary building blocks from Fairmont.

    {go, events, tee, stream, pump} = require "../src/index"

We can start our flow with `go`.

    go [

The first expression in a flow array must be a producer (an iterator or reactor). We're going use `events` to take a server that emits connection events and returns an iterator that produces connections. The `events` function can take an events map. Here, we're specifying that a `close` event ends the iteration.

      events name: "connection", end: "close", server

We use `tee` to introduce a nested flow for handling the connection stream.

      tee (s) ->
        go [
          stream s
          pump s
        ]
    ]

The `stream` function takes a stream and returns an iterator that produces values from the stream. Then we write these back to the connection with `pump`.

In this simple example, that's the end of the flow. There's not much to it. We get a connections and stream them back into themselves. However, we could have replaced the echo flow with something that processes the input and does something more interesting.
