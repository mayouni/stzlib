load "stzlib.ring"

/*-----------

pron()

o1 = new stzString("..<<Hi>>..<<Ring!>>..")
? @@( o1.FindAnyBetweenAsSections("<<", ">>") )
#--> [ [ 5, 6 ], [ 13, 17 ] ]

proff()
# Executed in 0.07 second(s)

/*-----------

pron()

o1 = new stzString("..<<Hi>>..<<Ring!>>..")

? @@(o1.FindAnyBetweenAsSectionsS("<<", ">>", 3))
#--> [ [ 5, 6 ], [ 13, 17 ] ]

? @@(o1.FindAnyBetweenAsSectionsS("<<", ">>", 8))
#--> [ [ 13, 17 ] ]

proff()
# Executed in 0.10 second(s)

/*-----------

pron()

#                     3    8   3
o1 = new stzString("**aa***aa**aa***")

? @@(o1.FindAnyBetweenAsSections("aa", "aa"))
#--> [ [ 5, 7 ], [ 10, 11 ] ]

proff()
# Executed in 0.08 second(s)

/*-----------
*/
pron()

#                       5 7  01    
o1 = new stzString("**aa***aa**aa***")

? @@(o1.FindAnyBetweenAsSectionsS("aa", "aa", :startingat = 2))
#--> [ [ 5, 7 ], [ 10, 11 ] ]

proff()
# Executed in 0.08 second(s)

