# Narrative
# --------
# pr()
#
# Extracted from stzchartest.ring, block #77.

load "../../stzBase.ring"


c1 = new stzChar("೨")
? c1.Unicode() #--> 3304
? c1.IsANumber() #--> TRUE
? c1.IsDigit() #--> TRUE

? c1.UnicodeCategory() #--> number_decimaldigit
? c1.Script() #--> kannada
? c1.Name() #--> KANNADA DIGIT TWO

pf()
# Executed in 0.04 second(s) in Ring 1.23
