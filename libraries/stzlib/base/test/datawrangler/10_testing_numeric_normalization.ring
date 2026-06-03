# Narrative
# --------
# Testing numeric normalization
#
# Extracted from stzdatawranglertest.ring, block #10.
#ERR Error (R20) : Calling function with extra number of parameters

load "../../stzBase.ring"


pr()

# Numeric data for normalization
aNumericData = [
    ["Sample1", 100, 0.5],
    ["Sample2", 200, 1.5],
    ["Sample3", 300, 2.5],
    ["Sample4", 150, 1.0],
    ["Sample5", 250, 2.0]
]
aNumericHeaders = ["Sample", "Value1", "Value2"]

o1 = new stzDataWrangler(aNumericData, aNumericHeaders)

? BoxRound("BEFORE NORMALIZATION")

aColumn = []
for i = 1 to len(aNumericData)
    aColumn + aNumericData[i][2]
next
? "• Data: " + @@(aColumn) + NL

# Normalize using min-max scaling
nNormalized = o1.NormalizeNumeric("minmax")
? BoxRound("AFTER MIN-MAX NORMALIZATION")
? "• Values normalized: " + nNormalized
? "• Normalized Value1 column:"
? @@( o1.GetData() ) + NL

# Test Z-score normalization
o2 = new stzDataWrangler(aNumericData, aNumericHeaders)
o2.NormalizeNumeric("zscore")
? BoxRound("Z-SCORE NORMALIZATION")
? @@( o2.GetData() )

#-->
'
╭──────────────────────╮
│ BEFORE NORMALIZATION │
╰──────────────────────╯
[ 100, 200, 300, 150, 250 ]

╭─────────────────────────────╮
│ AFTER MIN-MAX NORMALIZATION │
╰─────────────────────────────╯
• Values normalized: 10
• Normalized Value1 column:
[ [ "Sample1", 0, 0 ], [ "Sample2", 0.50, 0.50 ], [ "Sample3", 1, 1 ], [ "Sample4", 0.25, 0.25 ], [ "Sample5", 0.75, 0.75 ] ]

Z-SCORE NORMALIZATION:
[ 0.50, 1.50, 2.50, 1, 2 ]
'

pf()
# Executed in 0.04 second(s) in Ring 1.22
