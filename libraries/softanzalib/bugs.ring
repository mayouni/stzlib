load "stzlib.ring"

/*-----

pron()

o1 = new stzList([ "A", "b", 2, "C", 3, "♥" ])

? o1.ContainsW(' isNumber(This[@i]) ')
#--> TRUE
# Executed in 0.06 second(s)

? o1.ContainsWXT(' isNumber(@CurrentItem) ')
#--> TRUE
# Executed in 0.10 second(s)

proff()
# Executed in 0.12 second(s)

/*-----
*/

