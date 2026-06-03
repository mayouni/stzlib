# Narrative
# --------
# pr()
#
# Extracted from stzsubstringTest.ring, block #6.

load "../../../stzBase.ring"


? Q("human").InQ("THE human LIFE").IsInLowercase()
#--> TRUE

? Q("HUMAN").InQ("the HUMAN life").IsInUppercase()
#--> TRUE

? The("PYTHON").SubStringInQ("ring PYTHON ruby").Lowercased()
#--> ring python ruby

? TheWordQ("love").InQ("I love Ring").ReplacedBy(AHeart())
#--> I ♥ Ring

#TODO Not yet implemented:

//? TheSubString([ "Ring", :In = "I love Ring language!" ]).BoundedBy(3Hearts())
#--> I love ♥♥♥Ring♥♥♥ language!

//? TheSubString("Ring").InQ("I love Ring language!").BoundedBy(3Hearts())
#--> I love ♥♥♥Ring♥♥♥ language!

pf()
# Executed in 0.07 second(s) in Ring 1.22
# Executed in 0.80 second(s) in Ring 1.21
