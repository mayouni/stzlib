load "stzlib.ring"

/*======

pron()

o1 = new stzString("Ring programming language!")
? o1.ContainsSubStringBetween("ram", "prog", "ing")
#--> TRUE

proff()
# Executed in 0.02 second(s)

/*=====

pron()
#                       5     11             26        36    42      50
o1 = new stzString("The <<Ring>> programming <<language>> is >>Waooo!<<")
? o1.FindTheseBounds("<<", ">>")
#--> [ 5, 11, 26, 36 ]

proff()
#--> Executed in 0.01 second(s)

/*---- #narration #generated #ai #gemini

pron()

# The FindTheseBounds(cBound1, cBound2) function helps you locate
# substrings within a larger string that are marked by specific
# starting and ending characters (or substrings).

# These characters are called bounding characters (or substrings).

# Here's how it works:

#~> CASE 1 - MATCHING PAIRS:

	# The function searches for occurrences of the first
	# bounding character (cBound1) followed by the second bounding
	# character (cBound2). It then returns a list containing the
	# starting positions of these matching pairs.
	
	#                           v---v          v-------v
	o1 = new stzString("bla bal <<hi>> bla bla <<there!>>")
	? o1.FindTheseBounds("<<", ">>")
	#--> [ 9, 13, 24, 32 ]
	
	# In this case, both << and >> appear in matching pairs, so the function
	# returns the starting positions of all occurrences.

#~> CASE 2 - IGNORING UNMATCHED ENDINGS:

	# If cBound2 appears before cBound1, that occurrence is ignored.
	# The function prioritizes finding the # first cBound1 and then
	# searches for its matching cBound2.
	
	#                              v---------------v
	o1 = new stzString("bla >> bla << bla bla <<hi!>>")
	? o1.FindTheseBounds("<<", ">>")
	#--> [ 12, 28 ]

	# Here, the initial >> is ignored because it doesn't have a preceding <<.
	# The function finds the first valid pair at position 23 (<<hi!>>) and
	# returns its starting position along with the position of the matching >>.


#~> CASE 3 - SKIPPING NESTED BOUNDINGS:

	# If a cBound1 is found within an existing
	# bounded substring (marked by another cBound1 and cBound2 pair), the
	# inner cBound1 is ignored. The function focuses on finding the outermost
	# cBound1 that has a matching cBound2.
	
	#                   v-------------------------v
	o1 = new stzString("<<bla<< blabal <<hi>> bla >>")
	? o1.FindTheseBounds("<<", ">>")
	#--> [ 1, 20 ]
	
	# The inner << (within "<<bla<<") is ignored because it's part of
	# an unclosed bounding. The function finds the first valid outer
	# pair (<<hi>>) at position 1 and returns its starting position
	# along with the matching >>.
	

proff()
# Executed in 0.02 second(s)

/*---

pron()

o1 = new stzString("bla bal <<<hi>>> bla bla <<<there!>>>")

? @@( o1.FindTheseBounds("<<<", ">>>") )
#--> [ 9, 14, 26, 35 ]

? @@( o1.FindTheseBoundsAsSections("<<<", ">>>") )
#--> [ [ 9, 11 ], [ 14, 16 ], [ 26, 28 ], [ 35, 37 ] ]

#--

o1 = new stzString("bla >>> bla <<< bla bla <<<hi!>>>")

? @@( o1.FindTheseBounds("<<<", ">>>") )
#--> [ 13, 31 ]

? @@( o1.FindTheseBoundsZZ("<<<", ">>>") ) + NL
# [ [ 13, 15 ], [ 31, 33 ] ]

#--

o1 = new stzString("<<<bla<<< blabal <<<hi>>> bla >>>")

? @@( o1.FindTheseBounds("<<<", ">>>") )
#--> [ 1, 23 ]

? @@( o1.FindTheseBoundsZZ("<<<", ">>>") )
#--> [ [ 1, 3 ], [ 23, 25 ] ]

proff()
# Executed in 0.02 second(s)

/*======

pron()
#                         +------.--.--+
#                         |      :  :  |
#                         V      :  :  V
o1 = new stzString("I love the <<Ring>> programming <<language>>!")

? o1.ContainsSubStringBetween("Ring", "love", "program")
#--> TRUE

? o1.Between("love", "program") + NL
#--> " the <<Ring>> "

#--

? o1.ContainsSubStringBoundedBy("Ring", [ "<<", ">>" ])
#--> TRUE


? @@( o1.FindTheseBoundsZZ("<<", ">>") )
#--> [ [ 12, 13 ], [ 18, 19 ], [ 33, 34 ], [ 43, 44 ] ]

? @@( o1.Sections( o1.FindTheseBoundsZZ("<<", ">>") ) ) + NL
#--> [ "<<", ">>", "<<", ">>" ]

#-- 

? @@( o1.FindAnyBoundedBy([ "<<", ">>" ]) )
#--> [ 12, 18, 33, 43 ]

? @@( o1.FindAnyBoundedByZZ([ "<<", ">>" ]) )
#--> [ [ 12, 13 ], [ 18, 19 ], [ 33, 34 ], [ 43, 44 ] ]

? @@( o1.Sections( o1.FindAnyBoundedByZZ([ "<<", ">>" ]) ) ) + NL
#--> [ "<<", ">>", "<<", ">>" ]

proff()
# Executed in 0.04 second(s)

/*======

pron()

o1 = new stzString("I love the <<Ring>> programming <<language>>: <<Ring>> is nice!")


? @@( o1.SubStringsBoundedBy([ "<<", ">>" ]) ) + NL
#--> [ "Ring", "language", "Ring" ]

? @@( o1.FindSubStringsBoundedBy([ "<<", ">>" ]) ) + NL
#--> [ 12, 18, 33, 43, 47, 53 ]

? @@SP( o1.SubStringsBoundedByZ([ "<<", ">>" ]) ) + NL
#--> [
#	[ "Ring",     [ 14, 49 ] ],
#	[ "language", [ 35 ] ]
# ]

? @@SP( o1.SubStringsBoundedByZZ([ "<<", ">>" ]) )
#--> [
#	[ "Ring",     [ [ 14, 17 ], [ 49, 52 ] ] ],
#	[ "language", [ [ 35, 42 ] ] ]
# ]

proff()
# Executed in 0.02 second(s)

#--

pron()
#                                      20
o1 = new stzString("Ring programming language")

? o1.ContainsSubStringBoundedByS("ramm", ["prog", "ing"], 5)
#--> TRUE

? o1.ContainsSubStringBoundedBySD("ramm", [ "prog", "ing" ], :StartingAt = 20, :Going = :Backward)
#--> TRUE

proff()
# Executed in 0.08 second(s)

/*===

pron()

o1 = new stzString("THE START <<ring>> ring <<ring>> THE END")

? o1.NumberOfOccurrenceBetween("ring", "START", "END")
#--> 3

? o1.NumberOfOccurrenceBoundedBy("ring", [ "<<", ">>" ])
#--> 2

? o1.NumberOfSubStringBoundedByS("ring", [ "<<", ">>" ], 5)
#--> 2

proff()
# Executed in 0.06 second(s)

/*===

pron()

o1 = new stzString("THE START <<ring>> ring <<ring>> THE E<<ring>>ND")

? @@( o1.FindSubStringBetween("ring", "START", "END") )
#--> [ ]

proff()
# Executed in 0.01 second(s)

/*---

pron()

o1 = new stzString("THE START <<ring>> ring <<ring>> THE E<<ring>>ND")

? o1.ContainsNOccurrencesOfSubStringBetween(3, "ring", "START", "END")
#--> FALSE

# Becase there is no "END" substring in the string

? o1.ContainsNOccurrencesOfSubStringBetween(3, "ring", "SMART", "THE")
#--> FALSE

# Because there is no "SMART" substring in the string.

proff()
# Executed in 0.02 second(s)

/*---------- #todo #narration

pron()

o1 = new stzString("...<<ring>>...<<ring>>...<<ring>>...")

? o1.ContainsNOccurrenceOfSubStringBoundedBy(2, "ring", [ "<<", ">>" ])
#--> FALSE

? o1.NumberOfOccurrenceOfSubStringBoundedBy("ring", [ "<<", ">>" ])
#--> 3

? o1.ContainsNOccurrenceofSubStringBoundedBy(3, "ring", [ "<<", ">>" ])
#--> TRUE

proff()
# Executed in 0.06 second(s)

/*----------

pron()

o1 = new stzString("THE START <<ring>> ring <<ring>> THE E<<ring>>ND")

? o1.ContainsNOccurrencesOfSubStringboundedBy(3, "ring", [ "<<", ">>" ])
#--> TRUE

? o1.ContainsNOccurrencesOfSubStringBoundedByS(3, "ring", [ "<<", ">>" ], :StartingAt = 5)
#--> TRUE

#--

? o1.NumberOfOccurrenceOfSubStringBoundedByS("ring", [ "<<", ">>" ], :StartingAt = 34)
#--> 1

? o1.ContainsNOccurrencesOfSubStringBoundedByS(1, "ring", [ "<<", ">>" ], :StartingAt = 34)
#--> TRUE

proff()
# Executed in 0.09 second(s)

/*===

pron()

o1 = new stzString("THE START <<ring>> ring <<ring>> _ring_ THE END")

? @@( o1.FindSubStringBetween("ring", "START", "END") )
#--> [ 13, 20, 27, 35 ]

? @@( o1.FindSubstringBoundedBy("ring", [ "<<", ">>" ]) )
#--> [ 13, 27 ]

? @@( o1.FindSubstringBoundedBy("ring", "_") ) + NL
#--> [ 35 ]

? @@( o1.FindSubStringBetweenZZ("ring", "START", "END") ) + NL
#--> [ [ 13, 16 ], [ 20, 23 ], [ 27, 30 ], [ 35, 38 ] ]

? @@( o1.FindSubStringBoundedByZZ("ring", ["<<", ">>" ]) ) + NL
#--> [ [ 13, 16 ], [ 27, 30 ] ]

? @@( o1.FindSubStringBoundedByZZ("ring", "_") ) + NL
#--> [ [ 35, 38 ] ]


proff()
# Executed in 0.06 second(s)

/*---

pron()
#                             11            25
#                             v             v
o1 = new stzString("THE START <<ring>> ring <<ring>> _ring_ THE END")

? @@( o1.FindSubStringBoundedByIB("ring", ["<<", ">>"]) ) + NL
#--> [ 11, 25 ]

proff()
# Executed in 0.04 second(s)

/*---

pron()
#                       5       13     20     27
#                       v       v      v      v
o1 = new stzString("THE START <<ring>> ring <<ring>> _ring_ THE END")

? @@( o1.FindSubStringBoundedByS("ring", "_", 5) ) + NL
#--> [ 35 ]

? @@( o1.FindSubStringBoundedBySZZ("ring", "_", 5) )
#--> [ [ 35, 38 ] ]

proff()
# Executed in 0.05 second(s)

/*---

pron()
#                       5                            34     41
#                       v                            v      v
o1 = new stzString("THE START <<ring>> ring <<ring>> __ring__ THE END")

? @@( o1.FindSubStringBoundedBySIB("ring", "__", 5) ) + NL
#--> [ 34 ]

? @@( o1.FindSubStringBoundedBySIBZZ("ring", "__", 5) )
#--> [ [ 35, 41 ] ]

proff()
# Executed in 0.04 second(s)

/*===

pron()
#                       5              20     27
#                       v              v      v
o1 = new stzString("THE START <<ring>> ring <<ring>> __ring__ THE END")

? o1.FindNextNthSubStringBoundedByS(2, "ring", ["<<", ">>"], :StartingAt = 5)
#--> 27

? o1.FindNextNthSubStringBoundedBySIB(2, "ring", ["<<", ">>"], :StartingAt = 5)
#--> 25

? o1.FindNextSubStringBoundedByS("ring", ["<<", ">>"], :StartingAt = 5)
#--> 13

? o1.FindNextSubStringBoundedBySIB("ring", ["<<", ">>"], :StartingAt = 5)
#--> 11

proff()
# Executed in 0.02 second(s)

/*-----

pron()
#                       5              20     27
#                       v              v      v
o1 = new stzString("THE START <<ring>> ring <<ring>> __ring__ THE END")

? @@( o1.FindNextNthSubStringBoundedBySZZ(2, "ring", ["<<", ">>"], :StartingAt = 5) )
#--> [ 27, 30 ]

? @@( o1.FindNextNthSubStringBoundedBySIBZZ(2, "ring", ["<<", ">>"], :StartingAt = 5) )
#--> [ 25, 28 ]

? @@( o1.FindNextSubStringBoundedBySZZ("ring", ["<<", ">>"], :StartingAt = 5) )
#--> [ 13, 16 ]

? @@( o1.FindNextSubStringBoundedBySIBZZ("ring", ["<<", ">>"], :StartingAt = 5) )
#--> [ 11, 14 ]

proff()
# Executed in 0.02 second(s)

/*--- #ring

pron()

? ring_reverse("START")
#--> TRATS

? ring_reverse(1:3)
#--> [ 3, 2, 1 ]

proff()
# Executed in 0.02 second(s)

/*--------

pron()
#                       5       13     20     27       36         47
#                       v       v      v      v        v          v
o1 = new stzString("THE START <<ring>> ring <<ring>> __ring__ THE END of story")

? o1.FindPreviousNthSubStringBoundedByS(2, "ring", ["<<", ">>"], :StartingAt = 50)
#--> 13

? o1.FindPreviousNthSubStringBoundedBySIB(2, "ring", ["<<", ">>"], :StartingAt = 50) + NL
#--> 11

proff()
# Executed in 0.02 second(s)

/*===

pron()
#                       5       13     20     27       36         47
#                       v       v      v      v        v          v
o1 = new stzString("THE START <<ring>> ring <<ring>> __ring__ THE END of story")


? o1.FindNthSubStringBetween(3, "ring", "START", "END")
#--> 27

? o1.FindNthSubStringBetween(3, "ring", 5, 47)
#--> 27

? o1.FindNthSubStringBoundedBy(2, "ring", [ "<<", ">>" ])
#--> 27

? o1.FindFirstSubStringBetween("ring", "START", "END")
#--> 13

? o1.FindFirstSubStringBoundedBy("ring", [ "<<", ">>" ])
#--> 13

? o1.FindLastSubStringBetween("ring", "START", "END")
#--> 36

? o1.FindLastSubStringBoundedBy("ring", [ "<<", ">>" ])
#--> 27

proff()
# Executed in 0.06 second(s)

/*---

pron()
#                       5       13     20     27       36         47
#                       v       v      v      v        v          v
o1 = new stzString("THE START <<ring>> ring <<ring>> __ring__ THE END of story")


? o1.FindNthSubStringBetweenZZ(3, "ring", "START", "END")
#--> [ 27, 30 ]

? o1.FindNthSubStringBetweenZZ(3, "ring", 5, 47)
#--> [ 27, 30 ]

? o1.FindNthSubStringBoundedByZZ(2, "ring", [ "<<", ">>" ])
#--> [ 27, 30 ]

? o1.FindFirstSubStringBetweenZZ("ring", "START", "END")
#--> [ 13, 16 ]

? o1.FindFirstSubStringBoundedByZZ("ring", [ "<<", ">>" ])
#--> [ 13, 16 ]

? o1.FindLastSubStringBetweenZZ("ring", "START", "END")
#--> [ 36, 39 ]

? o1.FindLastSubStringBoundedByZZ("ring", [ "<<", ">>" ])
#--> [ 27, 30 ]

proff()
# Executed in 0.04 second(s)

/*----

pron()
#                       5     11     18     25
#                       v     v      v      v
o1 = new stzString("THE START <<ring>> ring <<ring>> __ring__ THE END of story")

? o1.FindNthSubStringBoundedByIB(2, "ring", [ "<<", ">>" ])
#--> 25

? o1.FindFirstSubStringBoundedByIB("ring", [ "<<", ">>" ])
#--> 11

? o1.FindLastSubStringBoundedByIB("ring", [ "<<", ">>" ])
#--> 25

? ""

? o1.FindNthSubStringBoundedByIBZZ(2, "ring", [ "<<", ">>" ])
#--> [ 25, 32 ]

? o1.FindFirstSubStringBoundedByIBZZ("ring", [ "<<", ">>" ])
#--> [ 11, 18 ]

? o1.FindLastSubStringBoundedByIBZZ("ring", [ "<<", ">>" ])
#--> [ 25, 32 ]

proff()
# Executed in 0.07 second(s)

/*====

pron()
#                       5       13     20     27       36         47
#                       v       v      v      v        v          v
o1 = new stzString("THE START <<ring>> ring <<ring>> __ring__ THE END of story")


? o1.FindNthSubStringBoundedByS(2, "ring", [ "<<", ">>" ], :StartingAt = 3)
#--> 27

? ""

? o1.FindFirstSubStringBoundedByS("ring", [ "<<", ">>" ], :StartingAt = 3)
#--> 13

? o1.FindLastSubStringBoundedByS("ring", [ "<<", ">>" ], :StartingAt = 3)
#--> 27

proff()
# Executed in 0.05 second(s)

/*---

pron()
#                       5       13     20     27       36         47
#                       v       v      v      v        v          v
o1 = new stzString("THE START <<ring>> ring <<ring>> __ring__ THE END of story")

? o1.FindNthSubStringBoundedBySZZ(2, "ring", [ "<<", ">>" ], :StartingAt = 3)
#--> [ 27, 30 ]

? o1.FindFirstSubStringBoundedBySZZ("ring", [ "<<", ">>" ], :StartingAt = 3)
#--> [ 13, 16 ]

? o1.FindLastSubStringBoundedBySZZ("ring", [ "<<", ">>" ], :StartingAt = 3)
#--> [ 27, 30 ]

proff()
# Executed in 0.08 second(s)

/*----

pron()
#                       5     11     18     25
#                       v     v      v      v
o1 = new stzString("THE START <<ring>> ring <<ring>> __ring__ THE END of story")

? o1.FindNthSubStringBoundedBySIB(2, "ring", [ "<<", ">>" ], :StartingAt = 3)
#--> 25

? o1.FindFirstSubStringBoundedBySIB("ring", [ "<<", ">>" ], :StartingAt = 3)
#--> 11

? o1.FindLastSubStringBoundedBySIB("ring", [ "<<", ">>" ], :StartingAt = 3)
#--> 25

? ""

? o1.FindNthSubStringBoundedBySIBZZ(2, "ring", [ "<<", ">>" ], :StartingAt = 3)
#--> [ 25, 28 ]

? o1.FindFirstSubStringBoundedBySIBZZ("ring", [ "<<", ">>" ], :StartingAt = 3)
#--> [ 11, 28 ]

? o1.FindLastSubStringBoundedBySIBZZ("ring", [ "<<", ">>" ], :StartingAt = 3)
#--> [ 25, 28 ]

proff()
# Executed in 0.14 second(s)

/*=========

pron()

? Direction(:forward)
#--> "forward"

? Direction(:backward)
#--> "backward"

? Direction(:Direction = :Forward)
#--> "forward"

? Direction(:Going = :Backward)
#--> "backward"

proff()
# Executed in 0.02 second(s)

/*--------

pron()
#                       5       13     20     27       36         47
#                       v       v      v      v        v          v
o1 = new stzString("THE START <<ring>> ring <<ring>> __ring__ THE END of story")

? o1.FindNthSubStringBoundedByD(2, "ring", [ "<<", ">>" ], :Forward)
#--> 27

? o1.FindNthSubStringBoundedByD(2, "ring", [ "<<", ">>" ], :Backward)
#--> 13

? o1.FindNthPreviousSubStringBoundedBySIB(2, "ring", [ "<<", ">>" ], 58)
#--> 11

? ""

? o1.FindFirstSubStringBoundedByD("ring", [ "<<", ">>" ], :Forward)
#--> 13

? o1.FindFirstSubStringBoundedByD("ring", [ "<<", ">>" ], :Backward)
#--> 27

? o1.FindLastSubStringBoundedByD("ring", [ "<<", ">>" ], :Forward)
#--> 27

? o1.FindLastSubStringBoundedByD("ring", [ "<<", ">>" ], :Backward)
#--> 13

proff()
# Executed in 0.06 second(s)

/*------

pron()
#                       5       13     20     27       36         47
#                       v       v      v      v        v          v
o1 = new stzString("THE START <<ring>> ring <<ring>> __ring__ THE END of story")

? @@( o1.FindNthSubStringBoundedByDZZ(2, "ring", [ "<<", ">>" ], :Forward) )
#--> [ 27, 30 ]

? @@( o1.FindNthSubStringBoundedByDZZ(2, "ring", [ "<<", ">>" ], :Backward) )
#--> [ 13, 16 ]

? @@( o1.FindNthPreviousSubStringBoundedBySIBZZ(2, "ring", [ "<<", ">>" ], 58) )
#--> [ 11, 14 ]

? ""

? @@( o1.FindFirstSubStringBoundedByDZZ("ring", [ "<<", ">>" ], :Forward) )
#--> [ 13, 16 ]

? @@( o1.FindFirstSubStringBoundedByDZZ("ring", [ "<<", ">>" ], :Backward) )
#--> [ 27, 30 ]

? @@( o1.FindLastSubStringBoundedByDZZ("ring", [ "<<", ">>" ], :Forward) )
#--> [ 27, 30 ]

? @@( o1.FindLastSubStringBoundedByDZZ("ring", [ "<<", ">>" ], :Backward) )
#--> [ 13, 16 ]

proff()
# Executed in 0.08 second(s)

/*=============

pron()
#                       5     11            25
#                       v     v             v
o1 = new stzString("THE START <<ring>> ring <<ring>> __ring__ THE END of story")

? o1.FindNthSubStringBoundedByDIB(2, "ring", [ "<<", ">>" ], :Forward)
#--> 25

? o1.FindNthSubStringBoundedByDIB(2, "ring", [ "<<", ">>" ], :Backward)
#--> 11

? o1.FindNthPreviousSubStringBoundedBySIB(2, "ring", [ "<<", ">>" ], :StartingAt = 58)
#--> 11

? ""

? o1.FindFirstSubStringBoundedByDIB("ring", [ "<<", ">>" ], :Forward)
#--> 11

? o1.FindFirstSubStringBoundedByDIB("ring", [ "<<", ">>" ], :Backward)
#--> 25

? o1.FindLastSubStringBoundedByDIB("ring", [ "<<", ">>" ], :Forward)
#--> 25

? o1.FindLastSubStringBoundedByDIB("ring", [ "<<", ">>" ], :Backward)
#--> 11

proff()
#Executed in 0.06 second(s)

/*------

pron()
#                       5     11    18      25     32
#                       v     v     v       v      v
o1 = new stzString("THE START <<ring>> ring <<ring>> __ring__ THE END of story")

? @@( o1.FindNthSubStringBoundedByDIBZZ(2, "ring", [ "<<", ">>" ], :Forward) )
#--> [ 25, 32 ]

? @@( o1.FindNthSubStringBoundedByDIBZZ(2, "ring", [ "<<", ">>" ], :Backward) )
#--> [ 11, 18 ]

? @@( o1.FindNthPreviousSubStringBoundedBySIBZZ(2, "ring", [ "<<", ">>" ], :StartingAt = 58) )
#--> [ 11, 14 ]

? ""

? @@( o1.FindFirstSubStringBoundedByDIBZZ("ring", [ "<<", ">>" ], :Forward) )
#--> [ 11, 18 ]

? @@( o1.FindFirstSubStringBoundedByDIBZZ("ring", [ "<<", ">>" ], :Backward) )
#--> [ 25, 32 ]

? @@( o1.FindLastSubStringBoundedByDIBZZ("ring", [ "<<", ">>" ], :Forward) )
#--> [ 25, 32 ]

? @@( o1.FindLastSubStringBoundedByDIBZZ("ring", [ "<<", ">>" ], :Backward) )
#--> [ 11, 18 ]

proff()
# Executed in 0.06 second(s)

/*======

pron()
#                       5       13     20     27       36         47
#                       v       v      v      v        v          v
o1 = new stzString("THE START <<ring>> ring <<ring>> __ring__ THE END of story")

? o1.FindNthSubStringBoundedBySD(2, "ring", [ "<<", ">>" ], :StartingAt = 3, :Forward)
#--> 27

? o1.FindNthSubStringBoundedBySD(2, "ring", [ "<<", ">>" ], :StartingAt = 47, :Backward)
#--> 13

? ""

? o1.FindFirstSubStringBoundedBySD("ring", [ "<<", ">>" ], :StartingAt = 3, :Forward)
#--> 13

? o1.FindFirstSubStringBoundedBySD("ring", [ "<<", ">>" ], :StartingAt = 47, :Backward)
#--> 27

? o1.FindLastSubStringBoundedBySD("ring", [ "<<", ">>" ], :StartingAt = 3, :Forward)
#--> 27

? o1.FindLastSubStringBoundedBySD("ring", [ "<<", ">>" ], :StartingAt = 47, :Backward)
#--> 13

proff()
# Executed in 0.09 second(s)

/*---

pron()
#                       5       13     20     27       36         47
#                       v       v      v      v        v          v
o1 = new stzString("THE START <<ring>> ring <<ring>> __ring__ THE END of story")

? o1.NumberOfOccurrenceOfSubStringBoundedBy("ring", [ "<<", ">>" ])
#--> 2

? o1.NumberOfOccurrenceOfSubStringBoundedByS("ring", [ "<<", ">>" ], :StartingAt = 5) + NL
#--> 2

? o1.FindNthSubStringBoundedBySDZZ(2, "ring", [ "<<", ">>" ], :StartingAt = 3, :Forward)
#--> [ 27, 30 ]

? o1.FindFirstSubStringBoundedBySDZZ("ring", [ "<<", ">>" ], :StartingAt = 3, :Forward)
#--> [ 13, 16 ]

? o1.FindLastSubStringBoundedBySDZZ("ring", [ "<<", ">>" ], :StartingAt = 3, :Forward)
#--> [ 27, 30 ]

#--

? o1.FindNthSubStringBoundedBySDZZ(2, "ring", [ "<<", ">>" ], :StartingAt = 47, :Backward)
#--> [ 13, 16 ]

? o1.FindFirstSubStringBoundedBySDZZ("ring", [ "<<", ">>" ], :StartingAt = 47, :Backward)
#--> [ 27, 30 ]

? o1.FindLastSubStringBoundedBySDZZ("ring", [ "<<", ">>" ], :StartingAt = 47, :Backward)
#--> [ 13, 16 ]

proff()
# Executed in 0.11 second(s)

/*----

pron()
#                       5     11     18     25     32
#                       v     v      v      v      v
o1 = new stzString("THE START <<ring>> ring <<ring>> __ring__ THE END of story")

? o1.FindNthSubStringBoundedBySDIB(2, "ring", [ "<<", ">>" ], :StartingAt = 3, :Forward)
#--> 25

? o1.FindFirstSubStringBoundedBySDIB("ring", [ "<<", ">>" ], :StartingAt = 3, :Forward)
#--> 11

? o1.FindLastSubStringBoundedBySDIB("ring", [ "<<", ">>" ], :StartingAt = 3, :Forward)
#--> 25

? ""

? o1.FindNthSubStringBoundedBySDIBZZ(2, "ring", [ "<<", ">>" ], :StartingAt = 3, :Forward)
#--> [ 25, 28 ]

? o1.FindFirstSubStringBoundedBySDIBZZ("ring", [ "<<", ">>" ], :StartingAt = 3, :Forward)
#--> [ 11, 18 ]

? o1.FindLastSubStringBoundedBySDIBZZ("ring", [ "<<", ">>" ], :StartingAt = 3, :Forward)
#--> [ 25, 32 ]

proff()
# Executed in 0.08 second(s)

#===============


pron()

o1 = new stzString("...<<ring>> ... <<ruby>> ... <<php>> ...")

? @@( o1.FindSubStringsBoundedBy([ "<<", ">>" ]) ) + NL
#--> [ 6, 19, 32 ]

? @@( o1.FindSubStringsBoundedByZZ([ "<<", ">>" ]) ) + NL
#--> [ [ 6, 9 ], [ 19, 22 ], [ 32, 34 ] ]

? @@( o1.SubStringsBoundedBy([ "<<", ">>" ]) )
# [ "ring", "ruby", "php" ]

proff()
# Executed in 0.02 second(s)

/*-----

pron()

#                       5  8
#                       v--v
o1 = new stzString("RingRingRing")
? o1.FindSubStringBoundedByZZ("Ring", "Ring")
#--> [ 5, 8 ]

# Same as
? o1.FindSubStringBoundedByZZ("Ring", [ "Ring", "Ring" ])
#--> [ 5, 8 ]


proff()
# Executed in 0.04 second(s)

/*=====

pron()

? IsCaseSensitive(:CS = FALSE)
#--> FALSE

? IsCaseSensitive(:CS = TRUE)
#--> TRUE

? @@( CaseSensitive(:CS = FALSE) )
#--> FALSE

proff()

/*---- #narration

pron()

# ~> Like @Direction() or @CaseSensitive() functions,
# @Bounds() function helps in checking the pacBounds
# param, sees if it is well formed (a string or a
# pair of strings), and returns it in a uniformed
# form to let us simplify our code and think about
# the solution without hassel.

# @Bounds() returns alway a pair of strings,
# @CaseSensitive() returns always TRUE or FALSE, and
# @Direction returns :Forward or :Backward.

? @Bounds(["<<", ">>"])
#--> [ "<<", ">>" ]

? @Bounds("_")
#--> [ "_", "_" ]

? @CaseSensitive(:CaseSensitive = TRUE)
#--> TRUE

? @@( @CaseSensitive(:CS = FALSE) )
#--> FALSE

? @CaseSensitive(TRUE)
#--> TRUE

? @CaseSensitive(FALSE)
#--> FALSE

? @Direction(:Direction = :Forward)
#--> "forward"

? @Direction(:Going = :Backward)
#--> "backward"

? @Direction(:Forward)
#--> "forward"

? @Direction(:Backward)
#--> "backward"

proff()
# Executed in 0.02 second(s)

/*===== #todo add #narration #visuality : FindBounded VS DeepFindBounded

pron()
#                               15  16
# BOUNDED BY >>         5   9    \  /    23 25
#                       v---v     vv      v-v
o1 = new stzString("---[ [===]---[==] ]--[===]--")
#                       | \_/     \/ |    \_/
# DEEP BOUNDED BY >>    | 7 9   15 16|   23 25
#                       \____________/
#                        5         18
       
? @@( o1.FindBoundedByZZ([ "[", "]"]) ) + NL
#-->[ [ 5, 9 ], [ 15, 16 ], [ 23, 25 ] ]


? @@( o1.DeepFindBoundedByZZ([ "[", "]" ]) )
#--> [ [ 7, 9 ], [ 15, 16 ], [ 23, 25 ], [ 5, 18 ] ]

proff()
# Executed in 0.02 second(s)

/*------
*/
pron()
#                              15   16
#                         7 9    \  /
#                       v v v     vv v    v v
o1 = new stzString("---< <===>---<==> >--<===>--")
#                       | | |     || |    | |
#                       | \_/     \/ |    \_/
#                       \____________/   23 25
#                       5           18

