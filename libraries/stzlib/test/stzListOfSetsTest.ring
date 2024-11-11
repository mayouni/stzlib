load "../max/stzmax.ring"

o1 = new stzListOfSets([ [ "a", "b", "c" ],
			[ "a", "b", "x", "c", "z" ],
			[ "a", "t", "c", "v" ]
		      ])

? o1.Intersection()

? o1.Intersection()

o1 = new stzSet([ "a", "b", "b", "c", "c" ])
? o1.IntersectionWith([ "a", "t", "c", "v" ])
? o1.UniqueItems()



	
