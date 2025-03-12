load "../max/stzmax.ring"

/*=====

profon()

o1 = new stzString("rixxnxg")  

? o1.RemoveQ("x").  
     ReplaceQ("i", :With = AHeart()).
     UppercaseQ().
     Spacified()

#--> R ♥ N G  

# The original object remains intact  
? o1.Content()  
#--> "R♥NG"

proff()
# Executed in 0.01 second(s) in Ring 1.22

/*-----

profon()

o1 = new stzString("rixxnxg")

? o1.RemoveQC("x").
     ReplaceQ("i", :With = AHeart()).
     UppercaseQ().
     Spacified()

#--> R ♥ N G

# The original object remains intact
? o1.Content()
#--> "rixxnxg"

proff()
# Executed in 0.01 second(s) in Ring 1.22

/*=====

profon()

o1 = new stzList([
	"item1",

	[ "item21", [ "item221", "item222" ], "item22" ],
	[ "item31", [ "item321", "item322" ] ],

	"item4"
])


? @@Q([
	"item1",

	[ "item21", ["item221", "item222"], "item22" ],
	[ "item31", ["item321", "item322" ] ],

	"item4"
])
.AllRemovedExcept([ "[", ",", "]" ]) + NL
#--> [,[,[,],],[,[,]],]

? @@NL( GeneratePaths("[,[,[,],],[,[,]],]") )
#--> [
#	[ 1 ],
#	[ 2 ],
#	[ 2, 1 ],
#	[ 2, 2 ],
#	[ 2, 2, 1 ],
#	[ 2, 2, 2 ],
#	[ 2, 3 ],
#	[ 3 ],
#	[ 3, 1 ],
#	[ 3, 2 ],
#	[ 3, 2, 1 ],
#	[ 3, 2, 2 ],
#	[ 4 ]
# ]

proff()
# Executed in almost 0.09 second(s) in Ring 1.22

/*============

profon()

? RingVersion()
#--> "1.22"

? StzVersion()
#--> "0.9"

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*------

profon()

o1 = new stzList([
	[ 1 ],
	[ 2 ],
	[ 2, 1 ],
	[ 2, 2 ],
	[ 2, 2, 1 ],
	[ 2, 2, 2 ],
	[ 2, 3 ],
	[ 3 ],
	[ 3, 1 ],
	[ 3, 2 ],
	[ 3, 2, 1 ],
	[ 4 ]
])

? "Larest lists:" + NL

? @@( o1.ListsSizes() ) + NL
#--> [ 1, 1, 2, 2, 3, 3, 2, 1, 2, 2, 3, 1 ]

? o1.SizeOfLargestList() # Or MaxListsSize()
#--> 3

? @@( o1.FindLargestLists() )
#--> [ 5, 6, 11 ]

? @@( o1.LargestLists() ) + NL
#--> [ [ 2, 2, 1 ], [ 2, 2, 2 ], [ 3, 2, 1 ] ]

#--

? "Shortest lists:" + NL

? o1.MinListsSize() # Or SizeOfSmallestList()
#--> 1

? @@( o1.FindShortestLists() ) # Shortest or Smallest
#--> [ 1, 2, 8, 12 ]

? @@( o1.ShortestLists() ) + NL
#--> [ [ 1 ], [ 2 ], [ 3 ], [ 4 ] ]

proff()
# Executed in 0.01 second(s) in Ring 1.22


/*------ #Misspelled forms

profon()

? Q("   Ring ").WithoutSapces()
#--> Ring

? Q("bla {♥♥♥} blaba bla {♥♥♥} blabla").FindLasteAsSection("♥♥♥")
#--> [ 22, 24 ]

? QQ([ 2, 7, 18, 18, 10, 12, 25, 4 ]).NearstTo(10)
#--> 12

proff()

/*==== PATHS MANAGEMENT

profon()

o1 = new stzList([
	"item1",
	[ "item21", [ "item221", "item222" ], "item23" ],
	[ "item31", [ "item321" ] ],
	"item4"
])

? o1.CountPaths() + NL
#--> 12

? @@NL( o1.Paths() )
#--> [
#	[ 1 ],
#	[ 2 ],
#	[ 2, 1 ],
#	[ 2, 2 ],
#	[ 2, 2, 1 ],
#	[ 2, 2, 2 ],
#	[ 2, 3 ],
#	[ 3 ],
#	[ 3, 1 ],
#	[ 3, 2 ],
#	[ 3, 2, 1 ],
#	[ 4 ]
# ]

proff()
# Executed in 0.09 second(s) in Ring 1.22

/*------

profon()

o1 = new stzList([
	"item1",
	[ "item21", [ "item221", "item222" ], "item23" ],
	[ "item31", [ "item321" ] ],
	"item4"
])

? @@( o1.LargestPaths() )
#--> [ [ 2, 2, 1 ], [ 2, 2, 2 ], [ 3, 2, 1 ] ]

proff()
# Executed in 0.09 second(s) in Ring 1.22

/*------

profon()

o1 = new stzList([
	"item1",
	[ "item21", [ "item221", "item222" ], "item23" ],
	[ "item31", [ "item321" ] ],
	"item4"
])

? @@( o1.ShortestPaths() )
#--> [ [ 1 ], [ 2 ], [ 3 ], [ 4 ] ]

proff()
# Executed in 0.09 second(s) in Ring 1.22

/*------

profon()

o1 = new stzList([
	"item1",
	[ "item21", [ "item221", "item222" ], "item23" ],
	[ "item31", [ "item321" ] ],
	"item4"
])

? @@( o1.PathsAtDepth(3) ) + NL		# Or PathsAtLevel or FindItemsAtDepth(3)
#--> [ [ 2, 2, 1 ], [ 2, 2, 2 ], [ 3, 2, 1 ] ]

? @@NL( o1.ItemsAtDepth(3) ) + NL
#--> [
#	"item221",
#	"item222",
#	"item321"
# ]

? @@NL( o1.ItemsAtDepthZZ(3) ) 
#--> [
#	[ "item221", [ 2, 2, 1 ] ],
#	[ "item222", [ 2, 2, 2 ] ],
#	[ "item321", [ 3, 2, 1 ] ]
# ]

proff()
# Executed in 0.24 second(s) in Ring 1.22

/*------

profon()

o1 = new stzList([
	"item1",
	[ "item21", [ "item221", "item222" ], "item23" ],
	[ "item31", [ "item321" ] ],
	"item4"
])

? o1.ItemAtPath([2, 2, 2])
#--> item222

? @@( o1.ItemAtPathZZ([2, 2, 2 ]) )
#--> [ "item222", [ 2, 2, 2 ] ]

proff()
# Executed in 0.11 second(s) in Ring 1.22

/*------

profon()

o1 = new stzList([
	"item1",
	[ "item21", [ "item221", "item222" ], "item23" ],
	[ "item31", [ "item321" ] ],
	"item4"
])

? @@NL( o1.ItemsAtPathXT([ 2, 2, 2 ]) ) + NL
#--> [
#	[ "item21", [ "item221", "item222" ], "item23" ],
#	[ "item221", "item222" ],
#	"item222"
# ]

? @@NL( o1.ItemsAtPathXTZZ([ 2, 2, 2 ]) )
#--> [
#	[ [ "item21", [ "item221", "item222" ], "item23" ], [ 2 ] ],
#	[ [ "item221", "item222" ], [ 2, 2 ] ],
#	[ "item222", [ 2, 2, 2 ] ]
# ]

proff()
# Executed in 0.12 second(s) in Ring 1.22

/*------

profon()

o1 = new stzList([
	"item1",
	[ "item21", [ "item221", "item222" ], "item23" ],
	[ "item31", [ "item321" ] ],
	"item4"
])

? @@NL( o1.ItemsAtPaths([
	[ 2, 2, 2 ],
	[ 3, 1 ],
	[ 4 ]
]) )
#--> [
#	"item222",
#	"item3",
#	"item4"
# ]

? @@NL( o1.ItemsAtPathsZZ([
	[ 2, 2, 2 ],
	[ 3, 1 ],
	[ 4 ]
]) )
#--> [
#	[ "item222", [ 2, 2, 2 ] ],
#	[ "item31", [ 3, 1 ] ],
#	[ "item4", [ 4 ] ]
# ]

proff()
# Executed in 0.39 second(s) in Ring 1.22


profon()

o1 = new stzList([
	"item1",
	[ "item21", [ "item221", "item222" ], "item23" ],
	[ "item31", [ "item321" ] ],
	"item4"
])

? @@NL( o1.ItemsAtPathsXT([
	[ 2, 2, 2 ],
	[ 3, 1 ],
	[ 4 ]
]) )
#--> [
#	[ [ "item21", [ "item221", "item222" ], "item23" ], [ "item221", "item222" ], "item222" ],
#	[ [ "item3", [ "item31" ] ], "item3" ],
#	[ "item4" ]
# ]

? @@NL( o1.ItemsAtPathsXTZZ([
	[ 2, 2, 2 ],
	[ 3, 1 ],
	[ 4 ]
]) )
#--> [
#	[ [ [ "item21", [ "item221", "item222" ], "item23" ], [ "item221", "item222" ], "item222" ], [ 2, 2, 2 ] ],
#	[ [ [ "item31", [ "item321" ] ], "item31" ], [ 3, 1 ] ],
#	[ [ "item4" ], [ 4 ] ]
# ]

proff()
# Executed in 0.44 second(s) in Ring 1.22

/*=====

profon()

? @@NL( PathsIn([ 2, 3, 2 ]) ) + NL
#--> [
#	[ 2 ],
#	[ 2, 3 ],
#	[ 2, 3, 2 ]
# ]

? @@NL( PathsInXT([ [ 2, 3 ], [ 2, 3, 2 ], [ 4 ] ]) )
#--> [
#	[ 2 ],
#	[ 2, 3 ],
#	[ 2, 3, 2 ],
#	[ 4 ]
# ]

proff()
# Executed in 0.01 second(s) in Ring 1.22

/*=====

profon()

aList1 = [
	[ 2, 1 ],
	[ 2, 2, 2, 1 ],
	[ 4 ]
]

aList2 = [
	[ 2 ],
	[ 2, 1 ],
	[ 4 ]
]

? @@( Intersection([ aList1, aList2 ]) )
#--> [ [ 2, 1 ], [ 4 ] ]

proff()
#--> Executed in 0.02 second(s) in Ring 1.22

/*-----

profon()

aLists = [
	[1, 2, 3, 4, 5],
	[4, 5, 6, 7, 8],
	[4, 5, 9, 10]
]


? @@( Intersection(aLists) )
#--> [ 4, 5 ]

aLists = [
	[ "apple", "banana", "orange" ],
	[ "banana", "orange", "grape" ],
	[ "orange", "grape", "banana" ]
]

? @@(Intersection(aLists))
#--> [ "banana", "orange" ]

? @@(intersection([]))
#--> []

? @@(intersection([ [1] ]))
#--> [ 1 ]

aLists = [
	[ "apple", "banana", "orange", 1:3 ],
	[ "banana", 1:3, "orange", "grape" ],
	[ "orange", "grape", 1:3, "banana" ]
]

? @@NL(Intersection(aLists))
#--> [
#	"banana",
#	"orange",
#	[ 1, 2, 3 ]
# ]

proff()
# Executed in 0.02 second(s) in Ring 1.22

/*-----

profon()

# All the examples return the same result, but they show the power and
# flexibility of finding items in singular or plural in a path or many paths

o1 = new stzList([
	"A",
	[ "♥", ["B", "♥", "C", "♥" ], "♥", "D" ],
	"E"
])

? @@( o1.FindItemInPath("♥", [2, 2]) )
#--> [ [ 2, 1 ] ]

? @@( o1.FindItemInPaths("♥", [ [2, 2] ]) )
#--> [ [ 2, 1 ] ]

? @@( o1.FindItemsInPath(["♥"], [2, 2]) )
#--> [ [ 2, 1 ] ]

? @@( o1.FindItemsInPaths(["♥"], [ [2, 2] ]) )
#--> [ [ 2, 1 ] ]

proff()
# Executed in 0.12 second(s) in Ring 1.22

/*=== REMOVING ITEMS AT PATHS

profon()

o1 = new stzList([
	"A",
	[ "♥", ["B", "♥", "C", "♥" ], "♥", "D" ],
	"E"
])

o1.RemoveItemAtPath("♥", [2, 2])

? @@NL( o1.Content() )
#--> [
#	"A",
#	[ "♥", [ "B", "C" ], "♥", "D" ],
#	"E"
# ]

proff()
# Executed in 0.09 second(s) in Ring 1.22

/*---

profon()

o1 = new stzList([
	"A",
	[ "B", "C", "♥" ],
	"♥"
])

o1.RemoveItemAtPath("♥", [3])

? @@NL( o1.Content() )
#--> [
#	"A",
#	[ "B", "C", "♥" ]
# ]

proff()
# Executed in 0.09 second(s) in Ring 1.22

/*---

profon()

o1 = new stzList([
	"A",
	[ "B", "C", "♥" ],
	[ "♥" ]
])

o1.RemoveItemAtPath("♥", [ 3 ])

? @@NL( o1.Content() )
#--> [
#	"A",
#	[ "B", "C", "♥" ],
#	[ ]
# ]

proff()
# Executed in 0.10 second(s) in Ring 1.22

/*---

profon()

o1 = new stzList([
	"A",
	[ "B", "C", "♥" ],
	[ "♥", 2 ]
])

o1.RemoveItemAtPath("♥", [ 3 ])

? @@NL( o1.Content() )
#--> [
#	"A",
#	[ "B", "C", "♥" ],
#	[ 2 ]
# ]

proff()
# Executed in 0.10 second(s) in Ring 1.22

/*---

profon()

o1 = new stzList([
	"A",
	[ "B", [ "C", "♥", "D", "*", "♥", "*" ], "E", "F" ],
	"G"
])

o1.RemoveItemsAtPath([ "♥", "*" ], [ 2, 2 ])

? @@NL( o1.Content() )
#--> [
#	"A",
#	[ "B", [ "C", "D" ], "E", "F" ],
#	"G"
# ]

proff()
# Executed in 0.11 second(s) in Ring 1.22

/*----

profon()

o1 = new stzList([
	"A",
	[ "B", [ "C", "♥", "D", "♥" ], "♥", "E" ],
	"F",
	[ "♥", "G" ]
])

o1.RemoveItemAtPaths("♥", [ [2, 2], [4] ])

? @@NL( o1.Content() )
#--> [
#	"A",
#	[ "B", [ "C", "D" ], "♥", "E" ],
#	"F",
#	[ "G" ]
# ]

proff()
# Executed in 0.18 second(s) in Ring 1.22

/*----

profon()

o1 = new stzList([ 1, 2, "♥", 4, 5 ])

o1.RemoveThisItemAtPosition("♥", 5)
? @@( o1.Content() )
#--> [ 1, 2, "♥", 4, 5 ]

o1.RemoveThisItemAtPosition("♥", 3)
? @@( o1.Content() )
#--> [ 1, 2, 4, 5 ]

proff()
# Executed in 0.03 second(s) in Ring 1.22

/*----

profon()

o1 = new stzList([ 1, 2, "♥", 4, "♥", 6, "♥" ])

o1.RemoveThisItemAtPositions("♥", [ 3, 6 ])
? @@( o1.Content() )
#--> [ 1, 2, 4, "♥", 6, "♥" ]

o1.RemoveThisItemAt("♥", [ 4, 6 ])
? @@( o1.Content() )
# [ 1, 2, 4, 6 ]

proff()
# Executed in 0.04 second(s) in Ring 1.22

/*----

profon()

o1 = new stzList([ 1, 2, "♥", 4, "*", 6, "♥" ])

o1.RemoveTheseItemsAt([ "♥", "*"], [ 3, 5, 7 ])
? @@( o1.Content() )
#--> [ 1, 2, 4, "♥", 6, "♥" ]

proff()
# Executed in 0.04 second(s) in Ring 1.22

/*----

profon()

o1 = new stzList([
	"A",
	[ "B", [ "C", "♥", "D", "*", "♥" ], "E", "F" ],
	"G",
	[ "♥", "H", "*" ]
])

o1.RemoveItemsAtPaths([ "♥", "*" ], [ [2, 2], [4] ])

? @@NL( o1.Content() )
#--> [
#	"A",
#	[ "B", [ "C", "D" ], "E", "F" ],
#	"G",
#	[ "H" ]
# ]

proff()
# Executed in 0.32 second(s) in Ring 1.22


/*=== REMOVING ITEMS OVER PATHS
*/
profon()

