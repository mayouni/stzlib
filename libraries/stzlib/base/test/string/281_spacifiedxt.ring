# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #281.

load "../../stzBase.ring"

pr()

? Q("123456789050").SpacifiedXT(

    :Separator	= [ ",", "." , :LastNChars = 3 ],
    :Step 	= [ 3, 0 ], 
    :Direction 	= :Backward

)
#--> 123,456,789.050

pf()
# Executed in 0.03 second(s).
