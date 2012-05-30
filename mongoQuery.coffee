do () ->
	name = "mongoQuery"
	
	# http://www.mongodb.org/display/DOCS/Mongo+Query+Language
	# http://api.mongodb.org/js/1.9.0/symbols/src/shell_collection.js.html
	
	factory = ->
		exports = {}
		
		`
		var TYPES = {
			'undefined'        : 'undefined',
			'number'           : 'number',
			'boolean'          : 'boolean',
			'string'           : 'string',
			'[object Function]': 'function',
			'[object RegExp]'  : 'regexp',
			'[object Array]'   : 'array',
			'[object Date]'    : 'date',
			'[object Error]'   : 'error'
		},
		TOSTRING = Object.prototype.toString;

		var typeOf = function (o) {
			return TYPES[typeof o] || TYPES[TOSTRING.call(o)] || (o ? 'object' : 'null');
		};
		`
		`
		var isInt = function (n) {
			return typeof n === 'number' && n % 1 == 0;
		}
		`
		
		BSONtypeIds =
			'double': 1
			'string': 2
			'object': 3
			'array': 4
			'binary': 5
			'object_id': 7
			'boolean': 8
			'date': 9
			'null': 10
			'regular_expression': 11
			'javascript_code': 13
			'symbol': 14
			'javascript_code_with_scope': 15
			'int32': 16
			'timestamp': 17
			'int64': 18
			'min_key': 255
			'max_key': 127
		
		exports.getBSONtypeId = getBSONtypeId = (o) ->
			type = typeOf(o)
			switch type
				when 'number'
					if o % 1 is 0
						BSONtype = 'int32'
					else
						BSONtype = 'double'
				when 'regexp'
					BSONtype = 'regular_expression'
				else
					BSONtype = type
			return BSONtypeIds[BSONtype]
		
		
		matchPropertySelector = (value, prop, val, fullSelector) ->
			switch prop
				when '$exists'
					exists = typeOf(value) isnt 'undefined'
					return (exists && val is true) || (((!exists) && (val is false)))
				when '$type'
					return getBSONtypeId(value) is val
				when '$size'
					if value.length?
						return value.length is val
					else
						return false
				when '$gt' then return value > val
				when '$gte' then return value >= val
				when '$lt' then return value < val
				when '$lte' then return value <= val
				when '$ne'
					return value isnt val
				when '$mod'
					#divisor = val[0]
					#remainder = val[1]
					return (value % val[0]) is val[1]
				when '$all'
					for item in val
						return false if value.indexOf(item) is -1
					return true
				when '$in'
					return val.indexOf(value) isnt -1
				when '$nin'
					return val.indexOf(value) is -1
				when '$regex'
					modifiers = fullSelector.$options
					if modifiers?
						# RegExp modifier cavaets:
						# Unlike mongod, in this implementation:
						#	-	's' (dot matches all) is not supported
						#	-	'g' (global) is not ignored
						regexp = new RegExp(val, modifiers)
					else
						regexp = new RegExp(val)
					return regexp.test(value)
				when '$elemMatch'
					anyMatch = false
					for item in value
						anyMatch ||= matchAdvancedQuerySelector(item, val)
					return anyMatch
				when '$not'
					return not matchAdvancedQuerySelector(value, val)
				
			
			return true
		
		matchAdvancedQuerySelector = (value, expr) ->
			if expr is null
				unless value is null or typeof value is "undefined"
					return false
			else if typeOf(expr) is 'regexp'
				return expr.test(value)
			else if typeOf(expr) is 'object'
				matches = true
				for prop, val of expr
					matches &&= matchPropertySelector(value, prop, val, expr)
				return matches
			else unless value is expr
				return false
			return true
		
		matchQuerySelector = (obj, query) ->
			matches = true
			for prop, expr of query
				switch prop
					 # the "$or" meta-query
					when '$or'
						orMatches = false
						# recurse, each option replacing the "$or"
						for optionSelector in expr
							optionQuery = _.clone(query)
							delete optionQuery['$or']
							_.extend(optionQuery, optionSelector)
							orMatches ||= matchQuerySelector(obj, optionQuery)
						matches &&= orMatches
					 # the "$nor" meta-query
					when '$nor'
						anyMatches = false
						# recurse, each option replacing the "$nor"
						for optionSelector in expr
							optionQuery = _.clone(query)
							delete optionQuery['$nor']
							_.extend(optionQuery, optionSelector)
							anyMatches ||= matchQuerySelector(obj, optionQuery)
						matches &&= not anyMatches
					 # the "$and" meta-query
					when '$and'
						allMatches = true
						# recurse, each option replacing the "$and"
						for optionSelector in expr
							optionQuery = _.clone(query)
							delete optionQuery['$and']
							_.extend(optionQuery, optionSelector)
							allMatches &&= matchQuerySelector(obj, optionQuery)
						matches &&= allMatches
					else
						matches &&= matchAdvancedQuerySelector(obj[prop], expr)
			return matches
		
		exports.find = (data, queryObject) ->
			query = queryObject.$query
			return data if query is null 
			result = []
			for item in data
				result.push(item) if matchQuerySelector(item, query)
			return result
		
		return exports
	
	window[name] = factory()
