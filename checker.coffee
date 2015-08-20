
parser = require './parser.coffee'

validateObject = (map, node) ->
	keys = node.value
	for key in keys
		if key.type is 'string'
			# check if map has this key
			if map[key.value] is undefined
				return false
		else if key.type is 'pair'
			# check if map has this key
			if map[key.key] is undefined
				return false
			# check value of pair is a string, check the type of the map's value
			if key.value.type is 'string'
				return typeof map[key.key] is key.value.value

			# check if value of this key is valid
			if validate(map[key.key], key.value) isnt true
				return false
	return true
	

validateArray = (array, node) ->
	nodeValues = node.value
	if nodeValues.length is 0
		return true
	else if nodeValues.length is 1
		# check if every element of the array matches the node
		for element in array
			if validate(element, nodeValues[0]) isnt true
				return false
		return true
	else
		# in this case (nodeValues.length > 1), the array must exactly match nodeValues
		if array.length isnt nodeValues.length
			return false
		for element, index in array
			if validate(element, nodeValues[index]) isnt true
				return false
		return true
		

isObject = (input) -> (input instanceof Object and !(input instanceof Array))
isArray = (input) -> (input instanceof Array)

validate = (input, node) ->
	if node.type is 'object' and isObject(input)
		return validateObject(input, node)
	else if node.type is 'array' and isArray(input)
		return validateArray(input, node)
	else
		return false

module.exports = (input, query) ->
	validate(input, parser(query))
