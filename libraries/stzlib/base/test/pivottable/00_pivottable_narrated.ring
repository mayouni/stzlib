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

Scenario("The presentation setters survive the engine fast path")

    # -- WHY THIS SCENE EXISTS --
    #
    # stzPivotTable has two implementations: a Zig crossTab for the common shape
    # (one column label, one value, one or two row labels) and a Ring fallback for
    # everything else. _CanUseEngine() picks between them silently.
    #
    # SetTotalLabel, SetNullValue and SetColumnOrder were read only by the fallback.
    # So on the shape MOST pivots have, all three did nothing -- no error, no
    # warning, and the accessors kept reporting the values back. The setters worked
    # perfectly on the paths nobody took.
    #
    # Every check below is run on the ENGINE shape on purpose. Running it on a
    # three-row-label pivot would pass against the broken build.

    Given("a pivot small enough for the engine to take")

    Then("the engine really is the one answering", EngineTakesIt(), TRUE)

    # THE TOTALS CARRY THE CALLER'S WORD, in the column name and in the row label.
    # Both halves matter: the label is written in two places by two different lines.
    Then("the totals column is named GRAND", TotalColName("GRAND"), "GRAND")
    Then("...and so is the totals row", TotalRowLabel("GRAND"), "GRAND")
    Then("...while the default stays TOTAL", TotalColName(""), "TOTAL")

    # AN EMPTY CELL IS NOT A ZERO. Gabes sold nothing in 2023; that is a hole in the
    # data, and a reader who is shown 0 cannot tell it from a real zero.
    Then("an empty cell reads n/a when asked", HasNullMark("n/a"), TRUE)
    Then("...and reads 0 when not", HasNullMark(""), FALSE)

    # THE CALLER'S COLUMN ORDER, with the negative sibling: unasked, the columns
    # come out in their natural order, so the check above is not passing by accident.
    Then("2024 leads when the caller says so", FirstDataCol([ 2024, 2023 ]), "2024")
    Then("...and 2023 leads when they say that", FirstDataCol([ 2023, 2024 ]), "2023")
    Then("...and unasked, nothing is reordered", FirstDataCol([]), "2023")

    # SetColumnOrder was also the ONE setter here that did not drop the generated
    # result, so an order set after a first Show() was never applied.
    Then("an order set after generating still lands", OrderAppliedLate(), TRUE)
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

# ── the presentation-setter helpers ────────────────────────────────────────────
#
# Gabes has no 2023 row: that hole is what the null value fills.
func PresData()
    return [ [ :CITY, :YEAR, :SALES ],
        [ "Tunis", 2023, 10 ], [ "Tunis", 2024, 5 ],
        [ "Sfax",  2023, 20 ], [ "Gabes", 2024, 3 ] ]

func PresPivot(cTotal, cNull, paOrder, bTotals)
    _oP_ = new stzPivotTable(PresData())
    _oP_.SetRowLabels([ :CITY ])
    _oP_.SetColumnLabels([ :YEAR ])
    _oP_.SetValues([ :SALES ])
    _oP_.SetShowTotals(bTotals, bTotals)
    if cTotal != ""
        _oP_.SetTotalLabel(cTotal)
    ok
    if cNull != ""
        _oP_.SetNullValue(cNull)
    ok
    if len(paOrder) > 0
        _oP_.SetColumnOrder(paOrder)
    ok
    return _oP_

func EngineTakesIt()
    _oE_ = PresPivot("", "", [], FALSE)
    return _oE_._CanUseEngine()

func TotalColName(cLabel)
    _aC_ = PresPivot(cLabel, "", [], TRUE).ToTable().Content()
    return _aC_[len(_aC_)][1]

func TotalRowLabel(cLabel)
    _aC2_ = PresPivot(cLabel, "", [], TRUE).ToTable().Content()
    _aFirst_ = _aC2_[1][2]
    return _aFirst_[len(_aFirst_)]

func HasNullMark(cNull)
    _aC3_ = PresPivot("", cNull, [], FALSE).ToTable().Content()
    _nL_ = len(_aC3_)
    for _i_ = 2 to _nL_
        _aCells_ = _aC3_[_i_][2]
        _nC_ = len(_aCells_)
        for _j_ = 1 to _nC_
            if isString(_aCells_[_j_]) and _aCells_[_j_] = "n/a"
                return TRUE
            ok
        next
    next
    return FALSE

# the name of the first DATA column -- column 1 holds the row labels
func FirstDataCol(paOrder)
    _aC4_ = PresPivot("", "", paOrder, FALSE).ToTable().Content()
    return _aC4_[2][1]

func OrderAppliedLate()
    _oL_ = PresPivot("", "", [], FALSE)
    _cBefore_ = _oL_.ToTable().Content()[2][1]
    _oL_.SetColumnOrder([ 2024, 2023 ])
    return _oL_.ToTable().Content()[2][1] != _cBefore_
