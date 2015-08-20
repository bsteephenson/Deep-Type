
checker = require '../checker.coffee'

{expect} = require 'chai'


describe 'checker', () ->
	it 'should work on nested objects', () ->
		val = {
			key: {
				inner: () -> null
				anotherInner: 42
			}
		}
		isValid = checker(val, '{ key: { inner: function, anotherInner: number  } }')

		expect(isValid).to.equal(true)

	it 'should work with arrays and stuff', () ->
		val = [
			{
				someKey: 'someval'
			}
			{
				someKey: 'nuther val'
			}
		]

		isValid = checker(val, '[ {someKey} ]')
		expect(isValid).to.equal(true)