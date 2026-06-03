# Narrative
# --------
# pr()
#
# Extracted from stzsubstringTest.ring, block #3.
#ERR Error (R14) : Calling Method without definition: substringinq

load "../../stzBase.ring"

pr()

//? Q("Ring").InQ("I love RING!").IsInUppercase() #TODO
#--> TRUE
 
? The("PYTHON").SubStringInQ("ring PYTHON ruby").Lowercased()
#--> ring python ruby
 
//? SubStringQ("Ring").InQ("Python Ring Ruby").BoundedBy(2Hearts()) #TODO
#--> Python ♥♥Ring♥♥ Ruby
 
? TheWordQ("love").InQ("I love Ring!").ReplacedBy(AHeart())
#--> I ♥ Ring!
 
//? OnlyQ("human").InQ([ "THE", "human", "LIFE" ]).IsInLowercase() #TODO Add OnlyQ()
#--> TRUE
 
//? Q("human").InQ([ "THE", "human", "LIFE" ]).Uppercased() #TODO
#--> [ "THE", "HUMAN", "LIFE" ]

#TODO Add ItemsQ()
//? ItemsQ(["THE", "LIFE"]).InListQ([ "THE", "human", "LIFE" ]).AreBothInUppercase()
#--> TRUE 

pf()
# Executed in 0.04 second(s) in Ring 1.22
