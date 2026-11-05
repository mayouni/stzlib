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

Scenario("Two column labels take the Ring path, and it runs")
    # The engine takes one column label; two go to the Ring fallback, where a
    # bare split(), trim(), Min() and Max() reached stzList's OWN methods and
    # raised R20 "Calling function with extra number of parameters" on every
    # such table (fixed 2026-11-05).
    Then("MIN generates", TwoColsRun("MIN", FALSE), "ok")
    Then("MAX generates", TwoColsRun("MAX", FALSE), "ok")
    Then("...and the table draws", TwoColsRun("SUM", TRUE), "ok")

    # THE FIRST DATA ROW COUNTS. The fallback read the source table from row 2,
    # as if row 1 were its header -- but stzTable numbers DATA rows from 1, so
    # every two-column pivot lost its first row: North's Widget/2023 read 50,
    # not 100 + 50, and every total was short by 100.
    Then("North's Widget/2023 cell holds both rows (100 + 50)", TwoColsCell("Widget_2023", 1), 150)
    Then("...South's Gadget/2024 is unchanged", TwoColsCell("Gadget_2024", 2), 70)
    Then("...and the grand total counts all three rows", TwoColsCell("SUM", 3), 220)
EndScenario()

Scenario("Two column labels are drawn as a grid whose rules meet the lines")
    # Each row of the old drawing chose its junctions by POSITION in the full
    # list of second-label values, so a group holding only some of them got
    # a stray separator (┬│, ┼┼, ││), and the rule under the first heading
    # row began and ended on a bare │. The grid reads every junction from
    # the cell edges directly above and below the rule (fixed 2026-11-05).
    cHgUneven = TwoColsPivot(UnevenData(), [ :REGION ], "SUM")._PivotTwoColLabelsText(0, 1)
    Then("the box of a pivot whose products hold one year each", cHgUneven, UnevenBox())

    cHgFull = TwoColsPivot(FullData(), [ :REGION ], "SUM")._PivotTwoColLabelsText(0, 1)
    Then("...a rule branches DOWN inside a group and CROSSES between groups",
        StzSplit(cHgFull, char(10))[3], "├────────┼──────┬──────┼──────┬──────┼─────┤")

    cHgTwoRows = TwoColsPivot(FullData(), [ :REGION, :CITY ], "SUM")._PivotTwoColLabelsText(0, 1)
    cHgXT = TwoColsPivot(FullData(), [ :REGION, :CITY ], "SUM")._PivotTwoColLabelsText(1, 0)
    Then("no stray junction in any of the four boxes",
        NoStrayJunction([ cHgUneven, cHgFull, cHgTwoRows, cHgXT ]), TRUE)
    Then("with two row labels, a rule separates the two regions (three rules begin a line)",
        LinesStartingWith(cHgTwoRows, "├"), 3)
    Then("ShowXT closes each region with its subtotal", Occurrences("│    SUM │", cHgXT), 2)
    Then("...and without the grand total the box is the last thing drawn",
        StzLeft(LastLine(cHgXT), 1), "╰")
    cHgAvgBox = TwoColsPivot(MixedData(), [ :REGION, :CITY ], "AVG")._PivotTwoColLabelsText(1, 0)
    Then("every line of the box is equally wide in characters, with a non-ASCII city",
        EquallyWide(cHgAvgBox), TRUE)
    Then("ShowXT draws a pivot with one row label (it raised R3 before)",
        StzLeft(TwoColsPivot(FullData(), [ :REGION ], "SUM")._PivotTwoColLabelsText(1, 1), 1), "╭")
EndScenario()

Scenario("A total aggregates the source rows it covers, as a cell does")
    # Row and column totals aggregated the pivot's CELLS: an AVG total was an
    # average of averages, a COUNT row total was the first cell's count and a
    # COUNT column total a count of cells (fixed 2026-11-05).
    oHgAvg = TwoColsPivot(MixedData(), [ :REGION, :CITY ], "AVG")
    Then("the AVG grand total is the average of the five amounts (290 / 5)", PivotColumn(oHgAvg, "AVG")[5], 58)
    Then("...not 61.25, the average of the four row averages", PivotColumn(oHgAvg, "AVG")[5] != 61.25, TRUE)
    oHgCount = TwoColsPivot(UnevenData(), [ :REGION ], "COUNT")
    Then("a COUNT row total counts the row's source rows", PivotColumn(oHgCount, "COUNT")[1], 2)
    Then("...and the COUNT grand total counts them all", PivotColumn(oHgCount, "COUNT")[3], 4)
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

# Generates, and draws when asked, a pivot with TWO column labels; answers
# "ok" or the error raised.
func TwoColsRun(cAgg, bShow)
    oTc = new stzPivotTable([ [ :REGION, :PRODUCT, :YEAR, :AMOUNT ],
        [ "North", "Widget", 2023, 100 ], [ "North", "Widget", 2023, 50 ],
        [ "South", "Gadget", 2024, 70 ] ])
    oTc.Analyze(:AMOUNT, :with = cAgg)
    oTc.SetRowsBy([ :REGION ])
    oTc.SetColsBy([ :PRODUCT, :YEAR ])
    try
        oTc.Generate()
        if bShow
            oTc.Show()
        ok
    catch
        return cCatchError
    done
    return "ok"

