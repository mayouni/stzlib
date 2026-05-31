# Narrative
# --------
# pr()
#
# Extracted from stzchartest.ring, block #75.

load "../../../stzBase.ring"


o1 = new stzChar("٠")
? o1.Script()	#--> arabic
? o1.unicode()	#--> 1632
? o1.IsDigit()	#--> TRUE
? o1.Name()	#--> ARABIC-INDIC DIGIT ZERO
? ""
o1 = new stzChar("۰")
? o1.Script()	#--> arabic
? o1.unicode()	#--> 1776
? o1.IsDigit()	#--> TRUE
? o1.Name()	#--> EXTENDED ARABIC-INDIC DIGIT ZERO
? ""
o1 = new stzChar("3")
? o1.Script()	#--> common
? o1.IsDigit()	#--> TRUE
? o1.Name()	#--> DIGIT THREE
? ""
o1 = new stzChar("૫") 
? o1.Script()	#--> gujarati
? o1.IsDigit()	#--> TRUE
? o1.Name()	#--> GUJARATI DIGIT FIVE
? ""
o1 = new stzChar("၉")
? o1.Script()	#--> myanmar
? o1.IsDigit()	#--> TRUE
? o1.Name()	#--> MYANMAR DIGIT NINE
? ""
o1 = new stzChar("꧓")
? o1.Script()	#--> javanese
? o1.IsDigit()	#--> TRUE
? o1.Name()	#--> JAVANESE DIGIT THREE
? ""
o1 = new stzChar(43217) # I used unicode because the char itself is imprintable ꣑
? o1.Script()	#--> saurashtra
? o1.IsDigit()	#--> TRUE
? o1.Name()	#--> SAURASHTRA DIGIT ONE
? ""
o1 = new stzChar("൫") 
? o1.Script()	#--> malayalam
? o1.IsDigit()	#--> TRUE
? o1.Name()	#--> MALAYALAM DIGIT FIVE
? ""
o1 = new stzChar("０")
? o1.Script()	#--> common
? o1.IsDigit()	#--> TRUE
? o1.Name()	#--> FULLWIDTH DIGIT ZERO

pf()
# Executed in 0.28 second(s) in Ring 1.23
