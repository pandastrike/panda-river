_This example is still under construction._

The idea here is to [use Mutual to create a reactive-systems style chat app](https://github.com/pandastrike/fairmont/issues/50). Since Mutual treats messages as events produced by event emitters, it's straightforward to pass those to Fairmont's `events` function and build flows from that.

The problem at this stage is that Mutual depends on an old version of Fairmont. What's worse, the dependency isn't fixed to that version, so when you install Mutual, it figures the latest Fairmont will be okay.

So: either the dependency needs to be fixed, or we need to update Mutual. I suspect the effort to do that latter is relatively minor. The initial error I ran into was related to switching from snake-case to camel-case. There might also be a few changes to function signatures, but, again, I don't think that will be too bad. I figure that's probably the best way to go.