? @@( o1.DeepFindSubStringsBoundedByZZ([ "<", ">" ]) ) + NL
#--> [ [ 7, 9 ], [ 15, 16 ], [ 23, 25 ], [ 5, 18 ] ]

# Same as:

? @@( o1.DeepFindSubStrings(:BoundedBy = [ "<", ">" ]) )
#--> [ 7, 15, 23, 5 ]

# Or simply:

? @@( o1.DeepFind([ "<", ">" ]) )
#--> [ 7, 15, 23, 5 ]

proff()
# Executed in 0.02 second(s)

/*------
*/
pron()
#                                   19  20
#                        6  9 11     \  /        30 32
#                        v  v v       vv  v      v v
o1 = new stzString("---<< <<===>>---<<==>> >>--<<===>>--")
#                        |  | |       ||  |      | |
#                        |  \_/       \/  |      \_/
#                        \________________/     30 32
#                       6                23


? @@( o1.DeepFindSubStringsBoundedByZZ([ "<<", ">>" ]) ) + NL
#--> [ [ 9, 11 ], [ 19, 20 ], [ 30, 32 ], [ 6, 23 ] ]

# Same as:

? @@( o1.FindNestedSubStringsZZ([ "<<", ">>" ]) ) + NL
#--> [ [ 9, 11 ], [ 19, 20 ], [ 30, 32 ], [ 6, 23 ] ]


