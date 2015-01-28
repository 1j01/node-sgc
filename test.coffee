
SGC = require './index'
fs = require 'fs'

heading = (title)->
	dashes = ""
	dashes += "-" for character in title
	console.log """
		
		+-#{dashes}-+
		| #{title } |
		+-#{dashes}-+
		
	"""

SGC.debug = {heading}

heading "PARSE TEST CONFIGURATION FILE"

config = SGC.parse fs.readFileSync "test.sgc", "utf8"

heading "LOADED CONFIGURATION"

console.log config

heading "RE-STRINGIFY CONFIGURATION"

console.log SGC.stringify config
