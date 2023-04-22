load "stzlib.ring"

/*===================

pron()

o1 = new stzString("...<<hi!>>...<<-->>...<<hi!>>...")

# Finding the substring "hi!" bounded by "<<" and ">>"
? @@S( o1.FindBetween("hi!", "<<", ">>") )
#--< [ 6, 25 ]

# Written in a near-natural form:
? @@S( o1.FindXT("hi!", :Between = ["<<", ">>"]) )
#--> [ 6, 25 ]

# We can yield not only the positions but the hole sections:
? @@S( o1.FindBetweenAsSections("hi!", "<<", ">>") )
#--> [ [ 6, 8 ], [ 25, 27 ] ]

# Written in a near-natural form:
? @@S( o1.FindAsSectionsXT("hi!", :Between = ["<<", ">>"]) )
#--> [ [ 6, 8 ], [ 25, 27 ] ]

proff()
# Executed in 0.11 second(s)

/*--------------
*/
pron()

o1 = new stzString("...<<--hi!-->>...<<-->>...<<hi!>>...")

# Inside the substrings bounded by "<<" and ">>", find the
# occurrences of the substring "hi!"

? o1.FindInBetween( "hi!", "<<", ">>" )
#--> [8, 29]

# Written in a near-natural form:

? o1.FindXT( "hi!", :InBetween = ["<<", ">>"] )
#--> [8, 29]

# Yielding the sections not just the positions

? o1.FindInBetweenAsSections( "hi!", "<<", ">>" )
#--> [ [8, 10], [29, 30] ]

# Written in a near-natural form:

? o1.FindAsSectionsXT( "hi!", :InBetween = ["<<", ">>"] )
#--> [ [8, 10], [29, 30] ]

proff()
# Executed in 0.09 second(s)
