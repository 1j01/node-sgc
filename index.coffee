
#console = require 'log-colors' # TODO: remove
#console = new (require 'log-color') "info" # TODO: remove
try
	require('simple-colors') # TODO: remove
	util = require('util') # TODO: remove

debug = log: ->
	console.log arguments... if module.exports.debug

module.exports =
	
	parse: (sgc)->
		# TODO: ignore empty lines
		# TODO: ignore comments
		# TODO: preserve comments???
		config = screens: {}, links: {}, aliases: {}, options: {}
		lines = sgc.split "\n"
		lineno = 0
		# This loop might be clever in that it accesses a line in the
		# 0-based array and then increments lineno to be 1-based
		#line = "<shared throughout scopes>" # TODO: can I remove this?
		while (line = lines[lineno++])?
			debug.log? "#{lineno} | #{line}"
			
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
				#console.log rgx, m
				o = {}
				for capture, i in captures
					o[capture] = m?[i+1]
				debug.log? "#{lineno} as".grey(), pattern.green(), "?".grey(), util.inspect(regExp).blue(), util.inspect(o).yellow()
				o
				
			#console.log parse "a=   b", "key = value"
			
			parseBlock = (o, pattern, parseSubBlock)->
				#console.log "BEGIN #{pattern} BLOCK (line #{lineno})".magenta()
				#console.log "BEGIN".blue(), pattern.magenta(), "BLOCK".blue()
				while (line = lines[lineno++])?
					#console.log "#{lineno} | #{line}".green()
					debug.log? "#{lineno} | #{line}"
					
					if line.match /^\s*$/
						continue # skip
					
					if line is "end"
						debug.log? "END OF SECTION; EXIT".red(), pattern.magenta(), "BLOCK".red()
						--lineno # reinterpret this in the parent block; break out of all blocks
						break
					
					{key, value} = parse line, pattern
					if value
						if o instanceof Array
							o.push value
						else
							o[key] = value
					else if parseSubBlock
						#console.log pattern, o, key, value, parseSubBlock
						parseSubBlock key #o[key] = {}
					else
						#console.log "NO MATCH; EXIT".red(), pattern.green(), "BLOCK (line #{lineno})".red()
						#console.log "NO MATCH; EXIT #{pattern} BLOCK (line #{lineno})".red()
						#console.log "NO MATCH; EXIT".red(), pattern.magenta(), "BLOCK (line #{lineno})".red()
						debug.log? "NO MATCH; EXIT".red(), pattern.magenta(), "BLOCK".red()
						--lineno
						break
			
			{section} = parse line, "section: SECTION"
			if section
				module.exports.debug?.heading "PARSE #{section.toUpperCase()} SECTION"
				switch section
					when "options"
						# Options are simply a list of KEY = VALUE pairs
						parseBlock config.options, "KEY = VALUE"
					when "screens", "aliases", "links"
						# These sections are all keyed with screen names
						parseBlock config[section], "KEY:", (screenName)->
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
		
		stringifySection "links", (links)->
			stringifyBlock links, "KEY:", (o)->
				stringifyBlock o, "KEY = VALUE"
		
		stringifySection "aliases", (aliases)->
			stringifyBlock aliases, "KEY:", (o)->
				stringifyBlock o, "VALUE"
		
		stringifySection "options", (options)->
			stringifyBlock options, "KEY = VALUE"
		
		sgc
