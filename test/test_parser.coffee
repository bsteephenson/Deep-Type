
{expect} = require 'chai'

parser = require '../parser.coffee'


describe 'Parser', () ->

	it 'should parse { key1: { nestedKey } , key2 }', () ->
		val = parser('{ key1: { nestedKey }, key2 }')
		expect(val).to.deep.equal {
			type: 'object'
			value: [
				{
					type: 'pair'
					key: 'key1'
					value: {
						type: 'object'
						value: [
							{
								type: 'string'
								value: 'nestedKey'
							}
						]
					}
				},
				{
					type: 'string'
					value: 'key2'
				}
			]
		}



	it 'should parse { key1: [ ], key2 }', () ->
		val = parser('{ key1: [ ], key2 }')
		expect(val).to.deep.equal {
			type: 'object'
			value: [
				{
					type: 'pair'
					key: 'key1'
					value: {
						type: 'array'
						value: []
					}
				},
				{
					type: 'string'
					value: 'key2'
				}
			]
		}

	it 'should parse [ { key1 }, { key2 } ]', () ->
		val = parser('[ { key1 }, { key2 } ]')
		expect(val).to.deep.equal {
			type: 'array'
			value: [
				{
					type: 'object'
					value: [
						{
							type: 'string'
							value: 'key1'
						}
					]
				},
				{
					type: 'object'
					value: [
						{
							type: 'string'
							value: 'key2'
						}
					]
				}
			]
		}
	it 'should parse [ { key1, nuther }, { key2 } ]', () ->
		val = parser('[ { key1, nuther }, { key2 } ]')
		expect(val).to.deep.equal {
			type: 'array'
			value: [
				{
					type: 'object'
					value: [
						{
							type: 'string'
							value: 'key1'
						}
						{
							type: 'string'
							value: 'nuther'
						}
					]
				},
				{
					type: 'object'
					value: [
						{
							type: 'string'
							value: 'key2'
						}
					]
				}
			]
		}

