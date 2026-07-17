# The aggregation layer, reachable from the class users actually instantiate.
#
# The aggregation methods (calculated columns, calculated rows, column
# aggregates) are DEFINED on the stzTableAggregator subclass. But every caller
# instantiates the base `new stzTable(...)` -- so those methods used to be
# unreachable (R14 "method without definition"), and 209_show.ring was a broken
# test because of it. Worse, some were broken even on the aggregator itself:
# its InsertCalculatedRow calls This.InsertRow (which lives on the SIBLING
# stzTableStructure and is unreachable from a sibling), and its
# FindCalculatedCols has a `new X().Method()` R13.
#
# The base now exposes the aggregation layer via forwarders (same pattern the
# base already uses for Show -> stzTableDisplay): heavy compute delegates to a
# throwaway aggregator/structure built from this table's content, while calc
# STATE (@anCalculatedCols / @anCalculatedRows) lives on THIS object so it
# persists across calls. This suite proves it all works from `new stzTable`.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

? "-- Scene 1: calculated columns from a bare stzTable --"

o = new stzTable([
	[ :COUNTRY,    [ "Tunisia", "Japan", "Brazil" ] ],
	[ :INCOME,     [ 1200, 40000, 9000 ] ],
	[ :POPULATION, [ 12, 125, 213 ] ]
])

# Note: division is real (float) arithmetic -- 9000/213 = 42.25..., not a
# truncated 42. Expected values are computed with Ring's own division so this
# asserts the engine matches Ring arithmetic exactly.
o.AddCalculatedCol(:PERCAPITA, '@(:INCOME) / @(:POPULATION)')
chk("AddCalculatedCol is reachable and correct",
	@@(o.Col(:PERCAPITA)) = @@([ 1200/12, 40000/125, 9000/213 ]))
chk("the calc col is tracked (position 4)", @@(o.FindCalculatedCols()) = @@([ 4 ]))
chk("CalculatedColNames reads our own state", @@(o.CalculatedColNames()) = @@([ "percapita" ]))
chk("CalculatedCols returns the column content", @@(o.CalculatedCols()) = @@([ [ 1200/12, 40000/125, 9000/213 ] ]))

? "  PERCAPITA -> " + @@(o.Col(:PERCAPITA))

? ""
? "-- Scene 2: a second calc col -- state PERSISTS across calls --"

o.InsertCalculatedCol(2, :DOUBLEINCOME, '@(:INCOME) * 2')
chk("InsertCalculatedCol at position 2", lower(o.ColName(2)) = "doubleincome")
chk("... values correct", @@(o.Col(:DOUBLEINCOME)) = @@([ 2400, 80000, 18000 ]))
chk("both calc cols now tracked", len(o.FindCalculatedCols()) = 2)

? ""
? "-- Scene 3: a FALLBACK calc col (Ring-only formula) still works --"

# StzCountryQ(...) is a Ring method call the engine DSL cannot compile, over a
# string column -- exactly like 209_show's Currency column. It must fall back
# to the classic eval path and still compute.
o.AddCalculatedCol(:SHOUT, 'upper(@(:COUNTRY))')
chk("a Ring-function calc col falls back and computes",
	@@(o.Col(:SHOUT)) = @@([ "TUNISIA", "JAPAN", "BRAZIL" ]))
? "  SHOUT -> " + @@(o.Col(:SHOUT))

? ""
? "-- Scene 4: column aggregates from a bare stzTable --"

t = new stzTable([ [ :PRICE, [ 1, 2, 3, 5 ] ], [ :QTY, [ 10, 20, 30, 40 ] ] ])
chk("SumCol",     t.SumCol(:PRICE) = 11)
chk("AvgCol",     t.AvgCol(:PRICE) = 2.75)
chk("MeanCol",    t.MeanCol(:PRICE) = 2.75)
chk("MinCol",     t.MinCol(:PRICE) = 1)
chk("MaxCol",     t.MaxCol(:PRICE) = 5)
chk("ProductCol", t.ProductCol(:QTY) = 240000)

? "  SumCol(:PRICE)=" + t.SumCol(:PRICE) + "  ProductCol(:QTY)=" + t.ProductCol(:QTY)

? ""
? "-- Scene 5: calculated ROWS from a bare stzTable --"

r = new stzTable([ [ :A, [ 1, 2, 3 ] ], [ :B, [ 10, 20, 30 ] ] ])
r.AddCalculatedRow([ '@Sum(@(:A))', '@Sum(@(:B))' ])
chk("AddCalculatedRow appends a summary row", r.NumberOfRows() = 4)
chk("... with the aggregated values", @@(r.Row(4)) = @@([ 6, 60 ]))
chk("... and the row is tracked", @@(r.FindCalculatedRows()) = @@([ 4 ]))

? "  summary row -> " + @@(r.Row(4))

? ""
? "-- Scene 6: InsertRow itself is now reachable on the base --"

s = new stzTable([ [ :A, [ 1, 3 ] ], [ :B, [ 10, 30 ] ] ])
s.InsertRow(2, [ 2, 20 ])
chk("InsertRow inserts at the right position", @@(s.Col(:A)) = @@([ 1, 2, 3 ]))

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
