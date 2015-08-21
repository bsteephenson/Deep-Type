# JS GraphQL-ish Type Checker

Use a GraphQL-esque syntax to validate Javascript objects and arrays. Also tells you where you messed up.

## Examples

```
checker = require './checker.coffee'

objectToValidate = {
	key1: {
		innerKey: 'value'
	}
}

checker('{key1: {innerKey}}', objectToValidate)
=> {isValid: true, stack: []}

checker('{key1: {innerKey: number}}', objectToValidate)
=> {isValid: false, stack: ['key1', 'innerKey']}

arrayToValidate = [
	{
		someKey: 'val'
		another: 'val'
	}
	{
		someKey: 'val'
	}
]

checker('[ {someKey, another} ]', objectToValidate)
=> {isValid: false, stack: [0, 'another']}

```

## Usage

checker(query, objectOrArrayToValidate) returns an object that looks like
	{
		isValid: true of false
		stack: a list of keys/indices
	}

Say the part that failed was object[0]['key']['innerKey'], then stack would be [0, 'key', 'innerKey']

If you only provide the query, you get back a partially applied function.

query = checker('{key}')
query({'key': 'value'})
=> { isValid: true, stack: [ ] }

## Writing Queries

```

someType => the input is of type 'someType'

{} => the input is an object

{key1, key2, key3} => the input has the following keys: key1, key2, key3

{key1, key2:{innerKey}} => input['key2'] has the following keys: innerKey

{ firstKey: string } => input['firstKey'] is a string

[] => the input is an arrays

[ innerQuery ] => each of the array's elements matches the innerQuery

[ firstQuery, secondQuery ] => the array has exactly two elements. the first element matches firstQuery. the second element matches secondQuery

[ {someKey} ] => each element of the array is an object that has the key 'someKey'

[ string, number ] => the first element of the array is a string. the second element is a number

```


