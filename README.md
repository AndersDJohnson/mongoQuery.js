mongoQuery.js
=============

A multi-environment, standalone implemenation of the Mongo Query Lanaguage (http://www.mongodb.org/display/DOCS/Mongo+Query+Language and http://www.mongodb.org/display/DOCS/Advanced+Queries).

Support
=======

Supports most of query features of the query language in the 2.x release of MongoDB. See the tests and source code for specfic support. Still missing support for the following:

dot notation in specificying properties
http://www.mongodb.org/display/DOCS/Dot+Notation+(Reaching+into+Objects)

Javascript Expressions and $where
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
