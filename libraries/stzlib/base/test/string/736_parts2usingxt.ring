# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #736.
#ERR Error (R14) : Calling Method without definition: parts2usingxt

load "../../stzBase.ring"

pr()

o1 = new stzString("Abc285XY&من")
? o1.Parts2UsingXT('{	# Or PartsAndPartitionersUsingXT()
	StzCharQ(@char).CharType()
}')

#--> [
#	"A"	= :Letter_Uppercase,
#	"bc"	= :Lerrer_Lowercase,
#	"285"	= :Number_DecimalDigit,
#	"XY"	= :Letter_Uppercase,
#	"&"	= :Punctauation_Other,
#o	"من"	= :Letter_Other
#    ]

pf()
# Executed in 0.15 second(s).
