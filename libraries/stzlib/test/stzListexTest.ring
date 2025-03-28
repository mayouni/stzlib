load "../max/stzmax.ring"

/*====================================#
#   LISTEX - TESTING MATCHES CAPTURE  #
#=====================================#

/*---

pr()

# [ 8, [ "tocolsfrom", [ 1, [ "to", 2 ] ] ] ]
# [ @N, [ @S, [ @N, [ @S, @N ] ] ] ]
oStr = new stzString(@@([ 8, [ "tocolsfrom", [ 1, [ "to", 2 ] ] ] ]))
acValues = ( oStr.RemoveManyQ([ "[ ", " ]" ]).Split(", ") )
nLenVal = len(acValues)
aValues = []
for i = 1 to nLenVal
	cCode = 'val = ' + acValues[i]
	eval(cCode)
	aValues + val
next

? @@NL(aValues)

/*--- GETTING MATCHED VALUES AFTER MATHCH IS DONE
*/
pr()

Lx = Lx('[ @N, [ @S, [ @N, [ @S, @N ] ] ] ]')

? Lx.Match([ 8, :ToColsFrom = [1, :To = 2] ])
#--> TRUE

? @@( Lx.Matches() ) + NL
#--> [ 8, "tocolsfrom", 1, "to", 2 ]

? @@NL( Lx.MatchesXT() )
#--> [ [ "@N", 8 ], [ "@S", "tocolsfrom" ], [ "@N", 1 ], [ "@S", "to" ], [ "@N", 2 ] ]


pf()

/*======================================================#
#   LISTEX - AUTOMATED TEST SUITE FOR PATTERN MATCHING  #
#=======================================================#

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

#---

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

#---

? ""
? "#------------------------------------------------#"
? "#  TEST GROUP 3: Set Selection Pattern Matching  #"
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

#---

? ""
? "#----------------------------------------------#"
? "#  TEST GROUP 4: Complex Pattern Combinations  #"
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

#---

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

#---

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

#---

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

#---

? ""
? "#---------------------------------#"
? "#  TEST GROUP 8: NESTED PATTERNS  #"
? "#---------------------------------#"

# Simple nested list with number constraints

TestPattern("[@N, [@N2], @N]", [
	[1, [2, 3], 4], "TRUE",
	[1, [2], 4], "FALSE",	# (inner list must have exactly 2 elements)
	[1, [2, 3, 4], 4], "FALSE" # (inner list must have exactly 2 elements)
])

# Mixed type nested list

TestPattern("[@N, [@S, @N], @S]", [
	[1, ["hello", 42], "world"], "TRUE",
	[1, ["hello"], "world"], "FALSE" # (inner list must have both string and number)
])

# Nested list with set constraints

TestPattern("[@N, [@N{10;20}], @N]", [
	[1, [10, 20], 5], "FALSE",
	[1, [15], 5], "FALSE",
	[1, [30], 5], "FALSE" # (inner number not in set)
])

# Complex nested pattern with multiple constraints

TestPattern("[@N, [@S, @N, [@N2]], @S]", [
	[1, ["hello", 42, [1, 2]], "world"], "TRUE",
	[1, ["hello", 42, [1]], "world"], "FALSE",  # (third nested list must have exactly 2 elements)
	[1, ["hello", 42, [1, 2, 3]], "world"], "FALSE"  # (third nested list must have exactly 2 elements)
])

# Nested list with quantifiers

TestPattern("[@N, [@N+], @N]", [
	[1, [10, 20, 30], 5], "TRUE",  # (one or more numbers in nested list)
	[1, [10], 5], "TRUE"  # (at least one number in nested list)
])

#---

? ""
? "#---------------------------------------#"
? "#  TEST GROUP 9: STEPPED RANGE PATTERN  #"
? "#---------------------------------------#"

# Basic stepped range tests
TestPattern("[@N{1-10:3}]", [
    [1], "TRUE",
    [4], "TRUE",
    [7], "TRUE",
    [10], "TRUE",
    [2], "FALSE",
    [3], "FALSE",
    [8], "FALSE",
    [11], "FALSE",
    ["text"], "FALSE"
])

# Stepped range with uniqueness constraint
TestPattern("[@N+{5-20:5}U]", [
    [5, 10, 15, 20], "TRUE",
    [5, 10, 15], "TRUE",
    [5, 10, 10, 15], "FALSE",
    [5, 5], "FALSE",
    [5, 25], "FALSE"
])

# Multiple instances with different steps
TestPattern("[@N{1-5:1}, @N{10-20:5}]", [
    [3, 15], "TRUE",
    [5, 10], "TRUE",
    [1, 20], "TRUE",
    [6, 15], "FALSE",
    [3, 12], "FALSE"
])

# Combining with other quantifiers
TestPattern("[@N*{2-10:2}]", [
    [2, 4, 6, 8, 10], "TRUE",
    [2, 6, 10], "TRUE",
    [4, 8], "TRUE",
    [2], "TRUE",
    [], "TRUE",
    [1, 3], "FALSE",
    [2, 3], "FALSE"
])

# Combining with alternation
TestPattern("[@N{1-9:2}|@S]", [
    [1], "TRUE",
    [3], "TRUE",
    [9], "TRUE",
    ["hello"], "TRUE",
    [2], "FALSE",
    [10], "FALSE"
])

# Complex pattern with stepped ranges
TestPattern("[@N+{1-10:3}, @S, @N?{50-100:25}]", [
    [1, 4, "text"], "TRUE",
    [7, 10, 1, "hello"], "TRUE",
    [7, "word", 75], "TRUE",
    [7, "word"], "TRUE",
    [2, "text"], "FALSE",
    [7, 11, "word"], "FALSE",
    ["word", 7], "FALSE"
])

# Nested patterns with stepped ranges
TestPattern("[[@N+{1-10:3}]]", [
    [[1, 4, 7]], "TRUE",
    [[10]], "TRUE",
    [[1, 4, 5]], "FALSE",
    [[2, 5, 8]], "FALSE",
    [1, 4, 7], "FALSE"
])

# Negated stepped range
# Matches any non-number or any number that is
# NOT in the set [2,5,8,11].

TestPattern("[@!N{2-12:3}]", [
    [2], "FALSE",
    [5], "FALSE",
    [8], "FALSE",

    [3], "TRUE",
    [6], "TRUE",
    [9], "TRUE"
])

#NOTES:
# - The negation is first applied only to the type check (e.g., "is this a number?")
# - Then, if the type check passes, we handle set membership separately

# - For negated tokens, uniqueness tracking is less relevant since we're matching what's NOT in the set
# - Uniqueness constraints are now only applied to non-negated tokens where appropriate

pf()
# Executed in 3.71 second(s) in Ring 1.22

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
