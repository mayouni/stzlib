load "../max/stzmax.ring"

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

	"item4"])
.AllRemovedExcept([ "[", ",", "]" ])

? @@NL( GeneratePaths("[,[,[,],],[,[,]],]") )

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*============

profon()

? RingVersion()
#--> "1.22"

? StzVersion()
#--> "0.9"

proff()

/*============

profon()

# Create a nested list

o1 = new stzList([
	"item1",
	[ "item2", [ "item3", "item4" ], "item5" ],
	[ "item6", [ "item7" ] ],
	"item8"
])

? @@Q(o1.Content()).AllRemovedExcept([ "[", ",", "]" ])
#--> [,[,[,],],[,[]],]

proff()
# Executed in 0.09 second(s) in Ring 1.22

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

? o1.HowManyLargestPaths()
#--> 3

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

? o1.NumberOfShortestPaths()
#--> 4

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
# Executed in 0.22 second(s) in Ring 1.22

/*------

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
# Executed in 0.27 second(s) in Ring 1.22
/*=====

profon()

? @@NL( PathsTo([ 2, 3, 2 ]) ) + NL
#--> [
#	[ 2 ],
#	[ 2, 3 ],
#	[ 2, 3, 2 ]
# ]

? @@NL( PathsToXT([ [ 2, 3 ], [ 2, 3, 2 ], [ 4 ] ]) )
#--> [
#	[ 2 ],
#	[ 2, 3 ],
#	[ 2, 3, 2 ],
#	[ 4 ]
# ]

proff()
# Executed in almost 0 second(s) in Ring 1.22

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
#--> [ 2, 1 ]

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

o1 = new stzList([
    "A",
    [ "♥", ["B", "♥", "C", "♥" ], "♥", "D" ],
    "E"
])

? @@( o1.FindItemOverPath("♥", [2, 2]) )
#--> [ [ 2, 1 ], [ 2, 3 ], [ 2, 2, 2 ], [ 2, 2, 4 ] ]

proff()
# Executed in 0.12 second(s) in Ring 1.22

/*-----

profon()

o1 = new stzList([
    "A",
    [ "♥", [ "B", "♥", "C", "♥" ], "♥", "D" ],
    "E"
])

? @@( o1.FindItemsOverPath([ "♥", "B" ], [2, 2]) )
#--> [ [ 2, 1 ], [ 2, 3 ], [ 2, 2, 2 ], [ 2, 2, 4 ], [ 2, 2, 1 ] ]

proff()
# Executed in 0.17 second(s) in Ring 1.22

/*------
*/
profon()

o1 = new stzList([
	"A",
	[ "♥", [ "B", "♥", "C", "♥" ], "♥", "D" ],
	"E",
	[ "F", "♥", "G", [ "♥" ] ]
])

//? o1.AreValidPaths([ [2, 2], [4, 2] ])
#--> TRUE

? @@( ExpandPaths([ [2, 2], [4, 2] ]) )
#--> [ [ 2 ], [ 2, 2 ], [ 4 ], [ 4, 2 ] ]

? @@( CollapsePaths([ [ 2 ], [ 2, 2 ], [ 4 ], [ 4, 2 ], [ 3, 1 ], [ 3, 1, 2 ] ]) )
#--> [ [ 2 ], [ 4 ], [ 3, 1 ] ]

? @@NL( SortPaths([ [ 2 ], [ 2, 2 ], [ 4 ], [ 4, 2 ], [ 2, 1 ], [ 1 ], [ 3, 1 ], [ 3, 1, 2 ] ]) )
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

//? @@( o1.FindItemOverPaths("♥", [ [2, 2], [4, 2] ]) )
#--> [ [ 2, 1 ], [ 2, 3 ], [ 2, 2, 2 ], [ 2, 2, 4 ], [ 2, 2, 1 ] ]

