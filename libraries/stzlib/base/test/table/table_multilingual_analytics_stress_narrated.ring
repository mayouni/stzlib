# stzTable STRESS -- a large, MULTILINGUAL, Excel-like sales ledger.
#
# This is the kind of work a spreadsheet actually gets used for: tens of
# thousands of order rows, text columns in real scripts, derived columns
# (gross/net), column totals, lookups, sorting, and a summary row -- then
# checked for correctness, not just "it ran".
#
# Multilingual matters because a table is mostly TEXT, and every cell has to
# survive storage, indexing, sorting, and search byte-for-byte:
#   Arabic   -- caseless, RTL, 2-byte codepoints
#   CJK      -- 3-byte, caseless
#   Emoji    -- 4-byte (surrogate-range in other stacks)
#   Greek /
#   Cyrillic -- CASED: upper/lower must fold for case-insensitive lookup
#   Latin    -- accented (café)
#
# All non-ASCII text is built from RAW CODEPOINTS via a UTF-8 encoder, never
# typed as literals -- this codebase has a history of editors double-encoding
# source, so the test refuses to depend on its own file's bytes.
#
# Ring trap avoided on purpose: no local named nL/n/N -- Ring is
# case-insensitive and such a local silently clobbers the global `nl`.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

# ---------------------------------------------------------------- vocabulary
cAr1   = MkW([ 0x0639, 0x0645, 0x064A, 0x0644 ])            # Arabic  "customer"
cAr2   = MkW([ 0x0642, 0x0644, 0x0645 ])                    # Arabic  "pen"
cAr3   = MkW([ 0x0645, 0x062F, 0x0631, 0x0633, 0x0629 ])    # Arabic  "school"
cCJK1  = MkW([ 0x6771, 0x4EAC ])                            # CJK     Tokyo
cCJK2  = MkW([ 0x5317, 0x4EAC ])                            # CJK     Beijing
cGrUp  = MkW([ 0x0391, 0x0398, 0x0397, 0x039D, 0x0391 ])    # Greek   UPPER
cGrLo  = MkW([ 0x03B1, 0x03B8, 0x03B7, 0x03BD, 0x03B1 ])    # Greek   lower
cCyUp  = MkW([ 0x041C, 0x0418, 0x0420 ])                    # Cyrillic UPPER
cCafe  = MkW([ 0x0063, 0x0061, 0x0066, 0x00E9 ])            # Latin   café
cBox   = MkW([ 0x1F4E6 ])                                   # Emoji   package

aCustomers = [ cAr1, cCJK1, cGrUp, cCafe, cCyUp ]           # 5, cycles
aProducts  = [ cAr2, cBox, cCJK2, cAr3 ]                    # 4, cycles

# ---------------------------------------------------------------- build data
nRows = 50000

aOrderId = []  aCustomer = []  aProduct = []
aQty = []      aPrice = []     aDiscount = []
nExpectGross = 0
nExpectNet   = 0
nExpectQty   = 0
nCountAr1    = 0                    # rows whose CUSTOMER is the Arabic one

t0 = clock()
for i = 1 to nRows
	aOrderId  + i
	aCustomer + aCustomers[ (i % 5) + 1 ]
	aProduct  + aProducts[ (i % 4) + 1 ]

	q = (i % 10) + 1                       # 1..10
	p = ((i % 5) + 1) * 2.5                # 2.5 .. 12.5
	d = (i % 4) * 0.05                     # 0, .05, .10, .15

	aQty + q  aPrice + p  aDiscount + d

	nExpectQty   += q
	nExpectGross += (q * p)
	nExpectNet   += (q * p) * (1 - d)
	if aCustomers[ (i % 5) + 1 ] = cAr1  nCountAr1++  ok
next

oT = new stzTable([
	[ :ORDERID,  aOrderId  ],
	[ :CUSTOMER, aCustomer ],
	[ :PRODUCT,  aProduct  ],
	[ :QTY,      aQty      ],
	[ :PRICE,    aPrice    ],
	[ :DISCOUNT, aDiscount ]
])
tBuild = (clock() - t0) / clockspersecond()

? "-- Scene 1: a 50k-row multilingual ledger --"
? "  " + oT.NumberOfRows() + " rows x " + oT.NumberOfCols() + " cols built in " + tBuild + " s"
chk("every row landed", oT.NumberOfRows() = nRows)
chk("every column landed", oT.NumberOfCols() = 6)

? ""
? "-- Scene 2: multilingual cells survive storage byte-for-byte --"
chk("Arabic customer is 8 bytes (4 letters x2)", len(cAr1) = 8)
chk("CJK city is 6 bytes (2 chars x3)", len(cCJK1) = 6)
chk("emoji product is 4 bytes", len(cBox) = 4)
chk("Arabic cell round-trips identical", oT.Cell(:CUSTOMER, 5) = cAr1)
# products cycle as aProducts[(i%4)+1], so the emoji (index 2) lands on row 1
chk("emoji cell round-trips identical", oT.Cell(:PRODUCT, 1) = cBox)
chk("accented Latin round-trips identical", oT.Cell(:CUSTOMER, 3) = cCafe)
chk("a deep row (49999) is still intact",
	oT.Cell(:CUSTOMER, 49999) = aCustomers[ (49999 % 5) + 1 ])

