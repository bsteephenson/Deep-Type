
checker = require '../checker.coffee'

{expect} = require 'chai'


describe 'checker', () ->
	it 'should work on nested objects and arrays', () ->
		val = {
			key: {
				inner: [
					{
						innerInnerKey: ''
						anotherKey: 42
					}
				]
			}
		}
		output = checker('{ key: {inner: [ {innerInnerKey: string, anotherKey} ]} }', val)

		expect(output.isValid).to.equal(true)

	it 'should show stack when there is a missing key (halts at the first error)', () ->
		val = {
			key: {
				inner: [
					{
						keyThatShouldFail: ''
					}
				]
			}
		} 
		output = checker('{ key: {inner: [ {innerInnerKey: string} ]} }', val)

		expect(output.isValid).to.equal(false)
		expect(output.stack).to.deep.equal(['key', 'inner', 0, 'innerInnerKey'])

	it 'should show stack when there is an incorrect type (halts at the first error)', () ->
		val = {
			key: {
				inner: [
					{
						innerInnerKey: 'good key'
					}
					{
						innerInnerKey: 42
					}

				]
			}
		}
		output = checker('{ key: {inner: [ {innerInnerKey: string} ]} }', val)

		expect(output.isValid).to.equal(false)
		expect(output.stack).to.deep.equal(['key', 'inner', 1, 'innerInnerKey'])

	it 'should work with an array of types', () ->
		output = checker('[ string ]', ['element'])
		expect(output.isValid).to.equal(true)

		output = checker('[ string ]', ['element', 42])
		expect(output.isValid).to.equal(false)
		expect(output.stack).to.deep.equal([1])

	it 'should return a function if only the query is given', () ->
		query = checker('{key}')
		expect(query instanceof Function).to.equal(true)
		expect(query({key: 'value'}).isValid).to.equal(true)
