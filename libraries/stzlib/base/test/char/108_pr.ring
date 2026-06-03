# Narrative
# --------
# pr()
#
# Extracted from stzchartest.ring, block #108.

load "../../stzBase.ring"


? "۲" = "٢" #--> FALSE

o1 = new stzChar("۲")
? o1.Name() #--> EXTENDED ARABIC-INDIC DIGIT TWO

? o1.Unicode() #--> 1778
? o1.UnicodeCategory() #--> number_decimaldigit
? o1.IsIndianDigit() #--> TRUE
? ""
o1 = new stzChar("٢")
? o1.Name() #--> ARABIC-INDIC DIGIT TWO
? o1.Unicode() # 1634
? o1.UnicodeCategory() #--> number_decimaldigit
? o1.IsIndianDigit() #--> TRUE

pf()
# Executed in 0.04 second(s) in Ring 1.23