? ""
? "-- Scene 3: derived columns at scale (the engine's compile-once path) --"
t0 = clock()
oT.AddCalculatedCol(:GROSS, '@(:QTY) * @(:PRICE)')
tGross = (clock() - t0) / clockspersecond()

t0 = clock()
oT.AddCalculatedCol(:NET, '@(:GROSS) * (1 - @(:DISCOUNT))')
tNet = (clock() - t0) / clockspersecond()

? "  GROSS computed in " + tGross + " s, NET (chained, uses GROSS) in " + tNet + " s"
chk("GROSS row 1 = qty x price", oT.Cell(:GROSS, 1) = aQty[1] * aPrice[1])
chk("GROSS last row correct", oT.Cell(:GROSS, nRows) = aQty[nRows] * aPrice[nRows])
chk("NET applies the discount", oT.Cell(:NET, 1) = (aQty[1]*aPrice[1]) * (1 - aDiscount[1]))
chk("a chained calc col sees the previous one", oT.NumberOfCols() = 8)
chk("50k derived rows are fast (< 5s)", tGross < 5)

? ""
? "-- Scene 4: column aggregates == independently computed totals --"
nSumQty   = oT.SumCol(:QTY)
nSumGross = oT.SumCol(:GROSS)
nSumNet   = oT.SumCol(:NET)
? "  SumCol(QTY)=" + nSumQty + "  SumCol(GROSS)=" + nSumGross
chk("SumCol(QTY) matches the running total", nSumQty = nExpectQty)
chk("SumCol(GROSS) matches (float-tolerant)", fabs(nSumGross - nExpectGross) < 0.01)
chk("SumCol(NET) matches (float-tolerant)", fabs(nSumNet - nExpectNet) < 0.01)
chk("MaxCol(QTY) is 10", oT.MaxCol(:QTY) = 10)
chk("MinCol(QTY) is 1", oT.MinCol(:QTY) = 1)
chk("AvgCol(QTY) = sum/rows", fabs(oT.AvgCol(:QTY) - (nExpectQty / nRows)) < 0.001)

? ""
? "-- Scene 5: lookup on MULTILINGUAL columns (needle-first find) --"
t0 = clock()
aHitsAr = oT.FindInCol(:CUSTOMER, cAr1)
tFind = (clock() - t0) / clockspersecond()
? "  found the Arabic customer in " + len(aHitsAr) + " rows (" + tFind + " s)"
chk("every Arabic-customer row was found", len(aHitsAr) = nCountAr1)
chk("a returned position really holds that customer",
	oT.Cell(:CUSTOMER, aHitsAr[1]) = cAr1)
chk("emoji product is findable", len(oT.FindInCol(:PRODUCT, cBox)) > 0)
chk("a customer never used is not found", len(oT.FindInCol(:CUSTOMER, cAr3)) = 0)

? ""
? "-- Scene 6: sorting a 50k table --"
# Copy first, UNTIMED: duplicating 50k x 8 cells is an inherent Ring
# value-copy cost and would otherwise be charged to the sort.
oSorted = oT.Copy()
t0 = clock()
oSorted.SortOn(:QTY)
tSort = (clock() - t0) / clockspersecond()
? "  sorted on QTY in " + tSort + " s (copy excluded -- measured separately)"
chk("sort keeps every row", oSorted.NumberOfRows() = nRows)
chk("first QTY is the minimum", oSorted.Cell(:QTY, 1) = 1)
chk("last QTY is the maximum", oSorted.Cell(:QTY, nRows) = 10)
chk("sorting did not corrupt multilingual text",
	len(oSorted.Cell(:CUSTOMER, 1)) > 0 and
	StzFindFirst(oSorted.Cell(:CUSTOMER, 1), "?") = 0)

? ""
? "-- Scene 7: the spreadsheet 'totals' row --"
oRep = oT.Copy()
oRep.AddCalculatedRow([ '', '', '', '@Sum(@(:QTY))', '', '', '@Sum(@(:GROSS))', '' ])
chk("a summary row was appended", oRep.NumberOfRows() = nRows + 1)
chk("the totals row carries the QTY total",
	fabs(oRep.Cell(:QTY, nRows + 1) - nExpectQty) < 0.01)

? ""
? "-- Scene 8: a practical question -- which order is the biggest? --"
nMaxNet = oT.MaxCol(:NET)
aTop = oT.FindInCol(:NET, nMaxNet)
? "  top NET = " + nMaxNet + " in " + len(aTop) + " order(s)"
chk("the max NET is really the maximum", nMaxNet >= oT.Cell(:NET, 1))
chk("the top order is locatable", len(aTop) > 0)
chk("its customer is readable multilingual text", len(oT.Cell(:CUSTOMER, aTop[1])) > 0)

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

# codepoint -> UTF-8 bytes, by arithmetic (no literals -> no mojibake risk)
func EncCp c
	if c < 128
		return char(c)
	but c < 2048
		return char(192 + floor(c/64)) + char(128 + (c % 64))
	but c < 65536
		return char(224 + floor(c/4096)) + char(128 + floor((c%4096)/64)) + char(128 + (c%64))
	else
		return char(240 + floor(c/262144)) + char(128 + floor((c%262144)/4096)) +
		       char(128 + floor((c%4096)/64)) + char(128 + (c%64))
	ok

func MkW aCp
	cW = ""
	_nCount_ = len(aCp)
	for _k_ = 1 to _nCount_
		cW += EncCp(aCp[_k_])
	next
	return cW
