# Narrative
# --------
# pr()
#
# Extracted from stzlocaletest.ring, block #77.

load "../../stzBase.ring"


o1 = new stzString("2")
? o1.IsScriptName() #--> FALSE
? o1.IsScriptAbbreviation() #--> FALSE

? o1.IsScriptNumber() #--> TRUE
? StzScriptQ("2").Name() #--> cyrillic
? Script("2") #--> cyrillic

? Country("216")
#--> tunisia

? Language("أم")
#--> arabic

pf()
# Executed in 0.06 second(s) in Ring 1.23
