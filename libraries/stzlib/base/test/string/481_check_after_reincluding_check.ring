# Narrative
# --------
# #TODO check after reincluding check()
#
# Extracted from stzStringTest.ring, block #481.
#ERR Error (R20) : Calling function with extra number of parameters

load "../../stzBase.ring"


pr()

? Q("248").AllCharsAreXT([ :Even, :Positive, :Numbers ], :EvaluateFrom = :RTL)

? Q("123").Check( 'isnumber( 0+(@char) )' ) #--> TRUE

pf()
