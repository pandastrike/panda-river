{start} = require "./reducers"
{flow} = require "./adapters"

go = -> start flow arguments...

module.exports = {go}
