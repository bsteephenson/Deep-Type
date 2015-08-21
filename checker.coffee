
parser = require './parser.coffee'

stack = []

validateObject = (map, node) ->
	childNodes = node.value
	for child in childNodes
		if child.type is 'string'
			
			# check if map has this child
			stack.push(child.key)
			if map[child.value] is undefined
				return false
			else
				stack.pop()

		else if child.type is 'pair'
			
			# check if map has this child
			stack.push(child.key)
			if map[child.key] is undefined
				return false
			else stack.pop()
						
			# check if value of this key is valid
			stack.push(child.key)
			if validate(map[child.key], child.value) isnt true
				return false
			else
				stack.pop()
	return true
	

validateArray = (array, node) ->
	children = node.value

	if children.length is 0
		return true

	else if children.length is 1	
		# check if every element of the array matches the node
		for element, index in array
			stack.push(index)
			if validate(element, children[0]) isnt true
				return false
			else
				stack.pop()

		return true
	
	else	
		# in this case (children.length > 1), the array must exactly match children
		if array.length isnt children.length
			return false
		for element, index in array
			stack.push(index)
			if validate(element, children[index]) isnt true
				return false
			else
				stack.pop()

		return true
	
validateType = (input, node) ->
	return typeof input is node.value

isObject = (input) -> (input instanceof Object and !(input instanceof Array))
isArray = (input) -> (input instanceof Array)

validate = (input, node) ->
	if node.type is 'object' and isObject(input)
		return validateObject(input, node)
	else if node.type is 'array' and isArray(input)
		return validateArray(input, node)
	else if node.type is 'string'
		return validateType(input, node)
	else
		return false

module.exports = (query, input) ->
	stack = []

	if input && query
		return  {
			isValid: validate(input, parser(query))
			stack: stack
		}		
	else if query
		return (input) ->
			return  {
				isValid: validate(input, parser(query))
				stack: stack
			}	