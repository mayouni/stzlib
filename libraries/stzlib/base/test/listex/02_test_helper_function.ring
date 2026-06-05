# Narrative
# --------
# #  TEST HELPER FUNCTION  #
#
# Extracted from stzlistextest.ring, block #2.

load "../../stzBase.ring"

pr()



func TestPattern(cPattern, aTestCases)
    Lx = new stzListex(cPattern)
    
    ? ""
    ? "Testing pattern: " + cPattern
    nLen = len(aTestCases)

    for i = 1 to nLen step 2
        pInput = aTestCases[i]
        cExpected = aTestCases[i+1]
        
        cInputStr = @@(pInput)
        bResult = Lx.Match(pInput)

	cActual = "FALSE"
	if bResult
		cActual = "TRUE"
	ok
        
	cStatus = "✗"
	if cActual = cExpected
		cStatus = "✓"
	ok

        ? "  " + cStatus + " Match(" + cInputStr + ") --> " + cActual + 
          iif(cActual != cExpected, " (Expected: " + cExpected + ")", "")
    next
    
    return

pf()
