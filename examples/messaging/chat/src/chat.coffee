{Channel, Transport} = require "mutual"
transport = Transport.Redis.Broadcast.create()
channel = Channel.create "hello", transport

channel.on message: (message) ->
  assert message == "Hello, World"