# The SUM pivot of TwoColsRun's data: the cell at row nRow of the result
# column named cCol, or "" when there is no such column.
func TwoColsCell(cCol, nRow)
    oTc = new stzPivotTable([ [ :REGION, :PRODUCT, :YEAR, :AMOUNT ],
        [ "North", "Widget", 2023, 100 ], [ "North", "Widget", 2023, 50 ],
        [ "South", "Gadget", 2024, 70 ] ])
    oTc.Analyze(:AMOUNT, :with = "SUM")
    oTc.SetRowsBy([ :REGION ])
    oTc.SetColsBy([ :PRODUCT, :YEAR ])
    oTc.Generate()
    aTc = oTc.ToTable().Content()
    nTc = len(aTc)
    for iTc = 1 to nTc
        if aTc[iTc][1] = cCol
            return aTc[iTc][2][nRow]
        ok
    next
    return ""

# ── the grid helpers ───────────────────────────────────────────────────────────

# A generated pivot over aData, with two column labels: PRODUCT and YEAR.
func TwoColsPivot(aData, aRows, cAgg)
    oTp = new stzPivotTable(aData)
    oTp.Analyze(:AMOUNT, :with = cAgg)
    oTp.SetRowsBy(aRows)
    oTp.SetColsBy([ :PRODUCT, :YEAR ])
    oTp.Generate()
    return oTp

# Each product sold in one year only: the shape that drew stray junctions.
func UnevenData()
    return [ [ :REGION, :PRODUCT, :YEAR, :AMOUNT ],
        [ "North", "Widget", 2023, 100 ], [ "North", "Gadget", 2024, 50 ],
        [ "South", "Widget", 2023, 70 ], [ "South", "Gadget", 2024, 30 ] ]

# Each product sold in both years; North has two cities.
func FullData()
    return [ [ :REGION, :CITY, :PRODUCT, :YEAR, :AMOUNT ],
        [ "North", "Oslo", "Widget", 2023, 100 ], [ "North", "Oslo", "Widget", 2024, 40 ],
        [ "North", "Oslo", "Gadget", 2023, 50 ], [ "North", "Bergen", "Gadget", 2024, 20 ],
        [ "South", "Rome", "Widget", 2023, 70 ], [ "South", "Rome", "Gadget", 2024, 30 ] ]

# The regions interleaved in the source, and a city that is not ASCII.
func MixedData()
    return [ [ :REGION, :CITY, :PRODUCT, :YEAR, :AMOUNT ],
        [ "South", "Rome", "Gadget", 2024, 30 ], [ "North", "Zürich", "Widget", 2023, 100 ],
        [ "South", "Milano", "Widget", 2023, 70 ], [ "North", "Oslo", "Gadget", 2023, 50 ],
        [ "North", "Oslo", "Widget", 2023, 40 ] ]

# The box UnevenData() draws, checked by eye on 2026-11-05.
func UnevenBox()
    return "╭────────┬────────┬────────┬─────╮" + char(10) +
           "│        │ Widget │ Gadget │     │" + char(10) +
           "├────────┼────────┼────────┼─────┤" + char(10) +
           "│ Region │  2023  │  2024  │ SUM │" + char(10) +
           "├────────┼────────┼────────┼─────┤" + char(10) +
           "│ North  │    100 │     50 │ 150 │" + char(10) +
           "│ South  │     70 │     30 │ 100 │" + char(10) +
           "╰────────┴────────┴────────┴─────╯" + char(10) +
           "     SUM │    170 │     80 │ 250 "

# TRUE when no box holds a junction the old drawing left behind.
func NoStrayJunction(acBoxes)
    acStray = [ "┬│", "┼┼", "││", "│─", "─│" ]
    nBoxes = len(acBoxes)
    for iB = 1 to nBoxes
        for iS = 1 to len(acStray)
            if len(StzFindCS(acStray[iS], acBoxes[iB], 1)) > 0
                return FALSE
            ok
        next
    next
    return TRUE

func LinesStartingWith(cText, cStart)
    acLines = StzSplit(cText, char(10))
    nCount = 0
    for iL = 1 to len(acLines)
        if StzLeft(acLines[iL], 1) = cStart
            nCount++
        ok
    next
    return nCount

func Occurrences(cNeedle, cText)
    return len(StzFindCS(cNeedle, cText, 1))

func LastLine(cText)
    acLines = StzSplit(cText, char(10))
    return acLines[len(acLines)]

# TRUE when every line of a box (no total row below it) has one length.
func EquallyWide(cText)
    acLines = StzSplit(cText, char(10))
    nWidth = StzLen(acLines[1])
    for iL = 2 to len(acLines)
        if StzLen(acLines[iL]) != nWidth
            return FALSE
        ok
    next
    return TRUE

# The values of the pivot's result column named cName.
func PivotColumn(oPivot, cName)
    aContent = oPivot.ToTable().Content()
    for iC = 1 to len(aContent)
        if aContent[iC][1] = cName
            return aContent[iC][2]
        ok
    next
    return []
