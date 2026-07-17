# stzTableAggregator CALCULATED COLUMN -- engine-first, with Ring fallback.
#
# A calculated column evaluates a formula for every row. The old path built
# the formula string once and then re-ran the Ring COMPILER with eval() on
# EACH row (~11us/row -- seconds of pure compile overhead on a large table).
#
# The formula now lowers @(:ColName) to the engine's per-row cell reference
# This[colIndex] and is evaluated COMPILED ONCE, engine-side, over all rows
# (StzEngineListEvalRows). A formula the engine DSL cannot compile -- or one
# that references a non-numeric column -- falls back to the classic eval path,
# so nothing regresses.
#
# This suite proves: (1) engine arithmetic is correct, (2) chained calc cols
# see earlier ones, (3) the string / non-arithmetic fallback keeps its old
# semantics, (4) insert position is honoured, (5) it scales -- 50k rows
# compute in a blink, which the per-row-compile path never could.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

? "-- Scene 1: engine arithmetic over several columns --"

o1 = new stzTableAggregator([
	[ :A,   [ 1, 3, 10, 100 ] ],
	[ :B,   [ 2, 4, 20,   5 ] ]
])

o1.AddCalculatedCol(:SUM, '@(:A) + @(:B)')
chk("A + B computed per row", @@(o1.Col(:SUM)) = @@([ 3, 7, 30, 105 ]))

o1.AddCalculatedCol(:EXPR, '@(:A) * @(:B) - 1')
chk("A * B - 1 computed per row", @@(o1.Col(:EXPR)) = @@([ 1, 11, 199, 499 ]))

o1.AddCalculatedCol(:SCALED, '@(:A) * 1000 + @(:B)')
chk("mixing a column with a literal", @@(o1.Col(:SCALED)) = @@([ 1002, 3004, 10020, 100005 ]))

? "  SUM    -> " + @@( o1.Col(:SUM) )
? "  EXPR   -> " + @@( o1.Col(:EXPR) )
? "  SCALED -> " + @@( o1.Col(:SCALED) )

? ""
? "-- Scene 2: a chained calc col sees the one added before it --"

# When SUM was inserted it became a real column, so a later formula may
# reference it -- lowered to This[<its index>] and evaluated engine-side.
o1.AddCalculatedCol(:DOUBLESUM, '@(:SUM) * 2')
chk("a calc col referencing an earlier calc col", @@(o1.Col(:DOUBLESUM)) = @@([ 6, 14, 60, 210 ]))
? "  DOUBLESUM -> " + @@( o1.Col(:DOUBLESUM) )

? ""
? "-- Scene 3: insert position is honoured --"

o2 = new stzTableAggregator([
	[ :X, [ 5, 6 ] ],
	[ :Y, [ 7, 8 ] ]
])
o2.InsertCalculatedCol(2, :MID, '@(:X) + @(:Y)')
# (the table stores column names lower-cased; lookups stay case-insensitive)
chk("calc col inserted at position 2", lower(o2.ColName(2)) = "mid")
chk("... with the right values", @@(o2.Col(:MID)) = @@([ 12, 14 ]))
chk("... and the original columns shifted",
	lower(o2.ColName(1)) = "x" and lower(o2.ColName(3)) = "y")

? ""
? "-- Scene 4: FALLBACK keeps non-arithmetic semantics --"

o3 = new stzTableAggregator([
	[ :N,    [ 1, 2, 3 ] ],
	[ :WORD, [ "al", "be", "ce" ] ]
])

# WORD is a string column: the numeric guard sends this to the Ring fallback,
# where '+' is string concatenation -- NOT the engine's numeric coercion.
o3.AddCalculatedCol(:TAG, '@(:WORD) + "-x"')
chk("a string-concat formula falls back and concatenates",
	@@(o3.Col(:TAG)) = @@([ "al-x", "be-x", "ce-x" ]))
? "  TAG -> " + @@( o3.Col(:TAG) )

# A Ring builtin the engine DSL does not implement: also the fallback path.
o3.AddCalculatedCol(:UP, 'upper(@(:WORD))')
chk("a Ring-only function falls back and still computes",
	@@(o3.Col(:UP)) = @@([ "AL", "BE", "CE" ]))
? "  UP  -> " + @@( o3.Col(:UP) )

# Numeric column, still correct after the fallback cases above.
o3.AddCalculatedCol(:N2, '@(:N) * @(:N)')
chk("a numeric formula beside string ones still uses the engine",
	@@(o3.Col(:N2)) = @@([ 1, 4, 9 ]))

? ""
? "-- Scene 5: it scales -- 50k rows compute in a blink --"

nBig = 50000
aColA = []
aColB = []
nExpectSum = 0
for i = 1 to nBig
	aColA + i
	aColB + (i * 2)
	nExpectSum += (i + (i * 2))     # expected total of the A+B column
next

oBig = new stzTableAggregator([ [ :A, aColA ], [ :B, aColB ] ])

t0 = clock()
oBig.AddCalculatedCol(:C, '@(:A) + @(:B)')
tCalc = (clock() - t0) / clockspersecond()

aC = oBig.Col(:C)
nGotSum = 0
nLenC = len(aC)
for i = 1 to nLenC
	nGotSum += aC[i]
next

? "  " + nBig + " rows, calculated column built in " + tCalc + " s"
chk("every one of 50k rows was computed", len(aC) = nBig)
chk("the 50k-row column totals correctly", nGotSum = nExpectSum)
chk("first and last rows are right", aC[1] = 3 and aC[nBig] = (nBig * 3))
chk("50k rows compiled ONCE, not 50k times (fast)", tCalc < 3)

? ""
? "=========================================="
? "TOTAL: " + (nPass + nFail) + " assertions, " + nPass + " pass, " + nFail + " fail"
? "=========================================="

pf()

func chk cLabel, bCond
	if bCond
		nPass++
		? "  [OK] " + cLabel
	else
		nFail++
		? "  [FAIL] " + cLabel
	ok
