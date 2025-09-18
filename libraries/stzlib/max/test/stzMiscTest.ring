load "../stzmax.ring"

#NOTE Most of the tesyt samples of Path Managemnt in stzList
# are here in this file #TODO Relocate them to stzListTest or
# stzListPaths.ring files

/*=====

pr()

o1 = new stzString("rixxnxg")  

? o1.RemoveQ("x").  
     ReplaceQ("i", :With = AHeart()).
     UppercaseQ().
     Spacified()

#--> R ♥ N G  

# The original object remains intact  
? o1.Content()  
#--> "R♥NG"

pf()
# Executed in 0.01 second(s) in Ring 1.22

/*-----

pr()

o1 = new stzString("rixxnxg")

? o1.RemoveQC("x").
     ReplaceQ("i", :With = AHeart()).
     UppercaseQ().
     Spacified()

#--> R ♥ N G

# The original object remains intact
? o1.Content()
#--> "rixxnxg"

pf()
# Executed in 0.01 second(s) in Ring 1.22

/*=====

pr()

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

pf()
# Executed in almost 0.08 second(s) in Ring 1.22

/*============

pr()

? RingVersion()
#--> "1.22"

? StzVersion()
#--> "0.9"

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*------

pr()

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

? "Largest lists:" + NL

? @@( o1.ListsSizes() )
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

? @@( o1.ShortestLists() )
#--> [ [ 1 ], [ 2 ], [ 3 ], [ 4 ] ]

pf()
# Executed in 0.01 second(s) in Ring 1.22


/*------ #Misspelled forms

pr()

? Q("   Ring ").WithoutSapces()
#--> Ring

? Q("bla {♥♥♥} blaba bla {♥♥♥} blabla").FindLasteAsSection("♥♥♥")
#--> [ 22, 24 ]

? QQ([ 2, 7, 18, 18, 10, 12, 25, 4 ]).NearstTo(10)
#--> 12

pf()
# Executed in 0.03 second(s) in Ring 1.22

/*==== PATHS MANAGEMENT

pr()

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

pf()
# Executed in 0.10 second(s) in Ring 1.22

/*------

pr()

o1 = new stzList([
	"item1",
	[ "item21", [ "item221", "item222" ], "item23" ],
	[ "item31", [ "item321" ] ],
	"item4"
])

? @@( o1.LargestPaths() )
#--> [ [ 2, 2, 1 ], [ 2, 2, 2 ], [ 3, 2, 1 ] ]

pf()
# Executed in 0.10 second(s) in Ring 1.22

/*------

pr()

o1 = new stzList([
	"item1",
	[ "item21", [ "item221", "item222" ], "item23" ],
	[ "item31", [ "item321" ] ],
	"item4"
])

? @@( o1.ShortestPaths() )
#--> [ [ 1 ], [ 2 ], [ 3 ], [ 4 ] ]

pf()
# Executed in 0.09 second(s) in Ring 1.22

/*------

pr()

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

pf()
# Executed in 0.46 second(s) in Ring 1.22

/*------

pr()

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

pf()
# Executed in 0.14 second(s) in Ring 1.22

/*------

pr()

o1 = new stzList([
	"item1",
	[ "item21", [ "item221", "item222" ], "item23" ],
	[ "item31", [ "item321" ] ],
	"item4"
])

? @@( o1.ItemsAtPaths([
	[ 2, 2, 2 ],
	[ 3, 1 ],
	[ 4 ]
]) )
#--> [ "item222", "item31", "item4" ]

? @@NL( o1.ItemsAtPathsZZ([ #TODO // Fix indentation
	[ 2, 2, 2 ],
	[ 3, 1 ],
	[ 4 ]
]) )
#--> [
#	[ "item222", [ 2, 2, 2 ] ],
#	[ "item31", [ 3, 1 ] ],
#	[ "item4", [ 4 ] ]
# ]

pf()
# Executed in 0.39 second(s) in Ring 1.22

/*=====

pr()

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

pf()
# Executed in 0.01 second(s) in Ring 1.22

/*=====

pr()

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

pf()
#--> Executed in 0.02 second(s) in Ring 1.22

/*-----

pr()

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

? @@( Intersection(aLists) )
#--> [ "banana", "orange" ]

? @@( Intersection([]) )
#--> [ ]

? @@( Intersection([ [1] ]) )
#--> [ 1 ]

aLists = [
	[ "apple", "banana", "orange", 1:3 ],
	[ "banana", 1:3, "orange", "grape" ],
	[ "orange", "grape", 1:3, "banana" ]
]

? @@NL( Intersection(aLists) )
#--> [
#	"banana",
#	"orange",
#	[ 1, 2, 3 ]
# ]

pf()
# Executed in 0.04 second(s) in Ring 1.22

/*-----

pr()

# All the examples return the same result, but they
# show the power and flexibility of finding items
# in singular or plural in a path or many paths

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

pf()
# Executed in 0.26 second(s) in Ring 1.22

/*=== REMOVING ITEMS AT PATHS

pr()

o1 = new stzList([
	"A",
	[ "B", "C", "♥", "D" ],
#          ^
	"E"
])

o1.RemoveItemAtPath("♥", [2, 3])

? @@NL( o1.Content() )
#--> [
#	"A",
#	[ "B", "C", "D" ],
#	"E"
# ]

pf()
# Executed in 0.16 second(s) in Ring 1.22

/*---

pr()

o1 = new stzList([
	"A",
	[ "B", "C", "D" ],
	"♥"
])

o1.RemoveItemAtPath("♥", [3])

? @@NL( o1.Content() )
#--> [
#	"A",
#	[ "B", "C", "D" ]
# ]

pf()
# Executed in 0.16 second(s) in Ring 1.22

/*---

pr()

o1 = new stzList([
	"A",
	[ "B", "C", "D" ],
	[ "♥" ]
])

o1.RemoveItemAtPath("♥", [ 3, 1 ])

? @@NL( o1.Content() )
#--> [
#	"A",
#	[ "B", "C", "D" ],
#	[ ]
# ]

pf()
# Executed in 0.16 second(s) in Ring 1.22

/*---

pr()

o1 = new stzList([
	"A",
	[ "B", "C" ],
	[ "♥", 2 ]
])

o1.RemoveItemAtPath("♥", [ 3, 1 ])

? @@NL( o1.Content() )
#--> [
#	"A",
#	[ "B", "C" ],
#	[ 2 ]
# ]

pf()
# Executed in 0.19 second(s) in Ring 1.22

/*---

pr()

o1 = new stzList([
	"A",
	[ "B", [ "C", "♥", "D", "*", "♥", "*" ], "E", "F" ],
	"G"
])

o1.RemoveItemsInPath([ "♥", "*" ], [ 2, 2, 6 ])

? @@( o1.Content() )
#--> [ "A", [ "B", [ "C", "D" ], "E", "F" ], "G" ]

pf()
# Executed in 0.16 second(s) in Ring 1.22

/*----

pr()

o1 = new stzList([
	"A",
	[ "B", [ "C", "D", "♥" ], "E" ],
	"F",
	[ "♥", "G" ]
])

o1.RemoveItemAtPaths("♥", [ [2, 2, 3], [4, 1] ])

? @@NL( o1.Content() )
#--> [
#	"A",
#	[ "B", [ "C", "D" ], "E" ],
#	"F",
#	[ "G" ]
# ]

pf()
# Executed in 0.28 second(s) in Ring 1.22

/*----

pr()

o1 = new stzList([ 1, 2, "♥", 4, 5 ])

o1.RemoveThisItemAtPosition("♥", 5)
? @@( o1.Content() )
#--> [ 1, 2, "♥", 4, 5 ]

o1.RemoveThisItemAtPosition("♥", 3)
? @@( o1.Content() )
#--> [ 1, 2, 4, 5 ]

pf()
# Executed in 0.01 second(s) in Ring 1.22

/*----

pr()

o1 = new stzList([ 1, 2, "♥", 4, "♥", 6, "♥" ])

o1.RemoveThisItemAtPositions("♥", [ 3, 7 ])
? @@( o1.Content() )
#--> [ 1, 2, 4, "♥", 6 ]

pf()
# Executed in 0.01 second(s) in Ring 1.22

/*----

pr()

o1 = new stzList([ 1, 2, "♥", 4, "*", 6, "♥" ])

o1.RemoveTheseItemsAt([ "♥", "*"], [ 3, 5, 7 ])
? @@( o1.Content() )
#--> [ 1, 2, 4, 6 ]

pf()
# Executed in 0.02 second(s) in Ring 1.22

/*----

pr()

o1 = new stzList([
	"A",
	[ "B", [ "C", "♥", "D" ], "E", "F" ],
	"G",
	[ "H", "I", "*" ]
])

? @@NL( o1.FindItemsAtPaths([ "♥", "*" ],  [ [2, 2, 2], [4, 3] ]) ) + nl
#--> [
#	[ 2, 2, 2 ],
#	[ 4, 3 ]
# ]

? @@( o1.ItemsAtPaths([ [ 2, 2, 2 ], [ 4, 3 ]]) )
#--> [ "♥", "*" ]

o1.RemoveItemsAtPaths([ "♥", "*" ], [ [2, 2, 2], [4, 3] ])

? @@NL( o1.Content() )
#--> [
#	"A",
#	[
#		"B",
#		[ "C", "D" ],
#		"E",
#		"F"
#	],
#	"G",
#	[ "H", "I" ]
# ]

pf()
# Executed in 0.84 second(s) in Ring 1.22

/*===

pr()

o1 = new stzList([ "A", [], "B" ])

? @@( o1.Paths() )
#--> [ [ 1 ], [ 2 ], [ 2, 1 ], [ 3 ] ]

? o1.ItemAtPath([1])
#--> "A"

? @@( o1.ItemAtPath([2]) )
#--> [ "" ] # Actually there is no "" inside [], but from
	    # "PATH"-semantic perspective, [""] should
	    # mean that there is no item at all at this path

? o1.ItemAtPath([3])
#--> "B"

pf()
# Executed in 0.17 second(s) in Ring 1.22

/*---

pr()

o1 = new stzList([
    "A",
    [ "♥", "B", "♥", [], "C" ], #NOTE //[] is replaced internally with [NULL]
    "D"				# Otherwise path parsing won't work correctly!
])

? @@NL( o1.Paths() ) + NL
#--> [
#	[ 1 ],
#	[ 2 ],
#
#	[ 2, 1 ],
#	[ 2, 2 ],
#	[ 2, 3 ],
#	[ 2, 4 ],
#	[ 2, 4, 1 ],
#	[ 2, 5 ],
#
#	[ 3 ]
# ]

? @@( o1.FindInPath("♥", [ 2, 5 ]) )
#--> [ [ 2, 1 ], [ 2, 3 ] ]

? @@( o1.FindInPath("♥", [ 2, 1 ]) )
#--> [ [ 2, 1 ] ]

? @@( o1.FindAtPath("♥", [ 2, 4 ]) )
#--> [ ]

pf()
# Executed in 0.22 second(s) in Ring 1.22

/*---

pr()

o1 = new stzList([ 1, "♥", [ 3, "♥" ], 4 ])

? @@( o1.Paths() )
#--> [ [ 1 ], [ 2 ], [ 3 ], [ 3, 1 ], [ 3, 2 ], [ 4 ] ]

? @@( o1.Path([3]) ) # or PathTo([3])
#--> [ [ 1 ], [ 2 ], [ 3 ] ]

? @@( o1.FindInPath("♥", [3]) )
#--> [ [ 2 ] ]

pf()
# Executed in 0.15 second(s) in Ring 1.22

/*=== REMOVING ITEMS OVER PATHS

pr()

o1 = new stzList([
    "A",
    [ "♥", ["B", "♥", "C", "♥" ], "♥", "D" ],
    "E"
])

? @@( PathsIn([2, 2]) ) + NL
#--> [ [ 2 ], [ 2, 2 ] ]

? @@( o1.FindInPath("♥", [ 2, 2 ]) ) + NL
#--> [ [ 2, 1 ] ]

o1.RemoveItemInPath("♥", [2, 2])
#NOTE All these paths are concerned:
# [ [ 2, 1 ], [ 2, 3 ], [ 2, 2, 2 ], [ 2, 2, 4 ] ]

? @@( o1.Content() )
#--> [ "A", [ [ "B", "♥", "C", "♥" ], "♥", "D" ], "E" ]

pf()
# Executed in 0.20 second(s) in Ring 1.22

/*----

pr()

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
#--> "A"

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

//? o1.NthItemInPath(7, [3])
#--> ERROR: Incorrect param value! n must be within the size of the path.

pf()
# Executed in 0.92 second(s) in Ring 1.22

/*----

pr()

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

pf()
# Executed in 0.32 second(s) in Ring 1.22

/*----

pr()


o1 = new stzList([
    	"A",
    	[ "♥", "B", [ "C", "♥", "D", "♥" ], "♥", "E", "♥" ],
    	"E"
])

? @@( o1.ItemAtPath([2,3,4]) )
#--> "♥"

? o1.ItemExistsAtPath("♥", [ 2, 3, 4 ]) + NL
#--> TRUE

# Many paths

? @@( o1.ItemsAtPaths([[2,3,4]]) )
#--> [ "♥" ]

? o1.ItemExistsAtPaths("♥", [[ 2, 3, 4 ]])
#--> TRUE

pf()
# Executed in 0.25 second(s) in Ring 1.22

/*----

pr()


o1 = new stzList([
    	"A",
    	[ "♥", "B", [ "C", "♥", "D", "♥" ], "♥", "E", "♥" ],
    	"E"
])


? @@( o1.PathTo([ 2 ]) ) # Or Path()
#--> [ [ 2 ] ]

? @@( o1.FindItemAtPath("♥", [ 2, 2 ]) ) + NL
#--> [ [ 2, 1 ], [ 2, 4 ], [ 2, 6 ] ]

? @@NL( o1.PathTo([ 2, 3, 4 ]) ) + NL
#--> [
#	[ 2 ],
#	[ 2, 3 ],
#	[ 2, 3, 4 ]
# ]

? @@( o1.ItemsAtPaths([[2,3,4]]) )
#--> [ "♥" ]

? o1.ItemExistsAtPaths("♥", [[ 2, 3, 4 ]])
#--> TRUE

? @@( o1.FindItemAtPath("♥", [ 2, 3, 4 ]) ) + NL
#--> [ 2, 3, 4 ]

? o1.ItemExistsAtPath("X", [ 2, 3, 4 ])
#--> FALSE

? @@( o1.FindItemAtPath("X", [ 2, 3, 4 ]) )
#--> [ ]

pf()
# Executed in 0.40 second(s) in Ring 1.22

/*----

pr()


o1 = new stzList([
    	"A",
    	[ "♥", "B", [ "C", "♥", "D", "♥" ], "♥", "E", "♥" ],
    	"E"
])

? @@( o1.FindItemAtPath("♥", [ 2, 3, 4 ]) )
#--> [ 2, 3, 4 ]

? @@( o1.FindAnyOfTheseItemsAtPath([ "♥", "X", "Y" ], [ 2, 3, 4 ]) )
#--> [ 2, 3, 4 ]

? @@( o1.FindAnyOfTheseItemsAtPath([ "X", "Y", "Z" ], [ 2, 3, 4 ]) )
#--> [ ]

pf()
# Executed in 0.37 second(s) in Ring 1.22

/*----

pr()


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

pf()
# Executed in 0.38 second(s) in Ring 1.22

/*----

pr()


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

pf()
# Executed in 0.38 second(s) in Ring 1.22

/*----

pr()


o1 = new stzList([
    "A",
    [ "♥", "B", [ "C", "♥", "D", "♥" ], "♥", "E", "♥" ],
    "E"
])

? @@NL( o1.PathTo([2, 2]) ) + NL
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

pf()
# Executed in 0.24 second(s) in Ring 1.22

/*---- #todo #narration finding an item over a given path
# using DeepFind(), PathsUpTo, and Intersection

pr()

o1 = new stzList([
    "A",
    [ "♥", "B", [ "C", "♥", "D", "♥" ], "♥", "E", "♥" ],
    "E"
])

aItemPaths = o1.DeepFind("♥")
? @@NL(aItemPaths) + nl
#--> [
#	[ 2, 1 ],
#	[ 2, 3, 2 ],
#	[ 2, 3, 4 ],
#	[ 2, 4 ],
#	[ 2, 6 ]
# ]

aAllPaths = o1.PathsUpTo([2, 3, 2]) # Or Path() or PathTo() or PathsTo()
? @@NL(aAllPaths) + nl
#--> [
#	[ 2 ],
#	[ 2, 3 ],
#	[ 2, 3, 2 ]
# ]

? @@( @Intersection([ aItemPaths, aAllPaths ]) )
#--> [ [ 2, 3, 2 ] ]

#UPDATE! Now you can find it simply in one line:

? @@( o1.FindInPath("♥", [2, 3]) )
#--> [ [ 2, 1 ] ]

pf()
# Executed in 0.14 second(s) in Ring 1.22

/*----

pr()

? IsSubPathOf( [2], [2, 3, 4])

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*-----

pr()

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

pf()
# Executed in 0.24 second(s) in Ring 1.22

/*-----

pr()

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

pf()
# Executed in 0.19 second(s) in Ring 1.22

/*-----

pr()

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

? @@NL( o1.ExpandThesePaths([ [2, 3], [3] ]) )
#--> [
#	[ 2, 3 ],
#	[ 2, 3, 1 ],
#	[ 2, 3, 2 ],
#	[ 2, 3, 3 ],
#	[ 2, 3, 4 ],
#	[ 3 ]
# ]

pf()
# Executed in 0.31 second(s) in Ring 1.22

/*------

pr()

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

pf()
# Executed in 0.47 second(s) in Ring 1.22

/*------

pr()

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

pf()
# Executed in 0.38 second(s) in Ring 1.22

/*-----

pr()

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

pf()
# Executed in 0.12 second(s) in Ring 1.22

/*-----

pr()

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

pf()
# Executed in 0.12 second(s) in Ring 1.22

/*-----

pr()

o1 = new stzList([
	"A",
	"♥",
	[ "B", "♥", "C" ],
	"D",
    	[ "♥", "E", [ "F", "♥", "G", "♥" ], "♥", "H", "♥" ],
    	"I"
])

? @@( o1.DeepestPath() )		# Or HighestPath() depending on how
#--> [ 6 ]				# you look to the list building ;)

? @@( o1.ShallowestPath() ) + NL	# Or LowestPath()
#--> [ 1 ]

pf()
# Executed in 0.21 second(s) in Ring 1.22

/*----

pr()

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

pf()
# Executed in 0.16 second(s) in Ring 1.22

/*---

pr()

o1 = new stzList([
	"A",
	"♥",
	[ "B", "♥", "C" ],
	"D",
    	[ "♥", "E", [ "F", "♥", "G", "♥" ], "♥", "H", "♥" ],
    	"I"
])

? len( o1.ShortestPath() )
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

pf()
# Executed in 0.12 second(s) in Ring 1.22

/*---

pr()

o1 = new stzList([])

? len( o1.ShortestPath() )
#--> 0

? @@( o1.ShortestPath() )
#--> [ ]

? @@NL( o1.ShortestPaths() ) + NL
#--> [ ]

? len( o1.LongestPath() )
#--> 0

? @@( o1.LongestPath() )
#--> [ ]

? @@NL( o1.LongestPaths() )
#--> [ ]

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*----

pr()

o1 = new stzList([
	"A",
	"♥",
	[ "B", "♥", "C" ],
	"D",
    	[ "♥", "E", [ "F", "♥", "G", "♥" ], "♥", "H", "♥" ],
    	"I"
])

? @@( o1.LengthOfLongestPath() )
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

pf()
# Executed in 0.14 second(s) in Ring 1.22

/*---- #TODO #narration #seantic-precision PATHS SEMANTICS

# Depth   -> DeepestPath()	or HighestPath() depending on the  observer perpspective
#	  VS ShallowestPath()	or LowestPath()

# Length  -> LongestPath() VS ShortestPath()

// Add examples here

/*====

pr()

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

pf()
# Executed in 0.18 second(s) in Ring 1.22

/*-----

pr()

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
#	[ 6, 3, 3 ],
#	[ 6, 3, 5 ],
#	[ 6, 4 ],
#	[ 6, 6 ]
# ]

pf()
# Executed in 0.14 second(s) in Ring 1.22

/*-----

pr()

o1 = new stzList([
    	"A",
	"B",
    	[ "♥", "C", [ "D", "♥", "E", "♥" ], "♥", "F", "♥" ],
    	"G"
])

? o1.ItemExistsInPath("♥", [ 3, 2 ])
#--> TRUE

? o1.ContainsItemInPath("♥", [ 3, 2 ])
#--> TRUE

? o1.ItemExistsInPaths("♥", [ [ 3, 2 ], [ 3, 3 ] ])
#--> TRUE

? o1.ContainsItemInPaths("♥", [ [ 3, 2 ], [ 3, 3 ] ])
#--> TRUE

? o1.ItemsExistInPath([ "♥" ], [ 3, 2 ])
#--> TRUE

? o1.ContainsItemsInPath([ "♥" ], [ 3, 2 ])
#--> TRUE

? o1.ItemsExistInPaths([ "♥" ], [ [ 3, 2 ] ])
#--> TRUE

? o1.ContainsItemsInPaths([ "♥" ], [ [ 3, 2 ] ])
#--> TRUE

# The fellowing are not implemented yet

# ? o1.ItemExistsInAllNodesOfPath("♥", [ 3, 2 ]) 			#TODO
# ? o1.ContainsItemInAllNodesOfPath("♥", [ 3, 2 ]) 			#TODO
# ? o1.ItemExistsInAllNodesOfPaths("♥", [ [ 3, 2 ], [ 3, 3 ] ])		#TODO
# ? o1.ContainsItemInAllNodesOfPaths("♥", [ [ 3, 2 ], [ 3, 3 ] ])	#TODO

pf()
# Executed in 0.55 second(s) in Ring 1.22

/*----

pr()

o1 = new stzList([
    	"A",
	"B",
    	[ "♥", "C", [ "D", "♥", "E", "♥" ], "♥", "F", "♥" ],
    	"G"
])

? @@( o1.FindItemInPaths("♥", [ [1], [2] ]) )
#--> []

? @@( o1.FindItemInPaths("♥", [ [1], [2], [3] ]) )
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

pf()
# Executed in 0.40 second(s) in Ring 1.22

/*---

pr()

o1 = new stzList([
    "A",
    [ "♥", "B", [ "C", "♥", "D", "♥" ], "♥", "E", "♥" ],
    "E"
])

? @@NL(o1.Paths())
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

? o1.IsValidPath([ 2, 3, 3 ])
#--> TRUE

? o1.AreValidPaths([ [ 2, 1 ], [ 2, 3, 2 ] ])
#--> TRUE

pf()
#--> Executed in 0.12 second(s) in Ring 1.22

/*---

pr()

o1 = new stzList([
    "A",
    [ "♥", "B", [ "C", "♥", "D", "♥" ], "♥", "E", "♥" ],
    "E"
])

? @@NL(PathsTo([2, 3, 3]))
#--> [
#	[ 2 ],
#	[ 2, 3 ],
#	[ 2, 3, 3 ]
# ]

? @@NL( o1.PathsTo([2, 3, 3]) )
#--> [
#	[ 2 ],
#	[ 2, 3 ],
#	[ 2, 3, 3 ]
# ]

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*---

pr()

# Finding the position of the smallest number

numbers = [ 7, 8, -2, 5, 3 ]

? FindMin(numbers)
#--> 3

? Min(numbers)
#--> -2

? FindMax(numbers)
#--> 2

? Max(numbers)
#--> 8

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*---

pr()

o1 = new stzList([
    "A",
    [ "♥", "B", [ "C", "♥", "D", "E" ], "♥", "F", "G" ],
    "E"
])

? @@NL( o1.PathsContainingItem("♥") ) # Or simply DeepFind()
#--> [
#	[ 2, 1 ],
#	[ 2, 3, 2 ],
#	[ 2, 4 ]
# ]

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*---

pr()

o1 = new stzList([
    "A",
    [ "♥", "B", [ "C", "♥", "D", "♥" ], "*", "E", "*" ],
    "E"
])

? @@NL( o1.PathsContainingItems([ "♥", "*" ]) ) # Or simpliy DeepFindMany()
#--> [
#	[ 2, 1 ],
#	[ 2, 3, 2 ],
#	[ 2, 3, 4 ],
#	[ 2, 4 ],
#	[ 2, 6 ]
# ]

pf()
# Executed in 0.01 second(s) in Ring 1.22

/*---

pr()

o1 = new stzList([
    "A",
    [ "♥", "B", [ "C", "♥", "D", "♥" ], "*", "E", "*" ],
    "E"
])

? @@NL( o1.FindItemInPath("♥", [ 2, 4 ]) )
#--> [
#	[ 2, 1 ],
#	[ 2, 3, 2 ],
#	[ 2, 3, 4 ]
# ]

pf()
# Executed in 0.12 second(s) in Ring 1.22

/*---

pr()

o1 = new stzList([
    "A",
    [ "♥", "B", [ "C", "♥", "D", "♥" ], "*", "E", "*" ],
    "E"
])

? @@NL( o1.FindItemsInPath([ "♥", "*" ], [ 2, 4 ]) )
#--> [
#	[ 2, 1 ],
#	[ 2, 3, 2 ],
#	[ 2, 3, 4 ],
#	[ 2, 4 ]
# ]

pf()
# Executed in 0.10 second(s) in Ring 1.22

/*---

pr()

aList = [
    "A",
    [ "♥", "B", [ "C", "♥", "D", "*" ], "♥", "E", "*" ],
    "E"
]

del(aList[2][3], 4)
del(aList[2][3], 2)
del(aList[2], 1)

? @@(aList)
#--> [ "A", [ "B", [ "C", "D" ], "♥", "E", "*" ], "E" ]

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*---

pr()

o1 = new stzList([
    "A",
    [ "♥", "B", [ "C", "♥", "D", "*" ], "♥", "E", "*" ],
    "E"
])

? @@( o1.FindItemsInPath([ "♥", "*" ], [2, 3, 4]) )
#--> [ [ 2, 1 ], [ 2, 3, 2 ], [ 2, 3, 4 ] ]

o1.RemoveItemsInPath([ "♥", "*" ], [2, 3, 4])

? @@NL( o1.Content() )
#--> [
#	"A",
#	[
#		"B",
#		[ "C", "D" ],
#		"♥",
#		"E",
#		"*"
#	],
#	"E"
# ]


pf()
# Executed in 0.20 second(s) in Ring 1.22

/*====

pr()

o1 = new stzList([
    "A",
    [ "♥", [ "B", "♥", "C", "♥" ], "♥", "D" ],
    "E"
])

? @@( o1.FindItemsInPath([ "♥", "B" ], [2, 2, 3]) )
#--> [ [ 2, 1 ], [ 2, 2, 1 ], [ 2, 2, 2 ] ]

pf()
# Executed in 0.09 second(s) in Ring 1.22

/*------

pr()

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

pf()
# Executed in 0.09 second(s) in Ring 1.22

/*---

pr()

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

pf()
# Executed in almost 0 second(s) in Ring 1.22

#---

pr()

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

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*---

pr()

# This list will have no common path because of root-level items

o1 = new stzList([
    "A",					# path [1]
    [ "target", [ "B", "target", "C" ] ],	# paths starting with [2]
    "E"						# path [3]
])

? @@( o1.CommonPath() ) + NL
#--> [ ]

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
# to have a common path, the structure needs to force all
# elements through the same "trunk" before branching out.

? o2.IsTree() # Use CommonPath() internally
#--> TRUE

? o1.IsTree()
#--> FALSE

pf()
# Executed in 0.17 second(s) in Ring 1.22

#--

pr()

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

pf()
# Executed in almost 0 second(s) in Ring 1.22

#--

pr()

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


pf()
# Executed in 1.04 second(s) in Ring 1.22

/*--

pr()

# [2,1] is a subpath of [2,1,3] but not of [2,2]

? IsSubPathOf([ 2, 1 ], [ 2, 1, 3 ])
#--> TRUE

? IsSubPathOf([ 2, 1 ], [ 2, 2 ]) + NL
#--> FALSE

pf()
# Executed in 0.01 second(s) in Ring 1.22

/*----

pr()

o1 = new stzList([
	"♥♥♥",
	[ "item21", [ "item221", "♥♥♥" ], "item23" ],
	[ "item3", [ "item31", "♥♥♥" ] ],
	"item4"
])

# Find paths containing specific items
? @@( o1.DeepFind("item221") ) #  Or PathsContaining()
#--> [ [2, 2, 1] ]

# Get item at specific path
? o1.ItemAtPath([2, 2, 1])
#--> "item221"

? @@( o1.DeepFindMany([ "item21", "♥♥♥" ]) ) # Or PathsContainingMany()
#--> [ [ 1 ], [ 2, 1 ], [ 2, 2, 2 ], [ 3, 2, 2 ] ]

? @@( U( o1.ItemsAtPaths([ [ 1 ], [ 2, 1 ], [ 2, 2, 2 ], [ 3, 2, 2 ] ]) ) )
#--> [ "♥♥♥", "item21" ]

pf()
# Executed in 0.37 second(s) in Ring 1.22

/*====

#NOTE Replacing item over paths is not yet implemented.

/*====

pr()

o1 = new stzList([
	"item1",
	[ "item2", ["item3", "item4"], "item5" ],
	[ "item6", ["item7"] ],
	"item8"
])

# Get paths at specific depth

? @@( o1.PathsAtDepth(2) )
#--> [ [ 2, 1 ], [ 2, 2 ], [ 2, 3 ], [ 3, 1 ], [ 3, 2 ] ]

# Get longest and shortest paths

? @@( o1.LongestPath() )
#--> [2, 2, 1]

? @@( o1.ShortestPath() )
#--> [1]

# Validate paths

? o1.IsValidPath([2, 2, 1])
#--> TRUE

? o1.IsValidPath([5, 1])
#--> FALSE

pf()
# Executed in 0.18 second(s) in Ring 1.22

/*====

#NOTE inserting items over paths is not yet implemented.

/*====

pr()

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

pf()
# Executed in 0.02 second(s) in Ring 1.22

/*----

pr()

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

pf()
# Executed in 0.03 second(s) in Ring 1.22


/*==== #TODO Write a Qwicker about it

pr()

c = "‎" # Do you think this is empy? Let's see...

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

? HowMany( InvisibleChars() )
#--> 27

pf()
# Executed in 1 second(s) in Ring 1.22

/*---
*/
pr()