o1 = new stzList([
    "A",
    [ "♥", ["B", "♥", "C", "♥" ], "♥", "D" ],
    "E"
])

? @@( o1.FindInPathXT("♥", [ 2, 2 ]) ) + NL

? @@( PathsIn([2, 2]) ) + nl

o1.RemoveItemInPath("♥", [2, 2])
#NOTE All these paths are concerned:
#     [ [ 2, 1 ], [ 2, 3 ], [ 2, 2, 2 ], [ 2, 2, 4 ] ]

? @@NL( o1.Content() )
#--> [
#	"A",
#	[ [ "B", "C" ], "D" ],
#	"E"
# ]

proff()
# Executed in 0.39 second(s) in Ring 1.22

/*----

profon()

o1 = new stzList([
	"A",
	[ "B", "♥", "C" ],
	"D"
])

? @@NL( o1.Paths() ) + NL
#--> [
#	[ 1 ],
#	[ 2 ],
#	[ 2, 1 ],
#	[ 2, 2 ],
#	[ 2, 3 ],
#	[ 3 ]
# ]

? o1.NumberOfItemsInPath([3])
#--> 6

? @@NL( o1.ItemsInPath([3]) ) + NL
#--> [
#	"A",
#	[ "B", "♥", "C" ],
#	"B",
#	"♥",
#	"C",
#	"D"
# ]

? @@NL( o1.ItemsInPathZZ([3]) ) + NL
#--> [
#	[ "A", [ 1 ] ],
#	[ [ "B", "♥", "C" ], [ 2 ] ],
#	[ "B", [ 2, 1 ] ],
#	[ "♥", [ 2, 2 ] ],
#	[ "C", [ 2, 3 ] ],
#	[ "D", [ 3 ] ]
# ]

? @@( o1.NthItemInPath(1, [3] ) )

? @@( o1.NthItemInPath(2, [3] ) )
#--> [ "B", "♥", "C" ]

? @@( o1.NthItemInPath(3, [3]) )
#--> "B"

? @@( o1.NthItemInPath(4, [3]) )
#--> "♥"

? @@( o1.NthItemInPath(5, [3]) )
#--> "C"

? @@( o1.NthItemInPath(6, [3]) )
#--> "D"

// ? @@( o1.NthItemInPath(7, [3]) )
#--> ERROR: Incorrect param value! n must be within the size of the path.

proff()
# Executed in 0.95 second(s) in Ring 1.22

/*----

profon()

o1 = new stzList([
	"A",
	[ "B", "♥", "C" ],
	"D"
])

? @@( o1.NthPathInPath(4, [3]) ) + NL
#--> [ 2, 2 ]

? @@( o1.NthItemInPath(4, [3]) ) + NL
#--> "♥"

? @@NL( o1.NthPathsInPath([2, 4, 6], [3]) ) + NL
#--> [
#	[ 2 ],
#	[ 2, 2 ],
#	[ 3 ]
# ]

? @@NL( o1.NthItemsInPath([ 2, 4, 6 ], [3]) )
#--> [
#	[ "B", "♥", "C" ],
#	"♥",
#	"D"
# ]

proff()
# Executed in 0.28 second(s) in Ring 1.22

/*----

profon()


o1 = new stzList([
    	"A",
    	[ "♥", "B", [ "C", "♥", "D", "♥" ], "♥", "E", "♥" ],
    	"E"
])


? @@( o1.PathsIn([ 2 ]) )
#--> [ [ 1 ], [ 2 ] ]

? @@( o1.FindItemAtPath("♥", [ 2 ]) ) + NL
#--> [ [ 2, 1 ], [ 2, 4 ], [ 2, 6 ] ]

? @@NL( o1.PathsIn([ 2, 3, 4 ]) ) + NL
#--> [
#	[ 1 ],
#	[ 2 ],
#	[ 2, 1 ],
#	[ 2, 2 ],
#	[ 2, 3 ],
#	[ 2, 3, 1 ],
#	[ 2, 3, 2 ],
#	[ 2, 3, 3 ],
#	[ 2, 3, 4 ]
# ]

? o1.ItemExistsAtPath("♥", [ 2, 3, 4 ])
#--> TRUE

? @@( o1.FindItemAtPath("♥", [ 2, 3, 4 ]) ) + NL
#--> [ 2, 3, 4 ]

? o1.ItemExistsAtPath("X", [ 2, 3, 4 ])
#--> FALSE

? @@( o1.FindItemAtPath("X", [ 2, 3, 4 ]) )
#--> [ ]

proff()
# Executed in 0.26 second(s) in Ring 1.22

/*----

profon()


o1 = new stzList([
    	"A",
    	[ "♥", "B", [ "C", "♥", "D", "♥" ], "♥", "E", "♥" ],
    	"E"
])

? @@( o1.FindItemAtPath("♥", [ 2, 3, 4 ]) ) + NL
#--> [ 2, 3, 4 ]

? @@( o1.FindAnyOfTheseItemsAtPath([ "♥", "X", "Y" ], [ 2, 3, 4 ]) )
#--> [ 2, 3, 4 ]

? @@( o1.FindAnyOfTheseItemsAtPath([ "X", "Y", "Z" ], [ 2, 3, 4 ]) )
#--> [ ]

proff()
# Executed in 0.32 second(s) in Ring 1.22

/*----

profon()


o1 = new stzList([
    	"A",
    	[ "♥", "B", [ "C", "♥", "D", "♥" ], "♥", "E", "♥" ],
    	"E",
	"♥"
])

? @@( o1.FindItemAtPaths("♥", [ [1], [3] ]) )
#--> []

? @@( o1.FindItemAtPaths("♥", [ [1], [3], [4] ]) )
#--> [ 4 ]

proff()
# Executed in 0.28 second(s) in Ring 1.22

/*----

profon()


o1 = new stzList([
    	"A",
    	[ "♥", "B", [ "C", "♥", "D", "♥" ], "♥", "E", "♥" ],
    	"E",
	"♥"
])

? @@( o1.FindItemAtPaths("♥", [ [1], [3] ]) )
#--> []

? @@( o1.FindItemAtPaths("♥", [ [1], [3], [2, 3] ]) )
#--> [ [ 2, 3, 2 ], [ 2, 3, 4 ] ]

proff()
# Executed in 0.28 second(s) in Ring 1.22

/*----

profon()


o1 = new stzList([
    "A",
    [ "♥", "B", [ "C", "♥", "D", "♥" ], "♥", "E", "♥" ],
    "E"
])

? @@NL( o1.PathsIn([2, 2]) ) + NL
#--> [
#	[ 1 ],
#	[ 2 ],
#	[ 2, 1 ],
#	[ 2, 2 ]
# ]

? @@NL( o1.ItemsInPathZZ([2, 2]) ) + NL
#--> [
#	[ "A", [ 1 ] ],
#	[ [ "♥", "B", [ "C", "♥", "D", "♥" ], "♥", "E", "♥" ], [ 2 ] ],
#	[ "♥", [ 2, 1 ] ],
#	[ "B", [ 2, 2 ] ]
# ]

proff()
# Executed in 0.25 second(s) in Ring 1.22

/*---- #todo #narration finding an item over a given path
# using DeepFind(), PathsIn, and Intersection

profon()

o1 = new stzList([
    "A",
    [ "♥", "B", [ "C", "♥", "D", "♥" ], "♥", "E", "♥" ],
    "E"
])

aItemPaths = o1.DeepFind("♥")
#--> [
#	[ 2, 1 ],
#	[ 2, 3, 2 ],
#	[ 2, 3, 4 ],
#	[ 2, 4 ],
#	[ 2, 6 ]
# ]

aAllPaths = o1.PathsIn([2, 3])
#--> [
#	[ 1 ],
#	[ 2 ],
#	[ 2, 1 ],
#	[ 2, 2 ]
# ]

? @@( @intersection([ aItemPaths, aAllPaths ]) )
#--> [ [ 2, 1 ] ]

fproff()

/*----

profon()

? IsSubPathOf( [2], [2, 3, 4])

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*-----

profon()

o1 = new stzList([
    "A",
    [ "♥", "B", [ "C", "♥", "D", "♥" ], "♥", "E", "♥" ],
    "E"
])

? o1.IsValidPath([3])
#--> TRUE

? o1.IsValidPath([ 2, 3])
#--> TRUE

? o1.AreValidPaths([ [3], [2,3] ])
#--> TRUE

? o1.AreValidPaths([ [2,3], [3] ])
#--> TRUE

proff()
# Executed in 0.18 second(s) in Ring 1.22

/*-----

profon()

o1 = new stzList([
    "A",
    [ "♥", "B", [ "C", "♥", "D", "♥" ], "♥", "E", "♥" ],
    "E"
])

? @@NL( o1.Paths() ) + NL
#--> [
#	[ 1 ],
#	[ 2 ],
#	[ 2, 1 ],
#	[ 2, 2 ],
#	[ 2, 3 ],
#	[ 2, 3, 1 ],
#	[ 2, 3, 2 ],
#	[ 2, 3, 3 ],
#	[ 2, 3, 4 ],
#	[ 2, 4 ],
#	[ 2, 5 ],
#	[ 2, 6 ],
#	[ 3 ]
# ]

? o1.ContainsPath([3])
#--> TRUE

? o1.ContainsPath([ 2, 3 ])
#--> TRUE

? o1.ContainsPaths([ [3], [2, 3] ])
#--> TRUE

proff()

/*-----

profon()

o1 = new stzList([
    "A",
    [ "♥", "B", [ "C", "♥", "D", "♥" ], "♥", "E", "♥" ],
    "E"
])

? @@NL( o1.Paths() )
#--> [
#	[ 1 ],
#	[ 2 ],
#	[ 2, 1 ],
#	[ 2, 2 ],
#	[ 2, 3 ],
#	[ 2, 3, 1 ],
#	[ 2, 3, 2 ],
#	[ 2, 3, 3 ],
#	[ 2, 3, 4 ],
#	[ 2, 4 ],
#	[ 2, 5 ],
#	[ 2, 6 ],
#	[ 3 ]
# ]

? @@NL( o1.ExpandPath([2]) )
#--> [
#	[ 2, 1 ],
#	[ 2, 2 ],
#	[ 2, 3 ],
#	[ 2, 3, 1 ],
#	[ 2, 3, 2 ],
#	[ 2, 3, 3 ],
#	[ 2, 3, 4 ],
#	[ 2, 4 ],
#	[ 2, 5 ],
#	[ 2, 6 ]
# ]

? @@( o1.ExpandPath([3]) )
#--> [ 3 ]

? @@NL( o1.ExpandPath([2, 3]) )
#--> [
#	[ 2, 3, 1 ],
#	[ 2, 3, 2 ],
#	[ 2, 3, 3 ],
#	[ 2, 3, 4 ]
# ]

? @@NL( o1.ExpandPaths([ [2, 3], [3] ]) )
#--> [
#	[ 2, 3 ],
#	[ 2, 3, 1 ],
#	[ 2, 3, 2 ],
#	[ 2, 3, 3 ],
#	[ 2, 3, 4 ],
#	[ 3 ]
# ]

proff()
# Executed in 0.18 second(s) in Ring 1.22

/*------

profon()

o1 = new stzList([
    "A",
    [ "♥", "B", [ "C", "♥", "D", "♥" ], "♥", "E", "♥" ],
    "E"
])

? @@NL( o1.Paths() ) # Or PathsExpanded()
#--> [
#	[ 1 ],
#	[ 2 ],
#	[ 2, 1 ],
#	[ 2, 2 ],
#	[ 2, 3 ],
#	[ 2, 3, 1 ],
#	[ 2, 3, 2 ],
#	[ 2, 3, 3 ],
#	[ 2, 3, 4 ],
#	[ 2, 4 ],
#	[ 2, 5 ],
#	[ 2, 6 ],
#	[ 3 ]
# ]

? @@NL( o1.PathsCollabsed() )
#--> [
#	[ 1 ],
#	[ 2 ],
#	[ 3 ]
# ]

proff()
# Executed in 0.40 second(s) in Ring 1.22

/*------

profon()

o1 = new stzList([
    "A",
    [ "♥", "B", [ "C", "♥", "D", "♥" ], "♥", "E", "♥" ],
    "E"
])


? @@NL( o1.ExpandPath([ 2, 3 ]) )
#--> [
#	[ 2, 3 ],
#	[ 2, 3, 1 ],
#	[ 2, 3, 2 ],
#	[ 2, 3, 3 ],
#	[ 2, 3, 4 ]
# ]

? @@Nl( o1.ExpandThesePaths([ [ 2, 3 ], [3] ]) )
#--> [
#	[ 2, 3 ],
#	[ 2, 3, 1 ],
#	[ 2, 3, 2 ],
#	[ 2, 3, 3 ],
#	[ 2, 3, 4 ],
#	[ 3 ]
# ]

? @@( o1.CollabsePath([2, 3, 4]) )
#--> [ 2 ]

? @@( o1.CollabseThesePaths([ [2, 3, 4], [ 2, 2 ], [ 3 ] ]) )
#--> [ [ 2 ], [ 3 ] ]

proff()
# Executed in 0.33 second(s) in Ring 1.22

/*-----

profon()

o1 = new stzList([
	"A",
	"♥",
	[ "B", "♥", "C" ],
	"D",
    	[ "♥", "E", [ "F", "♥", "G", "♥" ], "♥", "H", "♥" ],
    	"I"
])

? @@NL( o1.FindItemInPath("♥", [ 5, 3, 2 ]) )
#--> [
#	[ 2 ],
#	[ 3, 2 ],
#	[ 5, 1 ],
#	[ 5, 3, 2 ]
# ]

proff()
# Executed in 0.54 second(s) in Ring 1.22

/*-----

profon()

o1 = new stzList([
	"A",
	"♥",
	[ "B", "♥", "C" ],
	"*",
	"D",
    	[ "♥", "E", [ "F", "♥", "*", "G", "♥" ], "♥", "H", "♥" ],
    	"I"
])

? @@NL( o1.FindItemsInPath([ "♥", "*" ], [ 6, 3, 3 ]) )
#--> [
#	[ 2 ],
#	[ 3, 2 ],
#	[ 4 ],
#	[ 6, 1 ],
#	[ 6, 3, 2 ],
#	[ 6, 3, 3 ]
# ]

proff()
# Executed in 0.67 second(s) in Ring 1.22

/*-----

profon()

o1 = new stzList([
	"A",
	"♥",
	[ "B", "♥", "C" ],
	"D",
    	[ "♥", "E", [ "F", "♥", "G", "♥" ], "♥", "H", "♥" ],
    	"I"
])

? @@( o1.DeepestPath() ) + NL		# Or HighestPath() depending on how
#--> [ 6 ]				# you look to the list building ;)

? @@( o1.ShallowestPath() ) + NL	# Or LowestPath()
#--> [ 1 ]

proff()

/*----

profon()

o1 = new stzList([
	"A",
	"♥",
	[ "B", "♥", "C" ],
	"D",
    	[ "♥", "E", [ "F", "♥", "G", "♥" ], "♥", "H", "♥" ],
    	"I"
])

? o1.LengthOfLongestPath()
#--> 3

? @@( o1.LongestPath() ) + NL		# If many, returns the 1st
#--> [ 5, 3, 1 ]

? @@NL( o1.LongestPaths() ) + NL	# the little additional "s" returns them all ;)
#--> [
#	[ 5, 3, 1 ],
#	[ 5, 3, 2 ],
#	[ 5, 3, 3 ],
#	[ 5, 3, 4 ]
# ]

proff()
# Executed in 0.16 second(s) in Ring 1.22

/*---

profon()

o1 = new stzList([
	"A",
	"♥",
	[ "B", "♥", "C" ],
	"D",
    	[ "♥", "E", [ "F", "♥", "G", "♥" ], "♥", "H", "♥" ],
    	"I"
])

? o1.LenOfShortestPath()
#--> 1

? @@( o1.ShortestPath() ) + NL		# If many, returns the 1st
#--> [ 1 ]

? @@NL( o1.ShortestPaths() ) + NL	# the little additional "s" returns them all ;)
#--> [
#	[ 1 ],
#	[ 2 ],
#	[ 3 ],
#	[ 4 ],
#	[ 5 ],
#	[ 6 ]
# ]

proff()
# Executed in 0.13 second(s) in Ring 1.22

/*---

profon()

o1 = new stzList([])

? o1.LenOfShortestPath()
#--> 0

? @@( o1.ShortestPath() )
#--> [ ]

? @@NL( o1.ShortestPaths() ) + NL
#--> [ ]

? o1.LenOfLongestPath()
#--> 0

? @@( o1.LongestPath() )
#--> [ ]

? @@NL( o1.LongestPaths() )
#--> [ ]

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*----

profon()

o1 = new stzList([
	"A",
	"♥",
	[ "B", "♥", "C" ],
	"D",
    	[ "♥", "E", [ "F", "♥", "G", "♥" ], "♥", "H", "♥" ],
    	"I"
])

? @@( o1.LengthOfLongestPath() ) + NL
#--> 3

? @@( o1.LengthOfShortestPath() )
#--> 1

? @@NL( o1.PathsAndTheirLengths() )
#--> [
#	[ [ 1 ], 1 ],
#	[ [ 2 ], 1 ],
#	[ [ 3 ], 1 ],
#	[ [ 3, 1 ], 2 ],
#	[ [ 3, 2 ], 2 ],
#	[ [ 3, 3 ], 2 ],
#	[ [ 4 ], 1 ],
#	[ [ 5 ], 1 ],
#	[ [ 5, 1 ], 2 ],
#	[ [ 5, 2 ], 2 ],
#	[ [ 5, 3 ], 2 ],
#	[ [ 5, 3, 1 ], 3 ],
#	[ [ 5, 3, 2 ], 3 ],
#	[ [ 5, 3, 3 ], 3 ],
#	[ [ 5, 3, 4 ], 3 ],
#	[ [ 5, 4 ], 2 ],
#	[ [ 5, 5 ], 2 ],
#	[ [ 5, 6 ], 2 ],
#	[ [ 6 ], 1 ]
# ]

proff()
# Executed in 0.14 second(s) in Ring 1.22

/*---- #TODO #narration #seantic-precision PATHS SEMANTICS

# Depth   -> DeepestPath()	or HighestPath() depending on the  observer perpspective
	  VS ShallowestPath()	or LowestPath()

# Lenght  -> LongestPath() VS ShortestPath()

// Add examples here

/*====

profon()

o1 = new stzList([
	"A",
	"♥",
	[ "B", "♥", "C" ],
	"D",
    	[ "♥", "E", [ "F", "♥", "G", "♥" ], "♥", "H", "♥" ],
    	"I"
])

? @@NL( o1.FindItemInPaths("♥", [ [ 3, 2 ], [ 5, 2 ] ]) )
#--> [
#	[ 2 ],
#	[ 3, 2 ],
#	[ 5, 1 ]
# ]

proff()
# Executed in 0.51 second(s) in Ring 1.22

/*-----
*/
profon()

