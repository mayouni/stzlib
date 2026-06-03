load "../stzbase.ring"

#==========================#
#  BASIC PATTERN MATCHING  #
#==========================#

/*--- Matching exact size

pr()

oMx = new stzMatrex("{Size(3x3)}")

aMatrix = [
	[1, 2, 3],
	[4, 5, 6],
	[7, 8, 9]
]

? oMx.Match(aMatrix)
#--> TRUE

pf()
# Executed in 0.03 second(s) in Ring 1.24

/*--- Matching wrong size

pr()

oMx = new stzMatrex("{size(2x2)}")

aMatrix = [
	[1, 2, 3],
	[4, 5, 6],
	[7, 8, 9]
]

? oMx.Match(aMatrix)
#--> FALSE

pf()
# Executed in 0.02 second(s) in Ring 1.24

/*--- Matching any size (mxn notation)

pr()

oMx = new stzMatrex("{size(mxn)}")

aMatrix1 = [[1, 2], [3, 4]]
aMatrix2 = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
aMatrix3 = [[1, 2, 3, 4]]

? oMx.Match(aMatrix1)
#--> TRUE

? oMx.Match(aMatrix2)
#--> TRUE

? oMx.Match(aMatrix3)
#--> TRUE

pf()
# Executed in 0.04 second(s) in Ring 1.24

#==================#
#  SHAPE MATCHING  #
#==================#

/*--- Square matrix

pr()

oMx = new stzMatrex("{shape(square)}")

aSquare = [[1, 2], [3, 4]]
aRect = [[1, 2, 3], [4, 5, 6]]

? oMx.Match(aSquare)
#--> TRUE

? oMx.Match(aRect)
#--> FALSE

pf()
# Executed in 0.02 second(s) in Ring 1.24

/*--- Rectangular matrix

pr()

oMx = new stzMatrex("{shape(rectangular)}")

aSquare = [[1, 2], [3, 4]]
aRect = [[1, 2, 3], [4, 5, 6]]

? oMx.Match(aSquare)
#--> FALSE

? oMx.Match(aRect)
#--> TRUE

pf()
# Executed in 0.02 second(s) in Ring 1.24

/*--- Tall vs wide matrices

pr()

oMxTall = new stzMatrex("{shape(tall)}")
oMxWide = new stzMatrex("{shape(wide)}")

aTall = [[1], [2], [3], [4]]
aWide = [[1, 2, 3, 4]]

? oMxTall.Match(aTall)
#--> TRUE

? oMxTall.Match(aWide)
#--> FALSE

? oMxWide.Match(aWide)
#--> TRUE

? oMxWide.Match(aTall)
#--> FALSE

pf()
# Executed in 0.03 second(s) in Ring 1.24

/*--- Row and column vectors

pr()

oMxRow = new stzMatrex("{shape(row)}")
oMxCol = new stzMatrex("{shape(column)}")

aRowVector = [[1, 2, 3, 4, 5]]
aColVector = [[1], [2], [3]]

? oMxRow.Match(aRowVector)
#--> TRUE

? oMxRow.Match(aColVector)
#--> FALSE

? oMxCol.Match(aColVector)
#--> TRUE

? oMxCol.Match(aRowVector)
#--> FALSE

pf()
# Executed in 0.03 second(s) in Ring 1.24

#=====================#
#  PROPERTY MATCHING  #
#=====================#

/*--- Identity matrix

pr()

oMx = new stzMatrex("{property(identity)}")

aIdentity = [
	[1, 0, 0],
	[0, 1, 0],
	[0, 0, 1]
]

aNotIdentity = [
	[1, 0, 0],
	[0, 2, 0],
	[0, 0, 1]
]

? oMx.Match(aIdentity)
#--> TRUE

? oMx.Match(aNotIdentity)
#--> FALSE

pf()
# Executed in 0.03 second(s) in Ring 1.24

/*--- Symmetric matrix

pr()

oMx = new stzMatrex("{property(symmetric)}")

aSymmetric = [
	[1, 2, 3],
	[2, 4, 5],
	[3, 5, 6]
]

aAsymmetric = [
	[1, 2, 3],
	[4, 5, 6],
	[7, 8, 9]
]

? oMx.Match(aSymmetric)
#--> TRUE

? oMx.Match(aAsymmetric)
#--> FALSE

pf()
# Executed in 0.03 second(s) in Ring 1.24

/*--- Diagonal matrix

pr()

oMx = new stzMatrex("{property(diagonal)}")

aDiagonal = [
	[5, 0, 0],
	[0, 3, 0],
	[0, 0, 7]
]

aNonDiagonal = [
	[5, 1, 0],
	[0, 3, 0],
	[0, 0, 7]
]

? oMx.Match(aDiagonal)
#--> TRUE

? oMx.Match(aNonDiagonal)
#--> FALSE

pf()
# Executed in 0.03 second(s) in Ring 1.24

/*--- Zero matrix

pr()

oMx = new stzMatrex("{property(zero)}")

aZero = [
	[0, 0, 0],
	[0, 0, 0],
	[0, 0, 0]
]

aNonZero = [
	[0, 0, 1],
	[0, 0, 0],
	[0, 0, 0]
]

? oMx.Match(aZero)
#--> TRUE

? oMx.Match(aNonZero)
#--> FALSE

pf()
# Executed in 0.03 second(s) in Ring 1.24

/*--- Upper triangular matrix

pr()

oMx = new stzMatrex("{property(upper)}")

aUpper = [
	[1, 2, 3],
	[0, 4, 5],
	[0, 0, 6]
]

aLower = [
	[1, 0, 0],
	[2, 3, 0],
	[4, 5, 6]
]

? oMx.Match(aUpper)
#--> TRUE

? oMx.Match(aLower)
#--> FALSE

pf()
# Executed in 0.03 second(s) in Ring 1.24

/*--- Lower triangular matrix

pr()

oMx = new stzMatrex("{property(lower)}")

aLower = [
	[1, 0, 0],
	[2, 3, 0],
	[4, 5, 6]
]

aUpper = [
	[1, 2, 3],
	[0, 4, 5],
	[0, 0, 6]
]

? oMx.Match(aLower)
#--> TRUE

? oMx.Match(aUpper)
#--> FALSE

pf()
# Executed in 0.02 second(s) in Ring 1.24

#=======================#
#  ELEMENT CONSTRAINTS  #
#=======================#

/*--- Elements in range

pr()

oMx = new stzMatrex("{element(0..10)}")

aInRange = [
	[1, 2, 3],
	[4, 5, 6],
	[7, 8, 9]
]

aOutOfRange = [
	[1, 2, 15],
	[4, 5, 6],
	[7, 8, 9]
]

? oMx.Match(aInRange)
#--> TRUE

? oMx.Match(aOutOfRange)
#--> FALSE

pf()
# Executed in 0.03 second(s) in Ring 1.24

/*--- Elements from set

pr()

oMx = new stzMatrex("{element({0;1})}")

aBinary = [
	[1, 0, 1],
	[0, 1, 0],
	[1, 1, 0]
]

aNonBinary = [
	[1, 0, 2],
	[0, 1, 0],
	[1, 1, 0]
]

? oMx.Match(aBinary)
#--> TRUE

? oMx.Match(aNonBinary)
#--> FALSE

pf()

/*--- Exact element value

pr()

oMx = new stzMatrex("{element(5)}")

aAllFives = [
	[5, 5, 5],
	[5, 5, 5]
]

aMixed = [
	[5, 5, 5],
	[5, 3, 5]
]

? oMx.Match(aAllFives)
#--> TRUE

? oMx.Match(aMixed)
#--> FALSE

pf()

#=====================#
#  COMBINED PATTERNS  #
#=====================#

/*--- Square AND identity

pr()

oMx = new stzMatrex("{shape(square) & property(identity)}")

aIdentity3x3 = [
	[1, 0, 0],
	[0, 1, 0],
	[0, 0, 1]
]

aSquareNotIdentity = [
	[1, 2, 3],
	[4, 5, 6],
	[7, 8, 9]
]

? oMx.Match(aIdentity3x3)
#--> TRUE

? oMx.Match(aSquareNotIdentity)
#--> FALSE

pf()

/*--- Size AND symmetric

pr()

oMx = new stzMatrex("{size(3x3) & property(symmetric)}")

aValid = [
	[1, 2, 3],
	[2, 4, 5],
	[3, 5, 6]
]

aWrongSize = [
	[1, 2],
	[2, 3]
]

aNotSymmetric = [
	[1, 2, 3],
	[4, 5, 6],
	[7, 8, 9]
]

? oMx.Match(aValid)
#--> TRUE

? oMx.Match(aWrongSize)
#--> FALSE

? oMx.Match(aNotSymmetric)
#--> FALSE

pf()

/*--- Square OR rectangular (alternation)

pr()

oMx = new stzMatrex("{(shape(square) | shape(rectangular))}")

aSquare = [[1, 2], [3, 4]]
aRect = [[1, 2, 3], [4, 5, 6]]

? oMx.Match(aSquare)
#--> TRUE

? oMx.Match(aRect)
#--> TRUE

pf()

/*--- 2x2 OR 3x3 with diagonal property

pr()

oMx = new stzMatrex("{(size(2x2) | size(3x3)) & property(diagonal)}")

aDiag2x2 = [
	[1, 0],
	[0, 2]
]

aDiag3x3 = [
	[1, 0, 0],
	[0, 2, 0],
	[0, 0, 3]
]

aDiag4x4 = [
	[1, 0, 0, 0],
	[0, 2, 0, 0],
	[0, 0, 3, 0],
	[0, 0, 0, 4]
]

? oMx.Match(aDiag2x2)
#--> TRUE

? oMx.Match(aDiag3x3)
#--> TRUE

? oMx.Match(aDiag4x4)
#--> FALSE

pf()

#============#
#  NEGATION  #
#============#

/*--- NOT symmetric

pr()

oMx = new stzMatrex("{@!property(symmetric)}")

aSymmetric = [
	[1, 2],
	[2, 3]
]

aAsymmetric = [
	[1, 2],
	[3, 4]
]

? oMx.Match(aSymmetric)
#--> FALSE

? oMx.Match(aAsymmetric)
#--> TRUE

pf()

/*--- NOT identity

pr()

oMx = new stzMatrex("{@!property(identity)}")

aIdentity = [
	[1, 0, 0],
	[0, 1, 0],
	[0, 0, 1]
]

aDiagonal = [
	[2, 0, 0],
	[0, 3, 0],
	[0, 0, 4]
]

? oMx.Match(aIdentity)
#--> FALSE

? oMx.Match(aDiagonal)
#--> TRUE

pf()

/*--- Square but NOT diagonal

pr()

oMx = new stzMatrex("{shape(square) & @!property(diagonal)}")

aDiagonal = [
	[1, 0, 0],
	[0, 2, 0],
	[0, 0, 3]
]

aFull = [
	[1, 2, 3],
	[4, 5, 6],
	[7, 8, 9]
]

? oMx.Match(aDiagonal)
#--> FALSE

? oMx.Match(aFull)
#--> TRUE

pf()

#=============================#
#  FINDING MATCHING MATRICES  #
#=============================#

/*--- Find all square matrices

pr()

oMx = new stzMatrex("{shape(square)}")

aMatrices = [
	[[1, 2], [3, 4]],
	[[1, 2, 3], [4, 5, 6]],
	[[1, 2, 3], [4, 5, 6], [7, 8, 9]],
	[[1, 2, 3, 4]]
]

? oMx.CountMatchingMatricesIn(aMatrices)
#--> 2

? @@NL( oMx.FindMatchingMatricesIn(aMatrices) )
#--> [ 1, 3 ]

? @@NL( oMx.MatchingMatricesIn(aMatrices) )
#-->
'
[
	[
		[ 1, 2 ],
		[ 3, 4 ]
	],
	[
		[ 1, 2, 3 ],
		[ 4, 5, 6 ],
		[ 7, 8, 9 ]
	]
]
'

pf()

/*--- Count diagonal matrices

pr()

oMx = new stzMatrex("{property(diagonal)}")

aMatrices = [
	[[1, 0], [0, 2]],
	[[1, 2], [3, 4]],
	[[5, 0, 0], [0, 6, 0], [0, 0, 7]],
	[[1, 1], [1, 1]]
]

? oMx.CountMatchingMatrices( :In = aMatrices )
#--> 2

pf()

/*--- First matching matrix

pr()

oMx = new stzMatrex("{property(identity)}")

aMatrices = [
	[[1, 2], [3, 4]],
	[[1, 0], [0, 1]],
	[[5, 6], [7, 8]]
]

? @@( oMx.FirstMatchingMatrixIn(aMatrices) )
#--> [ [1, 0], [0, 1] ]

? oMx.FindFirstMatchingMatrix(:In = aMatrices)
#--> 2

pf()

/*--- Check if matches any

pr()

oMx = new stzMatrex("{property(symmetric)}")

aMatrices = [
	[[1, 2], [3, 4]],
	[[5, 6], [7, 8]]
]

? oMx.MatchesNone(:In = aMatrices)
#--> FALSE

pf()

/*--- Check if matches all

pr()

oMx = new stzMatrex("{shape(square)}")

aAllSquare = [
	[[1, 2], [3, 4]],
	[[1, 2, 3], [4, 5, 6], [7, 8, 9]]
]

aMixed = [
	[[1, 2], [3, 4]],
	[[1, 2, 3], [4, 5, 6]]
]

? oMx.MatchesAll( :In = aAllSquare )
#--> TRUE

? oMx.MatchesAll(aMixed)
#--> FALSE

pf()

#===========================#
#  ANALYSIS AND STATISTICS  #
#===========================#

/*--- Analyze matches

pr()

oMx = new stzMatrex("{size(2x2)}")

aMatrices = [
	[[1, 2], [3, 4]],
	[[5, 6], [7, 8]],
	[[1, 2, 3], [4, 5, 6]],
	[[9, 10], [11, 12]]
]

? @@NL( oMx.AnalyzeMatches(aMatrices) )
#-->
'
[
	[ "pattern", "{size(2x2)}" ],
	[ "totalmatrices", 4 ],
	[ "matchingcount", 3 ],
	[ "nonmatchingcount", 1 ],
	[ "matchrate", 0.75 ],
	[
		"matching",
		[
			[
				[ 1, 2 ],
				[ 3, 4 ]
			],
			[
				[ 5, 6 ],
				[ 7, 8 ]
			],
			[
				[ 9, 10 ],
				[ 11, 12 ]
			]
		]
	],
	[
		"nonmatching",
		[
			[
				[ 1, 2, 3 ],
				[ 4, 5, 6 ]
			]
		]
	]
]
'

pf()

/*--- Similarity score

pr()

oMx = new stzMatrex("")

aMatrix1 = [[1, 2], [3, 4]]
aMatrix2 = [[1, 2], [3, 4]]
aMatrix3 = [[1, 0], [0, 4]]

? oMx.SimilarityScore(aMatrix1, aMatrix2)
#--> 1.0

? oMx.SimilarityScore(aMatrix1, aMatrix3)
#--> 0.5

pf()

/*--- Most similar matrix

pr()

oMx = new stzMatrex("")

aTarget = [[1, 2], [3, 4]]

aCandidates = [
	[[1, 2], [3, 0]],
	[[5, 6], [7, 8]],
	[[1, 2], [3, 4]]
]

? @@( oMx.MostSimilarMatrix(:To = aTarget, :In = aCandidates) )
#--> [[1, 2], [3, 4]]

? oMx.FindMostSimilarMatrix(aTarget, aCandidates) 

pf()

#=======================#
#  PATTERN COMBINATION  #
#=======================#

/*--- Combining patterns with AND

pr()

oMx1 = new stzMatrex("{shape(square)}")
oMx2 = new stzMatrex("{property(symmetric)}")

oMxCombined = oMx1.And_(oMx2)

aValid = [
	[1, 2, 3],
	[2, 4, 5],
	[3, 5, 6]
]

aInvalid = [
	[1, 2, 3],
	[4, 5, 6],
	[7, 8, 9]
]

? oMxCombined.Match(aValid)
#--> TRUE

? oMxCombined.Match(aInvalid)
#--> FALSE

pf()

/*--- Combining patterns with OR

pr()

oMx1 = new stzMatrex("{property(identity)}")
oMx2 = new stzMatrex("{property(zero)}")

oMxCombined = oMx1.Or_(oMx2)

aIdentity = [[1, 0], [0, 1]]
aZero = [[0, 0], [0, 0]]
aOther = [[1, 2], [3, 4]]

? oMxCombined.Match(aIdentity)
#--> TRUE

? oMxCombined.Match(aZero)
#--> TRUE

? oMxCombined.Match(aOther)
#--> FALSE

pf()

/*--- Negating a pattern

pr()

oMx = new stzMatrex("{property(diagonal)}")
oMxNot = oMx.Not_()

aDiagonal = [[1, 0], [0, 2]]
aNonDiagonal = [[1, 2], [3, 4]]

? oMxNot.Match(aDiagonal)
#--> FALSE

? oMxNot.Match(aNonDiagonal)
#--> TRUE

pf()

#========================#
#  FILTERING OPERATIONS  #
#========================#

/*--- Filter square matrices

pr()

oMx = new stzMatrex("{shape(square)}")

aMatrices = [
	[[1, 2], [3, 4]],
	[[1, 2, 3], [4, 5, 6]],
	[[5, 6, 7], [8, 9, 10], [11, 12, 13]]
]

aFiltered = oMx.FilterMatrices(aMatrices)
? len(aFiltered)
#--> 2

pf()

#===================#
#  EXTRACTED PARTS  #
#===================#

/*--- Extract matched parts

pr()

oMx = new stzMatrex("{size(3x3) & property(symmetric)}")

aMatrix = [
	[1, 2, 3],
	[2, 4, 5],
	[3, 5, 6]
]

oMx.Match(aMatrix)

aParts = oMx.MatchedParts()
? @@(aParts["Size"])
#--> [3, 3]

? aParts["Properties"]
#--> ["Square", "Symmetric"]

? @@NL(aParts)
#-->
'
[
	[
		"Size",
		[ 3, 3 ]
	],
	[
		"Matrix",
		[
			[ 1, 2, 3 ],
			[ 2, 4, 5 ],
			[ 3, 5, 6 ]
		]
	],
	[
		"Properties",
		[ "Square", "Symmetric" ]
	]
]
'

pf()

/*--- Get size from matched parts

pr()

oMx = new stzMatrex("{shape(square)}")

aMatrix = [[1, 2, 3, 4], [5, 6, 7, 8], [9, 10, 11, 12], [13, 14, 15, 16]]

oMx.Match(aMatrix)

? @@( oMx.Size() )
#--> [ 4, 4 ]

pf()

/*--- Get properties list

pr()

oMx = new stzMatrex("{property(identity)}")

aMatrix = [
	[1, 0, 0],
	[0, 1, 0],
	[0, 0, 1]
]

oMx.Match(aMatrix)
? oMx.Properties()
#--> ["Square", "Symmetric", "Diagonal", "Identity"]

pf()

#======================#
#  PATTERN CONSTRAINT  #
#======================#

/*--- Add constraint to pattern

pr()

oMx = new stzMatrex("{size(3x3)}")

aMatrix1 = [
	[1, 2, 3],
	[4, 5, 6],
	[7, 8, 9]
]

? oMx.Match(aMatrix1)
#--> TRUE

oMx.AddConstraint("property(symmetric)") # We have alos RemoveConstraing()

? oMx.Match(aMatrix1)
#--> FALSE

pf()

#========================#
#  DEBUG AND INSPECTION  #
#========================#

/*--- Enable debug

pr()

oMx = new stzMatrex("{Size(3x3)}")

aMatrix = [
	[1, 2, 3],
	[4, 5, 6],
	[7, 8, 9]
]

oMx.EnableDebug()
? oMx.Match(aMatrix)
#--> TRUE
'
Parsing inner pattern: Size(3x3)
>>> Processing part 1: [Size(3x3)]
>>> Parsing as single token
>> cContent: 3x3
>> cType: size
>>> Token result: [ [ "type", "size" ], [ "value", "3x3" ], [ "constraints", [ ] ], [ "min", 1 ], [ "max", 1 ], [ "negated", 0 ] ]
>>> Token length: 6
>>> Final token count: 1
=== Matching Matrix ===
Size: 3x3
Checking token type: size
Negated value: 0
Result before negation: 1
Final result: 1
Result: 1
'

pf()

/*--- Get pattern

pr()

oMx = new stzMatrex("{size(3x3) & property(identity)}")

? oMx.Pattern()
#--> {size(3x3) & property(identity)}

pf()

/*--- Get tokens

pr()

oMx = new stzMatrex("{shape(square) | shape(rectangular)}")

? @@NL( oMx.Tokens() )
#-->
'
[
	[
		[ "type", "alternation" ],
		[
			"alternatives",
			[
				[
					[ "type", "shape" ],
					[ "value", "square" ],
					[ "constraints", [  ] ],
					[ "min", 1 ],
					[ "max", 1 ],
					[ "negated", 0 ]
				],
				[
					[ "type", "shape" ],
					[ "value", "rectangular" ],
					[ "constraints", [  ] ],
					[ "min", 1 ],
					[ "max", 1 ],
					[ "negated", 0 ]
				]
			]
		],
		[ "negated", 0 ]
	]
]
'

pf()

/*--- Explain pattern

pr()

oMx = new stzMatrex("{size(2x2) & property(symmetric)}")

aMatrix = [[1, 2], [2, 3]]
oMx.Match(aMatrix)

? @@NL( oMx.Explain() )
#-->
'
[
	[ "Pattern", "{size(2x2) & property(symmetric)}" ],
	[ "TokenCount", 1 ],
	[
		"Tokens",
		[
			[
				[ "type", "conjunction" ],
				[
					"conditions",
					[
						[
							[ "type", "size" ],
							[ "value", "2x2" ],
							[ "constraints", [  ] ],
							[ "min", 1 ],
							[ "max", 1 ],
							[ "negated", 0 ]
						],
						[
							[ "type", "property" ],
							[ "value", "symmetric" ],
							[ "constraints", [  ] ],
							[ "min", 1 ],
							[ "max", 1 ],
							[ "negated", 0 ]
						]
					]
				],
				[ "negated", 0 ]
			]
		]
	],
	[
		"Target",
		[
			[ 1, 2 ],
			[ 2, 3 ]
		]
	],
	[
		"MatchedParts",
		[
			[
				"Size",
				[ 2, 2 ]
			],
			[
				"Matrix",
				[
					[ 1, 2 ],
					[ 2, 3 ]
				]
			],
			[
				"Properties",
				[ "Square", "Symmetric" ]
			]
		]
	]
]
'

pf()

#==============#
#  EDGE CASES  #
#==============#

/*--- Empty pattern

pr()

oMx = new stzMatrex("{}")

aMatrix = [[1, 2], [3, 4]]
? oMx.Match(aMatrix)
#--> TRUE

pf()

/*--- 1x1 matrix

pr()

oMx = new stzMatrex("{size(1x1)}")

aMatrix = [[42]]
? oMx.Match(aMatrix)
#--> TRUE

pf()

/*--- Large matrix
*/
pr()

oMx = new stzMatrex("{size(10x10)}")

aLarge = []
for i = 1 to 10
	aRow = []
	for j = 1 to 10
		aRow + (i * 10 + j)
	next
	aLarge + aRow
next

? oMx.Match(aLarge)
#--> TRUE

pf()
