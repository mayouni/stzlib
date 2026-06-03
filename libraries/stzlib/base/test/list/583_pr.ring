# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #583.
#ERR Error (R50) : Object does not support operator overloading

load "../../stzBase.ring"

pr()

o1 = new stzString("File")

# Returning a new string and leaving o1 as is

? o1 * 3
#--> FileFileFile

? o1 + "File"
#--> FileFile

# Returning a list and leaving o1 as is

? @@( o1 / 4 )
#--> [ "F", "i", "l", "e" ]

? o1.Content() 	
#--> File

pf()
# Executed in 0.04 second(s).
