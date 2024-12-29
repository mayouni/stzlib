load "../max/stzmax.ring"

/*-----

profon()

aList1 = [
	"A",
	[ "B", "♥" ],
	[ "C", "D", "♥" ],
	"♥"
]

o1 = new stzList(aList1)
? @@( o1.DeepFind("♥") )

proff()

/*---------
*/
aList1 = [
	"A",
	[ "B", "♥" ],
	[ "C", "D", "♥" ],
	"♥"
]
? @@(DeepFind(aList1, "♥")) + NL
#--> [ [ 2, 2 ], [ 3, 3 ], 4 ]

aList2 = [
	"X",
	["Y", ["Z", "♥", ["W", "♥"]], "♥"],
	"V"
]
? @@(DeepFind(aList2, "♥"))
#--> [ [ 2, [ 2, 2 ] ], [ 2, [ 2, [ 3, 2 ] ] ], [ 2, 3 ] ]

func DeepFind(aList, pItem) #ai #chat-gpt
    outputList = [] // Initialize an empty list to store results

    for i = 1 to len(aList)
        if type(aList[i]) = "LIST"
            subPaths = DeepFind(aList[i], pItem) // Recursively search inner list
            for j = 1 to len(subPaths)
                path = [i] + subPaths[j]
                add(outputList, path)
            next
        else
            if aList[i] = pItem
                add(outputList, i) // Add root-level position as an integer
            ok
        ok
    next

    return outputList







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

