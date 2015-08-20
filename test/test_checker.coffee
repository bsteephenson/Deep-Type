
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
		output = checker(val, '{ key: {inner: [ {innerInnerKey: string, anotherKey} ]} }')

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
		output = checker(val, '{ key: {inner: [ {innerInnerKey: string} ]} }')

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
		output = checker(val, '{ key: {inner: [ {innerInnerKey: string} ]} }')

		expect(output.isValid).to.equal(false)
		expect(output.stack).to.deep.equal(['key', 'inner', 1, 'innerInnerKey'])
