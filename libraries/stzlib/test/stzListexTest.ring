load "../max/stzmax.ring"


#===================================================================#
#           LISTEX -  SOFTANZA LIST REGEX ENGINE - TEST SUITE               #
#===================================================================#

/*--

Lx = new stzListex('[ @S ]')
? Lx.Match([ 'Ring' ])
? @@( Lx.Tokens() )
#--> TRUE

/*------------------------------------------------------------------#
#  1. BASIC PATTERN MATCHING                                        #
#------------------------------------------------------------------#
*/

pr()

? "TEST GROUP 1: Basic Pattern Matching Tests"

# Basic single-token patterns

TestPattern("[@N]", [
	[1], "TRUE",
	[2.5], "TRUE",
	["hello"], "FALSE",
	[1, 2], "FALSE",
	[], "FALSE"
])

TestPattern("[@S]", [
	["hello"], "TRUE",
	[1], "FALSE",
	["hello", "world"], "FALSE",
	[], "FALSE"
])

TestPattern("[@L]", [
	[[1, 2]], "TRUE",
	[1], "FALSE",
	[[]], "TRUE",
	[], "FALSE"
])

TestPattern("[@$]", [
	[1], "TRUE",
	["hello"], "TRUE",
	[[1, 2]], "TRUE",
	[], "FALSE"
])

# Basic multi-token patterns

TestPattern("[@N, @S]", [
	[1, "hello"], "TRUE",
	["hello", 1], "FALSE",
	[1], "FALSE",
	[1, "hello", 2], "FALSE"
])

TestPattern("[@N, @N, @S]", [
	[1, 2, "hello"], "TRUE",
	[1, "hello"], "FALSE",
	[1, 2, 3], "FALSE"
])

/*------------------------------------------------------------------#
#  2. QUANTIFIER TESTS                                              #
#------------------------------------------------------------------#
*/
? ""
? "TEST GROUP 2: Quantifier Tests"

# Single-number quantifier

TestPattern("[@N2]", [
	[1, 2], "TRUE",
	[1], "FALSE",
	[1, 2, 3], "FALSE"
])

# Range quantifiers

TestPattern("[@N1-3]", [
	[1], "TRUE",
	[1, 2], "TRUE",
	[1, 2, 3], "TRUE",
	[1, 2, 3, 4], "FALSE",
	[], "FALSE"
])

# Special quantifiers

TestPattern("[@N+]", [
	[1], "TRUE",
	[1, 2, 3], "TRUE",
	[], "FALSE"
])

TestPattern("[@N*]", [
	[], "TRUE",
	[1], "TRUE",
	[1, 2, 3], "TRUE"
])

TestPattern("[@N?]", [
	[], "TRUE",
	[1], "TRUE",
	[1, 2], "FALSE"
])

# Mixed quantifiers

TestPattern("[@N2, @S+]", [
	[1, 2, "hello"], "TRUE",
	[1, 2, "hello", "world"], "TRUE",
	[1, "hello"], "FALSE"
])

/*------------------------------------------------------------------#
#  3. SET CONSTRAINT TESTS                                          #
#------------------------------------------------------------------#
*/
? ""
? "TEST GROUP 3: Set Constraint Tests"

# Basic set constraints

TestPattern("[@N{1; 2; 3}]", [
	[1], "TRUE",
	[2], "TRUE",
	[4], "FALSE",
	[1, 2], "FALSE"
])

TestPattern('[ @S{"hello"; "world"} ]', [
	["hello"], "TRUE",
	["world"], "TRUE",
	["other"], "FALSE"
])

# Unique sets

TestPattern("[@N2-3{1; 2; 3}U]", [
	[1, 2], "TRUE",
	[1, 2, 3], "TRUE",
	[1, 1], "FALSE",
	[1, 4], "FALSE"
])

# Sets with quantifiers

TestPattern("[@N+{1; 2; 3}]", [
	[1], "TRUE",
	[1, 2], "TRUE",
	[1, 2, 3], "TRUE",
	[4], "FALSE",
	[1, 4], "FALSE"
])

/*------------------------------------------------------------------#
#  4. COMPLEX PATTERN COMBINATIONS                                  #
#------------------------------------------------------------------#
*/
? ""
? "TEST GROUP 4: Complex Pattern Combinations"

# Complex nesting patterns

TestPattern("[@L{[1,2]; [1,4]}]", [
	[[1, 2]], "TRUE",
	[[3, 4]], "FALSE"
])

# Testing optimization capabilities

TestPattern("[@N1-2, @N0-3]", [
	[1], "TRUE",
	[1, 2], "TRUE",
	[1, 2, 3], "TRUE",
	[1, 2, 3, 4, 5], "FALSE"
])

# Combining multiple token types with quantifiers and sets

TestPattern('[ @N+{1; 2; 3}, @S{"hello"; "world"}, @L? ]', [
    [1, 2, "hello"], "TRUE",
    [3, "world"], "TRUE",
    [1, "hello", [1, 2]], "TRUE",
    [4, "hello"], "FALSE",
    [1, "other"], "FALSE",
    [1, "hello", [1], [2]], "FALSE"
])

/*------------------------------------------------------------------#
#  5. EDGE CASES AND ERROR HANDLING                                 #
#------------------------------------------------------------------#
*/
? ""
? "TEST GROUP 5: Edge Cases and Error Handling"

# Empty pattern handling

TestPattern("[]", [
	[], "TRUE",
	[1], "FALSE"
])

# Decimal numbers

TestPattern("[@N]", [
	[3.14], "TRUE",
	[-2.5], "TRUE"
])

# Nested lists with multiple levels

TestPattern("[@L]", [
	[[[1, 2], [3, 4]]], "TRUE"
])

# Very large quantifiers

TestPattern("[@N0-100]", [
	[], "TRUE",
	[1, 2, 3, 4, 5],
	"TRUE"
])

# Pattern with all token types

TestPattern("[@N, @S, @L, @$]", [
	[1, "hello", [1, 2], 42], "TRUE",
	[1, "hello", [1, 2]], "FALSE"
])

? ""
? "===== END OF TEST SUITE ====="

proff()
# Executed in 1.60 second(s) in Ring 1.22

/*------------------------------------------------------------------#
#  TEST HELPER FUNCTION                                             #
#------------------------------------------------------------------#
*/
func TestPattern(cPattern, aTestCases)
    Lx = new stzListex(cPattern)
    
    ? ""
    ? "Testing pattern: " + cPattern
    ? "----------------" + NL

    for i = 1 to len(aTestCases) step 2
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
