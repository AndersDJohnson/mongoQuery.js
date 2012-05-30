(function() {
  var factory, name;
  name = "mongoQuery";
  factory = function() {
    var BSONtypeIds, exports, getBSONtypeId, matchAdvancedQuerySelector, matchPropertySelector, matchQuerySelector;
    exports = {};
    
		var TYPES = {
			'undefined'        : 'undefined',
			'number'           : 'number',
			'boolean'          : 'boolean',
			'string'           : 'string',
			'[object Function]': 'function',
			'[object RegExp]'  : 'regexp',
			'[object Array]'   : 'array',
			'[object Date]'    : 'date',
			'[object Error]'   : 'error'
		},
		TOSTRING = Object.prototype.toString;

		var typeOf = function (o) {
			return TYPES[typeof o] || TYPES[TOSTRING.call(o)] || (o ? 'object' : 'null');
		};
		;

    
		var isInt = function (n) {
			return typeof n === 'number' && n % 1 == 0;
		}
		;

    BSONtypeIds = {
      'double': 1,
      'string': 2,
      'object': 3,
      'array': 4,
      'binary': 5,
      'object_id': 7,
      'boolean': 8,
      'date': 9,
      'null': 10,
      'regular_expression': 11,
      'javascript_code': 13,
      'symbol': 14,
      'javascript_code_with_scope': 15,
      'int32': 16,
      'timestamp': 17,
      'int64': 18,
      'min_key': 255,
      'max_key': 127
    };
    exports.getBSONtypeId = getBSONtypeId = function(o) {
      var BSONtype, type;
      type = typeOf(o);
      switch (type) {
        case 'number':
          if (o % 1 === 0) {
            BSONtype = 'int32';
          } else {
            BSONtype = 'double';
          }
          break;
        case 'regexp':
          BSONtype = 'regular_expression';
          break;
        default:
          BSONtype = type;
      }
      return BSONtypeIds[BSONtype];
    };
    matchPropertySelector = function(value, prop, val, fullSelector) {
      var anyMatch, exists, item, modifiers, regexp, _i, _j, _len, _len1;
      switch (prop) {
        case '$exists':
          exists = typeOf(value) !== 'undefined';
          return (exists && val === true) || ((!exists) && (val === false));
        case '$type':
          return getBSONtypeId(value) === val;
        case '$size':
          if (value.length != null) {
            return value.length === val;
          } else {
            return false;
          }
          break;
        case '$gt':
          return value > val;
        case '$gte':
          return value >= val;
        case '$lt':
          return value < val;
        case '$lte':
          return value <= val;
        case '$ne':
          return value !== val;
        case '$mod':
          return (value % val[0]) === val[1];
        case '$all':
          for (_i = 0, _len = val.length; _i < _len; _i++) {
            item = val[_i];
            if (value.indexOf(item) === -1) {
              return false;
            }
          }
          return true;
        case '$in':
          return val.indexOf(value) !== -1;
        case '$nin':
          return val.indexOf(value) === -1;
        case '$regex':
          modifiers = fullSelector.$options;
          if (modifiers != null) {
            regexp = new RegExp(val, modifiers);
          } else {
            regexp = new RegExp(val);
          }
          return regexp.test(value);
        case '$elemMatch':
          anyMatch = false;
          for (_j = 0, _len1 = value.length; _j < _len1; _j++) {
            item = value[_j];
            anyMatch || (anyMatch = matchAdvancedQuerySelector(item, val));
          }
          return anyMatch;
        case '$not':
          return !matchAdvancedQuerySelector(value, val);
      }
      return true;
    };
    matchAdvancedQuerySelector = function(value, expr) {
      var matches, prop, val;
      if (expr === null) {
        if (!(value === null || typeof value === "undefined")) {
          return false;
        }
      } else if (typeOf(expr) === 'regexp') {
        return expr.test(value);
      } else if (typeOf(expr) === 'object') {
        matches = true;
        for (prop in expr) {
          val = expr[prop];
          matches && (matches = matchPropertySelector(value, prop, val, expr));
        }
        return matches;
      } else if (value !== expr) {
        return false;
      }
      return true;
    };
    matchQuerySelector = function(obj, query) {
      var allMatches, anyMatches, expr, matches, optionQuery, optionSelector, orMatches, prop, _i, _j, _k, _len, _len1, _len2;
      matches = true;
      for (prop in query) {
        expr = query[prop];
        switch (prop) {
          case '$or':
            orMatches = false;
            for (_i = 0, _len = expr.length; _i < _len; _i++) {
              optionSelector = expr[_i];
              optionQuery = _.clone(query);
              delete optionQuery['$or'];
              _.extend(optionQuery, optionSelector);
              orMatches || (orMatches = matchQuerySelector(obj, optionQuery));
            }
            matches && (matches = orMatches);
            break;
          case '$nor':
            anyMatches = false;
            for (_j = 0, _len1 = expr.length; _j < _len1; _j++) {
              optionSelector = expr[_j];
              optionQuery = _.clone(query);
              delete optionQuery['$nor'];
              _.extend(optionQuery, optionSelector);
              anyMatches || (anyMatches = matchQuerySelector(obj, optionQuery));
            }
            matches && (matches = !anyMatches);
            break;
          case '$and':
            allMatches = true;
            for (_k = 0, _len2 = expr.length; _k < _len2; _k++) {
              optionSelector = expr[_k];
              optionQuery = _.clone(query);
              delete optionQuery['$and'];
              _.extend(optionQuery, optionSelector);
              allMatches && (allMatches = matchQuerySelector(obj, optionQuery));
            }
            matches && (matches = allMatches);
            break;
          default:
            matches && (matches = matchAdvancedQuerySelector(obj[prop], expr));
        }
      }
      return matches;
    };
    exports.find = function(data, queryObject) {
      var item, query, result, _i, _len;
      query = queryObject.$query;
      if (query === null) {
        return data;
      }
      result = [];
      for (_i = 0, _len = data.length; _i < _len; _i++) {
        item = data[_i];
        if (matchQuerySelector(item, query)) {
          result.push(item);
        }
      }
      return result;
    };
    return exports;
  };
  return window[name] = factory();
})();
