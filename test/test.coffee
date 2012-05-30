do () ->
	console.log mongoQuery
	
	mocha.setup('bdd')
	
	describe 'BSON', ->
		describe 'Types', ->
			it 'integer', ->
				expect(mongoQuery.getBSONtypeId(2)).to.be(16)
			it 'double', ->
				expect(mongoQuery.getBSONtypeId(2.1)).to.be(1)
			it 'string', ->
				expect(mongoQuery.getBSONtypeId('')).to.be(2)
			it 'array', ->
				expect(mongoQuery.getBSONtypeId([])).to.be(4)
			it 'object', ->
				expect(mongoQuery.getBSONtypeId({})).to.be(3)
			it 'boolean', ->
				expect(mongoQuery.getBSONtypeId(true)).to.be(8)
				expect(mongoQuery.getBSONtypeId(false)).to.be(8)
			it 'date', ->
				expect(mongoQuery.getBSONtypeId(new Date())).to.be(9)
			it 'null', ->
				expect(mongoQuery.getBSONtypeId(null)).to.be(10)
			it 'regexp', ->
				expect(mongoQuery.getBSONtypeId(new RegExp())).to.be(11)
		
	
	describe 'Querying', ->
		
		describe 'find()', ->
			
			it 'empty query returns all', ->
				data = [{x:3, y:4}, {x:1}, {x:5, w:6}]
				results = mongoQuery.find data, {
					$query: {}
				}
				expect(results).to.eql(data)
			
			it 'null query returns all', ->
				data = [{x:3, y:4}, {x:1}, {x:5, w:6}]
				results = mongoQuery.find data, {
					$query: null
				}
				expect(results).to.eql(data)
			
			it 'unused value returns empty results', ->
				data = [{x:3, y:4}, {x:1}, {x:5, w:6}]
				results = mongoQuery.find data, {
					$query: {x:7}
				}
				expect(results).to.eql([])
			
			it 'by not having property', ->
				data = [{x:3, y:4}, {x:1}, {x:5, w:6}]
				results = mongoQuery.find data, {
					$query: {y: null}
				}
				expect(results).to.eql([{x:1}, {x:5, w:6}])
			
			it 'including properties with null value', ->
				data = [{x:3, y:null}, {x:1}, {x:5, w:6}]
				results = mongoQuery.find data, {
					$query: {y: null}
				}
				expect(results).to.eql(data)
			
			it 'by value', ->
				data = [{x:3, y:4}, {x:1}, {x:5, w:6}]
				results = mongoQuery.find data, {
					$query: {x:1}
				}
				expect(results).to.eql([{x:1}])
			
			it 'by size', ->
				data = [{x:[1,2,3]},{x:[2,3], w:6},{x:[1], b:[7,8]},{x:[]},{x:2},{x:[3,2]}]
				results = mongoQuery.find data, {
					$query: {x:{$size:2}}
				}
				expect(results).to.eql([{x:[2,3], w:6},{x:[3,2]}])
			
			describe 'by  regular expression', ->
				data = [{s:"hey"}, {s:"why"}, {s:"rooster"}, {s:4}, {s: null}]
				it 'by RegExp object as value', ->
					results = mongoQuery.find data, {
						$query: {s:/.*h.?y.*/}
					}
					expect(results).to.eql([{s:"hey"}, {s:"why"}])
					
				it 'by advanced $regex query (without $options)', ->
					results = mongoQuery.find data, {
						$query: {s: {$regex: '.*h.?y.*'}}
					}
					expect(results).to.eql([{s:"hey"}, {s:"why"}])
				
				it 'by advanced $regex query (with $options)', ->
					data = [{s:"HEy"}, {s:"whY"}, {s:"rooster"}, {s:4}, {s: null}]
					results = mongoQuery.find data, {
						$query: {s: {$regex: '.*h.?y.*', $options: 'i'}}
					}
					expect(results).to.eql([{s:"HEy"}, {s:"whY"}])
			
			describe 'by value\'s type', ->
			
				it 'integer', ->
					data = [{x:3, y:4}, {x:1}, {x:'foo', w:6}]
					results = mongoQuery.find data, {
						$query: {x: {$type: 16}} # int
					}
					expect(results).to.eql([{x:3, y:4}, {x:1}])
			
				it 'double', ->
					data = [{x:3.1, y:4}, {x:1}, {x:3.0, w:6}]
					results = mongoQuery.find data, {
						$query: {x: {$type: 1}} # double
					}
					expect(results).to.eql([{x:3.1, y:4}])
				
				it 'string', ->
					data = [{x:3, y:4}, {x:1}, {x:'foo', w:6}]
					results = mongoQuery.find data, {
						$query: {x: {$type: 2}} # string
					}
					expect(results).to.eql([{x:'foo', w:6}])
				
				it 'array', ->
					data = [{x:[], y:4}, {x:[]}, {x:'foo', w:6}]
					results = mongoQuery.find data, {
						$query: {x: {$type: 4}} # array
					}
					expect(results).to.eql([{x:[], y:4}, {x:[]}])
				
				it 'object', ->
					data = [{x:{}, y:4}, {x:[]}, {x: new Date()}, {x:{}, w:6}]
					results = mongoQuery.find data, {
						$query: {x: {$type: 3}} # object
					}
					expect(results).to.eql([{x:{}, y:4}, {x:{}, w:6}])
				
				it 'boolean', ->
					data = [{x:true, y:4}, {x:1}, {x:null}, {x:0}, {x:false, w:6}]
					results = mongoQuery.find data, {
						$query: {x: {$type: 8}} # boolean
					}
					expect(results).to.eql([{x:true, y:4}, {x:false, w:6}])
				
				it 'date', ->
					date = new Date()
					data = [{x:{}, y:4}, {x: date}, {x:{}, w:6}]
					results = mongoQuery.find data, {
						$query: {x: {$type: 9}} # date
					}
					expect(results).to.eql([{x: date}])
			
			describe 'by existence', ->
				
				it 'exists', ->
					data = [{x:3, y:4}, {x:1}, {x:5, w:6}]
					results = mongoQuery.find data, {
						$query: {w: {$exists: true}}
					}
					expect(results).to.eql([{x:5, w:6}])
			
				it 'doesn\'t exist', ->
					data = [{x:3, y:4}, {x:1}, {x:5, y:6}]
					results = mongoQuery.find data, {
						$query: {y: {$exists: false}}
					}
					expect(results).to.eql([{x:1}])
			
			describe 'by comparison', ->
				data = [{x:3, y:4}, {x:1}, {x:5, y:6}]
				
				it 'greater than', ->
					results = mongoQuery.find data, {
						$query: {x: {$gt: 1}}
					}
					expect(results).to.eql([{x:3, y:4}, {x:5, y:6}])
				
				it 'greater than or equal', ->
					results = mongoQuery.find data, {
						$query: {x: {$gte: 3}}
					}
					expect(results).to.eql([{x:3, y:4}, {x:5, y:6}])
				
				it 'less than', ->
					results = mongoQuery.find data, {
						$query: {x: {$lt: 3}}
					}
					expect(results).to.eql([{x:1}])
				
				it 'less than or equal', ->
					results = mongoQuery.find data, {
						$query: {x: {$lte: 3}}
					}
					expect(results).to.eql([{x:3, y:4}, {x:1}])
			
			describe 'by array contents', ->
				
				it 'all', ->
					data = [{x:[1,2,3]},{x:[2,3]}]
					results = mongoQuery.find data, {
						$query: {x: {$all: [1,2,3]}}
					}
					expect(results).to.eql([{x:[1,2,3]}])
					
					results = mongoQuery.find data, {
						$query: {x: {$all: [2,3]}}
					}
					expect(results).to.eql(data)
					
					results = mongoQuery.find data, {
						$query: {x: {$all: [1,4]}}
					}
					expect(results).to.eql([])
				
				it 'in', ->
					data = [{x:2},{x:1},{x:3},{x:3}]
					results = mongoQuery.find data, {
						$query: {x: {$in: [3]}}
					}
					expect(results).to.eql([{x:3},{x:3}])
					
					results = mongoQuery.find data, {
						$query: {x: {$in: [1,2]}}
					}
					expect(results).to.eql([{x:2},{x:1}])
				
				it 'not in', ->
					data = [{x:2},{x:1},{x:3},{x:3}]
					results = mongoQuery.find data, {
						$query: {x: {$nin: [2,1]}}
					}
					expect(results).to.eql([{x:3},{x:3}])
					
					results = mongoQuery.find data, {
						$query: {x: {$nin: [3]}}
					}
					expect(results).to.eql([{x:2},{x:1}])
				
			it 'not equals', ->
				data = [{x:3},{x:2,w:5},{x:2}]
				results = mongoQuery.find data, {
					$query: {x: {$ne: 3}}
				}
				expect(results).to.eql([{x:2,w:5},{x:2}])
				
				results = mongoQuery.find data, {
					$query: {x: {$ne: 2}}
				}
				expect(results).to.eql([{x:3}])
				
				results = mongoQuery.find data, {
					$query: {x: {$ne: 9}}
				}
				expect(results).to.eql(data)
			
			it 'modulus', ->
				data = [{x:3},{x:6,w:5},{x:4},{x:-3},{x:-2},{x:0}]
				results = mongoQuery.find data, {
					$query: {x: {$mod: [3, 0]}}
				}
				expect(results).to.eql(
					[{x:3},{x:6,w:5},{x:-3},{x:0}]
				)
				results = mongoQuery.find data, {
					$query: {x: {$mod: [4, 2]}}
				}
				expect(results).to.eql(
					[{x:6,w:5}]
				)
			
			describe 'with or, nor, and', ->
				data = [{x:3,w:5},{x:6,w:5},{x:4},{y:-3},{x:-2},{y:0}]
				
				it 'or', ->
					results = mongoQuery.find data, {
						$query: {$or: [ {x:-2}, {y:-3} ]}
					}
					expect(results).to.have.length(2)
					r0Y = results[0].y?
					r0X = results[1].x?
					r1Y = results[0].y?
					r1X = results[1].x?
					expect((r0Y and r1X) or (r0X and r1Y)).to.be.ok()
					expect(
						(r0Y and results[0].y is -3 and r1X and results[1].x is -2) or (r0X and results[0].x is -2 and r1Y and results[1].y is -3)
					).to.be.ok()
				
				it 'nested or', ->
					results = mongoQuery.find data, {
						$query: {$or: [ $or:[{x:-2},{m:47}], {y:-3} ]}
					}
					expect(results).to.have.length(2)
					r0Y = results[0].y?
					r0X = results[1].x?
					r1Y = results[0].y?
					r1X = results[1].x?
					expect((r0Y and r1X) or (r0X and r1Y)).to.be.ok()
				
				it 'nor', ->
					results = mongoQuery.find data, {
						$query: {$nor: [ {x:6,w:5}, {y:-3}, {x:-2} ]}
					}
					expect(results).to.have.length(3)
					expect(results).to.eql([{x:3,w:5},{x:4},{y:0}])
				
				it 'and', ->
					results = mongoQuery.find data, {
						$query: {$and: [ {x:6}, {w:5} ]}
					}
					expect(results).to.eql([{x:6,w:5}])
			
			it '$not meta operator', ->
				data = [{x:3},{x:2,w:5},{x:2}]
				results = mongoQuery.find data, {
					$query: {x: {$not: 2}}
				}
				expect(results).to.eql([{x:3}])
			
			it '$elemMatch operator', ->
				x = {x:[{y:3},{y:6,x:7},{w:'hi'}]}
				y = {x:[{y:6},{w:7}]}
				data = [x, y, {x:7}]
				results = mongoQuery.find data, {
					$query: {x: {$elemMatch: {y:6}}}
				}
				expect(results).to.eql([x,y])
			
			it 'dot notation'#, ->
			
			it '$where operator / JavaScript expressions'#, ->
			
	
	onload = ->
		runner = mocha.run();
		#runner.globals(['foo', 'bar', 'baz']);
		#runner.on('test end', (test) ->
		#	console.log(test.fullTitle());
	
	onload()
