# Narrative
# --------
# #TODO check after reincluding check()
#
# Extracted from stzStringTest.ring, block #481.

load "../../stzBase.ring"


pr()

? Q("248").AllCharsAreXT([ :Even, :Positive, :Numbers ], :EvaluateFrom = :RTL)

? Q("123").Check( 'isnumber( 0+(@char) )' ) #--> TRUE

pf()
