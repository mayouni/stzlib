load "../../stzBase.ring"
load "../_narrated.ring"

# M-S2 narrated regression suite for stzPivotTable.
#
# Regression guard: this domain was previously flagged for an intermittent
# R31 ("destroy object using self reference" via StzUpper in
# SetAggregateFunction) on COUNT for certain grouping shapes. The earlier
# @StzMid / GC fixes resolved it; this suite locks in COUNT/SUM/AVG/MIN/MAX
# over a two-key grouping, with and without totals, and is run for real.
# Deterministic.

Scenario("COUNT aggregation over REGION x PRODUCT")
    Given("4 sales rows (North/Widget x2, South/Widget, South/Gadget)")
    o = CountPivot()
    Then("North/Widget counts 2 rows", o.Value("North", "Widget"), 2)
    Then("South/Widget counts 1 row", o.Value("South", "Widget"), 1)
    Then("South/Gadget counts 1 row", o.Value("South", "Gadget"), 1)
EndScenario()

Scenario("SUM / AVG / MIN / MAX aggregations")
    Given("the same dataset")
    Then("SUM of North/Widget is 150 (100+50)", SumPivot().Value("North", "Widget"), 150)
    Then("AVG of North/Widget is 75", AvgPivot().Value("North", "Widget"), 75)
    Then("MIN of North/Widget is 50", MinPivot().Value("North", "Widget"), 50)
    Then("MAX of North/Widget is 100", MaxPivot().Value("North", "Widget"), 100)
EndScenario()

Scenario("Totals (the previously-crashing COUNT + totals path)")
    Given("COUNT with row/column totals enabled")
    o = CountPivotTotals()
    Then("North/Widget still counts 2", o.Value("North", "Widget"), 2)
    Then("the North row total is 2", o.RowTotal("North"), 2)
EndScenario()

Summary()

func Data()
    return [ [ :REGION, :PRODUCT, :AMOUNT ],
        [ "North", "Widget", 100 ], [ "North", "Widget", 50 ],
        [ "South", "Widget", 150 ], [ "South", "Gadget", 75 ] ]

func MakePivot(cAgg, bTotals)
    o = new stzPivotTable(Data())
    o.Analyze(:AMOUNT, :with = cAgg)
    o.By(:REGION, :and = :PRODUCT)
    o.SetShowTotals(bTotals, bTotals)
    o.Generate()
    return o

func CountPivot()       return MakePivot("COUNT", FALSE)
func SumPivot()         return MakePivot("SUM",   FALSE)
func AvgPivot()         return MakePivot("AVG",   FALSE)
func MinPivot()         return MakePivot("MIN",   FALSE)
func MaxPivot()         return MakePivot("MAX",   FALSE)
func CountPivotTotals() return MakePivot("COUNT", TRUE)
