# Narrative
# --------
# pr()
#
# Extracted from stzObjectTest.ring, block #12.

load "../../stzBase.ring"

pr()

# There is a difference in Softanza between IsEither() and IsEitherA().
# The first checks for VALUES while the second checks for TYPES:

o1 = new stzNumber(5)
? o1.IsEither(5, :Or = 12)		#--> TRUE
? o1.IsEitherA(:Number, :Or = :String)	#--> TRUE

o1 = new stzList(1:3)
? o1.IsEither(1:3, :Or = 2:7) 		#--> TRUE
? o1.IsEitherA(:List, :Or = :String)	#--> TRUE

o1 = new stzString("ring")
? o1.IsEither("ring", :or = "ruby")	#--> TRUE
? o1.IsEitherA(:String, :Or = :List)	#--> TRUE

pf()
# Executed in 0.06 second(s)
