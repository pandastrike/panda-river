# Implementation Notes

## wait

Filters are polymorphic across producer types (iterators and reactors). But what if a producer's value is itself a promise?

Ex:

```coffeescript
console.log sum: go [
  [1..5]
  map follow
  # this will fail because
  # previous filter produces
  # promises not integers
  sum
]
```

What we'd like to do is find a way to compose filters F and G such that if filter F produces promises, we wait until that's resolved until passing it to G. In fact, that's basically how Panda Garden's `compose` function works already.

The problem is that when we compose filters, we get a function that accepts a producer. We don't “see” the promises until we start askng for values. And it has nothing to do with whether we have an iterator or reactor, so making `compose` polymorphic across producer types doesn't help. Either can produce a value that's a promise. We have to detect this at the point where we're producing values.

We can wrap a producer with logic to check to see if a given value being produced is a promise. However, this effectively requires that composition always results in a reactor, even if we're composing two iterators. That's because the solution to dealing with an iterator that produces promises is to turn it into a reactor. And since we don't know in advance whether we might get a promise, we have to assume that we will. Since we don't want to burden composition of iterators with `yield` and `await` overhead, this seems like a poor solution.

We can make that wrapping explicit, rather than on relying on composition to do it transparently. If we know an iterator is producing promises, as in the above example, we just turn it into a reactor with our wrapper.

Ex:

```coffeescript
console.log sum: go [
  [1..5]
  # this works now because we wrap
  # the promise-producing iterator and 
  # turn it into a reactor
  wait map follow
  sum
]
```

However, is this really a concern of producers? Or of functions themselves? That is, should we just wrap the combinator, like `wait follow`? But this doesn't make sense, because if the combinator returns a promise, so will our wrapper, and we're back to where we started. So we know the producer is the right thing to wrap.
