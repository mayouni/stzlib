load "../max/stzmax.ring"


/*===

pr()

# Create a 1D list and set all items to 1000

aList = 1:1_000_000

FastProUpdate(aList, :set = [ :items, :with = 1000 ])
? ShowShort(aList)
#--> [ 1000, 1000, 1000, "...", 1000, 1000, 1000 ]

pf()
# Executed in 0.15 second(s) in Ring 1.22

/*---

pr()

# Create a 2D list and set first column to 100

aMatrix = [
	[1, 2, 3],
	[4, 5, 6],
	[7, 8, 9]
]

FastProUpdate(aMatrix, :set = [ :col = 1, :with = 100 ])
? @@NL(aMatrix)
#--> [
#	[ 100, 2, 3 ],
#	[ 100, 5, 6 ],
#	[ 100, 8, 9 ]
# ]

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*---

pr()

# Create a matrix and perform multi-row/column operations

aMatrix = [
	[1, 2, 3],
	[4, 5, 6],
	[7, 8, 9]
]

# Set rows 1-2 to value 100

FastProUpdate(aMatrix, :set = [ :rows = [1, 2], :with = 100 ])
? @@NL(aMatrix) + NL
#--> [
#	[ 100, 100, 100 ],
#	[ 100, 100, 100 ],
#	[   7,   8,   9 ]
# ]

# Multiply column 2 by 10, result in column 3

FastProUpdate(aMatrix, :Multiply = [ :Col = 2, :By = 10, :ToCol = 3 ])

? @@NL(aMatrix)
#--> [
#	[ 100, 100, 1000 ],
#	[ 100, 100, 1000 ],
#	[   7,   8,   80 ]
# ]

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*---

pr()

aMatrix = [
	[ 1, 2, 3 ],
	[ 4, 5, 6 ],
	[ 7, 8, 9 ]
]

FastProUpdate(aMatrix, :Multiply = [ :Col = 2, :By = 2 ])
? @@NL(aMatrix) + NL
#--> [
#	[ 1,  4, 3 ],
#	[ 4, 10, 6 ],
#	[ 7, 16, 9 ]
# ]

FastProUpdate(aMatrix, :Multiply = [ :Col = 1, :By = 3, :ToCol = 3 ])
? @@NL(aMatrix)
#--> [
#	[ 1,  4, 3 ],
#	[ 4, 10, 12 ],
#	[ 7, 16, 21 ]
# ]

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*---

pr()

aMatrix = [
	[ 1, 2, 3 ],
	[ 4, 5, 6 ],
	[ 7, 8, 9 ]
]

FastProUpdate(aMatrix, :Set = [ :Row = 2, :With = 0 ])
? @@NL(aMatrix) + NL
#--> [
#	[ 1, 2, 3 ],
#	[ 0, 0, 0 ],
#	[ 7, 8, 9 ]
# ]

FastProUpdate(aMatrix, :Set = [ :Col = 2, :With = 0 ])
? @@NL(aMatrix)
#--> [
#	[ 1, 0, 3 ],
#	[ 0, 0, 0 ],
#	[ 7, 0, 9 ]
# ]

pf()
# Executed in almost 0 second(s) in Ring 1.22


/*---

pr()

aMatrix = 1:7

FastProUpdate(aMatrix, :set = [ :all = :with = 5 ])
? @@NL(aMatrix)

pf()
/*---

pr()

aMatrix = [
	[ 1, 2, 3 ],
	[ 4, 5, 6 ],
	[ 7, 8, 9 ]
]

FastProUpdate(aMatrix, :set = [ :all = :with = 5 ])
? @@NL(aMatrix)

pf()

/*---

pr()

aMatrix = [
	[ 1, 2, 3 ],
	[ 4, 5, 6 ],
	[ 7, 8, 9 ]
]

FastProUpdate(aMatrix, :Set = [ :Rows = [ 2, 3 ], :With = 5 ])
? @@NL(aMatrix)
#--> [
#	[ 1, 2, 3 ],
#	[ 5, 5, 5 ],
#	[ 5, 5, 5 ]
# ]

FastProUpdate(aMatrix, :Set = [ :Cols = [ 2, 3 ], :With = 0 ])
? @@NL(aMatrix)
#--> [
#	[ 1, 0, 0 ],
#	[ 5, 0, 0 ],
#	[ 5, 0, 0 ]
# ]

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*---

pr()

aMatrix = [
	[ 1, 2, 3 ],
	[ 1, 2, 3 ],
	[ 1, 2, 3 ]
]

FastProUpdate(aMatrix, :Add = [ 8, :ToColsFrom = [ 1, :To = 2 ] ])
? @@NL(aMatrix) + NL
#--> [
#	[ 9, 10, 3 ],
#	[ 9, 10, 3 ],
#	[ 9, 10, 3 ]
# ]

FastProUpdate(aMatrix, :Add = [ 7, :ToRowsFrom = [ 2, :To = 3 ] ])
? @@NL(aMatrix)
#--> [
#	[ 9, 10, 3 ],
#	[ 16, 17, 10 ],
#	[ 16, 17, 10 ]
# ]

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*---

pr()

aMatrix = [
	[ 10, 20, 30 ],
	[ 40, 50, 60 ],
	[ 70, 80, 90 ]
]

FastProUpdate(aMatrix, :Subtract = [ 10, :FromColsFrom = [ 1, :To = 3 ] ])
? @@NL(aMatrix) + NL
#--> [
#	[ 0, 10, 20 ],
#	[ 30, 40, 50 ],
#	[ 60, 70, 80 ]
# ]

FastProUpdate(aMatrix, :Subtract = [ 10, :FromRowsFrom = [ 1, :To = 3 ] ])
? @@NL(aMatrix)
#--> [
#	[ -10, 0, 10 ],
#	[ 20, 30, 40 ],
#	[ 50, 60, 70 ]
# ]

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*---

pr()

aMatrix = [
	[ 2, 4, 8 ],
	[ 1, 2, 4 ],
	[ 2, 4, 9 ]
]


FastProUpdate(aMatrix, :Multiply = [ :Col = 2, :By = 2 ])
? @@NL(aMatrix) + NL
#--> [
#	[ 2, 8, 8 ],
#	[ 1, 4, 4 ],
#	[ 2, 8, 9 ]
# ]

FastProUpdate(aMatrix, :Multiply = [ :Col = 2, :By = 2, :ToCol = 3 ])
? @@NL(aMatrix) + NL
#--> [
#	[ 2, 8, 16 ],
#	[ 1, 4,  8 ],
#	[ 2, 8, 16 ]
# ]

#--

FastProUpdate(aMatrix, :Multiply = [ :Row = 2, :By = 2 ])
? @@NL(aMatrix)
#--> [
#	[ 2, 8, 16 ],
#	[ 2, 8, 16 ],
#	[ 2, 8, 16 ]
# ]


pf()
# Executed in almost 0 second(s) in Ring 1.22

/*---

pr()

aMatrix = [
	[ 2, 4, 8 ],
	[ 1, 2, 4 ],
	[ 3, 4, 8 ]
]

FastProUpdate(aMatrix, :Divide = [ :Col = 2, :By = 2 ])
? @@NL(aMatrix)
#--> [
#	[ 2, 2, 8 ],
#	[ 1, 1, 4 ],
#	[ 3, 2, 8 ]
# ]

FastProUpdate(aMatrix, :Divide = [ :Col = 3, :By = 2, :ToCol = 1 ])
? @@NL(aMatrix)
#--> [
#	[ 4, 2, 8 ],
#	[ 2, 1, 4 ],
#	[ 4, 2, 8 ]
# ]

pf()
# Executed in 0.01 second(s) in Ring 1.22

/*---

pr()

aMatrix = [
	[ 2, 4, 8 ],
	[ 1, 2, 4 ],
	[ 3, 4, 8 ]
]

FastProUpdate(aMatrix, :Divide = [ :Row = 1, :By = 2 ])
? @@NL(aMatrix) + NL
#--> [
#	[ 1, 2, 4 ],
#	[ 1, 2, 4 ],
#	[ 3, 4, 8 ]
# ]

#--

FastProUpdate(aMatrix, :Divide = [ :Col = 3, :By = 4 ])
? @@NL(aMatrix) + NL
#--> [
#	[ 1, 2, 1 ],
#	[ 1, 2, 1 ],
#	[ 3, 4, 4 ]
#]

FastProUpdate(aMatrix, :Divide = [ :Col = 2, :By = 2, :ToCol = 1 ])
? @@NL(aMatrix)
#--> [
#	[ 1, 2, 1 ],
#	[ 1, 2, 1 ],
#	[ 2, 4, 2 ]
# ]

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*---

pr()

aMatrix = [
	[ 5, 5, 5 ],
	[ 5, 5, 5 ],
	[ 5, 5, 5 ]
]

FastProUpdate(aMatrix, :Set = [ :Col = 1, :Step = 0 ])
? @@NL( aMatrix )
#--> [
#	[ 1, 5, 5 ],
#	[ 2, 5, 5 ],
#	[ 3, 5, 5 ]
# ]

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*===

pr()

# Simulate an image matrix with RGB channels

aImage = [
	[255, 100, 50],   # R, G, B for pixel 1
	[200, 150, 75],   # R, G, B for pixel 2
	[180, 90, 120]    # R, G, B for pixel 3
]
   
# Simulate grayscale conversion with weighted channels

FastProUpdate(aImage, [

	:Multiply = [ :Col = 1, :By = 0.3, :ToCol = 1 ],     	# R *= 0.3

	:Multiply = [ :Col = 2, :By = 0.59, :ToCol = 1 ],    	# G *= 0.59
	:Multiply = [ :Col = 3, :By = 0.11, :ToCol = 1 ],    	# B *= 0.11

        :Merge = [ :Cols = [ 1, 2 ], :InCol = 1 ],    		# R += G
      	:Merge = [ :Cols = [ 1, 2 ], :InCol = 1 ], 		# R += B

        :Copy  = [ :Row = 1, :ToRow = 3],    			# G = R (grayscale)
     	:Copy  = [ :Col = 1, :toCol = 2]       			# B = R (grayscale)

])
    
# Grayscale Converted Image:
? @@NL(aImage)
#--> [
#	[ 150.45, 11, 50 ],
#	[ 118, 16.50, 75 ],
#	[ 106.20, 9.90, 120 ]
# ]

pf()
# Executed in 0.01 second(s) in Ring 1.22
