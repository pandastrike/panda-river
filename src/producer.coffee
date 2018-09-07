import {identity} from "fairmont-core"
import {Method} from "fairmont-multimethods"

{isIterable, isIterator, iterator} = require "./iterator"
{isReagent, isReactor, reactor} = require "./reactor"

isProducer = (x) -> (isIterator x) || (isReactor x)

producer = Method.create
  default: -> throw "Unable to convert value to a producer."

Method.define producer, isIterable, (x) -> iterator x
Method.define producer, isReagent, (x) -> reactor x
Method.define producer, isProducer, identity

export {isProducer, producer}
