load "stzlib.ring"


obj = new Person { name = "sun" }

o1 = new stzList( [ "b", "a", "c", [ 1, 2 ], obj, "c", "d", "b", "c", 7, 7, [ 1, 2 ] ] )

? o1.FindAllOccurrences("a")	# --> [ 2 ]
? o1.FindAllOccurrences("b")	# --> [ 1, 8 ]
? o1.FindAllOccurrences("c")	# --> [ 3, 6, 9 ]

? o1.FindAllOccurrences(7)	# --> [ 10, 11 ]

? o1.FindAllOccurrences([1,2])	# --> [ 4, 12 ]
? o1.FindAllOccurrences(obj)	# --> [ 4, 12 ]

class Person name

/*
obj = new Person { name = "sun" }
? find( [ "b", "a", [ 1, 2 ], obj, "c", "d", "a" ], "c" )

class Person name
/*
'[ "A", "T", [ :hi, [ "deep1", [] ], :bye ], 5, obj1, "C", "A", obj2, "A", 2 ]'

 1...........2......9..........31.3.......1..................................6
 ----------1---------2---------3---------4---------5---------6---------7------

