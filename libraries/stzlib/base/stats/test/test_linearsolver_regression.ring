# Integration regression for stzLinearSolver.
# Tests variable / constraint API + variable-type assignments
# (the addIntegerVariable + addBinaryVariable bug fixes).
#
# Run from base/stats/test/.

load "../../stzBase.ring"

nPsd = 0
nFld = 0
nTtl = 0

? "=== stzLinearSolver integration regression ==="

# ------------------------------------------------------------
# Construction + variables
# ------------------------------------------------------------
? ""
? "--- Variables ---"

oS = new stzLinearSolver
oS.addVariable("x", 0, 10)
oS.addVariable("y", 0, 5)

aV = oS.variables()
chk("2 variables added",             len(aV) = 2)
chk("First var name = 'x'",          aV[1][:name] = "x")
chk("First var type = continuous",   aV[1][:type] = "continuous")
chk("First var lower = 0",           aV[1][:lowerBound] = 0)
chk("First var upper = 10",          aV[1][:upperBound] = 10)

aN = oS.variableNames()
chk("variableNames = ['x', 'y']",    aN[1] = "x" and aN[2] = "y")

# ------------------------------------------------------------
# addIntegerVariable: type should actually be "integer"
# ------------------------------------------------------------
? ""
? "--- Integer variable ---"

oS2 = new stzLinearSolver
oS2.addIntegerVariable("z", 0, 100)
aV2 = oS2.variables()
chk("addInteger -> 1 var (not 2)",   len(aV2) = 1)
chk("Integer var type = 'integer'",  aV2[1][:type] = "integer")
chk("Integer var name correct",      aV2[1][:name] = "z")

# ------------------------------------------------------------
# addBinaryVariable: type should be "binary"
# ------------------------------------------------------------
? ""
? "--- Binary variable ---"

oS3 = new stzLinearSolver
oS3.addBinaryVariable("flag")
aV3 = oS3.variables()
chk("addBinary -> 1 var (not 2)",    len(aV3) = 1)
chk("Binary var type = 'binary'",    aV3[1][:type] = "binary")
chk("Binary var bounds 0..1",        aV3[1][:lowerBound] = 0 and aV3[1][:upperBound] = 1)

# ------------------------------------------------------------
# Mixed
# ------------------------------------------------------------
? ""
? "--- Mixed ---"

oM = new stzLinearSolver
oM.addVariable("a", 0, 10)
oM.addIntegerVariable("b", 0, 5)
oM.addBinaryVariable("c")
aM = oM.variables()
chk("3 variables added",             len(aM) = 3)
chk("Var 1 continuous",              aM[1][:type] = "continuous")
chk("Var 2 integer",                 aM[2][:type] = "integer")
chk("Var 3 binary",                  aM[3][:type] = "binary")

# ------------------------------------------------------------
# Bad input
# ------------------------------------------------------------
? ""
? "--- Bad input ---"

bRaised = 0
try
	oB = new stzLinearSolver
	oB.addVariable("x", 10, 5)  # upper < lower
catch
	bRaised = 1
done
chk("Upper < lower raises",          bRaised = 1)

# ------------------------------------------------------------
# Clear
# ------------------------------------------------------------
? ""
? "--- Clear ---"

oC = new stzLinearSolver
oC.addVariable("x", 0, 10)
oC.clear()
chk("After clear: 0 variables",      len(oC.variables()) = 0)

# ------------------------------------------------------------
# Summary
# ------------------------------------------------------------
? ""
? "=========================="
? "Total:  " + nTtl
? "Passed: " + nPsd
? "Failed: " + nFld
if nFld = 0
	? "ALL stzLinearSolver CHECKS PASSED!"
else
	? "SOME stzLinearSolver CHECKS FAILED!"
ok

func chk(cLabel, bCond)
	nTtl++
	if bCond
		nPsd++
	else
		nFld++
		? "  FAIL: " + cLabel
	ok