o1 = new stzList([
	"A",
	"♥",
	[ "B", "♥", "C" ],
	"*",
	"D",
    	[ "♥", "E", [ "F", "♥", "*", "G", "♥" ], "♥", "H", "♥" ],
    	"I"
])

? @@NL( o1.FindItemsInPaths([ "♥", "*" ], [ [ 6, 3, 3 ] ]) )
#--> [
#	[ 2 ],
#	[ 3, 2 ],
#	[ 4 ],
#	[ 6, 1 ],
#	[ 6, 3, 2 ],
#	[ 6, 3, 3 ]
# ]

proff()
# Executed in 0.68 second(s) in Ring 1.22

/*-----

profon()

o1 = new stzList([
    	"A",
	"B",
    	[ "♥", "C", [ "D", "♥", "E", "♥" ], "♥", "F", "♥" ],
    	"G"
])

ItemExistsInPath(pItem, paPath)
ContainsItemInPath(pItem, paPath)

ItemExistsInAllNodesOfPath(pItem, paPath)
ContainsItemInAllNodesOfPath(pItem, paPath)

ItemExistsInPaths(pItem, paPaths)
ContainsItemInPaths(pItem, paPaths)

ItemExistsInAllNodesOfPaths(pItem, paPath)
ContainsItemInAllNodesOfPaths(pItem, paPaths)

ItemsExistInPath(paItems, paPath)
ContainsItemsInPath(paItems, paPath)

ItemsExistInPaths(paItems, paPaths)
ContainsItemsInPaths(paItems, paPaths)

proff()

/*----
*/

