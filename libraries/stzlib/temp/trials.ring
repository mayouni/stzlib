load "../stzlib.ring"

/*----------
*/
pron()

o1 = new stzString("phpringringringpythonrubyruby")

? o1.NumberOfConsecutiveSubStringsOfNChars(4) + NL
#--> 26

? o1.ConsecutiveSubStringsOfNChars(4)
#--> [
#	"phpr", "ingr", "ingr", "ingp", "ytho", "nrub", "yrub",
#	"hpri", "ngri", "ngri", "ngpy", "thon", "ruby", "ruby",
#	"prin", "grin", "grin", "gpyt", "honr", "ubyr", "ring",
#	"ring", "ring", "pyth", "onru", "byru"
# ]


? o1.FindConsecutiveSubStringsOfNChars(4)
#--> [ 1, 2, 3, 4 ]

? @@NL( o1.FindConsecutiveSubStringsOfNCharsZZ(4) ) + NL
#--> [
#	[ 1, 4 ], [ 5, 8 ], [ 9, 12 ], [ 13, 16 ], [ 17, 20 ], [ 21, 24 ], [ 25, 28 ],
#	[ 2, 5 ], [ 6, 9 ], [ 10, 13 ], [ 14, 17 ], [ 18, 21 ], [ 22, 25 ], [ 26, 29 ],
#	[ 3, 6 ], [ 7, 10 ], [ 11, 14 ], [ 15, 18 ], [ 19, 22 ], [ 23, 26 ],
#	[ 4, 7 ], [ 8, 11 ], [ 12, 15 ], [ 16, 19 ], [ 20, 23 ], [ 24, 27 ]
# ]

? @@( o1.ConsecutiveSubStringsOfNCharsZ(4) ) + NL
#--> [
#	[ "phpr", 1 ], [ "ingr", 5 ], [ "ingr", 9 ], [ "ingp", 13 ], [ "ytho", 17 ],
#	[ "nrub", 21 ], [ "yrub", 25 ], [ "hpri", 2 ], [ "ngri", 6 ], [ "ngri", 10 ],
#	[ "ngpy", 14 ], [ "thon", 18 ], [ "ruby", 22 ], [ "ruby", 26 ], [ "prin", 3 ],
#	[ "grin", 7 ], [ "grin", 11 ], [ "gpyt", 15 ], [ "honr", 19 ], [ "ubyr", 23 ],
#	[ "ring", 4 ], [ "ring", 8 ], [ "ring", 12 ], [ "pyth", 16 ], [ "onru", 20 ],
#	[ "byru", 24 ]
# ]

? @@( o1.ConsecutiveSubStringsOfNCharsZZ(4) )
#--> [
#	[ "phpr", [ 1, 4 ] ], [ "ingr", [ 5, 8 ] ], [ "ingr", [ 9, 12 ] ],
#	[ "ingp", [ 13, 16 ] ], [ "ytho", [ 17, 20 ] ], [ "nrub", [ 21, 24 ] ],
#	[ "yrub", [ 25, 28 ] ], [ "hpri", [ 2, 5 ] ], [ "ngri", [ 6, 9 ] ],
#	[ "ngri", [ 10, 13 ] ], [ "ngpy", [ 14, 17 ] ], [ "thon", [ 18, 21 ] ],
#	[ "ruby", [ 22, 25 ] ], [ "ruby", [ 26, 29 ] ], [ "prin", [ 3, 6 ] ],
#	[ "grin", [ 7, 10 ] ], [ "grin", [ 11, 14 ] ], [ "gpyt", [ 15, 18 ] ],
#	[ "honr", [ 19, 22 ] ], [ "ubyr", [ 23, 26 ] ], [ "ring", [ 4, 7 ] ],
#	[ "ring", [ 8, 11 ] ], [ "ring", [ 12, 15 ] ], [ "pyth", [ 16, 19 ] ],
#	[ "onru", [ 20, 23 ] ], [ "byru", [ 24, 27 ] ] 
# ]

proff()
# Executed in 0.01 second(s).

/*-----------
*/
pron()

o1 = new stzString("phpringringringpythonrubyruby")
? o1.NumberOfConsecutiveSubStrings()
#--> 315

? o1.ConsecutiveSubStrings()

proff()
# Executed in 0.01 second(s).

/*-----------

pron()

# Example usage:
/*
str = "abcdefghi"
chunks = ConsecutiveSubStringsOfNChars(str, 2)
? chunks  # Output: ["ab", "cd", "ef", "gh", "bc", "de", "fg", "hi"]

str = "Hello"
chunks = ConsecutiveSubStringsOfNChars(str, 2)
? chunks  # Output: ["He", "ll", "el", "lo"]

str = "123456789012"
? ConsecutiveSubStringsOfNChars(str,3)
*/
pron()

str = "phpringringringpythonrubyruby"
? ConsecutiveSubStringsOfNChars(str, 4)

proff()

func ConsecutiveSubStringsOfNChars(str, n)

    if not isString(str) return [] ok
    if not isNumber(n) return [] ok
    if n <= 0 return [] ok
    if n > len(str) return [] ok
    
    aResult = []

   for i = 1 to n
	    # First pass - starting from position 1
	    for j = i to len(str) step n
	        if j + n - 1 <= len(str)
	            add(aResult, substr(str, j, n))
	        ok
	    next

   next

    return aResult

