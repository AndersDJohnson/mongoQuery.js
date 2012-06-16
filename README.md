mongoQuery.js
=============

http://adjohnson916.github.com/mongoQuery.js/

A multi-environment, standalone implemenation of the Mongo Query Lanaguage (http://www.mongodb.org/display/DOCS/Mongo+Query+Language and http://www.mongodb.org/display/DOCS/Advanced+Queries).

Support
=======

Supports most of query features of the query language in the 2.x release of MongoDB. See the tests and source code for specfic support. Still missing support for the following:

dot notation in specificying properties
http://www.mongodb.org/display/DOCS/Dot+Notation+(Reaching+into+Objects)

JavaScript Expressions and $where
http://www.mongodb.org/display/DOCS/Advanced+Queries#AdvancedQueries-JavascriptExpressionsand%7B%7B%24where%7D%7D

Meta query operators:
	$returnKey
	$maxScan
	$orderby
	$explain
	$snapshot
	$min and $max
	$showDiskLoc
	$hint
	$comment
http://www.mongodb.org/display/DOCS/Advanced+Queries#AdvancedQueries-Metaqueryoperators

Dependencies
============
Underscore.js (http://underscorejs.org/)

Tests depend on:
Mocha (http://visionmedia.github.com/mocha/)
Expect.js (https://github.com/LearnBoost/expect.js)

To Do
=====
* Add support for dot notation in property specifiers
* Add support for JavaScript Expressions
* Add support for $where modifier
* Implement update modifiers (presently, it's not CRUD but just R):
    * $inc
    * $set
    * $unset
    * $push
    * $pushAll
    * $addToSet and $each
    * $pop
    * $pull
    * $pullAll
    * $rename
    * $bit
* Implement localStorage as a store / persistence option
* Add functionality to push queries to server over:
    * AJAX
    * WebSockets

License
=======

MIT/X11

Copyright (C) 2012 Anders D. Johnson <adjohnson916@gmail.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
