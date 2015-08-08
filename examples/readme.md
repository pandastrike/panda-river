# Running The Examples

## Echo Server

- Execute the following command in project root:

```
coffee --nodejs --harmony examples/echo-server.litcoffee
```

- In a another terminal, enter:

```
nc localhost 1337
```

Enter some text and it will “echo” back in the terminal.

## Web Server

- Execute the following command in project root:

```
coffee --nodejs --harmony examples/web-server.litcoffee
```

- In a another terminal, enter:

```
curl localhost:1337
```

The result from the above curl will be: "Hello World"

## The File Watcher

- Execute the following command from project root:

```
coffee --nodejs --harmony examples/file-watcher.litcoffee
```

- In another terminal window, touch one of the src files...it will trigger the tests

```
touch touch src/index.coffee
```

## The Web App Example

Instructions for the Web app example [are in the `examples/web-app` directory][0].

[0]:./web-app/readme.md
