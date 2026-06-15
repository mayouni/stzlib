load "../../stzBase.ring"
load "../_narrated.ring"

# M-S2 narrated regression suite for stzMatrix. Element-level bulk ops are
# delegated to the Softanza Zig matrix engine (StzEngineMatrixUpdateRegion)
# -- this replaces the removed RingFastPro updateList() dependency, which
# made Add/Multiply crash R3. Deterministic.

Scenario("Dimensions")
    Given("a 3x3 matrix")
    o = Mtrx([ [1,2,3], [4,5,6], [7,8,9] ])
    Then("Rows is 3", o.Rows(), 3)
    Then("Cols is 3", o.Cols(), 3)
    Then("Size is [3,3]", ListEq(o.Size(), [ 3, 3 ]), TRUE)
EndScenario()

Scenario("Scalar add / multiply (whole matrix, via engine)")
    o = Mtrx([ [1,2,3], [4,5,6], [7,8,9] ])
    o.Add(10)
    Then("Add(10) lifts every cell", ListEq(o.Content(), [ [11,12,13], [14,15,16], [17,18,19] ]), TRUE)
    m = Mtrx([ [1,2], [3,4] ])
    m.MultiplyBy(2)
    Then("MultiplyBy(2) doubles every cell", ListEq(m.Content(), [ [2,4], [6,8] ]), TRUE)
EndScenario()

Scenario("Per-column and per-row add")
    c = Mtrx([ [1,2,3], [4,5,6] ])
    c.AddInCol(2, 100)
    Then("AddInCol(2,100) lifts column 2", ListEq(c.Content(), [ [1,102,3], [4,105,6] ]), TRUE)
    r = Mtrx([ [1,2,3], [4,5,6] ])
    r.AddInRow(1, 50)
    Then("AddInRow(1,50) lifts row 1", ListEq(r.Content(), [ [51,52,53], [4,5,6] ]), TRUE)
EndScenario()

Scenario("Per-column and per-row / multi-row multiply")
    c = Mtrx([ [1,1,1,1], [1,1,1,1], [1,1,1,1] ])
    c.MultiplyCol(2, 5)
    Then("MultiplyCol(2,5) scales column 2", ListEq(c.Content(), [ [1,5,1,1], [1,5,1,1], [1,5,1,1] ]), TRUE)
    r = Mtrx([ [1,1,1], [1,1,1], [1,1,1] ])
    r.MultiplyRow(2, 9)
    Then("MultiplyRow(2,9) scales row 2", ListEq(r.Content(), [ [1,1,1], [9,9,9], [1,1,1] ]), TRUE)
    rs = Mtrx([ [1,1], [1,1], [1,1] ])
    rs.MultiplyRows([1, 3], :By = 7)
    Then("MultiplyRows([1,3],7) scales rows 1 and 3 only", ListEq(rs.Content(), [ [7,7], [1,1], [7,7] ]), TRUE)
EndScenario()

Scenario("Determinant (engine, read-only)")
    Then("det [[1,2],[3,4]] is -2", Mtrx([ [1,2], [3,4] ]).Determinant(), -2)
    Then("det [[2,0],[0,3]] is 6", Mtrx([ [2,0], [0,3] ]).Determinant(), 6)
    Then("det of a 3x3 is -306", Mtrx([ [6,1,1], [4,-2,5], [2,8,7] ]).Determinant(), -306)
EndScenario()

Summary()

func Mtrx aRows
    return new stzMatrix(aRows)

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
