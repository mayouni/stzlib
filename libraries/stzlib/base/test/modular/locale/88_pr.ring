# Narrative
# --------
# pr()
#
# Extracted from stzlocaletest.ring, block #88.

load "../../../stzBase.ring"


o1 = new stzLocale("en_US")
? o1.ToLowercase("FDMLj") #--> fdmlj
? o1.ToUPPERcase("FDMLj") #--> FDMLJ

? o1.amText() #--> AM
? o1.pmText() #--> PM

? o1.DecimalPoint() #--> "."
? o1.Exponential()	#--> e
? o1.GroupSeparator() #--> ","

? o1.NegativeSign() #--> "-"
? o1.PositiveSign() #--> "+"
? o1.Percent()		#--> "%"

? o1.GroupSeparator() #--> ","

pf()
# Executed in 0.02 second(s) in Ring 1.23
