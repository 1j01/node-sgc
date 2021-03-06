
SGC = require './'
fs = require 'fs'

{heading} = SGC.helpers
SGC.debug = true

console.log heading "PARSE TEST CONFIGURATION FILE"
config = SGC.parse fs.readFileSync "test.sgc", "utf8"

console.log heading "LOADED CONFIGURATION"
console.log config # JSON.stringify config, null, 2

console.log heading "RE-STRINGIFY CONFIGURATION"
console.log SGC.stringify config
