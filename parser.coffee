

stringToNode = (input) -> {
	type: 'string'
	value: input
}

# splits by comma but keeps nested objects/arrays together
# deletes last element if empty (to allow trailing commas)
# returns an array of strings
splitByComma = (input) ->
	values = []
	lastIndex = 0
	index = 0
	depth = 0

	input = input.slice(1, -1)

	while(index < input.length)
		char = input.charAt(index)
		switch char
			when '{'
				depth++
			when '}'
				depth--
			when '['
				depth++
			when ']'
				depth--
		if char is ',' and depth is 0
			values.push(input.substring(lastIndex, index).trim())
			lastIndex = index + 1
		index++
	# add the last one
	if char isnt ','
		val = input.substring(lastIndex, index).trim()
		if val isnt ''
			values.push(val)	

	return values


# turns '{ key1, key2:{blah} }' into {type: 'object', value:['key1', 'key2:{blah}']}
shallowParseObjectString = (input) ->
	input = input.trim()
	# strip first and last chars

	values = splitByComma(input)

	return {
		type: 'object'
		value: values
	}

shallowParseArrayString = (input) ->
	input = input.trim()
	# strip first and last chars

	values = splitByComma(input)

	return {
		type: 'array'
		value: values
	}


deepParseArrayString = (input) ->
	node = shallowParseArrayString(input)
	for value, index in node.value
		node.value[index] = parse(value)
	return node

# returns 'object', 'array', or 'string'
determineType = (input) ->
	input = input.trim()
	if input.length is 1
		return 'string'
	firstChar = input[0]
	lastChar = input[input.length - 1]
	if firstChar is '{' and lastChar is '}'
		return 'object'
	if firstChar is '[' and lastChar is ']'
		return 'array'
	if input.indexOf(':') >= 0
		return 'pair'
	return 'string'

shallowParsePairString = (input) ->
	input = input.trim()
	index = input.indexOf(':')
	firstPart = input.substr(0, index).trim()
	secondPart = input.substr(index + 1).trim()
	return {
		type: 'pair'
		key: firstPart
		value: secondPart
	}

deepParsePairString = (input) ->
	node = shallowParsePairString(input)
	node.value = parse(node.value)
	return node

deepParseObjectString  = (input) ->
	node = shallowParseObjectString(input)
	for value, index in node.value
		node.value[index] = parse(value)
	return node

parse = (input) ->
		type = determineType(input)
		if type is 'object'
			return deepParseObjectString(input)
		if type is 'string'
			return stringToNode(input)
		if type is 'pair'
			return deepParsePairString(input)
		if type is 'array'
			return deepParseArrayString(input)

module.exports = parse
