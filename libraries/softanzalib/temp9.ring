load "stzlib.ring"

pron()

o1 = new stzString("TWO, ONE, THREE!")
o1.SwapSubStrings("TWO", "ONE")
? o1.Content()
#--> ONE, TWO, THREE!

proff()
# Executed in 0.03 second(s)

/*----

o1 = new stzString("...<<---teeba--->>...<<-->>...<<teeba>>...")
? @@S( o1.FindBetween("teeba", "<<", ">>") )

? @@S( o1.FindAsSectionsXT("teeba", :Between = ["<<", ">>"]) )
*/

/*----
*/
o1 = new stzString("...<<--hi!-->>...<<-->>...<<hi!>>...")
? o1.FindInBetween( "hi!", "<<", ">>" )
#--> [ [8, 10], [29, 30] ]
