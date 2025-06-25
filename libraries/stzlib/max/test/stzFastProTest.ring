load "../stzmax.ring"

/*---

pr()

aMatrix = [
	[ 1, 2, 3 ],
	[ 2, 4, 6 ],
	[ 3, 6, 9 ]
]

FastProUpdate(aMatrix, :Raise = [ :Col = 1, :ToPower = 2 ])
? @@NL(aMatrix)

# In RinFastPro:
# updateColumn(aMatrix, :pow, 1, 2)

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*---

pr()

aMatrix = [
	[ 1, 2, 3 ],
	[ 1, 2, 3 ],
	[ 1, 2, 3 ]
]

FastProUpdate(aMatrix, :Raise = [ :ColsFrom = [ 2, :To = 3 ], :ToPower = 2 ])
? @@NL(aMatrix) + NL
#--> [
#	[ 1, 4, 9 ],
#	[ 1, 4, 9 ],
#	[ 1, 4, 9 ]
# ]

FastProUpdate(aMatrix, :Raise = [ :RowsFrom = [ 2, :To = 3 ], :ToPower = 2 ])
? @@NL(aMatrix)
#--> [
#	[ 1, 4, 9 ],
#	[ 1, 16, 81 ],
#	[ 1, 16, 81 ]
# ]

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*---

pr()

? IsListOfNumbers(1:1_000_000)
#--> TRUE

pf()
# Executed in 0.23 second(s) in Ring 1.22

/*===

pr()

# Create a 1D list and set all items to 1000

myList = 1:1_000_000

FastProUpdate(myList, :set = [ :All, :with = 1000 ])
? ShowShort(myList)
#--> [ 1000, 1000, 1000, "...", 1000, 1000, 1000 ]

# In RinFastPro
# updateList(myList, :set, :items, 1000)


pf()
# Executed in 0.34 second(s) in Ring 1.22

/*---

pr()

myList = 1:7

FastProUpdate(myList, :set = [ :all, :with = 5 ])
? @@(myList)
#--> [ 5, 5, 5, 5, 5, 5, 5 ]

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*---

pr()

aMatrix = [
	[ 1, 2, 3 ],
	[ 4, 5, 6 ],
	[ 7, 8, 9 ]
]

FastProUpdate(aMatrix, :set = [ :all, :with = 5 ])
? @@NL(aMatrix)
#--> [
#	[ 5, 5, 5 ],
#	[ 5, 5, 5 ],
#	[ 5, 5, 5 ]
# ]

pf()
# Executed in almost 0 second(s) in Ring 1.22

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
*/
pr()

aMatrix = [
	[ 1, 2, 3 ],
	[ 4, 5, 6 ],
	[ 7, 8, 9 ]
]

FastProUpdate(aMatrix, :Set = [ :Rows = [ :From = 2, :To = 3 ], :With = 5 ])
? @@NL(aMatrix)
#--> [
#	[ 1, 2, 3 ],
#	[ 5, 5, 5 ],
#	[ 5, 5, 5 ]
# ]

FastProUpdate(aMatrix, :Set = [ :Cols = [ :From = 2, :To = 3 ], :With = 0 ])
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

FastProUpdate(aMatrix, :Add = [ 8, :ToCol = 2 ])
? @@NL(aMatrix)
#--> [
#	[ 1, 10, 3 ],
#	[ 1, 10, 3 ],
#	[ 1, 10, 3 ]
# ]

FastProUpdate(aMatrix, :Subtract = [ 10, :FromCol = 2 ])
? @@NL(aMatrix)
#--> [
#	[ 1, 0, 3 ],
#	[ 1, 0, 3 ],
#	[ 1, 0, 3 ]
# ]

pf()

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
	[ 1, 2, 3 ],
	[ 1, 2, 3 ],
	[ 1, 2, 3 ]
]

FastProUpdate(aMatrix, :Multiply = [ :ColsFrom = [ 1, :To = 3 ], :By = 2 ])
? @@NL(aMatrix) + NL
#--> [
# 	[ 2, 4, 6 ],
# 	[ 2, 4, 6 ],
# 	[ 2, 4, 6 ]
# ]

