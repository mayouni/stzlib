# Narrative
# --------
#
# Extracted from stzfastprotest.ring, block #25.

load "../../stzBase.ring"

pr()

aImage = [
	[ 10, 20, 30 ],
	[ 12, 22, 33 ],
	[ 14, 24, 36 ]
]

FastProUpdate(aImage, [
	:Multiply = [ :Col = 1, :By = 2 ],
	:Add	  = [ 6, :ToCol = 2 ],
	:Divide	  = [ :Col = 3, :By = 3 ],
	:Subtract = [ 10, :FromCol = 1 ]
])

? @@NL(aImage)
#--> [
#	[ 10, 26, 10 ],
#	[ 14, 28, 11 ],
#	[ 18, 30, 12 ]
# ]

pf()
# Executed in 0.02 second(s) in Ring 1.22
