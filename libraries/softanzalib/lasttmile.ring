load "stzlib.ring"

/*======

pron()

o1 = new stzString("Ring programming language!")
? o1.ContainsSubStringBetween("ram", "prog", "ing")
#--> TRUE

proff()
# Executed in 0.02 second(s)


/*=====
*/
pron()
#                       5     11             26        36    42      50
o1 = new stzString("The <<Ring>> programming <<language>> is >>Waooo!<<")
? o1.FindTheseBounds("<<", ">>")

proff()

/*----

*/
pron()
#                         +------.--.--+
#                         |      :  :  |
#                         V      :  :  V
o1 = new stzString("I love the <<Ring>> programming <<language>>!")

/*
? o1.ContainsSubStringBetween("Ring", "love", "program")
#--> TRUE

? o1.Between("love", "program") + NL
#--> " the <<Ring>> "

#--

? o1.ContainsSubStringBoundedBy("Ring", [ "<<", ">>" ])
#--> TRUE
*/

? @@( o1.FindTheseBoundsZZ("<<", ">>") )


//? o1.FindAnyBoundedBy(["<<", ">>"]) + NL

proff()

#--
/*
? o1.ContainsSubStringBoundedByS("ramm", ["prog", "ing"], 5)
#--> TRUE

proff()
# Executed in 0.06 second(s)

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

o1 = new stzString("THE START <<ring>> ring <<ring>> THE END")

? o1.ContainsNOccurrencesOfSubStringBetween(3, "ring", "ring", "END")
#--> TRUE

? o1.ContainsNOccurrencesOfSubStringboundedBy(2, "ring", [ "<<", ">>" ])
#--> TRUE

? o1.ContainsNOccurrencesOfSubStringBoundedByS(2, "ring", [ "<<", ">>" ], 5)

proff()
# Executed in 0.05 second(s)

/*===

pron()

o1 = new stzString("THE START <<ring>> ring <<ring>> _ring_ THE END")

? o1.FindSubStringBetween("ring", "START", "END")
#--> [ 13, 20, 27, 35 ]

? o1.FindSubstringBoundedBy("ring", [ "<<", ">>" ])
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
# Executed in 0.10 second(s)

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
# Executed in 0.04 second(s)

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
# Executed in 0.03 second(s)

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
#--> 11

? o1.FindPreviousNthSubStringBoundedBySIB(2, "ring", ["<<", ">>"], :StartingAt = 50) + NL
#--> 9

proff()
# Executed in 0.05 second(s)

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
# Executed in 0.06 second(s)

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

/*======================================================================

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
# Executed in 0.27 second(s)

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
#--> [ 25, 32 ]

? o1.FindFirstSubStringBoundedBySIBZZ("ring", [ "<<", ">>" ], :StartingAt = 3)
#--> [ 11, 18 ]

? o1.FindLastSubStringBoundedBySIBZZ("ring", [ "<<", ">>" ], :StartingAt = 3)
#--> [ 25, 32 ]

proff()
# Executed in 0.07 second(s)

/*======================================================================

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

? o1.FindNthSubStringBetweenD(3, "ring", "START", "END", :Forward)
#--> 27

? o1.FindNthSubStringBetweenD(3, "ring", "START", "END", :Direction = :Backward)
#--> 20

? o1.FindNthSubStringBetweenD(3, "ring", 5, 47, :Backward)
#--> 20

? o1.FindNthSubStringBoundedByD(2, "ring", [ "<<", ">>" ], :Forward)
#--> 27

? o1.FindNthSubStringBoundedByD(2, "ring", [ "<<", ">>" ], :Backward)
#--> 13

? o1.FindNthPreviousSubStringBoundedBySIB(2, "ring", [ "<<", ">>" ], 58)
#--> 11

? ""

? o1.FindFirstSubStringBetweenD("ring", "START", "END", :Forward)
#--> 13

? o1.FindFirstSubStringBetweenD("ring", "START", "END", :Backward)
#--> 36

? o1.FindFirstSubStringBoundedByD("ring", [ "<<", ">>" ], :Forward)
#--> 13

? o1.FindFirstSubStringBoundedByD("ring", [ "<<", ">>" ], :Backward)
#--> 27

? o1.FindLastSubStringBetweenD("ring", "START", "END", :Forward)
#--> 36

? o1.FindLastSubStringBetweenD("ring", "START", "END", :Backward)
#--> 13

? o1.FindLastSubStringBoundedByD("ring", [ "<<", ">>" ], :Forward)
#--> 27

? o1.FindLastSubStringBoundedByD("ring", [ "<<", ">>" ], :Backward)
#--> 13

proff()
# Executed in 0.12 second(s)

/*------

pron()
#                       5       13     20     27       36         47
#                       v       v      v      v        v          v
o1 = new stzString("THE START <<ring>> ring <<ring>> __ring__ THE END of story")

? @@( o1.FindNthSubStringBetweenDZZ(3, "ring", "START", "END", :Forward) )
#--> [ 27, 30 ]

? @@( o1.FindNthSubStringBetweenDZZ(3, "ring", "START", "END", :Direction = :Backward) )
#--> [ 20, 23 ]

? @@( o1.FindNthSubStringBetweenDZZ(3, "ring", 5, 47, :Backward) )
#--> [ 20, 23 ]

? @@( o1.FindNthSubStringBoundedByDZZ(2, "ring", [ "<<", ">>" ], :Forward) )
#--> [ 27, 30 ]

? @@( o1.FindNthSubStringBoundedByDZZ(2, "ring", [ "<<", ">>" ], :Backward) )
#--> [ 13, 16 ]

? @@( o1.FindNthPreviousSubStringBoundedBySIBZZ(2, "ring", [ "<<", ">>" ], 58) )
#--> [ 11, 14 ]

? ""

? @@( o1.FindFirstSubStringBetweenDZZ("ring", "START", "END", :Forward) )
#--> [ 13, 16 ]

? @@( o1.FindFirstSubStringBetweenDZZ("ring", "START", "END", :Backward) )
#--> [ 36, 39 ]

? @@( o1.FindFirstSubStringBoundedByDZZ("ring", [ "<<", ">>" ], :Forward) )
#--> [ 13, 16 ]

? @@( o1.FindFirstSubStringBoundedByDZZ("ring", [ "<<", ">>" ], :Backward) )
#--> [ 27, 30 ]

? @@( o1.FindLastSubStringBetweenDZZ("ring", "START", "END", :Forward) )
#--> [ 36, 39 ]

? @@( o1.FindLastSubStringBetweenDZZ("ring", "START", "END", :Backward) )
#--> [ 13, 16 ]

? @@( o1.FindLastSubStringBoundedByDZZ("ring", [ "<<", ">>" ], :Forward) )
#--> [ 27, 30 ]

? @@( o1.FindLastSubStringBoundedByDZZ("ring", [ "<<", ">>" ], :Backward) )
#--> [ 13, 16 ]

proff()
# Executed in 0.14 second(s)

/*=============//////////////////////

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
#Executed in 0.08 second(s)

/*------

pron()
#                       5     11    18      25     32
#                       v     v     v       v      v
o1 = new stzString("THE START <<ring>> ring <<ring>> __ring__ THE END of story")

? @@( o1.FindNthSubStringBoundedByDIBZZ(2, "ring", [ "<<", ">>" ], :Forward) )
#--> [ 25, 32 ]

? @@( o1.FindNthSubStringBoundedByDIBZZ(2, "ring", [ "<<", ">>" ], :Backward) )
#--> [ 11, 18 ]

////? @@( o1.FindNthPreviousSubStringBoundedByDSIBZZ(2, "ring", [ "<<", ">>" ], :StartingAt = 58) )
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

/*======================================================================

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
*/
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

