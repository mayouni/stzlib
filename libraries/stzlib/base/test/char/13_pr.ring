# Narrative
# --------
# pr()
#
# Extracted from stzchartest.ring, block #13.

load "../../stzBase.ring"


? QQ("Ǝ").IsTurned()
#--> TRUE

? QQ("Ⅎ").IsTurned()
#--> TRUE

? QQ("I").IsTurned()
#--> TRUE

? QQ("⅂").IsTurned()
#--> TRUE

? Q("ƎℲI⅂").IsTurned()
#--> TRUE

? Q("ƎℲI⅂").Turned()
#--> LIFE

? Q("LIFE").Turned()
#--> ƎℲI⅂

? Q("LIFE").CharsTurned()
#--> ⅂IℲƎ

? Q("⅂IℲƎ").CharsTurned()
#--> LIFE

pf()
# Executed in 0.26 second(s) in Ring 1.23
# Executed in 2.07 second(s) in Ring 1.20
