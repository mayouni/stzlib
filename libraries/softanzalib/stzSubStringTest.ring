load "stzlib.ring"

/*-----

pron()

o1 = new stzSubString("ring", :in = "I LOVE THE ring LANGUAGE!")

? o1.SubString()
#--> ring

? o1.String()
#--> I LOVE THE ring LANGUAGE!

? o1.CaseSensitive()
#--> TRUE

? o1.Uppercased()
#--> I LOVE THE RING LANGUAGE!

? o1.String()
#--> I LOVE THE ring LANGUAGE!

? o1.NumberOfChars()
#--> 4

proff()
# Executed in 0.05 second(s)

/*-----
*/
pron()

o1 = new stzSubString("ING", :in = "I love the RING language!")

? o1.Lowercased()
#--> I love the Ring language!

proff()
