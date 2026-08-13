# Narrative
# --------
# pr()
#
# Extracted from stzchartest.ring, block #41.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

# 1, not Qt's 14. UnicodeCategoryNumber follows the library's own utf8proc-
# derived numbering, which UnicodeCategoriesXT() is keyed by -- 1 is
# letter_uppercase, 2 letter_lowercase, 9 number_decimaldigit. (Note the
# asymmetry with UnicodeDirectionNumber, which DOES translate to Qt's
# QChar::Direction values, and says so.)
? StzCharQ("R").UnicodeCategoryNumber() #--> 1
? StzCharQ("R").UnicodeCategory() #--> letter_uppercase

? StringIsLowercase("RiNG")	#--> FALSE
? StzCharQ("R").IsLetter() 		#--> TRUE

pf()
# Executed in 0.02 second(s) in Ring 1.23
