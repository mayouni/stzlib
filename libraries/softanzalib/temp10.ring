load "stzlib.ring"

/*-----
*/
pron()

o1 = new stzString("")

? o1.FindSSZ("", -1, 0)
#--> 0

? @@( o1.FindSSZZ("", -1, 0) )
#-->  []

proff()

/*-----
*/

pron()

o1 = new stzString("123♥♥678♥♥123♥♥678")
? @@( o1.FindSSZZ("♥♥", 7, 17) )
#--> [ [ 9, 10 ], [ 14, 15 ] ]

? @@( o1.FindInSectionZZ("♥♥", 7, 17) )
#--> [ [ 9, 10 ], [ 14, 15 ] ]

? @@( o1.FindBetweenZZ("♥♥", 7, 17) )
#--> [ [ 9, 10 ], [ 14, 15 ] ]

proff()
# Executed in 0.05 second(s)
