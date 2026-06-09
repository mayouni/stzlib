# Narrative
# --------
# Different number types
#
# Extracted from stzextercodetest.ring, block #3.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oPyCode = new stzExterCode("python")

oPyCode.SetCode('
res = {
    "integer": 42,
    "decimal": 3.14159,
    "negative": -17,
    "calculation": 2 ** 8
}
')

oPyCode.Run()
? @@(oPyCode.Result())
#--> [
#	[ "integer", 42 ],
#	[ "decimal", 3.14 ],
#	[ "negative", -17 ],
#	[ "calculation", 256 ]
# ]

pf()
#--> Executed in 0.14 second(s) in Ring 1.23
