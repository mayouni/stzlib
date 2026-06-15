load "../../stzBase.ring"
load "../_narrated.ring"

# M-S2 narrated regression suite for stzTable -- a representative core of
# the engine-backed columnar table (domain has ~245 classic blocks). Covers
# shape, column/row/cell access, column-presence, and copy independence.
# Deterministic.
#
# Regression guard: HasCol/HasColName used to lowercase the query then do a
# case-SENSITIVE Contains against the as-stored (upper) names, so it always
# returned FALSE; fixed to a case-insensitive compare.

Scenario("Shape and headers")
    Given("a 3-row country/income/population table")
    o = Tbl()
    Then("NumberOfRows is 3", o.NumberOfRows(), 3)
    Then("NumberOfCols is 3", o.NumberOfCols(), 3)
    Then("ColNames lists the headers", ListEq(o.ColNames(), [ "COUNTRY", "INCOME", "POPULATION" ]), TRUE)
EndScenario()

Scenario("Column, row and cell access")
    Given("the same table")
    o = Tbl()
    Then("Col('INCOME') returns the column", ListEq(o.Col("INCOME"), [ 25450, 18150, 5310 ]), TRUE)
    Then("Cell('INCOME',2) is China's income", o.Cell("INCOME", 2), 18150)
    Then("Row(1) is the USA row", ListEq(o.Row(1), [ "USA", 25450, 340.1 ]), TRUE)
EndScenario()

Scenario("Column presence (case-insensitive)")
    Given("the same table")
    o = Tbl()
    Then("HasCol('INCOME') is TRUE", o.HasCol("INCOME"), TRUE)
    Then("HasCol('income') is TRUE (case-insensitive)", o.HasCol("income"), TRUE)
    Then("HasCol('ZZZ') is FALSE", o.HasCol("ZZZ"), FALSE)
    Then("HasColNames([INCOME,COUNTRY]) is TRUE", o.HasColNames([ "INCOME", "COUNTRY" ]), TRUE)
EndScenario()

Scenario("Copy is independent")
    Given("a copy with column 1 removed")
    o = Tbl()
    oc = o.Copy()
    oc.RemoveCol(1)
    Then("the copy drops COUNTRY", ListEq(oc.ColNames(), [ "INCOME", "POPULATION" ]), TRUE)
    Then("the original still has 3 columns", o.NumberOfCols(), 3)
EndScenario()

Scenario("Case-insensitive cell find is codepoint-correct (multibyte)")
    Given("a column with accented cells")
    m = new stzTable([ [ "city", [ "Cafe" + AccE(), AccE() + "cole", "bar" ] ] ])
    Then("FindInColCS folds case across multibyte (cafe-acute)", ListEq(m.FindInColCS("city", "cafe" + AccE(), FALSE), [ 1 ]), TRUE)
    Then("FindInColCS matches an accented value case-insensitively", ListEq(m.FindInColCS("city", AccCapE() + "COLE", FALSE), [ 2 ]), TRUE)
EndScenario()

Summary()

func AccE
    return char(195) + char(169)

func AccCapE
    return char(195) + char(137)

func Tbl()
    return new stzTable([
        [ "COUNTRY", "INCOME", "POPULATION" ],
        [ "USA",   25450,  340.1 ],
        [ "China", 18150, 1430.1 ],
        [ "Japan",  5310,  123.2 ]
    ])

func ListEq aA, aE
    if len(aA) != len(aE) return FALSE ok
    nLen = len(aA)
    for i = 1 to nLen
        if isList(aA[i]) and isList(aE[i])
            if NOT ListEq(aA[i], aE[i]) return FALSE ok
        else
            if aA[i] != aE[i] return FALSE ok
        ok
    next
    return TRUE