profon()

o1 = new stzList([
    	"A",
	"B",
    	[ "♥", "C", [ "D", "♥", "E", "♥" ], "♥", "F", "♥" ],
    	"G"
])

? @@( o1.FindItemInPaths("♥", [ [1], [2] ]) ) + NL
#--> []

? @@( o1.FindItemInPaths("♥", [ [1], [2], [3] ]) ) + NL
#--> []

? @@( o1.FindItemInPath("♥", [ 3, 1 ]) )
#--> [ [ 3, 1 ] ]

? @@NL( o1.FindItemInPath("♥", [3, 4]) )
#--> [
#	[ 3, 1 ],
#	[ 3, 3, 2 ],
#	[ 3, 3, 4 ],
#	[ 3, 4 ]
# ]

proff()
# Executed in 1.05 second(s) in Ring 1.22

/*---

profon()

o1 = new stzList([
    "A",
    [ "♥", "B", [ "C", "♥", "D", "♥" ], "♥", "E", "♥" ],
    "E"
])

//? @@( o1.FindItemsInPath([ "♥", "*" ], [2, 2]) )
//o1.RemoveItemsInPath([ "♥", "*" ], [2, 2])

//? @@NL( o1.Content() )
#--> [ "♥", ["B", "♥", "C", "♥" ], "♥", "D" ],

proff()
# Executed in 0.39 second(s) in Ring 1.22

/*====

profon()

o1 = new stzList([
    "A",
    [ "♥", [ "B", "♥", "C", "♥" ], "♥", "D" ],
    "E"
])

? @@( o1.FindItemsInPath([ "♥", "B" ], [2, 2]) )
#--> [ [ 2, 1 ], [ 2, 3 ], [ 2, 2, 2 ], [ 2, 2, 4 ], [ 2, 2, 1 ] ]

proff()
# Executed in 0.17 second(s) in Ring 1.22

/*------

profon()

o1 = new stzList([
	"A",
	[ "♥", [ "B", "♥", "C", "♥" ], "♥", "D" ],
	"E",
	[ "F", "♥", "G", [ "♥" ] ]
])

? o1.AreValidPaths([ [2, 2], [4, 2] ])
#--> TRUE

? @@( ExpandPaths([ [2, 2], [4, 2] ]) )
#--> [ [ 2 ], [ 2, 2 ], [ 4 ], [ 4, 2 ] ]

? @@( CollapsePaths([
	[ 2 ],
	[ 2, 2 ],
	[ 4 ],
	[ 4, 2 ],
	[ 3, 1 ],
	[ 3, 1, 2 ]
]) )
#--> [ [ 2 ], [ 4 ], [ 3, 1 ] ]

proff()
# Executed in 0.09 second(s) in Ring 1.22

/*---

profon()

o1 = new stzList([
	"A",
	[ "♥", [ "B", "♥", "C", "♥" ], "♥", "D" ],
	"E",
	[ "F", "♥", "G", [ "♥" ] ]
])

? @@NL( SortPaths([
	[ 2 ],
	[ 2, 2 ],
	[ 4 ],
	[ 4, 2 ],
	[ 2, 1 ],
	[ 1 ],
	[ 3, 1 ],
	[ 3, 1, 2 ]
]) )
#--> [
#	[ 1 ],
#	[ 2 ],
#	[ 2, 1 ],
#	[ 2, 2 ],
#	[ 3, 1 ],
#	[ 3, 1, 2 ],
#	[ 4 ],
#	[ 4, 2 ]
# ]

proff()
# Executed in almost 0 second(s) in Ring 1.22

#---

profon()

#  All paths share [2, 1] as common ancestor
? @@( CommonPath()([ [2, 1, 3], [2, 1, 4], [2, 1, 5] ]) ) # Or PathsIntersection()
#--> [ 2, 1 ]

# Paths share only [2]
? @@( CommonPath([ [2,1,3], [2,1,4], [2,2,1] ]) )
#--> [ 2 ]

# No common path
? @@( CommonPath([ [2,1,3], [3,1,4], [4,1,5] ]) )
#--> [ ]

# One path is ancestor of others
? @@( CommonPath([ [2,1], [2,1,3], [2,1,4] ]) )
#--> [ 2, 1 ]

# Single path
? @@( CommonPath([ [2,1,3] ]) )
#--> [ 2, 1, 3 ]

# Empty paths list
? @@( CommonPath([]) )
#--> [ ]

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*---

profon()

# This list will have no common path because of root-level items

o1 = new stzList([
    "A",					# path [1]
    [ "target", [ "B", "target", "C" ] ],	# paths starting with [2]
    "E"						# path [3]
])

? @@( o1.CommonPath() ) + NL

# But this list WILL have a common path [1]

o2 = new stzList([
    	[ 
		"X",
		[ "Y", [ "Z1" ] ],
		[ "Y", [ "Z2" ] ],
		[ "Y", [ "Z3" ] ]
	]
])

? @@NL( o2.Paths() )
#--> [
#	[ 1 ],
#	[ 1, 1 ],
#	[ 1, 2 ],
#	[ 1, 2, 1 ],
#	[ 1, 2, 2 ],
#	[ 1, 2, 2, 1 ],
#	[ 1, 3 ],
#	[ 1, 3, 1 ],
#	[ 1, 3, 2 ],
#	[ 1, 3, 2, 1 ],
#	[ 1, 4 ],
#	[ 1, 4, 1 ],
#	[ 1, 4, 2 ],
#	[ 1, 4, 2, 1 ]
# ]

? @@( o2.CommonPath() )
#--> [ 1 ]

# In o2, all paths will begin with [1], because:
#	- Everything is nested under the first element [1]
#	- Then all paths continue through the second level [1,2], the
#	  third level [1,3] and the forth level [1,4]
#	- No "sibling" elements at the root level to create divergent paths

#~> This is an important characteristic of tree structures:
# to have a common path, the structure needs to force all elements through the same "trunk" before branching out.

? o2.IsTree() # Use CommonPath() internally
#--> TRUE

? o1.IsTree()
#--> FALSE

proff()
# Executed in 0.13 second(s) in Ring 1.22

#--

profon()

? @@( PathsSection([ 2 ], [ 2, 3, 1 ]) )
#--> [ [ 2 ], [ 2, 3 ], [ 2, 3, 1 ] ]

? @@( PathsSection([2], [2,3,1]) )
#--> [ [ 2 ], [ 2, 3 ], [ 2, 3, 1 ] ]

? @@( PathsSection([2, 3], [2, 3, 1, 4]) )
#--> [ [ 2, 3 ], [2, 3, 1 ], [ 2, 3, 1, 4 ] ]

? @@( PathsSection([2], [3,1]) )
#--> [ ]    # Because [2] is not a subpath of [3,1]

? @@( PathsSection([2,3], [2]) ) + NL
#--> [ ]    # [2,3] is not a subpath of [2]

proff()
# Executed in almost 0 second(s) in Ring 1.22

#--

profon()

o1 = new stzList([ 
	"X",
	[ "Y", [ "Z1" ] ],
	[ "Y", [ "Z2" ] ],
	[ "Y", [ "Z3" ] ]
])

? @@NL( o1.Paths() )
#--> [
#	[ 1 ],
#	[ 2 ],
#	[ 2, 1 ],
#	[ 2, 2 ],
#	[ 2, 2, 1 ],
#	[ 3 ],
#	[ 3, 1 ],
#	[ 3, 2 ],
#	[ 3, 2, 1 ],
#	[ 4 ],
#	[ 4, 1 ],
#	[ 4, 2 ],
#	[ 4, 2, 1 ]
# ]

? @@NL( o1.PathsSection(:From = [2], :To = [2, 2, 1]) )
#--> [
#	[ "Y", [ "Z1" ] ],
#	[ "Z1" ],
#	"Z1"
#]

? @@NL( o1.PathsSectionZZ(:From = [2], :To = [2, 2, 1]) ) + NL
#--> [
#	[ [ "Y", [ "Z1" ] ], [ 2 ] ],
#	[ [ "Z1" ], [ 2, 2 ] ],
#	[ "Z1", [ 2, 2, 1 ] ]
# ]

# Can be accessed more expressively using SectionXT() like this:

? @@NL( o1.SectionXT(:FromPath = [2], :ToPath = [2, 2, 1]) )
#--> [
#	[ "Y", [ "Z1" ] ],
#	[ "Z1" ],
#	"Z1"
#]

? @@NL( o1.SectionXTZZ(:FromPath = [2], :ToPath = [2, 2, 1]) )
#--> [
#	[ [ "Y", [ "Z1" ] ], [ 2 ] ],
#	[ [ "Z1" ], [ 2, 2 ] ],
#	[ "Z1", [ 2, 2, 1 ] ]
# ]


proff()
# Executed in 0.45 second(s) in Ring 1.22

/*--

profon()

# [2,1] is a subpath of [2,1,3] but not of [2,2]

? IsSubPathOf([ 2, 1 ], [ 2, 1, 3 ])
#--> TRUE

? IsSubPathOf([ 2, 1 ], [ 2, 2 ]) + NL
#--> FALSE

proff()
# Executed in 0.01 second(s) in Ring 1.22


/*------------


/*----....

profon()

o1 = new stzList([
	"♥♥♥",
	[ "item21", [ "item221", "♥♥♥" ], "item23" ],
	[ "item3", [ "item31", "♥♥♥" ] ],
	"item4"
])

# Find paths containing specific items
//? @@( o1.PathsContaining("item3") )
#--> [ [2, 2, 1] ]

# Get item at specific path
//? o1.ItemAtPath([2, 2, 1])
#--> "item3"

proff()
# Executed in 0.08 second(s) in Ring 1.22

/*----

profon()

o1 = new stzList([
	"item1",
	[ "item2", ["item3", "item4"], "item5" ],
	[ "item6", ["item7"] ],
	"item8"
])

# Replace item at path
o1.ReplaceAtPath([2, 2, 1], "newitem3")
? o1.ItemAtPath([2, 2, 1])
#--> "newitem3"

proff()

/*-------

profon()

o1 = new stzList([
	"item1",
	[ "item2", ["item3", "item4"], "item5" ],
	[ "item6", ["item7"] ],
	"item8"
])

# Get paths at specific depth
? @@( o1.PathsAtDepth(2) )
#--> [ [2, 1], [2, 3], [3, 1] ]

# Get longest and shortest paths
? @@( o1.LongestPath() )
#--> [2, 2, 1]
? @@( o1.ShortestPath() )
#--> [1]

# Validate paths
? o1.IsValidPath([2, 2, 1])  #--> TRUE
? o1.IsValidPath([5, 1])     #--> FALSE

proff()

/*-------

profon()

o1 = new stzList([
	"item1",
	[ "item2", ["item3", "item4"], "item5" ],
	[ "item6", ["item7"] ],
	"item8"
])

# Insert and remove at paths
o1.InsertAtPath([2, 2], "inserted")
o1.RemoveAtPath([2, 2, 1])

? @@NL( o1.Content() )

proff()
/*============

profon()

o1 = new stzList([
	"ring",
	[ "ruby", "julia", [ "php", "ring" ] ],
	"pascal",
	[ "ring" ]
])

? @@NL( o1.DeepUppercased() )
#--> [
#	"RING",
#	[ "RUBY", "JULIA", [ "PHP", "RING" ] ],
#	"PASCAL",
	"RING"
# ]

? @@NL( o1.DeepLowercased() )
#--> [
#	"ring",
#	[ "ruby", "julia", [ "php", "ring" ] ],
#	"pascal",
#	[ "ring" ]
# ]

o1.DeepUppercaseString("ring")
? @@NL( o1.Content() )
#--> [
#	"RING",
#	[ "ruby", "julia", [ "php", "RING" ] ],
#	"pascal",
#	[ "RING" ]
# ]

proff()
# Executed in 0.03 second(s) in Ring 1.22

/*----

profon()

o1 = new stzList([
	"you",
	"other",
	[ "other", "you", [ "you" ], "other" ],
	"other",
	"you"
])

? @@( o1.DeepFind("you") ) + NL
#--> [ [ 1 ], [ 3, 2 ], [ 3, 3, 1 ], [ 5 ] ]

#--

o1.DeepReplace("you", :By = "♥")

? @@NL( o1.Content() ) + NL
#--> [
#	"♥",
#	"other",
#	[ "other", "♥", [ "♥" ], "other" ],
#	"other",
#	"♥"
# ]

#--

o1.DeepUppercaseString("other") #TODO
? @@NL( o1.Content() ) + NL
#--> [
#	"♥",
#	"OTHER",
#	[ "OTHER", "♥", [ "♥" ], "OTHER" ],
#	"OTHER",
#	"♥"
# ]

#--

o1.DeepRemove("OTHER")
? @@( o1.Content() )
#--> [ "♥", [ "♥", [ "♥" ] ], "♥" ]

proff()
# [ "♥", [ "♥", [ "♥" ] ], "♥" ]

/*====

profon()

c = "‎"

? IsEmpty(c)
#--> FALSE

? Unicode(c)
#--> 8206

? CharName(c)
#--> LEFT-TO-RIGHT MARK


? ShowShort( NamesOfInvisibleChars() )
#--> [
#   "<control>",
#   "SPACE",
#   "NO-BREAK SPACE",
#   "...",
#   "HANGUL FILLER",
#   "HANGUL CHOSEONG FILLER",
#   "HALFWIDTH HANGUL FILLER"
# ]

proff()
# Executed in 0.70 second(s) in Ring 1.22

/*----

profon()

aList = [
	1,
	[2, 3, [1] ],
	4,
	[ 1 ],
	1 ,
	[ 4, [ 7, [ 8, 9, 1 ] ] ]
]

? @@( FindNumberOrStringInNestedList(1, aList ) ) + NL
#--> [ [ 1 ], [ 2, 3, 1 ], [ 4, 1 ], [ 5 ], [ 6, 2, 2, 3 ] ]

? @@( Q(aList).DeepFind(1) )
#--> [ [ 1 ], [ 2, 3, 1 ], [ 4, 1 ], [ 5 ], [ 6, 2, 2, 3 ] ]


proff()
# Executed in almost 0 second(s) in Ring 1.22

/*----

profon()

o1 = new stzList([ 1, "♥", 3, 4, "♥", 6 ])

? o1.ExistsInPositions("♥", [ 2, 5 ])

? o1.ExistsAt("♥", 5)

proff()

/*----

profon()

aList = [
	[ 1, 2, 3 ],
	[ "B", [ 1, 2, 3 ] ],
	[ "C", [  [ 1, 2, 3 ], "F" ], "D", [ 1, 2, 3 ] ],
	"G",
	[ 1, 2, 3 ]
]

? @@( Q(aList).DeepFind([ 1, 2, 3 ]) )
#--> [ [ 1 ], [ 2, 2 ], [ 3, 2, 1 ], [ 3, 4 ], [ 5 ] ]

proff()
# [ [ 1 ], [ 2, 2 ], [ 3, 2, 1 ], [ 3, 4 ], [ 5 ] ]

/*----

profon()

# Test of internal functions used with DeepFind() in stzString

aList = [
	[ 1, 2, 3 ],
	[ "B", [ 1, 2, 3 ] ],
	[ "C", [  [ 1, 2, 3 ], "F" ], "D", [ 1, 2, 3 ] ],
	"G",
	[ 1, 2, 3 ]
]

cListInStr = '[
	[ 1, 2, 3 ],
	[ "B", [ 1, 2, 3 ] ],
	[ "C", [  [ 1, 2, 3 ], "F" ], "D", [ 1, 2, 3 ] ],
	"G",
	[ 1, 2, 3 ]
]'

? @@( FindStrListInNestedStrList("[ 1, 2, 3 ]", cListInStr) )
#--> [ 1, [ 2, 2 ], [ 3, 2, 1 ], [ 3, 4 ], 5 ]

? @@( FindStrListInNestedStrList("", "") )
#--> []

? @@( FindStrListInNestedStrList('[1]', "str") )
#--> []

_input1_ = '[ [ 1, 2, 3 ] ,    [ "B", [ 1, 2, 3 ] ],[ "C", "D", [ 1, 2, 3 ] ] , [ 1, 2, 3 ] ]'
? @@( FindStrListInNestedStrList("[ 1, 2, 3 ]", _input1_) )  # Should handle extra spaces
#--> [ [ 1 ], [ 2, 2 ], [ 3, 3 ], [ 4 ] ]

# Nested edge cases
_input2_ = '[[[[1, 2, 3]]]]'
? @@( FindStrListInNestedStrList("[ 1, 2, 3 ]", _input2_) ) # Should handle deep nesting
#--> [ ]

# Malformed but recoverable
_input3_ = '[ [ 1, 2, 3 ] , [ "B", [ 1, 2, 3 ] '  # Missing closing brackets
? @@( FindStrListInNestedStrList("[ 1, 2, 3 ]", _input3_) ) # Should return partial results
#--> [ [ 1 ] ]

proff()
# Executed in 0.08 second(s) in Ring 1.22

/*----- #todo #narration STRINGIFY VS DEEP-STRINGIFY

profon()

# Define a nested list with a mix of strings, numbers, and sublists

aList1 = [
	"A",
	[ "B", "♥" ],
	[ "C", "D", [ 1, 2, [ "str", 7:9, 10 ],  3 ], "♥" ],
	"♥"
]

o1 = new stzList(aList1)

# Stringified(): Converts top-level elements to strings, preserving
# nested sublists as string representations

? @@SP( o1.Stringified() ) + NL
#--> [
#	"A",
#	'[ "B", "♥" ]',
#	'[ "C", "D", [ 1, 2, [ "E", [ 7, 8, 9 ], 10 ], 3 ], "♥" ]',
#	"♥"
#]

# DeepStringified(): Recursively converts all elements into strings,
# retaining the structural hierarchy

? @@SP( o1.DeepStringified() )
#--> [
#	"A",
#	[ "B", "♥" ],
#	[ "C", "D", [ "1", "2", [ "E", [ "7", "8", "9" ], "10" ], "3" ], "♥" ],
#	"♥"
# ]

# NOTE: These are used internally by Softanza in Find() and DeepFind() functions
# to allow them search for items other then lists.

# Other possible use cases of Stringify() and DeepStringify()
# - 
proff()
# Executed in 0.01 second(s) in Ring 1.22

/*---------

profon()

o1 = new stzList([
	"A",
	[ "B", "♥" ],
	[ "C", "D", "♥" ],
	"♥"
])

? @@( o1.DeepFind("♥") ) + NL
#--> [ [ 2, 2 ], [ 3, 3 ], [ 4 ] ]

#---

o2 = new stzList([
	"X",
	["Y", ["Z", "♥", ["W", "♥"]], "♥"],
	"V",
	"♥"
])

? @@NL( o2.DeepFind("♥") )
#--> [
#	[ 2, 2, 2 ],
#	[ 2, 2, 3, 2 ],
#	[ 2, 3 ],
#	[ 4 ]
# ]

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*----------

profon()

o1 = new stzList([
	"you",
	"other",
	[ "other", "you", [ "you" ], "other" ],
	"other",
	"you"
])

? @@( o1.DeepFind("you") )
#--> [ [ 1 ], [ 3, 2 ], [ 3, 3, 1 ], [ 5 ] ]

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*---------

profon()

o1 = new stzList([
	1,
	"UP",
	[ "UP", 2, "UP" ],
	[ 1, 2, [ "UP" ], 3, [ [ 4, "UP", 5 ] ] ],
	"UP"
])

? @@NL( o1.Lowercased() ) + NL
#--> [
#	1,
#	"up",
#	[ "UP", 2, "UP" ],
#	[ 1, 2, [ "UP" ], 3, [ [ 4, "UP", 5 ] ] ],
#	"up"
# ]

? @@NL( o1.DeepLowercased() )
#--> [
#	1,
#	"up",
#	[ "up", 2, "up" ],
#	[ 1, 2, [ "up" ], 3, [ [ 4, "up", 5 ] ] ],
#	"up"
# ]

proff()
# Executed in 0.01 second(s) in Ring 1.22

/*---------

profon()

o1 = new stzList([
	1,
	"up",
	[ "up", 2, "up" ],
	[ 1, 2, [ "up" ], 3, [ [ 4, "up", 5 ] ] ],
	"up"
])

? @@NL( o1.Uppercased() ) + NL
#--> [
#	1,
#	"UP",
#	[ "up", 2, "up" ],
#	[ 1, 2, [ "up" ], 3, [ [ 4, "up", 5 ] ] ],
#	"UP"
# ]

? @@NL( o1.DeepUppercased() )
#--> [
#	1,
#	"UP",
#	[ "UP", 2, "UP" ],
#	[ 1, 2, [ "UP" ], 3, [ [ 4, "UP", 5 ] ] ],
#	"UP"
# ]
proff()
# Executed in 0.01 second(s) in Ring 1.22

/*--------- #todo add #quicker

profon()

o1 = Q('[ [ 1, 2, 3 ], [ "B", [ 1, 2, 3 ] ], [ "C", "D", [ 1, 2, 3 ] ], [ 1, 2, 3 ] ]')

? o1.AllRemovedExcept([ "[", "]" ])
#--> "[[][[]][[]][]]"

proff()
# Executed in 0.08 second(s) in Ring 1.22

/*-----------

profon()
/*
o1 = new stzList([
	"A",
	[ "B", "♥" ],
	[ "C", "D", "♥" ],
	"♥"
])

? @@(o1.DeepFind("♥")) + NL
#--> [ [ 2, 2 ], [ 3, 3 ], 4 ]

/*----

o1 = new stzList([
	1:3,
	[ "B", 1:3 ],
	[ "C", "D", 1:3 ],
	1:3
])

? @@(o1.DeepFind(1:3))
#--> [ [ 2, 2 ], [ 3, 3 ], 4 ]

proff()

/*---

profon()

o1 = new stzString("RIxxNxG")
? o1.@All("x").@Removed()
#--> RING

? o1.@All("z").@Removed()
#--> RIxxNxG

proff()

/*----

profon()

? isNull("")
#--> TRUE

? isNull(_NULL_)

? isTrue("") #TODO // Should rerurn TRUE

proff()

/*----

profon()


o1 = new stzString("abracadabra")

o1.ReplaceManyNthSubStrings([
	[ 1, 'a', :with = 'A' ],
	[ 2, 'a', :with = 'B' ],
	[ 4, 'a', :with = 'C' ],
	[ 5, 'a', :with = 'D' ],

	[ 1, 'b', :with = 'E' ],
		[ 2, 'r', :with = 'F' ]
])


? o1.Content()
# AErBcadCbFD


proff()
# Executed in 0.04 second(s) in Ring 1.22

/*---

profon()

# Given the string: "abracadabra", replace programatically:
#
#	the first 'a' with 'A'
#	the second 'a' with 'B'
#	the fourth 'a' with 'C'
#	the fifth 'a' with 'D'
#	the first 'b' with 'E'
#	the second 'r' with 'F'
#
# The answer should, of course, be : "AErBcadCbFD".

Q("abracadabra") {

	ReplaceNth(5, 'a', :with = 'D')
	ReplaceNth(4, 'a', :with = 'C')
	ReplaceNth(2, 'a', :with = 'B')
	ReplaceNth(1, 'a', :with = 'A')

	ReplaceNth(1, 'b', :with = 'E')
	ReplaceNth(2, 'r', :with = 'F')

	? Content()
	#--> AErBcadCbFD
}

proff()
# Executed in 0.01 second(s) in Ring 1.21

/*---

profon()

Q("abracadabra") {
	ReplaceManyNthSubStrings([
		[ 1, 'a', :with = 'A' ],
		[ 2, 'a', :with = 'B' ],
		[ 4, 'a', :with = 'C' ],
		[ 5, 'a', :with = 'D' ],
	
		[ 1, 'b', :with = 'E' ],
		[ 2, 'r', :with = 'F' ]
	])

	? Content()
}

proff()

/*--- #TODO

profon()

Naturally() {
	Given the string "abracadabra" replace programatically

		the first 'a' with 'A'
		the second 'a' with 'B'
		the fourth 'a' with 'C'
		the fifth 'a' with 'D'
		the first 'b' with 'E'
		the second 'r' with 'F'

	The answer should of course be "AErBcadCbFD"
}

proff()

