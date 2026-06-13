# Narrative
# --------
# pr()
#
# Extracted from stzfastprotest.ring, block #1.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

aMatrix = [
	[ 1, 2, 3 ],
	[ 2, 4, 6 ],
	[ 3, 6, 9 ]
]

FastProUpdate(aMatrix, :Raise = [ :Col = 1, :ToPower = 2 ])
# In RinFastPro: updateColumn(aMatrix, :pow, 1, 2)

? @@NL(aMatrix)
#--> [
# 	[ 1, 2, 3 ],
# 	[ 4, 4, 6 ],
# 	[ 9, 6, 9 ]
# ]

pf()
# Executed in almost 0 second(s) in Ring 1.22
