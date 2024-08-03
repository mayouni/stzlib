load "stzlib.ring"

/*-----------------

o1 = new stzPairOfLists(1:5, "A":"C")
? o1.Alternate()
#--> [ 1, "A", 2, "B", 3, "C", 4, 5 ]

/*-----------------
*/
o1 = new stzPairOfLists( [ :Ring, :Python, :Ruby ], [ 2016, 1991, 1996 ] )
? o1.Associate()
#--> [ :Ring = 2016, :Python = 1991, :Ruby = 1996 ]
