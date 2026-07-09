# Narrative
# --------
# CHECKER
#
# Extracted from stzlisttest.ring, block #610.

load "../../stzBase.ring"


pr()

o1 = new stzList([ "a", "b", "C", 5, "d", "E" ])

? o1.ContainsW("isString(This[@i]) and @IsUppercase(This[@i])")
#--> TRUE

? @@( o1.FindW("isString(This[@i]) and @IsUppercase(This[@i])") )
#--> [ 3, 6 ]

? @@( o1.ItemsW("isString(This[@i]) and @IsUppercase(This[@i])") )
#--> [ "C", "E" ]

pf()
# Executed in almost 0 second(s) in Ring 1.27
# Executed in 0.12 second(s) in Ring 1.22
