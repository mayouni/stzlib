load "../max/stzmax.ring"


#=======================================================#
#   LISTEX -  SOFTANZA LIST REGEX ENGINE - TEST SUITE   #
#=======================================================#

/*--

Lx = new stzListex('[ @S ]')
? Lx.Match([ 'Ring' ])
? @@( Lx.Tokens() )
#--> TRUE

#---
*/
pr()

? "#----------------------------------------#"
? "#  TEST GROUP 1: Basic Pattern Matching  #"
? "#----------------------------------------#"

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

/*---
*/
? ""
? "#-----------------------------------------#"
? "#  TEST GROUP 2: Pattern With Quantifier  #"
? "#-----------------------------------------#"

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

/*---
*/
? ""
? "#------------------------------------------------#"
? "#  TEST GROUP 1: Set Selection Pattern Matching  #"
? "#------------------------------------------------#"

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

/*---
*/
? ""
? "#----------------------------------------------#"
? "#  TEST GROUP 1: Complex Pattern Combinations  #"
? "#----------------------------------------------#"

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
	[1, 2, 3, 4, 5], "TRUE"
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

/*---
*/
? ""
? "#-----------------------------------------------#"
? "#  TEST GROUP 5: Edge Cases and Error Handling  #"
? "#-----------------------------------------------#"

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

/*---
*/
? ""
? "#-------------------------------------------#"
? "#  TEST GROUP 6: Negation Pattern Matching  #"
? "#-------------------------------------------#"

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


/*---
*/
? ""
? "#----------------------------------------------#"
? "#  TEST GROUP 7: Alternation Pattern Matching  #"
? "#----------------------------------------------#"

TestPattern("[@N|@S]", [
	[ 10 ], "TRUE",
	[ "hello" ], "TRUE",
	[ [1, 2, 3] ], "FALSE"
])

TestPattern("[ @N|@S, @L|@N ]", [
	[ 10, 20 ], "TRUE",
	[ "hello", [1, 2, 3] ], "TRUE",
	[ 10, [1, 2, 3] ], "TRUE",
	[ "hello", "world" ], "FALSE"
])

TestPattern("[ @N{1;2;3} | @S ]", [
	[ 1 ], "TRUE",
	[ 2 ], "TRUE",
	[ "hello" ], "TRUE",
	[ 4 ], "FALSE"
])

TestPattern("[ @N|@S, @!S ]", [
	[ 10, [1, 2, 3] ], "TRUE",
	[ "hello", [1, 2, 3] ], "TRUE",
	[ 10, "hello" ], "FALSE",
	[ "hello", 10 ], "TRUE"
])

proff()

/*=======================#
#  TEST HELPER FUNCTION  #
#------------------------#
*/
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
