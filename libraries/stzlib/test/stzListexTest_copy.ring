load "../max/stzmax.ring"


#===================================================================#
#           LISTEX -  SOFTANZA LIST REGEX ENGINE - TEST SUITE        #
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

? "===== END OF TEST SUITE ====="

proff()
# Executed in 1.60 second(s) in Ring 1.22

/*===============================#
#  GROUP 6 : NEGATION PATTERNS  #
#===============================#

TestPattern("[@!N]", [
	[ 10 ], "FALSE",
	[ "hello" ], "TRUE"
])

TestPattern("[@!S]", [
	[ "hello" ], "FALSE",
	[ 10 ], "TRUE",
	[ [1, 2, 3] ], "TRUE"
])


TestPattern('[@!L]', [
	[ [1, 2, 3] ], "FALSE",
	[ 10 ], "TRUE",
	[ "hello" ], "TRUE"
])

TestPattern("[@N, @!N]", [
	[ 10, "hello" ], "TRUE",
	[ 10, 20 ], "FALSE",
	[ "hello", 10 ], "FALSE"
])

/*=================================#
#  GROUP 7 : ALTERNATION PATTERN  #
#=================================#

TestPattern("[(@N|@S)]", [
	[ 10 ], "TRUE",
	[ "hello" ], "TRUE",
	[ [1, 2, 3] ], "FALSE"
])

TestPattern("[ (@N|@S), (@L|@N) ]", [
	[ 10, 20 ], "TRUE",
	[ "hello", [1, 2, 3] ], "TRUE",
	[ 10, [1, 2, 3] ], "TRUE",
	[ "hello", "world" ], "FALSE"
])

TestPattern("[ ( @N{1;2;3} | @S ) ]", [
	[ 1 ], "TRUE",
	[ 2 ], "TRUE",
	[ "hello" ], "TRUE",
	[ 4 ], "FALSE"
])

TestPattern("[ (@N|@S), @!S ]", [
	[ 10, [1, 2, 3] ], "TRUE",
	[ "hello", [1, 2, 3] ], "TRUE",
	[ 10, "hello" ], "FALSE",
	[ "hello", 10 ], "TRUE"
])

/*===========================#
#  GROUP 8 - NAMED CAPTURES  #
/*===========================#
 */

# A list starting with any number of numbers (captured using <num>),
# then comes an item which is either a string or a number (<str>),
# and finally, it ends with a binary value 0 or 1 (<bin>)

Lx("[ <num>(@N), <str>(@S|@N)*, <bin>(@N{0; 1}) ]") {
	? Match([ 10, 20, 30, "A", "B", 1 ]) #--> TRUE
	? CapturedValuesXT()
	#--> [
	# 	:num = [ 10, 20, 30 ],
	# 	:str = [ "A", "B" ],
	# 	:bin = 1
	# ]

	? CapturedValuesByName(:num)
	#--> [ 10, 20, 30 ]
}

# a name is written just before the group defined by ( and ).
# a group can be prefixed by any quantifier (*, +, etc)


/*
Testing pattern: [(?<num>@N)]
----------------

✓ Match([ 10 ]) --> TRUE
✓ GetCapture("num") --> [10]
✓ Match([ "hello" ]) --> FALSE

Testing pattern: [(?<values>@N+)]
----------------

✓ Match([ 10, 20, 30 ]) --> TRUE
✓ GetCapture("values") --> [10, 20, 30]
✓ Match([ "hello" ]) --> FALSE

Testing pattern: [(?<first>@S), (?<second>@N)]
----------------

✓ Match([ "hello", 10 ]) --> TRUE
✓ GetCapture("first") --> ["hello"]
✓ GetCapture("second") --> [10]
✓ Match([ 10, "hello" ]) --> FALSE

Testing pattern: [(?<mixed>(@N|@S)+)]
----------------

✓ Match([ 10, "hello", 20 ]) --> TRUE
✓ GetCapture("mixed") --> [10, "hello", 20]
✓ Match([ [1, 2, 3] ]) --> FALSE

Testing pattern: [(?<outer>@N, (?<inner>@S))]
----------------

✓ Match([ 10, "hello" ]) --> TRUE
✓ GetCapture("outer") --> [10, "hello"]
✓ GetCapture("inner") --> ["hello"]

/*=======================#
#  TEST HELPER FUNCTION  #
#------------------------#
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

func RunCaptureTest(cTestName, cPattern, aTestList, cCaptureName, aExpectedCapture)
    oListex = Lx(cPattern)
    
    ? ""
    ? "Testing pattern: " + cPattern
    ? "----------------" + NL
? ">> " + @@(aTestList)
? ">> " + @@(aExpectedCapture) + nl
    for i = 1 to len(aTestList)
        pInput = aTestList[i]
        cInputStr = @@(pInput)
        
        bResult = oListex.Match(pInput)
        cActual = "FALSE"
        
        if bResult and oListex.HasCapture(cCaptureName)
            aCapture = oListex.GetCapture(cCaptureName)
            bMatched = CompareCaptures(aCapture, aExpectedCapture[i])
            cActual = "TRUE"
        else
            bMatched = false
        ok

        cStatus = "✗"
        if bMatched
            cStatus = "✓"
        ok

        ? "  " + cStatus + " Match(" + cInputStr + ") --> " + cActual + 
          iif(!bMatched, " (Expected: " + @@(aExpectedCapture[i]) + ")", "")
    next
    
    return
end
