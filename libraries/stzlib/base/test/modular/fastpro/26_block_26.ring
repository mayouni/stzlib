# Narrative
# --------
# */
#
# Extracted from stzfastprotest.ring, block #26.

load "../../../stzBase.ring"

pr()

aImage = [
    [255, 100, 50],   # R, G, B for pixel 1
    [200, 150, 75],   # R, G, B for pixel 2
    [180, 90, 120]    # R, G, B for pixel 3
]

FastProUpdate(aImage, [

	:Multiply = [ :Col = 1, :By = 0.3 ],

	:Multiply = [ :Col = 2, :By = 0.59 ],
	:Multiply = [ :Col = 3, :By = 0.11 ],

        :Merge = [ :Cols = [ 1, :And = 2 ] ],
      	:Merge = [ :Cols = [ 1, :And = 2 ] ],

        :Copy  = [ :Row = 1, :ToRow = 3],
     	:Copy  = [ :Col = 1, :ToCol = 2]

])
    
# Grayscale Converted Image:
? @@NL(aImage)
#--> [
#	[ 194.50, 194.50, 194.50 ],
#	[ 237,    237,    237    ],
#	[ 160.20, 160.20, 160.20 ]
# ]

pf()
# Executed in 0.03 second(s) in Ring 1.22
