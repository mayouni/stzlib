# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #735.
#ERR Error (R19) : Calling function with less number of parameters

load "../../stzBase.ring"

pr()

o1 = new stzString("AM23-X ")
? o1.PartsAndPartitionersUsingXT('StzCharQ(@char).CharType()') # or Parts2UsingXT()
#--> [
#	"AM" = :Letter_Uppercase,
#	"23" = :Number_Decimaldigit,
#	"-"  = :Punctuation_Dash",
#	"X"  = :Letter_Uppercase,
#	" "  = :Separator_Space
#    ]

pf()
# Executed in 0.12 second(s).
