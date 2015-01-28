
try
	require('simple-colors') # TODO: remove
	util = require('util') # TODO: remove

inDebugMode = ->
	module.exports.debug # or imports, rather

heading = (title)->
	dashes = ""
	dashes += "-" for character in title
	"""
		
		+-#{dashes}-+
		| #{title } |
		+-#{dashes}-+
		
	"""

module.exports =
	helpers: {heading}
	
	parse: (sgc)->
		config = screens: {}, links: {}, aliases: {}, options: {}
		lines = sgc.split "\n"
		
		# This loop is kind of clever in that it accesses a line in the
		# 0-based array and then increments lineno to be 1-based
		lineno = 0
		line = ""
		nextLine = ->
			line = lines[lineno++]
			if line?
				# strip comments
				line = line.replace /#.*$/, ""
				# empty line?
				if line.match /^\s*$/
					console.log "#{lineno} ...".grey() if inDebugMode()
					nextLine() # skip this line; recurse
				else
					console.log "#{lineno} | #{line}" if inDebugMode()
					yes # continue loop
			else
				no # end loop
		
		while nextLine()
			
			tab = (line.match /^\s+/)?[0]
			config.meta ?= {tab} if tab
			
			parse = (str, pattern)->
				captures = []
				regExpPattern = pattern
					.replace /[A-Z]+/g, (match)->
						captures.push match.toLowerCase()
						///(
							# this matches a bunch of stuff
							[\w().\-+_~,]+
							
							(?:
								# sometimes stuff will even have spaces in it
								[\w().\-+_~,\ ]+
								# but it shouldn't end with a space
								[\w().\-+_~,]+
							)?
						)///.source
					.replace /\s+/g, "\\s*" 
				regExp = new RegExp "^\\s*#{regExpPattern}\\s*$"
				m = regExp.exec str
				o = {}
				for capture, i in captures
					o[capture] = m?[i+1]
				console.log "#{lineno} as".grey(), pattern.green(), "?".grey(), util.inspect(regExp).blue(), util.inspect(o).yellow() if inDebugMode()
				o
			
			parseBlock = (o, pattern, parseSubBlock)->
				while nextLine()
					
					if line is "end"
						console.log "END OF SECTION; EXIT".red(), pattern.magenta(), "BLOCK".red() if inDebugMode()
						--lineno # reinterpret this "end" line in the parent block
						break # break out of all blocks
					
					{key, value} = parse line, pattern
					if value
						if o instanceof Array
							o.push value
						else
							o[key] = value
					else if parseSubBlock
						parseSubBlock key
					else
						console.log "NO MATCH; EXIT".red(), pattern.magenta(), "BLOCK".red() if inDebugMode()
						--lineno # try this line again, as something else
						break
			
			{section} = parse line, "section: SECTION"
			if section
				console.log heading "PARSE #{section.toUpperCase()} SECTION" if inDebugMode()
				switch section
					when "options"
						# Options are simply a list of KEY = VALUE pairs
						parseBlock config.options, "KEY = VALUE"
					when "screens", "aliases", "links"
						# These sections are all keyed with screen names
						parseBlock config[section], "KEY:", (screenName)->
							# with sub-blocks
							switch section
								when "screens"
									parseBlock (config[section][screenName] = {}), "KEY = VALUE"
								when "aliases"
									parseBlock (config[section][screenName] = []), "VALUE"
								when "links"
									parseBlock (config[section][screenName] = {}), "KEY = VALUE"
					else
						throw new Error "Unknown section name on line #{lineno}"
		
		parseValue = (val)->
			switch val
				when "true" then true
				when "false" then false
				else
					if val.match /\d+(?:\.\d+)?/
						parseFloat val
					else if val.match /\s/
						val.split /\s/
					else
						val
		
		for screenName, screen of config.screens
			for key, val of screen
				screen[key] = parseValue val
				
		for key, val of config.options
			config.options[key] = parseValue val
		
		config
	
	stringify: (config)->
		sgc = ""
		tab = config.meta?.tab ? "\t" or "  " or "    " or whatever
		indent = (str)-> tab + str.replace /\n/gm, "\n#{tab}"
		has = (o)-> Object.keys(o ? {}).length
		
		stringifySection = (name, stringify)->
			if has config[name]
				sgc += """
					section: #{name}
					#{indent stringify config[name]}
					end
					
					
				"""
		
		stringifyBlock = (o, pattern, stringifySubBlock)->
			stringified = ""
			for key, val of o
				str = pattern.replace "KEY", key
				
				if stringifySubBlock
					str += "\n" + indent stringifySubBlock val
				else if val instanceof Array
					str = str.replace "VALUE", val.join " "
				else
					str = str.replace "VALUE", val
					
				stringified += str + "\n"
			stringified.replace /\n$/m, ""
			
		stringifySection "screens", (screens)->
			stringifyBlock screens, "KEY:", (o)->
				stringifyBlock o, "KEY = VALUE"
		
		stringifySection "aliases", (aliases)->
			stringifyBlock aliases, "KEY:", (o)->
				stringifyBlock o, "VALUE"
		
		stringifySection "links", (links)->
			stringifyBlock links, "KEY:", (o)->
				stringifyBlock o, "KEY = VALUE"
		
		stringifySection "options", (options)->
			stringifyBlock options, "KEY = VALUE"
		
		sgc
