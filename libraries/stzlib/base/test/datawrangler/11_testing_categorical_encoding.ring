# Narrative
# --------
# Testing categorical encoding
#
# Extracted from stzdatawranglertest.ring, block #11.

load "../../stzBase.ring"


pr()

# Categorical data for encoding
aCategoricalData = [
    ["Record1", "Red", "Large"],
    ["Record2", "Blue", "Medium"],
    ["Record3", "Green", "Small"],
    ["Record4", "Red", "Large"],
    ["Record5", "Blue", "Small"]
]
aCategoricalHeaders = ["ID", "Color", "Size"]

o1 = new stzDataWrangler(aCategoricalData, aCategoricalHeaders)

? BoxRound("BEFORE CATEGORICAL ENCODING")
aColumn = []
_nCategoricalDataLen_ = ring_len(aCategoricalData)
for i = 1 to _nCategoricalDataLen_
    aColumn + aCategoricalData[i][2]
next
? "• Data: " + @@(aColumn) + NL

# Apply label encoding

nEncoded = o1.EncodeCategories("label")
#~> We support three possible strategies of categorical encoding:
# - "label" (0,1,2...),
" - "onehot" (binary columns),
# - "ordinal" (custom order)

? BoxRound("AFTER LABEL ENCODING")
? "• Values encoded: " + nEncoded
? "• Encoded Color column:"
? @@(o1.GetData())

#-->
'
╭─────────────────────────────╮
│ BEFORE CATEGORICAL ENCODING │
╰─────────────────────────────╯
• Data: [ "Red", "Blue", "Green", "Red", "Blue" ]

╭──────────────────────╮
│ AFTER LABEL ENCODING │
╰──────────────────────╯
• Values encoded: 10
• Encoded Color column:
[ [ 0, 0, 0 ], [ 1, 1, 1 ], [ 2, 2, 2 ], [ 3, 0, 0 ], [ 4, 1, 2 ] ]
'

pf()
# Executed in 0.02 second(s) in Ring 1.22

#==================================#
#  TEST SECTION 5: PLAN EXECUTION  #
#==================================#
