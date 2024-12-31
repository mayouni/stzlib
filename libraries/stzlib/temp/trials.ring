load "../max/stzmax.ring"

/*------

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
*/
profon()

o1 = Q('[ [ 1, 2, 3 ], [ "B", [ 1, 2, 3 ] ], [ "C", "D", [ 1, 2, 3 ] ], [ 1, 2, 3 ] ]')

acTemp = o1.AllRemovedExcept([ "[", "]" ])
#--> "[[][[]][[]][]]"
#--> [ 1, 3, 13, 16, 23, 33, 35, 38, 50, 60, 62, 65, 75, 77 ]

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

/*-------

aList2 = [
	"X",
	["Y", ["Z", "♥", ["W", "♥"]], "♥"],
	"V"
]
? @@(DeepFind(aList2, "♥"))
#--> [ [ 2, [ 2, 2 ] ], [ 2, [ 2, [ 3, 2 ] ] ], [ 2, 3 ] ]

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

/*---

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

