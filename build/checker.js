(function() {
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

}).call(this);