/*======================================================================














///////////////////////////////////////////////
///////////////////////////////////////////////
///////////////////////////////////////////////

/*---

FindNthSubStringBoundedByDIB(n, pcSubStr, pacBounds, pcDirection)

FindNthSubStringBoundedByDIBZZ(n, pcSubStr, pacBounds, pcDirection)

/*--

FindNthSubStringBoundedBySD(n, pcSubStr, pacBounds, pnStartingAt, pcDirection)

FindNthSubStringBoundedBySDZZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection)

/*--

FindNthSubStringBoundedBySDIB(n, pcSubStr, pacBounds, pnStartingAt, pcDirection)

FindNthSubStringBoundedBySDIBZZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection)














/*--

FindFirstSubStringBetweenZZ(pcSubStr, pcBound1, pcBound2)

FindFirstSubStringBoundedByZZ(pcSubStr, pacBounds)

/*--

FindFirstSubStringBoundedByIB(pcSubStr, pacBounds)

FindFirstSubStringBoundedByIBZZ(pcSubStr, pacBounds)

/*--

FindFirstSubStringBoundedByS(pcSubStr, pacBounds, pnStartingAt)

FindFirstSubStringBoundedBySZZ(pcSubStr, pacBounds, pnStartingAt)

/*--

FindFirstSubStringBoundedBySIB(pcSubStr, pacBounds, pnStartingAt)

FindFirstSubStringBoundedBySIBZZ(pcSubStr, pacBounds, pnStartingAt)

/*--

FindFirstSubStringBetweenD(pcSubStr, pcBound1, pcBound2, pcDirection)

FindFirstSubStringBoundedByD(pcSubStr, pacBounds, pcDirection)

FindFirstSubStringBetweenDZZ(pcSubStr, pcBound1, pcBound2, pcDirection)

FindFirstSubStringBoundedByDZZ(pcSubStr, pacBounds, pcDirection)

/*--

FindFirstSubStringBoundedByDIB(pcSubStr, pacBounds, pcDirection)

FindFirstSubStringBoundedByDIBZZ(pcSubStr, pacBounds, pcDirection)

/*--

FindFirstSubStringBoundedBySD(pcSubStr, pacBounds, pnStartingAt, pcDirection)

FindFirstSubStringBoundedBySDZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)

/*--

FindFirstSubStringBoundedBySDIB(pcSubStr, pacBounds, pnStartingAt, pcDirection)

FindFirstSubStringBoundedBySDIBZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)

/*--

FindLastSubStringBetweenZZ(pcSubStr, pcBound1, pcBound2)

FindLastSubStringBoundedByZZ(pcSubStr, pacBounds)

/*--

FindLastSubStringBoundedByIB(pcSubStr, pacBounds)

FindLastSubStringBoundedByIBZZ(pcSubStr, pacBounds)

/*--

FindLastSubStringBoundedByS(pcSubStr, pacBounds, pnStartingAt)

FindLastSubStringBoundedBySZZ(pcSubStr, pacBounds, pnStartingAt)

/*--

FindLastSubStringBoundedBySIB(pcSubStr, pacBounds, pnStartingAt)

FindLastSubStringBoundedBySIBZZ(pcSubStr, pacBounds, pnStartingAt)

/*--

FindLastSubStringBetweenD(pcSubStr, pcBound1, pcBound2, pcDirection)

FindLastSubStringBoundedByD(pcSubStr, pacBounds, pcDirection)

FindLastSubStringBetweenDZZ(pcSubStr, pcBound1, pcBound2, pcDirection)

FindLastSubStringBoundedByDZZ(pcSubStr, pacBounds, pcDirection)

/*--

FindLastSubStringBoundedByDIB(pcSubStr, pacBounds, pcDirection)

FindLastSubStringBoundedByDIBZZ(pcSubStr, pacBounds, pcDirection)

/*--

FindLastSubStringBoundedBySD(pcSubStr, pacBounds, pnStartingAt, pcDirection)

FindLastSubStringBoundedBySDZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)

/*--

FindLastSubStringBoundedBySDIB(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

FindLastSubStringBoundedBySDIBZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)

/*--



