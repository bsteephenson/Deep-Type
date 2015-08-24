(function() {
  var deepParseArrayString, deepParseObjectString, deepParsePairString, determineType, parse, shallowParseArrayString, shallowParseObjectString, shallowParsePairString, splitByComma, stringToNode;

  stringToNode = function(input) {
    return {
      type: 'string',
      value: input
    };
  };

  splitByComma = function(input) {
    var char, depth, index, lastIndex, val, values;
    values = [];
    lastIndex = 0;
    index = 0;
    depth = 0;
    input = input.slice(1, -1);
    while (index < input.length) {
      char = input.charAt(index);
      switch (char) {
        case '{':
          depth++;
          break;
        case '}':
          depth--;
          break;
        case '[':
          depth++;
          break;
        case ']':
          depth--;
      }
      if (char === ',' && depth === 0) {
        values.push(input.substring(lastIndex, index).trim());
        lastIndex = index + 1;
      }
      index++;
    }
    if (char !== ',') {
      val = input.substring(lastIndex, index).trim();
      if (val !== '') {
        values.push(val);
      }
    }
    return values;
  };

  shallowParseObjectString = function(input) {
    var values;
    input = input.trim();
    values = splitByComma(input);
    return {
      type: 'object',
      value: values
    };
  };

  shallowParseArrayString = function(input) {
    var values;
    input = input.trim();
    values = splitByComma(input);
    return {
      type: 'array',
      value: values
    };
  };

  deepParseArrayString = function(input) {
    var i, index, len, node, ref, value;
    node = shallowParseArrayString(input);
    ref = node.value;
    for (index = i = 0, len = ref.length; i < len; index = ++i) {
      value = ref[index];
      node.value[index] = parse(value);
    }
    return node;
  };

  determineType = function(input) {
    var firstChar, lastChar;
    input = input.trim();
    if (input.length === 1) {
      return 'string';
    }
    firstChar = input[0];
    lastChar = input[input.length - 1];
    if (firstChar === '{' && lastChar === '}') {
      return 'object';
    }
    if (firstChar === '[' && lastChar === ']') {
      return 'array';
    }
    if (input.indexOf(':') >= 0) {
      return 'pair';
    }
    return 'string';
  };

  shallowParsePairString = function(input) {
    var firstPart, index, secondPart;
    input = input.trim();
    index = input.indexOf(':');
    firstPart = input.substr(0, index).trim();
    secondPart = input.substr(index + 1).trim();
    return {
      type: 'pair',
      key: firstPart,
      value: secondPart
    };
  };

  deepParsePairString = function(input) {
    var node;
    node = shallowParsePairString(input);
    node.value = parse(node.value);
    return node;
  };

  deepParseObjectString = function(input) {
    var i, index, len, node, ref, value;
    node = shallowParseObjectString(input);
    ref = node.value;
    for (index = i = 0, len = ref.length; i < len; index = ++i) {
      value = ref[index];
      node.value[index] = parse(value);
    }
    return node;
  };

  parse = function(input) {
    var type;
    type = determineType(input);
    if (type === 'object') {
      return deepParseObjectString(input);
    }
    if (type === 'string') {
      return stringToNode(input);
    }
    if (type === 'pair') {
      return deepParsePairString(input);
    }
    if (type === 'array') {
      return deepParseArrayString(input);
    }
  };

  module.exports = parse;

}).call(this);