text1 = "Hello World"
text2 = "Hello‎ World​"

# You may thing those two texts are the same, but they don't!

? stzlen(text1)
#--> 11

? stzlen(text2)
#--> 13

# In fact, the second text contains some invisible chars

StzStringQ(text2) {

	? ContainsInvisibleChars()
	#--> TRUE

	? @HowMany( InvisibleChars() ) + NL
	#--> 1

	? @@( FindInvisibleChars() )
	#--> [ 6, 13 ]

	? QQ(InvisibleChars()).Names()
	#--> [ "LEFT-TO-RIGHT MARK", "ZERO WIDTH SPACE" ]

	RemoveInvisibleChars()

	? @HowMany( InvisibleChars() )
	#--> 0
}

# Replacing invisible chars by a visible char

Q(text2) { ReplaceInvisibleChars(:With = "*") ? Content() }
#--> Hello* World*

pf()
# Executed in 0.64 second(s) in Ring 1.22

/*===

pr()

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


pf()
# Executed in almost 0 second(s) in Ring 1.22

/*----

pr()

o1 = new stzList([ 1, "♥", 3, 4, "♥", 6 ])

? o1.ExistsInPositions("♥", [ 2, 5 ])
#--> TRUE

? o1.ExistsAt("♥", 5)
#--> TRUE

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*----

pr()

aList = [
	[ 1, 2, 3 ],
	[ "B", [ 1, 2, 3 ] ],
	[ "C", [  [ 1, 2, 3 ], "F" ], "D", [ 1, 2, 3 ] ],
	"G",
	[ 1, 2, 3 ]
]

? @@( Q(aList).DeepFind([ 1, 2, 3 ]) )
#--> [ [ 1 ], [ 2, 2 ], [ 3, 2, 1 ], [ 3, 4 ], [ 5 ] ]

pf()
# Executed in 0.06 second(s) in Ring 1.22

/*----

pr()

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

pf()
# Executed in 0.12 second(s) in Ring 1.22

/*----- #todo #narration STRINGIFY VS DEEP-STRINGIFY

pr()

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
# ...
 
pf()
# Executed in 0.01 second(s) in Ring 1.22

/*---------

pr()

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

pf()
# Executed in 0.01 second(s) in Ring 1.22

/*----------

pr()

o1 = new stzList([
	"you",
	"other",
	[ "other", "you", [ "you" ], "other" ],
	"other",
	"you"
])

? @@( o1.DeepFind("you") )
#--> [ [ 1 ], [ 3, 2 ], [ 3, 3, 1 ], [ 5 ] ]

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*---

pr()

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

pf()
# Executed in 0.01 second(s) in Ring 1.22

/*---

pr()

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
pf()
# Executed in 0.01 second(s) in Ring 1.22

/*--------- #todo add #quicker

pr()

o1 = Q('[ [ 1, 2, 3 ], [ "B", [ 1, 2, 3 ] ], [ "C", "D", [ 1, 2, 3 ] ], [ 1, 2, 3 ] ]')

? o1.AllRemovedExcept([ "[", "]" ])
#--> "[[][[]][[]][]]"

pf()
# Executed in 0.08 second(s) in Ring 1.22

/*-----------

pr()

o1 = new stzList([
	"A",
	[ "B", "♥" ],
	[ "C", "D", "♥" ],
	"♥"
])

? @@(o1.DeepFind("♥")) + NL
#--> [ [ 2, 2 ], [ 3, 3 ], 4 ]

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*----

pr()

o1 = new stzList([
	1:3,
	[ "B", 1:3 ],
	[ "C", "D", 1:3 ],
	1:3
])

? @@(o1.DeepFind(1:3))
#--> [ [ 2, 2 ], [ 3, 3 ], 4 ]

pf()
# Executed in 0.04 second(s) in Ring 1.22

/*--- #natural-code

pr()

o1 = new stzString("RIxxNxG")
? o1.@All("x").@Removed()
#--> RING

? o1.@All("z").@Removed()
#--> RIxxNxG

pf()
# Executed in 0.06 second(s) in Ring 1.22

/*----

pr()

? isNull("")
#--> TRUE

? isNull(NULL)

//? isTrue("") #TODO // Should rerurn TRUE

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*----

pr()


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

pf()
# Executed in 0.03 second(s) in Ring 1.22

/*---

pr()

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

pf()
# Executed in 0.01 second(s) in Ring 1.21

/*---

pr()

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

pf()
# Executed in 0.03 second(s) in Ring 1.22

/*--- #TODO #natural-code

pr()

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

pf()

