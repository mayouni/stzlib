load "../max/stzmax.ring"

/*-----------------

pr()

o1 = new stzPairOfLists(1:5, "A":"C")
? @@( o1.Alternate() )
#--> [ 1, "A", 2, "B", 3, "C", 4, 5 ]

pf()
# Executed in 0.03 second(s) in Ring 1.21

/*-----------------
*/
pr()

o1 = new stzPairOfLists( [ :Ring, :Python, :Ruby ], [ 2016, 1991, 1996 ] )
? @@( o1.Associate() )
#--> [ [ "ring", 2016 ], [ "python", 1991 ], [ "ruby", 1996 ] ]

pf()
# Executed in 0.02 second(s) in Ring 1.21
