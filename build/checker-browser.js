(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);throw new Error("Cannot find module '"+o+"'")}var f=n[o]={exports:{}};t[o][0].call(f.exports,function(e){var n=t[o][1][e];return s(n?n:e)},f,f.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
var isArray, isObject, parser, stack, validate, validateArray, validateObject, validateType;

parser = require('./parser');

stack = [];

validateObject = function(map, node) {
  var child, childNodes, i, len;
  childNodes = node.value;
  for (i = 0, len = childNodes.length; i < len; i++) {
    child = childNodes[i];
    if (child.type === 'string') {
      stack.push(child.value);
      if (map[child.value] === void 0) {
        return false;
      } else {
        stack.pop();
      }
    } else if (child.type === 'pair') {
      stack.push(child.key);
      if (map[child.key] === void 0) {
        return false;
      } else {
        stack.pop();
      }
      stack.push(child.key);
      if (validate(map[child.key], child.value) !== true) {
        return false;
      } else {
        stack.pop();
      }
    }
  }
  return true;
};

validateArray = function(array, node) {
  var children, element, i, index, j, len, len1;
  children = node.value;
  if (children.length === 0) {
    return true;
  } else if (children.length === 1) {
    for (index = i = 0, len = array.length; i < len; index = ++i) {
      element = array[index];
      stack.push(index);
      if (validate(element, children[0]) !== true) {
        return false;
      } else {
        stack.pop();
      }
    }
    return true;
  } else {
    if (array.length !== children.length) {
      return false;
    }
    for (index = j = 0, len1 = array.length; j < len1; index = ++j) {
      element = array[index];
      stack.push(index);
      if (validate(element, children[index]) !== true) {
        return false;
      } else {
        stack.pop();
      }
    }
    return true;
  }
};

validateType = function(input, node) {
  return typeof input === node.value;
};

isObject = function(input) {
  return input instanceof Object && !(input instanceof Array);
};

isArray = function(input) {
  return input instanceof Array;
};

validate = function(input, node) {
  if (node.type === 'object' && isObject(input)) {
    return validateObject(input, node);
  } else if (node.type === 'array' && isArray(input)) {
    return validateArray(input, node);
  } else if (node.type === 'string') {
    return validateType(input, node);
  } else {
    return false;
  }
};

module.exports = function(query, input) {
  stack = [];
  if (input && query) {
    return {
      isValid: validate(input, parser(query)),
      stack: stack
    };
  } else if (query) {
    return function(input) {
      return {
        isValid: validate(input, parser(query)),
        stack: stack
      };
    };
  }
};



},{"./parser":2}],2:[function(require,module,exports){
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



},{}]},{},[1])