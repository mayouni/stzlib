load "stzlib.ring"

/*=============

pron()

o1 = new stzString("aa***aa**aa***aa")
? o1.IsBoundedByCS("aa", TRUE)
#--> TRUE

proff()
# Executed in 0.03 second(s)

/*----------------

pron()

o1 = new stzString("aa***aa**aa***aa")

? @@( o1.BoundedBy("aa") )
#--> [ "***", "**", "***" ]

proff()
# Executed in 0.08 second(s)

/*----------------
*/

pron()

o1 = new stzString("<<***>>**<<***>>")
? o1.FindAnyBetweenAsSections("<<", ">>")

proff()

/*----------------
*/
o1 = new stzString("<<***>>**<<***>>")

? o1.Between("<<", :and = ">>")

//? o1.BoundedBy(["<<", ">>"])
#--> [ "***", "***" ]

proff()

/*----------------
*/
pron()

o1 = new stzString("aa***aa**aa***aa")

? @@( o1.FindAnyBoundedBy("aa") )
#--> [ 3, 8, 12 ]

? @@( o1.FindAnyBoundedByAsSections("aa") )
#--> [ [ 3, 5 ], [ 8, 9 ], [ 12, 14 ] ]

proff()
# Executed in 0.10 second(s)

/*==============

pron()

o1 = new stzString("RINGORIALAND")

? o1.NumberOfSubStrings()
#--> 78

? o1.SubStrings()
#--> [ "R", "RI", "RIN", ..., "N", "ND", "D" ]	# TODO: add Shorten() / ShowShort()

proff()
#--> Executed in 0.15 second(s)

/*----------------
*/
pron()

o1 = new stzString("RINGORIALAND")
? o1.Duplicates()

#--> [ "R", "RI", "I", "N", "A" ]

proff()
#--> Executed in 0.44 second(s)