FastProUpdate(aMatrix, :Multiply = [ :RowsFrom = [ 2, :To = 3 ], :By = 3 ])
? @@NL(aMatrix)
#--> [
#	[ 2, 4, 6 ],
#	[ 6, 12, 18 ],
#	[ 6, 12, 18 ]
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
# Executed in almost 0 second(s) in Ring 1.22

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
#	[ 3, 4, 2 ]
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
	[ 1, 2, 3 ],
	[ 1, 2, 3 ],
	[ 1, 2, 3 ]
]

FastProUpdate(aMatrix, :Divide = [ :ColsFrom = [ 1, :To = 3 ], :By = 2 ])
? @@NL(aMatrix) + NL
#--> [
#	[ 0.50, 1, 1.50 ],
#	[ 0.50, 1, 1.50 ],
#	[ 0.50, 1, 1.50 ]
# ]

FastProUpdate(aMatrix, :Divide = [ :RowsFrom = [ 2, :To = 3 ], :By = 3 ])
? @@NL(aMatrix)
#--> [
#	[ 0.50, 1, 1.50 ],
#	[ 0.17, 0.33, 0.50 ],
#	[ 0.17, 0.33, 0.50 ]
# ]

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*---

pr()

aMatrix = [
	[ 1, 2, 4 ],
	[ 2, 4, 9 ],
	[ 2, 7, 8 ]
]

FastProUpdate(aMatrix, :Modulo = [ :Col = 3, :By = 2 ])

? @@NL(aMatrix)
#--> aMatrix = [
#	[ 1, 2, 0 ],
#	[ 2, 4, 1 ],
#	[ 2, 7, 0 ]
# ]

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*---

pr()

aMatrix = [
	[ 0, 5, 3 ],
	[ 0, 7, 9 ],
	[ 0, 9, 7 ]
]

FastProUpdate(aMatrix, :Modulo = [ :ColsFrom = [ 2, :To = 3 ], :By = 2 ])
? @@NL(aMatrix) + NL
#--> [
#	[ 0, 1, 1 ],
#	[ 0, 1, 1 ],
#	[ 0, 1, 1 ]
# ]

#---

aMatrix = [
	[ 0, 0, 0 ],
	[ 2, 7, 4 ],
	[ 5, 9, 7 ]
]

FastProUpdate(aMatrix, :Modulo = [ :RowsFrom = [ 2, :To = 3 ], :By = 2 ])
? @@NL(aMatrix)
#--> [
#	[ 0, 0, 0 ],
#	[ 0, 1, 0 ],
#	[ 1, 1, 1 ]
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

/*---

pr()

aMatrix = [
	[ 3, 7, 5 ],
	[ 2, 8, 0 ],
	[ 5, 5, 0 ]
]

FastProUpdate(aMatrix, :Merge = [ :Cols = [ 1, 2 ], :InCol = 2 ])
? @@NL(aMatrix) + NL
#--> [
#	[ 3, 10, 5 ],
#	[ 2, 10, 0 ],
#	[ 5, 10, 0 ]
# ]

FastProUpdate(aMatrix, :Merge = [ :Rows = [ 2, 3 ], :InRow = 3 ])
? @@NL(aMatrix)
#--> [
#	[ 3, 10, 5 ],
#	[ 2, 10, 0 ],
#	[ 7, 20, 0 ]
# ]

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*===

pr()

#--- Multiply

str = '[ "muliply", [ [ "col", 1 ], [ "by", 2 ] ] ]'

? @@( NumbersIn(str) )

_aCommandsXT = [
	:set = [ :set, 1, 2 ],
	:add = [ :add, 2, 1 ],
	:subtract = [ :sub, 2, 1 ],
	:multiply = [ :mul, 1, 2 ],
	:divide = [ :div, 1, 2 ],
	:raise = [ :pow, 1, 2 ],
	:modulo = [ :rem, 1, 2 ],
	:copy = [ :copy, 1, 2 ],
	:merge = [ :merge, 1, 2 ]
]




pf()

/*---
*/
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

/*---
*/
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