? @@NL( o1.NestedSubStringsZZ([ "<<", ">>" ]) )
#--> [
#	[ "===", [ 9, 11 ] ],
#	[ "==", [ 19, 20 ] ],
#	[ "===", [ 30, 32 ] ],
#	[ " <<===>>---<<==>> ", [ 6, 23 ] ]
# ]

proff()
# Executed in 0.03 second(s)

/*===----

pron()
#                                      
#                      4 6   10 14 17 19 22  26
#                      v v   v   v  v v  v   v
o1 = new stzString("---< <===>---<==> >--<===>--")
#                      | |   |   |  | |  |   |
#                      | \___/   \__/ |  \___/
#                      \______________/  22 26
#                      4             19

? @@( o1.DeepFindSubStringsBoundedByIBZZ([ "<", ">" ]) ) + NL
#--> [ [ 6, 10 ], [ 14, 17 ], [ 22, 26 ], [ 4, 19 ] ]

# Same as:

? @@( o1.FindNestedSubStringsIBZZ(:BoundedBy = [ "<", ">" ]) )
#--> [ [ 6, 10 ], [ 14, 17 ], [ 22, 26 ], [ 4, 19 ] ]

proff()
# Executed in 0.02 second(s)

/*------

pron()
#                                      
#                      4   8       16  20     27  31 34      42
#                      v   v       v   v      v   v  v       v
o1 = new stzString("---@<< @<<===>>@---@<<==>>@ >>@--@<<===>>@--")
#                      |   |       |   |      |   |  |       |
#                      |   \_______/   \______/   |  \_______/
#                      \__________________________/  34     42
#                      4                         31

? @@( o1.DeepFindSubStringsBoundedByIBZZ([ "@<<", ">>@" ]) ) + NL
#--> [ [ 8, 16 ], [ 20, 27 ], [ 34, 42 ], [ 4, 31 ] ]

# Same as:

? @@( o1.FindNestedSubStringsIBZZ(:BoundedBy = [ "@<<", ">>@" ]) ) + NL
#--> [ [ 8, 16 ], [ 20, 27 ], [ 34, 42 ], [ 4, 31 ] ]

#--

? @@NL( o1.NestedSubStringsIBZZ([ "@<<", ">>@" ]) ) # Or DeepSubStringsBoundedByIBZZ()
#--> [
#	[ "@<<===>>@", [ 8, 16 ] ],
#	[ "@<<==>>@", [ 20, 27 ] ],
#	[ "@<<===>>@", [ 34, 42 ] ],
#	[ "@<< @<<===>>@---@<<==>>@ >>@", [ 4, 31 ] ]
# ]

proff()
# Executed in 0.03 second(s)