? @@( PathsSection([ 2 ], [ 2, 3, 1 ]) )
#--> [ [ 2 ], [ 2,3 ], [2, 3, 1] ]

proff()
# Executed in 0.17 second(s) in Ring 1.22

def ReducePaths(paPaths)
    # Returns the shortest unique ancestor paths
    # For example, between [2] and [2,2], we keep [2]
    # Between [3,1] and [3,1,2], we keep [3,1]

    aResult = []
    
    for aPath in paPaths
        bShouldAdd = TRUE
        
        for aOtherPath in paPaths
            if aOtherPath != aPath and
               IsSubPathOf(aOtherPath, aPath)
                # If we find a shorter path that is a prefix of
                # our current path, we skip the current path
                bShouldAdd = FALSE
                exit
            ok
        next
        
        if bShouldAdd
            aResult + aPath
        ok
    next

    return aResult

    func ShortestCommonPaths(paPaths)
		return ReducePaths(paPaths)

    func CollapsePaths(paPaths)
		return ReducePaths(paPaths)

def SortPaths(paPaths)
    # Sorts paths in ascending order based on:
    # 1. Path length (shorter paths come first)
    # 2. Path values at each position

    aResult = paPaths
    
    for i = 1 to len(aResult) - 1
        for j = 1 to len(aResult) - i
            if PathIsGreaterThan(aResult[j], aResult[j+1])
                temp = aResult[j]
                aResult[j] = aResult[j+1]
                aResult[j+1] = temp
            ok
        next
    next

    return aResult


def PathIsGreaterThan(paPath1, paPath2)
        # Helper function for path comparison
        
        n1 = len(paPath1)
        n2 = len(paPath2)
        
        # First compare lengths
        if n1 != n2
            return n1 > n2
        ok
        
        # If same length, compare values at each position
        for i = 1 to n1
            if paPath1[i] != paPath2[i]
                return paPath1[i] > paPath2[i]
            ok
        next
        
        return FALSE

def IsSubPathOf(paShortPath, paLongPath)
    # Returns TRUE if paShortPath is an initial segment of paLongPath
    # Example: [2,1] is a subpath of [2,1,3] but not of [2,2]
    
    if len(paShortPath) >= len(paLongPath)
        return FALSE
    ok
    
    for i = 1 to len(paShortPath)
        if paShortPath[i] != paLongPath[i]
            return FALSE
        ok
    next
    
    return TRUE

def CommonPath(paPaths)
    # Returns the shortest path common to ALL provided paths
    # Example: [ [2,1,3], [2,1,4], [2,2,1] ] -> [2]
    
    if len(paPaths) = 0 return [] ok
    
    # Start with first path as potential common
    aShortestPath = paPaths[1]
    
    # Find shortest path length (since common can't be longer)
    for aPath in paPaths
        if len(aPath) < len(aShortestPath)
            aShortestPath = aPath
        ok
    next
    
    # Try each ancestor length, from longest to shortest
    for n = len(aShortestPath) to 1 step -1
        aCandidate = aShortestPath[1 : n]
        bIsCommon = TRUE
        
        # Check if this ancestor is common to all paths
        for aPath in paPaths
            if aPath[1 : n] != aCandidate
                bIsCommon = FALSE
                exit
            ok
        next
        
        if bIsCommon
            return aCandidate
        ok
    next
    
    return []

def PathsSection(paPath1, paPath2)
    # Returns all paths from paPath1 to paPath2, where paPath1 must be
    # a subpath of paPath2
    # Example: [2] and [2,3,1] -> [ [2], [2,3], [2,3,1] ]
    
    if NOT IsSubPathOf(paPath1, paPath2)
        return []
    ok
    
    aResult = []
    nStart = len(paPath1)
    nEnd = len(paPath2)
    
    for i = nStart to nEnd
        aTemp = []
        for j = 1 to i
            aTemp + paPath2[j]
        next
        aResult + aTemp
    next
    
    return aResult

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

